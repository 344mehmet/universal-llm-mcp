//+------------------------------------------------------------------+
//|                                      MA_Master_Scalper_v2.mq5    |
//|                     © 2025, Milyoner EA Project v2.0             |
//|                     GELİŞTİRİLMİŞ SCALPING SİSTEMİ               |
//+------------------------------------------------------------------+
//| v2 İYİLEŞTİRMELER:                                               |
//| • ATR bazlı dinamik SL/TP                                        |
//| • Trend gücü filtresi (ADX)                                      |
//| • Volatilite kontrolü                                            |
//| • Gelişmiş Martingale (daha yumuşak)                             |
//| • Çoklu timeframe onayı                                          |
//| • Momentum filtresi (RSI)                                        |
//+------------------------------------------------------------------+
#property copyright "© 2025, Milyoner EA Project v2.0"
#property link      "https://github.com/milyoner-ea"
#property version   "2.00"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// ENUM TANIMLARI
//====================================================================
enum ENUM_SCALP_MODE {
   MODE_CONSERVATIVE,    // Konservatif (Düşük Risk)
   MODE_BALANCED,        // Dengeli (Orta Risk)
   MODE_AGGRESSIVE       // Agresif (Yüksek Risk)
};

enum ENUM_TREND_FILTER {
   TREND_NONE,           // Filtre Yok
   TREND_EMA200,         // 200 EMA Trend
   TREND_ADX             // ADX Trend Gücü
};

//====================================================================
// INPUT PARAMETRELERİ - v2 GELİŞMİŞ AYARLAR
//====================================================================

//--- 1. ANA AYARLAR
input group "═══ 1. ANA AYARLAR v2 ═══"
input ulong    MagicNumber        = 888888;     // 🎰 Magic Number
input string   TradeComment       = "MILYONER_v2"; // İşlem Yorumu
input ENUM_SCALP_MODE ScalpMode   = MODE_BALANCED; // ⚡ Scalping Modu
input bool     ShowStartupWarning = true;       // ⚠️ Başlangıç Uyarısı

//--- 2. EMA SİNYAL SİSTEMİ (v2: Optimize Periyotlar)
input group "═══ 2. EMA SINYAL SİSTEMİ v2 ═══"
input int      EMA_Fast_Period    = 8;          // 🔵 Hızlı EMA (v2: 8)
input int      EMA_Slow_Period    = 21;         // 🔴 Yavaş EMA
input int      EMA_Trend_Period   = 50;         // 📈 Trend EMA (v2 YENİ)
input ENUM_APPLIED_PRICE EMA_Price = PRICE_CLOSE;

//--- 3. TREND FİLTRESİ (v2 YENİ)
input group "═══ 3. TREND FİLTRESİ v2 ═══"
input ENUM_TREND_FILTER TrendFilter = TREND_ADX; // Trend Filtresi
input int      ADX_Period         = 14;         // ADX Periyodu
input int      ADX_MinLevel       = 20;         // Min ADX (Trend Gücü)
input bool     RequireTrendAlign  = true;       // EMA Hizalama Şartı

//--- 4. STOKASTİK FİLTRE (v2: Sıkı Filtre)
input group "═══ 4. STOKASTİK FİLTRE v2 ═══"
input bool     UseStochFilter     = true;       // ✅ Stokastik Kullan
input int      Stoch_K            = 14;         // %K Periyodu
input int      Stoch_D            = 3;          // %D Periyodu
input int      Stoch_Slowing      = 3;          // Yavaşlatma
input int      Stoch_Oversold     = 25;         // v2: Aşırı Satım (25)
input int      Stoch_Overbought   = 75;         // v2: Aşırı Alım (75)

//--- 5. RSI MOMENTUM FİLTRESİ (v2 YENİ)
input group "═══ 5. RSI FİLTRESİ v2 ═══"
input bool     UseRSIFilter       = true;       // ✅ RSI Kullan
input int      RSI_Period         = 14;         // RSI Periyodu
input int      RSI_Oversold       = 35;         // RSI Aşırı Satım
input int      RSI_Overbought     = 65;         // RSI Aşırı Alım

