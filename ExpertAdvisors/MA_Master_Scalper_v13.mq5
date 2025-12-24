//+------------------------------------------------------------------+
//|                                     MA_Master_Scalper_v14.mq5    |
//|       © 2025, Milyoner EA Project v14.0 - ULTIMATE 5K EDITION    |
//|          All-in-One AI Trading System | 5000+ Lines              |
//+------------------------------------------------------------------+
#property copyright "© 2025, Milyoner EA v14 - ULTIMATE 5K"
#property version   "14.00"
#property description "Next-Gen AI Trading System with 30+ Synchronized Modules"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// v13 ULTIMATE 3K EDITION
//====================================================================
// MODÜL 1: AI Signal Scorer (7-Faktör Ağırlıklı Oylama)
// MODÜL 2: Candle Pattern Recognition (15+ Pattern)
// MODÜL 3: Wick Analysis (Fitil Gücü Analizi)
// MODÜL 4: Fibonacci Retracement & Extension
// MODÜL 5: Pivot Points (Classic, Camarilla, Woodie)
// MODÜL 6: Support/Resistance Dynamic Detection
// MODÜL 7: Multi-Timeframe Trend Analysis
// MODÜL 8: Market Session Analysis
// MODÜL 9: Volatility Regime Detection
// MODÜL 10: RSI/MACD Divergence Detection
// MODÜL 11: Signal History & Machine Learning Simulation
// MODÜL 12: Adaptive Threshold System
// MODÜL 13: Advanced Risk Management
// MODÜL 14: Smart Partial Close System
// MODÜL 15: Dynamic Trailing Stop
// MODÜL 16: Grid Matrix System
// MODÜL 17: Hedge Protection Mode
// MODÜL 18: News Event Filter
// MODÜL 19: Spread & Slippage Protection
// MODÜL 20: Visual Dashboard & Analytics
//====================================================================

//====================================================================
// ENUM TANIMLARI
//====================================================================
enum ENUM_MARKET_REGIME {
   REGIME_HIGH_VOLATILITY,    // Yüksek Volatilite
   REGIME_TRENDING,           // Trend
   REGIME_RANGING,            // Range
   REGIME_BREAKOUT,           // Kırılım
   REGIME_REVERSAL            // Dönüş
};

enum ENUM_ENTRY_MODE { 
   MODE_MARKET,               // Sadece Piyasa Emri
   MODE_PENDING,              // Sadece Bekleyen Emir
   MODE_BOTH,                 // Her İkisi
   MODE_GRID,                 // Grid Sistemi
   MODE_SMART                 // Akıllı Mod (Rejime Göre)
};

enum ENUM_SIGNAL_MODE {
   SIG_MA_CROSS,              // MA Kesişim
   SIG_PATTERN,               // Mum Pattern
   SIG_COMBINED,              // Birleşik
   SIG_AI_SCORE,              // AI Skor Bazlı
   SIG_HARMONY                // Tam Harmony
};

enum ENUM_CANDLE_PATTERN {
   PATTERN_NONE,
   PATTERN_BULLISH_PINBAR,
   PATTERN_BEARISH_PINBAR,
   PATTERN_BULLISH_ENGULFING,
   PATTERN_BEARISH_ENGULFING,
   PATTERN_DOJI,
   PATTERN_HAMMER,
   PATTERN_SHOOTING_STAR,
   PATTERN_MORNING_STAR,
   PATTERN_EVENING_STAR,
   PATTERN_THREE_WHITE_SOLDIERS,
   PATTERN_THREE_BLACK_CROWS,
   PATTERN_BULLISH_HARAMI,
   PATTERN_BEARISH_HARAMI,
   PATTERN_TWEEZER_TOP,
   PATTERN_TWEEZER_BOTTOM
};

enum ENUM_PIVOT_TYPE {
   PIVOT_CLASSIC,
   PIVOT_CAMARILLA,
   PIVOT_WOODIE,
   PIVOT_FIBONACCI
};

enum ENUM_TRAIL_MODE {
   TRAIL_FIXED,               // Sabit Pip
   TRAIL_ATR,                 // ATR Bazlı
   TRAIL_PARABOLIC,           // Parabolik
   TRAIL_CHANDELIER           // Chandelier Exit
};

enum ENUM_RISK_MODE {
   RISK_FIXED_LOT,            // Sabit Lot
   RISK_PERCENT,              // Yüzde Bazlı
   RISK_KELLY,                // Kelly Kriteri
   RISK_OPTIMAL_F             // Optimal F
};

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 1: ANA AYARLAR
//====================================================================
input group "══════════════════════════════════════════════════════════════"
input group "═══════ 1. ANA AYARLAR ═══════"
input ulong    MagicNumber       = 131313;
input string   TradeComment      = "MILYONER_v13_3K";
input ENUM_TIMEFRAMES TF         = PERIOD_M5;
input ENUM_ENTRY_MODE EntryMode  = MODE_MARKET;
input ENUM_SIGNAL_MODE SignalMode = SIG_HARMONY;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 2: AI SİNYAL SKORU
//====================================================================
input group "═══════ 2. AI SİNYAL SİSTEMİ ═══════"
input int      MinSignalScore    = 55;             // Min Sinyal Skoru - DENGELİ: Orijinal değer
input int      StrongSignalScore = 70;             // Güçlü Sinyal - DENGELİ: 75→70
input bool     UseAdaptiveThreshold = true;        // Adaptif Eşik
input int      AdaptiveLookback  = 50;             // Adaptif Geriye Bakış
input double   ScoreDecayFactor  = 0.95;           // Skor Azalma Faktörü
input bool     UseHarmonyBoost   = true;           // Harmony Güçlendirme

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 3: MUM ANALİZİ
//====================================================================
input group "═══════ 3. MUM FİTİLİ & PATTERN ═══════"
input bool     UseWickAnalysis   = true;           // Fitil Analizi
input double   MinWickRatio      = 0.25;           // Min Fitil/Gövde Oranı
input double   MaxBodyRatio      = 0.6;            // Max Gövde/Range Oranı
input bool     UseCandlePatterns = true;           // Mum Pattern Kullan
input bool     UseAdvancedPatterns = true;         // Gelişmiş Patternler
input int      PatternLookback   = 5;              // Pattern Geriye Bakış
input double   PatternMinScore   = 70;             // Min Pattern Skoru

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 4: ÜÇLÜ MA SİSTEMİ
//====================================================================
input group "═══════ 4. ÜÇLÜ MA SİSTEMİ ═══════"
input int      MA1_Period        = 8;              // Fast MA
input int      MA2_Period        = 21;             // Medium MA
input int      MA3_Period        = 50;             // Slow MA
input int      MA4_Period        = 200;            // Trend MA
input ENUM_MA_METHOD MA_Method   = MODE_EMA;
input bool     RequireMA4Confirm = false;          // MA200 Onayı - OPTİMİZE: true→false (SELL izin)

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 5: MOMENTUM
//====================================================================
input group "═══════ 5. MOMENTUM GÖSTERGELERİ ═══════"
input bool     UseMACD           = true;
input int      MACD_Fast         = 12;
input int      MACD_Slow         = 26;
input int      MACD_Signal       = 9;
input bool     UseMACDHistogram  = true;           // MACD Histogram Filtresi
input bool     UseRSI            = true;
input int      RSI_Period        = 14;
input int      RSI_OB            = 70;
input int      RSI_OS            = 30;
input bool     UseStochastic     = true;
input int      Stoch_K           = 14;
input int      Stoch_D           = 3;
input int      Stoch_Slowing     = 3;
input bool     UseCCI            = true;
input int      CCI_Period        = 14;
input int      CCI_Level         = 100;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 6: TREND KALİTESİ
//====================================================================
input group "═══════ 6. TREND KALİTESİ ═══════"
input bool     UseADX            = true;
input int      ADX_Period        = 14;
input int      ADX_Min           = 18;             // DENGELİ: 20→18 (Daha fazla fırsat)
input int      ADX_Strong        = 30;
input bool     UseLR             = true;
input int      LR_Period         = 20;
input double   LR_MinSlope       = 0.0001;
input bool     UseTrendStrength  = true;           // Trend Gücü İndeksi
input int      TrendStrengthBars = 20;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 7: VOLATİLİTE
//====================================================================
input group "═══════ 7. VOLATİLİTE REJİMİ ═══════"
input bool     UseATR            = true;
input int      ATR_Period        = 14;
input double   ATR_SL_Multi      = 1.5;            // DENGELİ: Orijinal değer
input double   ATR_TP_Multi      = 2.5;            // DENGELİ: 3.0→2.5 (Daha gerçekçi)
input int      MinSL_Pips        = 8;
input int      MaxSL_Pips        = 30;
input bool     UseVolatilityFilter = true;
input double   VolatilityMultiplier = 1.5;
input bool     UseBollingerBands = true;
input int      BB_Period         = 20;
input double   BB_Deviation      = 2.0;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 8: FİBONACCİ & PİVOT
//====================================================================
input group "═══════ 8. FİBONACCİ & PİVOT ═══════"
input bool     UseFibonacci      = true;
input int      FibLookback       = 50;             // Fibonacci Geriye Bakış
input bool     UsePivots         = true;
input ENUM_PIVOT_TYPE PivotType  = PIVOT_CLASSIC;
input bool     UseSupportResistance = true;
input int      SR_Lookback       = 100;            // S/R Geriye Bakış
input double   SR_TouchZone      = 10.0;           // S/R Temas Bölgesi (pip)

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 9: MULTI-TIMEFRAME
//====================================================================
input group "═══════ 9. MULTI-TIMEFRAME ═══════"
input bool     UseMTF            = true;
input ENUM_TIMEFRAMES HigherTF1  = PERIOD_H1;      // Üst TF 1
input ENUM_TIMEFRAMES HigherTF2  = PERIOD_H4;      // Üst TF 2
input int      MTF_MA_Period     = 50;             // MTF MA Periyodu
input bool     RequireMTFConfirm = true;           // MTF Onayı Gerekli

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 10: DIVERGENCE
//====================================================================
input group "═══════ 10. DİVERJANS TESPİTİ ═══════"
input bool     UseDivergence     = true;
input int      DivergenceLookback = 20;            // Diverjans Geriye Bakış
input bool     UseRSIDivergence  = true;
input bool     UseMACDDivergence = true;
input bool     UseCCIDivergence  = false;
input double   DivergenceMinStrength = 0.3;        // Min Diverjans Gücü

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 11: BREAKEVEN & TRAILING
//====================================================================
input group "═══════ 11. BREAKEVEN & TRAILING ═══════"
input bool     UseBreakeven      = true;
input double   BE_TriggerPct     = 30.0;           // OPTİMİZE: 40→30 (Erken koruma)
input int      BE_LockPips       = 5;              // OPTİMİZE: 3→5 (Daha fazla kâr kilidi)
input bool     UseTrailing       = true;
input ENUM_TRAIL_MODE TrailMode  = TRAIL_ATR;
input double   Trail_StartPct    = 40.0;           // OPTİMİZE: 60→40 (Erken trailing)
input double   Trail_ATR_Multi   = 1.0;
input int      Trail_FixedPips   = 15;
input double   Trail_ParabolicStep = 0.02;
input double   Trail_ParabolicMax = 0.2;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 12: AKILLI KISMİ KAPAMA
//====================================================================
input group "═══════ 12. AKILLI KISMİ KAPAMA ═══════"
input bool     UseSmartPartial   = true;
input double   Partial1_TriggerPct = 30.0;         // OPTİMİZE: 40→30 (Erken kâr al)
input double   Partial1_ClosePct = 40.0;           // OPTİMİZE: 30→40 (Daha fazla kâr al)
input double   Partial2_TriggerPct = 60.0;         // OPTİMİZE: 70→60
input double   Partial2_ClosePct = 30.0;           // 2. Kapama %
input bool     PartialMoveSLtoBE = true;           // Kısmi sonrası SL'yi BE'ye taşı

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 13: RİSK YÖNETİMİ
//====================================================================
input group "═══════ 13. RİSK YÖNETİMİ ═══════"
input ENUM_RISK_MODE RiskMode    = RISK_PERCENT;
input double   RiskPercent       = 1.0;
input double   MaxLotSize        = 2.0;
input double   MinLotSize        = 0.01;
input double   FixedLot          = 0.01;
input double   MaxDailyDDPct     = 5.0;
input double   MaxDailyDDMoney   = 100.0;
input double   MaxWeeklyDDPct    = 10.0;
input int      MaxDailyTrades    = 20;             // DENGELİ: 10→20 (Daha fazla fırsat)
input int      MaxOpenPositions  = 3;              // DENGELİ: 2→3
input double   MinMarginLevel    = 150.0;
input bool     UseCompounding    = false;          // Bileşik Büyüme
input double   CompoundRatio     = 0.5;            // Bileşik Oranı

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 14: GRİD SİSTEMİ
//====================================================================
input group "═══════ 14. GRİD SİSTEMİ ═══════"
input bool     UseGrid           = false;
input int      Grid_MaxLevels    = 5;
input double   Grid_StepPips     = 20;
input double   Grid_LotMultiplier = 1.5;
input double   Grid_TakeProfitPips = 50;
input bool     Grid_HedgeMode    = false;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 15: FİLTRE AĞIRLIKLARI
//====================================================================
input group "═══════ 15. AI FİLTRE AĞIRLIKLARI ═══════"
input double   Weight_MACross    = 20.0;           // MA Cross Ağırlığı
input double   Weight_MACD       = 12.0;           // MACD Ağırlığı
input double   Weight_RSI        = 12.0;           // RSI Ağırlığı
input double   Weight_ADX        = 10.0;           // ADX Ağırlığı
input double   Weight_Stoch      = 8.0;            // Stochastic Ağırlığı
input double   Weight_CCI        = 8.0;            // CCI Ağırlığı
input double   Weight_Pattern    = 12.0;           // Mum Pattern Ağırlığı
input double   Weight_Wick       = 5.0;            // Fitil Analizi Ağırlığı
input double   Weight_Level      = 8.0;            // S/R & Fib Ağırlığı
input double   Weight_Divergence = 5.0;            // Diverjans Ağırlığı

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 16: ZAMAN & SESSION
//====================================================================
input group "═══════ 16. ZAMAN & SESSION ═══════"
input bool     UseTimeFilter     = false;
input int      StartHour         = 8;
input int      EndHour           = 20;
input bool     UseSessionFilter  = true;
input bool     TradeAsia         = false;
input bool     TradeLondon       = true;
input bool     TradeNewYork      = true;
input bool     TradeOverlap      = true;           // London/NY Overlap
input bool     AvoidFridayClose  = true;
input int      FridayCloseHour   = 20;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 16.5: HABER FİLTRESİ
//====================================================================
input group "═══════ 16.5 HABER FİLTRESİ ═══════"
input bool     UseNewsFilter     = false;           // Haber Filtresi Kullan
input int      NewsImpactLevel   = 2;               // Min Impact (1=Low,2=Med,3=High)
input int      NewsMinutesBefore = 30;              // Haberden Önce (dk)
input int      NewsMinutesAfter  = 15;              // Haberden Sonra (dk)

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 16.6: HEDGE KORUMA
//====================================================================
input group "═══════ 16.6 HEDGE KORUMA ═══════"
input bool     UseHedge          = false;           // Hedge Kullan
input double   Hedge_TriggerPct  = 50.0;            // Tetikleme (SL % kaybı)
input double   Hedge_LotPercent  = 50.0;            // Hedge Lot (Ana pozisyon %)
input double   Hedge_TPPips      = 20.0;            // Hedge TP (pip)

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 17: SPREAD & SLİPPAGE
//====================================================================
input group "═══════ 17. SPREAD & SLİPPAGE ═══════"
input int      MaxSpreadPips     = 5;
input int      MaxSlippage       = 20;             // Max Kayma (point)
input int      CooldownBars      = 3;              // DENGELİ: 5→3 (Daha fazla fırsat)
input bool     UseStressTest     = false;
input int      SimulatedSlippage = 10;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 18: MANUEL İŞLEM
//====================================================================
input group "═══════ 18. MANUEL İŞLEM YÖNETİMİ ═══════"
input bool     ManageManualTrades = true;         // Manuel İşlemleri Yönet
input bool     ManageAllSymbols   = true;         // TÜM Sembolleri Yönet
input bool     AddSLTPToManual   = true;          // Manuel İşleme SL/TP Ekle
input bool     ApplyBEToManual   = true;          // Manuel İşleme BE Uygula
input bool     ApplyTrailToManual = true;         // Manuel İşleme Trail Uygula
input bool     ApplyPartialToManual = true;       // Manuel İşleme Kısmi Kapama Uygula
input bool     EvaluateManualBySignal = true;     // Sinyal ile Değerlendir
input bool     CloseCounterTrendManual = true;    // Ters Yönlü Manuel Kapat
input int      ManualEvalDelay = 60;              // Değerlendirme Gecikmesi (saniye)
input double   ManualDefaultSL = 30;              // Varsayılan SL (pip)
input double   ManualDefaultTP = 60;              // Varsayılan TP (pip)

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 19: PANEL & DEBUG
//====================================================================
input group "═══════ 19. PANEL & DEBUG ═══════"
input bool     ShowDashboard     = true;
input bool     ShowDetailedPanel = true;
input bool     ShowDebugLog      = true;
input int      DebugLogInterval  = 30;
input bool     SaveTradeLog      = true;
input bool     PlaySoundOnTrade  = true;
input string   SoundFile         = "alert.wav";
input bool     UsePushNotify     = false;  // Push Bildirimi
input bool     UseSendEmail      = false;  // Email Bildirimi

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 20: GÖRSEL
//====================================================================
input group "═══════ 20. GÖRSEL AYARLAR ═══════"
input color    PanelBgColor      = clrDarkSlateGray;
input color    PanelTextColor    = clrWhite;
input color    BuyColor          = clrLime;
input color    SellColor         = clrRed;
input color    NeutralColor      = clrGray;
input int      PanelX            = 10;
input int      PanelY            = 50;

//====================================================================
// GLOBAL KONTROL DEĞİŞKENLERİ
//====================================================================
bool g_ManualPause = false;
bool g_SystemLocked = false;
string g_LockReason = "";
string g_LastSignalReason = "";
int g_LastSignalScore = 0;
int g_LastHarmonyScore = 0;
string g_LastHarmonyDetails = "";
datetime g_LastTradeTime = 0;
int g_DailyTradeCount = 0;
double g_DailyPL = 0;
double g_WeeklyPL = 0;

// v14.3: Performans Optimizasyonu
bool g_IsTester = false;            // Test modunda mı?
bool g_VerboseLog = true;           // Detaylı log (test'te false)
datetime g_LastBarTime = 0;         // Yeni bar kontrolü
int g_MinSecondsBetweenTrades = 60; // Minimum saniye aralığı (overtrading önleme)

//====================================================================
// CLASS: PRICE ENGINE (Matematiksel Çekirdek)
//====================================================================
class CPriceEngine
{
public:
   static double PipToPoints(double pips) {
      return pips * 10.0 * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   }
   
   static double PointsToPip(double points) {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if(point == 0) return 0;
      return points / (10.0 * point);
   }
   
   static bool CheckStopLevel(double entry, double sl, double tp, int direction) {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      long stopLevelPts = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
      double stopLevel = (double)stopLevelPts * point;
      if(stopLevel == 0) stopLevel = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * point;
      double safeDist = 10 * point;
      if(direction == 1) return (sl < entry - safeDist) && (tp > entry + safeDist) && (entry - sl >= stopLevel) && (tp - entry >= stopLevel);
      else if(direction == -1) return (sl > entry + safeDist) && (tp < entry - safeDist) && (sl - entry >= stopLevel) && (entry - tp >= stopLevel);
      return false;
   }
   
   static void GetDynamicSLTP(double atr, double &slDist, double &tpDist) {
      if(UseATR && atr > 0) {
         slDist = atr * ATR_SL_Multi;
         tpDist = atr * ATR_TP_Multi;
         double minSL = PipToPoints(MinSL_Pips);
         double maxSL = PipToPoints(MaxSL_Pips);
         slDist = MathMax(minSL, MathMin(slDist, maxSL));
         if(tpDist < slDist * 2.0) tpDist = slDist * 2.0;
      } else {
         slDist = PipToPoints(15);
         tpDist = PipToPoints(30);
      }
   }
   
   static double CalculateLot(double slPips, double winRate = 0) {
      double lot = 0;
      switch(RiskMode) {
         case RISK_FIXED_LOT:
            lot = FixedLot;
            break;
         case RISK_PERCENT:
            lot = CalculatePercentLot(slPips);
            break;
         case RISK_KELLY:
            lot = CalculateKellyLot(slPips, winRate);
            break;
         case RISK_OPTIMAL_F:
            lot = CalculateOptimalFLot(slPips);
            break;
         default:
            lot = FixedLot;
      }
      return NormalizeLot(lot);
   }
   
   static double CalculatePercentLot(double slPips) {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * RiskPercent / 100.0;
      if(UseCompounding) riskAmount *= (1.0 + g_DailyPL / balance * CompoundRatio);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if(tickValue <= 0) tickValue = 10.0;
      if(tickSize <= 0) tickSize = point;
      double pipValue = tickValue * (point / tickSize) * 10.0;
      if(pipValue <= 0 || slPips <= 0) return MinLotSize;
      return riskAmount / (slPips * pipValue);
   }
   
   static double CalculateKellyLot(double slPips, double winRate) {
      if(winRate <= 0 || winRate >= 1) winRate = 0.5;
      double rrRatio = ATR_TP_Multi / ATR_SL_Multi;
      double kelly = (winRate * rrRatio - (1 - winRate)) / rrRatio;
      kelly = MathMax(0, MathMin(kelly, 0.25)); // Max 25% Kelly
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * kelly;
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if(tickValue <= 0) tickValue = 10.0;
      if(tickSize <= 0) tickSize = point;
      double pipValue = tickValue * (point / tickSize) * 10.0;
      if(pipValue <= 0 || slPips <= 0) return MinLotSize;
      return riskAmount / (slPips * pipValue);
   }
   
   static double CalculateOptimalFLot(double slPips) {
      // Optimal F = simplified Kelly with fixed ratio
      return CalculatePercentLot(slPips) * 0.75;
   }
   
   static double NormalizeLot(double lot) {
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      if(minLot <= 0) minLot = 0.01;
      if(stepLot <= 0) stepLot = 0.01;
      lot = MathFloor(lot / stepLot) * stepLot;
      lot = MathMax(minLot, MathMin(lot, MathMin(maxLot, MaxLotSize)));
      lot = MathMax(MinLotSize, lot);
      // Margin kontrolü
      double margin = 0, price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, margin)) {
         int maxIterations = 20;  // SONSUZ DÖNGÜ KORUMASI
         int iteration = 0;
         while(margin > freeMargin * 0.5 && lot > minLot && iteration < maxIterations) {
            lot = MathFloor((lot * 0.5) / stepLot) * stepLot;
            lot = MathMax(lot, minLot);
            if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, margin)) break;
            iteration++;
         }
      }
      return lot;
   }
   
   static double CalculateLRSlope(int period) {
      if(!UseLR) return 999;
      double Sx = 0, Sy = 0, Sxy = 0, Sxx = 0;
      for(int i = 0; i < period; i++) {
         double x = (double)i;
         double y = iClose(_Symbol, TF, i);
         Sx += x; Sy += y; Sxy += x * y; Sxx += x * x;
      }
      double denom = (double)period * Sxx - Sx * Sx;
      if(denom == 0) return 0;
      return ((double)period * Sxy - Sx * Sy) / denom;
   }
   
   static double GetTrendStrength(int bars) {
      if(!UseTrendStrength) return 50;
      double close0 = iClose(_Symbol, TF, 0);
      double closeN = iClose(_Symbol, TF, bars);
      double highest = 0, lowest = 999999;
      for(int i = 0; i <= bars; i++) {
         double h = iHigh(_Symbol, TF, i);
         double l = iLow(_Symbol, TF, i);
         if(h > highest) highest = h;
         if(l < lowest) lowest = l;
      }
      double range = highest - lowest;
      if(range == 0) return 50;
      double trend = (close0 - closeN) / range * 100;
      return MathMax(-100, MathMin(100, trend));
   }
};

//====================================================================
// CLASS: CANDLE ANALYZER (15+ Pattern Tanıma)
//====================================================================
class CCandleAnalyzer
{
public:
   static void GetCandleComponents(int shift, double &bodySize, double &upperWick, double &lowerWick, double &range, bool &isBullish) {
      double open = iOpen(_Symbol, TF, shift);
      double close = iClose(_Symbol, TF, shift);
      double high = iHigh(_Symbol, TF, shift);
      double low = iLow(_Symbol, TF, shift);
      isBullish = (close > open);
      bodySize = MathAbs(close - open);
      range = high - low;
      if(isBullish) { upperWick = high - close; lowerWick = open - low; }
      else { upperWick = high - open; lowerWick = close - low; }
   }
   
   static double GetWickRatio(int shift, bool isUpper) {
      double bodySize, upperWick, lowerWick, range; bool isBullish;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      if(range == 0) return 0;
      return isUpper ? upperWick / range : lowerWick / range;
   }
   
   static double GetBodyRatio(int shift) {
      double bodySize, upperWick, lowerWick, range; bool isBullish;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      if(range == 0) return 0;
      return bodySize / range;
   }
   
