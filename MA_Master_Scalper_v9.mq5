//+------------------------------------------------------------------+
//|                                      MA_Master_Scalper_v9.mq5    |
//|                     © 2025, Milyoner EA Project v9.0             |
//|          LINEAR REGRESSION + GELİŞMİŞ MATEMATİK                  |
//+------------------------------------------------------------------+
#property copyright "© 2025, Milyoner EA v9"
#property version   "9.00"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// v9: GELİŞMİŞ MATEMATİK SİSTEMİ
// [1] Linear Regression Slope - Trend yönü ve gücü
// [2] Expectancy hesaplama - Beklenti değeri
// [3] Doğru pip/lot hesaplama
// [4] ATR dinamik SL/TP
// [5] Breakeven + Trailing
//====================================================================

//====================================================================
// INPUT PARAMETRELERİ
//====================================================================
input group "═══ 1. ANA AYARLAR ═══"
input ulong    MagicNumber     = 999999;
input string   TradeComment    = "MILYONER_v9";
input ENUM_TIMEFRAMES TF       = PERIOD_M5;

input group "═══ 2. LINEAR REGRESSION ═══"
input int      LR_Period       = 20;              // Regresyon periyodu
input double   LR_SlopeMin     = 0.0001;          // Min eğim (trend gücü)

input group "═══ 3. EMA CROSS ═══"
input int      EMA_Fast        = 8;
input int      EMA_Slow        = 21;

input group "═══ 4. FİLTRELER ═══"
input bool     UseADX          = true;
input int      ADX_Period      = 14;
input int      ADX_Min         = 25;
input bool     UseRSI          = true;
input int      RSI_Period      = 14;
input int      RSI_OB          = 70;
input int      RSI_OS          = 30;

input group "═══ 5. ATR SL/TP ═══"
input int      ATR_Period      = 14;
input double   ATR_SL_Multi    = 1.5;
input double   ATR_TP_Multi    = 3.0;
input int      MinSL           = 8;
input int      MaxSL           = 30;

input group "═══ 6. BREAKEVEN ═══"
input bool     UseBE           = true;
input double   BE_Trigger      = 0.5;             // TP %50'de BE
input int      BE_Lock         = 2;

input group "═══ 7. TRAILING ═══"
input bool     UseTrail        = true;
input double   Trail_Start     = 1.0;             // TP %100'de başla
input double   Trail_ATR       = 1.0;

input group "═══ 8. RİSK ═══"
input double   RiskPct         = 1.0;
input double   MaxLot          = 1.0;
input double   MaxDailyDD      = 5.0;
input int      MaxDailyTrades  = 10;

input group "═══ 9. COOLDOWN ═══"
input int      Cooldown        = 3;
input int      MaxSpread       = 3;

input group "═══ 10. MANUEL İŞLEM ═══"
input bool     ManageManual    = true;            // Manuel işlemleri yönet
input bool     AddSLTP         = true;            // SL/TP yoksa ekle
input bool     ApplyBE         = true;            // Breakeven uygula
input bool     ApplyTrail      = true;            // Trailing uygula

//====================================================================
// GLOBAL
//====================================================================
int g_hEMA_Fast, g_hEMA_Slow, g_hADX, g_hRSI, g_hATR;
CTrade m_trade;

datetime g_lastBar = 0;
int g_barCount = 999;
double g_atr = 0;
double g_dayStart = 0;
int g_dayTrades = 0;
datetime g_lastDay = 0;
bool g_signalGiven = false;

// İstatistik
int g_total = 0, g_wins = 0;
double g_profit = 0, g_grossP = 0, g_grossL = 0;
double g_avgWin = 0, g_avgLoss = 0;
string g_state = "INIT";

//====================================================================
// HELPER
//====================================================================
double Pip2Pt(double p) { 
   int m = (SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) >= 4) ? 10 : 1;
   return p * m * SymbolInfoDouble(_Symbol, SYMBOL_POINT); 
}

double Pt2Pip(double p) { 
   int m = (SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) >= 4) ? 10 : 1;
   return p / (m * SymbolInfoDouble(_Symbol, SYMBOL_POINT)); 
}

