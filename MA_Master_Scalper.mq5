//+------------------------------------------------------------------+
//|                                         MA_Master_Scalper.mq5    |
//|                     © 2025, Milyoner EA Project                  |
//|                     HİPER-AGRESİF SCALPING SİSTEMİ               |
//+------------------------------------------------------------------+
//| UYARI: Bu EA, 10$ -> 1M$ ölçeklendirme hedeflidir.               |
//| Hesap kaybı riski ÇOK YÜKSEK. Demo hesapta test edin!            |
//+------------------------------------------------------------------+
#property copyright "© 2025, Milyoner EA Project"
#property link      "https://github.com/milyoner-ea"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// ENUM TANIMLARI
//====================================================================
enum ENUM_SCALP_MODE {
   MODE_CONSERVATIVE,    // Konservatif (Düşük Risk)
   MODE_AGGRESSIVE,      // Agresif (Orta Risk)
   MODE_ULTRA_AGGRESSIVE // Ultra Agresif (Maksimum Risk)
};

enum ENUM_ENTRY_FILTER {
   FILTER_STOCH_ONLY,    // Sadece Stokastik
   FILTER_BOTH,          // Stokastik + EMA Hizalama
   FILTER_NONE           // Filtre Yok (Sadece Cross)
};

//====================================================================
// INPUT PARAMETRELERİ - MİLYONER AYARLARI
//====================================================================

//--- 1. ANA AYARLAR
input group "═══ 1. ANA AYARLAR ═══"
input ulong    MagicNumber        = 777777;     // 🎰 Magic Number
input string   TradeComment       = "MILYONER"; // İşlem Yorumu
input ENUM_SCALP_MODE ScalpMode   = MODE_ULTRA_AGGRESSIVE; // ⚡ Scalping Modu
input bool     ShowStartupWarning = true;       // ⚠️ Başlangıç Uyarısı

//--- 2. EMA AYARLARI (9/21 - Scalping İçin Optimize)
input group "═══ 2. EMA SINYAL SİSTEMİ ═══"
input int      EMA_Fast_Period    = 9;          // 🔵 Hızlı EMA Periyodu
input int      EMA_Slow_Period    = 21;         // 🔴 Yavaş EMA Periyodu
input ENUM_APPLIED_PRICE EMA_Price = PRICE_CLOSE; // Fiyat Türü

//--- 3. STOKASTİK FİLTRE (Mean-Reversion)
input group "═══ 3. STOKASTİK FİLTRE ═══"
input bool     UseStochFilter     = true;       // ✅ Stokastik Filtre Kullan
input int      Stoch_K            = 14;         // %K Periyodu
input int      Stoch_D            = 3;          // %D Periyodu
input int      Stoch_Slowing      = 3;          // Yavaşlatma
input int      Stoch_Oversold     = 20;         // Aşırı Satım (<20)
input int      Stoch_Overbought   = 80;         // Aşırı Alım (>80)
input ENUM_ENTRY_FILTER EntryFilter = FILTER_BOTH; // Giriş Filtresi

//--- 4. MARTİNGALE RİSK YÖNETİMİ
input group "═══ 4. MARTİNGALE SİSTEMİ 🎲 ═══"
input bool     UseMartingale      = true;       // ✅ Martingale Kullan
input double   MartingaleMultiplier = 2.0;      // 📈 Kayıpta Çarpan (2x)
input int      MaxConsecutiveLoss = 3;          // ❌ Max Ardışık Kayıp
input bool     ResetOnWin         = true;       // ✅ Kazançta Sıfırla

//--- 5. FULL KELLY RİSK (AGRESİF)
input group "═══ 5. FULL KELLY RİSK 💰 ═══"
input double   KellyPercentage    = 25.0;       // 💸 Bakiye % (Kelly)
input double   BaseLot            = 0.01;       // Min Lot (Başlangıç)
input double   MaxLotSize         = 100.0;      // Max Lot Limiti
input bool     UseKellyLot        = true;       // Kelly Lot Hesaplama

