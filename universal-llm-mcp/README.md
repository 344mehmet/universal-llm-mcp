# 🧠 Universal LLM Platform (Enterprise Edition)

**Universal LLM Platform**, yerel (Ollama, LM Studio) ve bulut tabanlı (OpenAI, Gemini, Anthropic vb.) 21+ LLM backend'ini tek bir arayüzde birleştiren, tam donanımlı bir **AI Geliştirme Platformu ve IDE**'dir.

---

## 🚀 Öne Çıkan Özellikler

### 🤖 LLM & Vision

- **21+ LLM Backend**: Tek API ve UI üzerinden tüm popüler modellere erişim.
- **🖼️ Multimodal Vision**: Görsel analiz ve bağlamsal anlama desteği.
- **⚔️ Debate Engine**: Modeller arası otonom tartışma ve fikir teatisi.

### 💻 Developer Tools (IDE)

- **📟 Entegre Terminal**: Dashboard üzerinden doğrudan sistem komutları ve terminal erişimi.
- **🐋 Docker Management**: Konteyner derleme, çalıştırma ve otonom yönetim paneli.
- **🌿 Git Dashboard**: Akıllı git kontrolü (Clone, Pull, Push, Commit).
- **📂 Project Explorer**: Proje dosyalarını görüntüleme ve dosya gezgini.

### 🏗️ Enterprise Mimari

- **⚡ Next.js 15 & RSC**: React Server Components destekli modern web katmanı.
- **🌍 Edge Runtime**: Cloudflare Workers ve Edge Routing ile ultra düşük gecikme.
- **🔌 Drizzle & SQL**: SQLite/D1 tabanlı, indekslenmiş ve tip güvenli veritabanı mimarisi (DbService).
- **🛡️ Security Hardening**: CSP, HSTS, CSRF ve TLS güvenlik katmanlarıyla zırhlandırılmış altyapı.

### 📚 Knowledge & RAG

- **Bilgi Bankası**: PDF ve döküman analizi (RAG) ile yerel veri entegrasyonu.
- **Eğitim Modülü**: AI modelleri için otonom soru-cevap ve eğitim akışları.

---

## ⚙️ Kurulum & Başlatma

```bash
# Bağımlılıkları yükle
npm install

# Veritabanı şemasını oluştur (Drizzle)
npm run db:generate
npm run db:push

# Projeyi derle
npm run build

# Geliştirici modunda başlat
npm run dev
```

---

## 🛠️ MCP (Model Context Protocol) Araçları

Platform, AI agent'larınızın kullanabileceği gelişmiş MCP araçları sunar:

- `github_issue_tara/coz`: Otonom GitHub problem çözücü.
- `db_sorgula`: Enterprise DB (Sohbet geçmişi, Ayarlar) sorgulama.
- `terminal_komut`: Güvenli terminal komut çalıştırma.
- `docker_yonet`: Konteyner operasyonları.
- `kod_uret/analiz`: Gelişmiş kodlama asistanı.

---

## 🏛️ Mimari Kararlar (ADR)

Sistem mimarisi, global ölçeklenebilirlik için tasarlanmıştır. Detaylı teknik kararlar için [docs/adr-001-migration-decision.md](file:///c:/Users/win11.2025/Desktop/antygravty google id/universal-llm-mcp/docs/adr-001-migration-decision.md) dosyasını inceleyin.

---

## 📜 Lisans

Bu proje **MIT** lisansı ile sunulmaktadır. "AI-First" geliştirme prensipleriyle inşa edilmiştir.
