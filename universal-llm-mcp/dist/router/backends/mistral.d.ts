/**
 * Universal LLM MCP - Mistral AI Backend
 */
import { BaseLLMBackend, CompletionRequest, CompletionResponse } from './base.js';
export declare class MistralBackend extends BaseLLMBackend {
    private apiKey;
    constructor(apiKey?: string);
    complete(request: CompletionRequest): Promise<CompletionResponse>;
    listModels(): Promise<string[]>;
}
//# sourceMappingURL=mistral.d.ts.map