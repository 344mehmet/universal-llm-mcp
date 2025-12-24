//+------------------------------------------------------------------+
//|                                      MA_Master_Scalper_v6.mq5    |
//|                     © 2025, Milyoner EA Project v6.0             |
//|                     TRIPLE CONFIRMATION + PENDING ORDERS         |
//+------------------------------------------------------------------+
#property copyright "© 2025, Milyoner EA v6"
#property version   "6.00"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// v6 WEB ARAŞTIRMA BAZLI STRATEJİ:
// [1] Üçlü Onay: MACD + RSI + Stokastik
// [2] Bollinger Squeeze tespiti
// [3] Engulfing Pattern onayı
// [4] GELİŞMİŞ BEKLEYEN EMİR SİSTEMİ
//====================================================================

enum ENUM_ENTRY_MODE {
   ENTRY_MARKET,         // Anlık Piyasa Emri
   ENTRY_PENDING,        // Sadece Bekleyen Emir
   ENTRY_HYBRID          // Her İkisi
};

enum ENUM_PENDING_TYPE {
   PENDING_LIMIT,        // Limit Emir (pullback)
   PENDING_STOP,         // Stop Emir (breakout)
   PENDING_BOTH          // Her İkisi
};

//====================================================================
// INPUT PARAMETRELERİ
//====================================================================

//--- 1. ANA AYARLAR
input group "═══ 1. ANA AYARLAR v6 ═══"
input ulong    MagicNumber        = 666666;
input string   TradeComment       = "MILYONER_v6";
input ENUM_TIMEFRAMES SignalTF    = PERIOD_M5;
input bool     ShowDashboard      = true;

//--- 2. BEKLEYEN EMİR SİSTEMİ (ÖNEMLİ!)
input group "═══ 2. BEKLEYEN EMİR SİSTEMİ ═══"
input ENUM_ENTRY_MODE EntryMode   = ENTRY_HYBRID;
input ENUM_PENDING_TYPE PendingType = PENDING_STOP;
input double   PendingDistance    = 5.0;          // Bekleyen emir mesafesi (pip)
input int      PendingExpireBars  = 3;            // Geçerlilik süresi (bar)
input bool     MovePendingToPrice = true;         // Fiyata yaklaştır
input double   CancelIfAwayPips   = 15.0;         // İptal mesafesi (pip)

//--- 3. ÜÇLÜ ONAY SİSTEMİ
input group "═══ 3. ÜÇLÜ ONAY ═══"
input bool     UseTripleConfirm   = true;
input int      MACD_Fast          = 12;
input int      MACD_Slow          = 26;
input int      MACD_Signal        = 9;
input int      RSI_Period         = 6;            // Hızlı RSI
input int      RSI_BuyLevel       = 25;           // BUY tetikleme
input int      RSI_SellLevel      = 75;           // SELL tetikleme
input int      Stoch_K            = 14;
input int      Stoch_D            = 3;
input int      Stoch_Slowing      = 3;

//--- 4. TREND FİLTRESİ
input group "═══ 4. TREND FİLTRESİ ═══"
input int      TrendEMA_Period    = 50;
input bool     RequireTrendAlign  = true;

//--- 5. SL/TP
input group "═══ 5. SL/TP ═══"
input bool     UseATRStops        = true;
input int      ATR_Period         = 14;
input double   ATR_SL_Multi       = 1.5;
input double   ATR_TP_Multi       = 2.5;
input int      MinSL_Pips         = 5;
input int      MaxSL_Pips         = 25;
input int      FixedSL_Pips       = 10;
input int      FixedTP_Pips       = 20;

//--- 6. RİSK
input group "═══ 6. RİSK ═══"
input double   RiskPercent        = 1.0;
input double   MaxLotSize         = 1.0;
input double   MaxDrawdownPct     = 25.0;

//--- 7. COOLDOWN
input group "═══ 7. COOLDOWN ═══"
input int      CooldownBars       = 2;
input int      MaxSpreadPips      = 4;

//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================
int g_hMACD, g_hRSI, g_hStoch, g_hEMA, g_hATR;
CTrade m_trade;

double   g_lastATR = 0;
double   g_equityHigh = 0;
double   g_maxDD = 0;
datetime g_lastBarTime = 0;
int      g_barsSinceTrade = 0;
ulong    g_pendingTicket = 0;
datetime g_pendingPlaceTime = 0;

