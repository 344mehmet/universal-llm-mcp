/**
 * Universal LLM MCP - Docker Entegrasyonu
 */

import { spawn } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

export class DockerManager {
    private cwd: string;

    constructor(cwd?: string) {
        this.cwd = cwd || process.cwd();
    }

    private async exec(args: string[]): Promise<string> {
        return new Promise((resolve, reject) => {
            const proc = spawn('docker', args, { cwd: this.cwd });
            let stdout = '';
            let stderr = '';

            proc.stdout?.on('data', (data) => { stdout += data.toString(); });
            proc.stderr?.on('data', (data) => { stderr += data.toString(); });

            proc.on('close', (code) => {
                if (code === 0) {
                    resolve(stdout.trim());
                } else {
                    reject(new Error(stderr || `Docker error: ${code}`));
                }
            });
        });
    }

    /**
     * Docker mevcut mu?
     */
    async isAvailable(): Promise<boolean> {
        try {
            await this.exec(['--version']);
            return true;
        } catch {
            return false;
        }
    }

    /**
     * Dockerfile oluştur
     */
    generateDockerfile(options: {
        baseImage?: string;
        nodeVersion?: string;
        port?: number;
        command?: string;
    } = {}): string {
        const base = options.baseImage || `node:${options.nodeVersion || '20'}-alpine`;
        const port = options.port || 3000;
        const cmd = options.command || 'npm start';

        return `# Auto-generated Dockerfile
FROM ${base}

WORKDIR /app

# Dependencies
COPY package*.json ./
RUN npm ci --only=production

# Source
COPY . .

# Build (if needed)
RUN npm run build --if-present

EXPOSE ${port}

CMD ["sh", "-c", "${cmd}"]
`;
    }

    /**
     * Dockerfile kaydet
     */
    saveDockerfile(content?: string): void {
        const dockerfile = content || this.generateDockerfile();
        fs.writeFileSync(path.join(this.cwd, 'Dockerfile'), dockerfile);
    }

    /**
     * Docker Compose oluştur
     */
    generateDockerCompose(services: Array<{
        name: string;
        build?: string;
        image?: string;
        ports?: string[];
        environment?: Record<string, string>;
        volumes?: string[];
    }>): string {
        let yaml = 'version: "3.8"\n\nservices:\n';

        for (const svc of services) {
            yaml += `  ${svc.name}:\n`;
            if (svc.build) yaml += `    build: ${svc.build}\n`;
            if (svc.image) yaml += `    image: ${svc.image}\n`;
            if (svc.ports?.length) {
                yaml += '    ports:\n';
                for (const p of svc.ports) yaml += `      - "${p}"\n`;
            }
            if (svc.environment) {
                yaml += '    environment:\n';
                for (const [k, v] of Object.entries(svc.environment)) {
                    yaml += `      - ${k}=${v}\n`;
                }
            }
            if (svc.volumes?.length) {
                yaml += '    volumes:\n';
                for (const v of svc.volumes) yaml += `      - ${v}\n`;
            }
        }

        return yaml;
    }

    /**
     * Build
     */
    async build(tag: string, dockerfile?: string): Promise<string> {
        const args = ['build', '-t', tag];
        if (dockerfile) args.push('-f', dockerfile);
        args.push('.');
        return this.exec(args);
    }

    /**
     * Run
     */
    async run(image: string, options: {
        name?: string;
        ports?: string[];
        detach?: boolean;
        env?: Record<string, string>;
    } = {}): Promise<string> {
        const args = ['run'];
        if (options.detach) args.push('-d');
        if (options.name) args.push('--name', options.name);
        if (options.ports) {
            for (const p of options.ports) args.push('-p', p);
        }
        if (options.env) {
            for (const [k, v] of Object.entries(options.env)) {
                args.push('-e', `${k}=${v}`);
            }
        }
        args.push(image);
        return this.exec(args);
    }

    /**
     * Container listele
     */
    async listContainers(all?: boolean): Promise<string> {
        const args = ['ps'];
        if (all) args.push('-a');
        return this.exec(args);
    }

    /**
     * Container durdur
     */
    async stop(container: string): Promise<void> {
        await this.exec(['stop', container]);
    }

    /**
     * Image listele
     */
    async listImages(): Promise<string> {
        return this.exec(['images']);
    }
}

// Singleton
let dockerInstance: DockerManager | null = null;

export function getDockerManager(cwd?: string): DockerManager {
    if (!dockerInstance) {
        dockerInstance = new DockerManager(cwd);
    }
    return dockerInstance;
}
