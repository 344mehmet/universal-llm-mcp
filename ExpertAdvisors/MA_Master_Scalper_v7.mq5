//+------------------------------------------------------------------+
//|                                      MA_Master_Scalper_v7.mq5    |
//|                     © 2025, Milyoner EA Project v7.0             |
//|                 MTF + RSI EXTREME + ENGULFING + PENDING          |
//+------------------------------------------------------------------+
#property copyright "© 2025, Milyoner EA v7"
#property version   "7.00"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// v7 SİNYAL DOĞRULUK İYİLEŞTİRMELERİ:
// [1] MTF Trend Onayı - H1 trend yönü zorunlu
// [2] RSI Extreme Zones - 10/90 seviyeleri
// [3] MACD Zero Line Filter - Histogram yönü
// [4] Engulfing Pattern Onayı - Mum formasyonu
// [5] Gelişmiş Bekleyen Emir Sistemi
//====================================================================

enum ENUM_ENTRY_MODE { ENTRY_MARKET, ENTRY_PENDING, ENTRY_BOTH };

//====================================================================
// INPUT PARAMETRELERİ
//====================================================================
input group "═══ 1. ANA AYARLAR v7 ═══"
input ulong    MagicNumber     = 777777;
input string   TradeComment    = "MILYONER_v7";
input ENUM_TIMEFRAMES EntryTF  = PERIOD_M5;       // Giriş Timeframe
input ENUM_TIMEFRAMES TrendTF  = PERIOD_H1;       // Trend Timeframe (MTF)

input group "═══ 2. MTF TREND FİLTRESİ ═══"
input bool     UseMTFTrend     = true;            // ✅ MTF Trend Zorunlu
input int      MTF_EMA_Period  = 50;              // MTF EMA Periyodu

input group "═══ 3. RSI EXTREME ZONES ═══"
input int      RSI_Period      = 6;               // Hızlı RSI
input int      RSI_ExtremeLow  = 25;              // v7.1: Gevşetildi (25)
input int      RSI_ExtremeHigh = 75;              // v7.1: Gevşetildi (75)
input bool     WaitRSIExtreme  = true;            // ✅ Extreme beklenmeli

input group "═══ 4. MACD ZERO LINE ═══"
input int      MACD_Fast       = 12;
input int      MACD_Slow       = 26;
input int      MACD_Signal     = 9;
input bool     MACDAboveZero   = true;            // ✅ Zero line filtresi

input group "═══ 5. ENGULFING PATTERN ═══"
input bool     UseEngulfing    = false;           // v7.1: KAPALI (daha fazla sinyal)
input double   EngulfMinRatio  = 1.2;             // v7.1: Düşürüldü

input group "═══ 6. BEKLEYEN EMİR ═══"
input ENUM_ENTRY_MODE EntryMode = ENTRY_BOTH;
input double   PendingPips     = 5.0;             // Bekleyen mesafe
input int      PendingExpire   = 3;               // Bar sonra iptal

input group "═══ 7. SL/TP ═══"
input bool     UseATR          = true;
input int      ATR_Period      = 14;
input double   ATR_SL          = 1.5;
input double   ATR_TP          = 3.0;             // R:R = 1:2
input int      MinSL           = 5;
input int      MaxSL           = 30;
input int      FixedSL         = 15;
input int      FixedTP         = 30;

input group "═══ 8. RİSK ═══"
input double   RiskPct         = 1.0;
input double   MaxLot          = 1.0;
input double   MaxDD           = 25.0;

input group "═══ 9. COOLDOWN ═══"
input int      Cooldown        = 2;               // Bar bekleme
input int      MaxSpread       = 4;

//====================================================================
// GLOBAL
//====================================================================
int g_hMACD, g_hRSI, g_hATR, g_hEMA_Entry, g_hEMA_MTF;
CTrade m_trade;
double g_atr = 0, g_eqHigh = 0, g_maxDD = 0;
datetime g_lastBar = 0;
int g_barCount = 0, g_total = 0, g_wins = 0;
double g_profit = 0, g_grossP = 0, g_grossL = 0;
string g_state = "INIT";

