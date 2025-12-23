/**
 * Universal LLM MCP - Sohbet Aracı
 * Türkçe sohbet, özetleme ve beyin fırtınası
 */
import { z } from 'zod';
import { getRouter } from '../router/llm-router.js';
// Tool şemaları
export const turkishChatSchema = z.object({
    message: z.string().describe('Sohbet mesajı'),
    context: z.string().optional().describe('Önceki sohbet bağlamı'),
    personality: z.string().optional().describe('Asistan kişiliği (örn: samimi, resmi, eğlenceli)'),
});
export const summarizeSchema = z.object({
    text: z.string().describe('Özetlenecek metin'),
    style: z.enum(['kisa', 'orta', 'detayli']).optional().describe('Özet uzunluğu'),
    format: z.enum(['paragraf', 'maddeler', 'basliklar']).optional().describe('Özet formatı'),
});
export const brainstormSchema = z.object({
    topic: z.string().describe('Beyin fırtınası konusu'),
    count: z.number().optional().describe('Üretilecek fikir sayısı'),
    constraints: z.string().optional().describe('Kısıtlamalar veya gereksinimler'),
});
/**
 * Türkçe sohbet
 */
export async function turkishChat(args) {
    const router = getRouter();
    let systemPrompt = 'Sen Türkçe konuşan yardımcı bir asistansın.';
    if (args.personality) {
        const personalities = {
            samimi: 'Sen samimi, sıcak ve arkadaş canlısı bir asistansın. Günlük dil kullan.',
            resmi: 'Sen resmi ve profesyonel bir asistansın. Kibar ve saygılı ol.',
            eglenceli: 'Sen eğlenceli ve komik bir asistansın. Espri yap, emoji kullan.',
            uzman: 'Sen alanında uzman, detaylı açıklamalar yapan bir asistansın.',
        };
        systemPrompt = personalities[args.personality] || systemPrompt;
    }
    let prompt = args.message;
    if (args.context) {
        prompt = `Önceki bağlam: ${args.context}\n\nŞimdiki mesaj: ${args.message}`;
    }
    const response = await router.complete('chat', prompt, systemPrompt);
    return response.content;
}
/**
 * Metin özetle
 */
export async function summarize(args) {
    const router = getRouter();
    const styleGuide = {
        kisa: '2-3 cümle ile',
        orta: '1 paragraf ile',
        detayli: 'detaylı bir şekilde, önemli noktaları vurgulayarak',
    };
    const formatGuide = {
        paragraf: 'akıcı bir paragraf olarak',
        maddeler: 'madde işaretleri kullanarak',
        basliklar: 'başlıklar ve alt başlıklar kullanarak',
    };
    const style = styleGuide[args.style || 'orta'];
    const format = formatGuide[args.format || 'paragraf'];
    const prompt = `
Aşağıdaki metni ${style} ${format} özetle:

---
${args.text}
---

Özet Türkçe olmalı ve ana fikirleri içermeli.
`;
    const response = await router.complete('chat', prompt, 'Sen profesyonel bir özetleme uzmanısın. Metinleri anlaşılır ve özlü şekilde özetle.');
    return response.content;
}
/**
 * Beyin fırtınası
 */
export async function brainstorm(args) {
    const router = getRouter();
    const count = args.count || 5;
    const prompt = `
"${args.topic}" konusu için ${count} adet yaratıcı fikir üret.

${args.constraints ? `Kısıtlamalar: ${args.constraints}` : ''}

Her fikir için:
- Kısa bir başlık
- 1-2 cümle açıklama
- Olası avantajlar

Fikirler orijinal, uygulanabilir ve ilham verici olmalı.
`;
    const response = await router.complete('chat', prompt, 'Sen yaratıcı bir danışmansın. Yenilikçi ve uygulanabilir fikirler üret.');
    return response.content;
}
/**
 * Sohbet araçlarını kaydet
 */
export function registerChatTools(server) {
    server.tool('turkce_sohbet', 'Türkçe sohbet et, sorular sor, yardım al', turkishChatSchema.shape, async (args) => {
        const sonuc = await turkishChat(args);
        return { content: [{ type: 'text', text: sonuc }] };
    });
    server.tool('ozetle', 'Verilen metni Türkçe olarak özetle', summarizeSchema.shape, async (args) => {
        const sonuc = await summarize(args);
        return { content: [{ type: 'text', text: sonuc }] };
    });
    server.tool('beyin_firtinasi', 'Bir konu hakkında yaratıcı fikirler üret', brainstormSchema.shape, async (args) => {
        const sonuc = await brainstorm(args);
        return { content: [{ type: 'text', text: sonuc }] };
    });
}
//# sourceMappingURL=chat-tool.js.map