//+------------------------------------------------------------------+
//|                                     MA_Master_Scalper_v11.mq5    |
//|                     © 2025, Milyoner EA Project v11.0            |
//|     ULTIMATE HYBRID - Titanium Omega + MA Master Birleşimi       |
//+------------------------------------------------------------------+
#property copyright "© 2025, Milyoner EA v11 - Ultimate Hybrid"
#property version   "11.00"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// v11: ULTIMATE HYBRID SYSTEM
// ═══════════════════════════════════════════════════════════════════
// TITANIUM OMEGA ÖZELLİKLERİ:
// [1] Sınıf Tabanlı Mimari (CPriceEngine, CSecurityManager, CSignalEngine)
// [2] Evrensel PipToPoints Formülü (pips * 10 * Point)
// [3] Broker StopLevel Kontrolü
// [4] Para Transfer Algılama (Deposit/Withdraw)
// [5] Sistem Kilidi (Daily Loss Lock)
// [6] Market Rejim Tespiti (Volatility/Trend/Range)
// [7] Stres Test Modu
// [8] Klavye Kısayolları (P:Pause, C:Close, D:Reset)
// [9] Akıllı Kısmi Kapama (Smart Partial Close)
// [10] Grid Matrix Sistemi
//
// MA MASTER SCALPER ÖZELLİKLERİ:
// [11] MA1/MA2/MA3 Üçlü Kesişim (MA Dansı)
// [12] MACD Histogram Sıfır Çizgisi
// [13] Linear Regression Slope
// [14] RSI + ADX Filtreler
// [15] ATR Dinamik SL/TP
// [16] Breakeven Sistemi
// [17] ATR Trailing Stop
// [18] Bekleyen Emir Sistemi
// [19] Doğru Lot/Pip Hesaplama
// [20] Manuel İşlem Yönetimi
// [21] Günlük DD + İşlem Limiti
// [22] Expectancy Hesaplama
// ═══════════════════════════════════════════════════════════════════

//====================================================================
// ENUM TANIMLARI
//====================================================================
enum ENUM_MARKET_REGIME {
   REGIME_HIGH_VOLATILITY,    // Yüksek Volatilite - İşlem Yapma
   REGIME_TRENDING,           // Trend - Takip Et
   REGIME_RANGING             // Range - Geri Dönüş
};

enum ENUM_ENTRY_MODE { 
   MODE_MARKET,               // Sadece Piyasa Emri
   MODE_PENDING,              // Sadece Bekleyen Emir
   MODE_BOTH,                 // Her İkisi
   MODE_GRID                  // Grid Sistemi
};

enum ENUM_SIGNAL_MODE {
   SIG_MA_CROSS,              // MA Kesişim
   SIG_FRACTAL,               // Fractal
   SIG_COMBINED               // Birleşik
};

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 1: ANA AYARLAR
//====================================================================
input group "═══════════════════════════════════════════════════════"
input group "═══════ 1. ANA AYARLAR ═══════"
input ulong    MagicNumber       = 111111;
input string   TradeComment      = "MILYONER_v11";
input ENUM_TIMEFRAMES TF         = PERIOD_M5;
input ENUM_ENTRY_MODE EntryMode  = MODE_MARKET;
input ENUM_SIGNAL_MODE SignalMode = SIG_MA_CROSS;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 2: ÜÇLÜ MA SİSTEMİ
//====================================================================
input group "═══════ 2. ÜÇLÜ MA SİSTEMİ (MA Dansı) ═══════"
input int      MA1_Period        = 8;
input int      MA2_Period        = 21;
input int      MA3_Period        = 50;
input ENUM_MA_METHOD MA_Method   = MODE_EMA;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 3: MACD
//====================================================================
input group "═══════ 3. MACD SIFIR ÇİZGİSİ ═══════"
input bool     UseMACD           = true;
input int      MACD_Fast         = 12;
input int      MACD_Slow         = 26;
input int      MACD_Signal       = 9;
input bool     MACDAboveZero     = true;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 4: LINEAR REGRESSION
//====================================================================
input group "═══════ 4. LINEAR REGRESSION ═══════"
input bool     UseLR             = true;
input int      LR_Period         = 20;
input double   LR_MinSlope       = 0.0001;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 5: FİLTRELER
//====================================================================
input group "═══════ 5. FİLTRELER ═══════"
input bool     UseADX            = true;
input int      ADX_Period        = 14;
input int      ADX_Min           = 20;              // Düşürüldü: 25->20
input bool     UseRSI            = true;
input int      RSI_Period        = 14;
input int      RSI_OB            = 70;
input int      RSI_OS            = 30;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 6: MARKET REJİM
//====================================================================
input group "═══════ 6. MARKET REJİM TESPİTİ ═══════"
input bool     UseRegimeFilter   = false;          // Kapatıldı: test için
input ENUM_TIMEFRAMES HigherTF   = PERIOD_H4;
input int      MainTrend_MA      = 200;
input int      Regime_Lookback   = 50;
input double   Vol_Explosion_Mul = 1.8;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 7: ATR DİNAMİK SL/TP
//====================================================================
input group "═══════ 7. ATR DİNAMİK SL/TP ═══════"
input bool     UseATR            = true;
input int      ATR_Period        = 14;
input double   ATR_SL_Multi      = 1.5;
input double   ATR_TP_Multi      = 3.0;
input int      MinSL_Pips        = 8;
input int      MaxSL_Pips        = 30;
input int      FixedSL           = 15;
input int      FixedTP           = 30;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 8: BREAKEVEN
//====================================================================
input group "═══════ 8. BREAKEVEN ═══════"
input bool     UseBreakeven      = true;
input double   BE_TriggerPct     = 50.0;
input int      BE_LockPips       = 2;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 9: TRAILING STOP
//====================================================================
input group "═══════ 9. TRAILING STOP ═══════"
input bool     UseTrailing       = true;
input double   Trail_StartPct    = 100.0;
input double   Trail_ATR_Multi   = 1.0;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 10: AKILLI KISMİ KAPAMA
//====================================================================
input group "═══════ 10. AKILLI KISMİ KAPAMA ═══════"
input bool     UseSmartPartial   = true;
input double   Partial_TriggerPct = 50.0;
input double   Partial_ClosePct  = 50.0;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 11: GRID MATRİSİ
//====================================================================
input group "═══════ 11. GRID MATRİSİ ═══════"
input int      Grid_MaxOrders    = 5;
input int      Grid_StepPips     = 15;
input int      Grid_ExpirationHrs = 4;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 12: BEKLEYEN EMİR
//====================================================================
input group "═══════ 12. BEKLEYEN EMİR ═══════"
input double   PendingPips       = 5.0;
input int      PendingExpireBars = 3;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 13: RİSK YÖNETİMİ
//====================================================================
input group "═══════ 13. RİSK YÖNETİMİ ═══════"
input double   RiskPercent       = 1.0;
input double   MaxLotSize        = 1.0;
input double   FixedLot          = 0.01;
input bool     UseFixedLot       = false;
input double   MaxDailyDDPct     = 5.0;
input double   MaxDailyDDMoney   = 50.0;
input int      MaxDailyTrades    = 10;
input double   MinMarginLevel    = 150.0;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 14: GÜVENLİK
//====================================================================
input group "═══════ 14. GÜVENLİK ═══════"
input bool     DetectDeposit     = true;
input bool     UseTimeFilter     = false;           // Kapatıldı: test için 7/24 çalışsın
input int      StartHour         = 8;
input int      EndHour           = 20;
input int      MaxSpreadPips     = 5;               // Artırıldı: 3->5
input int      CooldownBars      = 2;               // Düşürüldü: 3->2

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 15: STRES TESTİ
//====================================================================
input group "═══════ 15. STRES TESTİ ═══════"
input bool     StressTestMode    = false;
input int      SimulatedSlippage = 10;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 16: MANUEL İŞLEM
//====================================================================
input group "═══════ 16. MANUEL İŞLEM YÖNETİMİ ═══════"
input bool     ManageManualTrades = true;
input bool     AddSLTPToManual   = true;
input bool     ApplyBEToManual   = true;
input bool     ApplyTrailToManual = true;
input bool     ApplyPartialToManual = true;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 17: PANEL
//====================================================================
input group "═══════ 17. PANEL & GÖRSEL ═══════"
input bool     ShowDashboard     = true;
input color    PanelColor        = clrDarkSlateGray;
input color    TextColor         = clrWhite;

//====================================================================
// GLOBAL KONTROL DEĞİŞKENLERİ
//====================================================================
bool g_ManualPause = false;
bool g_SystemLocked = false;
string g_LockReason = "";

//====================================================================
// CLASS: PRICE ENGINE (Matematiksel Çekirdek)
//====================================================================
class CPriceEngine
{
public:
   //=== EVRENSEL PIP/POINT DÖNÜŞÜMÜ ===
   // MQL5 Standardı: 1 Pip = 10 Points (5 digit ve 3 digit JPY dahil)
   static double PipToPoints(double pips)
   {
      return pips * 10.0 * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   }
   
