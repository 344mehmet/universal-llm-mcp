//+------------------------------------------------------------------+
//|                                 Titanium_Omega_Absorbe.mq5       |
//|                     © 2025, Systemic Trading Engineering         |
//|           ABSORBE EDITION - HEDGE + GRID STRATEGY                |
//+------------------------------------------------------------------+
//|  STRATEJİ MANTIĞI:                                               |
//|  ✅ SELL = SİGORTA (Her zaman 0.01 lot açık)                     |
//|  ✅ Trend YUKARI ise → Sıralı 5 BUY (Grid Absorbe)               |
//|  ✅ Büyük düşüşler kademeli alımlarla emilir                     |
//|  ✅ Tüm pozisyon kâra geçince kapatılır                          |
//+------------------------------------------------------------------+
#property copyright "© 2025, Systemic Trading Engineering - ABSORBE"
#property version   "1.00"
#property strict
#property description "Titanium Omega ABSORBE - Hedge + Grid Absorbe Stratejisi"

#include <Trade\Trade.mqh>

//====================================================================
// INPUT PARAMETRELERİ
//====================================================================

//--- 1. ANA AYARLAR
input group "═══════ 1. ANA AYARLAR ═══════"
input ulong    InpMagic           = 888888;     // 🔢 Magic Number
input string   InpComment         = "Absorbe";  // 💬 İşlem Yorumu
input bool     InpShowDashboard   = true;       // 📊 Bilgi Paneli

//--- 2. LOT AYARLARI
input group "═══════ 2. LOT AYARLARI ═══════"
input double   InpFixedLot        = 0.01;       // 📦 Sabit Lot (Tüm işlemler)
input int      InpMaxBuyOrders    = 5;          // 🔢 Max BUY Kademe Sayısı

//--- 3. GRID AYARLARI
input group "═══════ 3. GRID (KADEME) AYARLARI ═══════"
input int      InpGridStepPips    = 20;         // 📏 Kademe Aralığı (Pip)
input int      InpTotalTP_Pips    = 30;         // 🎯 Toplam TP (Pip) - Tüm pozisyon kâra geçince

//--- 4. TREND FİLTRESİ
input group "═══════ 4. TREND FİLTRESİ ═══════"
input int      InpTrendMA_Period  = 50;         // 📈 Trend MA Periyodu
input int      InpMinADX          = 20;         // 💪 Min ADX (Trend Gücü)

//--- 5. GÜVENLİK
input group "═══════ 5. GÜVENLİK ═══════"
input double   InpMaxDrawdown     = 30.0;       // 🛑 Max Drawdown %
input int      InpMaxSpreadPips   = 5;          // 📊 Max Spread (Pip)

//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================
CTrade   m_trade;
string   g_StateReason = "🚀 BAŞLATILIYOR...";

// İndikatör Handle'ları
int      g_hTrendMA;
int      g_hADX;

// Pozisyon Takibi
bool     g_hedgeSellOpen = false;      // Sigorta SELL açık mı?
int      g_buyOrderCount = 0;          // Açık BUY sayısı
double   g_lastBuyPrice = 0;           // Son BUY fiyatı
double   g_startEquity = 0;            // Başlangıç equity

//====================================================================
// HELPER FUNCTIONS
//====================================================================
double PipToPoints(int pips)
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   return pips * 10.0 * point;
}

//====================================================================
// SİGORTA SELL (HER ZAMAN AÇIK)
//====================================================================
bool OpenHedgeSell()
{
   if(g_hedgeSellOpen) return true; // Zaten açık
   
   double sl = 0; // SL yok - bu sigorta
   double tp = 0; // TP yok - manuel kapatılacak
   
   ResetLastError();
   if(m_trade.Sell(InpFixedLot, _Symbol, 0, sl, tp, InpComment + "_HEDGE"))
   {
      if(m_trade.ResultRetcode() == TRADE_RETCODE_DONE)
      {
         g_hedgeSellOpen = true;
         Print("🛡️ SİGORTA SELL AÇILDI | Lot: ", InpFixedLot, " | Ticket: ", m_trade.ResultOrder());
         return true;
      }
   }
   Print("❌ SİGORTA SELL AÇILAMADI! RetCode: ", m_trade.ResultRetcode());
   return false;
}