//====================================================================
// HELPER
//====================================================================
double Pip2Pt(double p) { return p * (SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)>=4?10:1) * SymbolInfoDouble(_Symbol,SYMBOL_POINT); }
double Pt2Pip(double p) { return p / ((SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)>=4?10:1) * SymbolInfoDouble(_Symbol,SYMBOL_POINT)); }

double NormLot(double lot) {
   double mn=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN);
   double mx=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX);
   double st=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(st<=0)st=0.01;
   lot=MathFloor(lot/st)*st;
   lot=MathMax(mn,MathMin(lot,MathMin(mx,MaxLot)));
   double margin=0,price=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double free=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   if(OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,lot,price,margin)){
      while(margin>free*0.5&&lot>mn){
         lot=MathFloor((lot*0.5)/st)*st;
         lot=MathMax(lot,mn);
         if(!OrderCalcMargin(ORDER_TYPE_BUY,_Symbol,lot,price,margin))break;
      }
   }
   return lot;
}

//====================================================================
// OnInit
//====================================================================
int OnInit(){
   m_trade.SetExpertMagicNumber(MagicNumber);
   m_trade.SetDeviationInPoints(15);
   m_trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   g_hMACD=iMACD(_Symbol,EntryTF,MACD_Fast,MACD_Slow,MACD_Signal,PRICE_CLOSE);
   g_hRSI=iRSI(_Symbol,EntryTF,RSI_Period,PRICE_CLOSE);
   g_hATR=iATR(_Symbol,EntryTF,ATR_Period);
   g_hEMA_Entry=iMA(_Symbol,EntryTF,MTF_EMA_Period,0,MODE_EMA,PRICE_CLOSE);
   g_hEMA_MTF=iMA(_Symbol,TrendTF,MTF_EMA_Period,0,MODE_EMA,PRICE_CLOSE);
   
   if(g_hMACD==INVALID_HANDLE||g_hRSI==INVALID_HANDLE){
      Print("❌ Indicator error");
      return INIT_FAILED;
   }
   g_eqHigh=AccountInfoDouble(ACCOUNT_EQUITY);
   
   Print("═══════════════════════════════════════════════════════════");
   Print("🎯 MİLYONER EA v7.0 - MTF + RSI EXTREME + ENGULFING");
   Print("═══════════════════════════════════════════════════════════");
   Print("📊 Entry: ",EnumToString(EntryTF)," | Trend: ",EnumToString(TrendTF));
   Print("🔥 RSI Extreme: <",RSI_ExtremeLow," / >",RSI_ExtremeHigh);
   Print("═══════════════════════════════════════════════════════════");
   return INIT_SUCCEEDED;
}

void OnDeinit(const int r){
   IndicatorRelease(g_hMACD);IndicatorRelease(g_hRSI);
   IndicatorRelease(g_hATR);IndicatorRelease(g_hEMA_Entry);IndicatorRelease(g_hEMA_MTF);
   double pf=g_grossL!=0?g_grossP/MathAbs(g_grossL):0;
   double wr=g_total>0?g_wins*100.0/g_total:0;
   Print("═══════════════════════════════════════════════════════════");
   Print("📊 v7: ",g_total," trades | WR: ",DoubleToString(wr,1),"%");
   Print("⚖️ PF: ",DoubleToString(pf,2)," | Net: $",DoubleToString(g_profit,2));
   Print("═══════════════════════════════════════════════════════════");
   ObjectsDeleteAll(0,"MIL_");
}