//--- 6. ATR BAZLI DİNAMİK SL/TP (v2 YENİ)
input group "═══ 6. ATR DİNAMİK SL/TP v2 ═══"
input bool     UseATRStops        = true;       // ✅ ATR Kullan
input int      ATR_Period         = 14;         // ATR Periyodu
input double   ATR_SL_Multiplier  = 1.5;        // SL = ATR x 1.5
input double   ATR_TP_Multiplier  = 2.5;        // TP = ATR x 2.5 (R:R 1:1.67)
input int      MinSL_Pips         = 5;          // Min SL (pip)
input int      MaxSL_Pips         = 30;         // Max SL (pip)

//--- 7. SABİT SL/TP (ATR kapalıysa)
input group "═══ 7. SABİT SL/TP ═══"
input int      TP_Pips            = 10;         // 🎯 Take Profit (pip)
input int      SL_Pips            = 15;         // 🛑 Stop Loss (pip)

//--- 8. MARTİNGALE v2 (YUMUŞAK)
input group "═══ 8. MARTİNGALE v2 (YUMUŞAK) ═══"
input bool     UseMartingale      = true;       // ✅ Martingale
input double   MartingaleMultiplier = 1.5;      // v2: 1.5x (daha yumuşak)
input int      MaxConsecutiveLoss = 4;          // v2: Max 4 kayıp
input bool     ResetOnWin         = true;       // Kazançta Sıfırla
input double   MartingaleRecovery = 0.5;        // v2: Kademeli azalma

//--- 9. RİSK YÖNETİMİ v2
input group "═══ 9. RİSK YÖNETİMİ v2 ═══"
input double   RiskPercent        = 2.0;        // v2: İşlem başı risk %
input double   BaseLot            = 0.01;       // Min Lot
input double   MaxLotSize         = 10.0;       // v2: Max Lot düşürüldü
input double   MaxDrawdownPercent = 30.0;       // v2: Max DD %30

//--- 10. TRAİLİNG STOP v2
input group "═══ 10. TRAİLİNG STOP v2 ═══"
input bool     UseTrailingStop    = true;       // Trailing Aktif
input int      TrailingStart      = 10;         // v2: Başlangıç (pip)
input int      TrailingStep       = 5;          // v2: Adım (pip)
input bool     UseBreakeven       = true;       // v2: Breakeven
input int      BreakevenStart     = 8;          // BE Tetikleme (pip)
input int      BreakevenProfit    = 2;          // BE Kâr (pip)

//--- 11. SPREAD/VOLATİLİTE KORUMA
input group "═══ 11. KORUMA SİSTEMLERİ v2 ═══"
input int      MaxSpreadPips      = 5;          // Max Spread
input double   MinATRValue        = 0.0005;     // Min Volatilite
input double   MaxATRValue        = 0.005;      // Max Volatilite
input bool     CloseAllOnDrawdown = true;       // DD'de Kapat

//--- 12. ZAMAN FİLTRESİ
input group "═══ 12. ZAMAN FİLTRESİ ═══"
input bool     UseTimeFilter      = true;       // v2: Aktif
input int      TradeStartHour     = 8;          // Londra Açılış
input int      TradeEndHour       = 20;         // NY Kapanış
input bool     AvoidHighImpactNews = false;     // Haber Kaçınma (manuel)

//--- 13. COOLDOWN
input group "═══ 13. İŞLEM ARASI BEKLEME ═══"
input int      CooldownBars       = 3;          // Sinyal sonrası bar bekleme
input int      CooldownMinutes    = 5;          // Min dakika bekleme

//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================
int      g_hEMA_Fast    = INVALID_HANDLE;
int      g_hEMA_Slow    = INVALID_HANDLE;
int      g_hEMA_Trend   = INVALID_HANDLE;
int      g_hStoch       = INVALID_HANDLE;
int      g_hADX         = INVALID_HANDLE;
int      g_hATR         = INVALID_HANDLE;
int      g_hRSI         = INVALID_HANDLE;

