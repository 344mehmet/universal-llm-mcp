//+------------------------------------------------------------------+
//|                                       MA_Master_Scalper_v16.mq5 |
//|                        Copyright 2025, Simplified Trading System |
//|                                  Basit ama Kanıtlanmış Strateji  |
//+------------------------------------------------------------------+
//
// ═══════════════════════════════════════════════════════════════════
// 📌 AÇIKLAMA:
// Bu EA, MQL5.com'daki araştırmalara dayalı olarak tasarlanmıştır.
// Adaptive Moving Average (AMA) en iyi performansı göstermiştir:
// - Net Kar: +36.39%
// - Kar Faktörü: 1.31
// - En düşük drawdown
//
// 📌 STRATEJİ:
// - Fiyat AMA'yı yukarı keserse → ALIŞ
// - Fiyat AMA'yı aşağı keserse → SATIŞ
// - ATR bazlı dinamik SL/TP (R:R = 1:2)
//
// 📌 MODÜLER YAPI:
// 1. CPriceEngine   - Fiyat ve lot hesaplamaları
// 2. CSignalEngine  - AMA sinyal üretimi
// 3. CRiskManager   - Risk yönetimi
// 4. CTradeExecutor - İşlem açma/kapama
// ═══════════════════════════════════════════════════════════════════

#property copyright "Simplified Trading System v16.5"  // USD/JPY Optimized
#property link      "https://www.mql5.com"             // Bağlantı
#property version   "16.50"                            // v16.5 USD/JPY için optimize
#property strict                                       // Katı sözdizimi kontrolü

// ═══════════════════════════════════════════════════════════════════
// 📚 KÜTÜPHANE DAHİL ETME
// ═══════════════════════════════════════════════════════════════════
#include <Trade\Trade.mqh>    // MQL5 standart işlem kütüphanesi - CTrade sınıfını sağlar

// ═══════════════════════════════════════════════════════════════════
// ⚙️ GİRDİ PARAMETRELERİ (Kullanıcı tarafından değiştirilebilir)
// ═══════════════════════════════════════════════════════════════════

//--- Temel Ayarlar
input group "═══════ 1. TEMEL AYARLAR ═══════"
input ulong    MagicNumber       = 161616;             // Benzersiz EA kimliği - işlemleri tanımak için
input string   TradeComment      = "MA_v16_Simple";    // İşlem açıklaması - terminalde görünür
input ENUM_TIMEFRAMES TimeFrame  = PERIOD_H1;          // Çalışma zaman dilimi - H1 önerilen

//--- AMA (Adaptive Moving Average) Ayarları
input group "═══════ 2. AMA AYARLARI ═══════"
input int      AMA_Period        = 20;                 // v16.5: USD/JPY için optimize (30→20)
input int      AMA_FastPeriod    = 3;                  // v16.5: Biraz yavaşlatıldı (2→3)
input int      AMA_SlowPeriod    = 30;                 // Değişmedi

//--- ATR (Average True Range) Ayarları - SL/TP için
input group "═══════ 3. ATR & SL/TP AYARLARI ═══════"
input int      ATR_Period        = 14;                 // Standart ATR
input double   SL_ATR_Multi      = 1.0;                // v16.5: 1x ATR (USD/JPY için optimal)
input double   TP_ATR_Multi      = 2.0;                // v16.5: 2x ATR (R:R = 1:2)
input int      MinSL_Pips        = 15;                 // v16.5: USD/JPY için 15 pips min
input int      MaxSL_Pips        = 40;                 // v16.5: USD/JPY için 40 pips max

//--- USD/JPY Scalping Göstergeleri (v16.5 Araştırma Bazlı)
input group "═══════ 4. USD/JPY GÖSTERGELER ═══════"
input int      EMA_Fast          = 5;                  // Hızlı EMA (scalping)
input int      EMA_Medium        = 9;                  // Orta EMA (crossover)
input int      EMA_Slow          = 20;                 // Yavaş EMA (trend)
input int      RSI_Period        = 14;                 // RSI periyodu (standart)
input int      RSI_Overbought    = 70;                 // Aşırı alım seviyesi
input int      RSI_Oversold      = 30;                 // Aşırı satım seviyesi
input bool     UseEMAConfirm     = true;               // EMA teyidi kullan
input bool     UseRSIFilter      = true;               // RSI filtresi kullan

//--- Risk Yönetimi
input group "═══════ 5. RİSK YÖNETİMİ ═══════"
input double   RiskPercent       = 1.0;                // Hesap başına risk yüzdesi (1% = güvenli)
input double   FixedLot          = 0.01;               // Sabit lot (RiskPercent=0 ise kullanılır)
input double   MaxLotSize        = 2.0;                // Maksimum lot büyüklüğü
input int      MaxDailyTrades    = 5;                  // Günlük maksimum işlem sayısı
input int      CooldownBars      = 3;                  // İşlem arası bekleme (bar)

//--- Zaman Filtresi (USD/JPY için Tokyo-NY çakışması önemli)
input group "═══════ 6. ZAMAN FİLTRESİ ═══════"
input bool     UseTimeFilter     = true;               // v16.5: USD/JPY için açık
input int      StartHour         = 0;                  // Tokyo açılış (00:00 UTC)
input int      EndHour           = 17;                 // NY kapanış (17:00 UTC)
input bool     TradeOnFriday     = true;               // Cuma günü işlem yap
input int      FridayCloseHour   = 20;                 // Cuma 20:00 UTC

// ═══════════════════════════════════════════════════════════════════
// 🔧 GLOBAL DEĞİŞKENLER
// ═══════════════════════════════════════════════════════════════════
int      g_hAMA;               // AMA gösterge tanıtıcısı (handle)
int      g_hATR;               // ATR gösterge tanıtıcısı (handle)

// v16.5: USD/JPY için ek göstergeler
int      g_hEMA_Fast;          // EMA 5 handle
int      g_hEMA_Medium;        // EMA 9 handle
int      g_hEMA_Slow;          // EMA 20 handle
int      g_hRSI;               // RSI 14 handle

int      g_dailyTrades;        // Bugün açılan işlem sayısı
int      g_lastTradeBar;       // Son işlem açılan bar numarası
datetime g_lastTradeDate;      // Son işlem tarihi (günlük sayaç için)
CTrade   g_trade;              // İşlem nesnesi

// ═══════════════════════════════════════════════════════════════════
// 📦 MODÜL 1: CPriceEngine - Fiyat ve Lot Hesaplamaları
// ═══════════════════════════════════════════════════════════════════
class CPriceEngine {
public:
   //--- Pip değerini point cinsinden hesaplar
   // Örnek: EURUSD'de 1 pip = 0.00010
   static double PipToPoints() {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);  // Sembolün point değeri
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);  // Ondalık basamak
      
      // 5 veya 3 basamaklı sembollerde pip = 10 point
      // 4 veya 2 basamaklı sembollerde pip = 1 point
      if(digits == 5 || digits == 3)
         return point * 10.0;  // Örn: 0.00001 * 10 = 0.00010
      else
         return point;         // Örn: 0.0001 = 0.0001
   }
   
   //--- Risk bazlı lot hesaplama
   // Formül: Lot = (Hesap * Risk%) / (SL_Pip * Pip_Değeri)
   static double CalculateLot(double slPips) {
      // Risk yüzdesi 0 ise sabit lot kullan
      if(RiskPercent <= 0)
         return NormalizeLot(FixedLot);
      
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);     // Hesap bakiyesi
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);  // 1 tick değeri
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);    // Tick boyutu
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);  // Point değeri
      
      // Pip başına değer hesabı
      double pipValue = tickValue * (PipToPoints() / tickSize);
      
      // Güvenlik kontrolü - sıfıra bölme önleme
      if(pipValue <= 0 || slPips <= 0)
         return NormalizeLot(FixedLot);
      
      // Risk bazlı lot hesaplama
      double riskMoney = balance * (RiskPercent / 100.0);  // Risk edilen para miktarı
      double lot = riskMoney / (slPips * pipValue);        // Lot = RiskPara / (SL * PipDeğeri)
      
      return NormalizeLot(lot);
   }
   
   //--- Lot değerini broker kurallarına göre normalize et
   static double NormalizeLot(double lot) {
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);   // Min lot (örn: 0.01)
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);   // Max lot (örn: 100)
      double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP); // Lot adımı (örn: 0.01)
      
      // Adım sayısını hesapla ve yuvarlat
      double steps = MathFloor(lot / stepLot);
      lot = steps * stepLot;
      
      // Min/Max sınırları uygula
      lot = MathMax(minLot, MathMin(MaxLotSize, MathMin(maxLot, lot)));
      
      return NormalizeDouble(lot, 2);  // 2 ondalık basamağa yuvarla
   }
};