   static bool IsPinBar(int shift, bool &isBullish) {
      double bodySize, upperWick, lowerWick, range;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      if(range == 0) return false;
      if(bodySize / range > MaxBodyRatio) return false;
      if(lowerWick > upperWick * 2 && lowerWick / range >= MinWickRatio) { isBullish = true; return true; }
      if(upperWick > lowerWick * 2 && upperWick / range >= MinWickRatio) { isBullish = false; return true; }
      return false;
   }
   
   static bool IsEngulfing(int shift, bool &isBullish) {
      double o1 = iOpen(_Symbol, TF, shift), c1 = iClose(_Symbol, TF, shift);
      double o2 = iOpen(_Symbol, TF, shift + 1), c2 = iClose(_Symbol, TF, shift + 1);
      double body1 = MathAbs(c1 - o1), body2 = MathAbs(c2 - o2);
      if(body1 <= body2) return false;
      if(c2 < o2 && c1 > o1 && c1 > o2 && o1 < c2) { isBullish = true; return true; }
      if(c2 > o2 && c1 < o1 && o1 > c2 && c1 < o2) { isBullish = false; return true; }
      return false;
   }
   
   static bool IsDoji(int shift) { return (GetBodyRatio(shift) < 0.1); }
   
   static bool IsHammer(int shift, bool &isBullish) {
      double bodySize, upperWick, lowerWick, range;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      if(range == 0 || bodySize / range > 0.3) return false;
      return (lowerWick >= bodySize * 2 && upperWick <= bodySize * 0.5);
   }
   
   static bool IsShootingStar(int shift, bool &isBullish) {
      double bodySize, upperWick, lowerWick, range;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      if(range == 0 || bodySize / range > 0.3) return false;
      return (upperWick >= bodySize * 2 && lowerWick <= bodySize * 0.5);
   }
   
   static bool IsThreeWhiteSoldiers() {
      for(int i = 1; i <= 3; i++) {
         double o = iOpen(_Symbol, TF, i), c = iClose(_Symbol, TF, i);
         if(c <= o) return false;
         if(i > 1 && o < iClose(_Symbol, TF, i+1)) return false;
      }
      return true;
   }
   
   static bool IsThreeBlackCrows() {
      for(int i = 1; i <= 3; i++) {
         double o = iOpen(_Symbol, TF, i), c = iClose(_Symbol, TF, i);
         if(c >= o) return false;
         if(i > 1 && o > iClose(_Symbol, TF, i+1)) return false;
      }
      return true;
   }
   
   static bool IsMorningStar() {
      double o1 = iOpen(_Symbol, TF, 3), c1 = iClose(_Symbol, TF, 3);
      double o2 = iOpen(_Symbol, TF, 2), c2 = iClose(_Symbol, TF, 2);
      double o3 = iOpen(_Symbol, TF, 1), c3 = iClose(_Symbol, TF, 1);
      return (c1 < o1) && (MathAbs(c2 - o2) < MathAbs(c1 - o1) * 0.3) && (c3 > o3) && (c3 > (o1 + c1) / 2);
   }
   
   static bool IsEveningStar() {
      double o1 = iOpen(_Symbol, TF, 3), c1 = iClose(_Symbol, TF, 3);
      double o2 = iOpen(_Symbol, TF, 2), c2 = iClose(_Symbol, TF, 2);
      double o3 = iOpen(_Symbol, TF, 1), c3 = iClose(_Symbol, TF, 1);
      return (c1 > o1) && (MathAbs(c2 - o2) < MathAbs(c1 - o1) * 0.3) && (c3 < o3) && (c3 < (o1 + c1) / 2);
   }
   
   static bool IsBullishHarami() {
      double o1 = iOpen(_Symbol, TF, 2), c1 = iClose(_Symbol, TF, 2);
      double o2 = iOpen(_Symbol, TF, 1), c2 = iClose(_Symbol, TF, 1);
      return (c1 < o1) && (c2 > o2) && (c2 < o1) && (o2 > c1);
   }
   
   static bool IsBearishHarami() {
      double o1 = iOpen(_Symbol, TF, 2), c1 = iClose(_Symbol, TF, 2);
      double o2 = iOpen(_Symbol, TF, 1), c2 = iClose(_Symbol, TF, 1);
      return (c1 > o1) && (c2 < o2) && (o2 < c1) && (c2 > o1);
   }
   
   static bool IsTweezerTop() {
      double h1 = iHigh(_Symbol, TF, 1), h2 = iHigh(_Symbol, TF, 2);
      double o1 = iOpen(_Symbol, TF, 1), c1 = iClose(_Symbol, TF, 1);
      double o2 = iOpen(_Symbol, TF, 2), c2 = iClose(_Symbol, TF, 2);
      double tolerance = CPriceEngine::PipToPoints(2);
      return (MathAbs(h1 - h2) < tolerance) && (c2 > o2) && (c1 < o1);
   }
   
   static bool IsTweezerBottom() {
      double l1 = iLow(_Symbol, TF, 1), l2 = iLow(_Symbol, TF, 2);
      double o1 = iOpen(_Symbol, TF, 1), c1 = iClose(_Symbol, TF, 1);
      double o2 = iOpen(_Symbol, TF, 2), c2 = iClose(_Symbol, TF, 2);
      double tolerance = CPriceEngine::PipToPoints(2);
      return (MathAbs(l1 - l2) < tolerance) && (c2 < o2) && (c1 > o1);
   }
   
   static ENUM_CANDLE_PATTERN DetectPattern(int shift = 1) {
      bool isBullish;
      if(UseAdvancedPatterns) {
         if(IsThreeWhiteSoldiers()) return PATTERN_THREE_WHITE_SOLDIERS;
         if(IsThreeBlackCrows()) return PATTERN_THREE_BLACK_CROWS;
         if(IsMorningStar()) return PATTERN_MORNING_STAR;
         if(IsEveningStar()) return PATTERN_EVENING_STAR;
         if(IsBullishHarami()) return PATTERN_BULLISH_HARAMI;
         if(IsBearishHarami()) return PATTERN_BEARISH_HARAMI;
         if(IsTweezerTop()) return PATTERN_TWEEZER_TOP;
         if(IsTweezerBottom()) return PATTERN_TWEEZER_BOTTOM;
      }
      if(IsPinBar(shift, isBullish)) return isBullish ? PATTERN_BULLISH_PINBAR : PATTERN_BEARISH_PINBAR;
      if(IsEngulfing(shift, isBullish)) return isBullish ? PATTERN_BULLISH_ENGULFING : PATTERN_BEARISH_ENGULFING;
      if(IsHammer(shift, isBullish)) return PATTERN_HAMMER;
      if(IsShootingStar(shift, isBullish)) return PATTERN_SHOOTING_STAR;
      if(IsDoji(shift)) return PATTERN_DOJI;
      return PATTERN_NONE;
   }
   
   static int GetPatternDirection(ENUM_CANDLE_PATTERN pattern) {
      switch(pattern) {
         case PATTERN_BULLISH_PINBAR: case PATTERN_BULLISH_ENGULFING: case PATTERN_HAMMER:
         case PATTERN_MORNING_STAR: case PATTERN_THREE_WHITE_SOLDIERS: case PATTERN_BULLISH_HARAMI:
         case PATTERN_TWEEZER_BOTTOM: return 1;
         case PATTERN_BEARISH_PINBAR: case PATTERN_BEARISH_ENGULFING: case PATTERN_SHOOTING_STAR:
         case PATTERN_EVENING_STAR: case PATTERN_THREE_BLACK_CROWS: case PATTERN_BEARISH_HARAMI:
         case PATTERN_TWEEZER_TOP: return -1;
         default: return 0;
      }
   }
   
   static int GetPatternScore(ENUM_CANDLE_PATTERN pattern) {
      switch(pattern) {
         case PATTERN_THREE_WHITE_SOLDIERS: case PATTERN_THREE_BLACK_CROWS: return 100;
         case PATTERN_BULLISH_ENGULFING: case PATTERN_BEARISH_ENGULFING: return 95;
         case PATTERN_MORNING_STAR: case PATTERN_EVENING_STAR: return 90;
         case PATTERN_BULLISH_PINBAR: case PATTERN_BEARISH_PINBAR: return 85;
         case PATTERN_HAMMER: case PATTERN_SHOOTING_STAR: return 80;
         case PATTERN_BULLISH_HARAMI: case PATTERN_BEARISH_HARAMI: return 75;
         case PATTERN_TWEEZER_TOP: case PATTERN_TWEEZER_BOTTOM: return 70;
         case PATTERN_DOJI: return 50;
         default: return 0;
      }
   }
   
   static string GetPatternName(ENUM_CANDLE_PATTERN pattern) {
      switch(pattern) {
         case PATTERN_BULLISH_PINBAR: return "Bull Pin";
         case PATTERN_BEARISH_PINBAR: return "Bear Pin";
         case PATTERN_BULLISH_ENGULFING: return "Bull Engulf";
         case PATTERN_BEARISH_ENGULFING: return "Bear Engulf";
         case PATTERN_DOJI: return "Doji";
         case PATTERN_HAMMER: return "Hammer";
         case PATTERN_SHOOTING_STAR: return "Shoot Star";
         case PATTERN_MORNING_STAR: return "Morning*";
         case PATTERN_EVENING_STAR: return "Evening*";
         case PATTERN_THREE_WHITE_SOLDIERS: return "3 Soldiers";
         case PATTERN_THREE_BLACK_CROWS: return "3 Crows";
         case PATTERN_BULLISH_HARAMI: return "Bull Harami";
         case PATTERN_BEARISH_HARAMI: return "Bear Harami";
         case PATTERN_TWEEZER_TOP: return "Tweezer Top";
         case PATTERN_TWEEZER_BOTTOM: return "Tweezer Bot";
         default: return "None";
   }
}
};

//====================================================================
// CLASS: ADVANCED LEVELS (Fibonacci + Pivot + S/R)
//====================================================================
class CAdvancedLevels
{
public:
   double m_pivot, m_r1, m_r2, m_r3, m_s1, m_s2, m_s3;
   double m_fib236, m_fib382, m_fib500, m_fib618, m_fib786;
   double m_support, m_resistance;
   double m_cam_r1, m_cam_r2, m_cam_r3, m_cam_r4;
   double m_cam_s1, m_cam_s2, m_cam_s3, m_cam_s4;
   datetime m_lastUpdate;
   
   CAdvancedLevels() : m_lastUpdate(0) {}
   
   void CalculatePivots() {
      double high = iHigh(_Symbol, PERIOD_D1, 1);
      double low = iLow(_Symbol, PERIOD_D1, 1);
      double close = iClose(_Symbol, PERIOD_D1, 1);
      double range = high - low;
      
      // Classic Pivot
      m_pivot = (high + low + close) / 3.0;
      m_r1 = 2 * m_pivot - low; m_s1 = 2 * m_pivot - high;
      m_r2 = m_pivot + range; m_s2 = m_pivot - range;
      m_r3 = high + 2 * (m_pivot - low); m_s3 = low - 2 * (high - m_pivot);
      
      // Camarilla Pivot
      m_cam_r1 = close + range * 1.1 / 12; m_cam_s1 = close - range * 1.1 / 12;
      m_cam_r2 = close + range * 1.1 / 6; m_cam_s2 = close - range * 1.1 / 6;
      m_cam_r3 = close + range * 1.1 / 4; m_cam_s3 = close - range * 1.1 / 4;
      m_cam_r4 = close + range * 1.1 / 2; m_cam_s4 = close - range * 1.1 / 2;
   }
   
   void CalculateFibonacci(int lookback) {
      double highest = 0, lowest = 999999;
      for(int i = 1; i <= lookback; i++) {
         double h = iHigh(_Symbol, TF, i), l = iLow(_Symbol, TF, i);
         if(h > highest) highest = h; if(l < lowest) lowest = l;
      }
      double range = highest - lowest;
      m_fib236 = highest - range * 0.236; m_fib382 = highest - range * 0.382;
      m_fib500 = highest - range * 0.500; m_fib618 = highest - range * 0.618;
      m_fib786 = highest - range * 0.786;
      m_resistance = highest; m_support = lowest;
   }
   
   void CalculateDynamicSR(int lookback) {
      double resistances[], supports[];
      ArrayResize(resistances, 0); ArrayResize(supports, 0);
      for(int i = 2; i < lookback - 2; i++) {
         double h = iHigh(_Symbol, TF, i), l = iLow(_Symbol, TF, i);
         bool isSwingHigh = (h > iHigh(_Symbol, TF, i-1)) && (h > iHigh(_Symbol, TF, i-2)) && (h > iHigh(_Symbol, TF, i+1)) && (h > iHigh(_Symbol, TF, i+2));
         bool isSwingLow = (l < iLow(_Symbol, TF, i-1)) && (l < iLow(_Symbol, TF, i-2)) && (l < iLow(_Symbol, TF, i+1)) && (l < iLow(_Symbol, TF, i+2));
         if(isSwingHigh) { ArrayResize(resistances, ArraySize(resistances) + 1); resistances[ArraySize(resistances)-1] = h; }
         if(isSwingLow) { ArrayResize(supports, ArraySize(supports) + 1); supports[ArraySize(supports)-1] = l; }
      }
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double nearestRes = 999999, nearestSup = 0;
      for(int i = 0; i < ArraySize(resistances); i++) if(resistances[i] > price && resistances[i] < nearestRes) nearestRes = resistances[i];
      for(int i = 0; i < ArraySize(supports); i++) if(supports[i] < price && supports[i] > nearestSup) nearestSup = supports[i];
      if(nearestRes < 999999) m_resistance = nearestRes;
      if(nearestSup > 0) m_support = nearestSup;
   }
   
   void Update() {
      MqlDateTime dt; TimeCurrent(dt);
      datetime today = StringToTime(IntegerToString(dt.year) + "." + IntegerToString(dt.mon) + "." + IntegerToString(dt.day));
      if(m_lastUpdate != today) {
         if(UsePivots) CalculatePivots();
         if(UseFibonacci) CalculateFibonacci(FibLookback);
         if(UseSupportResistance) CalculateDynamicSR(SR_Lookback);
         m_lastUpdate = today;
      }
   }
   
   int GetLevelScore(int direction) {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      int score = 50;
      double zone = CPriceEngine::PipToPoints(SR_TouchZone);
      
      if(direction == 1) {
         if(MathAbs(price - m_s1) < zone) score += 20;
         else if(MathAbs(price - m_support) < zone) score += 30;
         if(MathAbs(price - m_fib618) < zone) score += 25;
         else if(MathAbs(price - m_fib382) < zone) score += 15;
         if(price > m_r1) score -= 15;
         if(price > m_resistance - zone) score -= 25;
      } else if(direction == -1) {
         if(MathAbs(price - m_r1) < zone) score += 20;
         else if(MathAbs(price - m_resistance) < zone) score += 30;
         if(MathAbs(price - m_fib382) < zone) score += 25;
         else if(MathAbs(price - m_fib618) < zone) score += 15;
         if(price < m_s1) score -= 15;
         if(price < m_support + zone) score -= 25;
      }
      return MathMax(0, MathMin(100, score));
   }
};

//====================================================================
// CLASS: AI SIGNAL SCORER (10-Faktör Oylama)
//====================================================================
class CAISignalScorer
{
private:
   int m_hMA1, m_hMA2, m_hMA3, m_hMA4;
   int m_hMACD, m_hRSI, m_hADX, m_hATR, m_hStoch, m_hCCI, m_hBB;
   datetime m_lastBarTime;
   bool m_signalGivenThisBar;
   int m_barsSinceTrade;
   
   double m_scores[10];
   string m_signalReasons;

public:
   double m_lastATR;
   int m_lastDirection;
   int m_lastTotalScore;
   
   CAISignalScorer() : m_lastATR(0), m_lastDirection(0), m_lastTotalScore(0), m_lastBarTime(0), m_signalGivenThisBar(false), m_barsSinceTrade(999) {
      for(int i = 0; i < 10; i++) m_scores[i] = 50;
   }
   
   ~CAISignalScorer() { ReleaseHandles(); }
   
   void ReleaseHandles() {
      if(m_hMA1 != INVALID_HANDLE) IndicatorRelease(m_hMA1);
      if(m_hMA2 != INVALID_HANDLE) IndicatorRelease(m_hMA2);
      if(m_hMA3 != INVALID_HANDLE) IndicatorRelease(m_hMA3);
      if(m_hMA4 != INVALID_HANDLE) IndicatorRelease(m_hMA4);
      if(m_hMACD != INVALID_HANDLE) IndicatorRelease(m_hMACD);
      if(m_hRSI != INVALID_HANDLE) IndicatorRelease(m_hRSI);
      if(m_hADX != INVALID_HANDLE) IndicatorRelease(m_hADX);
      if(m_hATR != INVALID_HANDLE) IndicatorRelease(m_hATR);
      if(m_hStoch != INVALID_HANDLE) IndicatorRelease(m_hStoch);
      if(m_hCCI != INVALID_HANDLE) IndicatorRelease(m_hCCI);
      if(m_hBB != INVALID_HANDLE) IndicatorRelease(m_hBB);
   }

   bool Init() {
      ReleaseHandles();
      m_hMA1 = iMA(_Symbol, TF, MA1_Period, 0, MA_Method, PRICE_CLOSE);
      m_hMA2 = iMA(_Symbol, TF, MA2_Period, 0, MA_Method, PRICE_CLOSE);
      m_hMA3 = iMA(_Symbol, TF, MA3_Period, 0, MA_Method, PRICE_CLOSE);
      m_hMA4 = iMA(_Symbol, TF, MA4_Period, 0, MA_Method, PRICE_CLOSE);
      m_hMACD = iMACD(_Symbol, TF, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE);
      m_hRSI = iRSI(_Symbol, TF, RSI_Period, PRICE_CLOSE);
      m_hADX = iADX(_Symbol, TF, ADX_Period);
      m_hATR = iATR(_Symbol, TF, ATR_Period);
      m_hStoch = iStochastic(_Symbol, TF, Stoch_K, Stoch_D, Stoch_Slowing, MODE_SMA, STO_LOWHIGH);
      m_hCCI = iCCI(_Symbol, TF, CCI_Period, PRICE_TYPICAL);
      m_hBB = iBands(_Symbol, TF, BB_Period, 0, BB_Deviation, PRICE_CLOSE);
      return (m_hMA1 != INVALID_HANDLE && m_hMA2 != INVALID_HANDLE && m_hMACD != INVALID_HANDLE);
   }
   
   void UpdateATR() { double atr[]; ArraySetAsSeries(atr, true); if(CopyBuffer(m_hATR, 0, 0, 1, atr) >= 1) m_lastATR = atr[0]; }
   void UpdateBarState() {
      datetime currentBar = iTime(_Symbol, TF, 0);
      if(m_lastBarTime != currentBar) { m_lastBarTime = currentBar; m_barsSinceTrade++; m_signalGivenThisBar = false; }
   }
   bool CanTrade() { return (m_barsSinceTrade >= CooldownBars && !m_signalGivenThisBar); }
   void OnTradeOpened() { m_barsSinceTrade = 0; m_signalGivenThisBar = true; }
   
   double ScoreMACross(int &direction) {
      double ma1[], ma2[], ma3[], ma4[];
      ArraySetAsSeries(ma1, true); ArraySetAsSeries(ma2, true); ArraySetAsSeries(ma3, true); ArraySetAsSeries(ma4, true);
      if(CopyBuffer(m_hMA1, 0, 0, 3, ma1) < 3) return 0;
      if(CopyBuffer(m_hMA2, 0, 0, 3, ma2) < 3) return 0;
      if(CopyBuffer(m_hMA3, 0, 0, 3, ma3) < 3) return 0;
      
      double score = 0;
      bool crossUp = (ma1[2] <= ma2[2] && ma1[1] > ma2[1]);
      bool crossDown = (ma1[2] >= ma2[2] && ma1[1] < ma2[1]);
      bool aboveMA3 = (ma1[0] > ma3[0] && ma2[0] > ma3[0]);
      bool belowMA3 = (ma1[0] < ma3[0] && ma2[0] < ma3[0]);
      double spread = MathAbs(ma1[0] - ma2[0]) / ma3[0] * 10000;
      
      // CROSS sinyalleri öncelikli - gerçek kesişim
      if(crossUp) {
         direction = 1; score = 75;  // Cross = güçlü sinyal
         if(aboveMA3) score += 15;
         score = MathMin(100, score + spread * 2);
         if(RequireMA4Confirm && CopyBuffer(m_hMA4, 0, 0, 1, ma4) >= 1 && ma1[0] < ma4[0]) score -= 20;
      } 
      else if(crossDown) {
         direction = -1; score = 75;  // Cross = güçlü sinyal
         if(belowMA3) score += 15;
         score = MathMin(100, score + spread * 2);
         if(RequireMA4Confirm && CopyBuffer(m_hMA4, 0, 0, 1, ma4) >= 1 && ma1[0] > ma4[0]) score -= 20;
      }
      // Trend devam sinyalleri - sadece cross yoksa
      else if(ma1[0] > ma2[0] && aboveMA3) {
         direction = 1; score = 50;  // Trend devam = daha zayıf sinyal
         score = MathMin(80, score + spread);
      }
      else if(ma1[0] < ma2[0] && belowMA3) {
         direction = -1; score = 50;  // Trend devam = daha zayıf sinyal
         score = MathMin(80, score + spread);
      }
      
      return score;
   }
   
   double ScoreMACD(int direction) {
      if(!UseMACD) return 50;
      double main[], sig[], hist[];
      ArraySetAsSeries(main, true); ArraySetAsSeries(sig, true); ArraySetAsSeries(hist, true);
      if(CopyBuffer(m_hMACD, 0, 0, 2, main) < 2) return 50;
      if(CopyBuffer(m_hMACD, 1, 0, 2, sig) < 2) return 50;
      if(CopyBuffer(m_hMACD, 2, 0, 2, hist) < 2) return 50;
      double score = 50;
      bool histPos = (hist[0] > 0), histRise = (hist[0] > hist[1]);
      if(direction == 1) { if(histPos) score += 20; if(histRise) score += 15; }
      else if(direction == -1) { if(!histPos) score += 20; if(!histRise) score += 15; }
      return MathMin(100, score);
   }
   
   double ScoreRSI(int direction) {
      if(!UseRSI) return 50;
      double rsi[]; ArraySetAsSeries(rsi, true);
      if(CopyBuffer(m_hRSI, 0, 0, 1, rsi) < 1) return 50;
      double score = 50, val = rsi[0];
      if(direction == 1) { if(val < 30) score = 95; else if(val < 40) score = 75; else if(val > 70) score = 25; }
      else if(direction == -1) { if(val > 70) score = 95; else if(val > 60) score = 75; else if(val < 30) score = 25; }
      return score;
   }
   
   double ScoreADX() {
      if(!UseADX) return 50;
      double adx[]; ArraySetAsSeries(adx, true);
      if(CopyBuffer(m_hADX, 0, 0, 1, adx) < 1) return 50;
      if(adx[0] >= 40) return 100; if(adx[0] >= 30) return 85; if(adx[0] >= 25) return 70; if(adx[0] >= 20) return 55;
      return 35;
   }
   
   double ScoreStochastic(int direction) {
      if(!UseStochastic) return 50;
      double k[], d[]; ArraySetAsSeries(k, true); ArraySetAsSeries(d, true);
      if(CopyBuffer(m_hStoch, 0, 0, 2, k) < 2) return 50;
      if(CopyBuffer(m_hStoch, 1, 0, 2, d) < 2) return 50;
      double score = 50;
      bool crossUp = (k[1] <= d[1] && k[0] > d[0]); bool crossDown = (k[1] >= d[1] && k[0] < d[0]);
      if(direction == 1) { if(k[0] < 20) score = 90; else if(k[0] < 40) score = 70; if(crossUp && k[0] < 50) score += 15; }
      else if(direction == -1) { if(k[0] > 80) score = 90; else if(k[0] > 60) score = 70; if(crossDown && k[0] > 50) score += 15; }
      return MathMin(100, score);
   }
   
   double ScoreCCI(int direction) {
      if(!UseCCI) return 50;
      double cci[]; ArraySetAsSeries(cci, true);
      if(CopyBuffer(m_hCCI, 0, 0, 1, cci) < 1) return 50;
      double score = 50, val = cci[0];
      if(direction == 1) { if(val < -CCI_Level) score = 90; else if(val < 0) score = 65; else if(val > CCI_Level) score = 30; }
      else if(direction == -1) { if(val > CCI_Level) score = 90; else if(val > 0) score = 65; else if(val < -CCI_Level) score = 30; }
      return score;
   }
   
   double ScorePattern(int direction) {
      if(!UseCandlePatterns) return 50;
      ENUM_CANDLE_PATTERN pattern = CCandleAnalyzer::DetectPattern(1);
      int patDir = CCandleAnalyzer::GetPatternDirection(pattern);
      int patScore = CCandleAnalyzer::GetPatternScore(pattern);
      if(patDir == direction) return patScore;
      if(patDir == -direction) return 100 - patScore;
      return 50;
   }
   
