
import { getRAGService } from './src/rag/rag-service.js';
import { getConfigManager } from './src/config.js';

async function testLMStudioRAG() {
    console.log('--- LM Studio RAG Başarı Testi ---');

    const rag = getRAGService();

    // 1. Durum Kontrolü
    const stats = rag.getStats();
    console.log('Mevcut RAG İstatistikleri:', JSON.stringify(stats, null, 2));

    // 2. Eğer döküman yoksa ekle
    if (stats.sources === 0) {
        console.log('Döküman bulunamadı, varsayılan dökümanlar ekleniyor...');
        // Burada manuel ekleme yapılabilir veya rag-tool kullanılabilir
    }

    // 3. Test Sorusu
    const question = "LM Studio'nun Developer API'si hangi portu kullanır?";
    console.log(`Soru: ${question}`);

    const result = await rag.query(question);

    console.log('\n--- Yanıt ---');
    console.log(result.answer);

    console.log('\n--- Kaynaklar ---');
    result.sources.forEach((s, i) => {
        console.log(`${i + 1}. [Skor: ${s.similarity}] ${s.source}`);
    });
}

testLMStudioRAG().catch(console.error);