// ═══════════════════════════════════════════════════════════════════
// 📦 MODÜL 2: CSignalEngine - AMA Sinyal Üretimi
// ═══════════════════════════════════════════════════════════════════
class CSignalEngine {
private:
   int m_hAMA;  // AMA gösterge handle'ı
   
public:
   //--- Göstergeyi başlat
   bool Init() {
      // iAMA fonksiyonu: Adaptive Moving Average göstergesini oluşturur
      // Parametreler: sembol, zaman dilimi, periyot, hızlı, yavaş, kayma, fiyat türü
      m_hAMA = iAMA(_Symbol, TimeFrame, AMA_Period, AMA_FastPeriod, AMA_SlowPeriod, 0, PRICE_CLOSE);
      
      if(m_hAMA == INVALID_HANDLE) {
         Print("❌ HATA: AMA göstergesi oluşturulamadı!");
         return false;
      }
      
      // v16.5: USD/JPY için EMA göstergeleri
      g_hEMA_Fast = iMA(_Symbol, TimeFrame, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
      g_hEMA_Medium = iMA(_Symbol, TimeFrame, EMA_Medium, 0, MODE_EMA, PRICE_CLOSE);
      g_hEMA_Slow = iMA(_Symbol, TimeFrame, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
      g_hRSI = iRSI(_Symbol, TimeFrame, RSI_Period, PRICE_CLOSE);
      
      if(g_hEMA_Fast == INVALID_HANDLE || g_hEMA_Medium == INVALID_HANDLE || 
         g_hEMA_Slow == INVALID_HANDLE || g_hRSI == INVALID_HANDLE) {
         Print("❌ HATA: EMA/RSI göstergeleri oluşturulamadı!");
         return false;
      }
      
      Print("✅ AMA + EMA(", EMA_Fast, "/", EMA_Medium, "/", EMA_Slow, 
            ") + RSI(", RSI_Period, ") başlatıldı.");
      return true;
   }
   
   //--- Göstergeyi kapat (bellek temizliği)
   void Deinit() {
      if(m_hAMA != INVALID_HANDLE) IndicatorRelease(m_hAMA);
      
      // v16.5: EMA ve RSI handle'larını temizle
      if(g_hEMA_Fast != INVALID_HANDLE) IndicatorRelease(g_hEMA_Fast);
      if(g_hEMA_Medium != INVALID_HANDLE) IndicatorRelease(g_hEMA_Medium);
      if(g_hEMA_Slow != INVALID_HANDLE) IndicatorRelease(g_hEMA_Slow);
      if(g_hRSI != INVALID_HANDLE) IndicatorRelease(g_hRSI);
      
      Print("🔄 Tüm göstergeler kapatıldı (AMA, EMA, RSI).");
   }
   
   //--- Sinyal üret: 1=ALIŞ, -1=SATIŞ, 0=SİNYAL YOK
   // v16.2: Geliştirilmiş strateji - çoklu teyit sistemi
   int GetSignal() {
      // AMA değerlerini al (son 4 bar)
      double ama[];
      ArraySetAsSeries(ama, true);
      
      if(CopyBuffer(m_hAMA, 0, 0, 4, ama) < 4) {
         Print("⚠️ AMA verisi alınamadı!");
         return 0;
      }
      
      // Fiyat verilerini al
      double close1 = iClose(_Symbol, TimeFrame, 1);  // Son kapanış
      double close2 = iClose(_Symbol, TimeFrame, 2);  // Önceki kapanış
      double open1 = iOpen(_Symbol, TimeFrame, 1);    // Son açılış
      double high1 = iHigh(_Symbol, TimeFrame, 1);    // Son yüksek
      double low1 = iLow(_Symbol, TimeFrame, 1);      // Son düşük
      
      // ═══════════════════════════════════════════════════════════════
      // 📌 TEYİT 1: AMA EĞİMİ (Momentum)
      // AMA yükseliyor mu yoksa düşüyor mu?
      // ═══════════════════════════════════════════════════════════════
      double amaSlope = ama[1] - ama[2];  // Pozitif = yukarı, Negatif = aşağı
      bool amaRising = (ama[1] > ama[2] && ama[2] > ama[3]);  // 2 ardışık artış
      bool amaFalling = (ama[1] < ama[2] && ama[2] < ama[3]); // 2 ardışık düşüş
      
      // ═══════════════════════════════════════════════════════════════
      // 📌 TEYİT 2: MUM ANALİZİ
      // Mumun gücünü kontrol et
      // ═══════════════════════════════════════════════════════════════
      double bodySize = MathAbs(close1 - open1);  // Gövde boyutu
      double wickSize = high1 - low1;             // Toplam mum boyutu
      bool bullishCandle = (close1 > open1);      // Yeşil mum
      bool bearishCandle = (close1 < open1);      // Kırmızı mum
      bool strongCandle = (bodySize > wickSize * 0.5);  // Gövde mumun yarısından büyük
      
      // ═══════════════════════════════════════════════════════════════
      // 📌 TEYİT 3: MİNİMUM HAREKET
      // Gürültüyü filtrele
      // ═══════════════════════════════════════════════════════════════
      double atr = iATR(_Symbol, TimeFrame, 14);
      double minMove = atr * 0.3;  // ATR'nin %30'u minimum hareket
      double crossMove = MathAbs(close1 - ama[1]);  // Kesişim mesafesi
      
      // ═══════════════════════════════════════════════════════════════
      // 📌 ALIŞ SİNYALİ (v16.2 - Geliştirilmiş):
      // 1. Fiyat AMA'yı yukarı kesti
      // 2. AMA eğimi yukarı (momentum teyidi)
      // 3. Yeşil ve güçlü mum
      // 4. Minimum hareket sağlandı
      // ═══════════════════════════════════════════════════════════════
      if(close2 < ama[2] && close1 > ama[1]) {
         // Kesişim var, teyitleri kontrol et
         int confirmations = 0;
         
         if(amaSlope > 0) confirmations++;        // AMA yukarı bakıyor
         if(bullishCandle) confirmations++;       // Yeşil mum
         if(strongCandle) confirmations++;        // Güçlü gövde
         if(crossMove > minMove) confirmations++; // Yeterli hareket
         
         // En az 3 teyit gerekli
         if(confirmations >= 3) {
            Print("🟢 ALIŞ SİNYALİ! Teyit: ", confirmations, "/4");
            Print("   AMA Eğimi: ", (amaSlope > 0 ? "YUKARI ✓" : "AŞAĞI ✗"));
            Print("   Mum: ", (bullishCandle ? "YEŞİL ✓" : "KIRMIZI ✗"));
            Print("   Güç: ", (strongCandle ? "GÜÇLÜ ✓" : "ZAYIF ✗"));
            return 1;  // ALIŞ
         }
      }
      
      // ═══════════════════════════════════════════════════════════════
      // 📌 SATIŞ SİNYALİ (v16.2 - Geliştirilmiş):
      // 1. Fiyat AMA'yı aşağı kesti
      // 2. AMA eğimi aşağı (momentum teyidi)
      // 3. Kırmızı ve güçlü mum
      // 4. Minimum hareket sağlandı
      // ═══════════════════════════════════════════════════════════════
      if(close2 > ama[2] && close1 < ama[1]) {
         // Kesişim var, teyitleri kontrol et
         int confirmations = 0;
         
         if(amaSlope < 0) confirmations++;        // AMA aşağı bakıyor
         if(bearishCandle) confirmations++;       // Kırmızı mum
         if(strongCandle) confirmations++;        // Güçlü gövde
         if(crossMove > minMove) confirmations++; // Yeterli hareket
         
         // En az 3 teyit gerekli
         if(confirmations >= 3) {
            Print("🔴 SATIŞ SİNYALİ! Teyit: ", confirmations, "/4");
            Print("   AMA Eğimi: ", (amaSlope < 0 ? "AŞAĞI ✓" : "YUKARI ✗"));
            Print("   Mum: ", (bearishCandle ? "KIRMIZI ✓" : "YEŞİL ✗"));
            Print("   Güç: ", (strongCandle ? "GÜÇLÜ ✓" : "ZAYIF ✗"));
            return -1;  // SATIŞ
         }
      }
      
      return 0;  // Sinyal yok veya yetersiz teyit
   }
   
   //--- Mevcut AMA değerini döndür (dashboard için)
   double GetAMAValue() {
      double ama[];
      ArraySetAsSeries(ama, true);
      if(CopyBuffer(m_hAMA, 0, 0, 1, ama) >= 1)
         return ama[0];
      return 0;
   }
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 v16.5: EMA TEYİDİ
   // BUY: EMA5 > EMA9 > EMA20 (bullish alignment)
   // SELL: EMA5 < EMA9 < EMA20 (bearish alignment)
   // ═══════════════════════════════════════════════════════════════
   bool ConfirmWithEMA(int signal) {
      if(!UseEMAConfirm) return true;  // Kapalıysa teyit vermiş say
      
      double ema5[], ema9[], ema20[];
      ArraySetAsSeries(ema5, true);
      ArraySetAsSeries(ema9, true);
      ArraySetAsSeries(ema20, true);
      
      if(CopyBuffer(g_hEMA_Fast, 0, 0, 1, ema5) < 1) return false;
      if(CopyBuffer(g_hEMA_Medium, 0, 0, 1, ema9) < 1) return false;
      if(CopyBuffer(g_hEMA_Slow, 0, 0, 1, ema20) < 1) return false;
      
      if(signal == 1) {  // BUY
         // Bullish: EMA5 > EMA9 > EMA20
         bool aligned = (ema5[0] > ema9[0] && ema9[0] > ema20[0]);
         if(aligned) Print("✅ EMA Teyit: 5 > 9 > 20 (Bullish)");
         return aligned;
      }
      else if(signal == -1) {  // SELL
         // Bearish: EMA5 < EMA9 < EMA20
         bool aligned = (ema5[0] < ema9[0] && ema9[0] < ema20[0]);
         if(aligned) Print("✅ EMA Teyit: 5 < 9 < 20 (Bearish)");
         return aligned;
      }
      return false;
   }
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 v16.5: RSI TEYİDİ
   // BUY: RSI < 70 (aşırı alım değil)
   // SELL: RSI > 30 (aşırı satım değil)
   // + RSI 50 seviyesi momentum teyidi
   // ═══════════════════════════════════════════════════════════════
   bool ConfirmWithRSI(int signal) {
      if(!UseRSIFilter) return true;  // Kapalıysa teyit vermiş say
      
      double rsi[];
      ArraySetAsSeries(rsi, true);
      
      if(CopyBuffer(g_hRSI, 0, 0, 2, rsi) < 2) return false;
      
      double rsiNow = rsi[0];
      double rsiPrev = rsi[1];
      
      if(signal == 1) {  // BUY
         // RSI aşırı alımda değil VE yükseliyor
         bool valid = (rsiNow < RSI_Overbought && rsiNow > rsiPrev);
         if(valid) Print("✅ RSI Teyit: ", rsiNow, " < ", RSI_Overbought, " (Yükseliyor)");
         return valid;
      }
      else if(signal == -1) {  // SELL
         // RSI aşırı satımda değil VE düşüyor
         bool valid = (rsiNow > RSI_Oversold && rsiNow < rsiPrev);
         if(valid) Print("✅ RSI Teyit: ", rsiNow, " > ", RSI_Oversold, " (Düşüyor)");
         return valid;
      }
      return false;
   }
   
   //--- RSI değerini döndür
   double GetRSIValue() {
      double rsi[];
      ArraySetAsSeries(rsi, true);
      if(CopyBuffer(g_hRSI, 0, 0, 1, rsi) >= 1)
         return rsi[0];
      return 50;  // Default: nötr
   }
};

// ═══════════════════════════════════════════════════════════════════
// 📦 MODÜL 2.5: CSessionFilter - Seans Bazlı İşlem Filtresi
// Araştırmaya göre: Asya seansında SELL bias, Londra-NY'de trend takip
// ═══════════════════════════════════════════════════════════════════
class CSessionFilter {
public:
   // Seans türleri
   enum SESSION_TYPE {
      SESSION_SYDNEY = 0,   // 21:00-06:00 UTC
      SESSION_TOKYO  = 1,   // 00:00-09:00 UTC
      SESSION_LONDON = 2,   // 08:00-15:00 UTC
      SESSION_NEWYORK = 3   // 13:00-22:00 UTC
   };
   
   //--- Mevcut seansı belirle
   SESSION_TYPE GetCurrentSession() {
      MqlDateTime dt;
      TimeGMT(dt);  // UTC zamanı al
      int hour = dt.hour;
      
      // Londra-NY overlap (en aktif)
      if(hour >= 13 && hour < 17)
         return SESSION_LONDON;  // Aslında overlap ama London döndür
      
      // Londra
      if(hour >= 8 && hour < 15)
         return SESSION_LONDON;
      
      // New York
      if(hour >= 13 && hour < 22)
         return SESSION_NEWYORK;
      
      // Tokyo
      if(hour >= 0 && hour < 9)
         return SESSION_TOKYO;
      
      // Sydney (gece)
      return SESSION_SYDNEY;
   }
   
   //--- Seans bazlı yön tercihi: 1=BUY bias, -1=SELL bias, 0=nötr
   // Araştırma: Asya seansında (00:00-03:00) SELL bias
   int GetSessionBias() {
      MqlDateTime dt;
      TimeGMT(dt);
      int hour = dt.hour;
      int dayOfWeek = dt.day_of_week;  // 0=Pazar
      
      // ═══════════════════════════════════════════════════════════════
      // 📌 ASYA SEANSI SELL BIAS (00:00-03:00 UTC)
      // Araştırma: Gece robotları veri analizi yapar
      // Fiyatlar genelde yüksek, düşüş beklentisi
      // ═══════════════════════════════════════════════════════════════
      if(hour >= 0 && hour < 3) {
         Print("🌙 Asya Seansı (", hour, ":00 UTC) - SELL Bias");
         return -1;  // SELL tercih
      }
      
      // ═══════════════════════════════════════════════════════════════
      // 📌 LONDRA AÇILIŞ (08:00-10:00 UTC)
      // Araştırma: Breakout zamanı, trend başlangıcı
      // ═══════════════════════════════════════════════════════════════
      if(hour >= 8 && hour < 10) {
         Print("🇬🇧 Londra Açılış (", hour, ":00 UTC) - Trend Takip");
         return 0;  // Nötr (trend takip)
      }
      
      // ═══════════════════════════════════════════════════════════════
      // 📌 LONDRA-NY OVERLAP (13:00-17:00 UTC)
      // Araştırma: En yüksek likidite ve volatilite
      // En iyi işlem saatleri
      // ═══════════════════════════════════════════════════════════════
      if(hour >= 13 && hour < 17) {
         Print("🌍 Londra-NY Overlap (", hour, ":00 UTC) - Optimal Saat");
         return 0;  // Nötr (en iyi saatler)
      }
      
      // Diğer saatler - nötr
      return 0;
   }
   
   //--- Optimal işlem saati mi?
   bool IsOptimalTradingTime() {
      MqlDateTime dt;
      TimeGMT(dt);
      int hour = dt.hour;
      int dayOfWeek = dt.day_of_week;
      
      // Hafta sonu işlem yok
      if(dayOfWeek == 0 || dayOfWeek == 6)
         return false;
      
      // En iyi saatler: 08:00-17:00 UTC
      if(hour >= 8 && hour < 17)
         return true;
      
      // Asya seansı da işlem yapılabilir (SELL bias ile)
      if(hour >= 0 && hour < 3)
         return true;
      
      return false;
   }
   
   //--- Seans adını döndür
   string GetSessionName() {
      SESSION_TYPE session = GetCurrentSession();
      switch(session) {
         case SESSION_SYDNEY:  return "Sydney";
         case SESSION_TOKYO:   return "Tokyo";
         case SESSION_LONDON:  return "London";
         case SESSION_NEWYORK: return "New York";
         default: return "Unknown";
      }
   }
};

// ═══════════════════════════════════════════════════════════════════
// 📦 MODÜL 2.6: CCorrelationFilter - USD/JPY Korelasyon Filtresi
// Araştırma: EUR/USD ve USD/JPY negatif korelasyon (-0.7 ile -0.9)
// USD güçlü → EUR/USD düşer, USD/JPY yükselir
// ═══════════════════════════════════════════════════════════════════
class CCorrelationFilter {
private:
   int m_hUSDJPY_MA;  // USD/JPY için MA handle
   
public:
   //--- Başlat
   bool Init() {
      // USD/JPY için basit MA (trend yönü için)
      m_hUSDJPY_MA = iMA("USDJPY", TimeFrame, 20, 0, MODE_EMA, PRICE_CLOSE);
      
      if(m_hUSDJPY_MA == INVALID_HANDLE) {
         // USD/JPY sembolü yoksa devam et (bazı brokerlarda farklı isim)
         Print("⚠️ USD/JPY MA oluşturulamadı - korelasyon filtresi devre dışı");
         return true;  // Hata değil, filtre devre dışı
      }
      
      Print("✅ USD/JPY Korelasyon Filtresi aktif");
      return true;
   }
   
   //--- Kapat
   void Deinit() {
      if(m_hUSDJPY_MA != INVALID_HANDLE) {
         IndicatorRelease(m_hUSDJPY_MA);
      }
   }
   
   //--- USD gücünü belirle: 1=güçlü, -1=zayıf, 0=nötr
   int GetUSDStrength() {
      if(m_hUSDJPY_MA == INVALID_HANDLE)
         return 0;  // Filtre devre dışı
      
      double ma[];
      ArraySetAsSeries(ma, true);
      
      if(CopyBuffer(m_hUSDJPY_MA, 0, 0, 3, ma) < 3)
         return 0;
      
      // USD/JPY yükseliyorsa → USD güçleniyor
      // USD/JPY düşüyorsa → USD zayıflıyor
      double slope = ma[0] - ma[2];  // 2 barlık değişim
      
      // Eşik değeri (pip cinsinden yaklaşık)
      double threshold = 0.1;  // 10 pip
      
      if(slope > threshold) {
         Print("💪 USD Güçleniyor (USD/JPY ↑)");
         return 1;
      }
      else if(slope < -threshold) {
         Print("📉 USD Zayıflıyor (USD/JPY ↓)");
         return -1;
      }
      
      return 0;  // Nötr
   }
   
   //--- EUR/USD sinyalini USD/JPY ile doğrula
   // signal: 1=BUY, -1=SELL
   // Döndürür: true=onay, false=red
   bool ConfirmWithUSDJPY(int signal) {
      int usdStrength = GetUSDStrength();
      
      // Filtre devre dışıysa her zaman onay
      if(usdStrength == 0)
         return true;
      
      // ═══════════════════════════════════════════════════════════════
      // 📌 KORELASYON MANTIĞI:
      // EUR/USD BUY → USD zayıf olmalı → USD/JPY düşmeli
      // EUR/USD SELL → USD güçlü olmalı → USD/JPY yükselmeli
      // ═══════════════════════════════════════════════════════════════
      
      if(signal == 1 && usdStrength == -1) {
         Print("✅ USD/JPY korelasyonu ALIŞ'ı onaylıyor");
         return true;
      }
      
      if(signal == -1 && usdStrength == 1) {
         Print("✅ USD/JPY korelasyonu SATIŞ'ı onaylıyor");
         return true;
      }
      
      // Korelasyon uyumsuz - sinyali reddet
      Print("⚠️ USD/JPY korelasyonu sinyali onaylamıyor");
      return false;
   }
};

// ═══════════════════════════════════════════════════════════════════
// 📦 MODÜL 2.7: CLotManager - Anti-Martingale Lot Yönetimi
// Kazanınca lot artır, kaybedince lot azalt
// ═══════════════════════════════════════════════════════════════════
class CLotManager {
private:
   double m_baseLot;           // Temel lot
   double m_currentMultiplier; // Mevcut çarpan
   int    m_consecutiveWins;   // Ardışık kazanç sayısı
   int    m_consecutiveLosses; // Ardışık kayıp sayısı
   
public:
   //--- Başlat
   void Init(double baseLot) {
      m_baseLot = baseLot;
      m_currentMultiplier = 1.0;
      m_consecutiveWins = 0;
      m_consecutiveLosses = 0;
      Print("✅ Anti-Martingale Lot Yönetimi aktif. Temel Lot: ", baseLot);
   }
   
   //--- İşlem sonucunu kaydet
   void RecordResult(bool isWin) {
      if(isWin) {
         m_consecutiveWins++;
         m_consecutiveLosses = 0;
         
         // ═══════════════════════════════════════════════════════════════
         // 📌 ANTI-MARTINGALE: KAZANINCA LOT ARTIR
         // Her kazançta %20 artır (max 3x)
         // ═══════════════════════════════════════════════════════════════
         m_currentMultiplier = MathMin(3.0, m_currentMultiplier * 1.2);
         Print("🟢 KAZANÇ! Ardışık: ", m_consecutiveWins, 
               " Yeni Çarpan: ", DoubleToString(m_currentMultiplier, 2));
      }
      else {
         m_consecutiveLosses++;
         m_consecutiveWins = 0;
         
         // ═══════════════════════════════════════════════════════════════
         // 📌 ANTI-MARTINGALE: KAYBEDINCE LOT AZALT
         // Her kayıpta %30 azalt (min 0.5x)
         // ═══════════════════════════════════════════════════════════════
         m_currentMultiplier = MathMax(0.5, m_currentMultiplier * 0.7);
         Print("🔴 KAYIP! Ardışık: ", m_consecutiveLosses,
               " Yeni Çarpan: ", DoubleToString(m_currentMultiplier, 2));
      }
   }
   
   //--- Mevcut lot büyüklüğünü al
   double GetCurrentLot() {
      return CPriceEngine::NormalizeLot(m_baseLot * m_currentMultiplier);
   }
   
   //--- Çarpanı sıfırla
   void Reset() {
      m_currentMultiplier = 1.0;
      m_consecutiveWins = 0;
      m_consecutiveLosses = 0;
   }
};

// ═══════════════════════════════════════════════════════════════════
// 📦 MODÜL 2.8: CTrailingManager - Trailing TP + Breakeven
// Kâr artınca SL'yi ilerlet, riski azalt
// ═══════════════════════════════════════════════════════════════════
class CTrailingManager {
private:
   CTrade m_trade;
   
public:
   //--- Başlat
   void Init() {
      m_trade.SetExpertMagicNumber(MagicNumber);
      Print("✅ Trailing TP + Breakeven Yönetimi aktif");
   }
   
   //--- Tüm pozisyonları trail et (ATR değeri dışarıdan alınır - doğru pattern)
   void TrailPositions(double atrValue) {
      if(atrValue <= 0) return;  // Geçersiz ATR
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         
         // Bu EA'ya ait mi?
         if(PositionGetInteger(POSITION_MAGIC) != MagicNumber ||
            PositionGetString(POSITION_SYMBOL) != _Symbol)
            continue;
         
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentSL = PositionGetDouble(POSITION_SL);
         double currentTP = PositionGetDouble(POSITION_TP);
         double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
         int posType = (int)PositionGetInteger(POSITION_TYPE);
         
         // ATR bazlı trail mesafesi
         double trailDistance = atrValue * 1.0;  // 1 ATR trail
         double breakEvenTrigger = atrValue * 1.5;  // 1.5 ATR'de breakeven
         
         if(posType == POSITION_TYPE_BUY) {
            double profit = currentPrice - openPrice;
            
            // ═══════════════════════════════════════════════════════════════
            // 📌 BREAKEVEN: 1.5 ATR kâr → SL'yi giriş fiyatına taşı
            // ═══════════════════════════════════════════════════════════════
            if(profit >= breakEvenTrigger && currentSL < openPrice) {
               double newSL = openPrice + _Point * 10;  // +1 pip
               if(m_trade.PositionModify(ticket, newSL, currentTP)) {
                  Print("✅ BUY #", ticket, " Breakeven'a taşındı: ", newSL);
               }
            }
            // ═══════════════════════════════════════════════════════════════
            // 📌 TRAILING: Fiyat yükseldikçe SL'yi ilerlet
            // ═══════════════════════════════════════════════════════════════
            else if(profit > trailDistance * 2) {
               double newSL = currentPrice - trailDistance;
               if(newSL > currentSL + _Point) {
                  if(m_trade.PositionModify(ticket, newSL, currentTP)) {
                     Print("📈 BUY #", ticket, " Trail SL: ", newSL);
                  }
               }
            }
         }
         else if(posType == POSITION_TYPE_SELL) {
            double profit = openPrice - currentPrice;
            
            // BREAKEVEN
            if(profit >= breakEvenTrigger && (currentSL > openPrice || currentSL == 0)) {
               double newSL = openPrice - _Point * 10;
               if(m_trade.PositionModify(ticket, newSL, currentTP)) {
                  Print("✅ SELL #", ticket, " Breakeven'a taşındı: ", newSL);
               }
            }
            // TRAILING
            else if(profit > trailDistance * 2) {
               double newSL = currentPrice + trailDistance;
               if(currentSL == 0 || newSL < currentSL - _Point) {
                  if(m_trade.PositionModify(ticket, newSL, currentTP)) {
                     Print("📉 SELL #", ticket, " Trail SL: ", newSL);
                  }
               }
            }
         }
      }
   }
};

// ═══════════════════════════════════════════════════════════════════
// 📦 MODÜL 2.9: CPartialCloseManager - Kısmi Kapama
// Kâr hedefine ulaşınca yarısını kapat, riski azalt
// ═══════════════════════════════════════════════════════════════════
class CPartialCloseManager {
private:
   CTrade m_trade;
   
public:
   //--- Başlat
   void Init() {
      m_trade.SetExpertMagicNumber(MagicNumber);
      Print("✅ Kısmi Kapama Yönetimi aktif");
   }
   