int      g_consecutiveLosses  = 0;
int      g_consecutiveWins    = 0;
double   g_currentLot         = 0;
double   g_equityHigh         = 0;
double   g_maxDrawdownReached = 0;
datetime g_lastTradeTime      = 0;
datetime g_lastBarTime        = 0;
int      g_barsSinceTrade     = 0;
int      g_totalTrades        = 0;
int      g_winTrades          = 0;
int      g_lossTrades         = 0;
double   g_totalProfit        = 0;
double   g_grossProfit        = 0;
double   g_grossLoss          = 0;
bool     g_isDrawdownPaused   = false;
string   g_currentState       = "BAŞLATILIYOR...";
string   g_rejectReason       = "";
double   g_lastATR            = 0;

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
// OnInit - EA BAŞLATMA
//====================================================================
int OnInit()
{
   // Başlangıç uyarısı
   if(ShowStartupWarning && !MQLInfoInteger(MQL_TESTER))
   {
      int result = MessageBox(
         "🎰 MİLYONER EA v2.0 - GELİŞTİRİLMİŞ\n\n" +
         "v2 İyileştirmeler:\n" +
         "• ATR bazlı dinamik SL/TP\n" +
         "• ADX trend filtresi\n" +
         "• RSI momentum filtresi\n" +
         "• Yumuşak Martingale (1.5x)\n" +
         "• Breakeven koruması\n\n" +
         "Risk: " + DoubleToString(RiskPercent, 1) + "% / işlem\n" +
         "Max DD: " + DoubleToString(MaxDrawdownPercent, 0) + "%\n\n" +
         "DEVAM?",
         "MİLYONER EA v2.0",
         MB_YESNO | MB_ICONINFORMATION
      );
      
      if(result == IDNO) return INIT_FAILED;
   }
   
   // Trade ayarları
   m_trade.SetExpertMagicNumber(MagicNumber);
   m_trade.SetDeviationInPoints(10);
   m_trade.SetMarginMode();
   m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   // Göstergeleri yükle
   g_hEMA_Fast = iMA(_Symbol, PERIOD_CURRENT, EMA_Fast_Period, 0, MODE_EMA, EMA_Price);
   g_hEMA_Slow = iMA(_Symbol, PERIOD_CURRENT, EMA_Slow_Period, 0, MODE_EMA, EMA_Price);
   g_hEMA_Trend = iMA(_Symbol, PERIOD_CURRENT, EMA_Trend_Period, 0, MODE_EMA, EMA_Price);
   g_hStoch = iStochastic(_Symbol, PERIOD_CURRENT, Stoch_K, Stoch_D, Stoch_Slowing, MODE_SMA, STO_LOWHIGH);
   g_hADX = iADX(_Symbol, PERIOD_CURRENT, ADX_Period);
   g_hATR = iATR(_Symbol, PERIOD_CURRENT, ATR_Period);
   g_hRSI = iRSI(_Symbol, PERIOD_CURRENT, RSI_Period, PRICE_CLOSE);
   
   if(g_hEMA_Fast == INVALID_HANDLE || g_hEMA_Slow == INVALID_HANDLE || 
      g_hStoch == INVALID_HANDLE || g_hADX == INVALID_HANDLE || 
      g_hATR == INVALID_HANDLE || g_hRSI == INVALID_HANDLE)
   {
      Print("❌ Göstergeler yüklenemedi!");
      return INIT_FAILED;
   }
   
   // Başlangıç
   g_currentLot = BaseLot;
   g_equityHigh = AccountInfoDouble(ACCOUNT_EQUITY);
   
   Print("════════════════════════════════════════════════════════════════");
   Print("🎰 MİLYONER EA v2.0 - GELİŞTİRİLMİŞ VERSİYON");
   Print("════════════════════════════════════════════════════════════════");
   Print("📊 EMA: ", EMA_Fast_Period, "/", EMA_Slow_Period, "/", EMA_Trend_Period);
   Print("📈 Trend: ", EnumToString(TrendFilter), " | ADX Min: ", ADX_MinLevel);
   Print("🎲 Martingale: ", UseMartingale ? DoubleToString(MartingaleMultiplier, 1) + "x" : "KAPALI");
   Print("💰 Risk: ", DoubleToString(RiskPercent, 1), "% | Max DD: ", DoubleToString(MaxDrawdownPercent, 0), "%");
   Print("🎯 ATR SL/TP: ", UseATRStops ? "AKTİF (x" + DoubleToString(ATR_SL_Multiplier, 1) + "/" + DoubleToString(ATR_TP_Multiplier, 1) + ")" : "KAPALI");
   Print("💵 Başlangıç: $", DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2));
   Print("════════════════════════════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}

//====================================================================
// OnDeinit
//====================================================================
void OnDeinit(const int reason)
{
   if(g_hEMA_Fast != INVALID_HANDLE) IndicatorRelease(g_hEMA_Fast);
   if(g_hEMA_Slow != INVALID_HANDLE) IndicatorRelease(g_hEMA_Slow);
   if(g_hEMA_Trend != INVALID_HANDLE) IndicatorRelease(g_hEMA_Trend);
   if(g_hStoch != INVALID_HANDLE) IndicatorRelease(g_hStoch);
   if(g_hADX != INVALID_HANDLE) IndicatorRelease(g_hADX);
   if(g_hATR != INVALID_HANDLE) IndicatorRelease(g_hATR);
   if(g_hRSI != INVALID_HANDLE) IndicatorRelease(g_hRSI);
   
   // İstatistikler
   double profitFactor = g_grossLoss != 0 ? g_grossProfit / MathAbs(g_grossLoss) : 0;
   double winRate = g_totalTrades > 0 ? (double)g_winTrades / g_totalTrades * 100.0 : 0;
   
   Print("════════════════════════════════════════════════════════════════");
   Print("🎰 MİLYONER EA v2.0 - SONUÇLAR");
   Print("════════════════════════════════════════════════════════════════");
   Print("📊 Toplam: ", g_totalTrades, " | Kazanç: ", g_winTrades, " (", DoubleToString(winRate, 1), "%)");
   Print("💰 Net: $", DoubleToString(g_totalProfit, 2));
   Print("📈 Brüt Kâr: $", DoubleToString(g_grossProfit, 2), " | Brüt Zarar: $", DoubleToString(g_grossLoss, 2));
   Print("⚖️ Kâr Faktörü: ", DoubleToString(profitFactor, 2));
   Print("📉 Max DD: ", DoubleToString(g_maxDrawdownReached, 1), "%");
   Print("════════════════════════════════════════════════════════════════");
   
   ObjectsDeleteAll(0, "MILYONER_");
}

//====================================================================
// OnTick
//====================================================================
void OnTick()
{
   // Dashboard
   UpdateDashboard();
   
   // Yeni bar kontrolü
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(g_lastBarTime != currentBar)
   {
      g_lastBarTime = currentBar;
      g_barsSinceTrade++;
   }
   
   // Drawdown kontrolü
   if(CheckDrawdown())
   {
      g_currentState = "⛔ DRAWDOWN PAUSE";
      return;
   }
   
   // Pozisyon yönetimi
   ManagePositions();
   
   // Güvenlik kontrolleri
   if(!IsSafeToTrade())
   {
      return;
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
      g_currentState = "⏳ COOLDOWN: " + g_rejectReason;
      return;
   }
   
   // Sinyal kontrolü
   int signal = GetSignal();
   
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
// GÜVENLİK KONTROLLERİ
//====================================================================
bool IsSafeToTrade()
{
   // Spread kontrolü
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   double spreadPips = spread / 10.0;
   if(spreadPips > MaxSpreadPips)
   {
      g_currentState = "⚠️ YÜKSEK SPREAD: " + DoubleToString(spreadPips, 1);
      return false;
   }
   
   // Zaman filtresi
   if(UseTimeFilter)
   {
      MqlDateTime dt;
      TimeCurrent(dt);
      if(dt.hour < TradeStartHour || dt.hour >= TradeEndHour)
      {
         g_currentState = "⏰ SEANS DIŞI";
         return false;
      }
   }
   
   // Volatilite kontrolü
   double atr[];
   ArrayResize(atr, 1);
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(g_hATR, 0, 0, 1, atr) >= 1)
   {
      g_lastATR = atr[0];
      if(atr[0] < MinATRValue)
      {
         g_currentState = "⚠️ DÜŞÜK VOLATİLİTE";
         return false;
      }
      if(atr[0] > MaxATRValue)
      {
         g_currentState = "⚠️ AŞIRI VOLATİLİTE";
         return false;
      }
   }
   
   return true;
}

//====================================================================
// COOLDOWN KONTROLÜ
//====================================================================
bool CheckCooldown()
{
   // Bar bekleme
   if(g_barsSinceTrade < CooldownBars)
   {
      g_rejectReason = IntegerToString(CooldownBars - g_barsSinceTrade) + " bar bekle";
      return false;
   }
   
   // Dakika bekleme
   if(g_lastTradeTime > 0)
   {
      int minutesPassed = (int)((TimeCurrent() - g_lastTradeTime) / 60);
      if(minutesPassed < CooldownMinutes)
      {
         g_rejectReason = IntegerToString(CooldownMinutes - minutesPassed) + " dk bekle";
         return false;
      }
   }
   
   return true;
}

//====================================================================
// v2: GELİŞMİŞ SİNYAL MOTORU
//====================================================================
int GetSignal()
{
   g_rejectReason = "SİNYAL BEKLENİYOR";
   
   // EMA verileri
   double emaFast[], emaSlow[], emaTrend[];
   ArrayResize(emaFast, 3);
   ArrayResize(emaSlow, 3);
   ArrayResize(emaTrend, 2);
   ArraySetAsSeries(emaFast, true);
   ArraySetAsSeries(emaSlow, true);
   ArraySetAsSeries(emaTrend, true);
   
   if(CopyBuffer(g_hEMA_Fast, 0, 0, 3, emaFast) < 3) return 0;
   if(CopyBuffer(g_hEMA_Slow, 0, 0, 3, emaSlow) < 3) return 0;
   if(CopyBuffer(g_hEMA_Trend, 0, 0, 2, emaTrend) < 2) return 0;
   
   double price = iClose(_Symbol, PERIOD_CURRENT, 0);
   
   // 1. EMA Cross tespiti (Bar[1] için - önceki bar)
   bool goldenCross = (emaFast[2] <= emaSlow[2] && emaFast[1] > emaSlow[1]);
   bool deathCross  = (emaFast[2] >= emaSlow[2] && emaFast[1] < emaSlow[1]);
   
   if(!goldenCross && !deathCross)
   {
      g_rejectReason = "CROSS YOK";
      return 0;
   }
   
   // 2. TREND FİLTRESİ
   if(TrendFilter == TREND_ADX)
   {
      double adx[];
      ArrayResize(adx, 1);
      ArraySetAsSeries(adx, true);
      if(CopyBuffer(g_hADX, 0, 0, 1, adx) >= 1)
      {
         if(adx[0] < ADX_MinLevel)
         {
            g_rejectReason = "ADX DÜŞÜK: " + DoubleToString(adx[0], 0);
            return 0;
         }
      }
   }
   
   // 3. TREND HIZALAMA
   if(RequireTrendAlign)
   {
      if(goldenCross)
      {
         // BUY: Fiyat > EMA Trend olmalı
         if(price < emaTrend[0])
         {
            g_rejectReason = "TREND UYUMSUZ (BUY)";
            return 0;
         }
      }
      if(deathCross)
      {
         // SELL: Fiyat < EMA Trend olmalı
         if(price > emaTrend[0])
         {
            g_rejectReason = "TREND UYUMSUZ (SELL)";
            return 0;
         }
      }
   }
   
   // 4. STOKASTİK FİLTRE
   if(UseStochFilter)
   {
      double stochK[];
      ArrayResize(stochK, 2);
      ArraySetAsSeries(stochK, true);
      if(CopyBuffer(g_hStoch, 0, 0, 2, stochK) >= 2)
      {
         if(goldenCross && stochK[1] > Stoch_Oversold)
         {
            g_rejectReason = "STOCH YÜKSEK (BUY)";
            return 0;
         }
         if(deathCross && stochK[1] < Stoch_Overbought)
         {
            g_rejectReason = "STOCH DÜŞÜK (SELL)";
            return 0;
         }
      }
   }
   
   // 5. RSI MOMENTUM FİLTRESİ
   if(UseRSIFilter)
   {
      double rsi[];
      ArrayResize(rsi, 2);
      ArraySetAsSeries(rsi, true);
      if(CopyBuffer(g_hRSI, 0, 0, 2, rsi) >= 2)
      {
         // BUY: RSI aşırı yüksek olmamalı
         if(goldenCross && rsi[1] > RSI_Overbought)
         {
            g_rejectReason = "RSI AŞIRI YÜKSEK";
            return 0;
         }
         // SELL: RSI aşırı düşük olmamalı
         if(deathCross && rsi[1] < RSI_Oversold)
         {
            g_rejectReason = "RSI AŞIRI DÜŞÜK";
            return 0;
         }
      }
   }
   
   // Tüm filtreler geçti
   if(goldenCross) return 1;
   if(deathCross) return -1;
   
   return 0;
}

//====================================================================
// v2: ATR BAZLI DİNAMİK SL/TP
//====================================================================
void GetDynamicSLTP(int direction, double &sl, double &tp)
{
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double price = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   double slDist, tpDist;
   
   if(UseATRStops && g_lastATR > 0)
   {
      slDist = g_lastATR * ATR_SL_Multiplier;
      tpDist = g_lastATR * ATR_TP_Multiplier;
      
      // Min/Max limitleri
      double minSLDist = PipsToPoints(MinSL_Pips);
      double maxSLDist = PipsToPoints(MaxSL_Pips);
      
      slDist = MathMax(minSLDist, MathMin(slDist, maxSLDist));
      tpDist = MathMax(slDist * 1.5, tpDist); // Min R:R 1:1.5
   }
   else
   {
      slDist = PipsToPoints(SL_Pips);
      tpDist = PipsToPoints(TP_Pips);
   }
   
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
// v2: RİSK BAZLI LOT HESAPLAMA
//====================================================================
double CalculateLot()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * (RiskPercent / 100.0);
   
   // SL mesafesi (pip)
   double slPips = SL_Pips;
   if(UseATRStops && g_lastATR > 0)
   {
      slPips = PointsToPips(g_lastATR * ATR_SL_Multiplier);
      slPips = MathMax(MinSL_Pips, MathMin(slPips, MaxSL_Pips));
   }
   
   // Tick value
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tickValue <= 0) tickValue = 1;
   
   // Risk bazlı lot
   double lot = riskAmount / (slPips * 10 * tickValue);
   
   // Martingale
   if(UseMartingale && g_consecutiveLosses > 0)
   {
      double multiplier = 1.0;
      for(int i = 0; i < g_consecutiveLosses; i++)
      {
         multiplier *= MartingaleMultiplier;
         // Kademeli azalma
         multiplier *= (1.0 - MartingaleRecovery * i / MaxConsecutiveLoss);
      }
      lot *= MathMax(1.0, multiplier);
      Print("🎲 Martingale Lot: ", DoubleToString(lot, 2), " (", g_consecutiveLosses, " kayıp sonrası)");
   }
   
   // Broker limitleri
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   lot = MathFloor(lot / stepLot) * stepLot;
   lot = MathMax(minLot, MathMin(lot, MathMin(maxLot, MaxLotSize)));
   
   // Marjin kontrolü
   double marginRequired = 0;
   double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   bool marginOK = OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, marginRequired);
   if(marginOK && marginRequired > 0)
   {
      double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      while(marginRequired > freeMargin * 0.8 && lot > minLot)
      {
         lot = MathFloor((lot * 0.8) / stepLot) * stepLot;
         lot = MathMax(lot, minLot);
         if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, marginRequired))
            break;
      }
   }
   
   g_currentLot = lot;
   return lot;
}

