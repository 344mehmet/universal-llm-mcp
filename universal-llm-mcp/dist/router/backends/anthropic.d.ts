/**
 * Universal LLM MCP - Anthropic Claude Backend
 */
import { BaseLLMBackend, CompletionRequest, CompletionResponse } from './base.js';
export declare class AnthropicBackend extends BaseLLMBackend {
    private apiKey;
    constructor(apiKey?: string);
    complete(request: CompletionRequest): Promise<CompletionResponse>;
    listModels(): Promise<string[]>;
}
//# sourceMappingURL=anthropic.d.ts.map