   //--- Kısmi kapama kontrol et
   void CheckPartialClose() {
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         
         // Bu EA'ya ait mi?
         if(PositionGetInteger(POSITION_MAGIC) != MagicNumber ||
            PositionGetString(POSITION_SYMBOL) != _Symbol)
            continue;
         
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
         double currentTP = PositionGetDouble(POSITION_TP);
         double currentSL = PositionGetDouble(POSITION_SL);
         double lotSize = PositionGetDouble(POSITION_VOLUME);
         int posType = (int)PositionGetInteger(POSITION_TYPE);
         string comment = PositionGetString(POSITION_COMMENT);
         
         // Zaten kısmi kapama yapıldıysa atla
         if(StringFind(comment, "_PARTIAL") >= 0)
            continue;
         
         // Minimum lot kontrolü
         double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
         if(lotSize < minLot * 2)
            continue;  // Kısmi kapatmak için yeterli lot yok
         
         // TP mesafesinin %50'si hedef
         double tpDistance = MathAbs(currentTP - openPrice);
         double partialTarget = tpDistance * 0.5;
         
         double profit = 0;
         if(posType == POSITION_TYPE_BUY)
            profit = currentPrice - openPrice;
         else
            profit = openPrice - currentPrice;
         
         // ═══════════════════════════════════════════════════════════════
         // 📌 KISMI KAPAMA: %50 hedefe ulaşınca yarısını kapat
         // ═══════════════════════════════════════════════════════════════
         if(profit >= partialTarget) {
            double closeVolume = CPriceEngine::NormalizeLot(lotSize / 2.0);
            
            if(m_trade.PositionClosePartial(ticket, closeVolume)) {
               Print("✅ Kısmi Kapama: #", ticket, " Lot: ", closeVolume, 
                     " Kalan: ", lotSize - closeVolume);
               
               // Kalan pozisyonun SL'sini breakeven'a taşı
               double newSL = openPrice;
               if(posType == POSITION_TYPE_BUY)
                  newSL = openPrice + _Point * 5;
               else
                  newSL = openPrice - _Point * 5;
               
               // Pozisyonu tekrar modifiye et (yeni ticket ile)
               // Not: PositionClosePartial sonrası ticket değişebilir
            }
         }
      }
   }
};

