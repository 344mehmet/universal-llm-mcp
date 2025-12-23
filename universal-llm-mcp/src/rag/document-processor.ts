/**
 * Universal LLM MCP - Document Processor
 * Metin chunking ve işleme
 * Türkçe karakter desteği
 */

// Chunk sonucu
export interface ProcessedChunk {
    text: string;
    index: number;
    startChar: number;
    endChar: number;
}

// İşleme seçenekleri
export interface ProcessingOptions {
    chunkSize: number;      // Chunk boyutu (karakter)
    chunkOverlap: number;   // Overlap miktarı
    preserveSentences: boolean; // Cümle bütünlüğünü koru
}

// Varsayılan seçenekler
const DEFAULT_OPTIONS: ProcessingOptions = {
    chunkSize: 500,
    chunkOverlap: 50,
    preserveSentences: true,
};

/**
 * Belge İşleyici
 * Metinleri chunk'lara böler
 */
export class DocumentProcessor {
    private options: ProcessingOptions;

    constructor(options?: Partial<ProcessingOptions>) {
        this.options = { ...DEFAULT_OPTIONS, ...options };
    }

    /**
     * Metni chunk'lara böl
     */
    public process(text: string): ProcessedChunk[] {
        // Önce metni temizle
        const cleanedText = this.cleanText(text);

        if (cleanedText.length <= this.options.chunkSize) {
            return [{
                text: cleanedText,
                index: 0,
                startChar: 0,
                endChar: cleanedText.length,
            }];
        }

        if (this.options.preserveSentences) {
            return this.chunkBySentences(cleanedText);
        } else {
            return this.chunkBySize(cleanedText);
        }
    }

    /**
     * Metni temizle
     */
    private cleanText(text: string): string {
        return text
            // Fazla boşlukları temizle
            .replace(/\s+/g, ' ')
            // Satır başlarını düzelt
            .replace(/\n\s*\n/g, '\n\n')
            // Türkçe karakterleri koru
            .trim();
    }

    /**
     * Cümle bazlı chunking
     * Türkçe noktalama işaretlerini dikkate alır
     */
    private chunkBySentences(text: string): ProcessedChunk[] {
        // Türkçe cümle sonu işaretleri
        const sentenceEnders = /([.!?…])\s+/g;
        const sentences = text.split(sentenceEnders).filter(s => s.trim());

        const chunks: ProcessedChunk[] = [];
        let currentChunk = '';
        let currentStart = 0;
        let charPosition = 0;

        for (let i = 0; i < sentences.length; i++) {
            const sentence = sentences[i];

            // Noktalama işareti mi?
            if (/^[.!?…]$/.test(sentence)) {
                currentChunk += sentence + ' ';
                charPosition += sentence.length + 1;
                continue;
            }

            // Chunk boyutunu kontrol et
            if (currentChunk.length + sentence.length > this.options.chunkSize && currentChunk.length > 0) {
                // Mevcut chunk'ı kaydet
                chunks.push({
                    text: currentChunk.trim(),
                    index: chunks.length,
                    startChar: currentStart,
                    endChar: charPosition,
                });

                // Overlap ile yeni chunk başlat
                const overlapStart = Math.max(0, currentChunk.length - this.options.chunkOverlap);
                currentChunk = currentChunk.substring(overlapStart) + sentence + ' ';
                currentStart = charPosition - (currentChunk.length - sentence.length - 1);
            } else {
                currentChunk += sentence + ' ';
            }

            charPosition += sentence.length + 1;
        }

        // Son chunk'ı ekle
        if (currentChunk.trim()) {
            chunks.push({
                text: currentChunk.trim(),
                index: chunks.length,
                startChar: currentStart,
                endChar: charPosition,
            });
        }

        return chunks;
    }

    /**
     * Sabit boyutlu chunking
     */
    private chunkBySize(text: string): ProcessedChunk[] {
        const chunks: ProcessedChunk[] = [];
        let position = 0;

        while (position < text.length) {
            const end = Math.min(position + this.options.chunkSize, text.length);

            // Kelime ortasında kesmemeye çalış
            let adjustedEnd = end;
            if (end < text.length) {
                const lastSpace = text.lastIndexOf(' ', end);
                if (lastSpace > position) {
                    adjustedEnd = lastSpace;
                }
            }

            chunks.push({
                text: text.substring(position, adjustedEnd).trim(),
                index: chunks.length,
                startChar: position,
                endChar: adjustedEnd,
            });

            // Overlap ile ilerle
            position = adjustedEnd - this.options.chunkOverlap;
            if (position >= text.length - this.options.chunkOverlap) {
                position = adjustedEnd;
            }
        }

        return chunks;
    }

    /**
     * Markdown/kod bloklarını işle
     * Kod bloklarını ayrı chunk olarak tut
     */
    public processWithCodeBlocks(text: string): ProcessedChunk[] {
        const codeBlockRegex = /```[\s\S]*?```/g;
        const parts: { text: string; isCode: boolean }[] = [];

        let lastIndex = 0;
        let match;

        while ((match = codeBlockRegex.exec(text)) !== null) {
            // Kod bloğu öncesi metin
            if (match.index > lastIndex) {
                parts.push({
                    text: text.substring(lastIndex, match.index),
                    isCode: false,
                });
            }
            // Kod bloğu
            parts.push({
                text: match[0],
                isCode: true,
            });
            lastIndex = match.index + match[0].length;
        }

        // Kalan metin
        if (lastIndex < text.length) {
            parts.push({
                text: text.substring(lastIndex),
                isCode: false,
            });
        }

        // Her parçayı işle
        const chunks: ProcessedChunk[] = [];
        for (const part of parts) {
            if (part.isCode) {
                // Kod bloğunu olduğu gibi ekle
                chunks.push({
                    text: part.text,
                    index: chunks.length,
                    startChar: 0,
                    endChar: part.text.length,
                });
            } else {
                // Normal metni chunk'la
                const processed = this.process(part.text);
                for (const chunk of processed) {
                    chunks.push({
                        ...chunk,
                        index: chunks.length,
                    });
                }
            }
        }

        return chunks;
    }

    /**
     * Seçenekleri güncelle
     */
    public setOptions(options: Partial<ProcessingOptions>): void {
        this.options = { ...this.options, ...options };
    }

    /**
     * Mevcut seçenekler
     */
    public getOptions(): ProcessingOptions {
        return { ...this.options };
    }
}

// Singleton instance
let processorInstance: DocumentProcessor | null = null;

/**
 * DocumentProcessor singleton instance al
 */
export function getDocumentProcessor(options?: Partial<ProcessingOptions>): DocumentProcessor {
    if (!processorInstance) {
        processorInstance = new DocumentProcessor(options);
    }
    return processorInstance;
}
