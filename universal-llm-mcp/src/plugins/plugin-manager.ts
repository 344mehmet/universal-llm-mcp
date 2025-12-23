/**
 * Universal LLM MCP - Plugin Manager
 * Genişletilebilir eklenti sistemi
 */

import { EventEmitter } from 'events';
import { getRouter } from '../router/llm-router.js';
import { getRAGService } from '../rag/rag-service.js';

// Plugin arayüzü
export interface Plugin {
    name: string;
    version: string;
    description?: string;

    // Lifecycle hooks
    onLoad?: () => Promise<void> | void;
    onUnload?: () => Promise<void> | void;

    // Query hooks
    onQueryBefore?: (query: QueryContext) => Promise<QueryContext> | QueryContext;
    onQueryAfter?: (query: QueryContext, result: QueryResult) => Promise<QueryResult> | QueryResult;

    // RAG hooks
    onDocumentAdd?: (text: string, source: string) => Promise<string> | string;
    onSearchResults?: (results: any[]) => Promise<any[]> | any[];
}

// Sorgu bağlamı
export interface QueryContext {
    question: string;
    category?: string;
    topK?: number;
    metadata?: Record<string, any>;
}

// Sorgu sonucu
export interface QueryResult {
    answer: string;
    sources: string[];
    confidence?: number;
    metadata?: Record<string, any>;
}

// Plugin durumu
interface PluginState {
    plugin: Plugin;
    enabled: boolean;
    loadedAt: Date;
}

/**
 * Plugin Manager
 * Dinamik eklenti yükleme ve yönetimi
 */
export class PluginManager extends EventEmitter {
    private plugins: Map<string, PluginState> = new Map();

    constructor() {
        super();
        console.log('[PluginManager] Başlatıldı');
    }

    /**
     * Plugin yükle
     */
    public async register(plugin: Plugin): Promise<boolean> {
        if (this.plugins.has(plugin.name)) {
            console.warn(`[PluginManager] Plugin zaten yüklü: ${plugin.name}`);
            return false;
        }

        try {
            // onLoad hook'u çağır
            if (plugin.onLoad) {
                await plugin.onLoad();
            }

            this.plugins.set(plugin.name, {
                plugin,
                enabled: true,
                loadedAt: new Date(),
            });

            console.log(`[PluginManager] ✓ Plugin yüklendi: ${plugin.name} v${plugin.version}`);
            this.emit('pluginLoaded', plugin.name);
            return true;
        } catch (error) {
            console.error(`[PluginManager] Plugin yükleme hatası (${plugin.name}):`, error);
            return false;
        }
    }

    /**
     * Plugin kaldır
     */
    public async unregister(name: string): Promise<boolean> {
        const state = this.plugins.get(name);
        if (!state) {
            return false;
        }

        try {
            if (state.plugin.onUnload) {
                await state.plugin.onUnload();
            }

            this.plugins.delete(name);
            console.log(`[PluginManager] Plugin kaldırıldı: ${name}`);
            this.emit('pluginUnloaded', name);
            return true;
        } catch (error) {
            console.error(`[PluginManager] Plugin kaldırma hatası (${name}):`, error);
            return false;
        }
    }

    /**
     * Plugin etkinleştir/devre dışı bırak
     */
    public setEnabled(name: string, enabled: boolean): boolean {
        const state = this.plugins.get(name);
        if (!state) return false;

        state.enabled = enabled;
        console.log(`[PluginManager] ${name}: ${enabled ? 'etkin' : 'devre dışı'}`);
        return true;
    }

    /**
     * Sorgu öncesi hook'ları çalıştır
     */
    public async runQueryBefore(context: QueryContext): Promise<QueryContext> {
        let result = context;

        for (const [name, state] of this.plugins) {
            if (state.enabled && state.plugin.onQueryBefore) {
                try {
                    result = await state.plugin.onQueryBefore(result);
                } catch (error) {
                    console.error(`[PluginManager] ${name}.onQueryBefore hatası:`, error);
                }
            }
        }

        return result;
    }

