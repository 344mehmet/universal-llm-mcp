/**
 * Universal LLM MCP - Vector Store
 * Bellek tabanlı vektör depolama ve semantik arama
 * Türkçe destekli RAG sistemi için
 */
export interface VectorChunk {
    id: string;
    text: string;
    embedding: number[];
    metadata: ChunkMetadata;
}
export interface ChunkMetadata {
    source: string;
    createdAt: Date;
    category?: string;
    language?: string;
}
export interface SearchResult {
    chunk: VectorChunk;
    similarity: number;
}
/**
 * Bellek Tabanlı Vector Store
 * Cosine similarity ile semantik arama yapar
 */
export declare class VectorStore {
    private chunks;
    private idCounter;
    /**
     * Yeni chunk ekle
     */
    add(text: string, embedding: number[], metadata: Partial<ChunkMetadata>): string;
    /**
     * Toplu chunk ekleme
     */
    addBatch(items: Array<{
        text: string;
        embedding: number[];
        metadata?: Partial<ChunkMetadata>;
    }>): string[];
    /**
     * Chunk sil
     */
    delete(id: string): boolean;
    /**
     * Kaynağa göre tüm chunk'ları sil
     */
    deleteBySource(source: string): number;
    /**
     * Semantik arama - En benzer chunk'ları bul
     */
    search(queryEmbedding: number[], topK?: number, filter?: Partial<ChunkMetadata>): SearchResult[];
    /**
     * Cosine Similarity hesaplama
     * İki vektör arasındaki açısal benzerlik (0-1 arası)
     */
    private cosineSimilarity;
    /**
     * Tüm chunk'ları listele
     */
    list(limit?: number): VectorChunk[];
    /**
     * Kaynağa göre listele
     */
    listBySource(source: string): VectorChunk[];
    /**
     * Chunk sayısı
     */
    size(): number;
    /**
     * Tüm kaynakları listele
     */
    getSources(): string[];
    /**
     * İstatistikler
     */
    getStats(): {
        totalChunks: number;
        sources: number;
        categories: string[];
    };
    /**
     * Store'u temizle
     */
    clear(): void;
    /**
     * JSON olarak dışa aktar (kalıcılık için)
     */
    export(): string;
    /**
     * JSON'dan içe aktar
     */
    import(json: string): void;
}
/**
 * VectorStore singleton instance al
 */
export declare function getVectorStore(): VectorStore;
//# sourceMappingURL=vector-store.d.ts.map