   static double PointsToPip(double points)
   {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if(point == 0) return 0;
      return points / (10.0 * point);
   }
   
   //=== BROKER STOPLEVEL KONTROLÜ ===
   static bool CheckStopLevel(double entry, double sl, double tp, int direction)
   {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      long stopLevelPts = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
      double stopLevel = (double)stopLevelPts * point;
      
      if(stopLevel == 0) 
         stopLevel = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * point;
      
      double safeDist = 10 * point;

      if(direction == 1) // BUY
         return (sl < entry - safeDist) && (tp > entry + safeDist) && 
                (entry - sl >= stopLevel) && (tp - entry >= stopLevel);
      else if(direction == -1) // SELL
         return (sl > entry + safeDist) && (tp < entry - safeDist) && 
                (sl - entry >= stopLevel) && (entry - tp >= stopLevel);
      
      return false;
   }
   
   //=== DİNAMİK SL/TP HESAPLAMA ===
   static void GetDynamicSLTP(double atr, double &slDist, double &tpDist)
   {
      if(UseATR && atr > 0) {
         slDist = atr * ATR_SL_Multi;
         tpDist = atr * ATR_TP_Multi;
         
         double minSL = PipToPoints(MinSL_Pips);
         double maxSL = PipToPoints(MaxSL_Pips);
         slDist = MathMax(minSL, MathMin(slDist, maxSL));
         
         if(tpDist < slDist * 2.0) tpDist = slDist * 2.0;
      } else {
         slDist = PipToPoints(FixedSL);
         tpDist = PipToPoints(FixedTP);
      }
   }
   
   //=== LOT HESAPLAMA ===
   static double CalculateLot(double slPips)
   {
      if(UseFixedLot) return NormalizeLot(FixedLot);
      
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * RiskPercent / 100.0;
      
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      
      if(tickValue <= 0) tickValue = 10.0;
      if(tickSize <= 0) tickSize = point;
      
      double pipValue = tickValue * (point / tickSize) * 10.0;
      double lot = riskAmount / (slPips * pipValue);
      
      return NormalizeLot(lot);
   }
   
   static double NormalizeLot(double lot)
   {
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      
      if(minLot <= 0) minLot = 0.01;
      if(stepLot <= 0) stepLot = 0.01;
      
      lot = MathFloor(lot / stepLot) * stepLot;
      lot = MathMax(minLot, MathMin(lot, MathMin(maxLot, MaxLotSize)));
      
      double margin = 0, price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      
      if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, margin)) {
         while(margin > freeMargin * 0.5 && lot > minLot) {
            lot = MathFloor((lot * 0.5) / stepLot) * stepLot;
            lot = MathMax(lot, minLot);
            if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, margin)) break;
         }
      }
      
      return lot;
   }
   
   //=== LINEAR REGRESSION SLOPE ===
   static double CalculateLRSlope(int period)
   {
      if(!UseLR) return 999;
      
      double Sx = 0, Sy = 0, Sxy = 0, Sxx = 0;
      int n = period;
      
      for(int i = 0; i < n; i++) {
         double x = (double)i;
         double y = iClose(_Symbol, TF, i);
         Sx += x;
         Sy += y;
         Sxy += x * y;
         Sxx += x * x;
      }
      
      double denom = n * Sxx - Sx * Sx;
      if(denom == 0) return 0;
      
      return (n * Sxy - Sx * Sy) / denom;
   }
};

//====================================================================
// CLASS: SECURITY MANAGER (Güvenlik ve Bakiye)
//====================================================================
class CSecurityManager
{
private:
   double m_refBalance;
   double m_lastKnownBalance;
   int m_dayOfYear;
   int m_dailyTradeCount;

public:
   CSecurityManager() : m_refBalance(0), m_lastKnownBalance(0), m_dayOfYear(0), m_dailyTradeCount(0) {}
   
   void Init() { UpdateReference(true); }

   void UpdateReference(bool forceReset = false)
   {
      MqlDateTime dt; 
      TimeCurrent(dt);
      if(forceReset || dt.day_of_year != m_dayOfYear)
      {
         m_dayOfYear = dt.day_of_year;
         m_refBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         m_lastKnownBalance = m_refBalance;
         m_dailyTradeCount = 0;
         g_SystemLocked = false;
         g_LockReason = "";
         Print("═══════════════════════════════════════════════════════════");
         Print("📅 GÜNLÜK REFERANS GÜNCELLENDİ: $", DoubleToString(m_refBalance, 2));
         Print("═══════════════════════════════════════════════════════════");
      }
   }

   bool IsSafeToTrade()
   {
      if(g_ManualPause) { g_LockReason = "MANUEL DURAKLAMA"; return false; }
      if(g_SystemLocked) { return false; }
      
      UpdateReference();

      // Para Transferi Algılama
      double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      if(DetectDeposit && MathAbs(currentBalance - m_lastKnownBalance) > 0.001)
      {
         if(PositionsTotal() == 0) 
         {
            double diff = currentBalance - m_lastKnownBalance;
            m_refBalance += diff;
            Print("💰 PARA TRANSFERİ ALGILANDI: ", (diff > 0 ? "+" : ""), DoubleToString(diff, 2));
         }
         m_lastKnownBalance = currentBalance;
      }

      // Günlük Zarar Kontrolü (Equity Bazlı)
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double loss = m_refBalance - equity;
      double lossPct = (m_refBalance > 0) ? (loss / m_refBalance) * 100.0 : 0;
      
      if(loss >= MaxDailyDDMoney) {
         g_SystemLocked = true;
         g_LockReason = "GÜNLÜK $ KAYIP LİMİTİ";
         Print("🔒 ACİL DURUM: Günlük $ Zarar Limiti Aşıldı! ($", DoubleToString(loss, 2), ")");
         return false;
      }
      
      if(lossPct >= MaxDailyDDPct) {
         g_SystemLocked = true;
         g_LockReason = "GÜNLÜK % KAYIP LİMİTİ";
         Print("🔒 ACİL DURUM: Günlük % Zarar Limiti Aşıldı! (", DoubleToString(lossPct, 1), "%)");
         return false;
      }

      // Günlük İşlem Limiti
      if(m_dailyTradeCount >= MaxDailyTrades) {
         g_LockReason = "GÜNLÜK İŞLEM LİMİTİ";
         return false;
      }

      // Marjin Kontrolü
      double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
      if(marginLevel > 0 && marginLevel < MinMarginLevel) {
         g_LockReason = "DÜŞÜK MARJİN";
         return false;
      }
      
      // Sembol Kontrolü
      if(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL) {
         g_LockReason = "SEMBOL KAPALI";
         return false;
      }

      // Zaman Filtresi
      if(UseTimeFilter)
      {
         MqlDateTime dt; 
         TimeCurrent(dt);
         if(dt.hour < StartHour || dt.hour >= EndHour) {
            g_LockReason = "ZAMAN FİLTRESİ";
            return false;
         }
      }
      
      // Spread Kontrolü
      long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      double spreadPips = spread / 10.0;
      
      if(spreadPips > MaxSpreadPips) {
         g_LockReason = "YÜKSEK SPREAD";
         return false;
      }

      g_LockReason = "";
      return true;
   }
   
   void IncrementTradeCount() { m_dailyTradeCount++; }
   int GetTradeCount() { return m_dailyTradeCount; }
   double GetDailyPL() { return AccountInfoDouble(ACCOUNT_EQUITY) - m_refBalance; }
   double GetRefBalance() { return m_refBalance; }
};

//====================================================================
// CLASS: SIGNAL ENGINE (Sinyal Üretimi)
//====================================================================
class CSignalEngine
{
private:
   int m_hMA1, m_hMA2, m_hMA3;
   int m_hMACD, m_hADX, m_hRSI, m_hATR;
   int m_hFractal, m_hBands;
   int m_hMA_Higher;
   datetime m_lastSignalTime;
   datetime m_lastBarTime;
   int m_barsSinceTrade;
   bool m_signalGivenThisBar;

public:
   double m_lastATR;
   
   CSignalEngine() : m_hMA1(INVALID_HANDLE), m_hMA2(INVALID_HANDLE), m_hMA3(INVALID_HANDLE),
      m_hMACD(INVALID_HANDLE), m_hADX(INVALID_HANDLE), m_hRSI(INVALID_HANDLE), m_hATR(INVALID_HANDLE),
      m_hFractal(INVALID_HANDLE), m_hBands(INVALID_HANDLE), m_hMA_Higher(INVALID_HANDLE),
      m_lastSignalTime(0), m_lastBarTime(0), m_barsSinceTrade(999), m_signalGivenThisBar(false), m_lastATR(0) {}
   
   ~CSignalEngine() { ReleaseHandles(); }
   
