//+------------------------------------------------------------------+
//|                                     MA_Master_Scalper_v12.mq5    |
//|                © 2025, Milyoner EA Project v12.0 - AI Enhanced   |
//|     NEXT-GEN HYBRID - Machine Learning Inspired Architecture     |
//+------------------------------------------------------------------+
#property copyright "© 2025, Milyoner EA v12 - AI Enhanced"
#property version   "12.00"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// v12: AI-ENHANCED NEXT-GEN HYBRID SYSTEM
// ═══════════════════════════════════════════════════════════════════
// YENI ÖZELLİKLER:
// [1] Sinyal Kalite Skorlaması (0-100)
// [2] Mum Fitili Analizi (Wick Analysis)
// [3] Mum Pattern Tanıma (Pin Bar, Engulfing, Doji)
// [4] Multi-Factor Oylama Sistemi (Weighted Voting)
// [5] Dinamik Filtre Ağırlıkları
// [6] Momentum Strength Score
// [7] Volatility Regime Detection
// [8] Trend Quality Index (TQI)
// [9] False Breakout Filter
// [10] Adaptive Signal Threshold
//
// MEVCUT v11 ÖZELLİKLERİ:
// [11-22] Titanium Omega + MA Master Scalper tüm özellikleri
// ═══════════════════════════════════════════════════════════════════

//====================================================================
// ENUM TANIMLARI
//====================================================================
enum ENUM_MARKET_REGIME {
   REGIME_HIGH_VOLATILITY,    // Yüksek Volatilite
   REGIME_TRENDING,           // Trend
   REGIME_RANGING,            // Range
   REGIME_BREAKOUT            // Kırılım
};

enum ENUM_ENTRY_MODE { 
   MODE_MARKET,               // Sadece Piyasa Emri
   MODE_PENDING,              // Sadece Bekleyen Emir
   MODE_BOTH,                 // Her İkisi
   MODE_GRID                  // Grid Sistemi
};

enum ENUM_SIGNAL_MODE {
   SIG_MA_CROSS,              // MA Kesişim
   SIG_PATTERN,               // Mum Pattern
   SIG_COMBINED,              // Birleşik
   SIG_AI_SCORE               // AI Skor Bazlı
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
   PATTERN_EVENING_STAR
};

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 1: ANA AYARLAR
//====================================================================
input group "═══════════════════════════════════════════════════════"
input group "═══════ 1. ANA AYARLAR ═══════"
input ulong    MagicNumber       = 121212;
input string   TradeComment      = "MILYONER_v12_AI";
input ENUM_TIMEFRAMES TF         = PERIOD_M5;
input ENUM_ENTRY_MODE EntryMode  = MODE_MARKET;
input ENUM_SIGNAL_MODE SignalMode = SIG_AI_SCORE;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 2: AI SİNYAL SKORU
//====================================================================
input group "═══════ 2. AI SİNYAL SKORU ═══════"
input int      MinSignalScore    = 60;             // Min Sinyal Skoru (0-100)
input bool     UseAdaptiveThreshold = true;        // Adaptif Eşik
input int      ScoreHistoryBars  = 100;            // Skor Geçmişi
input double   ScoreDecayFactor  = 0.95;           // Skor Azalma Faktörü

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 3: MUM ANALİZİ
//====================================================================
input group "═══════ 3. MUM FİTİLİ ANALİZİ ═══════"
input bool     UseWickAnalysis   = true;           // Fitil Analizi
input double   MinWickRatio      = 0.3;            // Min Fitil/Gövde Oranı
input double   MaxBodyRatio      = 0.5;            // Max Gövde/Range Oranı
input bool     UseCandlePatterns = true;           // Mum Pattern Kullan

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 4: ÜÇLÜ MA SİSTEMİ
//====================================================================
input group "═══════ 4. ÜÇLÜ MA SİSTEMİ ═══════"
input int      MA1_Period        = 8;              // Fast MA
input int      MA2_Period        = 21;             // Medium MA
input int      MA3_Period        = 50;             // Slow MA
input ENUM_MA_METHOD MA_Method   = MODE_EMA;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 5: MOMENTUM
//====================================================================
input group "═══════ 5. MOMENTUM GÖSTERGELERİ ═══════"
input bool     UseMACD           = true;
input int      MACD_Fast         = 12;
input int      MACD_Slow         = 26;
input int      MACD_Signal       = 9;
input bool     UseRSI            = true;
input int      RSI_Period        = 14;
input int      RSI_OB            = 70;
input int      RSI_OS            = 30;
input bool     UseStochastic     = true;
input int      Stoch_K           = 14;
input int      Stoch_D           = 3;
input int      Stoch_Slowing     = 3;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 6: TREND KALİTESİ
//====================================================================
input group "═══════ 6. TREND KALİTESİ ═══════"
input bool     UseADX            = true;
input int      ADX_Period        = 14;
input int      ADX_Min           = 20;
input bool     UseLR             = true;
input int      LR_Period         = 20;
input double   LR_MinSlope       = 0.0001;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 7: VOLATİLİTE
//====================================================================
input group "═══════ 7. VOLATİLİTE REJİMİ ═══════"
input bool     UseATR            = true;
input int      ATR_Period        = 14;
input double   ATR_SL_Multi      = 1.5;
input double   ATR_TP_Multi      = 3.0;
input int      MinSL_Pips        = 8;
input int      MaxSL_Pips        = 30;
input bool     UseVolatilityFilter = true;
input double   VolatilityMultiplier = 1.5;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 8: BREAKEVEN & TRAILING
//====================================================================
input group "═══════ 8. BREAKEVEN & TRAILING ═══════"
input bool     UseBreakeven      = true;
input double   BE_TriggerPct     = 50.0;
input int      BE_LockPips       = 2;
input bool     UseTrailing       = true;
input double   Trail_StartPct    = 100.0;
input double   Trail_ATR_Multi   = 1.0;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 9: AKILLI KISMİ KAPAMA
//====================================================================
input group "═══════ 9. AKILLI KISMİ KAPAMA ═══════"
input bool     UseSmartPartial   = true;
input double   Partial_TriggerPct = 50.0;
input double   Partial_ClosePct  = 50.0;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 10: RİSK YÖNETİMİ
//====================================================================
input group "═══════ 10. RİSK YÖNETİMİ ═══════"
input double   RiskPercent       = 1.0;
input double   MaxLotSize        = 1.0;
input double   FixedLot          = 0.01;
input bool     UseFixedLot       = false;
input double   MaxDailyDDPct     = 5.0;
input double   MaxDailyDDMoney   = 50.0;
input int      MaxDailyTrades    = 10;
input double   MinMarginLevel    = 150.0;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 11: FİLTRE AĞIRLIKLARI
//====================================================================
input group "═══════ 11. AI FİLTRE AĞIRLIKLARI ═══════"
input double   Weight_MACross    = 25.0;           // MA Cross Ağırlığı
input double   Weight_MACD       = 15.0;           // MACD Ağırlığı
input double   Weight_RSI        = 15.0;           // RSI Ağırlığı
input double   Weight_ADX        = 15.0;           // ADX Ağırlığı
input double   Weight_Stoch      = 10.0;           // Stochastic Ağırlığı
input double   Weight_Pattern    = 15.0;           // Mum Pattern Ağırlığı
input double   Weight_Wick       = 5.0;            // Fitil Analizi Ağırlığı

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 12: GÜVENLİK
//====================================================================
input group "═══════ 12. GÜVENLİK ═══════"
input bool     UseTimeFilter     = false;
input int      StartHour         = 8;
input int      EndHour           = 20;
input int      MaxSpreadPips     = 5;
input int      CooldownBars      = 2;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 13: MANUEL İŞLEM
//====================================================================
input group "═══════ 13. MANUEL İŞLEM YÖNETİMİ ═══════"
input bool     ManageManualTrades = true;
input bool     AddSLTPToManual   = true;
input bool     ApplyBEToManual   = true;
input bool     ApplyTrailToManual = true;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 14: PANEL
//====================================================================
input group "═══════ 14. PANEL & DEBUG ═══════"
input bool     ShowDashboard     = true;
input bool     ShowDebugLog      = true;
input int      DebugLogInterval  = 60;

