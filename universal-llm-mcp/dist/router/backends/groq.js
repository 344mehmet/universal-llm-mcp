/**
 * Universal LLM MCP - Groq Backend (Hızlı inference)
 */
import { BaseLLMBackend } from './base.js';
export class GroqBackend extends BaseLLMBackend {
    apiKey;
    constructor(apiKey) {
        super('groq', 'https://api.groq.com/openai/v1', 'llama-3.3-70b-versatile', 60000);
        this.apiKey = apiKey || process.env.GROQ_API_KEY || '';
    }
    async complete(request) {
        const model = request.model || 'llama-3.3-70b-versatile';
        const body = {
            model,
            messages: request.messages.map(m => ({ role: m.role, content: m.content })),
            temperature: request.temperature ?? 0.7,
            max_tokens: request.maxTokens ?? 4096,
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
    async listModels() {
        return ['llama-3.3-70b-versatile', 'llama-3.1-8b-instant', 'mixtral-8x7b-32768'];
    }
}
//# sourceMappingURL=groq.js.map