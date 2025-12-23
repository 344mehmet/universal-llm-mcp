/**
 * Universal LLM MCP - Vector Store
 * Bellek tabanlı vektör depolama ve semantik arama
 * Türkçe destekli RAG sistemi için
 */

// Vektör chunk arayüzü
export interface VectorChunk {
    id: string;
    text: string;
    embedding: number[];
    metadata: ChunkMetadata;
}

// Chunk metadata
export interface ChunkMetadata {
    source: string;
    createdAt: Date;
    category?: string;
    language?: string;
}

// Arama sonucu
export interface SearchResult {
    chunk: VectorChunk;
    similarity: number;
}

/**
 * Bellek Tabanlı Vector Store
 * Cosine similarity ile semantik arama yapar
 */
export class VectorStore {
    private chunks: Map<string, VectorChunk> = new Map();
    private idCounter: number = 0;

    /**
     * Yeni chunk ekle
     */
    public add(text: string, embedding: number[], metadata: Partial<ChunkMetadata>): string {
        const id = `chunk_${++this.idCounter}_${Date.now()}`;

        const chunk: VectorChunk = {
            id,
            text,
            embedding,
            metadata: {
                source: metadata.source || 'unknown',
                createdAt: new Date(),
                category: metadata.category,
                language: metadata.language || 'tr',
            },
        };

        this.chunks.set(id, chunk);
        console.log(`[VectorStore] Chunk eklendi: ${id} (${text.substring(0, 50)}...)`);

        return id;
    }

    /**
     * Toplu chunk ekleme
     */
    public addBatch(items: Array<{ text: string; embedding: number[]; metadata?: Partial<ChunkMetadata> }>): string[] {
        return items.map(item => this.add(item.text, item.embedding, item.metadata || {}));
    }

    /**
     * Chunk sil
     */
    public delete(id: string): boolean {
        const deleted = this.chunks.delete(id);
        if (deleted) {
            console.log(`[VectorStore] Chunk silindi: ${id}`);
        }
        return deleted;
    }

    /**
     * Kaynağa göre tüm chunk'ları sil
     */
    public deleteBySource(source: string): number {
        let count = 0;
        for (const [id, chunk] of this.chunks) {
            if (chunk.metadata.source === source) {
                this.chunks.delete(id);
                count++;
            }
        }
        console.log(`[VectorStore] ${count} chunk silindi (kaynak: ${source})`);
        return count;
    }

    /**
     * Semantik arama - En benzer chunk'ları bul
     */
    public search(queryEmbedding: number[], topK: number = 3, filter?: Partial<ChunkMetadata>): SearchResult[] {
        const results: SearchResult[] = [];

        for (const chunk of this.chunks.values()) {
            // Filtre kontrolü
            if (filter) {
                if (filter.source && chunk.metadata.source !== filter.source) continue;
                if (filter.category && chunk.metadata.category !== filter.category) continue;
            }

            const similarity = this.cosineSimilarity(queryEmbedding, chunk.embedding);
            results.push({ chunk, similarity });
        }

        // Benzerliğe göre sırala ve en iyi K tanesi
        return results
            .sort((a, b) => b.similarity - a.similarity)
            .slice(0, topK);
    }

    /**
     * Cosine Similarity hesaplama
     * İki vektör arasındaki açısal benzerlik (0-1 arası)
     */
    private cosineSimilarity(a: number[], b: number[]): number {
        if (a.length !== b.length) {
            console.warn('[VectorStore] Vektör boyutları eşleşmiyor!');
            return 0;
        }

        let dotProduct = 0;
        let normA = 0;
        let normB = 0;

        for (let i = 0; i < a.length; i++) {
            dotProduct += a[i] * b[i];
            normA += a[i] * a[i];
            normB += b[i] * b[i];
        }

        const magnitude = Math.sqrt(normA) * Math.sqrt(normB);

        if (magnitude === 0) return 0;

        return dotProduct / magnitude;
    }

    /**
     * Tüm chunk'ları listele
     */
    public list(limit?: number): VectorChunk[] {
        const all = Array.from(this.chunks.values());
        return limit ? all.slice(0, limit) : all;
    }

    /**
     * Kaynağa göre listele
     */
    public listBySource(source: string): VectorChunk[] {
        return Array.from(this.chunks.values())
            .filter(chunk => chunk.metadata.source === source);
    }

    /**
     * Chunk sayısı
     */
    public size(): number {
        return this.chunks.size;
    }

    /**
     * Tüm kaynakları listele
     */
    public getSources(): string[] {
        const sources = new Set<string>();
        for (const chunk of this.chunks.values()) {
            sources.add(chunk.metadata.source);
        }
        return Array.from(sources);
    }

    /**
     * İstatistikler
     */
    public getStats(): { totalChunks: number; sources: number; categories: string[] } {
        const categories = new Set<string>();
        for (const chunk of this.chunks.values()) {
            if (chunk.metadata.category) {
                categories.add(chunk.metadata.category);
            }
        }

        return {
            totalChunks: this.chunks.size,
            sources: this.getSources().length,
            categories: Array.from(categories),
        };
    }

    /**
     * Store'u temizle
     */
    public clear(): void {
        this.chunks.clear();
        this.idCounter = 0;
        console.log('[VectorStore] Tüm veriler silindi');
    }

    /**
     * JSON olarak dışa aktar (kalıcılık için)
     */
    public export(): string {
        const data = {
            chunks: Array.from(this.chunks.entries()),
            idCounter: this.idCounter,
            exportedAt: new Date().toISOString(),
        };
        return JSON.stringify(data, null, 2);
    }

    /**
     * JSON'dan içe aktar
     */
    public import(json: string): void {
        try {
            const data = JSON.parse(json);
            this.chunks = new Map(data.chunks.map((entry: [string, VectorChunk]) => {
                // Date'leri düzelt
                entry[1].metadata.createdAt = new Date(entry[1].metadata.createdAt);
                return entry;
            }));
            this.idCounter = data.idCounter || this.chunks.size;
            console.log(`[VectorStore] ${this.chunks.size} chunk içe aktarıldı`);
        } catch (error) {
            console.error('[VectorStore] İçe aktarma hatası:', error);
            throw new Error('Geçersiz JSON formatı');
        }
    }
}

// Singleton instance
let vectorStoreInstance: VectorStore | null = null;

/**
 * VectorStore singleton instance al
 */
export function getVectorStore(): VectorStore {
    if (!vectorStoreInstance) {
        vectorStoreInstance = new VectorStore();
    }
    return vectorStoreInstance;
}