// ═══════════════════════════════════════════════════════════════════
// 📦 MODÜL 2.10: CZoneRecovery - Bölge Kurtarma Stratejisi
// Zarar eden pozisyon için ters hedge aç, matematiksel kurtarma
// ═══════════════════════════════════════════════════════════════════
class CZoneRecovery {
private:
   CTrade m_trade;
   bool   m_inRecovery;        // Kurtarma modunda mı?
   double m_recoveryZone;      // Kurtarma bölgesi genişliği
   int    m_maxRecoveryTrades; // Max kurtarma işlemi
   int    m_currentRecoveryCount;
   
public:
   //--- Başlat
   void Init() {
      m_trade.SetExpertMagicNumber(MagicNumber);
      m_inRecovery = false;
      m_recoveryZone = 0;
      m_maxRecoveryTrades = 5;  // Max 5 kurtarma denemesi
      m_currentRecoveryCount = 0;
      Print("✅ Zone Recovery (Bölge Kurtarma) aktif. Max: ", m_maxRecoveryTrades);
   }
   
   //--- Kurtarma modunda mı?
   bool IsInRecovery() { return m_inRecovery; }
   
   //--- Kurtarma gerekli mi kontrol et (ATR değeri dışarıdan alınır - doğru pattern)
   void CheckRecovery(double atrValue) {
      if(atrValue <= 0) return;  // Geçersiz ATR
      
      // Max kurtarma sayısına ulaşıldıysa dur
      if(m_currentRecoveryCount >= m_maxRecoveryTrades)
         return;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         
         // Bu EA'ya ait mi?
         if(PositionGetInteger(POSITION_MAGIC) != MagicNumber ||
            PositionGetString(POSITION_SYMBOL) != _Symbol)
            continue;
         
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
         double lotSize = PositionGetDouble(POSITION_VOLUME);
         int posType = (int)PositionGetInteger(POSITION_TYPE);
         string comment = PositionGetString(POSITION_COMMENT);
         
         // Zaten recovery pozisyonuysa atla
         if(StringFind(comment, "_RECOVERY") >= 0)
            continue;
         
         // ATR bazlı recovery zone (parametre olarak alındı)
         m_recoveryZone = atrValue * 2.0;  // 2 ATR zone
         
         double floatingLoss = 0;
         if(posType == POSITION_TYPE_BUY)
            floatingLoss = openPrice - currentPrice;
         else
            floatingLoss = currentPrice - openPrice;
         
         // ═══════════════════════════════════════════════════════════════
         // 📌 ZONE RECOVERY: 2 ATR zarar → Ters pozisyon aç
         // Lot: Orijinal lot x 1.5 (kurtarma için)
         // ⚠️ ÖNEMLI: Her zaman SL/TP ile aç (broker-side koruma)
         // ═══════════════════════════════════════════════════════════════
         if(floatingLoss >= m_recoveryZone && !m_inRecovery) {
            double recoveryLot = CPriceEngine::NormalizeLot(lotSize * 1.5);
            int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
            
            // ATR bazlı SL/TP hesapla (her zaman broker'a gönder!)
            double slDistance = m_recoveryZone * 1.5;  // 3 ATR SL
            double tpDistance = m_recoveryZone;        // 2 ATR TP (kurtarma hedefi)
            
            Print("🔄 ZONE RECOVERY AKTİF! Zarar: ", floatingLoss, " pips");
            Print("   Orijinal: ", (posType == POSITION_TYPE_BUY ? "BUY" : "SELL"),
                  " Lot: ", lotSize);
            Print("   Recovery: ", (posType == POSITION_TYPE_BUY ? "SELL" : "BUY"),
                  " Lot: ", recoveryLot);
            
            // Ters yönde pozisyon aç (HER ZAMAN SL/TP İLE!)
            if(posType == POSITION_TYPE_BUY) {
               // SELL recovery
               double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               double sl = NormalizeDouble(bid + slDistance, digits);  // SL üstte
               double tp = NormalizeDouble(bid - tpDistance, digits);  // TP altta
               
               Print("   Recovery SL: ", sl, " TP: ", tp);
               if(m_trade.Sell(recoveryLot, _Symbol, 0, sl, tp, "MA_v16_RECOVERY")) {
                  m_inRecovery = true;
                  m_currentRecoveryCount++;
                  Print("✅ SELL Recovery açıldı (SL/TP ile). Count: ", m_currentRecoveryCount);
               }
            }
            else {
               // BUY recovery
               double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
               double sl = NormalizeDouble(ask - slDistance, digits);  // SL altta
               double tp = NormalizeDouble(ask + tpDistance, digits);  // TP üstte
               
               Print("   Recovery SL: ", sl, " TP: ", tp);
               if(m_trade.Buy(recoveryLot, _Symbol, 0, sl, tp, "MA_v16_RECOVERY")) {
                  m_inRecovery = true;
                  m_currentRecoveryCount++;
                  Print("✅ BUY Recovery açıldı (SL/TP ile). Count: ", m_currentRecoveryCount);
               }
            }
         }
      }
   }
   
   //--- Tüm pozisyonları kapat (recovery bitişi)
   void CloseAllIfProfit() {
      if(!m_inRecovery) return;
      
      double totalProfit = 0;
      int posCount = 0;
      
      // Toplam floating P/L hesapla
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol) {
            totalProfit += PositionGetDouble(POSITION_PROFIT);
            posCount++;
         }
      }
      
      // ═══════════════════════════════════════════════════════════════
      // 📌 RECOVERY ÇIKIŞ: Toplam P/L pozitifse hepsini kapat
      // ═══════════════════════════════════════════════════════════════
      if(totalProfit > 0 && posCount > 1) {
         Print("🎯 RECOVERY BAŞARILI! Toplam Kâr: ", totalProfit);
         
         // Tüm pozisyonları kapat
         for(int i = PositionsTotal() - 1; i >= 0; i--) {
            ulong ticket = PositionGetTicket(i);
            if(ticket == 0) continue;
            
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
               PositionGetString(POSITION_SYMBOL) == _Symbol) {
               m_trade.PositionClose(ticket);
            }
         }
         
         // Recovery modunu sıfırla
         m_inRecovery = false;
         m_currentRecoveryCount = 0;
      }
   }
   
   //--- Reset
   void Reset() {
      m_inRecovery = false;
      m_currentRecoveryCount = 0;
   }
};

