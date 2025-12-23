/**
 * Universal LLM MCP - Çeviri Aracı
 * Dil çevirisi ve yerelleştirme
 */

import { z } from 'zod';
import { getRouter } from '../router/llm-router.js';

// Desteklenen diller
const DESTEKLENEN_DILLER = [
    'tr', // Türkçe
    'en', // İngilizce
    'de', // Almanca
    'fr', // Fransızca
    'es', // İspanyolca
    'it', // İtalyanca
    'ru', // Rusça
    'ar', // Arapça
    'zh', // Çince
    'ja', // Japonca
    'ko', // Korece
] as const;

const DIL_ISIMLERI: Record<string, string> = {
    tr: 'Türkçe',
    en: 'İngilizce',
    de: 'Almanca',
    fr: 'Fransızca',
    es: 'İspanyolca',
    it: 'İtalyanca',
    ru: 'Rusça',
    ar: 'Arapça',
    zh: 'Çince',
    ja: 'Japonca',
    ko: 'Korece',
};

// Tool şemaları
export const translateSchema = z.object({
    text: z.string().describe('Çevrilecek metin'),
    from: z.enum(DESTEKLENEN_DILLER).optional().describe('Kaynak dil kodu (otomatik algılama için boş bırak)'),
    to: z.enum(DESTEKLENEN_DILLER).describe('Hedef dil kodu'),
    style: z.enum(['formal', 'informal', 'technical', 'literary']).optional().describe('Çeviri stili'),
});

export const localizeSchema = z.object({
    text: z.string().describe('Yerelleştirilecek metin'),
    targetCulture: z.string().describe('Hedef kültür (örn: Türkiye, Almanya)'),
    context: z.string().optional().describe('Kullanım bağlamı'),
});

export const detectLanguageSchema = z.object({
    text: z.string().describe('Dili algılanacak metin'),
});

/**
 * Metin çevir
 */
export async function translate(args: z.infer<typeof translateSchema>): Promise<string> {
    const router = getRouter();

    const hedefDil = DIL_ISIMLERI[args.to] || args.to;
    const kaynakDil = args.from ? (DIL_ISIMLERI[args.from] || args.from) : 'otomatik algılanan dil';

    const styleGuide: Record<string, string> = {
        formal: 'resmi ve profesyonel bir dil kullan',
        informal: 'günlük ve samimi bir dil kullan',
        technical: 'teknik terminolojiyi koru, teknik bir dil kullan',
        literary: 'edebi ve akıcı bir dil kullan',
    };

    const style = args.style ? styleGuide[args.style] : '';

    const prompt = `
Aşağıdaki metni ${kaynakDil}'den ${hedefDil}'ye çevir:

---
${args.text}
---

${style ? `Stil: ${style}` : ''}

Çeviride:
- Anlamı doğru aktar
- Doğal ve akıcı ol
- Kültürel nüansları dikkate al
`;

    const response = await router.complete('translate', prompt,
        `Sen profesyonel bir çevirmensin. ${hedefDil} dilinde mükemmel çeviriler yap.`
    );

    return response.content;
}

/**
 * Yerelleştirme
 */
export async function localize(args: z.infer<typeof localizeSchema>): Promise<string> {
    const router = getRouter();

    const prompt = `
Aşağıdaki metni ${args.targetCulture} kültürüne uygun şekilde yerelleştir:

---
${args.text}
---

${args.context ? `Kullanım bağlamı: ${args.context}` : ''}

Yerelleştirmede:
- Kültürel referansları adapte et
- Yerel deyimleri ve ifadeleri kullan
- Para birimi, ölçü birimleri gibi unsurları dönüştür
- Hedef kitle için anlamlı hale getir
`;

    const response = await router.complete('translate', prompt,
        `Sen kültürlerarası iletişim uzmanısın. Metinleri farklı kültürlere uyarlama konusunda uzmansın.`
    );

    return response.content;
}

/**
 * Dil algıla
 */
export async function detectLanguage(args: z.infer<typeof detectLanguageSchema>): Promise<string> {
    const router = getRouter();

    const prompt = `
Aşağıdaki metnin dilini algıla ve analiz et:

---
${args.text}
---

Yanıtında:
- Algılanan dil
- Güven seviyesi (düşük/orta/yüksek)
- Dil özellikleri (lehçe, jargon vb. varsa)
- Örnek kelimeler

belirt.
`;

    const response = await router.complete('translate', prompt,
        'Sen dil bilimi uzmanısın. Dilleri ve lehçeleri analiz edebilirsin.'
    );

    return response.content;
}

/**
 * Çeviri araçlarını kaydet
 */
export function registerTranslateTools(server: any): void {
    server.tool(
        'cevir',
        'Metni bir dilden başka bir dile çevir',
        translateSchema.shape,
        async (args: z.infer<typeof translateSchema>) => {
            const sonuc = await translate(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'yerelleştir',
        'Metni hedef kültüre uygun şekilde yerelleştir',
        localizeSchema.shape,
        async (args: z.infer<typeof localizeSchema>) => {
            const sonuc = await localize(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'dil_algila',
        'Metnin dilini algıla ve analiz et',
        detectLanguageSchema.shape,
        async (args: z.infer<typeof detectLanguageSchema>) => {
            const sonuc = await detectLanguage(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );
}
