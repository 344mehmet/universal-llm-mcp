/**
 * Universal LLM MCP - Multi-Agent Debate Engine
 * LLM'ler arası otonom tartışma sistemi
 */

import { EventEmitter } from 'events';
import { getRouter, TaskType } from '../router/llm-router.js';

// Tartışma rolleri
export type DebateRole = 'advocate' | 'critic' | 'synthesizer';

// Uzmanlık alanları
export type ExpertiseDomain = 'coding' | 'mathematics' | 'analytics' | 'spacetime' | 'general';

// Tartışma turu
export interface DebateTurn {
    turnNumber: number;
    speaker: string;
    role: DebateRole;
    content: string;
    timestamp: Date;
    tokensUsed?: number;
}

// Tartışma yapılandırması
export interface DebateConfig {
    topic: string;
    maxTurns: number;
    domains: ExpertiseDomain[];
    participants: string[];
    synthesizeAtEnd: boolean;
}

// Tartışma durumu
export type DebateStatus = 'idle' | 'running' | 'paused' | 'completed' | 'error';

// Tartışma sonucu
export interface DebateResult {
    id: string;
    topic: string;
    status: DebateStatus;
    turns: DebateTurn[];
    synthesis?: string;
    startTime: Date;
    endTime?: Date;
    totalTokens: number;
}

// Uzmanlık sistem promptları
const EXPERTISE_PROMPTS: Record<ExpertiseDomain, string> = {
    coding: `Sen bir yazılım mühendisi uzmanısın. Algoritma, veri yapıları, yazılım mimarisi, 
        programlama dilleri (Python, TypeScript, MQL5, C++) konularında derin bilgiye sahipsin.
        Kod örnekleri ve teknik açıklamalar yapabilirsin.`,

    mathematics: `Sen bir matematik ve istatistik uzmanısın. Calculus, lineer cebir, olasılık,
        diferansiyel denklemler, sayısal analiz konularında derin bilgiye sahipsin.
        Formüller ve matematiksel kanıtlar sunabilirsin.`,

    analytics: `Sen bir analitik düşünce ve mantık uzmanısın. Problem çözme, kritik düşünme,
        veri analizi, pattern recognition, karar teorisi konularında uzmansın.
        Sistematik ve mantıksal argümanlar geliştirirsin.`,

    spacetime: `Sen bir teorik fizik uzmanısın. Görelilik teorisi, kuantum mekaniği,
        uzay-zaman geometrisi, kozmoloji, kara delikler konularında derin bilgiye sahipsin.
        Bilimsel açıklamalar ve düşünce deneyleri yapabilirsin.`,

    general: `Sen çok yönlü bir düşünür ve analistsin. Farklı disiplinlerden bilgileri
        sentezleyebilir, yaratıcı çözümler üretebilirsin.`,
};

// Rol sistem promptları
const ROLE_PROMPTS: Record<DebateRole, string> = {
    advocate: `Bu tartışmada SAVUNUCU rolündesin. Konuyu olumlu açıdan ele al,
        güçlü argümanlar sun, fikirleri destekle.`,

    critic: `Bu tartışmada ELEŞTİRMEN rolündesin. Karşı argümanlar sun,
        zayıf noktaları bul, alternatif bakış açıları öner.`,

    synthesizer: `Bu tartışmada SENTEZCİ rolündesin. Tüm görüşleri birleştir,
        ortak noktaları bul, dengeli bir sonuç oluştur.`,
};

/**
 * Multi-Agent Debate Engine
 */
export class DebateEngine extends EventEmitter {
    private currentDebate: DebateResult | null = null;
    private debateHistory: DebateResult[] = [];
    private isRunning: boolean = false;
    private debateIdCounter: number = 0;

    constructor() {
        super();
        console.log('[DebateEngine] Başlatıldı');
    }

    /**
     * Yeni tartışma başlat
     */
    public async startDebate(config: DebateConfig): Promise<DebateResult> {
        if (this.isRunning) {
            throw new Error('Bir tartışma zaten devam ediyor');
        }

        const debateId = `debate_${++this.debateIdCounter}_${Date.now()}`;

        this.currentDebate = {
            id: debateId,
            topic: config.topic,
            status: 'running',
            turns: [],
            startTime: new Date(),
            totalTokens: 0,
        };

        this.isRunning = true;
        this.emit('debateStarted', this.currentDebate);

        console.log(`[DebateEngine] Tartışma başladı: "${config.topic}"`);
        console.log(`[DebateEngine] Katılımcılar: ${config.participants.join(', ')}`);
        console.log(`[DebateEngine] Uzmanlık alanları: ${config.domains.join(', ')}`);

        try {
            await this.runDebate(config);

            if (config.synthesizeAtEnd) {
                await this.generateSynthesis(config);
            }

            this.currentDebate.status = 'completed';
            this.currentDebate.endTime = new Date();

        } catch (error) {
            console.error('[DebateEngine] Tartışma hatası:', error);
            this.currentDebate.status = 'error';
            this.currentDebate.endTime = new Date();
        }

        this.isRunning = false;
        this.debateHistory.push(this.currentDebate);
        this.emit('debateCompleted', this.currentDebate);

        return this.currentDebate;
    }