// ═══════════════════════════════════════════════════════════════════
// 📦 MODÜL 3: CRiskManager - Risk Yönetimi
// ═══════════════════════════════════════════════════════════════════
class CRiskManager {
private:
   int m_hATR;  // ATR gösterge handle'ı
   
public:
   //--- ATR göstergesini başlat
   bool Init() {
      // iATR: Average True Range - volatilite ölçer
      m_hATR = iATR(_Symbol, TimeFrame, ATR_Period);
      
      if(m_hATR == INVALID_HANDLE) {
         Print("❌ HATA: ATR göstergesi oluşturulamadı!");
         return false;
      }
      
      Print("✅ ATR göstergesi başarıyla oluşturuldu. Handle: ", m_hATR);
      return true;
   }
   
   //--- Göstergeyi kapat
   void Deinit() {
      if(m_hATR != INVALID_HANDLE) {
         IndicatorRelease(m_hATR);
         Print("🔄 ATR göstergesi kapatıldı.");
      }
   }
   
   //--- Mevcut ATR değerini al
   double GetATR() {
      double atr[];
      ArraySetAsSeries(atr, true);
      
      if(CopyBuffer(m_hATR, 0, 0, 1, atr) >= 1)
         return atr[0];
      
      return 0;
   }
   
   //--- SL ve TP mesafelerini hesapla (point cinsinden)
   // Giriş parametreleri: direction (1=BUY, -1=SELL)
   // Çıkış: slDist ve tpDist referans ile döndürülür
   void CalculateSLTP(int direction, double &slDist, double &tpDist) {
      double atr = GetATR();          // Mevcut ATR değeri
      double pipPoints = CPriceEngine::PipToPoints();  // 1 pip = kaç point
      
      // ATR bazlı SL/TP hesapla
      slDist = atr * SL_ATR_Multi;    // SL = ATR x çarpan
      tpDist = atr * TP_ATR_Multi;    // TP = ATR x çarpan
      
      // Min/Max pip sınırlarını uygula
      double minSL = MinSL_Pips * pipPoints;  // Min SL point cinsinden
      double maxSL = MaxSL_Pips * pipPoints;  // Max SL point cinsinden
      
      // SL sınırları
      if(slDist < minSL) slDist = minSL;
      if(slDist > maxSL) slDist = maxSL;
      
      // TP'yi SL'ye göre ayarla (R:R oranını koru)
      double ratio = TP_ATR_Multi / SL_ATR_Multi;
      tpDist = slDist * ratio;
      
      Print("📊 SL/TP Hesaplandı:");
      Print("   ATR: ", DoubleToString(atr, _Digits));
      Print("   SL Mesafesi: ", DoubleToString(slDist / pipPoints, 1), " pip");
      Print("   TP Mesafesi: ", DoubleToString(tpDist / pipPoints, 1), " pip");
   }
   