//====================================================================
// v9: LINEAR REGRESSION SLOPE HESAPLAMA
// y = ax + b formülü
// a = (n*Sxy - Sx*Sy) / (n*Sxx - Sx*Sx)
//====================================================================
double CalculateLRSlope(int period) {
   double Sx = 0, Sy = 0, Sxy = 0, Sxx = 0;
   int n = period;
   
   for(int i = 0; i < n; i++) {
      double x = i;
      double y = iClose(_Symbol, TF, i);
      Sx += x;
      Sy += y;
      Sxy += x * y;
      Sxx += x * x;
   }
   
   double denom = n * Sxx - Sx * Sx;
   if(denom == 0) return 0;
   
   double slope = (n * Sxy - Sx * Sy) / denom;
   return slope;
}

//====================================================================
// v9: EXPECTANCY (BEKLENTİ) HESAPLAMA
// E = (WinRate × AvgWin) - (LossRate × AvgLoss)
//====================================================================
double CalculateExpectancy() {
   if(g_total < 10) return 0;  // Yeterli veri yok
   
   double winRate = (double)g_wins / g_total;
   double lossRate = 1.0 - winRate;
   
   double avgWin = (g_wins > 0) ? g_grossP / g_wins : 0;
   double avgLoss = (g_total - g_wins > 0) ? MathAbs(g_grossL) / (g_total - g_wins) : 0;
   
   g_avgWin = avgWin;
   g_avgLoss = avgLoss;
   
   return (winRate * avgWin) - (lossRate * avgLoss);
}

//====================================================================
// v9: DOĞRU LOT HESAPLAMA
// Lot = RiskAmount / (SL_Pips × PipValue)
//====================================================================
double CalculateLot(double slPips) {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmt = balance * RiskPct / 100.0;
   
   // Pip değeri (doğru formül)
   double tickVal = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   if(tickVal <= 0) tickVal = 10;
   if(tickSize <= 0) tickSize = point;
   
   double pipVal = tickVal * (point / tickSize) * 10.0;
   double lot = riskAmt / (slPips * pipVal);
   
   return NormLot(lot);
}

double NormLot(double lot) {
   double mn = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double mx = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double st = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(st <= 0) st = 0.01;
   
   lot = MathFloor(lot / st) * st;
   lot = MathMax(mn, MathMin(lot, MathMin(mx, MaxLot)));
   
   // Marjin kontrolü
   double marg = 0, price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double free = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, marg)) {
      while(marg > free * 0.5 && lot > mn) {
         lot = MathFloor((lot * 0.5) / st) * st;
         lot = MathMax(lot, mn);
         if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, marg)) break;
      }
   }
   return lot;
}

