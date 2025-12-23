/**
 * Universal LLM MCP - RAG Araçları
 * bilgi_ekle, bilgi_sorgula, bilgi_listele
 */
import { z } from 'zod';
export declare const bilgiEkleSchema: z.ZodObject<{
    metin: z.ZodString;
    kaynak: z.ZodString;
    kategori: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    metin: string;
    kaynak: string;
    kategori?: string | undefined;
}, {
    metin: string;
    kaynak: string;
    kategori?: string | undefined;
}>;
export declare const bilgiSorgulaSchema: z.ZodObject<{
    soru: z.ZodString;
    topK: z.ZodOptional<z.ZodNumber>;
    kategori: z.ZodOptional<z.ZodString>;
}, "strip", z.ZodTypeAny, {
    soru: string;
    kategori?: string | undefined;
    topK?: number | undefined;
}, {
    soru: string;
    kategori?: string | undefined;
    topK?: number | undefined;
}>;
export declare const bilgiListeleSchema: z.ZodObject<{
    limit: z.ZodOptional<z.ZodNumber>;
}, "strip", z.ZodTypeAny, {
    limit?: number | undefined;
}, {
    limit?: number | undefined;
}>;
export declare const bilgiSilSchema: z.ZodObject<{
    kaynak: z.ZodString;
}, "strip", z.ZodTypeAny, {
    kaynak: string;
}, {
    kaynak: string;
}>;
/**
 * Bilgi ekle
 */
export declare function bilgiEkle(args: z.infer<typeof bilgiEkleSchema>): Promise<string>;
/**
 * Bilgi sorgula (RAG)
 */
export declare function bilgiSorgula(args: z.infer<typeof bilgiSorgulaSchema>): Promise<string>;
/**
 * Bilgileri listele
 */
export declare function bilgiListele(args: z.infer<typeof bilgiListeleSchema>): Promise<string>;
/**
 * Kaynak sil
 */
export declare function bilgiSil(args: z.infer<typeof bilgiSilSchema>): Promise<string>;
/**
 * RAG araçlarını kaydet
 */
export declare function registerRAGTools(server: any): void;
//# sourceMappingURL=rag-tool.d.ts.map