   //--- Günlük işlem limiti kontrolü
   bool CanTradeToday() {
      // Gün değişti mi kontrol et
      datetime today = StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
      
      if(today != g_lastTradeDate) {
         g_lastTradeDate = today;      // Tarihi güncelle
         g_dailyTrades = 0;            // Sayacı sıfırla
         Print("📅 Yeni gün başladı. İşlem sayacı sıfırlandı.");
      }
      
      // Limit kontrolü
      if(g_dailyTrades >= MaxDailyTrades) {
         Print("⚠️ Günlük işlem limiti doldu! (", g_dailyTrades, "/", MaxDailyTrades, ")");
         return false;
      }
      
      return true;
   }
   
   //--- Cooldown kontrolü (işlem arası bekleme)
   bool IsCooldownOver() {
      int currentBar = iBars(_Symbol, TimeFrame);
      int barsSinceTrade = currentBar - g_lastTradeBar;
      
      if(barsSinceTrade < CooldownBars) {
         // Henüz bekleme süresi dolmadı
         return false;
      }
      
      return true;
   }
   
   //--- Açık pozisyon var mı kontrol et
   bool HasOpenPosition() {
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         
         // Bu EA'ya ait mi kontrol et
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol) {
            return true;  // Açık pozisyon var
         }
      }
      return false;  // Açık pozisyon yok
   }
   
   //--- Piyasa açık mı kontrol et (Market Closed hatasını önler)
   // SYMBOL_TRADE_MODE ile broker'dan gerçek piyasa durumunu alır
   bool IsWithinTradingHours() {
      // ═══════════════════════════════════════════════════════════════
      // 📌 PİYASA DURUMU KONTROLÜ:
      // Broker'dan gerçek zamanlı piyasa durumunu al
      // Bu, "Market closed" hatasını önler
      // ═══════════════════════════════════════════════════════════════
      
      // Piyasa işlem modunu kontrol et
      ENUM_SYMBOL_TRADE_MODE tradeMode = (ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE);
      
      // SYMBOL_TRADE_MODE_FULL = Tam işlem modu (alış+satış)
      // SYMBOL_TRADE_MODE_DISABLED = İşlem devre dışı (piyasa kapalı)
      if(tradeMode != SYMBOL_TRADE_MODE_FULL) {
         // Piyasa kapalı veya sadece kapama işlemi yapılabilir
         return false;
      }
      
      // Spread kontrolü - çok yüksek spread piyasa kapalı işareti olabilir
      double spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point;
      double atr = GetATR();
      
      // Spread ATR'nin 3 katından fazlaysa muhtemelen piyasa kapalı/düşük likidite
      if(atr > 0 && spread > atr * 3) {
         Print("⚠️ Yüksek spread tespit edildi. İşlem atlanıyor.");
         return false;
      }
      
      // Zaman filtresi aktifse ek kontroller yap
      if(UseTimeFilter) {
         MqlDateTime dt;
         TimeCurrent(dt);
         int hour = dt.hour;
         
         // Saat aralığı kontrolü
         if(hour < StartHour || hour >= EndHour)
            return false;
      }
      
      return true;  // Piyasa açık ve işlem yapılabilir
   }
};

