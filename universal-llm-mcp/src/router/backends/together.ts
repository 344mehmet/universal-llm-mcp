/**
 * Universal LLM MCP - Together AI Backend
 * Open-source modellerin cloud versiyonları
 */

import { BaseLLMBackend, CompletionRequest, CompletionResponse } from './base.js';

export class TogetherBackend extends BaseLLMBackend {
    private apiKey: string;

    constructor(apiKey?: string) {
        super(
            'together',
            'https://api.together.xyz/v1',
            'meta-llama/Llama-3.3-70B-Instruct-Turbo',
            120000
        );
        this.apiKey = apiKey || process.env.TOGETHER_API_KEY || '';
    }

    async complete(request: CompletionRequest): Promise<CompletionResponse> {
        const model = request.model || 'meta-llama/Llama-3.3-70B-Instruct-Turbo';

        const body = {
            model,
            messages: request.messages.map(m => ({
                role: m.role,
                content: m.content,
            })),
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
            finishReason: response.choices[0]?.finish_reason,
        };
    }

    async listModels(): Promise<string[]> {
        return [
            'meta-llama/Llama-3.3-70B-Instruct-Turbo',
            'meta-llama/Meta-Llama-3.1-405B-Instruct-Turbo',
            'mistralai/Mixtral-8x22B-Instruct-v0.1',
            'Qwen/Qwen2.5-72B-Instruct-Turbo',
            'deepseek-ai/DeepSeek-V3',
            'google/gemma-2-27b-it',
        ];
    }
}