//====================================================================
// GLOBAL KONTROL DEĞİŞKENLERİ
//====================================================================
bool g_ManualPause = false;
bool g_SystemLocked = false;
string g_LockReason = "";
string g_LastSignalReason = "";
int g_LastSignalScore = 0;

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

      if(direction == 1)
         return (sl < entry - safeDist) && (tp > entry + safeDist) && 
                (entry - sl >= stopLevel) && (tp - entry >= stopLevel);
      else if(direction == -1)
         return (sl > entry + safeDist) && (tp < entry - safeDist) && 
                (sl - entry >= stopLevel) && (entry - tp >= stopLevel);
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
   
   static double CalculateLot(double slPips) {
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
   
   static double NormalizeLot(double lot) {
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
   
   static double CalculateLRSlope(int period) {
      if(!UseLR) return 999;
      double Sx = 0, Sy = 0, Sxy = 0, Sxx = 0;
      int n = period;
      for(int i = 0; i < n; i++) {
         double x = (double)i;
         double y = iClose(_Symbol, TF, i);
         Sx += x; Sy += y; Sxy += x * y; Sxx += x * x;
      }
      double denom = n * Sxx - Sx * Sx;
      if(denom == 0) return 0;
      return (n * Sxy - Sx * Sy) / denom;
   }
};

//====================================================================
// CLASS: CANDLE ANALYZER (Mum Fitili & Pattern Analizi)
//====================================================================
class CCandleAnalyzer
{
public:
   //=== MUM BİLEŞENLERİNİ HESAPLA ===
   static void GetCandleComponents(int shift, double &bodySize, double &upperWick, double &lowerWick, double &range, bool &isBullish)
   {
      double open = iOpen(_Symbol, TF, shift);
      double close = iClose(_Symbol, TF, shift);
      double high = iHigh(_Symbol, TF, shift);
      double low = iLow(_Symbol, TF, shift);
      
      isBullish = (close > open);
      bodySize = MathAbs(close - open);
      range = high - low;
      
      if(isBullish) {
         upperWick = high - close;
         lowerWick = open - low;
      } else {
         upperWick = high - open;
         lowerWick = close - low;
      }
   }
   
   //=== FİTİL ORANI HESAPLA ===
   static double GetWickRatio(int shift, bool isUpper)
   {
      double bodySize, upperWick, lowerWick, range;
      bool isBullish;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      
      if(range == 0) return 0;
      if(isUpper) return upperWick / range;
      return lowerWick / range;
   }
   
   //=== GÖVDE ORANI HESAPLA ===
   static double GetBodyRatio(int shift)
   {
      double bodySize, upperWick, lowerWick, range;
      bool isBullish;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      
      if(range == 0) return 0;
      return bodySize / range;
   }
   
   //=== PIN BAR TESPİTİ ===
   static bool IsPinBar(int shift, bool &isBullish)
   {
      double bodySize, upperWick, lowerWick, range;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      
      if(range == 0) return false;
      double bodyRatio = bodySize / range;
      
      // Pin bar: küçük gövde, uzun tek fitil
      if(bodyRatio > MaxBodyRatio) return false;
      
      // Bullish pin bar: uzun alt fitil
      if(lowerWick > upperWick * 2 && lowerWick / range >= MinWickRatio) {
         isBullish = true;
         return true;
      }
      
      // Bearish pin bar: uzun üst fitil
      if(upperWick > lowerWick * 2 && upperWick / range >= MinWickRatio) {
         isBullish = false;
         return true;
      }
      
      return false;
   }
   
   //=== ENGULFING TESPİTİ ===
   static bool IsEngulfing(int shift, bool &isBullish)
   {
      double open1 = iOpen(_Symbol, TF, shift);
      double close1 = iClose(_Symbol, TF, shift);
      double open2 = iOpen(_Symbol, TF, shift + 1);
      double close2 = iClose(_Symbol, TF, shift + 1);
      
      double body1 = MathAbs(close1 - open1);
      double body2 = MathAbs(close2 - open2);
      
      // Mevcut mum öncekini tamamen sarmalı
      if(body1 <= body2) return false;
      
      // Bullish engulfing: önceki kırmızı, şimdiki yeşil ve sarar
      if(close2 < open2 && close1 > open1) {
         if(close1 > open2 && open1 < close2) {
            isBullish = true;
            return true;
         }
      }
      
      // Bearish engulfing: önceki yeşil, şimdiki kırmızı ve sarar
      if(close2 > open2 && close1 < open1) {
         if(open1 > close2 && close1 < open2) {
            isBullish = false;
            return true;
         }
      }
      
      return false;
   }
   
   //=== DOJI TESPİTİ ===
   static bool IsDoji(int shift)
   {
      double bodyRatio = GetBodyRatio(shift);
      return (bodyRatio < 0.1); // Gövde, range'in %10'undan az
   }
   
   //=== HAMMER TESPİTİ ===
   static bool IsHammer(int shift, bool &isBullish)
   {
      double bodySize, upperWick, lowerWick, range;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      
      if(range == 0) return false;
      double bodyRatio = bodySize / range;
      
      // Hammer: küçük gövde üstte, uzun alt fitil
      if(bodyRatio > 0.3) return false;
      if(lowerWick < bodySize * 2) return false;
      if(upperWick > bodySize * 0.5) return false;
      
      return true;
   }
   
   //=== SHOOTING STAR TESPİTİ ===
   static bool IsShootingStar(int shift, bool &isBullish)
   {
      double bodySize, upperWick, lowerWick, range;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      
      if(range == 0) return false;
      double bodyRatio = bodySize / range;
      
      // Shooting star: küçük gövde altta, uzun üst fitil
      if(bodyRatio > 0.3) return false;
      if(upperWick < bodySize * 2) return false;
      if(lowerWick > bodySize * 0.5) return false;
      
      return true;
   }
   
   //=== ANA PATTERN TESPİT FONKSİYONU ===
   static ENUM_CANDLE_PATTERN DetectPattern(int shift = 1)
   {
      bool isBullish;
      
      // En güçlü patternler önce
      if(IsPinBar(shift, isBullish)) {
         return isBullish ? PATTERN_BULLISH_PINBAR : PATTERN_BEARISH_PINBAR;
      }
      
      if(IsEngulfing(shift, isBullish)) {
         return isBullish ? PATTERN_BULLISH_ENGULFING : PATTERN_BEARISH_ENGULFING;
      }
      
      if(IsHammer(shift, isBullish)) {
         return PATTERN_HAMMER;
      }
      
      if(IsShootingStar(shift, isBullish)) {
         return PATTERN_SHOOTING_STAR;
      }
      
      if(IsDoji(shift)) {
         return PATTERN_DOJI;
      }
      
      return PATTERN_NONE;
   }
   
   //=== PATTERN YÖNÜ ===
   static int GetPatternDirection(ENUM_CANDLE_PATTERN pattern)
   {
      switch(pattern) {
         case PATTERN_BULLISH_PINBAR:
         case PATTERN_BULLISH_ENGULFING:
         case PATTERN_HAMMER:
         case PATTERN_MORNING_STAR:
            return 1; // BUY
            
         case PATTERN_BEARISH_PINBAR:
         case PATTERN_BEARISH_ENGULFING:
         case PATTERN_SHOOTING_STAR:
         case PATTERN_EVENING_STAR:
            return -1; // SELL
            
         default:
            return 0; // NÖTR
      }
   }
   
   //=== PATTERN SKORU ===
   static int GetPatternScore(ENUM_CANDLE_PATTERN pattern)
   {
      switch(pattern) {
         case PATTERN_BULLISH_ENGULFING:
         case PATTERN_BEARISH_ENGULFING:
            return 100; // En güçlü
            
         case PATTERN_BULLISH_PINBAR:
         case PATTERN_BEARISH_PINBAR:
            return 90;
            
         case PATTERN_HAMMER:
         case PATTERN_SHOOTING_STAR:
            return 80;
            
         case PATTERN_MORNING_STAR:
         case PATTERN_EVENING_STAR:
            return 85;
            
         case PATTERN_DOJI:
            return 50; // Nötr ama dikkat çekici
            
         default:
            return 0;
      }
   }
   
   //=== PATTERN İSMİ ===
   static string GetPatternName(ENUM_CANDLE_PATTERN pattern)
   {
      switch(pattern) {
         case PATTERN_BULLISH_PINBAR: return "Bullish Pin Bar";
         case PATTERN_BEARISH_PINBAR: return "Bearish Pin Bar";
         case PATTERN_BULLISH_ENGULFING: return "Bullish Engulfing";
         case PATTERN_BEARISH_ENGULFING: return "Bearish Engulfing";
         case PATTERN_DOJI: return "Doji";
         case PATTERN_HAMMER: return "Hammer";
         case PATTERN_SHOOTING_STAR: return "Shooting Star";
         case PATTERN_MORNING_STAR: return "Morning Star";
         case PATTERN_EVENING_STAR: return "Evening Star";
         default: return "None";
      }
   }
};

//====================================================================
// CLASS: AI SIGNAL SCORER (Çoklu Faktör Oylama Sistemi)
//====================================================================
class CAISignalScorer
{
private:
   int m_hMA1, m_hMA2, m_hMA3;
   int m_hMACD, m_hRSI, m_hADX, m_hATR;
   int m_hStoch;
   datetime m_lastBarTime;
   bool m_signalGivenThisBar;
   int m_barsSinceTrade;
   
   // Skor bileşenleri
   double m_scoreMACross;
   double m_scoreMACD;
   double m_scoreRSI;
   double m_scoreADX;
   double m_scoreStoch;
   double m_scorePattern;
   double m_scoreWick;
   
   string m_signalReasons;

public:
   double m_lastATR;
   int m_lastDirection;
   int m_lastTotalScore;
   
   CAISignalScorer() : m_hMA1(INVALID_HANDLE), m_hMA2(INVALID_HANDLE), m_hMA3(INVALID_HANDLE),
      m_hMACD(INVALID_HANDLE), m_hRSI(INVALID_HANDLE), m_hADX(INVALID_HANDLE), m_hATR(INVALID_HANDLE),
      m_hStoch(INVALID_HANDLE), m_lastBarTime(0), m_signalGivenThisBar(false), m_barsSinceTrade(999),
      m_lastATR(0), m_lastDirection(0), m_lastTotalScore(0) {}
   
   ~CAISignalScorer() { ReleaseHandles(); }
   
   void ReleaseHandles() {
      if(m_hMA1 != INVALID_HANDLE) { IndicatorRelease(m_hMA1); m_hMA1 = INVALID_HANDLE; }
      if(m_hMA2 != INVALID_HANDLE) { IndicatorRelease(m_hMA2); m_hMA2 = INVALID_HANDLE; }
      if(m_hMA3 != INVALID_HANDLE) { IndicatorRelease(m_hMA3); m_hMA3 = INVALID_HANDLE; }
      if(m_hMACD != INVALID_HANDLE) { IndicatorRelease(m_hMACD); m_hMACD = INVALID_HANDLE; }
      if(m_hRSI != INVALID_HANDLE) { IndicatorRelease(m_hRSI); m_hRSI = INVALID_HANDLE; }
      if(m_hADX != INVALID_HANDLE) { IndicatorRelease(m_hADX); m_hADX = INVALID_HANDLE; }
      if(m_hATR != INVALID_HANDLE) { IndicatorRelease(m_hATR); m_hATR = INVALID_HANDLE; }
      if(m_hStoch != INVALID_HANDLE) { IndicatorRelease(m_hStoch); m_hStoch = INVALID_HANDLE; }
   }

   bool Init() {
      ReleaseHandles();
      m_hMA1 = iMA(_Symbol, TF, MA1_Period, 0, MA_Method, PRICE_CLOSE);
      m_hMA2 = iMA(_Symbol, TF, MA2_Period, 0, MA_Method, PRICE_CLOSE);
      m_hMA3 = iMA(_Symbol, TF, MA3_Period, 0, MA_Method, PRICE_CLOSE);
      m_hMACD = iMACD(_Symbol, TF, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE);
      m_hRSI = iRSI(_Symbol, TF, RSI_Period, PRICE_CLOSE);
      m_hADX = iADX(_Symbol, TF, ADX_Period);
      m_hATR = iATR(_Symbol, TF, ATR_Period);
      m_hStoch = iStochastic(_Symbol, TF, Stoch_K, Stoch_D, Stoch_Slowing, MODE_SMA, STO_LOWHIGH);
      
      return (m_hMA1 != INVALID_HANDLE && m_hMA2 != INVALID_HANDLE && m_hMA3 != INVALID_HANDLE &&
              m_hMACD != INVALID_HANDLE && m_hRSI != INVALID_HANDLE && m_hADX != INVALID_HANDLE);
   }
   
   void UpdateATR() {
      double atr[]; ArraySetAsSeries(atr, true);
      if(CopyBuffer(m_hATR, 0, 0, 1, atr) >= 1) m_lastATR = atr[0];
   }
   
   void UpdateBarState() {
      datetime currentBar = iTime(_Symbol, TF, 0);
      if(m_lastBarTime != currentBar) {
         m_lastBarTime = currentBar;
         m_barsSinceTrade++;
         m_signalGivenThisBar = false;
      }
   }
   
   bool CanTrade() {
      if(m_barsSinceTrade < CooldownBars) return false;
      if(m_signalGivenThisBar) return false;
      return true;
   }
   
   void OnTradeOpened() { m_barsSinceTrade = 0; m_signalGivenThisBar = true; }
   
   //=== MA CROSS SKORU (0-100) ===
   double ScoreMACross(int &direction) {
      double ma1[], ma2[], ma3[];
      ArraySetAsSeries(ma1, true); ArraySetAsSeries(ma2, true); ArraySetAsSeries(ma3, true);
      if(CopyBuffer(m_hMA1, 0, 0, 3, ma1) < 3) return 0;
      if(CopyBuffer(m_hMA2, 0, 0, 3, ma2) < 3) return 0;
      if(CopyBuffer(m_hMA3, 0, 0, 3, ma3) < 3) return 0;
      
      double score = 0;
      
      // Cross tespiti
      bool crossUp = (ma1[2] <= ma2[2]) && (ma1[1] > ma2[1]);
      bool crossDown = (ma1[2] >= ma2[2]) && (ma1[1] < ma2[1]);
      
      // Trend yönü
      bool upTrend = (ma1[0] > ma2[0]);
      bool downTrend = (ma1[0] < ma2[0]);
      
      // MA3 pozisyonu
      bool aboveMA3 = (ma1[0] > ma3[0]) && (ma2[0] > ma3[0]);
      bool belowMA3 = (ma1[0] < ma3[0]) && (ma2[0] < ma3[0]);
      
      // MA'lar arası mesafe (trend gücü)
      double spread12 = MathAbs(ma1[0] - ma2[0]) / ma3[0] * 10000;
      double spread23 = MathAbs(ma2[0] - ma3[0]) / ma3[0] * 10000;
      
      if(crossUp || upTrend) {
         direction = 1;
         score = 50; // Base score
         if(crossUp) score += 30; // Cross bonus
         if(aboveMA3) score += 20; // MA3 bonus
         score = MathMin(100, score + spread12 * 2); // Spread bonus
      }
      else if(crossDown || downTrend) {
         direction = -1;
         score = 50;
         if(crossDown) score += 30;
         if(belowMA3) score += 20;
         score = MathMin(100, score + spread12 * 2);
      }
      
      return score;
   }
   
   //=== MACD SKORU (0-100) ===
   double ScoreMACD(int direction) {
      if(!UseMACD) return 50; // Nötr
      
      double main[], sig[], hist[];
      ArraySetAsSeries(main, true); ArraySetAsSeries(sig, true); ArraySetAsSeries(hist, true);
      if(CopyBuffer(m_hMACD, 0, 0, 2, main) < 2) return 50;
      if(CopyBuffer(m_hMACD, 1, 0, 2, sig) < 2) return 50;
      if(CopyBuffer(m_hMACD, 2, 0, 2, hist) < 2) return 50;
      
      double score = 50;
      bool histPositive = (hist[0] > 0);
      bool histRising = (hist[0] > hist[1]);
      bool macdCrossUp = (main[1] <= sig[1]) && (main[0] > sig[0]);
      bool macdCrossDown = (main[1] >= sig[1]) && (main[0] < sig[0]);
      
      if(direction == 1) {
         if(histPositive) score += 25;
         if(histRising) score += 15;
         if(macdCrossUp) score += 10;
      } else if(direction == -1) {
         if(!histPositive) score += 25;
         if(!histRising) score += 15;
         if(macdCrossDown) score += 10;
      }
      
      return MathMin(100, score);
   }
   
   //=== RSI SKORU (0-100) ===
   double ScoreRSI(int direction) {
      if(!UseRSI) return 50;
      
      double rsi[];
      ArraySetAsSeries(rsi, true);
      if(CopyBuffer(m_hRSI, 0, 0, 1, rsi) < 1) return 50;
      
      double score = 50;
      double rsiVal = rsi[0];
      
      if(direction == 1) {
         if(rsiVal < 30) score = 100; // Aşırı satım - güçlü alım
         else if(rsiVal < 40) score = 80;
         else if(rsiVal < 50) score = 60;
         else if(rsiVal < 60) score = 50;
         else if(rsiVal > 70) score = 20; // Aşırı alım - zayıf alım
         else score = 40;
      } else if(direction == -1) {
         if(rsiVal > 70) score = 100; // Aşırı alım - güçlü satım
         else if(rsiVal > 60) score = 80;
         else if(rsiVal > 50) score = 60;
         else if(rsiVal > 40) score = 50;
         else if(rsiVal < 30) score = 20; // Aşırı satım - zayıf satım
         else score = 40;
      }
      
      return score;
   }
   
   //=== ADX SKORU (0-100) ===
   double ScoreADX() {
      if(!UseADX) return 50;
      
      double adx[], plusDI[], minusDI[];
      ArraySetAsSeries(adx, true); ArraySetAsSeries(plusDI, true); ArraySetAsSeries(minusDI, true);
      if(CopyBuffer(m_hADX, 0, 0, 1, adx) < 1) return 50;
      if(CopyBuffer(m_hADX, 1, 0, 1, plusDI) < 1) return 50;
      if(CopyBuffer(m_hADX, 2, 0, 1, minusDI) < 1) return 50;
      
      double adxVal = adx[0];
      
      // Trend gücü skoru
      if(adxVal >= 40) return 100; // Çok güçlü trend
      if(adxVal >= 30) return 85;
      if(adxVal >= 25) return 70;
      if(adxVal >= 20) return 55;
      if(adxVal >= 15) return 40;
      return 25; // Zayıf trend
   }
   
   //=== STOCHASTIC SKORU (0-100) ===
   double ScoreStochastic(int direction) {
      if(!UseStochastic) return 50;
      
      double k[], d[];
      ArraySetAsSeries(k, true); ArraySetAsSeries(d, true);
      if(CopyBuffer(m_hStoch, 0, 0, 2, k) < 2) return 50;
      if(CopyBuffer(m_hStoch, 1, 0, 2, d) < 2) return 50;
      
      double score = 50;
      bool stochCrossUp = (k[1] <= d[1]) && (k[0] > d[0]);
      bool stochCrossDown = (k[1] >= d[1]) && (k[0] < d[0]);
      
      if(direction == 1) {
         if(k[0] < 20) score = 90; // Aşırı satım
         else if(k[0] < 40) score = 70;
         if(stochCrossUp && k[0] < 50) score += 20;
      } else if(direction == -1) {
         if(k[0] > 80) score = 90; // Aşırı alım
         else if(k[0] > 60) score = 70;
         if(stochCrossDown && k[0] > 50) score += 20;
      }
      
      return MathMin(100, score);
   }
   
   //=== PATTERN SKORU (0-100) ===
   double ScorePattern(int direction) {
      if(!UseCandlePatterns) return 50;
      
      ENUM_CANDLE_PATTERN pattern = CCandleAnalyzer::DetectPattern(1);
      int patternDir = CCandleAnalyzer::GetPatternDirection(pattern);
      int patternScore = CCandleAnalyzer::GetPatternScore(pattern);
      
      if(patternDir == direction) {
         return patternScore;
      } else if(patternDir == -direction) {
         return 100 - patternScore; // Ters yönde penalty
      }
      
      return 50; // Nötr
   }
   
   //=== FİTİL SKORU (0-100) ===
   double ScoreWick(int direction) {
      if(!UseWickAnalysis) return 50;
      
      double upperRatio = CCandleAnalyzer::GetWickRatio(1, true);
      double lowerRatio = CCandleAnalyzer::GetWickRatio(1, false);
      double bodyRatio = CCandleAnalyzer::GetBodyRatio(1);
      
      double score = 50;
      
      if(direction == 1) {
         // Uzun alt fitil = alım baskısı
         if(lowerRatio > 0.4) score = 85;
         else if(lowerRatio > 0.3) score = 70;
         
         // Uzun üst fitil = satım baskısı (alım için kötü)
         if(upperRatio > 0.4) score -= 20;
      } else if(direction == -1) {
         // Uzun üst fitil = satım baskısı
         if(upperRatio > 0.4) score = 85;
         else if(upperRatio > 0.3) score = 70;
         
         // Uzun alt fitil = alım baskısı (satım için kötü)
         if(lowerRatio > 0.4) score -= 20;
      }
      
      return MathMax(0, MathMin(100, score));
   }
   
   //=== ANA SKOR FONKSİYONU ===
   int CalculateTotalScore(int &outDirection) {
      m_signalReasons = "";
      int direction = 0;
      
      // 1. MA Cross skoru ve yön tespiti
      m_scoreMACross = ScoreMACross(direction);
      if(direction == 0) return 0;
      
      outDirection = direction;
      
      // 2. Diğer gösterge skorları
      m_scoreMACD = ScoreMACD(direction);
      m_scoreRSI = ScoreRSI(direction);
      m_scoreADX = ScoreADX();
      m_scoreStoch = ScoreStochastic(direction);
      m_scorePattern = ScorePattern(direction);
      m_scoreWick = ScoreWick(direction);
      
      // 3. Ağırlıklı toplam
      double totalWeight = Weight_MACross + Weight_MACD + Weight_RSI + Weight_ADX + 
                          Weight_Stoch + Weight_Pattern + Weight_Wick;
      
      double weightedScore = (m_scoreMACross * Weight_MACross + 
                             m_scoreMACD * Weight_MACD +
                             m_scoreRSI * Weight_RSI +
                             m_scoreADX * Weight_ADX +
                             m_scoreStoch * Weight_Stoch +
                             m_scorePattern * Weight_Pattern +
                             m_scoreWick * Weight_Wick) / totalWeight;
      
      // Sebepleri oluştur
      m_signalReasons = StringFormat("MA:%.0f MACD:%.0f RSI:%.0f ADX:%.0f ST:%.0f PAT:%.0f WK:%.0f",
         m_scoreMACross, m_scoreMACD, m_scoreRSI, m_scoreADX, m_scoreStoch, m_scorePattern, m_scoreWick);
      
      m_lastDirection = direction;
      m_lastTotalScore = (int)weightedScore;
      
      return (int)weightedScore;
   }
   
   string GetSignalReasons() { return m_signalReasons; }
   
   //=== ANA SİNYAL FONKSİYONU ===
   int GetSignal() {
      int direction = 0;
      int score = CalculateTotalScore(direction);
      
      g_LastSignalScore = score;
      g_LastSignalReason = m_signalReasons;
      
      // Adaptif eşik
      int threshold = MinSignalScore;
      if(UseAdaptiveThreshold) {
         // ADX yüksekse eşiği düşür (güçlü trendde daha az seçici)
         double adx[];
         ArraySetAsSeries(adx, true);
         if(CopyBuffer(m_hADX, 0, 0, 1, adx) >= 1) {
            if(adx[0] > 30) threshold -= 10;
            else if(adx[0] < 20) threshold += 10;
         }
      }
      
      if(score >= threshold) {
         if(ShowDebugLog) {
            Print("═══════════════════════════════════════════════════════════");
            Print("🤖 AI SKOR: ", score, "/100 | Eşik: ", threshold);
            Print("   📊 ", m_signalReasons);
            Print("   ➡️ ", (direction == 1 ? "BUY" : "SELL"), " SİNYALİ");
            Print("═══════════════════════════════════════════════════════════");
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
   double m_refBalance, m_lastKnownBalance;
   int m_dayOfYear, m_dailyTradeCount;
public:
   CSecurityManager() : m_refBalance(0), m_lastKnownBalance(0), m_dayOfYear(0), m_dailyTradeCount(0) {}
   void Init() { UpdateReference(true); }
   void UpdateReference(bool forceReset = false) {
      MqlDateTime dt; TimeCurrent(dt);
      if(forceReset || dt.day_of_year != m_dayOfYear) {
         m_dayOfYear = dt.day_of_year;
         m_refBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         m_lastKnownBalance = m_refBalance;
         m_dailyTradeCount = 0;
         g_SystemLocked = false; g_LockReason = "";
      }
   }
   bool IsSafeToTrade() {
      if(g_ManualPause) { g_LockReason = "PAUSE"; return false; }
      if(g_SystemLocked) return false;
      UpdateReference();
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double loss = m_refBalance - equity;
      if(loss >= MaxDailyDDMoney || (m_refBalance > 0 && (loss/m_refBalance)*100 >= MaxDailyDDPct)) {
         g_SystemLocked = true; g_LockReason = "GÜNLÜK LİMİT"; return false;
      }
      if(m_dailyTradeCount >= MaxDailyTrades) { g_LockReason = "İŞLEM LİMİTİ"; return false; }
      double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
      if(marginLevel > 0 && marginLevel < MinMarginLevel) { g_LockReason = "MARJİN"; return false; }
      if(UseTimeFilter) {
         MqlDateTime dt; TimeCurrent(dt);
         if(dt.hour < StartHour || dt.hour >= EndHour) { g_LockReason = "ZAMAN"; return false; }
      }
      long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      if(spread / 10.0 > MaxSpreadPips) { g_LockReason = "SPREAD"; return false; }
      g_LockReason = ""; return true;
   }
   void IncrementTradeCount() { m_dailyTradeCount++; }
   int GetTradeCount() { return m_dailyTradeCount; }
   double GetDailyPL() { return AccountInfoDouble(ACCOUNT_EQUITY) - m_refBalance; }
};

//====================================================================
// CLASS: TRADE EXECUTOR
//====================================================================
class CTradeExecutor
{
private:
   CTrade m_trade;
public:
   void Init() { m_trade.SetExpertMagicNumber(MagicNumber); m_trade.SetTypeFilling(ORDER_FILLING_FOK); m_trade.SetDeviationInPoints(20); }
   
   bool OpenMarketOrder(int direction, double atr) {
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      double slDist, tpDist; CPriceEngine::GetDynamicSLTP(atr, slDist, tpDist);
      double slPips = CPriceEngine::PointsToPip(slDist);
      double lot = CPriceEngine::CalculateLot(slPips);
      double price = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double sl, tp;
      if(direction == 1) { sl = NormalizeDouble(price - slDist, digits); tp = NormalizeDouble(price + tpDist, digits); if(!CPriceEngine::CheckStopLevel(price, sl, tp, 1)) return false; m_trade.Buy(lot, _Symbol, 0, sl, tp, TradeComment); }
      else { sl = NormalizeDouble(price + slDist, digits); tp = NormalizeDouble(price - tpDist, digits); if(!CPriceEngine::CheckStopLevel(price, sl, tp, -1)) return false; m_trade.Sell(lot, _Symbol, 0, sl, tp, TradeComment); }
      if(m_trade.ResultRetcode() == TRADE_RETCODE_DONE) {
         Print("═══════════════════════════════════════════════════════════");
         Print("🤖 AI v12 ", (direction == 1 ? "BUY" : "SELL"), " | Skor: ", g_LastSignalScore, "/100");
         Print("   💰 Lot: ", lot, " | SL: ", slPips, " pip | TP: ", CPriceEngine::PointsToPip(tpDist), " pip");
         Print("   📊 ", g_LastSignalReason);
         Print("═══════════════════════════════════════════════════════════");
         return true;
      }
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
   
   bool HasOpenPosition() {
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber && PositionGetString(POSITION_SYMBOL) == _Symbol) return true;
      }
      return false;
   }
   
   CTrade* GetTrade() { return &m_trade; }
};

//====================================================================
// CLASS: POSITION MANAGER
//====================================================================
class CPositionManager
{
private:
   CTrade* m_pTrade;
   int m_totalTrades, m_winTrades;
   double m_grossProfit, m_grossLoss, m_netProfit;
public:
   CPositionManager() : m_pTrade(NULL), m_totalTrades(0), m_winTrades(0), m_grossProfit(0), m_grossLoss(0), m_netProfit(0) {}
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
         
         // Smart Partial Close
         if(UseSmartPartial && tpDist > 0 && profitDist >= tpDist * (Partial_TriggerPct / 100.0)) {
            bool isBE = (MathAbs(currentSL - openPrice) < CPriceEngine::PipToPoints(5));
            double minVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
            if(!isBE && volume > minVol) {
               double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
               double closeVol = MathFloor((volume * Partial_ClosePct / 100.0) / lotStep) * lotStep;
               if(closeVol >= minVol) { m_pTrade.PositionClosePartial(ticket, closeVol); Print("💰 Kısmi kapama: ", closeVol); }
            }
         }
         
         // Breakeven
         if(UseBreakeven && tpDist > 0 && profitDist >= tpDist * (BE_TriggerPct / 100.0)) {
            double bePrice;
            if(posType == POSITION_TYPE_BUY) { bePrice = NormalizeDouble(openPrice + CPriceEngine::PipToPoints(BE_LockPips), digits); if(currentSL < bePrice) m_pTrade.PositionModify(ticket, bePrice, currentTP); }
            else { bePrice = NormalizeDouble(openPrice - CPriceEngine::PipToPoints(BE_LockPips), digits); if(currentSL > bePrice || currentSL == 0) m_pTrade.PositionModify(ticket, bePrice, currentTP); }
         }
         
         // Trailing Stop
         if(UseTrailing && atr > 0 && tpDist > 0 && profitDist >= tpDist * (Trail_StartPct / 100.0)) {
            double trailDist = atr * Trail_ATR_Multi;
            double newSL;
            if(posType == POSITION_TYPE_BUY) { newSL = NormalizeDouble(currentPrice - trailDist, digits); if(newSL > currentSL) m_pTrade.PositionModify(ticket, newSL, currentTP); }
            else { newSL = NormalizeDouble(currentPrice + trailDist, digits); if(newSL < currentSL || currentSL == 0) m_pTrade.PositionModify(ticket, newSL, currentTP); }
         }
      }
   }
   
   void UpdateStats(double profit) { m_netProfit += profit; if(profit > 0) { m_winTrades++; m_grossProfit += profit; } else m_grossLoss += profit; }
   void IncrementTrades() { m_totalTrades++; }
   int GetTotalTrades() { return m_totalTrades; }
   int GetWinTrades() { return m_winTrades; }
   double GetNetProfit() { return m_netProfit; }
   double GetWinRate() { return (m_totalTrades > 0) ? m_winTrades * 100.0 / m_totalTrades : 0; }
   double GetProfitFactor() { return (m_grossLoss != 0) ? m_grossProfit / MathAbs(m_grossLoss) : 0; }
   double GetExpectancy() { if(m_totalTrades < 5) return 0; double wr = (double)m_winTrades / m_totalTrades; double avgW = (m_winTrades > 0) ? m_grossProfit / m_winTrades : 0; double avgL = (m_totalTrades - m_winTrades > 0) ? MathAbs(m_grossLoss) / (m_totalTrades - m_winTrades) : 0; return (wr * avgW) - ((1-wr) * avgL); }
   void PrintStats() { Print("📊 SONUÇLAR: ", m_totalTrades, " işlem | WR: ", DoubleToString(GetWinRate(), 1), "% | PF: ", DoubleToString(GetProfitFactor(), 2), " | Net: $", DoubleToString(m_netProfit, 2)); }
};

//====================================================================
// GLOBAL NESNELER
//====================================================================
CSecurityManager Security;
CAISignalScorer  AIScorer;
CTradeExecutor   Executor;
CPositionManager PosMgr;

//+------------------------------------------------------------------+
//| ONINIT                                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   if(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL) { Alert("❌ Sembol kapalı!"); return INIT_FAILED; }
   if(!AIScorer.Init()) { Alert("❌ Gösterge hatası!"); return INIT_FAILED; }
   Security.Init(); Executor.Init(); PosMgr.Init(Executor.GetTrade());
   Print("═══════════════════════════════════════════════════════════════════");
   Print("🤖 MİLYONER EA v12.0 - AI ENHANCED");
   Print("═══════════════════════════════════════════════════════════════════");
   Print("📊 AI Skor Eşiği: ", MinSignalScore, " | Adaptif: ", UseAdaptiveThreshold);
   Print("📊 7 Faktör Oylama: MA(", Weight_MACross, ") MACD(", Weight_MACD, ") RSI(", Weight_RSI, ") ADX(", Weight_ADX, ") Stoch(", Weight_Stoch, ") Pattern(", Weight_Pattern, ") Wick(", Weight_Wick, ")");
   Print("📊 Mum Pattern: ", UseCandlePatterns ? "AÇIK" : "KAPALI", " | Fitil Analizi: ", UseWickAnalysis ? "AÇIK" : "KAPALI");
   Print("═══════════════════════════════════════════════════════════════════");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) { PosMgr.PrintStats(); Comment(""); }

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   if(id == CHARTEVENT_KEYDOWN) {
      if(lparam == 80 || lparam == 112) { g_ManualPause = !g_ManualPause; Alert(g_ManualPause ? "⏸️ PAUSE" : "▶️ RESUME"); }
      else if(lparam == 67 || lparam == 99) { if(MessageBox("Tüm pozisyonları kapat?", "ACİL", MB_YESNO) == IDYES) { Executor.EmergencyCloseAll(); g_ManualPause = true; } }
      else if(lparam == 68 || lparam == 100) { Security.UpdateReference(true); g_SystemLocked = false; Alert("🔄 RESET"); }
   }
}

