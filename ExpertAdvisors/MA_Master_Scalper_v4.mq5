//+------------------------------------------------------------------+
//|                                      MA_Master_Scalper_v4.mq5    |
//|                     © 2025, Milyoner EA Project v4.0             |
//|                     ANTİ-MARTİNGALE + HEDGE SİSTEMİ              |
//+------------------------------------------------------------------+
//| v4 SİSTEM MANTIĞI:                                               |
//| 1. Sinyal takip → 0.01 lot başlangıç işlem                       |
//| 2. KÂR varsa → Lot artır (Anti-Martingale)                       |
//| 3. ZARAR varsa → Hedge (ters pozisyon) ile dengeleme             |
//| 4. Üçlü operatör koşulları ile karar mekanizması                 |
//+------------------------------------------------------------------+
#property copyright "© 2025, Milyoner EA Project v4.0"
#property link      "https://github.com/milyoner-ea"
#property version   "4.00"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// v4: SİSTEM KOŞULLARI (ÜÇLÜ OPERATÖR İLE)
//====================================================================
// KOŞUL 1: Sinyal takip edildi mi?
//          signalOK = (cross detected) ? true : false
//
// KOŞUL 2: İşlem açıldı mı? (0.01 lot)
//          tradeOpened = (position exists) ? true : false
//
// KOŞUL 3: Kâr mı zarar mı?
//          profitState = (currentProfit > 0) ? PROFIT : LOSS
//
// KOŞUL 4: Lot artırım mı hedge mi?
//          action = (profitState == PROFIT) ? LOT_INCREASE : HEDGE_OPEN
//
// KOŞUL 5: Hedge yönü
//          hedgeDir = (currentPos == BUY) ? SELL : BUY
//====================================================================

//====================================================================
// ENUM TANIMLARI
//====================================================================
enum ENUM_PROFIT_STATE {
   STATE_NONE,           // Pozisyon yok
   STATE_PROFIT,         // Kârda
   STATE_LOSS,           // Zararda
   STATE_BREAKEVEN       // Başabaş
};

enum ENUM_ACTION_TYPE {
   ACTION_NONE,          // Aksiyon yok
   ACTION_OPEN_SIGNAL,   // Sinyal ile aç
   ACTION_LOT_INCREASE,  // Lot artır (kârda)
   ACTION_HEDGE          // Hedge aç (zararda)
};

//====================================================================
// INPUT PARAMETRELERİ - v4 AKILLI SİSTEM
//====================================================================

//--- 1. ANA AYARLAR
input group "═══ 1. ANA AYARLAR v4 ═══"
input ulong    MagicNumber        = 444444;        // 🎰 Magic Number
input string   TradeComment       = "MILYONER_v4"; // İşlem Yorumu
input bool     ShowDashboard      = true;          // Dashboard Göster

//--- 2. SİNYAL TAKİP SİSTEMİ
input group "═══ 2. SİNYAL TAKİP ═══"
input ENUM_TIMEFRAMES SignalTimeframe = PERIOD_M1; // Sinyal Timeframe
input int      EMA_Fast_Period    = 8;             // Hızlı EMA
input int      EMA_Slow_Period    = 21;            // Yavaş EMA
input int      EMA_Trend_Period   = 50;            // Trend EMA
input bool     RequireTrendAlign  = true;          // Trend Hizalama

//--- 3. BAŞLANGIÇ LOT (SABİT 0.01)
input group "═══ 3. BAŞLANGIÇ LOT ═══"
input double   StartingLot        = 0.01;          // 📦 Başlangıç Lot (sabit)
input double   MaxLotSize         = 5.0;           // Max Lot Limiti

