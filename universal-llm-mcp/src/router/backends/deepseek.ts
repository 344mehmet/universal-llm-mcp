/**
 * Universal LLM MCP - DeepSeek Backend
 * DeepSeek V3, DeepSeek Coder desteği
 */

import { BaseLLMBackend, CompletionRequest, CompletionResponse } from './base.js';

export class DeepSeekBackend extends BaseLLMBackend {
    private apiKey: string;

    constructor(apiKey?: string) {
        super(
            'deepseek',
            'https://api.deepseek.com/v1',
            'deepseek-chat',
            120000
        );
        this.apiKey = apiKey || process.env.DEEPSEEK_API_KEY || '';
    }

    async complete(request: CompletionRequest): Promise<CompletionResponse> {
        const model = request.model || 'deepseek-chat';

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
            'deepseek-chat',
            'deepseek-coder',
            'deepseek-reasoner'
        ];
    }
}
