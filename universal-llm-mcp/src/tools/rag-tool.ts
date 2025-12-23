/**
 * Universal LLM MCP - RAG Araçları
 * bilgi_ekle, bilgi_sorgula, bilgi_listele
 */

import { z } from 'zod';
import { getRAGService } from '../rag/rag-service.js';

// Şemalar
export const bilgiEkleSchema = z.object({
    metin: z.string().describe('Eklenecek bilgi metni'),
    kaynak: z.string().describe('Bilginin kaynağı (örn: kullanici, dosya-adi, url)'),
    kategori: z.string().optional().describe('Bilgi kategorisi (örn: kod, genel, ea)'),
});

export const bilgiSorgulaSchema = z.object({
    soru: z.string().describe('Sorulacak soru'),
    topK: z.number().optional().describe('Kaç sonuç döndürülsün (varsayılan: 3)'),
    kategori: z.string().optional().describe('Belirli bir kategoride ara'),
});

export const bilgiListeleSchema = z.object({
    limit: z.number().optional().describe('Maksimum kaynak sayısı'),
});

export const bilgiSilSchema = z.object({
    kaynak: z.string().describe('Silinecek kaynağın adı'),
});

/**
 * Bilgi ekle
 */
export async function bilgiEkle(args: z.infer<typeof bilgiEkleSchema>): Promise<string> {
    const ragService = getRAGService();

    const result = await ragService.addDocument(
        args.metin,
        args.kaynak,
        args.kategori
    );

    if (result.success) {
        return `✅ **Bilgi Eklendi**\n\n` +
            `- Kaynak: ${result.source}\n` +
            `- Parça Sayısı: ${result.chunksAdded}\n` +
            `- Mesaj: ${result.message}`;
    } else {
        return `❌ **Hata**\n\n${result.message}`;
    }
}

/**
 * Bilgi sorgula (RAG)
 */
export async function bilgiSorgula(args: z.infer<typeof bilgiSorgulaSchema>): Promise<string> {
    const ragService = getRAGService();

    const result = await ragService.query(args.soru, {
        topK: args.topK,
        category: args.kategori,
    });

    let response = `## 📝 Cevap\n\n${result.answer}\n\n`;

    if (result.sources.length > 0) {
        response += `---\n\n## 📚 Kaynaklar\n\n`;
        for (const source of result.sources) {
            response += `- **${source.source}** (benzerlik: ${source.similarity})\n`;
            response += `  > ${source.text}\n\n`;
        }
    }

    return response;
}

/**
 * Bilgileri listele
 */
export async function bilgiListele(args: z.infer<typeof bilgiListeleSchema>): Promise<string> {
    const ragService = getRAGService();
    const stats = ragService.getStats();
    const documents = ragService.listDocuments(args.limit);

    let response = `## 📊 Bilgi Tabanı İstatistikleri\n\n`;
    response += `- Toplam Chunk: ${stats.totalChunks}\n`;
    response += `- Kaynak Sayısı: ${stats.sources}\n`;

    if (stats.categories.length > 0) {
        response += `- Kategoriler: ${stats.categories.join(', ')}\n`;
    }

    if (documents.length > 0) {
        response += `\n## 📂 Kaynaklar\n\n`;
        for (const doc of documents) {
            response += `### ${doc.source}\n`;
            response += `- Parça Sayısı: ${doc.chunkCount}\n`;
            response += `- Önizleme: ${doc.preview}\n\n`;
        }
    } else {
        response += `\n*Henüz bilgi eklenmemiş.*`;
    }

    return response;
}

/**
 * Kaynak sil
 */
export async function bilgiSil(args: z.infer<typeof bilgiSilSchema>): Promise<string> {
    const ragService = getRAGService();
    const count = ragService.deleteSource(args.kaynak);

    if (count > 0) {
        return `✅ **${args.kaynak}** kaynağından ${count} bilgi parçası silindi.`;
    } else {
        return `⚠️ **${args.kaynak}** kaynağı bulunamadı.`;
    }
}

/**
 * RAG araçlarını kaydet
 */
export function registerRAGTools(server: any): void {
    server.tool(
        'bilgi_ekle',
        'Bilgi tabanına yeni bilgi/belge ekle (RAG için)',
        bilgiEkleSchema.shape,
        async (args: z.infer<typeof bilgiEkleSchema>) => {
            const sonuc = await bilgiEkle(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'bilgi_sorgula',
        'Bilgi tabanından akıllı arama yap (RAG ile)',
        bilgiSorgulaSchema.shape,
        async (args: z.infer<typeof bilgiSorgulaSchema>) => {
            const sonuc = await bilgiSorgula(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'bilgi_listele',
        'Bilgi tabanındaki tüm kaynakları listele',
        bilgiListeleSchema.shape,
        async (args: z.infer<typeof bilgiListeleSchema>) => {
            const sonuc = await bilgiListele(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'bilgi_sil',
        'Bilgi tabanından kaynak sil',
        bilgiSilSchema.shape,
        async (args: z.infer<typeof bilgiSilSchema>) => {
            const sonuc = await bilgiSil(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );
}
