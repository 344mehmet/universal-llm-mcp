//+------------------------------------------------------------------+
//|                                      MA_Master_Scalper_v5.mq5    |
//|                     © 2025, Milyoner EA Project v5.0             |
//|                     ARAŞTIRMA BAZLI OPTİMİZE STRATEJİ            |
//+------------------------------------------------------------------+
//| v5 WEB ARAŞTIRMASI SONUÇLARI:                                    |
//| [1] Kelly Criterion: f% = S - (1-S)/R                            |
//| [2] Secret Mindset: 3-RSI Pullback + 5-ADX > 30                  |
//| [3] Trend Confirmation: Price > 50 EMA                           |
//| [4] Risk/Reward: Min 1:1.5 hedef                                 |
//| [5] Position Size: Max %1-2 risk per trade                       |
//| [6] Optimal Win Rate Target: %70-80                              |
//+------------------------------------------------------------------+
#property copyright "© 2025, Milyoner EA Project v5.0"
#property link      "https://github.com/milyoner-ea"
#property version   "5.00"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// v5: ARAŞTIRMA BAZLI FORMÜLLER
//====================================================================
//
// KELLY CRITERION (Optimal Lot):
// f% = WinRate - (1 - WinRate) / PayoffRatio
// f% = S - (1-S) / R
// Örnek: WR=%60, R=1.5 → f = 0.60 - 0.40/1.5 = 0.60 - 0.27 = 0.33 (%33)
// Güvenli Kelly: f/4 veya f/5 kullan (drawdown azaltmak için)
//
// SECRET MINDSET STRATEJİSİ:
// 1. Trend: Price > 50 EMA (uptrend) veya < 50 EMA (downtrend)
// 2. RSI Pullback: 3-period RSI < 20 (buy) veya > 80 (sell)  
// 3. ADX Strength: 5-period ADX > 30
// 4. Entry: İlk momentum mumunda
//
// R:R FORMÜLÜ:
// Take Profit = SL * RiskRewardRatio
// Min R:R = 1:1.5 (tercih: 1:2)
//====================================================================

//====================================================================
// INPUT PARAMETRELERİ - v5 ARAŞTIRMA BAZLI
//====================================================================

//--- 1. ANA AYARLAR
input group "═══ 1. ANA AYARLAR v5 ═══"
input ulong    MagicNumber        = 555555;        // 🎰 Magic Number
input string   TradeComment       = "MILYONER_v5"; // İşlem Yorumu
input bool     ShowDashboard      = true;          // Dashboard

//--- 2. SECRET MINDSET STRATEJİSİ
input group "═══ 2. SECRET MINDSET STRATEJİ ═══"
input ENUM_TIMEFRAMES SignalTimeframe = PERIOD_M5; // ⚡ Sinyal Timeframe
input int      TrendEMA_Period    = 50;            // 📈 Trend EMA (50)
input int      FastRSI_Period     = 3;             // 🔥 Hızlı RSI (3)
input int      FastADX_Period     = 5;             // ⚡ Hızlı ADX (5)
input int      RSI_Oversold       = 20;            // RSI Aşırı Satım
input int      RSI_Overbought     = 80;            // RSI Aşırı Alım
input int      ADX_MinStrength    = 30;            // Min ADX (trend gücü)

//--- 3. EMA CROSS (Opsiyonel - Ek Onay)
input group "═══ 3. EMA CROSS ONAY ═══"
input bool     UseEMACross        = true;          // EMA Cross Kullan
input int      EMA_Fast_Period    = 8;             // Hızlı EMA
input int      EMA_Slow_Period    = 21;            // Yavaş EMA

//--- 4. KELLY CRITERION LOT HESAPLAMA
input group "═══ 4. KELLY CRITERION ═══"
input bool     UseKellyCriterion  = true;          // ✅ Kelly Kullan
input double   KellyDivisor       = 4.0;           // Kelly Bölen (güvenlik)
input double   AssumedWinRate     = 0.60;          // Varsayılan WR (%60)
input double   AssumedPayoffRatio = 1.5;           // Varsayılan R:R (1:1.5)
input double   FixedRiskPercent   = 1.0;           // Sabit Risk % (Kelly kapalıysa)

