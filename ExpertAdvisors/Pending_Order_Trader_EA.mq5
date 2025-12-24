//+------------------------------------------------------------------+
//|                                    Pending_Order_Trader_EA.mq5   |
//|                     © 2025, Pending Order Trading System         |
//|                     Martingale / Anti-Martingale Destekli        |
//+------------------------------------------------------------------+
//| AÇIKLAMA:                                                        |
//| - Bekleyen emirler (BuyLimit/SellLimit) ile alım satım yapar     |
//| - Fiyat hedefe gelince emir tetiklenir                           |
//| - Otomatik SL/TP ile risk yönetimi                               |
//| - Martingale veya Anti-Martingale lot stratejisi                 |
//| - Tüm semboller ve tüm zamanlarda çalışır                        |
//+------------------------------------------------------------------+
#property copyright "© 2025, Pending Order Trader"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// ENUM TANIMLARI
//====================================================================
enum ENUM_LOT_MODE
  {
   LOT_NORMAL,        // Normal (Sabit Lot)
   LOT_MARTINGALE,    // Martingale (Kayıpta Artır)
   LOT_ANTI_MARTINGALE // Anti-Martingale (Kazançta Artır)
  };

enum ENUM_PENDING_TYPE
  {
   PENDING_LIMIT,     // Limit Emirleri (BuyLimit/SellLimit)
   PENDING_STOP,      // Stop Emirleri (BuyStop/SellStop)
   PENDING_BOTH       // Her İkisi
  };

enum ENUM_SIGNAL_MODE
  {
   SIGNAL_ALWAYS,     // Her Bar'da Emir Aç
   SIGNAL_MA_CROSS,   // MA Kesişiminde
   SIGNAL_PRICE_LEVEL // Belirli Fiyat Seviyelerinde
  };

//====================================================================
// INPUT PARAMETRELERİ
//====================================================================

//--- 1. ANA AYARLAR
input group "═══ 1. ANA AYARLAR ═══"
input ulong          InpMagicNumber     = 202512;        // 🎰 Magic Number
input string         InpTradeComment    = "PendingTrader"; // 💬 İşlem Yorumu
input ENUM_PENDING_TYPE InpPendingType  = PENDING_LIMIT; // 📋 Bekleyen Emir Tipi

//--- 2. LOT YÖNETİMİ
input group "═══ 2. LOT YÖNETİMİ ═══"
input ENUM_LOT_MODE  InpLotMode         = LOT_MARTINGALE; // 🎲 Lot Modu
input double         InpStartLot        = 0.01;           // 💰 Başlangıç Lot
input double         InpLotStep         = 0.01;           // 📈 Lot Artış Adımı
input double         InpMaxLot          = 0.05;           // 🔝 Maximum Lot
input int            InpMaxSteps        = 5;              // 🔢 Max Kademe (1-5)

//--- 3. PENDING ORDER AYARLARI
input group "═══ 3. PENDING ORDER AYARLARI ═══"
input int            InpPendingDistPips = 20;             // 📏 Emir Mesafesi (pip)
input int            InpSLPips          = 30;             // 🛑 Stop Loss (pip)
input int            InpTPPips          = 50;             // 🎯 Take Profit (pip)
input int            InpExpirationHours = 24;             // ⏰ Emir Geçerlilik (saat)

//--- 4. SİNYAL AYARLARI
input group "═══ 4. SİNYAL AYARLARI ═══"
input ENUM_SIGNAL_MODE InpSignalMode    = SIGNAL_ALWAYS; // 📊 Sinyal Modu
input int            InpMAPeriod        = 20;             // MA Periyodu
input int            InpBarDelay        = 1;              // Bar Bekleme Süresi