//====================================================================
// TREND KONTROLÜ
//====================================================================
int GetTrendDirection()
{
   double ma[], adx[];
   ArraySetAsSeries(ma, true);
   ArraySetAsSeries(adx, true);
   
   if(CopyBuffer(g_hTrendMA, 0, 0, 2, ma) < 2) return 0;
   if(CopyBuffer(g_hADX, 0, 0, 1, adx) < 1) return 0;
   
   // ADX kontrolü
   if(adx[0] < InpMinADX)
   {
      g_StateReason = "📉 ADX DÜŞÜK: " + DoubleToString(adx[0], 0);
      return 0;
   }
   
   double price = iClose(_Symbol, PERIOD_CURRENT, 0);
   
   // MA üzerinde ve MA yükseliyor = YUKARI TREND
   if(price > ma[0] && ma[0] > ma[1])
   {
      g_StateReason = "📈 TREND: YUKARI (ADX:" + DoubleToString(adx[0], 0) + ")";
      return 1;
   }
   // MA altında ve MA düşüyor = AŞAĞI TREND
   else if(price < ma[0] && ma[0] < ma[1])
   {
      g_StateReason = "📉 TREND: AŞAĞI (ADX:" + DoubleToString(adx[0], 0) + ")";
      return -1;
   }
   
   g_StateReason = "➡️ TREND: YATAY";
   return 0;
}

//====================================================================
// BUY KADEME AÇ
//====================================================================
bool OpenBuyGrid()
{
   if(g_buyOrderCount >= InpMaxBuyOrders)
   {
      g_StateReason = "🔒 MAX KADEME: " + IntegerToString(g_buyOrderCount);
      return false;
   }
   
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double gridStep = PipToPoints(InpGridStepPips);
   
   // İlk BUY veya fiyat yeterince düştüyse yeni kademe aç
   if(g_buyOrderCount == 0 || currentPrice <= g_lastBuyPrice - gridStep)
   {
      double sl = 0; // SL yok - toplam TP ile kapatılacak
      double tp = 0; // TP yok - toplam TP ile kapatılacak
      
      ResetLastError();
      if(m_trade.Buy(InpFixedLot, _Symbol, 0, sl, tp, InpComment + "_BUY" + IntegerToString(g_buyOrderCount + 1)))
      {
         if(m_trade.ResultRetcode() == TRADE_RETCODE_DONE)
         {
            g_buyOrderCount++;
            g_lastBuyPrice = currentPrice;
            Print("🟢 BUY KADEME ", g_buyOrderCount, " AÇILDI | Fiyat: ", DoubleToString(currentPrice, 5), " | Lot: ", InpFixedLot);
            return true;
         }
      }
      Print("❌ BUY AÇILAMADI! RetCode: ", m_trade.ResultRetcode());
   }
   
   return false;
}

//====================================================================
// TOPLAM KÂR KONTROLÜ VE KAPATMA
//====================================================================
bool CheckAndCloseProfitTarget()
{
   double totalProfit = 0;
   double totalBuyProfit = 0;
   double hedgeSellProfit = 0;
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
         totalBuyProfit += profit;
         buyCount++;
      }
      else if(type == POSITION_TYPE_SELL)
      {
         hedgeSellProfit += profit;
      }
   }
   
   // Hedef kâr hesapla (pip bazlı)
   double targetProfit = InpTotalTP_Pips * 10 * SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) * InpFixedLot * (buyCount + 1);
   
   // Basit hedef: Toplam pozisyon kârda mı?
   if(totalProfit >= targetProfit && buyCount > 0)
   {
      Print("🎯 HEDEF KÂRA ULAŞILDI! Toplam: +", DoubleToString(totalProfit, 2), " $ | Kapatılıyor...");
      
      // Tüm pozisyonları kapat
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket > 0 && PositionGetInteger(POSITION_MAGIC) == InpMagic && PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            m_trade.PositionClose(ticket);
         }
      }
      
      // Sayaçları sıfırla
      g_hedgeSellOpen = false;
      g_buyOrderCount = 0;
      g_lastBuyPrice = 0;
      
      return true;
   }
   
   return false;
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
         
         // ACİL KAPAT
         for(int i = PositionsTotal() - 1; i >= 0; i--)
         {
            ulong ticket = PositionGetTicket(i);
            if(ticket > 0 && PositionGetInteger(POSITION_MAGIC) == InpMagic)
            {
               m_trade.PositionClose(ticket);
            }
         }
         
         g_hedgeSellOpen = false;
         g_buyOrderCount = 0;
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
         if(g_lastBuyPrice == 0 || openPrice < g_lastBuyPrice)
         {
            g_lastBuyPrice = openPrice;
         }
      }
   }
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
   
   string dash = "";
   dash += "╔═══════════════════════════════════════════╗\n";
   dash += "║   🌀 TITANIUM OMEGA ABSORBE 🌀           ║\n";
   dash += "╠═══════════════════════════════════════════╣\n";
   dash += "║ ℹ️  DURUM     : " + g_StateReason + "\n";
   dash += "╠═══════════════════════════════════════════╣\n";
   dash += "║ 🛡️  HEDGE SELL: " + (g_hedgeSellOpen ? "✅ AÇIK" : "❌ KAPALI") + "\n";
   dash += "║ 📊 BUY KADEME: " + IntegerToString(g_buyOrderCount) + "/" + IntegerToString(InpMaxBuyOrders) + "\n";
   dash += "║ 💰 TOPLAM P/L: " + (totalProfit >= 0 ? "+" : "") + DoubleToString(totalProfit, 2) + " $\n";
   dash += "╠═══════════════════════════════════════════╣\n";
   dash += "║ 📦 LOT       : " + DoubleToString(InpFixedLot, 2) + "\n";
   dash += "║ 📏 KADEME    : " + IntegerToString(InpGridStepPips) + " pip\n";
   dash += "║ 🎯 HEDEF TP  : " + IntegerToString(InpTotalTP_Pips) + " pip\n";
   dash += "╚═══════════════════════════════════════════╝";
   
   Comment(dash);
}