//--- 5. RİSK/REWARD OPTİMİZASYONU
input group "═══ 5. RİSK/REWARD OPTİMİZASYONU ═══"
input double   MinRiskReward      = 1.5;           // Min R:R Oranı
input double   TargetRiskReward   = 2.0;           // Hedef R:R Oranı
input bool     UseATRStops        = true;          // ATR Bazlı SL/TP
input int      ATR_Period         = 14;            // ATR Periyodu
input double   ATR_SL_Multiplier  = 1.5;           // SL = ATR x 1.5
input int      MinSL_Pips         = 5;             // Min SL
input int      MaxSL_Pips         = 20;            // Max SL

//--- 6. SABİT SL/TP (Fallback)
input group "═══ 6. SABİT SL/TP ═══"
input int      TP_Pips            = 15;            // Take Profit (pip)
input int      SL_Pips            = 10;            // Stop Loss (pip)

//--- 7. LOT LİMİTLERİ
input group "═══ 7. LOT LİMİTLERİ ═══"
input double   StartingLot        = 0.01;          // Başlangıç Lot
input double   MaxLotSize         = 2.0;           // Max Lot
input double   MaxRiskPercent     = 2.0;           // Mutlak Max Risk %

//--- 8. TRAİLİNG VE BREAKEVEN
input group "═══ 8. TRAİLİNG/BREAKEVEN ═══"
input bool     UseTrailingStop    = true;          // Trailing Stop
input int      TrailingStart      = 10;            // Başlangıç (pip)
input int      TrailingStep       = 5;             // Adım (pip)
input bool     UseBreakeven       = true;          // Breakeven
input int      BreakevenStart     = 8;             // BE Tetikleme (pip)
input int      BreakevenProfit    = 2;             // BE Kâr (pip)

//--- 9. KORUMA VE FİLTRELER
input group "═══ 9. KORUMA ═══"
input int      MaxSpreadPips      = 3;             // Max Spread
input double   MaxDrawdownPercent = 20.0;          // Max DD %
input bool     CloseAllOnDrawdown = true;          // DD'de Kapat

//--- 10. ZAMAN FİLTRESİ
input group "═══ 10. ZAMAN FİLTRESİ ═══"
input bool     UseSessionFilter   = true;          // Seans Filtresi
input int      LondonStartHour    = 8;             // Londra Başlangıç
input int      NYEndHour          = 20;            // NY Bitiş

//--- 11. COOLDOWN
input group "═══ 11. COOLDOWN ═══"
input int      CooldownBars       = 2;             // Bar Bekleme
input int      CooldownSeconds    = 30;            // Saniye Bekleme

//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================
int      g_hEMA_Trend   = INVALID_HANDLE;
int      g_hEMA_Fast    = INVALID_HANDLE;
int      g_hEMA_Slow    = INVALID_HANDLE;
int      g_hRSI_Fast    = INVALID_HANDLE;
int      g_hADX_Fast    = INVALID_HANDLE;
int      g_hATR         = INVALID_HANDLE;

// İstatistikler (Kelly için)
int      g_totalTrades        = 0;
int      g_winTrades          = 0;
int      g_lossTrades         = 0;
double   g_grossProfit        = 0;
double   g_grossLoss          = 0;
double   g_totalProfit        = 0;
double   g_avgWin             = 0;
double   g_avgLoss            = 0;
double   g_dynamicWinRate     = 0;
double   g_dynamicPayoffRatio = 0;
double   g_kellyFraction      = 0;

// Takip
double   g_currentLot         = 0;
double   g_equityHigh         = 0;
double   g_maxDrawdownReached = 0;
datetime g_lastTradeTime      = 0;
datetime g_lastBarTime        = 0;
int      g_barsSinceTrade     = 0;
bool     g_isDrawdownPaused   = false;
string   g_currentState       = "BAŞLATILIYOR...";
string   g_rejectReason       = "";
double   g_lastATR            = 0;
int      g_currentSignal      = 0;
int      g_consecutiveWins    = 0;
int      g_consecutiveLosses  = 0;

CTrade   m_trade;

//====================================================================
// HELPER FONKSİYONLARI
//====================================================================
double PipsToPoints(double pips)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int multiplier = (digits == 3 || digits == 5) ? 10 : 1;
   return pips * multiplier * point;
}

double PointsToPips(double points)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int multiplier = (digits == 3 || digits == 5) ? 10 : 1;
   return points / (multiplier * point);
}

