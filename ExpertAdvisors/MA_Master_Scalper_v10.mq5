//+------------------------------------------------------------------+
//|                                     MA_Master_Scalper_v10.mq5    |
//|                     © 2025, Milyoner EA Project v10.0            |
//|              ULTIMATE VERSION - TÜM ÖZELLİKLER BİRLEŞİK          |
//+------------------------------------------------------------------+
#property copyright "© 2025, Milyoner EA v10 - Ultimate"
#property version   "10.00"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// v10: ULTIMATE VERSION - TÜM ÖZELLİKLER
// ═══════════════════════════════════════════════════════════════════
// [1] MA1/MA2/MA3 Üçlü Kesişim Sistemi (MA Dansı)
// [2] MACD Histogram Sıfır Çizgisi Filtresi
// [3] Linear Regression Slope (Trend Gücü)
// [4] RSI + ADX Filtreler
// [5] ATR Dinamik SL/TP (Min 1:2 R:R)
// [6] Breakeven Sistemi
// [7] ATR Trailing Stop
// [8] Bekleyen Emir Sistemi
// [9] Doğru Lot/Pip Hesaplama Matematiği
// [10] Günlük DD + İşlem Limiti
// [11] Bar Başına Tek Sinyal
// [12] Expectancy Hesaplama
// ═══════════════════════════════════════════════════════════════════

enum ENUM_ENTRY_MODE { 
   MODE_MARKET,      // Sadece Piyasa Emri
   MODE_PENDING,     // Sadece Bekleyen Emir
   MODE_BOTH         // Her İkisi
};

//====================================================================
// INPUT PARAMETRELERİ
//====================================================================
input group "═══════ 1. ANA AYARLAR ═══════"
input ulong    MagicNumber       = 101010;
input string   TradeComment      = "MILYONER_v10";
input ENUM_TIMEFRAMES TF         = PERIOD_M5;

input group "═══════ 2. ÜÇLÜ MA SİSTEMİ (MA Dansı) ═══════"
input int      MA1_Period        = 8;              // Hızlı MA (Sinyal)
input int      MA2_Period        = 21;             // Orta MA (Trend)
input int      MA3_Period        = 50;             // Yavaş MA (Ana Trend)
input ENUM_MA_METHOD MA_Method   = MODE_EMA;       // MA Tipi

input group "═══════ 3. MACD SIFIR ÇİZGİSİ ═══════"
input bool     UseMACD           = true;
input int      MACD_Fast         = 12;
input int      MACD_Slow         = 26;
input int      MACD_Signal       = 9;
input bool     MACDAboveZero     = true;           // Histogram > 0 zorunlu

input group "═══════ 4. LINEAR REGRESSION ═══════"
input bool     UseLR             = true;
input int      LR_Period         = 20;
input double   LR_MinSlope       = 0.0001;         // Min trend eğimi

input group "═══════ 5. FİLTRELER ═══════"
input bool     UseADX            = true;
input int      ADX_Period        = 14;
input int      ADX_Min           = 25;
input bool     UseRSI            = true;
input int      RSI_Period        = 14;
input int      RSI_OB            = 70;
input int      RSI_OS            = 30;

input group "═══════ 6. ATR DİNAMİK SL/TP ═══════"
input bool     UseATR            = true;
input int      ATR_Period        = 14;
input double   ATR_SL_Multi      = 1.5;            // SL = ATR × 1.5
input double   ATR_TP_Multi      = 3.0;            // TP = ATR × 3.0 (1:2 R:R)
input int      MinSL_Pips        = 8;
input int      MaxSL_Pips        = 30;
input int      FixedSL           = 15;             // ATR kapalıysa
input int      FixedTP           = 30;

input group "═══════ 7. BREAKEVEN ═══════"
input bool     UseBreakeven      = true;
input double   BE_TriggerPct     = 50.0;           // TP %50'de BE aktif
input int      BE_LockPips       = 2;              // Kilitlenen pip

