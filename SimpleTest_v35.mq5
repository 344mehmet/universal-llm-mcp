//+------------------------------------------------------------------+
//|                                       SimpleTest_v35.mq5         |
//|                      Diagnostic Test EA for v35 Troubleshooting  |
//+------------------------------------------------------------------+
#property copyright "Test EA"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>

CTrade trade;
bool g_tradeAttempted = false;

//+------------------------------------------------------------------+
int OnInit()
{
   Print("========================================");
   Print("SIMPLE TEST EA STARTED");
   Print("Symbol: ", _Symbol);
   Print("Period: ", EnumToString(Period()));
   Print("Balance: ", AccountInfoDouble(ACCOUNT_BALANCE));
   Print("========================================");
   
   trade.SetExpertMagicNumber(999888);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
void OnTick()
{
   // Sadece bir kez işlem aç
   if(g_tradeAttempted) return;
   
   Print("🔵 OnTick çalıştı - İşlem açılacak");
   
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   Print("🔵 Ask: ", ask, " Bid: ", bid);
   
   double lot = 0.01;
   double sl = 0;  // SL/TP yok - basit test
   double tp = 0;
   
   Print("🔵 Market BUY emri gönderiliyor...");
   Print("🔵 Lot: ", lot, " SL: ", sl, " TP: ", tp);
   
   bool result = trade.Buy(lot, _Symbol, 0, sl, tp, "Test");
   
   if(result)
   {
      Print("✅ İŞLEM BAŞARILI! Ticket: ", trade.ResultOrder());
      Print("✅ Result Code: ", trade.ResultRetcode());
   }
   else
   {
      Print("❌ İŞLEM BAŞARISIZ!");
      Print("❌ Error Code: ", trade.ResultRetcode());
      Print("❌ Error Description: ", trade.ResultRetcodeDescription());
      Print("❌ Comment: ", trade.ResultComment());
   }
   
   g_tradeAttempted = true;
}
//+------------------------------------------------------------------+