//--- 4. KÂR YÖNLÜ LOT ARTIRIM (ANTİ-MARTİNGALE)
input group "═══ 4. KÂR YÖNLÜ LOT ARTIRIM ═══"
input bool     UseProfitLotIncrease = true;        // ✅ Kârda Lot Artır
input double   LotIncreaseMultiplier = 1.5;        // 📈 Kâr Çarpanı (1.5x)
input int      MinProfitPips      = 5;             // Min Kâr (pip) - tetikleme
input int      MaxConsecutiveWins = 5;             // Max Ardışık Kazanç

//--- 5. ZARAR HEDGE SİSTEMİ
input group "═══ 5. ZARAR HEDGE SİSTEMİ ═══"
input bool     UseHedgeOnLoss     = true;          // ✅ Zararda Hedge Aç
input int      HedgeTriggerPips   = 10;            // Hedge Tetikleme (pip zarar)
input double   HedgeLotMultiplier = 1.0;           // Hedge Lot Çarpanı
input int      MaxHedgeCount      = 2;             // Max Hedge Sayısı

//--- 6. ATR SL/TP
input group "═══ 6. ATR SL/TP v4 ═══"
input bool     UseATRStops        = true;          // ATR Kullan
input int      ATR_Period         = 14;            // ATR Periyodu
input double   ATR_SL_Multiplier  = 1.5;           // SL Çarpanı
input double   ATR_TP_Multiplier  = 2.5;           // TP Çarpanı
input int      MinSL_Pips         = 5;             // Min SL
input int      MaxSL_Pips         = 25;            // Max SL

//--- 7. SABİT SL/TP (Fallback)
input group "═══ 7. SABİT SL/TP ═══"
input int      TP_Pips            = 15;            // Take Profit
input int      SL_Pips            = 20;            // Stop Loss

//--- 8. FİLTRELER
input group "═══ 8. FİLTRELER v4 ═══"
input bool     UseADXFilter       = true;          // ADX Filtresi
input int      ADX_Period         = 14;            // ADX Periyodu
input int      ADX_MinLevel       = 20;            // Min ADX
input bool     UseStochFilter     = true;          // Stokastik Filtresi
input int      Stoch_Oversold     = 30;            // Aşırı Satım
input int      Stoch_Overbought   = 70;            // Aşırı Alım

//--- 9. KORUMA
input group "═══ 9. KORUMA v4 ═══"
input int      MaxSpreadPips      = 5;             // Max Spread
input double   MaxDrawdownPercent = 25.0;          // Max DD %
input bool     CloseAllOnDrawdown = true;          // DD'de Kapat

//--- 10. COOLDOWN
input group "═══ 10. COOLDOWN v4 ═══"
input int      CooldownBars       = 3;             // Bar Bekleme
input int      CooldownSeconds    = 30;            // Saniye Bekleme

//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================
int      g_hEMA_Fast    = INVALID_HANDLE;
int      g_hEMA_Slow    = INVALID_HANDLE;
int      g_hEMA_Trend   = INVALID_HANDLE;
int      g_hADX         = INVALID_HANDLE;
int      g_hATR         = INVALID_HANDLE;
int      g_hStoch       = INVALID_HANDLE;

// İşlem takip
int      g_consecutiveWins    = 0;
int      g_consecutiveLosses  = 0;
int      g_hedgeCount         = 0;
double   g_currentLot         = 0;
double   g_lastProfit         = 0;

// İstatistikler
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
int      g_currentSignal      = 0;

