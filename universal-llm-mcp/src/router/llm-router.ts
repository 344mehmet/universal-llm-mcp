/**
 * Universal LLM MCP - LLM Router
 * Görev tipine göre uygun backend'e yönlendirme
 */

import { getConfigManager, type BackendConfig } from '../config.js';
import { BaseLLMBackend, CompletionRequest, CompletionResponse, BackendStatus, ChatMessage } from './backends/base.js';
import { LMStudioBackend } from './backends/lmstudio.js';
import { OllamaBackend } from './backends/ollama.js';
import { GeminiBackend } from './backends/gemini.js';
import { GroqBackend } from './backends/groq.js';
import { OpenAIBackend } from './backends/openai.js';
import { AnthropicBackend } from './backends/anthropic.js';
import { MistralBackend } from './backends/mistral.js';
import { AnythingLLMBackend } from './backends/anythingllm.js';
import { DeepSeekBackend } from './backends/deepseek.js';
import { OpenRouterBackend } from './backends/openrouter.js';
import { TogetherBackend } from './backends/together.js';
import { CohereBackend } from './backends/cohere.js';

// Görev tipleri
export type TaskType = 'code' | 'chat' | 'translate' | 'file' | 'reasoning' | 'research' | 'creative' | 'rag' | 'default';

/**
 * LLM Router Sınıfı
 * Merkezi backend yönetimi ve yönlendirme
 */
export class LLMRouter {
    private backends: Map<string, BaseLLMBackend> = new Map();
    private backendStatus: Map<string, BackendStatus> = new Map();

    constructor() {
        this.initializeBackends();
    }

    /**
     * Backend'leri yapılandırmadan başlat
     */
    private initializeBackends(): void {
        const config = getConfigManager();
        const aktifBackendler = config.getAktifBackendler();

        for (const backendName of aktifBackendler) {
            const backendConfig = config.getBackend(backendName);
            if (backendConfig) {
                const backend = this.createBackend(backendName, backendConfig);
                if (backend) {
                    this.backends.set(backendName, backend);
                    console.log(`[Router] Backend yüklendi: ${backendName}`);
                }
            }
        }
    }

    /**
     * Backend instance oluştur
     */
    private createBackend(name: string, config: BackendConfig): BaseLLMBackend | null {
        switch (name) {
            case 'lmstudio':
                return new LMStudioBackend(config.url || 'http://localhost:1234', config.defaultModel, config.timeout);
            case 'ollama':
                return new OllamaBackend(config.url || 'http://localhost:11434', config.defaultModel, config.timeout);
            case 'gemini':
                return new GeminiBackend(config.apiKey);
            case 'groq':
                return new GroqBackend(config.apiKey);
            case 'openai':
                return new OpenAIBackend(config.apiKey, config.url);
            case 'anthropic':
                return new AnthropicBackend(config.apiKey);
            case 'mistral':
                return new MistralBackend(config.apiKey);
            case 'anythingllm':
                return new AnythingLLMBackend(config.url, config.apiKey, config.workspace, config.timeout);
            case 'deepseek':
                return new DeepSeekBackend(config.apiKey);
            case 'openrouter':
                return new OpenRouterBackend(config.apiKey);
            case 'together':
                return new TogetherBackend(config.apiKey);
            case 'cohere':
                return new CohereBackend(config.apiKey);
            default:
                console.warn(`[Router] Bilinmeyen backend: ${name}`);
                return null;
        }
    }

    /**
     * Tüm backend'lerin sağlık durumunu kontrol et
     */
    async checkAllBackends(): Promise<Map<string, BackendStatus>> {
        console.log('[Router] Backend sağlık kontrolü başlatılıyor...');

        for (const [name, backend] of this.backends) {
            try {
                const status = await backend.checkHealth();
                this.backendStatus.set(name, status);
                console.log(`[Router] ${name}: ${status.isAvailable ? 'Erişilebilir' : 'Erişilemez'}`);
            } catch (error) {
                this.backendStatus.set(name, {
                    isAvailable: false,
                    models: [],
                    error: String(error),
                });
            }
        }

        return this.backendStatus;
    }

    /**
     * Belirli bir backend'in durumunu al
     */
    getBackendStatus(name: string): BackendStatus | undefined {
        return this.backendStatus.get(name);
    }

