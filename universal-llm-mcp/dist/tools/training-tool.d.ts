/**
 * Universal LLM MCP - Eğitim Araçları
 * egitim_baslat, soru_sor, cevap_degerlendir, ilerleme_goster
 */
import { z } from 'zod';
export declare const egitimBaslatSchema: z.ZodObject<{
    kategori: z.ZodOptional<z.ZodEnum<["matematik", "mantik", "kod", "dil", "analiz"]>>;
    zorluk: z.ZodOptional<z.ZodNumber>;
}, "strip", z.ZodTypeAny, {
    kategori?: "matematik" | "mantik" | "kod" | "dil" | "analiz" | undefined;
    zorluk?: number | undefined;
}, {
    kategori?: "matematik" | "mantik" | "kod" | "dil" | "analiz" | undefined;
    zorluk?: number | undefined;
}>;
export declare const soruSorSchema: z.ZodObject<{
    kategori: z.ZodOptional<z.ZodEnum<["matematik", "mantik", "kod", "dil", "analiz"]>>;
}, "strip", z.ZodTypeAny, {
    kategori?: "matematik" | "mantik" | "kod" | "dil" | "analiz" | undefined;
}, {
    kategori?: "matematik" | "mantik" | "kod" | "dil" | "analiz" | undefined;
}>;
export declare const cevapDegerlendirSchema: z.ZodObject<{
    soruId: z.ZodString;
    cevap: z.ZodString;
}, "strip", z.ZodTypeAny, {
    soruId: string;
    cevap: string;
}, {
    soruId: string;
    cevap: string;
}>;
export declare const promptEkleSchema: z.ZodObject<{
    soru: z.ZodString;
    beklenenCevap: z.ZodString;
    kategori: z.ZodEnum<["matematik", "mantik", "kod", "dil", "analiz"]>;
    zorluk: z.ZodNumber;
    ipuclari: z.ZodOptional<z.ZodArray<z.ZodString, "many">>;
}, "strip", z.ZodTypeAny, {
    kategori: "matematik" | "mantik" | "kod" | "dil" | "analiz";
    soru: string;
    zorluk: number;
    beklenenCevap: string;
    ipuclari?: string[] | undefined;
}, {
    kategori: "matematik" | "mantik" | "kod" | "dil" | "analiz";
    soru: string;
    zorluk: number;
    beklenenCevap: string;
    ipuclari?: string[] | undefined;
}>;
/**
 * Eğitim oturumu başlat
 */
export declare function egitimBaslat(args: z.infer<typeof egitimBaslatSchema>): Promise<string>;
/**
 * Soru sor
 */
export declare function soruSor(args: z.infer<typeof soruSorSchema>): Promise<string>;
/**
 * LLM'e soruyu sor ve cevabını değerlendir
 */
export declare function soruSorVeDegerlendir(args: z.infer<typeof soruSorSchema>): Promise<string>;
/**
 * Manuel cevap değerlendirme
 */
export declare function cevapDegerlendir(args: z.infer<typeof cevapDegerlendirSchema>): Promise<string>;
/**
 * İlerleme göster
 */
export declare function ilerleseGoster(): Promise<string>;
/**
 * Soru bankasına soru ekle
 */
export declare function promptEkle(args: z.infer<typeof promptEkleSchema>): Promise<string>;
/**
 * Eğitim araçlarını kaydet
 */
export declare function registerTrainingTools(server: any): void;
//# sourceMappingURL=training-tool.d.ts.map