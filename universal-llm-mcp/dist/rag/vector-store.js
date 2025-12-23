/**
 * Universal LLM MCP - Vector Store
 * Bellek tabanlı vektör depolama ve semantik arama
 * Türkçe destekli RAG sistemi için
 */
/**
 * Bellek Tabanlı Vector Store
 * Cosine similarity ile semantik arama yapar
 */
export class VectorStore {
    chunks = new Map();
    idCounter = 0;
    /**
     * Yeni chunk ekle
     */
    add(text, embedding, metadata) {
        const id = `chunk_${++this.idCounter}_${Date.now()}`;
        const chunk = {
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
    addBatch(items) {
        return items.map(item => this.add(item.text, item.embedding, item.metadata || {}));
    }
    /**
     * Chunk sil
     */
    delete(id) {
        const deleted = this.chunks.delete(id);
        if (deleted) {
            console.log(`[VectorStore] Chunk silindi: ${id}`);
        }
        return deleted;
    }
    /**
     * Kaynağa göre tüm chunk'ları sil
     */
    deleteBySource(source) {
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
    search(queryEmbedding, topK = 3, filter) {
        const results = [];
        for (const chunk of this.chunks.values()) {
            // Filtre kontrolü
            if (filter) {
                if (filter.source && chunk.metadata.source !== filter.source)
                    continue;
                if (filter.category && chunk.metadata.category !== filter.category)
                    continue;
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
    cosineSimilarity(a, b) {
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
        if (magnitude === 0)
            return 0;
        return dotProduct / magnitude;
    }
    /**
     * Tüm chunk'ları listele
     */
    list(limit) {
        const all = Array.from(this.chunks.values());
        return limit ? all.slice(0, limit) : all;
    }
    /**
     * Kaynağa göre listele
     */
    listBySource(source) {
        return Array.from(this.chunks.values())
            .filter(chunk => chunk.metadata.source === source);
    }
    /**
     * Chunk sayısı
     */
    size() {
        return this.chunks.size;
    }
    /**
     * Tüm kaynakları listele
     */
    getSources() {
        const sources = new Set();
        for (const chunk of this.chunks.values()) {
            sources.add(chunk.metadata.source);
        }
        return Array.from(sources);
    }
    /**
     * İstatistikler
     */
    getStats() {
        const categories = new Set();
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
    clear() {
        this.chunks.clear();
        this.idCounter = 0;
        console.log('[VectorStore] Tüm veriler silindi');
    }
    /**
     * JSON olarak dışa aktar (kalıcılık için)
     */
    export() {
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
    import(json) {
        try {
            const data = JSON.parse(json);
            this.chunks = new Map(data.chunks.map((entry) => {
                // Date'leri düzelt
                entry[1].metadata.createdAt = new Date(entry[1].metadata.createdAt);
                return entry;
            }));
            this.idCounter = data.idCounter || this.chunks.size;
            console.log(`[VectorStore] ${this.chunks.size} chunk içe aktarıldı`);
        }
        catch (error) {
            console.error('[VectorStore] İçe aktarma hatası:', error);
            throw new Error('Geçersiz JSON formatı');
        }
    }
}
// Singleton instance
let vectorStoreInstance = null;
/**
 * VectorStore singleton instance al
 */
export function getVectorStore() {
    if (!vectorStoreInstance) {
        vectorStoreInstance = new VectorStore();
    }
    return vectorStoreInstance;
}
//# sourceMappingURL=vector-store.js.map