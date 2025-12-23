/**
 * Universal LLM MCP - Prompt/Soru Bankası
 * LLM eğitimi ve değerlendirmesi için soru yönetimi
 */
export type QuestionCategory = 'matematik' | 'mantik' | 'kod' | 'dil' | 'analiz';
export type DifficultyLevel = 1 | 2 | 3 | 4 | 5;
export interface PromptQuestion {
    id: string;
    category: QuestionCategory;
    difficulty: DifficultyLevel;
    question: string;
    expectedAnswer: string;
    hints?: string[];
    contextClues?: string[];
    tags?: string[];
    createdAt: Date;
}
export interface PromptBankStats {
    totalQuestions: number;
    byCategory: Record<QuestionCategory, number>;
    byDifficulty: Record<DifficultyLevel, number>;
}
/**
 * Prompt/Soru Bankası
 */
export declare class PromptBank {
    private questions;
    private dataPath;
    private idCounter;
    constructor(dataPath?: string);
    /**
     * Varsayılan sorular (ilk kurulum için)
     */
    private initializeDefaultQuestions;
    /**
     * Soru ekle
     */
    add(question: Omit<PromptQuestion, 'id' | 'createdAt'>): string;
    /**
     * Soru al
     */
    get(id: string): PromptQuestion | undefined;
    /**
     * Rastgele soru al
     */
    getRandom(filter?: {
        category?: QuestionCategory;
        difficulty?: DifficultyLevel;
    }): PromptQuestion | null;
    /**
     * Kategoriye göre sorular
     */
    getByCategory(category: QuestionCategory): PromptQuestion[];
    /**
     * Zorluğa göre sorular
     */
    getByDifficulty(difficulty: DifficultyLevel): PromptQuestion[];
    /**
     * Soru sil
     */
    delete(id: string): boolean;
    /**
     * Tüm soruları listele
     */
    list(limit?: number): PromptQuestion[];
    /**
     * İstatistikler
     */
    getStats(): PromptBankStats;
    /**
     * Dosyadan yükle
     */
    private loadFromFile;
    /**
     * Dosyaya kaydet
     */
    saveToFile(): void;
}
export declare function getPromptBank(): PromptBank;
//# sourceMappingURL=prompt-bank.d.ts.map