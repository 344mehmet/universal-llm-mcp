//+------------------------------------------------------------------+
//|                                    MA_Master_Scalper_v8.1.mq5    |
//|                     © 2025, Milyoner EA Project v8.1             |
//|          GELİŞMİŞ MATEMATİK: ATR + BREAKEVEN + TRAILING          |
//+------------------------------------------------------------------+
#property copyright "© 2025, Milyoner EA v8.1"
#property version   "8.10"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// v8.1: GELİŞMİŞ MATEMATİK
// [1] ATR Dinamik SL/TP
// [2] Doğru Lot Hesaplama (TickValue bazlı)
// [3] Breakeven Sistemi
// [4] ATR Trailing Stop
// [5] R:R Min 1:2 Garantisi
//====================================================================

//====================================================================
// INPUT PARAMETRELERİ
//====================================================================
input group "═══ 1. ANA AYARLAR ═══"
input ulong    MagicNumber     = 888881;
input string   TradeComment    = "MILYONER_v8.1";
input ENUM_TIMEFRAMES TF       = PERIOD_M5;

input group "═══ 2. EMA CROSS ═══"
input int      EMA_Fast        = 8;
input int      EMA_Slow        = 21;
input bool     OnlyCross       = true;            // Sadece cross'ta işlem aç

input group "═══ 3. FİLTRELER ═══"
input bool     UseADX          = true;
input int      ADX_Period      = 14;
input int      ADX_Min         = 25;              // v8.1: Yükseltildi
input bool     UseRSI          = true;
input int      RSI_Period      = 14;
input int      RSI_OB          = 70;
input int      RSI_OS          = 30;

input group "═══ 4. ATR DİNAMİK SL/TP ═══"
input bool     UseATR          = true;
input int      ATR_Period      = 14;
input double   ATR_SL_Multi    = 1.5;             // SL = ATR × 1.5
input double   ATR_TP_Multi    = 3.0;             // TP = ATR × 3.0 (1:2 R:R)
input int      MinSL_Pips      = 8;
input int      MaxSL_Pips      = 25;
input int      FixedSL_Pips    = 15;              // ATR kapalıysa
input int      FixedTP_Pips    = 30;              // ATR kapalıysa

input group "═══ 5. BREAKEVEN ═══"
input bool     UseBreakeven    = true;
input double   BE_TriggerRatio = 0.5;             // TP'nin %50'sinde BE
input int      BE_LockPips     = 2;               // BE'de kilitlenen pip

input group "═══ 6. TRAILING STOP ═══"
input bool     UseTrailing     = true;
input double   Trail_StartRatio = 1.0;            // TP'nin %100'ünde başla
input double   Trail_ATR_Multi = 1.0;             // Trail mesafesi = ATR × 1.0

input group "═══ 7. RİSK YÖNETİMİ ═══"
input double   RiskPercent     = 1.0;             // İşlem başı risk %
input double   MaxLotSize      = 1.0;
input double   MaxDailyDD      = 5.0;             // Günlük max kayıp %
input int      MaxDailyTrades  = 10;              // Günlük max işlem

input group "═══ 8. COOLDOWN ═══"
input int      CooldownBars    = 3;               // v8.1: Artırıldı
input int      MaxSpread       = 3;               // v8.1: Düşürüldü

input group "═══ 9. MANUEL İŞLEM ═══"
input bool     ManageManual    = true;            // Manuel işlemleri yönet
input bool     AddSLTP         = true;            // SL/TP yoksa ekle
input bool     ApplyBEManual   = true;            // Breakeven uygula
input bool     ApplyTrailManual = true;           // Trailing uygula

//====================================================================
// GLOBAL
//====================================================================
int g_hEMA_Fast, g_hEMA_Slow, g_hADX, g_hRSI, g_hATR;
CTrade m_trade;

datetime g_lastBar = 0;
int g_barCount = 999;
double g_lastATR = 0;
double g_dayStartBalance = 0;
int g_dailyTrades = 0;
datetime g_lastDay = 0;
bool g_signalGivenThisBar = false;  // v8.1: Aynı bar'da tekrar sinyal verme

// İstatistik
int g_total = 0, g_wins = 0;
double g_profit = 0, g_grossP = 0, g_grossL = 0;
string g_state = "INIT";

//====================================================================
// HELPER FONKSİYONLARI
//====================================================================
double Pip2Pt(double pips) { 
   int mult = (SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) >= 4) ? 10 : 1;
   return pips * mult * SymbolInfoDouble(_Symbol, SYMBOL_POINT); 
}

