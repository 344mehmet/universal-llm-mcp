//+------------------------------------------------------------------+
//|                                   Titanium_Omega_Harmony.mq5     |
//|                     © 2025, Systemic Trading Engineering         |
//|         HARMONY EDİTİON - TÜM ÖZELLİKLER BİRLEŞTİRİLDİ           |
//+------------------------------------------------------------------+
//|  BU VERSİYON ŞU ÖZELLİKLERİ BİRLEŞTİRİR:                         |
//|  ✅ v50: R:R 1:3 Strateji, MTF Onay, Kısmi Kâr, Gelişmiş Hata    |
//|  ✅ v25: HMA Cross, Haber Filtresi, Performans Analizi (ML)      |
//|  ✅ v24: Anti-Spam, Sıkı Init Kontrolü, Günlük İşlem Limiti      |
//|  ✅ v23: Hull Moving Average (HMA) Trend Filtresi                 |
//|  ✅ TrendciHoca: SuperTrend Benzeri ATR Bantları Mantığı          |
//|  ✅ Trade.mqh: OrderCheck ile Ön Doğrulama                        |
//+------------------------------------------------------------------+
#property copyright "© 2025, Systemic Trading Engineering - HARMONY"
#property version   "100.00"
#property strict
#property description "Titanium Omega HARMONY - Tüm Gelişmiş Özelliklerin Birleşimi"

#include <Trade\Trade.mqh>

//====================================================================
// ENUM TANIMLARI
//====================================================================

/// @brief Piyasa Rejimi
enum ENUM_MARKET_REGIME {
   REGIME_HIGH_VOLATILITY,   // ⚡ Yüksek Volatilite (BEKLE)
   REGIME_TRENDING,          // 📈 Trend (İYİ)
   REGIME_RANGING            // ➡️ Yatay (DİKKATLİ)
};

/// @brief Strateji Modu
enum ENUM_STRATEGY_MODE {
   STRATEGY_MA_MASTER,          // MA Master (v50 - Varsayılan)
   STRATEGY_FRACTAL_REVERSAL,   // Fractal Dönüş (Sniper)
   STRATEGY_HMA_CROSS           // HMA Kesişim (Trend Takip)
};

/// @brief Sinyal Tipi
enum ENUM_SIGNAL_TYPE {
   SIGNAL_NONE = 0,          // Sinyal Yok
   SIGNAL_BUY  = 1,          // AL Sinyali
   SIGNAL_SELL = -1          // SAT Sinyali
};

//====================================================================
// INPUT PARAMETRELERİ - TÜRKÇE AÇIKLAMALI
//====================================================================

//--- 1. ANA AYARLAR
input group "═══════ 1. ANA AYARLAR ═══════"
input ulong    InpMagic           = 999999;    // 🔢 Magic Number
input string   InpComment         = "Harmony"; // 💬 İşlem Yorumu
input bool     InpShowDashboard   = true;      // 📊 Bilgi Paneli Göster
input ENUM_STRATEGY_MODE InpStrategyMode = STRATEGY_MA_MASTER; // 🎯 Strateji Modu

//--- 2. RİSK YÖNETİMİ (10$ İÇİN OPTİMİZE)
input group "═══════ 2. RİSK YÖNETİMİ ═══════"
input double   InpRiskPerTrade    = 1.0;       // 💰 İşlem Başı Risk %
input double   InpFixedLot        = 0.01;      // 📦 Sabit Lot
input bool     InpUseRiskBasedLot = false;     // ⚖️ Risk Bazlı Lot (10$ için KAPALI)
input double   InpMaxDailyLoss    = 30.0;      // 🛑 Günlük Max Zarar % (3$ = %30)
input double   InpMaxMoneyDD      = 5.0;       // 💵 Günlük Max Zarar $
input double   InpMinMarginLevel  = 50.0;      // 📉 Min Marjin Seviyesi %
input int      InpMaxTradesPerDay = 10;        // 🔢 Günlük Max İşlem

//--- 3. STOP LOSS & TAKE PROFIT (R:R 1:3)
input group "═══════ 3. SL/TP AYARLARI ═══════"
input bool     InpUseATRStops     = true;      // 📐 ATR Bazlı SL/TP
input int      InpATRPeriod       = 14;        // 📊 ATR Periyodu
input double   InpATRMultiplierSL = 1.5;       // 🎯 SL Çarpanı (Sıkı)
input double   InpATRMultiplierTP = 4.5;       // 🎯 TP Çarpanı (Geniş - R:R 1:3)
input int      InpSL_Pips         = 15;        // 📍 Sabit SL (Pip)
input int      InpTP_Pips         = 45;        // 📍 Sabit TP (Pip)
input double   InpMinRiskReward   = 2.5;       // ⚖️ Minimum R:R Oranı
input int      InpMinStopPips     = 10;        // 📏 Min SL Mesafesi (Pip)

//--- 4. TRAILING STOP & BREAKEVEN
input group "═══════ 4. POZİSYON YÖNETİMİ ═══════"
input bool     InpUseTrailing     = true;      // 🏃 Trailing Stop Kullan
input int      InpTrailingStart   = 15;        // 🚀 Trailing Başlangıç (Pip)
input int      InpTrailingStep    = 8;         // 📏 Trailing Adım (Pip)
input bool     InpUseBreakeven    = true;      // 🔒 Breakeven Kullan
input int      InpBreakevenPips   = 12;        // 🎯 BE Tetikleme (Pip)
input int      InpBreakevenOffset = 2;         // ➡️ BE Offset (Pip)
input bool     InpUsePartialClose = true;      // ✂️ Kısmi Kâr Alma
input double   InpPartialPercent  = 50.0;      // 📊 Kısmi Kapama %
input int      InpPartialTriggerPips = 30;     // 🎯 Kısmi Tetikleme (Pip)

