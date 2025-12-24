//+------------------------------------------------------------------+
//|                                       UltraSimple.mq5            |
//|                      EN BASİT TEST - OnInit'te işlem açar        |
//+------------------------------------------------------------------+
#property copyright "Test"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>

//+------------------------------------------------------------------+
int OnInit()
{
   Print("========================================");
   Print("ULTRA SIMPLE TEST BAŞLATILDI");
   Print("========================================");
   
   // CTrade nesnesi oluştur
   CTrade trade;
   trade.SetExpertMagicNumber(888777);
   
   // 2 saniye bekle
   Sleep(2000);
   
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double lot = 0.01;
   
   // ==================== BUY İŞLEMİ ====================
   Print(">> Market BUY emri gönderiliyor...");
   Print(">> Symbol: ", _Symbol);
   Print(">> Ask: ", ask);
   Print(">> Lot: ", lot);
   
   bool resultBuy = trade.Buy(lot);
   
   if(resultBuy)
   {
      Print("✅✅✅ BUY BAŞARILI! Ticket: ", trade.ResultOrder());
   }
   else
   {
      Print("❌❌❌ BUY BAŞARISIZ!");
      Print("❌ Error Code: ", trade.ResultRetcode());
      Print("❌ Description: ", trade.ResultRetcodeDescription());
      Print("❌ Comment: ", trade.ResultComment());
   }
   
   // 1 saniye ara
   Sleep(1000);
   
   // ==================== SELL İŞLEMİ ====================
   Print(">> Market SELL emri gönderiliyor...");
   Print(">> Bid: ", bid);
   Print(">> Lot: ", lot);
   
   bool resultSell = trade.Sell(lot);
   
   if(resultSell)
   {
      Print("✅✅✅ SELL BAŞARILI! Ticket: ", trade.ResultOrder());
   }
   else
   {
      Print("❌❌❌ SELL BAŞARISIZ!");
      Print("❌ Error Code: ", trade.ResultRetcode());
      Print("❌ Description: ", trade.ResultRetcodeDescription());
      Print("❌ Comment: ", trade.ResultComment());
   }
   
   // Sonuç bildirimi
   if(resultBuy && resultSell)
   {
      Alert("✅ HER İKİ İŞLEM DE BAŞARILI! BUY ve SELL açıldı.");
   }
   else
   {
      Alert("⚠️ SORUN VAR! BUY:", resultBuy, " SELL:", resultSell);
   }
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnTick()
{
   // Boş - OnTick'te hiçbir şey yapmıyor
}
//+------------------------------------------------------------------+
