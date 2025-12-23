/**
 * Universal LLM MCP - Hızlı Eğitim Modülü
 * REG (Regularization) + Fine-tuning desteği
 */
import { EventEmitter } from 'events';
export interface TrainingExample {
    id: string;
    input: string;
    expectedOutput: string;
    category: string;
    difficulty: number;
    weight: number;
}
export interface TrainingResult {
    exampleId: string;
    actualOutput: string;
    score: number;
    latencyMs: number;
    feedback?: string;
}
export interface FineTuneBatch {
    examples: TrainingExample[];
    batchSize: number;
    learningRate: number;
    epochs: number;
}
export interface TrainingMetrics {
    totalExamples: number;
    completedExamples: number;
    averageScore: number;
    averageLatency: number;
    topCategories: {
        category: string;
        score: number;
    }[];
    weakCategories: {
        category: string;
        score: number;
    }[];
}
/**
 * Hızlı Eğitim Motoru
 */
export declare class FastTrainer extends EventEmitter {
    private examples;
    private results;
    private scoreCache;
    private isTraining;
    private knowledgePool;
    private regularizationStrength;
    private dropoutRate;
    private momentumDecay;
    constructor();
    /**
     * Eğitim örneği ekle
     */
    addExample(example: Omit<TrainingExample, 'id' | 'weight'>): string;
    /**
     * REG: Ağırlık hesaplama
     */
    private calculateWeight;
    /**
     * Hızlı batch eğitimi
     */
    trainBatch(options?: Partial<FineTuneBatch>): Promise<TrainingMetrics>;
    /**
     * Tek örnek eğitimi
     */
    private trainSingle;
    /**
     * Basit skor hesaplama
     */
    private calculateScore;
    /**
     * REG: Momentum shuffle
     */
    private shuffleWithMomentum;
    /**
     * Metrik hesaplama
     */
    private calculateMetrics;
    /**
     * Anlık eğitim (tek örnek, hızlı)
     */
    quickTrain(input: string, expected: string, category?: string): Promise<TrainingResult>;
    /**
     * REG parametrelerini ayarla
     */
    setRegularization(strength: number, dropout: number, momentum: number): void;
    /**
     * İstatistikler
     */
    getStats(): {
        exampleCount: number;
        categoryCount: number;
        isTraining: boolean;
    };
}
export declare function getFastTrainer(): FastTrainer;
//# sourceMappingURL=fast-trainer.d.ts.map