/**
 * Universal LLM MCP - Google Gemini Backend
 */

import { BaseLLMBackend, CompletionRequest, CompletionResponse } from './base.js';

export class GeminiBackend extends BaseLLMBackend {
    private apiKey: string;

    constructor(apiKey?: string) {
        super(
            'gemini',
            'https://generativelanguage.googleapis.com/v1beta',
            'gemini-1.5-flash',
            120000
        );
        this.apiKey = apiKey || process.env.GOOGLE_API_KEY || '';
    }

    async complete(request: CompletionRequest): Promise<CompletionResponse> {
        const model = request.model || 'gemini-1.5-flash';

        const contents = request.messages
            .filter(m => m.role !== 'system')
            .map(m => ({
                role: m.role === 'assistant' ? 'model' : 'user',
                parts: [{ text: m.content }],
            }));

        const systemInstruction = request.messages.find(m => m.role === 'system');

        const body: any = {
            contents,
            generationConfig: {
                temperature: request.temperature ?? 0.7,
                maxOutputTokens: request.maxTokens ?? 4096,
            },
        };

        if (systemInstruction) {
            body.systemInstruction = { parts: [{ text: systemInstruction.content }] };
        }

        const url = `/models/${model}:generateContent?key=${this.apiKey}`;
        const response = await this.httpRequest<any>(url, 'POST', body);

        return {
            content: response.candidates?.[0]?.content?.parts?.[0]?.text || '',
            model,
            tokensUsed: response.usageMetadata?.totalTokenCount,
            finishReason: response.candidates?.[0]?.finishReason,
        };
    }

    async listModels(): Promise<string[]> {
        return ['gemini-2.0-flash-exp', 'gemini-1.5-pro', 'gemini-1.5-flash'];
    }
}
