//+------------------------------------------------------------------+
//|                                           MA_Master_Pro_EA.mq5   |
//|                     © 2025, MA Master Pro Trading System         |
//|                     Grid + Basket + Drawdown Recovery            |
//+------------------------------------------------------------------+
//| ÖZELLİKLER:                                                      |
//| • EMA Cross sinyal sistemi                                       |
//| • Grid/Basket emir yönetimi                                      |
//| • Drawdown azaltma (Kârlı + Zararlı emir kapatma)                |
//| • Martingale / Anti-Martingale lot yönetimi                      |
//| • Regression Channel gösterimi                                   |
//| • Trailing Stop / Breakeven                                      |
//| • Volatilite filtresi (ATR)                                      |
//+------------------------------------------------------------------+
#property copyright "© 2025, MA Master Pro EA"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// ENUM TANIMLARI
//====================================================================
enum ENUM_LOT_MODE
  {
   LOT_FIXED,           // Sabit Lot
   LOT_MARTINGALE,      // Martingale (Kayıpta Artır)
   LOT_ANTI_MARTINGALE, // Anti-Martingale (Kazançta Artır)
   LOT_MULTIPLIER       // Grid Çarpanı
  };

enum ENUM_GRID_MODE
  {
   GRID_DISABLED,       // Grid Kapalı
   GRID_ONE_DIRECTION,  // Tek Yönlü Grid
   GRID_BOTH_DIRECTIONS // Çift Yönlü Grid (Hedge)
  };

enum ENUM_SIGNAL_MODE
  {
   SIGNAL_EMA_CROSS,    // EMA Kesişimi
   SIGNAL_EMA_DIRECTION,// EMA Yönü
   SIGNAL_PRICE_MA      // Fiyat MA Kesişimi
  };

//====================================================================
// INPUT PARAMETRELERİ
//====================================================================

//--- 1. ANA AYARLAR
input group "═══ 1. ANA AYARLAR ═══"
input ulong          InpMagicNumber     = 888999;         // 🎰 Magic Number
input string         InpTradeComment    = "MA_Master_Pro"; // 💬 İşlem Yorumu
input double         InpMinDeposit      = 500.0;          // 💵 Minimum Bakiye ($)

//--- 2. EMA AYARLARI
input group "═══ 2. EMA SİNYAL SİSTEMİ ═══"
input ENUM_SIGNAL_MODE InpSignalMode    = SIGNAL_EMA_CROSS; // 📊 Sinyal Modu
input int            InpFastMA          = 8;               // 🔵 Hızlı EMA Periyodu
input int            InpSlowMA          = 21;              // 🔴 Yavaş EMA Periyodu
input int            InpTrendMA         = 50;              // 📈 Trend EMA Periyodu
input ENUM_MA_METHOD InpMAMethod        = MODE_EMA;        // MA Metodu
input ENUM_APPLIED_PRICE InpMAPrice     = PRICE_CLOSE;     // MA Fiyat Tipi

//--- 3. LOT YÖNETİMİ
input group "═══ 3. LOT YÖNETİMİ ═══"
input ENUM_LOT_MODE  InpLotMode         = LOT_MARTINGALE;  // 🎲 Lot Modu
input double         InpStartLot        = 0.01;            // 💰 Başlangıç Lot
input double         InpLotMultiplier   = 1.5;             // 📈 Lot Çarpanı
input double         InpMaxLot          = 2.0;             // 🔝 Maximum Lot

//--- 4. GRİD / BASKET SİSTEMİ
input group "═══ 4. GRİD / BASKET SİSTEMİ ═══"
input ENUM_GRID_MODE InpGridMode        = GRID_ONE_DIRECTION; // 📊 Grid Modu
input int            InpGridStepPips    = 30;              // 📏 Grid Adımı (pip)
input int            InpMaxGridOrders   = 7;               // 🔢 Max Grid Emirleri
input bool           InpAveraging       = true;            // 📊 Averaging Aktif
input double         InpAveragingProfit = 10.0;            // 💵 Basket Hedef Kâr ($)

