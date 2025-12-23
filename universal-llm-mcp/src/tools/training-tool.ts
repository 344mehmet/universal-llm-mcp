/**
 * Universal LLM MCP - Eğitim Araçları
 * egitim_baslat, soru_sor, cevap_degerlendir, ilerleme_goster
 */

import { z } from 'zod';
import { getTrainingSession } from '../training/training-session.js';
import { getPromptBank, type QuestionCategory, type DifficultyLevel } from '../training/prompt-bank.js';
import { getRouter } from '../router/llm-router.js';

// Şemalar
export const egitimBaslatSchema = z.object({
    kategori: z.enum(['matematik', 'mantik', 'kod', 'dil', 'analiz']).optional()
        .describe('Eğitim kategorisi'),
    zorluk: z.number().min(1).max(5).optional()
        .describe('Zorluk seviyesi (1-5)'),
});

export const soruSorSchema = z.object({
    kategori: z.enum(['matematik', 'mantik', 'kod', 'dil', 'analiz']).optional()
        .describe('Belirli bir kategoriden soru'),
});

export const cevapDegerlendirSchema = z.object({
    soruId: z.string().describe('Sorunun ID\'si'),
    cevap: z.string().describe('LLM\'in verdiği cevap'),
});

export const promptEkleSchema = z.object({
    soru: z.string().describe('Soru metni'),
    beklenenCevap: z.string().describe('Beklenen cevap'),
    kategori: z.enum(['matematik', 'mantik', 'kod', 'dil', 'analiz'])
        .describe('Kategori'),
    zorluk: z.number().min(1).max(5).describe('Zorluk (1-5)'),
    ipuclari: z.array(z.string()).optional().describe('İpuçları'),
});

// Son sorulan soru (oturum içi takip)
let lastAskedQuestion: { id: string; question: string; expectedAnswer: string } | null = null;

/**
 * Eğitim oturumu başlat
 */
export async function egitimBaslat(args: z.infer<typeof egitimBaslatSchema>): Promise<string> {
    const session = getTrainingSession();

    // Mevcut oturumu kapat
    if (session.hasActiveSession()) {
        session.end();
    }

    const newSession = session.start({
        category: args.kategori as QuestionCategory | undefined,
        difficulty: args.zorluk as DifficultyLevel | undefined,
    });

    let response = `## 🎓 Eğitim Oturumu Başlatıldı\n\n`;
    response += `- **Oturum ID**: ${newSession.id}\n`;

    if (args.kategori) {
        response += `- **Kategori**: ${args.kategori}\n`;
    }
    if (args.zorluk) {
        response += `- **Zorluk**: ${args.zorluk}/5\n`;
    }

    response += `\n*"soru_sor" aracını kullanarak sorulara başlayabilirsiniz.*`;

    return response;
}

/**
 * Soru sor
 */
export async function soruSor(args: z.infer<typeof soruSorSchema>): Promise<string> {
    const session = getTrainingSession();

    if (!session.hasActiveSession()) {
        // Otomatik oturum başlat
        session.start({ category: args.kategori as QuestionCategory | undefined });
    }

    const question = getPromptBank().getRandom({
        category: args.kategori as QuestionCategory | undefined,
    });

    if (!question) {
        return '❌ Bu kriterlere uygun soru bulunamadı.';
    }

    // Son soruyu kaydet
    lastAskedQuestion = {
        id: question.id,
        question: question.question,
        expectedAnswer: question.expectedAnswer,
    };

    let response = `## ❓ Soru (${question.category} - Zorluk: ${question.difficulty}/5)\n\n`;
    response += `**ID**: ${question.id}\n\n`;
    response += `${question.question}\n\n`;

    if (question.contextClues && question.contextClues.length > 0) {
        response += `---\n*Bağlam İpucu: ${question.contextClues[0]}*\n`;
    }

    response += `\n---\n*Cevabı değerlendirmek için "cevap_degerlendir" aracını kullanın.*`;

    return response;
}

