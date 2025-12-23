/**
 * Universal LLM MCP - RAG Service
 * Ana RAG (Retrieval-Augmented Generation) servisi
 * Bilgi ekleme, sorgulama ve bağlam zenginleştirme
 */
export interface RAGQueryResult {
    answer: string;
    sources: Array<{
        text: string;
        source: string;
        similarity: number;
    }>;
    tokensUsed?: number;
}
export interface RAGAddResult {
    success: boolean;
    chunksAdded: number;
    source: string;
    message: string;
}
/**
 * RAG Servisi
 * Bilgi tabanı yönetimi ve akıllı sorgulama
 */
export declare class RAGService {
    private vectorStore;
    private embeddingService;
    private documentProcessor;
    private topK;
    private minSimilarity;
    constructor();
    /**
     * Bilgi tabanına metin ekle
     */
    addDocument(text: string, source: string, category?: string): Promise<RAGAddResult>;
    /**
     * RAG ile sorgula - İlgili bilgileri bul ve LLM'e sor
     */
    query(question: string, options?: {
        topK?: number;
        category?: string;
    }): Promise<RAGQueryResult>;
    /**
     * Bağlam metni oluştur
     */
    private buildContext;
    /**
     * LLM'e bağlamla birlikte sor
     */
    private askLLMWithContext;
    /**
     * Eklenen bilgileri listele
     */
    listDocuments(limit?: number): Array<{
        source: string;
        chunkCount: number;
        preview: string;
    }>;
    /**
     * Kaynak sil
     */
    deleteSource(source: string): number;
    /**
     * İstatistikler
     */
    getStats(): {
        totalChunks: number;
        sources: number;
        categories: string[];
    };
    /**
     * Tüm veriyi temizle
     */
    clear(): void;
}
/**
 * RAGService singleton instance al
 */
export declare function getRAGService(): RAGService;
//# sourceMappingURL=rag-service.d.ts.map