double Pt2Pip(double points) { 
   int mult = (SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) >= 4) ? 10 : 1;
   return points / (mult * SymbolInfoDouble(_Symbol, SYMBOL_POINT)); 
}

//====================================================================
// v8.1: DOĞRU LOT HESAPLAMA FORMÜLÜ
//====================================================================
double CalculateOptimalLot(double slPips) {
   //====================================================================
   // [WEB] FORMÜL:
   // RiskAmount = Balance × RiskPercent / 100
   // LotSize = RiskAmount / (SL_Pips × PipValue)
   // PipValue = TickValue × (Point / TickSize) × 10
   //====================================================================
   
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * RiskPercent / 100.0;
   
   // Pip değeri hesaplama
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   if(tickValue <= 0) tickValue = 10.0;
   if(tickSize <= 0) tickSize = point;
   
   // 1 pip = 10 point (5 haneli broker için)
   double pipValue = tickValue * (point / tickSize) * 10.0;
   
   // Lot hesapla
   double lot = riskAmount / (slPips * pipValue);
   
   // Normalize et
   lot = NormalizeLot(lot);
   
   return lot;
}

double NormalizeLot(double lot) {
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   if(minLot <= 0) minLot = 0.01;
   if(stepLot <= 0) stepLot = 0.01;
   
   lot = MathFloor(lot / stepLot) * stepLot;
   lot = MathMax(minLot, MathMin(lot, MathMin(maxLot, MaxLotSize)));
   
   // Marjin kontrolü
   double margin = 0, price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double free = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   
   if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, margin)) {
      while(margin > free * 0.5 && lot > minLot) {
         lot = MathFloor((lot * 0.5) / stepLot) * stepLot;
         lot = MathMax(lot, minLot);
         if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, margin)) break;
      }
   }
   
   return lot;
}