void OnTick()
{
   AIScorer.UpdateATR(); AIScorer.UpdateBarState();
   if(ShowDashboard) UpdateDashboard();
   if(g_ManualPause) return;
   if(!Security.IsSafeToTrade()) { if(g_SystemLocked) Executor.EmergencyCloseAll(); return; }
   PosMgr.ManagePositions(AIScorer.m_lastATR);
   if(Executor.HasOpenPosition()) return;
   if(!AIScorer.CanTrade()) return;
   int signal = AIScorer.GetSignal();
   if(signal != 0) {
      if(Executor.OpenMarketOrder(signal, AIScorer.m_lastATR)) {
         AIScorer.OnTradeOpened(); Security.IncrementTradeCount(); PosMgr.IncrementTrades();
      }
   }
}

void UpdateDashboard()
{
   string status = g_ManualPause ? "⏸️ PAUSE" : (g_SystemLocked ? "🔒 "+g_LockReason : (g_LockReason != "" ? "⏳ "+g_LockReason : "✅ AKTİF"));
   string dash = "";
   dash += "═══════════════════════════════════════\n";
   dash += "   🤖 MİLYONER EA v12.0 AI-ENHANCED\n";
   dash += "═══════════════════════════════════════\n";
   dash += status + "\n";
   dash += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   dash += "🎯 SON SKOR: " + IntegerToString(g_LastSignalScore) + "/100 (Eşik:" + IntegerToString(MinSignalScore) + ")\n";
   dash += "📊 " + g_LastSignalReason + "\n";
   dash += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   dash += "💰 Günlük: $" + DoubleToString(Security.GetDailyPL(), 2) + "\n";
   dash += "📊 İşlem: " + IntegerToString(Security.GetTradeCount()) + "/" + IntegerToString(MaxDailyTrades) + "\n";
   dash += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   dash += "📈 Toplam: " + IntegerToString(PosMgr.GetTotalTrades()) + " | Win: " + IntegerToString(PosMgr.GetWinTrades()) + "\n";
   dash += "⚖️ WR: " + DoubleToString(PosMgr.GetWinRate(), 1) + "% | PF: " + DoubleToString(PosMgr.GetProfitFactor(), 2) + "\n";
   dash += "💵 Net: $" + DoubleToString(PosMgr.GetNetProfit(), 2) + "\n";
   dash += "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n";
   dash += "⌨️ [P]ause [C]lose [D]ailyReset\n";
   dash += "═══════════════════════════════════════\n";
   Comment(dash);
}