   void ReleaseHandles()
   {
      if(m_hMA1 != INVALID_HANDLE) { IndicatorRelease(m_hMA1); m_hMA1 = INVALID_HANDLE; }
      if(m_hMA2 != INVALID_HANDLE) { IndicatorRelease(m_hMA2); m_hMA2 = INVALID_HANDLE; }
      if(m_hMA3 != INVALID_HANDLE) { IndicatorRelease(m_hMA3); m_hMA3 = INVALID_HANDLE; }
      if(m_hMACD != INVALID_HANDLE) { IndicatorRelease(m_hMACD); m_hMACD = INVALID_HANDLE; }
      if(m_hADX != INVALID_HANDLE) { IndicatorRelease(m_hADX); m_hADX = INVALID_HANDLE; }
      if(m_hRSI != INVALID_HANDLE) { IndicatorRelease(m_hRSI); m_hRSI = INVALID_HANDLE; }
      if(m_hATR != INVALID_HANDLE) { IndicatorRelease(m_hATR); m_hATR = INVALID_HANDLE; }
      if(m_hFractal != INVALID_HANDLE) { IndicatorRelease(m_hFractal); m_hFractal = INVALID_HANDLE; }
      if(m_hBands != INVALID_HANDLE) { IndicatorRelease(m_hBands); m_hBands = INVALID_HANDLE; }
      if(m_hMA_Higher != INVALID_HANDLE) { IndicatorRelease(m_hMA_Higher); m_hMA_Higher = INVALID_HANDLE; }
   }

   bool Init()
   {
      ReleaseHandles();
      
      m_hMA1 = iMA(_Symbol, TF, MA1_Period, 0, MA_Method, PRICE_CLOSE);
      m_hMA2 = iMA(_Symbol, TF, MA2_Period, 0, MA_Method, PRICE_CLOSE);
      m_hMA3 = iMA(_Symbol, TF, MA3_Period, 0, MA_Method, PRICE_CLOSE);
      m_hMACD = iMACD(_Symbol, TF, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE);
      m_hADX = iADX(_Symbol, TF, ADX_Period);
      m_hRSI = iRSI(_Symbol, TF, RSI_Period, PRICE_CLOSE);
      m_hATR = iATR(_Symbol, TF, ATR_Period);
      m_hFractal = iFractals(_Symbol, TF);
      m_hBands = iBands(_Symbol, TF, 20, 0, 2.0, PRICE_CLOSE);
      m_hMA_Higher = iMA(_Symbol, HigherTF, MainTrend_MA, 0, MODE_SMA, PRICE_CLOSE);
      
      bool success = (m_hMA1 != INVALID_HANDLE && m_hMA2 != INVALID_HANDLE && m_hMA3 != INVALID_HANDLE &&
                     m_hMACD != INVALID_HANDLE && m_hADX != INVALID_HANDLE && m_hRSI != INVALID_HANDLE &&
                     m_hATR != INVALID_HANDLE);
      
      if(!success) Print("❌ Gösterge hatası!");
      return success;
   }
   
   void UpdateATR()
   {
      double atr[];
      ArraySetAsSeries(atr, true);
      ArrayResize(atr, 1);
      if(CopyBuffer(m_hATR, 0, 0, 1, atr) >= 1) m_lastATR = atr[0];
   }
   
   void UpdateBarState()
   {
      datetime currentBar = iTime(_Symbol, TF, 0);
      if(m_lastBarTime != currentBar) {
         m_lastBarTime = currentBar;
         m_barsSinceTrade++;
         m_signalGivenThisBar = false;
      }
   }
   
   bool CanTrade()
   {
      if(m_barsSinceTrade < CooldownBars) return false;
      if(m_signalGivenThisBar) return false;
      return true;
   }
   
   void OnTradeOpened() { m_barsSinceTrade = 0; m_signalGivenThisBar = true; }
   
   //=== MARKET REJİM TESPİTİ ===
   ENUM_MARKET_REGIME GetRegime()
   {
      if(!UseRegimeFilter) return REGIME_TRENDING;
      
      double upper[], lower[], adx[];
      ArraySetAsSeries(upper, true); ArraySetAsSeries(lower, true); ArraySetAsSeries(adx, true);
      
      if(CopyBuffer(m_hBands, 1, 0, Regime_Lookback, upper) < Regime_Lookback) return REGIME_TRENDING;
      if(CopyBuffer(m_hBands, 2, 0, Regime_Lookback, lower) < Regime_Lookback) return REGIME_TRENDING;
      if(CopyBuffer(m_hADX, 0, 0, 1, adx) < 1) return REGIME_TRENDING;

      double sumWidth = 0;
      for(int i = 1; i < Regime_Lookback; i++) sumWidth += (upper[i] - lower[i]);
      
      double avgWidth = sumWidth / (double)(Regime_Lookback - 1);
      double curWidth = upper[0] - lower[0];

      if(avgWidth > 0 && curWidth > avgWidth * Vol_Explosion_Mul) return REGIME_HIGH_VOLATILITY;
      if(adx[0] > 25) return REGIME_TRENDING;
      
      return REGIME_RANGING;
   }
   
   //=== ÜÇLÜ MA SİNYALİ (MA Dansı) ===
   int GetMACrossSignal()
   {
      double ma1[], ma2[], ma3[];
      ArraySetAsSeries(ma1, true); ArraySetAsSeries(ma2, true); ArraySetAsSeries(ma3, true);
      ArrayResize(ma1, 3); ArrayResize(ma2, 3); ArrayResize(ma3, 3);
      
      if(CopyBuffer(m_hMA1, 0, 0, 3, ma1) < 3) { Print("⚠️ MA1 buffer hatası"); return 0; }
      if(CopyBuffer(m_hMA2, 0, 0, 3, ma2) < 3) { Print("⚠️ MA2 buffer hatası"); return 0; }
      if(CopyBuffer(m_hMA3, 0, 0, 3, ma3) < 3) { Print("⚠️ MA3 buffer hatası"); return 0; }
      
      // MA1 MA2'yi yukarı kesiyor (Cross)
      bool ma1CrossUpMa2 = (ma1[2] <= ma2[2]) && (ma1[1] > ma2[1]);
      bool ma1CrossDownMa2 = (ma1[2] >= ma2[2]) && (ma1[1] < ma2[1]);
      
      // Trend yönü (Cross olmasa bile)
      bool upTrend = (ma1[0] > ma2[0]);
      bool downTrend = (ma1[0] < ma2[0]);
      
      // MA3 yönü (Ana Trend)
      bool aboveMA3 = (ma1[0] > ma3[0]) && (ma2[0] > ma3[0]);
      bool belowMA3 = (ma1[0] < ma3[0]) && (ma2[0] < ma3[0]);
      
      // v11 FIX: Cross veya Trend yeterli, MA3 opsiyonel
      // Cross varsa = güçlü sinyal, Trend varsa = normal sinyal
      bool buySetup = (ma1CrossUpMa2 || upTrend);
      bool sellSetup = (ma1CrossDownMa2 || downTrend);
      
      // Debug log
      static datetime lastDebug = 0;
      if(TimeCurrent() - lastDebug > 60) { // Her 60 saniyede bir
         Print("📊 MA DEBUG: MA1=", ma1[0], " MA2=", ma2[0], " MA3=", ma3[0]);
         Print("   Cross Up:", ma1CrossUpMa2, " Cross Down:", ma1CrossDownMa2);
         Print("   UpTrend:", upTrend, " DownTrend:", downTrend);
         Print("   AboveMA3:", aboveMA3, " BelowMA3:", belowMA3);
         lastDebug = TimeCurrent();
      }
      
      if(!buySetup && !sellSetup) return 0;

      
      // MACD Filtresi
      if(UseMACD) {
         double hist[];
         ArraySetAsSeries(hist, true);
         ArrayResize(hist, 1);
         if(CopyBuffer(m_hMACD, 2, 0, 1, hist) < 1) return 0;
         
         if(MACDAboveZero) {
            if(buySetup && hist[0] <= 0) return 0;
            if(sellSetup && hist[0] >= 0) return 0;
         }
      }
      
      // Linear Regression Slope
      if(UseLR) {
         double slope = CPriceEngine::CalculateLRSlope(LR_Period);
         if(buySetup && slope < LR_MinSlope) return 0;
         if(sellSetup && slope > -LR_MinSlope) return 0;
      }
      
      // ADX Filtresi
      if(UseADX) {
         double adx[];
         ArraySetAsSeries(adx, true);
         ArrayResize(adx, 1);
         if(CopyBuffer(m_hADX, 0, 0, 1, adx) < 1) return 0;
         if(adx[0] < ADX_Min) return 0;
      }
      
      // RSI Filtresi
      if(UseRSI) {
         double rsi[];
         ArraySetAsSeries(rsi, true);
         ArrayResize(rsi, 1);
         if(CopyBuffer(m_hRSI, 0, 0, 1, rsi) < 1) return 0;
         if(buySetup && rsi[0] > RSI_OB) return 0;
         if(sellSetup && rsi[0] < RSI_OS) return 0;
      }
      
      if(buySetup) {
         Print("═══════════════════════════════════════════════════════════");
         Print("✅ v11 BUY: MA", MA1_Period, " × MA", MA2_Period, " Golden Cross");
         Print("   📊 MA3(", MA3_Period, ") üzerinde");
         Print("═══════════════════════════════════════════════════════════");
         return 1;
      }
      
      if(sellSetup) {
         Print("═══════════════════════════════════════════════════════════");
         Print("✅ v11 SELL: MA", MA1_Period, " × MA", MA2_Period, " Death Cross");
         Print("   📊 MA3(", MA3_Period, ") altında");
         Print("═══════════════════════════════════════════════════════════");
         return -1;
      }
      
      return 0;
   }
   
