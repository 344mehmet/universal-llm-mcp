/**
 * Universal LLM MCP - Scaleway Backend
 */

import { BaseLLMBackend, CompletionRequest, CompletionResponse } from './base.js';

export class ScalewayBackend extends BaseLLMBackend {
    private apiKey: string;

    constructor(apiKey?: string, model?: string) {
        super(
            'scaleway',
            'https://api.scaleway.ai/v1',
            model || 'llama-3.1-70b-instruct',
            120000
        );
        this.apiKey = apiKey || process.env.SCALEWAY_API_KEY || '';
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
            'llama-3.1-70b-instruct',
            'mistral-7b-instruct-v0.3',
            'pixtral-12b-2409'
        ];
    }
}