//+------------------------------------------------------------------+
//| v12 AI-Enhanced - Machine Learning Inspired Architecture         |
//| 7-Factor Weighted Voting System                                  |
//| Candle Pattern Recognition + Wick Analysis                        |
//| © 2025, Milyoner EA Project                                       |
//+------------------------------------------------------------------+

//====================================================================
// HARMONY EXTENSION - Gelişmiş Teknik Analiz Modülleri
//====================================================================

//+------------------------------------------------------------------+
//| CLASS: Advanced Price Levels (Fibonacci + Pivot + S/R)           |
//+------------------------------------------------------------------+
class CAdvancedLevels
{
public:
   // Pivot seviyeleri
   double m_pivot, m_r1, m_r2, m_r3, m_s1, m_s2, m_s3;
   
   // Fibonacci seviyeleri
   double m_fib236, m_fib382, m_fib500, m_fib618, m_fib786;
   
   // S/R seviyeleri
   double m_support, m_resistance;
   
   // Son güncelleme
   datetime m_lastUpdate;
   
   CAdvancedLevels() : m_lastUpdate(0) {}
   
   //=== GÜNLÜK PİVOT HESAPLA ===
   void CalculatePivots()
   {
      double high = iHigh(_Symbol, PERIOD_D1, 1);
      double low = iLow(_Symbol, PERIOD_D1, 1);
      double close = iClose(_Symbol, PERIOD_D1, 1);
      
      m_pivot = (high + low + close) / 3.0;
      
      m_r1 = 2 * m_pivot - low;
      m_s1 = 2 * m_pivot - high;
      
      m_r2 = m_pivot + (high - low);
      m_s2 = m_pivot - (high - low);
      
      m_r3 = high + 2 * (m_pivot - low);
      m_s3 = low - 2 * (high - m_pivot);
   }
   
