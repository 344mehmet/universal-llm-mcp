/**
 * Universal LLM MCP - Akilli Embedding Service
 * Multi-backend failover destegi ile embedding uretici
 * CACHE ve hiz optimizasyonlari dahil
 */

import { getConfigManager, type BackendConfig } from '../config.js';
import { FastCache, fastHash } from '../core/performance.js';

// Embedding yanıtı
export interface EmbeddingResponse {
    embedding: number[];
    model: string;
    tokensUsed?: number;
    backend?: string;
}

// Backend durumu
interface BackendHealth {
    name: string;
    available: boolean;
    lastCheck: Date;
    failCount: number;
}

// LM Studio embedding yanıtı (OpenAI uyumlu)
interface LMStudioEmbeddingResponse {
    data: Array<{
        embedding: number[];
        index: number;
    }>;
    model: string;
    usage?: {
        prompt_tokens: number;
        total_tokens: number;
    };
}

// Ollama embedding yanıtı
interface OllamaEmbeddingResponse {
    embedding: number[];
}

/**
 * Akıllı Embedding Servisi
 * Otomatik failover: lmstudio → ollama → basit hash
 */
export class EmbeddingService {
    private backendPriority: ('lmstudio' | 'ollama')[] = ['ollama', 'lmstudio'];
    private backendHealth: Map<string, BackendHealth> = new Map();
    private backendConfigs: Map<string, { url: string; model: string; timeout: number }> = new Map();
    private useFallbackHash: boolean = true;
    private embeddingDimension: number = 384;
    private cache = new FastCache<number[]>(600); // 10 dakika cache

    constructor() {
        const config = getConfigManager();
        const ragConfig = config.getConfig().rag;

        // Öncelik sırasını ayarla
        if (ragConfig?.embeddingBackend) {
            const primary = ragConfig.embeddingBackend as 'lmstudio' | 'ollama';
            this.backendPriority = primary === 'lmstudio'
                ? ['lmstudio', 'ollama']
                : ['ollama', 'lmstudio'];
        }

        // Backend yapılandırmalarını yükle
        for (const backend of this.backendPriority) {
            const backendConfig = config.getBackend(backend);
            if (backendConfig) {
                const defaultUrl = backend === 'lmstudio'
                    ? 'http://localhost:1234'
                    : 'http://localhost:11434';
                this.backendConfigs.set(backend, {
                    url: backendConfig.url || defaultUrl,
                    model: backendConfig.defaultModel,
                    timeout: backendConfig.timeout,
                });
            } else {
                // Varsayılan değerler
                const defaultUrl = backend === 'lmstudio'
                    ? 'http://localhost:1234'
                    : 'http://localhost:11434';
                this.backendConfigs.set(backend, {
                    url: defaultUrl,
                    model: 'auto',
                    timeout: 60000,
                });
            }

            // Healthcheck başlat
            this.backendHealth.set(backend, {
                name: backend,
                available: true, // Başlangıçta true
                lastCheck: new Date(0),
                failCount: 0,
            });
        }

        console.log(`[EmbeddingService] Akıllı mod aktif. Öncelik: ${this.backendPriority.join(' → ')}`);
    }

    /**
     * Akilli embedding - cache + otomatik failover
     */
    public async embed(text: string): Promise<EmbeddingResponse> {
        // Cache kontrol
        const cacheKey = fastHash(text);
        const cached = this.cache.get(cacheKey);
        if (cached) {
            return { embedding: cached, model: 'cache', backend: 'cache' };
        }

        // Sirayla backend'leri dene
        for (const backend of this.backendPriority) {
            const health = this.backendHealth.get(backend);

            // Çok başarısız olmuşsa atla (kısa süreli)
            if (health && health.failCount > 3) {
                const timeSinceCheck = Date.now() - health.lastCheck.getTime();
                if (timeSinceCheck < 30000) { // 30 saniye bekleme
                    continue;
                }
                // Reset ve tekrar dene
                health.failCount = 0;
            }

            try {
                const result = await this.embedWithBackend(backend, text);

                // Başarılı - health güncelle
                if (health) {
                    health.available = true;
                    health.failCount = 0;
                    health.lastCheck = new Date();
                }

                return { ...result, backend };
            } catch (error) {
                console.warn(`[EmbeddingService] ${backend} hatasi:`, error);

                // Fail count artır
                if (health) {
                    health.available = false;
                    health.failCount++;
                    health.lastCheck = new Date();
                }
            }
        }

        // Tüm backend'ler başarısız - hash fallback
        if (this.useFallbackHash) {
            console.log('[EmbeddingService] Tüm backend\'ler başarısız, hash fallback kullanılıyor');
            return this.hashFallback(text);
        }

        throw new Error('Hiçbir embedding backend erişilebilir değil');
    }

