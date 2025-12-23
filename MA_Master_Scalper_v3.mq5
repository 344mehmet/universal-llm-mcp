//+------------------------------------------------------------------+
//|                                      MA_Master_Scalper_v3.mq5    |
//|                     © 2025, Milyoner EA Project v3.0             |
//|                     ULTRA-HIZLI M1 SCALPING SİSTEMİ              |
//+------------------------------------------------------------------+
//| v3 YENİ ÖZELLİKLER:                                              |
//| • M1 sabit timeframe sinyal                                      |
//| • Ultra-hızlı işlem açma                                         |
//| • Bekleyen emir (Pending Order) desteği                          |
//| • Ters yön müdahalesi - Yanlış pozisyon düzeltme                 |
//| • Otomatik yön koruma sistemi                                    |
//+------------------------------------------------------------------+
#property copyright "© 2025, Milyoner EA Project v3.0"
#property link      "https://github.com/milyoner-ea"
#property version   "3.00"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// ENUM TANIMLARI
//====================================================================
enum ENUM_ENTRY_MODE {
   ENTRY_INSTANT,        // Anlık (Market Order)
   ENTRY_PENDING,        // Bekleyen Emir (Limit/Stop)
   ENTRY_BOTH            // Her İkisi
};

enum ENUM_PENDING_TYPE {
   PENDING_LIMIT,        // Limit Order (Geri çekilmede)
   PENDING_STOP          // Stop Order (Breakout'ta)
};

enum ENUM_DIRECTION_CONTROL {
   DIR_FOLLOW_SIGNAL,    // Sinyal Takip
   DIR_BUY_ONLY,         // Sadece AL
   DIR_SELL_ONLY,        // Sadece SAT
   DIR_AUTO_CORRECT      // Otomatik Düzelt (v3 YENİ)
};

//====================================================================
// INPUT PARAMETRELERİ - v3 ULTRA HIZLI
//====================================================================

//--- 1. ANA AYARLAR
input group "═══ 1. ANA AYARLAR v3 ═══"
input ulong    MagicNumber        = 999999;        // 🎰 Magic Number
input string   TradeComment       = "MILYONER_v3"; // İşlem Yorumu
input bool     ShowDashboard      = true;          // Dashboard Göster

//--- 2. M1 SİNYAL SİSTEMİ (SABİT M1)
input group "═══ 2. M1 SİNYAL SİSTEMİ ═══"
input ENUM_TIMEFRAMES SignalTimeframe = PERIOD_M1; // ⚡ Sinyal Timeframe
input int      EMA_Fast_Period    = 8;             // 🔵 Hızlı EMA
input int      EMA_Slow_Period    = 21;            // 🔴 Yavaş EMA
input int      EMA_Trend_Period   = 50;            // 📈 Trend EMA
input bool     RequireTrendAlign  = true;          // Trend Hizalama Şartı

//--- 3. GİRİŞ MODU (v3 YENİ)
input group "═══ 3. GİRİŞ MODU v3 ═══"
input ENUM_ENTRY_MODE EntryMode   = ENTRY_INSTANT; // Giriş Modu
input ENUM_PENDING_TYPE PendingType = PENDING_LIMIT; // Bekleyen Emir Tipi
input int      PendingDistance    = 5;             // Bekleyen Emir Mesafesi (pip)
input int      PendingExpiry      = 5;             // Bekleyen Emir Süresi (bar)

//--- 4. YÖN KONTROLÜ (v3 YENİ - TERS POZİSYON MÜDAHALESİ)
input group "═══ 4. YÖN KONTROLÜ v3 ═══"
input ENUM_DIRECTION_CONTROL DirControl = DIR_FOLLOW_SIGNAL; // v3.1: Sadece sinyal takip
input bool     CloseWrongDirection = false;        // v3.1: KAPALI (test sonrası)
input bool     ReverseWrongPosition = false;       // v3.1: KAPALI (test sonrası)
input int      WrongDirMaxLoss    = 10;            // Tolerans (pip)