//====================================================================
// v8.1: ATR DİNAMİK SL/TP
//====================================================================
void GetDynamicSLTP(int direction, double &slDist, double &tpDist) {
   if(UseATR && g_lastATR > 0) {
      slDist = g_lastATR * ATR_SL_Multi;
      tpDist = g_lastATR * ATR_TP_Multi;
      
      // Min/Max sınırları (pip cinsinden)
      double minSL = Pip2Pt(MinSL_Pips);
      double maxSL = Pip2Pt(MaxSL_Pips);
      slDist = MathMax(minSL, MathMin(slDist, maxSL));
      
      // R:R garantisi (min 1:2)
      if(tpDist < slDist * 2.0) {
         tpDist = slDist * 2.0;
      }
   }
   else {
      slDist = Pip2Pt(FixedSL_Pips);
      tpDist = Pip2Pt(FixedTP_Pips);
   }
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
   
   if(g_hEMA_Fast == INVALID_HANDLE || g_hEMA_Slow == INVALID_HANDLE || g_hATR == INVALID_HANDLE) {
      Print("❌ Gösterge hatası!");
      return INIT_FAILED;
   }
   
   g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   Print("═══════════════════════════════════════════════════════════");
   Print("🎯 MİLYONER EA v8.1 - GELİŞMİŞ MATEMATİK");
   Print("═══════════════════════════════════════════════════════════");
   Print("📊 EMA: ", EMA_Fast, "/", EMA_Slow, " | ADX>", ADX_Min);
   Print("📊 ATR SL:", ATR_SL_Multi, "x | TP:", ATR_TP_Multi, "x");
   Print("📊 Breakeven: ", UseBreakeven ? "ON" : "OFF");
   Print("📊 Trailing: ", UseTrailing ? "ON" : "OFF");
   Print("═══════════════════════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int r) {
   IndicatorRelease(g_hEMA_Fast);
   IndicatorRelease(g_hEMA_Slow);
   IndicatorRelease(g_hADX);
   IndicatorRelease(g_hRSI);
   IndicatorRelease(g_hATR);
   
   double pf = g_grossL != 0 ? g_grossP / MathAbs(g_grossL) : 0;
   double wr = g_total > 0 ? g_wins * 100.0 / g_total : 0;
   
   Print("═══════════════════════════════════════════════════════════");
   Print("📊 v8.1: ", g_total, " işlem | WR: ", DoubleToString(wr, 1), "%");
   Print("⚖️ PF: ", DoubleToString(pf, 2), " | Net: $", DoubleToString(g_profit, 2));
   Print("═══════════════════════════════════════════════════════════");
}

//====================================================================
// OnTick
//====================================================================
void OnTick() {
   UpdateATR();
   
   // Günlük reset
   MqlDateTime dt;
   TimeCurrent(dt);
   datetime today = StringToTime(IntegerToString(dt.year) + "." + IntegerToString(dt.mon) + "." + IntegerToString(dt.day));
   if(g_lastDay != today) {
      g_lastDay = today;
      g_dailyTrades = 0;
      g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   }
   
   // Günlük DD kontrolü
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double dailyDD = (g_dayStartBalance - currentBalance) / g_dayStartBalance * 100.0;
   if(dailyDD >= MaxDailyDD) {
      g_state = "⛔ GÜNLÜK DD";
      return;
   }
   
   // Günlük işlem limiti
   if(g_dailyTrades >= MaxDailyTrades) {
      g_state = "⛔ GÜNLÜK LİMİT";
      return;
   }
   
   // Spread kontrolü
   if(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0 > MaxSpread) {
      g_state = "⚠️ SPREAD";
      return;
   }
   
   // Pozisyon yönetimi (Breakeven + Trailing)
   ManagePositions();
   
   // Manuel işlem yönetimi
   if(ManageManual) ManageManualPositions();
   
   // Yeni bar kontrolü
   datetime bar = iTime(_Symbol, TF, 0);
   if(g_lastBar != bar) {
      g_lastBar = bar;
      g_barCount++;
      g_signalGivenThisBar = false;  // v8.1: Yeni bar'da sinyal sıfırla
   }
   
   // Pozisyon varsa çık
   if(HasPosition()) {
      g_state = "📊 AÇIK";
      return;
   }
   
   // Cooldown
   if(g_barCount < CooldownBars) {
      g_state = "⏳ BEKLE";
      return;
   }
   
   // v8.1: Bu bar'da zaten sinyal verildiyse çık
   if(g_signalGivenThisBar) {
      g_state = "⏳ BAR BEKLENİYOR";
      return;
   }
   
   // Sinyal al
   int signal = GetSignal();
   
   if(signal == 1) {
      g_state = "🟢 BUY!";
      OpenTrade(ORDER_TYPE_BUY);
      g_barCount = 0;
      g_dailyTrades++;
      g_signalGivenThisBar = true;  // v8.1: Sinyal verildi
   }
   else if(signal == -1) {
      g_state = "🔴 SELL!";
      OpenTrade(ORDER_TYPE_SELL);
      g_barCount = 0;
      g_dailyTrades++;
      g_signalGivenThisBar = true;  // v8.1: Sinyal verildi
   }
}

//====================================================================
// v8.1: BREAKEVEN + TRAILING YÖNETİMİ
//====================================================================
void ManagePositions() {
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
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
      
      double tpDist = MathAbs(currentTP - openPrice);
      double profitDist = (posType == POSITION_TYPE_BUY) ? 
         (currentPrice - openPrice) : (openPrice - currentPrice);
      
      //=== BREAKEVEN ===
      if(UseBreakeven) {
         double beTrigger = tpDist * BE_TriggerRatio;
         
         if(profitDist >= beTrigger) {
            double bePrice;
            if(posType == POSITION_TYPE_BUY) {
               bePrice = NormalizeDouble(openPrice + Pip2Pt(BE_LockPips), digits);
               if(currentSL < bePrice) {
                  m_trade.PositionModify(ticket, bePrice, currentTP);
                  Print("🔒 BE: SL→", DoubleToString(bePrice, digits));
               }
            }
            else {
               bePrice = NormalizeDouble(openPrice - Pip2Pt(BE_LockPips), digits);
               if(currentSL > bePrice || currentSL == 0) {
                  m_trade.PositionModify(ticket, bePrice, currentTP);
                  Print("🔒 BE: SL→", DoubleToString(bePrice, digits));
               }
            }
         }
      }
      
      //=== TRAILING STOP ===
      if(UseTrailing && g_lastATR > 0) {
         double trailTrigger = tpDist * Trail_StartRatio;
         double trailDist = g_lastATR * Trail_ATR_Multi;
         
         if(profitDist >= trailTrigger) {
            double newSL;
            if(posType == POSITION_TYPE_BUY) {
               newSL = NormalizeDouble(currentPrice - trailDist, digits);
               if(newSL > currentSL) {
                  m_trade.PositionModify(ticket, newSL, currentTP);
                  Print("📈 TRAIL: SL→", DoubleToString(newSL, digits));
               }
            }
            else {
               newSL = NormalizeDouble(currentPrice + trailDist, digits);
               if(newSL < currentSL || currentSL == 0) {
                  m_trade.PositionModify(ticket, newSL, currentTP);
                  Print("📉 TRAIL: SL→", DoubleToString(newSL, digits));
               }
            }
         }
      }
   }
}

