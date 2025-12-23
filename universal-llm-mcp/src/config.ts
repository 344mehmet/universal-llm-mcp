/**
 * Universal LLM MCP Sunucusu - Konfigürasyon Yönetimi
 * Türkçe destekli yerel LLM entegrasyonu
 */

import { readFileSync, existsSync, writeFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

// Dosya yolu hesaplama
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Backend yapılandırma tipi
export interface BackendConfig {
    enabled: boolean;
    url: string;
    defaultModel: string;
    timeout: number;
    aciklama?: string;
}

// Routing yapılandırma tipi
export interface RoutingConfig {
    code: string;
    chat: string;
    translate: string;
    file: string;
    default: string;
}

// Dil yapılandırma tipi
export interface LanguageConfig {
    default: string;
    systemPrompt: string;
}

// Tools yapılandırma tipi
export interface ToolsConfig {
    enabled: string[];
}

// RAG yapılandırma tipi
export interface RAGConfig {
    enabled: boolean;
    chunkSize: number;
    chunkOverlap: number;
    topK: number;
    embeddingBackend: string;
}

// Training yapılandırma tipi
export interface TrainingConfig {
    enabled: boolean;
    questionBankPath: string;
    categories: string[];
}

// Ana yapılandırma tipi
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

// Varsayılan yapılandırma
const defaultConfig: AppConfig = {
    backends: {
        lmstudio: {
            enabled: true,
            url: "http://127.0.0.1:1234",
            defaultModel: "auto",
            timeout: 120000,
            aciklama: "LM Studio API baglantisi"
        },
        ollama: {
            enabled: true,
            url: "http://127.0.0.1:11434",
            defaultModel: "llama3",
            timeout: 120000,
            aciklama: "Ollama API baglantisi"
        }
    },
    routing: {
        code: "lmstudio",
        chat: "ollama",
        translate: "lmstudio",
        file: "lmstudio",
        default: "lmstudio"
    },
    language: {
        default: "tr",
        systemPrompt: "Sen Türkçe düşünen ve Türkçe yanıt veren bir yapay zeka asistanısın. Tüm açıklamalarını, analizlerini ve yanıtlarını Türkçe olarak ver."
    },
    tools: {
        enabled: ["code", "chat", "translate", "file"]
    }
};

/**
 * Yapılandırma yöneticisi sınıfı
 */
export class ConfigManager {
    private config: AppConfig;
    private configPath: string;

    constructor(configPath?: string) {
        this.configPath = configPath || join(__dirname, '..', 'config.json');
        this.config = this.yukle();
    }

    /**
     * Yapılandırmayı dosyadan yükle
     */
    private yukle(): AppConfig {
        try {
            if (existsSync(this.configPath)) {
                const icerik = readFileSync(this.configPath, 'utf-8');
                // JSON yorumlarını temizle
                const temizIcerik = icerik.replace(/\/\/.*$/gm, '').replace(/,\s*}/g, '}').replace(/,\s*]/g, ']');
                const yuklenenConfig = JSON.parse(temizIcerik);
                return { ...defaultConfig, ...yuklenenConfig };
            }
        } catch (hata) {
            console.error(`[Yapılandırma] Yükleme hatası: ${hata}`);
        }
        return defaultConfig;
    }

    /**
     * Yapılandırmayı kaydet
     */
    public kaydet(): void {
        try {
            writeFileSync(this.configPath, JSON.stringify(this.config, null, 2), 'utf-8');
            console.log('[Yapılandırma] Başarıyla kaydedildi');
        } catch (hata) {
            console.error(`[Yapılandırma] Kaydetme hatası: ${hata}`);
        }
    }

    /**
     * Tüm yapılandırmayı al
     */
    public getConfig(): AppConfig {
        return this.config;
    }

    /**
     * Backend yapılandırmasını al
     */
    public getBackend(isim: string): BackendConfig | undefined {
        return this.config.backends[isim];
    }

    /**
     * Aktif backend'leri al
     */
    public getAktifBackendler(): string[] {
        return Object.entries(this.config.backends)
            .filter(([_, backend]) => backend.enabled)
            .map(([isim, _]) => isim);
    }

    /**
     * Görev için backend belirle
     */
    public getBackendForTask(gorev: string): string {
        const routing = this.config.routing as unknown as Record<string, string>;
        return routing[gorev] || this.config.routing.default;
    }

    /**
     * Sistem prompt'unu al
     */
    public getSystemPrompt(): string {
        return this.config.language.systemPrompt;
    }

    /**
     * Varsayılan dili al
     */
    public getDefaultLanguage(): string {
        return this.config.language.default;
    }

    /**
     * Aktif araçları al
     */
    public getAktifAraclar(): string[] {
        return this.config.tools.enabled;
    }

    /**
     * Yeni backend ekle
     */
    public addBackend(isim: string, config: BackendConfig): void {
        this.config.backends[isim] = config;
        this.kaydet();
    }

    /**
     * Backend'i güncelle
     */
    public updateBackend(isim: string, config: Partial<BackendConfig>): void {
        if (this.config.backends[isim]) {
            this.config.backends[isim] = { ...this.config.backends[isim], ...config };
            this.kaydet();
        }
    }
}

// Singleton instance
let configInstance: ConfigManager | null = null;

/**
 * Yapılandırma yöneticisi instance'ını al
 */
export function getConfigManager(configPath?: string): ConfigManager {
    if (!configInstance) {
        configInstance = new ConfigManager(configPath);
    }
    return configInstance;
}