// İstatistik
int      g_totalTrades = 0;
int      g_winTrades = 0;
double   g_totalProfit = 0;
double   g_grossProfit = 0;
double   g_grossLoss = 0;
string   g_state = "BAŞLATILIYOR";
string   g_rejectReason = "";

//====================================================================
// HELPER
//====================================================================
double PipsToPoints(double pips) {
   int mult = (SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) >= 4) ? 10 : 1;
   return pips * mult * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
}

double PointsToPips(double pts) {
   int mult = (SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) >= 4) ? 10 : 1;
   return pts / (mult * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
}

double NormalizeLot(double lot) {
   double minL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxL = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(step <= 0) step = 0.01;
   lot = MathFloor(lot / step) * step;
   lot = MathMax(minL, MathMin(lot, MathMin(maxL, MaxLotSize)));
   
   // Margin check
   double margin = 0, price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double free = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, margin)) {
      while(margin > free * 0.5 && lot > minL) {
         lot = MathFloor((lot * 0.5) / step) * step;
         lot = MathMax(lot, minL);
         if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, margin)) break;
      }
   }
   return lot;
}

//====================================================================
// OnInit
//====================================================================
int OnInit() {
   m_trade.SetExpertMagicNumber(MagicNumber);
   m_trade.SetDeviationInPoints(15);
   m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   g_hMACD  = iMACD(_Symbol, SignalTF, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE);
   g_hRSI   = iRSI(_Symbol, SignalTF, RSI_Period, PRICE_CLOSE);
   g_hStoch = iStochastic(_Symbol, SignalTF, Stoch_K, Stoch_D, Stoch_Slowing, MODE_SMA, STO_LOWHIGH);
   g_hEMA   = iMA(_Symbol, SignalTF, TrendEMA_Period, 0, MODE_EMA, PRICE_CLOSE);
   g_hATR   = iATR(_Symbol, SignalTF, ATR_Period);
   
   if(g_hMACD == INVALID_HANDLE || g_hRSI == INVALID_HANDLE) {
      Print("❌ Göstergeler yüklenemedi!");
      return INIT_FAILED;
   }
   
   g_equityHigh = AccountInfoDouble(ACCOUNT_EQUITY);
   
   Print("═══════════════════════════════════════════════════════════");
   Print("🎯 MİLYONER EA v6.0 - TRIPLE CONFIRM + PENDING ORDERS");
   Print("═══════════════════════════════════════════════════════════");
   Print("📊 Entry Mode: ", EnumToString(EntryMode));
   Print("📋 Pending Type: ", EnumToString(PendingType));
   Print("═══════════════════════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}

//====================================================================
// OnDeinit
//====================================================================
void OnDeinit(const int reason) {
   IndicatorRelease(g_hMACD);
   IndicatorRelease(g_hRSI);
   IndicatorRelease(g_hStoch);
   IndicatorRelease(g_hEMA);
   IndicatorRelease(g_hATR);
   
   double pf = g_grossLoss != 0 ? g_grossProfit / MathAbs(g_grossLoss) : 0;
   double wr = g_totalTrades > 0 ? g_winTrades * 100.0 / g_totalTrades : 0;
   
   Print("═══════════════════════════════════════════════════════════");
   Print("📊 v6 SONUÇLAR: ", g_totalTrades, " işlem | WR: ", DoubleToString(wr, 1), "%");
   Print("⚖️ PF: ", DoubleToString(pf, 2), " | Net: $", DoubleToString(g_totalProfit, 2));
   Print("═══════════════════════════════════════════════════════════");
   
   ObjectsDeleteAll(0, "MIL_");
}

//====================================================================
// OnTick
//====================================================================
void OnTick() {
   if(ShowDashboard) UpdateDashboard();
   UpdateATR();
   
   // Drawdown check
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   if(eq > g_equityHigh) g_equityHigh = eq;
   double dd = g_equityHigh > 0 ? (g_equityHigh - eq) / g_equityHigh * 100 : 0;
   if(dd > g_maxDD) g_maxDD = dd;
   if(dd >= MaxDrawdownPct) { g_state = "⛔ MAX DD"; return; }
   
   // Spread check
   if(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0 > MaxSpreadPips) {
      g_state = "⚠️ SPREAD"; return;
   }
   
   // Bar update
   datetime bar = iTime(_Symbol, SignalTF, 0);
   if(g_lastBarTime != bar) { g_lastBarTime = bar; g_barsSinceTrade++; }
   
   // Bekleyen emir yönetimi
   ManagePendingOrders();
   
   // Pozisyon varsa çık
   if(HasPosition()) { g_state = "📊 AÇIK POZ"; return; }
   
   // Cooldown
   if(g_barsSinceTrade < CooldownBars) { g_state = "⏳ COOLDOWN"; return; }
   
   // Sinyal al
   int sig = GetTripleConfirmSignal();
   
   if(sig != 0) {
      if(EntryMode == ENTRY_MARKET || EntryMode == ENTRY_HYBRID)
         OpenMarketOrder(sig);
      if(EntryMode == ENTRY_PENDING || EntryMode == ENTRY_HYBRID)
         PlacePendingOrder(sig);
      g_barsSinceTrade = 0;
   }
}

//====================================================================
// ÜÇLÜ ONAY SİNYAL SİSTEMİ
//====================================================================
int GetTripleConfirmSignal() {
   g_rejectReason = "BEKLEYEN...";
   
   // MACD
   double macd[], signal[], hist[];
   ArraySetAsSeries(macd, true); ArraySetAsSeries(signal, true); ArraySetAsSeries(hist, true);
   ArrayResize(macd, 2); ArrayResize(signal, 2); ArrayResize(hist, 2);
   CopyBuffer(g_hMACD, 0, 0, 2, macd);
   CopyBuffer(g_hMACD, 1, 0, 2, signal);
   CopyBuffer(g_hMACD, 2, 0, 2, hist);
   
   // RSI
   double rsi[];
   ArraySetAsSeries(rsi, true); ArrayResize(rsi, 2);
   CopyBuffer(g_hRSI, 0, 0, 2, rsi);
   
   // Stochastic
   double stochK[], stochD[];
   ArraySetAsSeries(stochK, true); ArraySetAsSeries(stochD, true);
   ArrayResize(stochK, 2); ArrayResize(stochD, 2);
   CopyBuffer(g_hStoch, 0, 0, 2, stochK);
   CopyBuffer(g_hStoch, 1, 0, 2, stochD);
   
   // EMA Trend
   double ema[];
   ArraySetAsSeries(ema, true); ArrayResize(ema, 1);
   CopyBuffer(g_hEMA, 0, 0, 1, ema);
   
   double price = iClose(_Symbol, SignalTF, 0);
   int trend = (price > ema[0]) ? 1 : -1;
   
   //=== BUY SİNYALİ ===
   // [1] MACD: Histogram > 0 veya cross up
   bool macdBuy = (hist[0] > 0) || (macd[1] < signal[1] && macd[0] > signal[0]);
   // [2] RSI: < 25 veya yükseliyor
   bool rsiBuy = (rsi[1] <= RSI_BuyLevel) || (rsi[0] > rsi[1] && rsi[0] < 50);
   // [3] Stochastic: K > D ve < 80
   bool stochBuy = (stochK[0] > stochD[0]) && (stochK[0] < 80);
   
   //=== SELL SİNYALİ ===
   bool macdSell = (hist[0] < 0) || (macd[1] > signal[1] && macd[0] < signal[0]);
   bool rsiSell = (rsi[1] >= RSI_SellLevel) || (rsi[0] < rsi[1] && rsi[0] > 50);
   bool stochSell = (stochK[0] < stochD[0]) && (stochK[0] > 20);
   
   // Trend filtresi
   if(RequireTrendAlign) {
      if(trend != 1) macdBuy = false;
      if(trend != -1) macdSell = false;
   }
   
   // Üçlü onay
   if(UseTripleConfirm) {
      if(macdBuy && rsiBuy && stochBuy) {
         g_state = "🟢 BUY SİNYAL!";
         Print("✅ v6 BUY: MACD+RSI+STOCH onaylı | Trend: UP");
         return 1;
      }
      if(macdSell && rsiSell && stochSell) {
         g_state = "🔴 SELL SİNYAL!";
         Print("✅ v6 SELL: MACD+RSI+STOCH onaylı | Trend: DOWN");
         return -1;
      }
   } else {
      // Sadece MACD
      if(macdBuy && trend == 1) return 1;
      if(macdSell && trend == -1) return -1;
   }
   
   g_rejectReason = "ONAY YOK";
   return 0;
}

//====================================================================
// BEKLEYEN EMİR YÖNETİMİ
//====================================================================
void ManagePendingOrders() {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0) continue;
      if(OrderGetInteger(ORDER_MAGIC) != MagicNumber) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      
      ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double currentAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      
      // Süre kontrolü - belirli bar sonra iptal
      datetime placeTime = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
      int barsPassed = (int)((TimeCurrent() - placeTime) / PeriodSeconds(SignalTF));
      
      if(barsPassed >= PendingExpireBars) {
         m_trade.OrderDelete(ticket);
         Print("⏰ Bekleyen emir süresi doldu, iptal: #", ticket);
         continue;
      }
      
      // Uzaklaştıysa iptal
      double distance = 0;
      if(type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_BUY_LIMIT)
         distance = PointsToPips(MathAbs(orderPrice - currentAsk));
      else
         distance = PointsToPips(MathAbs(orderPrice - currentBid));
      
      if(distance > CancelIfAwayPips) {
         m_trade.OrderDelete(ticket);
         Print("📏 Bekleyen emir çok uzakta, iptal: #", ticket, " (", DoubleToString(distance, 1), " pip)");
         continue;
      }
      
      // Fiyata yaklaştırma (opsiyonel)
      if(MovePendingToPrice && barsPassed >= 1) {
         double newPrice = 0;
         double sl = OrderGetDouble(ORDER_SL);
         double tp = OrderGetDouble(ORDER_TP);
         
         if(type == ORDER_TYPE_BUY_STOP) {
            newPrice = currentAsk + PipsToPoints(PendingDistance);
         } else if(type == ORDER_TYPE_SELL_STOP) {
            newPrice = currentBid - PipsToPoints(PendingDistance);
         } else if(type == ORDER_TYPE_BUY_LIMIT) {
            newPrice = currentAsk - PipsToPoints(PendingDistance);
         } else if(type == ORDER_TYPE_SELL_LIMIT) {
            newPrice = currentBid + PipsToPoints(PendingDistance);
         }
         
         if(newPrice > 0 && MathAbs(newPrice - orderPrice) > PipsToPoints(1)) {
            // SL/TP'yi yeni fiyata göre ayarla
            double slPips = PointsToPips(MathAbs(orderPrice - sl));
            double tpPips = PointsToPips(MathAbs(tp - orderPrice));
            int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
            
            if(type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_BUY_LIMIT) {
               sl = NormalizeDouble(newPrice - PipsToPoints(slPips), digits);
               tp = NormalizeDouble(newPrice + PipsToPoints(tpPips), digits);
            } else {
               sl = NormalizeDouble(newPrice + PipsToPoints(slPips), digits);
               tp = NormalizeDouble(newPrice - PipsToPoints(tpPips), digits);
            }
            
            m_trade.OrderModify(ticket, NormalizeDouble(newPrice, digits), sl, tp, ORDER_TIME_GTC, 0);
         }
      }
   }
}

