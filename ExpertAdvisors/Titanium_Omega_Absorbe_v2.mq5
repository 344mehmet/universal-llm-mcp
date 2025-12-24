//+------------------------------------------------------------------+
//|                               Titanium_Omega_Absorbe_v2.mq5      |
//|                     © 2025, Systemic Trading Engineering         |
//|           ABSORBE v2 - GELİŞTİRİLMİŞ HEDGE + GRID                |
//+------------------------------------------------------------------+
//|  v2 GELİŞTİRMELER:                                               |
//|  ✅ Pozisyon Bazlı Stop Loss (Kayıp Sınırı)                      |
//|  ✅ Trailing Stop (Kârı Kilitle)                                  |
//|  ✅ Kısmi Kâr Alma (%50)                                          |
//|  ✅ Daha Akıllı Grid (ATR Bazlı)                                  |
//|  ✅ Zaman Filtresi (En İyi Saatler)                               |
//+------------------------------------------------------------------+
#property copyright "© 2025, Systemic Trading Engineering - ABSORBE v2"
#property version   "2.00"
#property strict
#property description "Titanium Omega ABSORBE v2 - Geliştirilmiş Hedge + Grid"

#include <Trade\Trade.mqh>

//====================================================================
// INPUT PARAMETRELERİ
//====================================================================

//--- 1. ANA AYARLAR
input group "═══════ 1. ANA AYARLAR ═══════"
input ulong    InpMagic           = 999888;     // 🔢 Magic Number
input string   InpComment         = "AbsorbeV2";// 💬 İşlem Yorumu
input bool     InpShowDashboard   = true;       // 📊 Bilgi Paneli

//--- 2. LOT AYARLARI
input group "═══════ 2. LOT AYARLARI ═══════"
input double   InpFixedLot        = 0.01;       // 📦 Sabit Lot (Tüm işlemler)
input int      InpMaxBuyOrders    = 5;          // 🔢 Max BUY Kademe Sayısı

//--- 3. GRID AYARLARI (OPTİMİZE)
input group "═══════ 3. GRID AYARLARI ═══════"
input int      InpGridStepPips    = 25;         // 📏 Kademe Aralığı (Pip) - Artırıldı
input int      InpTotalTP_Pips    = 40;         // 🎯 Toplam TP (Pip) - Artırıldı
input bool     InpUseATRGrid      = true;       // 📐 ATR Bazlı Grid (Dinamik)
input double   InpATRMultiplier   = 1.5;        // 📊 ATR Çarpanı

//--- 4. KAYIP SINIRI (YENİ!)
input group "═══════ 4. KAYIP SINIRI ═══════"
input bool     InpUseStopLoss     = true;       // 🛑 Pozisyon SL Kullan
input int      InpMaxLossPips     = 50;         // 📉 Max Kayıp (Pip) - Her kademe için
input double   InpMaxLossMoney    = 30.0;       // 💵 Max Kayıp ($) - Toplam pozisyon

//--- 5. TRAILING STOP (YENİ!)
input group "═══════ 5. TRAILING STOP ═══════"
input bool     InpUseTrailing     = true;       // 🏃 Trailing Stop Kullan
input int      InpTrailingStart   = 20;         // 🚀 Trailing Başlangıç (Pip)
input int      InpTrailingStep    = 10;         // 📏 Trailing Adım (Pip)

//--- 6. KISMİ KÂR ALMA (YENİ!)
input group "═══════ 6. KISMİ KÂR ═══════"
input bool     InpUsePartialClose = true;       // ✂️ Kısmi Kâr Kullan
input int      InpPartialPips     = 30;         // 🎯 Kısmi TP Tetikleme (Pip)
input double   InpPartialPercent  = 50.0;       // 📊 Kapatılacak % (Pozisyonun)