//--- 5. DRAWDOWN AZALTMA
input group "═══ 5. DRAWDOWN AZALTMA ═══"
input bool           InpEnableDrawdownReduction = true;    // ✅ DD Azaltma Aktif
input int            InpDDReductionStartOrders = 4;        // 🔢 DD Azaltma Başlangıç (emir sayısı)
input double         InpDDReductionMinProfit = 1.0;        // 💵 Min Kâr ($) Kapatma için
input double         InpMaxDrawdownPercent = 30.0;         // 📉 Max Drawdown %

//--- 6. SL / TP AYARLARI
input group "═══ 6. SL / TP AYARLARI ═══"
input int            InpStopLoss        = 0;               // 🛑 Stop Loss (pip, 0=kapalı)
input int            InpTakeProfit      = 0;               // 🎯 Take Profit (pip, 0=kapalı)
input bool           InpUseBreakeven    = true;            // 🔒 Breakeven Aktif
input int            InpBreakevenStart  = 20;              // BE Tetik (pip)
input int            InpBreakevenProfit = 5;               // BE Kâr (pip)
input bool           InpUseTrailing     = true;            // 📈 Trailing Stop Aktif
input int            InpTrailingStart   = 30;              // Trailing Başlangıç (pip)
input int            InpTrailingStep    = 15;              // Trailing Adım (pip)

//--- 7. VOLATİLİTE FİLTRESİ
input group "═══ 7. VOLATİLİTE (ATR) FİLTRESİ ═══"
input bool           InpUseATRFilter    = true;            // ✅ ATR Filtresi
input int            InpATRPeriod       = 14;              // ATR Periyodu
input double         InpMinATR          = 0.0005;          // Min ATR
input double         InpMaxATR          = 0.01;            // Max ATR

//--- 8. SPREAD VE ZAMAN
input group "═══ 8. SPREAD VE ZAMAN FİLTRESİ ═══"
input int            InpMaxSpreadPips   = 5;               // 📊 Max Spread (pip)
input bool           InpUseTimeFilter   = false;           // ⏰ Zaman Filtresi
input int            InpStartHour       = 8;               // Başlangıç Saati
input int            InpEndHour         = 20;              // Bitiş Saati

//--- 9. REGRESSION CHANNEL
input group "═══ 9. REGRESSION CHANNEL ═══"
input bool           InpShowRegChannel  = true;            // 📈 Regression Channel Göster
input int            InpRegChannelBars  = 100;             // Bar Sayısı
input color          InpRegChannelColor = clrDodgerBlue;   // Kanal Rengi
input int            InpRegChannelWidth = 2;               // Çizgi Kalınlığı

//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================
CTrade            g_trade;              // Trade nesnesi

//--- Indikatör handle'ları
int               g_hFastMA;
int               g_hSlowMA;
int               g_hTrendMA;
int               g_hATR;

//--- Grid/Basket yönetimi
struct GridOrder
  {
   ulong             ticket;
   double            openPrice;
   double            lots;
   ENUM_POSITION_TYPE posType;
   double            profit;
  };

GridOrder         g_buyOrders[];
GridOrder         g_sellOrders[];
int               g_buyOrderCount;
int               g_sellOrderCount;
double            g_buyAveragePrice;
double            g_sellAveragePrice;
double            g_buyTotalLots;
double            g_sellTotalLots;
double            g_buyTotalProfit;
double            g_sellTotalProfit;

//--- İstatistikler
int               g_consecutiveWins;
int               g_consecutiveLosses;
double            g_equityHigh;
double            g_maxDrawdown;
double            g_totalProfit;
int               g_totalTrades;

//--- Kontrol
datetime          g_lastBarTime;
int               g_lastSignal;
bool              g_isGridActive;

//====================================================================
// YARDIMCI FONKSİYONLAR
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
   if(multiplier * point == 0) return 0;
   return points / (multiplier * point);
  }