   double ScoreWick(int direction) {
      if(!UseWickAnalysis) return 50;
      double upper = CCandleAnalyzer::GetWickRatio(1, true);
      double lower = CCandleAnalyzer::GetWickRatio(1, false);
      double score = 50;
      if(direction == 1) { if(lower > 0.4) score = 85; else if(lower > 0.3) score = 70; if(upper > 0.4) score -= 20; }
      else if(direction == -1) { if(upper > 0.4) score = 85; else if(upper > 0.3) score = 70; if(lower > 0.4) score -= 20; }
      return MathMax(0, MathMin(100, score));
   }
   
   int CalculateTotalScore(int &outDirection) {
      m_signalReasons = "";
      int direction = 0;
      m_scores[0] = ScoreMACross(direction); if(direction == 0) return 0;
      outDirection = direction;
      m_scores[1] = ScoreMACD(direction);
      m_scores[2] = ScoreRSI(direction);
      m_scores[3] = ScoreADX();
      m_scores[4] = ScoreStochastic(direction);
      m_scores[5] = ScoreCCI(direction);
      m_scores[6] = ScorePattern(direction);
      m_scores[7] = ScoreWick(direction);
      m_scores[8] = 50; m_scores[9] = 50; // Level & Divergence added by Harmony
      
      double weights[] = {Weight_MACross, Weight_MACD, Weight_RSI, Weight_ADX, Weight_Stoch, Weight_CCI, Weight_Pattern, Weight_Wick, Weight_Level, Weight_Divergence};
      double totalW = 0, weighted = 0;
      for(int i = 0; i < 10; i++) { totalW += weights[i]; weighted += m_scores[i] * weights[i]; }
      
      m_signalReasons = StringFormat("MA:%.0f MD:%.0f RS:%.0f ADX:%.0f ST:%.0f CCI:%.0f PAT:%.0f WK:%.0f",
         m_scores[0], m_scores[1], m_scores[2], m_scores[3], m_scores[4], m_scores[5], m_scores[6], m_scores[7]);
      
      m_lastDirection = direction;
      m_lastTotalScore = (int)(weighted / totalW);
      return m_lastTotalScore;
   }
   
   string GetSignalReasons() { return m_signalReasons; }
   
   int GetSignal() {
      int direction = 0;
      int score = CalculateTotalScore(direction);
      g_LastSignalScore = score; g_LastSignalReason = m_signalReasons;
      
      int threshold = MinSignalScore;
      if(UseAdaptiveThreshold) {
         double adx[]; ArraySetAsSeries(adx, true);
         if(CopyBuffer(m_hADX, 0, 0, 1, adx) >= 1) {
            if(adx[0] > ADX_Strong) threshold -= 10;
            else if(adx[0] < ADX_Min) threshold += 10;
         }
      }
      
      if(score >= threshold) {
         if(ShowDebugLog) {
            Print("════════════════════════════════════════════════════");
            Print("🤖 AI v13 SKOR: ", score, "/100 | Eşik: ", threshold);
            Print("   📊 ", m_signalReasons);
            Print("   ➡️ ", (direction == 1 ? "BUY" : "SELL"), " SİNYALİ");
            Print("════════════════════════════════════════════════════");
         }
         return direction;
      }
      return 0;
   }
};

//====================================================================
// CLASS: SECURITY MANAGER
//====================================================================
class CSecurityManager
{
private:
   double m_refBalance, m_weekRefBalance;
   int m_dayOfYear, m_weekOfYear;
   int m_dailyTradeCount;
public:
   CSecurityManager() : m_refBalance(0), m_weekRefBalance(0), m_dayOfYear(0), m_weekOfYear(0), m_dailyTradeCount(0) {}
   
   void Init() { UpdateReference(true); }
   
   void UpdateReference(bool forceReset = false) {
      MqlDateTime dt; TimeCurrent(dt);
      if(forceReset || dt.day_of_year != m_dayOfYear) {
         m_dayOfYear = dt.day_of_year;
         m_refBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         m_dailyTradeCount = 0;
         g_SystemLocked = false; g_LockReason = "";
      }
      if(forceReset || (dt.day_of_week == 1 && m_weekOfYear != (dt.day_of_year / 7))) {
         m_weekOfYear = dt.day_of_year / 7;
         m_weekRefBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      }
   }
   
   bool IsSafeToTrade() {
      if(g_ManualPause) { g_LockReason = "PAUSE"; return false; }
      if(g_SystemLocked) return false;
      UpdateReference();
      
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double dailyLoss = m_refBalance - equity;
      double weeklyLoss = m_weekRefBalance - equity;
      
      if(dailyLoss >= MaxDailyDDMoney || (m_refBalance > 0 && (dailyLoss/m_refBalance)*100 >= MaxDailyDDPct))
         { g_SystemLocked = true; g_LockReason = "GÜNLÜK LİMİT"; return false; }
      if(m_weekRefBalance > 0 && (weeklyLoss/m_weekRefBalance)*100 >= MaxWeeklyDDPct)
         { g_SystemLocked = true; g_LockReason = "HAFTALIK LİMİT"; return false; }
      if(m_dailyTradeCount >= MaxDailyTrades) { g_LockReason = "İŞLEM LİMİTİ"; return false; }
      
      double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
      if(marginLevel > 0 && marginLevel < MinMarginLevel) { g_LockReason = "MARJİN"; return false; }
      
      if(UseTimeFilter) {
         MqlDateTime dt; TimeCurrent(dt);
         if(dt.hour < StartHour || dt.hour >= EndHour) { g_LockReason = "ZAMAN"; return false; }
      }
      
      if(UseSessionFilter) {
         MqlDateTime dt; TimeCurrent(dt);
         int h = dt.hour;
         bool isAsia = (h >= 0 && h < 8);
         bool isLondon = (h >= 8 && h < 12);
         bool isOverlap = (h >= 12 && h < 17);
         bool isNY = (h >= 17 && h < 22);
         
         if(isAsia && !TradeAsia) { g_LockReason = "ASIA SESSİON"; return false; }
         if(isLondon && !TradeLondon) { g_LockReason = "LONDON SESSİON"; return false; }
         if(isNY && !TradeNewYork) { g_LockReason = "NY SESSİON"; return false; }
         if(isOverlap && !TradeOverlap) { g_LockReason = "OVERLAP SESSİON"; return false; }
      }
      
      if(AvoidFridayClose) {
         MqlDateTime dt; TimeCurrent(dt);
         if(dt.day_of_week == 5 && dt.hour >= FridayCloseHour) { g_LockReason = "CUMA KAPANIŞ"; return false; }
      }
      
      long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      if(spread / 10.0 > MaxSpreadPips) { g_LockReason = "SPREAD"; return false; }
      
      g_LockReason = "";
      return true;
   }
   
   void IncrementTradeCount() { m_dailyTradeCount++; }
   int GetTradeCount() { return m_dailyTradeCount; }
   double GetDailyPL() { g_DailyPL = AccountInfoDouble(ACCOUNT_EQUITY) - m_refBalance; return g_DailyPL; }
   double GetWeeklyPL() { g_WeeklyPL = AccountInfoDouble(ACCOUNT_EQUITY) - m_weekRefBalance; return g_WeeklyPL; }
};

//====================================================================
// CLASS: TRADE EXECUTOR
//====================================================================
class CTradeExecutor
{
private:
   CTrade m_trade;
public:
   void Init() {
      m_trade.SetExpertMagicNumber(MagicNumber);
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
      m_trade.SetDeviationInPoints(MaxSlippage);
   }
   
   bool OpenMarketOrder(int direction, double atr, double winRate = 0) {
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      double slDist, tpDist;
      CPriceEngine::GetDynamicSLTP(atr, slDist, tpDist);
      double slPips = CPriceEngine::PointsToPip(slDist);
      double lot = CPriceEngine::CalculateLot(slPips, winRate);
      double price = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double sl = 0, tp = 0;
      
      // BUY ve SELL için SL/TP hesapla - AYNI MANTIK
      if(direction == 1) {
         sl = NormalizeDouble(price - slDist, digits);
         tp = NormalizeDouble(price + tpDist, digits);
         m_trade.Buy(lot, _Symbol, 0, sl, tp, TradeComment);
      } else {
         sl = NormalizeDouble(price + slDist, digits);
         tp = NormalizeDouble(price - tpDist, digits);
         m_trade.Sell(lot, _Symbol, 0, sl, tp, TradeComment);
      }
      
      // Sonuç kontrolü
      uint retcode = m_trade.ResultRetcode();
      if(retcode == TRADE_RETCODE_DONE || retcode == TRADE_RETCODE_PLACED) {
         g_LastTradeTime = TimeCurrent();
         Print("🤖 ", (direction == 1 ? "BUY" : "SELL"), " | Lot:", lot, " SL:", sl, " TP:", tp);
         return true;
      }
      
      Print("❌ Hata: ", m_trade.ResultRetcodeDescription());
      return false;
   }
   
   void EmergencyCloseAll() {
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket > 0 && PositionSelectByTicket(ticket)) {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber || ManageManualTrades)
               m_trade.PositionClose(ticket);
         }
      }
   }
   
   int CountOpenPositions() {
      int count = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber && PositionGetString(POSITION_SYMBOL) == _Symbol) count++;
      }
      return count;
   }
   
   bool HasOpenPosition() { return (CountOpenPositions() > 0); }
   
   bool CanOpenMore() { 
      // Pozisyon limit kontrolü
      if(CountOpenPositions() >= MaxOpenPositions) return false;
      
      // ZAMAN BAZLI COOLDOWN - Overtrading önleme
      if(g_LastTradeTime > 0) {
         int secondsSinceLast = (int)(TimeCurrent() - g_LastTradeTime);
         if(secondsSinceLast < g_MinSecondsBetweenTrades) {
            return false;  // Minimum süre geçmedi
         }
      }
      
      return true;
   }
   
   void OnTradeOpened() {
      g_LastTradeTime = TimeCurrent();  // Son işlem zamanını güncelle
   }
   
   CTrade* GetTrade() { return &m_trade; }
};

//====================================================================
// CLASS: POSITION MANAGER (BE, Trail, Partial)
//====================================================================
class CPositionManager
{
private:
   CTrade* m_pTrade;
   int m_totalTrades, m_winTrades, m_lossTrades;
   double m_grossProfit, m_grossLoss, m_netProfit;
   double m_maxDD, m_maxProfit;
public:
   CPositionManager() : m_pTrade(NULL), m_totalTrades(0), m_winTrades(0), m_lossTrades(0),
      m_grossProfit(0), m_grossLoss(0), m_netProfit(0), m_maxDD(0), m_maxProfit(0) {}
   
   void Init(CTrade* pTrade) { m_pTrade = pTrade; }
   
   void ManagePositions(double atr) {
      if(m_pTrade == NULL) return;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         bool isEA = (PositionGetInteger(POSITION_MAGIC) == MagicNumber);
         if(!isEA && !ManageManualTrades) continue;
         
         if(!PositionSelectByTicket(ticket)) continue;
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
         double currentSL = PositionGetDouble(POSITION_SL);
         double currentTP = PositionGetDouble(POSITION_TP);
         double volume = PositionGetDouble(POSITION_VOLUME);
         long posType = PositionGetInteger(POSITION_TYPE);
         int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
         
         if(currentTP == 0) continue;
         double tpDist = MathAbs(currentTP - openPrice);
         double profitDist = (posType == POSITION_TYPE_BUY) ? (currentPrice - openPrice) : (openPrice - currentPrice);
         
         // 1. Kısmi Kapama
         if(UseSmartPartial && tpDist > 0) {
            double minVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
            double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
            
            // 1. Partial
            if(profitDist >= tpDist * (Partial1_TriggerPct / 100.0) && volume > minVol * 2) {
               bool isBE = (MathAbs(currentSL - openPrice) < CPriceEngine::PipToPoints(5));
               if(!isBE) {
                  double closeVol = MathFloor((volume * Partial1_ClosePct / 100.0) / lotStep) * lotStep;
                  if(closeVol >= minVol) {
                     (*m_pTrade).PositionClosePartial(ticket, closeVol);
                     if(PartialMoveSLtoBE) {
                        double bePrice = (posType == POSITION_TYPE_BUY) ?
                           NormalizeDouble(openPrice + CPriceEngine::PipToPoints(BE_LockPips), digits) :
                           NormalizeDouble(openPrice - CPriceEngine::PipToPoints(BE_LockPips), digits);
                        (*m_pTrade).PositionModify(ticket, bePrice, currentTP);
                     }
                  }
               }
            }
            
            // 2. Partial
            if(profitDist >= tpDist * (Partial2_TriggerPct / 100.0) && volume > minVol * 2) {
               double closeVol = MathFloor((volume * Partial2_ClosePct / 100.0) / lotStep) * lotStep;
               if(closeVol >= minVol) (*m_pTrade).PositionClosePartial(ticket, closeVol);
            }
         }
         
         // 2. Breakeven
         if(UseBreakeven && tpDist > 0 && profitDist >= tpDist * (BE_TriggerPct / 100.0)) {
            double bePrice;
            if(posType == POSITION_TYPE_BUY) {
               bePrice = NormalizeDouble(openPrice + CPriceEngine::PipToPoints(BE_LockPips), digits);
               if(currentSL < bePrice) (*m_pTrade).PositionModify(ticket, bePrice, currentTP);
            } else {
               bePrice = NormalizeDouble(openPrice - CPriceEngine::PipToPoints(BE_LockPips), digits);
               if(currentSL > bePrice || currentSL == 0) (*m_pTrade).PositionModify(ticket, bePrice, currentTP);
            }
         }
         
         // 3. Trailing Stop
         if(UseTrailing && atr > 0 && tpDist > 0 && profitDist >= tpDist * (Trail_StartPct / 100.0)) {
            double trailDist;
            switch(TrailMode) {
               case TRAIL_FIXED: trailDist = CPriceEngine::PipToPoints(Trail_FixedPips); break;
               case TRAIL_ATR: trailDist = atr * Trail_ATR_Multi; break;
               default: trailDist = atr * Trail_ATR_Multi;
            }
            
            double newSL;
            if(posType == POSITION_TYPE_BUY) {
               newSL = NormalizeDouble(currentPrice - trailDist, digits);
               if(newSL > currentSL) (*m_pTrade).PositionModify(ticket, newSL, currentTP);
            } else {
               newSL = NormalizeDouble(currentPrice + trailDist, digits);
               if(newSL < currentSL || currentSL == 0) (*m_pTrade).PositionModify(ticket, newSL, currentTP);
            }
         }
      }
   }
   
   void UpdateStats(double profit) {
      m_netProfit += profit;
      if(profit > 0) { m_winTrades++; m_grossProfit += profit; }
      else { m_lossTrades++; m_grossLoss += profit; }
      if(m_netProfit > m_maxProfit) m_maxProfit = m_netProfit;
      if(m_netProfit < m_maxDD) m_maxDD = m_netProfit;
   }
   
   void IncrementTrades() { m_totalTrades++; }
   int GetTotalTrades() { return m_totalTrades; }
   int GetWinTrades() { return m_winTrades; }
   int GetLossTrades() { return m_lossTrades; }
   double GetNetProfit() { return m_netProfit; }
   double GetWinRate() { return (m_totalTrades > 0) ? m_winTrades * 100.0 / m_totalTrades : 0; }
   double GetProfitFactor() { return (m_grossLoss != 0) ? m_grossProfit / MathAbs(m_grossLoss) : 0; }
   double GetExpectancy() {
      if(m_totalTrades < 5) return 0;
      double wr = (double)m_winTrades / m_totalTrades;
      double avgW = (m_winTrades > 0) ? m_grossProfit / m_winTrades : 0;
      double avgL = (m_lossTrades > 0) ? MathAbs(m_grossLoss) / m_lossTrades : 0;
      return (wr * avgW) - ((1-wr) * avgL);
   }
   
   void PrintStats() {
      Print("════════════════════════════════════════════════════════════════════");
      Print("📊 v13 SONUÇ RAPORU:");
      Print("   İşlem: ", m_totalTrades, " | Win: ", m_winTrades, " | Loss: ", m_lossTrades);
      Print("   WR: ", DoubleToString(GetWinRate(), 1), "% | PF: ", DoubleToString(GetProfitFactor(), 2));
      Print("   Net: $", DoubleToString(m_netProfit, 2), " | Expectancy: $", DoubleToString(GetExpectancy(), 2));
      Print("════════════════════════════════════════════════════════════════════");
   }
};

//====================================================================
// CLASS: HARMONY MANAGER (Tüm Modülleri Senkronize Eder)
//====================================================================
class CHarmonyManager
{
public:
   CAdvancedLevels Levels;
   
   int m_lastLevelScore;
   int m_lastMTFScore;
   int m_lastSessionScore;
   int m_lastDivergenceScore;
   
   CHarmonyManager() : m_lastLevelScore(50), m_lastMTFScore(50), m_lastSessionScore(50), m_lastDivergenceScore(50) {}
   
   void Update() { Levels.Update(); }
   
   int GetMTFScore(int direction) {
      if(!UseMTF) return 50;
      int score = 50;
      
      int hMA1 = iMA(_Symbol, HigherTF1, MTF_MA_Period, 0, MODE_EMA, PRICE_CLOSE);
      int hMA2 = iMA(_Symbol, HigherTF2, MTF_MA_Period, 0, MODE_EMA, PRICE_CLOSE);
      
      if(hMA1 != INVALID_HANDLE) {
         double ma[]; ArraySetAsSeries(ma, true);
         double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(CopyBuffer(hMA1, 0, 0, 1, ma) >= 1) {
            if(direction == 1 && price > ma[0]) score += 15;
            else if(direction == -1 && price < ma[0]) score += 15;
            else score -= 15;
         }
         IndicatorRelease(hMA1);
      }
      
      if(hMA2 != INVALID_HANDLE) {
         double ma[]; ArraySetAsSeries(ma, true);
         double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(CopyBuffer(hMA2, 0, 0, 1, ma) >= 1) {
            if(direction == 1 && price > ma[0]) score += 20;
            else if(direction == -1 && price < ma[0]) score += 20;
            else score -= 20;
         }
         IndicatorRelease(hMA2);
      }
      
      return MathMax(0, MathMin(100, score));
   }
   
   string GetSessionName() {
      MqlDateTime dt; TimeCurrent(dt);
      int h = dt.hour;
      if(h >= 0 && h < 8) return "ASYA";
      if(h >= 8 && h < 12) return "LONDRA";
      if(h >= 12 && h < 17) return "OVERLAP";
      if(h >= 17 && h < 22) return "NEW YORK";
      return "OFF";
   }
   
   int GetSessionScore() {
      string session = GetSessionName();
      if(session == "OVERLAP") return 100;
      if(session == "LONDRA") return 85;
      if(session == "NEW YORK") return 80;
      if(session == "ASYA") return 60;
      return 40;
   }
   
   int GetDivergenceScore(int direction) {
      if(!UseDivergence) return 50;
      
      int hRSI = iRSI(_Symbol, TF, RSI_Period, PRICE_CLOSE);
      if(hRSI == INVALID_HANDLE) return 50;
      
      double rsi[]; ArraySetAsSeries(rsi, true);
      if(CopyBuffer(hRSI, 0, 0, DivergenceLookback, rsi) < DivergenceLookback) { IndicatorRelease(hRSI); return 50; }
      IndicatorRelease(hRSI);
      
      double price1 = iLow(_Symbol, TF, 1), price2 = iLow(_Symbol, TF, DivergenceLookback/2);
      double rsi1 = rsi[1], rsi2 = rsi[DivergenceLookback/2];
      
      // Bullish Divergence
      if(direction == 1 && price1 < price2 && rsi1 > rsi2) return 90;
      
      price1 = iHigh(_Symbol, TF, 1); price2 = iHigh(_Symbol, TF, DivergenceLookback/2);
      
      // Bearish Divergence
      if(direction == -1 && price1 > price2 && rsi1 < rsi2) return 90;
      
      return 50;
   }
   
   int CalculateHarmonyScore(int direction, int baseScore) {
      m_lastLevelScore = Levels.GetLevelScore(direction);
      m_lastMTFScore = GetMTFScore(direction);
      m_lastSessionScore = GetSessionScore();
      m_lastDivergenceScore = GetDivergenceScore(direction);
      
      double totalW = 50 + Weight_Level + 10 + 5 + Weight_Divergence;
      double weighted = (
         baseScore * 50.0 +
         m_lastLevelScore * Weight_Level +
         m_lastMTFScore * 10.0 +
         m_lastSessionScore * 5.0 +
         m_lastDivergenceScore * Weight_Divergence
      ) / totalW;
      
      g_LastHarmonyScore = (int)weighted;
      g_LastHarmonyDetails = StringFormat("LVL:%d MTF:%d SES:%d DIV:%d",
         m_lastLevelScore, m_lastMTFScore, m_lastSessionScore, m_lastDivergenceScore);
      
      return (int)MathMin(100, MathMax(0, weighted));
   }
};

//====================================================================
// GLOBAL NESNELER
//====================================================================
CSecurityManager Security;
CAISignalScorer  AIScorer;
CTradeExecutor   Executor;
CPositionManager PosMgr;
CHarmonyManager  Harmony;

//+------------------------------------------------------------------+
//| ONINIT                                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   if(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL) {
      Alert("❌ Sembol kapalı!");
      return INIT_FAILED;
   }
   
   if(!AIScorer.Init()) {
      Alert("❌ Gösterge hatası!");
      return INIT_FAILED;
   }
   
   Security.Init();
   Executor.Init();
   PosMgr.Init(Executor.GetTrade());
   
   // v14 5K Edition - Yeni Modül Başlatmaları
   MLSimulator.Init();
   RiskParity.SetBaseRisk(RiskPercent);
   NewsCalc.SetPauseTimes(NewsMinutesBefore, NewsMinutesAfter);
   ManualProtector.Init(Executor.GetTrade());
   
   // v14.3: Performans Optimizasyonu - Test modunda log azalt
   g_IsTester = MQLInfoInteger(MQL_TESTER);
   g_VerboseLog = !g_IsTester; // Test modunda detaylı log KAPALI
   if(g_IsTester) Print("⚡ v14.3: Test modu - Performans optimizasyonu aktif");
   
   // v14.2: State Persistence - Önceki oturumdan durumu oku
   string prefix = "MILYONER_" + _Symbol + "_";
   if(GlobalVariableCheck(prefix + "DailyPL")) {
      g_DailyPL = GlobalVariableGet(prefix + "DailyPL");
      g_WeeklyPL = GlobalVariableGet(prefix + "WeeklyPL");
      g_DailyTradeCount = (int)GlobalVariableGet(prefix + "TradeCount");
      g_LastSignalScore = (int)GlobalVariableGet(prefix + "LastSignalScore");
      g_LastHarmonyScore = (int)GlobalVariableGet(prefix + "LastHarmonyScore");
      g_ManualPause = GlobalVariableGet(prefix + "ManualPause") > 0;
      Print("📂 v14.2: EA durumu geri yüklendi - PL:", DoubleToString(g_DailyPL, 2), 
            " | Trades:", g_DailyTradeCount, " | Pause:", g_ManualPause);
   }
   
   Print("════════════════════════════════════════════════════════════════════════════════");
   Print("                    🤖 MİLYONER EA v14.2 - ULTIMATE 5K EDITION                   ");
   Print("════════════════════════════════════════════════════════════════════════════════");
   Print("📊 AI Skor Eşiği: ", MinSignalScore, " | Güçlü Sinyal: ", StrongSignalScore);
   Print("📊 10 Faktör Oylama: MA(", Weight_MACross, ") MACD(", Weight_MACD, ") RSI(", Weight_RSI, ")");
   Print("   ADX(", Weight_ADX, ") Stoch(", Weight_Stoch, ") CCI(", Weight_CCI, ")");
   Print("   Pattern(", Weight_Pattern, ") Wick(", Weight_Wick, ") Level(", Weight_Level, ") Div(", Weight_Divergence, ")");
   Print("📊 v14.2: ML | SmartEntry | Scaling | StatePersistence | ManualProtect");
   Print("📊 Session: ", Harmony.GetSessionName(), " | Risk: ", EnumToString(RiskMode));
   Print("════════════════════════════════════════════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}


//+------------------------------------------------------------------+
//| ONDEINIT                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // v14.2: State Persistence - Grafik değişikliğinde durumu kaydet
   if(reason == REASON_CHARTCHANGE || reason == REASON_PARAMETERS || reason == REASON_RECOMPILE) {
      string prefix = "MILYONER_" + _Symbol + "_";
      GlobalVariableSet(prefix + "DailyPL", g_DailyPL);
      GlobalVariableSet(prefix + "WeeklyPL", g_WeeklyPL);
      GlobalVariableSet(prefix + "TradeCount", g_DailyTradeCount);
      GlobalVariableSet(prefix + "LastSignalScore", g_LastSignalScore);
      GlobalVariableSet(prefix + "LastHarmonyScore", g_LastHarmonyScore);
      GlobalVariableSet(prefix + "ManualPause", g_ManualPause ? 1 : 0);
      Print("💾 v14.2: EA durumu kaydedildi (Reason: ", reason, ")");
   }
   
   PosMgr.PrintStats();
   ObjectsDeleteAll(0, "v14_");
   Comment("");
}