//====================================================================
// MANUEL İŞLEM YÖNETİMİ
//====================================================================
void ManageManualPositions() {
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0 || PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      if(PositionGetInteger(POSITION_MAGIC) == MagicNumber) continue; // EA işlemlerini atla
      
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);
      long posType = PositionGetInteger(POSITION_TYPE);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      // SL/TP yoksa ekle
      if(AddSLTP && (currentSL == 0 || currentTP == 0)) {
         double slDist, tpDist;
         GetDynamicSLTP(1, slDist, tpDist);
         
         double newSL = currentSL, newTP = currentTP;
         if(posType == POSITION_TYPE_BUY) {
            if(currentSL == 0) newSL = NormalizeDouble(openPrice - slDist, digits);
            if(currentTP == 0) newTP = NormalizeDouble(openPrice + tpDist, digits);
         } else {
            if(currentSL == 0) newSL = NormalizeDouble(openPrice + slDist, digits);
            if(currentTP == 0) newTP = NormalizeDouble(openPrice - tpDist, digits);
         }
         if(newSL != currentSL || newTP != currentTP) {
            m_trade.PositionModify(ticket, newSL, newTP);
            Print("🛠️ MANUEL: SL/TP eklendi #", ticket);
         }
         currentSL = newSL; currentTP = newTP;
      }
      
      if(currentTP == 0) continue;
      double tpDist = MathAbs(currentTP - openPrice);
      double profitDist = (posType == POSITION_TYPE_BUY) ? (currentPrice - openPrice) : (openPrice - currentPrice);
      
      // Breakeven
      if(ApplyBEManual && UseBreakeven && profitDist >= tpDist * BE_TriggerRatio) {
         double bePrice = (posType == POSITION_TYPE_BUY) ? 
            openPrice + Pip2Pt(BE_LockPips) : openPrice - Pip2Pt(BE_LockPips);
         bePrice = NormalizeDouble(bePrice, digits);
         if((posType == POSITION_TYPE_BUY && currentSL < bePrice) || (posType == POSITION_TYPE_SELL && currentSL > bePrice)) {
            m_trade.PositionModify(ticket, bePrice, currentTP);
            Print("🔒 MANUEL BE #", ticket);
         }
      }
      
      // Trailing
      if(ApplyTrailManual && UseTrailing && g_lastATR > 0 && profitDist >= tpDist * Trail_StartRatio) {
         double trailDist = g_lastATR * Trail_ATR_Multi;
         double newSL = (posType == POSITION_TYPE_BUY) ? currentPrice - trailDist : currentPrice + trailDist;
         newSL = NormalizeDouble(newSL, digits);
         if((posType == POSITION_TYPE_BUY && newSL > currentSL) || (posType == POSITION_TYPE_SELL && newSL < currentSL)) {
            m_trade.PositionModify(ticket, newSL, currentTP);
            Print("📈 MANUEL TRAIL #", ticket);
         }
      }
   }
}