// v4: Durum takip
ENUM_PROFIT_STATE g_profitState = STATE_NONE;
ENUM_ACTION_TYPE  g_nextAction  = ACTION_NONE;

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
   m_trade.SetDeviationInPoints(15);
   m_trade.SetMarginMode();
   m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   // Göstergeleri yükle
   g_hEMA_Fast = iMA(_Symbol, SignalTimeframe, EMA_Fast_Period, 0, MODE_EMA, PRICE_CLOSE);
   g_hEMA_Slow = iMA(_Symbol, SignalTimeframe, EMA_Slow_Period, 0, MODE_EMA, PRICE_CLOSE);
   g_hEMA_Trend = iMA(_Symbol, SignalTimeframe, EMA_Trend_Period, 0, MODE_EMA, PRICE_CLOSE);
   g_hADX = iADX(_Symbol, SignalTimeframe, ADX_Period);
   g_hATR = iATR(_Symbol, SignalTimeframe, ATR_Period);
   g_hStoch = iStochastic(_Symbol, SignalTimeframe, 14, 3, 3, MODE_SMA, STO_LOWHIGH);
   
   if(g_hEMA_Fast == INVALID_HANDLE || g_hEMA_Slow == INVALID_HANDLE || 
      g_hADX == INVALID_HANDLE || g_hATR == INVALID_HANDLE || g_hStoch == INVALID_HANDLE)
   {
      Print("❌ Göstergeler yüklenemedi!");
      return INIT_FAILED;
   }
   
   g_currentLot = StartingLot;
   g_equityHigh = AccountInfoDouble(ACCOUNT_EQUITY);
   
   Print("════════════════════════════════════════════════════════════════");
   Print("🎯 MİLYONER EA v4.0 - ANTİ-MARTİNGALE + HEDGE");
   Print("════════════════════════════════════════════════════════════════");
   Print("📊 Sinyal: ", EMA_Fast_Period, "/", EMA_Slow_Period, " EMA Cross");
   Print("📦 Başlangıç Lot: ", DoubleToString(StartingLot, 2));
   Print("📈 Kâr Lot Çarpan: ", DoubleToString(LotIncreaseMultiplier, 1), "x");
   Print("🔄 Hedge: ", UseHedgeOnLoss ? "AKTİF" : "KAPALI");
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
   if(g_hADX != INVALID_HANDLE) IndicatorRelease(g_hADX);
   if(g_hATR != INVALID_HANDLE) IndicatorRelease(g_hATR);
   if(g_hStoch != INVALID_HANDLE) IndicatorRelease(g_hStoch);
   
   double pf = g_grossLoss != 0 ? g_grossProfit / MathAbs(g_grossLoss) : 0;
   double wr = g_totalTrades > 0 ? (double)g_winTrades / g_totalTrades * 100.0 : 0;
   
   Print("════════════════════════════════════════════════════════════════");
   Print("🎯 MİLYONER EA v4.0 - SONUÇLAR");
   Print("════════════════════════════════════════════════════════════════");
   Print("📊 Toplam: ", g_totalTrades, " | WR: ", DoubleToString(wr, 1), "%");
   Print("⚖️ Kâr Faktörü: ", DoubleToString(pf, 2));
   Print("💰 Net: $", DoubleToString(g_totalProfit, 2));
   Print("📈 Ardışık Win: ", g_consecutiveWins, " | 🔄 Hedge: ", g_hedgeCount);
   Print("════════════════════════════════════════════════════════════════");
   
   ObjectsDeleteAll(0, "MILYONER_");
}

//====================================================================
// OnTick - v4 ANA DÖNGÜ
//====================================================================
void OnTick()
{
   if(ShowDashboard) UpdateDashboard();
   
   // ATR güncelle
   UpdateATR();
   
   // Drawdown kontrolü
   if(CheckDrawdown())
   {
      g_currentState = "⛔ DRAWDOWN";
      return;
   }
   
   // v4: MEVCUT POZİSYON DURUMU KONTROL
   AnalyzePositionState();
   
   // v4: KARAR MEKANİZMASI (Üçlü Operatör)
   DecideNextAction();
   
   // Spread kontrolü
   if(!CheckSpread())
   {
      g_currentState = "⚠️ SPREAD";
      return;
   }
   
   // Bar kontrolü
   datetime currentBar = iTime(_Symbol, SignalTimeframe, 0);
   if(g_lastBarTime != currentBar)
   {
      g_lastBarTime = currentBar;
      g_barsSinceTrade++;
   }
   
   // Cooldown
   if(!CheckCooldown())
   {
      g_currentState = "⏳ COOLDOWN";
      return;
   }
   
   // v4: AKSİYON UYGULA
   ExecuteAction();
}