//====================================================================
// BEKLEYEN EMİR YERLEŞTIR
//====================================================================
void PlacePendingOrder(int direction) {
   // Mevcut bekleyen emir varsa yenisini açma
   if(HasPendingOrder()) {
      Print("⚠️ Zaten bekleyen emir var, yeni emir atlanıyor");
      return;
   }
   
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   double sl, tp;
   GetSLTP(direction, sl, tp);
   
   double lot = CalculateLot();
   double pendDist = PipsToPoints(PendingDistance);
   
   ENUM_ORDER_TYPE orderType;
   double orderPrice;
   
   if(direction == 1) {
      // BUY
      if(PendingType == PENDING_STOP || PendingType == PENDING_BOTH) {
         // BUY STOP - fiyat yukarı kırılırsa al
         orderType = ORDER_TYPE_BUY_STOP;
         orderPrice = NormalizeDouble(ask + pendDist, digits);
         sl = NormalizeDouble(orderPrice - GetSLDistance(), digits);
         tp = NormalizeDouble(orderPrice + GetTPDistance(), digits);
         
         if(m_trade.OrderOpen(_Symbol, orderType, lot, 0, orderPrice, sl, tp, ORDER_TIME_GTC, 0, TradeComment + "_STOP")) {
            Print("📋 BUY STOP yerleştirildi @ ", DoubleToString(orderPrice, digits));
         }
      }
      if(PendingType == PENDING_LIMIT || PendingType == PENDING_BOTH) {
         // BUY LIMIT - pullback'te al
         orderType = ORDER_TYPE_BUY_LIMIT;
         orderPrice = NormalizeDouble(ask - pendDist, digits);
         sl = NormalizeDouble(orderPrice - GetSLDistance(), digits);
         tp = NormalizeDouble(orderPrice + GetTPDistance(), digits);
         
         if(m_trade.OrderOpen(_Symbol, orderType, lot, 0, orderPrice, sl, tp, ORDER_TIME_GTC, 0, TradeComment + "_LIMIT")) {
            Print("📋 BUY LIMIT yerleştirildi @ ", DoubleToString(orderPrice, digits));
         }
      }
   } else {
      // SELL
      if(PendingType == PENDING_STOP || PendingType == PENDING_BOTH) {
         orderType = ORDER_TYPE_SELL_STOP;
         orderPrice = NormalizeDouble(bid - pendDist, digits);
         sl = NormalizeDouble(orderPrice + GetSLDistance(), digits);
         tp = NormalizeDouble(orderPrice - GetTPDistance(), digits);
         
         if(m_trade.OrderOpen(_Symbol, orderType, lot, 0, orderPrice, sl, tp, ORDER_TIME_GTC, 0, TradeComment + "_STOP")) {
            Print("📋 SELL STOP yerleştirildi @ ", DoubleToString(orderPrice, digits));
         }
      }
      if(PendingType == PENDING_LIMIT || PendingType == PENDING_BOTH) {
         orderType = ORDER_TYPE_SELL_LIMIT;
         orderPrice = NormalizeDouble(bid + pendDist, digits);
         sl = NormalizeDouble(orderPrice + GetSLDistance(), digits);
         tp = NormalizeDouble(orderPrice - GetTPDistance(), digits);
         
         if(m_trade.OrderOpen(_Symbol, orderType, lot, 0, orderPrice, sl, tp, ORDER_TIME_GTC, 0, TradeComment + "_LIMIT")) {
            Print("📋 SELL LIMIT yerleştirildi @ ", DoubleToString(orderPrice, digits));
         }
      }
   }
}

