/**
 * Universal LLM MCP - Kapsamlı Eğitim Veri Seti
 * Tüm kategoriler: matematik, kod, dil, analiz, uzay-zaman
 */
import { getFastTrainer } from './fast-trainer.js';
// Matematik örnekleri
export const MATEMATIK_ORNEKLERI = {
    category: 'matematik',
    examples: [
        { input: '2 + 2 = ?', expectedOutput: '4', difficulty: 1 },
        { input: '15 x 7 = ?', expectedOutput: '105', difficulty: 2 },
        { input: '144\'ün karekökü?', expectedOutput: '12', difficulty: 2 },
        { input: 'Fibonacci dizisinde 10. eleman?', expectedOutput: '55', difficulty: 3 },
        { input: 'e^(i*pi) + 1 = ?', expectedOutput: '0 (Euler özdeşliği)', difficulty: 4 },
        { input: 'Türev: d/dx (x^3)', expectedOutput: '3x^2', difficulty: 3 },
        { input: 'İntegral: ∫ 2x dx', expectedOutput: 'x^2 + C', difficulty: 3 },
        { input: 'Limit: lim(x→0) sin(x)/x', expectedOutput: '1', difficulty: 4 },
        { input: 'Asal sayı mıdır: 97?', expectedOutput: 'Evet, 97 asal sayıdır', difficulty: 2 },
        { input: '1000\'in faktöriyeli kaç basamaklı?', expectedOutput: '2568 basamak', difficulty: 5 },
    ]
};
// Kod örnekleri
export const KOD_ORNEKLERI = {
    category: 'kod',
    examples: [
        { input: 'Python: liste tersine çevir', expectedOutput: 'liste[::-1] veya liste.reverse()', difficulty: 1 },
        { input: 'JavaScript: dizi filtreleme', expectedOutput: 'array.filter(x => condition)', difficulty: 2 },
        { input: 'TypeScript: interface tanımla', expectedOutput: 'interface Name { prop: type; }', difficulty: 2 },
        { input: 'SQL: benzersiz değerler', expectedOutput: 'SELECT DISTINCT column FROM table', difficulty: 2 },
        { input: 'Git: son commit geri al', expectedOutput: 'git reset --soft HEAD~1', difficulty: 3 },
        { input: 'Regex: email doğrulama', expectedOutput: '^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+$', difficulty: 4 },
        { input: 'Big O: binary search', expectedOutput: 'O(log n)', difficulty: 3 },
        { input: 'MQL5: pozisyon aç', expectedOutput: 'trade.Buy(lot, symbol, price, sl, tp)', difficulty: 4 },
        { input: 'Python: async fonksiyon', expectedOutput: 'async def func(): await ...', difficulty: 3 },
        { input: 'C++: smart pointer', expectedOutput: 'std::unique_ptr veya std::shared_ptr', difficulty: 4 },
    ]
};
// Dil örnekleri
export const DIL_ORNEKLERI = {
    category: 'dil',
    examples: [
        { input: 'Hello Türkçeye çevir', expectedOutput: 'Merhaba', difficulty: 1 },
        { input: 'Yapay zeka İngilizce?', expectedOutput: 'Artificial Intelligence', difficulty: 1 },
        { input: 'Paradigma kelimesinin kökeni?', expectedOutput: 'Yunanca paradeigma (örnek, model)', difficulty: 3 },
        { input: 'Metafor ile benzetme farkı?', expectedOutput: 'Metafor doğrudan, benzetme "gibi" ile', difficulty: 3 },
        { input: 'Osmanlıca "mektup" ne demek?', expectedOutput: 'Yazılmış şey, mektup', difficulty: 2 },
        { input: 'İdiom: "taşı gediğine koymak"', expectedOutput: 'Doğru kişiyi doğru yere yerleştirmek', difficulty: 3 },
        { input: 'Etimoloji: "bilgisayar"', expectedOutput: 'bilgi + sayar (Türkçe kökenli)', difficulty: 2 },
        { input: 'Çoğul: radyo', expectedOutput: 'radyolar', difficulty: 1 },
        { input: 'Eş anlamlı: güzel', expectedOutput: 'hoş, latif, zarif, şirin', difficulty: 2 },
        { input: 'Zıt anlamlı: karanlık', expectedOutput: 'aydınlık', difficulty: 1 },
    ]
};
// Analiz örnekleri
export const ANALIZ_ORNEKLERI = {
    category: 'analiz',
    examples: [
        { input: 'Tümdengelim nedir?', expectedOutput: 'Genelden özele mantık yürütme', difficulty: 2 },
        { input: 'Tümevarım nedir?', expectedOutput: 'Özelden genele mantık yürütme', difficulty: 2 },
        { input: 'Korelasyon = Nedensellik?', expectedOutput: 'Hayır, korelasyon nedensellik değildir', difficulty: 3 },
        { input: 'Occam usturası?', expectedOutput: 'En basit açıklama genellikle doğrudur', difficulty: 3 },
        { input: 'Sunk cost fallacy?', expectedOutput: 'Batık maliyet yanılgısı, geçmiş yatırımı karar etkisi', difficulty: 4 },
        { input: 'Confirmation bias?', expectedOutput: 'Doğrulama önyargısı, inancı destekleyen bilgi arama', difficulty: 3 },
        { input: 'A/B testi nedir?', expectedOutput: 'İki varyantı karşılaştırmalı test', difficulty: 2 },
        { input: 'P-değeri < 0.05?', expectedOutput: 'İstatistiksel olarak anlamlı', difficulty: 3 },
        { input: 'Pareto ilkesi?', expectedOutput: '80/20 kuralı, çoğunluk azınlıktan gelir', difficulty: 2 },
        { input: 'Dunning-Kruger etkisi?', expectedOutput: 'Yetersiz kişilerin kendini aşırı değerlemesi', difficulty: 4 },
    ]
};
// Uzay-zaman örnekleri
export const UZAYZAMAN_ORNEKLERI = {
    category: 'uzayzaman',
    examples: [
        { input: 'Işık hızı?', expectedOutput: '299,792,458 m/s (c)', difficulty: 1 },
        { input: 'E = mc² ne demek?', expectedOutput: 'Enerji = kütle x ışık hızının karesi', difficulty: 2 },
        { input: 'Kara delik nedir?', expectedOutput: 'Işığın bile kaçamadığı gravitasyon alanı', difficulty: 2 },
        { input: 'Zaman genişlemesi?', expectedOutput: 'Hıza/gravitasyona bağlı zaman yavaşlaması', difficulty: 3 },
        { input: 'Kuantum dolanıklık?', expectedOutput: 'Parçacıklar arası anlık korelasyon', difficulty: 4 },
        { input: 'Planck uzunluğu?', expectedOutput: '1.616 × 10^-35 metre', difficulty: 4 },
        { input: 'Evrenin yaşı?', expectedOutput: 'Yaklaşık 13.8 milyar yıl', difficulty: 2 },
        { input: 'Schrödinger kedisi?', expectedOutput: 'Kuantum süperpozisyon düşünce deneyi', difficulty: 3 },
        { input: 'Karanlık madde?', expectedOutput: 'Görünmez ama gravitasyon etkisi olan madde', difficulty: 3 },
        { input: 'Çoklu evren teorisi?', expectedOutput: 'Sonsuz paralel evrenler hipotezi', difficulty: 4 },
    ]
};
// Tüm setler
export const TUM_EGITIM_SETLERI = [
    MATEMATIK_ORNEKLERI,
    KOD_ORNEKLERI,
    DIL_ORNEKLERI,
    ANALIZ_ORNEKLERI,
    UZAYZAMAN_ORNEKLERI,
];
/**
 * Tüm örnekleri yükle
 */
export function loadAllTrainingExamples() {
    const trainer = getFastTrainer();
    let count = 0;
    for (const set of TUM_EGITIM_SETLERI) {
        for (const example of set.examples) {
            trainer.addExample({
                input: example.input,
                expectedOutput: example.expectedOutput,
                category: set.category,
                difficulty: example.difficulty,
            });
            count++;
        }
    }
    console.log(`[TrainingData] ${count} örnek yüklendi`);
    return count;
}
/**
 * Belirli kategori yükle
 */
export function loadCategoryExamples(category) {
    const trainer = getFastTrainer();
    const set = TUM_EGITIM_SETLERI.find(s => s.category === category);
    if (!set) {
        console.log(`[TrainingData] Kategori bulunamadı: ${category}`);
        return 0;
    }
    for (const example of set.examples) {
        trainer.addExample({
            input: example.input,
            expectedOutput: example.expectedOutput,
            category: set.category,
            difficulty: example.difficulty,
        });
    }
    console.log(`[TrainingData] ${set.examples.length} örnek yüklendi (${category})`);
    return set.examples.length;
}
//# sourceMappingURL=training-data.js.map