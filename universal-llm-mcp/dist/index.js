/**
 * Universal LLM MCP Sunucusu - Giriş Noktası
 *
 * Bu dosya MCP sunucusunu başlatır.
 * Kullanım: npm start veya node dist/index.js
 */
import { UniversalLLMServer } from './server.js';
// Sunucuyu başlat
async function main() {
    try {
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('   Universal LLM MCP Sunucusu v1.0.0');
        console.log('   Türkçe Destekli Yerel LLM Entegrasyonu');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('');
        const server = new UniversalLLMServer();
        await server.start();
    }
    catch (error) {
        console.error('[Hata] Sunucu başlatılamadı:', error);
        process.exit(1);
    }
}
// Hata yakalama
process.on('uncaughtException', (error) => {
    console.error('[Kritik Hata] Yakalanmamış istisna:', error);
    process.exit(1);
});
process.on('unhandledRejection', (reason) => {
    console.error('[Kritik Hata] İşlenmeyen promise reddi:', reason);
    process.exit(1);
});
// Başlat
main();
//# sourceMappingURL=index.js.map