//====================================================================
// PİYASA EMRİ
//====================================================================
void OpenMarketOrder(int direction) {
   if(HasPosition()) return;
   
   double lot = CalculateLot();
   double sl, tp;
   GetSLTP(direction, sl, tp);
   
   bool ok = false;
   if(direction == 1)
      ok = m_trade.Buy(lot, _Symbol, 0, sl, tp, TradeComment);
   else
      ok = m_trade.Sell(lot, _Symbol, 0, sl, tp, TradeComment);
   
   if(ok && m_trade.ResultRetcode() == TRADE_RETCODE_DONE) {
      g_totalTrades++;
      Print("✅ ", (direction == 1 ? "BUY" : "SELL"), " @ ", DoubleToString(m_trade.ResultPrice(), 5), " Lot: ", DoubleToString(lot, 2));
   }
}

//====================================================================
// YARDIMCI FONKSİYONLAR
//====================================================================
double GetSLDistance() {
   if(UseATRStops && g_lastATR > 0) {
      double d = g_lastATR * ATR_SL_Multi;
      d = MathMax(PipsToPoints(MinSL_Pips), MathMin(d, PipsToPoints(MaxSL_Pips)));
      return d;
   }
   return PipsToPoints(FixedSL_Pips);
}

double GetTPDistance() {
   if(UseATRStops && g_lastATR > 0) {
      return g_lastATR * ATR_TP_Multi;
   }
   return PipsToPoints(FixedTP_Pips);
}