//====================================================================
// OnInit
//====================================================================
int OnInit()
{
   m_trade.SetExpertMagicNumber(MagicNumber);
   m_trade.SetDeviationInPoints(10);
   m_trade.SetMarginMode();
   m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   // Göstergeleri yükle
   g_hEMA_Trend = iMA(_Symbol, SignalTimeframe, TrendEMA_Period, 0, MODE_EMA, PRICE_CLOSE);
   g_hEMA_Fast = iMA(_Symbol, SignalTimeframe, EMA_Fast_Period, 0, MODE_EMA, PRICE_CLOSE);
   g_hEMA_Slow = iMA(_Symbol, SignalTimeframe, EMA_Slow_Period, 0, MODE_EMA, PRICE_CLOSE);
   g_hRSI_Fast = iRSI(_Symbol, SignalTimeframe, FastRSI_Period, PRICE_CLOSE);
   g_hADX_Fast = iADX(_Symbol, SignalTimeframe, FastADX_Period);
   g_hATR = iATR(_Symbol, SignalTimeframe, ATR_Period);
   
   if(g_hEMA_Trend == INVALID_HANDLE || g_hRSI_Fast == INVALID_HANDLE || 
      g_hADX_Fast == INVALID_HANDLE || g_hATR == INVALID_HANDLE)
   {
      Print("❌ Göstergeler yüklenemedi!");
      return INIT_FAILED;
   }
   
   g_currentLot = StartingLot;
   g_equityHigh = AccountInfoDouble(ACCOUNT_EQUITY);
   
   // Başlangıç Kelly hesaplama
   CalculateKellyFraction();
   
   Print("════════════════════════════════════════════════════════════════");
   Print("📊 MİLYONER EA v5.0 - ARAŞTIRMA BAZLI STRATEJİ");
   Print("════════════════════════════════════════════════════════════════");
   Print("🔬 Secret Mindset: ", TrendEMA_Period, " EMA + ", FastRSI_Period, "-RSI + ", FastADX_Period, "-ADX");
   Print("📈 Kelly Criterion: ", UseKellyCriterion ? "AKTİF" : "KAPALI");
   Print("⚖️ Min R:R: 1:", DoubleToString(MinRiskReward, 1));
   Print("💵 Başlangıç: $", DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2));
   Print("════════════════════════════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}

//====================================================================
// OnDeinit
//====================================================================
void OnDeinit(const int reason)
{
   if(g_hEMA_Trend != INVALID_HANDLE) IndicatorRelease(g_hEMA_Trend);
   if(g_hEMA_Fast != INVALID_HANDLE) IndicatorRelease(g_hEMA_Fast);
   if(g_hEMA_Slow != INVALID_HANDLE) IndicatorRelease(g_hEMA_Slow);
   if(g_hRSI_Fast != INVALID_HANDLE) IndicatorRelease(g_hRSI_Fast);
   if(g_hADX_Fast != INVALID_HANDLE) IndicatorRelease(g_hADX_Fast);
   if(g_hATR != INVALID_HANDLE) IndicatorRelease(g_hATR);
   
   double pf = g_grossLoss != 0 ? g_grossProfit / MathAbs(g_grossLoss) : 0;
   double wr = g_totalTrades > 0 ? (double)g_winTrades / g_totalTrades * 100.0 : 0;
   
   Print("════════════════════════════════════════════════════════════════");
   Print("📊 MİLYONER EA v5.0 - SONUÇLAR");
   Print("════════════════════════════════════════════════════════════════");
   Print("📊 Toplam: ", g_totalTrades, " | WR: ", DoubleToString(wr, 1), "%");
   Print("⚖️ Kâr Faktörü: ", DoubleToString(pf, 2));
   Print("💰 Net: $", DoubleToString(g_totalProfit, 2));
   Print("📈 Kelly f: ", DoubleToString(g_kellyFraction * 100, 1), "%");
   Print("📉 Max DD: ", DoubleToString(g_maxDrawdownReached, 1), "%");
   Print("════════════════════════════════════════════════════════════════");
   
   ObjectsDeleteAll(0, "MILYONER_");
}

//====================================================================
// OnTick
//====================================================================
void OnTick()
{
   if(ShowDashboard) UpdateDashboard();
   
   // ATR güncelle
   UpdateATR();
   
   // Drawdown kontrolü
   if(CheckDrawdown())
   {
      g_currentState = "⛔ DRAWDOWN LIMIT";
      return;
   }
   
   // Trailing ve Breakeven
   ManagePositions();
   
   // Güvenlik kontrolleri
   if(!IsSafeToTrade())
   {
      return;
   }
   
   // Bar kontrolü
   datetime currentBar = iTime(_Symbol, SignalTimeframe, 0);
   if(g_lastBarTime != currentBar)
   {
      g_lastBarTime = currentBar;
      g_barsSinceTrade++;
   }
   
   // Açık pozisyon kontrolü
   if(HasOpenPosition())
   {
      g_currentState = "📊 POZİSYON AKTİF";
      return;
   }
   
   // Cooldown
   if(!CheckCooldown())
   {
      g_currentState = "⏳ COOLDOWN";
      return;
   }
   
   // v5: SECRET MINDSET SİNYAL
   int signal = GetSecretMindsetSignal();
   g_currentSignal = signal;
   
   if(signal == 1)
   {
      g_currentState = "🟢 BUY SİNYALİ!";
      OpenTrade(ORDER_TYPE_BUY);
   }
   else if(signal == -1)
   {
      g_currentState = "🔴 SELL SİNYALİ!";
      OpenTrade(ORDER_TYPE_SELL);
   }
   else
   {
      g_currentState = "⏳ " + g_rejectReason;
   }
}

//====================================================================
// v5: SECRET MINDSET SİNYAL SİSTEMİ
//====================================================================
int GetSecretMindsetSignal()
{
   g_rejectReason = "SİNYAL BEKLENİYOR";
   
   // 1. TREND EMA (50) - Fiyat pozisyonu
   double emaTrend[];
   ArrayResize(emaTrend, 2);
   ArraySetAsSeries(emaTrend, true);
   if(CopyBuffer(g_hEMA_Trend, 0, 0, 2, emaTrend) < 2) return 0;
   
   double price = iClose(_Symbol, SignalTimeframe, 0);
   
   //====================================================================
   // [WEB] Trend Direction: Price > 50 EMA = UPTREND, else DOWNTREND
   //====================================================================
   int trendDirection = (price > emaTrend[0]) ? 1 : (price < emaTrend[0]) ? -1 : 0;
   
   if(trendDirection == 0)
   {
      g_rejectReason = "TREND BELİRSİZ";
      return 0;
   }
   
   // 2. HIZLI RSI (3-period) - Pullback tespiti
   double rsi[];
   ArrayResize(rsi, 3);
   ArraySetAsSeries(rsi, true);
   if(CopyBuffer(g_hRSI_Fast, 0, 0, 3, rsi) < 3) return 0;
   
   //====================================================================
   // [WEB] RSI Pullback: 
   // BUY: RSI şımdi veya önceki barda < 20 OLUŞTU ve yükseliyor
   // SELL: RSI şımdi veya önceki barda > 80 OLUŞTU ve düşüyor
   // v5.1: Daha sıkı koşul - RSI mutlaka aşırı bölgede olmalı
   //====================================================================
   bool rsiBuyPullback = (rsi[1] <= RSI_Oversold && rsi[0] > rsi[1]);
   bool rsiSellPullback = (rsi[1] >= RSI_Overbought && rsi[0] < rsi[1]);
   
   // 3. HIZLI ADX (5-period) - Trend gücü
   double adx[];
   ArrayResize(adx, 1);
   ArraySetAsSeries(adx, true);
   if(CopyBuffer(g_hADX_Fast, 0, 0, 1, adx) < 1) return 0;
   
   //====================================================================
   // [WEB] ADX Filter: ADX > 30 = Strong Trend
   //====================================================================
   if(adx[0] < ADX_MinStrength)
   {
      g_rejectReason = "ADX ZAYIF: " + DoubleToString(adx[0], 0);
      return 0;
   }
   
   // 4. EMA CROSS ONAY (Opsiyonel)
   bool emaCrossConfirm = true;
   if(UseEMACross)
   {
      double emaFast[], emaSlow[];
      ArrayResize(emaFast, 2);
      ArrayResize(emaSlow, 2);
      ArraySetAsSeries(emaFast, true);
      ArraySetAsSeries(emaSlow, true);
      
      if(CopyBuffer(g_hEMA_Fast, 0, 0, 2, emaFast) >= 2 &&
         CopyBuffer(g_hEMA_Slow, 0, 0, 2, emaSlow) >= 2)
      {
         // BUY: Fast > Slow, SELL: Fast < Slow
         if(trendDirection == 1 && emaFast[0] <= emaSlow[0])
         {
            emaCrossConfirm = false;
            g_rejectReason = "EMA UYUMSUZ (BUY)";
         }
         if(trendDirection == -1 && emaFast[0] >= emaSlow[0])
         {
            emaCrossConfirm = false;
            g_rejectReason = "EMA UYUMSUZ (SELL)";
         }
      }
   }
   
   if(!emaCrossConfirm) return 0;
   
   //====================================================================
   // [WEB] SECRET MINDSET SİNYAL KOŞULLARI:
   // BUY = Price > 50 EMA + RSI Pullback from <20 + ADX > 30
   // SELL = Price < 50 EMA + RSI Pullback from >80 + ADX > 30
   //====================================================================
   if(trendDirection == 1 && rsiBuyPullback)
   {
      Print("════════════════════════════════════════════════════════════════");
      Print("🔬 v5 SECRET MINDSET BUY:");
      Print("📈 Trend: UP (Price > ", TrendEMA_Period, " EMA)");
      Print("🔥 RSI Pullback: ", DoubleToString(rsi[1], 1), " → ", DoubleToString(rsi[0], 1));
      Print("⚡ ADX Strength: ", DoubleToString(adx[0], 1));
      Print("════════════════════════════════════════════════════════════════");
      return 1;
   }
   
   if(trendDirection == -1 && rsiSellPullback)
   {
      Print("════════════════════════════════════════════════════════════════");
      Print("🔬 v5 SECRET MINDSET SELL:");
      Print("📉 Trend: DOWN (Price < ", TrendEMA_Period, " EMA)");
      Print("🔥 RSI Pullback: ", DoubleToString(rsi[1], 1), " → ", DoubleToString(rsi[0], 1));
      Print("⚡ ADX Strength: ", DoubleToString(adx[0], 1));
      Print("════════════════════════════════════════════════════════════════");
      return -1;
   }
   
   g_rejectReason = "RSI PULLBACK YOK";
   return 0;
}

//====================================================================
// v5: KELLY CRITERION LOT HESAPLAMA
//====================================================================
double CalculateKellyLot()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   // Kelly istatistiklerini güncelle
   CalculateKellyFraction();
   
   double riskPercent;
   
   if(UseKellyCriterion && g_totalTrades >= 20)
   {
      //====================================================================
      // [WEB] KELLY CRITERION FORMÜLÜ:
      // f% = WinRate - (1 - WinRate) / PayoffRatio
      // f% = S - (1-S) / R
      // Güvenli Kelly: f / KellyDivisor (genellikle f/4 veya f/5)
      //====================================================================
      double safeKelly = g_kellyFraction / KellyDivisor;
      
      // Sınırla
      safeKelly = MathMax(0.005, MathMin(safeKelly, MaxRiskPercent / 100.0));
      riskPercent = safeKelly * 100.0;
      
      Print("📊 Kelly: f=", DoubleToString(g_kellyFraction * 100, 1), 
            "% → Safe=", DoubleToString(riskPercent, 2), "%");
   }
   else
   {
      // Yetersiz veri - sabit risk kullan
      riskPercent = FixedRiskPercent;
   }
   
   // Risk bazlı lot hesapla
   double riskAmount = balance * (riskPercent / 100.0);
   
   double slPips = SL_Pips;
   if(UseATRStops && g_lastATR > 0)
   {
      slPips = PointsToPips(g_lastATR * ATR_SL_Multiplier);
      slPips = MathMax(MinSL_Pips, MathMin(slPips, MaxSL_Pips));
   }
   
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tickValue <= 0) tickValue = 10.0;
   
   double pipValue = tickValue * 10;
   double lot = riskAmount / (slPips * pipValue);
   
   // Normalize
   lot = NormalizeLot(lot);
   
   g_currentLot = lot;
   return lot;
}

