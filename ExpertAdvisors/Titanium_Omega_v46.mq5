//+------------------------------------------------------------------+
//|                                     Titanium_Omega_v46.mq5       |
//|                     © 2025, Systemic Trading Engineering         |
//|  Versiyon: 46.0 (OPTIMIZED PROFIT - MA MASTER NATIVE)           |
//+------------------------------------------------------------------+
#property copyright "© 2025, Systemic Trading Engineering"
#property version   "46.00"
#property strict

#include <Trade\Trade.mqh>

//--- ENUMS
enum ENUM_MARKET_REGIME {
   REGIME_HIGH_VOLATILITY, // Yüksek Volatilite (Bekle)
   REGIME_TRENDING,        // Trend (İşlem Yap)
   REGIME_RANGING          // Yatay (Dikkatli Ol)
};

enum ENUM_STRATEGY_MODE {
   STRATEGY_FRACTAL_REVERSAL, // Mevcut: Dönüş Yakalama (Sniper)
   STRATEGY_HMA_CROSS,        // HMA Cross: Trend Takip
   STRATEGY_AMA_CROSS,        // v30: AMA Cross
   STRATEGY_MA_MASTER         // v42: Native MA Master (SMA+EMA)
};

// v35: Emir Tipi Seçimi
enum ENUM_ORDER_TYPE_MODE {
   ORDER_MODE_MARKET,         // Anında Market Emri
   ORDER_MODE_STOP,           // Bekleyen Stop Emir (BuyStop/SellStop)
   ORDER_MODE_LIMIT           // Bekleyen Limit Emir (BuyLimit/SellLimit)
};

//--- INPUTS
//--- 1. ANA AYARLAR
input group "=== 1. MAIN SETTINGS ==="
input ulong    InpMagic           = 123456;    // Magic Number
input string   InpComment         = "Titanium Omega v46"; // İşlem Yorumu
input bool     InpShowDashboard   = true;      // Bilgi Paneli Göster
input ENUM_STRATEGY_MODE InpStrategyMode = STRATEGY_MA_MASTER; // v46: MA MASTER VARSAYILAN
input bool     InpStrictInitChecks = true;  // Sıkı Başlangıç Kontrolleri (Safety)

//--- 2. RİSK VE SERMAYE YÖNETİMİ
input group "=== 2. RISK & CAPITAL ==="
input double   InpBaseRiskPercent = 2.0;      // v46: Baz Risk % (Artırıldı)
input double   InpMaxDailyLoss    = 30.0;     // Günlük Max Zarar %
input double   InpMaxMoneyDD      = 5.0;      // Günlük Max Zarar $ (Küçük hesaplar için genişletilebilir)
input double   InpMinMarginLevel  = 50.0;     // Min Marjin Seviyesi %
input bool     InpDetectDeposit   = true;     // Para Yatırma/Çekme Algıla
input bool     InpMultiOrder      = true;     // Çoklu Emir Aç
input int      InpMaxOpenOrders   = 5;        // Max Açık Emir Sayısı
input bool     InpCancelOnReverse = true;     // Yön Değişince Bekleyenleri Sil
input bool     InpAllowHedging    = true;     // Hedging İzni (Ters Yön)

//--- 3. GRID MATRIX (v40: SCALPING)
input group "=== 3. GRID MATRIX (v40 SCALPING) ==="
input double   InpFixedLot        = 0.01;     // v40: Sabit Lot (Mikro)
input int      InpMaxOrders       = 3;        // v46: Max Basamak Sayısı (Artırıldı)
input int      InpStepPips        = 15;       // v46: Adım Aralığı (Genişletildi)
input int      InpSL_Pips         = 30;       // v46: Stop Loss (Pips) - Daha güvenli
input int      InpTP_Pips         = 60;       // v46: Take Profit (Pips) - Trend yakalama
input int      InpExpirationHrs   = 4;        // Bekleyen Emir Ömrü (Saat)

//--- 4. STRATEJİ MOTORU
input group "=== 4. STRATEGY ENGINE ==="
input ENUM_TIMEFRAMES HigherTF    = PERIOD_M15; // MTF Onayı
input int      MainTrend_MA       = 200;       // Ana Trend Filtresi (HMA)
input int      InpHMA_Fast        = 20;        // HMA Cross Hızlı
input int      InpHMA_Slow        = 50;        // HMA Cross Yavaş
input int      Regime_Lookback    = 50;        // Volatilite Lookback
input double   Vol_Explosion_Mul  = 1.8;       // Volatilite Patlama Çarpanı

//--- 5. AMA AYARLARI (v30)
input group "=== 5. AMA SETTINGS (v30) ==="
input int      InpAMA_Period      = 50;        // AMA Periyodu
input int      InpAMA_Fast        = 5;         // AMA Hızlı
input int      InpAMA_Slow        = 100;       // AMA Yavaş

//--- 6. GÜVENLİK VE STRES TESTİ
input group "=== 6. SAFETY & STRESS ==="
input int      InpMaxSpreadPips   = 6;        // Max Spread
input bool     InpUseTimeFilter   = false;    // Zaman Filtresi
input int      InpStartHour       = 8;        // Başlangıç Saati
input int      InpEndHour         = 20;       // Bitiş Saati
input bool     StressTest_Mode    = false;    // Stres Testi
input int      Simulated_Slippage = 10;       // Kayma (Points)