input group "═══════ 8. TRAILING STOP ═══════"
input bool     UseTrailing       = true;
input double   Trail_StartPct    = 100.0;          // TP %100'de başla
input double   Trail_ATR_Multi   = 1.0;            // Trail = ATR × 1.0

input group "═══════ 9. BEKLEYEN EMİR ═══════"
input ENUM_ENTRY_MODE EntryMode  = MODE_MARKET;
input double   PendingPips       = 5.0;
input int      PendingExpireBars = 3;

input group "═══════ 10. RİSK YÖNETİMİ ═══════"
input double   RiskPercent       = 1.0;            // İşlem başı risk %
input double   MaxLotSize        = 1.0;
input double   MaxDailyDDPct     = 5.0;            // Günlük max kayıp %
input int      MaxDailyTrades    = 10;

input group "═══════ 11. COOLDOWN ═══════"
input int      CooldownBars      = 3;
input int      MaxSpreadPips     = 3;

input group "═══════ 12. MANUEL İŞLEM YÖNETİMİ ═══════"
input bool     ManageManualTrades = true;          // ✅ Manuel işlemleri yönet
input bool     AddSLTPToManual   = true;           // SL/TP yoksa ekle
input bool     ApplyBEToManual   = true;           // Breakeven uygula
input bool     ApplyTrailToManual = true;          // Trailing uygula

//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================
int g_hMA1, g_hMA2, g_hMA3;
int g_hMACD, g_hADX, g_hRSI, g_hATR;
CTrade m_trade;

datetime g_lastBarTime = 0;
int g_barsSinceTrade = 999;
double g_lastATR = 0;
double g_dayStartBalance = 0;
int g_dailyTradeCount = 0;
datetime g_lastDay = 0;
bool g_signalGivenThisBar = false;

// İSTATİSTİK
int g_totalTrades = 0;
int g_winTrades = 0;
double g_netProfit = 0;
double g_grossProfit = 0;
double g_grossLoss = 0;
double g_avgWin = 0;
double g_avgLoss = 0;
string g_state = "BAŞLATILIYOR...";

