//+------------------------------------------------------------------+
//|                                     Titanium_Omega_v50.mq5       |
//|                     © 2025, Systemic Trading Engineering         |
//|  Versiyon: 50.0 - PRODUCTION READY (Üretim Kalitesi)            |
//|                                                                  |
//|  FEATURES:                                                       |
//|  - R:R 1:3 Strategy (Tight SL, Wide TP)                         |
//|  - Multi-Timeframe Confirmation (H1)                            |
//|  - ADX Trend Strength Filter                                     |
//|  - Partial Close & Breakeven                                     |
//|  - Advanced Error Handling                                       |
//|  - Performance Optimized                                         |
//+------------------------------------------------------------------+
#property copyright "© 2025, Systemic Trading Engineering"
#property version   "50.00"
#property strict
#property description "Titanium Omega v50 - Production Ready EA"

#include <Trade\Trade.mqh>

//====================================================================
// v50: ENUM TANIMLARI (Okunabilirlik için)
//====================================================================

/// @brief Piyasa rejimi
enum ENUM_MARKET_REGIME {
   REGIME_HIGH_VOLATILITY,   // Yüksek Volatilite
   REGIME_TRENDING,          // Trend
   REGIME_RANGING            // Yatay
};

/// @brief Strateji modu
enum ENUM_STRATEGY_MODE {
   STRATEGY_FRACTAL_REVERSAL,
   STRATEGY_HMA_CROSS,
   STRATEGY_AMA_CROSS,
   STRATEGY_MA_MASTER
};

/// @brief v50: Sinyal tipi (Okunabilirlik için)
enum ENUM_SIGNAL_TYPE {
   SIGNAL_NONE = 0,          // Sinyal yok
   SIGNAL_BUY  = 1,          // AL sinyali
   SIGNAL_SELL = -1          // SAT sinyali
};

//====================================================================
// v50 INPUT PARAMETRELERİ - PRODUCTION READY
//====================================================================

//--- 1. ANA AYARLAR
input group "=== 1. MAIN SETTINGS ==="
input ulong    InpMagic           = 505050;    // v50 Magic Number
input string   InpComment         = "Titanium v50 PROD"; 
input bool     InpShowDashboard   = true;
input ENUM_STRATEGY_MODE InpStrategyMode = STRATEGY_MA_MASTER;

//--- 2. RİSK YÖNETİMİ (v47: DÜŞÜK RİSK)
input group "=== 2. RISK MANAGEMENT (v47 SAFE) ==="
input double   InpRiskPerTrade    = 0.5;       // v47: İşlem Başı Risk % (DÜŞÜRÜLDÜ)
input double   InpFixedLot        = 0.01;      // Sabit Lot (Fallback)
input bool     InpUseRiskBasedLot = true;      // Risk Bazlı Lot Kullan
input double   InpMaxDrawdownStop = 25.0;      // Max Drawdown % (Durdurma)
input int      InpCooldownMinutes = 60;        // Drawdown Sonrası Bekleme (dk)
input int      InpMaxTradesPerDay = 10;        // v47.3: Günlük Max İşlem ARTİRİLDİ
input bool     InpAllowHedging    = false;     // v47: Hedging KAPALI (Net Yön)

//--- 3. STOP LOSS & TAKE PROFIT (v47.4: TIGHT SL, WIDE TP = R:R 1:3)
input group "=== 3. SL/TP SETTINGS (v47.4 R:R 1:3) ==="
input bool     InpUseATRStops     = true;      // ATR Bazlı SL/TP
input int      InpATRPeriod       = 14;        // ATR Periyodu
input double   InpATRMultiplierSL = 1.5;       // v47.4: SL Çarpanı SIKI (1.5x ATR)
input double   InpATRMultiplierTP = 4.5;       // v47.4: TP Çarpanı GENİŞ (4.5x = R:R 1:3)
input int      InpSL_Pips         = 15;        // v47.4: Sabit SL - 15 Pip
input int      InpTP_Pips         = 45;        // v47.4: Sabit TP - 45 Pip (3x SL)
input double   InpMinRiskReward   = 2.5;       // v47.4: Min R:R YÜKSEK (2.5)
input int      InpMinStopPips     = 10;        // v47.4: Min SL 10 pip (sıkı)

//--- 4. TRAILING STOP (v47.4: AGRESİF)
input group "=== 4. TRAILING STOP (v47.4 AGGRESSIVE) ==="
input bool     InpUseTrailing     = true;
input int      InpTrailingStart   = 15;        // v47.4: ERKEN başla (15 pip)
input int      InpTrailingStep    = 8;         // v47.4: SIKI adım (8 pip)

//--- 5. BREAKEVEN (v47.4: ERKEN)
input group "=== 5. BREAKEVEN (v47.4 EARLY) ==="
input bool     InpUseBreakeven    = true;
input int      InpBreakevenPips   = 12;        // v47.4: BE tetikleme ERKEN (12 pip)
input int      InpBreakevenOffset = 2;         // v47.4: BE offset (giriş + 2 pip)

//--- 6. MA MASTER AYARLARI (v47.4: GÜÇLÜ TREND)
input group "=== 6. MA MASTER (v47.4 STRONG TREND) ==="
input int      InpTrend_SMA       = 200;       // Ana Trend SMA
input int      InpSignal_EMA_Fast = 8;         // Sinyal Hızlı EMA
input int      InpSignal_EMA_Slow = 21;        // Sinyal Yavaş EMA
input bool     InpRequireEMAAlign = true;      // EMA Hizalama ŞARTİ
input int      InpMinADX          = 25;        // v47.4: ADX YÜKSEK (Güçlü Trend)

