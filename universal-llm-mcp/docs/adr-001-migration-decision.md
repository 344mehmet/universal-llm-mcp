# Architecture Decision Record (ADR-001)

## Başlık: Next.js ve Cloudflare D1/Edge Geçiş Kararı

**Durum:** Kabul Edildi (Accepted)
**Tarih:** 2025-12-24
**Yazar:** Senior Engineer (Universal LLM Team)

---

### Bağlam (Context)

Platformun mevcut mimarisi Node.js tabanlı bir monolitik sunucudan oluşmaktadır. Ölçeklenebilirlik, küresel performans (Edge latency) ve kurumsal güvenlik gereksinimleri doğrultusunda sistemin modernize edilmesi gerekmektedir.

### Karar (Decision)

Platformun aşağıdaki teknolojilerle yeniden yapılandırılmasına karar verilmiştir:

1. **Frontend/Backend Framework:** Next.js 15+ (App Router & RSC).
2. **Edge Runtime:** Cloudflare Workers (Latency-critical işlemler için).
3. **Database:** Cloudflare D1 (SQL) + LibSQL (Local development).
4. **ORM:** Drizzle ORM (Type-safety ve lightweight mimari).
5. **Data Fetching:** React Server Components (RSC) ile sunucu taraflı optimizasyon.

### Gerekçe (Rationale)

- **RSC:** Veri alma işlemlerini sunucuda (Edge üzerinde) yaparak istemci yükünü ve gecikmeyi (TTFB) azaltır.
- **Cloudflare Edge:** Global ölçekte düşük gecikmeli erişim ve güvenlik (WAF, DDoS koruma) sağlar.
- **D1:** SQLite tabanlı, düşük maliyetli ve Edge native bir veritabanı çözümüdür.
- **Type Safety:** TypeScript ve Drizzle kombinasyonu, kurumsal düzeyde hata payını minimize eder.

### Sonuçlar (Consequences)

- **Pozitif:** Daha hızlı sayfa yüklemeleri, daha güvenli veri katmanı, kolay CI/CD süreci.
- **Negatif:** Node.js kütüphanelerinin (ağır kütüphaneler) Edge üzerinde çalışmaması durumunda hibrit (Edge + Node.js) yapı yönetimi karmaşıklığı.

---
Döküman versiyonu: 1.0.0
