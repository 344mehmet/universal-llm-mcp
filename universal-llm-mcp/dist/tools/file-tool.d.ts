/**
 * Universal LLM MCP - Dosya Aracı
 * Dosya analizi ve dokümantasyon üretme
 */
import { z } from 'zod';
export declare const analyzeFileSchema: z.ZodObject<{
    filePath: z.ZodString;
    analysisType: z.ZodOptional<z.ZodEnum<["genel", "guvenlik", "performans", "kod_kalitesi"]>>;
}, "strip", z.ZodTypeAny, {
    filePath: string;
    analysisType?: "genel" | "guvenlik" | "performans" | "kod_kalitesi" | undefined;
}, {
    filePath: string;
    analysisType?: "genel" | "guvenlik" | "performans" | "kod_kalitesi" | undefined;
}>;
export declare const analyzeContentSchema: z.ZodObject<{
    content: z.ZodString;
    contentType: z.ZodString;
    analysisType: z.ZodOptional<z.ZodEnum<["genel", "guvenlik", "performans", "kod_kalitesi"]>>;
}, "strip", z.ZodTypeAny, {
    content: string;
    contentType: string;
    analysisType?: "genel" | "guvenlik" | "performans" | "kod_kalitesi" | undefined;
}, {
    content: string;
    contentType: string;
    analysisType?: "genel" | "guvenlik" | "performans" | "kod_kalitesi" | undefined;
}>;
export declare const generateDocsSchema: z.ZodObject<{
    code: z.ZodString;
    language: z.ZodString;
    docStyle: z.ZodOptional<z.ZodEnum<["jsdoc", "sphinx", "markdown", "readme"]>>;
}, "strip", z.ZodTypeAny, {
    code: string;
    language: string;
    docStyle?: "jsdoc" | "sphinx" | "markdown" | "readme" | undefined;
}, {
    code: string;
    language: string;
    docStyle?: "jsdoc" | "sphinx" | "markdown" | "readme" | undefined;
}>;
export declare const compareFilesSchema: z.ZodObject<{
    content1: z.ZodString;
    content2: z.ZodString;
    comparisonType: z.ZodOptional<z.ZodEnum<["diff", "semantic", "both"]>>;
}, "strip", z.ZodTypeAny, {
    content1: string;
    content2: string;
    comparisonType?: "diff" | "semantic" | "both" | undefined;
}, {
    content1: string;
    content2: string;
    comparisonType?: "diff" | "semantic" | "both" | undefined;
}>;
/**
 * Dosya analiz et
 */
export declare function analyzeFile(args: z.infer<typeof analyzeFileSchema>): Promise<string>;
/**
 * İçerik analiz et
 */
export declare function analyzeContent(args: z.infer<typeof analyzeContentSchema>): Promise<string>;
/**
 * Dokümantasyon üret
 */
export declare function generateDocs(args: z.infer<typeof generateDocsSchema>): Promise<string>;
/**
 * Dosyaları karşılaştır
 */
export declare function compareFiles(args: z.infer<typeof compareFilesSchema>): Promise<string>;
/**
 * Dosya araçlarını kaydet
 */
export declare function registerFileTools(server: any): void;
//# sourceMappingURL=file-tool.d.ts.map