//====================================================================
// YARDIMCI FONKSİYONLAR
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
// v10: LINEAR REGRESSION SLOPE HESAPLAMA
// Formül: slope = (n×Sxy - Sx×Sy) / (n×Sxx - Sx²)
//====================================================================
double CalculateLRSlope() {
   if(!UseLR) return 999;  // LR devre dışı
   
   double Sx = 0, Sy = 0, Sxy = 0, Sxx = 0;
   int n = LR_Period;
   
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

//====================================================================
// v10: EXPECTANCY HESAPLAMA
// E = (WinRate × AvgWin) - (LossRate × AvgLoss)
//====================================================================
double CalculateExpectancy() {
   if(g_totalTrades < 5) return 0;
   
   double winRate = (double)g_winTrades / g_totalTrades;
   double lossRate = 1.0 - winRate;
   
   g_avgWin = (g_winTrades > 0) ? g_grossProfit / g_winTrades : 0;
   g_avgLoss = (g_totalTrades - g_winTrades > 0) ? MathAbs(g_grossLoss) / (g_totalTrades - g_winTrades) : 0;
   
   return (winRate * g_avgWin) - (lossRate * g_avgLoss);
}

//====================================================================
// v10: DOĞRU LOT HESAPLAMA
// Lot = RiskAmount / (SL_Pips × PipValue)
//====================================================================
double CalculateOptimalLot(double slPips) {
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double riskAmount = balance * RiskPercent / 100.0;
   
   // Doğru Pip Değeri Hesaplama
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   if(tickValue <= 0) tickValue = 10.0;
   if(tickSize <= 0) tickSize = point;
   
   double pipValue = tickValue * (point / tickSize) * 10.0;
   double lot = riskAmount / (slPips * pipValue);
   
   return NormalizeLot(lot);
}

double NormalizeLot(double lot) {
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   if(minLot <= 0) minLot = 0.01;
   if(stepLot <= 0) stepLot = 0.01;
   
   lot = MathFloor(lot / stepLot) * stepLot;
   lot = MathMax(minLot, MathMin(lot, MathMin(maxLot, MaxLotSize)));
   
   // Marjin Kontrolü
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

//====================================================================
// v10: DİNAMİK SL/TP HESAPLAMA
//====================================================================
void GetDynamicSLTP(double &slDist, double &tpDist) {
   if(UseATR && g_lastATR > 0) {
      slDist = g_lastATR * ATR_SL_Multi;
      tpDist = g_lastATR * ATR_TP_Multi;
      
      // Pip limitlerini uygula
      double minSL = Pip2Pt(MinSL_Pips);
      double maxSL = Pip2Pt(MaxSL_Pips);
      slDist = MathMax(minSL, MathMin(slDist, maxSL));
      
      // Min 1:2 R:R garantisi
      if(tpDist < slDist * 2.0) {
         tpDist = slDist * 2.0;
      }
   } else {
      slDist = Pip2Pt(FixedSL);
      tpDist = Pip2Pt(FixedTP);
   }
}

//====================================================================
// OnInit
//====================================================================
int OnInit() {
   m_trade.SetExpertMagicNumber(MagicNumber);
   m_trade.SetDeviationInPoints(20);
   m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   // Göstergeler
   g_hMA1 = iMA(_Symbol, TF, MA1_Period, 0, MA_Method, PRICE_CLOSE);
   g_hMA2 = iMA(_Symbol, TF, MA2_Period, 0, MA_Method, PRICE_CLOSE);
   g_hMA3 = iMA(_Symbol, TF, MA3_Period, 0, MA_Method, PRICE_CLOSE);
   g_hMACD = iMACD(_Symbol, TF, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE);
   g_hADX = iADX(_Symbol, TF, ADX_Period);
   g_hRSI = iRSI(_Symbol, TF, RSI_Period, PRICE_CLOSE);
   g_hATR = iATR(_Symbol, TF, ATR_Period);
   
   if(g_hMA1 == INVALID_HANDLE || g_hMA2 == INVALID_HANDLE || g_hMA3 == INVALID_HANDLE) {
      Print("❌ Gösterge hatası!");
      return INIT_FAILED;
   }
   
   g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   Print("═══════════════════════════════════════════════════════════════════");
   Print("🎯 MİLYONER EA v10.0 - ULTIMATE VERSION");
   Print("═══════════════════════════════════════════════════════════════════");
   Print("📊 MA Dansı: MA", MA1_Period, " × MA", MA2_Period, " × MA", MA3_Period);
   Print("📊 MACD Sıfır: ", UseMACD ? "AÇIK" : "KAPALI");
   Print("📊 LR Slope: ", UseLR ? "AÇIK (min=" + DoubleToString(LR_MinSlope, 6) + ")" : "KAPALI");
   Print("📊 ADX: ", UseADX ? ">"+IntegerToString(ADX_Min) : "KAPALI");
   Print("📊 RSI: ", UseRSI ? IntegerToString(RSI_OS)+"-"+IntegerToString(RSI_OB) : "KAPALI");
   Print("📊 ATR SL×", ATR_SL_Multi, " TP×", ATR_TP_Multi);
   Print("📊 BE: ", UseBreakeven ? "ON" : "OFF", " | Trail: ", UseTrailing ? "ON" : "OFF");
   Print("═══════════════════════════════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason) {
   IndicatorRelease(g_hMA1); IndicatorRelease(g_hMA2); IndicatorRelease(g_hMA3);
   IndicatorRelease(g_hMACD); IndicatorRelease(g_hADX); IndicatorRelease(g_hRSI);
   IndicatorRelease(g_hATR);
   
   double pf = g_grossLoss != 0 ? g_grossProfit / MathAbs(g_grossLoss) : 0;
   double wr = g_totalTrades > 0 ? g_winTrades * 100.0 / g_totalTrades : 0;
   double exp = CalculateExpectancy();
   
   Print("═══════════════════════════════════════════════════════════════════");
   Print("📊 v10 SONUÇLAR");
   Print("═══════════════════════════════════════════════════════════════════");
   Print("📈 Toplam: ", g_totalTrades, " | Kazanan: ", g_winTrades);
   Print("📈 WinRate: ", DoubleToString(wr, 1), "%");
   Print("⚖️ Profit Factor: ", DoubleToString(pf, 2));
   Print("💰 Net Kar: $", DoubleToString(g_netProfit, 2));
   Print("📊 Expectancy: $", DoubleToString(exp, 2), " / işlem");
   Print("💵 Avg Win: $", DoubleToString(g_avgWin, 2), " | Avg Loss: $", DoubleToString(g_avgLoss, 2));
   Print("═══════════════════════════════════════════════════════════════════");
   
   ObjectsDeleteAll(0, "MIL_");
}

//====================================================================
// OnTick
//====================================================================
void OnTick() {
   UpdateATR();
   
   // Günlük Reset
   MqlDateTime dt;
   TimeCurrent(dt);
   datetime today = StringToTime(IntegerToString(dt.year) + "." + IntegerToString(dt.mon) + "." + IntegerToString(dt.day));
   if(g_lastDay != today) {
      g_lastDay = today;
      g_dailyTradeCount = 0;
      g_dayStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   }
   
   // Günlük DD Kontrolü
   double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
   double dailyDD = (g_dayStartBalance - currentBalance) / g_dayStartBalance * 100.0;
   if(dailyDD >= MaxDailyDDPct) {
      g_state = "⛔ GÜNLÜK DD LİMİTİ";
      return;
   }
   
   // Günlük İşlem Limiti
   if(g_dailyTradeCount >= MaxDailyTrades) {
      g_state = "⛔ GÜNLÜK İŞLEM LİMİTİ";
      return;
   }
   
   // Spread Kontrolü
   if(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0 > MaxSpreadPips) {
      g_state = "⚠️ SPREAD YÜKSEK";
      return;
   }
   
   // Pozisyon Yönetimi (BE + Trailing)
   ManageOpenPositions();
   
   // Manuel İşlem Yönetimi
   if(ManageManualTrades) {
      ManageManualPositions();
   }
   
   // Bekleyen Emir Yönetimi
   ManagePendingOrders();
   
   // Yeni Bar Kontrolü
   datetime currentBar = iTime(_Symbol, TF, 0);
   if(g_lastBarTime != currentBar) {
      g_lastBarTime = currentBar;
      g_barsSinceTrade++;
      g_signalGivenThisBar = false;
   }
   
   // Pozisyon Varsa Çık
   if(HasOpenPosition()) {
      g_state = "📊 POZİSYON AÇIK";
      return;
   }
   
   // Cooldown
   if(g_barsSinceTrade < CooldownBars) {
      g_state = "⏳ COOLDOWN (" + IntegerToString(g_barsSinceTrade) + "/" + IntegerToString(CooldownBars) + ")";
      return;
   }
   
   // Bu Bar'da Sinyal Verildiyse Çık
   if(g_signalGivenThisBar) {
      g_state = "⏳ BAR BEKLENİYOR";
      return;
   }
   
   // Sinyal Al
   int signal = GetSignal();
   
   if(signal != 0) {
      ENUM_ORDER_TYPE orderType = (signal == 1) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
      
      if(EntryMode == MODE_MARKET || EntryMode == MODE_BOTH) {
         OpenMarketOrder(orderType);
      }
      if(EntryMode == MODE_PENDING || EntryMode == MODE_BOTH) {
         PlacePendingOrder(signal);
      }
      
      g_signalGivenThisBar = true;
      g_barsSinceTrade = 0;
      g_dailyTradeCount++;
   }
}

//====================================================================
// v10: ULTIMATE SİNYAL SİSTEMİ
// MA1 × MA2 × MA3 Kesişim + MACD Sıfır + LR Slope + ADX + RSI
//====================================================================
int GetSignal() {
   //=== 1. ÜÇLÜ MA VERİLERİ ===
   double ma1[], ma2[], ma3[];
   ArraySetAsSeries(ma1, true); ArraySetAsSeries(ma2, true); ArraySetAsSeries(ma3, true);
   ArrayResize(ma1, 3); ArrayResize(ma2, 3); ArrayResize(ma3, 3);
   
   if(CopyBuffer(g_hMA1, 0, 0, 3, ma1) < 3) return 0;
   if(CopyBuffer(g_hMA2, 0, 0, 3, ma2) < 3) return 0;
   if(CopyBuffer(g_hMA3, 0, 0, 3, ma3) < 3) return 0;
   
   //=== 2. MA DANSI - KESİŞİM TESPİTİ ===
   // MA1 MA2'yi yukarı kesiyor (Golden Cross)
   bool ma1CrossUpMa2 = (ma1[2] <= ma2[2]) && (ma1[1] > ma2[1]);
   // MA1 MA2'yi aşağı kesiyor (Death Cross)
   bool ma1CrossDownMa2 = (ma1[2] >= ma2[2]) && (ma1[1] < ma2[1]);
   
   // MA3 üzerinde mi altında mı (Ana Trend)
   bool aboveMA3 = (ma1[0] > ma3[0]) && (ma2[0] > ma3[0]);
   bool belowMA3 = (ma1[0] < ma3[0]) && (ma2[0] < ma3[0]);
   
   // Sıralama: MA1 > MA2 > MA3 (Uptrend) veya MA1 < MA2 < MA3 (Downtrend)
   bool perfectUpOrder = (ma1[0] > ma2[0]) && (ma2[0] > ma3[0]);
   bool perfectDownOrder = (ma1[0] < ma2[0]) && (ma2[0] < ma3[0]);
   
   // Sinyal koşulu: Cross + MA3 yönünde
   bool buySetup = ma1CrossUpMa2 && aboveMA3;
   bool sellSetup = ma1CrossDownMa2 && belowMA3;
   
   if(!buySetup && !sellSetup) {
      g_state = "⏳ MA KESİŞİM BEKLENİYOR";
      return 0;
   }
   
   //=== 3. MACD SIFIR ÇİZGİSİ ===
   if(UseMACD) {
      double hist[];
      ArraySetAsSeries(hist, true);
      ArrayResize(hist, 2);
      if(CopyBuffer(g_hMACD, 2, 0, 2, hist) < 2) return 0;
      
      if(MACDAboveZero) {
         // BUY: Histogram > 0
         if(buySetup && hist[0] <= 0) {
            g_state = "⏳ MACD < 0";
            return 0;
         }
         // SELL: Histogram < 0
         if(sellSetup && hist[0] >= 0) {
            g_state = "⏳ MACD > 0";
            return 0;
         }
      }
   }
   
   //=== 4. LINEAR REGRESSION SLOPE ===
   if(UseLR) {
      double slope = CalculateLRSlope();
      
      if(buySetup && slope < LR_MinSlope) {
         g_state = "⏳ LR SLOPE DÜŞÜK";
         return 0;
      }
      if(sellSetup && slope > -LR_MinSlope) {
         g_state = "⏳ LR SLOPE DÜŞÜK";
         return 0;
      }
   }
   
   //=== 5. ADX FİLTRESİ ===
   if(UseADX) {
      double adx[];
      ArraySetAsSeries(adx, true);
      ArrayResize(adx, 1);
      if(CopyBuffer(g_hADX, 0, 0, 1, adx) < 1) return 0;
      
      if(adx[0] < ADX_Min) {
         g_state = "⏳ ADX < " + IntegerToString(ADX_Min);
         return 0;
      }
   }
   
   //=== 6. RSI FİLTRESİ ===
   if(UseRSI) {
      double rsi[];
      ArraySetAsSeries(rsi, true);
      ArrayResize(rsi, 1);
      if(CopyBuffer(g_hRSI, 0, 0, 1, rsi) < 1) return 0;
      
      if(buySetup && rsi[0] > RSI_OB) {
         g_state = "⏳ RSI > " + IntegerToString(RSI_OB);
         return 0;
      }
      if(sellSetup && rsi[0] < RSI_OS) {
         g_state = "⏳ RSI < " + IntegerToString(RSI_OS);
         return 0;
      }
   }
   
   //=== 7. FİNAL SİNYAL ===
   if(buySetup) {
      g_state = "🟢 BUY SİNYAL!";
      Print("════════════════════════════════════════════════════════════");
      Print("✅ v10 BUY SİNYALİ:");
      Print("   📊 MA", MA1_Period, " × MA", MA2_Period, " = Golden Cross");
      Print("   📊 MA3(", MA3_Period, ") üzerinde");
      Print("   📊 MACD Histogram > 0");
      Print("   📊 LR Slope: Pozitif");
      Print("════════════════════════════════════════════════════════════");
      return 1;
   }
   
   if(sellSetup) {
      g_state = "🔴 SELL SİNYAL!";
      Print("════════════════════════════════════════════════════════════");
      Print("✅ v10 SELL SİNYALİ:");
      Print("   📊 MA", MA1_Period, " × MA", MA2_Period, " = Death Cross");
      Print("   📊 MA3(", MA3_Period, ") altında");
      Print("   📊 MACD Histogram < 0");
      Print("   📊 LR Slope: Negatif");
      Print("════════════════════════════════════════════════════════════");
      return -1;
   }
   
   return 0;
}

//====================================================================
// PİYASA EMRİ AÇ
//====================================================================
void OpenMarketOrder(ENUM_ORDER_TYPE orderType) {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   
   double slDist, tpDist;
   GetDynamicSLTP(slDist, tpDist);
   
   double slPips = Pt2Pip(slDist);
   double lot = CalculateOptimalLot(slPips);
   
   double price, sl, tp;
   
   if(orderType == ORDER_TYPE_BUY) {
      price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      sl = NormalizeDouble(price - slDist, digits);
      tp = NormalizeDouble(price + tpDist, digits);
      m_trade.Buy(lot, _Symbol, 0, sl, tp, TradeComment);
   } else {
      price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      sl = NormalizeDouble(price + slDist, digits);
      tp = NormalizeDouble(price - tpDist, digits);
      m_trade.Sell(lot, _Symbol, 0, sl, tp, TradeComment);
   }
   
   if(m_trade.ResultRetcode() == TRADE_RETCODE_DONE) {
      g_totalTrades++;
      double rr = tpDist / slDist;
      Print("════════════════════════════════════════════════════════════");
      Print("✅ ", (orderType == ORDER_TYPE_BUY ? "BUY" : "SELL"), " AÇILDI");
      Print("   💰 Lot: ", DoubleToString(lot, 2), " | Risk: ", DoubleToString(RiskPercent, 1), "%");
      Print("   🛑 SL: ", DoubleToString(slPips, 1), " pips");
      Print("   🎯 TP: ", DoubleToString(Pt2Pip(tpDist), 1), " pips");
      Print("   ⚖️ R:R = 1:", DoubleToString(rr, 2));
      Print("════════════════════════════════════════════════════════════");
   }
}

//====================================================================
// BEKLEYEN EMİR YERLEŞTİR
//====================================================================
void PlacePendingOrder(int direction) {
   if(HasPendingOrder()) return;
   
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double pendDist = Pip2Pt(PendingPips);
   
   double slDist, tpDist;
   GetDynamicSLTP(slDist, tpDist);
   
   double slPips = Pt2Pip(slDist);
   double lot = CalculateOptimalLot(slPips);
   
   double orderPrice, sl, tp;
   ENUM_ORDER_TYPE orderType;
   
   if(direction == 1) {
      orderType = ORDER_TYPE_BUY_STOP;
      orderPrice = NormalizeDouble(ask + pendDist, digits);
      sl = NormalizeDouble(orderPrice - slDist, digits);
      tp = NormalizeDouble(orderPrice + tpDist, digits);
   } else {
      orderType = ORDER_TYPE_SELL_STOP;
      orderPrice = NormalizeDouble(bid - pendDist, digits);
      sl = NormalizeDouble(orderPrice + slDist, digits);
      tp = NormalizeDouble(orderPrice - tpDist, digits);
   }
   
   if(m_trade.OrderOpen(_Symbol, orderType, lot, 0, orderPrice, sl, tp, ORDER_TIME_GTC, 0, TradeComment)) {
      Print("📋 BEKLEYEN EMİR: ", (direction == 1 ? "BUY_STOP" : "SELL_STOP"), " @ ", DoubleToString(orderPrice, digits));
   }
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
      
      datetime placeTime = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
      int barsPassed = (int)((TimeCurrent() - placeTime) / PeriodSeconds(TF));
      
      if(barsPassed >= PendingExpireBars) {
         m_trade.OrderDelete(ticket);
         Print("⏰ Bekleyen emir süresi doldu: #", ticket);
      }
   }
}

//====================================================================
// BREAKEVEN + TRAILING YÖNETİMİ
//====================================================================
void ManageOpenPositions() {
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
         double beTrigger = tpDist * (BE_TriggerPct / 100.0);
         
         if(profitDist >= beTrigger) {
            double bePrice;
            if(posType == POSITION_TYPE_BUY) {
               bePrice = NormalizeDouble(openPrice + Pip2Pt(BE_LockPips), digits);
               if(currentSL < bePrice) {
                  m_trade.PositionModify(ticket, bePrice, currentTP);
                  Print("🔒 BREAKEVEN: SL → ", DoubleToString(bePrice, digits));
               }
            } else {
               bePrice = NormalizeDouble(openPrice - Pip2Pt(BE_LockPips), digits);
               if(currentSL > bePrice || currentSL == 0) {
                  m_trade.PositionModify(ticket, bePrice, currentTP);
                  Print("🔒 BREAKEVEN: SL → ", DoubleToString(bePrice, digits));
               }
            }
         }
      }
      
      //=== TRAILING STOP ===
      if(UseTrailing && g_lastATR > 0) {
         double trailTrigger = tpDist * (Trail_StartPct / 100.0);
         double trailDist = g_lastATR * Trail_ATR_Multi;
         
         if(profitDist >= trailTrigger) {
            double newSL;
            if(posType == POSITION_TYPE_BUY) {
               newSL = NormalizeDouble(currentPrice - trailDist, digits);
               if(newSL > currentSL) {
                  m_trade.PositionModify(ticket, newSL, currentTP);
                  Print("📈 TRAILING: SL → ", DoubleToString(newSL, digits));
               }
            } else {
               newSL = NormalizeDouble(currentPrice + trailDist, digits);
               if(newSL < currentSL || currentSL == 0) {
                  m_trade.PositionModify(ticket, newSL, currentTP);
                  Print("📉 TRAILING: SL → ", DoubleToString(newSL, digits));
               }
            }
         }
      }
   }
}

