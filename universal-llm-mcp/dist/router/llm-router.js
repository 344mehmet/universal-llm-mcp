/**
 * Universal LLM MCP - LLM Router
 * Görev tipine göre uygun backend'e yönlendirme
 */
import { getConfigManager } from '../config.js';
import { LMStudioBackend } from './backends/lmstudio.js';
import { OllamaBackend } from './backends/ollama.js';
/**
 * LLM Router Sınıfı
 * Merkezi backend yönetimi ve yönlendirme
 */
export class LLMRouter {
    backends = new Map();
    backendStatus = new Map();
    constructor() {
        this.initializeBackends();
    }
    /**
     * Backend'leri yapılandırmadan başlat
     */
    initializeBackends() {
        const config = getConfigManager();
        const aktifBackendler = config.getAktifBackendler();
        for (const backendName of aktifBackendler) {
            const backendConfig = config.getBackend(backendName);
            if (backendConfig) {
                const backend = this.createBackend(backendName, backendConfig);
                if (backend) {
                    this.backends.set(backendName, backend);
                    console.log(`[Router] Backend yüklendi: ${backendName}`);
                }
            }
        }
    }
    /**
     * Backend instance oluştur
     */
    createBackend(name, config) {
        switch (name) {
            case 'lmstudio':
                return new LMStudioBackend(config.url, config.defaultModel, config.timeout);
            case 'ollama':
                return new OllamaBackend(config.url, config.defaultModel, config.timeout);
            default:
                console.warn(`[Router] Bilinmeyen backend: ${name}`);
                return null;
        }
    }
    /**
     * Tüm backend'lerin sağlık durumunu kontrol et
     */
    async checkAllBackends() {
        console.log('[Router] Backend sağlık kontrolü başlatılıyor...');
        for (const [name, backend] of this.backends) {
            try {
                const status = await backend.checkHealth();
                this.backendStatus.set(name, status);
                console.log(`[Router] ${name}: ${status.isAvailable ? 'Erişilebilir' : 'Erişilemez'}`);
            }
            catch (error) {
                this.backendStatus.set(name, {
                    isAvailable: false,
                    models: [],
                    error: String(error),
                });
            }
        }
        return this.backendStatus;
    }
    /**
     * Belirli bir backend'in durumunu al
     */
    getBackendStatus(name) {
        return this.backendStatus.get(name);
    }
    /**
     * Görev tipi için uygun backend'i seç
     */
    selectBackend(taskType) {
        const config = getConfigManager();
        const preferredBackend = config.getBackendForTask(taskType);
        // Tercih edilen backend erişilebilir mi?
        const status = this.backendStatus.get(preferredBackend);
        if (status?.isAvailable && this.backends.has(preferredBackend)) {
            return this.backends.get(preferredBackend);
        }
        // Fallback: herhangi bir erişilebilir backend
        for (const [name, backend] of this.backends) {
            const backendStatus = this.backendStatus.get(name);
            if (backendStatus?.isAvailable) {
                console.log(`[Router] Fallback backend kullanılıyor: ${name}`);
                return backend;
            }
        }
        return null;
    }
    /**
     * Tamamlama isteği gönder
     */
    async complete(taskType, mesaj, sistemPrompt, options) {
        const backend = this.selectBackend(taskType);
        if (!backend) {
            throw new Error('[Router] Erişilebilir backend bulunamadı!');
        }
        const config = getConfigManager();
        const varsayilanPrompt = config.getSystemPrompt();
        const messages = [
            {
                role: 'system',
                content: sistemPrompt || varsayilanPrompt,
            },
            {
                role: 'user',
                content: mesaj,
            },
        ];
        const request = {
            messages,
            temperature: options?.temperature ?? 0.7,
            maxTokens: options?.maxTokens ?? 4096,
            model: options?.model,
            stream: false,
        };
        console.log(`[Router] İstek gönderiliyor: ${backend.getName()} (${taskType})`);
        try {
            const response = await backend.complete(request);
            return response;
        }
        catch (error) {
            // Fallback dene
            console.error(`[Router] ${backend.getName()} hatası, fallback deneniyor...`);
            for (const [name, altBackend] of this.backends) {
                if (name !== backend.getName()) {
                    const status = this.backendStatus.get(name);
                    if (status?.isAvailable) {
                        try {
                            return await altBackend.complete(request);
                        }
                        catch {
                            continue;
                        }
                    }
                }
            }
            throw new Error(`[Router] Tüm backend'ler başarısız: ${error}`);
        }
    }
    /**
     * Belirli bir backend ile tamamlama
     */
    async completeWithBackend(backendName, mesaj, sistemPrompt) {
        const backend = this.backends.get(backendName);
        if (!backend) {
            throw new Error(`[Router] Backend bulunamadı: ${backendName}`);
        }
        const config = getConfigManager();
        const varsayilanPrompt = config.getSystemPrompt();
        const messages = [
            { role: 'system', content: sistemPrompt || varsayilanPrompt },
            { role: 'user', content: mesaj },
        ];
        const request = {
            messages,
            temperature: 0.7,
            maxTokens: 16384,
            stream: false,
        };
        console.log(`[Router] Direkt istek: ${backendName}`);
        return backend.complete(request);
    }
    /**
     * Mevcut modelleri listele
     */
    async listAllModels() {
        const result = {};
        for (const [name, backend] of this.backends) {
            try {
                const models = await backend.listModels();
                result[name] = models;
            }
            catch {
                result[name] = [];
            }
        }
        return result;
    }
    /**
     * Yeni backend ekle (çalışma zamanında)
     */
    addBackend(name, backend) {
        this.backends.set(name, backend);
        console.log(`[Router] Yeni backend eklendi: ${name}`);
    }
    /**
     * Backend kaldır
     */
    removeBackend(name) {
        const removed = this.backends.delete(name);
        if (removed) {
            this.backendStatus.delete(name);
            console.log(`[Router] Backend kaldırıldı: ${name}`);
        }
        return removed;
    }
}
// Singleton instance
let routerInstance = null;
/**
 * Router instance'ını al
 */
export function getRouter() {
    if (!routerInstance) {
        routerInstance = new LLMRouter();
    }
    return routerInstance;
}
//# sourceMappingURL=llm-router.js.map