//====================================================================
// OnInit
//====================================================================
int OnInit() {
   m_trade.SetExpertMagicNumber(MagicNumber);
   m_trade.SetDeviationInPoints(20);
   m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   g_hEMA_Fast = iMA(_Symbol, TF, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
   g_hEMA_Slow = iMA(_Symbol, TF, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
   g_hADX = iADX(_Symbol, TF, ADX_Period);
   g_hRSI = iRSI(_Symbol, TF, RSI_Period, PRICE_CLOSE);
   g_hATR = iATR(_Symbol, TF, ATR_Period);
   
   if(g_hEMA_Fast == INVALID_HANDLE) return INIT_FAILED;
   
   g_dayStart = AccountInfoDouble(ACCOUNT_BALANCE);
   
   Print("═══════════════════════════════════════════════════════════");
   Print("🎯 MİLYONER EA v9.0 - LINEAR REGRESSION + MATH");
   Print("═══════════════════════════════════════════════════════════");
   Print("📊 LR Period: ", LR_Period, " | Min Slope: ", LR_SlopeMin);
   Print("📊 EMA: ", EMA_Fast, "/", EMA_Slow, " | ADX>", ADX_Min);
   Print("═══════════════════════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int r) {
   IndicatorRelease(g_hEMA_Fast); IndicatorRelease(g_hEMA_Slow);
   IndicatorRelease(g_hADX); IndicatorRelease(g_hRSI); IndicatorRelease(g_hATR);
   
   double pf = g_grossL != 0 ? g_grossP / MathAbs(g_grossL) : 0;
   double wr = g_total > 0 ? g_wins * 100.0 / g_total : 0;
   double exp = CalculateExpectancy();
   
   Print("═══════════════════════════════════════════════════════════");
   Print("📊 v9: ", g_total, " trades | WR: ", DoubleToString(wr, 1), "%");
   Print("⚖️ PF: ", DoubleToString(pf, 2), " | Net: $", DoubleToString(g_profit, 2));
   Print("📈 Expectancy: $", DoubleToString(exp, 2), "/trade");
   Print("💰 AvgWin: $", DoubleToString(g_avgWin, 2), " | AvgLoss: $", DoubleToString(g_avgLoss, 2));
   Print("═══════════════════════════════════════════════════════════");
}

//====================================================================
// OnTick
//====================================================================
void OnTick() {
   UpdateATR();
   
   // Günlük reset
   MqlDateTime dt; TimeCurrent(dt);
   datetime today = StringToTime(IntegerToString(dt.year) + "." + IntegerToString(dt.mon) + "." + IntegerToString(dt.day));
   if(g_lastDay != today) { g_lastDay = today; g_dayTrades = 0; g_dayStart = AccountInfoDouble(ACCOUNT_BALANCE); }
   
   // DD kontrolü
   double dd = (g_dayStart - AccountInfoDouble(ACCOUNT_BALANCE)) / g_dayStart * 100;
   if(dd >= MaxDailyDD) { g_state = "⛔ DD"; return; }
   if(g_dayTrades >= MaxDailyTrades) { g_state = "⛔ LMT"; return; }
   if(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0 > MaxSpread) { g_state = "⚠️ SPR"; return; }
   
   ManagePos();
   if(ManageManual) ManageManualPos();
   
   datetime bar = iTime(_Symbol, TF, 0);
   if(g_lastBar != bar) { g_lastBar = bar; g_barCount++; g_signalGiven = false; }
   
   if(HasPos()) { g_state = "📊 AÇIK"; return; }
   if(g_barCount < Cooldown) { g_state = "⏳ BEKLE"; return; }
   if(g_signalGiven) { g_state = "⏳ BAR"; return; }
   
   int sig = GetSignal();
   if(sig == 1) { OpenTrade(ORDER_TYPE_BUY); g_signalGiven = true; g_barCount = 0; g_dayTrades++; }
   else if(sig == -1) { OpenTrade(ORDER_TYPE_SELL); g_signalGiven = true; g_barCount = 0; g_dayTrades++; }
}

//====================================================================
// v9 SİNYAL: LR Slope + EMA Cross + ADX + RSI
//====================================================================
int GetSignal() {
   // 1. Linear Regression Slope
   double slope = CalculateLRSlope(LR_Period);
   bool upTrend = slope > LR_SlopeMin;
   bool downTrend = slope < -LR_SlopeMin;
   
   if(!upTrend && !downTrend) { g_state = "⏳ LR FLAT"; return 0; }
   
   // 2. EMA Cross
   double emaF[], emaS[];
   ArraySetAsSeries(emaF, true); ArraySetAsSeries(emaS, true);
   ArrayResize(emaF, 3); ArrayResize(emaS, 3);
   if(CopyBuffer(g_hEMA_Fast, 0, 0, 3, emaF) < 3) return 0;
   if(CopyBuffer(g_hEMA_Slow, 0, 0, 3, emaS) < 3) return 0;
   
   bool goldCross = (emaF[2] <= emaS[2]) && (emaF[1] > emaS[1]);
   bool deadCross = (emaF[2] >= emaS[2]) && (emaF[1] < emaS[1]);
   
   // 3. ADX
   if(UseADX) {
      double adx[]; ArraySetAsSeries(adx, true); ArrayResize(adx, 1);
      if(CopyBuffer(g_hADX, 0, 0, 1, adx) < 1) return 0;
      if(adx[0] < ADX_Min) { g_state = "⏳ ADX"; return 0; }
   }
   
   // 4. RSI
   if(UseRSI) {
      double rsi[]; ArraySetAsSeries(rsi, true); ArrayResize(rsi, 1);
      if(CopyBuffer(g_hRSI, 0, 0, 1, rsi) < 1) return 0;
      if(upTrend && rsi[0] > RSI_OB) { g_state = "⏳ RSI>70"; return 0; }
      if(downTrend && rsi[0] < RSI_OS) { g_state = "⏳ RSI<30"; return 0; }
   }
   
   // Sinyal
   if(upTrend && goldCross) {
      Print("✅ v9 BUY: LR↑(", DoubleToString(slope, 6), ") + Golden Cross");
      return 1;
   }
   if(downTrend && deadCross) {
      Print("✅ v9 SELL: LR↓(", DoubleToString(slope, 6), ") + Death Cross");
      return -1;
   }
   
   g_state = "⏳ NO SIG";
   return 0;
}

//====================================================================
// İŞLEM
//====================================================================
void OpenTrade(ENUM_ORDER_TYPE type) {
   int d = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double slD = g_atr * ATR_SL_Multi;
   double tpD = g_atr * ATR_TP_Multi;
   slD = MathMax(Pip2Pt(MinSL), MathMin(slD, Pip2Pt(MaxSL)));
   if(tpD < slD * 2) tpD = slD * 2;
   
   double slPip = Pt2Pip(slD);
   double lot = CalculateLot(slPip);
   double price, sl, tp;
   
   if(type == ORDER_TYPE_BUY) {
      price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      sl = NormalizeDouble(price - slD, d);
      tp = NormalizeDouble(price + tpD, d);
      m_trade.Buy(lot, _Symbol, 0, sl, tp, TradeComment);
   } else {
      price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      sl = NormalizeDouble(price + slD, d);
      tp = NormalizeDouble(price - tpD, d);
      m_trade.Sell(lot, _Symbol, 0, sl, tp, TradeComment);
   }
   
   if(m_trade.ResultRetcode() == TRADE_RETCODE_DONE) {
      g_total++;
      double rr = tpD / slD;
      Print("════════════════════════════════════════");
      Print("✅ ", (type == ORDER_TYPE_BUY ? "BUY" : "SELL"), " Lot:", DoubleToString(lot, 2));
      Print("🛑 SL:", DoubleToString(slPip, 1), "p | 🎯 TP:", DoubleToString(Pt2Pip(tpD), 1), "p");
      Print("⚖️ R:R = 1:", DoubleToString(rr, 2));
      Print("════════════════════════════════════════");
   }
}

void ManagePos() {
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong t = PositionGetTicket(i);
      if(t == 0 || PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double curr = PositionGetDouble(POSITION_PRICE_CURRENT);
      double sl = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      long pType = PositionGetInteger(POSITION_TYPE);
      int d = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      double tpDist = MathAbs(tp - open);
      double profit = (pType == POSITION_TYPE_BUY) ? (curr - open) : (open - curr);
      
      // Breakeven
      if(UseBE && profit >= tpDist * BE_Trigger) {
         double beP = (pType == POSITION_TYPE_BUY) ? open + Pip2Pt(BE_Lock) : open - Pip2Pt(BE_Lock);
         beP = NormalizeDouble(beP, d);
         if((pType == POSITION_TYPE_BUY && sl < beP) || (pType == POSITION_TYPE_SELL && sl > beP)) {
            m_trade.PositionModify(t, beP, tp);
         }
      }
      
      // Trailing
      if(UseTrail && g_atr > 0 && profit >= tpDist * Trail_Start) {
         double trD = g_atr * Trail_ATR;
         double newSL = (pType == POSITION_TYPE_BUY) ? curr - trD : curr + trD;
         newSL = NormalizeDouble(newSL, d);
         if((pType == POSITION_TYPE_BUY && newSL > sl) || (pType == POSITION_TYPE_SELL && newSL < sl)) {
            m_trade.PositionModify(t, newSL, tp);
         }
      }
   }
}

//====================================================================
// MANUEL İŞLEM YÖNETİMİ
//====================================================================
void ManageManualPos() {
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong t = PositionGetTicket(i);
      if(t == 0 || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) == MagicNumber) continue; // EA işlemlerini atla
      
      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double curr = PositionGetDouble(POSITION_PRICE_CURRENT);
      double sl = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      long pType = PositionGetInteger(POSITION_TYPE);
      int d = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      // SL/TP yoksa ekle
      if(AddSLTP && (sl == 0 || tp == 0)) {
         double slD = g_atr * ATR_SL_Multi;
         double tpD = g_atr * ATR_TP_Multi;
         slD = MathMax(Pip2Pt(MinSL), MathMin(slD, Pip2Pt(MaxSL)));
         if(tpD < slD * 2) tpD = slD * 2;
         
         double nSL = sl, nTP = tp;
         if(pType == POSITION_TYPE_BUY) {
            if(sl == 0) nSL = NormalizeDouble(open - slD, d);
            if(tp == 0) nTP = NormalizeDouble(open + tpD, d);
         } else {
            if(sl == 0) nSL = NormalizeDouble(open + slD, d);
            if(tp == 0) nTP = NormalizeDouble(open - tpD, d);
         }
         if(nSL != sl || nTP != tp) {
            m_trade.PositionModify(t, nSL, nTP);
            Print("🛠️ MANUEL: SL/TP eklendi #", t);
         }
         sl = nSL; tp = nTP;
      }
      
      if(tp == 0) continue;
      double tpDist = MathAbs(tp - open);
      double profit = (pType == POSITION_TYPE_BUY) ? (curr - open) : (open - curr);
      
      // Breakeven
      if(ApplyBE && UseBE && profit >= tpDist * BE_Trigger) {
         double beP = (pType == POSITION_TYPE_BUY) ? open + Pip2Pt(BE_Lock) : open - Pip2Pt(BE_Lock);
         beP = NormalizeDouble(beP, d);
         if((pType == POSITION_TYPE_BUY && sl < beP) || (pType == POSITION_TYPE_SELL && sl > beP)) {
            m_trade.PositionModify(t, beP, tp);
            Print("🔒 MANUEL BE #", t);
         }
      }
      
      // Trailing
      if(ApplyTrail && UseTrail && g_atr > 0 && profit >= tpDist * Trail_Start) {
         double trD = g_atr * Trail_ATR;
         double newSL = (pType == POSITION_TYPE_BUY) ? curr - trD : curr + trD;
         newSL = NormalizeDouble(newSL, d);
         if((pType == POSITION_TYPE_BUY && newSL > sl) || (pType == POSITION_TYPE_SELL && newSL < sl)) {
            m_trade.PositionModify(t, newSL, tp);
            Print("📈 MANUEL TRAIL #", t);
         }
      }
   }
}

void UpdateATR() {
   double a[]; ArraySetAsSeries(a, true); ArrayResize(a, 1);
   if(CopyBuffer(g_hATR, 0, 0, 1, a) >= 1) g_atr = a[0];
}

bool HasPos() {
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong t = PositionGetTicket(i);
      if(t > 0 && PositionGetInteger(POSITION_MAGIC) == MagicNumber && PositionGetString(POSITION_SYMBOL) == _Symbol) return true;
   }
   return false;
}

void OnTradeTransaction(const MqlTradeTransaction& tr, const MqlTradeRequest& rq, const MqlTradeResult& rs) {
   if(tr.type == TRADE_TRANSACTION_DEAL_ADD) {
      if(tr.deal_type == DEAL_TYPE_BUY || tr.deal_type == DEAL_TYPE_SELL) return;
      ulong tk = tr.deal;
      if(tk > 0 && HistoryDealSelect(tk)) {
         double pf = HistoryDealGetDouble(tk, DEAL_PROFIT);
         if(HistoryDealGetInteger(tk, DEAL_MAGIC) == MagicNumber) {
            g_profit += pf;
            if(pf > 0) { g_wins++; g_grossP += pf; }
            else { g_grossL += pf; }
         }
      }
   }
}
//+------------------------------------------------------------------+
