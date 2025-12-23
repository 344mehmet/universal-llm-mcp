/**
 * Universal LLM MCP - Hızlı Eğitim Modülü
 * REG (Regularization) + Fine-tuning desteği
 */
import { EventEmitter } from 'events';
import { getRouter } from '../router/llm-router.js';
import { getSharedKnowledgePool } from '../core/knowledge-pool.js';
import { FastCache, parallelMap, withTimeout } from '../core/performance.js';
/**
 * Hızlı Eğitim Motoru
 */
export class FastTrainer extends EventEmitter {
    examples = [];
    results = new Map();
    scoreCache = new FastCache(300); // 5 dk cache
    isTraining = false;
    knowledgePool = getSharedKnowledgePool();
    // REG parametreleri
    regularizationStrength = 0.1;
    dropoutRate = 0.1;
    momentumDecay = 0.9;
    constructor() {
        super();
        console.log('[FastTrainer] Hızlı eğitim modülü başlatıldı');
    }
    /**
     * Eğitim örneği ekle
     */
    addExample(example) {
        const id = `ex_${Date.now()}_${Math.random().toString(36).substr(2, 6)}`;
        // REG: Ağırlık hesapla (zorluk * kategori önemi)
        const weight = this.calculateWeight(example.difficulty, example.category);
        const fullExample = {
            ...example,
            id,
            weight,
        };
        this.examples.push(fullExample);
        console.log(`[FastTrainer] Örnek eklendi: ${id} (ağırlık: ${weight.toFixed(2)})`);
        return id;
    }
    /**
     * REG: Ağırlık hesaplama
     */
    calculateWeight(difficulty, category) {
        // Zayıf kategorilere daha fazla ağırlık
        const categoryHistory = this.results.get(category) || [];
        const avgScore = categoryHistory.length > 0
            ? categoryHistory.reduce((sum, r) => sum + r.score, 0) / categoryHistory.length
            : 0.5;
        // Düşük skor = yüksek ağırlık
        const categoryWeight = 1 - avgScore + 0.5;
        // Zorluk faktörü
        const difficultyFactor = difficulty / 5;
        // L2 regularization
        const regWeight = 1 + (this.regularizationStrength * difficultyFactor * categoryWeight);
        return Math.min(regWeight, 3); // Max 3x ağırlık
    }
    /**
     * Hızlı batch eğitimi
     */
    async trainBatch(options = {}) {
        if (this.isTraining) {
            throw new Error('Eğitim zaten devam ediyor');
        }
        this.isTraining = true;
        const startTime = Date.now();
        const batchSize = options.batchSize || 5;
        const epochs = options.epochs || 1;
        const examples = options.examples || this.examples;
        console.log(`[FastTrainer] Batch eğitimi başlıyor: ${examples.length} örnek, ${epochs} epoch`);
        this.emit('trainingStarted', { exampleCount: examples.length, epochs });
        const allResults = [];
        try {
            for (let epoch = 0; epoch < epochs; epoch++) {
                console.log(`[FastTrainer] Epoch ${epoch + 1}/${epochs}`);
                // Shuffle with momentum (REG)
                const shuffled = this.shuffleWithMomentum(examples, epoch);
                // Batch'lere böl
                for (let i = 0; i < shuffled.length; i += batchSize) {
                    const batch = shuffled.slice(i, i + batchSize);
                    // Paralel işle (hızlandırma)
                    const batchResults = await parallelMap(batch, (ex) => this.trainSingle(ex), 3 // 3 paralel istek
                    );
                    allResults.push(...batchResults);
                    // Progress
                    const progress = Math.round(((i + batch.length) / shuffled.length) * 100);
                    this.emit('progress', { epoch: epoch + 1, progress, completed: i + batch.length });
                }
            }
        }
        finally {
            this.isTraining = false;
        }
        // Sonuçları kategori bazında kaydet
        for (const result of allResults) {
            const example = examples.find(e => e.id === result.exampleId);
            if (example) {
                const catResults = this.results.get(example.category) || [];
                catResults.push(result);
                this.results.set(example.category, catResults.slice(-100)); // Son 100
                // İyi sonuçları bilgi havuzuna ekle
                if (result.score > 0.8) {
                    await this.knowledgePool.learnFromTraining(example.input, result.actualOutput, example.category, result.score);
                }
            }
        }
        const metrics = this.calculateMetrics(allResults);
        const totalTime = Date.now() - startTime;
        console.log(`[FastTrainer] Eğitim tamamlandı: ${totalTime}ms, skor: ${metrics.averageScore.toFixed(2)}`);
        this.emit('trainingCompleted', { metrics, totalTime });
        return metrics;
    }
    /**
     * Tek örnek eğitimi
     */
    async trainSingle(example) {
        const startTime = Date.now();
        try {
            const router = getRouter();
            // Dropout simulasyonu (REG)
            if (Math.random() < this.dropoutRate) {
                return {
                    exampleId: example.id,
                    actualOutput: '[DROPOUT]',
                    score: 0,
                    latencyMs: 0,
                    feedback: 'Regularization dropout',
                };
            }
            // LLM'den yanıt al (timeout ile)
            const response = await withTimeout(router.complete('chat', example.input), 30000, // 30 saniye max
            'Eğitim timeout');
            const latencyMs = Date.now() - startTime;
            // Skor hesapla
            const score = this.calculateScore(response.content, example.expectedOutput);
            return {
                exampleId: example.id,
                actualOutput: response.content,
                score: score * example.weight, // Ağırlıklı skor
                latencyMs,
            };
        }
        catch (error) {
            return {
                exampleId: example.id,
                actualOutput: '',
                score: 0,
                latencyMs: Date.now() - startTime,
                feedback: String(error),
            };
        }
    }
    /**
     * Basit skor hesaplama
     */
    calculateScore(actual, expected) {
        if (!actual || !expected)
            return 0;
        // Benzerlik (basit kelime eşleşmesi)
        const actualWords = new Set(actual.toLowerCase().split(/\s+/));
        const expectedWords = new Set(expected.toLowerCase().split(/\s+/));
        let matches = 0;
        for (const word of expectedWords) {
            if (actualWords.has(word))
                matches++;
        }
        const similarity = matches / expectedWords.size;
        // Uzunluk faktörü
        const lengthRatio = Math.min(actual.length, expected.length) / Math.max(actual.length, expected.length);
        return (similarity * 0.7) + (lengthRatio * 0.3);
    }
    /**
     * REG: Momentum shuffle
     */
    shuffleWithMomentum(examples, epoch) {
        const sorted = [...examples].sort((a, b) => {
            // Epoch'a göre ağırlık değişimi (momentum decay)
            const decayA = a.weight * Math.pow(this.momentumDecay, epoch);
            const decayB = b.weight * Math.pow(this.momentumDecay, epoch);
            return decayB - decayA; // Yüksek ağırlıklılar önce
        });
        // Kısmi shuffle (top 30% sabit, rest shuffle)
        const fixedCount = Math.floor(sorted.length * 0.3);
        const fixed = sorted.slice(0, fixedCount);
        const shuffled = sorted.slice(fixedCount).sort(() => Math.random() - 0.5);
        return [...fixed, ...shuffled];
    }
    /**
     * Metrik hesaplama
     */
    calculateMetrics(results) {
        const validResults = results.filter(r => r.score > 0);
        const avgScore = validResults.length > 0
            ? validResults.reduce((sum, r) => sum + r.score, 0) / validResults.length
            : 0;
        const avgLatency = validResults.length > 0
            ? validResults.reduce((sum, r) => sum + r.latencyMs, 0) / validResults.length
            : 0;
        // Kategori skorları
        const categoryScores = new Map();
        for (const result of validResults) {
            const example = this.examples.find(e => e.id === result.exampleId);
            if (example) {
                const scores = categoryScores.get(example.category) || [];
                scores.push(result.score);
                categoryScores.set(example.category, scores);
            }
        }
        const categoryAvgs = Array.from(categoryScores.entries()).map(([cat, scores]) => ({
            category: cat,
            score: scores.reduce((a, b) => a + b, 0) / scores.length,
        }));
        categoryAvgs.sort((a, b) => b.score - a.score);
        return {
            totalExamples: results.length,
            completedExamples: validResults.length,
            averageScore: avgScore,
            averageLatency: avgLatency,
            topCategories: categoryAvgs.slice(0, 3),
            weakCategories: categoryAvgs.slice(-3).reverse(),
        };
    }
    /**
     * Anlık eğitim (tek örnek, hızlı)
     */
    async quickTrain(input, expected, category = 'genel') {
        const example = {
            id: `quick_${Date.now()}`,
            input,
            expectedOutput: expected,
            category,
            difficulty: 3,
            weight: 1,
        };
        return this.trainSingle(example);
    }
    /**
     * REG parametrelerini ayarla
     */
    setRegularization(strength, dropout, momentum) {
        this.regularizationStrength = Math.max(0, Math.min(1, strength));
        this.dropoutRate = Math.max(0, Math.min(0.5, dropout));
        this.momentumDecay = Math.max(0.5, Math.min(0.99, momentum));
        console.log(`[FastTrainer] REG güncellendi: L2=${strength}, dropout=${dropout}, momentum=${momentum}`);
    }
    /**
     * İstatistikler
     */
    getStats() {
        return {
            exampleCount: this.examples.length,
            categoryCount: this.results.size,
            isTraining: this.isTraining,
        };
    }
}
// Singleton
let trainerInstance = null;
export function getFastTrainer() {
    if (!trainerInstance) {
        trainerInstance = new FastTrainer();
    }
    return trainerInstance;
}
//# sourceMappingURL=fast-trainer.js.map