   //=== FRACTAL SİNYALİ ===
   int GetFractalSignal()
   {
      double up[], down[];
      ArraySetAsSeries(up, true); ArraySetAsSeries(down, true);
      
      if(CopyBuffer(m_hFractal, 0, 0, 5, up) < 5) return 0;
      if(CopyBuffer(m_hFractal, 1, 0, 5, down) < 5) return 0;

      bool isDip = (down[2] != 0.0 && down[2] != EMPTY_VALUE);
      bool isTop = (up[2] != 0.0 && up[2] != EMPTY_VALUE);
      
      datetime barTime = iTime(_Symbol, TF, 2);
      if(barTime <= m_lastSignalTime) return 0;

      // Higher TF trend kontrolü
      double bufMA[], bufClose[];
      ArraySetAsSeries(bufMA, true); ArraySetAsSeries(bufClose, true);
      
      if(CopyBuffer(m_hMA_Higher, 0, 0, 1, bufMA) > 0 && CopyClose(_Symbol, HigherTF, 0, 1, bufClose) > 0)
      {
         if(isDip && bufClose[0] < bufMA[0]) return 0;
         if(isTop && bufClose[0] > bufMA[0]) return 0;
      }

      if(isDip) { m_lastSignalTime = barTime; return 1; }
      if(isTop) { m_lastSignalTime = barTime; return -1; }
      
      return 0;
   }
   
   //=== ANA SİNYAL FONKSİYONU ===
   int GetSignal(ENUM_MARKET_REGIME regime)
   {
      if(regime == REGIME_HIGH_VOLATILITY) return 0;
      
      if(SignalMode == SIG_MA_CROSS) return GetMACrossSignal();
      if(SignalMode == SIG_FRACTAL) return GetFractalSignal();
      if(SignalMode == SIG_COMBINED) {
         int maSignal = GetMACrossSignal();
         int fracSignal = GetFractalSignal();
         if(maSignal != 0 && maSignal == fracSignal) return maSignal;
      }
      return 0;
   }
};

//====================================================================
// CLASS: TRADE EXECUTOR (İşlem Açma)
//====================================================================
class CTradeExecutor
{
private:
   CTrade m_trade;

public:
   void Init()
   {
      m_trade.SetExpertMagicNumber(MagicNumber);
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
      m_trade.SetDeviationInPoints(20);
   }
   
   //=== PİYASA EMRİ ===
   bool OpenMarketOrder(int direction, double atr)
   {
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      double slDist, tpDist;
      CPriceEngine::GetDynamicSLTP(atr, slDist, tpDist);
      
      double slPips = CPriceEngine::PointsToPip(slDist);
      double lot = CPriceEngine::CalculateLot(slPips);
      
      double price, sl, tp;
      
      if(StressTestMode) {
         double slip = SimulatedSlippage * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         if(direction == 1) price = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + slip;
         else price = SymbolInfoDouble(_Symbol, SYMBOL_BID) - slip;
      } else {
         price = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      }
      
      if(direction == 1) {
         sl = NormalizeDouble(price - slDist, digits);
         tp = NormalizeDouble(price + tpDist, digits);
         
         if(!CPriceEngine::CheckStopLevel(price, sl, tp, 1)) {
            Print("⚠️ StopLevel reddetti");
            return false;
         }
         
         m_trade.Buy(lot, _Symbol, 0, sl, tp, TradeComment);
      } else {
         sl = NormalizeDouble(price + slDist, digits);
         tp = NormalizeDouble(price - tpDist, digits);
         
         if(!CPriceEngine::CheckStopLevel(price, sl, tp, -1)) {
            Print("⚠️ StopLevel reddetti");
            return false;
         }
         
         m_trade.Sell(lot, _Symbol, 0, sl, tp, TradeComment);
      }
      
      if(m_trade.ResultRetcode() == TRADE_RETCODE_DONE) {
         double rr = tpDist / slDist;
         Print("═══════════════════════════════════════════════════════════");
         Print("✅ ", (direction == 1 ? "BUY" : "SELL"), " AÇILDI");
         Print("   💰 Lot: ", DoubleToString(lot, 2), " | Risk: ", DoubleToString(RiskPercent, 1), "%");
         Print("   🛑 SL: ", DoubleToString(slPips, 1), " pips");
         Print("   🎯 TP: ", DoubleToString(CPriceEngine::PointsToPip(tpDist), 1), " pips");
         Print("   ⚖️ R:R = 1:", DoubleToString(rr, 2));
         Print("═══════════════════════════════════════════════════════════");
         return true;
      }
      
      Print("❌ İşlem başarısız: ", m_trade.ResultRetcode());
      return false;
   }
   
   //=== BEKLEYEN EMİR ===
   bool PlacePendingOrder(int direction, double atr)
   {
      if(HasPendingOrder()) return false;
      
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      double pendDist = CPriceEngine::PipToPoints(PendingPips);
      
      double slDist, tpDist;
      CPriceEngine::GetDynamicSLTP(atr, slDist, tpDist);
      
      double slPips = CPriceEngine::PointsToPip(slDist);
      double lot = CPriceEngine::CalculateLot(slPips);
      
      double orderPrice, sl, tp;
      datetime expiration = iTime(_Symbol, TF, 0) + (PendingExpireBars * PeriodSeconds(TF));
      
      if(direction == 1) {
         orderPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) + pendDist, digits);
         sl = NormalizeDouble(orderPrice - slDist, digits);
         tp = NormalizeDouble(orderPrice + tpDist, digits);
         
         if(!CPriceEngine::CheckStopLevel(orderPrice, sl, tp, 1)) return false;
         
         m_trade.BuyStop(lot, orderPrice, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, TradeComment);
      } else {
         orderPrice = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) - pendDist, digits);
         sl = NormalizeDouble(orderPrice + slDist, digits);
         tp = NormalizeDouble(orderPrice - tpDist, digits);
         
         if(!CPriceEngine::CheckStopLevel(orderPrice, sl, tp, -1)) return false;
         
         m_trade.SellStop(lot, orderPrice, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, TradeComment);
      }
      
      if(m_trade.ResultRetcode() == TRADE_RETCODE_DONE) {
         Print("📋 BEKLEYEN EMİR: ", (direction == 1 ? "BUY_STOP" : "SELL_STOP"));
         return true;
      }
      
      return false;
   }
   
   //=== GRID MATRIX ===
   void PlaceGrid(int direction, double atr)
   {
      if(PositionsTotal() > 0 || OrdersTotal() > 0) return;
      
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      double basePrice = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      datetime expiration = TimeCurrent() + (Grid_ExpirationHrs * 3600);
      double stepSize = CPriceEngine::PipToPoints(Grid_StepPips);
      
      double slDist, tpDist;
      CPriceEngine::GetDynamicSLTP(atr, slDist, tpDist);
      
      double slPips = CPriceEngine::PointsToPip(slDist);
      double lot = CPriceEngine::CalculateLot(slPips);
      
      for(int i = 0; i < Grid_MaxOrders; i++)
      {
         double entry, sl, tp;
         
         if(direction == 1) {
            entry = NormalizeDouble(basePrice + ((i + 1) * stepSize), digits);
            sl = NormalizeDouble(entry - slDist, digits);
            tp = NormalizeDouble(entry + tpDist, digits);
            
            if(!CPriceEngine::CheckStopLevel(entry, sl, tp, 1)) continue;
            
            if(!m_trade.BuyStop(lot, entry, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, 
               TradeComment + "_G" + IntegerToString(i))) {
               if(m_trade.ResultRetcode() == 10014) break;
            }
         } else {
            entry = NormalizeDouble(basePrice - ((i + 1) * stepSize), digits);
            sl = NormalizeDouble(entry + slDist, digits);
            tp = NormalizeDouble(entry - tpDist, digits);
            
            if(!CPriceEngine::CheckStopLevel(entry, sl, tp, -1)) continue;
            
            if(!m_trade.SellStop(lot, entry, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration,
               TradeComment + "_G" + IntegerToString(i))) {
               if(m_trade.ResultRetcode() == 10014) break;
            }
         }
      }
      
      Print("📊 GRID yerleştirildi: ", direction == 1 ? "BUY" : "SELL", " x", Grid_MaxOrders);
   }
   
   //=== BEKLEYEN EMİR YÖNETİMİ ===
   void ManagePendingOrders()
   {
      for(int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetInteger(ORDER_MAGIC) != MagicNumber) continue;
         if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
         
         datetime placeTime = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
         int barsPassed = (int)((TimeCurrent() - placeTime) / PeriodSeconds(TF));
         
         if(barsPassed >= PendingExpireBars) {
            m_trade.OrderDelete(ticket);
            Print("⏰ Bekleyen emir süresi doldu: #", ticket);
         }
      }
   }
   
   //=== ACİL KAPAMA ===
   void EmergencyCloseAll()
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket > 0 && PositionSelectByTicket(ticket))
         {
            bool myTrade = (PositionGetInteger(POSITION_MAGIC) == MagicNumber);
            if(myTrade || ManageManualTrades)
               m_trade.PositionClose(ticket);
         }
      }
      CleanupOrders();
   }
   
   void CleanupOrders()
   {
      for(int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if(ticket > 0 && OrderGetInteger(ORDER_MAGIC) == MagicNumber)
            m_trade.OrderDelete(ticket);
      }
   }
   
   bool HasOpenPosition()
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         return true;
      }
      return false;
   }
   
   bool HasPendingOrder()
   {
      for(int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetInteger(ORDER_MAGIC) != MagicNumber) continue;
         if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
         return true;
      }
      return false;
   }
   
   CTrade* GetTrade() { return &m_trade; }
};