   //=== FİBONACCİ SEVİYELERİ ===
   void CalculateFibonacci(int lookback = 50)
   {
      double highest = 0, lowest = 999999;
      
      for(int i = 1; i <= lookback; i++) {
         double high = iHigh(_Symbol, TF, i);
         double low = iLow(_Symbol, TF, i);
         if(high > highest) highest = high;
         if(low < lowest) lowest = low;
      }
      
      double range = highest - lowest;
      
      m_fib236 = highest - range * 0.236;
      m_fib382 = highest - range * 0.382;
      m_fib500 = highest - range * 0.500;
      m_fib618 = highest - range * 0.618;
      m_fib786 = highest - range * 0.786;
      
      m_resistance = highest;
      m_support = lowest;
   }
   
   //=== SEVİYELERİ GÜNCELLE ===
   void Update()
   {
      MqlDateTime dt;
      TimeCurrent(dt);
      datetime today = StringToTime(IntegerToString(dt.year) + "." + IntegerToString(dt.mon) + "." + IntegerToString(dt.day));
      
      if(m_lastUpdate != today) {
         CalculatePivots();
         CalculateFibonacci();
         m_lastUpdate = today;
         
         if(ShowDebugLog) {
            Print("📊 SEVİYELER GÜNCELLENDİ:");
            Print("   Pivot: ", m_pivot, " | R1: ", m_r1, " | S1: ", m_s1);
            Print("   Fib 38.2: ", m_fib382, " | Fib 61.8: ", m_fib618);
            Print("   S/R: ", m_support, " - ", m_resistance);
         }
      }
   }
   
