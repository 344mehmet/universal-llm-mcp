/**
 * Universal LLM MCP - Groq Backend (Hızlı inference)
 */
import { BaseLLMBackend, CompletionRequest, CompletionResponse } from './base.js';
export declare class GroqBackend extends BaseLLMBackend {
    private apiKey;
    constructor(apiKey?: string);
    complete(request: CompletionRequest): Promise<CompletionResponse>;
    listModels(): Promise<string[]>;
}
//# sourceMappingURL=groq.d.ts.map