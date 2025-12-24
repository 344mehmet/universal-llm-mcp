/**
 * Universal LLM MCP - Sistem Tepsisi Başlatıcı
 * Windows system tray ile arka planda çalışır
 */

import { getWebRAGServer } from './web-server.js';
import { getRouter } from './router/llm-router.js';
import { spawn } from 'child_process';
import { writeFileSync, existsSync, mkdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Yapılandırma
const PORT = 3355;
const APP_NAME = 'Universal RAG Server';

/**
 * System Tray Başlatıcı
 */
class SystemTrayLauncher {
    private server = getWebRAGServer(PORT);
    private trayIconPath: string = '';

    /**
     * Başlat
     */
    public async start(): Promise<void> {
        console.log('╔═══════════════════════════════════════════════════════╗');
        console.log('║                                                       ║');
        console.log('║    🧠 UNIVERSAL RAG SERVER                            ║');
        console.log('║    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                 ║');
        console.log('║    Tarayıcı tabanlı RAG + LLM Sunucusu                ║');
        console.log('║                                                       ║');
        console.log('╚═══════════════════════════════════════════════════════╝');
        console.log('');

        // Backend'leri kontrol et
        console.log('[Başlatıcı] Backend\'ler kontrol ediliyor...');
        const router = getRouter();
        await router.checkAllBackends();

        // Web sunucuyu başlat
        await this.server.start();

        // Tarayıcıyı aç (opsiyonel)
        this.openBrowser();

        // Tray bildirim göster (Windows)
        this.showNotification('Sunucu Başlatıldı', `http://localhost:${PORT} adresinde çalışıyor`);

        // Kapanış sinyallerini yakala
        this.setupShutdownHandlers();

        console.log('');
        console.log('📌 Sunucu arka planda çalışıyor...');
        console.log('   Kapatmak için Ctrl+C veya pencereyi kapatın.');
        console.log('');
    }

    /**
     * Varsayılan tarayıcıda aç
     */
    private openBrowser(): void {
        const url = `http://localhost:${PORT}`;

        try {
            // Windows
            spawn('cmd', ['/c', 'start', url], { detached: true, stdio: 'ignore' });
            console.log(`[Başlatıcı] Tarayıcı açılıyor: ${url}`);
        } catch (error) {
            console.log(`[Başlatıcı] Tarayıcı açılamadı. Manuel olarak ziyaret edin: ${url}`);
        }
    }

    /**
     * Windows baloncuk bildirimi
     */
    private showNotification(title: string, message: string): void {
        try {
            // PowerShell ile Windows toast bildirimi
            const psScript = `
                [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
                [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
                $template = @"
                <toast>
                    <visual>
                        <binding template="ToastText02">
                            <text id="1">${title}</text>
                            <text id="2">${message}</text>
                        </binding>
                    </visual>
                </toast>
"@
                $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
                $xml.LoadXml($template)
                $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
                [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("Universal RAG").Show($toast)
            `;

            spawn('powershell', ['-Command', psScript], {
                detached: true,
                stdio: 'ignore',
                windowsHide: true
            });
        } catch (error) {
            // Bildirim gösterilemezse sessizce devam et
        }
    }

    /**
     * Kapanış işleyicileri
     */
    private setupShutdownHandlers(): void {
        const shutdown = async () => {
            console.log('\n[Başlatıcı] Kapatılıyor...');
            await this.server.stop();
            process.exit(0);
        };

        process.on('SIGINT', shutdown);
        process.on('SIGTERM', shutdown);
        process.on('SIGHUP', shutdown);

        // Windows console close
        if (process.platform === 'win32') {
            process.on('message', (msg) => {
                if (msg === 'shutdown') shutdown();
            });
        }
    }

    /**
     * Sunucu durumu
     */
    public isRunning(): boolean {
        return this.server.isActive;
    }

    /**
     * URL al
     */
    public getURL(): string {
        return `http://localhost:${PORT}`;
    }
}

// Ana fonksiyon
async function main(): Promise<void> {
    const launcher = new SystemTrayLauncher();

    try {
        await launcher.start();
    } catch (error) {
        console.error('[Başlatıcı] Kritik hata:', error);
        process.exit(1);
    }
}

// Hata yakalama
process.on('uncaughtException', (error) => {
    console.error('[Kritik] Yakalanmamış hata:', error);
    process.exit(1);
});

process.on('unhandledRejection', (reason) => {
    console.error('[Kritik] İşlenmeyen promise reddi:', reason);
    process.exit(1);
});

// Başlat
main();