//+------------------------------------------------------------------+
//| ONCHARTEVENT                                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_KEYDOWN) {
      if(lparam == 80 || lparam == 112) { // P
         g_ManualPause = !g_ManualPause;
         Alert(g_ManualPause ? "⏸️ PAUSE" : "▶️ RESUME");
      }
      else if(lparam == 67 || lparam == 99) { // C
         if(MessageBox("Tüm pozisyonları kapat?", "ACİL", MB_YESNO) == IDYES) {
            Executor.EmergencyCloseAll();
            g_ManualPause = true;
         }
      }
      else if(lparam == 68 || lparam == 100) { // D
         Security.UpdateReference(true);
         g_SystemLocked = false;
         Alert("🔄 GÜNLÜK RESET");
      }
      else if(lparam == 82 || lparam == 114) { // R
         PosMgr.PrintStats();
      }
   }
}

//+------------------------------------------------------------------+
//| ONTICK                                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   AIScorer.UpdateATR();
   AIScorer.UpdateBarState();
   Harmony.Update();
   
   // v14.3: Yeni bar kontrolü - Test modunda sadece yeni bar'da işlem al
   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   bool isNewBar = (currentBarTime != g_LastBarTime);
   if(isNewBar) g_LastBarTime = currentBarTime;
   
   // v14.2: Manuel işlem koruma - EN ÖNCE ÇALIŞIR (PAUSE/FİLTRE BAĞIMSIZ)
   // SL/TP yoksa HEMEN ekler, beklemez!
   int quickSignal = AIScorer.GetSignal();
   ManualProtector.ManageManualPositions(quickSignal, AIScorer.m_lastATR);
   
   // v14 5K Edition - Modül Güncellemeleri (sadece yeni bar'da güncelle)
   if(isNewBar || !g_IsTester) {
      EquityFilter.Update();
      SessionAnalyzer.UpdateCurrentSession();
      EntryTiming.RecordVolatility(AIScorer.m_lastATR);
      SessionAnalyzer.RecordVolatility(AIScorer.m_lastATR);
   }
   
   if(ShowDashboard && (!g_IsTester || isNewBar)) UpdateDashboard();
   
   if(g_ManualPause) return;
   
   // v14: Equity Curve Filter
   if(!EquityFilter.IsTradingAllowed()) return;
   
   if(!Security.IsSafeToTrade()) {
      if(g_SystemLocked) Executor.EmergencyCloseAll();
      return;
   }
   
   // Pozisyon yönetimi
   PosMgr.ManagePositions(AIScorer.m_lastATR);
   
   // currentSignal = quickSignal zaten yukarıda alındı
   int currentSignal = quickSignal;
   
   // Yeni işlem açma kontrolü - DEBUG ekle
   Print("=== FILTER DEBUG === Signal: ", (currentSignal == 1 ? "BUY" : (currentSignal == -1 ? "SELL" : "NONE")));

   if(!Executor.CanOpenMore()) { Print(">>> BLOCKED: CanOpenMore() = false"); return; }
   if(!AIScorer.CanTrade()) { Print(">>> BLOCKED: CanTrade() = false"); return; }
   
   // v14: Smart Entry Timing Filter
   if(!EntryTiming.CanEnterNow()) { Print(">>> BLOCKED: CanEnterNow() = false"); return; }
   
   // v14: Session Filter
   if(!SessionAnalyzer.IsOptimalSession()) { Print(">>> BLOCKED: IsOptimalSession() = false"); return; }
   
   // currentSignal zaten yukarıda alındı (satır 1622)
   if(currentSignal == 0) { Print(">>> BLOCKED: Signal = 0"); return; }
   
   // v14: Correlation Filter
   if(CorrFilter.HasConflictingPosition(currentSignal)) { Print(">>> BLOCKED: HasConflictingPosition() = true for ", (currentSignal == 1 ? "BUY" : "SELL")); return; }
   
   // Harmony boost
   int finalScore = g_LastSignalScore;
   if(UseHarmonyBoost) {
      finalScore = Harmony.CalculateHarmonyScore(currentSignal, g_LastSignalScore);
   }
   
   // v14: Risk Parity - Dinamik Risk Hesaplama
   RiskParity.UpdateVolatilityAdjustment(AIScorer.m_lastATR, EntryTiming.GetAvgVolatility());
   RiskParity.UpdateCorrelationAdjustment(CorrFilter.GetMaxCorrelation());
   
   // Güçlü sinyal kontrolü
   if(SignalMode == SIG_HARMONY && finalScore < MinSignalScore) { Print(">>> BLOCKED: Harmony score too low: ", finalScore); return; }
   
   Print(">>> ALL FILTERS PASSED - Opening ", (currentSignal == 1 ? "BUY" : "SELL"));
   
   // İşlem aç
   if(Executor.OpenMarketOrder(currentSignal, AIScorer.m_lastATR, PosMgr.GetWinRate() / 100.0)) {
      Executor.OnTradeOpened();     // Overtrading önleme - zaman damgası
      AIScorer.OnTradeOpened();
      Security.IncrementTradeCount();
      PosMgr.IncrementTrades();
      EntryTiming.OnEntry();
      Print("📈 v14 Risk: ", RiskParity.GetRiskReport());
   }
}


//+------------------------------------------------------------------+
//| DASHBOARD                                                         |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
   string status = g_ManualPause ? "⏸️ PAUSE" :
                   (g_SystemLocked ? "🔒 " + g_LockReason :
                   (g_LockReason != "" ? "⏳ " + g_LockReason : "✅ AKTİF"));
   
   string dash = "";
   dash += "══════════════════════════════════════════════════\n";
   dash += "        🤖 MİLYONER EA v13.0 ULTIMATE 3K\n";
   dash += "══════════════════════════════════════════════════\n";
   dash += "DURUM: " + status + "\n";
   dash += "──────────────────────────────────────────────────\n";
   dash += "🎯 AI SKOR: " + IntegerToString(g_LastSignalScore) + "/100\n";
   if(UseHarmonyBoost) {
      dash += "🎼 HARMONY: " + IntegerToString(g_LastHarmonyScore) + "/100\n";
      dash += "   " + g_LastHarmonyDetails + "\n";
   }
   dash += "📊 " + g_LastSignalReason + "\n";
   dash += "──────────────────────────────────────────────────\n";
   dash += "🌍 Session: " + Harmony.GetSessionName() + "\n";
   dash += "💰 Günlük: $" + DoubleToString(Security.GetDailyPL(), 2) + "\n";
   dash += "💵 Haftalık: $" + DoubleToString(Security.GetWeeklyPL(), 2) + "\n";
   dash += "📊 İşlem: " + IntegerToString(Security.GetTradeCount()) + "/" + IntegerToString(MaxDailyTrades) + "\n";
   dash += "📈 Pozisyon: " + IntegerToString(Executor.CountOpenPositions()) + "/" + IntegerToString(MaxOpenPositions) + "\n";
   dash += "──────────────────────────────────────────────────\n";
   dash += "📊 Toplam: " + IntegerToString(PosMgr.GetTotalTrades()) + " | Win: " + IntegerToString(PosMgr.GetWinTrades()) + "\n";
   dash += "⚖️ WR: " + DoubleToString(PosMgr.GetWinRate(), 1) + "%\n";
   dash += "📈 PF: " + DoubleToString(PosMgr.GetProfitFactor(), 2) + "\n";
   dash += "💵 Net: $" + DoubleToString(PosMgr.GetNetProfit(), 2) + "\n";
   dash += "──────────────────────────────────────────────────\n";
   dash += "⌨️ [P]ause [C]lose [D]ailyReset [R]eport\n";
   dash += "══════════════════════════════════════════════════\n";
   
   Comment(dash);
}

//+------------------------------------------------------------------+
//| v13 ULTIMATE 3K EDITION                                          |
//| All-in-One AI Trading System with 20+ Synchronized Modules       |
//| 10-Factor Weighted Voting | 15+ Candle Patterns                  |
//| Fibonacci + Pivot + S/R | MTF | Divergence | Sessions            |
//| Kelly Criterion | Compounding | Grid | Hedge                      |
//| Smart Partial Close | Dynamic Trailing | Advanced Risk           |
//| © 2025, Milyoner EA Project - ULTIMATE 3K EDITION                |
//+------------------------------------------------------------------+

//====================================================================
// EXTENSION MODULE 1: GRID MATRIX SYSTEM
//====================================================================
class CGridManager
{
private:
   struct GridLevel {
      double price;
      double lot;
      int direction;
      bool filled;
      ulong ticket;
   };
   
   GridLevel m_levels[];
   int m_currentLevel;
   double m_entryPrice;
   int m_direction;
   bool m_active;
   double m_totalProfit;
   
public:
   CGridManager() : m_currentLevel(0), m_entryPrice(0), m_direction(0), m_active(false), m_totalProfit(0) {
      ArrayResize(m_levels, 0);
   }
   
   bool IsActive() { return m_active; }
   
   void Initialize(int direction, double entryPrice, double baseLot) {
      if(!UseGrid) return;
      
      m_direction = direction;
      m_entryPrice = entryPrice;
      m_active = true;
      m_currentLevel = 0;
      
      ArrayResize(m_levels, Grid_MaxLevels);
      
      double stepDist = CPriceEngine::PipToPoints(Grid_StepPips);
      double currentLot = baseLot;
      
      for(int i = 0; i < Grid_MaxLevels; i++) {
         if(direction == 1) {
            m_levels[i].price = entryPrice - (stepDist * (i + 1));
         } else {
            m_levels[i].price = entryPrice + (stepDist * (i + 1));
         }
         m_levels[i].lot = NormalizeDouble(currentLot, 2);
         m_levels[i].direction = direction;
         m_levels[i].filled = false;
         m_levels[i].ticket = 0;
         
         currentLot *= Grid_LotMultiplier;
         currentLot = MathMin(currentLot, MaxLotSize);
      }
      
      if(ShowDebugLog) {
         Print("🔲 Grid başlatıldı: ", (direction == 1 ? "BUY" : "SELL"), " | ", Grid_MaxLevels, " seviye");
         Print("   Adım: ", Grid_StepPips, " pip | Çarpan: ", Grid_LotMultiplier);
      }
   }
   
   void CheckLevels(CTrade &trade) {
      if(!m_active || !UseGrid) return;
      
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      for(int i = 0; i < ArraySize(m_levels); i++) {
         if(m_levels[i].filled) continue;
         
         bool shouldFill = false;
         if(m_direction == 1 && currentPrice <= m_levels[i].price) shouldFill = true;
         else if(m_direction == -1 && currentPrice >= m_levels[i].price) shouldFill = true;
         
         if(shouldFill) {
            int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
            double sl = 0, tp = 0;
            
            // Grid SL/TP hesapla
            double tpDist = CPriceEngine::PipToPoints(Grid_TakeProfitPips);
            double slDist = CPriceEngine::PipToPoints(Grid_StepPips * (Grid_MaxLevels + 1)); // SL = Grid son seviyesinden sonra
            
            if(m_direction == 1) {
               tp = NormalizeDouble(m_levels[i].price + tpDist, digits);
               sl = NormalizeDouble(m_levels[i].price - slDist, digits);  // BUY için SL aşağıda
            } else {
               tp = NormalizeDouble(m_levels[i].price - tpDist, digits);
               sl = NormalizeDouble(m_levels[i].price + slDist, digits);  // SELL için SL yukarıda
            }
            
            if(m_direction == 1) {
               trade.Buy(m_levels[i].lot, _Symbol, 0, sl, tp, "GRID_L" + IntegerToString(i + 1));
            } else {
               trade.Sell(m_levels[i].lot, _Symbol, 0, sl, tp, "GRID_L" + IntegerToString(i + 1));
            }
            
            if(trade.ResultRetcode() == TRADE_RETCODE_DONE) {
               m_levels[i].filled = true;
               m_levels[i].ticket = trade.ResultOrder();
               m_currentLevel = i + 1;
               Print("🔲 Grid L", (i + 1), " dolduruldu: ", m_levels[i].lot, " lot @ ", m_levels[i].price);
            }
         }
      }
   }
   
   double GetAveragePrice() {
      double totalLot = 0, weightedPrice = 0;
      for(int i = 0; i < ArraySize(m_levels); i++) {
         if(m_levels[i].filled) {
            totalLot += m_levels[i].lot;
            weightedPrice += m_levels[i].price * m_levels[i].lot;
         }
      }
      if(totalLot == 0) return 0;
      return weightedPrice / totalLot;
   }
   
   int GetFilledLevels() { return m_currentLevel; }
   
   void Reset() {
      m_active = false;
      m_currentLevel = 0;
      m_entryPrice = 0;
      m_direction = 0;
      ArrayResize(m_levels, 0);
   }
   
   void CheckCloseAll(CTrade &trade) {
      if(!m_active) return;
      
      double avgPrice = GetAveragePrice();
      if(avgPrice == 0) return;
      
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double profitDist = (m_direction == 1) ? (currentPrice - avgPrice) : (avgPrice - currentPrice);
      double targetDist = CPriceEngine::PipToPoints(Grid_TakeProfitPips);
      
      if(profitDist >= targetDist) {
         for(int i = PositionsTotal() - 1; i >= 0; i--) {
            ulong ticket = PositionGetTicket(i);
            if(ticket == 0) continue;
            string comment = PositionGetString(POSITION_COMMENT);
            if(StringFind(comment, "GRID_") >= 0) {
               trade.PositionClose(ticket);
            }
         }
         Print("🔲 Grid kapatıldı! Toplam kar hedefine ulaşıldı.");
         Reset();
      }
   }
};

//====================================================================
// EXTENSION MODULE 2: PENDING ORDER MANAGER
//====================================================================
class CPendingOrderManager
{
private:
   ulong m_pendingTickets[];
   int m_pendingCount;
   
public:
   CPendingOrderManager() : m_pendingCount(0) {
      ArrayResize(m_pendingTickets, 0);
   }
   
   bool PlaceBuyStop(CTrade &trade, double price, double sl, double tp, double lot, string comment) {
      if(trade.BuyStop(lot, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comment)) {
         ArrayResize(m_pendingTickets, m_pendingCount + 1);
         m_pendingTickets[m_pendingCount] = trade.ResultOrder();
         m_pendingCount++;
         Print("📋 BuyStop yerleştirildi @ ", price);
         return true;
      }
      return false;
   }
   
   bool PlaceSellStop(CTrade &trade, double price, double sl, double tp, double lot, string comment) {
      if(trade.SellStop(lot, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comment)) {
         ArrayResize(m_pendingTickets, m_pendingCount + 1);
         m_pendingTickets[m_pendingCount] = trade.ResultOrder();
         m_pendingCount++;
         Print("📋 SellStop yerleştirildi @ ", price);
         return true;
      }
      return false;
   }
   
   bool PlaceBuyLimit(CTrade &trade, double price, double sl, double tp, double lot, string comment) {
      if(trade.BuyLimit(lot, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comment)) {
         ArrayResize(m_pendingTickets, m_pendingCount + 1);
         m_pendingTickets[m_pendingCount] = trade.ResultOrder();
         m_pendingCount++;
         Print("📋 BuyLimit yerleştirildi @ ", price);
         return true;
      }
      return false;
   }
   
   bool PlaceSellLimit(CTrade &trade, double price, double sl, double tp, double lot, string comment) {
      if(trade.SellLimit(lot, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comment)) {
         ArrayResize(m_pendingTickets, m_pendingCount + 1);
         m_pendingTickets[m_pendingCount] = trade.ResultOrder();
         m_pendingCount++;
         Print("📋 SellLimit yerleştirildi @ ", price);
         return true;
      }
      return false;
   }
   
   void CancelAllPending(CTrade &trade) {
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber && OrderGetString(ORDER_SYMBOL) == _Symbol) {
            trade.OrderDelete(ticket);
         }
      }
      ArrayResize(m_pendingTickets, 0);
      m_pendingCount = 0;
   }
   
   int CountPending() {
      int count = 0;
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber && OrderGetString(ORDER_SYMBOL) == _Symbol) count++;
      }
      return count;
   }
   
   void CleanupExpired() {
      datetime now = TimeCurrent();
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber) {
            datetime orderTime = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
            if(now - orderTime > 3600 * 4) { // 4 saatten eski emirleri iptal et
               CTrade tempTrade;
               tempTrade.OrderDelete(ticket);
               Print("📋 Eski bekleyen emir silindi: ", ticket);
            }
         }
      }
   }
};

//====================================================================
// EXTENSION MODULE 3: SIGNAL HISTORY & LEARNING
//====================================================================
class CSignalHistory
{
private:
   struct SignalRecord {
      datetime time;
      int direction;
      int score;
      int harmonyScore;
      double entryPrice;
      double exitPrice;
      double profit;
      bool isWin;
      string pattern;
   };
   
   SignalRecord m_history[];
   int m_count;
   int m_maxHistory;
   
public:
   CSignalHistory() : m_count(0), m_maxHistory(500) {
      ArrayResize(m_history, 0);
   }
   
   void RecordSignal(int direction, int score, int harmonyScore, double entryPrice, string pattern) {
      if(m_count >= m_maxHistory) {
         // Shift array
         for(int i = 0; i < m_maxHistory - 1; i++) {
            m_history[i] = m_history[i + 1];
         }
         m_count = m_maxHistory - 1;
      }
      
      ArrayResize(m_history, m_count + 1);
      m_history[m_count].time = TimeCurrent();
      m_history[m_count].direction = direction;
      m_history[m_count].score = score;
      m_history[m_count].harmonyScore = harmonyScore;
      m_history[m_count].entryPrice = entryPrice;
      m_history[m_count].exitPrice = 0;
      m_history[m_count].profit = 0;
      m_history[m_count].isWin = false;
      m_history[m_count].pattern = pattern;
      m_count++;
   }
   
   void UpdateLastResult(double exitPrice, double profit) {
      if(m_count > 0) {
         m_history[m_count - 1].exitPrice = exitPrice;
         m_history[m_count - 1].profit = profit;
         m_history[m_count - 1].isWin = (profit > 0);
      }
   }
   
   double GetWinRateByScoreRange(int minScore, int maxScore) {
      int wins = 0, total = 0;
      for(int i = 0; i < m_count; i++) {
         if(m_history[i].exitPrice > 0 && m_history[i].score >= minScore && m_history[i].score <= maxScore) {
            total++;
            if(m_history[i].isWin) wins++;
         }
      }
      return (total > 0) ? (double)wins / total * 100 : 50;
   }
   
   double GetWinRateByPattern(string pattern) {
      int wins = 0, total = 0;
      for(int i = 0; i < m_count; i++) {
         if(m_history[i].exitPrice > 0 && m_history[i].pattern == pattern) {
            total++;
            if(m_history[i].isWin) wins++;
         }
      }
      return (total > 0) ? (double)wins / total * 100 : 50;
   }
   
   double GetWinRateByDirection(int direction) {
      int wins = 0, total = 0;
      for(int i = 0; i < m_count; i++) {
         if(m_history[i].exitPrice > 0 && m_history[i].direction == direction) {
            total++;
            if(m_history[i].isWin) wins++;
         }
      }
      return (total > 0) ? (double)wins / total * 100 : 50;
   }
   
   double GetAverageProfitByScore(int minScore) {
      double total = 0;
      int count = 0;
      for(int i = 0; i < m_count; i++) {
         if(m_history[i].exitPrice > 0 && m_history[i].score >= minScore) {
            total += m_history[i].profit;
            count++;
         }
      }
      return (count > 0) ? total / count : 0;
   }
   
   int GetOptimalThreshold() {
      int bestThreshold = 55;
      double bestWR = 0;
      
      for(int threshold = 45; threshold <= 80; threshold += 5) {
         double wr = GetWinRateByScoreRange(threshold, 100);
         if(wr > bestWR) {
            bestWR = wr;
            bestThreshold = threshold;
         }
      }
      return bestThreshold;
   }
   
   void PrintAnalysis() {
      if(m_count < 10) {
         Print("📊 Yeterli veri yok (min 10 işlem)");
         return;
      }
      
      Print("════════════════════════════════════════════════════════════════════");
      Print("📊 SİNYAL GEÇMİŞİ ANALİZİ (", m_count, " kayıt)");
      Print("════════════════════════════════════════════════════════════════════");
      Print("   45-54 Skor WR: ", DoubleToString(GetWinRateByScoreRange(45, 54), 1), "%");
      Print("   55-64 Skor WR: ", DoubleToString(GetWinRateByScoreRange(55, 64), 1), "%");
      Print("   65-74 Skor WR: ", DoubleToString(GetWinRateByScoreRange(65, 74), 1), "%");
      Print("   75-100 Skor WR: ", DoubleToString(GetWinRateByScoreRange(75, 100), 1), "%");
      Print("   BUY WR: ", DoubleToString(GetWinRateByDirection(1), 1), "%");
      Print("   SELL WR: ", DoubleToString(GetWinRateByDirection(-1), 1), "%");
      Print("   Optimal Eşik: ", GetOptimalThreshold());
      Print("════════════════════════════════════════════════════════════════════");
   }
   
   int GetRecordCount() { return m_count; }
};

//====================================================================
// EXTENSION MODULE 4: TRADE LOGGER
//====================================================================
class CTradeLogger
{
private:
   string m_logFileName;
   bool m_enabled;
   
public:
   CTradeLogger() : m_enabled(false) {
      m_logFileName = "Milyoner_v13_TradeLog_" + _Symbol + ".csv";
   }
   
   void Enable(bool enable) { m_enabled = enable; }
   
   void Initialize() {
      if(!m_enabled || !SaveTradeLog) return;
      
      int handle = FileOpen(m_logFileName, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
      if(handle != INVALID_HANDLE) {
         FileWrite(handle, "Tarih", "Sembol", "Tip", "Lot", "Giriş", "Çıkış", "SL", "TP", "Kar", "Skor", "Harmony", "Pattern", "Süre");
         FileClose(handle);
         Print("📝 Trade log dosyası oluşturuldu: ", m_logFileName);
      }
   }
   
   void LogTrade(string type, double lot, double entry, double exit, double sl, double tp, double profit, int score, int harmony, string pattern, int duration) {
      if(!m_enabled || !SaveTradeLog) return;
      
      int handle = FileOpen(m_logFileName, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
      if(handle != INVALID_HANDLE) {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, 
            TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES),
            _Symbol,
            type,
            DoubleToString(lot, 2),
            DoubleToString(entry, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)),
            DoubleToString(exit, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)),
            DoubleToString(sl, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)),
            DoubleToString(tp, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)),
            DoubleToString(profit, 2),
            IntegerToString(score),
            IntegerToString(harmony),
            pattern,
            IntegerToString(duration) + "m"
         );
         FileClose(handle);
      }
   }
   
   void LogEvent(string event, string details) {
      if(!m_enabled) return;
      Print("📝 [LOG] ", event, ": ", details);
   }
};

//====================================================================
// EXTENSION MODULE 5: VOLATILITY ANALYZER
//====================================================================
class CVolatilityAnalyzer
{
private:
   double m_atrHistory[];
   int m_historySize;
   double m_avgATR;
   double m_currentATR;
   ENUM_MARKET_REGIME m_regime;
   
public:
   CVolatilityAnalyzer() : m_historySize(50), m_avgATR(0), m_currentATR(0), m_regime(REGIME_RANGING) {
      ArrayResize(m_atrHistory, m_historySize);
      ArrayInitialize(m_atrHistory, 0);
   }
   
   void Update(double atr) {
      m_currentATR = atr;
      
      // Shift history
      for(int i = m_historySize - 1; i > 0; i--) {
         m_atrHistory[i] = m_atrHistory[i - 1];
      }
      m_atrHistory[0] = atr;
      
      // Calculate average
      double sum = 0;
      int count = 0;
      for(int i = 0; i < m_historySize; i++) {
         if(m_atrHistory[i] > 0) {
            sum += m_atrHistory[i];
            count++;
         }
      }
      if(count > 0) m_avgATR = sum / count;
      
      // Determine regime
      DetectRegime();
   }
   
   void DetectRegime() {
      if(m_avgATR == 0) {
         m_regime = REGIME_RANGING;
         return;
      }
      
      double ratio = m_currentATR / m_avgATR;
      
      if(ratio > VolatilityMultiplier) {
         m_regime = REGIME_HIGH_VOLATILITY;
      } else if(ratio > 1.2) {
         m_regime = REGIME_BREAKOUT;
      } else if(ratio < 0.6) {
         m_regime = REGIME_RANGING;
      } else {
         // Check trend with LR slope
         double slope = CPriceEngine::CalculateLRSlope(LR_Period);
         if(MathAbs(slope) > LR_MinSlope) {
            m_regime = REGIME_TRENDING;
         } else {
            m_regime = REGIME_RANGING;
         }
      }
   }
   
   ENUM_MARKET_REGIME GetRegime() { return m_regime; }
   double GetCurrentATR() { return m_currentATR; }
   double GetAverageATR() { return m_avgATR; }
   double GetVolatilityRatio() { return (m_avgATR > 0) ? m_currentATR / m_avgATR : 1; }
   
   string GetRegimeName() {
      switch(m_regime) {
         case REGIME_HIGH_VOLATILITY: return "YÜKSEK VOL";
         case REGIME_TRENDING: return "TREND";
         case REGIME_RANGING: return "RANGE";
         case REGIME_BREAKOUT: return "KIRILIM";
         case REGIME_REVERSAL: return "DÖNÜŞ";
         default: return "BİLİNMİYOR";
      }
   }
   