//--- 7. TREND FİLTRESİ (GELİŞTİRİLMİŞ)
input group "═══════ 7. TREND FİLTRESİ ═══════"
input int      InpTrendMA_Period  = 50;         // 📈 Trend MA Periyodu
input int      InpMinADX          = 20;         // 💪 Min ADX (Trend Gücü)
input bool     InpRequireRising   = true;       // 📈 MA Yükseliyor Olmalı

//--- 8. ZAMAN FİLTRESİ (YENİ!)
input group "═══════ 8. ZAMAN FİLTRESİ ═══════"
input bool     InpUseTimeFilter   = true;       // ⏰ Zaman Filtresi
input int      InpStartHour       = 8;          // 🌅 Başlangıç Saati
input int      InpEndHour         = 20;         // 🌆 Bitiş Saati

//--- 9. GÜVENLİK
input group "═══════ 9. GÜVENLİK ═══════"
input double   InpMaxDrawdown     = 25.0;       // 🛑 Max Drawdown % (Düşürüldü)
input int      InpMaxSpreadPips   = 4;          // 📊 Max Spread (Düşürüldü)

//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================
CTrade   m_trade;
string   g_StateReason = "🚀 BAŞLATILIYOR...";

// İndikatör Handle'ları
int      g_hTrendMA;
int      g_hADX;
int      g_hATR;

// Pozisyon Takibi
bool     g_hedgeSellOpen = false;
int      g_buyOrderCount = 0;
double   g_lastBuyPrice = 0;
double   g_startEquity = 0;
double   g_totalBuyVolume = 0;
double   g_avgBuyPrice = 0;

// İstatistikler
int      g_totalTrades = 0;
int      g_winTrades = 0;
double   g_totalProfit = 0;

//====================================================================
// HELPER FUNCTIONS
//====================================================================
double PipToPoints(int pips)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   return pips * 10.0 * point;
}

double GetATR()
{
   double atr[];
   ArraySetAsSeries(atr, true);
   if(CopyBuffer(g_hATR, 0, 0, 1, atr) < 1) return 0;
   return atr[0];
}

double GetDynamicGridStep()
{
   if(!InpUseATRGrid) return PipToPoints(InpGridStepPips);
   
   double atr = GetATR();
   if(atr <= 0) return PipToPoints(InpGridStepPips);
   
   double dynamicStep = atr * InpATRMultiplier;
   double minStep = PipToPoints(InpGridStepPips / 2);
   double maxStep = PipToPoints(InpGridStepPips * 2);
   
   return MathMax(minStep, MathMin(dynamicStep, maxStep));
}

//====================================================================
// SİGORTA SELL (HER ZAMAN AÇIK)
//====================================================================
bool OpenHedgeSell()
{
   if(g_hedgeSellOpen) return true;
   
   // Zaman kontrolü
   if(InpUseTimeFilter)
   {
      MqlDateTime dt;
      TimeCurrent(dt);
      if(dt.hour < InpStartHour || dt.hour >= InpEndHour) return false;
   }
   
   double sl = 0;
   double tp = 0;
   
   ResetLastError();
   if(m_trade.Sell(InpFixedLot, _Symbol, 0, sl, tp, InpComment + "_HEDGE"))
   {
      if(m_trade.ResultRetcode() == TRADE_RETCODE_DONE)
      {
         g_hedgeSellOpen = true;
         Print("🛡️ SİGORTA SELL AÇILDI | Lot: ", InpFixedLot);
         return true;
      }
   }
   Print("❌ SİGORTA SELL AÇILAMADI! RetCode: ", m_trade.ResultRetcode());
   return false;
}

