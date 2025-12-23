/**
 * Universal LLM MCP - Sohbet Aracı
 * Türkçe sohbet, özetleme ve beyin fırtınası
 */
import { z } from 'zod';
export declare const turkishChatSchema: z.ZodObject<{
    message: z.ZodString;
    context: z.ZodOptional<z.ZodString>;
    personality: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    message: string;
    context?: string | undefined;
    personality?: string | undefined;
}, {
    message: string;
    context?: string | undefined;
    personality?: string | undefined;
}>;
export declare const summarizeSchema: z.ZodObject<{
    text: z.ZodString;
    style: z.ZodOptional<z.ZodEnum<["kisa", "orta", "detayli"]>>;
    format: z.ZodOptional<z.ZodEnum<["paragraf", "maddeler", "basliklar"]>>;
}, "strip", z.ZodTypeAny, {
    text: string;
    style?: "kisa" | "orta" | "detayli" | undefined;
    format?: "paragraf" | "maddeler" | "basliklar" | undefined;
}, {
    text: string;
    style?: "kisa" | "orta" | "detayli" | undefined;
    format?: "paragraf" | "maddeler" | "basliklar" | undefined;
}>;
export declare const brainstormSchema: z.ZodObject<{
    topic: z.ZodString;
    count: z.ZodOptional<z.ZodNumber>;
    constraints: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    topic: string;
    count?: number | undefined;
    constraints?: string | undefined;
}, {
    topic: string;
    count?: number | undefined;
    constraints?: string | undefined;
}>;
/**
 * Türkçe sohbet
 */
export declare function turkishChat(args: z.infer<typeof turkishChatSchema>): Promise<string>;
/**
 * Metin özetle
 */
export declare function summarize(args: z.infer<typeof summarizeSchema>): Promise<string>;
/**
 * Beyin fırtınası
 */
export declare function brainstorm(args: z.infer<typeof brainstormSchema>): Promise<string>;
/**
 * Sohbet araçlarını kaydet
 */
export declare function registerChatTools(server: any): void;
//# sourceMappingURL=chat-tool.d.ts.map