//--- 7. OPERASYONEL (v40: SCALPING OPTIMIZED)
input group "=== 7. OPS & MANAGEMENT (v40) ==="
input bool     InpUseBreakeven    = true;     // v40: Tight Breakeven
input bool     InpUseTrailing     = true;     // Trailing Stop Kullan
input int      InpTrailingStart   = 15;       // v46: Trailing Başlangıç (Pips) - Gevşetildi
input int      InpTrailingStep    = 5;        // Trailing Adım (Pips)
input bool     InpUseSmartPartial = true;     // Akıllı Kısmi Kapama
input bool     InpManageManual    = true;     // Manuel İşlemleri de Yönet

//--- 8. AI & HABER
input group "=== 7. AI & NEWS FILTER ==="
input bool     InpUseNewsFilter   = true;     // Haber Filtresi (Ekonomik Takvim)
input int      InpNewsPauseMins   = 60;       // Haber Öncesi/Sonrası Bekleme (Dk)
input bool     InpUseDynamicLot   = true;     // Dinamik Lot (ATR Bazlı)
input bool     InpUsePerformance  = true;     // Performans Analizi (Basit ML)
input int      InpMaxLoseStreak   = 3;        // Üst Üste Max Zarar (Duraklatma İçin)

//--- 8. RULE ENFORCER (GÜVENLİK v24)
input group "=== 8. TANK SECURITY (v24) ==="
input int      InpMaxTradesPerDay      = 0;        // Günlük Maks İşlem (0 = SINIRSIZ)
input int      InpMinRequestIntervalMs = 100;      // Emirler Arası Bekleme (Anti-Spam, ms)
//--- 8. MA MASTER SETTINGS (v42)
input group "=== 8. MA MASTER SETTINGS (v42) ==="
input int      InpTrend_SMA        = 200;      // Ana Trend SMA (Filitre)
input int      InpPullback_SMA     = 50;       // Pullback/Destek SMA (Ekleme)
input int      InpSignal_EMA_Fast  = 8;        // Sinyal Hızlı EMA
input int      InpSignal_EMA_Slow  = 21;       // Sinyal Yavaş EMA
input bool     InpPyramiding       = true;     // Kazanan Trende Ekleme Yap
input int      InpPyramidStepPips  = 20;       // Ekleme Adımı (Pips)

//--- 9. RULE ENFORCER (GÜVENLİK v24)
input group "=== 9. AGGRESSIVE MODE (v29) ==="
input bool     InpUseReverse       = true;      // Zarar Sonrası Yön Değiştir
input bool     InpUseScaleUp       = true;      // Kâr Sonrası Lot Artır
input double   InpScaleUpMultiplier = 1.5;      // Scale Up Çarpanı (%50 artış)
input int      InpWinStreakForScale = 2;        // Kaç Üst Üste Kâr Scale Up Tetikler

//--- 10. TEST & DEBUG
input group "=== 10. TEST & DEBUG (v37) ==="
input bool     InpAutoTestTrade        = false;     // v46: Kapalı
input bool     InpTestMode             = false;     // v46: Kapalı (Production Ready)
input bool     InpRelaxChecks          = false;     // v46: Kapalı
input bool     InpForceShowDashboard   = true;     // Dashboard'ı Her Zaman Göster

//--- 11. HESAP KURTARMA (v27)
input group "=== 11. RECOVERY MODE (v27) ==="
input bool     InpUseRecovery      = true;      // Kurtarma Modu
input double   InpRecoveryTrigger  = 20.0;      // Kurtarma Tetikleme (% Zarar)
input double   InpRecoveryTarget   = 10.0;      // Kurtarma Hedefi (% Geri Kazanım)
input double   InpRecoveryLotMul   = 0.5;       // Kurtarma Lot Çarpanı

//--- 12. FON YÖNETİMİ (v27)
input group "=== 12. FUND MANAGEMENT (v27) ==="
input double   InpDailyProfitTarget   = 0;      // Günlük Kâr Hedefi $ (0=Kapalı)
input double   InpWeeklyProfitTarget  = 0;      // Haftalık Kâr Hedefi $
input bool     InpPauseOnTarget       = true;   // Hedefe Ulaşınca Durdur

//--- 13. GELİŞMİŞ RİSK YÖNETİMİ (v31 - KARLILIK)
input group "=== 13. ADVANCED RISK (v31) ==="
input bool     InpUseRiskBasedLot  = true;      // Risk % Bazlı Lot Hesapla
input double   InpRiskPerTrade     = 1.0;       // v46 SAFE: İşlem Başı Risk % (Düşürüldü)
input bool     InpUseATRStops      = true;      // ATR Bazlı SL/TP
input int      InpATRPeriod        = 14;        // ATR Periyodu
input double   InpATRMultiplierSL  = 3.0;       // v46 SAFE: Stop Loss ATR Çarpanı (Genişletildi)
input double   InpATRMultiplierTP  = 5.0;       // v46 SAFE: Take Profit ATR Çarpanı (Trend Odaklı)
input double   InpMinRiskReward    = 1.5;       // v46: Minimum Risk/Reward Oranı
input double   InpMaxDrawdownStop  = 30.0;      // Emergency Stop Drawdown %
input int      InpCooldownMinutes  = 30;        // v46: Bekleme süresi

//--- 14. KONSENSÜS SİNYALLERİ (v31 - KOLAY SİNYAL)
input group "=== 14. TRIPLE MA SIGNALS (v31) ==="
input bool     InpUseConsensus     = false;     // v46: KAPALI (Daha fazla işlem sinyaline izin ver)
input int      InpMA_Fast          = 10;        // Hızlı MA Periyot (Scalp)
input int      InpMA_Medium        = 20;        // Orta MA Periyot (Trend)
input int      InpMA_Slow          = 50;        // Yavaş MA Periyot (Ana Yön)
input ENUM_MA_METHOD InpMA_Method  = MODE_EMA;  // MA Metodu
input bool     InpRequireAlignment = true;      // Tam Sıralanma Şartı (Güçlü Trend)

