/**
 * Universal LLM MCP - Ortak Bilgi Havuzu
 * Tüm modüller (RAG, Debate, Chat, Training) için merkezi bilgi yönetimi
 */
import { EventEmitter } from 'events';
export type KnowledgeSource = 'user' | 'debate' | 'training' | 'import' | 'auto';
export interface KnowledgeItem {
    id: string;
    content: string;
    source: KnowledgeSource;
    category?: string;
    timestamp: Date;
    metadata?: Record<string, any>;
}
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
export declare class SharedKnowledgePool extends EventEmitter {
    private ragService;
    private learningLog;
    private autoLearnEnabled;
    constructor();
    /**
     * Bilgi ekle (tüm kaynaklardan)
     */
    addKnowledge(content: string, source: KnowledgeSource, category?: string, metadata?: Record<string, any>): Promise<string>;
    /**
     * Bilgi sorgula (tum moduller icin)
     */
    query(question: string, topK?: number): Promise<{
        answer: string;
        sources: string[];
        relevantChunks: any[];
    }>;
    /**
     * Tartışmadan öğren (Debate sonuçlarını havuza ekle)
     */
    learnFromDebate(topic: string, insights: string[], synthesis?: string): Promise<void>;
    /**
     * Eğitimden öğren (Training sonuçlarını havuza ekle)
     */
    learnFromTraining(question: string, answer: string, category: string, score: number): Promise<void>;
    /**
     * Sohbetten öğren (önemli bilgileri otomatik kaydet)
     */
    learnFromChat(userMessage: string, aiResponse: string, isImportant?: boolean): Promise<void>;
    /**
     * Otomatik öğrenmeyi aç/kapat
     */
    setAutoLearn(enabled: boolean): void;
    /**
     * Havuz istatistikleri
     */
    getStats(): {
        totalItems: number;
        bySource: Record<string, number>;
        learningEvents: number;
        autoLearnEnabled: boolean;
    };
    /**
     * Son öğrenme olayları
     */
    getRecentLearning(limit?: number): LearningEvent[];
    /**
     * Havuzu temizle
     */
    clear(): void;
}
/**
 * Ortak bilgi havuzu instance'ı al
 */
export declare function getSharedKnowledgePool(): SharedKnowledgePool;
//# sourceMappingURL=knowledge-pool.d.ts.map