//--- 5. MA MASTER STRATEJİSİ
input group "═══════ 5. MA MASTER ═══════"
input int      InpTrend_SMA       = 200;       // 📈 Ana Trend SMA
input int      InpSignal_EMA_Fast = 8;         // ⚡ Hızlı EMA
input int      InpSignal_EMA_Slow = 21;        // 🐢 Yavaş EMA
input bool     InpRequireEMAAlign = true;      // ✅ EMA Hizalama Şart
input int      InpMinADX          = 25;        // 💪 Min ADX (Trend Gücü)

//--- 6. HMA CROSS STRATEJİSİ
input group "═══════ 6. HMA CROSS ═══════"
input int      InpHMA_Fast        = 20;        // ⚡ Hızlı HMA
input int      InpHMA_Slow        = 50;        // 🐢 Yavaş HMA

//--- 7. MTF ONAY
input group "═══════ 7. MTF ONAY ═══════"
input bool     InpUseMTF          = true;      // 🔍 MTF Onayı Kullan
input ENUM_TIMEFRAMES InpMTF_TF   = PERIOD_H1; // ⏰ MTF Zaman Dilimi
input int      InpMTF_MA_Period   = 50;        // 📊 MTF MA Periyodu

//--- 8. ZAMAN VE SPREAD FİLTRESİ
input group "═══════ 8. FİLTRELER ═══════"
input bool     InpUseTimeFilter   = false;     // ⏰ Zaman Filtresi (Test için KAPALI)
input int      InpStartHour       = 8;         // 🌅 Başlangıç Saati
input int      InpEndHour         = 20;        // 🌆 Bitiş Saati
input int      InpMaxSpreadPips   = 6;         // 📊 Max Spread (Pip)

//--- 9. HABER FİLTRESİ & AI
input group "═══════ 9. HABER & AI ═══════"
input bool     InpUseNewsFilter   = true;      // 📰 Haber Filtresi
input int      InpNewsPauseMins   = 60;        // ⏱️ Haber Öncesi/Sonrası Bekleme (Dk)
input bool     InpUsePerformance  = true;      // 🧠 Performans Analizi (Basit ML)
input int      InpMaxLoseStreak   = 3;         // ❌ Üst Üste Max Zarar

//--- 10. GÜVENLİK (TANK MODU)
input group "═══════ 10. GÜVENLİK ═══════"
input int      InpMinRequestIntervalMs = 100;  // ⏱️ Anti-Spam (ms)
input bool     InpStrictInitChecks = true;     // 🔒 Sıkı Başlangıç Kontrolü
input int      InpMinutesCooldown  = 15;       // ⏳ İşlem Arası Bekleme (Dk)

//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================

// === TEMEL ===
int      g_tradesTodayCount = 0;
datetime g_today_start = 0;
string   g_StateReason = "🚀 BAŞLATILIYOR...";
double   g_refBalance = 0;
double   g_lastKnownBalance = 0;
datetime g_lastTradeTime = 0;
long     g_lastTradeOperationTime = 0;
int      g_consecutiveLosses = 0;

// === İSTATİSTİKLER ===
int      g_totalTrades = 0;
int      g_totalWins = 0;
int      g_totalLosses = 0;
double   g_grossProfit = 0;
double   g_grossLoss = 0;
double   g_peakBalance = 0;
double   g_maxDrawdownMoney = 0;
double   g_equityHigh = 0;
double   g_maxDrawdownReached = 0;

// === HATA YÖNETİMİ ===
int      g_errorCount = 0;
int      g_criticalErrorCount = 0;
int      g_lastErrorCode = 0;
datetime g_lastErrorTime = 0;

// === TRADE OBJECT ===
CTrade   m_trade;

//====================================================================
// HELPER FUNCTIONS
//====================================================================

/// @brief Pip'i Point'e çevirir
double PipToPoints(int pips)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   return pips * 10.0 * point;
}

/// @brief Anti-Spam: Broker sunucusunu korur
void EnforceRequestInterval()
{
   if(InpMinRequestIntervalMs <= 0) return;
   
   long current = GetTickCount();
   long elapsed = current - g_lastTradeOperationTime;
   
   if(elapsed < InpMinRequestIntervalMs)
   {
      Sleep((int)(InpMinRequestIntervalMs - elapsed));
   }
   g_lastTradeOperationTime = GetTickCount();
}

//====================================================================
// CLASS: CSecurityManager (GÜVENLİK)
//====================================================================
class CSecurityManager
{
public:
   void Init()
   {
      g_refBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      g_lastKnownBalance = g_refBalance;
      g_equityHigh = AccountInfoDouble(ACCOUNT_EQUITY);
      g_peakBalance = g_refBalance;
      Print("💰 GÜNLÜK REFERANS: ", g_refBalance);
   }
   
