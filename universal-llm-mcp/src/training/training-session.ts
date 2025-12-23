/**
 * Universal LLM MCP - Eğitim Oturumu
 * LLM eğitim ve ilerleme takibi
 */

import { getPromptBank, type PromptQuestion, type QuestionCategory, type DifficultyLevel } from './prompt-bank.js';
import { getEvaluator, type EvaluationResult } from './evaluator.js';

// Oturum durumu
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

// Geçmiş öğesi
export interface SessionHistoryItem {
    questionId: string;
    question: string;
    expectedAnswer: string;
    llmAnswer: string;
    evaluation: EvaluationResult;
    timestamp: Date;
}

// Oturum raporu
export interface SessionReport {
    sessionId: string;
    duration: number;              // saniye
    questionsAsked: number;
    correctAnswers: number;
    averageScore: number;
    categoryBreakdown: Record<string, { asked: number; correct: number; avgScore: number }>;
    weakAreas: string[];
    strongAreas: string[];
    recommendations: string[];
}

/**
 * Eğitim Oturumu Yöneticisi
 */
export class TrainingSession {
    private sessions: Map<string, SessionState> = new Map();
    private currentSessionId: string | null = null;
    private promptBank = getPromptBank();
    private evaluator = getEvaluator();

    /**
     * Yeni oturum başlat
     */
    public start(options?: { category?: QuestionCategory; difficulty?: DifficultyLevel }): SessionState {
        const id = `session_${Date.now()}`;

        const session: SessionState = {
            id,
            startedAt: new Date(),
            category: options?.category,
            difficulty: options?.difficulty,
            questionsAsked: 0,
            correctAnswers: 0,
            totalScore: 0,
            history: [],
        };

        this.sessions.set(id, session);
        this.currentSessionId = id;

        console.log(`[TrainingSession] Oturum başlatıldı: ${id}`);
        return session;
    }

    /**
     * Soru al
     */
    public getNextQuestion(): PromptQuestion | null {
        const session = this.getCurrentSession();
        if (!session) return null;

        return this.promptBank.getRandom({
            category: session.category,
            difficulty: session.difficulty,
        });
    }

    /**
     * Cevabı değerlendir
     */
    public async evaluateAnswer(
        question: PromptQuestion,
        llmAnswer: string
    ): Promise<EvaluationResult> {
        const session = this.getCurrentSession();
        if (!session) {
            throw new Error('Aktif oturum yok!');
        }

        const evaluation = await this.evaluator.evaluate(question, llmAnswer);

        // Oturumu güncelle
        session.questionsAsked++;
        session.totalScore += evaluation.score;
        if (evaluation.correctness) {
            session.correctAnswers++;
        }

        // Geçmişe ekle
        session.history.push({
            questionId: question.id,
            question: question.question,
            expectedAnswer: question.expectedAnswer,
            llmAnswer,
            evaluation,
            timestamp: new Date(),
        });

        return evaluation;
    }

    /**
     * Mevcut ilerleme
     */
    public getProgress(): {
        questionsAsked: number;
        correctAnswers: number;
        averageScore: number;
        successRate: number;
    } | null {
        const session = this.getCurrentSession();
        if (!session) return null;

        return {
            questionsAsked: session.questionsAsked,
            correctAnswers: session.correctAnswers,
            averageScore: session.questionsAsked > 0
                ? Math.round(session.totalScore / session.questionsAsked)
                : 0,
            successRate: session.questionsAsked > 0
                ? Math.round((session.correctAnswers / session.questionsAsked) * 100)
                : 0,
        };
    }

    /**
     * Oturum raporu oluştur
     */
    public generateReport(): SessionReport | null {
        const session = this.getCurrentSession();
        if (!session) return null;

        const duration = Math.round((Date.now() - session.startedAt.getTime()) / 1000);

        // Kategori bazlı analiz
        const categoryBreakdown: Record<string, { asked: number; correct: number; avgScore: number }> = {};

        for (const item of session.history) {
            const q = this.promptBank.get(item.questionId);
            if (!q) continue;

            if (!categoryBreakdown[q.category]) {
                categoryBreakdown[q.category] = { asked: 0, correct: 0, avgScore: 0 };
            }

            categoryBreakdown[q.category].asked++;
            if (item.evaluation.correctness) {
                categoryBreakdown[q.category].correct++;
            }
            categoryBreakdown[q.category].avgScore += item.evaluation.score;
        }

        // Ortalama hesapla
        for (const cat in categoryBreakdown) {
            categoryBreakdown[cat].avgScore = Math.round(
                categoryBreakdown[cat].avgScore / categoryBreakdown[cat].asked
            );
        }

        // Zayıf ve güçlü alanlar
        const weakAreas: string[] = [];
        const strongAreas: string[] = [];

        for (const [cat, stats] of Object.entries(categoryBreakdown)) {
            if (stats.avgScore < 50) {
                weakAreas.push(cat);
            } else if (stats.avgScore >= 80) {
                strongAreas.push(cat);
            }
        }

        // Öneriler
        const recommendations: string[] = [];
        if (weakAreas.length > 0) {
            recommendations.push(`${weakAreas.join(', ')} alanlarında daha fazla pratik yapılmalı.`);
        }
        if (session.history.some(h => h.evaluation.implicitUnderstanding < 50)) {
            recommendations.push('Örtük anlam ve bağlam çıkarımı geliştirilmeli.');
        }

        return {
            sessionId: session.id,
            duration,
            questionsAsked: session.questionsAsked,
            correctAnswers: session.correctAnswers,
            averageScore: this.getProgress()?.averageScore || 0,
            categoryBreakdown,
            weakAreas,
            strongAreas,
            recommendations,
        };
    }

    /**
     * Oturumu sonlandır
     */
    public end(): SessionReport | null {
        const report = this.generateReport();
        this.currentSessionId = null;
        return report;
    }

    /**
     * Mevcut oturum
     */
    public getCurrentSession(): SessionState | null {
        if (!this.currentSessionId) return null;
        return this.sessions.get(this.currentSessionId) || null;
    }

    /**
     * Aktif oturum var mı?
     */
    public hasActiveSession(): boolean {
        return this.currentSessionId !== null;
    }
}

// Singleton
let trainingSessionInstance: TrainingSession | null = null;

export function getTrainingSession(): TrainingSession {
    if (!trainingSessionInstance) {
        trainingSessionInstance = new TrainingSession();
    }
    return trainingSessionInstance;
}