//====================================================================
// OnTick
//====================================================================
void OnTick(){
   UpdateATR();
   
   double eq=AccountInfoDouble(ACCOUNT_EQUITY);
   if(eq>g_eqHigh)g_eqHigh=eq;
   double dd=g_eqHigh>0?(g_eqHigh-eq)/g_eqHigh*100:0;
   if(dd>g_maxDD)g_maxDD=dd;
   if(dd>=MaxDD){g_state="⛔ MAX DD";return;}
   
   if(SymbolInfoInteger(_Symbol,SYMBOL_SPREAD)/10.0>MaxSpread){g_state="⚠️ SPREAD";return;}
   
   datetime bar=iTime(_Symbol,EntryTF,0);
   if(g_lastBar!=bar){g_lastBar=bar;g_barCount++;}
   
   ManagePending();
   
   if(HasPos()){g_state="📊 OPEN";return;}
   if(g_barCount<Cooldown){g_state="⏳ WAIT";return;}
   
   int sig=GetSignal();
   if(sig!=0){
      if(EntryMode==ENTRY_MARKET||EntryMode==ENTRY_BOTH)OpenMarket(sig);
      if(EntryMode==ENTRY_PENDING||EntryMode==ENTRY_BOTH)PlacePending(sig);
      g_barCount=0;
   }
}

//====================================================================
// v7.1 SİNYAL SİSTEMİ - GEVŞETİLMİŞ
//====================================================================
int GetSignal(){
   //=== 1. MTF TREND ===
   double mtfEMA[];ArraySetAsSeries(mtfEMA,true);ArrayResize(mtfEMA,1);
   CopyBuffer(g_hEMA_MTF,0,0,1,mtfEMA);
   double mtfPrice=iClose(_Symbol,TrendTF,0);
   int mtfTrend=(mtfPrice>mtfEMA[0])?1:(mtfPrice<mtfEMA[0])?-1:0;
   
   // MTF zorunlu değilse her iki yönde işlem al
   if(!UseMTFTrend) mtfTrend = 0;
   
   //=== 2. RSI ===
   double rsi[];ArraySetAsSeries(rsi,true);ArrayResize(rsi,3);
   CopyBuffer(g_hRSI,0,0,3,rsi);
   
   // v7.1: Daha geniş RSI aralığı
   bool rsiBuyZone = (rsi[0] < 50);              // RSI orta altında
   bool rsiSellZone = (rsi[0] > 50);             // RSI orta üstünde
   bool rsiRecoveryBuy = (rsi[0] > rsi[1]);      // RSI yükseliyor
   bool rsiRecoverySell = (rsi[0] < rsi[1]);     // RSI düşüyor
   
   // Opsiyonel extreme kontrolü
   if(WaitRSIExtreme){
      rsiBuyZone = (rsi[1] <= RSI_ExtremeLow || rsi[2] <= RSI_ExtremeLow);
      rsiSellZone = (rsi[1] >= RSI_ExtremeHigh || rsi[2] >= RSI_ExtremeHigh);
   }
   
   //=== 3. MACD ===
   double hist[];ArraySetAsSeries(hist,true);ArrayResize(hist,2);
   CopyBuffer(g_hMACD,2,0,2,hist);
   
   bool macdBuy = (hist[0] > hist[1]);           // Histogram artıyor
   bool macdSell = (hist[0] < hist[1]);          // Histogram azalıyor
   
   // Opsiyonel zero line kontrolü
   if(MACDAboveZero){
      macdBuy = macdBuy && (hist[0] > 0 || hist[0] > hist[1]);
      macdSell = macdSell && (hist[0] < 0 || hist[0] < hist[1]);
   }
   
   //=== 4. ENGULFING ===
   bool engulfOK = true;
   if(UseEngulfing){
      if(mtfTrend >= 0) engulfOK = IsBullishEngulfing();
      else engulfOK = IsBearishEngulfing();
      if(!engulfOK){g_state="⏳ ENGULF";return 0;}
   }
   
   //=== v7.1 SİNYAL KARAR ===
   // BUY: MTF yukarı (veya nötr) + RSI düşük bölge + MACD artıyor
   if((mtfTrend >= 0) && rsiBuyZone && rsiRecoveryBuy && macdBuy){
      g_state="🟢 BUY!";
      Print("✅ v7.1 BUY: RSI=",DoubleToString(rsi[0],1)," MACD↑ MTF=",mtfTrend);
      return 1;
   }
   
   // SELL: MTF aşağı (veya nötr) + RSI yüksek bölge + MACD azalıyor
   if((mtfTrend <= 0) && rsiSellZone && rsiRecoverySell && macdSell){
      g_state="🔴 SELL!";
      Print("✅ v7.1 SELL: RSI=",DoubleToString(rsi[0],1)," MACD↓ MTF=",mtfTrend);
      return -1;
   }
   
   g_state="⏳ BEKLE";
   return 0;
}