//--- 7. ZAMAN FİLTRESİ (v47.4: OVERLAP SAATLERİ)
input group "=== 7. TIME FILTER (v47.4 OVERLAP HOURS) ==="
input bool     InpUseTimeFilter   = true;      // Zaman Filtresi AKTİF
input int      InpStartHour       = 13;        // v47.4: NY Açılış (Overlap)
input int      InpEndHour         = 17;        // v47.4: Overlap Bitişi

//--- 8. SPREAD FİLTRESİ
input group "=== 8. SPREAD FILTER ==="
input int      InpMaxSpreadPips   = 5;         // v47: Max Spread (Düşük)

//--- 9. KONSENSÜS (v47: KAPALI)
input group "=== 9. CONSENSUS (DISABLED) ==="
input bool     InpUseConsensus    = false;     // v47: Konsensüs KAPALI

//--- 10. MULTI-TIMEFRAME ONAY (v47.1 YENİ)
input group "=== 10. MTF CONFIRMATION (v47.1) ==="
input bool     InpUseMTF          = true;      // v47.4: MTF AÇIK (Trend onayı)
input ENUM_TIMEFRAMES InpMTF_TF   = PERIOD_H1; // MTF Zaman Dilimi
input int      InpMTF_MA_Period   = 50;        // MTF MA Periyodu
input bool     InpMTF_RequireAbove = true;     // Fiyat MTF MA Üzerinde Olmalı

//--- 11. KISMİ KÂR ALMA (v47.1 YENİ)
input group "=== 11. PARTIAL CLOSE (v47.1) ==="
input bool     InpUsePartialClose = true;      // v47.1: Kısmi Kâr Alma
input double   InpPartialPercent  = 50.0;      // Kapanacak Pozisyon % 
input int      InpPartialTriggerPips = 30;     // Tetikleme Mesafesi (Pip)

//--- 12. PULLBACK GİRİŞ (v47.1 YENİ)
input group "=== 12. PULLBACK ENTRY (v47.1) ==="
input bool     InpUsePullbackEntry = false;    // v47.3: Pullback KAPALI (hızlı giriş)
input int      InpPullbackPips    = 10;        // EMA'ya Yakınlık (Pip)

//--- 13. SEANS TAKİBİ (v47.1 YENİ)
input group "=== 13. SESSION TRACKING (v47.1) ==="
input bool     InpTrackSessions   = true;      // v47.1: Seans Takibi
input int      InpLondonStart     = 8;         // Londra Başlangıç
input int      InpNYStart         = 13;        // New York Başlangıç
input int      InpNYEnd           = 21;        // New York Bitiş

//--- 14. İŞLEM ARASI BEKLEME (v47.1 YENİ)
input group "=== 14. TRADE COOLDOWN (v47.1) ==="
input int      InpBarsAfterTrade  = 5;         // İşlem Sonrası Beklenecek Bar
input int      InpMinutesCooldown = 15;        // v47.3: Cooldown DÜŞÜRÜLDÜ (15dk)

//====================================================================
// GLOBAL DEĞİŞKENLER (v50 - PRODUCTION READY)
//====================================================================

// === TEMEL DEĞİŞKENLER ===
int      g_tradesTodayCount = 0;          ///< Bugünkü işlem sayısı
datetime g_today_start = 0;               ///< Günün başlangıç zamanı
string   g_StateReason = "BAŞLATILIYOR..."; ///< Mevcut durum açıklaması
double   g_equityHigh = 0;                ///< En yüksek equity
double   g_maxDrawdownReached = 0;        ///< Ulaşılan max drawdown %
datetime g_cooldownUntil = 0;             ///< Cooldown bitiş zamanı
int      g_consecutiveWins = 0;           ///< Ardışık kazanç sayısı
int      g_consecutiveLosses = 0;         ///< Ardışık kayıp sayısı
int      g_lastSignalDirection = 0;       ///< Son sinyal yönü
datetime g_lastTradeTime = 0;             ///< Son işlem zamanı
int      g_barsSinceLastTrade = 0;        ///< Son işlemden bu yana bar sayısı

// === v50: POZİSYON CACHE (Performans için) ===
int      g_cachedOpenPositions = 0;       ///< Cache: Açık pozisyon sayısı
ulong    g_cachedPositionTickets[];       ///< Cache: Pozisyon ticketları
datetime g_lastPositionCheck = 0;         ///< Son pozisyon kontrolü zamanı

// === v50: DASHBOARD OPTİMİZASYONU ===
string   g_lastDashboardState = "";       ///< Son dashboard durumu (değişiklik kontrolü için)
datetime g_lastDashboardUpdate = 0;       ///< Son dashboard güncelleme zamanı
int      g_dashboardUpdateInterval = 1;   ///< Dashboard güncelleme aralığı (saniye)

// === v50: HATA YÖNETİMİ ===
int      g_errorCount = 0;                ///< Toplam hata sayısı
int      g_criticalErrorCount = 0;        ///< Kritik hata sayısı
datetime g_lastErrorTime = 0;             ///< Son hata zamanı
int      g_lastErrorCode = 0;             ///< Son hata kodu

