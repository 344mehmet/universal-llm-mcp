/**
 * Universal LLM MCP - Çeviri Aracı
 * Dil çevirisi ve yerelleştirme
 */
import { z } from 'zod';
export declare const translateSchema: z.ZodObject<{
    text: z.ZodString;
    from: z.ZodOptional<z.ZodEnum<["tr", "en", "de", "fr", "es", "it", "ru", "ar", "zh", "ja", "ko"]>>;
    to: z.ZodEnum<["tr", "en", "de", "fr", "es", "it", "ru", "ar", "zh", "ja", "ko"]>;
    style: z.ZodOptional<z.ZodEnum<["formal", "informal", "technical", "literary"]>>;
}, "strip", z.ZodTypeAny, {
    text: string;
    to: "tr" | "en" | "de" | "fr" | "es" | "it" | "ru" | "ar" | "zh" | "ja" | "ko";
    style?: "formal" | "informal" | "technical" | "literary" | undefined;
    from?: "tr" | "en" | "de" | "fr" | "es" | "it" | "ru" | "ar" | "zh" | "ja" | "ko" | undefined;
}, {
    text: string;
    to: "tr" | "en" | "de" | "fr" | "es" | "it" | "ru" | "ar" | "zh" | "ja" | "ko";
    style?: "formal" | "informal" | "technical" | "literary" | undefined;
    from?: "tr" | "en" | "de" | "fr" | "es" | "it" | "ru" | "ar" | "zh" | "ja" | "ko" | undefined;
}>;
export declare const localizeSchema: z.ZodObject<{
    text: z.ZodString;
    targetCulture: z.ZodString;
    context: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    text: string;
    targetCulture: string;
    context?: string | undefined;
}, {
    text: string;
    targetCulture: string;
    context?: string | undefined;
}>;
export declare const detectLanguageSchema: z.ZodObject<{
    text: z.ZodString;
}, "strip", z.ZodTypeAny, {
    text: string;
}, {
    text: string;
}>;
/**
 * Metin çevir
 */
export declare function translate(args: z.infer<typeof translateSchema>): Promise<string>;
/**
 * Yerelleştirme
 */
export declare function localize(args: z.infer<typeof localizeSchema>): Promise<string>;
/**
 * Dil algıla
 */
export declare function detectLanguage(args: z.infer<typeof detectLanguageSchema>): Promise<string>;
/**
 * Çeviri araçlarını kaydet
 */
export declare function registerTranslateTools(server: any): void;
//# sourceMappingURL=translate-tool.d.ts.map