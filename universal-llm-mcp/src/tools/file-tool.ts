/**
 * Universal LLM MCP - Dosya Aracı
 * Dosya analizi ve dokümantasyon üretme
 */

import { z } from 'zod';
import { readFileSync, existsSync } from 'fs';
import { getRouter } from '../router/llm-router.js';

// Tool şemaları
export const analyzeFileSchema = z.object({
    filePath: z.string().describe('Analiz edilecek dosyanın yolu'),
    analysisType: z.enum(['genel', 'guvenlik', 'performans', 'kod_kalitesi']).optional()
        .describe('Analiz tipi'),
});

export const analyzeContentSchema = z.object({
    content: z.string().describe('Analiz edilecek içerik'),
    contentType: z.string().describe('İçerik tipi (örn: javascript, python, json, markdown)'),
    analysisType: z.enum(['genel', 'guvenlik', 'performans', 'kod_kalitesi']).optional()
        .describe('Analiz tipi'),
});

export const generateDocsSchema = z.object({
    code: z.string().describe('Dokümantasyonu üretilecek kod'),
    language: z.string().describe('Programlama dili'),
    docStyle: z.enum(['jsdoc', 'sphinx', 'markdown', 'readme']).optional()
        .describe('Dokümantasyon stili'),
});

export const compareFilesSchema = z.object({
    content1: z.string().describe('Birinci dosya içeriği'),
    content2: z.string().describe('İkinci dosya içeriği'),
    comparisonType: z.enum(['diff', 'semantic', 'both']).optional()
        .describe('Karşılaştırma tipi'),
});

/**
 * Dosya analiz et
 */
export async function analyzeFile(args: z.infer<typeof analyzeFileSchema>): Promise<string> {
    // Dosya var mı kontrol et
    if (!existsSync(args.filePath)) {
        return `Hata: Dosya bulunamadı: ${args.filePath}`;
    }

    let content: string;
    try {
        content = readFileSync(args.filePath, 'utf-8');
    } catch (error) {
        return `Hata: Dosya okunamadı: ${error}`;
    }

    // İçerik türünü dosya uzantısından belirle
    const extension = args.filePath.split('.').pop() || '';

    return analyzeContent({
        content,
        contentType: extension,
        analysisType: args.analysisType,
    });
}

/**
 * İçerik analiz et
 */
export async function analyzeContent(args: z.infer<typeof analyzeContentSchema>): Promise<string> {
    const router = getRouter();

    const analysisGuide: Record<string, string> = {
        genel: 'yapısını, amacını ve içeriğini',
        guvenlik: 'güvenlik açıklarını, riskleri ve iyileştirme önerilerini',
        performans: 'performans sorunlarını, optimizasyon fırsatlarını',
        kod_kalitesi: 'kod kalitesini, okunabilirliği ve best practice uyumunu',
    };

    const analysis = analysisGuide[args.analysisType || 'genel'];

    const prompt = `
Aşağıdaki ${args.contentType} içeriğini analiz et ve ${analysis} değerlendir:

\`\`\`${args.contentType}
${args.content}
\`\`\`

Analizinde:
- Genel değerlendirme
- Tespit edilen sorunlar (varsa)
- İyileştirme önerileri
- Güçlü yönler

Türkçe ve detaylı yanıt ver.
`;

    const response = await router.complete('file', prompt,
        'Sen uzman bir dosya ve kod analiz uzmanısın. Detaylı ve yapıcı analizler yap.'
    );

    return response.content;
}

/**
 * Dokümantasyon üret
 */
export async function generateDocs(args: z.infer<typeof generateDocsSchema>): Promise<string> {
    const router = getRouter();

    const styleGuide: Record<string, string> = {
        jsdoc: 'JSDoc formatında (JavaScript/TypeScript için)',
        sphinx: 'Sphinx formatında (Python için)',
        markdown: 'Markdown formatında',
        readme: 'README.md formatında, projenin genel açıklaması olarak',
    };

    const style = styleGuide[args.docStyle || 'markdown'];

    const prompt = `
Aşağıdaki ${args.language} kodu için ${style} dokümantasyon üret:

\`\`\`${args.language}
${args.code}
\`\`\`

Dokümantasyonda:
- Her fonksiyon/sınıf için açıklama
- Parametreler ve dönüş değerleri
- Kullanım örnekleri
- Notlar ve uyarılar

Türkçe olarak yaz.
`;

    const response = await router.complete('file', prompt,
        'Sen teknik dokümantasyon uzmanısın. Anlaşılır ve kapsamlı dokümantasyon yaz.'
    );

    return response.content;
}

/**
 * Dosyaları karşılaştır
 */
export async function compareFiles(args: z.infer<typeof compareFilesSchema>): Promise<string> {
    const router = getRouter();

    const comparisonGuide: Record<string, string> = {
        diff: 'satır satır farklılıkları',
        semantic: 'anlamsal ve yapısal farklılıkları',
        both: 'hem satır bazlı hem de anlamsal farklılıkları',
    };

    const comparison = comparisonGuide[args.comparisonType || 'both'];

    const prompt = `
Aşağıdaki iki dosyayı karşılaştır ve ${comparison} analiz et:

=== DOSYA 1 ===
${args.content1}

=== DOSYA 2 ===
${args.content2}

Karşılaştırmada:
- Eklenen içerikler
- Silinen içerikler
- Değiştirilen içerikler
- Anlamsal farklar
- Olası etkileri

Türkçe ve detaylı açıkla.
`;

    const response = await router.complete('file', prompt,
        'Sen dosya karşılaştırma uzmanısın. Değişiklikleri net ve anlaşılır şekilde raporla.'
    );

    return response.content;
}

/**
 * Dosya araçlarını kaydet
 */
export function registerFileTools(server: any): void {
    server.tool(
        'dosya_analiz',
        'Bir dosyayı analiz et (dosya yolu ile)',
        analyzeFileSchema.shape,
        async (args: z.infer<typeof analyzeFileSchema>) => {
            const sonuc = await analyzeFile(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'icerik_analiz',
        'Verilen içeriği analiz et',
        analyzeContentSchema.shape,
        async (args: z.infer<typeof analyzeContentSchema>) => {
            const sonuc = await analyzeContent(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'dokumantasyon_uret',
        'Kod için dokümantasyon üret',
        generateDocsSchema.shape,
        async (args: z.infer<typeof generateDocsSchema>) => {
            const sonuc = await generateDocs(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'dosya_karsilastir',
        'İki dosya içeriğini karşılaştır',
        compareFilesSchema.shape,
        async (args: z.infer<typeof compareFilesSchema>) => {
            const sonuc = await compareFiles(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );
}