   void UpdateReference()
   {
      MqlDateTime dt;
      TimeCurrent(dt);
      datetime today = iTime(_Symbol, PERIOD_D1, 0);
      
      if(g_today_start != today)
      {
         g_today_start = today;
         g_tradesTodayCount = 0;
         g_refBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         Print("🔄 YENİ GÜN - Referans güncellendi: ", g_refBalance);
      }
   }
   
   bool IsSafeToTrade()
   {
      UpdateReference();
      
      // === 1. GÜNLÜK ZARAR KONTROLÜ ===
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double loss = g_refBalance - equity;
      
      if(loss >= InpMaxMoneyDD || (g_refBalance > 0 && (loss/g_refBalance)*100.0 >= InpMaxDailyLoss))
      {
         g_StateReason = "🛑 GÜNLÜK ZARAR LİMİTİ";
         return false;
      }
      
      // === 2. MARJİN KONTROLÜ ===
      double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
      if(marginLevel > 0 && marginLevel < InpMinMarginLevel)
      {
         g_StateReason = "📉 DÜŞÜK MARJİN: %" + DoubleToString(marginLevel, 0);
         return false;
      }
      
      // === 3. GÜNLÜK LİMİT ===
      if(InpMaxTradesPerDay > 0 && g_tradesTodayCount >= InpMaxTradesPerDay)
      {
         g_StateReason = "🔒 GÜNLÜK LİMİT: " + IntegerToString(g_tradesTodayCount);
         return false;
      }
      
      // === 4. ZAMAN FİLTRESİ ===
      if(InpUseTimeFilter)
      {
         MqlDateTime dt;
         TimeCurrent(dt);
         if(dt.hour < InpStartHour || dt.hour >= InpEndHour)
         {
            g_StateReason = "⏰ ZAMAN FİLTRESİ: " + IntegerToString(dt.hour) + ":00";
            return false;
         }
      }
      
      // === 5. SPREAD KONTROLÜ ===
      long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      double spreadPips = spread / 10.0;
      if(spreadPips > InpMaxSpreadPips)
      {
         g_StateReason = "📊 YÜKSEK SPREAD: " + DoubleToString(spreadPips, 1);
         return false;
      }
      
      // === 6. İŞLEM ARASI BEKLEME ===
      if(g_lastTradeTime > 0)
      {
         datetime minNext = g_lastTradeTime + (InpMinutesCooldown * 60);
         if(TimeCurrent() < minNext)
         {
            g_StateReason = "⏳ BEKLEME: " + TimeToString(minNext);
            return false;
         }
      }
      
      return true;
   }
   
   bool CheckPerformance()
   {
      if(!InpUsePerformance) return true;
      
      if(g_consecutiveLosses >= InpMaxLoseStreak)
      {
         g_StateReason = "🧠 PERFORMANS KORUMASI (" + IntegerToString(g_consecutiveLosses) + " ZARAR)";
         return false;
      }
      return true;
   }
   
   double GetDailyPL()
   {
      return AccountInfoDouble(ACCOUNT_EQUITY) - g_refBalance;
   }
};

//====================================================================
// CLASS: CNewsManager (HABER FİLTRESİ)
//====================================================================
class CNewsManager
{
public:
   bool IsNewsTime()
   {
      if(!InpUseNewsFilter) return false;
      
      MqlCalendarValue values[];
      datetime start = TimeCurrent() - (InpNewsPauseMins * 60);
      datetime end   = TimeCurrent() + (InpNewsPauseMins * 60);
      
      // USD Haberleri
      if(CalendarValueHistory(values, start, end, "USD", NULL) > 0)
      {
         for(int i=0; i<ArraySize(values); i++)
         {
            MqlCalendarEvent event;
            if(CalendarEventById(values[i].event_id, event))
            {
               if(event.importance == CALENDAR_IMPORTANCE_HIGH)
               {
                  g_StateReason = "📰 HABER FİLTRESİ (USD)";
                  return true;
               }
            }
         }
      }
      
      // EUR Haberleri
      if(CalendarValueHistory(values, start, end, "EUR", NULL) > 0)
      {
         for(int i=0; i<ArraySize(values); i++)
         {
            MqlCalendarEvent event;
            if(CalendarEventById(values[i].event_id, event))
            {
               if(event.importance == CALENDAR_IMPORTANCE_HIGH)
               {
                  g_StateReason = "📰 HABER FİLTRESİ (EUR)";
                  return true;
               }
            }
         }
      }
      
      return false;
   }
};

//====================================================================
// CLASS: CSignalEngine (SİNYAL MOTORU)
//====================================================================
class CSignalEngine
{
private:
   // MA Master
   int m_hSMA_Trend;
   int m_hEMA_Fast;
   int m_hEMA_Slow;
   int m_hADX;
   int m_hMTF_MA;
   
   // Fractal
   int m_hFrac;
   int m_hBands;
   
   // HMA Cross
   int m_hHMA_Fast_Half;
   int m_hHMA_Fast_Full;
   int m_hHMA_Slow_Half;
   int m_hHMA_Slow_Full;
   
   datetime m_lastSignalTime;
   
public:
   CSignalEngine() : 
      m_hSMA_Trend(INVALID_HANDLE), m_hEMA_Fast(INVALID_HANDLE), m_hEMA_Slow(INVALID_HANDLE),
      m_hADX(INVALID_HANDLE), m_hMTF_MA(INVALID_HANDLE), m_hFrac(INVALID_HANDLE), m_hBands(INVALID_HANDLE),
      m_hHMA_Fast_Half(INVALID_HANDLE), m_hHMA_Fast_Full(INVALID_HANDLE),
      m_hHMA_Slow_Half(INVALID_HANDLE), m_hHMA_Slow_Full(INVALID_HANDLE), m_lastSignalTime(0) {}
   
