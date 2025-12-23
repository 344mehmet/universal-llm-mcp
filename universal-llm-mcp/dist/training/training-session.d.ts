/**
 * Universal LLM MCP - Eğitim Oturumu
 * LLM eğitim ve ilerleme takibi
 */
import { type PromptQuestion, type QuestionCategory, type DifficultyLevel } from './prompt-bank.js';
import { type EvaluationResult } from './evaluator.js';
export interface SessionState {
    id: string;
    startedAt: Date;
    category?: QuestionCategory;
    difficulty?: DifficultyLevel;
    questionsAsked: number;
    correctAnswers: number;
    totalScore: number;
    history: SessionHistoryItem[];
}
export interface SessionHistoryItem {
    questionId: string;
    question: string;
    expectedAnswer: string;
    llmAnswer: string;
    evaluation: EvaluationResult;
    timestamp: Date;
}
export interface SessionReport {
    sessionId: string;
    duration: number;
    questionsAsked: number;
    correctAnswers: number;
    averageScore: number;
    categoryBreakdown: Record<string, {
        asked: number;
        correct: number;
        avgScore: number;
    }>;
    weakAreas: string[];
    strongAreas: string[];
    recommendations: string[];
}
/**
 * Eğitim Oturumu Yöneticisi
 */
export declare class TrainingSession {
    private sessions;
    private currentSessionId;
    private promptBank;
    private evaluator;
    /**
     * Yeni oturum başlat
     */
    start(options?: {
        category?: QuestionCategory;
        difficulty?: DifficultyLevel;
    }): SessionState;
    /**
     * Soru al
     */
    getNextQuestion(): PromptQuestion | null;
    /**
     * Cevabı değerlendir
     */
    evaluateAnswer(question: PromptQuestion, llmAnswer: string): Promise<EvaluationResult>;
    /**
     * Mevcut ilerleme
     */
    getProgress(): {
        questionsAsked: number;
        correctAnswers: number;
        averageScore: number;
        successRate: number;
    } | null;
    /**
     * Oturum raporu oluştur
     */
    generateReport(): SessionReport | null;
    /**
     * Oturumu sonlandır
     */
    end(): SessionReport | null;
    /**
     * Mevcut oturum
     */
    getCurrentSession(): SessionState | null;
    /**
     * Aktif oturum var mı?
     */
    hasActiveSession(): boolean;
}
export declare function getTrainingSession(): TrainingSession;
//# sourceMappingURL=training-session.d.ts.map