//====================================================================
// TREND KONTROLÜ (GELİŞTİRİLMİŞ)
//====================================================================
int GetTrendDirection()
{
   double ma[], adx[];
   ArraySetAsSeries(ma, true);
   ArraySetAsSeries(adx, true);
   
   if(CopyBuffer(g_hTrendMA, 0, 0, 3, ma) < 3) return 0;
   if(CopyBuffer(g_hADX, 0, 0, 1, adx) < 1) return 0;
   
   if(adx[0] < InpMinADX)
   {
      g_StateReason = "📉 ADX DÜŞÜK: " + DoubleToString(adx[0], 0);
      return 0;
   }
   
   double price = iClose(_Symbol, PERIOD_CURRENT, 0);
   
   // MA üzerinde kontrol
   if(price > ma[0])
   {
      // MA yükseliyor mu?
      if(InpRequireRising && ma[0] <= ma[2])
      {
         g_StateReason = "📊 MA YATAY (Yükselmiyor)";
         return 0;
      }
      g_StateReason = "📈 TREND: YUKARI (ADX:" + DoubleToString(adx[0], 0) + ")";
      return 1;
   }
   else if(price < ma[0])
   {
      if(InpRequireRising && ma[0] >= ma[2])
      {
         g_StateReason = "📊 MA YATAY (Düşmüyor)";
         return 0;
      }
      g_StateReason = "📉 TREND: AŞAĞI (ADX:" + DoubleToString(adx[0], 0) + ")";
      return -1;
   }
   
   g_StateReason = "➡️ TREND: YATAY";
   return 0;
}

//====================================================================
// BUY KADEME AÇ (GELİŞTİRİLMİŞ)
//====================================================================
bool OpenBuyGrid()
{
   if(g_buyOrderCount >= InpMaxBuyOrders)
   {
      g_StateReason = "🔒 MAX KADEME: " + IntegerToString(g_buyOrderCount);
      return false;
   }
   
   // Zaman kontrolü
   if(InpUseTimeFilter)
   {
      MqlDateTime dt;
      TimeCurrent(dt);
      if(dt.hour < InpStartHour || dt.hour >= InpEndHour)
      {
         g_StateReason = "⏰ ZAMAN FİLTRESİ";
         return false;
      }
   }
   
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double gridStep = GetDynamicGridStep();
   
   // İlk BUY veya fiyat yeterince düştüyse
   if(g_buyOrderCount == 0 || currentPrice <= g_lastBuyPrice - gridStep)
   {
      // Stop Loss hesapla
      double sl = 0;
      if(InpUseStopLoss)
      {
         sl = currentPrice - PipToPoints(InpMaxLossPips);
         int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
         sl = NormalizeDouble(sl, digits);
      }
      
      ResetLastError();
      if(m_trade.Buy(InpFixedLot, _Symbol, 0, sl, 0, InpComment + "_BUY" + IntegerToString(g_buyOrderCount + 1)))
      {
         if(m_trade.ResultRetcode() == TRADE_RETCODE_DONE)
         {
            g_buyOrderCount++;
            g_lastBuyPrice = currentPrice;
            
            // Ortalama fiyat hesapla
            g_avgBuyPrice = ((g_avgBuyPrice * (g_buyOrderCount - 1)) + currentPrice) / g_buyOrderCount;
            g_totalBuyVolume += InpFixedLot;
            
            Print("🟢 BUY ", g_buyOrderCount, "/", InpMaxBuyOrders, " | Fiyat: ", DoubleToString(currentPrice, 5), 
                  " | Ort: ", DoubleToString(g_avgBuyPrice, 5));
            return true;
         }
      }
      Print("❌ BUY AÇILAMADI! RetCode: ", m_trade.ResultRetcode());
   }
   
   return false;
}

//====================================================================
// TRAILING STOP YÖNETİMİ
//====================================================================
void ManageTrailingStop()
{
   if(!InpUseTrailing) return;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      long type = PositionGetInteger(POSITION_TYPE);
      if(type != POSITION_TYPE_BUY) continue; // Sadece BUY'lara uygula
      
      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double curr = PositionGetDouble(POSITION_PRICE_CURRENT);
      double sl = PositionGetDouble(POSITION_SL);
      double tp = PositionGetDouble(POSITION_TP);
      
      double trailStart = PipToPoints(InpTrailingStart);
      double trailStep = PipToPoints(InpTrailingStep);
      
      // Kârda mı?
      if(curr - open > trailStart)
      {
         double newSL = curr - trailStart;
         if(newSL > sl + trailStep || sl == 0)
         {
            int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
            newSL = NormalizeDouble(newSL, digits);
            m_trade.PositionModify(ticket, newSL, tp);
         }
      }
   }
}