//====================================================================
// MANUEL İŞLEM YÖNETİMİ
// MagicNumber = 0 veya farklı olan işlemler
//====================================================================
void ManageManualPositions() {
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      // EA'ın kendi işlemlerini atla
      if(PositionGetInteger(POSITION_MAGIC) == MagicNumber) continue;
      
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);
      long posType = PositionGetInteger(POSITION_TYPE);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      //=== SL/TP YOKSA EKLE ===
      if(AddSLTPToManual && (currentSL == 0 || currentTP == 0)) {
         double slDist, tpDist;
         GetDynamicSLTP(slDist, tpDist);
         
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
            m_trade.PositionModify(ticket, newSL, newTP);
            Print("🛠️ MANUEL İŞLEM: SL/TP eklendi #", ticket);
            Print("   🛑 SL: ", DoubleToString(newSL, digits), " | 🎯 TP: ", DoubleToString(newTP, digits));
         }
         
         // Güncelle
         currentSL = newSL;
         currentTP = newTP;
      }
      
      // TP yoksa diğer yönetim yapma
      if(currentTP == 0) continue;
      
      double tpDist = MathAbs(currentTP - openPrice);
      double profitDist = (posType == POSITION_TYPE_BUY) ? 
         (currentPrice - openPrice) : (openPrice - currentPrice);
      
      //=== BREAKEVEN ===
      if(ApplyBEToManual && UseBreakeven) {
         double beTrigger = tpDist * (BE_TriggerPct / 100.0);
         
         if(profitDist >= beTrigger) {
            double bePrice;
            if(posType == POSITION_TYPE_BUY) {
               bePrice = NormalizeDouble(openPrice + Pip2Pt(BE_LockPips), digits);
               if(currentSL < bePrice) {
                  m_trade.PositionModify(ticket, bePrice, currentTP);
                  Print("🔒 MANUEL BE: SL → ", DoubleToString(bePrice, digits), " #", ticket);
               }
            } else {
               bePrice = NormalizeDouble(openPrice - Pip2Pt(BE_LockPips), digits);
               if(currentSL > bePrice || currentSL == 0) {
                  m_trade.PositionModify(ticket, bePrice, currentTP);
                  Print("🔒 MANUEL BE: SL → ", DoubleToString(bePrice, digits), " #", ticket);
               }
            }
         }
      }
      
      //=== TRAILING STOP ===
      if(ApplyTrailToManual && UseTrailing && g_lastATR > 0) {
         double trailTrigger = tpDist * (Trail_StartPct / 100.0);
         double trailDist = g_lastATR * Trail_ATR_Multi;
         
         if(profitDist >= trailTrigger) {
            double newSL;
            if(posType == POSITION_TYPE_BUY) {
               newSL = NormalizeDouble(currentPrice - trailDist, digits);
               if(newSL > currentSL) {
                  m_trade.PositionModify(ticket, newSL, currentTP);
                  Print("📈 MANUEL TRAIL: SL → ", DoubleToString(newSL, digits), " #", ticket);
               }
            } else {
               newSL = NormalizeDouble(currentPrice + trailDist, digits);
               if(newSL < currentSL || currentSL == 0) {
                  m_trade.PositionModify(ticket, newSL, currentTP);
                  Print("📉 MANUEL TRAIL: SL → ", DoubleToString(newSL, digits), " #", ticket);
               }
            }
         }
      }
   }
}

//====================================================================
// YARDIMCI FONKSİYONLAR
//====================================================================
void UpdateATR() {
   double atr[];
   ArraySetAsSeries(atr, true);
   ArrayResize(atr, 1);
   if(CopyBuffer(g_hATR, 0, 0, 1, atr) >= 1) {
      g_lastATR = atr[0];
   }
}

bool HasOpenPosition() {
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != MagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      return true;
   }
   return false;
}

bool HasPendingOrder() {
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0) continue;
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
      
      ulong dealTicket = trans.deal;
      if(dealTicket > 0 && HistoryDealSelect(dealTicket)) {
         double dealProfit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
         if(HistoryDealGetInteger(dealTicket, DEAL_MAGIC) == MagicNumber) {
            g_netProfit += dealProfit;
            if(dealProfit > 0) {
               g_winTrades++;
               g_grossProfit += dealProfit;
               Print("🎉 WIN: +$", DoubleToString(dealProfit, 2));
            } else {
               g_grossLoss += dealProfit;
               Print("💔 LOSS: $", DoubleToString(dealProfit, 2));
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