//====================================================================
// SİNYAL SİSTEMİ (v8'den)
//====================================================================
int GetSignal() {
   double emaFast[], emaSlow[];
   ArraySetAsSeries(emaFast, true);
   ArraySetAsSeries(emaSlow, true);
   ArrayResize(emaFast, 3);
   ArrayResize(emaSlow, 3);
   
   if(CopyBuffer(g_hEMA_Fast, 0, 0, 3, emaFast) < 3) return 0;
   if(CopyBuffer(g_hEMA_Slow, 0, 0, 3, emaSlow) < 3) return 0;
   
   // EMA Cross tespiti
   bool goldenCross = (emaFast[2] <= emaSlow[2]) && (emaFast[1] > emaSlow[1]);
   bool deathCross = (emaFast[2] >= emaSlow[2]) && (emaFast[1] < emaSlow[1]);
   
   // v8.1: Sadece cross'ta işlem (OnlyCross = true ise)
   if(OnlyCross && !goldenCross && !deathCross) {
      g_state = "⏳ CROSS BEKLE";
      return 0;
   }
   
   // ADX filtresi
   if(UseADX) {
      double adx[];
      ArraySetAsSeries(adx, true);
      ArrayResize(adx, 1);
      if(CopyBuffer(g_hADX, 0, 0, 1, adx) < 1) return 0;
      
      if(adx[0] < ADX_Min) {
         g_state = "⏳ ADX<" + IntegerToString(ADX_Min);
         return 0;
      }
   }
   
   // RSI filtresi
   if(UseRSI) {
      double rsi[];
      ArraySetAsSeries(rsi, true);
      ArrayResize(rsi, 1);
      if(CopyBuffer(g_hRSI, 0, 0, 1, rsi) < 1) return 0;
      
      if(goldenCross && rsi[0] > RSI_OB) {
         g_state = "⏳ RSI>" + IntegerToString(RSI_OB);
         return 0;
      }
      if(deathCross && rsi[0] < RSI_OS) {
         g_state = "⏳ RSI<" + IntegerToString(RSI_OS);
         return 0;
      }
   }
   
   // Sinyal üret
   if(goldenCross) {
      Print("✅ v8.1 BUY: Golden Cross (EMA", EMA_Fast, ">EMA", EMA_Slow, ")");
      return 1;
   }
   
   if(deathCross) {
      Print("✅ v8.1 SELL: Death Cross (EMA", EMA_Fast, "<EMA", EMA_Slow, ")");
      return -1;
   }
   
   g_state = "⏳ SİNYAL YOK";
   return 0;
}

//====================================================================
// İŞLEM AÇ
//====================================================================
void OpenTrade(ENUM_ORDER_TYPE orderType) {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int direction = (orderType == ORDER_TYPE_BUY) ? 1 : -1;
   
   double slDist, tpDist;
   GetDynamicSLTP(direction, slDist, tpDist);
   
   double slPips = Pt2Pip(slDist);
   double lot = CalculateOptimalLot(slPips);
   
   double price, sl, tp;
   
   if(orderType == ORDER_TYPE_BUY) {
      price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      sl = NormalizeDouble(price - slDist, digits);
      tp = NormalizeDouble(price + tpDist, digits);
      m_trade.Buy(lot, _Symbol, 0, sl, tp, TradeComment);
   }
   else {
      price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      sl = NormalizeDouble(price + slDist, digits);
      tp = NormalizeDouble(price - tpDist, digits);
      m_trade.Sell(lot, _Symbol, 0, sl, tp, TradeComment);
   }
   
   if(m_trade.ResultRetcode() == TRADE_RETCODE_DONE) {
      g_total++;
      double rr = tpDist / slDist;
      Print("════════════════════════════════════════════════════");
      Print("✅ ", (orderType == ORDER_TYPE_BUY ? "BUY" : "SELL"), 
            " @ ", DoubleToString(m_trade.ResultPrice(), digits));
      Print("📦 Lot: ", DoubleToString(lot, 2), 
            " | Risk: ", DoubleToString(RiskPercent, 1), "%");
      Print("🛑 SL: ", DoubleToString(slPips, 1), " pips | 🎯 TP: ", 
            DoubleToString(Pt2Pip(tpDist), 1), " pips");
      Print("⚖️ R:R = 1:", DoubleToString(rr, 2));
      Print("════════════════════════════════════════════════════");
   }
}

void UpdateATR() {
   double atr[];
   ArraySetAsSeries(atr, true);
   ArrayResize(atr, 1);
   if(CopyBuffer(g_hATR, 0, 0, 1, atr) >= 1) {
      g_lastATR = atr[0];
   }
}

bool HasPosition() {
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      return true;
   }
   return false;
}

void OnTradeTransaction(const MqlTradeTransaction& t, const MqlTradeRequest& r, const MqlTradeResult& res) {
   if(t.type == TRADE_TRANSACTION_DEAL_ADD) {
      if(t.deal_type == DEAL_TYPE_BUY || t.deal_type == DEAL_TYPE_SELL) return;
      
      ulong tk = t.deal;
      if(tk > 0 && HistoryDealSelect(tk)) {
         double pf = HistoryDealGetDouble(tk, DEAL_PROFIT);
         if(HistoryDealGetInteger(tk, DEAL_MAGIC) == MagicNumber) {
            g_profit += pf;
            if(pf > 0) {
               g_wins++;
               g_grossP += pf;
               Print("🎉 WIN +$", DoubleToString(pf, 2));
            }
            else {
               g_grossL += pf;
               Print("💔 LOSS $", DoubleToString(pf, 2));
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
