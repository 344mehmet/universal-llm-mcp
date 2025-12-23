/**
 * Universal LLM MCP - Kod Aracı
 * Kod yazma, analiz ve iyileştirme işlemleri
 */
import { z } from 'zod';
export declare const generateCodeSchema: z.ZodObject<{
    description: z.ZodString;
    language: z.ZodString;
    context: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    description: string;
    language: string;
    context?: string | undefined;
}, {
    description: string;
    language: string;
    context?: string | undefined;
}>;
export declare const explainCodeSchema: z.ZodObject<{
    code: z.ZodString;
    language: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    code: string;
    language?: string | undefined;
}, {
    code: string;
    language?: string | undefined;
}>;
export declare const refactorCodeSchema: z.ZodObject<{
    code: z.ZodString;
    instructions: z.ZodString;
    language: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    code: string;
    instructions: string;
    language?: string | undefined;
}, {
    code: string;
    instructions: string;
    language?: string | undefined;
}>;
export declare const debugCodeSchema: z.ZodObject<{
    code: z.ZodString;
    error: z.ZodOptional<z.ZodString>;
    language: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    code: string;
    error?: string | undefined;
    language?: string | undefined;
}, {
    code: string;
    error?: string | undefined;
    language?: string | undefined;
}>;
/**
 * Kod üret
 */
export declare function generateCode(args: z.infer<typeof generateCodeSchema>): Promise<string>;
/**
 * Kodu açıkla
 */
export declare function explainCode(args: z.infer<typeof explainCodeSchema>): Promise<string>;
/**
 * Kodu iyileştir
 */
export declare function refactorCode(args: z.infer<typeof refactorCodeSchema>): Promise<string>;
/**
 * Kodu debug et
 */
export declare function debugCode(args: z.infer<typeof debugCodeSchema>): Promise<string>;
/**
 * Kod araçlarını kaydet
 */
export declare function registerCodeTools(server: any): void;
//# sourceMappingURL=code-tool.d.ts.map