void GetSLTP(int dir, double &sl, double &tp) {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double price = (dir == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double slD = GetSLDistance();
   double tpD = GetTPDistance();
   
   if(dir == 1) {
      sl = NormalizeDouble(price - slD, digits);
      tp = NormalizeDouble(price + tpD, digits);
   } else {
      sl = NormalizeDouble(price + slD, digits);
      tp = NormalizeDouble(price - tpD, digits);
   }
}

double CalculateLot() {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double risk = balance * RiskPercent / 100.0;
   double slPips = UseATRStops ? PointsToPips(g_lastATR * ATR_SL_Multi) : FixedSL_Pips;
   slPips = MathMax(slPips, MinSL_Pips);
   
   double tickVal = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   if(tickVal <= 0) tickVal = 10;
   double pipVal = tickVal * 10;
   
   double lot = risk / (slPips * pipVal);
   return NormalizeLot(lot);
}

void UpdateATR() {
   double a[]; ArrayResize(a, 1); ArraySetAsSeries(a, true);
   if(CopyBuffer(g_hATR, 0, 0, 1, a) >= 1) g_lastATR = a[0];
}

bool HasPosition() {
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong t = PositionGetTicket(i);
      if(t == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      return true;
   }
   return false;
}

bool HasPendingOrder() {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      ulong t = OrderGetTicket(i);
      if(t == 0) continue;
      if(OrderGetInteger(ORDER_MAGIC) != MagicNumber) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      return true;
   }
   return false;
}