   int GetRegimeScore(int direction) {
      switch(m_regime) {
         case REGIME_TRENDING: return 85;
         case REGIME_BREAKOUT: return 80;
         case REGIME_HIGH_VOLATILITY: return 60;
         case REGIME_RANGING: return 40;
         default: return 50;
      }
   }
};

//====================================================================
// EXTENSION MODULE 6: MONEY MANAGEMENT CALCULATOR
//====================================================================
class CMoneyManagement
{
public:
   static double CalculatePositionSize(double riskPercent, double slPips, double accountBalance) {
      if(slPips <= 0) return MinLotSize;
      
      double riskAmount = accountBalance * riskPercent / 100.0;
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      
      if(tickValue <= 0) tickValue = 10.0;
      if(tickSize <= 0) tickSize = point;
      
      double pipValue = tickValue * (point / tickSize) * 10.0;
      double lot = riskAmount / (slPips * pipValue);
      
      return CPriceEngine::NormalizeLot(lot);
   }
   
   static double CalculateKellySize(double winRate, double avgWin, double avgLoss) {
      if(avgLoss == 0) return 0;
      double rr = avgWin / avgLoss;
      double kelly = (winRate * rr - (1 - winRate)) / rr;
      return MathMax(0, MathMin(kelly * 100, 25)); // Max 25%
   }
   
   static double GetMaxDrawdownPercent() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      if(balance == 0) return 0;
      return (balance - equity) / balance * 100;
   }
   
   static bool IsRiskAcceptable(double lot, double slPips) {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double riskAmount = lot * slPips * tickValue * 10;
      double riskPercent = (balance > 0) ? (riskAmount / balance) * 100 : 0;
      return (riskPercent <= RiskPercent * 1.5);
   }
   
   static double GetDailyProfitTarget() {
      return AccountInfoDouble(ACCOUNT_BALANCE) * MaxDailyDDPct / 100.0 * 0.5; // DD limitinin yarısı
   }
};

//====================================================================
// EXTENSION MODULE 7: SYMBOL INFO HELPER
//====================================================================
class CSymbolInfo
{
public:
   static double GetSpreadPips() {
      return SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0;
   }
   
   static double GetAsk() { return SymbolInfoDouble(_Symbol, SYMBOL_ASK); }
   static double GetBid() { return SymbolInfoDouble(_Symbol, SYMBOL_BID); }
   
   static double GetMidPrice() {
      return (GetAsk() + GetBid()) / 2.0;
   }
   
   static bool IsMarketOpen() {
      MqlDateTime dt;
      TimeCurrent(dt);
      return (dt.day_of_week >= 1 && dt.day_of_week <= 5);
   }
   
   static double GetTickValue() {
      return SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   }
   
   static double GetTickSize() {
      return SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   }
   
   static double GetPoint() {
      return SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   }
   
   static int GetDigits() {
      return (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   }
   
   static double GetMinLot() {
      return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   }
   
   static double GetMaxLot() {
      return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   }
   
   static double GetLotStep() {
      return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   }
   
   static long GetStopLevel() {
      return SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   }
   
   static string GetDescription() {
      return SymbolInfoString(_Symbol, SYMBOL_DESCRIPTION);
   }
   
   static double GetContractSize() {
      return SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   }
   
   static void PrintInfo() {
      Print("════════════════════════════════════════════════════════════════════");
      Print("📊 SEMBOL BİLGİSİ: ", _Symbol);
      Print("   Açıklama: ", GetDescription());
      Print("   Spread: ", DoubleToString(GetSpreadPips(), 1), " pip");
      Print("   Lot Min/Max/Step: ", GetMinLot(), "/", GetMaxLot(), "/", GetLotStep());
      Print("   Stop Level: ", GetStopLevel(), " point");
      Print("   Kontrat: ", GetContractSize());
      Print("════════════════════════════════════════════════════════════════════");
   }
};

//====================================================================
// EXTENSION MODULE 8: TIME HELPER
//====================================================================
class CTimeHelper
{
public:
   static bool IsNewBar() {
      static datetime lastBarTime = 0;
      datetime currentBar = iTime(_Symbol, TF, 0);
      if(lastBarTime != currentBar) {
         lastBarTime = currentBar;
         return true;
      }
      return false;
   }
   
   static bool IsNewDay() {
      static int lastDay = -1;
      MqlDateTime dt;
      TimeCurrent(dt);
      if(lastDay != dt.day) {
         lastDay = dt.day;
         return true;
      }
      return false;
   }
   
   static bool IsNewWeek() {
      static int lastWeek = -1;
      MqlDateTime dt;
      TimeCurrent(dt);
      int currentWeek = dt.day_of_year / 7;
      if(lastWeek != currentWeek) {
         lastWeek = currentWeek;
         return true;
      }
      return false;
   }
   
   static bool IsTradingHours() {
      if(!UseTimeFilter) return true;
      MqlDateTime dt;
      TimeCurrent(dt);
      return (dt.hour >= StartHour && dt.hour < EndHour);
   }
   
   static bool IsFridayEvening() {
      MqlDateTime dt;
      TimeCurrent(dt);
      return (dt.day_of_week == 5 && dt.hour >= 20);
   }
   
   static bool IsWeekend() {
      MqlDateTime dt;
      TimeCurrent(dt);
      return (dt.day_of_week == 0 || dt.day_of_week == 6);
   }
   
   static int GetMinutesInPosition(datetime openTime) {
      return (int)((TimeCurrent() - openTime) / 60);
   }
   
   static string GetCurrentTimeStr() {
      return TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES);
   }
   
   static int GetCurrentHour() {
      MqlDateTime dt;
      TimeCurrent(dt);
      return dt.hour;
   }
   
   static int GetCurrentDayOfWeek() {
      MqlDateTime dt;
      TimeCurrent(dt);
      return dt.day_of_week;
   }
};

//====================================================================
// EXTENSION MODULE 9: STATISTICAL HELPER
//====================================================================
class CStatistics
{
public:
   static double Mean(double &arr[], int size) {
      if(size <= 0) return 0;
      double sum = 0;
      for(int i = 0; i < size; i++) sum += arr[i];
      return sum / size;
   }
   
   static double StdDev(double &arr[], int size) {
      if(size <= 1) return 0;
      double mean = Mean(arr, size);
      double sumSq = 0;
      for(int i = 0; i < size; i++) sumSq += MathPow(arr[i] - mean, 2);
      return MathSqrt(sumSq / (size - 1));
   }
   
   static double Variance(double &arr[], int size) {
      double sd = StdDev(arr, size);
      return sd * sd;
   }
   
   static double Max(double &arr[], int size) {
      if(size <= 0) return 0;
      double max = arr[0];
      for(int i = 1; i < size; i++) if(arr[i] > max) max = arr[i];
      return max;
   }
   
   static double Min(double &arr[], int size) {
      if(size <= 0) return 0;
      double min = arr[0];
      for(int i = 1; i < size; i++) if(arr[i] < min) min = arr[i];
      return min;
   }
   
   static double Median(double &arr[], int size) {
      if(size <= 0) return 0;
      double sorted[];
      ArrayCopy(sorted, arr, 0, 0, size);
      ArraySort(sorted);
      if(size % 2 == 0) return (sorted[size/2 - 1] + sorted[size/2]) / 2;
      return sorted[size/2];
   }
   
   static double Correlation(double &arr1[], double &arr2[], int size) {
      if(size < 2) return 0;
      double mean1 = Mean(arr1, size);
      double mean2 = Mean(arr2, size);
      double num = 0, den1 = 0, den2 = 0;
      for(int i = 0; i < size; i++) {
         num += (arr1[i] - mean1) * (arr2[i] - mean2);
         den1 += MathPow(arr1[i] - mean1, 2);
         den2 += MathPow(arr2[i] - mean2, 2);
      }
      double denom = MathSqrt(den1 * den2);
      return (denom > 0) ? num / denom : 0;
   }
   
   static double SharpeRatio(double &returns[], int size, double riskFreeRate = 0) {
      if(size < 2) return 0;
      double mean = Mean(returns, size);
      double sd = StdDev(returns, size);
      if(sd == 0) return 0;
      return (mean - riskFreeRate) / sd;
   }
   
   static double SortinoRatio(double &returns[], int size, double riskFreeRate = 0) {
      if(size < 2) return 0;
      double mean = Mean(returns, size);
      double downside[];
      ArrayResize(downside, 0);
      int dCount = 0;
      for(int i = 0; i < size; i++) {
         if(returns[i] < 0) {
            ArrayResize(downside, dCount + 1);
            downside[dCount] = returns[i];
            dCount++;
         }
      }
      double downsideDev = StdDev(downside, dCount);
      if(downsideDev == 0) return 0;
      return (mean - riskFreeRate) / downsideDev;
   }
};

//====================================================================
// EXTENSION MODULE 10: ALERT MANAGER
//====================================================================
class CAlertManager
{
public:
   static void TradeOpened(int direction, double lot, double price, int score) {
      string msg = StringFormat("%s v13: %s @ %s | Lot: %s | Score: %d",
         _Symbol, (direction == 1 ? "BUY" : "SELL"),
         DoubleToString(price, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)),
         DoubleToString(lot, 2), score);
      
      if(PlaySoundOnTrade) PlaySound(SoundFile);
      if(UsePushNotify) SendNotification(msg);
      if(UseSendEmail) SendMail("Trade Alert - " + _Symbol, msg);
      Print("🔔 ", msg);
   }
   
   static void TradeClosed(double profit, string reason) {
      string msg = StringFormat("%s v13: Kapat @ %s | Sebep: %s",
         _Symbol, DoubleToString(profit, 2), reason);
      
      if(UsePushNotify) SendNotification(msg);
      Print("🔔 ", msg);
   }
   
   static void RiskWarning(string warning) {
      string msg = StringFormat("%s v13 RİSK: %s", _Symbol, warning);
      Alert(msg);
      Print("⚠️ ", msg);
   }
   
   static void DailyReport(int trades, double pnl, double winRate) {
      string msg = StringFormat("%s v13 Günlük: %d işlem | PnL: $%s | WR: %s%%",
         _Symbol, trades, DoubleToString(pnl, 2), DoubleToString(winRate, 1));
      
      if(UsePushNotify) SendNotification(msg);
      Print("📊 ", msg);
   }
};

//====================================================================
// GLOBAL EXTENSION OBJECTS
//====================================================================
CGridManager       GridMgr;
CPendingOrderManager PendingMgr;
CSignalHistory     SignalHist;
CTradeLogger       TradeLog;
CVolatilityAnalyzer VolAnalyzer;

//+------------------------------------------------------------------+
//| Extended OnTick - Integration with new modules                    |
//+------------------------------------------------------------------+
void OnTickExtended()
{
   // Update volatility analyzer
   VolAnalyzer.Update(AIScorer.m_lastATR);
   
   // Cleanup expired pending orders
   PendingMgr.CleanupExpired();
   
   // Check grid levels
   if(UseGrid && GridMgr.IsActive()) {
      GridMgr.CheckLevels(*Executor.GetTrade());
      GridMgr.CheckCloseAll(*Executor.GetTrade());
   }
   
   // New day check
   if(CTimeHelper::IsNewDay()) {
      TradeLog.Initialize();
      SignalHist.PrintAnalysis();
   }
}

//+------------------------------------------------------------------+
//| v13 ULTIMATE 3K EDITION - COMPLETE                               |
//| Total Modules: 20+ Core + 10 Extensions = 30+ Features           |
//| Line Count: 3000+ | All Modules Synchronized                     |
//| © 2025, Milyoner EA Project - The Ultimate Trading System        |
//+------------------------------------------------------------------+

//====================================================================
// EXTENSION MODULE 11: DRAWDOWN MANAGER
//====================================================================
class CDrawdownManager
{
private:
   double m_peakEquity;
   double m_currentDD;
   double m_maxDD;
   datetime m_maxDDTime;
   double m_recoveryFactor;
   int m_consecutiveLosses;
   int m_maxConsecutiveLosses;
   
public:
   CDrawdownManager() : m_peakEquity(0), m_currentDD(0), m_maxDD(0), m_maxDDTime(0),
      m_recoveryFactor(0), m_consecutiveLosses(0), m_maxConsecutiveLosses(0) {}
   
   void Update() {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      
      if(equity > m_peakEquity) {
         m_peakEquity = equity;
         m_consecutiveLosses = 0;
      }
      
      if(m_peakEquity > 0) {
         m_currentDD = (m_peakEquity - equity) / m_peakEquity * 100;
         
         if(m_currentDD > m_maxDD) {
            m_maxDD = m_currentDD;
            m_maxDDTime = TimeCurrent();
         }
      }
   }
   
   void OnTradeClosed(double profit) {
      if(profit < 0) {
         m_consecutiveLosses++;
         if(m_consecutiveLosses > m_maxConsecutiveLosses) {
            m_maxConsecutiveLosses = m_consecutiveLosses;
         }
      } else {
         m_consecutiveLosses = 0;
      }
   }
   
   double GetCurrentDD() { return m_currentDD; }
   double GetMaxDD() { return m_maxDD; }
   datetime GetMaxDDTime() { return m_maxDDTime; }
   int GetConsecutiveLosses() { return m_consecutiveLosses; }
   int GetMaxConsecutiveLosses() { return m_maxConsecutiveLosses; }
   
   bool IsInCriticalDD() { return (m_currentDD >= MaxDailyDDPct * 0.8); }
   
   double GetRecoveryFactor(double netProfit) {
      if(m_maxDD == 0) return 0;
      double peakDD = m_peakEquity * m_maxDD / 100;
      return (peakDD > 0) ? netProfit / peakDD : 0;
   }
   
   void Reset() {
      m_peakEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      m_currentDD = 0;
      m_maxDD = 0;
      m_consecutiveLosses = 0;
   }
   
   void PrintStats() {
      Print("════════════════════════════════════════════════════════════════════");
      Print("📉 DRAWDOWN ANALİZİ:");
      Print("   Mevcut DD: ", DoubleToString(m_currentDD, 2), "%");
      Print("   Max DD: ", DoubleToString(m_maxDD, 2), "% @ ", TimeToString(m_maxDDTime, TIME_DATE));
      Print("   Ardışık Zarar: ", m_consecutiveLosses, " | Max: ", m_maxConsecutiveLosses);
      Print("════════════════════════════════════════════════════════════════════");
   }
};

//====================================================================
// EXTENSION MODULE 12: PERFORMANCE TRACKER
//====================================================================
class CPerformanceTracker
{
private:
   struct DailyPerformance {
      datetime date;
      int trades;
      int wins;
      double profit;
      double maxDD;
   };
   
   DailyPerformance m_dailyStats[];
   int m_dayCount;
   double m_totalProfit;
   int m_totalTrades;
   int m_totalWins;
   
public:
   CPerformanceTracker() : m_dayCount(0), m_totalProfit(0), m_totalTrades(0), m_totalWins(0) {
      ArrayResize(m_dailyStats, 0);
   }
   
   void NewDay() {
      ArrayResize(m_dailyStats, m_dayCount + 1);
      m_dailyStats[m_dayCount].date = TimeCurrent();
      m_dailyStats[m_dayCount].trades = 0;
      m_dailyStats[m_dayCount].wins = 0;
      m_dailyStats[m_dayCount].profit = 0;
      m_dailyStats[m_dayCount].maxDD = 0;
      m_dayCount++;
   }
   
   void RecordTrade(bool isWin, double profit) {
      if(m_dayCount == 0) NewDay();
      
      m_dailyStats[m_dayCount - 1].trades++;
      if(isWin) m_dailyStats[m_dayCount - 1].wins++;
      m_dailyStats[m_dayCount - 1].profit += profit;
      
      m_totalTrades++;
      if(isWin) m_totalWins++;
      m_totalProfit += profit;
   }
   
   double GetDailyWinRate() {
      if(m_dayCount == 0 || m_dailyStats[m_dayCount - 1].trades == 0) return 0;
      return (double)m_dailyStats[m_dayCount - 1].wins / m_dailyStats[m_dayCount - 1].trades * 100;
   }
   
   double GetOverallWinRate() {
      if(m_totalTrades == 0) return 0;
      return (double)m_totalWins / m_totalTrades * 100;
   }
   
   double GetAverageDailyProfit() {
      if(m_dayCount == 0) return 0;
      return m_totalProfit / m_dayCount;
   }
   
   double GetBestDay() {
      double best = -999999;
      for(int i = 0; i < m_dayCount; i++) {
         if(m_dailyStats[i].profit > best) best = m_dailyStats[i].profit;
      }
      return best;
   }
   
   double GetWorstDay() {
      double worst = 999999;
      for(int i = 0; i < m_dayCount; i++) {
         if(m_dailyStats[i].profit < worst) worst = m_dailyStats[i].profit;
      }
      return worst;
   }
   
   int GetProfitableDays() {
      int count = 0;
      for(int i = 0; i < m_dayCount; i++) {
         if(m_dailyStats[i].profit > 0) count++;
      }
      return count;
   }
   
   void PrintReport() {
      Print("════════════════════════════════════════════════════════════════════");
      Print("📊 PERFORMANS RAPORU:");
      Print("   Toplam Gün: ", m_dayCount, " | Karlı: ", GetProfitableDays());
      Print("   Toplam İşlem: ", m_totalTrades, " | WR: ", DoubleToString(GetOverallWinRate(), 1), "%");
      Print("   Toplam Kar: $", DoubleToString(m_totalProfit, 2));
      Print("   Günlük Ort: $", DoubleToString(GetAverageDailyProfit(), 2));
      Print("   En İyi Gün: $", DoubleToString(GetBestDay(), 2));
      Print("   En Kötü Gün: $", DoubleToString(GetWorstDay(), 2));
      Print("════════════════════════════════════════════════════════════════════");
   }
};

//====================================================================
// EXTENSION MODULE 13: MARKET STRUCTURE ANALYZER
//====================================================================
class CMarketStructure
{
public:
   static bool IsHigherHigh(int shift = 0, int lookback = 10) {
      double currentHigh = iHigh(_Symbol, TF, shift);
      for(int i = shift + 1; i <= shift + lookback; i++) {
         if(iHigh(_Symbol, TF, i) >= currentHigh) return false;
      }
      return true;
   }
   
   static bool IsLowerLow(int shift = 0, int lookback = 10) {
      double currentLow = iLow(_Symbol, TF, shift);
      for(int i = shift + 1; i <= shift + lookback; i++) {
         if(iLow(_Symbol, TF, i) <= currentLow) return false;
      }
      return true;
   }
   
   static bool IsHigherLow(int shift = 0, int lookback = 10) {
      double currentLow = iLow(_Symbol, TF, shift);
      double prevLow = 999999;
      for(int i = shift + 1; i <= shift + lookback; i++) {
         if(iLow(_Symbol, TF, i) < prevLow) prevLow = iLow(_Symbol, TF, i);
      }
      return (currentLow > prevLow);
   }
   
   static bool IsLowerHigh(int shift = 0, int lookback = 10) {
      double currentHigh = iHigh(_Symbol, TF, shift);
      double prevHigh = 0;
      for(int i = shift + 1; i <= shift + lookback; i++) {
         if(iHigh(_Symbol, TF, i) > prevHigh) prevHigh = iHigh(_Symbol, TF, i);
      }
      return (currentHigh < prevHigh);
   }
   
   static int GetTrendStructure(int lookback = 20) {
      int hh = 0, hl = 0, lh = 0, ll = 0;
      
      for(int i = 2; i < lookback; i++) {
         if(IsHigherHigh(i, 5)) hh++;
         if(IsHigherLow(i, 5)) hl++;
         if(IsLowerHigh(i, 5)) lh++;
         if(IsLowerLow(i, 5)) ll++;
      }
      
      if(hh >= 2 && hl >= 2) return 1;  // Uptrend
      if(lh >= 2 && ll >= 2) return -1; // Downtrend
      return 0; // Ranging
   }
   
   static string GetStructureName() {
      int structure = GetTrendStructure();
      if(structure == 1) return "HH/HL UPTREND";
      if(structure == -1) return "LH/LL DOWNTREND";
      return "RANGING";
   }
   
   static int GetStructureScore(int direction) {
      int structure = GetTrendStructure();
      if(structure == direction) return 90;
      if(structure == -direction) return 20;
      return 50;
   }
};

//====================================================================
// EXTENSION MODULE 14: ORDER FLOW IMBALANCE
//====================================================================
class COrderFlowAnalyzer
{
public:
   static double GetBuyingPressure(int lookback = 10) {
      double bullVolume = 0, totalVolume = 0;
      
      for(int i = 1; i <= lookback; i++) {
         double open = iOpen(_Symbol, TF, i);
         double close = iClose(_Symbol, TF, i);
         double high = iHigh(_Symbol, TF, i);
         double low = iLow(_Symbol, TF, i);
         long vol = iVolume(_Symbol, TF, i);
         
         double range = high - low;
         if(range > 0) {
            double buyRatio = (close - low) / range;
            bullVolume += buyRatio * vol;
            totalVolume += (double)vol;
         }
      }
      
      return (totalVolume > 0) ? bullVolume / totalVolume * 100 : 50;
   }
   
   static double GetSellingPressure(int lookback = 10) {
      return 100 - GetBuyingPressure(lookback);
   }
   
   static int GetImbalanceSignal(int direction) {
      double buyPressure = GetBuyingPressure();
      
      if(direction == 1) {
         if(buyPressure > 65) return 85;
         if(buyPressure > 55) return 70;
         if(buyPressure < 40) return 25;
         return 50;
      } else {
         double sellPressure = 100 - buyPressure;
         if(sellPressure > 65) return 85;
         if(sellPressure > 55) return 70;
         if(sellPressure < 40) return 25;
         return 50;
      }
   }
   
   static bool IsBullishImbalance() { return (GetBuyingPressure() > 60); }
   static bool IsBearishImbalance() { return (GetSellingPressure() > 60); }
};

//====================================================================
// EXTENSION MODULE 15: MOMENTUM DETECTOR
//====================================================================
class CMomentumDetector
{
public:
   static double GetPriceROC(int period = 10) {
      double close0 = iClose(_Symbol, TF, 0);
      double closeN = iClose(_Symbol, TF, period);
      if(closeN == 0) return 0;
      return (close0 - closeN) / closeN * 100;
   }
   
   static double GetMomentumStrength(int period = 14) {
      double roc = GetPriceROC(period);
      return MathAbs(roc);
   }
   
   static bool IsAccelerating() {
      double roc1 = GetPriceROC(5);
      double roc2 = GetPriceROC(10);
      return (MathAbs(roc1) > MathAbs(roc2) * 1.2);
   }
   
   static bool IsDecelerating() {
      double roc1 = GetPriceROC(5);
      double roc2 = GetPriceROC(10);
      return (MathAbs(roc1) < MathAbs(roc2) * 0.8);
   }
   
   static int GetMomentumScore(int direction) {
      double roc = GetPriceROC();
      bool isAccel = IsAccelerating();
      
      int score = 50;
      if(direction == 1 && roc > 0) {
         score = 60;
         if(roc > 0.5) score = 75;
         if(isAccel) score += 15;
      } else if(direction == -1 && roc < 0) {
         score = 60;
         if(roc < -0.5) score = 75;
         if(isAccel) score += 15;
      } else if((direction == 1 && roc < 0) || (direction == -1 && roc > 0)) {
         score = 30;
      }
      
      return MathMin(100, score);
   }
};

//====================================================================
// GLOBAL OBJECTS FOR EXTENSIONS
//====================================================================
CDrawdownManager     DDManager;
CPerformanceTracker  PerfTracker;

//====================================================================
// UTILITY FUNCTIONS
//====================================================================
double NormalizePips(double pips) {
   return CPriceEngine::PipToPoints(pips);
}

double PipsToValue(double pips, double lot) {
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(tickValue <= 0) tickValue = 10.0;
   if(tickSize <= 0) tickSize = point;
   double pipValue = tickValue * (point / tickSize) * 10.0;
   return pips * pipValue * lot;
}

bool IsValidPrice(double price) {
   return (price > 0 && price < 999999);
}

bool IsValidLot(double lot) {
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   return (lot >= minLot && lot <= maxLot);
}

string DirectionToString(int direction) {
   if(direction == 1) return "BUY";
   if(direction == -1) return "SELL";
   return "NONE";
}

color DirectionToColor(int direction) {
   if(direction == 1) return BuyColor;
   if(direction == -1) return SellColor;
   return NeutralColor;
}

string SecondsToTimeString(int seconds) {
   int hours = seconds / 3600;
   int mins = (seconds % 3600) / 60;
   int secs = seconds % 60;
   return StringFormat("%02d:%02d:%02d", hours, mins, secs);
}

//====================================================================
// DEBUG & DIAGNOSTIC FUNCTIONS
//====================================================================
void PrintSystemStatus() {
   Print("════════════════════════════════════════════════════════════════════");
   Print("🤖 v13 SİSTEM DURUMU:");
   Print("   Paused: ", g_ManualPause);
   Print("   Locked: ", g_SystemLocked, " (", g_LockReason, ")");
   Print("   Session: ", Harmony.GetSessionName());
   Print("   Regime: ", VolAnalyzer.GetRegimeName());
   Print("   AI Score: ", g_LastSignalScore);
   Print("   Harmony Score: ", g_LastHarmonyScore);
   Print("   Positions: ", Executor.CountOpenPositions(), "/", MaxOpenPositions);
   Print("   Daily Trades: ", Security.GetTradeCount(), "/", MaxDailyTrades);
   Print("════════════════════════════════════════════════════════════════════");
}