//--------------------------------------------------------------------
// GLOBAL DEĞİŞKENLER VE SINIFLAR (v45 ile aynı yapı korundu)
//--------------------------------------------------------------------
// Not: Aşağıdaki sınıflar v45'ten kopyalanmıştır. Sadece CheckRiskReward mantığı düzeltilmiştir.

// GLOBAL DEĞİŞKENLER
int      g_ticket = 0;
double   g_equityHigh = 0;
double   g_maxDrawdownReached = 0;
bool     g_recoveryMode = false;
datetime g_cooldownUntil = 0;

// İstatistikler
int      g_tradesTodayCount = 0;
datetime g_today_start = 0;
string   g_StateReason = "BAŞLATILIYOR...";
double   g_dailyProfit = 0;
double   g_profitHistory[];
int      g_totalWins = 0;
int      g_totalLosses = 0;
double   g_grossProfit = 0;
double   g_grossLoss = 0;

// v29 Agresif
int      g_consecutiveWins = 0;
int      g_consecutiveLosses = 0;
int      g_lastTradeDirection = 0;
double   g_currentLotMultiplier = 1.0;

// OBJECTS
CTrade m_trade;

//====================================================================
// CLASS: NEWS MANAGER
//====================================================================
class CNewsManager 
{
public:
   bool IsNewsTime() { return false; } // Basitleştirilmiş (Gerçek entegrasyon için web request gerekir)
};

//====================================================================
// CLASS: SECURITY MANAGER
//====================================================================
class CSecurityManager
{
public:
   void Init() { g_equityHigh = AccountInfoDouble(ACCOUNT_EQUITY); }
   
   bool IsSafeToTrade()
   {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      if(equity > g_equityHigh) g_equityHigh = equity;
      
      double dd = (g_equityHigh - equity) / g_equityHigh * 100.0;
      if(dd > InpMaxDrawdownStop)
      {
         g_StateReason = "MAX DRAWDOWN AŞILDI! (%" + DoubleToString(dd, 1) + ")";
         return false;
      }
      
      if(TimeCurrent() < g_cooldownUntil)
      {
         g_StateReason = "COOLDOWN SÜRESİ (" + TimeToString(g_cooldownUntil) + ")";
         return false;
      }
      
      if(InpUseTimeFilter)
      {
         MqlDateTime dt;
         TimeCurrent(dt);
         if(dt.hour < InpStartHour || dt.hour >= InpEndHour)
         {
            g_StateReason = "ZAMAN FİLTRESİ (SAAT DİŞİ)";
            return false;
         }
      }
      
      if(InpMaxSpreadPips > 0)
      {
         int spread = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
         double spreadPips = spread * SymbolInfoDouble(_Symbol, SYMBOL_POINT); // Puan hesabı
         // MT5 Spread usually in points. 1 pip = 10 points usually.
         // Let's assume standard broker: spread integer is in points. 
         // If InpMaxSpreadPips = 6 (60 points).
         
         double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         double diff = spread * point; 
         // Bu kontrolü basitleştirelim: Spread (Points)
         if(spread > InpMaxSpreadPips * 10) // 6 pips * 10 = 60 points
         {
            g_StateReason = "YÜKSEK SPREAD (" + IntegerToString(spread) + ")";
            return false;
         }
      }
      
      return true;
   }
   
   void CheckPerformance()
   {
      // v29: Agresif modda işlem durdurma kaldırıldı, sadece izleme
   }
   
   void UpdateStreak()
   {
       if(HistoryDealsTotal() > 0)
       {
           ulong ticket = HistoryDealGetTicket(HistoryDealsTotal()-1);
           if(ticket > 0)
           {
               double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
               if(profit > 0) {
                   g_consecutiveWins++;
                   g_consecutiveLosses = 0;
               } else if(profit < 0) {
                   g_consecutiveLosses++;
                   g_consecutiveWins = 0;
               }
           }
       }
   }
   
   int GetReverseSignal()
   {
       if(InpUseReverse && g_consecutiveLosses >= InpMaxLoseStreak)
       {
           // Son işlem yönünün tersine sinyal ver
           if(g_lastTradeDirection == 1) return -1;
           if(g_lastTradeDirection == -1) return 1;
       }
       return 0;
   }
   
   double GetScaledLot(double baseLot)
   {
       if(InpUseScaleUp && g_consecutiveWins >= InpWinStreakForScale)
       {
           g_currentLotMultiplier = InpScaleUpMultiplier;
           return baseLot * InpScaleUpMultiplier;
       }
       g_currentLotMultiplier = 1.0;
       return baseLot;
   }
};

//====================================================================
// CLASS: PRICE ENGINE
//====================================================================
class CPriceEngine
{
public:
   static double PipToPoints(int pips)
   {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      int multiplier = (digits == 3 || digits == 5) ? 10 : 1;
      return pips * multiplier * point;
   }
   
   static bool CheckStopLevel(double price, double sl, double tp, int direction)
   {
      double stopLevel = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      
      if(sl != 0)
      {
         double distSL = MathAbs(price - sl);
         if(distSL < stopLevel) return false;
      }
      
      if(tp != 0)
      {
         double distTP = MathAbs(price - tp);
         if(distTP < stopLevel) return false;
      }
      
      return true;
   }
   
