/**
 * Universal LLM MCP - Document Processor
 * Metin chunking ve işleme
 * Türkçe karakter desteği
 */
// Varsayılan seçenekler
const DEFAULT_OPTIONS = {
    chunkSize: 500,
    chunkOverlap: 50,
    preserveSentences: true,
};
/**
 * Belge İşleyici
 * Metinleri chunk'lara böler
 */
export class DocumentProcessor {
    options;
    constructor(options) {
        this.options = { ...DEFAULT_OPTIONS, ...options };
    }
    /**
     * Metni chunk'lara böl
     */
    process(text) {
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
        }
        else {
            return this.chunkBySize(cleanedText);
        }
    }
    /**
     * Metni temizle
     */
    cleanText(text) {
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
    chunkBySentences(text) {
        // Türkçe cümle sonu işaretleri
        const sentenceEnders = /([.!?…])\s+/g;
        const sentences = text.split(sentenceEnders).filter(s => s.trim());
        const chunks = [];
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
            }
            else {
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
    chunkBySize(text) {
        const chunks = [];
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
    processWithCodeBlocks(text) {
        const codeBlockRegex = /```[\s\S]*?```/g;
        const parts = [];
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
        const chunks = [];
        for (const part of parts) {
            if (part.isCode) {
                // Kod bloğunu olduğu gibi ekle
                chunks.push({
                    text: part.text,
                    index: chunks.length,
                    startChar: 0,
                    endChar: part.text.length,
                });
            }
            else {
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
    setOptions(options) {
        this.options = { ...this.options, ...options };
    }
    /**
     * Mevcut seçenekler
     */
    getOptions() {
        return { ...this.options };
    }
}
// Singleton instance
let processorInstance = null;
/**
 * DocumentProcessor singleton instance al
 */
export function getDocumentProcessor(options) {
    if (!processorInstance) {
        processorInstance = new DocumentProcessor(options);
    }
    return processorInstance;
}
//# sourceMappingURL=document-processor.js.map