double NormalizePrice(double price)
  {
   return NormalizeDouble(price, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
  }

double NormalizeLot(double lot)
  {
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   lot = MathFloor(lot / stepLot) * stepLot;
   return NormalizeDouble(MathMax(minLot, MathMin(lot, maxLot)), 2);
  }

void WriteLog(string msg) { Print("📋 ", msg); }
void PrintSeparator(string title = "")
  {
   if(title == "") Print("════════════════════════════════════════════════════════════════");
   else Print("═══════════════ ", title, " ═══════════════");
  }

//====================================================================
// OnInit
//====================================================================
int OnInit()
  {
   PrintSeparator("MA MASTER PRO EA");
   
   // Bakiye kontrolü
   if(AccountInfoDouble(ACCOUNT_BALANCE) < InpMinDeposit)
     {
      Print("❌ Minimum bakiye gerekli: $", InpMinDeposit);
      return INIT_FAILED;
     }
   
   // Trade ayarları
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(10);
   g_trade.SetTypeFilling(ORDER_FILLING_FOK);
   g_trade.SetMarginMode();
   g_trade.LogLevel(LOG_LEVEL_ERRORS);
   g_trade.SetTypeFillingBySymbol(_Symbol);
   
   // İndikatörler
   g_hFastMA = iMA(_Symbol, PERIOD_CURRENT, InpFastMA, 0, InpMAMethod, InpMAPrice);
   g_hSlowMA = iMA(_Symbol, PERIOD_CURRENT, InpSlowMA, 0, InpMAMethod, InpMAPrice);
   g_hTrendMA = iMA(_Symbol, PERIOD_CURRENT, InpTrendMA, 0, InpMAMethod, InpMAPrice);
   g_hATR = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
   
   if(g_hFastMA == INVALID_HANDLE || g_hSlowMA == INVALID_HANDLE || 
      g_hTrendMA == INVALID_HANDLE || g_hATR == INVALID_HANDLE)
     {
      Print("❌ İndikatörler yüklenemedi!");
      return INIT_FAILED;
     }
   
   // Değişkenleri sıfırla
   ArrayResize(g_buyOrders, 0);
   ArrayResize(g_sellOrders, 0);
   g_buyOrderCount = 0;
   g_sellOrderCount = 0;
   g_consecutiveWins = 0;
   g_consecutiveLosses = 0;
   g_equityHigh = AccountInfoDouble(ACCOUNT_EQUITY);
   g_maxDrawdown = 0;
   g_totalProfit = 0;
   g_totalTrades = 0;
   g_lastBarTime = 0;
   g_lastSignal = 0;
   g_isGridActive = false;
   
   WriteLog("Sembol: " + _Symbol);
   WriteLog("Lot Modu: " + EnumToString(InpLotMode));
   WriteLog("Grid Modu: " + EnumToString(InpGridMode));
   WriteLog("EMA: " + IntegerToString(InpFastMA) + "/" + IntegerToString(InpSlowMA) + "/" + IntegerToString(InpTrendMA));
   PrintSeparator();
   
   return INIT_SUCCEEDED;
  }

//====================================================================
// OnDeinit
//====================================================================
void OnDeinit(const int reason)
  {
   IndicatorRelease(g_hFastMA);
   IndicatorRelease(g_hSlowMA);
   IndicatorRelease(g_hTrendMA);
   IndicatorRelease(g_hATR);
   
   // Regression channel sil
   ObjectsDeleteAll(0, "RegChannel_");
   
   PrintSeparator("SONUÇLAR");
   WriteLog("Toplam İşlem: " + IntegerToString(g_totalTrades));
   WriteLog("Max Drawdown: " + DoubleToString(g_maxDrawdown, 2) + "%");
   WriteLog("Toplam Kar: $" + DoubleToString(g_totalProfit, 2));
   PrintSeparator();
  }

//====================================================================
// GRID/BASKET POZİSYONLARINI GÜNCELLE
//====================================================================
void UpdateGridPositions()
  {
   // Dizileri sıfırla
   ArrayResize(g_buyOrders, 0);
   ArrayResize(g_sellOrders, 0);
   g_buyOrderCount = 0;
   g_sellOrderCount = 0;
   g_buyTotalLots = 0;
   g_sellTotalLots = 0;
   g_buyTotalProfit = 0;
   g_sellTotalProfit = 0;
   g_buyAveragePrice = 0;
   g_sellAveragePrice = 0;
   
   double buyPriceSum = 0;
   double sellPriceSum = 0;
   
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      GridOrder order;
      order.ticket = ticket;
      order.openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      order.lots = PositionGetDouble(POSITION_VOLUME);
      order.posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      order.profit = PositionGetDouble(POSITION_PROFIT) + 
                     PositionGetDouble(POSITION_SWAP);
      
      if(order.posType == POSITION_TYPE_BUY)
        {
         ArrayResize(g_buyOrders, g_buyOrderCount + 1);
         g_buyOrders[g_buyOrderCount] = order;
         g_buyOrderCount++;
         g_buyTotalLots += order.lots;
         g_buyTotalProfit += order.profit;
         buyPriceSum += order.openPrice * order.lots;
        }
      else
        {
         ArrayResize(g_sellOrders, g_sellOrderCount + 1);
         g_sellOrders[g_sellOrderCount] = order;
         g_sellOrderCount++;
         g_sellTotalLots += order.lots;
         g_sellTotalProfit += order.profit;
         sellPriceSum += order.openPrice * order.lots;
        }
     }
   
   // Ortalama fiyatları hesapla
   if(g_buyTotalLots > 0)
      g_buyAveragePrice = buyPriceSum / g_buyTotalLots;
   if(g_sellTotalLots > 0)
      g_sellAveragePrice = sellPriceSum / g_sellTotalLots;
   
   g_isGridActive = (g_buyOrderCount > 0 || g_sellOrderCount > 0);
  }

