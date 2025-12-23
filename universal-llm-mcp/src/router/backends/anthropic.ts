/**
 * Universal LLM MCP - Anthropic Claude Backend
 */

import { BaseLLMBackend, CompletionRequest, CompletionResponse } from './base.js';

export class AnthropicBackend extends BaseLLMBackend {
    private apiKey: string;

    constructor(apiKey?: string) {
        super(
            'anthropic',
            'https://api.anthropic.com/v1',
            'claude-3-5-sonnet-20241022',
            120000
        );
        this.apiKey = apiKey || process.env.ANTHROPIC_API_KEY || '';
    }

    async complete(request: CompletionRequest): Promise<CompletionResponse> {
        const model = request.model || 'claude-3-5-sonnet-20241022';

        const systemMsg = request.messages.find(m => m.role === 'system');
        const otherMsgs = request.messages.filter(m => m.role !== 'system');

        const body: any = {
            model,
            messages: otherMsgs.map(m => ({ role: m.role, content: m.content })),
            max_tokens: request.maxTokens ?? 4096,
        };

        if (systemMsg) body.system = systemMsg.content;

        const response = await this.httpRequest<any>('/messages', 'POST', body, {
            'x-api-key': this.apiKey,
            'anthropic-version': '2023-06-01',
        });

        return {
            content: response.content[0]?.text || '',
            model: response.model,
            tokensUsed: (response.usage?.input_tokens || 0) + (response.usage?.output_tokens || 0),
            finishReason: response.stop_reason,
        };
    }

    async listModels(): Promise<string[]> {
        return [
            'claude-3-5-sonnet-20241022',
            'claude-3-5-haiku-20241022',
            'claude-3-opus-20240229',
        ];
    }
}