//====================================================================
// KELLY İSTATİSTİKLERİNİ HESAPLA
//====================================================================
void CalculateKellyFraction()
{
   if(g_totalTrades < 5)
   {
      // Yeterli veri yok - varsayılan değerler
      g_dynamicWinRate = AssumedWinRate;
      g_dynamicPayoffRatio = AssumedPayoffRatio;
   }
   else
   {
      // Dinamik hesaplama
      g_dynamicWinRate = (double)g_winTrades / g_totalTrades;
      
      if(g_winTrades > 0 && g_lossTrades > 0)
      {
         g_avgWin = g_grossProfit / g_winTrades;
         g_avgLoss = MathAbs(g_grossLoss) / g_lossTrades;
         g_dynamicPayoffRatio = (g_avgLoss > 0) ? g_avgWin / g_avgLoss : AssumedPayoffRatio;
      }
      else
      {
         g_dynamicPayoffRatio = AssumedPayoffRatio;
      }
   }
   
   //====================================================================
   // f% = WinRate - (1 - WinRate) / PayoffRatio
   //====================================================================
   g_kellyFraction = g_dynamicWinRate - (1.0 - g_dynamicWinRate) / g_dynamicPayoffRatio;
   
   // Negatif olmamalı
   g_kellyFraction = MathMax(0, g_kellyFraction);
}

