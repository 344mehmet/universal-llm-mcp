/**
 * Universal LLM MCP - OpenAI Backend
 * GPT-4, GPT-4V, GPT-3.5 desteği
 */
import { BaseLLMBackend, CompletionRequest, CompletionResponse, ChatMessage } from './base.js';
export declare class OpenAIBackend extends BaseLLMBackend {
    private apiKey;
    constructor(apiKey?: string, baseUrl?: string);
    complete(request: CompletionRequest): Promise<CompletionResponse>;
    listModels(): Promise<string[]>;
    /**
     * Vision destekli completion (görsel + metin)
     */
    completeWithVision(messages: ChatMessage[], imageUrl: string, model?: string): Promise<CompletionResponse>;
}
//# sourceMappingURL=openai.d.ts.map