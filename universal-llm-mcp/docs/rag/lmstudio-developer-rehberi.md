# 🖥️ LM Studio Geliştirici Rehberi

## Türkçe LM Studio Developer Guide - LLM'ler İçin

### LM Studio Nedir?

LM Studio, yerel LLM'leri çalıştırmak için kullanılan masaüstü uygulamasıdır. OpenAI-uyumlu REST API sağlar.

---

## 🔧 API Özellikleri

### Temel Bilgiler

| Özellik | Değer |
| ------- | ----- |
| API URL | `http://localhost:1234` |
| API Stili | OpenAI-uyumlu |
| Model Yükleme | JIT (Just-in-Time) |
| Formatlar | GGUF quantized |

### Desteklenen Endpoint'ler

```text
GET  /v1/models              - Model listesi
POST /v1/chat/completions    - Chat tamamlama
POST /v1/completions         - Metin tamamlama
POST /v1/embeddings          - Embedding oluşturma
```

---

## 💻 JavaScript/TypeScript Kullanımı

### Temel İstek

```typescript
const LMSTUDIO_URL = "http://localhost:1234";

async function chatTamamla(mesaj: string): Promise<string> {
    const yanit = await fetch(`${LMSTUDIO_URL}/v1/chat/completions`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            model: "auto",  // otomatik seçim
            messages: [
                { role: "system", content: "Sen yardımsever bir asistandsın." },
                { role: "user", content: mesaj }
            ],
            temperature: 0.7,
            max_tokens: 2048
        })
    });
    
    const veri = await yanit.json();
    return veri.choices[0].message.content;
}
```

### Streaming Yanıt

```typescript
async function* streamChat(mesaj: string): AsyncGenerator<string> {
    const yanit = await fetch(`${LMSTUDIO_URL}/v1/chat/completions`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
            model: "auto",
            messages: [{ role: "user", content: mesaj }],
            stream: true
        })
    });
    
    const reader = yanit.body?.getReader();
    const decoder = new TextDecoder();
    
    while (true) {
        const { done, value } = await reader!.read();
        if (done) break;
        
        const satir = decoder.decode(value);
        if (satir.startsWith("data: ")) {
            const json = JSON.parse(satir.slice(6));
            const icerik = json.choices[0]?.delta?.content;
            if (icerik) yield icerik;
        }
    }
}
```

---

## 🐍 Python Kullanımı

### OpenAI SDK ile

```python
from openai import OpenAI

istemci = OpenAI(
    base_url="http://localhost:1234/v1",
    api_key="lm-studio"  # herhangi bir değer olabilir
)

yanit = istemci.chat.completions.create(
    model="auto",
    messages=[
        {"role": "system", "content": "Sen yardımsever bir asistandsın."},
        {"role": "user", "content": "Merhaba, nasılsın?"}
    ],
    temperature=0.7
)

print(yanit.choices[0].message.content)
```

### LM Studio SDK ile

```python
# pip install lmstudio-python
from lmstudio import Client

istemci = Client()

# Model yükle
model = istemci.llm.load("deepseek/deepseek-r1-0528-qwen3-8b")

# Chat oluştur
yanit = model.respond("Python'da liste nasıl oluşturulur?")
print(yanit)
```

---

## 🔨 CLI Araçları

LM Studio CLI (`lms`) komutu ile terminal üzerinden kontrol:

```bash
# LM Studio durumunu kontrol et
lms status

# Model listele
lms ls

# Model yükle
lms load deepseek/deepseek-r1-0528-qwen3-8b

# Model indir
lms get qwen/qwq-32b

# Sunucuyu başlat
lms server start
```

---

## 🧰 Function Calling (Tool Use)

LM Studio, OpenAI-uyumlu tool calling destekler:

```typescript
const araçlar = [
    {
        type: "function",
        function: {
            name: "havadurumu_al",
            description: "Belirtilen şehrin hava durumunu al",
            parameters: {
                type: "object",
                properties: {
                    sehir: { 
                        type: "string", 
                        description: "Şehir adı" 
                    }
                },
                required: ["sehir"]
            }
        }
    }
];

const yanit = await fetch(`${LMSTUDIO_URL}/v1/chat/completions`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
        model: "auto",
        messages: [
            { role: "user", content: "İstanbul'da hava nasıl?" }
        ],
        tools: araçlar,
        tool_choice: "auto"
    })
});
```

---

## 📊 Performans İpuçları

### GPU Offload

- **Tam GPU:** Tüm katmanları GPU'ya yükle
- **Kısmi GPU:** Bellek sınırlıysa bazı katmanları RAM'de tut
- **Sadece CPU:** GPU yoksa veya küçük modeller için

### Context Length

- Varsayılan: 4096 token
- Maksimum: Model bağımlı (bazıları 128K destekler)
- Arttıkça bellek kullanımı artar

### Önerilen Ayarlar (16GB VRAM)

| Model | GPU Layers | Context |
| ----- | ---------- | ------- |
| 7B-Q4 | 35 | 8192 |
| 14B-Q4 | 28 | 4096 |
| 32B-Q4 | 20 | 4096 |

---

## 🔌 Entegrasyon Örnekleri

### VSCode Continue ile

```json
{
    "models": [{
        "title": "LM Studio",
        "provider": "lmstudio",
        "model": "auto"
    }]
}
```

### LangChain ile

```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    base_url="http://localhost:1234/v1",
    api_key="lm-studio",
    model="auto"
)

yanit = llm.invoke("Python'da decorator nedir?")
print(yanit.content)
```

---
**LLM Notu:** Bu doküman LM Studio geliştirici özellikleri için Türkçe RAG kaynağıdır.