//--- 6. SCALPING TP/SL (SIKI HEDEFLER)
input group "═══ 6. SCALPING TP/SL ═══"
input int      TP_Pips            = 5;          // 🎯 Take Profit (pip)
input int      SL_Pips            = 10;         // 🛑 Stop Loss (pip)
input bool     UseTrailingStop    = true;       // Trailing Stop
input int      TrailingStart      = 3;          // Trailing Başlangıç (pip)
input int      TrailingStep       = 2;          // Trailing Adım (pip)

//--- 7. SPREAD/SLİPPAGE KORUMA
input group "═══ 7. KORUMA SİSTEMLERİ ═══"
input int      MaxSpreadPips      = 3;          // 🚫 Max Spread (pip)
input int      MaxSlippage        = 5;          // Max Slippage (point)
input double   MaxDrawdownPercent = 50.0;       // Max Drawdown % (Durdurma)
input bool     CloseAllOnDrawdown = true;       // DD'de Tümünü Kapat

//--- 8. ZAMAN FİLTRESİ (OPSİYONEL)
input group "═══ 8. ZAMAN FİLTRESİ ═══"
input bool     UseTimeFilter      = false;      // Zaman Filtresi
input int      TradeStartHour     = 8;          // Başlangıç Saati
input int      TradeEndHour       = 20;         // Bitiş Saati

//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================
int      g_hEMA_Fast = INVALID_HANDLE;
int      g_hEMA_Slow = INVALID_HANDLE;
int      g_hStoch    = INVALID_HANDLE;

int      g_consecutiveLosses = 0;
int      g_consecutiveWins   = 0;
double   g_currentLot        = 0;
double   g_equityHigh        = 0;
double   g_maxDrawdownReached = 0;
datetime g_lastTradeTime     = 0;
int      g_totalTrades       = 0;
int      g_winTrades         = 0;
int      g_lossTrades        = 0;
double   g_totalProfit       = 0;
bool     g_isDrawdownPaused  = false;
string   g_currentState      = "BAŞLATILIYOR...";

CTrade   m_trade;