    /**
     * Tartışma döngüsü
     */
    private async runDebate(config: DebateConfig): Promise<void> {
        const router = getRouter();
        const participants = config.participants;

        // İlk tur: Konu hakkında görüş
        for (let turn = 1; turn <= config.maxTurns; turn++) {
            for (let i = 0; i < participants.length; i++) {
                const participant = participants[i];
                const role: DebateRole = turn === config.maxTurns && i === participants.length - 1
                    ? 'synthesizer'
                    : (i % 2 === 0 ? 'advocate' : 'critic');

                const systemPrompt = this.buildSystemPrompt(config.domains, role, turn);
                const userPrompt = this.buildUserPrompt(config.topic, turn, this.currentDebate!.turns);

                console.log(`[DebateEngine] Tur ${turn} - ${participant} (${role})`);

                try {
                    const response = await router.complete('chat', userPrompt, systemPrompt);

                    const debateTurn: DebateTurn = {
                        turnNumber: turn,
                        speaker: participant,
                        role,
                        content: response.content,
                        timestamp: new Date(),
                        tokensUsed: response.tokensUsed,
                    };

                    this.currentDebate!.turns.push(debateTurn);
                    this.currentDebate!.totalTokens += response.tokensUsed || 0;

                    this.emit('turnCompleted', debateTurn);
                    console.log(`[DebateEngine] ${participant}: ${response.content.substring(0, 100)}...`);

                    // Kısa bekleme
                    await this.delay(500);

                } catch (error) {
                    console.error(`[DebateEngine] ${participant} hatası:`, error);
                    // Diğer katılımcıyla devam et
                }
            }
        }
    }

    /**
     * Sentez oluştur
     */
    private async generateSynthesis(config: DebateConfig): Promise<void> {
        const router = getRouter();

        const allTurns = this.currentDebate!.turns
            .map(t => `[${t.speaker} - ${t.role}]: ${t.content}`)
            .join('\n\n');

        const systemPrompt = `Sen bir tartışma moderatörüsün. Aşağıdaki tartışmayı analiz et ve:
1. Ana argümanları özetle
2. Ortak noktaları belirle
3. Farklılıkları not et
4. Dengeli bir sonuç oluştur

Uzmanlık alanların: ${config.domains.join(', ')}`;

        const userPrompt = `Konu: "${config.topic}"

Tartışma:
${allTurns}

Lütfen bu tartışmanın kapsamlı bir sentezini oluştur.`;

        try {
            const response = await router.complete('chat', userPrompt, systemPrompt);
            this.currentDebate!.synthesis = response.content;
            this.currentDebate!.totalTokens += response.tokensUsed || 0;

            console.log('[DebateEngine] Sentez oluşturuldu');
            this.emit('synthesisCompleted', response.content);
        } catch (error) {
            console.error('[DebateEngine] Sentez hatası:', error);
        }
    }

    /**
     * Sistem promptu oluştur
     */
    private buildSystemPrompt(domains: ExpertiseDomain[], role: DebateRole, turn: number): string {
        const expertisePrompts = domains.map(d => EXPERTISE_PROMPTS[d]).join('\n\n');
        const rolePrompt = ROLE_PROMPTS[role];

        return `${expertisePrompts}

${rolePrompt}

Bu ${turn}. tur. Önceki konuşmalara dayanarak düşünceli ve derinlemesine bir yanıt ver.
Türkçe yanıt ver. Kısa ve öz ol ama içerik zengin olsun.`;
    }

    /**
     * Kullanıcı promptu oluştur
     */
    private buildUserPrompt(topic: string, turn: number, previousTurns: DebateTurn[]): string {
        if (turn === 1 && previousTurns.length === 0) {
            return `Tartışma konusu: "${topic}"

Bu konuda ilk görüşünü paylaş. Neden önemli? Ne düşünüyorsun?`;
        }

        const recentTurns = previousTurns.slice(-3)
            .map(t => `[${t.speaker}]: ${t.content}`)
            .join('\n\n');

        return `Tartışma konusu: "${topic}"

Önceki konuşmalar:
${recentTurns}

Şimdi senin sıran. Önceki görüşlere yanıt ver, kendi perspektifini ekle.`;
    }

    /**
     * Bekleme
     */
    private delay(ms: number): Promise<void> {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /**
     * Mevcut tartışmayı al
     */
    public getCurrentDebate(): DebateResult | null {
        return this.currentDebate;
    }

    /**
     * Tartışma geçmişi
     */
    public getHistory(limit: number = 10): DebateResult[] {
        return this.debateHistory.slice(-limit);
    }

    /**
     * Tartışma durumu
     */
    public getStatus(): { isRunning: boolean; currentTopic?: string; turnCount?: number } {
        return {
            isRunning: this.isRunning,
            currentTopic: this.currentDebate?.topic,
            turnCount: this.currentDebate?.turns.length,
        };
    }

    /**
     * Tartışmayı durdur
     */
    public stopDebate(): void {
        if (this.isRunning && this.currentDebate) {
            this.currentDebate.status = 'paused';
            this.isRunning = false;
            this.emit('debatePaused', this.currentDebate);
            console.log('[DebateEngine] Tartışma durduruldu');
        }
    }
}

// Singleton instance
let debateEngineInstance: DebateEngine | null = null;

/**
 * DebateEngine singleton instance al
 */
export function getDebateEngine(): DebateEngine {
    if (!debateEngineInstance) {
        debateEngineInstance = new DebateEngine();
    }
    return debateEngineInstance;
}

// Varsayılan tartışma yapılandırması
export const DEFAULT_DEBATE_CONFIG: Partial<DebateConfig> = {
    maxTurns: 3,
    domains: ['coding', 'mathematics', 'analytics', 'spacetime'],
    participants: ['lmstudio', 'ollama'],
    synthesizeAtEnd: true,
};