void PrintIndicatorValues() {
   AIScorer.UpdateATR();
   Print("════════════════════════════════════════════════════════════════════");
   Print("📊 GÖSTERGE DEĞERLERİ:");
   Print("   ATR: ", DoubleToString(AIScorer.m_lastATR, 5));
   Print("   Spread: ", DoubleToString(CSymbolInfo::GetSpreadPips(), 1), " pip");
   Print("   Volatility: ", DoubleToString(VolAnalyzer.GetVolatilityRatio(), 2), "x");
   Print("   Trend Strength: ", DoubleToString(CPriceEngine::GetTrendStrength(TrendStrengthBars), 1));
   Print("   LR Slope: ", DoubleToString(CPriceEngine::CalculateLRSlope(LR_Period), 6));
   Print("   Structure: ", CMarketStructure::GetStructureName());
   Print("   Buy Pressure: ", DoubleToString(COrderFlowAnalyzer::GetBuyingPressure(), 1), "%");
   Print("════════════════════════════════════════════════════════════════════");
}

void PrintAllStats() {
   PosMgr.PrintStats();
   SignalHist.PrintAnalysis();
   DDManager.PrintStats();
   PerfTracker.PrintReport();
}

//+------------------------------------------------------------------+
//| v13.1 ULTIMATE 4K EDITION - COMPLETE                             |
//| 40+ Synchronized Modules | 4000+ Lines                           |
//| AI-Powered Signal Scoring | Multi-Factor Harmony System          |
//| Grid Matrix | Pending Orders | Signal History & Learning         |
//| Advanced Risk Management | Kelly Criterion | Compounding         |
//| Market Structure | Order Flow | Momentum Detection               |
//| Drawdown Manager | Performance Tracker | Trade Logger            |
//| Statistical Analysis | Alert System | Visual Dashboard           |
//| © 2025, Milyoner EA Project - The Ultimate Trading System v13.1  |
//+------------------------------------------------------------------+

//====================================================================
// EXTENSION MODULE 16: NEWS EVENT FILTER
//====================================================================
class CNewsFilter
{
private:
   struct NewsEvent {
      datetime time;
      string currency;
      int impact; // 1=Low, 2=Medium, 3=High
      string description;
   };
   
   NewsEvent m_events[];
   int m_eventCount;
   bool m_newsActive;
   
public:
   CNewsFilter() : m_eventCount(0), m_newsActive(false) {
      ArrayResize(m_events, 0);
   }
   
   void AddEvent(datetime time, string currency, int impact, string desc) {
      ArrayResize(m_events, m_eventCount + 1);
      m_events[m_eventCount].time = time;
      m_events[m_eventCount].currency = currency;
      m_events[m_eventCount].impact = impact;
      m_events[m_eventCount].description = desc;
      m_eventCount++;
   }
   
   bool IsNewsTime(int minutesBefore = 30, int minutesAfter = 15) {
      if(!UseNewsFilter) return false;
      
      datetime now = TimeCurrent();
      
      for(int i = 0; i < m_eventCount; i++) {
         if(m_events[i].impact >= NewsImpactLevel) {
            datetime start = m_events[i].time - minutesBefore * 60;
            datetime end = m_events[i].time + minutesAfter * 60;
            
            if(now >= start && now <= end) {
               m_newsActive = true;
               return true;
            }
         }
      }
      
      m_newsActive = false;
      return false;
   }
   
   string GetNextNewsEvent() {
      datetime now = TimeCurrent();
      datetime nearest = D'2099.12.31';
      int nearestIdx = -1;
      
      for(int i = 0; i < m_eventCount; i++) {
         if(m_events[i].time > now && m_events[i].time < nearest) {
            nearest = m_events[i].time;
            nearestIdx = i;
         }
      }
      
      if(nearestIdx >= 0) {
         return StringFormat("%s - %s (%d)", 
            TimeToString(m_events[nearestIdx].time, TIME_MINUTES),
            m_events[nearestIdx].description,
            m_events[nearestIdx].impact);
      }
      return "Yok";
   }
   
   void ClearOldEvents() {
      datetime now = TimeCurrent();
      int newCount = 0;
      
      for(int i = 0; i < m_eventCount; i++) {
         if(m_events[i].time > now - 3600) {
            if(newCount != i) {
               m_events[newCount].time = m_events[i].time;
               m_events[newCount].currency = m_events[i].currency;
               m_events[newCount].impact = m_events[i].impact;
               m_events[newCount].description = m_events[i].description;
            }
            newCount++;
         }
      }
      
      m_eventCount = newCount;
      ArrayResize(m_events, m_eventCount);
   }
   
   bool IsActive() { return m_newsActive; }
   int GetEventCount() { return m_eventCount; }
};

//====================================================================
// EXTENSION MODULE 17: HEDGE PROTECTION SYSTEM
//====================================================================
class CHedgeManager
{
private:
   bool m_hedgeActive;
   ulong m_hedgeTicket;
   double m_hedgeLot;
   int m_originalDirection;
   double m_originalEntry;
   
public:
   CHedgeManager() : m_hedgeActive(false), m_hedgeTicket(0), m_hedgeLot(0),
      m_originalDirection(0), m_originalEntry(0) {}
   
   bool ShouldActivateHedge(int direction, double currentPrice, double entryPrice, double slDistance) {
      if(!UseHedge) return false;
      if(m_hedgeActive) return false;
      
      double loss = (direction == 1) ? (entryPrice - currentPrice) : (currentPrice - entryPrice);
      double triggerDist = slDistance * (Hedge_TriggerPct / 100.0);
      
      return (loss >= triggerDist);
   }
   
   bool OpenHedge(CTrade &trade, int direction, double lot) {
      if(m_hedgeActive) return false;
      
      double hedgeLot = NormalizeDouble(lot * (Hedge_LotPercent / 100.0), 2);
      hedgeLot = MathMax(hedgeLot, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
      
      int hedgeDir = -direction;
      
      if(hedgeDir == 1) {
         trade.Buy(hedgeLot, _Symbol, 0, 0, 0, "HEDGE");
      } else {
         trade.Sell(hedgeLot, _Symbol, 0, 0, 0, "HEDGE");
      }
      
      if(trade.ResultRetcode() == TRADE_RETCODE_DONE) {
         m_hedgeActive = true;
         m_hedgeTicket = trade.ResultOrder();
         m_hedgeLot = hedgeLot;
         m_originalDirection = direction;
         Print("🛡️ HEDGE açıldı: ", (hedgeDir == 1 ? "BUY" : "SELL"), " ", hedgeLot);
         return true;
      }
      return false;
   }
   
   void CloseHedge(CTrade &trade) {
      if(!m_hedgeActive) return;
      
      if(PositionSelectByTicket(m_hedgeTicket)) {
         trade.PositionClose(m_hedgeTicket);
         Print("🛡️ HEDGE kapatıldı");
      }
      
      m_hedgeActive = false;
      m_hedgeTicket = 0;
      m_hedgeLot = 0;
   }
   
   bool IsActive() { return m_hedgeActive; }
   ulong GetTicket() { return m_hedgeTicket; }
};

//====================================================================
// EXTENSION MODULE 18: EQUITY CURVE ANALYZER
//====================================================================
class CEquityCurveAnalyzer
{
private:
   double m_equityHistory[];
   int m_historySize;
   int m_maxHistory;
   
public:
   CEquityCurveAnalyzer() : m_historySize(0), m_maxHistory(1000) {
      ArrayResize(m_equityHistory, m_maxHistory);
      ArrayInitialize(m_equityHistory, 0);
   }
   
   void RecordEquity() {
      if(m_historySize >= m_maxHistory) {
         for(int i = 0; i < m_maxHistory - 1; i++) {
            m_equityHistory[i] = m_equityHistory[i + 1];
         }
         m_historySize = m_maxHistory - 1;
      }
      
      m_equityHistory[m_historySize] = AccountInfoDouble(ACCOUNT_EQUITY);
      m_historySize++;
   }
   
   double GetEquitySlope(int period = 20) {
      if(m_historySize < period) return 0;
      
      double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
      int n = period;
      int startIdx = m_historySize - period;
      
      for(int i = 0; i < n; i++) {
         double x = i;
         double y = m_equityHistory[startIdx + i];
         sumX += x;
         sumY += y;
         sumXY += x * y;
         sumX2 += x * x;
      }
      
      double denom = n * sumX2 - sumX * sumX;
      if(denom == 0) return 0;
      
      return (n * sumXY - sumX * sumY) / denom;
   }
   
   bool IsEquityCurvePositive() {
      return (GetEquitySlope() > 0);
   }
   
   bool IsEquityCurveStronglyPositive() {
      return (GetEquitySlope() > 10);
   }
   
   double GetEquityStdDev(int period = 20) {
      if(m_historySize < period) return 0;
      
      int startIdx = m_historySize - period;
      double sum = 0;
      
      for(int i = 0; i < period; i++) {
         sum += m_equityHistory[startIdx + i];
      }
      double mean = sum / period;
      
      double sumSq = 0;
      for(int i = 0; i < period; i++) {
         sumSq += MathPow(m_equityHistory[startIdx + i] - mean, 2);
      }
      
      return MathSqrt(sumSq / (period - 1));
   }
   
   int GetHistorySize() { return m_historySize; }
};

//====================================================================
// EXTENSION MODULE 19: CORRELATION MATRIX
//====================================================================
class CCorrelationAnalyzer
{
public:
   static double CalculatePairCorrelation(string symbol1, string symbol2, ENUM_TIMEFRAMES tf, int period) {
      double prices1[], prices2[];
      ArrayResize(prices1, period);
      ArrayResize(prices2, period);
      
      for(int i = 0; i < period; i++) {
         prices1[i] = iClose(symbol1, tf, i);
         prices2[i] = iClose(symbol2, tf, i);
      }
      
      return CStatistics::Correlation(prices1, prices2, period);
   }
   
   static bool IsHighlyCorrelated(string symbol1, string symbol2, double threshold = 0.7) {
      double corr = CalculatePairCorrelation(symbol1, symbol2, PERIOD_H1, 100);
      return (MathAbs(corr) >= threshold);
   }
   
   static bool IsNegativelyCorrelated(string symbol1, string symbol2, double threshold = -0.7) {
      double corr = CalculatePairCorrelation(symbol1, symbol2, PERIOD_H1, 100);
      return (corr <= threshold);
   }
   
   static string GetCorrelationType(double correlation) {
      if(correlation >= 0.8) return "Çok Güçlü +";
      if(correlation >= 0.6) return "Güçlü +";
      if(correlation >= 0.3) return "Orta +";
      if(correlation >= -0.3) return "Zayıf";
      if(correlation >= -0.6) return "Orta -";
      if(correlation >= -0.8) return "Güçlü -";
      return "Çok Güçlü -";
   }
};

//====================================================================
// EXTENSION MODULE 20: PRICE ACTION PATTERNS
//====================================================================
class CPriceAction
{
public:
   static bool IsInsideBar(int shift = 0) {
      double high0 = iHigh(_Symbol, TF, shift);
      double low0 = iLow(_Symbol, TF, shift);
      double high1 = iHigh(_Symbol, TF, shift + 1);
      double low1 = iLow(_Symbol, TF, shift + 1);
      return (high0 < high1 && low0 > low1);
   }
   
   static bool IsOutsideBar(int shift = 0) {
      double high0 = iHigh(_Symbol, TF, shift);
      double low0 = iLow(_Symbol, TF, shift);
      double high1 = iHigh(_Symbol, TF, shift + 1);
      double low1 = iLow(_Symbol, TF, shift + 1);
      return (high0 > high1 && low0 < low1);
   }
   
   static bool IsBullishPinBar(int shift = 1) {
      double open = iOpen(_Symbol, TF, shift);
      double close = iClose(_Symbol, TF, shift);
      double high = iHigh(_Symbol, TF, shift);
      double low = iLow(_Symbol, TF, shift);
      
      double body = MathAbs(close - open);
      double range = high - low;
      double lowerWick = MathMin(open, close) - low;
      double upperWick = high - MathMax(open, close);
      
      if(range == 0) return false;
      
      return (lowerWick / range > 0.6 && body / range < 0.25 && upperWick / range < 0.15);
   }
   
   static bool IsBearishPinBar(int shift = 1) {
      double open = iOpen(_Symbol, TF, shift);
      double close = iClose(_Symbol, TF, shift);
      double high = iHigh(_Symbol, TF, shift);
      double low = iLow(_Symbol, TF, shift);
      
      double body = MathAbs(close - open);
      double range = high - low;
      double lowerWick = MathMin(open, close) - low;
      double upperWick = high - MathMax(open, close);
      
      if(range == 0) return false;
      
      return (upperWick / range > 0.6 && body / range < 0.25 && lowerWick / range < 0.15);
   }
   
   static bool IsBreakout(int direction, int lookback = 20) {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      if(direction == 1) {
         double highest = 0;
         for(int i = 1; i <= lookback; i++) {
            double h = iHigh(_Symbol, TF, i);
            if(h > highest) highest = h;
         }
         return (price > highest);
      } else {
         double lowest = 999999;
         for(int i = 1; i <= lookback; i++) {
            double l = iLow(_Symbol, TF, i);
            if(l < lowest) lowest = l;
         }
         return (price < lowest);
      }
   }
   
   static bool IsFalseBreakout(int direction, int lookback = 5) {
      if(!IsBreakout(-direction, lookback + 5)) return false;
      return IsBreakout(direction, lookback);
   }
   
   static double GetAverageCandleSize(int period = 20) {
      double sum = 0;
      for(int i = 1; i <= period; i++) {
         sum += iHigh(_Symbol, TF, i) - iLow(_Symbol, TF, i);
      }
      return sum / period;
   }
   
   static int GetPriceActionScore(int direction) {
      int score = 50;
      
      if(IsBreakout(direction)) score += 25;
      if(direction == 1 && IsBullishPinBar()) score += 20;
      if(direction == -1 && IsBearishPinBar()) score += 20;
      if(IsInsideBar() && IsBreakout(direction, 5)) score += 15;
      if(IsFalseBreakout(direction)) score += 30;
      
      return MathMin(100, score);
   }
};

//====================================================================
// EXTENSION MODULE 21: MULTI-SYMBOL SCANNER
//====================================================================
class CSymbolScanner
{
private:
   string m_symbols[];
   int m_symbolCount;
   
public:
   CSymbolScanner() : m_symbolCount(0) {
      ArrayResize(m_symbols, 0);
   }
   
   void AddSymbol(string symbol) {
      ArrayResize(m_symbols, m_symbolCount + 1);
      m_symbols[m_symbolCount] = symbol;
      m_symbolCount++;
   }
   
   void InitDefaultForexPairs() {
      AddSymbol("EURUSD");
      AddSymbol("GBPUSD");
      AddSymbol("USDJPY");
      AddSymbol("USDCHF");
      AddSymbol("AUDUSD");
      AddSymbol("USDCAD");
      AddSymbol("NZDUSD");
      AddSymbol("EURGBP");
      AddSymbol("EURJPY");
      AddSymbol("GBPJPY");
   }
   
   double GetSymbolSpread(string symbol) {
      return (double)SymbolInfoInteger(symbol, SYMBOL_SPREAD) / 10.0;
   }
   
   double GetSymbolATR(string symbol, int period = 14) {
      int handle = iATR(symbol, TF, period);
      if(handle == INVALID_HANDLE) return 0;
      
      double atr[];
      ArraySetAsSeries(atr, true);
      if(CopyBuffer(handle, 0, 0, 1, atr) >= 1) {
         IndicatorRelease(handle);
         return atr[0];
      }
      IndicatorRelease(handle);
      return 0;
   }
   
   string GetBestSymbol() {
      string best = "";
      double bestScore = 0;
      
      for(int i = 0; i < m_symbolCount; i++) {
         double spread = GetSymbolSpread(m_symbols[i]);
         double atr = GetSymbolATR(m_symbols[i]);
         
         if(spread > 0 && atr > 0) {
            double score = atr * 10000 / spread;
            if(score > bestScore) {
               bestScore = score;
               best = m_symbols[i];
            }
         }
      }
      return best;
   }
   
   int GetSymbolCount() { return m_symbolCount; }
};

//====================================================================
// EXTENSION MODULE 22: ADAPTIVE PARAMETERS
//====================================================================
class CAdaptiveParams
{
public:
   static int GetAdaptiveThreshold(double winRate, double volatility) {
      int base = MinSignalScore;
      
      if(winRate > 70) base -= 5;
      else if(winRate < 50) base += 10;
      
      if(volatility > 1.5) base += 5;
      else if(volatility < 0.7) base -= 5;
      
      return MathMax(40, MathMin(80, base));
   }
   
   static double GetAdaptiveLotMultiplier(double winRate, int consecutiveWins) {
      double multi = 1.0;
      
      if(winRate > 75 && consecutiveWins >= 3) {
         multi = 1.25;
      } else if(winRate > 80 && consecutiveWins >= 5) {
         multi = 1.5;
      } else if(winRate < 45) {
         multi = 0.75;
      }
      
      return multi;
   }
   
   static double GetAdaptiveSLMultiplier(double volatility) {
      if(volatility > 2.0) return 1.5;
      if(volatility > 1.5) return 1.25;
      if(volatility < 0.5) return 0.8;
      return 1.0;
   }
   
   static double GetAdaptiveTPMultiplier(double winRate) {
      if(winRate > 75) return 1.5;
      if(winRate > 65) return 1.25;
      if(winRate < 50) return 0.9;
      return 1.0;
   }
};

//====================================================================
// EXTENSION MODULE 23: SPREAD ANALYZER
//====================================================================
class CSpreadAnalyzer
{
private:
   double m_spreadHistory[];
   int m_historySize;
   int m_maxHistory;
   double m_avgSpread;
   double m_minSpread;
   double m_maxSpread;
   
public:
   CSpreadAnalyzer() : m_historySize(0), m_maxHistory(500), m_avgSpread(0), m_minSpread(999), m_maxSpread(0) {
      ArrayResize(m_spreadHistory, m_maxHistory);
      ArrayInitialize(m_spreadHistory, 0);
   }
   
   void RecordSpread() {
      double spread = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0;
      
      if(m_historySize >= m_maxHistory) {
         for(int i = 0; i < m_maxHistory - 1; i++) {
            m_spreadHistory[i] = m_spreadHistory[i + 1];
         }
         m_historySize = m_maxHistory - 1;
      }
      
      m_spreadHistory[m_historySize] = spread;
      m_historySize++;
      
      if(spread < m_minSpread) m_minSpread = spread;
      if(spread > m_maxSpread) m_maxSpread = spread;
      
      double sum = 0;
      for(int i = 0; i < m_historySize; i++) sum += m_spreadHistory[i];
      m_avgSpread = sum / m_historySize;
   }
   
   bool IsSpreadNormal() {
      double current = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0;
      return (current <= m_avgSpread * 1.5);
   }
   
   bool IsSpreadLow() {
      double current = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0;
      return (current <= m_avgSpread * 0.8);
   }
   
   bool IsSpreadHigh() {
      double current = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0;
      return (current >= m_avgSpread * 2.0);
   }
   
   double GetCurrentSpread() {
      return (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0;
   }
   
   double GetAverageSpread() { return m_avgSpread; }
   double GetMinSpread() { return m_minSpread; }
   double GetMaxSpread() { return m_maxSpread; }
};

//====================================================================
// EXTENSION MODULE 24: SESSION VOLATILITY TRACKER
//====================================================================
class CSessionVolatility
{
private:
   double m_asiaATR, m_londonATR, m_nyATR, m_overlapATR;
   int m_asiaCount, m_londonCount, m_nyCount, m_overlapCount;
   
public:
   CSessionVolatility() : m_asiaATR(0), m_londonATR(0), m_nyATR(0), m_overlapATR(0),
      m_asiaCount(0), m_londonCount(0), m_nyCount(0), m_overlapCount(0) {}
   
   void RecordATR(double atr) {
      MqlDateTime dt;
      TimeCurrent(dt);
      int h = dt.hour;
      
      if(h >= 0 && h < 8) {
         m_asiaATR = (m_asiaATR * m_asiaCount + atr) / (m_asiaCount + 1);
         m_asiaCount++;
      } else if(h >= 8 && h < 12) {
         m_londonATR = (m_londonATR * m_londonCount + atr) / (m_londonCount + 1);
         m_londonCount++;
      } else if(h >= 12 && h < 17) {
         m_overlapATR = (m_overlapATR * m_overlapCount + atr) / (m_overlapCount + 1);
         m_overlapCount++;
      } else if(h >= 17 && h < 22) {
         m_nyATR = (m_nyATR * m_nyCount + atr) / (m_nyCount + 1);
         m_nyCount++;
      }
   }
   
   double GetSessionATR(string session) {
      if(session == "ASYA" || session == "ASIA") return m_asiaATR;
      if(session == "LONDRA" || session == "LONDON") return m_londonATR;
      if(session == "OVERLAP") return m_overlapATR;
      if(session == "NEW YORK" || session == "NY") return m_nyATR;
      return 0;
   }
   
   string GetMostVolatileSession() {
      double max = m_asiaATR;
      string session = "ASYA";
      
      if(m_londonATR > max) { max = m_londonATR; session = "LONDRA"; }
      if(m_overlapATR > max) { max = m_overlapATR; session = "OVERLAP"; }
      if(m_nyATR > max) { max = m_nyATR; session = "NEW YORK"; }
      
      return session;
   }
   
   double GetCurrentVsAvgRatio(double lastATR, string currentSession) {
      double sessionATR = GetSessionATR(currentSession);
      if(sessionATR == 0) return 1.0;
      return lastATR / sessionATR;
   }
};

//====================================================================
// EXTENSION MODULE 25: TRADE ZONE MANAGER
//====================================================================
class CTradeZone
{
private:
   struct Zone {
      double priceHigh;
      double priceLow;
      int touchCount;
      bool isBullish;
      datetime created;
   };
   
   Zone m_demandZones[];
   Zone m_supplyZones[];
   int m_demandCount;
   int m_supplyCount;
   
public:
   CTradeZone() : m_demandCount(0), m_supplyCount(0) {
      ArrayResize(m_demandZones, 0);
      ArrayResize(m_supplyZones, 0);
   }
   
   void AddDemandZone(double high, double low) {
      ArrayResize(m_demandZones, m_demandCount + 1);
      m_demandZones[m_demandCount].priceHigh = high;
      m_demandZones[m_demandCount].priceLow = low;
      m_demandZones[m_demandCount].touchCount = 0;
      m_demandZones[m_demandCount].isBullish = true;
      m_demandZones[m_demandCount].created = TimeCurrent();
      m_demandCount++;
   }
   
   void AddSupplyZone(double high, double low) {
      ArrayResize(m_supplyZones, m_supplyCount + 1);
      m_supplyZones[m_supplyCount].priceHigh = high;
      m_supplyZones[m_supplyCount].priceLow = low;
      m_supplyZones[m_supplyCount].touchCount = 0;
      m_supplyZones[m_supplyCount].isBullish = false;
      m_supplyZones[m_supplyCount].created = TimeCurrent();
      m_supplyCount++;
   }
   
   bool IsInDemandZone(double price) {
      for(int i = 0; i < m_demandCount; i++) {
         if(price >= m_demandZones[i].priceLow && price <= m_demandZones[i].priceHigh) {
            m_demandZones[i].touchCount++;
            return true;
         }
      }
      return false;
   }
   
   bool IsInSupplyZone(double price) {
      for(int i = 0; i < m_supplyCount; i++) {
         if(price >= m_supplyZones[i].priceLow && price <= m_supplyZones[i].priceHigh) {
            m_supplyZones[i].touchCount++;
            return true;
         }
      }
      return false;
   }
   
   int GetZoneScore(int direction) {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      if(direction == 1 && IsInDemandZone(price)) return 85;
      if(direction == -1 && IsInSupplyZone(price)) return 85;
      if(direction == 1 && IsInSupplyZone(price)) return 25;
      if(direction == -1 && IsInDemandZone(price)) return 25;
      
      return 50;
   }
   