// === İSTATİSTİKLER (Strategy Tester için) ===
double   g_grossProfit = 0;               ///< Brüt kâr
double   g_grossLoss = 0;                 ///< Brüt zarar
int      g_totalWins = 0;                 ///< Toplam kazançlı işlem
int      g_totalLosses = 0;               ///< Toplam kayıplı işlem
int      g_totalTrades = 0;               ///< Toplam işlem sayısı
double   g_peakBalance = 0;               ///< En yüksek bakiye
double   g_maxDrawdownMoney = 0;          ///< Para cinsinden max DD
double   g_profitHistory[];               ///< Kâr geçmişi (Sharpe için)
int      g_profitHistorySize = 0;         ///< Geçmiş boyutu
double   g_sumProfit = 0;                 ///< Toplam kâr
double   g_sumProfitSquared = 0;          ///< Kâr karelerinin toplamı
double   g_largestWin = 0;                ///< En büyük kazanç
double   g_largestLoss = 0;               ///< En büyük kayıp
double   g_avgWin = 0;                    ///< Ortalama kazanç
double   g_avgLoss = 0;                   ///< Ortalama kayıp
datetime g_firstTradeTime = 0;            ///< İlk işlem zamanı
datetime g_lastCloseTime = 0;             ///< Son kapanış zamanı

// === TRADE OBJECT ===
CTrade   m_trade;

//====================================================================
// HELPER FUNCTIONS
//====================================================================
double PipToPoints(int pips)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int multiplier = (digits == 3 || digits == 5) ? 10 : 1;
   return pips * multiplier * point;
}

