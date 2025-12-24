/**
 * Universal LLM MCP Sunucusu
 * Yerel LLM'ler için evrensel MCP sunucusu - Türkçe destekli
 * 
 * Bu sunucu, farklı LLM backend'lerini (LM Studio, Ollama vb.) tek bir
 * arayüz altında birleştirir ve çeşitli araçlar sunar.
 */

import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { getConfigManager } from './config.js';
import { getRouter } from './router/llm-router.js';
import { registerCodeTools } from './tools/code-tool.js';
import { registerChatTools } from './tools/chat-tool.js';
import { registerTranslateTools } from './tools/translate-tool.js';
import { registerFileTools } from './tools/file-tool.js';
import { registerRAGTools } from './tools/rag-tool.js';
import { registerTrainingTools } from './tools/training-tool.js';
import { registerGitHubTools } from './tools/github-tool.js';
import { registerDBTools } from './tools/db-tool.js';

/**
 * Ana sunucu sınıfı
 */
export class UniversalLLMServer {
    private server: McpServer;
    private config = getConfigManager();

    constructor() {
        this.server = new McpServer({
            name: 'universal-llm-mcp',
            version: '1.2.0',
        });

        this.registerAllTools();
    }

    /**
     * Tüm araçları kaydet
     */
    private registerAllTools(): void {
        const aktifAraclar = this.config.getAktifAraclar();

        console.log('[Sunucu] Araçlar kaydediliyor...');

        if (aktifAraclar.includes('code')) {
            registerCodeTools(this.server);
            console.log('[Sunucu] ✓ Kod araçları yüklendi');
        }

        if (aktifAraclar.includes('chat')) {
            registerChatTools(this.server);
            console.log('[Sunucu] ✓ Sohbet araçları yüklendi');
        }

        if (aktifAraclar.includes('translate')) {
            registerTranslateTools(this.server);
            console.log('[Sunucu] ✓ Çeviri araçları yüklendi');
        }

        if (aktifAraclar.includes('file')) {
            registerFileTools(this.server);
            console.log('[Sunucu] ✓ Dosya araçları yüklendi');
        }

        if (aktifAraclar.includes('rag')) {
            registerRAGTools(this.server);
            console.log('[Sunucu] ✓ RAG araçları yüklendi');
        }

        if (aktifAraclar.includes('training')) {
            registerTrainingTools(this.server);
            console.log('[Sunucu] ✓ Eğitim araçları yüklendi');
        }

        // GitHub ve Enterprise DB Araçları
        registerGitHubTools(this.server);
        registerDBTools(this.server);
        console.log('[Sunucu] ✓ Kurumsal araçlar yüklendi (GitHub & DB)');

        // Sistem araçları (her zaman aktif)
        this.registerSystemTools();
        console.log('[Sunucu] ✓ Sistem araçları yüklendi');
    }

