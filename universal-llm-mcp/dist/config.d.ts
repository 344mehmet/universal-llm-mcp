/**
 * Universal LLM MCP Sunucusu - Konfigürasyon Yönetimi
 * Türkçe destekli yerel LLM entegrasyonu
 */
export interface BackendConfig {
    enabled: boolean;
    url: string;
    defaultModel: string;
    timeout: number;
    aciklama?: string;
}
export interface RoutingConfig {
    code: string;
    chat: string;
    translate: string;
    file: string;
    default: string;
}
export interface LanguageConfig {
    default: string;
    systemPrompt: string;
}
export interface ToolsConfig {
    enabled: string[];
}
export interface RAGConfig {
    enabled: boolean;
    chunkSize: number;
    chunkOverlap: number;
    topK: number;
    embeddingBackend: string;
}
export interface TrainingConfig {
    enabled: boolean;
    questionBankPath: string;
    categories: string[];
}
export interface AppConfig {
    backends: {
        lmstudio: BackendConfig;
        ollama: BackendConfig;
        [key: string]: BackendConfig;
    };
    routing: RoutingConfig;
    language: LanguageConfig;
    tools: ToolsConfig;
    rag?: RAGConfig;
    training?: TrainingConfig;
}
/**
 * Yapılandırma yöneticisi sınıfı
 */
export declare class ConfigManager {
    private config;
    private configPath;
    constructor(configPath?: string);
    /**
     * Yapılandırmayı dosyadan yükle
     */
    private yukle;
    /**
     * Yapılandırmayı kaydet
     */
    kaydet(): void;
    /**
     * Tüm yapılandırmayı al
     */
    getConfig(): AppConfig;
    /**
     * Backend yapılandırmasını al
     */
    getBackend(isim: string): BackendConfig | undefined;
    /**
     * Aktif backend'leri al
     */
    getAktifBackendler(): string[];
    /**
     * Görev için backend belirle
     */
    getBackendForTask(gorev: string): string;
    /**
     * Sistem prompt'unu al
     */
    getSystemPrompt(): string;
    /**
     * Varsayılan dili al
     */
    getDefaultLanguage(): string;
    /**
     * Aktif araçları al
     */
    getAktifAraclar(): string[];
    /**
     * Yeni backend ekle
     */
    addBackend(isim: string, config: BackendConfig): void;
    /**
     * Backend'i güncelle
     */
    updateBackend(isim: string, config: Partial<BackendConfig>): void;
}
/**
 * Yapılandırma yöneticisi instance'ını al
 */
export declare function getConfigManager(configPath?: string): ConfigManager;
//# sourceMappingURL=config.d.ts.map