//--- 5. RİSK KONTROLÜ
input group "═══ 5. RİSK KONTROLÜ ═══"
input int            InpMaxOpenOrders   = 2;              // 📊 Max Açık Emir
input int            InpMaxOpenTrades   = 2;              // 📊 Max Açık Pozisyon
input bool           InpCloseOnOpposite = true;           // ❌ Ters Sinyalde Kapat
input double         InpMaxDailyLoss    = 100.0;          // 💸 Günlük Max Zarar ($)

//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================
CTrade            g_trade;              // Trade nesnesi

//--- Lot yönetimi
double            g_currentLot;         // Mevcut lot
int               g_currentStep;        // Mevcut kademe (1-5)
int               g_consecutiveWins;    // Ardışık kazanç
int               g_consecutiveLosses;  // Ardışık kayıp

//--- İstatistikler
int               g_totalTrades;        // Toplam işlem
int               g_winTrades;          // Kazanan
int               g_lossTrades;         // Kaybeden
double            g_totalProfit;        // Toplam kar/zarar
double            g_dailyProfit;        // Günlük kar/zarar
datetime          g_lastTradeDate;      // Son işlem tarihi

//--- Kontrol
datetime          g_lastBarTime;        // Son bar zamanı
int               g_barCounter;         // Bar sayacı
ulong             g_lastBuyOrderTicket; // Son buy order ticket
ulong             g_lastSellOrderTicket;// Son sell order ticket

//--- MA Handle
int               g_hMA;                // MA indikatör handle

//====================================================================
// YARDIMCI FONKSİYONLAR
//====================================================================

//+------------------------------------------------------------------+
//| Pip'i Point'e Çevir                                              |
//+------------------------------------------------------------------+
double PipsToPoints(double pips)
  {
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int multiplier = (digits == 3 || digits == 5) ? 10 : 1;
   return pips * multiplier * point;
  }

//+------------------------------------------------------------------+
//| Fiyatı Normalize Et                                              |
//+------------------------------------------------------------------+
double NormalizePrice(double price)
  {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   return NormalizeDouble(price, digits);
  }

//+------------------------------------------------------------------+
//| Log Yaz                                                          |
//+------------------------------------------------------------------+
void WriteLog(string message)
  {
   Print("📋 ", message);
  }

//+------------------------------------------------------------------+
//| Ayırıcı Çizgi                                                    |
//+------------------------------------------------------------------+
void PrintSeparator(string title = "")
  {
   if(title == "")
      Print("════════════════════════════════════════════════════════════════");
   else
      Print("═══════════════ ", title, " ═══════════════");
  }

