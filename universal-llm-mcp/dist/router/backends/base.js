/**
 * Universal LLM MCP - Backend Temel Sınıfı
 * Tüm LLM backend'leri için soyut temel sınıf
 */
/**
 * Soyut Backend Sınıfı
 * Yeni backend eklemek için bu sınıfı extend edin
 */
export class BaseLLMBackend {
    name;
    url;
    timeout;
    defaultModel;
    constructor(name, url, defaultModel, timeout = 120000) {
        this.name = name;
        this.url = url;
        this.defaultModel = defaultModel;
        this.timeout = timeout;
    }
    /**
     * Backend adını al
     */
    getName() {
        return this.name;
    }
    /**
     * Backend URL'ini al
     */
    getUrl() {
        return this.url;
    }
    /**
     * Backend'in erişilebilir olup olmadığını kontrol et
     */
    async checkHealth() {
        try {
            const models = await this.listModels();
            return {
                isAvailable: models.length > 0,
                models,
                currentModel: this.defaultModel,
            };
        }
        catch (error) {
            return {
                isAvailable: false,
                models: [],
                error: String(error),
            };
        }
    }
    /**
     * HTTP isteği gönder (yardımcı metod)
     */
    async httpRequest(endpoint, method = 'GET', body, headers) {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), this.timeout);
        try {
            const options = {
                method,
                headers: {
                    'Content-Type': 'application/json',
                    ...headers,
                },
                signal: controller.signal,
            };
            if (body) {
                options.body = JSON.stringify(body);
            }
            const response = await fetch(`${this.url}${endpoint}`, options);
            if (!response.ok) {
                throw new Error(`HTTP Hatası: ${response.status} ${response.statusText}`);
            }
            return await response.json();
        }
        finally {
            clearTimeout(timeoutId);
        }
    }
}
//# sourceMappingURL=base.js.map