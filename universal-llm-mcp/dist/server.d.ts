/**
 * Universal LLM MCP Sunucusu
 * Yerel LLM'ler için evrensel MCP sunucusu - Türkçe destekli
 *
 * Bu sunucu, farklı LLM backend'lerini (LM Studio, Ollama vb.) tek bir
 * arayüz altında birleştirir ve çeşitli araçlar sunar.
 */
/**
 * Ana sunucu sınıfı
 */
export declare class UniversalLLMServer {
    private server;
    private config;
    constructor();
    /**
     * Tüm araçları kaydet
     */
    private registerAllTools;
    /**
     * Sistem araçlarını kaydet
     */
    private registerSystemTools;
    /**
     * Sunucuyu başlat
     */
    start(): Promise<void>;
}
//# sourceMappingURL=server.d.ts.map