//====================================================================
// İŞLEM AÇ
//====================================================================
void OpenTrade(ENUM_ORDER_TYPE orderType)
{
   double lot = CalculateKellyLot();
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int direction = (orderType == ORDER_TYPE_BUY) ? 1 : -1;
   
   double sl, tp;
   GetOptimizedSLTP(direction, sl, tp);
   
   double price = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   bool success = false;
   ResetLastError();
   
   if(orderType == ORDER_TYPE_BUY)
      success = m_trade.Buy(lot, _Symbol, 0, sl, tp, TradeComment);
   else
      success = m_trade.Sell(lot, _Symbol, 0, sl, tp, TradeComment);
   
   if(success && m_trade.ResultRetcode() == TRADE_RETCODE_DONE)
   {
      g_totalTrades++;
      g_lastTradeTime = TimeCurrent();
      g_barsSinceTrade = 0;
      
      double slPips = PointsToPips(MathAbs(price - sl));
      double tpPips = PointsToPips(MathAbs(tp - price));
      double rr = tpPips / slPips;
      
      Print("════════════════════════════════════════════════════════════════");
      Print("🔬 v5: ", (orderType == ORDER_TYPE_BUY ? "BUY" : "SELL"), " AÇILDI!");
      Print("📦 Lot: ", DoubleToString(lot, 2), " (Kelly: ", DoubleToString(g_kellyFraction * 100, 1), "%)");
      Print("💰 Entry: ", DoubleToString(price, digits));
      Print("🛑 SL: ", DoubleToString(sl, digits), " (", DoubleToString(slPips, 1), " pips)");
      Print("🎯 TP: ", DoubleToString(tp, digits), " (", DoubleToString(tpPips, 1), " pips)");
      Print("⚖️ R:R = 1:", DoubleToString(rr, 2));
      Print("════════════════════════════════════════════════════════════════");
   }
}

