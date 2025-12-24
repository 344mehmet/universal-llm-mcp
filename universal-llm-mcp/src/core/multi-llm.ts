/**
 * Universal LLM MCP - Çoklu LLM Sorgulama
 * Tüm LLM'lere aynı soruyu sor, her birinin yanıtını göster
 */

import { getRouter } from '../router/llm-router.js';

export interface MultiLLMResponse {
    backend: string;
    model: string;
    answer: string;
    latencyMs: number;
    success: boolean;
    error?: string;
}

export interface MultiQueryResult {
    question: string;
    responses: MultiLLMResponse[];
    totalLatency: number;
    timestamp: Date;
}

/**
 * Tüm LLM'lere aynı soruyu sor
 */
export async function queryAllLLMs(question: string, systemPrompt?: string): Promise<MultiQueryResult> {
    const router = getRouter();
    const backends = [
        'lmstudio', 'ollama', 'gemini', 'groq',
        'openai', 'anthropic', 'mistral', 'deepseek',
        'openrouter', 'together', 'cohere', 'huggingface',
        'nvidia', 'scaleway', 'xai', 'fireworks',
        'sambanova', 'novita', 'hyperbolic', 'ai21'
    ];
    const startTime = Date.now();
    const responses: MultiLLMResponse[] = [];

    console.log(`[MultiLLM] Soru: "${question.substring(0, 50)}..."`);

    // Paralel olarak tüm backend'lere sor
    const promises = backends.map(async (backend) => {
        const backendStart = Date.now();
        try {
            const response = await router.completeWithBackend(
                backend,
                question,
                systemPrompt || 'Sen yardimci bir asistansin. Detayli ve kapsamli yanit ver. Sinir yok.'
            );

            return {
                backend,
                model: response.model || backend,
                answer: response.content,
                latencyMs: Date.now() - backendStart,
                success: true,
            };
        } catch (error) {
            console.error(`[MultiLLM] ${backend} hatası:`, error);
            return {
                backend,
                model: backend,
                answer: '',
                latencyMs: Date.now() - backendStart,
                success: false,
                error: String(error),
            };
        }
    });

    const results = await Promise.allSettled(promises);

    for (const result of results) {
        if (result.status === 'fulfilled') {
            responses.push(result.value);
        }
    }

    const totalLatency = Date.now() - startTime;
    console.log(`[MultiLLM] ${responses.filter(r => r.success).length}/${backends.length} backend yanıt verdi (${totalLatency}ms)`);

    return {
        question,
        responses,
        totalLatency,
        timestamp: new Date(),
    };
}
