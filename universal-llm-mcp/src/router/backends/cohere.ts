/**
 * Universal LLM MCP - Cohere Backend
 * Command modelleri - İyi doküman anlama ve summarization
 */

import { BaseLLMBackend, CompletionRequest, CompletionResponse } from './base.js';

export class CohereBackend extends BaseLLMBackend {
    private apiKey: string;

    constructor(apiKey?: string) {
        super(
            'cohere',
            'https://api.cohere.ai/v1',
            'command-r-plus',
            120000
        );
        this.apiKey = apiKey || process.env.COHERE_API_KEY || '';
    }

    async complete(request: CompletionRequest): Promise<CompletionResponse> {
        const model = request.model || 'command-r-plus';

        // Cohere farklı API formatı kullanıyor
        const systemMsg = request.messages.find(m => m.role === 'system');
        const userMsgs = request.messages.filter(m => m.role !== 'system');
        const lastMsg = userMsgs[userMsgs.length - 1];

        const body: any = {
            model,
            message: lastMsg.content,
            temperature: request.temperature ?? 0.7,
            max_tokens: request.maxTokens ?? 4096,
        };

        if (systemMsg) {
            body.preamble = systemMsg.content;
        }

        // Chat history (son mesaj hariç)
        if (userMsgs.length > 1) {
            body.chat_history = userMsgs.slice(0, -1).map(m => ({
                role: m.role === 'user' ? 'USER' : 'CHATBOT',
                message: m.content,
            }));
        }

        const response = await this.httpRequest<any>('/chat', 'POST', body, {
            'Authorization': `Bearer ${this.apiKey}`,
        });

        return {
            content: response.text || '',
            model: model,
            tokensUsed: (response.meta?.tokens?.input_tokens || 0) + (response.meta?.tokens?.output_tokens || 0),
            finishReason: response.finish_reason,
        };
    }

    async listModels(): Promise<string[]> {
        return [
            'command-r-plus',
            'command-r',
            'command',
            'command-light',
        ];
    }
}
