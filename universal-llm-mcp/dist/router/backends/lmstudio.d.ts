/**
 * Universal LLM MCP - LM Studio Backend
 * LM Studio API bağlantısı
 */
import { BaseLLMBackend, CompletionRequest, CompletionResponse, BackendStatus } from './base.js';
/**
 * LM Studio Backend Sınıfı
 */
export declare class LMStudioBackend extends BaseLLMBackend {
    constructor(url: string, defaultModel?: string, timeout?: number);
    /**
     * LM Studio sağlık kontrolü
     */
    checkHealth(): Promise<BackendStatus>;
    /**
     * Mevcut modelleri listele
     */
    listModels(): Promise<string[]>;
    /**
     * Chat tamamlama
     */
    complete(request: CompletionRequest): Promise<CompletionResponse>;
}
//# sourceMappingURL=lmstudio.d.ts.map