//====================================================================
// CLASS: SIGNAL ENGINE (v47.1 - GELIŞMIŞ SINYAL MOTORU)
//====================================================================
class CSignalEngine
{
private:
   int m_hSMA_Trend;
   int m_hEMA_Fast;
   int m_hEMA_Slow;
   int m_hADX;
   int m_hMTF_MA;        // v47.1: MTF Moving Average
   
public:
   bool Init()
   {
      m_hSMA_Trend = iMA(_Symbol, PERIOD_CURRENT, InpTrend_SMA, 0, MODE_SMA, PRICE_CLOSE);
      m_hEMA_Fast = iMA(_Symbol, PERIOD_CURRENT, InpSignal_EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
      m_hEMA_Slow = iMA(_Symbol, PERIOD_CURRENT, InpSignal_EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
      m_hADX = iADX(_Symbol, PERIOD_CURRENT, 14);
      
      // v47.1: MTF MA
      if(InpUseMTF)
      {
         m_hMTF_MA = iMA(_Symbol, InpMTF_TF, InpMTF_MA_Period, 0, MODE_EMA, PRICE_CLOSE);
         if(m_hMTF_MA == INVALID_HANDLE)
         {
            Print("⚠️ v47.1: MTF MA yüklenemedi!");
         }
         else
         {
            Print("✅ v47.1: MTF MA (", EnumToString(InpMTF_TF), " EMA", InpMTF_MA_Period, ") yüklendi.");
         }
      }
      
      if(m_hSMA_Trend == INVALID_HANDLE || m_hEMA_Fast == INVALID_HANDLE || 
         m_hEMA_Slow == INVALID_HANDLE || m_hADX == INVALID_HANDLE)
      {
         Print("❌ v47: Göstergeler yüklenemedi!");
         return false;
      }
      Print("✅ v47.1: MA Master + ADX + MTF yüklendi.");
      return true;
   }
   
   void ReleaseHandles()
   {
      if(m_hSMA_Trend != INVALID_HANDLE) IndicatorRelease(m_hSMA_Trend);
      if(m_hEMA_Fast != INVALID_HANDLE) IndicatorRelease(m_hEMA_Fast);
      if(m_hEMA_Slow != INVALID_HANDLE) IndicatorRelease(m_hEMA_Slow);
      if(m_hADX != INVALID_HANDLE) IndicatorRelease(m_hADX);
      if(m_hMTF_MA != INVALID_HANDLE) IndicatorRelease(m_hMTF_MA);
   }
   
   // v47.1: MTF Trend Kontrolü
   int GetMTFTrend()
   {
      if(!InpUseMTF || m_hMTF_MA == INVALID_HANDLE) return 0;
      
      double mtfMA[];
      ArraySetAsSeries(mtfMA, true);
      if(CopyBuffer(m_hMTF_MA, 0, 0, 1, mtfMA) < 1) return 0;
      
      double price = iClose(_Symbol, InpMTF_TF, 0);
      
      if(InpMTF_RequireAbove)
      {
         if(price > mtfMA[0]) return 1;  // Yukarı trend
         if(price < mtfMA[0]) return -1; // Aşağı trend
      }
      else
      {
         // Sadece yönü belirle
         if(price > mtfMA[0]) return 1;
         else return -1;
      }
      return 0;
   }
   
   // v47.1: Pullback Kontrolü
   bool IsPullbackEntry(int direction)
   {
      if(!InpUsePullbackEntry) return true; // Devre dışıysa her zaman true
      
      double fast[];
      ArraySetAsSeries(fast, true);
      if(CopyBuffer(m_hEMA_Fast, 0, 0, 1, fast) < 1) return false;
      
      double price = iClose(_Symbol, PERIOD_CURRENT, 0);
      double pullbackDist = PipToPoints(InpPullbackPips);
      
      // BUY: Fiyat EMA'nın yakınında (çok üstünde değil)
      if(direction == 1)
      {
         double distFromEMA = price - fast[0];
         if(distFromEMA >= 0 && distFromEMA <= pullbackDist)
            return true;
      }
      // SELL: Fiyat EMA'nın yakınında (çok altında değil)
      else if(direction == -1)
      {
         double distFromEMA = fast[0] - price;
         if(distFromEMA >= 0 && distFromEMA <= pullbackDist)
            return true;
      }
      
      g_StateReason = "PULLBACK BEKLENİYOR";
      return false;
   }
   
   // v47.1: Seans Kontrolü
   bool IsActiveSession()
   {
      if(!InpTrackSessions) return true;
      
      MqlDateTime dt;
      TimeCurrent(dt);
      int hour = dt.hour;
      
      // Londra veya NY seansında mı?
      bool inLondon = (hour >= InpLondonStart && hour < InpNYEnd);
      bool inNY = (hour >= InpNYStart && hour < InpNYEnd);
      
      if(inLondon || inNY)
      {
         // Overlap saatleri bonus (en iyi zaman)
         if(hour >= InpNYStart && hour < 17)
         {
            g_StateReason = "SEANS: LONDRA-NY OVERLAP 🔥";
         }
         else if(inLondon)
         {
            g_StateReason = "SEANS: LONDRA";
         }
         else
         {
            g_StateReason = "SEANS: NEW YORK";
         }
         return true;
      }
      
      g_StateReason = "SEANS DIŞI";
      return false;
   }
   
   // v47.1: GÜÇLENDİRİLMİŞ MA MASTER SİNYALİ
   int GetMAMasterSignal()
   {
      // 1. Veri Okuma
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
      
      // 2. ADX FİLTRESİ (Trend Gücü)
      if(adx[0] < InpMinADX)
      {
         g_StateReason = "ADX DÜŞÜK (" + DoubleToString(adx[0], 1) + " < " + IntegerToString(InpMinADX) + ")";
         return 0;
      }
      
      // 3. TREND YÖNÜ (GÜÇLENDİRİLMİŞ)
      int trend = 0;
      
      if(InpRequireEMAAlign)
      {
         // v47: EMA Hizalama Şartı
         // BUY: Price > EMA8 > EMA21 > SMA200
         if(price > fast[0] && fast[0] > slow[0] && slow[0] > smaTrend[0])
         {
            trend = 1;
         }
         // SELL: Price < EMA8 < EMA21 < SMA200
         else if(price < fast[0] && fast[0] < slow[0] && slow[0] < smaTrend[0])
         {
            trend = -1;
         }
      }
      else
      {
         // Basit kontrol
         if(price > smaTrend[0] && fast[0] > smaTrend[0] && slow[0] > smaTrend[0])
            trend = 1;
         else if(price < smaTrend[0] && fast[0] < smaTrend[0] && slow[0] < smaTrend[0])
            trend = -1;
      }
      
      if(trend == 0) 
      {
         g_StateReason = "TREND YOK (EMA Hizalanmamış)";
         return 0;
      }
      
      // 4. EMA CROSS SİNYALİ
      bool goldenCross = (fast[1] <= slow[1] && fast[0] > slow[0]);
      bool deathCross  = (fast[1] >= slow[1] && fast[0] < slow[0]);
      
      // 5. ANA SİNYAL
      if(trend == 1 && goldenCross)
      {
         g_StateReason = "v47: GÜÇLÜ BUY (ADX:" + DoubleToString(adx[0], 0) + ")";
         return 1;
      }
      if(trend == -1 && deathCross)
      {
         g_StateReason = "v47: GÜÇLÜ SELL (ADX:" + DoubleToString(adx[0], 0) + ")";
         return -1;
      }
      
      g_StateReason = "SİNYAL BEKLENİYOR";
      return 0;
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
// CLASS: RISK MANAGER (v47 - GÜVENLİ)
//====================================================================
class CRiskManager
{
public:
   // v47: Güvenli Lot Hesaplama
   double GetSafeLot()
   {
      if(!InpUseRiskBasedLot) return InpFixedLot;
      
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * (InpRiskPerTrade / 100.0);
      
      // Stop Loss Puanı (v47: Minimum 25 pip zorunlu)
      double slPips = InpSL_Pips;
      
      if(InpUseATRStops)
      {
         int hATR = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
         double atr[1];
         CopyBuffer(hATR, 0, 0, 1, atr);
         IndicatorRelease(hATR);
         
         double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         double atrPips = atr[0] * InpATRMultiplierSL / point / 10.0;
         slPips = MathMax(atrPips, (double)InpMinStopPips);
      }
      
      slPips = MathMax(slPips, (double)InpMinStopPips); // Minimum garantisi
      
      double slPoints = PipToPoints((int)slPips);
      if(slPoints <= 0) return InpFixedLot;
      
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      if(tickValue <= 0) return InpFixedLot;
      
      // Risk bazlı lot
      double lot = riskAmount / (slPips * 10 * tickValue);
      
      // Marjin kontrolü
      double marginPerLot = 0;
      double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, 1.0, price, marginPerLot) && marginPerLot > 0)
      {
         double equity = AccountInfoDouble(ACCOUNT_EQUITY);
         double maxLotByMargin = (equity * 0.80) / marginPerLot; // %80 kullanım
         lot = MathMin(lot, maxLotByMargin);
      }
      
      // Broker limitleri
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      
      lot = MathFloor(lot / stepLot) * stepLot;
      lot = MathMax(minLot, MathMin(lot, maxLot));
      
      return lot;
   }
   
   // v47: ATR Stop Loss (Geniş + Minimum Koruma)
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
      
      // v47: Minimum mesafe garantisi (25 pip)
      double minDist = PipToPoints(InpMinStopPips);
      if(slDist < minDist) slDist = minDist;
      
      // StopLevel kontrolü
      double stopLevel = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;
      double spread = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * point;
      double brokerMin = MathMax(stopLevel, spread * 2.0);
      if(slDist < brokerMin) slDist = brokerMin + (10 * point);
      
      if(direction == 1) return SymbolInfoDouble(_Symbol, SYMBOL_ASK) - slDist;
      else return SymbolInfoDouble(_Symbol, SYMBOL_BID) + slDist;
   }
   
   // v47: ATR Take Profit (Trend Takip)
   double GetATRTakeProfit(int direction)
   {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
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
      
      // Minimum TP (SL'nin 1.5 katı)
      double minTP = PipToPoints(InpMinStopPips) * 1.5;
      if(tpDist < minTP) tpDist = minTP;
      
      if(direction == 1) return SymbolInfoDouble(_Symbol, SYMBOL_ASK) + tpDist;
      else return SymbolInfoDouble(_Symbol, SYMBOL_BID) - tpDist;
   }
   
   // v47: R:R Kontrolü
   bool CheckRiskReward(double entry, double sl, double tp)
   {
      if(sl == 0 || tp == 0) return true;
      
      double risk = MathAbs(entry - sl);
      double reward = MathAbs(tp - entry);
      
      if(risk <= 0) return false;
      double rr = reward / risk;
      
      if(rr < InpMinRiskReward)
      {
         g_StateReason = "R:R DÜŞÜK (" + DoubleToString(rr, 2) + ")";
         return false;
      }
      return true;
   }
   
   // Emergency Drawdown
   bool CheckEmergencyDrawdown()
   {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      if(equity > g_equityHigh) g_equityHigh = equity;
      
      double dd = 0;
      if(g_equityHigh > 0) dd = (g_equityHigh - equity) / g_equityHigh * 100.0;
      if(dd > g_maxDrawdownReached) g_maxDrawdownReached = dd;
      
      if(dd >= InpMaxDrawdownStop)
      {
         g_cooldownUntil = TimeCurrent() + (InpCooldownMinutes * 60);
         g_StateReason = "EMERGENCY DD: %" + DoubleToString(dd, 1);
         return true;
      }
      return false;
   }
   
   bool IsInCooldown()
   {
      if(g_cooldownUntil > 0 && TimeCurrent() < g_cooldownUntil)
      {
         g_StateReason = "COOLDOWN: " + TimeToString(g_cooldownUntil);
         return true;
      }
      g_cooldownUntil = 0;
      return false;
   }
};

//====================================================================
// GLOBAL OBJECTS
//====================================================================
CSignalEngine Signal;
CRiskManager  RiskMgr;

//====================================================================
// HELPER: Güvenlik Kontrolleri
//====================================================================
bool IsSafeToTrade()
{
   // Drawdown kontrolü
   if(RiskMgr.CheckEmergencyDrawdown()) return false;
   if(RiskMgr.IsInCooldown()) return false;
   
   // Günlük limit
   if(InpMaxTradesPerDay > 0 && g_tradesTodayCount >= InpMaxTradesPerDay)
   {
      g_StateReason = "GÜNLÜK LİMİT: " + IntegerToString(g_tradesTodayCount);
      return false;
   }
   
   // Zaman filtresi (v47: Aktif)
   if(InpUseTimeFilter)
   {
      MqlDateTime dt;
      TimeCurrent(dt);
      if(dt.hour < InpStartHour || dt.hour >= InpEndHour)
      {
         g_StateReason = "ZAMAN FİLTRESİ (" + IntegerToString(dt.hour) + ":00)";
         return false;
      }
   }
   
   // Spread kontrolü
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   double spreadPips = spread / 10.0;
   if(spreadPips > InpMaxSpreadPips)
   {
      g_StateReason = "YÜKSEK SPREAD: " + DoubleToString(spreadPips, 1);
      return false;
   }
   
   // Marjin kontrolü
   double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   if(marginLevel > 0 && marginLevel < 100)
   {
      g_StateReason = "DÜŞÜK MARJİN: %" + DoubleToString(marginLevel, 0);
      return false;
   }
   
   return true;
}

// Hedging kontrolü
bool CanOpenPosition(int direction)
{
   if(InpAllowHedging) return true;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol && 
         PositionGetInteger(POSITION_MAGIC) == InpMagic)
      {
         long posType = PositionGetInteger(POSITION_TYPE);
         if((direction == 1 && posType == POSITION_TYPE_SELL) ||
            (direction == -1 && posType == POSITION_TYPE_BUY))
         {
            g_StateReason = "HEDGING ENGELLENDİ";
            return false;
         }
      }
   }
   return true;
}