    /**
     * Görev tipi için uygun backend'i seç
     */
    private selectBackend(taskType: TaskType): BaseLLMBackend | null {
        const config = getConfigManager();
        const preferredBackend = config.getBackendForTask(taskType);

        // Tercih edilen backend erişilebilir mi?
        const status = this.backendStatus.get(preferredBackend);
        if (status?.isAvailable && this.backends.has(preferredBackend)) {
            return this.backends.get(preferredBackend)!;
        }

        // Fallback: herhangi bir erişilebilir backend
        for (const [name, backend] of this.backends) {
            const backendStatus = this.backendStatus.get(name);
            if (backendStatus?.isAvailable) {
                console.log(`[Router] Fallback backend kullanılıyor: ${name}`);
                return backend;
            }
        }

        return null;
    }

    /**
     * Tamamlama isteği gönder
     */
    async complete(
        taskType: TaskType,
        mesaj: string,
        sistemPrompt?: string,
        options?: Partial<CompletionRequest>
    ): Promise<CompletionResponse> {
        const backend = this.selectBackend(taskType);

        if (!backend) {
            throw new Error('[Router] Erişilebilir backend bulunamadı!');
        }

        const config = getConfigManager();
        const varsayilanPrompt = config.getSystemPrompt();

        const messages: ChatMessage[] = [
            {
                role: 'system',
                content: sistemPrompt || varsayilanPrompt,
            },
            {
                role: 'user',
                content: mesaj,
            },
        ];

        const request: CompletionRequest = {
            messages,
            temperature: options?.temperature ?? 0.7,
            maxTokens: options?.maxTokens ?? 4096,
            model: options?.model,
            stream: false,
        };

        console.log(`[Router] İstek gönderiliyor: ${backend.getName()} (${taskType})`);

        try {
            const response = await backend.complete(request);
            return response;
        } catch (error) {
            // Fallback dene
            console.error(`[Router] ${backend.getName()} hatası, fallback deneniyor...`);

            for (const [name, altBackend] of this.backends) {
                if (name !== backend.getName()) {
                    const status = this.backendStatus.get(name);
                    if (status?.isAvailable) {
                        try {
                            return await altBackend.complete(request);
                        } catch {
                            continue;
                        }
                    }
                }
            }

            throw new Error(`[Router] Tüm backend'ler başarısız: ${error}`);
        }
    }

    /**
     * Belirli bir backend ile tamamlama
     */
    async completeWithBackend(
        backendName: string,
        mesaj: string,
        sistemPrompt?: string
    ): Promise<CompletionResponse> {
        const backend = this.backends.get(backendName);

        if (!backend) {
            throw new Error(`[Router] Backend bulunamadı: ${backendName}`);
        }

        const config = getConfigManager();
        const varsayilanPrompt = config.getSystemPrompt();

        const messages: ChatMessage[] = [
            { role: 'system', content: sistemPrompt || varsayilanPrompt },
            { role: 'user', content: mesaj },
        ];

        const request: CompletionRequest = {
            messages,
            temperature: 0.7,
            maxTokens: 16384,
            stream: false,
        };

        console.log(`[Router] Direkt istek: ${backendName}`);
        return backend.complete(request);
    }

    /**
     * Mevcut modelleri listele
     */
    async listAllModels(): Promise<Record<string, string[]>> {
        const result: Record<string, string[]> = {};

        for (const [name, backend] of this.backends) {
            try {
                const models = await backend.listModels();
                result[name] = models;
            } catch {
                result[name] = [];
            }
        }

        return result;
    }

    /**
     * Yeni backend ekle (çalışma zamanında)
     */
    addBackend(name: string, backend: BaseLLMBackend): void {
        this.backends.set(name, backend);
        console.log(`[Router] Yeni backend eklendi: ${name}`);
    }

    /**
     * Backend kaldır
     */
    removeBackend(name: string): boolean {
        const removed = this.backends.delete(name);
        if (removed) {
            this.backendStatus.delete(name);
            console.log(`[Router] Backend kaldırıldı: ${name}`);
        }
        return removed;
    }
}

// Singleton instance
let routerInstance: LLMRouter | null = null;

/**
 * Router instance'ını al
 */
export function getRouter(): LLMRouter {
    if (!routerInstance) {
        routerInstance = new LLMRouter();
    }
    return routerInstance;
}