//====================================================================
// v5: OPTİMİZE SL/TP (Min R:R garantili)
//====================================================================
void GetOptimizedSLTP(int direction, double &sl, double &tp)
{
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double price = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   double slDist;
   
   if(UseATRStops && g_lastATR > 0)
   {
      slDist = g_lastATR * ATR_SL_Multiplier;
      double minSLDist = PipsToPoints(MinSL_Pips);
      double maxSLDist = PipsToPoints(MaxSL_Pips);
      slDist = MathMax(minSLDist, MathMin(slDist, maxSLDist));
   }
   else
   {
      slDist = PipsToPoints(SL_Pips);
   }
   
   //====================================================================
   // [WEB] Min R:R garantisi: TP = SL * TargetRiskReward
   //====================================================================
   double tpDist = slDist * TargetRiskReward;
   
   if(direction == 1)
   {
      sl = NormalizeDouble(price - slDist, digits);
      tp = NormalizeDouble(price + tpDist, digits);
   }
   else
   {
      sl = NormalizeDouble(price + slDist, digits);
      tp = NormalizeDouble(price - tpDist, digits);
   }
}

//====================================================================
// YARDIMCI FONKSİYONLAR
//====================================================================
double NormalizeLot(double lot)
{
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   if(minLot <= 0) minLot = 0.01;
   if(stepLot <= 0) stepLot = 0.01;
   
   lot = MathFloor(lot / stepLot) * stepLot;
   lot = MathMax(minLot, MathMin(lot, MathMin(maxLot, MaxLotSize)));
   
   // v5.1: MARJİN KONTROLÜ - ÇOK ÖNEMLİ!
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   double marginRequired = 0;
   double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, marginRequired))
   {
      // Serbest marjinin %50'sinden fazlasını kullanma
      while(marginRequired > freeMargin * 0.5 && lot > minLot)
      {
         lot = MathFloor((lot * 0.5) / stepLot) * stepLot;
         lot = MathMax(lot, minLot);
         
         if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, marginRequired))
            break;
      }
   }
   else
   {
      // Marjin hesaplanamadıysa minimum lot kullan
      lot = minLot;
   }
   
   return lot;
}