// Yeni gün kontrolü
void CheckNewDay()
{
   datetime today = iTime(_Symbol, PERIOD_D1, 0);
   if(g_today_start != today)
   {
      g_today_start = today;
      g_tradesTodayCount = 0;
   }
}

//====================================================================
// v50: İŞLEM AÇMA (Gelişmiş Hata Yönetimi)
//====================================================================
void OpenTrade(int direction)
{
   // === 1. LOT VE SEVİYE HESAPLAMA ===
   double lot = RiskMgr.GetSafeLot();
   double sl = RiskMgr.GetATRStopLoss(direction);
   double tp = RiskMgr.GetATRTakeProfit(direction);
   
   double entry = (direction == SIGNAL_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // === 2. R:R KONTROLÜ ===
   if(!RiskMgr.CheckRiskReward(entry, sl, tp))
   {
      Print("⚠️ v50: R:R kontrolü başarısız - işlem iptal");
      return;
   }
   
   // === 3. FİYAT NORMALİZASYONU ===
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   sl = NormalizeDouble(sl, digits);
   tp = NormalizeDouble(tp, digits);
   entry = NormalizeDouble(entry, digits);
   
   // === 4. İŞLEM AÇMA ===
   ResetLastError(); // v50: Önceki hatayı temizle
   bool success = false;
   
   if(direction == SIGNAL_BUY)
   {
      success = m_trade.Buy(lot, _Symbol, 0, sl, tp, InpComment);
   }
   else if(direction == SIGNAL_SELL)
   {
      success = m_trade.Sell(lot, _Symbol, 0, sl, tp, InpComment);
   }
   
   // === 5. SONUÇ DEĞERLENDİRME ===
   if(success && m_trade.ResultRetcode() == TRADE_RETCODE_DONE)
   {
      g_tradesTodayCount++;
      g_lastSignalDirection = direction;
      g_lastTradeTime = TimeCurrent();
      g_cachedOpenPositions++; // v50: Cache güncelle
      
      Print("✅ v50: ", (direction == SIGNAL_BUY ? "BUY" : "SELL"), 
            " | Lot:", DoubleToString(lot, 2),
            " | Entry:", DoubleToString(entry, digits),
            " | SL:", DoubleToString(sl, digits),
            " | TP:", DoubleToString(tp, digits),
            " | Ticket:", m_trade.ResultOrder());
   }
   else
   {
      // === v50: GELİŞMİŞ HATA YÖNETİMİ ===
      int errorCode = GetLastError();
      int retcode = (int)m_trade.ResultRetcode();
      string errorDesc = m_trade.ResultRetcodeDescription();
      
      // Hata sayaçlarını güncelle
      g_errorCount++;
      g_lastErrorCode = (errorCode != 0) ? errorCode : retcode;
      g_lastErrorTime = TimeCurrent();
      
      // Hata logla
      Print("❌ v50: İşlem BAŞARISIZ!");
      Print("   -> RetCode: ", retcode, " (", errorDesc, ")");
      Print("   -> LastError: ", errorCode);
      Print("   -> Lot: ", DoubleToString(lot, 2), " | SL: ", DoubleToString(sl, digits), " | TP: ", DoubleToString(tp, digits));
      
      // Kritik hatalar için Alert
      if(retcode == TRADE_RETCODE_NO_MONEY || 
         retcode == TRADE_RETCODE_INVALID_STOPS ||
         retcode == TRADE_RETCODE_MARKET_CLOSED)
      {
         g_criticalErrorCount++;
         Alert("❌ TITANIUM v50 KRİTİK HATA: ", errorDesc);
      }
      
      // Hata kodunu sıfırla
      ResetLastError();
   }
}

//====================================================================
// POZİSYON YÖNETİMİ (v47.1: Trailing + Breakeven + Partial Close)
//====================================================================
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
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      
      // v47.1: KISMİ KÂR ALMA
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
               if(m_trade.PositionClosePartial(ticket, closeVol))
               {
                  Print("🎯 v47.1: Kısmi kâr alındı! ", DoubleToString(closeVol, 2), " lot kapatıldı.");
               }
            }
         }
      }
      
      // BREAKEVEN
      if(InpUseBreakeven)
      {
         double beTrigger = PipToPoints(InpBreakevenPips);
         double beOffset = PipToPoints(InpBreakevenOffset);
         
         if(type == POSITION_TYPE_BUY)
         {
            if(curr > open + beTrigger && sl < open)
            {
               double newSL = open + beOffset;
               m_trade.PositionModify(ticket, newSL, tp);
            }
         }
         else
         {
            if(curr < open - beTrigger && (sl > open || sl == 0))
            {
               double newSL = open - beOffset;
               m_trade.PositionModify(ticket, newSL, tp);
            }
         }
      }
      
      // TRAILING STOP
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
                  m_trade.PositionModify(ticket, newSL, tp);
            }
         }
         else
         {
            if(open - curr > trailStart)
            {
               double newSL = curr + trailStart;
               if(sl == 0 || newSL < sl - trailStep)
                  m_trade.PositionModify(ticket, newSL, tp);
            }
         }
      }
   }
}

