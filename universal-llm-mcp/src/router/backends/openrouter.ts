/**
 * Universal LLM MCP - OpenRouter Backend
 * 100+ model tek API altında: GPT-4, Claude, Gemini, Llama, Mistral vb.
 */

import { BaseLLMBackend, CompletionRequest, CompletionResponse } from './base.js';

export class OpenRouterBackend extends BaseLLMBackend {
    private apiKey: string;

    constructor(apiKey?: string) {
        super(
            'openrouter',
            'https://openrouter.ai/api/v1',
            'openai/gpt-4o-mini',
            120000
        );
        this.apiKey = apiKey || process.env.OPENROUTER_API_KEY || '';
    }

    async complete(request: CompletionRequest): Promise<CompletionResponse> {
        const model = request.model || 'openai/gpt-4o-mini';

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
            'HTTP-Referer': 'https://universal-llm-mcp.local',
            'X-Title': 'Universal LLM MCP',
        });

        return {
            content: response.choices[0]?.message?.content || '',
            model: response.model,
            tokensUsed: response.usage?.total_tokens,
            finishReason: response.choices[0]?.finish_reason,
        };
    }

    async listModels(): Promise<string[]> {
        // Ücretsiz ve popüler modeller
        return [
            // Ücretsiz modeller
            'google/gemma-2-9b-it:free',
            'meta-llama/llama-3.2-3b-instruct:free',
            'mistralai/mistral-7b-instruct:free',
            'qwen/qwen-2-7b-instruct:free',
            // Popüler ücretli modeller
            'openai/gpt-4o',
            'openai/gpt-4o-mini',
            'anthropic/claude-3.5-sonnet',
            'google/gemini-2.0-flash-exp:free',
            'google/gemini-pro-1.5',
            'meta-llama/llama-3.3-70b-instruct',
            'deepseek/deepseek-chat',
            'mistralai/mistral-large',
        ];
    }
}