   void DetectZonesFromHistory(int lookback = 100) {
      for(int i = 3; i < lookback - 3; i++) {
         double high = iHigh(_Symbol, TF, i);
         double low = iLow(_Symbol, TF, i);
         double close = iClose(_Symbol, TF, i);
         double open = iOpen(_Symbol, TF, i);
         
         bool isBullishEngulf = (close > open) && 
            (close > iHigh(_Symbol, TF, i+1)) && 
            (open < iLow(_Symbol, TF, i+1));
         
         bool isBearishEngulf = (close < open) && 
            (close < iLow(_Symbol, TF, i+1)) && 
            (open > iHigh(_Symbol, TF, i+1));
         
         if(isBullishEngulf) AddDemandZone(iHigh(_Symbol, TF, i+1), iLow(_Symbol, TF, i+1));
         if(isBearishEngulf) AddSupplyZone(iHigh(_Symbol, TF, i+1), iLow(_Symbol, TF, i+1));
      }
   }
};

//====================================================================
// GLOBAL OBJECTS FOR NEW EXTENSIONS
//====================================================================
CNewsFilter          NewsFilter;
CHedgeManager        HedgeMgr;
CEquityCurveAnalyzer EquityCurve;
CSpreadAnalyzer      SpreadAnalyzer;
CSessionVolatility   SessionVol;
CTradeZone           TradeZones;

//====================================================================
// ADDITIONAL UTILITY FUNCTIONS
//====================================================================
void OnTickExtended2() {
   // Record spread
   SpreadAnalyzer.RecordSpread();
   
   // Record equity
   EquityCurve.RecordEquity();
   
   // Record session volatility
   SessionVol.RecordATR(AIScorer.m_lastATR);
   
   // Check news filter
   if(NewsFilter.IsNewsTime()) {
      if(ShowDebugLog) Print("📰 Haber zamanı - işlem durdu");
      return;
   }
   
   // Check hedge conditions
   if(UseHedge && Executor.HasOpenPosition() && !HedgeMgr.IsActive()) {
      // Hedge kontrolü yapılabilir
   }
}

string GetFullSystemStatus() {
   string status = "";
   status += "═══════════════════════════════════════\n";
   status += "🤖 v13.1 ULTIMATE 4K SYSTEM STATUS\n";
   status += "═══════════════════════════════════════\n";
   status += "Session: " + Harmony.GetSessionName() + "\n";
   status += "Regime: " + VolAnalyzer.GetRegimeName() + "\n";
   status += "Spread: " + DoubleToString(SpreadAnalyzer.GetCurrentSpread(), 1) + " pip\n";
   status += "Equity Curve: " + (EquityCurve.IsEquityCurvePositive() ? "UP" : "DOWN") + "\n";
   status += "News Active: " + (NewsFilter.IsActive() ? "YES" : "NO") + "\n";
   status += "Hedge Active: " + (HedgeMgr.IsActive() ? "YES" : "NO") + "\n";
   status += "═══════════════════════════════════════\n";
   return status;
}

void InitializeExtendedModules() {
   NewsFilter.ClearOldEvents();
   TradeZones.DetectZonesFromHistory(100);
   Print("📊 v13.1 Extended modules initialized");
}
//+------------------------------------------------------------------+
//| v13.1 ULTIMATE 4K EDITION - COMPLETE                             |
//| 40+ Synchronized Modules | 4000+ Lines                           |
//| Features: AI Signal Scoring, Harmony System, Grid Matrix          |
//| News Filter, Hedge Protection, Equity Curve Analysis             |
//| Supply/Demand Zones, Session Volatility, Spread Analysis         |
//| Multi-Symbol Scanner, Adaptive Parameters, Price Action          |
//| Correlation Analysis, Market Structure, Order Flow               |
//| Kelly Criterion, Compounding, Drawdown Management                |
//| Performance Tracking, Trade Logging, Alert System                |
//| Visual Dashboard, Keyboard Controls, Emergency Close             |
//| © 2025, Milyoner EA Project - The Ultimate Trading System v13.1  |
//+------------------------------------------------------------------+

//====================================================================
// EXTENSION MODULE 26: CANDLE STRENGTH ANALYZER
//====================================================================
class CCandleStrength
{
public:
   static double GetBullishStrength(int lookback = 10) {
      int bullishCount = 0;
      double bullishVolume = 0;
      
      for(int i = 1; i <= lookback; i++) {
         double open = iOpen(_Symbol, TF, i);
         double close = iClose(_Symbol, TF, i);
         if(close > open) {
            bullishCount++;
            bullishVolume += (double)iVolume(_Symbol, TF, i);
         }
      }
      
      return (double)bullishCount / lookback * 100;
   }
   
   static double GetBearishStrength(int lookback = 10) {
      return 100 - GetBullishStrength(lookback);
   }
   
   static double GetAverageCandleBody(int period = 20) {
      double sum = 0;
      for(int i = 1; i <= period; i++) {
         sum += MathAbs(iClose(_Symbol, TF, i) - iOpen(_Symbol, TF, i));
      }
      return sum / period;
   }
   
   static double GetBodyToRangeRatio(int shift = 0) {
      double body = MathAbs(iClose(_Symbol, TF, shift) - iOpen(_Symbol, TF, shift));
      double range = iHigh(_Symbol, TF, shift) - iLow(_Symbol, TF, shift);
      if(range == 0) return 0;
      return body / range * 100;
   }
   
   static bool IsStrongCandle(int shift = 0) {
      return (GetBodyToRangeRatio(shift) > 70);
   }
   
   static bool IsWeakCandle(int shift = 0) {
      return (GetBodyToRangeRatio(shift) < 30);
   }
};

//====================================================================
// EXTENSION MODULE 27: VOLUME PROFILE
//====================================================================
class CVolumeProfile
{
public:
   static double GetVolumeWeightedPrice(int period = 20) {
      double sumPV = 0, sumV = 0;
      
      for(int i = 1; i <= period; i++) {
         double price = (iHigh(_Symbol, TF, i) + iLow(_Symbol, TF, i) + iClose(_Symbol, TF, i)) / 3;
         long vol = iVolume(_Symbol, TF, i);
         sumPV += price * (double)vol;
         sumV += (double)vol;
      }
      
      return (sumV > 0) ? sumPV / sumV : 0;
   }
   
   static bool IsPriceAboveVWAP() {
      return (SymbolInfoDouble(_Symbol, SYMBOL_BID) > GetVolumeWeightedPrice());
   }
   
   static bool IsPriceBelowVWAP() {
      return (SymbolInfoDouble(_Symbol, SYMBOL_BID) < GetVolumeWeightedPrice());
   }
   
   static double GetVolumeRatio(int period = 20) {
      if(period < 2) return 1.0;
      
      long currentVol = iVolume(_Symbol, TF, 1);
      long avgVol = 0;
      
      for(int i = 2; i <= period; i++) {
         avgVol += iVolume(_Symbol, TF, i);
      }
      avgVol /= (period - 1);
      
      if(avgVol == 0) return 1.0;
      return (double)currentVol / (double)avgVol;
   }
   
   static bool IsHighVolume() {
      return (GetVolumeRatio() > 1.5);
   }
   
   static bool IsLowVolume() {
      return (GetVolumeRatio() < 0.5);
   }
};

//====================================================================
// EXTENSION MODULE 28: TREND QUALITY ANALYZER
//====================================================================
class CTrendQuality
{
public:
   static double GetTrendConsistency(int period = 20) {
      int consistent = 0;
      
      for(int i = 1; i < period; i++) {
         double close1 = iClose(_Symbol, TF, i);
         double close2 = iClose(_Symbol, TF, i + 1);
         
         if(i == 1) continue;
         
         double close0 = iClose(_Symbol, TF, i - 1);
         bool upMove = (close1 > close2);
         bool prevUpMove = (close0 > close1);
         
         if(upMove == prevUpMove) consistent++;
      }
      
      return (double)consistent / (period - 2) * 100;
   }
   
   static int GetTrendBars(int maxLookback = 50) {
      int bars = 0;
      double firstClose = iClose(_Symbol, TF, 1);
      double secondClose = iClose(_Symbol, TF, 2);
      bool isUp = (firstClose > secondClose);
      
      for(int i = 2; i < maxLookback; i++) {
         double c1 = iClose(_Symbol, TF, i);
         double c2 = iClose(_Symbol, TF, i + 1);
         bool currentUp = (c1 > c2);
         
         if(currentUp != isUp) break;
         bars++;
      }
      
      return bars;
   }
   
   static double GetTrendAngle(int period = 20) {
      double y1 = iClose(_Symbol, TF, period);
      double y2 = iClose(_Symbol, TF, 0);
      double diff = y2 - y1;
      double avgPrice = (y1 + y2) / 2;
      
      return MathArctan(diff / avgPrice * 100) * 180 / M_PI;
   }
   
   static bool IsStrongTrend() {
      return (GetTrendConsistency() > 70 && GetTrendBars() > 10);
   }
};

//+------------------------------------------------------------------+
//| v13.1 ULTIMATE 4K EDITION - FINAL                                |
//| 40+ Synchronized Modules | 4000+ Lines                           |
//| © 2025, Milyoner EA Project - The Ultimate Trading System v13.1  |
//+------------------------------------------------------------------+

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 27: MACHINE LEARNING SIMULATOR
//====================================================================
class CMLSimulator
{
private:
   double m_signalWeights[10];           // 10 faktör ağırlıkları
   double m_winHistory[];                // Kazanç/kayıp geçmişi
   int    m_historyIndex;
   int    m_historySize;
   double m_learningRate;
   int    m_optimizationPeriod;
   datetime m_lastOptimization;
   
   struct SignalRecord {
      double factors[10];                // Sinyal faktörleri
      int result;                        // 1=win, -1=loss, 0=pending
      datetime time;
   };
   SignalRecord m_records[];
   int m_recordCount;
   
public:
   CMLSimulator() : m_historyIndex(0), m_historySize(100), m_learningRate(0.01),
                    m_optimizationPeriod(50), m_lastOptimization(0), m_recordCount(0) {
      ArrayResize(m_winHistory, m_historySize);
      ArrayResize(m_records, 200);
      ArrayInitialize(m_signalWeights, 1.0);
   }
   
   void Init() {
      // Varsayılan ağırlıkları input'lardan al
      m_signalWeights[0] = Weight_MACross;
      m_signalWeights[1] = Weight_MACD;
      m_signalWeights[2] = Weight_RSI;
      m_signalWeights[3] = Weight_ADX;
      m_signalWeights[4] = Weight_Stoch;
      m_signalWeights[5] = Weight_CCI;
      m_signalWeights[6] = Weight_Pattern;
      m_signalWeights[7] = Weight_Wick;
      m_signalWeights[8] = Weight_Level;
      m_signalWeights[9] = Weight_Divergence;
      NormalizeWeights();
   }
   
   void NormalizeWeights() {
      double total = 0;
      for(int i = 0; i < 10; i++) total += m_signalWeights[i];
      if(total > 0) {
         for(int i = 0; i < 10; i++) m_signalWeights[i] = (m_signalWeights[i] / total) * 100.0;
      }
   }
   
   void RecordSignal(double &factors[], int direction) {
      if(m_recordCount >= 200) {
         // Eski kayıtları kaydır
         for(int i = 0; i < 199; i++) m_records[i] = m_records[i+1];
         m_recordCount = 199;
      }
      for(int i = 0; i < 10; i++) m_records[m_recordCount].factors[i] = factors[i];
      m_records[m_recordCount].result = 0;
      m_records[m_recordCount].time = TimeCurrent();
      m_recordCount++;
   }
   
   void UpdateResult(bool isWin) {
      // Son bekleyen sinyali güncelle
      for(int i = m_recordCount - 1; i >= 0; i--) {
         if(m_records[i].result == 0) {
            m_records[i].result = isWin ? 1 : -1;
            m_winHistory[m_historyIndex] = isWin ? 1.0 : 0.0;
            m_historyIndex = (m_historyIndex + 1) % m_historySize;
            break;
         }
      }
      
      // Periyodik optimizasyon
      if(GetRecordedWins() + GetRecordedLosses() >= m_optimizationPeriod) {
         OptimizeWeights();
      }
   }
   
   void OptimizeWeights() {
      if(TimeCurrent() - m_lastOptimization < 3600) return; // Saatte 1 kez
      
      double winFactorSum[10] = {0};
      double lossFactorSum[10] = {0};
      int winCount = 0, lossCount = 0;
      
      for(int i = 0; i < m_recordCount; i++) {
         if(m_records[i].result == 1) {
            for(int j = 0; j < 10; j++) winFactorSum[j] += m_records[i].factors[j];
            winCount++;
         } else if(m_records[i].result == -1) {
            for(int j = 0; j < 10; j++) lossFactorSum[j] += m_records[i].factors[j];
            lossCount++;
         }
      }
      
      if(winCount > 0 && lossCount > 0) {
         for(int i = 0; i < 10; i++) {
            double winAvg = winFactorSum[i] / winCount;
            double lossAvg = lossFactorSum[i] / lossCount;
            double ratio = (winAvg + 0.01) / (lossAvg + 0.01);
            m_signalWeights[i] += m_learningRate * (ratio - 1.0) * m_signalWeights[i];
            m_signalWeights[i] = MathMax(1.0, MathMin(30.0, m_signalWeights[i]));
         }
         NormalizeWeights();
         Print("🧠 ML: Ağırlıklar optimize edildi. WR: ", GetMLWinRate(), "%");
      }
      
      m_lastOptimization = TimeCurrent();
   }
   
   int GetRecordedWins() {
      int count = 0;
      for(int i = 0; i < m_recordCount; i++) if(m_records[i].result == 1) count++;
      return count;
   }
   
   int GetRecordedLosses() {
      int count = 0;
      for(int i = 0; i < m_recordCount; i++) if(m_records[i].result == -1) count++;
      return count;
   }
   
   double GetMLWinRate() {
      int wins = GetRecordedWins();
      int total = wins + GetRecordedLosses();
      if(total == 0) return 50.0;
      return (double)wins / total * 100.0;
   }
   
   double GetWeight(int idx) {
      if(idx < 0 || idx >= 10) return 10.0;
      return m_signalWeights[idx];
   }
   
   double GetAdaptiveScore(double &rawScores[]) {
      double total = 0;
      for(int i = 0; i < 10; i++) {
         total += rawScores[i] * m_signalWeights[i] / 100.0;
      }
      return total;
   }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 28: SMART ENTRY TIMING
//====================================================================
class CSmartEntryTiming
{
private:
   double m_volatilityHistory[];
   int    m_historySize;
   int    m_historyIndex;
   double m_optimalVolatilityMin;
   double m_optimalVolatilityMax;
   datetime m_lastEntryTime;
   int    m_minBarsBetweenTrades;
   
   struct TimingStats {
      int hour;
      int trades;
      int wins;
      double avgProfit;
   };
   TimingStats m_hourlyStats[24];
   
public:
   CSmartEntryTiming() : m_historySize(100), m_historyIndex(0),
                         m_optimalVolatilityMin(0.5), m_optimalVolatilityMax(2.0),
                         m_lastEntryTime(0), m_minBarsBetweenTrades(3) {
      ArrayResize(m_volatilityHistory, m_historySize);
      ArrayInitialize(m_volatilityHistory, 0);
      for(int i = 0; i < 24; i++) {
         m_hourlyStats[i].hour = i;
         m_hourlyStats[i].trades = 0;
         m_hourlyStats[i].wins = 0;
         m_hourlyStats[i].avgProfit = 0;
      }
   }
   
   void RecordVolatility(double atr) {
      m_volatilityHistory[m_historyIndex] = atr;
      m_historyIndex = (m_historyIndex + 1) % m_historySize;
   }
   
   double GetAvgVolatility() {
      double sum = 0;
      int count = 0;
      for(int i = 0; i < m_historySize; i++) {
         if(m_volatilityHistory[i] > 0) {
            sum += m_volatilityHistory[i];
            count++;
         }
      }
      return count > 0 ? sum / count : 0;
   }
   
   bool IsOptimalVolatility(double currentATR) {
      double avg = GetAvgVolatility();
      if(avg == 0) return true;
      double ratio = currentATR / avg;
      return (ratio >= m_optimalVolatilityMin && ratio <= m_optimalVolatilityMax);
   }
   
   void RecordTrade(int hour, bool isWin, double profit) {
      if(hour < 0 || hour >= 24) return;
      m_hourlyStats[hour].trades++;
      if(isWin) m_hourlyStats[hour].wins++;
      m_hourlyStats[hour].avgProfit = 
         (m_hourlyStats[hour].avgProfit * (m_hourlyStats[hour].trades - 1) + profit) / 
         m_hourlyStats[hour].trades;
   }
   
   double GetHourlyWinRate(int hour) {
      if(hour < 0 || hour >= 24) return 50.0;
      if(m_hourlyStats[hour].trades == 0) return 50.0;
      return (double)m_hourlyStats[hour].wins / m_hourlyStats[hour].trades * 100.0;
   }
   
   bool IsOptimalHour() {
      MqlDateTime dt;
      TimeCurrent(dt);
      int hour = dt.hour;
      
      // Yeterli veri yoksa geç
      if(m_hourlyStats[hour].trades < 5) return true;
      
      // Win rate %40'ın altındaysa bu saatte işlem yapma
      if(GetHourlyWinRate(hour) < 40.0) return false;
      
      return true;
   }
   
   bool CanEnterNow() {
      datetime now = TimeCurrent();
      if(now - m_lastEntryTime < m_minBarsBetweenTrades * PeriodSeconds(TF)) return false;
      if(!IsOptimalHour()) return false;
      return true;
   }
   
   void OnEntry() {
      m_lastEntryTime = TimeCurrent();
   }
   
   int GetBestHour() {
      int bestHour = 0;
      double bestRate = 0;
      for(int i = 0; i < 24; i++) {
         if(m_hourlyStats[i].trades >= 5) {
            double rate = GetHourlyWinRate(i);
            if(rate > bestRate) {
               bestRate = rate;
               bestHour = i;
            }
         }
      }
      return bestHour;
   }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 29: POSITION SCALING SYSTEM
//====================================================================
class CPositionScaling
{
private:
   double m_scaleLevels[5];              // Kâr seviyeleri (ATR çarpanları)
   double m_scalePercents[5];            // Her seviyede ekleme yüzdesi
   int    m_maxScales;
   int    m_currentScales;
   double m_totalAddedLots;
   ulong  m_baseTicket;
   double m_baseEntryPrice;
   
public:
   CPositionScaling() : m_maxScales(3), m_currentScales(0), 
                        m_totalAddedLots(0), m_baseTicket(0), m_baseEntryPrice(0) {
      // Varsayılan seviyeler
      m_scaleLevels[0] = 1.0;   // 1 ATR kârda
      m_scaleLevels[1] = 2.0;   // 2 ATR kârda
      m_scaleLevels[2] = 3.0;   // 3 ATR kârda
      m_scaleLevels[3] = 4.0;   // 4 ATR kârda
      m_scaleLevels[4] = 5.0;   // 5 ATR kârda
      
      m_scalePercents[0] = 50;  // Orijinal lotun %50'si
      m_scalePercents[1] = 30;  // Orijinal lotun %30'u
      m_scalePercents[2] = 20;  // Orijinal lotun %20'si
      m_scalePercents[3] = 10;
      m_scalePercents[4] = 10;
   }
   
   void SetBasePosition(ulong ticket, double entryPrice) {
      m_baseTicket = ticket;
      m_baseEntryPrice = entryPrice;
      m_currentScales = 0;
      m_totalAddedLots = 0;
   }
   
   bool ShouldScale(int direction, double currentPrice, double atr) {
      if(m_baseTicket == 0 || m_currentScales >= m_maxScales) return false;
      
      double targetLevel = m_scaleLevels[m_currentScales] * atr;
      double profit = 0;
      
      if(direction == 1) // BUY
         profit = currentPrice - m_baseEntryPrice;
      else
         profit = m_baseEntryPrice - currentPrice;
      
      return (profit >= targetLevel);
   }
   
   double GetScaleLot(double baseLot) {
      if(m_currentScales >= m_maxScales) return 0;
      return baseLot * m_scalePercents[m_currentScales] / 100.0;
   }
   
   void OnScaled(double addedLot) {
      m_totalAddedLots += addedLot;
      m_currentScales++;
      Print("📈 Scale ", m_currentScales, ": +", DoubleToString(addedLot, 2), " lot eklendi");
   }
   
   void Reset() {
      m_baseTicket = 0;
      m_baseEntryPrice = 0;
      m_currentScales = 0;
      m_totalAddedLots = 0;
   }
   
   int GetScaleCount() { return m_currentScales; }
   double GetTotalAddedLots() { return m_totalAddedLots; }
   bool IsScalingActive() { return m_baseTicket > 0; }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 30: CORRELATION FILTER
//====================================================================
class CCorrelationFilter
{
private:
   string m_correlatedPairs[10];
   double m_correlationValues[10];
   int    m_pairCount;
   int    m_lookbackPeriod;
   double m_correlationThreshold;
   
public:
   CCorrelationFilter() : m_pairCount(0), m_lookbackPeriod(50), 
                          m_correlationThreshold(0.7) {
      // Varsayılan korelasyonlu çiftler
      m_correlatedPairs[0] = "EURUSD";
      m_correlatedPairs[1] = "GBPUSD";
      m_correlatedPairs[2] = "USDJPY";
      m_correlatedPairs[3] = "USDCHF";
      m_pairCount = 4;
   }
   
   double CalculateCorrelation(string pair1, string pair2) {
      double prices1[], prices2[];
      ArraySetAsSeries(prices1, true);
      ArraySetAsSeries(prices2, true);
      
      int copied1 = CopyClose(pair1, PERIOD_H1, 0, m_lookbackPeriod, prices1);
      int copied2 = CopyClose(pair2, PERIOD_H1, 0, m_lookbackPeriod, prices2);
      
      if(copied1 < m_lookbackPeriod || copied2 < m_lookbackPeriod) return 0;
      
      double mean1 = 0, mean2 = 0;
      for(int i = 0; i < m_lookbackPeriod; i++) {
         mean1 += prices1[i];
         mean2 += prices2[i];
      }
      mean1 /= m_lookbackPeriod;
      mean2 /= m_lookbackPeriod;
      
      double cov = 0, var1 = 0, var2 = 0;
      for(int i = 0; i < m_lookbackPeriod; i++) {
         double d1 = prices1[i] - mean1;
         double d2 = prices2[i] - mean2;
         cov += d1 * d2;
         var1 += d1 * d1;
         var2 += d2 * d2;
      }
      
      if(var1 == 0 || var2 == 0) return 0;
      return cov / MathSqrt(var1 * var2);
   }
   
   bool HasConflictingPosition(int direction) {
      for(int i = 0; i < m_pairCount; i++) {
         if(m_correlatedPairs[i] == _Symbol) continue;
         
         // Bu çiftte açık pozisyon var mı kontrol et
         for(int j = PositionsTotal() - 1; j >= 0; j--) {
            if(PositionSelectByTicket(PositionGetTicket(j))) {
               if(PositionGetString(POSITION_SYMBOL) == m_correlatedPairs[i]) {
                  double corr = CalculateCorrelation(_Symbol, m_correlatedPairs[i]);
                  
                  // Yüksek korelasyon ve aynı yönde pozisyon
                  if(MathAbs(corr) > m_correlationThreshold) {
                     int posDir = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? 1 : -1;
                     if(corr > 0 && posDir == direction) {
                        Print("⚠️ Korelasyon Filtresi: ", m_correlatedPairs[i], " ile çakışma (", 
                              DoubleToString(corr, 2), ")");
                        return true;
                     }
                     if(corr < 0 && posDir == -direction) {
                        Print("⚠️ Negatif Korelasyon Çakışması: ", m_correlatedPairs[i]);
                        return true;
                     }
                  }
               }
            }
         }
      }
      return false;
   }
   
   void UpdateCorrelations() {
      for(int i = 0; i < m_pairCount; i++) {
         m_correlationValues[i] = CalculateCorrelation(_Symbol, m_correlatedPairs[i]);
      }
   }
   
   double GetMaxCorrelation() {
      double maxCorr = 0;
      for(int i = 0; i < m_pairCount; i++) {
         if(MathAbs(m_correlationValues[i]) > MathAbs(maxCorr))
            maxCorr = m_correlationValues[i];
      }
      return maxCorr;
   }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 31: BREAK-EVEN PLUS
//====================================================================
class CBreakEvenPlus
{
private:
   double m_bePlusLevels[5];             // BE+ seviyeleri (ATR çarpanları)
   double m_bePlusPips[5];               // Her seviyede BE üstüne eklenen pips
   int    m_currentLevel;
   bool   m_beActivated;
   double m_lastSLPrice;
   
public:
   CBreakEvenPlus() : m_currentLevel(0), m_beActivated(false), m_lastSLPrice(0) {
      // Varsayılan BE+ seviyeleri
      m_bePlusLevels[0] = 1.0;   // 1 ATR kârda
      m_bePlusLevels[1] = 1.5;   // 1.5 ATR kârda
      m_bePlusLevels[2] = 2.0;   // 2 ATR kârda
      m_bePlusLevels[3] = 3.0;   // 3 ATR kârda
      m_bePlusLevels[4] = 4.0;   // 4 ATR kârda
      
      m_bePlusPips[0] = 2.0;     // BE + 2 pip
      m_bePlusPips[1] = 5.0;     // BE + 5 pip
      m_bePlusPips[2] = 10.0;    // BE + 10 pip
      m_bePlusPips[3] = 15.0;    // BE + 15 pip
      m_bePlusPips[4] = 20.0;    // BE + 20 pip
   }
   
   double CalculateBEPlusLevel(int direction, double entryPrice, double currentPrice, double atr) {
      double profit = 0;
      if(direction == 1)
         profit = currentPrice - entryPrice;
      else
         profit = entryPrice - currentPrice;
      
      double newSL = 0;
      for(int i = 4; i >= 0; i--) {
         if(profit >= m_bePlusLevels[i] * atr) {
            double plusPips = m_bePlusPips[i] * 10.0 * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            if(direction == 1)
               newSL = entryPrice + plusPips;
            else
               newSL = entryPrice - plusPips;
            
            if(i > m_currentLevel) {
               m_currentLevel = i;
               Print("🎯 BE+ Level ", i+1, ": SL = Entry + ", m_bePlusPips[i], " pips");
            }
            break;
         }
      }
      return newSL;
   }
   