//====================================================================
// KISMİ KÂR ALMA
//====================================================================
void ManagePartialClose()
{
   if(!InpUsePartialClose) return;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      long type = PositionGetInteger(POSITION_TYPE);
      if(type != POSITION_TYPE_BUY) continue;
      
      double open = PositionGetDouble(POSITION_PRICE_OPEN);
      double curr = PositionGetDouble(POSITION_PRICE_CURRENT);
      double volume = PositionGetDouble(POSITION_VOLUME);
      
      double partialTrigger = PipToPoints(InpPartialPips);
      
      // Kısmi kâr tetiklendi mi?
      if(curr - open >= partialTrigger && volume > SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
      {
         double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
         double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
         double closeVol = MathFloor((volume * InpPartialPercent / 100.0) / lotStep) * lotStep;
         
         if(closeVol >= minLot && (volume - closeVol) >= minLot)
         {
            if(m_trade.PositionClosePartial(ticket, closeVol))
            {
               Print("✂️ KISMİ KÂR: ", DoubleToString(closeVol, 2), " lot kapatıldı");
            }
         }
      }
   }
}

//====================================================================
// TOPLAM KÂR KONTROLÜ
//====================================================================
bool CheckAndCloseProfitTarget()
{
   double totalProfit = 0;
   double buyProfit = 0;
   double sellProfit = 0;
   int buyCount = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      double profit = PositionGetDouble(POSITION_PROFIT);
      totalProfit += profit;
      
      long type = PositionGetInteger(POSITION_TYPE);
      if(type == POSITION_TYPE_BUY)
      {
         buyProfit += profit;
         buyCount++;
      }
      else
      {
         sellProfit += profit;
      }
   }
   
   // Hedef hesapla
   double targetProfit = InpTotalTP_Pips * 10 * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) * InpFixedLot * MathMax(buyCount, 1);
   
   if(totalProfit >= targetProfit && buyCount > 0)
   {
      Print("🎯 HEDEF KÂRA ULAŞILDI! +", DoubleToString(totalProfit, 2), " $ | Kapatılıyor...");
      
      g_totalTrades += buyCount + 1;
      g_winTrades++;
      g_totalProfit += totalProfit;
      
      // Tüm pozisyonları kapat
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket > 0 && PositionGetInteger(POSITION_MAGIC) == InpMagic && PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            m_trade.PositionClose(ticket);
         }
      }
      
      ResetCounters();
      return true;
   }
   
   // MAX KAYIP KONTROLÜ
   if(InpUseStopLoss && totalProfit <= -InpMaxLossMoney)
   {
      Print("🛑 MAX KAYIP! ", DoubleToString(totalProfit, 2), " $ | ACİL KAPATILIYOR...");
      
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket > 0 && PositionGetInteger(POSITION_MAGIC) == InpMagic && PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            m_trade.PositionClose(ticket);
         }
      }
      
      g_totalTrades += buyCount + 1;
      ResetCounters();
      return true;
   }
   
   return false;
}

//====================================================================
// SAYAÇLARI SIFIRLA
//====================================================================
void ResetCounters()
{
   g_hedgeSellOpen = false;
   g_buyOrderCount = 0;
   g_lastBuyPrice = 0;
   g_avgBuyPrice = 0;
   g_totalBuyVolume = 0;
}

