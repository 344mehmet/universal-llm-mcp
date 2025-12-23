/**
 * Universal LLM MCP - Ortak Bilgi Havuzu
 * Tüm modüller (RAG, Debate, Chat, Training) için merkezi bilgi yönetimi
 */

import { EventEmitter } from 'events';
import { getRAGService } from '../rag/rag-service.js';
import { getEmbeddingService } from '../rag/embedding-service.js';

// Bilgi kaynağı türleri
export type KnowledgeSource = 'user' | 'debate' | 'training' | 'import' | 'auto';

// Bilgi öğesi
export interface KnowledgeItem {
    id: string;
    content: string;
    source: KnowledgeSource;
    category?: string;
    timestamp: Date;
    metadata?: Record<string, any>;
}

// Öğrenme olayı
export interface LearningEvent {
    type: 'add' | 'update' | 'query' | 'debate_insight';
    item?: KnowledgeItem;
    query?: string;
    insight?: string;
}

/**
 * Ortak Bilgi Havuzu
 * Tüm modüller bu havuzu paylaşır
 */
export class SharedKnowledgePool extends EventEmitter {
    private ragService = getRAGService();
    private learningLog: LearningEvent[] = [];
    private autoLearnEnabled: boolean = true;

    constructor() {
        super();
        console.log('[KnowledgePool] Başlatıldı - Tüm modüller bağlandı');
    }

    /**
     * Bilgi ekle (tüm kaynaklardan)
     */
    public async addKnowledge(
        content: string,
        source: KnowledgeSource,
        category?: string,
        metadata?: Record<string, any>
    ): Promise<string> {
        const item: KnowledgeItem = {
            id: `kb_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            content,
            source,
            category,
            timestamp: new Date(),
            metadata,
        };

        // RAG'a ekle
        await this.ragService.addDocument(content, `${source}:${category || 'genel'}`);

        // Log ve event
        this.learningLog.push({ type: 'add', item });
        this.emit('knowledgeAdded', item);

        console.log(`[KnowledgePool] Bilgi eklendi: ${source}/${category || 'genel'} (${content.substring(0, 50)}...)`);
        return item.id;
    }

    /**
     * Bilgi sorgula (tum moduller icin)
     */
    public async query(question: string, topK: number = 3): Promise<{
        answer: string;
        sources: string[];
        relevantChunks: any[];
    }> {
        this.learningLog.push({ type: 'query', query: question });

        const result = await this.ragService.query(question);

        return {
            answer: result.answer,
            sources: result.sources.map((s: any) => typeof s === 'string' ? s : s.source || s.text || ''),
            relevantChunks: [],
        };
    }

    /**
     * Tartışmadan öğren (Debate sonuçlarını havuza ekle)
     */
    public async learnFromDebate(
        topic: string,
        insights: string[],
        synthesis?: string
    ): Promise<void> {
        if (!this.autoLearnEnabled) return;

        // Her insight'ı ekle
        for (const insight of insights) {
            await this.addKnowledge(
                insight,
                'debate',
                'tartisma_cikarimlari',
                { topic, type: 'insight' }
            );
        }

        // Sentezi ekle
        if (synthesis) {
            await this.addKnowledge(
                `Konu: ${topic}\n\nSonuç: ${synthesis}`,
                'debate',
                'tartisma_sentezu',
                { topic, type: 'synthesis' }
            );
        }

        this.emit('debateLearned', { topic, insightCount: insights.length });
        console.log(`[KnowledgePool] Tartışmadan öğrenildi: "${topic}" (${insights.length} çıkarım)`);
    }

    /**
     * Eğitimden öğren (Training sonuçlarını havuza ekle)
     */
    public async learnFromTraining(
        question: string,
        answer: string,
        category: string,
        score: number
    ): Promise<void> {
        if (!this.autoLearnEnabled || score < 0.7) return; // Sadece iyi cevapları öğren

        const content = `Soru: ${question}\nCevap: ${answer}`;
        await this.addKnowledge(content, 'training', category, { score });

        console.log(`[KnowledgePool] Eğitimden öğrenildi: ${category} (skor: ${score.toFixed(2)})`);
    }

    /**
     * Sohbetten öğren (önemli bilgileri otomatik kaydet)
     */
    public async learnFromChat(
        userMessage: string,
        aiResponse: string,
        isImportant: boolean = false
    ): Promise<void> {
        if (!this.autoLearnEnabled || !isImportant) return;

        const content = `Kullanıcı: ${userMessage}\nAsistan: ${aiResponse}`;
        await this.addKnowledge(content, 'auto', 'sohbet_notlari');
    }

    /**
     * Otomatik öğrenmeyi aç/kapat
     */
    public setAutoLearn(enabled: boolean): void {
        this.autoLearnEnabled = enabled;
        console.log(`[KnowledgePool] Otomatik öğrenme: ${enabled ? 'AÇIK' : 'KAPALI'}`);
    }

    /**
     * Havuz istatistikleri
     */
    public getStats(): {
        totalItems: number;
        bySource: Record<string, number>;
        learningEvents: number;
        autoLearnEnabled: boolean;
    } {
        const ragStats = this.ragService.getStats();

        return {
            totalItems: ragStats.totalChunks,
            bySource: {},
            learningEvents: this.learningLog.length,
            autoLearnEnabled: this.autoLearnEnabled,
        };
    }

    /**
     * Son öğrenme olayları
     */
    public getRecentLearning(limit: number = 10): LearningEvent[] {
        return this.learningLog.slice(-limit);
    }

    /**
     * Havuzu temizle
     */
    public clear(): void {
        this.ragService.clear();
        this.learningLog = [];
        console.log('[KnowledgePool] Havuz temizlendi');
    }
}

// Singleton instance
let poolInstance: SharedKnowledgePool | null = null;

/**
 * Ortak bilgi havuzu instance'ı al
 */
export function getSharedKnowledgePool(): SharedKnowledgePool {
    if (!poolInstance) {
        poolInstance = new SharedKnowledgePool();
    }
    return poolInstance;
}
