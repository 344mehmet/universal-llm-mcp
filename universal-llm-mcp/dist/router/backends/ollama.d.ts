/**
 * Universal LLM MCP - Ollama Backend
 * Ollama API bağlantısı
 */
import { BaseLLMBackend, CompletionRequest, CompletionResponse, BackendStatus } from './base.js';
/**
 * Ollama Backend Sınıfı
 */
export declare class OllamaBackend extends BaseLLMBackend {
    constructor(url: string, defaultModel?: string, timeout?: number);
    /**
     * Ollama sağlık kontrolü
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
//# sourceMappingURL=ollama.d.ts.map