//====================================================================
// LOT HESAPLA
//====================================================================
double CalculateLot(int gridLevel = 0)
  {
   double lot = InpStartLot;
   
   switch(InpLotMode)
     {
      case LOT_FIXED:
         lot = InpStartLot;
         break;
         
      case LOT_MARTINGALE:
         if(g_consecutiveLosses > 0)
            lot = InpStartLot * MathPow(InpLotMultiplier, g_consecutiveLosses);
         break;
         
      case LOT_ANTI_MARTINGALE:
         if(g_consecutiveWins > 0)
            lot = InpStartLot * MathPow(InpLotMultiplier, g_consecutiveWins);
         break;
         
      case LOT_MULTIPLIER:
         // Grid seviyesine göre lot artır
         if(gridLevel > 0)
            lot = InpStartLot * MathPow(InpLotMultiplier, gridLevel);
         break;
     }
   
   return NormalizeLot(MathMin(lot, InpMaxLot));
  }

//====================================================================
// SİNYAL AL
//====================================================================
int GetSignal()
  {
   double fastMA[], slowMA[], trendMA[];
   ArraySetAsSeries(fastMA, true);
   ArraySetAsSeries(slowMA, true);
   ArraySetAsSeries(trendMA, true);
   
   if(CopyBuffer(g_hFastMA, 0, 0, 3, fastMA) < 3) return 0;
   if(CopyBuffer(g_hSlowMA, 0, 0, 3, slowMA) < 3) return 0;
   if(CopyBuffer(g_hTrendMA, 0, 0, 2, trendMA) < 2) return 0;
   
   double price = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   switch(InpSignalMode)
     {
      case SIGNAL_EMA_CROSS:
         // Golden Cross
         if(fastMA[2] <= slowMA[2] && fastMA[1] > slowMA[1])
            return 1;
         // Death Cross
         if(fastMA[2] >= slowMA[2] && fastMA[1] < slowMA[1])
            return -1;
         break;
         
      case SIGNAL_EMA_DIRECTION:
         // Hızlı MA yükseliyor
         if(fastMA[1] > fastMA[2] && price > trendMA[1])
            return 1;
         // Hızlı MA düşüyor
         if(fastMA[1] < fastMA[2] && price < trendMA[1])
            return -1;
         break;
         
      case SIGNAL_PRICE_MA:
         // Fiyat MA'yı yukarı kesti
         if(iClose(_Symbol, PERIOD_CURRENT, 2) < fastMA[2] && 
            iClose(_Symbol, PERIOD_CURRENT, 1) > fastMA[1])
            return 1;
         // Fiyat MA'yı aşağı kesti
         if(iClose(_Symbol, PERIOD_CURRENT, 2) > fastMA[2] && 
            iClose(_Symbol, PERIOD_CURRENT, 1) < fastMA[1])
            return -1;
         break;
     }
   
   return 0;
  }