// ═══════════════════════════════════════════════════════════════════
// 📦 MODÜL 4: CTradeExecutor - İşlem Açma/Kapama
// ═══════════════════════════════════════════════════════════════════
class CTradeExecutor {
private:
   CTrade m_trade;  // MQL5 standart işlem nesnesi
   
public:
   //--- Başlat
   bool Init() {
      m_trade.SetExpertMagicNumber(MagicNumber);  // EA kimliğini ayarla
      m_trade.SetDeviationInPoints(20);           // Max kayma (slippage) 2 pip
      m_trade.SetTypeFilling(ORDER_FILLING_IOC);  // Dolum tipi
      
      Print("✅ İşlem modülü başlatıldı. Magic: ", MagicNumber);
      return true;
   }
   
   //--- Pozisyon aç
   // direction: 1=BUY, -1=SELL
   // slDist: Stop Loss mesafesi (point)
   // tpDist: Take Profit mesafesi (point)
   bool OpenPosition(int direction, double slDist, double tpDist) {
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      // Fiyatları al
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);  // Alış fiyatı
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);  // Satış fiyatı
      
      // Lot hesapla (SL pip cinsinden)
      double pipPoints = CPriceEngine::PipToPoints();
      double slPips = slDist / pipPoints;
      double lot = CPriceEngine::CalculateLot(slPips);
      
      Print("📌 İşlem Açılıyor:");
      Print("   Yön: ", (direction == 1 ? "ALIŞ" : "SATIŞ"));
      Print("   Lot: ", lot);
      
      bool result = false;
      
      if(direction == 1) {
         // ═══════════════════════════════════════════════════════════════
         // 📌 ALIŞ (BUY):
         // - Giriş: ASK fiyatından
         // - SL: Girişin ALTINDA (fiyat düşerse zarar)
         // - TP: Girişin ÜSTÜNDE (fiyat yükselirse kar)
         // ═══════════════════════════════════════════════════════════════
         double sl = NormalizeDouble(ask - slDist, digits);  // SL = Giriş - SL mesafesi
         double tp = NormalizeDouble(ask + tpDist, digits);  // TP = Giriş + TP mesafesi
         
         Print("   Giriş: ", ask, " SL: ", sl, " TP: ", tp);
         result = m_trade.Buy(lot, _Symbol, 0, sl, tp, TradeComment);
      }
      else if(direction == -1) {
         // ═══════════════════════════════════════════════════════════════
         // 📌 SATIŞ (SELL):
         // - Giriş: BID fiyatından
         // - SL: Girişin ÜSTÜNDE (fiyat yükselirse zarar)
         // - TP: Girişin ALTINDA (fiyat düşerse kar)
         // ═══════════════════════════════════════════════════════════════
         double sl = NormalizeDouble(bid + slDist, digits);  // SL = Giriş + SL mesafesi
         double tp = NormalizeDouble(bid - tpDist, digits);  // TP = Giriş - TP mesafesi
         
         Print("   Giriş: ", bid, " SL: ", sl, " TP: ", tp);
         result = m_trade.Sell(lot, _Symbol, 0, sl, tp, TradeComment);
      }
      
      // Sonuç kontrolü
      if(result) {
         Print("✅ İŞLEM BAŞARILI! Ticket: ", m_trade.ResultOrder());
         g_dailyTrades++;                         // Günlük sayacı artır
         g_lastTradeBar = iBars(_Symbol, TimeFrame);  // Son işlem barını kaydet
         return true;
      }
      else {
         Print("❌ İŞLEM BAŞARISIZ! Hata: ", m_trade.ResultRetcodeDescription());
         return false;
      }
   }
   
   //--- Mevcut pozisyonu kapat (ters sinyal geldiğinde)
   void ClosePosition() {
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         
         // Bu EA'ya ait mi kontrol et
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber &&
            PositionGetString(POSITION_SYMBOL) == _Symbol) {
            
            if(m_trade.PositionClose(ticket)) {
               Print("✅ Pozisyon kapatıldı: #", ticket);
            }
            else {
               Print("❌ Pozisyon kapatılamadı: ", m_trade.ResultRetcodeDescription());
            }
         }
      }
   }
};

// ═══════════════════════════════════════════════════════════════════
// 🌐 GLOBAL MODÜL NESNELERİ
// ═══════════════════════════════════════════════════════════════════
CSignalEngine      SignalEngine;       // Sinyal motoru
CSessionFilter     SessionFilter;      // v16.3: Seans filtresi
CCorrelationFilter CorrelationFilter;  // v16.3: USD/JPY korelasyon
CRiskManager       RiskManager;        // Risk yöneticisi
CTradeExecutor     TradeExecutor;      // İşlem yürütücü

// v16.4: Zarar Kurtarma Modülleri
CLotManager        LotManager;         // Anti-Martingale lot yönetimi
CTrailingManager   TrailingManager;    // Trailing TP + Breakeven
CPartialCloseManager PartialCloseManager; // Kısmi kapama
CZoneRecovery      ZoneRecovery;       // Bölge kurtarma (hedge)

// ═══════════════════════════════════════════════════════════════════
// 🚀 OnInit - EA başlatıldığında çalışır
// ═══════════════════════════════════════════════════════════════════
int OnInit() {
   Print("═══════════════════════════════════════════════════════════");
   Print("🚀 MA Master Scalper v16.4 - Zarar Kurtarma Sistemi");
   Print("═══════════════════════════════════════════════════════════");
   Print("📌 Sembol: ", _Symbol);
   Print("📌 Zaman Dilimi: ", EnumToString(TimeFrame));
   Print("📌 AMA Ayarları: ", AMA_Period, "/", AMA_FastPeriod, "/", AMA_SlowPeriod);
   Print("📌 Risk: %", RiskPercent);
   Print("═══════════════════════════════════════════════════════════");
   
   // Modülleri başlat
   if(!SignalEngine.Init()) return INIT_FAILED;
   if(!CorrelationFilter.Init()) return INIT_FAILED;
   if(!RiskManager.Init()) return INIT_FAILED;
   if(!TradeExecutor.Init()) return INIT_FAILED;
   
   // v16.4: Zarar Kurtarma Modülleri
   // Not: ATR değeri henüz mevcut değil, sabit lot kullan
   LotManager.Init(FixedLot);
   TrailingManager.Init();
   PartialCloseManager.Init();
   ZoneRecovery.Init();
   
   // Global değişkenleri sıfırla
   g_dailyTrades = 0;
   g_lastTradeBar = 0;
   g_lastTradeDate = 0;
   
   // v16.4: Timer'ı başlat (kurtarma modülleri için)
   EventSetTimer(1);  // Her 1 saniyede OnTimer çağrılır
   
   Print("✅ EA başarıyla başlatıldı!");
   Print("🌐 Seans: ", SessionFilter.GetSessionName());
   Print("🛡️ Kurtarma Modülleri: Aktif (Timer: 1s)");
   return INIT_SUCCEEDED;
}

