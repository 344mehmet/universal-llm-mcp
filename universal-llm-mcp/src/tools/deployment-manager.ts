/**
 * Universal LLM MCP - Cloud Deployment Manager
 * Netlify, Vercel, GitHub Pages dağıtımı
 */

import { spawn } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

export type DeploymentTarget = 'netlify' | 'vercel' | 'github-pages';

export interface DeploymentResult {
    success: boolean;
    url?: string;
    error?: string;
    logs: string[];
}

export class DeploymentManager {
    private cwd: string;

    constructor(cwd?: string) {
        this.cwd = cwd || process.cwd();
    }

    private async exec(command: string, args: string[]): Promise<{ stdout: string; stderr: string; code: number }> {
        return new Promise((resolve) => {
            const proc = spawn(command, args, { cwd: this.cwd, shell: true });
            let stdout = '';
            let stderr = '';

            proc.stdout?.on('data', (data) => { stdout += data.toString(); });
            proc.stderr?.on('data', (data) => { stderr += data.toString(); });

            proc.on('close', (code) => {
                resolve({ stdout, stderr, code: code || 0 });
            });
        });
    }

    /**
     * Netlify dağıtımı
     */
    async deployNetlify(options: {
        siteId?: string;
        authToken?: string;
        directory?: string;
        production?: boolean;
    } = {}): Promise<DeploymentResult> {
        const logs: string[] = [];

        try {
            // netlify-cli kontrol
            const { code } = await this.exec('npx', ['netlify', '--version']);
            if (code !== 0) {
                return { success: false, error: 'Netlify CLI bulunamadı', logs };
            }

            const args = ['netlify', 'deploy'];
            if (options.directory) args.push('--dir', options.directory);
            if (options.production) args.push('--prod');
            if (options.siteId) args.push('--site', options.siteId);

            logs.push(`Çalıştırılıyor: npx ${args.join(' ')}`);
            const result = await this.exec('npx', args);
            logs.push(result.stdout);

            // URL çıkar
            const urlMatch = result.stdout.match(/https:\/\/[^\s]+\.netlify\.app/);

            return {
                success: result.code === 0,
                url: urlMatch?.[0],
                logs,
            };
        } catch (error) {
            return { success: false, error: String(error), logs };
        }
    }

    /**
     * Vercel dağıtımı
     */
    async deployVercel(options: {
        token?: string;
        production?: boolean;
    } = {}): Promise<DeploymentResult> {
        const logs: string[] = [];

        try {
            const args = ['vercel'];
            if (options.production) args.push('--prod');
            if (options.token) args.push('--token', options.token);
            args.push('--yes'); // Confirm otomatik

            logs.push(`Çalıştırılıyor: npx ${args.join(' ')}`);
            const result = await this.exec('npx', args);
            logs.push(result.stdout);

            const urlMatch = result.stdout.match(/https:\/\/[^\s]+\.vercel\.app/);

            return {
                success: result.code === 0,
                url: urlMatch?.[0],
                logs,
            };
        } catch (error) {
            return { success: false, error: String(error), logs };
        }
    }

    /**
     * GitHub Pages dağıtımı
     */
    async deployGitHubPages(options: {
        branch?: string;
        directory?: string;
    } = {}): Promise<DeploymentResult> {
        const logs: string[] = [];
        const branch = options.branch || 'gh-pages';
        const dir = options.directory || 'dist';

        try {
            // gh-pages paketi ile
            logs.push('gh-pages ile dağıtım başlıyor...');
            const result = await this.exec('npx', [
                'gh-pages',
                '-d', dir,
                '-b', branch,
            ]);
            logs.push(result.stdout);

            return {
                success: result.code === 0,
                logs,
            };
        } catch (error) {
            return { success: false, error: String(error), logs };
        }
    }

    /**
     * Vercel config oluştur
     */
    generateVercelConfig(options: {
        framework?: string;
        buildCommand?: string;
        outputDirectory?: string;
    } = {}): void {
        const config = {
            version: 2,
            framework: options.framework,
            buildCommand: options.buildCommand || 'npm run build',
            outputDirectory: options.outputDirectory || 'dist',
        };

        fs.writeFileSync(
            path.join(this.cwd, 'vercel.json'),
            JSON.stringify(config, null, 2)
        );
    }

    /**
     * Netlify config oluştur
     */
    generateNetlifyConfig(options: {
        buildCommand?: string;
        publishDirectory?: string;
        redirects?: Array<{ from: string; to: string; status?: number }>;
    } = {}): void {
        let toml = `[build]
  command = "${options.buildCommand || 'npm run build'}"
  publish = "${options.publishDirectory || 'dist'}"
`;

        if (options.redirects?.length) {
            toml += '\n';
            for (const r of options.redirects) {
                toml += `[[redirects]]
  from = "${r.from}"
  to = "${r.to}"
  status = ${r.status || 200}
`;
            }
        }

        fs.writeFileSync(path.join(this.cwd, 'netlify.toml'), toml);
    }
}

// Singleton
let deployInstance: DeploymentManager | null = null;

export function getDeploymentManager(cwd?: string): DeploymentManager {
    if (!deployInstance) {
        deployInstance = new DeploymentManager(cwd);
    }
    return deployInstance;
}
