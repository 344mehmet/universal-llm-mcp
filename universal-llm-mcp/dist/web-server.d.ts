/**
 * Universal LLM MCP - Web RAG Server
 * HTTPS API sunucusu - Güvenli bağlantı (Self-signed sertifika)
 * Tüm tarayıcılarda çalışır (CORS etkin)
 */
/**
 * Web RAG Sunucusu (HTTPS)
 */
export declare class WebRAGServer {
    private server;
    private port;
    private isRunning;
    private useHttps;
    constructor(port?: number);
    /**
     * Sunucuyu başlat (HTTPS tercih edilir)
     */
    start(): Promise<void>;
    /**
     * Sunucuyu durdur
     */
    stop(): Promise<void>;
    /**
     * HTTP isteğini işle
     */
    private handleRequest;
    /**
     * JSON body parse
     */
    private parseBody;
    /**
     * Yanıt gönder
     */
    private sendResponse;
    /**
     * Durum endpoint'i
     */
    private handleStatus;
    /**
     * RAG bilgi ekleme
     */
    private handleRAGAdd;
    /**
     * RAG sorgulama
     */
    private handleRAGQuery;
    /**
     * RAG bilgi listesi
     */
    private handleRAGList;
    /**
     * Sohbet endpoint'i
     */
    private handleChat;
    /**
     * Eğitim soruları
     */
    private handleTrainingQuestions;
    /**
     * Tartışma başlat
     */
    private handleDebateStart;
    /**
     * Tartışma durumu
     */
    private handleDebateStatus;
    /**
     * Tartışma geçmişi
     */
    private handleDebateHistory;
    /**
     * Egitim baslat
     */
    private handleTrainingStart;
    /**
     * Egitim durumu
     */
    private handleTrainingStatus;
    /**
     * Tum LLM'lere sor
     */
    private handleAskAll;
    /**
     * Web arayuzu HTML
     */
    private serveHTML;
    /**
     * Port bilgisi
     */
    getPort(): number;
    /**
     * Çalışıyor mu?
     */
    isActive(): boolean;
}
export declare function getWebRAGServer(port?: number): WebRAGServer;
//# sourceMappingURL=web-server.d.ts.map