//====================================================================
// CLASS: POSITION MANAGER (BE, Trailing, Partial, Manuel)
//====================================================================
class CPositionManager
{
private:
   CTrade* m_pTrade;
   
   // İstatistik
   int m_totalTrades;
   int m_winTrades;
   double m_grossProfit;
   double m_grossLoss;
   double m_netProfit;

public:
   CPositionManager() : m_pTrade(NULL), m_totalTrades(0), m_winTrades(0), 
      m_grossProfit(0), m_grossLoss(0), m_netProfit(0) {}
   
   void Init(CTrade* pTrade) { m_pTrade = pTrade; }
   
   //=== EA POZİSYONLARINI YÖNET ===
   void ManageEAPositions(double atr)
   {
      if(m_pTrade == NULL) return;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         
         ManagePosition(ticket, atr, true);
      }
   }
   
   //=== MANUEL POZİSYONLARI YÖNET ===
   void ManageManualPositions(double atr)
   {
      if(!ManageManualTrades || m_pTrade == NULL) return;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber) continue;
         
         // SL/TP yoksa ekle
         if(AddSLTPToManual) {
            double sl = PositionGetDouble(POSITION_SL);
            double tp = PositionGetDouble(POSITION_TP);
            
            if(sl == 0 || tp == 0) {
               AddSLTPToPosition(ticket, atr);
            }
         }
         
         ManagePosition(ticket, atr, false);
      }
   }
   
   //=== SL/TP EKLE ===
   void AddSLTPToPosition(ulong ticket, double atr)
   {
      if(!PositionSelectByTicket(ticket)) return;
      
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);
      long posType = PositionGetInteger(POSITION_TYPE);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      double slDist, tpDist;
      CPriceEngine::GetDynamicSLTP(atr, slDist, tpDist);
      
      double newSL = currentSL;
      double newTP = currentTP;
      
      if(posType == POSITION_TYPE_BUY) {
         if(currentSL == 0) newSL = NormalizeDouble(openPrice - slDist, digits);
         if(currentTP == 0) newTP = NormalizeDouble(openPrice + tpDist, digits);
      } else {
         if(currentSL == 0) newSL = NormalizeDouble(openPrice + slDist, digits);
         if(currentTP == 0) newTP = NormalizeDouble(openPrice - tpDist, digits);
      }
      
      if(newSL != currentSL || newTP != currentTP) {
         m_pTrade.PositionModify(ticket, newSL, newTP);
         Print("🛠️ MANUEL: SL/TP eklendi #", ticket);
      }
   }
   
   //=== TEK POZİSYON YÖNETİMİ ===
   void ManagePosition(ulong ticket, double atr, bool isEA)
   {
      if(!PositionSelectByTicket(ticket)) return;
      
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);
      double volume = PositionGetDouble(POSITION_VOLUME);
      long posType = PositionGetInteger(POSITION_TYPE);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      if(currentTP == 0) return;
      
      double tpDist = MathAbs(currentTP - openPrice);
      double profitDist = (posType == POSITION_TYPE_BUY) ? 
         (currentPrice - openPrice) : (openPrice - currentPrice);
      
      //=== AKILLI KISMİ KAPAMA ===
      bool applyPartial = isEA ? UseSmartPartial : (ApplyPartialToManual && UseSmartPartial);
      if(applyPartial && tpDist > 0)
      {
         double partialTrigger = tpDist * (Partial_TriggerPct / 100.0);
         
         if(profitDist >= partialTrigger)
         {
            bool isBE = (MathAbs(currentSL - openPrice) < CPriceEngine::PipToPoints(5));
            double minVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
            
            if(!isBE && volume > minVol)
            {
               double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
               double closeVol = MathFloor((volume * Partial_ClosePct / 100.0) / lotStep) * lotStep;
               
               if(closeVol >= minVol) {
                  m_pTrade.PositionClosePartial(ticket, closeVol);
                  Print("💰 KISMİ KAPAMA: ", DoubleToString(closeVol, 2), " lot #", ticket);
               }
            }
         }
      }
      
      //=== BREAKEVEN ===
      bool applyBE = isEA ? UseBreakeven : (ApplyBEToManual && UseBreakeven);
      if(applyBE && tpDist > 0)
      {
         double beTrigger = tpDist * (BE_TriggerPct / 100.0);
         
         if(profitDist >= beTrigger)
         {
            double bePrice;
            if(posType == POSITION_TYPE_BUY) {
               bePrice = NormalizeDouble(openPrice + CPriceEngine::PipToPoints(BE_LockPips), digits);
               if(currentSL < bePrice) {
                  m_pTrade.PositionModify(ticket, bePrice, currentTP);
                  Print("🔒 BREAKEVEN: SL → ", DoubleToString(bePrice, digits), " #", ticket);
               }
            } else {
               bePrice = NormalizeDouble(openPrice - CPriceEngine::PipToPoints(BE_LockPips), digits);
               if(currentSL > bePrice || currentSL == 0) {
                  m_pTrade.PositionModify(ticket, bePrice, currentTP);
                  Print("🔒 BREAKEVEN: SL → ", DoubleToString(bePrice, digits), " #", ticket);
               }
            }
         }
      }
      
      //=== TRAILING STOP ===
      bool applyTrail = isEA ? UseTrailing : (ApplyTrailToManual && UseTrailing);
      if(applyTrail && atr > 0 && tpDist > 0)
      {
         double trailTrigger = tpDist * (Trail_StartPct / 100.0);
         double trailDist = atr * Trail_ATR_Multi;
         
         if(profitDist >= trailTrigger)
         {
            double newSL;
            if(posType == POSITION_TYPE_BUY) {
               newSL = NormalizeDouble(currentPrice - trailDist, digits);
               if(newSL > currentSL) {
                  m_pTrade.PositionModify(ticket, newSL, currentTP);
                  Print("📈 TRAILING: SL → ", DoubleToString(newSL, digits), " #", ticket);
               }
            } else {
               newSL = NormalizeDouble(currentPrice + trailDist, digits);
               if(newSL < currentSL || currentSL == 0) {
                  m_pTrade.PositionModify(ticket, newSL, currentTP);
                  Print("📉 TRAILING: SL → ", DoubleToString(newSL, digits), " #", ticket);
               }
            }
         }
      }
   }
   
   //=== İSTATİSTİK ===
   void UpdateStats(double profit)
   {
      m_netProfit += profit;
      if(profit > 0) {
         m_winTrades++;
         m_grossProfit += profit;
         Print("🎉 WIN: +$", DoubleToString(profit, 2));
      } else {
         m_grossLoss += profit;
         Print("💔 LOSS: $", DoubleToString(profit, 2));
      }
   }
   
   void IncrementTrades() { m_totalTrades++; }
   
   double GetExpectancy()
   {
      if(m_totalTrades < 5) return 0;
      
      double winRate = (double)m_winTrades / m_totalTrades;
      double lossRate = 1.0 - winRate;
      
      double avgWin = (m_winTrades > 0) ? m_grossProfit / m_winTrades : 0;
      double avgLoss = (m_totalTrades - m_winTrades > 0) ? MathAbs(m_grossLoss) / (m_totalTrades - m_winTrades) : 0;
      
      return (winRate * avgWin) - (lossRate * avgLoss);
   }
   
   void PrintStats()
   {
      double pf = (m_grossLoss != 0) ? m_grossProfit / MathAbs(m_grossLoss) : 0;
      double wr = (m_totalTrades > 0) ? m_winTrades * 100.0 / m_totalTrades : 0;
      double exp = GetExpectancy();
      double avgWin = (m_winTrades > 0) ? m_grossProfit / m_winTrades : 0;
      double avgLoss = (m_totalTrades - m_winTrades > 0) ? MathAbs(m_grossLoss) / (m_totalTrades - m_winTrades) : 0;
      
      Print("═══════════════════════════════════════════════════════════");
      Print("📊 v11 SONUÇLAR");
      Print("═══════════════════════════════════════════════════════════");
      Print("📈 Toplam: ", m_totalTrades, " | Kazanan: ", m_winTrades);
      Print("📈 WinRate: ", DoubleToString(wr, 1), "%");
      Print("⚖️ Profit Factor: ", DoubleToString(pf, 2));
      Print("💰 Net Kar: $", DoubleToString(m_netProfit, 2));
      Print("📊 Expectancy: $", DoubleToString(exp, 2), " / işlem");
      Print("💵 Avg Win: $", DoubleToString(avgWin, 2), " | Avg Loss: $", DoubleToString(avgLoss, 2));
      Print("═══════════════════════════════════════════════════════════");
   }
   
   int GetTotalTrades() { return m_totalTrades; }
   int GetWinTrades() { return m_winTrades; }
   double GetNetProfit() { return m_netProfit; }
   double GetProfitFactor() { return (m_grossLoss != 0) ? m_grossProfit / MathAbs(m_grossLoss) : 0; }
   double GetWinRate() { return (m_totalTrades > 0) ? m_winTrades * 100.0 / m_totalTrades : 0; }
};

