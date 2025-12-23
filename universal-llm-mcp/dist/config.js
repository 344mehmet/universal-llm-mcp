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
// Varsayılan yapılandırma
const defaultConfig = {
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
    config;
    configPath;
    constructor(configPath) {
        this.configPath = configPath || join(__dirname, '..', 'config.json');
        this.config = this.yukle();
    }
    /**
     * Yapılandırmayı dosyadan yükle
     */
    yukle() {
        try {
            if (existsSync(this.configPath)) {
                const icerik = readFileSync(this.configPath, 'utf-8');
                // JSON yorumlarını temizle
                const temizIcerik = icerik.replace(/\/\/.*$/gm, '').replace(/,\s*}/g, '}').replace(/,\s*]/g, ']');
                const yuklenenConfig = JSON.parse(temizIcerik);
                return { ...defaultConfig, ...yuklenenConfig };
            }
        }
        catch (hata) {
            console.error(`[Yapılandırma] Yükleme hatası: ${hata}`);
        }
        return defaultConfig;
    }
    /**
     * Yapılandırmayı kaydet
     */
    kaydet() {
        try {
            writeFileSync(this.configPath, JSON.stringify(this.config, null, 2), 'utf-8');
            console.log('[Yapılandırma] Başarıyla kaydedildi');
        }
        catch (hata) {
            console.error(`[Yapılandırma] Kaydetme hatası: ${hata}`);
        }
    }
    /**
     * Tüm yapılandırmayı al
     */
    getConfig() {
        return this.config;
    }
    /**
     * Backend yapılandırmasını al
     */
    getBackend(isim) {
        return this.config.backends[isim];
    }
    /**
     * Aktif backend'leri al
     */
    getAktifBackendler() {
        return Object.entries(this.config.backends)
            .filter(([_, backend]) => backend.enabled)
            .map(([isim, _]) => isim);
    }
    /**
     * Görev için backend belirle
     */
    getBackendForTask(gorev) {
        const routing = this.config.routing;
        return routing[gorev] || this.config.routing.default;
    }
    /**
     * Sistem prompt'unu al
     */
    getSystemPrompt() {
        return this.config.language.systemPrompt;
    }
    /**
     * Varsayılan dili al
     */
    getDefaultLanguage() {
        return this.config.language.default;
    }
    /**
     * Aktif araçları al
     */
    getAktifAraclar() {
        return this.config.tools.enabled;
    }
    /**
     * Yeni backend ekle
     */
    addBackend(isim, config) {
        this.config.backends[isim] = config;
        this.kaydet();
    }
    /**
     * Backend'i güncelle
     */
    updateBackend(isim, config) {
        if (this.config.backends[isim]) {
            this.config.backends[isim] = { ...this.config.backends[isim], ...config };
            this.kaydet();
        }
    }
}
// Singleton instance
let configInstance = null;
/**
 * Yapılandırma yöneticisi instance'ını al
 */
export function getConfigManager(configPath) {
    if (!configInstance) {
        configInstance = new ConfigManager(configPath);
    }
    return configInstance;
}
//# sourceMappingURL=config.js.map