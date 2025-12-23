/**
 * Universal LLM MCP - Plugin Manager
 * Genişletilebilir eklenti sistemi
 */
import { EventEmitter } from 'events';
export interface Plugin {
    name: string;
    version: string;
    description?: string;
    onLoad?: () => Promise<void> | void;
    onUnload?: () => Promise<void> | void;
    onQueryBefore?: (query: QueryContext) => Promise<QueryContext> | QueryContext;
    onQueryAfter?: (query: QueryContext, result: QueryResult) => Promise<QueryResult> | QueryResult;
    onDocumentAdd?: (text: string, source: string) => Promise<string> | string;
    onSearchResults?: (results: any[]) => Promise<any[]> | any[];
}
export interface QueryContext {
    question: string;
    category?: string;
    topK?: number;
    metadata?: Record<string, any>;
}
export interface QueryResult {
    answer: string;
    sources: string[];
    confidence?: number;
    metadata?: Record<string, any>;
}
/**
 * Plugin Manager
 * Dinamik eklenti yükleme ve yönetimi
 */
export declare class PluginManager extends EventEmitter {
    private plugins;
    constructor();
    /**
     * Plugin yükle
     */
    register(plugin: Plugin): Promise<boolean>;
    /**
     * Plugin kaldır
     */
    unregister(name: string): Promise<boolean>;
    /**
     * Plugin etkinleştir/devre dışı bırak
     */
    setEnabled(name: string, enabled: boolean): boolean;
    /**
     * Sorgu öncesi hook'ları çalıştır
     */
    runQueryBefore(context: QueryContext): Promise<QueryContext>;
    /**
     * Sorgu sonrası hook'ları çalıştır
     */
    runQueryAfter(context: QueryContext, result: QueryResult): Promise<QueryResult>;
    /**
     * Doküman ekleme hook'ları
     */
    runDocumentAdd(text: string, source: string): Promise<string>;
    /**
     * Arama sonuçları hook'ları
     */
    runSearchResults(results: any[]): Promise<any[]>;
    /**
     * Plugin listesi
     */
    list(): Array<{
        name: string;
        version: string;
        enabled: boolean;
        description?: string;
    }>;
    /**
     * Plugin al
     */
    get(name: string): Plugin | undefined;
    /**
     * Toplam plugin sayısı
     */
    get count(): number;
}
/**
 * PluginManager singleton instance al
 */
export declare function getPluginManager(): PluginManager;
/**
 * Türkçe Normalizer Plugin
 * Sorguları Türkçe için optimize eder
 */
export declare const TurkishNormalizerPlugin: Plugin;
/**
 * Query Logger Plugin
 * Tüm sorguları loglar
 */
export declare const QueryLoggerPlugin: Plugin;
/**
 * Confidence Filter Plugin
 * Düşük güvenilirlikli sonuçları filtreler
 */
export declare const ConfidenceFilterPlugin: Plugin;
//# sourceMappingURL=plugin-manager.d.ts.map