//====================================================================
// GÜVENLİK KONTROLLERİ
//====================================================================
bool IsSafeToTrade()
  {
   // Spread kontrolü
   double spreadPips = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0;
   if(spreadPips > InpMaxSpreadPips)
      return false;
   
   // Zaman filtresi
   if(InpUseTimeFilter)
     {
      MqlDateTime dt;
      TimeCurrent(dt);
      if(dt.hour < InpStartHour || dt.hour >= InpEndHour)
         return false;
     }
   
   // ATR filtresi
   if(InpUseATRFilter)
     {
      double atr[];
      ArraySetAsSeries(atr, true);
      if(CopyBuffer(g_hATR, 0, 0, 1, atr) >= 1)
        {
         if(atr[0] < InpMinATR || atr[0] > InpMaxATR)
            return false;
        }
     }
   
   return true;
  }

//====================================================================
// GRİD EMRİ AÇ
//====================================================================
bool OpenGridOrder(int direction, int gridLevel)
  {
   double lot = CalculateLot(gridLevel);
   double sl = 0, tp = 0;
   
   if(InpStopLoss > 0)
      sl = PipsToPoints(InpStopLoss);
   if(InpTakeProfit > 0)
      tp = PipsToPoints(InpTakeProfit);
   
   string comment = InpTradeComment + "_G" + IntegerToString(gridLevel);
   
   if(direction == 1)
     {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double slPrice = (sl > 0) ? NormalizePrice(ask - sl) : 0;
      double tpPrice = (tp > 0) ? NormalizePrice(ask + tp) : 0;
      
      if(g_trade.Buy(lot, _Symbol, ask, slPrice, tpPrice, comment))
        {
         WriteLog("🟢 BUY #" + IntegerToString(gridLevel) + " Lot: " + DoubleToString(lot, 2));
         return true;
        }
     }
   else
     {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double slPrice = (sl > 0) ? NormalizePrice(bid + sl) : 0;
      double tpPrice = (tp > 0) ? NormalizePrice(bid - tp) : 0;
      
      if(g_trade.Sell(lot, _Symbol, bid, slPrice, tpPrice, comment))
        {
         WriteLog("🔴 SELL #" + IntegerToString(gridLevel) + " Lot: " + DoubleToString(lot, 2));
         return true;
        }
     }
   
   return false;
  }

//====================================================================
// GRİD YÖNETİMİ - Fiyat Ters Giderse Ek Emir Aç
//====================================================================
void ManageGrid()
  {
   if(InpGridMode == GRID_DISABLED) return;
   
   double gridStep = PipsToPoints(InpGridStepPips);
   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // BUY Grid
   if(g_buyOrderCount > 0 && g_buyOrderCount < InpMaxGridOrders)
     {
      // En düşük fiyatlı buy emrini bul
      double lowestBuyPrice = 999999;
      for(int i = 0; i < g_buyOrderCount; i++)
        {
         if(g_buyOrders[i].openPrice < lowestBuyPrice)
            lowestBuyPrice = g_buyOrders[i].openPrice;
        }
      
      // Fiyat grid adımı kadar düştüyse yeni buy aç
      if(currentPrice <= lowestBuyPrice - gridStep)
        {
         if(InpGridMode == GRID_ONE_DIRECTION || InpGridMode == GRID_BOTH_DIRECTIONS)
           {
            OpenGridOrder(1, g_buyOrderCount);
           }
        }
     }
   
   // SELL Grid
   if(g_sellOrderCount > 0 && g_sellOrderCount < InpMaxGridOrders)
     {
      // En yüksek fiyatlı sell emrini bul
      double highestSellPrice = 0;
      for(int i = 0; i < g_sellOrderCount; i++)
        {
         if(g_sellOrders[i].openPrice > highestSellPrice)
            highestSellPrice = g_sellOrders[i].openPrice;
        }
      
      // Fiyat grid adımı kadar yükseldiyse yeni sell aç
      if(currentPrice >= highestSellPrice + gridStep)
        {
         if(InpGridMode == GRID_ONE_DIRECTION || InpGridMode == GRID_BOTH_DIRECTIONS)
           {
            OpenGridOrder(-1, g_sellOrderCount);
           }
        }
     }
  }