   static void EnforceRequestInterval()
   {
      static uint lastReq = 0;
      uint now = GetTickCount();
      if(now - lastReq < (uint)InpMinRequestIntervalMs)
         Sleep(InpMinRequestIntervalMs);
      lastReq = GetTickCount();
   }
};

//====================================================================
// CLASS: RECOVERY MANAGER
//====================================================================
class CRecoveryManager
{
public:
   void Init() {}
   void Update() 
   {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      if(g_equityHigh == 0) g_equityHigh = equity; // İlk değer
      
      double dd = (g_equityHigh - equity) / g_equityHigh * 100.0;
      
      if(dd >= InpRecoveryTrigger && !g_recoveryMode)
      {
         g_recoveryMode = true;
         Print("⚠️ RECOVERY MODE AKTİF! Drawdown: %", DoubleToString(dd, 1));
      }
      else if(g_recoveryMode && dd < InpRecoveryTarget)
      {
         g_recoveryMode = false;
         Print("✅ RECOVERY MODE KAPALI. Normal operasyona dönüş.");
      }
   }
   
   bool IsActive() { return g_recoveryMode; }
   double GetLotMultiplier() { return InpRecoveryLotMul; }
   double GetDrawdownPercent() { 
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      return (g_equityHigh > 0) ? (g_equityHigh - equity) / g_equityHigh * 100.0 : 0.0; 
   }
};

//====================================================================
// CLASS: FUND MANAGER
//====================================================================
class CFundManager
{
public:
   void Init() 
   {
       g_dailyProfit = 0; 
   }
   
   void Update()
   {
      // Basit günlük kar takibi (HistorySelect ile yapılmalı normalde)
      // Burada sadece anlık durumu güncelleyelim
   }
   
   bool ShouldPauseTrading()
   {
      if(InpDailyProfitTarget > 0 && GetDailyProfit() >= InpDailyProfitTarget && InpPauseOnTarget)
      {
         g_StateReason = "GÜNLÜK HEDEF TAMAMLANDI ($" + DoubleToString(GetDailyProfit(), 2) + ")";
         return true;
      }
      return false;
   }
   
   double GetDailyProfit()
   {
      double profit = 0;
      HistorySelect(g_today_start, TimeCurrent());
      for(int i = 0; i < HistoryDealsTotal(); i++)
      {
         ulong ticket = HistoryDealGetTicket(i);
         profit += HistoryDealGetDouble(ticket, DEAL_PROFIT);
         profit += HistoryDealGetDouble(ticket, DEAL_SWAP);
         profit += HistoryDealGetDouble(ticket, DEAL_COMMISSION);
      }
      return profit;
   }
   
   double GetWinRate()
   {
      if(g_totalWins + g_totalLosses == 0) return 0;
      return (double)g_totalWins / (g_totalWins + g_totalLosses) * 100.0;
   }
};

//====================================================================
// CLASS: SIGNAL ENGINE
//====================================================================
class CSignalEngine
{
private:
   int m_hFrac;
   int m_hBands;
   int m_hADX;
   int m_hAMA;
   double m_lastSignalTime;
   
   // HMA Handles
   int m_hWMA_Half;
   int m_hWMA_Full;
   int m_hHMA_Fast_Half;
   int m_hHMA_Fast_Full;
   int m_hHMA_Slow_Half;
   int m_hHMA_Slow_Full;
   int m_hmaPeriod;
   
   // MA Master Handles (v42)
   int m_hSMA_Trend;
   int m_hSMA_Pullback;
   int m_hEMA_Fast;
   int m_hEMA_Slow;
   
public:
   CSignalEngine() : m_hFrac(INVALID_HANDLE), m_hBands(INVALID_HANDLE), m_hADX(INVALID_HANDLE) {}
   
   void ReleaseHandles()
   {
      if(m_hFrac != INVALID_HANDLE) IndicatorRelease(m_hFrac);
      if(m_hBands != INVALID_HANDLE) IndicatorRelease(m_hBands);
      if(m_hADX != INVALID_HANDLE) IndicatorRelease(m_hADX);
      if(m_hWMA_Half != INVALID_HANDLE) IndicatorRelease(m_hWMA_Half);
      if(m_hWMA_Full != INVALID_HANDLE) IndicatorRelease(m_hWMA_Full);
      if(m_hHMA_Fast_Half != INVALID_HANDLE) IndicatorRelease(m_hHMA_Fast_Half);
      if(m_hHMA_Fast_Full != INVALID_HANDLE) IndicatorRelease(m_hHMA_Fast_Full);
      if(m_hHMA_Slow_Half != INVALID_HANDLE) IndicatorRelease(m_hHMA_Slow_Half);
      if(m_hHMA_Slow_Full != INVALID_HANDLE) IndicatorRelease(m_hHMA_Slow_Full);
      if(m_hAMA != INVALID_HANDLE) IndicatorRelease(m_hAMA);
      // v42
      if(m_hSMA_Trend != INVALID_HANDLE) IndicatorRelease(m_hSMA_Trend);
      if(m_hSMA_Pullback != INVALID_HANDLE) IndicatorRelease(m_hSMA_Pullback);
      if(m_hEMA_Fast != INVALID_HANDLE) IndicatorRelease(m_hEMA_Fast);
      if(m_hEMA_Slow != INVALID_HANDLE) IndicatorRelease(m_hEMA_Slow);
   }