//====================================================================
// OnInit
//====================================================================
int OnInit()
{
   // İndikatörler
   g_hTrendMA = iMA(_Symbol, PERIOD_CURRENT, InpTrendMA_Period, 0, MODE_EMA, PRICE_CLOSE);
   g_hADX = iADX(_Symbol, PERIOD_CURRENT, 14);
   
   if(g_hTrendMA == INVALID_HANDLE || g_hADX == INVALID_HANDLE)
   {
      Alert("❌ Göstergeler yüklenemedi!");
      return INIT_FAILED;
   }
   
   // Trade ayarları
   m_trade.SetExpertMagicNumber(InpMagic);
   m_trade.SetDeviationInPoints(20);
   
   // Başlangıç equity
   g_startEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   
   // Mevcut pozisyonları say
   CountPositions();
   
   Print("═══════════════════════════════════════════");
   Print("🌀 TITANIUM OMEGA ABSORBE BAŞLATILDI 🌀");
   Print("═══════════════════════════════════════════");
   Print("📦 Lot: ", InpFixedLot);
   Print("🔢 Max Kademe: ", InpMaxBuyOrders);
   Print("📏 Kademe Aralığı: ", InpGridStepPips, " pip");
   Print("🎯 Toplam TP: ", InpTotalTP_Pips, " pip");
   Print("═══════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}

//====================================================================
// OnDeinit
//====================================================================
void OnDeinit(const int reason)
{
   if(g_hTrendMA != INVALID_HANDLE) IndicatorRelease(g_hTrendMA);
   if(g_hADX != INVALID_HANDLE) IndicatorRelease(g_hADX);
   
   Comment("");
}

//====================================================================
// OnTick
//====================================================================
void OnTick()
{
   // Pozisyonları say
   CountPositions();
   
   // Drawdown kontrolü
   if(CheckDrawdown())
   {
      UpdateDashboard();
      return;
   }
   
   // Toplam kâr kontrolü - Hedefe ulaşıldıysa kapat
   if(CheckAndCloseProfitTarget())
   {
      UpdateDashboard();
      return;
   }
   
   // Spread kontrolü
   if(!IsSpreadOK())
   {
      UpdateDashboard();
      return;
   }
   
   // === 1. SİGORTA SELL'İ KONTROL ET ===
   if(!g_hedgeSellOpen)
   {
      OpenHedgeSell();
   }
   
   // === 2. TREND KONTROLÜ ===
   int trend = GetTrendDirection();
   
   // === 3. TREND YUKARI İSE BUY KADEME AÇ ===
   if(trend == 1) // Trend yukarı
   {
      OpenBuyGrid();
   }
   
   // Dashboard güncelle
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
   
   double score = (netProfit * profitFactor) / (1 + maxDD / 10);
   
   Print("🌀 ABSORBE SCORE: ", DoubleToString(score, 2));
   return score;
}