//====================================================================
// BASKET KAPAT - Hedef Kâra Ulaşıldığında
//====================================================================
void ManageBasket()
  {
   if(!InpAveraging) return;
   
   // Buy basket kontrolü
   if(g_buyOrderCount > 1 && g_buyTotalProfit >= InpAveragingProfit)
     {
      PrintSeparator();
      WriteLog("🏆 BUY BASKET KAPANIYOR! Kâr: $" + DoubleToString(g_buyTotalProfit, 2));
      
      for(int i = 0; i < g_buyOrderCount; i++)
        {
         g_trade.PositionClose(g_buyOrders[i].ticket);
        }
      
      g_totalProfit += g_buyTotalProfit;
      g_totalTrades += g_buyOrderCount;
      g_consecutiveWins++;
      g_consecutiveLosses = 0;
      PrintSeparator();
     }
   
   // Sell basket kontrolü
   if(g_sellOrderCount > 1 && g_sellTotalProfit >= InpAveragingProfit)
     {
      PrintSeparator();
      WriteLog("🏆 SELL BASKET KAPANIYOR! Kâr: $" + DoubleToString(g_sellTotalProfit, 2));
      
      for(int i = 0; i < g_sellOrderCount; i++)
        {
         g_trade.PositionClose(g_sellOrders[i].ticket);
        }
      
      g_totalProfit += g_sellTotalProfit;
      g_totalTrades += g_sellOrderCount;
      g_consecutiveWins++;
      g_consecutiveLosses = 0;
      PrintSeparator();
     }
  }

//====================================================================
// DRAWDOWN AZALTMA - Kârlı + Zararlı Emirleri Birlikte Kapat
//====================================================================
void ManageDrawdownReduction()
  {
   if(!InpEnableDrawdownReduction) return;
   
   int totalOrders = g_buyOrderCount + g_sellOrderCount;
   if(totalOrders < InpDDReductionStartOrders) return;
   
   // Buy emirlerinde DD azaltma
   if(g_buyOrderCount >= 2)
     {
      // En kârlı ve en zararlı buy emrini bul
      int mostProfitableIdx = -1;
      int leastProfitableIdx = -1;
      double maxProfit = -999999;
      double minProfit = 999999;
      
      for(int i = 0; i < g_buyOrderCount; i++)
        {
         if(g_buyOrders[i].profit > maxProfit)
           {
            maxProfit = g_buyOrders[i].profit;
            mostProfitableIdx = i;
           }
         if(g_buyOrders[i].profit < minProfit)
           {
            minProfit = g_buyOrders[i].profit;
            leastProfitableIdx = i;
           }
        }
      
      // Eğer kombine kâr minimum kârın üzerindeyse kapat
      if(mostProfitableIdx >= 0 && leastProfitableIdx >= 0 && 
         mostProfitableIdx != leastProfitableIdx)
        {
         double combinedProfit = maxProfit + minProfit;
         if(combinedProfit >= InpDDReductionMinProfit)
           {
            WriteLog("📉 DD AZALTMA (BUY): Kârlı + Zararlı emir kapatılıyor");
            WriteLog("   Kârlı: $" + DoubleToString(maxProfit, 2) + 
                     " | Zararlı: $" + DoubleToString(minProfit, 2) +
                     " = Net: $" + DoubleToString(combinedProfit, 2));
            
            g_trade.PositionClose(g_buyOrders[mostProfitableIdx].ticket);
            g_trade.PositionClose(g_buyOrders[leastProfitableIdx].ticket);
            
            g_totalProfit += combinedProfit;
            g_totalTrades += 2;
           }
        }
     }
   
   // Sell emirlerinde DD azaltma (aynı mantık)
   if(g_sellOrderCount >= 2)
     {
      int mostProfitableIdx = -1;
      int leastProfitableIdx = -1;
      double maxProfit = -999999;
      double minProfit = 999999;
      
      for(int i = 0; i < g_sellOrderCount; i++)
        {
         if(g_sellOrders[i].profit > maxProfit)
           {
            maxProfit = g_sellOrders[i].profit;
            mostProfitableIdx = i;
           }
         if(g_sellOrders[i].profit < minProfit)
           {
            minProfit = g_sellOrders[i].profit;
            leastProfitableIdx = i;
           }
        }
      
      if(mostProfitableIdx >= 0 && leastProfitableIdx >= 0 && 
         mostProfitableIdx != leastProfitableIdx)
        {
         double combinedProfit = maxProfit + minProfit;
         if(combinedProfit >= InpDDReductionMinProfit)
           {
            WriteLog("📉 DD AZALTMA (SELL): Kârlı + Zararlı emir kapatılıyor");
            g_trade.PositionClose(g_sellOrders[mostProfitableIdx].ticket);
            g_trade.PositionClose(g_sellOrders[leastProfitableIdx].ticket);
            g_totalProfit += combinedProfit;
            g_totalTrades += 2;
           }
        }
     }
  }