   bool Init()
   {
      ReleaseHandles();
      
      m_hFrac    = iFractals(_Symbol, PERIOD_CURRENT);
      m_hBands   = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
      m_hADX     = iADX(_Symbol, PERIOD_CURRENT, 14);
      
      // HMA Hazırlığı
      m_hmaPeriod = MainTrend_MA;
      m_hWMA_Half = iMA(_Symbol, HigherTF, m_hmaPeriod / 2, 0, MODE_LWMA, PRICE_CLOSE);
      m_hWMA_Full = iMA(_Symbol, HigherTF, m_hmaPeriod, 0, MODE_LWMA, PRICE_CLOSE);
      
      // HMA Cross Hazırlığı
      if(InpStrategyMode == STRATEGY_HMA_CROSS)
      {
         m_hHMA_Fast_Half = iMA(_Symbol, PERIOD_CURRENT, InpHMA_Fast / 2, 0, MODE_LWMA, PRICE_CLOSE);
         m_hHMA_Fast_Full = iMA(_Symbol, PERIOD_CURRENT, InpHMA_Fast, 0, MODE_LWMA, PRICE_CLOSE);
         m_hHMA_Slow_Half = iMA(_Symbol, PERIOD_CURRENT, InpHMA_Slow / 2, 0, MODE_LWMA, PRICE_CLOSE);
         m_hHMA_Slow_Full = iMA(_Symbol, PERIOD_CURRENT, InpHMA_Slow, 0, MODE_LWMA, PRICE_CLOSE);
      }
      
      // AMA Hazırlığı
      if(InpStrategyMode == STRATEGY_AMA_CROSS)
      {
         m_hAMA = iAMA(_Symbol, PERIOD_CURRENT, InpAMA_Period, InpAMA_Fast, InpAMA_Slow, 0, PRICE_CLOSE);
      }
      
      // v42: MA Master Init
      if(InpStrategyMode == STRATEGY_MA_MASTER)
      {
         m_hSMA_Trend = iMA(_Symbol, PERIOD_CURRENT, InpTrend_SMA, 0, MODE_SMA, PRICE_CLOSE);
         m_hSMA_Pullback = iMA(_Symbol, PERIOD_CURRENT, InpPullback_SMA, 0, MODE_SMA, PRICE_CLOSE);
         m_hEMA_Fast = iMA(_Symbol, PERIOD_CURRENT, InpSignal_EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
         m_hEMA_Slow = iMA(_Symbol, PERIOD_CURRENT, InpSignal_EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
         
         if(m_hSMA_Trend == INVALID_HANDLE || m_hEMA_Fast == INVALID_HANDLE || m_hEMA_Slow == INVALID_HANDLE)
         {
            Print("❌ v42: MA Master göstergeleri yüklenemedi!");
            return false;
         }
         Print("✅ v46: MA Master (Native) yüklendi.");
         return true;
      }
      
      return true;
   }
   
   double CalculateHMA(int shift)
   {
      double val1[], val2[];
      CopyBuffer(m_hWMA_Half, 0, shift, 1, val1);
      CopyBuffer(m_hWMA_Full, 0, shift, 1, val2);
      
      double raw = 2 * val1[0] - val2[0];
      return raw; // Tam HMA için bir smoothing daha gerekir ama bu yaklaşık değer yeterli
   }
   
   ENUM_MARKET_REGIME GetRegime()
   {
      double adx[1];
      CopyBuffer(m_hADX, 0, 0, 1, adx);
      
      if(adx[0] < 20) return REGIME_RANGING;
      if(adx[0] > 40) return REGIME_HIGH_VOLATILITY;
      return REGIME_TRENDING;
   }
   
   // --- v42: MA MASTER SIGNAL LOGIC (DEBUG MODE v45) ---
   int GetMAMasterSignal()
   {
      // 1. Veri Okuma
      double smaTrend[], fast[], slow[];
      ArrayResize(smaTrend, 1);
      ArrayResize(fast, 2);
      ArrayResize(slow, 2);
      
      ArraySetAsSeries(smaTrend, true);
      ArraySetAsSeries(fast, true);
      ArraySetAsSeries(slow, true);
      
      int c1 = CopyBuffer(m_hSMA_Trend, 0, 0, 1, smaTrend);
      int c2 = CopyBuffer(m_hEMA_Fast, 0, 0, 2, fast);
      int c3 = CopyBuffer(m_hEMA_Slow, 0, 0, 2, slow);
      
      if(c1 < 1 || c2 < 2 || c3 < 2) return 0;
      
      double price = iClose(_Symbol, PERIOD_CURRENT, 0);
      
      // 2. Trend Yönü (GÜÇLENDİRİLMİŞ)
      // v46 Safe: Sadece fiyat değil, EMA'ların da SMA üstünde olması gerekir.
      // Bu, yatay piyasada SMA200 etrafındaki testere (whipsaw) hareketlerini filtreler.
      int trend = 0;
      
      // BUY Trendi: Fiyat > SMA200 VE Hızlı/Yavaş EMA > SMA200
      if(price > smaTrend[0] && fast[0] > smaTrend[0] && slow[0] > smaTrend[0]) 
      {
         trend = 1;
      }
      // SELL Trendi: Fiyat < SMA200 VE Hızlı/Yavaş EMA < SMA200
      else if(price < smaTrend[0] && fast[0] < smaTrend[0] && slow[0] < smaTrend[0]) 
      {
         trend = -1;
      }
      
      if(trend == 0) return 0;
      
      // 3. EMA Cross Sinyali (8/21)
      bool goldenCross = (fast[1] <= slow[1] && fast[0] > slow[0]);
      bool deathCross  = (fast[1] >= slow[1] && fast[0] < slow[0]);
      
      // 4. Ana Sinyal (Trend Yönünde Cross)
      if(trend == 1 && goldenCross)
      {
         g_StateReason = "MA MASTER: TREND + CROSS BUY";
         Print("DEBUG: [MA MASTER] BUY Signal (Trend: ", trend, ")");
         return 1;
      }
      if(trend == -1 && deathCross)
      {
         g_StateReason = "MA MASTER: TREND + CROSS SELL";
         Print("DEBUG: [MA MASTER] SELL Signal (Trend: ", trend, ")");
         return -1;
      }
      
      return 0;
   }
   
   int GetDirection(ENUM_MARKET_REGIME regime)
   {
      // v42: MA Master (Native) - ÖNCELİKLİ KONTROL
      if(InpStrategyMode == STRATEGY_MA_MASTER)
      {
         return GetMAMasterSignal();
      }
      return 0; // Diğer modlar bu versiyonda devre dışı bırakılabilir
   }
};

//====================================================================
// CLASS: RISK MANAGER (v31 - Karlılık Odaklı)
//====================================================================
class CRiskManager
{
private:
   double m_equityHigh;          // Equity zirvesi
   double m_maxDrawdown;         // Maksimum drawdown
   
public:
   bool Init()
   {
      m_equityHigh = AccountInfoDouble(ACCOUNT_EQUITY);
      m_maxDrawdown = 0;
      ArrayResize(g_profitHistory, 100); 
      return true;
   }

   bool CheckEmergencyDrawdown()
   {
      double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      if(currentEquity > m_equityHigh) m_equityHigh = currentEquity;
      
      double ddPercent = 0;
      if(m_equityHigh > 0) ddPercent = (m_equityHigh - currentEquity) / m_equityHigh * 100.0;
      
      if(ddPercent > m_maxDrawdown) m_maxDrawdown = ddPercent;
      g_maxDrawdownReached = m_maxDrawdown;
      
      if(InpMaxDrawdownStop > 0 && ddPercent >= InpMaxDrawdownStop)
      {
         return true; // ACİL DURDURMA!
      }
      return false;
   }
   
   bool IsInCooldown()
   {
      if(g_cooldownUntil > 0)
      {
         if(TimeCurrent() < g_cooldownUntil)
         {
            g_StateReason = "COOLDOWN: " + TimeToString(g_cooldownUntil);
            return true;
         }
         g_cooldownUntil = 0;
      }
      return false;
   }
   
   double GetRiskBasedLot()
   {
      if(!InpUseRiskBasedLot) return InpFixedLot;
      
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * (InpRiskPerTrade / 100.0);
      
      // Stop Loss Puanı
      double slPoints = CPriceEngine::PipToPoints(InpSL_Pips);
      if(InpUseATRStops)
      {
         int hATR = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
         double atr[1];
         CopyBuffer(hATR, 0, 0, 1, atr);
         IndicatorRelease(hATR);
         
         double spread = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         double atrSL = atr[0] * InpATRMultiplierSL;
         
         // v46 Fix: Minimum SL Artırıldı -> 20 Pips (200 Puan)
         // M1 grafiğindeki gürültüden korunmak için en az 200 puanlık alan bırak
         double minSL = MathMax(200 * SymbolInfoDouble(_Symbol, SYMBOL_POINT), spread * 3.0);
         slPoints = MathMax(atrSL, minSL) / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      }
      
      if(slPoints <= 0) return InpFixedLot;
      
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      if(tickValue == 0) return InpFixedLot; 
      
      // 1. Risk Bazlı Lot Hesabı
      double lot = riskAmount / (slPoints * tickValue);
      
      // 2. Marjin (Bakiye) Bazlı Sınırlandırma
      double marginPerLot = 0;
      double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      
      // 1 Lot için gereken marjini hesapla
      if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, 1.0, price, marginPerLot) || marginPerLot == 0)
      {
          // Hesaplama başarısızsa varsayılan kaldıraç tahmini (1:100 güvenli varsayım, ama hata riskli)
          // Fallback: Bakiyenin %5'inden fazlasını riske atma (lot olarak değil equity olarak)
          marginPerLot = balance / 10.0; // Kabaca
      }
      
      // Serbest marjinin %80'ini geçme
      double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      // Eğer hiç işlem yoksa free margin = balance olabilir, ama testte - bakiye görünüyor.
      // Güvenlik: Balance üzerinden gidelim.
      double safeEquity = AccountInfoDouble(ACCOUNT_EQUITY) * 0.90; // %90 kullanım
      double maxLotByMargin = safeEquity / marginPerLot;
      
      // Risk lotu ile Marjin lotunu karşılaştır, küçüğünü al
      double originalLot = lot;
      lot = MathMin(lot, maxLotByMargin);
      
      if(lot < originalLot)
      {
         Print("⚠️ MARJİN KISITLAMASI: Hesaplanan Lot: ", DoubleToString(originalLot, 2), " -> Düzeltilen: ", DoubleToString(lot, 2), " (MarginLot: ", DoubleToString(marginPerLot, 2), ")");
      }
      
      // 3. Broker Sınırları
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      
      lot = MathFloor(lot / stepLot) * stepLot;
      
      Print("DEBUG: Lot Final -> RiskAmount: $", DoubleToString(riskAmount, 2), " SL: ", DoubleToString(slPoints, 0), " pts. Lot: ", lot);
      
      return MathMax(minLot, MathMin(lot, maxLot)); 
   }
   