   bool ShouldUpdateSL(double newSL, int direction) {
      if(newSL == 0) return false;
      if(m_lastSLPrice == 0) {
         m_lastSLPrice = newSL;
         return true;
      }
      
      if(direction == 1 && newSL > m_lastSLPrice) {
         m_lastSLPrice = newSL;
         return true;
      }
      if(direction == -1 && newSL < m_lastSLPrice) {
         m_lastSLPrice = newSL;
         return true;
      }
      return false;
   }
   
   void Reset() {
      m_currentLevel = 0;
      m_beActivated = false;
      m_lastSLPrice = 0;
   }
   
   int GetCurrentLevel() { return m_currentLevel; }
   bool IsBEActivated() { return m_beActivated; }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 32: EQUITY CURVE FILTER
//====================================================================
class CEquityCurveFilter
{
private:
   double m_equityHistory[];
   int    m_historySize;
   int    m_historyIndex;
   double m_maPeriod;
   bool   m_tradingEnabled;
   datetime m_lastUpdate;
   double m_peakEquity;
   double m_currentDD;
   int    m_consecutiveLosses;
   int    m_maxConsecutiveLosses;
   
public:
   CEquityCurveFilter() : m_historySize(100), m_historyIndex(0), m_maPeriod(20),
                          m_tradingEnabled(true), m_lastUpdate(0), m_peakEquity(0),
                          m_currentDD(0), m_consecutiveLosses(0), m_maxConsecutiveLosses(5) {
      ArrayResize(m_equityHistory, m_historySize);
      ArrayInitialize(m_equityHistory, 0);
   }
   
   void Update() {
      if(TimeCurrent() - m_lastUpdate < 60) return; // Dakikada 1 güncelle
      
      double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      m_equityHistory[m_historyIndex] = currentEquity;
      m_historyIndex = (m_historyIndex + 1) % m_historySize;
      
      if(currentEquity > m_peakEquity) m_peakEquity = currentEquity;
      m_currentDD = (m_peakEquity - currentEquity) / m_peakEquity * 100.0;
      
      m_lastUpdate = TimeCurrent();
      
      // Equity curve MA kontrolü
      double ma = GetEquityMA();
      if(ma > 0) {
         m_tradingEnabled = (currentEquity >= ma * 0.98); // MA'nın %2 altına inerse durdur
      }
   }
   
   double GetEquityMA() {
      double sum = 0;
      int count = 0;
      for(int i = 0; i < (int)m_maPeriod; i++) {
         int idx = (m_historyIndex - 1 - i + m_historySize) % m_historySize;
         if(m_equityHistory[idx] > 0) {
            sum += m_equityHistory[idx];
            count++;
         }
      }
      return count > 0 ? sum / count : 0;
   }
   
   void OnTradeResult(bool isWin) {
      if(isWin) {
         m_consecutiveLosses = 0;
      } else {
         m_consecutiveLosses++;
         if(m_consecutiveLosses >= m_maxConsecutiveLosses) {
            m_tradingEnabled = false;
            Print("🔴 Equity Filter: ", m_consecutiveLosses, " üst üste kayıp! İşlem durduruldu.");
         }
      }
   }
   
   void Reset() {
      m_consecutiveLosses = 0;
      m_tradingEnabled = true;
   }
   
   bool IsTradingAllowed() { return m_tradingEnabled; }
   double GetCurrentDD() { return m_currentDD; }
   double GetPeakEquity() { return m_peakEquity; }
   int GetConsecutiveLosses() { return m_consecutiveLosses; }
   
   double GetEquityScore() {
      // 0-100 arası skor
      double ddScore = MathMax(0, 100 - m_currentDD * 10);
      double lossScore = MathMax(0, 100 - m_consecutiveLosses * 20);
      return (ddScore + lossScore) / 2.0;
   }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 33: SMART EXIT SYSTEM
//====================================================================
class CSmartExitSystem
{
private:
   double m_profitTargets[5];            // Kâr hedefleri (ATR çarpanları)
   double m_exitPercents[5];             // Her hedefte kapatılacak yüzde
   int    m_currentTarget;
   bool   m_trailingActivated;
   double m_highestProfit;
   double m_exitTriggerPct;              // Trailing exit tetikleme yüzdesi
   
   // AI Exit Signals
   bool   m_divergenceExit;
   bool   m_momentumExit;
   bool   m_levelExit;
   
public:
   CSmartExitSystem() : m_currentTarget(0), m_trailingActivated(false),
                        m_highestProfit(0), m_exitTriggerPct(50),
                        m_divergenceExit(false), m_momentumExit(false), m_levelExit(false) {
      // Varsayılan hedefler
      m_profitTargets[0] = 1.0;   // 1 ATR
      m_profitTargets[1] = 2.0;   // 2 ATR
      m_profitTargets[2] = 3.0;   // 3 ATR
      m_profitTargets[3] = 5.0;   // 5 ATR
      m_profitTargets[4] = 8.0;   // 8 ATR (Fibonacci)
      
      m_exitPercents[0] = 25;
      m_exitPercents[1] = 25;
      m_exitPercents[2] = 25;
      m_exitPercents[3] = 15;
      m_exitPercents[4] = 10;
   }
   
   int CheckExitLevel(double profitATR) {
      for(int i = 4; i >= 0; i--) {
         if(profitATR >= m_profitTargets[i]) {
            return i;
         }
      }
      return -1;
   }
   
   double GetExitPercent(int level) {
      if(level < 0 || level >= 5) return 0;
      return m_exitPercents[level];
   }
   
   void UpdateProfit(double currentProfit) {
      if(currentProfit > m_highestProfit) {
         m_highestProfit = currentProfit;
         m_trailingActivated = true;
      }
   }
   
   bool ShouldExitOnRetracement(double currentProfit) {
      if(!m_trailingActivated || m_highestProfit <= 0) return false;
      
      double retracement = (m_highestProfit - currentProfit) / m_highestProfit * 100.0;
      return (retracement >= m_exitTriggerPct);
   }
   
   void SetDivergenceExit(bool detected) { m_divergenceExit = detected; }
   void SetMomentumExit(bool detected) { m_momentumExit = detected; }
   void SetLevelExit(bool detected) { m_levelExit = detected; }
   
   bool ShouldExitOnSignal() {
      int exitSignals = 0;
      if(m_divergenceExit) exitSignals++;
      if(m_momentumExit) exitSignals++;
      if(m_levelExit) exitSignals++;
      return (exitSignals >= 2); // 2/3 sinyal gerekliyse çık
   }
   
   string GetExitReason() {
      string reason = "";
      if(m_divergenceExit) reason += "DIV ";
      if(m_momentumExit) reason += "MOM ";
      if(m_levelExit) reason += "LVL ";
      return reason;
   }
   
   void Reset() {
      m_currentTarget = 0;
      m_trailingActivated = false;
      m_highestProfit = 0;
      m_divergenceExit = false;
      m_momentumExit = false;
      m_levelExit = false;
   }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 34: MULTI-SESSION ANALYSIS
//====================================================================
class CMultiSessionAnalysis
{
private:
   struct SessionData {
      string name;
      int    startHour;
      int    endHour;
      int    trades;
      int    wins;
      double totalProfit;
      double avgVolatility;
   };
   SessionData m_sessions[4];
   int m_currentSession;
   
public:
   CMultiSessionAnalysis() : m_currentSession(-1) {
      // Session tanımları (UTC)
      m_sessions[0].name = "Sydney";
      m_sessions[0].startHour = 22;
      m_sessions[0].endHour = 7;
      
      m_sessions[1].name = "Tokyo";
      m_sessions[1].startHour = 0;
      m_sessions[1].endHour = 9;
      
      m_sessions[2].name = "London";
      m_sessions[2].startHour = 8;
      m_sessions[2].endHour = 17;
      
      m_sessions[3].name = "NewYork";
      m_sessions[3].startHour = 13;
      m_sessions[3].endHour = 22;
      
      for(int i = 0; i < 4; i++) {
         m_sessions[i].trades = 0;
         m_sessions[i].wins = 0;
         m_sessions[i].totalProfit = 0;
         m_sessions[i].avgVolatility = 0;
      }
   }
   
   void UpdateCurrentSession() {
      MqlDateTime dt;
      TimeCurrent(dt);
      int hour = dt.hour;
      
      m_currentSession = -1;
      for(int i = 0; i < 4; i++) {
         if(m_sessions[i].startHour <= m_sessions[i].endHour) {
            if(hour >= m_sessions[i].startHour && hour < m_sessions[i].endHour)
               m_currentSession = i;
         } else {
            if(hour >= m_sessions[i].startHour || hour < m_sessions[i].endHour)
               m_currentSession = i;
         }
      }
   }
   
   void RecordTrade(bool isWin, double profit) {
      if(m_currentSession < 0 || m_currentSession >= 4) return;
      m_sessions[m_currentSession].trades++;
      if(isWin) m_sessions[m_currentSession].wins++;
      m_sessions[m_currentSession].totalProfit += profit;
   }
   
   void RecordVolatility(double atr) {
      if(m_currentSession < 0 || m_currentSession >= 4) return;
      if(m_sessions[m_currentSession].avgVolatility == 0)
         m_sessions[m_currentSession].avgVolatility = atr;
      else
         m_sessions[m_currentSession].avgVolatility = 
            (m_sessions[m_currentSession].avgVolatility * 0.9) + (atr * 0.1);
   }
   
   double GetSessionWinRate(int session) {
      if(session < 0 || session >= 4) return 50.0;
      if(m_sessions[session].trades == 0) return 50.0;
      return (double)m_sessions[session].wins / m_sessions[session].trades * 100.0;
   }
   
   bool IsOptimalSession() {
      if(m_currentSession < 0) return true;
      if(m_sessions[m_currentSession].trades < 10) return true;
      return (GetSessionWinRate(m_currentSession) >= 45.0);
   }
   
   string GetCurrentSessionName() {
      if(m_currentSession < 0 || m_currentSession >= 4) return "Unknown";
      return m_sessions[m_currentSession].name;
   }
   
   int GetBestSession() {
      int best = 0;
      double bestRate = 0;
      for(int i = 0; i < 4; i++) {
         if(m_sessions[i].trades >= 10) {
            double rate = GetSessionWinRate(i);
            if(rate > bestRate) {
               bestRate = rate;
               best = i;
            }
         }
      }
      return best;
   }
   
   double GetSessionScore() {
      if(m_currentSession < 0) return 50;
      return GetSessionWinRate(m_currentSession);
   }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 35: NEWS IMPACT CALCULATOR
//====================================================================
class CNewsImpactCalculator
{
private:
   struct ImpactEvent {
      datetime time;
      string currency;
      int impact;              // 1=Low, 2=Medium, 3=High
      bool processed;
   };
   ImpactEvent m_events[];
   int m_eventCount;
   int m_pauseMinutesBefore;
   int m_pauseMinutesAfter;
   double m_impactMultiplier;
   
public:
   CNewsImpactCalculator() : m_eventCount(0), m_pauseMinutesBefore(30),
                              m_pauseMinutesAfter(15), m_impactMultiplier(1.0) {
      ArrayResize(m_events, 100);
   }
   
   void SetPauseTimes(int before, int after) {
      m_pauseMinutesBefore = before;
      m_pauseMinutesAfter = after;
   }
   
   void AddEvent(datetime time, string currency, int impact) {
      if(m_eventCount >= 100) {
         // Eski eventleri temizle
         ClearOldEvents();
      }
      m_events[m_eventCount].time = time;
      m_events[m_eventCount].currency = currency;
      m_events[m_eventCount].impact = impact;
      m_events[m_eventCount].processed = false;
      m_eventCount++;
   }
   
   void ClearOldEvents() {
      datetime now = TimeCurrent();
      int newCount = 0;
      for(int i = 0; i < m_eventCount; i++) {
         if(m_events[i].time > now - 3600) { // Son 1 saatteki eventler
            if(i != newCount) m_events[newCount] = m_events[i];
            newCount++;
         }
      }
      m_eventCount = newCount;
   }
   
   bool IsNearHighImpactNews() {
      datetime now = TimeCurrent();
      string baseCurrency = StringSubstr(_Symbol, 0, 3);
      string quoteCurrency = StringSubstr(_Symbol, 3, 3);
      
      for(int i = 0; i < m_eventCount; i++) {
         if(m_events[i].impact >= 3) { // High impact
            if(m_events[i].currency == baseCurrency || m_events[i].currency == quoteCurrency) {
               datetime startPause = m_events[i].time - m_pauseMinutesBefore * 60;
               datetime endPause = m_events[i].time + m_pauseMinutesAfter * 60;
               if(now >= startPause && now <= endPause) return true;
            }
         }
      }
      return false;
   }
   
   double GetCurrentImpactScore() {
      // 0-100: 0 = Haber yok, 100 = Yüksek etkili haber yakın
      datetime now = TimeCurrent();
      double maxScore = 0;
      
      for(int i = 0; i < m_eventCount; i++) {
         double timeDiff = MathAbs((double)(m_events[i].time - now)) / 60.0; // Dakika cinsinden
         if(timeDiff < 60) { // 1 saat içinde
            double score = m_events[i].impact * 33.3 * (1.0 - timeDiff / 60.0);
            if(score > maxScore) maxScore = score;
         }
      }
      return maxScore;
   }
   
   int GetUpcomingNewsCount(int hours) {
      datetime now = TimeCurrent();
      datetime future = now + hours * 3600;
      int count = 0;
      for(int i = 0; i < m_eventCount; i++) {
         if(m_events[i].time > now && m_events[i].time <= future)
            count++;
      }
      return count;
   }
   
   double GetAdjustedMultiplier() {
      // Haber yakınsa risk azalt
      if(IsNearHighImpactNews()) return 0.5;
      double impactScore = GetCurrentImpactScore();
      if(impactScore > 50) return 0.75;
      return 1.0;
   }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 36: RISK PARITY SYSTEM
//====================================================================
class CRiskParitySystem
{
private:
   double m_baseRisk;
   double m_currentRisk;
   double m_volatilityAdjustment;
   double m_correlationAdjustment;
   double m_performanceAdjustment;
   double m_minRiskMultiplier;
   double m_maxRiskMultiplier;
   
   // Performans metrikleri
   double m_recentWinRate;
   double m_recentExpectancy;
   double m_recentSharpe;
   
public:
   CRiskParitySystem() : m_baseRisk(1.0), m_currentRisk(1.0),
                         m_volatilityAdjustment(1.0), m_correlationAdjustment(1.0),
                         m_performanceAdjustment(1.0),
                         m_minRiskMultiplier(0.25), m_maxRiskMultiplier(2.0),
                         m_recentWinRate(50), m_recentExpectancy(0), m_recentSharpe(0) {}
   
   void SetBaseRisk(double risk) { m_baseRisk = risk; }
   
   void UpdateVolatilityAdjustment(double currentATR, double avgATR) {
      if(avgATR <= 0) {
         m_volatilityAdjustment = 1.0;
         return;
      }
      double ratio = currentATR / avgATR;
      // Yüksek volatilitede riski azalt, düşük volatilitede artır
      m_volatilityAdjustment = 1.0 / ratio;
      m_volatilityAdjustment = MathMax(0.5, MathMin(1.5, m_volatilityAdjustment));
   }
   
   void UpdateCorrelationAdjustment(double maxCorrelation) {
      // Yüksek korelasyonda riski azalt
      m_correlationAdjustment = 1.0 - MathAbs(maxCorrelation) * 0.5;
      m_correlationAdjustment = MathMax(0.5, m_correlationAdjustment);
   }
   
   void UpdatePerformanceAdjustment(double winRate, double expectancy, double sharpe) {
      m_recentWinRate = winRate;
      m_recentExpectancy = expectancy;
      m_recentSharpe = sharpe;
      
      double perfScore = 0;
      
      // Win rate katkısı (50% baz)
      if(winRate > 50) perfScore += (winRate - 50) / 50.0 * 0.5;
      else perfScore -= (50 - winRate) / 50.0 * 0.5;
      
      // Sharpe katkısı
      if(sharpe > 1) perfScore += 0.25;
      else if(sharpe > 0) perfScore += sharpe * 0.25;
      else perfScore -= 0.25;
      
      m_performanceAdjustment = 1.0 + perfScore;
      m_performanceAdjustment = MathMax(0.5, MathMin(1.5, m_performanceAdjustment));
   }
   
   double CalculateOptimalRisk() {
      m_currentRisk = m_baseRisk * m_volatilityAdjustment * 
                      m_correlationAdjustment * m_performanceAdjustment;
      
      m_currentRisk = MathMax(m_baseRisk * m_minRiskMultiplier, 
                              MathMin(m_baseRisk * m_maxRiskMultiplier, m_currentRisk));
      
      return m_currentRisk;
   }
   
   double GetRiskMultiplier() {
      return m_currentRisk / m_baseRisk;
   }
   
   string GetRiskReport() {
      return StringFormat("Risk: %.2fx (V:%.2f C:%.2f P:%.2f)", 
                          GetRiskMultiplier(), 
                          m_volatilityAdjustment,
                          m_correlationAdjustment,
                          m_performanceAdjustment);
   }
   
   double GetVolatilityAdj() { return m_volatilityAdjustment; }
   double GetCorrelationAdj() { return m_correlationAdjustment; }
   double GetPerformanceAdj() { return m_performanceAdjustment; }
};

//====================================================================
// v14 5K EDITION - GLOBAL OBJECTS (NEW MODULES)
//====================================================================
CMLSimulator        MLSimulator;
CSmartEntryTiming   EntryTiming;
CPositionScaling    PositionScaler;
CCorrelationFilter  CorrFilter;
CBreakEvenPlus      BEPlus;
CEquityCurveFilter  EquityFilter;
CSmartExitSystem    SmartExit;
CMultiSessionAnalysis SessionAnalyzer;
CNewsImpactCalculator NewsCalc;
CRiskParitySystem   RiskParity;

//====================================================================
// v14.1 EXTENSION MODULE 37: MANUAL POSITION PROTECTOR
//====================================================================
class CManualPositionProtector
{
private:
   CTrade* m_pTrade;
   datetime m_detectedPositions[];
   ulong    m_detectedTickets[];
   int      m_detectedCount;
   
public:
   CManualPositionProtector() : m_pTrade(NULL), m_detectedCount(0) {
      ArrayResize(m_detectedPositions, 50);
      ArrayResize(m_detectedTickets, 50);
   }
   
   void Init(CTrade* trade) {
      m_pTrade = trade;
   }
   
   bool IsManualPosition(ulong ticket) {
      if(!PositionSelectByTicket(ticket)) return false;
      ulong posMagic = PositionGetInteger(POSITION_MAGIC);
      return (posMagic == 0 || posMagic != MagicNumber);
   }
   
   bool IsNewManualPosition(ulong ticket) {
      for(int i = 0; i < m_detectedCount; i++) {
         if(m_detectedTickets[i] == ticket) return false;
      }
      return true;
   }
   
   void RegisterPosition(ulong ticket) {
      if(m_detectedCount >= 50) {
         for(int i = 0; i < 49; i++) {
            m_detectedTickets[i] = m_detectedTickets[i+1];
            m_detectedPositions[i] = m_detectedPositions[i+1];
         }
         m_detectedCount = 49;
      }
      m_detectedTickets[m_detectedCount] = ticket;
      m_detectedPositions[m_detectedCount] = TimeCurrent();
      m_detectedCount++;
   }
   
   datetime GetDetectionTime(ulong ticket) {
      for(int i = 0; i < m_detectedCount; i++) {
         if(m_detectedTickets[i] == ticket) return m_detectedPositions[i];
      }
      return 0;
   }
   
   void ManageManualPositions(int currentSignal, double atr) {
      if(!ManageManualTrades || m_pTrade == NULL) return;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(!PositionSelectByTicket(ticket)) continue;
         
         string posSymbol = PositionGetString(POSITION_SYMBOL);
         
         // ManageAllSymbols=false ise sadece mevcut sembol
         if(!ManageAllSymbols && posSymbol != _Symbol) continue;
         
         if(!IsManualPosition(ticket)) continue;
         
         // Yeni manuel pozisyon mu?
         if(IsNewManualPosition(ticket)) {
            RegisterPosition(ticket);
            Print("🔍 Manuel işlem tespit edildi: #", ticket, " | ", posSymbol);
         }

         
         double entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentSL = PositionGetDouble(POSITION_SL);
         double currentTP = PositionGetDouble(POSITION_TP);
         double posLots = PositionGetDouble(POSITION_VOLUME);
         int posDir = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? 1 : -1;
         
         // SL/TP yoksa ekle
         if(AddSLTPToManual && (currentSL == 0 || currentTP == 0)) {
            // SEMBOL BAZLI hesaplama - her sembol için ayrı point ve stop level
            double point = SymbolInfoDouble(posSymbol, SYMBOL_POINT);
            int digits = (int)SymbolInfoInteger(posSymbol, SYMBOL_DIGITS);
            long stopLevel = SymbolInfoInteger(posSymbol, SYMBOL_TRADE_STOPS_LEVEL);
            double currentPrice = posDir == 1 ? 
                                  SymbolInfoDouble(posSymbol, SYMBOL_BID) : 
                                  SymbolInfoDouble(posSymbol, SYMBOL_ASK);
            
            // Minimum mesafe = stop level + 5 pip güvenlik marjı
            double minDistance = (stopLevel + 50) * point;
            if(minDistance < ManualDefaultSL * 10 * point) 
               minDistance = ManualDefaultSL * 10 * point;
            
            double newSL = currentSL;
            double newTP = currentTP;
            
            if(currentSL == 0) {
               if(posDir == 1)
                  newSL = currentPrice - minDistance;
               else
                  newSL = currentPrice + minDistance;
               newSL = NormalizeDouble(newSL, digits);
            }
            
            if(currentTP == 0) {
               double tpDistance = minDistance * 2.0; // RR 1:2
               if(posDir == 1)
                  newTP = currentPrice + tpDistance;
               else
                  newTP = currentPrice - tpDistance;
               newTP = NormalizeDouble(newTP, digits);
            }
            
            // Son kontrol - fiyatlardan yeterince uzak mı?
            double slDistance = MathAbs(currentPrice - newSL);
            double tpDistance = MathAbs(currentPrice - newTP);
            
            if(slDistance >= stopLevel * point && tpDistance >= stopLevel * point) {
               if((*m_pTrade).PositionModify(ticket, newSL, newTP)) {
                  Print("✅ Manuel işleme SL/TP eklendi: #", ticket, " | ", posSymbol,
                        " SL:", DoubleToString(newSL, digits), " TP:", DoubleToString(newTP, digits));
               } else {
                  Print("⚠️ SL/TP eklenemedi: #", ticket, " | ", posSymbol, " | Hata: ", GetLastError());
               }
            } else {
               Print("⚠️ Stop Level yetersiz: ", posSymbol, " MinLevel:", stopLevel, 
                     " SL_Dist:", slDistance/point, " TP_Dist:", tpDistance/point);
            }
         }

         
         // Sinyal ile değerlendirme
         if(EvaluateManualBySignal && CloseCounterTrendManual && currentSignal != 0) {
            datetime detectionTime = GetDetectionTime(ticket);
            if(TimeCurrent() - detectionTime >= ManualEvalDelay) {
               // Ters yönlü mü?
               if(posDir != currentSignal) {
                  // Zarar durumunda kapat
                  double profit = PositionGetDouble(POSITION_PROFIT);
                  if(profit < 0) {
                     if((*m_pTrade).PositionClose(ticket)) {
                        Print("🚨 Ters yönlü manuel işlem kapatıldı: #", ticket, 
                              " | Sinyal: ", (currentSignal == 1 ? "BUY" : "SELL"),
                              " | Pozisyon: ", (posDir == 1 ? "BUY" : "SELL"));
                     }
                  } else {
                     Print("⚠️ Ters yönlü ama kârda: #", ticket, " - Bekleniyor");
                  }
               }
            }
         }
      }
   }
   
   int GetManualPositionCount() {
      int count = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket) && 
            PositionGetString(POSITION_SYMBOL) == _Symbol &&
            IsManualPosition(ticket)) {
            count++;
         }
      }
      return count;
   }
   
   double GetManualPositionProfit() {
      double profit = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket) && 
            PositionGetString(POSITION_SYMBOL) == _Symbol &&
            IsManualPosition(ticket)) {
            profit += PositionGetDouble(POSITION_PROFIT);
         }
      }
      return profit;
   }
};

CManualPositionProtector ManualProtector;

//+------------------------------------------------------------------+
//| v14.1 ULTIMATE 5K EDITION - FINAL                                |
//| 50+ Synchronized Modules | 5000+ Lines                           |
//| Machine Learning | Smart Entry | Position Scaling                 |
//| Correlation Filter | Break-Even Plus | Equity Curve Filter        |
//| Smart Exit | Multi-Session | News Impact | Risk Parity            |
//| Manual Position Protection | Signal Evaluation | Auto SL/TP       |
//| © 2025, Milyoner EA Project - The Ultimate Trading System v14.1  |
//+------------------------------------------------------------------+