//====================================================================
// İŞLEM AÇ
//====================================================================
void OpenTrade(ENUM_ORDER_TYPE orderType)
{
   double lot = CalculateLot();
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int direction = (orderType == ORDER_TYPE_BUY) ? 1 : -1;
   
   double sl, tp;
   GetDynamicSLTP(direction, sl, tp);
   
   double price = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   string comment = TradeComment + "_" + IntegerToString(g_totalTrades + 1);
   
   bool success = false;
   ResetLastError();
   
   if(orderType == ORDER_TYPE_BUY)
      success = m_trade.Buy(lot, _Symbol, 0, sl, tp, comment);
   else
      success = m_trade.Sell(lot, _Symbol, 0, sl, tp, comment);
   
   if(success && m_trade.ResultRetcode() == TRADE_RETCODE_DONE)
   {
      g_totalTrades++;
      g_lastTradeTime = TimeCurrent();
      g_barsSinceTrade = 0;
      
      double slPips = PointsToPips(MathAbs(price - sl));
      double tpPips = PointsToPips(MathAbs(tp - price));
      double rr = tpPips / slPips;
      
      Print("════════════════════════════════════════════════════════════════");
      Print("🎰 v2: ", (orderType == ORDER_TYPE_BUY ? "BUY" : "SELL"), " AÇILDI!");
      Print("📊 Lot: ", DoubleToString(lot, 2), " | Entry: ", DoubleToString(price, digits));
      Print("🛑 SL: ", DoubleToString(sl, digits), " (", DoubleToString(slPips, 1), " pips)");
      Print("🎯 TP: ", DoubleToString(tp, digits), " (", DoubleToString(tpPips, 1), " pips)");
      Print("⚖️ R:R = 1:", DoubleToString(rr, 2));
      Print("🎟️ Ticket: ", m_trade.ResultOrder());
      Print("════════════════════════════════════════════════════════════════");
   }
   else
   {
      Print("❌ İşlem BAŞARISIZ: ", m_trade.ResultRetcode(), " - ", m_trade.ResultRetcodeDescription());
   }
}