//--- 5. HIZLI FİLTRELER (SADECE CROSS)
input group "═══ 5. HIZLI FİLTRELER ═══"
input bool     UseADXFilter       = true;          // ADX Filtresi
input int      ADX_Period         = 14;            // ADX Periyodu
input int      ADX_MinLevel       = 25;            // v3.1: Min ADX yükseltildi
input bool     UseStochFilter     = true;          // v3.1: Stokastik AKTİF (kalite için)

//--- 6. ATR DİNAMİK SL/TP
input group "═══ 6. ATR SL/TP v3 ═══"
input bool     UseATRStops        = true;          // ATR Kullan
input int      ATR_Period         = 14;            // ATR Periyodu
input double   ATR_SL_Multiplier  = 1.2;           // v3: Daha sıkı SL (1.2x)
input double   ATR_TP_Multiplier  = 2.0;           // v3: TP (2.0x) R:R 1:1.67
input int      MinSL_Pips         = 3;             // v3: Min SL düşük
input int      MaxSL_Pips         = 20;            // Max SL

//--- 7. SABİT SL/TP
input group "═══ 7. SABİT SL/TP ═══"
input int      TP_Pips            = 8;             // Take Profit
input int      SL_Pips            = 12;            // Stop Loss

//--- 8. MARTİNGALE
input group "═══ 8. MARTİNGALE v3 ═══"
input bool     UseMartingale      = true;          // Martingale
input double   MartingaleMultiplier = 1.5;         // Çarpan
input int      MaxConsecutiveLoss = 4;             // Max Kayıp
input bool     ResetOnWin         = true;          // Kazançta Sıfırla

//--- 9. RİSK YÖNETİMİ
input group "═══ 9. RİSK v3 ═══"
input double   RiskPercent        = 1.0;           // v3.1: Risk % düşürüldü
input double   BaseLot            = 0.01;          // Min Lot
input double   MaxLotSize         = 1.0;           // v3.1: Max Lot düşürüldü
input double   MaxDrawdownPercent = 30.0;          // Max DD %

//--- 10. HIZLI TRAİLİNG
input group "═══ 10. TRAİLİNG v3 ═══"
input bool     UseTrailingStop    = true;          // Trailing
input int      TrailingStart      = 5;             // v3: Erken başla
input int      TrailingStep       = 3;             // v3: Sıkı adım
input bool     UseBreakeven       = true;          // Breakeven
input int      BreakevenStart     = 4;             // v3: Erken BE
input int      BreakevenProfit    = 1;             // BE Kâr

//--- 11. KORUMA
input group "═══ 11. KORUMA v3 ═══"
input int      MaxSpreadPips      = 5;             // Max Spread
input bool     CloseAllOnDrawdown = true;          // DD'de Kapat

//--- 12. COOLDOWN (DÜZELTİLDİ)
input group "═══ 12. COOLDOWN v3.1 ═══"
input int      CooldownBars       = 5;             // v3.1: 5 bar (daha az işlem)
input int      CooldownSeconds    = 60;            // v3.1: 60 saniye

