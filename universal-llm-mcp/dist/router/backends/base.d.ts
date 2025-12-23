/**
 * Universal LLM MCP - Backend Temel Sınıfı
 * Tüm LLM backend'leri için soyut temel sınıf
 */
export interface ChatMessage {
    role: 'system' | 'user' | 'assistant';
    content: string;
}
export interface CompletionRequest {
    messages: ChatMessage[];
    model?: string;
    temperature?: number;
    maxTokens?: number;
    stream?: boolean;
}
export interface CompletionResponse {
    content: string;
    model: string;
    tokensUsed?: number;
    finishReason?: string;
}
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
export declare abstract class BaseLLMBackend {
    protected name: string;
    protected url: string;
    protected timeout: number;
    protected defaultModel: string;
    constructor(name: string, url: string, defaultModel: string, timeout?: number);
    /**
     * Backend adını al
     */
    getName(): string;
    /**
     * Backend URL'ini al
     */
    getUrl(): string;
    /**
     * Backend'in erişilebilir olup olmadığını kontrol et
     */
    checkHealth(): Promise<BackendStatus>;
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
    protected httpRequest<T>(endpoint: string, method?: 'GET' | 'POST', body?: unknown, headers?: Record<string, string>): Promise<T>;
}
//# sourceMappingURL=base.d.ts.map