//====================================================================
// OnInit - EA BAŞLATMA
//====================================================================
int OnInit()
  {
   PrintSeparator("PENDING ORDER TRADER EA");
   
   //--- Trade ayarları
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(10);
   g_trade.SetTypeFilling(ORDER_FILLING_FOK);
   g_trade.SetMarginMode();
   g_trade.LogLevel(LOG_LEVEL_ERRORS);
   
   // Filling tipini sembole göre ayarla
   g_trade.SetTypeFillingBySymbol(_Symbol);
   
   //--- Değişkenleri sıfırla
   g_currentLot = InpStartLot;
   g_currentStep = 1;
   g_consecutiveWins = 0;
   g_consecutiveLosses = 0;
   g_totalTrades = 0;
   g_winTrades = 0;
   g_lossTrades = 0;
   g_totalProfit = 0;
   g_dailyProfit = 0;
   g_lastTradeDate = 0;
   g_lastBarTime = 0;
   g_barCounter = 0;
   g_lastBuyOrderTicket = 0;
   g_lastSellOrderTicket = 0;
   
   //--- MA indikatörü yükle
   if(InpSignalMode == SIGNAL_MA_CROSS)
     {
      g_hMA = iMA(_Symbol, PERIOD_CURRENT, InpMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
      if(g_hMA == INVALID_HANDLE)
        {
         Print("❌ MA indikatörü yüklenemedi!");
         return INIT_FAILED;
        }
     }
   
   //--- Bilgi yazdır
   WriteLog("Sembol: " + _Symbol);
   WriteLog("Lot Modu: " + EnumToString(InpLotMode));
   WriteLog("Başlangıç Lot: " + DoubleToString(InpStartLot, 2));
   WriteLog("Max Lot: " + DoubleToString(InpMaxLot, 2));
   WriteLog("Emir Tipi: " + EnumToString(InpPendingType));
   WriteLog("SL: " + IntegerToString(InpSLPips) + " pip | TP: " + IntegerToString(InpTPPips) + " pip");
   WriteLog("Emir Mesafesi: " + IntegerToString(InpPendingDistPips) + " pip");
   PrintSeparator();
   
   return INIT_SUCCEEDED;
  }

//====================================================================
// OnDeinit - EA KAPANIŞ
//====================================================================
void OnDeinit(const int reason)
  {
   if(g_hMA != INVALID_HANDLE)
      IndicatorRelease(g_hMA);
   
   PrintSeparator("SONUÇLAR");
   WriteLog("Toplam İşlem: " + IntegerToString(g_totalTrades));
   WriteLog("Kazanan: " + IntegerToString(g_winTrades) + " | Kaybeden: " + IntegerToString(g_lossTrades));
   WriteLog("Toplam Kar/Zarar: $" + DoubleToString(g_totalProfit, 2));
   PrintSeparator();
  }

//====================================================================
// LOT HESAPLAMA - Martingale / Anti-Martingale
//====================================================================
double CalculateLot()
  {
   double lot = InpStartLot;
   
   switch(InpLotMode)
     {
      case LOT_NORMAL:
         // Sabit lot
         lot = InpStartLot;
         break;
         
      case LOT_MARTINGALE:
         // Kayıptan sonra lot artır
         // 0.01 → 0.02 → 0.03 → 0.04 → 0.05
         if(g_consecutiveLosses > 0)
           {
            int step = MathMin(g_consecutiveLosses, InpMaxSteps);
            lot = InpStartLot + (step * InpLotStep);
           }
         else
           {
            lot = InpStartLot;
           }
         break;
         
      case LOT_ANTI_MARTINGALE:
         // Kazançtan sonra lot artır
         if(g_consecutiveWins > 0)
           {
            int step = MathMin(g_consecutiveWins, InpMaxSteps);
            lot = InpStartLot + (step * InpLotStep);
           }
         else
           {
            lot = InpStartLot;
           }
         break;
     }
   
   // Max lot sınırı
   lot = MathMin(lot, InpMaxLot);
   
   // Broker limitleri
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   lot = MathFloor(lot / stepLot) * stepLot;
   lot = MathMax(minLot, MathMin(lot, maxLot));
   
   g_currentLot = NormalizeDouble(lot, 2);
   return g_currentLot;
  }

//====================================================================
// AÇIK POZİSYON SAYISI
//====================================================================
int CountOpenPositions()
  {
   int count = 0;
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
        {
         if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
           {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol)
               count++;
           }
        }
     }
   return count;
  }

//====================================================================
// AÇIK EMİR SAYISI
//====================================================================
int CountOpenOrders()
  {
   int count = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
        {
         if(OrderGetInteger(ORDER_MAGIC) == InpMagicNumber)
           {
            if(OrderGetString(ORDER_SYMBOL) == _Symbol)
               count++;
           }
        }
     }
   return count;
  }

//====================================================================
// TÜM BEKLEYENLERİ SİL
//====================================================================
void DeleteAllPendingOrders()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(ticket > 0)
        {
         if(OrderGetInteger(ORDER_MAGIC) == InpMagicNumber)
           {
            if(OrderGetString(ORDER_SYMBOL) == _Symbol)
              {
               g_trade.OrderDelete(ticket);
              }
           }
        }
     }
  }

//====================================================================
// TÜM POZİSYONLARI KAPAT
//====================================================================
void CloseAllPositions()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
        {
         if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber)
           {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol)
              {
               g_trade.PositionClose(ticket);
              }
           }
        }
     }
  }

