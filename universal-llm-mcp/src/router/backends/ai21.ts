/**
 * Universal LLM MCP - AI21 Labs Backend
 */

import { BaseLLMBackend, CompletionRequest, CompletionResponse } from './base.js';

export class AI21Backend extends BaseLLMBackend {
    private apiKey: string;

    constructor(apiKey?: string, model?: string) {
        super(
            'ai21',
            'https://api.ai21.com/studio/v1',
            model || 'j2-grande-chat',
            120000
        );
        this.apiKey = apiKey || process.env.AI21_API_KEY || '';
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
        return ['j2-grande-chat', 'j2-jumbo-chat', 'j2-light', 'j2-mid', 'j2-ultra'];
    }
}
