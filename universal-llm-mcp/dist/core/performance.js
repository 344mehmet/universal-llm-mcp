/**
 * Universal LLM MCP - Performans Optimizasyonları
 * Cache, paralel işleme, hızlı yanıt
 */
// Basit in-memory cache
export class FastCache {
    cache = new Map();
    ttlMs;
    constructor(ttlSeconds = 300) {
        this.ttlMs = ttlSeconds * 1000;
    }
    set(key, value) {
        this.cache.set(key, {
            value,
            expires: Date.now() + this.ttlMs,
        });
    }
    get(key) {
        const item = this.cache.get(key);
        if (!item)
            return undefined;
        if (Date.now() > item.expires) {
            this.cache.delete(key);
            return undefined;
        }
        return item.value;
    }
    has(key) {
        return this.get(key) !== undefined;
    }
    clear() {
        this.cache.clear();
    }
    size() {
        return this.cache.size;
    }
}
// Embedding cache - aynı metinler için tekrar hesaplama yapma
export const embeddingCache = new FastCache(600); // 10 dakika
// Sorgu sonuç cache
export const queryCache = new FastCache(60); // 1 dakika
/**
 * Paralel işleme yardımcısı
 */
export async function parallelMap(items, fn, concurrency = 3) {
    const results = [];
    const executing = [];
    for (const item of items) {
        const promise = fn(item).then(result => {
            results.push(result);
        });
        executing.push(promise);
        if (executing.length >= concurrency) {
            await Promise.race(executing);
            executing.splice(executing.findIndex(p => p === promise), 1);
        }
    }
    await Promise.all(executing);
    return results;
}
/**
 * Debounce - çok sık çağrıları engelle
 */
export function debounce(fn, delayMs) {
    let timeoutId = null;
    return (...args) => {
        if (timeoutId)
            clearTimeout(timeoutId);
        timeoutId = setTimeout(() => fn(...args), delayMs);
    };
}
/**
 * Hızlı hash fonksiyonu (cache key için)
 */
export function fastHash(text) {
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
export function withTimeout(promise, timeoutMs, errorMessage = 'Timeout') {
    return Promise.race([
        promise,
        new Promise((_, reject) => setTimeout(() => reject(new Error(errorMessage)), timeoutMs)),
    ]);
}
/**
 * Retry mekanizması
 */
export async function withRetry(fn, maxRetries = 2, delayMs = 500) {
    let lastError;
    for (let i = 0; i <= maxRetries; i++) {
        try {
            return await fn();
        }
        catch (error) {
            lastError = error;
            if (i < maxRetries) {
                await new Promise(resolve => setTimeout(resolve, delayMs));
            }
        }
    }
    throw lastError;
}
console.log('[Performance] Optimizasyon modülü yüklendi');
//# sourceMappingURL=performance.js.map