    /**
     * Sorgu sonrası hook'ları çalıştır
     */
    public async runQueryAfter(context: QueryContext, result: QueryResult): Promise<QueryResult> {
        let output = result;

        for (const [name, state] of this.plugins) {
            if (state.enabled && state.plugin.onQueryAfter) {
                try {
                    output = await state.plugin.onQueryAfter(context, output);
                } catch (error) {
                    console.error(`[PluginManager] ${name}.onQueryAfter hatası:`, error);
                }
            }
        }

        return output;
    }

    /**
     * Doküman ekleme hook'ları
     */
    public async runDocumentAdd(text: string, source: string): Promise<string> {
        let result = text;

        for (const [name, state] of this.plugins) {
            if (state.enabled && state.plugin.onDocumentAdd) {
                try {
                    result = await state.plugin.onDocumentAdd(result, source);
                } catch (error) {
                    console.error(`[PluginManager] ${name}.onDocumentAdd hatası:`, error);
                }
            }
        }

        return result;
    }

    /**
     * Arama sonuçları hook'ları
     */
    public async runSearchResults(results: any[]): Promise<any[]> {
        let output = results;

        for (const [name, state] of this.plugins) {
            if (state.enabled && state.plugin.onSearchResults) {
                try {
                    output = await state.plugin.onSearchResults(output);
                } catch (error) {
                    console.error(`[PluginManager] ${name}.onSearchResults hatası:`, error);
                }
            }
        }

        return output;
    }

    /**
     * Plugin listesi
     */
    public list(): Array<{ name: string; version: string; enabled: boolean; description?: string }> {
        const result: Array<{ name: string; version: string; enabled: boolean; description?: string }> = [];

        for (const [name, state] of this.plugins) {
            result.push({
                name,
                version: state.plugin.version,
                enabled: state.enabled,
                description: state.plugin.description,
            });
        }

        return result;
    }

    /**
     * Plugin al
     */
    public get(name: string): Plugin | undefined {
        return this.plugins.get(name)?.plugin;
    }

    /**
     * Toplam plugin sayısı
     */
    public get count(): number {
        return this.plugins.size;
    }
}

// Singleton instance
let pluginManagerInstance: PluginManager | null = null;

/**
 * PluginManager singleton instance al
 */
export function getPluginManager(): PluginManager {
    if (!pluginManagerInstance) {
        pluginManagerInstance = new PluginManager();
    }
    return pluginManagerInstance;
}

// ============================================
// Örnek Dahili Eklentiler
// ============================================

/**
 * Türkçe Normalizer Plugin
 * Sorguları Türkçe için optimize eder
 */
export const TurkishNormalizerPlugin: Plugin = {
    name: 'turkish-normalizer',
    version: '1.0.0',
    description: 'Türkçe karakter ve metin normalizasyonu',

    onQueryBefore: (context) => {
        // Türkçe karakterleri normalize et
        let normalized = context.question
            .replace(/İ/g, 'I')
            .replace(/ı/g, 'i')
            .toLowerCase();

        return { ...context, question: normalized };
    },
};

/**
 * Query Logger Plugin
 * Tüm sorguları loglar
 */
export const QueryLoggerPlugin: Plugin = {
    name: 'query-logger',
    version: '1.0.0',
    description: 'Sorguları konsola loglar',

    onQueryBefore: (context) => {
        console.log(`[QueryLogger] Sorgu: "${context.question}"`);
        return context;
    },

    onQueryAfter: (context, result) => {
        console.log(`[QueryLogger] Cevap: ${result.answer.substring(0, 100)}...`);
        return result;
    },
};

/**
 * Confidence Filter Plugin
 * Düşük güvenilirlikli sonuçları filtreler
 */
export const ConfidenceFilterPlugin: Plugin = {
    name: 'confidence-filter',
    version: '1.0.0',
    description: 'Düşük güvenilirlikli sonuçları filtreler',

    onSearchResults: (results) => {
        // 0.3 altındaki sonuçları filtrele
        return results.filter(r => r.similarity >= 0.3);
    },
};