//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================
int      g_hEMA_Fast    = INVALID_HANDLE;
int      g_hEMA_Slow    = INVALID_HANDLE;
int      g_hEMA_Trend   = INVALID_HANDLE;
int      g_hADX         = INVALID_HANDLE;
int      g_hATR         = INVALID_HANDLE;
int      g_hStoch       = INVALID_HANDLE;  // v3.1: Stokastik eklendi

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
int      g_currentSignal      = 0;  // Mevcut sinyal yönü (1=BUY, -1=SELL)
ulong    g_pendingTicket      = 0;  // Bekleyen emir ticket

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
   // Trade ayarları - HIZLI
   m_trade.SetExpertMagicNumber(MagicNumber);
   m_trade.SetDeviationInPoints(20); // v3: Geniş slippage toleransı
   m_trade.SetMarginMode();
   m_trade.SetTypeFilling(ORDER_FILLING_IOC); // v3: Hızlı dolum
   
   // M1 Timeframe için göstergeler
   g_hEMA_Fast = iMA(_Symbol, SignalTimeframe, EMA_Fast_Period, 0, MODE_EMA, PRICE_CLOSE);
   g_hEMA_Slow = iMA(_Symbol, SignalTimeframe, EMA_Slow_Period, 0, MODE_EMA, PRICE_CLOSE);
   g_hEMA_Trend = iMA(_Symbol, SignalTimeframe, EMA_Trend_Period, 0, MODE_EMA, PRICE_CLOSE);
   g_hADX = iADX(_Symbol, SignalTimeframe, ADX_Period);
   g_hATR = iATR(_Symbol, SignalTimeframe, ATR_Period);
   g_hStoch = iStochastic(_Symbol, SignalTimeframe, 14, 3, 3, MODE_SMA, STO_LOWHIGH); // v3.1
   
   if(g_hEMA_Fast == INVALID_HANDLE || g_hEMA_Slow == INVALID_HANDLE || 
      g_hADX == INVALID_HANDLE || g_hATR == INVALID_HANDLE || g_hStoch == INVALID_HANDLE)
   {
      Print("❌ Göstergeler yüklenemedi!");
      return INIT_FAILED;
   }
   
   g_currentLot = BaseLot;
   g_equityHigh = AccountInfoDouble(ACCOUNT_EQUITY);
   
   Print("════════════════════════════════════════════════════════════════");
   Print("⚡ MİLYONER EA v3.0 - ULTRA HIZLI M1 SCALPING");
   Print("════════════════════════════════════════════════════════════════");
   Print("📊 Timeframe: ", EnumToString(SignalTimeframe));
   Print("📈 EMA: ", EMA_Fast_Period, "/", EMA_Slow_Period, "/", EMA_Trend_Period);
   Print("🎯 Giriş Modu: ", EnumToString(EntryMode));
   Print("🔄 Yön Kontrolü: ", EnumToString(DirControl));
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
   if(g_hStoch != INVALID_HANDLE) IndicatorRelease(g_hStoch); // v3.1
   
   double pf = g_grossLoss != 0 ? g_grossProfit / MathAbs(g_grossLoss) : 0;
   double wr = g_totalTrades > 0 ? (double)g_winTrades / g_totalTrades * 100.0 : 0;
   
   Print("════════════════════════════════════════════════════════════════");
   Print("⚡ MİLYONER EA v3.0 - SONUÇLAR");
   Print("════════════════════════════════════════════════════════════════");
   Print("📊 Toplam: ", g_totalTrades, " | WR: ", DoubleToString(wr, 1), "%");
   Print("⚖️ Kâr Faktörü: ", DoubleToString(pf, 2));
   Print("💰 Net: $", DoubleToString(g_totalProfit, 2));
   Print("📉 Max DD: ", DoubleToString(g_maxDrawdownReached, 1), "%");
   Print("════════════════════════════════════════════════════════════════");
   
   ObjectsDeleteAll(0, "MILYONER_");
}

//====================================================================
// OnTick - ULTRA HIZLI
//====================================================================
void OnTick()
{
   // Dashboard
   if(ShowDashboard) UpdateDashboard();
   
   // ATR güncelle (her tick)
   UpdateATR();
   
   // Drawdown kontrolü
   if(CheckDrawdown())
   {
      g_currentState = "⛔ DRAWDOWN";
      return;
   }
   
   // v3: TERS YÖN MÜDAHALESİ - Her tick kontrol
   if(DirControl == DIR_AUTO_CORRECT)
   {
      CheckAndCorrectWrongPositions();
   }
   
   // Pozisyon yönetimi (Trailing + BE)
   ManagePositions();
   
   // Bekleyen emirleri yönet
   ManagePendingOrders();
   
   // Spread kontrolü
   if(!CheckSpread())
   {
      g_currentState = "⚠️ SPREAD";
      return;
   }
   
   // M1 Bar değişimi kontrolü
   datetime currentBar = iTime(_Symbol, SignalTimeframe, 0);
   bool newBar = (g_lastBarTime != currentBar);
   if(newBar)
   {
      g_lastBarTime = currentBar;
      g_barsSinceTrade++;
   }
   
   // Cooldown kontrolü
   if(!CheckCooldown())
   {
      g_currentState = "⏳ COOLDOWN";
      return;
   }
   
   // Sinyal al (her tick veya yeni bar)
   int signal = GetSignal();
   g_currentSignal = signal;
   
   // Açık pozisyon varsa ve aynı yönde ise bekle
   if(HasOpenPosition())
   {
      g_currentState = "📊 POZİSYON AKTİF";
      return;
   }
   
   // İşlem aç
   if(signal == 1)
   {
      g_currentState = "🟢 BUY!";
      ExecuteEntry(ORDER_TYPE_BUY);
   }
   else if(signal == -1)
   {
      g_currentState = "🔴 SELL!";
      ExecuteEntry(ORDER_TYPE_SELL);
   }
   else
   {
      g_currentState = "⏳ " + g_rejectReason;
   }
}