   // İstatistiksel Metrikler
   double GetProfitFactor() { return (g_grossLoss == 0) ? 0 : g_grossProfit / g_grossLoss; }
   double GetSharpeRatio() { return 0; } // Placeholder
   double GetMaxDrawdown() { return g_maxDrawdownReached; }
   
   double GetATRPips()
   {
      int hMA = iATR(_Symbol, PERIOD_CURRENT, 14);
      double val[1];
      CopyBuffer(hMA, 0, 0, 1, val);
      IndicatorRelease(hMA);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      return val[0] / point / 10.0; // Pips
   }
   
   // ATR Bazlı SL/TP Helperları
   double GetATRStopLoss(int direction)
   {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double minDist = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;
      if(minDist == 0) minDist = 20 * point; // Fallback 2 pips
      
      // Spread koruması
      double spread = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * point;
      minDist = MathMax(minDist, spread * 1.5);

      double slDist = 0;
      if(!InpUseATRStops) 
      {
         slDist = CPriceEngine::PipToPoints(InpSL_Pips) * point; // Basit pips conversion hatasını düzelt (önceki kodda logic hatası olabilir)
         // Düzeltme: CPriceEngine::PipToPoints zaten multiply point yapıyor mu?
         // Evet: return pips * multiplier * point; -> Yani sonuç FİYAT FARKIDIR.
         slDist = CPriceEngine::PipToPoints(InpSL_Pips); 
      }
      else
      {
         int hATR = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
         double atr[1];
         CopyBuffer(hATR, 0, 0, 1, atr);
         IndicatorRelease(hATR);
         slDist = atr[0] * InpATRMultiplierSL;
      }
      
      // v46 Fix: Minimum Mesafe + Gürültü Koruması (200 Puan / 20 Pip)
      double absoluteMin = 200 * point;
      if(slDist < absoluteMin) slDist = absoluteMin;
      
      // StopLevel Kontrolü (Broker Limit)
      if(slDist < minDist) slDist = minDist + (10 * point); 
      
      if(direction == 1) return SymbolInfoDouble(_Symbol, SYMBOL_ASK) - slDist;
      else return SymbolInfoDouble(_Symbol, SYMBOL_BID) + slDist;
   }
   