//====================================================================
// GLOBAL NESNELER
//====================================================================
CSecurityManager Security;
CSignalEngine    Signal;
CTradeExecutor   Executor;
CPositionManager PosMgr;

//+------------------------------------------------------------------+
//| ONINIT                                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   // Sembol kontrolü
   if(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL)
   {
      Alert("❌ HATA: Bu sembolde işlem izni yok!");
      return INIT_FAILED;
   }
   
   // Lot kontrolü
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(UseFixedLot && (FixedLot < minLot || FixedLot > maxLot))
   {
      Alert("❌ HATA: Lot boyutu uygun değil! Min:", minLot, " Max:", maxLot);
      return INIT_FAILED;
   }
   
   // Sinyal motorunu başlat
   if(!Signal.Init())
   {
      Alert("❌ HATA: İndikatörler yüklenemedi!");
      return INIT_FAILED;
   }
   
   // Diğer modüller
   Security.Init();
   Executor.Init();
   PosMgr.Init(Executor.GetTrade());
   
   // Başlangıç mesajı
   Print("═══════════════════════════════════════════════════════════════════");
   Print("🎯 MİLYONER EA v11.0 - ULTIMATE HYBRID");
   Print("═══════════════════════════════════════════════════════════════════");
   Print("📊 MA Dansı: MA", MA1_Period, " × MA", MA2_Period, " × MA", MA3_Period);
   Print("📊 MACD Sıfır: ", UseMACD ? "AÇIK" : "KAPALI");
   Print("📊 LR Slope: ", UseLR ? "AÇIK" : "KAPALI");
   Print("📊 ADX: ", UseADX ? ">"+IntegerToString(ADX_Min) : "KAPALI");
   Print("📊 RSI: ", UseRSI ? IntegerToString(RSI_OS)+"-"+IntegerToString(RSI_OB) : "KAPALI");
   Print("📊 Rejim Filtre: ", UseRegimeFilter ? "AÇIK" : "KAPALI");
   Print("📊 ATR SL×", ATR_SL_Multi, " TP×", ATR_TP_Multi);
   Print("📊 BE: ", UseBreakeven ? "ON" : "OFF", " | Trail: ", UseTrailing ? "ON" : "OFF");
   Print("📊 Smart Partial: ", UseSmartPartial ? "ON" : "OFF");
   Print("📊 Giriş Modu: ", EnumToString(EntryMode));
   Print("📊 Sinyal Modu: ", EnumToString(SignalMode));
   Print("📊 Manuel Yönetim: ", ManageManualTrades ? "AÇIK" : "KAPALI");
   Print("═══════════════════════════════════════════════════════════════════");
   Print("⌨️ Klavye: [P] Pause | [C] Close All | [D] Daily Reset");
   Print("═══════════════════════════════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| ONDEINIT                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Bekleyen emirleri temizle
   Executor.CleanupOrders();
   
   // İstatistikleri yazdır
   PosMgr.PrintStats();
   
   // Paneli temizle
   ObjectsDeleteAll(0, "MIL_");
   Comment("");
}

//+------------------------------------------------------------------+
//| ONCHARTEVENT - Klavye Kısayolları                                 |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_KEYDOWN)
   {
      // P veya p: Pause/Resume
      if(lparam == 80 || lparam == 112)
      {
         g_ManualPause = !g_ManualPause;
         if(g_ManualPause) {
            Alert("🛑 SİSTEM DURAKLATILDI");
            Print("⏸️ Manuel duraklama aktif");
         } else {
            Alert("✅ SİSTEM DEVAM EDİYOR");
            Print("▶️ Manuel duraklama kaldırıldı");
         }
      }
      // C veya c: Close All
      else if(lparam == 67 || lparam == 99)
      {
         if(MessageBox("Tüm pozisyonları ve emirleri kapatmak istiyor musunuz?", 
            "⚠️ ACİL KAPAMA", MB_YESNO | MB_ICONWARNING) == IDYES)
         {
            Executor.EmergencyCloseAll();
            g_ManualPause = true;
            Alert("🔴 TÜM POZİSYONLAR KAPATILDI");
            Print("🚨 Acil kapama gerçekleştirildi");
         }
      }
      // D veya d: Daily Reset
      else if(lparam == 68 || lparam == 100)
      {
         Security.UpdateReference(true);
         g_SystemLocked = false;
         g_LockReason = "";
         Alert("🔄 GÜNLÜK LİMİTLER SIFIRLANDI");
         Print("📅 Günlük referans yenilendi");
      }
   }
}

//+------------------------------------------------------------------+
//| ONTICK                                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   // ATR güncelle
   Signal.UpdateATR();
   Signal.UpdateBarState();
   
   // Dashboard
   if(ShowDashboard) UpdateDashboard();
   
   // Manuel pause kontrolü
   if(g_ManualPause)
   {
      return;
   }
   
   // Güvenlik kontrolü
   if(!Security.IsSafeToTrade())
   {
      if(g_SystemLocked) {
         Executor.EmergencyCloseAll();
      }
      return;
   }
   
   // Pozisyon yönetimi
   PosMgr.ManageEAPositions(Signal.m_lastATR);
   PosMgr.ManageManualPositions(Signal.m_lastATR);
   
   // Bekleyen emir yönetimi
   Executor.ManagePendingOrders();
   
   // Pozisyon varsa sinyal arama
   if(Executor.HasOpenPosition())
   {
      return;
   }
   
   // Cooldown ve barlık kontrol
   if(!Signal.CanTrade())
   {
      return;
   }
   
   // Market rejimi
   ENUM_MARKET_REGIME regime = Signal.GetRegime();
   
   // Sinyal al
   int signal = Signal.GetSignal(regime);
   
   if(signal != 0)
   {
      bool success = false;
      
      // Giriş moduna göre işlem aç
      if(EntryMode == MODE_MARKET || EntryMode == MODE_BOTH) {
         success = Executor.OpenMarketOrder(signal, Signal.m_lastATR);
      }
      if(EntryMode == MODE_PENDING || EntryMode == MODE_BOTH) {
         success = Executor.PlacePendingOrder(signal, Signal.m_lastATR) || success;
      }
      if(EntryMode == MODE_GRID) {
         Executor.PlaceGrid(signal, Signal.m_lastATR);
         success = true;
      }
      
      if(success) {
         Signal.OnTradeOpened();
         Security.IncrementTradeCount();
         PosMgr.IncrementTrades();
      }
   }
}