   //=== FİYAT SEVİYE SKORU (0-100) ===
   int GetLevelScore(int direction)
   {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      int score = 50;
      double atrDist = CPriceEngine::PipToPoints(10); // 10 pip tolerans
      
      if(direction == 1) { // BUY
         // Destek seviyesine yakınsa iyi
         if(MathAbs(price - m_s1) < atrDist) score += 25;
         else if(MathAbs(price - m_s2) < atrDist) score += 20;
         else if(MathAbs(price - m_support) < atrDist) score += 30;
         
         // Fibonacci seviyesine yakınsa
         if(MathAbs(price - m_fib618) < atrDist) score += 25;
         else if(MathAbs(price - m_fib382) < atrDist) score += 15;
         
         // Dirence yakınsa kötü
         if(price > m_r1) score -= 20;
         if(price > m_resistance - atrDist) score -= 30;
      }
      else if(direction == -1) { // SELL
         // Direnç seviyesine yakınsa iyi
         if(MathAbs(price - m_r1) < atrDist) score += 25;
         else if(MathAbs(price - m_r2) < atrDist) score += 20;
         else if(MathAbs(price - m_resistance) < atrDist) score += 30;
         
         // Fibonacci seviyesine yakınsa
         if(MathAbs(price - m_fib382) < atrDist) score += 25;
         else if(MathAbs(price - m_fib618) < atrDist) score += 15;
         
         // Desteğe yakınsa kötü
         if(price < m_s1) score -= 20;
         if(price < m_support + atrDist) score -= 30;
      }
      
      return MathMax(0, MathMin(100, score));
   }
};

