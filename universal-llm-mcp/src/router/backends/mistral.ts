/**
 * Universal LLM MCP - Mistral AI Backend
 */

import { BaseLLMBackend, CompletionRequest, CompletionResponse } from './base.js';

export class MistralBackend extends BaseLLMBackend {
    private apiKey: string;

    constructor(apiKey?: string) {
        super('mistral', 'https://api.mistral.ai/v1', 'mistral-large-latest', 120000);
        this.apiKey = apiKey || process.env.MISTRAL_API_KEY || '';
    }

    async complete(request: CompletionRequest): Promise<CompletionResponse> {
        const model = request.model || 'mistral-large-latest';

        const body = {
            model,
            messages: request.messages.map(m => ({ role: m.role, content: m.content })),
            temperature: request.temperature ?? 0.7,
            max_tokens: request.maxTokens ?? 4096,
        };

        const response = await this.httpRequest<any>('/chat/completions', 'POST', body, {
            'Authorization': `Bearer ${this.apiKey}`,
        });

        return {
            content: response.choices[0]?.message?.content || '',
            model: response.model,
            tokensUsed: response.usage?.total_tokens,
        };
    }

    async listModels(): Promise<string[]> {
        return ['mistral-large-latest', 'mistral-medium-latest', 'codestral-latest'];
    }
}
