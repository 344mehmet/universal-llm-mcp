/**
 * Eğitim Başlatıcı Script
 */

import { getFastTrainer } from './src/training/fast-trainer.js';
import { loadAllTrainingExamples } from './src/training/training-data.js';

async function runTraining() {
    console.log('🎯 Eğitim başlıyor...\n');

    const trainer = getFastTrainer();

    // Örnekleri yükle
    const count = loadAllTrainingExamples();
    console.log(`📚 ${count} örnek yüklendi\n`);

    // REG parametrelerini ayarla
    trainer.setRegularization(0.1, 0.1, 0.9);

    // Progress takibi
    trainer.on('progress', (data) => {
        console.log(`⏳ Epoch ${data.epoch}: %${data.progress} (${data.completed} tamamlandı)`);
    });

    // Eğitimi başlat
    console.log('🚀 Batch eğitimi başlıyor...\n');

    const metrics = await trainer.trainBatch({
        batchSize: 5,
        epochs: 2,
    });

    // Sonuçları göster
    console.log('\n════════════════════════════════');
    console.log('📊 EĞİTİM SONUÇLARI');
    console.log('════════════════════════════════');
    console.log(`Toplam örnek: ${metrics.totalExamples}`);
    console.log(`Tamamlanan: ${metrics.completedExamples}`);
    console.log(`Ortalama skor: ${(metrics.averageScore * 100).toFixed(1)}%`);
    console.log(`Ortalama gecikme: ${metrics.averageLatency.toFixed(0)}ms`);

    console.log('\n🏆 En İyi Kategoriler:');
    for (const cat of metrics.topCategories) {
        console.log(`   ${cat.category}: ${(cat.score * 100).toFixed(1)}%`);
    }

    console.log('\n⚠️ Zayıf Kategoriler:');
    for (const cat of metrics.weakCategories) {
        console.log(`   ${cat.category}: ${(cat.score * 100).toFixed(1)}%`);
    }

    console.log('\n✅ Eğitim tamamlandı!');
}

runTraining().catch(console.error);