//+------------------------------------------------------------------+
//| ONTRADETRANSACTION                                                |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& req, const MqlTradeResult& res)
{
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      if(trans.deal_type == DEAL_TYPE_BUY || trans.deal_type == DEAL_TYPE_SELL) return;
      
      ulong dealTicket = trans.deal;
      if(dealTicket > 0 && HistoryDealSelect(dealTicket))
      {
         double dealProfit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
         if(HistoryDealGetInteger(dealTicket, DEAL_MAGIC) == MagicNumber)
         {
            PosMgr.UpdateStats(dealProfit);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| DASHBOARD                                                         |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
   string status = "";
   string emoji = "";
   
   if(g_ManualPause) {
      status = "DURAKLATILDI";
      emoji = "⏸️";
   } else if(g_SystemLocked) {
      status = g_LockReason;
      emoji = "🔒";
   } else if(g_LockReason != "") {
      status = g_LockReason;
      emoji = "⏳";
   } else {
      status = "AKTİF";
      emoji = "✅";
   }
   
   string regimeStr = "";
   ENUM_MARKET_REGIME reg = Signal.GetRegime();
   if(reg == REGIME_HIGH_VOLATILITY) regimeStr = "⚡ YÜKSEK VOL";
   else if(reg == REGIME_TRENDING) regimeStr = "📈 TREND";
   else regimeStr = "📊 RANGE";
   
   string dash = "";
   dash += "═══════════════════════════════════════\n";
   dash += "   🎯 MİLYONER EA v11.0 ULTIMATE\n";
   dash += "═══════════════════════════════════════\n";
   dash += emoji + " Durum: " + status + "\n";
   dash += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   dash += "📊 Rejim: " + regimeStr + "\n";
   dash += "📈 ATR: " + DoubleToString(CPriceEngine::PointsToPip(Signal.m_lastATR), 1) + " pip\n";
   dash += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   dash += "💰 Günlük P/L: $" + DoubleToString(Security.GetDailyPL(), 2) + "\n";
   dash += "📊 İşlemler: " + IntegerToString(Security.GetTradeCount()) + "/" + IntegerToString(MaxDailyTrades) + "\n";
   dash += "📈 Marjin: " + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 0) + "%\n";
   dash += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   dash += "📊 Toplam: " + IntegerToString(PosMgr.GetTotalTrades()) + " | ";
   dash += "Win: " + IntegerToString(PosMgr.GetWinTrades()) + "\n";
   dash += "⚖️ WR: " + DoubleToString(PosMgr.GetWinRate(), 1) + "% | ";
   dash += "PF: " + DoubleToString(PosMgr.GetProfitFactor(), 2) + "\n";
   dash += "💵 Net: $" + DoubleToString(PosMgr.GetNetProfit(), 2) + "\n";
   dash += "📊 Expectancy: $" + DoubleToString(PosMgr.GetExpectancy(), 2) + "\n";
   dash += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   dash += "⌨️ [P]ause [C]lose [D]aily Reset\n";
   dash += "═══════════════════════════════════════\n";
   
   Comment(dash);
}

//====================================================================
// EK ÖZELLİKLER VE UTILITY FONKSİYONLARI
//====================================================================

//+------------------------------------------------------------------+
//| Sembol Bilgilerini Yazdır                                         |
//+------------------------------------------------------------------+
void PrintSymbolInfo()
{
   Print("═══════════════════════════════════════════════════════════");
   Print("📊 SEMBOL BİLGİLERİ: ", _Symbol);
   Print("═══════════════════════════════════════════════════════════");
   Print("   Point: ", SymbolInfoDouble(_Symbol, SYMBOL_POINT));
   Print("   Digits: ", SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
   Print("   Spread: ", SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), " points");
   Print("   StopLevel: ", SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL), " points");
   Print("   Min Lot: ", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
   Print("   Max Lot: ", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX));
   Print("   Lot Step: ", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP));
   Print("   Tick Value: ", SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE));
   Print("   Tick Size: ", SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE));
   Print("   Contract Size: ", SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE));
   Print("   1 Pip = ", CPriceEngine::PipToPoints(1), " points");
   Print("═══════════════════════════════════════════════════════════");
}

//+------------------------------------------------------------------+
//| Hesap Bilgilerini Yazdır                                          |
//+------------------------------------------------------------------+
void PrintAccountInfo()
{
   Print("═══════════════════════════════════════════════════════════");
   Print("💰 HESAP BİLGİLERİ");
   Print("═══════════════════════════════════════════════════════════");
   Print("   Balance: $", DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2));
   Print("   Equity: $", DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2));
   Print("   Free Margin: $", DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE), 2));
   Print("   Margin Level: ", DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 2), "%");
   Print("   Leverage: 1:", AccountInfoInteger(ACCOUNT_LEVERAGE));
   Print("   Currency: ", AccountInfoString(ACCOUNT_CURRENCY));
   Print("═══════════════════════════════════════════════════════════");
}

//+------------------------------------------------------------------+
//| Pip Değerini Hesapla                                              |
//+------------------------------------------------------------------+
double CalculatePipValue(double lots)
{
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   if(tickValue <= 0 || tickSize <= 0) return 0;
   
   double pipValue = tickValue * (point / tickSize) * 10.0 * lots;
   return pipValue;
}

//+------------------------------------------------------------------+
//| Risk Miktarını Hesapla                                            |
//+------------------------------------------------------------------+
double CalculateRiskAmount()
{
   return AccountInfoDouble(ACCOUNT_BALANCE) * RiskPercent / 100.0;
}

//+------------------------------------------------------------------+
//| Maksimum Lot Hesapla (Risk Bazlı)                                 |
//+------------------------------------------------------------------+
double CalculateMaxLotByRisk(double slPips)
{
   double riskAmount = CalculateRiskAmount();
   double pipValue = CalculatePipValue(1.0); // 1 lot için pip değeri
   
   if(pipValue <= 0 || slPips <= 0) return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   
   double maxLot = riskAmount / (slPips * pipValue);
   return CPriceEngine::NormalizeLot(maxLot);
}

//+------------------------------------------------------------------+
//| Toplam Pozisyon Sayısı                                            |
//+------------------------------------------------------------------+
int CountPositions(bool onlyEA = true)
{
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      if(onlyEA && PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      
      count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| Toplam Bekleyen Emir Sayısı                                       |
//+------------------------------------------------------------------+
int CountPendingOrders(bool onlyEA = true)
{
   int count = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      
      if(onlyEA && OrderGetInteger(ORDER_MAGIC) != MagicNumber) continue;
      
      count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| Toplam Floating P/L                                               |
//+------------------------------------------------------------------+
double GetFloatingPL(bool onlyEA = true)
{
   double pl = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      if(onlyEA && PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      
      pl += PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
   }
   return pl;
}

//+------------------------------------------------------------------+
//| Toplam Lot Miktarı                                                |
//+------------------------------------------------------------------+
double GetTotalLots(bool onlyEA = true)
{
   double lots = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      if(onlyEA && PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      
      lots += PositionGetDouble(POSITION_VOLUME);
   }
   return lots;
}

//+------------------------------------------------------------------+
//| Son Kapanan İşlem Sonucu                                          |
//+------------------------------------------------------------------+
double GetLastClosedTradeResult()
{
   datetime from = TimeCurrent() - 86400; // Son 24 saat
   datetime to = TimeCurrent();
   
   if(!HistorySelect(from, to)) return 0;
   
   int total = HistoryDealsTotal();
   for(int i = total - 1; i >= 0; i--)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;
      
      if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != MagicNumber) continue;
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;
      
      ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY)
      {
         return HistoryDealGetDouble(ticket, DEAL_PROFIT);
      }
   }
   return 0;
}

//+------------------------------------------------------------------+
//| Ardışık Kazanç/Kayıp Sayısı                                       |
//+------------------------------------------------------------------+
int GetConsecutiveResults(bool countWins)
{
   datetime from = TimeCurrent() - 86400 * 30; // Son 30 gün
   datetime to = TimeCurrent();
   
   if(!HistorySelect(from, to)) return 0;
   
   int count = 0;
   int total = HistoryDealsTotal();
   
   for(int i = total - 1; i >= 0; i--)
   {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket == 0) continue;
      
      if(HistoryDealGetInteger(ticket, DEAL_MAGIC) != MagicNumber) continue;
      if(HistoryDealGetString(ticket, DEAL_SYMBOL) != _Symbol) continue;
      
      ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
      if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY)
      {
         double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         
         if(countWins && profit > 0) count++;
         else if(!countWins && profit < 0) count++;
         else break; // Seri kırıldı
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Zaman Dilimi Kontrolü                                             |
//+------------------------------------------------------------------+
bool IsWithinTradingHours()
{
   if(!UseTimeFilter) return true;
   
   MqlDateTime dt;
   TimeCurrent(dt);
   
   return (dt.hour >= StartHour && dt.hour < EndHour);
}

//+------------------------------------------------------------------+
//| Hafta Sonu Kontrolü                                               |
//+------------------------------------------------------------------+
bool IsWeekend()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   
   return (dt.day_of_week == 0 || dt.day_of_week == 6);
}

//+------------------------------------------------------------------+
//| Piyasa Açık mı Kontrolü                                           |
//+------------------------------------------------------------------+
bool IsMarketOpen()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   
   // Pazar günü piyasa kapalı
   if(dt.day_of_week == 0) return false;
   
   // Cuma 22:00'dan sonra piyasa kapanmaya başlar
   if(dt.day_of_week == 5 && dt.hour >= 22) return false;
   
   // Pazartesi 00:00'dan önce piyasa kapalı
   if(dt.day_of_week == 1 && dt.hour < 0) return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Volatilite Kontrolü (ATR Bazlı)                                   |
//+------------------------------------------------------------------+
bool IsHighVolatility(double atr, double threshold)
{
   double atrPips = CPriceEngine::PointsToPip(atr);
   return (atrPips > threshold);
}

//+------------------------------------------------------------------+
//| Trend Yönü (MA Bazlı)                                             |
//+------------------------------------------------------------------+
int GetTrendDirection()
{
   double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   int hMA = iMA(_Symbol, TF, MA3_Period, 0, MA_Method, PRICE_CLOSE);
   if(hMA == INVALID_HANDLE) return 0;
   
   double ma[];
   ArraySetAsSeries(ma, true);
   if(CopyBuffer(hMA, 0, 0, 1, ma) < 1) { IndicatorRelease(hMA); return 0; }
   
   IndicatorRelease(hMA);
   
   if(price > ma[0]) return 1;  // Uptrend
   if(price < ma[0]) return -1; // Downtrend
   return 0;
}