//====================================================================
// TRAILING STOP VE BREAKEVEN
//====================================================================
void ManageTrailingAndBreakeven()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);
      double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      
      double profit = (posType == POSITION_TYPE_BUY) ? 
                      (currentPrice - openPrice) : (openPrice - currentPrice);
      
      double beStart = PipsToPoints(InpBreakevenStart);
      double beProfit = PipsToPoints(InpBreakevenProfit);
      double trailStart = PipsToPoints(InpTrailingStart);
      double trailStep = PipsToPoints(InpTrailingStep);
      
      // Breakeven
      if(InpUseBreakeven && profit >= beStart)
        {
         double newSL;
         if(posType == POSITION_TYPE_BUY)
           {
            newSL = NormalizePrice(openPrice + beProfit);
            if(currentSL < newSL)
               g_trade.PositionModify(ticket, newSL, currentTP);
           }
         else
           {
            newSL = NormalizePrice(openPrice - beProfit);
            if(currentSL == 0 || currentSL > newSL)
               g_trade.PositionModify(ticket, newSL, currentTP);
           }
        }
      
      // Trailing Stop
      if(InpUseTrailing && profit >= trailStart)
        {
         double newSL;
         if(posType == POSITION_TYPE_BUY)
           {
            newSL = NormalizePrice(currentPrice - trailStep);
            if(newSL > currentSL)
               g_trade.PositionModify(ticket, newSL, currentTP);
           }
         else
           {
            newSL = NormalizePrice(currentPrice + trailStep);
            if(currentSL == 0 || newSL < currentSL)
               g_trade.PositionModify(ticket, newSL, currentTP);
           }
        }
     }
  }

