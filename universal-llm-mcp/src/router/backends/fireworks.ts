/**
 * Universal LLM MCP - Fireworks AI Backend
 */

import { BaseLLMBackend, CompletionRequest, CompletionResponse } from './base.js';

export class FireworksBackend extends BaseLLMBackend {
    private apiKey: string;

    constructor(apiKey?: string, model?: string) {
        super(
            'fireworks',
            'https://api.fireworks.ai/inference/v1',
            model || 'accounts/fireworks/models/llama-v3p1-70b-instruct',
            120000
        );
        this.apiKey = apiKey || process.env.FIREWORKS_API_KEY || '';
    }

    async complete(request: CompletionRequest): Promise<CompletionResponse> {
        const model = request.model || this.defaultModel;

        const body = {
            model,
            messages: request.messages.map(m => ({
                role: m.role,
                content: m.content,
            })),
            temperature: request.temperature ?? 0.7,
            max_tokens: request.maxTokens ?? 4096,
            stream: false,
        };

        const response = await this.httpRequest<any>('/chat/completions', 'POST', body, {
            'Authorization': `Bearer ${this.apiKey}`,
        });

        return {
            content: response.choices[0]?.message?.content || '',
            model: response.model,
            tokensUsed: response.usage?.total_tokens,
            finishReason: response.choices[0]?.finish_reason,
        };
    }

    async listModels(): Promise<string[]> {
        return [
            'accounts/fireworks/models/llama-v3p1-70b-instruct',
            'accounts/fireworks/models/llama-v3p1-8b-instruct',
            'accounts/fireworks/models/mixtral-8x7b-instruct'
        ];
    }
}
