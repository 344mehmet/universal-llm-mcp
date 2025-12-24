/**
 * AI Developer Army - Ana Başlatıcı
 * 7/24 GitHub Issue Çözücü Ordusu
 */

import { createDeveloperArmy } from './github/agent-orchestrator.js';
import { MonetizationService } from './github/monetization.js';
import { getRouter } from './router/llm-router.js';

// Yapılandırma
const CONFIG = {
    github: {
        token: process.env.GITHUB_TOKEN || '',
        owner: '344mehmet', // GitHub kullanıcı adınız
        repos: [
            // Orijinal Projeler
            'llm',
            'bolt',
            'apt-get-update',
            'winget-update',
            // AI/LLM Fork'ları
            '344mehmetllama.cpp',
            'yapay-zeka',
            'anything-llm',
            'ollama',
            'unsloth',
            // MCP Sunucuları
            'mcp',
            'servers',
            'github-mcp-server',
            'github-chat-mcp',
            'notion-mcp-server',
            'mcp-atlassian',
            'mcp-discord',
            'mcp-grafana',
            'mcp-redis',
            'memory-bank-MCP',
            'gemini-cli',
            // Diğer Araçlar
            'ComfyUI',
            'cline',
            'context7',
            'localization',
        ],
    },
    scheduler: {
        scanIntervalMinutes: 30,
        maxConcurrentAgents: 3,
    },
};

async function main() {
    console.log('');
    console.log('╔═══════════════════════════════════════════════════════════╗');
    console.log('║       🤖 AI DEVELOPER ORDUSU - 7/24 AKTİF 🤖              ║');
    console.log('╠═══════════════════════════════════════════════════════════╣');
    console.log('║  GitHub Issue Çözücü | PR Oluşturucu | Kod İnceleyici     ║');
    console.log('╚═══════════════════════════════════════════════════════════╝');
    console.log('');

    // Token kontrolü
    if (!CONFIG.github.token) {
        console.error('❌ GITHUB_TOKEN environment variable gerekli!');
        console.log('');
        console.log('Token oluşturmak için:');
        console.log('1. https://github.com/settings/tokens/new adresine gidin');
        console.log('2. Şu izinleri verin: repo, write:packages, read:org');
        console.log('3. GITHUB_TOKEN=<token> şeklinde .env dosyasına ekleyin');
        console.log('');
        process.exit(1);
    }

    // LLM Router başlat
    console.log('🔧 LLM Router başlatılıyor...');
    const router = getRouter();

    // LLM Client wrapper
    const llmClient = {
        complete: async (request: any) => {
            const prompt = request.messages[0]?.content || '';
            return router.complete('code', prompt);
        },
    };

    // Monetization servisi
    console.log('💰 Monetization servisi başlatılıyor...');
    const monetization = new MonetizationService('344mehmet');
    const stats = monetization.getStats();
    console.log(`   Aktif sponsor: ${stats.totalSponsors}`);
    console.log(`   Aylık gelir: $${stats.monthlyRevenue}`);

    // Developer ordusu oluştur
    console.log('🚀 Developer ordusu oluşturuluyor...');
    const army = createDeveloperArmy(
        CONFIG.github.token,
        CONFIG.github.owner,
        CONFIG.github.repos,
        llmClient
    );

    // Başlat
    army.start();

    // Graceful shutdown
    process.on('SIGINT', () => {
        console.log('\n⏹️ Kapatılıyor...');
        army.stop();
        process.exit(0);
    });

    process.on('SIGTERM', () => {
        army.stop();
        process.exit(0);
    });

    // Canlı tut
    console.log('');
    console.log('✅ Sistem aktif. Ctrl+C ile durdurabilirsiniz.');
    console.log('');
}

main().catch(console.error);