//====================================================================
// ENGULFING PATTERN TESPİTİ
//====================================================================
bool IsBullishEngulfing(){
   double o1=iOpen(_Symbol,EntryTF,1), c1=iClose(_Symbol,EntryTF,1);
   double o2=iOpen(_Symbol,EntryTF,2), c2=iClose(_Symbol,EntryTF,2);
   
   bool prevBearish=(c2<o2);         // Önceki mum kırmızı
   bool currBullish=(c1>o1);         // Son mum yeşil
   bool engulfs=(c1>o2&&o1<c2);      // Tamamen yutmuş
   
   double prevBody=MathAbs(c2-o2);
   double currBody=MathAbs(c1-o1);
   bool ratio=(currBody>=prevBody*EngulfMinRatio);
   
   return prevBearish&&currBullish&&engulfs&&ratio;
}

bool IsBearishEngulfing(){
   double o1=iOpen(_Symbol,EntryTF,1), c1=iClose(_Symbol,EntryTF,1);
   double o2=iOpen(_Symbol,EntryTF,2), c2=iClose(_Symbol,EntryTF,2);
   
   bool prevBullish=(c2>o2);
   bool currBearish=(c1<o1);
   bool engulfs=(c1<o2&&o1>c2);
   
   double prevBody=MathAbs(c2-o2);
   double currBody=MathAbs(c1-o1);
   bool ratio=(currBody>=prevBody*EngulfMinRatio);
   
   return prevBullish&&currBearish&&engulfs&&ratio;
}

//====================================================================
// BEKLEYEN EMİR
//====================================================================
void ManagePending(){
   for(int i=OrdersTotal()-1;i>=0;i--){
      ulong t=OrderGetTicket(i);
      if(t==0||OrderGetInteger(ORDER_MAGIC)!=MagicNumber)continue;
      if(OrderGetString(ORDER_SYMBOL)!=_Symbol)continue;
      
      datetime pt=(datetime)OrderGetInteger(ORDER_TIME_SETUP);
      int bars=(int)((TimeCurrent()-pt)/PeriodSeconds(EntryTF));
      if(bars>=PendingExpire){
         m_trade.OrderDelete(t);
         Print("⏰ Pending expired #",t);
      }
   }
}

void PlacePending(int dir){
   if(HasPending())return;
   int d=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double dist=Pip2Pt(PendingPips);
   double lot=CalcLot();
   double slD=GetSLDist(),tpD=GetTPDist();
   
   if(dir==1){
      double price=NormalizeDouble(ask+dist,d);
      double sl=NormalizeDouble(price-slD,d);
      double tp=NormalizeDouble(price+tpD,d);
      m_trade.OrderOpen(_Symbol,ORDER_TYPE_BUY_STOP,lot,0,price,sl,tp,ORDER_TIME_GTC,0,TradeComment);
      Print("📋 BUY_STOP @ ",DoubleToString(price,d));
   }else{
      double price=NormalizeDouble(bid-dist,d);
      double sl=NormalizeDouble(price+slD,d);
      double tp=NormalizeDouble(price-tpD,d);
      m_trade.OrderOpen(_Symbol,ORDER_TYPE_SELL_STOP,lot,0,price,sl,tp,ORDER_TIME_GTC,0,TradeComment);
      Print("📋 SELL_STOP @ ",DoubleToString(price,d));
   }
}

