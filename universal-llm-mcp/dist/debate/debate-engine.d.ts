/**
 * Universal LLM MCP - Multi-Agent Debate Engine
 * LLM'ler arası otonom tartışma sistemi
 */
import { EventEmitter } from 'events';
export type DebateRole = 'advocate' | 'critic' | 'synthesizer';
export type ExpertiseDomain = 'coding' | 'mathematics' | 'analytics' | 'spacetime' | 'general';
export interface DebateTurn {
    turnNumber: number;
    speaker: string;
    role: DebateRole;
    content: string;
    timestamp: Date;
    tokensUsed?: number;
}
export interface DebateConfig {
    topic: string;
    maxTurns: number;
    domains: ExpertiseDomain[];
    participants: string[];
    synthesizeAtEnd: boolean;
}
export type DebateStatus = 'idle' | 'running' | 'paused' | 'completed' | 'error';
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
/**
 * Multi-Agent Debate Engine
 */
export declare class DebateEngine extends EventEmitter {
    private currentDebate;
    private debateHistory;
    private isRunning;
    private debateIdCounter;
    constructor();
    /**
     * Yeni tartışma başlat
     */
    startDebate(config: DebateConfig): Promise<DebateResult>;
    /**
     * Tartışma döngüsü
     */
    private runDebate;
    /**
     * Sentez oluştur
     */
    private generateSynthesis;
    /**
     * Sistem promptu oluştur
     */
    private buildSystemPrompt;
    /**
     * Kullanıcı promptu oluştur
     */
    private buildUserPrompt;
    /**
     * Bekleme
     */
    private delay;
    /**
     * Mevcut tartışmayı al
     */
    getCurrentDebate(): DebateResult | null;
    /**
     * Tartışma geçmişi
     */
    getHistory(limit?: number): DebateResult[];
    /**
     * Tartışma durumu
     */
    getStatus(): {
        isRunning: boolean;
        currentTopic?: string;
        turnCount?: number;
    };
    /**
     * Tartışmayı durdur
     */
    stopDebate(): void;
}
/**
 * DebateEngine singleton instance al
 */
export declare function getDebateEngine(): DebateEngine;
export declare const DEFAULT_DEBATE_CONFIG: Partial<DebateConfig>;
//# sourceMappingURL=debate-engine.d.ts.map