//====================================================================
// v4: POZİSYON DURUMU ANALİZİ
//====================================================================
void AnalyzePositionState()
{
   g_profitState = STATE_NONE;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      double profit = PositionGetDouble(POSITION_PROFIT);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      long posType = PositionGetInteger(POSITION_TYPE);
      
      // Pip cinsinden kâr/zarar hesapla
      double pips = (posType == POSITION_TYPE_BUY) ? 
         PointsToPips(currentPrice - openPrice) : 
         PointsToPips(openPrice - currentPrice);
      
      //====================================================================
      // v4 KOŞUL: Kâr mı zarar mı? (Üçlü operatör)
      // profitState = (pips > 0) ? PROFIT : (pips < 0) ? LOSS : BREAKEVEN
      //====================================================================
      g_profitState = (pips > 0) ? STATE_PROFIT : 
                      (pips < 0) ? STATE_LOSS : 
                      STATE_BREAKEVEN;
      
      // Hedge tetikleme kontrolü
      if(UseHedgeOnLoss && g_profitState == STATE_LOSS)
      {
         //====================================================================
         // v4 KOŞUL: Zarar hedge tetiklemesi
         // shouldHedge = (pips < -HedgeTriggerPips && hedgeCount < MaxHedge) ? true : false
         //====================================================================
         bool shouldHedge = (pips < -HedgeTriggerPips && g_hedgeCount < MaxHedgeCount) ? true : false;
         
         if(shouldHedge)
         {
            //====================================================================
            // v4 KOŞUL: Hedge yönü (mevcut alımsa satış, satışsa alım)
            // hedgeType = (posType == BUY) ? SELL : BUY
            //====================================================================
            ENUM_ORDER_TYPE hedgeType = (posType == POSITION_TYPE_BUY) ? ORDER_TYPE_SELL : ORDER_TYPE_BUY;
            
            double hedgeLot = PositionGetDouble(POSITION_VOLUME) * HedgeLotMultiplier;
            hedgeLot = MathMax(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN), hedgeLot);
            hedgeLot = MathMin(hedgeLot, MaxLotSize);
            
            OpenHedgePosition(hedgeType, hedgeLot);
            g_hedgeCount++;
            
            Print("════════════════════════════════════════════════════════════════");
            Print("🔄 v4: HEDGE AÇILDI!");
            Print("📊 Ana Pozisyon: ", (posType == POSITION_TYPE_BUY ? "BUY" : "SELL"));
            Print("🔄 Hedge: ", (hedgeType == ORDER_TYPE_BUY ? "BUY" : "SELL"));
            Print("💔 Zarar: ", DoubleToString(pips, 1), " pips");
            Print("📦 Hedge Lot: ", DoubleToString(hedgeLot, 2));
            Print("════════════════════════════════════════════════════════════════");
         }
      }
      
      break; // İlk pozisyonu analiz et
   }
}