//+------------------------------------------------------------------+
//| CLASS: Signal History & Learning (Basit ML Simülasyonu)          |
//+------------------------------------------------------------------+
class CSignalHistory
{
private:
   int m_historySize;
   int m_signals[];      // 1=buy, -1=sell
   int m_scores[];       // 0-100
   int m_results[];      // 1=win, 0=loss
   int m_count;
   
public:
   CSignalHistory() : m_historySize(100), m_count(0) {
      ArrayResize(m_signals, m_historySize);
      ArrayResize(m_scores, m_historySize);
      ArrayResize(m_results, m_historySize);
   }
   
   //=== SİNYAL KAYDET ===
   void RecordSignal(int signal, int score)
   {
      if(m_count >= m_historySize) {
         // Shift array
         for(int i = 0; i < m_historySize - 1; i++) {
            m_signals[i] = m_signals[i+1];
            m_scores[i] = m_scores[i+1];
            m_results[i] = m_results[i+1];
         }
         m_count = m_historySize - 1;
      }
      
      m_signals[m_count] = signal;
      m_scores[m_count] = score;
      m_results[m_count] = -1; // Henüz bilinmiyor
      m_count++;
   }
   
   //=== SONUÇ GÜNCELLE ===
   void UpdateLastResult(bool isWin)
   {
      if(m_count > 0) {
         m_results[m_count - 1] = isWin ? 1 : 0;
      }
   }
   
   //=== SKOR BAZINDA WIN RATE ===
   double GetWinRateByScore(int minScore, int maxScore)
   {
      int wins = 0, total = 0;
      
      for(int i = 0; i < m_count; i++) {
         if(m_results[i] >= 0 && m_scores[i] >= minScore && m_scores[i] <= maxScore) {
            total++;
            if(m_results[i] == 1) wins++;
         }
      }
      
      return (total > 0) ? (double)wins / total * 100 : 50;
   }
   
   //=== OPTİMAL SKOR EŞİĞİ BUL ===
   int GetOptimalThreshold()
   {
      int bestThreshold = 60;
      double bestWinRate = 0;
      
      for(int threshold = 50; threshold <= 80; threshold += 5) {
         double wr = GetWinRateByScore(threshold, 100);
         if(wr > bestWinRate) {
            bestWinRate = wr;
            bestThreshold = threshold;
         }
      }
      
      return bestThreshold;
   }
   
   //=== PATTERN BAZINDA ANALİZ ===
   void PrintAnalysis()
   {
      if(m_count < 10) {
         Print("📊 Yeterli veri yok (min 10 trade)");
         return;
      }
      
      Print("═══════════════════════════════════════════════════════════");
      Print("📊 SİNYAL GEÇMİŞİ ANALİZİ");
      Print("═══════════════════════════════════════════════════════════");
      Print("   50-59 Skor WR: ", DoubleToString(GetWinRateByScore(50, 59), 1), "%");
      Print("   60-69 Skor WR: ", DoubleToString(GetWinRateByScore(60, 69), 1), "%");
      Print("   70-79 Skor WR: ", DoubleToString(GetWinRateByScore(70, 79), 1), "%");
      Print("   80-100 Skor WR: ", DoubleToString(GetWinRateByScore(80, 100), 1), "%");
      Print("   Optimal Eşik: ", GetOptimalThreshold());
      Print("═══════════════════════════════════════════════════════════");
   }
};

//+------------------------------------------------------------------+
//| CLASS: Multi-Timeframe Analysis                                   |
//+------------------------------------------------------------------+
class CMTFAnalysis
{
public:
   //=== ÜST ZAMAN DİLİMİ TREND ===
   static int GetHigherTFTrend()
   {
      int hMA = iMA(_Symbol, PERIOD_H4, 50, 0, MODE_EMA, PRICE_CLOSE);
      if(hMA == INVALID_HANDLE) return 0;
      
      double ma[], price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      ArraySetAsSeries(ma, true);
      if(CopyBuffer(hMA, 0, 0, 1, ma) < 1) { IndicatorRelease(hMA); return 0; }
      
      IndicatorRelease(hMA);
      
      if(price > ma[0]) return 1;
      if(price < ma[0]) return -1;
      return 0;
   }
   
   //=== ÇOK ZAMAN DİLİMİ SKORU ===
   static int GetMTFScore(int direction)
   {
      int score = 50;
      int htf = GetHigherTFTrend();
      
      if(htf == direction) score += 30;
      else if(htf == -direction) score -= 30;
      
      return MathMax(0, MathMin(100, score));
   }
};

//+------------------------------------------------------------------+
//| CLASS: Market Session Analysis                                    |
//+------------------------------------------------------------------+
class CSessionAnalysis
{
public:
   static string GetSession()
   {
      MqlDateTime dt;
      TimeCurrent(dt);
      int hour = dt.hour;
      
      if(hour >= 0 && hour < 8) return "ASIA";
      if(hour >= 8 && hour < 12) return "LONDON";
      if(hour >= 12 && hour < 17) return "OVERLAP";
      if(hour >= 17 && hour < 22) return "NEWYORK";
      return "OFF";
   }
   
   static int GetSessionScore()
   {
      string session = GetSession();
      if(session == "OVERLAP") return 100; // En iyi
      if(session == "LONDON") return 85;
      if(session == "NEWYORK") return 80;
      if(session == "ASIA") return 60;
      return 40; // OFF
   }
};

