/**
 * Universal LLM MCP - RAG Service
 * Ana RAG (Retrieval-Augmented Generation) servisi
 * Bilgi ekleme, sorgulama ve bağlam zenginleştirme
 */

import { getVectorStore, type VectorChunk, type SearchResult } from './vector-store.js';
import { getEmbeddingService } from './embedding-service.js';
import { getDocumentProcessor } from './document-processor.js';
import { getRouter } from '../router/llm-router.js';
import { getConfigManager } from '../config.js';

// RAG sorgu sonucu
export interface RAGQueryResult {
    answer: string;
    sources: Array<{
        text: string;
        source: string;
        similarity: number;
    }>;
    tokensUsed?: number;
}

// Ekleme sonucu
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
export class RAGService {
    private vectorStore = getVectorStore();
    private embeddingService = getEmbeddingService();
    private documentProcessor = getDocumentProcessor();

    // Varsayılan ayarlar
    private topK: number = 3;
    private minSimilarity: number = 0.5;

    constructor() {
        // Config'den ayarları al
        const config = getConfigManager().getConfig();
        if (config.rag) {
            this.topK = config.rag.topK || 3;
        }
        console.log('[RAGService] Başlatıldı');
    }

    /**
     * Bilgi tabanına metin ekle
     */
    public async addDocument(text: string, source: string, category?: string): Promise<RAGAddResult> {
        try {
            console.log(`[RAGService] Belge ekleniyor: ${source}`);

            // Metni chunk'lara böl
            const chunks = this.documentProcessor.processWithCodeBlocks(text);
            console.log(`[RAGService] ${chunks.length} chunk oluşturuldu`);

            // Her chunk için embedding üret
            let addedCount = 0;
            for (const chunk of chunks) {
                if (chunk.text.trim().length < 10) continue; // Çok kısa chunk'ları atla

                try {
                    const { embedding } = await this.embeddingService.embed(chunk.text);

                    this.vectorStore.add(chunk.text, embedding, {
                        source,
                        category,
                    });
                    addedCount++;
                } catch (embedError) {
                    console.error(`[RAGService] Chunk embedding hatası:`, embedError);
                }
            }

            return {
                success: true,
                chunksAdded: addedCount,
                source,
                message: `${addedCount} bilgi parçası başarıyla eklendi.`,
            };
        } catch (error) {
            console.error('[RAGService] Belge ekleme hatası:', error);
            return {
                success: false,
                chunksAdded: 0,
                source,
                message: `Hata: ${error}`,
            };
        }
    }

    /**
     * RAG ile sorgula - İlgili bilgileri bul ve LLM'e sor
     */
    public async query(question: string, options?: { topK?: number; category?: string }): Promise<RAGQueryResult> {
        const topK = options?.topK || this.topK;

        try {
            console.log(`[RAGService] Sorgu: ${question.substring(0, 50)}...`);

            // Soru için embedding üret
            const { embedding: queryEmbedding } = await this.embeddingService.embed(question);

            // Benzer chunk'ları bul
            const searchResults = this.vectorStore.search(
                queryEmbedding,
                topK,
                options?.category ? { category: options.category } : undefined
            );

            if (searchResults.length === 0) {
                return {
                    answer: 'Bilgi tabanında bu soruyla ilgili bilgi bulunamadı.',
                    sources: [],
                };
            }

            // Düşük benzerlik skorlu sonuçları filtrele
            const relevantResults = searchResults.filter(r => r.similarity >= this.minSimilarity);

            if (relevantResults.length === 0) {
                return {
                    answer: 'Yeterli benzerlikte bilgi bulunamadı. Lütfen sorunuzu farklı şekilde ifade edin.',
                    sources: [],
                };
            }

            // Bağlam oluştur
            const context = this.buildContext(relevantResults);

            // LLM'e sor
            const answer = await this.askLLMWithContext(question, context);

            return {
                answer,
                sources: relevantResults.map(r => ({
                    text: r.chunk.text.substring(0, 200) + (r.chunk.text.length > 200 ? '...' : ''),
                    source: r.chunk.metadata.source,
                    similarity: Math.round(r.similarity * 100) / 100,
                })),
            };
        } catch (error) {
            console.error('[RAGService] Sorgu hatası:', error);
            return {
                answer: `Sorgu işlenirken hata oluştu: ${error}`,
                sources: [],
            };
        }
    }

    /**
     * Bağlam metni oluştur
     */
    private buildContext(results: SearchResult[]): string {
        let context = '## İlgili Bilgiler:\n\n';

        for (let i = 0; i < results.length; i++) {
            const result = results[i];
            context += `### Kaynak ${i + 1} (${result.chunk.metadata.source}):\n`;
            context += result.chunk.text + '\n\n';
        }

        return context;
    }

    /**
     * LLM'e bağlamla birlikte sor
     */
    private async askLLMWithContext(question: string, context: string): Promise<string> {
        const router = getRouter();

        const prompt = `Aşağıdaki bilgileri kullanarak soruyu Türkçe olarak cevapla.

${context}

## Soru:
${question}

## Talimatlar:
- Sadece verilen bilgilere dayanarak cevap ver
- Bilgiler yetersizse bunu belirt
- Cevabı açık ve anlaşılır şekilde yaz
- Kaynaklara atıfta bulun`;

        const response = await router.complete('default', prompt,
            'Sen bir bilgi asistanısın. Verilen bağlamdan doğru ve öz bilgiler çıkar, Türkçe cevap ver.'
        );

        return response.content;
    }

    /**
     * Eklenen bilgileri listele
     */
    public listDocuments(limit?: number): Array<{ source: string; chunkCount: number; preview: string }> {
        const sources = this.vectorStore.getSources();

        return sources.map(source => {
            const chunks = this.vectorStore.listBySource(source);
            return {
                source,
                chunkCount: chunks.length,
                preview: chunks[0]?.text.substring(0, 100) + '...' || '',
            };
        }).slice(0, limit);
    }

    /**
     * Kaynak sil
     */
    public deleteSource(source: string): number {
        return this.vectorStore.deleteBySource(source);
    }

    /**
     * İstatistikler
     */
    public getStats() {
        return this.vectorStore.getStats();
    }

    /**
     * Tüm veriyi temizle
     */
    public clear(): void {
        this.vectorStore.clear();
    }
}

// Singleton instance
let ragServiceInstance: RAGService | null = null;

/**
 * RAGService singleton instance al
 */
export function getRAGService(): RAGService {
    if (!ragServiceInstance) {
        ragServiceInstance = new RAGService();
    }
    return ragServiceInstance;
}