//====================================================================
// BUY LIMIT EMRİ AÇ
//====================================================================
bool OpenBuyLimit()
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double pendingDist = PipsToPoints(InpPendingDistPips);
   double slDist = PipsToPoints(InpSLPips);
   double tpDist = PipsToPoints(InpTPPips);
   
   double price = NormalizePrice(ask - pendingDist);
   double sl = NormalizePrice(price - slDist);
   double tp = NormalizePrice(price + tpDist);
   
   double lot = CalculateLot();
   string comment = InpTradeComment + "_BL_" + IntegerToString(g_currentStep);
   
   datetime expiration = TimeCurrent() + (InpExpirationHours * 3600);
   
   bool result = g_trade.BuyLimit(lot, price, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, comment);
   
   if(result && g_trade.ResultRetcode() == TRADE_RETCODE_DONE)
     {
      g_lastBuyOrderTicket = g_trade.ResultOrder();
      WriteLog("✅ BUY LIMIT açıldı: Fiyat=" + DoubleToString(price, _Digits) + 
               " | Lot=" + DoubleToString(lot, 2) +
               " | SL=" + DoubleToString(sl, _Digits) + 
               " | TP=" + DoubleToString(tp, _Digits));
      return true;
     }
   else
     {
      WriteLog("❌ BUY LIMIT HATA: " + g_trade.ResultRetcodeDescription());
      return false;
     }
  }

//====================================================================
// SELL LIMIT EMRİ AÇ
//====================================================================
bool OpenSellLimit()
  {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double pendingDist = PipsToPoints(InpPendingDistPips);
   double slDist = PipsToPoints(InpSLPips);
   double tpDist = PipsToPoints(InpTPPips);
   
   double price = NormalizePrice(bid + pendingDist);
   double sl = NormalizePrice(price + slDist);
   double tp = NormalizePrice(price - tpDist);
   
   double lot = CalculateLot();
   string comment = InpTradeComment + "_SL_" + IntegerToString(g_currentStep);
   
   datetime expiration = TimeCurrent() + (InpExpirationHours * 3600);
   
   bool result = g_trade.SellLimit(lot, price, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, comment);
   
   if(result && g_trade.ResultRetcode() == TRADE_RETCODE_DONE)
     {
      g_lastSellOrderTicket = g_trade.ResultOrder();
      WriteLog("✅ SELL LIMIT açıldı: Fiyat=" + DoubleToString(price, _Digits) + 
               " | Lot=" + DoubleToString(lot, 2) +
               " | SL=" + DoubleToString(sl, _Digits) + 
               " | TP=" + DoubleToString(tp, _Digits));
      return true;
     }
   else
     {
      WriteLog("❌ SELL LIMIT HATA: " + g_trade.ResultRetcodeDescription());
      return false;
     }
  }

//====================================================================
// BUY STOP EMRİ AÇ
//====================================================================
bool OpenBuyStop()
  {
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double pendingDist = PipsToPoints(InpPendingDistPips);
   double slDist = PipsToPoints(InpSLPips);
   double tpDist = PipsToPoints(InpTPPips);
   
   double price = NormalizePrice(ask + pendingDist);
   double sl = NormalizePrice(price - slDist);
   double tp = NormalizePrice(price + tpDist);
   
   double lot = CalculateLot();
   string comment = InpTradeComment + "_BS_" + IntegerToString(g_currentStep);
   
   datetime expiration = TimeCurrent() + (InpExpirationHours * 3600);
   
   bool result = g_trade.BuyStop(lot, price, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, comment);
   
   if(result && g_trade.ResultRetcode() == TRADE_RETCODE_DONE)
     {
      g_lastBuyOrderTicket = g_trade.ResultOrder();
      WriteLog("✅ BUY STOP açıldı: Fiyat=" + DoubleToString(price, _Digits) + 
               " | Lot=" + DoubleToString(lot, 2));
      return true;
     }
   else
     {
      WriteLog("❌ BUY STOP HATA: " + g_trade.ResultRetcodeDescription());
      return false;
     }
  }