//====================================================================
// v3: TERS YÖN MÜDAHALESİ
//====================================================================
void CheckAndCorrectWrongPositions()
{
   if(!CloseWrongDirection && !ReverseWrongPosition) return;
   
   // Mevcut sinyal yönünü al
   int signal = GetSignalDirection();
   if(signal == 0) return; // Sinyal yoksa müdahale etme
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      
      // Tüm pozisyonları kontrol et (magic number dahil manuel açılanlar)
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      long posType = PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      double positionProfit = PositionGetDouble(POSITION_PROFIT);
      double volume = PositionGetDouble(POSITION_VOLUME);
      
      // Pozisyon yönü
      int posDirection = (posType == POSITION_TYPE_BUY) ? 1 : -1;
      
      // Ters yönde mi?
      if(posDirection != signal)
      {
         // Kayıp hesapla
         double lossPips = 0;
         if(posType == POSITION_TYPE_BUY)
            lossPips = PointsToPips(openPrice - currentPrice);
         else
            lossPips = PointsToPips(currentPrice - openPrice);
         
         // Tolerans aşıldı mı veya kayıpta mı?
         if(lossPips > WrongDirMaxLoss || positionProfit < 0)
         {
            Print("════════════════════════════════════════════════════════════════");
            Print("🔄 v3: TERS YÖN TESPİT EDİLDİ!");
            Print("📊 Pozisyon: ", (posType == POSITION_TYPE_BUY ? "BUY" : "SELL"));
            Print("📈 Sinyal: ", (signal == 1 ? "BUY" : "SELL"));
            Print("💔 Kayıp: ", DoubleToString(lossPips, 1), " pips");
            
            // Ters pozisyonu kapat
            if(CloseWrongDirection)
            {
               if(m_trade.PositionClose(ticket))
               {
                  Print("✅ Ters pozisyon KAPATILDI! Ticket: ", ticket);
                  
                  // Doğru yönde yeni pozisyon aç
                  if(ReverseWrongPosition)
                  {
                     Print("🔄 Doğru yönde pozisyon açılıyor...");
                     if(signal == 1)
                        ExecuteEntry(ORDER_TYPE_BUY);
                     else
                        ExecuteEntry(ORDER_TYPE_SELL);
                  }
               }
            }
            Print("════════════════════════════════════════════════════════════════");
         }
      }
   }
}

//====================================================================
// SİNYAL YÖNÜ (Sadece yön - filtre yok)
//====================================================================
int GetSignalDirection()
{
   double emaFast[], emaSlow[];
   ArrayResize(emaFast, 2);
   ArrayResize(emaSlow, 2);
   ArraySetAsSeries(emaFast, true);
   ArraySetAsSeries(emaSlow, true);
   
   if(CopyBuffer(g_hEMA_Fast, 0, 0, 2, emaFast) < 2) return 0;
   if(CopyBuffer(g_hEMA_Slow, 0, 0, 2, emaSlow) < 2) return 0;
   
   // Mevcut EMA pozisyonu
   if(emaFast[0] > emaSlow[0]) return 1;  // BUY bölgesi
   if(emaFast[0] < emaSlow[0]) return -1; // SELL bölgesi
   
   return 0;
}