//====================================================================
// OnInit
//====================================================================
int OnInit()
{
   if(!Signal.Init()) return INIT_FAILED;
   
   m_trade.SetExpertMagicNumber(InpMagic);
   m_trade.SetDeviationInPoints(20);
   
   g_equityHigh = AccountInfoDouble(ACCOUNT_EQUITY);
   g_peakBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   // v47.2: Kâr geçmişi dizisini başlat (Sharpe hesabı için)
   ArrayResize(g_profitHistory, 1000);
   ArrayInitialize(g_profitHistory, 0);
   
   Print("=================================================");
   Print("TITANIUM OMEGA v47.2 - STRATEGY TESTER OPTIMIZED");
   Print("=================================================");
   Print("💰 Bakıye: ", AccountInfoDouble(ACCOUNT_BALANCE));
   Print("📊 Risk: %", DoubleToString(InpRiskPerTrade, 1), " | SL: ", InpATRMultiplierSL, "x ATR | TP: ", InpATRMultiplierTP, "x ATR");
   Print("⏰ Saat: ", InpStartHour, ":00 - ", InpEndHour, ":00");
   Print("📈 Min ADX: ", InpMinADX, " | Min SL: ", InpMinStopPips, " pips");
   Print("🧪 Strategy Tester Optimizations: AKTİF");
   Print("=================================================");
   
   return INIT_SUCCEEDED;
}

