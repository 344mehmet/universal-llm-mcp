# RAG Performans Optimizasyonu Rehberi

Bu doküman, LLM eğitimi için RAG sisteminin nasıl optimize edileceğini açıklar.

## 1. Embedding Modelleri Karşılaştırması

### En İyi Modeller (2024)
| Model | Parametre | Boyut | Özellik |
|-------|-----------|-------|---------|
| BAAI/bge-m3 | 568M | 1024 dim | Multi-lingual, dense+sparse |
| intfloat/e5-large-v2 | 350M | 1024 dim | Genel amaçlı |
| nomic-embed-text | 137M | 768 dim | Hızlı, Ollama destekli |
| mxbai-embed-large | 335M | 1024 dim | Dengeli performans |

### Önerilen: Yerel Kullanım İçin
```bash
# Ollama ile nomic-embed-text (hızlı, 16GB VRAM uyumlu)
ollama pull nomic-embed-text
```

## 2. Chunking Stratejileri

### Semantic Chunking (En İyi)
- Cümle sınırlarını korur
- Anlam bütünlüğü sağlar
- 256-512 token ideal

### Recursive Chunking
- Paragraf → Cümle → Kelime bazlı
- Büyük dokümanlar için uygun

### Sliding Window
- Overlap: %20-30
- Bağlam kaybını önler

## 3. Hibrit Arama (Hybrid Search)

```
Sonuç = α × Vektör_Arama + (1-α) × BM25_Arama
```
- α = 0.7 (vektör ağırlıklı)
- Anahtar kelime + semantik birleşimi

## 4. Re-ranking

İlk 20 sonucu al → Cross-encoder ile yeniden sırala → Top-3 kullan

### Önerilen Reranker'lar:
- BAAI/bge-reranker-v2-m3
- cross-encoder/ms-marco-MiniLM-L-12-v2

## 5. Query Transformation

### HyDE (Hypothetical Document Embeddings)
1. LLM'e hipotetik yanıt yazdır
2. Bu yanıtı embed et
3. Embedding ile arama yap

### Query Decomposition
Karmaşık soruyu alt sorulara böl, her biri için ayrı arama yap

## 6. Implementasyon Önerileri

### Mevcut Sistemimiz İçin:
1. **Embedding**: `nomic-embed-text` (Ollama)
2. **Chunk Size**: 400 token, 50 token overlap
3. **Hybrid**: Keyword + vector search (alpha=0.7)
4. **TopK**: 5 sonuç al, rerank ile 3'e indir

### Performans İpuçları:
- Batch embedding (100 chunk/batch)
- Async indexing
- Memory-mapped vector storage
- Quantized embeddings (int8)

## 7. Benchmark Metrikleri

- **Precision@K**: Doğru sonuç oranı
- **Recall@K**: Bulunan doğru sonuç oranı  
- **NDCG**: Sıralama kalitesi
- **Latency**: Sorgu süresi (<100ms hedef)