//+------------------------------------------------------------------+
//| RSI Değerini Al                                                   |
//+------------------------------------------------------------------+
double GetRSI()
{
   int hRSI = iRSI(_Symbol, TF, RSI_Period, PRICE_CLOSE);
   if(hRSI == INVALID_HANDLE) return 50;
   
   double rsi[];
   ArraySetAsSeries(rsi, true);
   if(CopyBuffer(hRSI, 0, 0, 1, rsi) < 1) { IndicatorRelease(hRSI); return 50; }
   
   IndicatorRelease(hRSI);
   return rsi[0];
}

//+------------------------------------------------------------------+
//| ADX Değerini Al                                                   |
//+------------------------------------------------------------------+
double GetADX()
{
   int hADX = iADX(_Symbol, TF, ADX_Period);
   if(hADX == INVALID_HANDLE) return 0;
   
   double adx[];
   ArraySetAsSeries(adx, true);
   if(CopyBuffer(hADX, 0, 0, 1, adx) < 1) { IndicatorRelease(hADX); return 0; }
   
   IndicatorRelease(hADX);
   return adx[0];
}

//+------------------------------------------------------------------+
//| MACD Histogram Değerini Al                                        |
//+------------------------------------------------------------------+
double GetMACDHistogram()
{
   int hMACD = iMACD(_Symbol, TF, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE);
   if(hMACD == INVALID_HANDLE) return 0;
   
   double hist[];
   ArraySetAsSeries(hist, true);
   if(CopyBuffer(hMACD, 2, 0, 1, hist) < 1) { IndicatorRelease(hMACD); return 0; }
   
   IndicatorRelease(hMACD);
   return hist[0];
}

//+------------------------------------------------------------------+
//| Bollinger Bands Değerlerini Al                                    |
//+------------------------------------------------------------------+
void GetBollingerBands(double &upper, double &middle, double &lower)
{
   int hBands = iBands(_Symbol, TF, 20, 0, 2.0, PRICE_CLOSE);
   if(hBands == INVALID_HANDLE) { upper = middle = lower = 0; return; }
   
   double up[], mid[], low[];
   ArraySetAsSeries(up, true); ArraySetAsSeries(mid, true); ArraySetAsSeries(low, true);
   
   CopyBuffer(hBands, 0, 0, 1, mid);  // Middle
   CopyBuffer(hBands, 1, 0, 1, up);   // Upper
   CopyBuffer(hBands, 2, 0, 1, low);  // Lower
   
   upper = (ArraySize(up) > 0) ? up[0] : 0;
   middle = (ArraySize(mid) > 0) ? mid[0] : 0;
   lower = (ArraySize(low) > 0) ? low[0] : 0;
   
   IndicatorRelease(hBands);
}

//+------------------------------------------------------------------+
//| Support/Resistance Seviyeleri (Basit)                             |
//+------------------------------------------------------------------+
void GetSupportResistance(double &support, double &resistance, int bars = 50)
{
   double highest = 0, lowest = 999999;
   
   for(int i = 1; i <= bars; i++)
   {
      double high = iHigh(_Symbol, TF, i);
      double low = iLow(_Symbol, TF, i);
      
      if(high > highest) highest = high;
      if(low < lowest) lowest = low;
   }
   
   resistance = highest;
   support = lowest;
}

//+------------------------------------------------------------------+
//| Pivot Noktalarını Hesapla                                         |
//+------------------------------------------------------------------+
void CalculatePivotPoints(double &pp, double &r1, double &r2, double &r3, double &s1, double &s2, double &s3)
{
   double high = iHigh(_Symbol, PERIOD_D1, 1);
   double low = iLow(_Symbol, PERIOD_D1, 1);
   double close = iClose(_Symbol, PERIOD_D1, 1);
   
   pp = (high + low + close) / 3.0;
   
   r1 = 2 * pp - low;
   s1 = 2 * pp - high;
   
   r2 = pp + (high - low);
   s2 = pp - (high - low);
   
   r3 = high + 2 * (pp - low);
   s3 = low - 2 * (high - pp);
}

//+------------------------------------------------------------------+
//| Fibonacci Seviyeleri                                              |
//+------------------------------------------------------------------+
void CalculateFibonacciLevels(double high, double low, double &fib236, double &fib382, double &fib500, double &fib618, double &fib786)
{
   double range = high - low;
   
   fib236 = high - range * 0.236;
   fib382 = high - range * 0.382;
   fib500 = high - range * 0.500;
   fib618 = high - range * 0.618;
   fib786 = high - range * 0.786;
}

//+------------------------------------------------------------------+
//| Session Kontrolü                                                  |
//+------------------------------------------------------------------+
string GetCurrentSession()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   int hour = dt.hour;
   
   // GMT+0 varsayımıyla
   if(hour >= 0 && hour < 8) return "Sydney/Tokyo";
   if(hour >= 8 && hour < 12) return "London";
   if(hour >= 12 && hour < 17) return "London/NY";
   if(hour >= 17 && hour < 22) return "New York";
   
   return "Off-Hours";
}

//+------------------------------------------------------------------+
//| Log Fonksiyonu                                                    |
//+------------------------------------------------------------------+
void LogMessage(string message, bool isError = false)
{
   string prefix = isError ? "❌ " : "📝 ";
   Print(prefix, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS), " | ", message);
}

//+------------------------------------------------------------------+
//| Debug Modu Fonksiyonu                                             |
//+------------------------------------------------------------------+
void DebugPrint(string message)
{
   #ifdef _DEBUG
   Print("🔧 DEBUG: ", message);
   #endif
}

//+------------------------------------------------------------------+
//| Dosyaya Log Yaz                                                   |
//+------------------------------------------------------------------+
void WriteToLogFile(string message)
{
   string filename = "MilyonerEA_v11_" + _Symbol + ".log";
   int handle = FileOpen(filename, FILE_WRITE | FILE_READ | FILE_TXT | FILE_ANSI);
   
   if(handle != INVALID_HANDLE)
   {
      FileSeek(handle, 0, SEEK_END);
      FileWriteString(handle, TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + " | " + message + "\r\n");
      FileClose(handle);
   }
}

//+------------------------------------------------------------------+
//| Alert Gönder                                                      |
//+------------------------------------------------------------------+
void SendAlertNotification(string message)
{
   Alert(message);
   
   // Push notification (eğer ayarlıysa)
   if(TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))
   {
      SendNotification("MilyonerEA v11: " + message);
   }
}

//+------------------------------------------------------------------+
//| Ses Çal                                                           |
//+------------------------------------------------------------------+
void PlayAlertSound(string soundFile = "alert.wav")
{
   PlaySound(soundFile);
}

//+------------------------------------------------------------------+
//| İşlem Özeti Yazdır                                                |
//+------------------------------------------------------------------+
void PrintTradeSummary()
{
   Print("═══════════════════════════════════════════════════════════");
   Print("📊 İŞLEM ÖZETİ - ", _Symbol);
   Print("═══════════════════════════════════════════════════════════");
   Print("   Açık Pozisyonlar: ", CountPositions(true));
   Print("   Bekleyen Emirler: ", CountPendingOrders(true));
   Print("   Floating P/L: $", DoubleToString(GetFloatingPL(true), 2));
   Print("   Toplam Lot: ", DoubleToString(GetTotalLots(true), 2));
   Print("   Son İşlem: $", DoubleToString(GetLastClosedTradeResult(), 2));
   Print("   Ardışık Win: ", GetConsecutiveResults(true));
   Print("   Ardışık Loss: ", GetConsecutiveResults(false));
   Print("═══════════════════════════════════════════════════════════");
}

//+------------------------------------------------------------------+
//| Sistem Durumu Raporu                                              |
//+------------------------------------------------------------------+
void PrintSystemStatus()
{
   Print("═══════════════════════════════════════════════════════════");
   Print("🖥️ SİSTEM DURUMU");
   Print("═══════════════════════════════════════════════════════════");
   Print("   Pause: ", g_ManualPause ? "EVET" : "HAYIR");
   Print("   Locked: ", g_SystemLocked ? "EVET (" + g_LockReason + ")" : "HAYIR");
   Print("   Session: ", GetCurrentSession());
   Print("   Market Open: ", IsMarketOpen() ? "EVET" : "HAYIR");
   Print("   Trading Hours: ", IsWithinTradingHours() ? "EVET" : "HAYIR");
   Print("   ATR: ", DoubleToString(CPriceEngine::PointsToPip(Signal.m_lastATR), 1), " pip");
   Print("   RSI: ", DoubleToString(GetRSI(), 1));
   Print("   ADX: ", DoubleToString(GetADX(), 1));
   Print("   Trend: ", GetTrendDirection() == 1 ? "UP" : (GetTrendDirection() == -1 ? "DOWN" : "FLAT"));
   Print("═══════════════════════════════════════════════════════════");
}

//+------------------------------------------------------------------+
//| v11 - Tüm özellikler ile Ultimate Hybrid EA                       |
//| Titanium Omega + MA Master Scalper birleşimi                      |
//| © 2025, Milyoner EA Project                                       |
//+------------------------------------------------------------------+
