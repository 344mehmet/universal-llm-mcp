/**
 * Universal LLM MCP - Ortak Bilgi Havuzu
 * Tüm modüller (RAG, Debate, Chat, Training) için merkezi bilgi yönetimi
 */
import { EventEmitter } from 'events';
import { getRAGService } from '../rag/rag-service.js';
/**
 * Ortak Bilgi Havuzu
 * Tüm modüller bu havuzu paylaşır
 */
export class SharedKnowledgePool extends EventEmitter {
    ragService = getRAGService();
    learningLog = [];
    autoLearnEnabled = true;
    constructor() {
        super();
        console.log('[KnowledgePool] Başlatıldı - Tüm modüller bağlandı');
    }
    /**
     * Bilgi ekle (tüm kaynaklardan)
     */
    async addKnowledge(content, source, category, metadata) {
        const item = {
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
    async query(question, topK = 3) {
        this.learningLog.push({ type: 'query', query: question });
        const result = await this.ragService.query(question);
        return {
            answer: result.answer,
            sources: result.sources.map((s) => typeof s === 'string' ? s : s.source || s.text || ''),
            relevantChunks: [],
        };
    }
    /**
     * Tartışmadan öğren (Debate sonuçlarını havuza ekle)
     */
    async learnFromDebate(topic, insights, synthesis) {
        if (!this.autoLearnEnabled)
            return;
        // Her insight'ı ekle
        for (const insight of insights) {
            await this.addKnowledge(insight, 'debate', 'tartisma_cikarimlari', { topic, type: 'insight' });
        }
        // Sentezi ekle
        if (synthesis) {
            await this.addKnowledge(`Konu: ${topic}\n\nSonuç: ${synthesis}`, 'debate', 'tartisma_sentezu', { topic, type: 'synthesis' });
        }
        this.emit('debateLearned', { topic, insightCount: insights.length });
        console.log(`[KnowledgePool] Tartışmadan öğrenildi: "${topic}" (${insights.length} çıkarım)`);
    }
    /**
     * Eğitimden öğren (Training sonuçlarını havuza ekle)
     */
    async learnFromTraining(question, answer, category, score) {
        if (!this.autoLearnEnabled || score < 0.7)
            return; // Sadece iyi cevapları öğren
        const content = `Soru: ${question}\nCevap: ${answer}`;
        await this.addKnowledge(content, 'training', category, { score });
        console.log(`[KnowledgePool] Eğitimden öğrenildi: ${category} (skor: ${score.toFixed(2)})`);
    }
    /**
     * Sohbetten öğren (önemli bilgileri otomatik kaydet)
     */
    async learnFromChat(userMessage, aiResponse, isImportant = false) {
        if (!this.autoLearnEnabled || !isImportant)
            return;
        const content = `Kullanıcı: ${userMessage}\nAsistan: ${aiResponse}`;
        await this.addKnowledge(content, 'auto', 'sohbet_notlari');
    }
    /**
     * Otomatik öğrenmeyi aç/kapat
     */
    setAutoLearn(enabled) {
        this.autoLearnEnabled = enabled;
        console.log(`[KnowledgePool] Otomatik öğrenme: ${enabled ? 'AÇIK' : 'KAPALI'}`);
    }
    /**
     * Havuz istatistikleri
     */
    getStats() {
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
    getRecentLearning(limit = 10) {
        return this.learningLog.slice(-limit);
    }
    /**
     * Havuzu temizle
     */
    clear() {
        this.ragService.clear();
        this.learningLog = [];
        console.log('[KnowledgePool] Havuz temizlendi');
    }
}
// Singleton instance
let poolInstance = null;
/**
 * Ortak bilgi havuzu instance'ı al
 */
export function getSharedKnowledgePool() {
    if (!poolInstance) {
        poolInstance = new SharedKnowledgePool();
    }
    return poolInstance;
}
//# sourceMappingURL=knowledge-pool.js.map