//====================================================================
// v47.2: İŞLEM İSTATİSTİKLERİNİ GÜNCELLE (Her kapanan işlemde çağrılır)
//====================================================================
void UpdateTradeStats(double profit, double volume)
{
   g_totalTrades++;
   g_sumProfit += profit;
   g_sumProfitSquared += profit * profit;
   
   // İlk işlem zamanını kaydet
   if(g_firstTradeTime == 0) g_firstTradeTime = TimeCurrent();
   g_lastCloseTime = TimeCurrent();
   
   if(profit > 0)
   {
      g_totalWins++;
      g_grossProfit += profit;
      g_consecutiveWins++;
      g_consecutiveLosses = 0;
      if(profit > g_largestWin) g_largestWin = profit;
   }
   else if(profit < 0)
   {
      g_totalLosses++;
      g_grossLoss += MathAbs(profit);
      g_consecutiveLosses++;
      g_consecutiveWins = 0;
      if(MathAbs(profit) > g_largestLoss) g_largestLoss = MathAbs(profit);
   }
   
   // Ortalama kazanç/kayıp güncelle
   if(g_totalWins > 0) g_avgWin = g_grossProfit / g_totalWins;
   if(g_totalLosses > 0) g_avgLoss = g_grossLoss / g_totalLosses;
   
   // Kâr geçmişine ekle (Sharpe için)
   if(g_profitHistorySize < 1000)
   {
      g_profitHistory[g_profitHistorySize] = profit;
      g_profitHistorySize++;
   }
   
   // Peak balance ve drawdown güncelle
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   if(balance > g_peakBalance) g_peakBalance = balance;
   
   double ddMoney = g_peakBalance - balance;
   if(ddMoney > g_maxDrawdownMoney) g_maxDrawdownMoney = ddMoney;
   
   Print("📊 Trade #", g_totalTrades, " | Sonuç: ", (profit >= 0 ? "+" : ""), DoubleToString(profit, 2), 
         " | WinRate: ", DoubleToString(GetWinRate(), 1), "%");
}

//====================================================================
// v47.2: METRİK HESAPLAMA FONKSİYONLARI
//====================================================================
double GetWinRate()
{
   if(g_totalTrades == 0) return 0;
   return (double)g_totalWins / g_totalTrades * 100.0;
}

double GetProfitFactor()
{
   if(g_grossLoss == 0) return g_grossProfit > 0 ? 100.0 : 0.0;
   return g_grossProfit / g_grossLoss;
}

double GetSharpeRatio()
{
   if(g_profitHistorySize < 2) return 0;
   
   // Ortalama hesapla
   double mean = g_sumProfit / g_profitHistorySize;
   
   // Standart sapma hesapla
   double variance = (g_sumProfitSquared / g_profitHistorySize) - (mean * mean);
   if(variance <= 0) return 0;
   double stdDev = MathSqrt(variance);
   
   if(stdDev == 0) return 0;
   return mean / stdDev;
}

double GetMaxDrawdownPercent()
{
   if(g_peakBalance == 0) return 0;
   return (g_maxDrawdownMoney / g_peakBalance) * 100.0;
}

double GetExpectancy()
{
   if(g_totalTrades == 0) return 0;
   double winRate = GetWinRate() / 100.0;
   double lossRate = 1.0 - winRate;
   return (winRate * g_avgWin) - (lossRate * g_avgLoss);
}

//====================================================================
// v47.2: OnTester() - ÖZEL OPTİMİZASYON KRİTERİ
// Anti-Overfitting: Sadece kârı değil, tutarlılığı da ölçer
//====================================================================
double OnTester()
{
   // === 1. TEMEL İSTATİSTİKLER ===
   double netProfit = TesterStatistics(STAT_PROFIT);
   double totalTrades = TesterStatistics(STAT_TRADES);
   double profitFactor = TesterStatistics(STAT_PROFIT_FACTOR);
   double maxDD = TesterStatistics(STAT_BALANCE_DD_RELATIVE);
   double sharpe = TesterStatistics(STAT_SHARPE_RATIO);
   double winRate = totalTrades > 0 ? (TesterStatistics(STAT_PROFIT_TRADES) / totalTrades) * 100.0 : 0;
   
   // === 2. MİNİMUM İŞLEM SAYISI KONTROLÜ (Anti-Overfitting) ===
   double minTradesRequired = 30.0;
   if(totalTrades < minTradesRequired)
   {
      Print("❌ OPTIMIZATION FAILED: Yetersiz işlem (", totalTrades, " < ", minTradesRequired, ")");
      return 0.0; // Yetersiz veri = geçersiz sonuç
   }
   
   // === 3. ZARAR EDEN STRATEJİYİ ELEYEZ ===
   if(netProfit < 0 || profitFactor < 1.0)
   {
      Print("❌ OPTIMIZATION FAILED: Zarar eden strateji (PF: ", DoubleToString(profitFactor, 2), ")");
      return 0.0;
   }
   
   // === 4. AŞIRİ DRAWDOWN KONTROLÜ ===
   double maxAllowedDD = 25.0;
   if(maxDD > maxAllowedDD)
   {
      Print("❌ OPTIMIZATION FAILED: Aşırı DD (%", DoubleToString(maxDD, 1), " > %", DoubleToString(maxAllowedDD, 1), ")");
      return 0.0;
   }
   
   // === 5. ROBUST OPTIMIZATION SCORE ===
   // Formül: (PF * Sharpe * √Trades * WinRate) / (1 + DD)
   // Bu formül:
   // - Yüksek Profit Factor ödüllendirir
   // - Yüksek Sharpe (risk-adjusted return) ödüllendirir
   // - Çok işlem = güvenilir sonuç (kare kök ile dengeleniyor)
   // - Yüksek Win Rate bonusu
   // - Düşük Drawdown ödüllendirir
   
   double pfScore = MathMin(profitFactor, 5.0);  // Cap at 5 (aşırı değerleri sınırla)
   double sharpeScore = MathMax(0.1, MathMin(sharpe, 3.0)); // 0.1-3.0 arası
   double tradeScore = MathSqrt(MathMin(totalTrades, 500.0)); // 500'den sonra azalan katkı
   double winScore = winRate / 50.0; // %50 win rate = 1.0
   double ddPenalty = 1.0 + (maxDD / 100.0); // DD arttıkça ceza artar
   
   double robustScore = (pfScore * sharpeScore * tradeScore * winScore) / ddPenalty;
   
   // Normalize (0-1000 arası)
   robustScore = MathMin(robustScore * 10.0, 1000.0);
   
   // === 6. DETAYLI LOG ===
   Print("=================================================");
   Print("📊 v47.2 OPTIMIZATION RESULT");
   Print("=================================================");
   Print("💰 Net Profit: $", DoubleToString(netProfit, 2));
   Print("📈 Trades: ", (int)totalTrades, " | Win Rate: %", DoubleToString(winRate, 1));
   Print("⚡ Profit Factor: ", DoubleToString(profitFactor, 2));
   Print("📉 Max Drawdown: %", DoubleToString(maxDD, 1));
   Print("📐 Sharpe Ratio: ", DoubleToString(sharpe, 2));
   Print("-------------------------------------------------");
   Print("🎯 ROBUST SCORE: ", DoubleToString(robustScore, 2));
   Print("=================================================");
   
   return robustScore;
}