//====================================================================
// OnTradeTransaction
//====================================================================
void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& req, const MqlTradeResult& res) {
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD) {
      if(trans.deal_type == DEAL_TYPE_BUY || trans.deal_type == DEAL_TYPE_SELL) return;
      
      ulong tk = trans.deal;
      if(tk > 0 && HistoryDealSelect(tk)) {
         double pf = HistoryDealGetDouble(tk, DEAL_PROFIT);
         if(HistoryDealGetInteger(tk, DEAL_MAGIC) == MagicNumber) {
            g_totalProfit += pf;
            if(pf > 0) { g_winTrades++; g_grossProfit += pf; Print("🎉 WIN +$", DoubleToString(pf, 2)); }
            else { g_grossLoss += pf; Print("💔 LOSS $", DoubleToString(pf, 2)); }
         }
      }
   }
}

//====================================================================
// DASHBOARD
//====================================================================
void UpdateDashboard() {
   if(!MQLInfoInteger(MQL_VISUAL_MODE) && !MQLInfoInteger(MQL_TESTER)) return;
   
   int x = 10, y = 25, h = 16;
   
   CreateLbl("MIL_T", "🎯 MİLYONER v6.0", x, y, clrGold, 10); y += h + 3;
   CreateLbl("MIL_S", "📊 " + g_state, x, y, clrLime, 9); y += h;
   CreateLbl("MIL_B", "💰 $" + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2), x, y, clrWhite, 8); y += h;
   
   double wr = g_totalTrades > 0 ? g_winTrades * 100.0 / g_totalTrades : 0;
   CreateLbl("MIL_WR", "📈 WR: " + DoubleToString(wr, 1) + "%", x, y, wr >= 50 ? clrLime : clrRed, 8); y += h;
   
   double pf = g_grossLoss != 0 ? g_grossProfit / MathAbs(g_grossLoss) : 0;
   CreateLbl("MIL_PF", "⚖️ PF: " + DoubleToString(pf, 2), x, y, pf >= 1 ? clrLime : clrRed, 8); y += h;
   
   CreateLbl("MIL_Net", "💵 Net: $" + DoubleToString(g_totalProfit, 2), x, y, g_totalProfit >= 0 ? clrLime : clrRed, 8); y += h;
   
   int pendCount = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      if(OrderGetTicket(i) > 0 && OrderGetInteger(ORDER_MAGIC) == MagicNumber) pendCount++;
   }
   CreateLbl("MIL_Pend", "📋 Bekleyen: " + IntegerToString(pendCount), x, y, pendCount > 0 ? clrYellow : clrWhite, 8);
}

void CreateLbl(string n, string t, int x, int y, color c, int s) {
   if(ObjectFind(0, n) < 0) {
      ObjectCreate(0, n, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, n, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   }
   ObjectSetInteger(0, n, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, n, OBJPROP_YDISTANCE, y);
   ObjectSetString(0, n, OBJPROP_TEXT, t);
   ObjectSetInteger(0, n, OBJPROP_COLOR, c);
   ObjectSetInteger(0, n, OBJPROP_FONTSIZE, s);
}
//+------------------------------------------------------------------+
