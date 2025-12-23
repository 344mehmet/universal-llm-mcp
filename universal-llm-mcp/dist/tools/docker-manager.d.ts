/**
 * Universal LLM MCP - Docker Entegrasyonu
 */
export declare class DockerManager {
    private cwd;
    constructor(cwd?: string);
    private exec;
    /**
     * Docker mevcut mu?
     */
    isAvailable(): Promise<boolean>;
    /**
     * Dockerfile oluştur
     */
    generateDockerfile(options?: {
        baseImage?: string;
        nodeVersion?: string;
        port?: number;
        command?: string;
    }): string;
    /**
     * Dockerfile kaydet
     */
    saveDockerfile(content?: string): void;
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
    }>): string;
    /**
     * Build
     */
    build(tag: string, dockerfile?: string): Promise<string>;
    /**
     * Run
     */
    run(image: string, options?: {
        name?: string;
        ports?: string[];
        detach?: boolean;
        env?: Record<string, string>;
    }): Promise<string>;
    /**
     * Container listele
     */
    listContainers(all?: boolean): Promise<string>;
    /**
     * Container durdur
     */
    stop(container: string): Promise<void>;
    /**
     * Image listele
     */
    listImages(): Promise<string>;
}
export declare function getDockerManager(cwd?: string): DockerManager;
//# sourceMappingURL=docker-manager.d.ts.map