/**
 * LLM'e soruyu sor ve cevabını değerlendir
 */
export async function soruSorVeDegerlendir(args: z.infer<typeof soruSorSchema>): Promise<string> {
    const session = getTrainingSession();

    if (!session.hasActiveSession()) {
        session.start({ category: args.kategori as QuestionCategory | undefined });
    }

    const question = getPromptBank().getRandom({
        category: args.kategori as QuestionCategory | undefined,
    });

    if (!question) {
        return '❌ Soru bulunamadı.';
    }

    // LLM'e sor
    const router = getRouter();
    let prompt = question.question;

    if (question.contextClues && question.contextClues.length > 0) {
        prompt += `\n\n(Bağlam: ${question.contextClues.join('; ')})`;
    }

    const llmResponse = await router.complete('default', prompt,
        'Soruyu dikkatlice oku ve en iyi cevabını ver. Kısa ve öz ol.'
    );

    // Değerlendir
    const evaluation = await session.evaluateAnswer(question, llmResponse.content);

    let response = `## ❓ Soru (${question.category})\n${question.question}\n\n`;
    response += `## 🤖 LLM Cevabı\n${llmResponse.content}\n\n`;
    response += `## ✅ Beklenen Cevap\n${question.expectedAnswer}\n\n`;
    response += `## 📊 Değerlendirme\n`;
    response += `- **Skor**: ${evaluation.score}/100 ${evaluation.correctness ? '✅' : '❌'}\n`;
    response += `- **Olgusal Doğruluk**: ${evaluation.details.factualAccuracy}%\n`;
    response += `- **Mantık**: ${evaluation.details.logicChain}%\n`;
    response += `- **Örtük Anlam**: ${evaluation.implicitUnderstanding}%\n`;

    if (evaluation.reasoning) {
        response += `\n**Açıklama**: ${evaluation.reasoning}\n`;
    }

    if (evaluation.suggestions.length > 0) {
        response += `\n**Öneriler**:\n`;
        for (const s of evaluation.suggestions) {
            response += `- ${s}\n`;
        }
    }

    return response;
}

/**
 * Manuel cevap değerlendirme
 */
export async function cevapDegerlendir(args: z.infer<typeof cevapDegerlendirSchema>): Promise<string> {
    const session = getTrainingSession();
    const promptBank = getPromptBank();

    if (!session.hasActiveSession()) {
        return '❌ Aktif eğitim oturumu yok. Önce "egitim_baslat" kullanın.';
    }

    const question = promptBank.get(args.soruId);
    if (!question) {
        return `❌ "${args.soruId}" ID'li soru bulunamadı.`;
    }

    const evaluation = await session.evaluateAnswer(question, args.cevap);

    let response = `## 📊 Değerlendirme Sonucu\n\n`;
    response += `### Skor: ${evaluation.score}/100 ${evaluation.correctness ? '✅ Doğru' : '❌ Yanlış'}\n\n`;

    response += `| Kriter | Puan |\n|--------|------|\n`;
    response += `| Olgusal Doğruluk | ${evaluation.details.factualAccuracy}% |\n`;
    response += `| Mantık Zinciri | ${evaluation.details.logicChain}% |\n`;
    response += `| Tamlık | ${evaluation.details.completeness}% |\n`;
    response += `| Açıklık | ${evaluation.details.clarity}% |\n`;
    response += `| Örtük Anlam | ${evaluation.implicitUnderstanding}% |\n`;

    if (evaluation.reasoning) {
        response += `\n### Değerlendirme\n${evaluation.reasoning}\n`;
    }

    if (evaluation.suggestions.length > 0) {
        response += `\n### Öneriler\n`;
        for (const s of evaluation.suggestions) {
            response += `- ${s}\n`;
        }
    }

    return response;
}

/**
 * İlerleme göster
 */
