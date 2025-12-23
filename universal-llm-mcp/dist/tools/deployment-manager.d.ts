/**
 * Universal LLM MCP - Cloud Deployment Manager
 * Netlify, Vercel, GitHub Pages dağıtımı
 */
export type DeploymentTarget = 'netlify' | 'vercel' | 'github-pages';
export interface DeploymentResult {
    success: boolean;
    url?: string;
    error?: string;
    logs: string[];
}
export declare class DeploymentManager {
    private cwd;
    constructor(cwd?: string);
    private exec;
    /**
     * Netlify dağıtımı
     */
    deployNetlify(options?: {
        siteId?: string;
        authToken?: string;
        directory?: string;
        production?: boolean;
    }): Promise<DeploymentResult>;
    /**
     * Vercel dağıtımı
     */
    deployVercel(options?: {
        token?: string;
        production?: boolean;
    }): Promise<DeploymentResult>;
    /**
     * GitHub Pages dağıtımı
     */
    deployGitHubPages(options?: {
        branch?: string;
        directory?: string;
    }): Promise<DeploymentResult>;
    /**
     * Vercel config oluştur
     */
    generateVercelConfig(options?: {
        framework?: string;
        buildCommand?: string;
        outputDirectory?: string;
    }): void;
    /**
     * Netlify config oluştur
     */
    generateNetlifyConfig(options?: {
        buildCommand?: string;
        publishDirectory?: string;
        redirects?: Array<{
            from: string;
            to: string;
            status?: number;
        }>;
    }): void;
}
export declare function getDeploymentManager(cwd?: string): DeploymentManager;
//# sourceMappingURL=deployment-manager.d.ts.map