//====================================================================
// v4: KARAR MEKANİZMASI (Üçlü Operatör)
//====================================================================
void DecideNextAction()
{
   g_nextAction = ACTION_NONE;
   
   // Sinyal al
   int signal = GetSignal();
   g_currentSignal = signal;
   
   if(signal == 0)
   {
      g_rejectReason = "SİNYAL YOK";
      return;
   }
   
   //====================================================================
   // v4 KOŞUL: Sinyal var mı?
   // signalOK = (signal != 0) ? true : false
   //====================================================================
   bool signalOK = (signal != 0) ? true : false;
   
   //====================================================================
   // v4 KOŞUL: Açık pozisyon var mı?
   // hasPosition = (PositionCount > 0) ? true : false  
   //====================================================================
   bool hasPosition = HasOpenPosition();
   
   //====================================================================
   // v4 KOŞUL: Sonraki aksiyon ne?
   // action = !hasPosition ? OPEN_SIGNAL :
   //          (profitState == PROFIT && UseProfitLotIncrease) ? LOT_INCREASE :
   //          (profitState == LOSS && UseHedgeOnLoss) ? HEDGE :
   //          NONE
   //====================================================================
   g_nextAction = !hasPosition ? ACTION_OPEN_SIGNAL :
                  (g_profitState == STATE_PROFIT && UseProfitLotIncrease) ? ACTION_LOT_INCREASE :
                  (g_profitState == STATE_LOSS && UseHedgeOnLoss) ? ACTION_HEDGE :
                  ACTION_NONE;
   
   // Durum mesajı
   g_currentState = (g_nextAction == ACTION_OPEN_SIGNAL) ? "🟢 YENİ İŞLEM" :
                    (g_nextAction == ACTION_LOT_INCREASE) ? "📈 LOT ARTIRIM" :
                    (g_nextAction == ACTION_HEDGE) ? "🔄 HEDGE" :
                    "⏳ BEKLİYOR";
}

//====================================================================
// v4: AKSİYON UYGULA
//====================================================================
void ExecuteAction()
{
   if(g_nextAction == ACTION_OPEN_SIGNAL && g_currentSignal != 0)
   {
      //====================================================================
      // v4: SİNYAL TAKİP EDİLDİ - 0.01 LOT İŞLEM AÇILDI
      //====================================================================
      double lot = StartingLot;
      
      //====================================================================
      // v4 KOŞUL: Ardışık kazanç varsa lot artır
      // lot = (consecutiveWins > 0 && UseProfitLotIncrease) ? 
      //       StartingLot * (LotIncreaseMultiplier ^ consecutiveWins) : 
      //       StartingLot
      //====================================================================
      if(g_consecutiveWins > 0 && UseProfitLotIncrease && g_consecutiveWins <= MaxConsecutiveWins)
      {
         lot = StartingLot * MathPow(LotIncreaseMultiplier, g_consecutiveWins);
         Print("📈 Kâr Yönlü Lot Artırımı AKTİF! Win:", g_consecutiveWins, " Lot:", DoubleToString(lot, 2));
      }
      
      lot = MathMin(lot, MaxLotSize);
      lot = NormalizeLot(lot);
      
      ENUM_ORDER_TYPE orderType = (g_currentSignal == 1) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      OpenTradeWithSLTP(orderType, lot);
      
      g_lastTradeTime = TimeCurrent();
      g_barsSinceTrade = 0;
   }
   else if(g_nextAction == ACTION_LOT_INCREASE)
   {
      // Lot artırım zaten sinyal açılışında yapılıyor
      // Burada ek pozisyon eklenebilir (pyramiding)
   }
}

//====================================================================
// v4: İŞLEM AÇ (SL/TP ile)
//====================================================================
void OpenTradeWithSLTP(ENUM_ORDER_TYPE orderType, double lot)
{
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int direction = (orderType == ORDER_TYPE_BUY) ? 1 : -1;
   
   double sl, tp;
   GetDynamicSLTP(direction, sl, tp);
   
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
      
      Print("════════════════════════════════════════════════════════════════");
      Print("🎯 v4: ", (orderType == ORDER_TYPE_BUY ? "BUY" : "SELL"), " AÇILDI!");
      Print("📦 Lot: ", DoubleToString(lot, 2));
      Print("💰 Entry: ", DoubleToString(price, digits));
      Print("📈 Win Streak: ", g_consecutiveWins);
      Print("════════════════════════════════════════════════════════════════");
   }
}