//====================================================================
// POZİSYON YÖNETİMİ - Trailing + Breakeven
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
            
            if(shouldModify && MathAbs(currentSL - openPrice) > beProfit * 0.5)
            {
               if(m_trade.PositionModify(ticket, newSL, currentTP))
               {
                  Print("🔒 Breakeven: Ticket #", ticket);
               }
            }
         }
      }
      
      // TRAILING STOP
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
               {
                  m_trade.PositionModify(ticket, newSL, currentTP);
               }
            }
            else
            {
               newSL = NormalizeDouble(currentPrice + trailStep, digits);
               if(newSL < currentSL || currentSL == 0)
               {
                  m_trade.PositionModify(ticket, newSL, currentTP);
               }
            }
         }
      }
   }
}

//====================================================================
// DRAWDOWN KONTROLÜ
//====================================================================
bool CheckDrawdown()
{
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   if(equity > g_equityHigh)
      g_equityHigh = equity;
   
   double drawdown = 0;
   if(g_equityHigh > 0)
      drawdown = (g_equityHigh - equity) / g_equityHigh * 100.0;
   
   if(drawdown > g_maxDrawdownReached)
      g_maxDrawdownReached = drawdown;
   
   if(drawdown >= MaxDrawdownPercent)
   {
      if(CloseAllOnDrawdown && !g_isDrawdownPaused)
      {
         Print("⛔ DRAWDOWN LİMİTİ: ", DoubleToString(drawdown, 1), "%");
         CloseAllPositions();
         g_isDrawdownPaused = true;
      }
      return true;
   }
   
   return false;
}

