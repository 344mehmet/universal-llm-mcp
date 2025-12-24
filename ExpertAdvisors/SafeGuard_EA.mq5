//+------------------------------------------------------------------+
//|                                                 SafeGuard_EA.mq5 |
//|                                  Copyright 2025, Antigravity AI  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Antigravity AI"
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>

//--- Girdi Parametreleri
input double   InpLotSize     = 0.01;     // İşlem Hacmi (Sabit)
input int      InpStopLoss    = 200;      // Zarar Durdur (Puan - 20 Pips)
input int      InpTakeProfit  = 300;      // Kar Al (Puan - 30 Pips)
input double   InpDailyLoss   = 4.0;      // Günlük Maksimum Kayıp ($)
input int      InpMagicNum    = 123456;   // Sihirli Numara
input int      InpEMAPeriod   = 200;      // EMA Periyodu
input int      InpRSIPeriod   = 14;       // RSI Periyodu

//--- Global Değişkenler
CTrade         trade;
int            handleEMA;
int            handleRSI;
datetime       lastTradeDay;
double         dailyLossAccumulated = 0.0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   //--- Gösterge Handle'larını Oluştur
   handleEMA = iMA(_Symbol, _Period, InpEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   handleRSI = iRSI(_Symbol, _Period, InpRSIPeriod, PRICE_CLOSE);

   if(handleEMA == INVALID_HANDLE || handleRSI == INVALID_HANDLE)
     {
      Print("Göstergeler oluşturulamadı!");
      return(INIT_FAILED);
     }

   //--- Trade Ayarları
   trade.SetExpertMagicNumber(InpMagicNum);
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(handleEMA);
   IndicatorRelease(handleRSI);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   //--- 1. Günlük Kayıp Kontrolü
   CheckDailyLossReset();
   if(dailyLossAccumulated >= InpDailyLoss)
     {
      Comment("GÜNLÜK KAYIP LİMİTİNE ULAŞILDI. İŞLEM YAPILMIYOR.");
      return;
     }

   //--- 2. Açık Pozisyon Kontrolü (Sadece 1 işlem)
   if(PositionsTotal() > 0) return;

   //--- 3. Verileri Al
   double ema[], rsi[];
   ArraySetAsSeries(ema, true);
   ArraySetAsSeries(rsi, true);

   if(CopyBuffer(handleEMA, 0, 0, 3, ema) < 3 || CopyBuffer(handleRSI, 0, 0, 3, rsi) < 3) return;

   double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   //--- 4. Alış Sinyali (Trend Yukarı + RSI Aşırı Satımdan Dönüş)
   // Fiyat EMA'nın üzerinde
   // RSI önceki mumda 30'un altındaydı, şimdi 30'un üzerine çıktı
   if(currentPrice > ema[0] && rsi[1] < 30 && rsi[0] > 30)
     {
      double sl = currentPrice - InpStopLoss * _Point;
      double tp = currentPrice + InpTakeProfit * _Point;
      
      if(trade.Buy(InpLotSize, _Symbol, currentPrice, sl, tp, "SafeGuard Buy"))
        {
         Print("Alış İşlemi Açıldı");
        }
     }

   //--- 5. Satış Sinyali (Trend Aşağı + RSI Aşırı Alımdan Dönüş)
   // Fiyat EMA'nın altında
   // RSI önceki mumda 70'in üzerindeydi, şimdi 70'in altına indi
   if(currentPrice < ema[0] && rsi[1] > 70 && rsi[0] < 70)
     {
      double sl = currentPrice + InpStopLoss * _Point;
      double tp = currentPrice - InpTakeProfit * _Point;
      
      if(trade.Sell(InpLotSize, _Symbol, currentPrice, sl, tp, "SafeGuard Sell"))
        {
         Print("Satış İşlemi Açıldı");
        }
     }
     
   Comment("Günlük Kayıp: ", DoubleToString(dailyLossAccumulated, 2), " / ", DoubleToString(InpDailyLoss, 2));
  }

//+------------------------------------------------------------------+
//| Günlük Kayıp Sıfırlama ve Hesaplama                              |
//+------------------------------------------------------------------+
void CheckDailyLossReset()
  {
   datetime currentTime = TimeCurrent();
   MqlDateTime tm;
   TimeToStruct(currentTime, tm);
   
   // Yeni gün kontrolü
   if(tm.day != TimeDay(lastTradeDay))
     {
      dailyLossAccumulated = 0.0;
      lastTradeDay = currentTime;
     }
     
   // Geçmiş işlemleri kontrol et (Bugünkü kayıpları topla)
   HistorySelect(iTime(_Symbol, PERIOD_D1, 0), TimeCurrent());
   int deals = HistoryDealsTotal();
   
   double todayLoss = 0;
   
   for(int i = 0; i < deals; i++)
     {
      ulong ticket = HistoryDealGetTicket(i);
      if(ticket > 0)
        {
         double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
         if(profit < 0) todayLoss += MathAbs(profit);
        }
     }
     
   dailyLossAccumulated = todayLoss;
  }

int TimeDay(datetime time)
{
   MqlDateTime tm;
   TimeToStruct(time, tm);
   return tm.day;
}
