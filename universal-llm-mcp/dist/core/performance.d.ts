/**
 * Universal LLM MCP - Performans Optimizasyonları
 * Cache, paralel işleme, hızlı yanıt
 */
export declare class FastCache<T> {
    private cache;
    private ttlMs;
    constructor(ttlSeconds?: number);
    set(key: string, value: T): void;
    get(key: string): T | undefined;
    has(key: string): boolean;
    clear(): void;
    size(): number;
}
export declare const embeddingCache: FastCache<number[]>;
export declare const queryCache: FastCache<any>;
/**
 * Paralel işleme yardımcısı
 */
export declare function parallelMap<T, R>(items: T[], fn: (item: T) => Promise<R>, concurrency?: number): Promise<R[]>;
/**
 * Debounce - çok sık çağrıları engelle
 */
export declare function debounce<T extends (...args: any[]) => any>(fn: T, delayMs: number): (...args: Parameters<T>) => void;
/**
 * Hızlı hash fonksiyonu (cache key için)
 */
export declare function fastHash(text: string): string;
/**
 * Timeout ile promise
 */
export declare function withTimeout<T>(promise: Promise<T>, timeoutMs: number, errorMessage?: string): Promise<T>;
/**
 * Retry mekanizması
 */
export declare function withRetry<T>(fn: () => Promise<T>, maxRetries?: number, delayMs?: number): Promise<T>;
//# sourceMappingURL=performance.d.ts.map