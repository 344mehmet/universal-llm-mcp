/**
 * Universal LLM MCP - Prompt/Soru Bankası
 * LLM eğitimi ve değerlendirmesi için soru yönetimi
 */

import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Soru kategorileri
export type QuestionCategory = 'matematik' | 'mantik' | 'kod' | 'dil' | 'analiz';

// Zorluk seviyesi
export type DifficultyLevel = 1 | 2 | 3 | 4 | 5;

// Soru arayüzü
export interface PromptQuestion {
    id: string;
    category: QuestionCategory;
    difficulty: DifficultyLevel;
    question: string;
    expectedAnswer: string;
    hints?: string[];
    contextClues?: string[];  // Örtük bağlam ipuçları
    tags?: string[];
    createdAt: Date;
}

// Soru bankası istatistikleri
export interface PromptBankStats {
    totalQuestions: number;
    byCategory: Record<QuestionCategory, number>;
    byDifficulty: Record<DifficultyLevel, number>;
}

/**
 * Prompt/Soru Bankası
 */
export class PromptBank {
    private questions: Map<string, PromptQuestion> = new Map();
    private dataPath: string;
    private idCounter: number = 0;

    constructor(dataPath?: string) {
        this.dataPath = dataPath || join(__dirname, '..', '..', 'training-data', 'questions.json');
        this.loadFromFile();
        this.initializeDefaultQuestions();
    }

    /**
     * Varsayılan sorular (ilk kurulum için)
     */
    private initializeDefaultQuestions(): void {
        if (this.questions.size > 0) return;

        const defaultQuestions: Omit<PromptQuestion, 'id' | 'createdAt'>[] = [
            // Matematik
            {
                category: 'matematik',
                difficulty: 1,
                question: '15 + 27 = ?',
                expectedAnswer: '42',
            },
            {
                category: 'matematik',
                difficulty: 2,
                question: 'Bir sayının %20\'si 50 ise, sayının kendisi kaçtır?',
                expectedAnswer: '250',
                hints: ['%20 = 1/5, yani sayı 50\'nin 5 katı'],
            },
            {
                category: 'matematik',
                difficulty: 3,
                question: 'x² - 5x + 6 = 0 denkleminin kökleri nelerdir?',
                expectedAnswer: 'x = 2 ve x = 3',
                hints: ['Çarpanlarına ayır: (x-2)(x-3) = 0'],
            },
            {
                category: 'matematik',
                difficulty: 4,
                question: '1\'den 100\'e kadar olan sayıların toplamı kaçtır?',
                expectedAnswer: '5050',
                hints: ['Gauss formülü: n(n+1)/2'],
            },

            // Mantık
            {
                category: 'mantik',
                difficulty: 2,
                question: 'Tüm kediler hayvandır. Bazı hayvanlar siyahtır. O halde: Bazı kediler siyahtır - doğru mu?',
                expectedAnswer: 'Kesin değil. Bazı hayvanlar siyah olabilir ama bunların kedi olduğunu bilemeyiz.',
            },
            {
                category: 'mantik',
                difficulty: 3,
                question: 'A, B\'den büyük. C, A\'dan küçük. B, D\'den büyük. En küçük hangisi?',
                expectedAnswer: 'D en küçük. Sıralama: A > B > D ve A > C, ama C ile B/D ilişkisi belirsiz.',
                hints: ['Önce kesin ilişkileri belirle'],
            },
            {
                category: 'mantik',
                difficulty: 4,
                question: 'Bir ada var, halk ya hep doğru söyler ya hep yalan. Biri diyor ki: "Ben yalancıyım." Bu kişi doğrucu mu yalancı mı?',
                expectedAnswer: 'Bu bir paradoks. Doğrucu olamaz çünkü yalancı olduğunu söylüyor. Yalancı olamaz çünkü doğru söylemiş olur.',
            },

            // Kod
            {
                category: 'kod',
                difficulty: 1,
                question: 'Python\'da bir listedeki elemanları tersten yazdırmak için hangi metod kullanılır?',
                expectedAnswer: 'list.reverse() veya list[::-1]',
            },
            {
                category: 'kod',
                difficulty: 2,
                question: 'for i in range(5): sum += i -- Bu kodun sonucu nedir?',
                expectedAnswer: '0+1+2+3+4 = 10',
            },
            {
                category: 'kod',
                difficulty: 3,
                question: 'Bu kodda hata nedir?\nfunction add(a, b) { return a + b }\nconsole.log(add(5));',
                expectedAnswer: 'Fonksiyon 2 parametre bekliyor ama 1 tane verilmiş. b undefined olacak, sonuç NaN.',
                hints: ['Eksik parametre kontrolü'],
            },
            {
                category: 'kod',
                difficulty: 4,
                question: 'O(n²) karmaşıklığındaki bubble sort\'u O(n log n)\'e nasıl düşürürsün?',
                expectedAnswer: 'Bubble sort yerine merge sort veya quick sort kullan.',
                hints: ['Böl ve fethet algoritmaları'],
            },

            // Dil / Örtük Anlam
            {
                category: 'dil',
                difficulty: 2,
                question: '"Taşı gediğine koymak" deyimi ne anlama gelir?',
                expectedAnswer: 'Bir şeyi en uygun yerine yerleştirmek, isabetli konuşmak.',
            },
            {
                category: 'dil',
                difficulty: 3,
                question: 'Kullanıcı: "Yarın sabah erkenden..." - Bu cümleyi tamamla.',
                expectedAnswer: 'Bağlama göre değişir. Örn: "kalkmalıyım", "toplantım var", "yola çıkacağım"',
                contextClues: ['Kullanıcı geçen gün iş görüşmesinden bahsetmişti'],
                hints: ['Bağlam ipucunu kullan'],
            },
            {
                category: 'dil',
                difficulty: 4,
                question: 'Bir kullanıcı sadece "..." yazıyor. Ne ifade ediyor olabilir?',
                expectedAnswer: 'Belirsizlik, düşünme, memnuniyetsizlik veya konuşmayı sürdürme isteği olabilir.',
                contextClues: ['Önceki mesajda bir öneri yapılmıştı'],
            },

            // Analiz
            {
                category: 'analiz',
                difficulty: 2,
                question: 'Satışlar: Ocak=100, Şubat=120, Mart=150, Nisan=140. Trend nedir?',
                expectedAnswer: 'Genel artış trendi var, ancak Nisan\'da hafif düşüş.',
            },
            {
                category: 'analiz',
                difficulty: 3,
                question: 'Bir EA\'nın win rate %60, risk:reward 1:2. Uzun vadede kârlı mı?',
                expectedAnswer: 'Evet. Beklenen değer: 0.6*2 - 0.4*1 = 1.2 - 0.4 = 0.8 (pozitif)',
                hints: ['Beklenen değer hesapla'],
            },
        ];

        for (const q of defaultQuestions) {
            this.add(q);
        }

        this.saveToFile();
        console.log(`[PromptBank] ${defaultQuestions.length} varsayılan soru yüklendi`);
    }