    /**
     * Sistem araçlarını kaydet
     */
    private registerSystemTools(): void {
        // Backend durumu aracı
        this.server.tool(
            'backend_durumu',
            'Tüm LLM backend\'lerinin durumunu kontrol et',
            {},
            async () => {
                const router = getRouter();
                const durumlar = await router.checkAllBackends();

                let sonuc = '## LLM Backend Durumları\n\n';

                for (const [isim, durum] of durumlar) {
                    const emoji = durum.isAvailable ? '✅' : '❌';
                    sonuc += `### ${emoji} ${isim.toUpperCase()}\n`;
                    sonuc += `- Durum: ${durum.isAvailable ? 'Erişilebilir' : 'Erişilemez'}\n`;

                    if (durum.models.length > 0) {
                        sonuc += `- Modeller: ${durum.models.join(', ')}\n`;
                    }

                    if (durum.error) {
                        sonuc += `- Hata: ${durum.error}\n`;
                    }

                    sonuc += '\n';
                }

                return { content: [{ type: 'text', text: sonuc }] };
            }
        );

        // Model listesi aracı
        this.server.tool(
            'model_listele',
            'Tüm backend\'lerdeki mevcut modelleri listele',
            {},
            async () => {
                const router = getRouter();
                const modeller = await router.listAllModels();

                let sonuc = '## Mevcut LLM Modelleri\n\n';

                for (const [backend, modelListesi] of Object.entries(modeller)) {
                    sonuc += `### ${backend.toUpperCase()}\n`;

                    if (modelListesi.length > 0) {
                        modelListesi.forEach((model, index) => {
                            sonuc += `${index + 1}. ${model}\n`;
                        });
                    } else {
                        sonuc += 'Model bulunamadı veya backend erişilemez.\n';
                    }

                    sonuc += '\n';
                }

                return { content: [{ type: 'text', text: sonuc }] };
            }
        );

        // Yapılandırma bilgisi aracı
        this.server.tool(
            'yapilandirma_goster',
            'Mevcut sunucu yapılandırmasını göster',
            {},
            async () => {
                const router = getRouter();
                const config = this.config.getConfig();

                let sonuc = '## Universal LLM MCP Yapılandırması\n\n';

                sonuc += '### Backend\'ler\n';
                for (const [isim, backend] of Object.entries(config.backends)) {
                    sonuc += `- **${isim}**: ${backend.url} (${backend.enabled ? 'Aktif' : 'Pasif'})\n`;
                }

                sonuc += '\n### Yönlendirme\n';
                sonuc += `- Kod: ${config.routing.code}\n`;
                sonuc += `- Sohbet: ${config.routing.chat}\n`;
                sonuc += `- Çeviri: ${config.routing.translate}\n`;
                sonuc += `- Dosya: ${config.routing.file}\n`;

                sonuc += '\n### Dil Ayarları\n';
                sonuc += `- Varsayılan Dil: ${config.language.default}\n`;

                sonuc += '\n### Aktif Araçlar\n';
                config.tools.enabled.forEach((arac) => {
                    sonuc += `- ${arac}\n`;
                });

                return { content: [{ type: 'text', text: sonuc }] };
            }
        );

        // Observability: Metrikler (Prometheus uyumlu)
        this.server.tool(
            'metrikleri_goster',
            'Sistem metriklerini (İstek sayısı, hata oranı, kaynak kullanımı) göster',
            {},
            async () => {
                const uptime = process.uptime();
                const memoryUsage = process.memoryUsage();

                let metrics = '# HELP platform_uptime_seconds Sunucu çalışma süresi\n';
                metrics += `# TYPE platform_uptime_seconds counter\n`;
                metrics += `platform_uptime_seconds ${uptime}\n\n`;

                metrics += '# HELP platform_memory_heap_bytes Bellek kullanımı (Heap)\n';
                metrics += `# TYPE platform_memory_heap_bytes gauge\n`;
                metrics += `platform_memory_heap_bytes ${memoryUsage.heapUsed}\n\n`;

                metrics += '# HELP platform_memory_rss_bytes Bellek kullanımı (RSS)\n';
                metrics += `# TYPE platform_memory_rss_bytes gauge\n`;
                metrics += `platform_memory_rss_bytes ${memoryUsage.rss}\n`;

                return {
                    content: [{
                        type: 'text',
                        text: `## Sistem Metrikleri (Observability)\n\n\`\`\`prometheus\n${metrics}\`\`\``
                    }]
                };
            }
        );
    }

    /**
     * Sunucuyu başlat
     */
    async start(): Promise<void> {
        console.log('[Sunucu] Universal LLM MCP Sunucusu başlatılıyor...');

        // Backend'leri kontrol et
        const router = getRouter();
        await router.checkAllBackends();

        // Stdio transport ile başlat
        const transport = new StdioServerTransport();
        await this.server.connect(transport);

        console.log('[Sunucu] MCP sunucusu hazır ve dinliyor.');
    }
}