export async function ilerleseGoster(): Promise<string> {
    const session = getTrainingSession();

    if (!session.hasActiveSession()) {
        return '❌ Aktif eğitim oturumu yok.';
    }

    const progress = session.getProgress();
    const report = session.generateReport();

    if (!progress || !report) {
        return '❌ İlerleme bilgisi alınamadı.';
    }

    let response = `## 📈 Eğitim İlerlemesi\n\n`;
    response += `- **Soru Sayısı**: ${progress.questionsAsked}\n`;
    response += `- **Doğru Cevap**: ${progress.correctAnswers}\n`;
    response += `- **Başarı Oranı**: ${progress.successRate}%\n`;
    response += `- **Ortalama Skor**: ${progress.averageScore}/100\n`;

    if (Object.keys(report.categoryBreakdown).length > 0) {
        response += `\n### Kategori Bazlı\n`;
        response += `| Kategori | Soru | Doğru | Ort. Skor |\n|----------|------|-------|----------|\n`;
        for (const [cat, stats] of Object.entries(report.categoryBreakdown)) {
            response += `| ${cat} | ${stats.asked} | ${stats.correct} | ${stats.avgScore}% |\n`;
        }
    }

    if (report.weakAreas.length > 0) {
        response += `\n### ⚠️ Zayıf Alanlar\n${report.weakAreas.join(', ')}\n`;
    }

    if (report.strongAreas.length > 0) {
        response += `\n### 💪 Güçlü Alanlar\n${report.strongAreas.join(', ')}\n`;
    }

    if (report.recommendations.length > 0) {
        response += `\n### 💡 Öneriler\n`;
        for (const r of report.recommendations) {
            response += `- ${r}\n`;
        }
    }

    return response;
}

/**
 * Soru bankasına soru ekle
 */
export async function promptEkle(args: z.infer<typeof promptEkleSchema>): Promise<string> {
    const promptBank = getPromptBank();

    const id = promptBank.add({
        category: args.kategori as QuestionCategory,
        difficulty: args.zorluk as DifficultyLevel,
        question: args.soru,
        expectedAnswer: args.beklenenCevap,
        hints: args.ipuclari,
    });

    promptBank.saveToFile();

    return `✅ Soru eklendi!\n\n- **ID**: ${id}\n- **Kategori**: ${args.kategori}\n- **Zorluk**: ${args.zorluk}/5`;
}

/**
 * Eğitim araçlarını kaydet
 */
export function registerTrainingTools(server: any): void {
    server.tool(
        'egitim_baslat',
        'Yeni bir LLM eğitim oturumu başlat',
        egitimBaslatSchema.shape,
        async (args: z.infer<typeof egitimBaslatSchema>) => {
            const sonuc = await egitimBaslat(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'soru_sor',
        'Eğitim için bir test sorusu al',
        soruSorSchema.shape,
        async (args: z.infer<typeof soruSorSchema>) => {
            const sonuc = await soruSor(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'soru_degerlendir',
        'Soruyu LLM\'e sor ve cevabını otomatik değerlendir',
        soruSorSchema.shape,
        async (args: z.infer<typeof soruSorSchema>) => {
            const sonuc = await soruSorVeDegerlendir(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'cevap_degerlendir',
        'Verilen cevabı değerlendir ve puanla',
        cevapDegerlendirSchema.shape,
        async (args: z.infer<typeof cevapDegerlendirSchema>) => {
            const sonuc = await cevapDegerlendir(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'ilerleme_goster',
        'Eğitim oturumu ilerlemesini ve raporunu göster',
        {},
        async () => {
            const sonuc = await ilerleseGoster();
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );

    server.tool(
        'prompt_ekle',
        'Soru bankasına yeni test sorusu ekle',
        promptEkleSchema.shape,
        async (args: z.infer<typeof promptEkleSchema>) => {
            const sonuc = await promptEkle(args);
            return { content: [{ type: 'text', text: sonuc }] };
        }
    );
}