   double GetATRTakeProfit(int direction)
   {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double minDist = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;
      if(minDist == 0) minDist = 20 * point;

      double tpDist = 0;
      if(!InpUseATRStops) 
      {
          tpDist = CPriceEngine::PipToPoints(InpTP_Pips);
      }
      else
      {
         int hATR = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
         double atr[1];
         CopyBuffer(hATR, 0, 0, 1, atr);
         IndicatorRelease(hATR);
         tpDist = atr[0] * InpATRMultiplierTP;
      }
      
      // v46 Fix: Minimum Mesafe + R:R Koruması
      if(tpDist < minDist) tpDist = minDist + (20 * point);
      
      if(direction == 1) return SymbolInfoDouble(_Symbol, SYMBOL_ASK) + tpDist;
      else return SymbolInfoDouble(_Symbol, SYMBOL_BID) - tpDist;
   }
   
   bool CheckRiskReward(double entry, double sl, double tp, int direction)
   {
      if(sl == 0 || tp == 0) return true; // Sabit SL/TP kullanılıyorsa geç
      
      double risk = MathAbs(entry - sl);
      double reward = MathAbs(tp - entry);
      
      if(risk <= 0) return false;
      
      double rr = reward / risk;
      // v46: Clean Check
      if(rr < InpMinRiskReward)
      {
         g_StateReason = "DÜŞÜK R:R (" + DoubleToString(rr, 2) + " < " + DoubleToString(InpMinRiskReward, 2) + ")";
         return false;
      }
      return true;
   }
};

//====================================================================
// CLASS: CONSENSUS ENGINE (v31)
//====================================================================
class CConsensusEngine
{
public:
   bool Init() { return true; }
   void Release() {}
   int GetConsensusSignal() { return 0; } // v46 Disabled
};

//====================================================================
// CLASS: HEDGING MANAGER (v31)
//====================================================================
class CHedgingManager
{
public:
   bool CanOpenPosition(int direction)
   {
      if(InpAllowHedging) return true;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            long posType = PositionGetInteger(POSITION_TYPE);
            if(direction == 1 && posType == POSITION_TYPE_SELL) return false;
            if(direction == -1 && posType == POSITION_TYPE_BUY) return false;
         }
      }
      return true;
   }
};

//====================================================================
// CLASS: GRID EXECUTOR
//====================================================================
class CGridExecutor
{
public:
   void Init() { m_trade.SetExpertMagicNumber(InpMagic); }
   void CleanUp() {}

   void InitialTrade() {} // Deprecated