//====================================================================
// DRAWDOWN KONTROLÜ
//====================================================================
bool CheckDrawdown()
{
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   if(g_startEquity > 0)
   {
      double dd = (g_startEquity - equity) / g_startEquity * 100.0;
      if(dd >= InpMaxDrawdown)
      {
         g_StateReason = "🛑 MAX DRAWDOWN: %" + DoubleToString(dd, 1);
         
         for(int i = PositionsTotal() - 1; i >= 0; i--)
         {
            ulong ticket = PositionGetTicket(i);
            if(ticket > 0 && PositionGetInteger(POSITION_MAGIC) == InpMagic)
            {
               m_trade.PositionClose(ticket);
            }
         }
         
         ResetCounters();
         return true;
      }
   }
   
   return false;
}

//====================================================================
// SPREAD KONTROLÜ
//====================================================================
bool IsSpreadOK()
{
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   double spreadPips = spread / 10.0;
   
   if(spreadPips > InpMaxSpreadPips)
   {
      g_StateReason = "📊 YÜKSEK SPREAD: " + DoubleToString(spreadPips, 1);
      return false;
   }
   return true;
}

//====================================================================
// POZİSYON SAYACI
//====================================================================
void CountPositions()
{
   g_hedgeSellOpen = false;
   g_buyOrderCount = 0;
   g_lastBuyPrice = 999999;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagic) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      long type = PositionGetInteger(POSITION_TYPE);
      if(type == POSITION_TYPE_SELL)
      {
         g_hedgeSellOpen = true;
      }
      else if(type == POSITION_TYPE_BUY)
      {
         g_buyOrderCount++;
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         if(openPrice < g_lastBuyPrice)
         {
            g_lastBuyPrice = openPrice;
         }
      }
   }
   
   if(g_lastBuyPrice == 999999) g_lastBuyPrice = 0;
}

//====================================================================
// DASHBOARD
//====================================================================
void UpdateDashboard()
{
   if(!InpShowDashboard) return;
   
   double totalProfit = 0;
   int totalPositions = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0 && PositionGetInteger(POSITION_MAGIC) == InpMagic && PositionGetString(POSITION_SYMBOL) == _Symbol)
      {
         totalProfit += PositionGetDouble(POSITION_PROFIT);
         totalPositions++;
      }
   }
   
   double atr = GetATR();
   double gridStep = GetDynamicGridStep() / SymbolInfoDouble(_Symbol, SYMBOL_POINT) / 10;
   
   string dash = "";
   dash += "╔═══════════════════════════════════════════════╗\n";
   dash += "║   🌀 TITANIUM ABSORBE v2.0 - GELİŞTİRİLMİŞ   ║\n";
   dash += "╠═══════════════════════════════════════════════╣\n";
   dash += "║ ℹ️  DURUM     : " + g_StateReason + "\n";
   dash += "╠═══════════════════════════════════════════════╣\n";
   dash += "║ 🛡️  HEDGE SELL: " + (g_hedgeSellOpen ? "✅ AÇIK" : "⏳ BEKLİYOR") + "\n";
   dash += "║ 📊 BUY KADEME: " + IntegerToString(g_buyOrderCount) + "/" + IntegerToString(InpMaxBuyOrders) + "\n";
   dash += "║ 💰 TOPLAM P/L: " + (totalProfit >= 0 ? "+" : "") + DoubleToString(totalProfit, 2) + " $\n";
   dash += "╠═══════════════════════════════════════════════╣\n";
   dash += "║ 📏 KADEME    : " + DoubleToString(gridStep, 1) + " pip (ATR: " + DoubleToString(atr*10000, 0) + ")\n";
   dash += "║ 🎯 HEDEF TP  : " + IntegerToString(InpTotalTP_Pips) + " pip\n";
   dash += "║ 🛑 MAX KAYIP : -" + DoubleToString(InpMaxLossMoney, 0) + " $\n";
   dash += "╠═══════════════════════════════════════════════╣\n";
   dash += "║ 📈 TOPLAM    : " + IntegerToString(g_totalTrades) + " işlem | W: " + IntegerToString(g_winTrades) + "\n";
   dash += "╚═══════════════════════════════════════════════╝";
   
   Comment(dash);
}

