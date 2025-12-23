/**
 * Universal LLM MCP - Akilli Embedding Service
 * Multi-backend failover destegi ile embedding uretici
 * CACHE ve hiz optimizasyonlari dahil
 */
export interface EmbeddingResponse {
    embedding: number[];
    model: string;
    tokensUsed?: number;
    backend?: string;
}
/**
 * Akıllı Embedding Servisi
 * Otomatik failover: lmstudio → ollama → basit hash
 */
export declare class EmbeddingService {
    private backendPriority;
    private backendHealth;
    private backendConfigs;
    private useFallbackHash;
    private embeddingDimension;
    private cache;
    constructor();
    /**
     * Akilli embedding - cache + otomatik failover
     */
    embed(text: string): Promise<EmbeddingResponse>;
    /**
     * Belirli backend ile embedding
     */
    private embedWithBackend;
    /**
     * Basit hash tabanlı "embedding" - fallback
     * Not: Bu gerçek semantik embedding değil, sadece acil durum için
     */
    private hashFallback;
    /**
     * Toplu embedding üretimi
     */
    embedBatch(texts: string[]): Promise<EmbeddingResponse[]>;
    /**
     * LM Studio ile embedding (OpenAI uyumlu /v1/embeddings)
     */
    private embedWithLMStudio;
    /**
     * Ollama ile embedding (/api/embeddings)
     */
    private embedWithOllama;
    /**
     * HTTP request helper
     */
    private httpRequest;
    /**
     * Backend önceliğini değiştir
     */
    setPriority(priority: ('lmstudio' | 'ollama')[]): void;
    /**
     * Backend durumlarını al
     */
    getHealthStatus(): Record<string, {
        available: boolean;
        failCount: number;
    }>;
    /**
     * Fallback hash'i etkinleştir/devre dışı bırak
     */
    setFallbackHash(enabled: boolean): void;
    /**
     * Mevcut bilgiler
     */
    getInfo(): {
        priority: string[];
        health: Record<string, any>;
    };
}
/**
 * EmbeddingService singleton instance al
 */
export declare function getEmbeddingService(): EmbeddingService;
//# sourceMappingURL=embedding-service.d.ts.map