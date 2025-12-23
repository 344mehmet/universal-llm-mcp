/**
 * Universal LLM MCP - LM Studio Backend
 * LM Studio API bağlantısı
 */
import { BaseLLMBackend, } from './base.js';
/**
 * LM Studio Backend Sınıfı
 */
export class LMStudioBackend extends BaseLLMBackend {
    constructor(url, defaultModel = 'auto', timeout = 120000) {
        super('lmstudio', url, defaultModel, timeout);
    }
    /**
     * LM Studio sağlık kontrolü
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
                error: `LM Studio bağlantı hatası: ${error}`,
            };
        }
    }
    /**
     * Mevcut modelleri listele
     */
    async listModels() {
        try {
            const response = await this.httpRequest('/v1/models');
            return response.data.map((model) => model.id);
        }
        catch (error) {
            console.error(`[LM Studio] Model listeleme hatası: ${error}`);
            return [];
        }
    }
    /**
     * Chat tamamlama
     */
    async complete(request) {
        const model = request.model || this.defaultModel;
        const body = {
            model: model === 'auto' ? undefined : model,
            messages: request.messages,
            temperature: request.temperature ?? 0.7,
            max_tokens: request.maxTokens ?? 4096,
            stream: false,
        };
        try {
            const response = await this.httpRequest('/v1/chat/completions', 'POST', body);
            const choice = response.choices[0];
            return {
                content: choice.message.content,
                model: response.model,
                tokensUsed: response.usage?.total_tokens,
                finishReason: choice.finish_reason,
            };
        }
        catch (error) {
            throw new Error(`[LM Studio] Tamamlama hatası: ${error}`);
        }
    }
}
//# sourceMappingURL=lmstudio.js.map