    /**
     * Belirli backend ile embedding
     */
    private async embedWithBackend(backend: 'lmstudio' | 'ollama', text: string): Promise<EmbeddingResponse> {
        if (backend === 'lmstudio') {
            return this.embedWithLMStudio(text);
        } else {
            return this.embedWithOllama(text);
        }
    }

    /**
     * Basit hash tabanlı "embedding" - fallback
     * Not: Bu gerçek semantik embedding değil, sadece acil durum için
     */
    private hashFallback(text: string): EmbeddingResponse {
        const embedding = new Array(this.embeddingDimension).fill(0);

        // Basit hash fonksiyonu
        const normalized = text.toLowerCase().trim();
        for (let i = 0; i < normalized.length; i++) {
            const charCode = normalized.charCodeAt(i);
            const index = (charCode * (i + 1)) % this.embeddingDimension;
            embedding[index] += 1 / (normalized.length + 1);
        }

        // Normalize et
        const magnitude = Math.sqrt(embedding.reduce((sum, val) => sum + val * val, 0));
        if (magnitude > 0) {
            for (let i = 0; i < embedding.length; i++) {
                embedding[i] /= magnitude;
            }
        }

        return {
            embedding,
            model: 'hash-fallback',
            backend: 'fallback',
        };
    }

    /**
     * Toplu embedding üretimi
     */
    public async embedBatch(texts: string[]): Promise<EmbeddingResponse[]> {
        const promises = texts.map(text => this.embed(text));
        return Promise.all(promises);
    }

    /**
     * LM Studio ile embedding (OpenAI uyumlu /v1/embeddings)
     */
    private async embedWithLMStudio(text: string): Promise<EmbeddingResponse> {
        const config = this.backendConfigs.get('lmstudio')!;
        const endpoint = `${config.url}/v1/embeddings`;

        const body = {
            input: text,
            model: config.model === 'auto' ? undefined : config.model,
        };

        const response = await this.httpRequest<LMStudioEmbeddingResponse>(endpoint, body, config.timeout);

        return {
            embedding: response.data[0].embedding,
            model: response.model,
            tokensUsed: response.usage?.total_tokens,
        };
    }

    /**
     * Ollama ile embedding (/api/embeddings)
     */
    private async embedWithOllama(text: string): Promise<EmbeddingResponse> {
        const config = this.backendConfigs.get('ollama')!;
        const endpoint = `${config.url}/api/embeddings`;

        const body = {
            model: config.model,
            prompt: text,
        };

        const response = await this.httpRequest<OllamaEmbeddingResponse>(endpoint, body, config.timeout);

        return {
            embedding: response.embedding,
            model: config.model,
        };
    }

    /**
     * HTTP request helper
     */
    private async httpRequest<T>(url: string, body: unknown, timeout: number): Promise<T> {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), timeout);

        try {
            const response = await fetch(url, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(body),
                signal: controller.signal,
            });

            if (!response.ok) {
                throw new Error(`HTTP ${response.status}: ${response.statusText}`);
            }

            return await response.json() as T;
        } finally {
            clearTimeout(timeoutId);
        }
    }

    /**
     * Backend önceliğini değiştir
     */
    public setPriority(priority: ('lmstudio' | 'ollama')[]): void {
        this.backendPriority = priority;
        console.log(`[EmbeddingService] Öncelik değiştirildi: ${priority.join(' → ')}`);
    }

    /**
     * Backend durumlarını al
     */
    public getHealthStatus(): Record<string, { available: boolean; failCount: number }> {
        const result: Record<string, { available: boolean; failCount: number }> = {};
        for (const [name, health] of this.backendHealth) {
            result[name] = {
                available: health.available,
                failCount: health.failCount,
            };
        }
        return result;
    }

    /**
     * Fallback hash'i etkinleştir/devre dışı bırak
     */
    public setFallbackHash(enabled: boolean): void {
        this.useFallbackHash = enabled;
    }

    /**
     * Mevcut bilgiler
     */
    public getInfo(): { priority: string[]; health: Record<string, any> } {
        return {
            priority: this.backendPriority,
            health: this.getHealthStatus(),
        };
    }
}

// Singleton instance
let embeddingServiceInstance: EmbeddingService | null = null;

/**
 * EmbeddingService singleton instance al
 */
export function getEmbeddingService(): EmbeddingService {
    if (!embeddingServiceInstance) {
        embeddingServiceInstance = new EmbeddingService();
    }
    return embeddingServiceInstance;
}