void OpenMarket(int dir){
   if(HasPos())return;
   double lot=CalcLot();
   int d=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);
   double slD=GetSLDist(),tpD=GetTPDist();
   double price,sl,tp;
   
   if(dir==1){
      price=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
      sl=NormalizeDouble(price-slD,d);
      tp=NormalizeDouble(price+tpD,d);
      m_trade.Buy(lot,_Symbol,0,sl,tp,TradeComment);
   }else{
      price=SymbolInfoDouble(_Symbol,SYMBOL_BID);
      sl=NormalizeDouble(price+slD,d);
      tp=NormalizeDouble(price-tpD,d);
      m_trade.Sell(lot,_Symbol,0,sl,tp,TradeComment);
   }
   if(m_trade.ResultRetcode()==TRADE_RETCODE_DONE){
      g_total++;
      Print("✅ ",(dir==1?"BUY":"SELL")," @ ",DoubleToString(m_trade.ResultPrice(),d)," Lot:",DoubleToString(lot,2));
   }
}

//====================================================================
// YARDIMCI
//====================================================================
double GetSLDist(){
   if(UseATR&&g_atr>0){
      double d=g_atr*ATR_SL;
      return MathMax(Pip2Pt(MinSL),MathMin(d,Pip2Pt(MaxSL)));
   }
   return Pip2Pt(FixedSL);
}

double GetTPDist(){
   if(UseATR&&g_atr>0)return g_atr*ATR_TP;
   return Pip2Pt(FixedTP);
}

double CalcLot(){
   double bal=AccountInfoDouble(ACCOUNT_BALANCE);
   double risk=bal*RiskPct/100.0;
   double slPip=UseATR?Pt2Pip(g_atr*ATR_SL):FixedSL;
   slPip=MathMax(slPip,MinSL);
   double tv=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   if(tv<=0)tv=10;
   return NormLot(risk/(slPip*tv*10));
}

void UpdateATR(){
   double a[];ArrayResize(a,1);ArraySetAsSeries(a,true);
   if(CopyBuffer(g_hATR,0,0,1,a)>=1)g_atr=a[0];
}

bool HasPos(){
   for(int i=PositionsTotal()-1;i>=0;i--){
      ulong t=PositionGetTicket(i);
      if(t>0&&PositionGetInteger(POSITION_MAGIC)==MagicNumber&&PositionGetString(POSITION_SYMBOL)==_Symbol)return true;
   }
   return false;
}

bool HasPending(){
   for(int i=OrdersTotal()-1;i>=0;i--){
      ulong t=OrderGetTicket(i);
      if(t>0&&OrderGetInteger(ORDER_MAGIC)==MagicNumber&&OrderGetString(ORDER_SYMBOL)==_Symbol)return true;
   }
   return false;
}

void OnTradeTransaction(const MqlTradeTransaction& t,const MqlTradeRequest& r,const MqlTradeResult& res){
   if(t.type==TRADE_TRANSACTION_DEAL_ADD){
      if(t.deal_type==DEAL_TYPE_BUY||t.deal_type==DEAL_TYPE_SELL)return;
      ulong tk=t.deal;
      if(tk>0&&HistoryDealSelect(tk)){
         double pf=HistoryDealGetDouble(tk,DEAL_PROFIT);
         if(HistoryDealGetInteger(tk,DEAL_MAGIC)==MagicNumber){
            g_profit+=pf;
            if(pf>0){g_wins++;g_grossP+=pf;Print("🎉 WIN +$",DoubleToString(pf,2));}
            else{g_grossL+=pf;Print("💔 LOSS $",DoubleToString(pf,2));}
         }
      }
   }
}
//+------------------------------------------------------------------+
