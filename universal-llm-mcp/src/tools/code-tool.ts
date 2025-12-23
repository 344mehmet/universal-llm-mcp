/**
 * Universal LLM MCP - Kod Aracı
 * Kod yazma, analiz ve iyileştirme işlemleri
 */

import { z } from 'zod';
import { getRouter } from '../router/llm-router.js';

// Tool şemaları
export const generateCodeSchema = z.object({
    description: z.string().describe('Yazılacak kodun Türkçe açıklaması'),
    language: z.string().describe('Programlama dili (python, javascript, typescript, vb.)'),
    context: z.string().optional().describe('Ek bağlam veya gereksinimler'),
});

export const explainCodeSchema = z.object({
    code: z.string().describe('Açıklanacak kod'),
    language: z.string().optional().describe('Programlama dili'),
});

export const refactorCodeSchema = z.object({
    code: z.string().describe('İyileştirilecek kod'),
    instructions: z.string().describe('İyileştirme talimatları'),
    language: z.string().optional().describe('Programlama dili'),
});

export const debugCodeSchema = z.object({
    code: z.string().describe('Hatalı kod'),
    error: z.string().optional().describe('Hata mesajı'),
    language: z.string().optional().describe('Programlama dili'),
});

/**
 * Kod üret
 */
export async function generateCode(args: z.infer<typeof generateCodeSchema>): Promise<string> {
    const router = getRouter();

    const prompt = `
Aşağıdaki gereksinimlere göre ${args.language} kodu yaz:

Gereksinim: ${args.description}
${args.context ? `Ek Bağlam: ${args.context}` : ''}

Kodun:
- Temiz ve okunabilir olsun
- Yorumlarla açıklanmış olsun (Türkçe)
- Best practice'leri takip etsin
`;

    const response = await router.complete('code', prompt,
        'Sen uzman bir programcısın. Türkçe açıklamalarla temiz ve işlevsel kod yaz.'
    );

    return response.content;
}

/**
 * Kodu açıkla
 */
export async function explainCode(args: z.infer<typeof explainCodeSchema>): Promise<string> {
    const router = getRouter();

    const prompt = `
Aşağıdaki kodu Türkçe olarak detaylı açıkla:

\`\`\`${args.language || ''}
${args.code}
\`\`\`

Açıklamanda:
- Kodun ne yaptığını
- Her önemli bölümün işlevini
- Kullanılan algoritma veya tasarım kalıplarını
- Olası iyileştirme önerilerini
belirt.
`;

    const response = await router.complete('code', prompt,
        'Sen kod eğitmenisin. Kodları Türkçe olarak anlaşılır ve detaylı şekilde açıkla.'
    );

    return response.content;
}

/**
 * Kodu iyileştir
 */
export async function refactorCode(args: z.infer<typeof refactorCodeSchema>): Promise<string> {
    const router = getRouter();

    const prompt = `
Aşağıdaki kodu verilen talimatlara göre iyileştir:

Orijinal Kod:
\`\`\`${args.language || ''}
${args.code}
\`\`\`

İyileştirme Talimatları: ${args.instructions}

İyileştirilmiş kodu ver ve yapılan değişiklikleri Türkçe açıkla.
`;

    const response = await router.complete('code', prompt,
        'Sen uzman bir kod refactoring uzmanısın. Kodu iyileştir ve değişiklikleri Türkçe açıkla.'
    );

    return response.content;
}

/**
 * Kodu debug et
 */
export async function debugCode(args: z.infer<typeof debugCodeSchema>): Promise<string> {
    const router = getRouter();

    const prompt = `
Aşağıdaki koddaki hatayı bul ve düzelt:

Hatalı Kod:
\`\`\`${args.language || ''}
${args.code}
\`\`\`

${args.error ? `Hata Mesajı: ${args.error}` : ''}

Yanıtında:
- Hatanın ne olduğunu
- Neden oluştuğunu
- Düzeltilmiş kodu
- Gelecekte benzer hataları önlemek için önerileri
Türkçe olarak açıkla.
`;

    const response = await router.complete('code', prompt,
        'Sen uzman bir debugging uzmanısın. Hataları bul, açıkla ve düzelt.'
    );

    return response.content;
}

/**
 * Kod araçlarını kaydet
 */
export function registerCodeTools(server: any): void {
    server.tool(
        'kod_uret',
        'Verilen açıklamaya göre kod üret',
        generateCodeSchema.shape,
        async (args: z.infer<typeof generateCodeSchema>) => {
            const sonuc = await generateCode(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'kod_acikla',
        'Verilen kodu Türkçe olarak açıkla',
        explainCodeSchema.shape,
        async (args: z.infer<typeof explainCodeSchema>) => {
            const sonuc = await explainCode(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'kod_iyilestir',
        'Verilen kodu iyileştir/refactor et',
        refactorCodeSchema.shape,
        async (args: z.infer<typeof refactorCodeSchema>) => {
            const sonuc = await refactorCode(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'kod_debug',
        'Koddaki hataları bul ve düzelt',
        debugCodeSchema.shape,
        async (args: z.infer<typeof debugCodeSchema>) => {
            const sonuc = await debugCode(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );
}
