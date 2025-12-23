/**
 * Universal LLM MCP - Plugin Manager
 * Genişletilebilir eklenti sistemi
 */
import { EventEmitter } from 'events';
/**
 * Plugin Manager
 * Dinamik eklenti yükleme ve yönetimi
 */
export class PluginManager extends EventEmitter {
    plugins = new Map();
    constructor() {
        super();
        console.log('[PluginManager] Başlatıldı');
    }
    /**
     * Plugin yükle
     */
    async register(plugin) {
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
        }
        catch (error) {
            console.error(`[PluginManager] Plugin yükleme hatası (${plugin.name}):`, error);
            return false;
        }
    }
    /**
     * Plugin kaldır
     */
    async unregister(name) {
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
        }
        catch (error) {
            console.error(`[PluginManager] Plugin kaldırma hatası (${name}):`, error);
            return false;
        }
    }
    /**
     * Plugin etkinleştir/devre dışı bırak
     */
    setEnabled(name, enabled) {
        const state = this.plugins.get(name);
        if (!state)
            return false;
        state.enabled = enabled;
        console.log(`[PluginManager] ${name}: ${enabled ? 'etkin' : 'devre dışı'}`);
        return true;
    }
    /**
     * Sorgu öncesi hook'ları çalıştır
     */
    async runQueryBefore(context) {
        let result = context;
        for (const [name, state] of this.plugins) {
            if (state.enabled && state.plugin.onQueryBefore) {
                try {
                    result = await state.plugin.onQueryBefore(result);
                }
                catch (error) {
                    console.error(`[PluginManager] ${name}.onQueryBefore hatası:`, error);
                }
            }
        }
        return result;
    }
    /**
     * Sorgu sonrası hook'ları çalıştır
     */
    async runQueryAfter(context, result) {
        let output = result;
        for (const [name, state] of this.plugins) {
            if (state.enabled && state.plugin.onQueryAfter) {
                try {
                    output = await state.plugin.onQueryAfter(context, output);
                }
                catch (error) {
                    console.error(`[PluginManager] ${name}.onQueryAfter hatası:`, error);
                }
            }
        }
        return output;
    }
    /**
     * Doküman ekleme hook'ları
     */
    async runDocumentAdd(text, source) {
        let result = text;
        for (const [name, state] of this.plugins) {
            if (state.enabled && state.plugin.onDocumentAdd) {
                try {
                    result = await state.plugin.onDocumentAdd(result, source);
                }
                catch (error) {
                    console.error(`[PluginManager] ${name}.onDocumentAdd hatası:`, error);
                }
            }
        }
        return result;
    }
    /**
     * Arama sonuçları hook'ları
     */
    async runSearchResults(results) {
        let output = results;
        for (const [name, state] of this.plugins) {
            if (state.enabled && state.plugin.onSearchResults) {
                try {
                    output = await state.plugin.onSearchResults(output);
                }
                catch (error) {
                    console.error(`[PluginManager] ${name}.onSearchResults hatası:`, error);
                }
            }
        }
        return output;
    }
    /**
     * Plugin listesi
     */
    list() {
        const result = [];
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
    get(name) {
        return this.plugins.get(name)?.plugin;
    }
    /**
     * Toplam plugin sayısı
     */
    get count() {
        return this.plugins.size;
    }
}
// Singleton instance
let pluginManagerInstance = null;
/**
 * PluginManager singleton instance al
 */
export function getPluginManager() {
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
export const TurkishNormalizerPlugin = {
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
export const QueryLoggerPlugin = {
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
export const ConfidenceFilterPlugin = {
    name: 'confidence-filter',
    version: '1.0.0',
    description: 'Düşük güvenilirlikli sonuçları filtreler',
    onSearchResults: (results) => {
        // 0.3 altındaki sonuçları filtrele
        return results.filter(r => r.similarity >= 0.3);
    },
};
//# sourceMappingURL=plugin-manager.js.map