    /**
     * Soru ekle
     */
    public add(question: Omit<PromptQuestion, 'id' | 'createdAt'>): string {
        const id = `q_${++this.idCounter}_${Date.now()}`;

        const fullQuestion: PromptQuestion = {
            ...question,
            id,
            createdAt: new Date(),
        };

        this.questions.set(id, fullQuestion);
        return id;
    }

    /**
     * Soru al
     */
    public get(id: string): PromptQuestion | undefined {
        return this.questions.get(id);
    }

    /**
     * Rastgele soru al
     */
    public getRandom(filter?: { category?: QuestionCategory; difficulty?: DifficultyLevel }): PromptQuestion | null {
        let candidates = Array.from(this.questions.values());

        if (filter?.category) {
            candidates = candidates.filter(q => q.category === filter.category);
        }
        if (filter?.difficulty) {
            candidates = candidates.filter(q => q.difficulty === filter.difficulty);
        }

        if (candidates.length === 0) return null;

        const randomIndex = Math.floor(Math.random() * candidates.length);
        return candidates[randomIndex];
    }

    /**
     * Kategoriye göre sorular
     */
    public getByCategory(category: QuestionCategory): PromptQuestion[] {
        return Array.from(this.questions.values())
            .filter(q => q.category === category);
    }

    /**
     * Zorluğa göre sorular
     */
    public getByDifficulty(difficulty: DifficultyLevel): PromptQuestion[] {
        return Array.from(this.questions.values())
            .filter(q => q.difficulty === difficulty);
    }

    /**
     * Soru sil
     */
    public delete(id: string): boolean {
        return this.questions.delete(id);
    }

    /**
     * Tüm soruları listele
     */
    public list(limit?: number): PromptQuestion[] {
        const all = Array.from(this.questions.values());
        return limit ? all.slice(0, limit) : all;
    }

    /**
     * İstatistikler
     */
    public getStats(): PromptBankStats {
        const stats: PromptBankStats = {
            totalQuestions: this.questions.size,
            byCategory: {
                matematik: 0,
                mantik: 0,
                kod: 0,
                dil: 0,
                analiz: 0,
            },
            byDifficulty: {
                1: 0, 2: 0, 3: 0, 4: 0, 5: 0,
            },
        };

        for (const q of this.questions.values()) {
            stats.byCategory[q.category]++;
            stats.byDifficulty[q.difficulty]++;
        }

        return stats;
    }

    /**
     * Dosyadan yükle
     */
    private loadFromFile(): void {
        try {
            if (existsSync(this.dataPath)) {
                const data = readFileSync(this.dataPath, 'utf-8');
                const parsed = JSON.parse(data);

                this.questions = new Map(
                    parsed.questions.map((q: PromptQuestion) => {
                        q.createdAt = new Date(q.createdAt);
                        return [q.id, q];
                    })
                );
                this.idCounter = parsed.idCounter || this.questions.size;
                console.log(`[PromptBank] ${this.questions.size} soru yüklendi`);
            }
        } catch (error) {
            console.error('[PromptBank] Yükleme hatası:', error);
        }
    }

    /**
     * Dosyaya kaydet
     */
    public saveToFile(): void {
        try {
            const dir = dirname(this.dataPath);
            if (!existsSync(dir)) {
                mkdirSync(dir, { recursive: true });
            }

            const data = {
                questions: Array.from(this.questions.values()),
                idCounter: this.idCounter,
                savedAt: new Date().toISOString(),
            };

            writeFileSync(this.dataPath, JSON.stringify(data, null, 2), 'utf-8');
            console.log('[PromptBank] Kaydedildi');
        } catch (error) {
            console.error('[PromptBank] Kaydetme hatası:', error);
        }
    }
}

// Singleton
let promptBankInstance: PromptBank | null = null;

export function getPromptBank(): PromptBank {
    if (!promptBankInstance) {
        promptBankInstance = new PromptBank();
    }
    return promptBankInstance;
}