//====================================================================
// v4: HEDGE POZİSYON AÇ
//====================================================================
void OpenHedgePosition(ENUM_ORDER_TYPE orderType, double lot)
{
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   double price = (orderType == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Hedge için SL/TP geniş tutulur
   double slDist = PipsToPoints(SL_Pips * 2);
   double tpDist = PipsToPoints(TP_Pips);
   
   double sl, tp;
   if(orderType == ORDER_TYPE_BUY)
   {
      sl = NormalizeDouble(price - slDist, digits);
      tp = NormalizeDouble(price + tpDist, digits);
   }
   else
   {
      sl = NormalizeDouble(price + slDist, digits);
      tp = NormalizeDouble(price - tpDist, digits);
   }
   
   lot = NormalizeLot(lot);
   
   if(orderType == ORDER_TYPE_BUY)
      m_trade.Buy(lot, _Symbol, 0, sl, tp, TradeComment + "_HEDGE");
   else
      m_trade.Sell(lot, _Symbol, 0, sl, tp, TradeComment + "_HEDGE");
}

//====================================================================
// v4: SİNYAL MOTORU
//====================================================================
int GetSignal()
{
   g_rejectReason = "SİNYAL BEKLENİYOR";
   
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
   
   double price = iClose(_Symbol, SignalTimeframe, 0);
   
   // EMA Cross kontrolü
   bool goldenCross = (emaFast[2] <= emaSlow[2] && emaFast[1] > emaSlow[1]);
   bool deathCross  = (emaFast[2] >= emaSlow[2] && emaFast[1] < emaSlow[1]);
   
   if(!goldenCross && !deathCross)
   {
      g_rejectReason = "CROSS YOK";
      return 0;
   }
   
   // ADX Filtresi
   if(UseADXFilter)
   {
      double adx[];
      ArrayResize(adx, 1);
      ArraySetAsSeries(adx, true);
      if(CopyBuffer(g_hADX, 0, 0, 1, adx) >= 1)
      {
         if(adx[0] < ADX_MinLevel)
         {
            g_rejectReason = "ADX: " + DoubleToString(adx[0], 0);
            return 0;
         }
      }
   }
   
   // Trend hizalama
   if(RequireTrendAlign)
   {
      if(goldenCross && price < emaTrend[0])
      {
         g_rejectReason = "TREND↓";
         return 0;
      }
      if(deathCross && price > emaTrend[0])
      {
         g_rejectReason = "TREND↑";
         return 0;
      }
   }
   
   // Stokastik filtre
   if(UseStochFilter)
   {
      double stochK[];
      ArrayResize(stochK, 2);
      ArraySetAsSeries(stochK, true);
      if(CopyBuffer(g_hStoch, 0, 0, 2, stochK) >= 2)
      {
         if(goldenCross && stochK[1] > Stoch_Oversold + 20)
         {
            g_rejectReason = "STOCH↑";
            return 0;
         }
         if(deathCross && stochK[1] < Stoch_Overbought - 20)
         {
            g_rejectReason = "STOCH↓";
            return 0;
         }
      }
   }
   
   if(goldenCross) return 1;
   if(deathCross) return -1;
   
   return 0;
}

//====================================================================
// YARDIMCI FONKSİYONLAR
//====================================================================
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

void GetDynamicSLTP(int direction, double &sl, double &tp)
{
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double price = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   double slDist, tpDist;
   
   if(UseATRStops && g_lastATR > 0)
   {
      slDist = g_lastATR * ATR_SL_Multiplier;
      tpDist = g_lastATR * ATR_TP_Multiplier;
      
      double minSLDist = PipsToPoints(MinSL_Pips);
      double maxSLDist = PipsToPoints(MaxSL_Pips);
      slDist = MathMax(minSLDist, MathMin(slDist, maxSLDist));
      tpDist = MathMax(slDist * 1.5, tpDist);
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

double NormalizeLot(double lot)
{
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   if(minLot <= 0) minLot = 0.01;
   if(stepLot <= 0) stepLot = 0.01;
   
   lot = MathFloor(lot / stepLot) * stepLot;
   lot = MathMax(minLot, MathMin(lot, MathMin(maxLot, MaxLotSize)));
   
   return lot;
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

bool CheckSpread()
{
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   return (spread / 10.0 <= MaxSpreadPips);
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
            g_lastProfit = profit;
            
            if(profit > 0)
            {
               g_winTrades++;
               g_consecutiveWins++;
               g_consecutiveLosses = 0;
               g_grossProfit += profit;
               g_hedgeCount = 0; // Hedge sayacını sıfırla
               
               Print("════════════════════════════════════════════════════════════════");
               Print("🎉 WIN! +$", DoubleToString(profit, 2));
               Print("📈 Win Streak: ", g_consecutiveWins, " → Sonraki lot artacak!");
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
               Print("❌ Loss Streak: ", g_consecutiveLosses);
               Print("════════════════════════════════════════════════════════════════");
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
   
   int x = 10, y = 25, h = 16;
   color gold = clrGold, white = clrWhite, gray = clrDimGray;
   
   CreateLabel("MILYONER_T", "🎯 MİLYONER v4.0 - ANTİ-MART + HEDGE", x, y, gold, 10); y += h + 3;
   CreateLabel("MILYONER_L1", "══════════════════════════════", x, y, gray, 7); y += h;
   
   CreateLabel("MILYONER_S", "📊 " + g_currentState, x, y, clrLime, 9); y += h;
   
   string profitStr = (g_profitState == STATE_PROFIT) ? "KÂRDA ✅" :
                      (g_profitState == STATE_LOSS) ? "ZARARDA ❌" :
                      (g_profitState == STATE_BREAKEVEN) ? "BAŞABAŞ" : "---";
   color profitClr = (g_profitState == STATE_PROFIT) ? clrLime :
                     (g_profitState == STATE_LOSS) ? clrRed : white;
   CreateLabel("MILYONER_Prof", "💹 Durum: " + profitStr, x, y, profitClr, 8); y += h;
   
   CreateLabel("MILYONER_B", "💰 $" + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2), x, y, white, 8); y += h;
   
   double dd = g_equityHigh > 0 ? (g_equityHigh - AccountInfoDouble(ACCOUNT_EQUITY)) / g_equityHigh * 100.0 : 0;
   CreateLabel("MILYONER_DD", "📉 DD: " + DoubleToString(dd, 1) + "%", x, y, dd < 10 ? clrLime : clrRed, 8); y += h;
   
   double pf = g_grossLoss != 0 ? g_grossProfit / MathAbs(g_grossLoss) : 0;
   CreateLabel("MILYONER_PF", "⚖️ PF: " + DoubleToString(pf, 2), x, y, pf >= 1.0 ? clrLime : clrRed, 8); y += h;
   
   CreateLabel("MILYONER_Net", "💵 Net: $" + DoubleToString(g_totalProfit, 2), x, y, g_totalProfit >= 0 ? clrLime : clrRed, 9); y += h;
   
   CreateLabel("MILYONER_L2", "══════════════════════════════", x, y, gray, 7); y += h;
   
   CreateLabel("MILYONER_Win", "📈 Win Streak: " + IntegerToString(g_consecutiveWins), x, y, g_consecutiveWins > 0 ? clrLime : white, 8); y += h;
   CreateLabel("MILYONER_Hedge", "🔄 Hedge: " + IntegerToString(g_hedgeCount) + "/" + IntegerToString(MaxHedgeCount), x, y, g_hedgeCount > 0 ? clrYellow : white, 8); y += h;
   
   double nextLot = StartingLot * MathPow(LotIncreaseMultiplier, g_consecutiveWins);
   nextLot = MathMin(nextLot, MaxLotSize);
   CreateLabel("MILYONER_Lot", "📦 Sonraki Lot: " + DoubleToString(nextLot, 2), x, y, gold, 8);
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