void UpdateATR()
{
   double atr[];
   ArrayResize(atr, 1);
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(g_hATR, 0, 0, 1, atr) >= 1)
   {
      g_lastATR = atr[0];
   }
}

bool IsSafeToTrade()
{
   // Spread kontrolü
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   if(spread / 10.0 > MaxSpreadPips)
   {
      g_currentState = "⚠️ YÜKSEK SPREAD";
      return false;
   }
   
   // Seans filtresi
   if(UseSessionFilter)
   {
      MqlDateTime dt;
      TimeCurrent(dt);
      if(dt.hour < LondonStartHour || dt.hour >= NYEndHour)
      {
         g_currentState = "⏰ SEANS DIŞI";
         return false;
      }
   }
   
   return true;
}

bool CheckDrawdown()
{
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   if(equity > g_equityHigh) g_equityHigh = equity;
   
   double dd = g_equityHigh > 0 ? (g_equityHigh - equity) / g_equityHigh * 100.0 : 0;
   if(dd > g_maxDrawdownReached) g_maxDrawdownReached = dd;
   
   if(dd >= MaxDrawdownPercent)
   {
      if(CloseAllOnDrawdown && !g_isDrawdownPaused)
      {
         CloseAllPositions();
         g_isDrawdownPaused = true;
      }
      return true;
   }
   return false;
}

bool CheckCooldown()
{
   if(g_barsSinceTrade < CooldownBars) return false;
   if(g_lastTradeTime > 0 && (TimeCurrent() - g_lastTradeTime) < CooldownSeconds) return false;
   return true;
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

void CloseAllPositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      m_trade.PositionClose(ticket);
   }
}

//====================================================================
// POZİSYON YÖNETİMİ
//====================================================================
void ManagePositions()
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);
      long posType = PositionGetInteger(POSITION_TYPE);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      double profit = (posType == POSITION_TYPE_BUY) ? (currentPrice - openPrice) : (openPrice - currentPrice);
      
      // BREAKEVEN
      if(UseBreakeven)
      {
         double beStart = PipsToPoints(BreakevenStart);
         double beProfit = PipsToPoints(BreakevenProfit);
         
         if(profit >= beStart)
         {
            double newSL = (posType == POSITION_TYPE_BUY) ? 
               NormalizeDouble(openPrice + beProfit, digits) :
               NormalizeDouble(openPrice - beProfit, digits);
            
            bool shouldModify = (posType == POSITION_TYPE_BUY) ? (newSL > currentSL) : (newSL < currentSL || currentSL == 0);
            
            if(shouldModify)
            {
               m_trade.PositionModify(ticket, newSL, currentTP);
            }
         }
      }
      
      // TRAILING
      if(UseTrailingStop)
      {
         double trailStart = PipsToPoints(TrailingStart);
         double trailStep = PipsToPoints(TrailingStep);
         
         if(profit >= trailStart)
         {
            double newSL;
            if(posType == POSITION_TYPE_BUY)
            {
               newSL = NormalizeDouble(currentPrice - trailStep, digits);
               if(newSL > currentSL)
                  m_trade.PositionModify(ticket, newSL, currentTP);
            }
            else
            {
               newSL = NormalizeDouble(currentPrice + trailStep, digits);
               if(newSL < currentSL || currentSL == 0)
                  m_trade.PositionModify(ticket, newSL, currentTP);
            }
         }
      }
   }
}

