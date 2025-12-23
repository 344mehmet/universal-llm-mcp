/**
 * Universal LLM MCP - Backend Temel Sınıfı
 * Tüm LLM backend'leri için soyut temel sınıf
 */

// Mesaj tipi
export interface ChatMessage {
    role: 'system' | 'user' | 'assistant';
    content: string;
}

// Tamamlama isteği
export interface CompletionRequest {
    messages: ChatMessage[];
    model?: string;
    temperature?: number;
    maxTokens?: number;
    stream?: boolean;
}

// Tamamlama yanıtı
export interface CompletionResponse {
    content: string;
    model: string;
    tokensUsed?: number;
    finishReason?: string;
}

// Backend durumu
export interface BackendStatus {
    isAvailable: boolean;
    models: string[];
    currentModel?: string;
    error?: string;
}

/**
 * Soyut Backend Sınıfı
 * Yeni backend eklemek için bu sınıfı extend edin
 */
export abstract class BaseLLMBackend {
    protected name: string;
    protected url: string;
    protected timeout: number;
    protected defaultModel: string;

    constructor(name: string, url: string, defaultModel: string, timeout: number = 120000) {
        this.name = name;
        this.url = url;
        this.defaultModel = defaultModel;
        this.timeout = timeout;
    }

    /**
     * Backend adını al
     */
    public getName(): string {
        return this.name;
    }

    /**
     * Backend URL'ini al
     */
    public getUrl(): string {
        return this.url;
    }

    /**
     * Backend'in erişilebilir olup olmadığını kontrol et
     */
    async checkHealth(): Promise<BackendStatus> {
        try {
            const models = await this.listModels();
            return {
                isAvailable: models.length > 0,
                models,
                currentModel: this.defaultModel,
            };
        } catch (error) {
            return {
                isAvailable: false,
                models: [],
                error: String(error),
            };
        }
    }

    /**
     * Mevcut modelleri listele
     */
    abstract listModels(): Promise<string[]>;

    /**
     * Chat tamamlama isteği gönder
     */
    abstract complete(request: CompletionRequest): Promise<CompletionResponse>;

    /**
     * HTTP isteği gönder (yardımcı metod)
     */
    protected async httpRequest<T>(
        endpoint: string,
        method: 'GET' | 'POST' = 'GET',
        body?: unknown,
        headers?: Record<string, string>
    ): Promise<T> {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), this.timeout);

        try {
            const options: RequestInit = {
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

            return await response.json() as T;
        } finally {
            clearTimeout(timeoutId);
        }
    }
}
