/**
 * Universal LLM MCP - Document Processor
 * Metin chunking ve işleme
 * Türkçe karakter desteği
 */
export interface ProcessedChunk {
    text: string;
    index: number;
    startChar: number;
    endChar: number;
}
export interface ProcessingOptions {
    chunkSize: number;
    chunkOverlap: number;
    preserveSentences: boolean;
}
/**
 * Belge İşleyici
 * Metinleri chunk'lara böler
 */
export declare class DocumentProcessor {
    private options;
    constructor(options?: Partial<ProcessingOptions>);
    /**
     * Metni chunk'lara böl
     */
    process(text: string): ProcessedChunk[];
    /**
     * Metni temizle
     */
    private cleanText;
    /**
     * Cümle bazlı chunking
     * Türkçe noktalama işaretlerini dikkate alır
     */
    private chunkBySentences;
    /**
     * Sabit boyutlu chunking
     */
    private chunkBySize;
    /**
     * Markdown/kod bloklarını işle
     * Kod bloklarını ayrı chunk olarak tut
     */
    processWithCodeBlocks(text: string): ProcessedChunk[];
    /**
     * Seçenekleri güncelle
     */
    setOptions(options: Partial<ProcessingOptions>): void;
    /**
     * Mevcut seçenekler
     */
    getOptions(): ProcessingOptions;
}
/**
 * DocumentProcessor singleton instance al
 */
export declare function getDocumentProcessor(options?: Partial<ProcessingOptions>): DocumentProcessor;
//# sourceMappingURL=document-processor.d.ts.map