//+------------------------------------------------------------------+
//| CLASS: Advanced Pattern Recognition                               |
//+------------------------------------------------------------------+
class CAdvancedPatterns
{
public:
   //=== ÜÇ BEYAZ ASKER ===
   static bool IsThreeWhiteSoldiers()
   {
      for(int i = 1; i <= 3; i++) {
         double open = iOpen(_Symbol, TF, i);
         double close = iClose(_Symbol, TF, i);
         if(close <= open) return false; // Hepsi yeşil olmalı
         if(i > 1) {
            double prevClose = iClose(_Symbol, TF, i+1);
            if(open < prevClose) return false; // Her biri öncekinin üzerinde açmalı
         }
      }
      return true;
   }
   
   //=== ÜÇ SİYAH KARGA ===
   static bool IsThreeBlackCrows()
   {
      for(int i = 1; i <= 3; i++) {
         double open = iOpen(_Symbol, TF, i);
         double close = iClose(_Symbol, TF, i);
         if(close >= open) return false; // Hepsi kırmızı olmalı
         if(i > 1) {
            double prevClose = iClose(_Symbol, TF, i+1);
            if(open > prevClose) return false;
         }
      }
      return true;
   }
   
   //=== MORNING STAR ===
   static bool IsMorningStar()
   {
      double o1 = iOpen(_Symbol, TF, 3), c1 = iClose(_Symbol, TF, 3);
      double o2 = iOpen(_Symbol, TF, 2), c2 = iClose(_Symbol, TF, 2);
      double o3 = iOpen(_Symbol, TF, 1), c3 = iClose(_Symbol, TF, 1);
      
      bool firstBearish = (c1 < o1);
      bool secondSmall = MathAbs(c2 - o2) < MathAbs(c1 - o1) * 0.3;
      bool thirdBullish = (c3 > o3) && (c3 > (o1 + c1) / 2);
      
      return firstBearish && secondSmall && thirdBullish;
   }
   
   //=== EVENING STAR ===
   static bool IsEveningStar()
   {
      double o1 = iOpen(_Symbol, TF, 3), c1 = iClose(_Symbol, TF, 3);
      double o2 = iOpen(_Symbol, TF, 2), c2 = iClose(_Symbol, TF, 2);
      double o3 = iOpen(_Symbol, TF, 1), c3 = iClose(_Symbol, TF, 1);
      
      bool firstBullish = (c1 > o1);
      bool secondSmall = MathAbs(c2 - o2) < MathAbs(c1 - o1) * 0.3;
      bool thirdBearish = (c3 < o3) && (c3 < (o1 + c1) / 2);
      
      return firstBullish && secondSmall && thirdBearish;
   }
   
   //=== GELİŞMİŞ PATTERN SKORU ===
   static int GetAdvancedPatternScore(int direction)
   {
      int score = 50;
      
      if(direction == 1) {
         if(IsThreeWhiteSoldiers()) score = 100;
         else if(IsMorningStar()) score = 95;
      }
      else if(direction == -1) {
         if(IsThreeBlackCrows()) score = 100;
         else if(IsEveningStar()) score = 95;
      }
      
      return score;
   }
};

//+------------------------------------------------------------------+
//| CLASS: Momentum Divergence Detection                              |
//+------------------------------------------------------------------+
class CDivergence
{
public:
   //=== RSI DİVERJANS ===
   static int CheckRSIDivergence()
   {
      int hRSI = iRSI(_Symbol, TF, 14, PRICE_CLOSE);
      if(hRSI == INVALID_HANDLE) return 0;
      
      double rsi[];
      ArraySetAsSeries(rsi, true);
      if(CopyBuffer(hRSI, 0, 0, 20, rsi) < 20) { IndicatorRelease(hRSI); return 0; }
      
      IndicatorRelease(hRSI);
      
      // Son 20 bar içinde divergence ara
      double price1 = iLow(_Symbol, TF, 1);
      double price2 = iLow(_Symbol, TF, 10);
      double rsi1 = rsi[1];
      double rsi2 = rsi[10];
      
      // Bullish Divergence: Fiyat düşüyor, RSI yükseliyor
      if(price1 < price2 && rsi1 > rsi2) return 1;
      
      price1 = iHigh(_Symbol, TF, 1);
      price2 = iHigh(_Symbol, TF, 10);
      
      // Bearish Divergence: Fiyat yükseliyor, RSI düşüyor
      if(price1 > price2 && rsi1 < rsi2) return -1;
      
      return 0;
   }
   
   static int GetDivergenceScore(int direction)
   {
      int div = CheckRSIDivergence();
      if(div == direction) return 90;
      if(div == -direction) return 20;
      return 50;
   }
};

//====================================================================
// HARMONY MANAGER - Tüm Modülleri Senkronize Eden Ana Sınıf
//====================================================================
class CHarmonyManager
{
public:
   CAdvancedLevels  Levels;
   CSignalHistory   History;
   
   int m_lastLevelScore;
   int m_lastMTFScore;
   int m_lastSessionScore;
   int m_lastAdvPatternScore;
   int m_lastDivergenceScore;
   
   CHarmonyManager() : m_lastLevelScore(50), m_lastMTFScore(50), m_lastSessionScore(50),
      m_lastAdvPatternScore(50), m_lastDivergenceScore(50) {}
   
   void Update() {
      Levels.Update();
   }
   
   //=== HARMONY SKORU HESAPLA ===
   int CalculateHarmonyScore(int direction, int baseScore)
   {
      // Tüm modüllerden skor al
      m_lastLevelScore = Levels.GetLevelScore(direction);
      m_lastMTFScore = CMTFAnalysis::GetMTFScore(direction);
      m_lastSessionScore = CSessionAnalysis::GetSessionScore();
      m_lastAdvPatternScore = CAdvancedPatterns::GetAdvancedPatternScore(direction);
      m_lastDivergenceScore = CDivergence::GetDivergenceScore(direction);
      
      // Ağırlıklı ortalama (base score en yüksek ağırlık)
      double totalWeight = 50 + 15 + 10 + 5 + 10 + 10;
      double weightedScore = (
         baseScore * 50.0 +               // Ana AI skoru
         m_lastLevelScore * 15.0 +        // S/R + Fibonacci
         m_lastMTFScore * 10.0 +          // Multi-Timeframe
         m_lastSessionScore * 5.0 +       // Session
         m_lastAdvPatternScore * 10.0 +   // Gelişmiş patternler
         m_lastDivergenceScore * 10.0     // RSI Divergence
      ) / totalWeight;
      
      return (int)MathMin(100, MathMax(0, weightedScore));
   }
   
   //=== HARMONY DETAY RAPORU ===
   string GetHarmonyDetails()
   {
      return StringFormat("LVL:%d MTF:%d SES:%d PAT:%d DIV:%d",
         m_lastLevelScore, m_lastMTFScore, m_lastSessionScore,
         m_lastAdvPatternScore, m_lastDivergenceScore);
   }
   
   //=== SİNYAL KAYDET ===
   void RecordSignal(int signal, int score) {
      History.RecordSignal(signal, score);
   }
   
   //=== SONUÇ GÜNCELLE ===
   void UpdateResult(bool isWin) {
      History.UpdateLastResult(isWin);
   }
   
   //=== ANALİZ YAZDIR ===
   void PrintAnalysis() {
      History.PrintAnalysis();
   }
};

// Global Harmony Manager
CHarmonyManager Harmony;

//+------------------------------------------------------------------+
//| EXTENDED ONTICK - Harmony Entegrasyonu                           |
//+------------------------------------------------------------------+
void OnTickHarmony()
{
   // Seviyeleri güncelle
   Harmony.Update();
}

//+------------------------------------------------------------------+
//| v12.5 ULTIMATE HARMONY EDITION                                   |
//| All-in-One Trading System with Synchronized Modules              |
//| AI + Fibonacci + Pivot + S/R + MTF + Sessions + Patterns         |
//| Signal History & Learning + Divergence Detection                 |
//| © 2025, Milyoner EA Project - HARMONY EDITION                    |
//+------------------------------------------------------------------+