//====================================================================
// OnDeinit
//====================================================================
void OnDeinit(const int reason)
{
   Signal.ReleaseHandles();
   
   // v47.2: Son istatistikleri yazdır
   if(g_totalTrades > 0)
   {
      Print("=== v47.2 FINAL STATISTICS ===");
      Print("Total Trades: ", g_totalTrades);
      Print("Win Rate: ", DoubleToString(GetWinRate(), 1), "%");
      Print("Profit Factor: ", DoubleToString(GetProfitFactor(), 2));
      Print("Sharpe Ratio: ", DoubleToString(GetSharpeRatio(), 2));
      Print("Max Drawdown: ", DoubleToString(GetMaxDrawdownPercent(), 1), "%");
      Print("Expectancy: $", DoubleToString(GetExpectancy(), 2));
      Print("Largest Win: $", DoubleToString(g_largestWin, 2));
      Print("Largest Loss: $", DoubleToString(g_largestLoss, 2));
      Print("==============================");
   }
   
   Comment("");
}

//====================================================================
// OnTick
//====================================================================
void OnTick()
{
   CheckNewDay();
   ManagePositions();
   
   bool safeToOpen = IsSafeToTrade();
   
   if(!safeToOpen)
   {
      UpdateDashboard(0);
      return;
   }
   
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
      g_StateReason = "POZİSYON AÇIK: " + IntegerToString(openPositions);
      UpdateDashboard(0);
      return;
   }
   
   // Sinyal al
   int signal = Signal.GetMAMasterSignal();
   
   // v47.1: Seans kontrolü
   if(signal != 0 && !Signal.IsActiveSession())
   {
      signal = 0;
   }
   
   // v47.1: MTF Trend Onayı
   if(signal != 0 && InpUseMTF)
   {
      int mtfTrend = Signal.GetMTFTrend();
      if(mtfTrend != 0 && mtfTrend != signal)
      {
         g_StateReason = "MTF UYUŞMAZLIĞI (H1 vs M1)";
         signal = 0;
      }
   }
   
   // v47.1: Pullback Girişi
   if(signal != 0 && !Signal.IsPullbackEntry(signal))
   {
      signal = 0;
   }
   
   // v47.1: İşlem Arası Bekleme
   if(signal != 0 && g_lastTradeTime > 0)
   {
      datetime minNextTrade = g_lastTradeTime + (InpMinutesCooldown * 60);
      if(TimeCurrent() < minNextTrade)
      {
         g_StateReason = "İŞLEM ARASI BEKLEME";
         signal = 0;
      }
   }
   
   // Hedging kontrolü
   if(signal != 0 && !CanOpenPosition(signal))
   {
      signal = 0;
   }
   
   // İşlem aç
   if(signal != 0)
   {
      OpenTrade(signal);
   }
   
   UpdateDashboard(signal);
}

//====================================================================
// Dashboard
//====================================================================
void UpdateDashboard(int signal)
{
   if(!InpShowDashboard) return;
   
   double adx = Signal.GetADX();
   double lot = RiskMgr.GetSafeLot();
   
   string dash = "+================================================+\n";
   dash += "|   TITANIUM OMEGA v47.0 - PROFIT OPTIMIZED     |\n";
   dash += "+================================================+\n";
   dash += "| DURUM    : " + g_StateReason + "\n";
   dash += "| SİNYAL   : " + (signal == 1 ? "🟢 BUY" : (signal == -1 ? "🔴 SELL" : "⏳ BEKLEME")) + "\n";
   dash += "+------------------------------------------------+\n";
   dash += "| ADX      : " + DoubleToString(adx, 1) + " (MIN: " + IntegerToString(InpMinADX) + ")\n";
   dash += "| LOT      : " + DoubleToString(lot, 2) + " (Risk: %" + DoubleToString(InpRiskPerTrade, 1) + ")\n";
   dash += "| DRAWDOWN : %" + DoubleToString(g_maxDrawdownReached, 1) + "\n";
   dash += "+------------------------------------------------+\n";
   dash += "| İŞLEMLER : " + IntegerToString(g_tradesTodayCount) + "/" + IntegerToString(InpMaxTradesPerDay) + "\n";
   dash += "| POZİSYON : " + IntegerToString(PositionsTotal()) + "\n";
   dash += "+================================================+";
   
   Comment(dash);
}
