/**
 * Universal LLM MCP - LLM Değerlendirici
 * Cevapları puanlama ve örtük anlam değerlendirmesi
 */
import { getRouter } from '../router/llm-router.js';
/**
 * LLM Değerlendirici
 */
export class Evaluator {
    /**
     * Cevabı değerlendir
     */
    async evaluate(question, llmAnswer) {
        const router = getRouter();
        const prompt = `Bir değerlendirici olarak aşağıdaki soru-cevap çiftini analiz et.

## Soru:
${question.question}

## Beklenen Cevap:
${question.expectedAnswer}

## LLM'in Cevabı:
${llmAnswer}

${question.hints ? `## İpuçları (değerlendirmede dikkate al):\n${question.hints.join('\n')}` : ''}

${question.contextClues ? `## Örtük Bağlam İpuçları:\n${question.contextClues.join('\n')}` : ''}

## Değerlendirme Kriterleri:
1. **Olgusal Doğruluk** (0-100): Cevap doğru mu?
2. **Mantık Zinciri** (0-100): Akıl yürütme doğru mu?
3. **Tamlık** (0-100): Tüm noktalar kapsandı mı?
4. **Açıklık** (0-100): Cevap anlaşılır mı?
5. **Örtük Anlam** (0-100): Bağlamdan çıkarım yapabildi mi?

## Yanıt Formatı (JSON):
{
    "overallScore": <0-100>,
    "isCorrect": <true/false>,
    "factualAccuracy": <0-100>,
    "logicChain": <0-100>,
    "completeness": <0-100>,
    "clarity": <0-100>,
    "implicitUnderstanding": <0-100>,
    "reasoning": "<neden bu skor>",
    "suggestions": ["<öneri 1>", "<öneri 2>"]
}`;
        try {
            const response = await router.complete('default', prompt, 'Sen bir eğitim değerlendiricisisin. Cevapları objektif ve adil değerlendir. Yanıtını SADECE JSON formatında ver.');
            // JSON parse
            const jsonMatch = response.content.match(/\{[\s\S]*\}/);
            if (!jsonMatch) {
                return this.createDefaultResult(false, 'JSON parse hatası');
            }
            const parsed = JSON.parse(jsonMatch[0]);
            return {
                score: parsed.overallScore || 0,
                correctness: parsed.isCorrect || false,
                reasoning: parsed.reasoning || '',
                implicitUnderstanding: parsed.implicitUnderstanding || 0,
                suggestions: parsed.suggestions || [],
                details: {
                    factualAccuracy: parsed.factualAccuracy || 0,
                    logicChain: parsed.logicChain || 0,
                    completeness: parsed.completeness || 0,
                    clarity: parsed.clarity || 0,
                },
            };
        }
        catch (error) {
            console.error('[Evaluator] Değerlendirme hatası:', error);
            return this.createDefaultResult(false, `Hata: ${error}`);
        }
    }
    /**
     * İki cevabı karşılaştır
     */
    async compare(expectedAnswer, actualAnswer) {
        const router = getRouter();
        const prompt = `İki cevabı karşılaştır:

## Beklenen Cevap:
${expectedAnswer}

## Verilen Cevap:
${actualAnswer}

## Yanıt (JSON):
{
    "similarity": <0-100>,
    "keyPointsMatched": ["<eşleşen nokta 1>", ...],
    "keyPointsMissed": ["<kaçırılan nokta 1>", ...],
    "extraPoints": ["<fazladan nokta 1>", ...]
}`;
        try {
            const response = await router.complete('default', prompt, 'Cevapları karşılaştır ve JSON döndür.');
            const jsonMatch = response.content.match(/\{[\s\S]*\}/);
            if (!jsonMatch) {
                return { similarity: 0, keyPointsMatched: [], keyPointsMissed: [], extraPoints: [] };
            }
            return JSON.parse(jsonMatch[0]);
        }
        catch (error) {
            return { similarity: 0, keyPointsMatched: [], keyPointsMissed: [], extraPoints: [] };
        }
    }
    /**
     * Basit cevap kontrolü (LLM kullanmadan)
     */
    quickCheck(expectedAnswer, actualAnswer) {
        const normalize = (s) => s.toLowerCase()
            .replace(/[^\w\sğüşıöçĞÜŞİÖÇ]/g, '')
            .replace(/\s+/g, ' ')
            .trim();
        const expected = normalize(expectedAnswer);
        const actual = normalize(actualAnswer);
        // Tam eşleşme
        if (expected === actual)
            return 100;
        // Kapsama kontrolü
        if (actual.includes(expected) || expected.includes(actual)) {
            return 80;
        }
        // Kelime bazlı benzerlik
        const expectedWords = new Set(expected.split(' '));
        const actualWords = new Set(actual.split(' '));
        let matches = 0;
        for (const word of expectedWords) {
            if (actualWords.has(word))
                matches++;
        }
        return Math.round((matches / expectedWords.size) * 100);
    }
    /**
     * Varsayılan sonuç oluştur
     */
    createDefaultResult(isCorrect, reasoning) {
        return {
            score: isCorrect ? 100 : 0,
            correctness: isCorrect,
            reasoning,
            implicitUnderstanding: 0,
            suggestions: [],
            details: {
                factualAccuracy: 0,
                logicChain: 0,
                completeness: 0,
                clarity: 0,
            },
        };
    }
}
// Singleton
let evaluatorInstance = null;
export function getEvaluator() {
    if (!evaluatorInstance) {
        evaluatorInstance = new Evaluator();
    }
    return evaluatorInstance;
}
//# sourceMappingURL=evaluator.js.map