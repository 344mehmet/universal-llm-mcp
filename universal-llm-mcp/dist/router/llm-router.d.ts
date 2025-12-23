/**
 * Universal LLM MCP - LLM Router
 * Görev tipine göre uygun backend'e yönlendirme
 */
import { BaseLLMBackend, CompletionRequest, CompletionResponse, BackendStatus } from './backends/base.js';
export type TaskType = 'code' | 'chat' | 'translate' | 'file' | 'default';
/**
 * LLM Router Sınıfı
 * Merkezi backend yönetimi ve yönlendirme
 */
export declare class LLMRouter {
    private backends;
    private backendStatus;
    constructor();
    /**
     * Backend'leri yapılandırmadan başlat
     */
    private initializeBackends;
    /**
     * Backend instance oluştur
     */
    private createBackend;
    /**
     * Tüm backend'lerin sağlık durumunu kontrol et
     */
    checkAllBackends(): Promise<Map<string, BackendStatus>>;
    /**
     * Belirli bir backend'in durumunu al
     */
    getBackendStatus(name: string): BackendStatus | undefined;
    /**
     * Görev tipi için uygun backend'i seç
     */
    private selectBackend;
    /**
     * Tamamlama isteği gönder
     */
    complete(taskType: TaskType, mesaj: string, sistemPrompt?: string, options?: Partial<CompletionRequest>): Promise<CompletionResponse>;
    /**
     * Belirli bir backend ile tamamlama
     */
    completeWithBackend(backendName: string, mesaj: string, sistemPrompt?: string): Promise<CompletionResponse>;
    /**
     * Mevcut modelleri listele
     */
    listAllModels(): Promise<Record<string, string[]>>;
    /**
     * Yeni backend ekle (çalışma zamanında)
     */
    addBackend(name: string, backend: BaseLLMBackend): void;
    /**
     * Backend kaldır
     */
    removeBackend(name: string): boolean;
}
/**
 * Router instance'ını al
 */
export declare function getRouter(): LLMRouter;
//# sourceMappingURL=llm-router.d.ts.map