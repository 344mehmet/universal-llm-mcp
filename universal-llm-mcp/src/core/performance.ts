/**
 * Universal LLM MCP - Performans Optimizasyonları
 * Cache, paralel işleme, hızlı yanıt
 */

// Basit in-memory cache
export class FastCache<T> {
    private cache = new Map<string, { value: T; expires: number }>();
    private ttlMs: number;

    constructor(ttlSeconds: number = 300) {
        this.ttlMs = ttlSeconds * 1000;
    }

    set(key: string, value: T): void {
        this.cache.set(key, {
            value,
            expires: Date.now() + this.ttlMs,
        });
    }

    get(key: string): T | undefined {
        const item = this.cache.get(key);
        if (!item) return undefined;

        if (Date.now() > item.expires) {
            this.cache.delete(key);
            return undefined;
        }

        return item.value;
    }

    has(key: string): boolean {
        return this.get(key) !== undefined;
    }

    clear(): void {
        this.cache.clear();
    }

    size(): number {
        return this.cache.size;
    }
}

// Embedding cache - aynı metinler için tekrar hesaplama yapma
export const embeddingCache = new FastCache<number[]>(600); // 10 dakika

// Sorgu sonuç cache
export const queryCache = new FastCache<any>(60); // 1 dakika

/**
 * Paralel işleme yardımcısı
 */
export async function parallelMap<T, R>(
    items: T[],
    fn: (item: T) => Promise<R>,
    concurrency: number = 3
): Promise<R[]> {
    const results: R[] = [];
    const executing: Promise<void>[] = [];

    for (const item of items) {
        const promise = fn(item).then(result => {
            results.push(result);
        });

        executing.push(promise);

        if (executing.length >= concurrency) {
            await Promise.race(executing);
            executing.splice(
                executing.findIndex(p => p === promise),
                1
            );
        }
    }

    await Promise.all(executing);
    return results;
}

/**
 * Debounce - çok sık çağrıları engelle
 */
export function debounce<T extends (...args: any[]) => any>(
    fn: T,
    delayMs: number
): (...args: Parameters<T>) => void {
    let timeoutId: NodeJS.Timeout | null = null;

    return (...args: Parameters<T>) => {
        if (timeoutId) clearTimeout(timeoutId);
        timeoutId = setTimeout(() => fn(...args), delayMs);
    };
}

/**
 * Hızlı hash fonksiyonu (cache key için)
 */
export function fastHash(text: string): string {
    let hash = 0;
    for (let i = 0; i < text.length; i++) {
        const char = text.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash = hash & hash; // 32bit integer
    }
    return hash.toString(36);
}

/**
 * Timeout ile promise
 */
export function withTimeout<T>(
    promise: Promise<T>,
    timeoutMs: number,
    errorMessage: string = 'Timeout'
): Promise<T> {
    return Promise.race([
        promise,
        new Promise<T>((_, reject) =>
            setTimeout(() => reject(new Error(errorMessage)), timeoutMs)
        ),
    ]);
}

/**
 * Retry mekanizması
 */
export async function withRetry<T>(
    fn: () => Promise<T>,
    maxRetries: number = 2,
    delayMs: number = 500
): Promise<T> {
    let lastError: Error | undefined;

    for (let i = 0; i <= maxRetries; i++) {
        try {
            return await fn();
        } catch (error) {
            lastError = error as Error;
            if (i < maxRetries) {
                await new Promise(resolve => setTimeout(resolve, delayMs));
            }
        }
    }

    throw lastError;
}

console.log('[Performance] Optimizasyon modülü yüklendi');
