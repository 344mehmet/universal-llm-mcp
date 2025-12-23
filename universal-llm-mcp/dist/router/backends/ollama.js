/**
 * Universal LLM MCP - Ollama Backend
 * Ollama API bağlantısı
 */
import { BaseLLMBackend, } from './base.js';
/**
 * Ollama Backend Sınıfı
 */
export class OllamaBackend extends BaseLLMBackend {
    constructor(url, defaultModel = 'llama3', timeout = 120000) {
        super('ollama', url, defaultModel, timeout);
    }
    /**
     * Ollama sağlık kontrolü
     */
    async checkHealth() {
        try {
            const models = await this.listModels();
            return {
                isAvailable: true,
                models,
                currentModel: models.length > 0 ? models[0] : undefined,
            };
        }
        catch (error) {
            return {
                isAvailable: false,
                models: [],
                error: `Ollama bağlantı hatası: ${error}`,
            };
        }
    }
    /**
     * Mevcut modelleri listele
     */
    async listModels() {
        try {
            const response = await this.httpRequest('/api/tags');
            return response.models.map((model) => model.name);
        }
        catch (error) {
            console.error(`[Ollama] Model listeleme hatası: ${error}`);
            return [];
        }
    }
    /**
     * Chat tamamlama
     */
    async complete(request) {
        const model = request.model || this.defaultModel;
        // Ollama formatına dönüştür
        const ollamaMessages = request.messages.map((msg) => ({
            role: msg.role,
            content: msg.content,
        }));
        const body = {
            model,
            messages: ollamaMessages,
            stream: false,
            options: {
                temperature: request.temperature ?? 0.7,
                num_predict: request.maxTokens ?? 4096,
            },
        };
        try {
            const response = await this.httpRequest('/api/chat', 'POST', body);
            return {
                content: response.message.content,
                model: response.model,
                tokensUsed: (response.eval_count || 0) + (response.prompt_eval_count || 0),
                finishReason: response.done ? 'stop' : 'length',
            };
        }
        catch (error) {
            throw new Error(`[Ollama] Tamamlama hatası: ${error}`);
        }
    }
}
//# sourceMappingURL=ollama.js.map