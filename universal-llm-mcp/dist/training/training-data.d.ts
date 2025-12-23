/**
 * Universal LLM MCP - Kapsamlı Eğitim Veri Seti
 * Tüm kategoriler: matematik, kod, dil, analiz, uzay-zaman
 */
export interface TrainingSet {
    category: string;
    examples: Array<{
        input: string;
        expectedOutput: string;
        difficulty: number;
    }>;
}
export declare const MATEMATIK_ORNEKLERI: TrainingSet;
export declare const KOD_ORNEKLERI: TrainingSet;
export declare const DIL_ORNEKLERI: TrainingSet;
export declare const ANALIZ_ORNEKLERI: TrainingSet;
export declare const UZAYZAMAN_ORNEKLERI: TrainingSet;
export declare const TUM_EGITIM_SETLERI: TrainingSet[];
/**
 * Tüm örnekleri yükle
 */
export declare function loadAllTrainingExamples(): number;
/**
 * Belirli kategori yükle
 */
export declare function loadCategoryExamples(category: string): number;
//# sourceMappingURL=training-data.d.ts.map