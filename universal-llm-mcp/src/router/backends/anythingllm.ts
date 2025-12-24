/**
 * Universal LLM MCP - AnythingLLM Backend
 * Yerel AnythingLLM sunucusuyla entegrasyon
 */

import { BaseLLMBackend, CompletionRequest, CompletionResponse, BackendStatus } from './base.js';

interface AnythingLLMResponse {
    textResponse: string;
    sources?: any[];
    error?: string;
}

/**
 * AnythingLLM Backend Sınıfı
 * Varsayılan port: 3001
 */
export class AnythingLLMBackend extends BaseLLMBackend {
    private apiKey: string;
    private workspaceSlug: string;

    constructor(
        url: string = 'http://127.0.0.1:3001',
        apiKey?: string,
        workspaceSlug: string = 'default',
        timeout: number = 120000
    ) {
        super('anythingllm', url, 'local', timeout);
        this.apiKey = apiKey || process.env.ANYTHINGLLM_API_KEY || '';
        this.workspaceSlug = workspaceSlug;
    }

    /**
     * AnythingLLM sağlık kontrolü
     */
    async checkHealth(): Promise<BackendStatus> {
        try {
            const response = await this.httpRequest<any>('/api/v1/auth', 'GET', undefined, {
                'Authorization': `Bearer ${this.apiKey}`,
            });

            return {
                isAvailable: response?.authenticated === true,
                models: ['local-rag'],
                currentModel: 'local-rag',
            };
        } catch (error) {
            return {
                isAvailable: false,
                models: [],
                error: `AnythingLLM bağlantı hatası: ${error}`,
            };
        }
    }

    /**
     * Mevcut workspace'leri listele
     */
    async listModels(): Promise<string[]> {
        try {
            const response = await this.httpRequest<any>('/api/v1/workspaces', 'GET', undefined, {
                'Authorization': `Bearer ${this.apiKey}`,
            });

            if (response?.workspaces) {
                return response.workspaces.map((ws: any) => ws.slug);
            }
            return ['default'];
        } catch (error) {
            console.error(`[AnythingLLM] Workspace listeleme hatası: ${error}`);
            return ['default'];
        }
    }

    /**
     * Chat tamamlama (RAG destekli)
     */
    async complete(request: CompletionRequest): Promise<CompletionResponse> {
        const workspace = request.model || this.workspaceSlug;

        // Son mesajı al
        const lastMessage = request.messages[request.messages.length - 1];

        const body = {
            message: lastMessage.content,
            mode: 'chat', // 'chat' veya 'query' (sadece RAG)
        };

        try {
            const url = `/api/v1/workspace/${workspace}/chat`;

            const response = await this.httpRequest<AnythingLLMResponse>(url, 'POST', body, {
                'Authorization': `Bearer ${this.apiKey}`,
                'Content-Type': 'application/json',
            });

            if (response.error) {
                throw new Error(response.error);
            }

            return {
                content: response.textResponse,
                model: workspace,
                tokensUsed: 0, // AnythingLLM token sayısı döndürmüyor
                finishReason: 'stop',
            };
        } catch (error) {
            throw new Error(`[AnythingLLM] Tamamlama hatası: ${error}`);
        }
    }

    /**
     * Belge yükle (RAG için)
     */
    async uploadDocument(workspace: string, content: string, filename: string): Promise<boolean> {
        try {
            const formData = new FormData();
            const blob = new Blob([content], { type: 'text/plain' });
            formData.append('file', blob, filename);

            const response = await fetch(`${this.url}/api/v1/workspace/${workspace}/upload`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                },
                body: formData,
            });

            return response.ok;
        } catch (error) {
            console.error(`[AnythingLLM] Belge yükleme hatası: ${error}`);
            return false;
        }
    }
}