//====================================================================
// HELPER FONKSİYONLARI
//====================================================================
double PipsToPoints(int pips)
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
   if(ShowStartupWarning)
   {
      int result = MessageBox(
         "⚠️ YÜKSEK RİSK UYARISI ⚠️\n\n" +
         "Bu EA, 100.000x getiri hedefli HİPER-AGRESİF bir scalping sistemidir.\n\n" +
         "• Martingale sistemi kullanılıyor (" + DoubleToString(MartingaleMultiplier, 1) + "x)\n" +
         "• Full Kelly risk (" + DoubleToString(KellyPercentage, 0) + "% bakiye)\n" +
         "• Hesap patlaması istatistiksel olarak KAÇINILMAZDIR\n\n" +
         "Bu bir 'istatistiksel piyango bileti'dir!\n\n" +
         "DEVAM ETMEK İSTİYOR MUSUNUZ?",
         "🎰 MİLYONER EA - RİSK UYARISI",
         MB_YESNO | MB_ICONWARNING
      );
      
      if(result == IDNO)
      {
         Print("❌ Kullanıcı EA'yı iptal etti.");
         return INIT_FAILED;
      }
   }
   
   // Trade nesnesini ayarla
   m_trade.SetExpertMagicNumber(MagicNumber);
   m_trade.SetDeviationInPoints(MaxSlippage);
   m_trade.SetMarginMode();
   m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   // Göstergeleri yükle
   g_hEMA_Fast = iMA(_Symbol, PERIOD_CURRENT, EMA_Fast_Period, 0, MODE_EMA, EMA_Price);
   g_hEMA_Slow = iMA(_Symbol, PERIOD_CURRENT, EMA_Slow_Period, 0, MODE_EMA, EMA_Price);
   g_hStoch = iStochastic(_Symbol, PERIOD_CURRENT, Stoch_K, Stoch_D, Stoch_Slowing, MODE_SMA, STO_LOWHIGH);
   
   if(g_hEMA_Fast == INVALID_HANDLE || g_hEMA_Slow == INVALID_HANDLE || g_hStoch == INVALID_HANDLE)
   {
      Print("❌ Göstergeler yüklenemedi!");
      return INIT_FAILED;
   }
   
   // Başlangıç değerleri
   g_currentLot = BaseLot;
   g_equityHigh = AccountInfoDouble(ACCOUNT_EQUITY);
   g_consecutiveLosses = 0;
   g_consecutiveWins = 0;
   
   Print("═══════════════════════════════════════════════════════════");
   Print("🎰 MİLYONER EA v1.00 - BAŞLATILDI!");
   Print("═══════════════════════════════════════════════════════════");
   Print("📊 EMA: ", EMA_Fast_Period, "/", EMA_Slow_Period);
   Print("📈 Martingale: ", UseMartingale ? DoubleToString(MartingaleMultiplier, 1) + "x" : "KAPALI");
   Print("💰 Kelly: ", UseKellyLot ? DoubleToString(KellyPercentage, 0) + "%" : "KAPALI");
   Print("🎯 TP/SL: ", TP_Pips, "/", SL_Pips, " pips");
   Print("💵 Başlangıç Bakiye: $", DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2));
   Print("═══════════════════════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}

//====================================================================
// OnDeinit - EA KAPATMA
//====================================================================
void OnDeinit(const int reason)
{
   // Göstergeleri serbest bırak
   if(g_hEMA_Fast != INVALID_HANDLE) IndicatorRelease(g_hEMA_Fast);
   if(g_hEMA_Slow != INVALID_HANDLE) IndicatorRelease(g_hEMA_Slow);
   if(g_hStoch != INVALID_HANDLE) IndicatorRelease(g_hStoch);
   
   // İstatistikleri yazdır
   Print("═══════════════════════════════════════════════════════════");
   Print("🎰 MİLYONER EA - KAPATILDI");
   Print("═══════════════════════════════════════════════════════════");
   Print("📊 Toplam İşlem: ", g_totalTrades);
   Print("✅ Kazançlı: ", g_winTrades, " (", g_totalTrades > 0 ? DoubleToString((double)g_winTrades/g_totalTrades*100, 1) : "0", "%)");
   Print("❌ Kayıplı: ", g_lossTrades);
   Print("💰 Net Kâr: $", DoubleToString(g_totalProfit, 2));
   Print("📉 Max Drawdown: ", DoubleToString(g_maxDrawdownReached, 1), "%");
   Print("═══════════════════════════════════════════════════════════");
   
   // Dashboard'u temizle
   ObjectsDeleteAll(0, "MILYONER_");
}

//====================================================================
// OnTick - ANA DÖNGÜ
//====================================================================
void OnTick()
{
   // Dashboard güncelle
   UpdateDashboard();
   
   // Drawdown kontrolü
   if(CheckDrawdown())
   {
      g_currentState = "⛔ DRAWDOWN PAUSE";
      return;
   }
   
   // Mevcut pozisyonları yönet
   ManagePositions();
   
   // Spread kontrolü
   if(!CheckSpread())
   {
      g_currentState = "⏳ YÜKSEK SPREAD";
      return;
   }
   
   // Zaman filtresi
   if(UseTimeFilter && !IsTradeTime())
   {
      g_currentState = "⏰ SEANS DIŞI";
      return;
   }
   
   // Açık pozisyon varsa yeni işlem açma
   if(HasOpenPosition())
   {
      g_currentState = "📊 POZİSYON AKTİF";
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
      g_currentState = "⏳ SİNYAL BEKLENİYOR";
   }
}

//====================================================================
// SİNYAL MOTORU - EMA Cross + Stokastik
//====================================================================
int GetSignal()
{
   // EMA verileri - Dinamik dizi
   double emaFast[];
   double emaSlow[];
   ArrayResize(emaFast, 3);
   ArrayResize(emaSlow, 3);
   ArraySetAsSeries(emaFast, true);
   ArraySetAsSeries(emaSlow, true);
   
   if(CopyBuffer(g_hEMA_Fast, 0, 0, 3, emaFast) < 3) return 0;
   if(CopyBuffer(g_hEMA_Slow, 0, 0, 3, emaSlow) < 3) return 0;
   
   // EMA Cross tespiti
   bool goldenCross = (emaFast[2] <= emaSlow[2] && emaFast[1] > emaSlow[1]); // BUY
   bool deathCross  = (emaFast[2] >= emaSlow[2] && emaFast[1] < emaSlow[1]); // SELL
   
   // Stokastik verisi - Dinamik dizi
   double stochK[];
   double stochD[];
   ArrayResize(stochK, 2);
   ArrayResize(stochD, 2);
   ArraySetAsSeries(stochK, true);
   ArraySetAsSeries(stochD, true);
   
   if(CopyBuffer(g_hStoch, 0, 0, 2, stochK) < 2) return 0;
   if(CopyBuffer(g_hStoch, 1, 0, 2, stochD) < 2) return 0;
   
   // Filtre kontrolü
   bool stochOversold = (stochK[1] < Stoch_Oversold);
   bool stochOverbought = (stochK[1] > Stoch_Overbought);
   
   // Sinyal üret
   int signal = 0;
   
   if(goldenCross)
   {
      if(EntryFilter == FILTER_NONE)
      {
         signal = 1;
      }
      else if(EntryFilter == FILTER_STOCH_ONLY && stochOversold)
      {
         signal = 1;
      }
      else if(EntryFilter == FILTER_BOTH && stochOversold && emaFast[0] > emaSlow[0])
      {
         signal = 1;
      }
   }
   
   if(deathCross)
   {
      if(EntryFilter == FILTER_NONE)
      {
         signal = -1;
      }
      else if(EntryFilter == FILTER_STOCH_ONLY && stochOverbought)
      {
         signal = -1;
      }
      else if(EntryFilter == FILTER_BOTH && stochOverbought && emaFast[0] < emaSlow[0])
      {
         signal = -1;
      }
   }
   
   return signal;
}

//====================================================================
// LOT HESAPLAMA - Martingale + Kelly
//====================================================================
double CalculateLot()
{
   double lot = BaseLot;
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   
   // Kelly lot hesaplama
   if(UseKellyLot)
   {
      double kellyLot = (balance * KellyPercentage / 100.0) / (SL_Pips * 10);
      lot = MathMax(BaseLot, kellyLot);
   }
   
   // Martingale uygula
   if(UseMartingale && g_consecutiveLosses > 0)
   {
      for(int i = 0; i < g_consecutiveLosses; i++)
      {
         lot *= MartingaleMultiplier;
      }
      Print("🎲 Martingale Lot: ", DoubleToString(lot, 2), " (", g_consecutiveLosses, " kayıp sonrası)");
   }
   
   // Lot limitleri
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
      while(marginRequired > freeMargin * 0.9 && lot > minLot)
      {
         lot = MathFloor((lot / MartingaleMultiplier) / stepLot) * stepLot;
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
   
   double price, sl, tp;
   
   if(orderType == ORDER_TYPE_BUY)
   {
      price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      sl = NormalizeDouble(price - PipsToPoints(SL_Pips), digits);
      tp = NormalizeDouble(price + PipsToPoints(TP_Pips), digits);
   }
   else
   {
      price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      sl = NormalizeDouble(price + PipsToPoints(SL_Pips), digits);
      tp = NormalizeDouble(price - PipsToPoints(TP_Pips), digits);
   }
   
   string comment = TradeComment + "_" + IntegerToString(g_totalTrades + 1);
   
   bool success = false;
   ResetLastError();
   
   if(orderType == ORDER_TYPE_BUY)
   {
      success = m_trade.Buy(lot, _Symbol, 0, sl, tp, comment);
   }
   else
   {
      success = m_trade.Sell(lot, _Symbol, 0, sl, tp, comment);
   }
   
   if(success && m_trade.ResultRetcode() == TRADE_RETCODE_DONE)
   {
      g_totalTrades++;
      g_lastTradeTime = TimeCurrent();
      
      Print("═══════════════════════════════════════════════════════════");
      Print("🎰 MİLYONER: ", (orderType == ORDER_TYPE_BUY ? "BUY" : "SELL"), " AÇILDI!");
      Print("📊 Lot: ", DoubleToString(lot, 2));
      Print("💰 Entry: ", DoubleToString(price, digits));
      Print("🛑 SL: ", DoubleToString(sl, digits), " (", SL_Pips, " pips)");
      Print("🎯 TP: ", DoubleToString(tp, digits), " (", TP_Pips, " pips)");
      Print("🎟️ Ticket: ", m_trade.ResultOrder());
      Print("═══════════════════════════════════════════════════════════");
   }
   else
   {
      Print("❌ İşlem BAŞARISIZ! Hata: ", m_trade.ResultRetcode(), " - ", m_trade.ResultRetcodeDescription());
   }
}

//====================================================================
// POZİSYON YÖNETİMİ - Trailing Stop
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
      
      // Trailing Stop
      if(UseTrailingStop)
      {
         double trailStart = PipsToPoints(TrailingStart);
         double trailStep = PipsToPoints(TrailingStep);
         
         if(posType == POSITION_TYPE_BUY)
         {
            double profit = currentPrice - openPrice;
            if(profit >= trailStart)
            {
               double newSL = NormalizeDouble(currentPrice - trailStep, digits);
               if(newSL > currentSL)
               {
                  m_trade.PositionModify(ticket, newSL, currentTP);
               }
            }
         }
         else if(posType == POSITION_TYPE_SELL)
         {
            double profit = openPrice - currentPrice;
            if(profit >= trailStart)
            {
               double newSL = NormalizeDouble(currentPrice + trailStep, digits);
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
   {
      g_equityHigh = equity;
   }
   
   double drawdown = 0;
   if(g_equityHigh > 0)
   {
      drawdown = (g_equityHigh - equity) / g_equityHigh * 100.0;
   }
   
   if(drawdown > g_maxDrawdownReached)
   {
      g_maxDrawdownReached = drawdown;
   }
   
   if(drawdown >= MaxDrawdownPercent)
   {
      if(CloseAllOnDrawdown && !g_isDrawdownPaused)
      {
         Print("⛔ DRAWDOWN LİMİTİ AŞILDI! (", DoubleToString(drawdown, 1), "%)");
         Print("🔴 TÜM POZİSYONLAR KAPATILIYOR...");
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
// SPREAD KONTROLÜ
//====================================================================
bool CheckSpread()
{
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   double spreadPips = spread / 10.0;
   
   return (spreadPips <= MaxSpreadPips);
}

//====================================================================
// ZAMAN FİLTRESİ
//====================================================================
bool IsTradeTime()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   return (dt.hour >= TradeStartHour && dt.hour < TradeEndHour);
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
// OnTradeTransaction - İşlem Sonuçları
//====================================================================
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      if(trans.deal_type == DEAL_TYPE_BUY || trans.deal_type == DEAL_TYPE_SELL)
      {
         // Yeni işlem açıldı
         return;
      }
      
      // İşlem kapandı - sonucu kontrol et
      ulong dealTicket = trans.deal;
      if(dealTicket > 0)
      {
         if(HistoryDealSelect(dealTicket))
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
                  
                  if(ResetOnWin)
                  {
                     g_consecutiveLosses = 0;
                  }
                  
                  Print("═══════════════════════════════════════════════════════════");
                  Print("🎉 KAZANÇ! +$", DoubleToString(profit, 2));
                  Print("🔥 Ardışık Kazanç: ", g_consecutiveWins);
                  Print("💰 Toplam Kâr: $", DoubleToString(g_totalProfit, 2));
                  Print("═══════════════════════════════════════════════════════════");
               }
               else if(profit < 0)
               {
                  g_lossTrades++;
                  g_consecutiveLosses++;
                  g_consecutiveWins = 0;
                  
                  Print("═══════════════════════════════════════════════════════════");
                  Print("💔 KAYIP! $", DoubleToString(profit, 2));
                  Print("❌ Ardışık Kayıp: ", g_consecutiveLosses, "/", MaxConsecutiveLoss);
                  Print("💰 Toplam: $", DoubleToString(g_totalProfit, 2));
                  Print("═══════════════════════════════════════════════════════════");
                  
                  // Max kayıp kontrolü
                  if(g_consecutiveLosses >= MaxConsecutiveLoss)
                  {
                     Print("⛔ MAX ARDIŞIK KAYIP! Martingale sıfırlanıyor...");
                     g_consecutiveLosses = 0;
                     Alert("🎰 MİLYONER EA: ", MaxConsecutiveLoss, " ardışık kayıp! Sistem sıfırlandı.");
                  }
               }
            }
         }
      }
   }
}

//====================================================================
// DASHBOARD - Görsel Arayüz
//====================================================================
void UpdateDashboard()
{
   if(!MQLInfoInteger(MQL_VISUAL_MODE) && !MQLInfoInteger(MQL_TESTER)) return;
   
   int x = 10;
   int y = 30;
   int lineHeight = 20;
   color bgColor = clrBlack;
   color textColor = clrWhite;
   color accentColor = clrGold;
   
   // Başlık
   CreateLabel("MILYONER_Title", "🎰 MİLYONER EA v1.00", x, y, accentColor, 12);
   y += lineHeight + 5;
   
   CreateLabel("MILYONER_Line1", "════════════════════════", x, y, clrDarkGray, 8);
   y += lineHeight;
   
   // Durum
   CreateLabel("MILYONER_State", "📊 " + g_currentState, x, y, clrLime, 10);
   y += lineHeight;
   
   // Bakiye
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   CreateLabel("MILYONER_Balance", "💰 Bakiye: $" + DoubleToString(balance, 2), x, y, textColor, 9);
   y += lineHeight;
   CreateLabel("MILYONER_Equity", "💵 Equity: $" + DoubleToString(equity, 2), x, y, textColor, 9);
   y += lineHeight;
   
   // Drawdown
   double dd = g_equityHigh > 0 ? (g_equityHigh - equity) / g_equityHigh * 100.0 : 0;
   color ddColor = dd < 10 ? clrLime : (dd < 25 ? clrYellow : clrRed);
   CreateLabel("MILYONER_DD", "📉 Drawdown: " + DoubleToString(dd, 1) + "% (Max: " + DoubleToString(g_maxDrawdownReached, 1) + "%)", x, y, ddColor, 9);
   y += lineHeight;
   
   CreateLabel("MILYONER_Line2", "════════════════════════", x, y, clrDarkGray, 8);
   y += lineHeight;
   
   // İşlem istatistikleri
   CreateLabel("MILYONER_Trades", "📊 İşlemler: " + IntegerToString(g_totalTrades), x, y, textColor, 9);
   y += lineHeight;
   
   double winRate = g_totalTrades > 0 ? (double)g_winTrades / g_totalTrades * 100.0 : 0;
   CreateLabel("MILYONER_WinRate", "✅ Kazanç: " + IntegerToString(g_winTrades) + " (" + DoubleToString(winRate, 1) + "%)", x, y, clrLime, 9);
   y += lineHeight;
   CreateLabel("MILYONER_Loss", "❌ Kayıp: " + IntegerToString(g_lossTrades), x, y, clrRed, 9);
   y += lineHeight;
   
   // Net Kâr
   color profitColor = g_totalProfit >= 0 ? clrLime : clrRed;
   CreateLabel("MILYONER_Profit", "💰 Net: $" + DoubleToString(g_totalProfit, 2), x, y, profitColor, 10);
   y += lineHeight;
   
   CreateLabel("MILYONER_Line3", "════════════════════════", x, y, clrDarkGray, 8);
   y += lineHeight;
   
   // Martingale durumu
   if(UseMartingale)
   {
      color martColor = g_consecutiveLosses == 0 ? clrLime : (g_consecutiveLosses < MaxConsecutiveLoss ? clrYellow : clrRed);
      CreateLabel("MILYONER_Mart", "🎲 Martingale: " + IntegerToString(g_consecutiveLosses) + "/" + IntegerToString(MaxConsecutiveLoss), x, y, martColor, 9);
      y += lineHeight;
   }
   
   // Mevcut lot
   CreateLabel("MILYONER_Lot", "📦 Sonraki Lot: " + DoubleToString(CalculateLot(), 2), x, y, accentColor, 9);
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
