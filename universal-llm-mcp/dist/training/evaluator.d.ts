/**
 * Universal LLM MCP - LLM Değerlendirici
 * Cevapları puanlama ve örtük anlam değerlendirmesi
 */
import type { PromptQuestion } from './prompt-bank.js';
export interface EvaluationResult {
    score: number;
    correctness: boolean;
    reasoning: string;
    implicitUnderstanding: number;
    suggestions: string[];
    details: {
        factualAccuracy: number;
        logicChain: number;
        completeness: number;
        clarity: number;
    };
}
export interface ComparisonResult {
    similarity: number;
    keyPointsMatched: string[];
    keyPointsMissed: string[];
    extraPoints: string[];
}
/**
 * LLM Değerlendirici
 */
export declare class Evaluator {
    /**
     * Cevabı değerlendir
     */
    evaluate(question: PromptQuestion, llmAnswer: string): Promise<EvaluationResult>;
    /**
     * İki cevabı karşılaştır
     */
    compare(expectedAnswer: string, actualAnswer: string): Promise<ComparisonResult>;
    /**
     * Basit cevap kontrolü (LLM kullanmadan)
     */
    quickCheck(expectedAnswer: string, actualAnswer: string): number;
    /**
     * Varsayılan sonuç oluştur
     */
    private createDefaultResult;
}
export declare function getEvaluator(): Evaluator;
//# sourceMappingURL=evaluator.d.ts.map