//====================================================================
// REGRESSION CHANNEL ÇİZ
//====================================================================
void DrawRegressionChannel()
  {
   if(!InpShowRegChannel) return;
   
   string prefix = "RegChannel_";
   ObjectsDeleteAll(0, prefix);
   
   double prices[];
   ArrayResize(prices, InpRegChannelBars);
   
   for(int i = 0; i < InpRegChannelBars; i++)
      prices[i] = iClose(_Symbol, PERIOD_CURRENT, i);
   
   // Lineer regresyon hesapla
   double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
   int n = InpRegChannelBars;
   
   for(int i = 0; i < n; i++)
     {
      sumX += i;
      sumY += prices[i];
      sumXY += i * prices[i];
      sumX2 += i * i;
     }
   
   double slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
   double intercept = (sumY - slope * sumX) / n;
   
   // Standart sapma hesapla
   double sumDev = 0;
   for(int i = 0; i < n; i++)
     {
      double predicted = intercept + slope * i;
      sumDev += MathPow(prices[i] - predicted, 2);
     }
   double stdDev = MathSqrt(sumDev / n);
   
   // Kanal çizgileri
   datetime time1 = iTime(_Symbol, PERIOD_CURRENT, n - 1);
   datetime time2 = iTime(_Symbol, PERIOD_CURRENT, 0);
   
   double price1 = intercept + slope * (n - 1);
   double price2 = intercept;
   
   // Orta çizgi
   ObjectCreate(0, prefix + "Mid", OBJ_TREND, 0, time1, price1, time2, price2);
   ObjectSetInteger(0, prefix + "Mid", OBJPROP_COLOR, InpRegChannelColor);
   ObjectSetInteger(0, prefix + "Mid", OBJPROP_WIDTH, InpRegChannelWidth);
   ObjectSetInteger(0, prefix + "Mid", OBJPROP_RAY_RIGHT, true);
   
   // Üst band
   ObjectCreate(0, prefix + "Upper", OBJ_TREND, 0, time1, price1 + 2*stdDev, time2, price2 + 2*stdDev);
   ObjectSetInteger(0, prefix + "Upper", OBJPROP_COLOR, InpRegChannelColor);
   ObjectSetInteger(0, prefix + "Upper", OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, prefix + "Upper", OBJPROP_RAY_RIGHT, true);
   
   // Alt band
   ObjectCreate(0, prefix + "Lower", OBJ_TREND, 0, time1, price1 - 2*stdDev, time2, price2 - 2*stdDev);
   ObjectSetInteger(0, prefix + "Lower", OBJPROP_COLOR, InpRegChannelColor);
   ObjectSetInteger(0, prefix + "Lower", OBJPROP_STYLE, STYLE_DOT);
   ObjectSetInteger(0, prefix + "Lower", OBJPROP_RAY_RIGHT, true);
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
   
   if(drawdown > g_maxDrawdown)
      g_maxDrawdown = drawdown;
   
   if(drawdown >= InpMaxDrawdownPercent)
     {
      WriteLog("⛔ MAX DRAWDOWN AŞILDI: " + DoubleToString(drawdown, 1) + "%");
      return true;
     }
   
   return false;
  }

//====================================================================
// OnTick - ANA DÖNGÜ
//====================================================================
void OnTick()
  {
   // Pozisyonları güncelle
   UpdateGridPositions();
   
   // Regression channel çiz
   DrawRegressionChannel();
   
   // Drawdown kontrolü
   if(CheckDrawdown())
      return;
   
   // Trailing ve Breakeven
   ManageTrailingAndBreakeven();
   
   // Basket yönetimi (hedef kâr)
   ManageBasket();
   
   // Drawdown azaltma
   ManageDrawdownReduction();
   
   // Yeni bar kontrolü
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(g_lastBarTime == currentBar)
     {
      // Aynı bar içinde grid yönetimi
      ManageGrid();
      return;
     }
   g_lastBarTime = currentBar;
   
   // Güvenlik kontrolleri
   if(!IsSafeToTrade())
      return;
   
   // Sinyal al
   int signal = GetSignal();
   if(signal == 0)
      return;
   
   // İlk emir aç (grid yoksa)
   if(signal == 1 && g_buyOrderCount == 0)
     {
      OpenGridOrder(1, 0);
      g_lastSignal = 1;
     }
   else if(signal == -1 && g_sellOrderCount == 0)
     {
      OpenGridOrder(-1, 0);
      g_lastSignal = -1;
     }
   
   // Çift yönlü grid modunda ters emir de aç
   if(InpGridMode == GRID_BOTH_DIRECTIONS)
     {
      if(signal == 1 && g_sellOrderCount == 0)
         OpenGridOrder(-1, 0);
      else if(signal == -1 && g_buyOrderCount == 0)
         OpenGridOrder(1, 0);
     }
  }
//+------------------------------------------------------------------+