//====================================================================
// OnInit
//====================================================================
int OnInit()
{
   g_hTrendMA = iMA(_Symbol, PERIOD_CURRENT, InpTrendMA_Period, 0, MODE_EMA, PRICE_CLOSE);
   g_hADX = iADX(_Symbol, PERIOD_CURRENT, 14);
   g_hATR = iATR(_Symbol, PERIOD_CURRENT, 14);
   
   if(g_hTrendMA == INVALID_HANDLE || g_hADX == INVALID_HANDLE || g_hATR == INVALID_HANDLE)
   {
      Alert("❌ Göstergeler yüklenemedi!");
      return INIT_FAILED;
   }
   
   m_trade.SetExpertMagicNumber(InpMagic);
   m_trade.SetDeviationInPoints(20);
   
   g_startEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   CountPositions();
   
   Print("═══════════════════════════════════════════════");
   Print("🌀 TITANIUM ABSORBE v2.0 BAŞLATILDI 🌀");
   Print("═══════════════════════════════════════════════");
   Print("📦 Lot: ", InpFixedLot, " | Max Kademe: ", InpMaxBuyOrders);
   Print("📏 Grid: ", InpGridStepPips, " pip | ATR:", InpUseATRGrid ? "AÇIK" : "KAPALI");
   Print("🎯 TP: ", InpTotalTP_Pips, " pip | Max Kayıp: -$", InpMaxLossMoney);
   Print("🏃 Trailing: ", InpUseTrailing ? "AÇIK" : "KAPALI");
   Print("✂️ Kısmi Kâr: ", InpUsePartialClose ? "AÇIK" : "KAPALI");
   Print("═══════════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}

//====================================================================
// OnDeinit
//====================================================================
void OnDeinit(const int reason)
{
   if(g_hTrendMA != INVALID_HANDLE) IndicatorRelease(g_hTrendMA);
   if(g_hADX != INVALID_HANDLE) IndicatorRelease(g_hADX);
   if(g_hATR != INVALID_HANDLE) IndicatorRelease(g_hATR);
   
   if(g_totalTrades > 0)
   {
      Print("═══ ABSORBE v2 ÖZET ═══");
      Print("Toplam: ", g_totalTrades, " | Kazanç: ", g_winTrades);
      Print("Kâr: $", DoubleToString(g_totalProfit, 2));
      Print("═══════════════════════");
   }
   
   Comment("");
}

//====================================================================
// OnTick
//====================================================================
void OnTick()
{
   CountPositions();
   
   if(CheckDrawdown())
   {
      UpdateDashboard();
      return;
   }
   
   if(CheckAndCloseProfitTarget())
   {
      UpdateDashboard();
      return;
   }
   
   if(!IsSpreadOK())
   {
      UpdateDashboard();
      return;
   }
   
   // Trailing Stop yönet
   ManageTrailingStop();
   
   // Kısmi kâr yönet
   ManagePartialClose();
   
   // Sigorta SELL
   if(!g_hedgeSellOpen)
   {
      OpenHedgeSell();
   }
   
   // Trend kontrolü
   int trend = GetTrendDirection();
   
   // Trend yukarı ise BUY kademe aç
   if(trend == 1)
   {
      OpenBuyGrid();
   }
   
   UpdateDashboard();
}

//====================================================================
// OnTester
//====================================================================
double OnTester()
{
   double netProfit = TesterStatistics(STAT_PROFIT);
   double totalTrades = TesterStatistics(STAT_TRADES);
   double profitFactor = TesterStatistics(STAT_PROFIT_FACTOR);
   double maxDD = TesterStatistics(STAT_BALANCE_DD_RELATIVE);
   
   if(totalTrades < 10) return 0;
   if(netProfit < 0) return 0;
   
   // Robust Score
   double score = (netProfit * profitFactor * MathSqrt(totalTrades)) / (1 + maxDD);
   
   Print("🌀 ABSORBE v2 SCORE: ", DoubleToString(score, 2));
   return score;
}