//====================================================================
// SELL STOP EMRİ AÇ
//====================================================================
bool OpenSellStop()
  {
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double pendingDist = PipsToPoints(InpPendingDistPips);
   double slDist = PipsToPoints(InpSLPips);
   double tpDist = PipsToPoints(InpTPPips);
   
   double price = NormalizePrice(bid - pendingDist);
   double sl = NormalizePrice(price + slDist);
   double tp = NormalizePrice(price - tpDist);
   
   double lot = CalculateLot();
   string comment = InpTradeComment + "_SS_" + IntegerToString(g_currentStep);
   
   datetime expiration = TimeCurrent() + (InpExpirationHours * 3600);
   
   bool result = g_trade.SellStop(lot, price, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, comment);
   
   if(result && g_trade.ResultRetcode() == TRADE_RETCODE_DONE)
     {
      g_lastSellOrderTicket = g_trade.ResultOrder();
      WriteLog("✅ SELL STOP açıldı: Fiyat=" + DoubleToString(price, _Digits) + 
               " | Lot=" + DoubleToString(lot, 2));
      return true;
     }
   else
     {
      WriteLog("❌ SELL STOP HATA: " + g_trade.ResultRetcodeDescription());
      return false;
     }
  }

//====================================================================
// İŞLEM SONUCU KONTROLÜ - OnTradeTransaction
//====================================================================
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
   // Deal tamamlandığında
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
     {
      // Bizim işlemimiz mi kontrol et
      if(trans.order_state == ORDER_STATE_FILLED || trans.deal_type == DEAL_TYPE_BUY || trans.deal_type == DEAL_TYPE_SELL)
        {
         // History'den deal bilgisini al
         if(HistoryDealSelect(trans.deal))
           {
            ulong magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
            if(magic == InpMagicNumber)
              {
               ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
               
               // Pozisyon kapanışı (çıkış)
               if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY)
                 {
                  double profit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT);
                  double commission = HistoryDealGetDouble(trans.deal, DEAL_COMMISSION);
                  double swap = HistoryDealGetDouble(trans.deal, DEAL_SWAP);
                  double netProfit = profit + commission + swap;
                  
                  g_totalProfit += netProfit;
                  g_dailyProfit += netProfit;
                  g_totalTrades++;
                  
                  if(netProfit >= 0)
                    {
                     g_winTrades++;
                     g_consecutiveWins++;
                     g_consecutiveLosses = 0;
                     
                     // Anti-Martingale: Kazançta kademe artır
                     if(InpLotMode == LOT_ANTI_MARTINGALE)
                       {
                        g_currentStep = MathMin(g_currentStep + 1, InpMaxSteps);
                       }
                     // Martingale: Kazançta sıfırla
                     else if(InpLotMode == LOT_MARTINGALE)
                       {
                        g_currentStep = 1;
                       }
                     
                     PrintSeparator();
                     WriteLog("🏆 KAZANÇ: $" + DoubleToString(netProfit, 2) + 
                              " | Ardışık: " + IntegerToString(g_consecutiveWins) +
                              " | Sonraki Lot: " + DoubleToString(CalculateLot(), 2));
                     PrintSeparator();
                    }
                  else
                    {
                     g_lossTrades++;
                     g_consecutiveLosses++;
                     g_consecutiveWins = 0;
                     
                     // Martingale: Kayıpta kademe artır
                     if(InpLotMode == LOT_MARTINGALE)
                       {
                        g_currentStep = MathMin(g_currentStep + 1, InpMaxSteps);
                       }
                     // Anti-Martingale: Kayıpta sıfırla
                     else if(InpLotMode == LOT_ANTI_MARTINGALE)
                       {
                        g_currentStep = 1;
                       }
                     
                     PrintSeparator();
                     WriteLog("❌ KAYIP: $" + DoubleToString(netProfit, 2) + 
                              " | Ardışık: " + IntegerToString(g_consecutiveLosses) +
                              " | Sonraki Lot: " + DoubleToString(CalculateLot(), 2));
                     PrintSeparator();
                    }
                 }
              }
           }
        }
     }
  }