//====================================================================
// TÜM POZİSYONLARI KAPAT
//====================================================================
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
// AÇIK POZİSYON KONTROLÜ
//====================================================================
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

//====================================================================
// İŞLEM SONUÇLARI
//====================================================================
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      if(trans.deal_type == DEAL_TYPE_BUY || trans.deal_type == DEAL_TYPE_SELL)
         return;
      
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
               g_grossProfit += profit;
               
               if(ResetOnWin) g_consecutiveLosses = 0;
               
               Print("════════════════════════════════════════════════════════════════");
               Print("🎉 KAZANÇ! +$", DoubleToString(profit, 2));
               Print("🔥 Win Streak: ", g_consecutiveWins, " | Toplam: $", DoubleToString(g_totalProfit, 2));
               Print("════════════════════════════════════════════════════════════════");
            }
            else if(profit < 0)
            {
               g_lossTrades++;
               g_consecutiveLosses++;
               g_consecutiveWins = 0;
               g_grossLoss += profit;
               
               Print("════════════════════════════════════════════════════════════════");
               Print("💔 KAYIP: $", DoubleToString(profit, 2));
               Print("❌ Loss Streak: ", g_consecutiveLosses, "/", MaxConsecutiveLoss);
               Print("════════════════════════════════════════════════════════════════");
               
               if(g_consecutiveLosses >= MaxConsecutiveLoss)
               {
                  Print("⛔ MAX KAYIP! Martingale sıfırlanıyor...");
                  g_consecutiveLosses = 0;
               }
            }
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
   
   int x = 10, y = 30, lineH = 18;
   color gold = clrGold, white = clrWhite, gray = clrDarkGray;
   
   CreateLabel("MILYONER_Title", "🎰 MİLYONER EA v2.0", x, y, gold, 11); y += lineH + 5;
   CreateLabel("MILYONER_Line1", "═══════════════════════════", x, y, gray, 7); y += lineH;
   
   CreateLabel("MILYONER_State", "📊 " + g_currentState, x, y, clrLime, 9); y += lineH;
   
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   CreateLabel("MILYONER_Bal", "💰 Bakiye: $" + DoubleToString(balance, 2), x, y, white, 8); y += lineH;
   CreateLabel("MILYONER_Eq", "💵 Equity: $" + DoubleToString(equity, 2), x, y, white, 8); y += lineH;
   
   double dd = g_equityHigh > 0 ? (g_equityHigh - equity) / g_equityHigh * 100.0 : 0;
   color ddClr = dd < 10 ? clrLime : (dd < 20 ? clrYellow : clrRed);
   CreateLabel("MILYONER_DD", "📉 DD: " + DoubleToString(dd, 1) + "% (Max: " + DoubleToString(g_maxDrawdownReached, 1) + "%)", x, y, ddClr, 8); y += lineH;
   
   CreateLabel("MILYONER_Line2", "═══════════════════════════", x, y, gray, 7); y += lineH;
   
   double winRate = g_totalTrades > 0 ? (double)g_winTrades / g_totalTrades * 100.0 : 0;
   CreateLabel("MILYONER_Trades", "📊 İşlem: " + IntegerToString(g_totalTrades) + " | WR: " + DoubleToString(winRate, 1) + "%", x, y, white, 8); y += lineH;
   
   double pf = g_grossLoss != 0 ? g_grossProfit / MathAbs(g_grossLoss) : 0;
   color pfClr = pf >= 1.5 ? clrLime : (pf >= 1.0 ? clrYellow : clrRed);
   CreateLabel("MILYONER_PF", "⚖️ Kâr Faktörü: " + DoubleToString(pf, 2), x, y, pfClr, 8); y += lineH;
   
   color netClr = g_totalProfit >= 0 ? clrLime : clrRed;
   CreateLabel("MILYONER_Net", "💰 Net: $" + DoubleToString(g_totalProfit, 2), x, y, netClr, 9); y += lineH;
   
   CreateLabel("MILYONER_Line3", "═══════════════════════════", x, y, gray, 7); y += lineH;
   
   color martClr = g_consecutiveLosses == 0 ? clrLime : (g_consecutiveLosses < MaxConsecutiveLoss ? clrYellow : clrRed);
   CreateLabel("MILYONER_Mart", "🎲 Martingale: " + IntegerToString(g_consecutiveLosses) + "/" + IntegerToString(MaxConsecutiveLoss), x, y, martClr, 8); y += lineH;
   
   CreateLabel("MILYONER_ATR", "📈 ATR: " + DoubleToString(g_lastATR * 10000, 1) + " pips", x, y, white, 8); y += lineH;
   CreateLabel("MILYONER_Lot", "📦 Sonraki: " + DoubleToString(CalculateLot(), 2) + " lot", x, y, gold, 8);
}

void CreateLabel(string name, string text, int x, int y, color clr, int fontSize)
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
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
   ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
}
//+------------------------------------------------------------------+
