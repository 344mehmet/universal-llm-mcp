# 🎁 Ücretsiz AI/LLM Araçları Koleksiyonu

Bu belge, ücretsiz kullanılabilen yapay zeka araçlarını ve API'lerini listelemektedir.

---

## 🌐 Ücretsiz Cloud API'ler

### 1. Google Gemini

- **URL:** <https://aistudio.google.com>
- **Limit:** 1,500 istek/gün (Flash)
- **Kurulum:**

```bash
pip install google-generativeai
```

```python
import google.generativeai as genai
genai.configure(api_key="YOUR_API_KEY")
model = genai.GenerativeModel('gemini-1.5-flash')
response = model.generate_content("Merhaba!")
```

### 2. Groq (En Hızlı!)

- **URL:** <https://console.groq.com>
- **Limit:** 14,400 istek/gün
- **Kurulum:**

```bash
pip install groq
```

```python
from groq import Groq
client = Groq(api_key="YOUR_API_KEY")
response = client.chat.completions.create(
    model="llama-3.3-70b-versatile",
    messages=[{"role": "user", "content": "Merhaba!"}]
)
```

### 3. DeepSeek

- **URL:** <https://platform.deepseek.com>
- **Limit:** Çok düşük maliyet ($0.14/1M token)
- **Özellik:** Kodlama ve reasoning için güçlü

### 4. Hugging Face

- **URL:** <https://huggingface.co>
- **Limit:** 10,000 istek/gün (modele bağlı)
- **Kurulum:**

```bash
pip install huggingface_hub
```

### 5. OpenRouter (Hub)

- **URL:** <https://openrouter.ai>
- **Özellik:** Birçok modele tek API'den erişim

### 6. Together AI

- **URL:** <https://together.ai>
- **Limit:** $25 ücretsiz kredi

### 7. Scaleway

- **URL:** <https://console.scaleway.com>
- **Limit:** 1,000,000 token ücretsiz!

### 8. NVIDIA NIM

- **URL:** <https://build.nvidia.com>
- **Limit:** 1,000 kredi

---

## 🏠 Yerel LLM'ler (Sınırsız)

### 1. Ollama

- **URL:** <https://ollama.ai>
- **Kurulum:**

```bash
# Windows
winget install Ollama.Ollama

# Model indir ve çalıştır
ollama run llama3.1:8b
ollama run qwen3:30b
ollama run deepseek-r1:8b
```

### 2. LM Studio

- **URL:** <https://lmstudio.ai>
- **Özellik:** GUI ile kolay model yönetimi
- **API:** OpenAI uyumlu API (localhost:1234)

### 3. Jan.ai

- **URL:** <https://jan.ai>
- **Özellik:** Özelleştirilebilir AI asistan

### 4. GPT4All

- **URL:** <https://gpt4all.io>
- **Özellik:** Çevrimdışı çalışır

### 5. LocalAI

- **URL:** <https://localai.io>
- **Özellik:** Docker ile kolay kurulum

---

## 🔧 RAG ve Dokümantasyon

### AnythingLLM

- **URL:** <https://useanything.com>
- **Kurulum:**

```bash
docker pull mintplexlabs/anythingllm
docker run -p 3001:3001 mintplexlabs/anythingllm
```

### Open WebUI

- **URL:** <https://openwebui.com>
- **Kurulum:**

```bash
docker run -p 8080:8080 ghcr.io/open-webui/open-webui:main
```

---

## 📊 Önerilen 16GB VRAM Modelleri

| Model | Boyut | Kullanım |
| ----- | ----- | -------- |
| qwen3:30b-q4_K_M | 18GB | Genel amaçlı |
| gemma3:27b-q4_K_M | 17GB | Türkçe iyi |
| deepseek-r1:8b | 5GB | Reasoning |
| llama3.1:8b-q4_K_M | 5GB | Hızlı |
| qwen3-coder:30b | 18GB | Kodlama |

---

## 🚀 Hızlı Başlangıç

```bash
# 1. Ollama kur
winget install Ollama.Ollama

# 2. Model indir
ollama pull qwen3:8b

# 3. API ile kullan
curl http://localhost:11434/api/generate -d '{
  "model": "qwen3:8b",
  "prompt": "Merhaba!"
}'
```

---

**Son Güncelleme:** 24 Aralık 2024
**Katkıda Bulunanlar:** AI Developer Army