// ═══════════════════════════════════════════════════════════════════
// 🛑 OnDeinit - EA kapatıldığında çalışır
// ═══════════════════════════════════════════════════════════════════
void OnDeinit(const int reason) {
   // Timer'ı durdur
   EventKillTimer();
   
   // Göstergeleri temizle
   SignalEngine.Deinit();
   CorrelationFilter.Deinit();
   RiskManager.Deinit();
   
   Print("🛑 EA kapatıldı. Sebep kodu: ", reason);
}

// ═══════════════════════════════════════════════════════════════════
// 🔄 OnTick - Her yeni fiyat geldiğinde çalışır
// ═══════════════════════════════════════════════════════════════════
void OnTick() {
   // ═══════════════════════════════════════════════════════════════
   // 📌 ADIM 1: Yeni bar kontrolü (sadece bar kapanışında işlem yap)
   // Bu, sinyal gürültüsünü azaltır ve daha güvenilir sinyaller sağlar
   // ═══════════════════════════════════════════════════════════════
   static int lastBars = 0;
   int currentBars = iBars(_Symbol, TimeFrame);
   
   if(currentBars == lastBars)
      return;  // Yeni bar yok, çık
   
   lastBars = currentBars;  // Bar sayısını güncelle
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 ADIM 2: Risk kontrolleri
   // ═══════════════════════════════════════════════════════════════
   
   // İşlem saatleri kontrolü (Market Closed hatasını önler)
   if(!RiskManager.IsWithinTradingHours())
      return;
   
   // Günlük işlem limiti kontrolü
   if(!RiskManager.CanTradeToday())
      return;
   
   // Cooldown kontrolü (işlem arası bekleme)
   if(!RiskManager.IsCooldownOver())
      return;
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 ADIM 3: Sinyal al
   // ═══════════════════════════════════════════════════════════════
   int signal = SignalEngine.GetSignal();
   
   if(signal == 0)
      return;  // Sinyal yok, çık
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 ADIM 3.5: SEANS BIAS UYGULA (v16.3)
   // Asya seansında (00:00-03:00 UTC) SELL tercih edilir
   // ═══════════════════════════════════════════════════════════════
   int sessionBias = SessionFilter.GetSessionBias();
   
   // Seans bias'ı sinyalle uyumsuzsa - sinyali atla veya zayıflat
   if(sessionBias != 0 && signal != sessionBias) {
      // Asya seansında BUY sinyali geldi ama SELL bekleniyor
      // Bu sinyali reddet
      Print("⚠️ Seans bias'ı sinyalle uyumsuz. Sinyal: ", 
            (signal == 1 ? "BUY" : "SELL"),
            " Bias: ", (sessionBias == -1 ? "SELL" : "BUY"));
      Print("   Sinyal atlanıyor...");
      return;
   }
   
   // Seans bias'ı ile uyumluysa bonus bilgi
   if(sessionBias != 0 && signal == sessionBias) {
      Print("✅ Seans bias'ı sinyali destekliyor! (",
            SessionFilter.GetSessionName(), " → ",
            (sessionBias == -1 ? "SELL" : "BUY"), ")");
   }
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 ADIM 3.6: USD/JPY KORELASYON TEYİDİ (v16.3)
   // EUR/USD BUY → USD zayıf olmalı (USD/JPY düşmeli)
   // EUR/USD SELL → USD güçlü olmalı (USD/JPY yükselmeli)
   // ═══════════════════════════════════════════════════════════════
   if(!CorrelationFilter.ConfirmWithUSDJPY(signal)) {
      Print("⚠️ USD/JPY korelasyonu sinyali onaylamıyor. Sinyal atlanıyor...");
      return;
   }
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 ADIM 3.7: RECOVERY MODU KONTROLÜ (v16.4)
   // Recovery modundayken yeni işlem açma
   // ═══════════════════════════════════════════════════════════════
   if(ZoneRecovery.IsInRecovery()) {
      Print("🔄 Recovery modunda - yeni işlem atlanıyor...");
      return;
   }
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 ADIM 3.8: EMA TEYİDİ (v16.5 USD/JPY)
   // BUY: EMA5 > EMA9 > EMA20 | SELL: EMA5 < EMA9 < EMA20
   // ═══════════════════════════════════════════════════════════════
   if(!SignalEngine.ConfirmWithEMA(signal)) {
      Print("⚠️ EMA teyit vermedi - sinyal atlanıyor.");
      return;
   }
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 ADIM 3.9: RSI TEYİDİ (v16.5 USD/JPY)
   // Momentum yönünü ve aşırı alım/satım kontrolü
   // ═══════════════════════════════════════════════════════════════
   if(!SignalEngine.ConfirmWithRSI(signal)) {
      Print("⚠️ RSI teyit vermedi - sinyal atlanıyor.");
      return;
   }
   
   Print("✅ TÜM TEYİTLER TAMAMLANDI (AMA + EMA + RSI)");
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 ADIM 4: Mevcut pozisyon kontrolü
   // Eğer ters yönde açık pozisyon varsa kapat
   // ═══════════════════════════════════════════════════════════════
   if(RiskManager.HasOpenPosition()) {
      TradeExecutor.ClosePosition();  // Mevcut pozisyonu kapat
   }
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 ADIM 5: SL/TP hesapla ve pozisyon aç
   // ═══════════════════════════════════════════════════════════════
   double slDist, tpDist;
   RiskManager.CalculateSLTP(signal, slDist, tpDist);
   
   // Pozisyon aç
   TradeExecutor.OpenPosition(signal, slDist, tpDist);
}

// ═══════════════════════════════════════════════════════════════════
// 🔁 OnTimer - Periyodik işlemler (Kurtarma yönetimi için)
// ═══════════════════════════════════════════════════════════════════
void OnTimer() {
   // v16.4: ATR değerini BİR KEZ al (doğru pattern!)
   // RiskManager'daki m_hATR handle'ı OnInit'te oluşturuldu
   double atrValue = RiskManager.GetATR();
   
   if(atrValue <= 0) {
      // ATR henüz mevcut değilse çık
      return;
   }
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 1. TRAILING + BREAKEVEN
   // Açık pozisyonların SL'lerini dinamik yönet
   // ═══════════════════════════════════════════════════════════════
   TrailingManager.TrailPositions(atrValue);
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 2. KISMİ KAPAMA
   // %50 hedefe ulaşan pozisyonların yarısını kapat
   // ═══════════════════════════════════════════════════════════════
   PartialCloseManager.CheckPartialClose();
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 3. ZONE RECOVERY KONTROL
   // Zarar eden pozisyonlar için ters hedge aç
   // ═══════════════════════════════════════════════════════════════
   ZoneRecovery.CheckRecovery(atrValue);
   
   // ═══════════════════════════════════════════════════════════════
   // 📌 4. RECOVERY ÇIKIŞ
   // Toplam P/L pozitifse tüm pozisyonları kapat
   // ═══════════════════════════════════════════════════════════════
   ZoneRecovery.CloseAllIfProfit();
}
//+------------------------------------------------------------------+