//====================================================================
// v3: HIZLI SİNYAL MOTORU (M1)
//====================================================================
int GetSignal()
{
   g_rejectReason = "SİNYAL BEKLENİYOR";
   
   // EMA verileri (M1)
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
   
   // EMA Cross (Bar[1])
   bool goldenCross = (emaFast[2] <= emaSlow[2] && emaFast[1] > emaSlow[1]);
   bool deathCross  = (emaFast[2] >= emaSlow[2] && emaFast[1] < emaSlow[1]);
   
   if(!goldenCross && !deathCross)
   {
      g_rejectReason = "CROSS YOK";
      return 0;
   }
   
   // Yön kontrolü
   if(DirControl == DIR_BUY_ONLY && deathCross) return 0;
   if(DirControl == DIR_SELL_ONLY && goldenCross) return 0;
   
   // ADX Filtresi (opsiyonel)
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
   
   // Trend hizalama (opsiyonel)
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
   
   // v3.1: STOKASTİK FİLTRE
   if(UseStochFilter)
   {
      double stochK[];
      ArrayResize(stochK, 2);
      ArraySetAsSeries(stochK, true);
      if(CopyBuffer(g_hStoch, 0, 0, 2, stochK) >= 2)
      {
         // BUY için: Stokastik aşırı satımdan (≤30) çıkıyor olmalı
         if(goldenCross && stochK[1] > 30)
         {
            g_rejectReason = "STOCH YÜKSEK";
            return 0;
         }
         // SELL için: Stokastik aşırı alımda (≥70) olmalı
         if(deathCross && stochK[1] < 70)
         {
            g_rejectReason = "STOCH DÜŞÜK";
            return 0;
         }
      }
   }
   
   if(goldenCross) return 1;
   if(deathCross) return -1;
   
   return 0;
}

//====================================================================
// v3: GİRİŞ MODU - ANLIK veya BEKLEYEN
//====================================================================
void ExecuteEntry(ENUM_ORDER_TYPE orderType)
{
   if(EntryMode == ENTRY_INSTANT || EntryMode == ENTRY_BOTH)
   {
      OpenMarketOrder(orderType);
   }
   
   if(EntryMode == ENTRY_PENDING || EntryMode == ENTRY_BOTH)
   {
      PlacePendingOrder(orderType);
   }
}

//====================================================================
// ANLIK EMİR
//====================================================================
void OpenMarketOrder(ENUM_ORDER_TYPE orderType)
{
   double lot = CalculateLot();
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
      g_lastTradeTime = TimeCurrent();
      g_barsSinceTrade = 0;
      
      Print("⚡ v3: ", (orderType == ORDER_TYPE_BUY ? "BUY" : "SELL"), 
            " | Lot: ", DoubleToString(lot, 2),
            " | Entry: ", DoubleToString(price, digits),
            " | Ticket: ", m_trade.ResultOrder());
   }
}

//====================================================================
// v3: BEKLEYEN EMİR
//====================================================================
void PlacePendingOrder(ENUM_ORDER_TYPE marketType)
{
   // Mevcut bekleyen emir varsa iptal et
   CancelPendingOrders();
   
   double lot = CalculateLot();
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double pendingDist = PipsToPoints(PendingDistance);
   
   double price, sl, tp;
   ENUM_ORDER_TYPE pendingOrderType;
   datetime expiry = TimeCurrent() + PendingExpiry * PeriodSeconds(SignalTimeframe);
   
   if(marketType == ORDER_TYPE_BUY)
   {
      if(PendingType == PENDING_LIMIT)
      {
         // BUY LIMIT - Mevcut fiyatın altında
         price = SymbolInfoDouble(_Symbol, SYMBOL_ASK) - pendingDist;
         pendingOrderType = ORDER_TYPE_BUY_LIMIT;
      }
      else
      {
         // BUY STOP - Mevcut fiyatın üstünde  
         price = SymbolInfoDouble(_Symbol, SYMBOL_ASK) + pendingDist;
         pendingOrderType = ORDER_TYPE_BUY_STOP;
      }
      GetDynamicSLTP(1, sl, tp);
      sl = NormalizeDouble(price - MathAbs(SymbolInfoDouble(_Symbol, SYMBOL_ASK) - sl), digits);
      tp = NormalizeDouble(price + MathAbs(tp - SymbolInfoDouble(_Symbol, SYMBOL_ASK)), digits);
   }
   else
   {
      if(PendingType == PENDING_LIMIT)
      {
         // SELL LIMIT - Mevcut fiyatın üstünde
         price = SymbolInfoDouble(_Symbol, SYMBOL_BID) + pendingDist;
         pendingOrderType = ORDER_TYPE_SELL_LIMIT;
      }
      else
      {
         // SELL STOP - Mevcut fiyatın altında
         price = SymbolInfoDouble(_Symbol, SYMBOL_BID) - pendingDist;
         pendingOrderType = ORDER_TYPE_SELL_STOP;
      }
      GetDynamicSLTP(-1, sl, tp);
      sl = NormalizeDouble(price + MathAbs(sl - SymbolInfoDouble(_Symbol, SYMBOL_BID)), digits);
      tp = NormalizeDouble(price - MathAbs(SymbolInfoDouble(_Symbol, SYMBOL_BID) - tp), digits);
   }
   
   price = NormalizeDouble(price, digits);
   
   if(m_trade.OrderOpen(_Symbol, pendingOrderType, lot, 0, price, sl, tp, ORDER_TIME_SPECIFIED, expiry, TradeComment + "_PENDING"))
   {
      g_pendingTicket = m_trade.ResultOrder();
      Print("📋 v3: BEKLEYEN EMİR | ", EnumToString(pendingOrderType),
            " | Price: ", DoubleToString(price, digits),
            " | Expiry: ", expiry);
   }
}