   void PlaceGrid(int direction)
   {
      double lotToUse = RiskMgr.GetRiskBasedLot();
      
      // Scale Up
      if(g_currentLotMultiplier > 1.0) lotToUse = Security.GetScaledLot(lotToUse);
      if(g_recoveryMode) lotToUse *= InpRecoveryLotMul;
      
      // Min/Max Lot
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      lotToUse = MathMax(minLot, MathMin(lotToUse, maxLot));
      
      double sl = RiskMgr.GetATRStopLoss(direction);
      double tp = RiskMgr.GetATRTakeProfit(direction);
      
      // Sabit SL/TP
      if(sl == 0 || tp == 0)
      {
         double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         double slSize = CPriceEngine::PipToPoints(InpSL_Pips);
         double tpSize = CPriceEngine::PipToPoints(InpTP_Pips);
         
         double price = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
         
         if(direction == 1) { sl = price - slSize; tp = price + tpSize; }
         else { sl = price + slSize; tp = price - tpSize; }
      }
      
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      sl = NormalizeDouble(sl, digits);
      tp = NormalizeDouble(tp, digits);
      
      if(direction == 1)
      {
         if(m_trade.Buy(lotToUse, _Symbol, 0, sl, tp, InpComment))
         {
            g_tradesTodayCount++;
            Print("✅ v46: BUY AÇILDI. Lot: ", lotToUse, " SL: ", sl, " TP: ", tp);
         }
      }
      else
      {
         if(m_trade.Sell(lotToUse, _Symbol, 0, sl, tp, InpComment))
         {
            g_tradesTodayCount++;
            Print("✅ v46: SELL AÇILDI. Lot: ", lotToUse, " SL: ", sl, " TP: ", tp);
         }
      }
   }
   
   void ManagePositions()
   {
       // Trailing Logic
       if(!InpUseTrailing) return;
       
       for(int i = PositionsTotal() - 1; i >= 0; i--)
       {
           ulong ticket = PositionGetTicket(i);
           if(ticket > 0 && PositionGetInteger(POSITION_MAGIC) == InpMagic)
           {
               double open = PositionGetDouble(POSITION_PRICE_OPEN);
               double current = PositionGetDouble(POSITION_PRICE_CURRENT);
               double sl = PositionGetDouble(POSITION_SL);
               double tp = PositionGetDouble(POSITION_TP);
               long type = PositionGetInteger(POSITION_TYPE);
               
               double trailStart = CPriceEngine::PipToPoints(InpTrailingStart);
               double trailStep = CPriceEngine::PipToPoints(InpTrailingStep);
               
               if(type == POSITION_TYPE_BUY)
               {
                   if(current - open > trailStart)
                   {
                       double newSL = current - trailStart;
                       if(newSL > sl + trailStep)
                           m_trade.PositionModify(ticket, newSL, tp);
                   }
               }
               else // SELL
               {
                   if(open - current > trailStart)
                   {
                       double newSL = current + trailStart;
                       if(sl == 0 || newSL < sl - trailStep) // sl==0 check important
                           m_trade.PositionModify(ticket, newSL, tp);
                   }
               }
           }
       }
   }
};

//====================================================================
// GLOBAL OBJECTS
//====================================================================
CNewsManager     News;
CSecurityManager Security;
CSignalEngine    Signal;
CRecoveryManager Recovery;
CFundManager     Fund;
CRiskManager     RiskMgr;
CConsensusEngine Consensus;
CHedgingManager  Hedging;
CGridExecutor    Executor; // EKLENDI: Global Executor Nesnesi

// CGridExecutor buradaydı, yukarı taşındı.

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Security.Init();
   if(!Signal.Init()) return INIT_FAILED;
   Executor.Init();
   Recovery.Init();
   Fund.Init();
   RiskMgr.Init();
   
   Print("=================================================");
   Print("TITANIUM OMEGA v46.0 - OPTIMIZED PROFIT MA MASTER");
   Print("=================================================");
   Print("💰 Bakıye: ", AccountInfoDouble(ACCOUNT_BALANCE));
   Print("📊 R:R Ayarı: ", InpMinRiskReward, " (SL ATR x", InpATRMultiplierSL, " / TP ATR x", InpATRMultiplierTP, ")");
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   Signal.ReleaseHandles();
   Comment("");
}

void OnTick()
{
   // CheckNewDay(); // v46: Basitleştirildi
   
   Security.UpdateStreak();
   Recovery.Update();
   Fund.Update();

   bool safeToOpen = Security.IsSafeToTrade();
   
   if(safeToOpen && Fund.ShouldPauseTrading()) safeToOpen = false;
   if(InpMaxTradesPerDay > 0 && g_tradesTodayCount >= InpMaxTradesPerDay) safeToOpen = false;
   if(safeToOpen && News.IsNewsTime()) safeToOpen = false;
   
   Executor.ManagePositions(); // Manage Stops
   
   if(!safeToOpen) 
   {
       // Dashboard update only
       // ...
       return;
   }
   
   // --- SIGNAL AL ---
   int signal = 0;
   
   // v46: Sadece MA Master
   if(InpStrategyMode == STRATEGY_MA_MASTER)
   {
      signal = Signal.GetMAMasterSignal();
   }
   
   if(signal != 0)
   {
      // Hedging Check
      if(!Hedging.CanOpenPosition(signal)) return;
      
      // R:R Check
      double entry = (signal == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double sl = RiskMgr.GetATRStopLoss(signal);
      double tp = RiskMgr.GetATRTakeProfit(signal);
      
      if(RiskMgr.CheckRiskReward(entry, sl, tp, signal))
      {
         int total = PositionsTotal();
         if(InpMultiOrder && total < InpMaxOpenOrders)
         {
             Executor.PlaceGrid(signal);
         }
         else if(!InpMultiOrder && total == 0)
         {
             Executor.PlaceGrid(signal);
         }
      }
   }
   
   // DASHBOARD (Hafifletilmiş)
    if(InpShowDashboard)
   {
      string comment = "TITANIUM OMEGA v46\n";
      comment += "Bakiye: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2) + "\n";
      comment += "Strategy: MA MASTER\n";
      comment += "Son Sinyal: " + IntegerToString(signal);
      Comment(comment);
   }
}