//====================================================================
// SİNYAL KONTROLÜ
//====================================================================
int GetSignal()
  {
   // 0 = sinyal yok, 1 = buy, -1 = sell
   
   switch(InpSignalMode)
     {
      case SIGNAL_ALWAYS:
         // Her bar'da hem buy hem sell emir aç
         return 2; // Özel kod: her ikisi
         
      case SIGNAL_MA_CROSS:
         {
          double ma[];
          ArraySetAsSeries(ma, true);
          if(CopyBuffer(g_hMA, 0, 0, 3, ma) < 3)
             return 0;
          
          double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
          double close2 = iClose(_Symbol, PERIOD_CURRENT, 2);
          
          // Fiyat MA'yı yukarı kesti
          if(close2 < ma[2] && close1 > ma[1])
             return 1;
          
          // Fiyat MA'yı aşağı kesti
          if(close2 > ma[2] && close1 < ma[1])
             return -1;
          
          return 0;
         }
         
      case SIGNAL_PRICE_LEVEL:
         // Basit: Son bar yükseliş = buy, düşüş = sell
         {
          double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
          double open1 = iOpen(_Symbol, PERIOD_CURRENT, 1);
          
          if(close1 > open1)
             return 1;
          else if(close1 < open1)
             return -1;
          
          return 0;
         }
     }
   
   return 0;
  }

//====================================================================
// OnTick - ANA DÖNGÜ
//====================================================================
void OnTick()
  {
   //--- Günlük zarar kontrolü
   MqlDateTime dt;
   TimeCurrent(dt);
   datetime today = StringToTime(IntegerToString(dt.year) + "." + IntegerToString(dt.mon) + "." + IntegerToString(dt.day));
   
   if(today != g_lastTradeDate)
     {
      g_dailyProfit = 0;
      g_lastTradeDate = today;
     }
   
   if(g_dailyProfit < -InpMaxDailyLoss)
     {
      // Günlük zarar limitine ulaşıldı
      return;
     }
   
   //--- Yeni bar kontrolü
   datetime currentBar = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(g_lastBarTime == currentBar)
      return; // Aynı bar, işlem yapma
   g_lastBarTime = currentBar;
   g_barCounter++;
   
   //--- Bar bekleme
   if(g_barCounter < InpBarDelay)
      return;
   
   //--- Açık emir/pozisyon kontrolü
   int openOrders = CountOpenOrders();
   int openPositions = CountOpenPositions();
   
   //--- Max limit kontrolü
   if(openOrders >= InpMaxOpenOrders)
      return;
   
   if(openPositions >= InpMaxOpenTrades)
      return;
   
   //--- Sinyal al
   int signal = GetSignal();
   
   if(signal == 0)
      return; // Sinyal yok
   
   //--- Emir aç
   if(InpPendingType == PENDING_LIMIT || InpPendingType == PENDING_BOTH)
     {
      if(signal == 1 || signal == 2)
        {
         if(openOrders < InpMaxOpenOrders)
            OpenBuyLimit();
        }
      
      if(signal == -1 || signal == 2)
        {
         if(CountOpenOrders() < InpMaxOpenOrders)
            OpenSellLimit();
        }
     }
   
   if(InpPendingType == PENDING_STOP || InpPendingType == PENDING_BOTH)
     {
      if(signal == 1 || signal == 2)
        {
         if(CountOpenOrders() < InpMaxOpenOrders)
            OpenBuyStop();
        }
      
      if(signal == -1 || signal == 2)
        {
         if(CountOpenOrders() < InpMaxOpenOrders)
            OpenSellStop();
        }
     }
  }
//+------------------------------------------------------------------+