//====================================================================
// BEKLEYEN EMİRLERİ YÖNETİ
//====================================================================
void ManagePendingOrders()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0) continue;
      if(OrderGetInteger(ORDER_MAGIC) != MagicNumber) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      
      // Sinyal değiştiyse bekleyen emri iptal et
      ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
      int orderDir = (orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP) ? 1 : -1;
      
      if(g_currentSignal != 0 && g_currentSignal != orderDir)
      {
         m_trade.OrderDelete(ticket);
         Print("🚫 v3: Bekleyen emir iptal (sinyal değişti)");
      }
   }
}

//====================================================================
// BEKLEYEN EMİRLERİ İPTAL ET
//====================================================================
void CancelPendingOrders()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0) continue;
      if(OrderGetInteger(ORDER_MAGIC) != MagicNumber) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      m_trade.OrderDelete(ticket);
   }
}

//====================================================================
// ATR GÜNCELLE
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

//====================================================================
// DİNAMİK SL/TP
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

//====================================================================
// LOT HESAPLAMA - GÜVENLİ
//====================================================================
double CalculateLot()
{
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   
   // SL pip değeri
   double slPips = SL_Pips;
   if(UseATRStops && g_lastATR > 0)
   {
      slPips = PointsToPips(g_lastATR * ATR_SL_Multiplier);
      slPips = MathMax(MinSL_Pips, MathMin(slPips, MaxSL_Pips));
   }
   if(slPips <= 0) slPips = SL_Pips;
   
   // Risk miktarı
   double riskAmount = balance * (RiskPercent / 100.0);
   
   // Tick value hesaplama
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   if(tickValue <= 0 || tickSize <= 0)
   {
      // Fallback: basit hesaplama
      tickValue = 10.0; // Standart forex için yaklaşık
   }
   
   // Pip değeri hesapla
   double pipValue = tickValue * (PipsToPoints(1) / tickSize);
   if(pipValue <= 0) pipValue = 10.0;
   
   // Risk bazlı lot
   double lot = riskAmount / (slPips * pipValue);
   
   // Martingale
   if(UseMartingale && g_consecutiveLosses > 0)
   {
      double mult = MathPow(MartingaleMultiplier, g_consecutiveLosses);
      lot *= mult;
      Print("🎲 Martingale: ", g_consecutiveLosses, " kayıp, çarpan: ", DoubleToString(mult, 2));
   }
   
   // Broker limitleri
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   if(minLot <= 0) minLot = 0.01;
   if(maxLot <= 0) maxLot = 100;
   if(stepLot <= 0) stepLot = 0.01;
   
   // İlk sınırlama
   lot = MathFloor(lot / stepLot) * stepLot;
   lot = MathMax(minLot, MathMin(lot, MathMin(maxLot, MaxLotSize)));
   
   // MARJIN KONTROLÜ - ÇOK ÖNEMLİ
   double marginRequired = 0;
   double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   // Marjin hesapla
   if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, marginRequired))
   {
      // Yetersiz marjin kontrolü
      double safeMargin = freeMargin * 0.5; // Serbest marjinin %50'sini kullan
      
      while(marginRequired > safeMargin && lot > minLot)
      {
         lot = MathFloor((lot * 0.5) / stepLot) * stepLot;
         lot = MathMax(lot, minLot);
         
         if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, marginRequired))
            break;
            
         Print("⚠️ Marjin düşürme: Lot=", DoubleToString(lot, 2), " Marjin=", DoubleToString(marginRequired, 2));
      }
   }
   else
   {
      // Marjin hesaplanamadıysa minimum lot kullan
      lot = minLot;
      Print("⚠️ Marjin hesaplanamadı, minimum lot kullanılıyor");
   }
   
   // Son kontrol
   lot = MathMax(minLot, MathMin(lot, MaxLotSize));
   
   // Debug log
   if(lot > 1.0)
   {
      Print("⚠️ YÜKSEK LOT: ", DoubleToString(lot, 2), 
            " | Balance: $", DoubleToString(balance, 2),
            " | FreeMargin: $", DoubleToString(freeMargin, 2));
   }
   
   g_currentLot = lot;
   return lot;
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
// KONTROLLER
//====================================================================
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
         CancelPendingOrders();
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
            
            if(profit > 0)
            {
               g_winTrades++;
               g_consecutiveWins++;
               g_grossProfit += profit;
               if(ResetOnWin) g_consecutiveLosses = 0;
               Print("🎉 WIN! +$", DoubleToString(profit, 2), " | Total: $", DoubleToString(g_totalProfit, 2));
            }
            else if(profit < 0)
            {
               g_lossTrades++;
               g_consecutiveLosses++;
               g_consecutiveWins = 0;
               g_grossLoss += profit;
               Print("💔 LOSS: $", DoubleToString(profit, 2), " | Streak: ", g_consecutiveLosses);
               
               if(g_consecutiveLosses >= MaxConsecutiveLoss)
               {
                  g_consecutiveLosses = 0;
                  Print("⛔ MAX KAYIP! Sıfırlandı.");
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
   
   int x = 10, y = 25, h = 16;
   color gold = clrGold, white = clrWhite, gray = clrDimGray;
   
   CreateLabel("MILYONER_T", "⚡ MİLYONER v3.0 - M1 SCALPER", x, y, gold, 10); y += h + 3;
   CreateLabel("MILYONER_L1", "══════════════════════════", x, y, gray, 7); y += h;
   
   CreateLabel("MILYONER_S", "📊 " + g_currentState, x, y, clrLime, 9); y += h;
   CreateLabel("MILYONER_Sig", "🎯 Sinyal: " + (g_currentSignal == 1 ? "BUY" : (g_currentSignal == -1 ? "SELL" : "---")), x, y, g_currentSignal == 1 ? clrLime : (g_currentSignal == -1 ? clrRed : white), 8); y += h;
   
   double bal = AccountInfoDouble(ACCOUNT_BALANCE);
   double eq = AccountInfoDouble(ACCOUNT_EQUITY);
   CreateLabel("MILYONER_B", "💰 $" + DoubleToString(bal, 2), x, y, white, 8); y += h;
   
   double dd = g_equityHigh > 0 ? (g_equityHigh - eq) / g_equityHigh * 100.0 : 0;
   color ddClr = dd < 10 ? clrLime : (dd < 20 ? clrYellow : clrRed);
   CreateLabel("MILYONER_DD", "📉 DD: " + DoubleToString(dd, 1) + "%", x, y, ddClr, 8); y += h;
   
   double pf = g_grossLoss != 0 ? g_grossProfit / MathAbs(g_grossLoss) : 0;
   CreateLabel("MILYONER_PF", "⚖️ PF: " + DoubleToString(pf, 2), x, y, pf >= 1.0 ? clrLime : clrRed, 8); y += h;
   
   color netClr = g_totalProfit >= 0 ? clrLime : clrRed;
   CreateLabel("MILYONER_Net", "💵 Net: $" + DoubleToString(g_totalProfit, 2), x, y, netClr, 9); y += h;
   
   CreateLabel("MILYONER_M", "🎲 Mart: " + IntegerToString(g_consecutiveLosses) + "/" + IntegerToString(MaxConsecutiveLoss), x, y, g_consecutiveLosses > 0 ? clrYellow : clrLime, 8); y += h;
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
