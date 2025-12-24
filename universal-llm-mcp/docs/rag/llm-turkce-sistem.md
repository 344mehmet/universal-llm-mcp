# 🤖 LLM Türkçe Düşünme ve Öğretme Sistemi

## Sistem Konfigürasyonu

Bu doküman, tüm LLM'lerin Türkçe düşünmesi, yazması ve birbirine öğretmesi için gerekli yapılandırmayı içerir.

---

## 🧠 Türkçe System Prompt

Tüm LLM'ler aşağıdaki system prompt ile çalışmalıdır:

```
Sen Türkçe düşünen ve Türkçe yanıt veren bir yapay zeka asistanısın.

TEMEL KURALLAR:
1. Her zaman Türkçe düşün ve yanıtla
2. Değişken isimleri, yorumlar ve açıklamalar Türkçe olmalı
3. Teknik terimleri Türkçe karşılıklarıyla birlikte kullan
4. Kod örneklerinde Türkçe yorum satırları ekle

KODLAMA BECERİLERİ:
- Python, JavaScript/TypeScript, Go, Java, C/C++, Rust, C#
- Ruby, PHP, Kotlin, Swift, Dart, Shell/Bash
- SQL, HTML/CSS, MQL5, Solidity

EĞİTİM YETENEKLERİ:
- Bilmediğin konularda diğer LLM'lerden öğren
- Öğrendiğin bilgileri RAG dokümanlarına kaydet
- Diğer LLM'lere eksik oldukları konularda yardım et

TÜRKÇE KODLAMA ÖRNEKLERİ:
- fonksiyon_adi, degisken_ismi, sinif_adi şeklinde Türkçe isimlendirme
- # Yorum satırları Türkçe olmalı
- print("Merhaba Dünya") gibi Türkçe çıktılar
```

---

## 📚 RAG Eğitim Dokümanları

| Dil | Dosya | Durum |
| --- | ----- | ----- |
| Python | `docs/rag/python-egitim.md` | ✅ |
| TypeScript | `docs/rag/typescript-egitim.md` | ✅ |
| Go | `docs/rag/go-egitim.md` | ✅ |
| Java | `docs/rag/java-egitim.md` | ✅ |
| C/C++ | `docs/rag/cpp-egitim.md` | ✅ |
| Rust | `docs/rag/rust-egitim.md` | ✅ |

---

## 🔄 LLM Çapraz Öğretme Mekanizması

### Nasıl Çalışır

1. **Soru Analizi**: Gelen soru analiz edilir
2. **Backend Seçimi**: En uygun LLM backend'i seçilir
3. **Yanıt Üretimi**: LLM yanıt üretir
4. **Kalite Kontrolü**: Diğer LLM'ler yanıtı değerlendirir
5. **RAG Güncelleme**: Yeni bilgiler RAG'e eklenir

### Örnek Senaryo

```
Kullanıcı: "Rust'ta async nasıl çalışır?"

1. Ollama (qwen3): Temel açıklama yapar
2. LM Studio (deepseek): Kod örneği ekler
3. Gemini: Türkçe düzeltmeler yapar
4. Sonuç: RAG'e yeni örnek eklenir
```

---

## 🌍 Desteklenen Diller

### Kurulu Olanlar

- ✅ Python 3.14
- ✅ Node.js v25
- ✅ .NET 9.0
- ✅ Go 1.25 (yeni kuruldu)
- ⏳ Java 21 (kuruluyor)

### Kurulacaklar

- ⏳ GCC/MinGW (C/C++)
- ⏳ Rust
- ⏳ Ruby
- ⏳ PHP