//====================================================================
// İŞLEM SONUÇLARI
//====================================================================
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      if(trans.deal_type == DEAL_TYPE_BUY || trans.deal_type == DEAL_TYPE_SELL) return;
      
      ulong dealTicket = trans.deal;
      if(dealTicket > 0 && HistoryDealSelect(dealTicket))
      {
         double profit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
         ulong magic = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
         
         if(magic == MagicNumber)
         {
            g_totalProfit += profit;
            
            if(profit > 0)
            {
               g_winTrades++;
               g_consecutiveWins++;
               g_consecutiveLosses = 0;
               g_grossProfit += profit;
               
               Print("════════════════════════════════════════════════════════════════");
               Print("🎉 WIN! +$", DoubleToString(profit, 2));
               Print("📊 WR: ", DoubleToString(g_dynamicWinRate * 100, 1), "% | Kelly: ", 
                     DoubleToString(g_kellyFraction * 100, 1), "%");
               Print("════════════════════════════════════════════════════════════════");
            }
            else if(profit < 0)
            {
               g_lossTrades++;
               g_consecutiveLosses++;
               g_consecutiveWins = 0;
               g_grossLoss += profit;
               
               Print("════════════════════════════════════════════════════════════════");
               Print("💔 LOSS: $", DoubleToString(profit, 2));
               Print("📊 WR: ", DoubleToString(g_dynamicWinRate * 100, 1), "%");
               Print("════════════════════════════════════════════════════════════════");
            }
            
            // Kelly güncelle
            CalculateKellyFraction();
         }
      }
   }
}

//====================================================================
// DASHBOARD
//====================================================================
void UpdateDashboard()
{
   if(!MQLInfoInteger(MQL_VISUAL_MODE) && !MQLInfoInteger(MQL_TESTER)) return;
   
   int x = 10, y = 25, h = 16;
   color gold = clrGold, white = clrWhite, gray = clrDimGray;
   
   CreateLabel("MILYONER_T", "📊 MİLYONER v5.0 - ARAŞTIRMA BAZLI", x, y, gold, 10); y += h + 3;
   CreateLabel("MILYONER_L1", "════════════════════════════════", x, y, gray, 7); y += h;
   
   CreateLabel("MILYONER_S", "📊 " + g_currentState, x, y, clrLime, 9); y += h;
   
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   CreateLabel("MILYONER_B", "💰 $" + DoubleToString(bal, 2), x, y, white, 8); y += h;
   
   double dd = g_equityHigh > 0 ? (g_equityHigh - AccountInfoDouble(ACCOUNT_EQUITY)) / g_equityHigh * 100.0 : 0;
   CreateLabel("MILYONER_DD", "📉 DD: " + DoubleToString(dd, 1) + "% / " + DoubleToString(MaxDrawdownPercent, 0) + "%", x, y, dd < 10 ? clrLime : clrRed, 8); y += h;
   
   double wr = g_totalTrades > 0 ? (double)g_winTrades / g_totalTrades * 100.0 : 0;
   CreateLabel("MILYONER_WR", "📈 WR: " + DoubleToString(wr, 1) + "% (" + IntegerToString(g_winTrades) + "/" + IntegerToString(g_totalTrades) + ")", x, y, wr >= 50 ? clrLime : clrRed, 8); y += h;
   
   double pf = g_grossLoss != 0 ? g_grossProfit / MathAbs(g_grossLoss) : 0;
   CreateLabel("MILYONER_PF", "⚖️ PF: " + DoubleToString(pf, 2), x, y, pf >= 1.0 ? clrLime : clrRed, 8); y += h;
   
   CreateLabel("MILYONER_Net", "💵 Net: $" + DoubleToString(g_totalProfit, 2), x, y, g_totalProfit >= 0 ? clrLime : clrRed, 9); y += h;
   
   CreateLabel("MILYONER_L2", "════════════════════════════════", x, y, gray, 7); y += h;
   
   CreateLabel("MILYONER_Kelly", "📊 Kelly f: " + DoubleToString(g_kellyFraction * 100, 1) + "%", x, y, clrYellow, 8); y += h;
   CreateLabel("MILYONER_RR", "⚖️ Payoff: " + DoubleToString(g_dynamicPayoffRatio, 2), x, y, white, 8); y += h;
   CreateLabel("MILYONER_Lot", "📦 Lot: " + DoubleToString(g_currentLot, 2), x, y, gold, 8);
}

void CreateLabel(string name, string text, int x, int y, color clr, int size)
{
   if(ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   }
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, size);
   ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
}
//+------------------------------------------------------------------+
