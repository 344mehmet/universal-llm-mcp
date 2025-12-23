/**
 * Universal LLM MCP - Google Gemini Backend
 */
import { BaseLLMBackend, CompletionRequest, CompletionResponse } from './base.js';
export declare class GeminiBackend extends BaseLLMBackend {
    private apiKey;
    constructor(apiKey?: string);
    complete(request: CompletionRequest): Promise<CompletionResponse>;
    listModels(): Promise<string[]>;
}
//# sourceMappingURL=gemini.d.ts.map