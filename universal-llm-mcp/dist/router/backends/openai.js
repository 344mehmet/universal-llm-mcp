/**
 * Universal LLM MCP - OpenAI Backend
 * GPT-4, GPT-4V, GPT-3.5 desteği
 */
import { BaseLLMBackend } from './base.js';
export class OpenAIBackend extends BaseLLMBackend {
    apiKey;
    constructor(apiKey, baseUrl) {
        super('openai', baseUrl || 'https://api.openai.com/v1', 'gpt-4o-mini', 120000);
        this.apiKey = apiKey || process.env.OPENAI_API_KEY || '';
    }
    async complete(request) {
        const model = request.model || 'gpt-4o-mini';
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
        const response = await this.httpRequest('/chat/completions', 'POST', body, {
            'Authorization': `Bearer ${this.apiKey}`,
        });
        return {
            content: response.choices[0]?.message?.content || '',
            model: response.model,
            tokensUsed: response.usage?.total_tokens,
            finishReason: response.choices[0]?.finish_reason,
        };
    }
    async listModels() {
        if (!this.apiKey)
            return [];
        try {
            const response = await this.httpRequest('/models', 'GET', undefined, {
                'Authorization': `Bearer ${this.apiKey}`,
            });
            return response.data
                .filter((m) => m.id.includes('gpt'))
                .map((m) => m.id);
        }
        catch {
            return ['gpt-4o', 'gpt-4o-mini', 'gpt-4-turbo', 'gpt-3.5-turbo'];
        }
    }
    /**
     * Vision destekli completion (görsel + metin)
     */
    async completeWithVision(messages, imageUrl, model = 'gpt-4o') {
        const visionMessages = messages.map(m => {
            if (m.role === 'user') {
                return {
                    role: 'user',
                    content: [
                        { type: 'text', text: m.content },
                        { type: 'image_url', image_url: { url: imageUrl } },
                    ],
                };
            }
            return { role: m.role, content: m.content };
        });
        const body = {
            model,
            messages: visionMessages,
            max_tokens: 4096,
        };
        const response = await this.httpRequest('/chat/completions', 'POST', body, {
            'Authorization': `Bearer ${this.apiKey}`,
        });
        return {
            content: response.choices[0]?.message?.content || '',
            model: response.model,
            tokensUsed: response.usage?.total_tokens,
        };
    }
}
//# sourceMappingURL=openai.js.map