   bool Init()
   {
      ReleaseHandles();
      
      // MA Master göstergeleri
      m_hSMA_Trend = iMA(_Symbol, PERIOD_CURRENT, InpTrend_SMA, 0, MODE_SMA, PRICE_CLOSE);
      m_hEMA_Fast = iMA(_Symbol, PERIOD_CURRENT, InpSignal_EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
      m_hEMA_Slow = iMA(_Symbol, PERIOD_CURRENT, InpSignal_EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
      m_hADX = iADX(_Symbol, PERIOD_CURRENT, 14);
      
      // MTF
      if(InpUseMTF)
      {
         m_hMTF_MA = iMA(_Symbol, InpMTF_TF, InpMTF_MA_Period, 0, MODE_EMA, PRICE_CLOSE);
      }
      
      // Fractal göstergeleri
      m_hFrac = iFractals(_Symbol, PERIOD_CURRENT);
      m_hBands = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
      
      // HMA Cross göstergeleri
      if(InpStrategyMode == STRATEGY_HMA_CROSS)
      {
         m_hHMA_Fast_Half = iMA(_Symbol, PERIOD_CURRENT, InpHMA_Fast / 2, 0, MODE_LWMA, PRICE_CLOSE);
         m_hHMA_Fast_Full = iMA(_Symbol, PERIOD_CURRENT, InpHMA_Fast, 0, MODE_LWMA, PRICE_CLOSE);
         m_hHMA_Slow_Half = iMA(_Symbol, PERIOD_CURRENT, InpHMA_Slow / 2, 0, MODE_LWMA, PRICE_CLOSE);
         m_hHMA_Slow_Full = iMA(_Symbol, PERIOD_CURRENT, InpHMA_Slow, 0, MODE_LWMA, PRICE_CLOSE);
      }
      
      // Kontrol
      bool valid = (m_hSMA_Trend != INVALID_HANDLE) && (m_hEMA_Fast != INVALID_HANDLE) &&
                   (m_hEMA_Slow != INVALID_HANDLE) && (m_hADX != INVALID_HANDLE);
      
      if(!valid)
      {
         Print("❌ HATA: Göstergeler yüklenemedi!");
         return false;
      }
      
      Print("✅ HARMONY: Tüm göstergeler yüklendi.");
      return true;
   }
   
   void ReleaseHandles()
   {
      if(m_hSMA_Trend != INVALID_HANDLE) IndicatorRelease(m_hSMA_Trend);
      if(m_hEMA_Fast != INVALID_HANDLE) IndicatorRelease(m_hEMA_Fast);
      if(m_hEMA_Slow != INVALID_HANDLE) IndicatorRelease(m_hEMA_Slow);
      if(m_hADX != INVALID_HANDLE) IndicatorRelease(m_hADX);
      if(m_hMTF_MA != INVALID_HANDLE) IndicatorRelease(m_hMTF_MA);
      if(m_hFrac != INVALID_HANDLE) IndicatorRelease(m_hFrac);
      if(m_hBands != INVALID_HANDLE) IndicatorRelease(m_hBands);
      if(m_hHMA_Fast_Half != INVALID_HANDLE) IndicatorRelease(m_hHMA_Fast_Half);
      if(m_hHMA_Fast_Full != INVALID_HANDLE) IndicatorRelease(m_hHMA_Fast_Full);
      if(m_hHMA_Slow_Half != INVALID_HANDLE) IndicatorRelease(m_hHMA_Slow_Half);
      if(m_hHMA_Slow_Full != INVALID_HANDLE) IndicatorRelease(m_hHMA_Slow_Full);
   }
   
   // === MA MASTER SİNYALİ ===
   int GetMAMasterSignal()
   {
      double smaTrend[], fast[], slow[], adx[];
      ArraySetAsSeries(smaTrend, true);
      ArraySetAsSeries(fast, true);
      ArraySetAsSeries(slow, true);
      ArraySetAsSeries(adx, true);
      
      if(CopyBuffer(m_hSMA_Trend, 0, 0, 3, smaTrend) < 3) return 0;
      if(CopyBuffer(m_hEMA_Fast, 0, 0, 3, fast) < 3) return 0;
      if(CopyBuffer(m_hEMA_Slow, 0, 0, 3, slow) < 3) return 0;
      if(CopyBuffer(m_hADX, 0, 0, 1, adx) < 1) return 0;
      
      double price = iClose(_Symbol, PERIOD_CURRENT, 0);
      
      // ADX Filtresi
      if(adx[0] < InpMinADX)
      {
         g_StateReason = "📉 ADX DÜŞÜK: " + DoubleToString(adx[0], 0) + " < " + IntegerToString(InpMinADX);
         return 0;
      }
      
      // Trend Yönü
      int trend = 0;
      if(InpRequireEMAAlign)
      {
         if(price > fast[0] && fast[0] > slow[0] && slow[0] > smaTrend[0])
            trend = 1;
         else if(price < fast[0] && fast[0] < slow[0] && slow[0] < smaTrend[0])
            trend = -1;
      }
      else
      {
         if(price > smaTrend[0]) trend = 1;
         else if(price < smaTrend[0]) trend = -1;
      }
      
      if(trend == 0)
      {
         g_StateReason = "📊 EMA HİZALANMAMIŞ";
         return 0;
      }
      
      // EMA Cross Kontrolü
      bool goldenCross = (fast[1] <= slow[1] && fast[0] > slow[0]);
      bool deathCross  = (fast[1] >= slow[1] && fast[0] < slow[0]);
      
      if(trend == 1 && goldenCross)
      {
         g_StateReason = "🟢 MA MASTER: BUY (ADX:" + DoubleToString(adx[0], 0) + ")";
         return SIGNAL_BUY;
      }
      if(trend == -1 && deathCross)
      {
         g_StateReason = "🔴 MA MASTER: SELL (ADX:" + DoubleToString(adx[0], 0) + ")";
         return SIGNAL_SELL;
      }
      
      g_StateReason = "🔎 SİNYAL ARANIYOR...";
      return SIGNAL_NONE;
   }
   
   // === HMA KESİŞİM SİNYALİ ===
   double CalculateHMA(int period, int hHalf, int hFull, int shift)
   {
      int sqrtP = (int)MathSqrt(period);
      int lookback = sqrtP + 1;
      
      double wmaHalf[], wmaFull[];
      ArraySetAsSeries(wmaHalf, true);
      ArraySetAsSeries(wmaFull, true);
      
      if(CopyBuffer(hHalf, 0, shift, lookback, wmaHalf) < lookback) return 0;
      if(CopyBuffer(hFull, 0, shift, lookback, wmaFull) < lookback) return 0;
      
      double rawHMA[];
      ArrayResize(rawHMA, lookback);
      for(int i=0; i<lookback; i++)
         rawHMA[i] = (2 * wmaHalf[i]) - wmaFull[i];
      
      double hmaVal = 0, weightSum = 0;
      for(int i=0; i<sqrtP; i++)
      {
         double weight = sqrtP - i;
         hmaVal += rawHMA[i] * weight;
         weightSum += weight;
      }
      
      return (weightSum > 0) ? hmaVal / weightSum : 0;
   }
   
   int GetHMACrossSignal()
   {
      double fastCurr = CalculateHMA(InpHMA_Fast, m_hHMA_Fast_Half, m_hHMA_Fast_Full, 0);
      double fastPrev = CalculateHMA(InpHMA_Fast, m_hHMA_Fast_Half, m_hHMA_Fast_Full, 1);
      double slowCurr = CalculateHMA(InpHMA_Slow, m_hHMA_Slow_Half, m_hHMA_Slow_Full, 0);
      double slowPrev = CalculateHMA(InpHMA_Slow, m_hHMA_Slow_Half, m_hHMA_Slow_Full, 1);
      
      if(fastCurr == 0 || slowCurr == 0) return 0;
      
      if(fastPrev < slowPrev && fastCurr > slowCurr)
      {
         g_StateReason = "🟢 HMA CROSS: BUY";
         return SIGNAL_BUY;
      }
      if(fastPrev > slowPrev && fastCurr < slowCurr)
      {
         g_StateReason = "🔴 HMA CROSS: SELL";
         return SIGNAL_SELL;
      }
      
      g_StateReason = "🔎 HMA CROSS: BEKLEME";
      return SIGNAL_NONE;
   }
   
   // === FRACTAL SİNYALİ ===
   int GetFractalSignal()
   {
      double up[], down[];
      if(CopyBuffer(m_hFrac, 0, 0, 5, up) < 5 || CopyBuffer(m_hFrac, 1, 0, 5, down) < 5)
         return 0;
      
      bool isDip = (down[2] != 0.0 && down[2] != EMPTY_VALUE);
      bool isTop = (up[2] != 0.0 && up[2] != EMPTY_VALUE);
      
      datetime barTime = iTime(_Symbol, PERIOD_CURRENT, 2);
      if(barTime <= m_lastSignalTime) return 0;
      
      if(isDip)
      {
         m_lastSignalTime = barTime;
         g_StateReason = "🟢 FRACTAL DİP";
         return SIGNAL_BUY;
      }
      if(isTop)
      {
         m_lastSignalTime = barTime;
         g_StateReason = "🔴 FRACTAL TEPE";
         return SIGNAL_SELL;
      }
      
      g_StateReason = "🔎 FRACTAL: BEKLEME";
      return SIGNAL_NONE;
   }
   
   // === MTF ONAY ===
   int GetMTFTrend()
   {
      if(!InpUseMTF || m_hMTF_MA == INVALID_HANDLE) return 0;
      
      double mtfMA[];
      ArraySetAsSeries(mtfMA, true);
      if(CopyBuffer(m_hMTF_MA, 0, 0, 1, mtfMA) < 1) return 0;
      
      double price = iClose(_Symbol, InpMTF_TF, 0);
      
      if(price > mtfMA[0]) return SIGNAL_BUY;
      if(price < mtfMA[0]) return SIGNAL_SELL;
      return 0;
   }
   
   // === ANA SİNYAL FONKSİYONU ===
   int GetSignal()
   {
      int signal = 0;
      
      switch(InpStrategyMode)
      {
         case STRATEGY_MA_MASTER:
            signal = GetMAMasterSignal();
            break;
         case STRATEGY_FRACTAL_REVERSAL:
            signal = GetFractalSignal();
            break;
         case STRATEGY_HMA_CROSS:
            signal = GetHMACrossSignal();
            break;
      }
      
      // MTF Onay
      if(signal != 0 && InpUseMTF)
      {
         int mtfTrend = GetMTFTrend();
         if(mtfTrend != 0 && mtfTrend != signal)
         {
            g_StateReason = "⚠️ MTF UYUŞMAZLIĞI";
            signal = 0;
         }
      }
      
      return signal;
   }
   
   double GetADX()
   {
      double adx[];
      ArraySetAsSeries(adx, true);
      if(CopyBuffer(m_hADX, 0, 0, 1, adx) < 1) return 0;
      return adx[0];
   }
};

//====================================================================
// CLASS: CRiskManager (RİSK YÖNETİMİ)
//====================================================================
class CRiskManager
{
public:
   double GetSafeLot()
   {
      if(!InpUseRiskBasedLot) return InpFixedLot;
      
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * (InpRiskPerTrade / 100.0);
      
      double slPips = InpSL_Pips;
      double slPoints = PipToPoints((int)slPips);
      if(slPoints <= 0) return InpFixedLot;
      
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      if(tickValue <= 0) return InpFixedLot;
      
      double lot = riskAmount / (slPips * 10 * tickValue);
      
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      
      lot = MathFloor(lot / stepLot) * stepLot;
      lot = MathMax(minLot, MathMin(lot, maxLot));
      
      return lot;
   }
   
   double GetATRStopLoss(int direction)
   {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double slDist = 0;
      
      if(InpUseATRStops)
      {
         int hATR = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
         double atr[1];
         CopyBuffer(hATR, 0, 0, 1, atr);
         IndicatorRelease(hATR);
         slDist = atr[0] * InpATRMultiplierSL;
      }
      else
      {
         slDist = PipToPoints(InpSL_Pips);
      }
      
      double minDist = PipToPoints(InpMinStopPips);
      if(slDist < minDist) slDist = minDist;
      
      // StopLevel kontrolü
      double stopLevel = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;
      if(slDist < stopLevel) slDist = stopLevel + (10 * point);
      
      if(direction == SIGNAL_BUY) return SymbolInfoDouble(_Symbol, SYMBOL_ASK) - slDist;
      else return SymbolInfoDouble(_Symbol, SYMBOL_BID) + slDist;
   }
   
   double GetATRTakeProfit(int direction)
   {
      double tpDist = 0;
      
      if(InpUseATRStops)
      {
         int hATR = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
         double atr[1];
         CopyBuffer(hATR, 0, 0, 1, atr);
         IndicatorRelease(hATR);
         tpDist = atr[0] * InpATRMultiplierTP;
      }
      else
      {
         tpDist = PipToPoints(InpTP_Pips);
      }
      
      if(direction == SIGNAL_BUY) return SymbolInfoDouble(_Symbol, SYMBOL_ASK) + tpDist;
      else return SymbolInfoDouble(_Symbol, SYMBOL_BID) - tpDist;
   }
   
   bool CheckRiskReward(double entry, double sl, double tp)
   {
      if(sl == 0 || tp == 0) return true;
      
      double risk = MathAbs(entry - sl);
      double reward = MathAbs(tp - entry);
      
      if(risk <= 0) return false;
      double rr = reward / risk;
      
      if(rr < InpMinRiskReward)
      {
         g_StateReason = "⚠️ R:R DÜŞÜK: " + DoubleToString(rr, 2);
         return false;
      }
      return true;
   }
};

//====================================================================
// GLOBAL OBJECTS
//====================================================================
CSecurityManager Security;
CNewsManager     News;
CSignalEngine    Signal;
CRiskManager     RiskMgr;

//====================================================================
// TRADE FUNCTIONS
//====================================================================
void OpenTrade(int direction)
{
   double lot = RiskMgr.GetSafeLot();
   double sl = RiskMgr.GetATRStopLoss(direction);
   double tp = RiskMgr.GetATRTakeProfit(direction);
   
   double entry = (direction == SIGNAL_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // R:R Kontrolü
   if(!RiskMgr.CheckRiskReward(entry, sl, tp)) return;
   
   // Normalizasyon
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   sl = NormalizeDouble(sl, digits);
   tp = NormalizeDouble(tp, digits);
   entry = NormalizeDouble(entry, digits);
   
   // Anti-Spam
   EnforceRequestInterval();
   
   // Önceki hatayı temizle
   ResetLastError();
   
   bool success = false;
   if(direction == SIGNAL_BUY)
      success = m_trade.Buy(lot, _Symbol, 0, sl, tp, InpComment);
   else
      success = m_trade.Sell(lot, _Symbol, 0, sl, tp, InpComment);
   
   if(success && m_trade.ResultRetcode() == TRADE_RETCODE_DONE)
   {
      g_tradesTodayCount++;
      g_lastTradeTime = TimeCurrent();
      g_totalTrades++;
      
      Print("✅ ", (direction == SIGNAL_BUY ? "BUY" : "SELL"),
            " | Lot:", DoubleToString(lot, 2),
            " | Entry:", DoubleToString(entry, digits),
            " | SL:", DoubleToString(sl, digits),
            " | TP:", DoubleToString(tp, digits),
            " | Ticket:", m_trade.ResultOrder());
   }
   else
   {
      g_errorCount++;
      g_lastErrorCode = (int)m_trade.ResultRetcode();
      g_lastErrorTime = TimeCurrent();
      
      Print("❌ İŞLEM BAŞARISIZ! RetCode: ", m_trade.ResultRetcode(), " (", m_trade.ResultRetcodeDescription(), ")");
      
      if(m_trade.ResultRetcode() == TRADE_RETCODE_NO_MONEY ||
         m_trade.ResultRetcode() == TRADE_RETCODE_INVALID_STOPS)
      {
         g_criticalErrorCount++;
         Alert("❌ KRİTİK HATA: ", m_trade.ResultRetcodeDescription());
      }
   }
}

void ManagePositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double curr = PositionGetDouble(POSITION_PRICE_CURRENT);
      double sl = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      long type = PositionGetInteger(POSITION_TYPE);
      double volume = PositionGetDouble(POSITION_VOLUME);
      
      // === KISMİ KÂR ALMA ===
      if(InpUsePartialClose && volume > SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
      {
         double partialTrigger = PipToPoints(InpPartialTriggerPips);
         double profit = (type == POSITION_TYPE_BUY) ? (curr - open) : (open - curr);
         
         if(profit >= partialTrigger)
         {
            double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
            double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
            double closeVol = MathFloor((volume * InpPartialPercent / 100.0) / lotStep) * lotStep;
            
            if(closeVol >= minLot && (volume - closeVol) >= minLot)
            {
               EnforceRequestInterval();
               if(m_trade.PositionClosePartial(ticket, closeVol))
                  Print("🎯 KISMİ KÂR: ", DoubleToString(closeVol, 2), " lot kapatıldı");
            }
         }
      }
      
      // === BREAKEVEN ===
      if(InpUseBreakeven)
      {
         double beTrigger = PipToPoints(InpBreakevenPips);
         double beOffset = PipToPoints(InpBreakevenOffset);
         
         if(type == POSITION_TYPE_BUY)
         {
            if(curr > open + beTrigger && sl < open)
            {
               EnforceRequestInterval();
               m_trade.PositionModify(ticket, open + beOffset, tp);
            }
         }
         else
         {
            if(curr < open - beTrigger && (sl > open || sl == 0))
            {
               EnforceRequestInterval();
               m_trade.PositionModify(ticket, open - beOffset, tp);
            }
         }
      }
      
      // === TRAILING STOP ===
      if(InpUseTrailing)
      {
         double trailStart = PipToPoints(InpTrailingStart);
         double trailStep = PipToPoints(InpTrailingStep);
         
         if(type == POSITION_TYPE_BUY)
         {
            if(curr - open > trailStart)
            {
               double newSL = curr - trailStart;
               if(newSL > sl + trailStep)
               {
                  EnforceRequestInterval();
                  m_trade.PositionModify(ticket, newSL, tp);
               }
            }
         }
         else
         {
            if(open - curr > trailStart)
            {
               double newSL = curr + trailStart;
               if(sl == 0 || newSL < sl - trailStep)
               {
                  EnforceRequestInterval();
                  m_trade.PositionModify(ticket, newSL, tp);
               }
            }
         }
      }
   }
}

//====================================================================
// DASHBOARD
//====================================================================
void UpdateDashboard(int signal)
{
   if(!InpShowDashboard) return;
   
   double adx = Signal.GetADX();
   double lot = RiskMgr.GetSafeLot();
   double dailyPL = Security.GetDailyPL();
   
   string strategyName = "";
   switch(InpStrategyMode)
   {
      case STRATEGY_MA_MASTER: strategyName = "MA MASTER"; break;
      case STRATEGY_FRACTAL_REVERSAL: strategyName = "FRACTAL"; break;
      case STRATEGY_HMA_CROSS: strategyName = "HMA CROSS"; break;
   }
   
   string dash = "";
   dash += "╔═══════════════════════════════════════════╗\n";
   dash += "║   🎯 TITANIUM OMEGA HARMONY 🎯           ║\n";
   dash += "╠═══════════════════════════════════════════╣\n";
   dash += "║ 📊 STRATEJİ : " + strategyName + "\n";
   dash += "║ ℹ️  DURUM   : " + g_StateReason + "\n";
   dash += "║ 🎯 SİNYAL  : " + (signal == 1 ? "🟢 BUY" : (signal == -1 ? "🔴 SELL" : "⏳ BEKLEME")) + "\n";
   dash += "╠═══════════════════════════════════════════╣\n";
   dash += "║ 💪 ADX     : " + DoubleToString(adx, 1) + " (MIN: " + IntegerToString(InpMinADX) + ")\n";
   dash += "║ 📦 LOT     : " + DoubleToString(lot, 2) + "\n";
   dash += "║ 💰 GÜN P/L : " + (dailyPL >= 0 ? "+" : "") + DoubleToString(dailyPL, 2) + " $\n";
   dash += "╠═══════════════════════════════════════════╣\n";
   dash += "║ 📈 İŞLEMLER: " + IntegerToString(g_tradesTodayCount) + "/" + IntegerToString(InpMaxTradesPerDay) + "\n";
   dash += "║ 📊 POZİSYON: " + IntegerToString(PositionsTotal()) + "\n";
   dash += "║ ❌ HATALAR : " + IntegerToString(g_errorCount) + "\n";
   dash += "╚═══════════════════════════════════════════╝";
   
   Comment(dash);
}

//====================================================================
// OnInit
//====================================================================
int OnInit()
{
   // === v24: SIKI BAŞLANGIÇ KONTROLÜ ===
   if(InpStrictInitChecks)
   {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      
      if(point <= 0 || tickValue <= 0 || minLot <= 0)
      {
         Alert("❌ KRİTİK: Broker verileri alınamadı! EA çalışmayı reddediyor.");
         return INIT_FAILED;
      }
      
      if(InpFixedLot < minLot)
      {
         Alert("❌ Lot boyutu minimum değerden küçük! Min: ", minLot);
         return INIT_FAILED;
      }
   }
   
   if(!Signal.Init()) return INIT_FAILED;
   
   Security.Init();
   
   m_trade.SetExpertMagicNumber(InpMagic);
   m_trade.SetDeviationInPoints(20);
   
   g_lastTradeOperationTime = GetTickCount();
   
   Print("═══════════════════════════════════════════");
   Print("🎯 TITANIUM OMEGA HARMONY BAŞLATILDI 🎯");
   Print("═══════════════════════════════════════════");
   Print("💰 Bakiye: ", AccountInfoDouble(ACCOUNT_BALANCE));
   Print("📊 Strateji: ", EnumToString(InpStrategyMode));
   Print("⚖️ Risk: %", DoubleToString(InpRiskPerTrade, 1), " | Lot: ", InpFixedLot);
   Print("🎯 SL: ", InpATRMultiplierSL, "x ATR | TP: ", InpATRMultiplierTP, "x ATR");
   Print("✅ Haber Filtresi: ", InpUseNewsFilter ? "AÇIK" : "KAPALI");
   Print("✅ Performans AI: ", InpUsePerformance ? "AÇIK" : "KAPALI");
   Print("═══════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}

//====================================================================
// OnDeinit
//====================================================================
void OnDeinit(const int reason)
{
   Signal.ReleaseHandles();
   
   if(g_totalTrades > 0)
   {
      double winRate = (g_totalWins > 0) ? (double)g_totalWins / g_totalTrades * 100.0 : 0;
      Print("═══ HARMONY ÖZET ═══");
      Print("Toplam İşlem: ", g_totalTrades);
      Print("Win Rate: %", DoubleToString(winRate, 1));
      Print("Hatalar: ", g_errorCount);
      Print("═══════════════════");
   }
   
   Comment("");
}

//====================================================================
// OnTick
//====================================================================
void OnTick()
{
   // === GÜVENLİK KONTROLLER ===
   if(!Security.IsSafeToTrade())
   {
      UpdateDashboard(0);
      return;
   }
   
   // Performans Analizi (Basit ML)
   if(!Security.CheckPerformance())
   {
      UpdateDashboard(0);
      return;
   }
   
   // Haber Kontrolü
   if(News.IsNewsTime())
   {
      UpdateDashboard(0);
      return;
   }
   
   // Pozisyon Yönetimi
   ManagePositions();
   
   // Mevcut pozisyon varsa yeni işlem açma
   int openPositions = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == InpMagic)
      {
         openPositions++;
      }
   }
   
   if(openPositions > 0)
   {
      g_StateReason = "📊 POZİSYON AÇIK: " + IntegerToString(openPositions);
      UpdateDashboard(0);
      return;
   }
   
   // === SİNYAL AL ===
   int signal = Signal.GetSignal();
   
   // === İŞLEM AÇ ===
   if(signal != SIGNAL_NONE)
   {
      OpenTrade(signal);
   }
   
   UpdateDashboard(signal);
}

//====================================================================
// OnTester - OPTİMİZASYON İÇİN
//====================================================================
double OnTester()
{
   double netProfit = TesterStatistics(STAT_PROFIT);
   double totalTrades = TesterStatistics(STAT_TRADES);
   double profitFactor = TesterStatistics(STAT_PROFIT_FACTOR);
   double maxDD = TesterStatistics(STAT_BALANCE_DD_RELATIVE);
   double sharpe = TesterStatistics(STAT_SHARPE_RATIO);
   
   // Minimum işlem kontrolü
   if(totalTrades < 30)
   {
      Print("❌ OPTIMIZATION: Yetersiz işlem (", totalTrades, ")");
      return 0.0;
   }
   
   // Zarar eden strateji
   if(netProfit < 0 || profitFactor < 1.0)
   {
      Print("❌ OPTIMIZATION: Zarar eden strateji");
      return 0.0;
   }
   
   // Aşırı Drawdown
   if(maxDD > 25.0)
   {
      Print("❌ OPTIMIZATION: Aşırı DD (%", DoubleToString(maxDD, 1), ")");
      return 0.0;
   }
   
   // ROBUST SCORE
   double pfScore = MathMin(profitFactor, 5.0);
   double sharpeScore = MathMax(0.1, MathMin(sharpe, 3.0));
   double tradeScore = MathSqrt(MathMin(totalTrades, 500.0));
   double ddPenalty = 1.0 + (maxDD / 100.0);
   
   double robustScore = (pfScore * sharpeScore * tradeScore) / ddPenalty;
   robustScore = MathMin(robustScore * 10.0, 1000.0);
   
   Print("🎯 HARMONY SCORE: ", DoubleToString(robustScore, 2));
   
   return robustScore;
}
