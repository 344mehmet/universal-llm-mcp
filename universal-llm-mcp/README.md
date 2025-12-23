# Universal LLM MCP Sunucusu

Yerel LLM'ler (LM Studio, Ollama vb.) için evrensel MCP sunucusu - Türkçe destekli.

## Özellikler

- 🔌 **Çoklu Backend Desteği**: LM Studio ve Ollama aynı anda çalışabilir
- 🔀 **Akıllı Yönlendirme**: Görev tipine göre otomatik backend seçimi
- 🇹🇷 **Türkçe Odaklı**: Tüm yanıtlar Türkçe
- 🔧 **Genişletilebilir**: Yeni araçlar ve backend'ler kolayca eklenebilir

## Kurulum

```bash
# Proje klasörüne git
cd universal-llm-mcp

# Bağımlılıkları yükle
npm install

# Derle
npm run build
```

## Yapılandırma

`config.json` dosyasını düzenleyin:

```json
{
  "backends": {
    "lmstudio": {
      "enabled": true,
      "url": "https://localhost:1234"
    },
    "ollama": {
      "enabled": true,
      "url": "https://localhost:11434"
    }
  },
  "routing": {
    "code": "lmstudio",
    "chat": "ollama",
    "translate": "lmstudio"
  }
}
```

## Gemini CLI Entegrasyonu

`~/.gemini/settings.json` dosyasına ekleyin:

```json
{
  "mcpServers": {
    "universal-llm": {
      "command": "node",
      "args": ["C:/Users/win11.2025/Desktop/antygravty google id/universal-llm-mcp/dist/index.js"]
    }
  }
}
```

## Mevcut Araçlar

### 📝 Kod Araçları

| Araç | Açıklama |
|------|----------|
| `kod_uret` | Verilen açıklamaya göre kod üret |
| `kod_acikla` | Kodu Türkçe olarak açıkla |
| `kod_iyilestir` | Kodu refactor et |
| `kod_debug` | Hataları bul ve düzelt |

### 💬 Sohbet Araçları

| Araç | Açıklama |
|------|----------|
| `turkce_sohbet` | Türkçe sohbet et |
| `ozetle` | Metin özetle |
| `beyin_firtinasi` | Yaratıcı fikirler üret |

### 🌐 Çeviri Araçları

| Araç | Açıklama |
|------|----------|
| `cevir` | 11 dil arasında çeviri yap |
| `yerelleştir` | Kültüre uygun yerelleştirme |
| `dil_algila` | Dil algılama ve analiz |

### 📂 Dosya Araçları

| Araç | Açıklama |
|------|----------|
| `dosya_analiz` | Dosya analizi |
| `icerik_analiz` | İçerik analizi |
| `dokumantasyon_uret` | Kod dokümantasyonu üret |
| `dosya_karsilastir` | Dosya karşılaştırma |

### ⚙️ Sistem Araçları

| Araç | Açıklama |
|------|----------|
| `backend_durumu` | Backend sağlık kontrolü |
| `model_listele` | Mevcut modelleri listele |
| `yapilandirma_goster` | Yapılandırmayı göster |

## Yeni Araç Ekleme

`src/tools/` klasörüne yeni bir TypeScript dosyası ekleyin:

```typescript
// src/tools/my-tool.ts
import { z } from 'zod';
import { getRouter } from '../router/llm-router.js';

export const mySchema = z.object({
  input: z.string().describe('Giriş parametresi'),
});

export async function myFunction(args: z.infer<typeof mySchema>): Promise<string> {
  const router = getRouter();
  const response = await router.complete('default', args.input);
  return response.content;
}

export function registerMyTools(server: any): void {
  server.tool('arac_adim', 'Araç açıklaması', mySchema.shape,
    async (args: z.infer<typeof mySchema>) => {
      const sonuc = await myFunction(args);
      return { content: [{ type: 'text', text: sonuc }] };
    }
  );
}
```

Sonra `src/server.ts` dosyasına import edin ve kaydedin.

## Lisans

MIT
