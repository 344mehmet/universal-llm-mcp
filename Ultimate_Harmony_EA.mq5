//+------------------------------------------------------------------+
//|                                       Ultimate_Harmony_EA.mq5    |
//|              © 2025, Ultimate Harmony Trading System v1.0        |
//|          All-in-One: 45 Modül + CTrade Complete + Grid/Basket    |
//+------------------------------------------------------------------+
//| ÖZELLİKLER:                                                      |
//| • AI Signal Scorer (10-Faktör + TSI Momentum)                    |
//| • Mum Pattern Tanıma (15+ pattern)                               |
//| • Fibonacci / Pivot / S-R Seviyeleri                             |
//| • Grid/Basket Yönetimi + Drawdown Recovery                       |
//| • Martingale / Anti-Martingale / Kelly Kriteri                   |
//| • Trailing Stop (ATR/Parabolic/Chandelier)                       |
//| • Breakeven + Smart Partial Close                                |
//| • Pending Orders (Limit/Stop) + Expiration                       |
//| • Haber Filtresi + Session Filtresi                              |
//| • Multi-Timeframe Trend Onayı                                    |
//| • CTrade Sınıfı TÜM Metodları                                    |
//| • Gelişmiş Dashboard + Regression Channel                        |
//+------------------------------------------------------------------+
#property copyright "© 2025, Ultimate Harmony EA v1.0"
#property version   "1.00"
#property description "45 Modül + CTrade Complete + Grid/Basket + AI Scorer"
#property strict

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>

//====================================================================
// ENUM TANIMLARI
//====================================================================
enum ENUM_SIGNAL_MODE {
   SIG_AI_SCORE,         // AI Skor Bazlı
   SIG_MA_CROSS,         // MA Kesişim
   SIG_PATTERN,          // Mum Pattern
   SIG_COMBINED,         // Birleşik
   SIG_HARMONY           // Tam Harmony
};

enum ENUM_ENTRY_MODE { 
   MODE_MARKET,          // Piyasa Emri
   MODE_PENDING,         // Bekleyen Emir
   MODE_GRID,            // Grid Sistemi
   MODE_SMART            // Akıllı Mod
};

enum ENUM_LOT_MODE {
   LOT_FIXED,            // Sabit Lot
   LOT_RISK_PERCENT,     // Risk %
   LOT_KELLY,            // Kelly Kriteri
   LOT_MARTINGALE,       // Martingale
   LOT_ANTI_MARTINGALE   // Anti-Martingale
};

enum ENUM_TRAIL_MODE {
   TRAIL_FIXED,          // Sabit Pip
   TRAIL_ATR,            // ATR Bazlı
   TRAIL_PARABOLIC,      // Parabolik
   TRAIL_CHANDELIER      // Chandelier Exit
};

enum ENUM_PIVOT_TYPE {
   PIVOT_CLASSIC,        // Klasik
   PIVOT_CAMARILLA,      // Camarilla
   PIVOT_WOODIE,         // Woodie
   PIVOT_FIBONACCI       // Fibonacci
};

enum ENUM_CANDLE_PATTERN {
   PATTERN_NONE,
   PATTERN_BULLISH_PINBAR,
   PATTERN_BEARISH_PINBAR,
   PATTERN_BULLISH_ENGULFING,
   PATTERN_BEARISH_ENGULFING,
   PATTERN_DOJI,
   PATTERN_HAMMER,
   PATTERN_SHOOTING_STAR,
   PATTERN_MORNING_STAR,
   PATTERN_EVENING_STAR,
   PATTERN_THREE_WHITE_SOLDIERS,
   PATTERN_THREE_BLACK_CROWS,
   PATTERN_BULLISH_HARAMI,
   PATTERN_BEARISH_HARAMI,
   PATTERN_TWEEZER_TOP,
   PATTERN_TWEEZER_BOTTOM
};

//====================================================================
// INPUT PARAMETRELERİ - 1. ANA AYARLAR
//====================================================================
input group "═══════ 1. ANA AYARLAR ═══════"
input ulong          InpMagicNumber     = 999888;         // 🎰 Magic Number
input string         InpTradeComment    = "Harmony_v1";   // 💬 İşlem Yorumu
input ENUM_TIMEFRAMES InpTimeframe      = PERIOD_M15;     // ⏰ Zaman Dilimi
input ENUM_SIGNAL_MODE InpSignalMode    = SIG_AI_SCORE;   // 📊 Sinyal Modu
input ENUM_ENTRY_MODE InpEntryMode      = MODE_MARKET;    // 📋 Giriş Modu

//====================================================================
// INPUT PARAMETRELERİ - 2. AI SİNYAL SİSTEMİ
//====================================================================
input group "═══════ 2. AI SİNYAL SİSTEMİ ═══════"
input int            InpMinSignalScore  = 55;             // 🎯 Min Sinyal Skoru
input int            InpStrongSignalScore = 70;           // 💪 Güçlü Sinyal Skoru
input bool           InpUseHarmonyBoost = true;           // 🚀 Harmony Güçlendirme

//--- AI Filtre Ağırlıkları
input double         InpWeight_MACross  = 20.0;           // MA Cross Ağırlığı
input double         InpWeight_MACD     = 12.0;           // MACD Ağırlığı
input double         InpWeight_RSI      = 10.0;           // RSI Ağırlığı
input double         InpWeight_ADX      = 10.0;           // ADX Ağırlığı
input double         InpWeight_Pattern  = 15.0;           // Pattern Ağırlığı
input double         InpWeight_Level    = 8.0;            // Seviye Ağırlığı

//====================================================================
// INPUT PARAMETRELERİ - 3. MA SİSTEMİ
//====================================================================
input group "═══════ 3. ÜÇLÜ MA SİSTEMİ ═══════"
input int            InpMA1_Period      = 9;              // 🔵 Hızlı MA
input int            InpMA2_Period      = 21;             // 🟡 Orta MA
input int            InpMA3_Period      = 55;             // 🔴 Yavaş MA
input ENUM_MA_METHOD InpMA_Method       = MODE_EMA;       // MA Metodu

//====================================================================
// INPUT PARAMETRELERİ - 4. MOMENTUM GÖSTERGELERİ
//====================================================================
input group "═══════ 4. MOMENTUM GÖSTERGELERİ ═══════"
input bool           InpUseMACD         = true;           // ✅ MACD
input int            InpMACD_Fast       = 12;             // MACD Hızlı
input int            InpMACD_Slow       = 26;             // MACD Yavaş
input int            InpMACD_Signal     = 9;              // MACD Sinyal
input bool           InpUseRSI          = true;           // ✅ RSI
input int            InpRSI_Period      = 14;             // RSI Periyodu
input int            InpRSI_OB          = 70;             // RSI Aşırı Alım
input int            InpRSI_OS          = 30;             // RSI Aşırı Satım
input bool           InpUseADX          = true;           // ✅ ADX
input int            InpADX_Period      = 14;             // ADX Periyodu
input int            InpADX_Min         = 20;             // ADX Minimum

//====================================================================
// INPUT PARAMETRELERİ - 5. MUM ANALİZİ
//====================================================================
input group "═══════ 5. MUM ANALİZİ ═══════"
input bool           InpUseCandlePatterns = true;         // ✅ Mum Pattern
input bool           InpUseWickAnalysis = true;           // ✅ Fitil Analizi
input double         InpMinWickRatio    = 0.25;           // Min Fitil Oranı
input double         InpMaxBodyRatio    = 0.6;            // Max Gövde Oranı

//====================================================================
// INPUT PARAMETRELERİ - 6. SEVİYELER
//====================================================================
input group "═══════ 6. FİBONACCİ & PİVOT ═══════"
input bool           InpUseFibonacci    = true;           // ✅ Fibonacci
input int            InpFibLookback     = 50;             // Fib Geriye Bakış
input bool           InpUsePivots       = true;           // ✅ Pivot
input ENUM_PIVOT_TYPE InpPivotType      = PIVOT_CLASSIC;  // Pivot Tipi
input bool           InpUseSR           = true;           // ✅ S/R Seviyeleri
input int            InpSR_Lookback     = 100;            // S/R Geriye Bakış

//====================================================================
// INPUT PARAMETRELERİ - 7. RİSK YÖNETİMİ
//====================================================================
input group "═══════ 7. RİSK YÖNETİMİ ═══════"
input ENUM_LOT_MODE  InpLotMode         = LOT_RISK_PERCENT; // 💰 Lot Modu
input double         InpFixedLot        = 0.01;           // Sabit Lot
input double         InpRiskPercent     = 1.0;            // Risk %
input double         InpMaxLot          = 2.0;            // Max Lot
input double         InpMinLot          = 0.01;           // Min Lot
input double         InpLotMultiplier   = 1.5;            // Lot Çarpanı
input double         InpMaxDailyDD      = 5.0;            // Günlük Max DD %
input int            InpMaxDailyTrades  = 10;             // Günlük Max İşlem
input int            InpMaxOpenPos      = 1;              // Max Açık Pozisyon

//====================================================================
// INPUT PARAMETRELERİ - 8. ATR & VOLATİLİTE
//====================================================================
input group "═══════ 8. ATR & VOLATİLİTE ═══════"
input bool           InpUseATR          = true;           // ✅ ATR Kullan
input int            InpATR_Period      = 14;             // ATR Periyodu
input double         InpATR_SL_Multi    = 1.5;            // ATR SL Çarpanı
input double         InpATR_TP_Multi    = 3.0;            // ATR TP Çarpanı
input int            InpMinSL_Pips      = 10;             // Min SL (pip)
input int            InpMaxSL_Pips      = 100;            // Max SL (pip)

//====================================================================
// INPUT PARAMETRELERİ - 9. GRİD SİSTEMİ
//====================================================================
input group "═══════ 9. GRİD & BASKET ═══════"
input bool           InpUseGrid         = false;          // ✅ Grid Kullan
input int            InpGrid_MaxLevels  = 7;              // Max Grid Seviye
input double         InpGrid_StepPips   = 30;             // Grid Adımı (pip)
input double         InpGrid_LotMulti   = 1.5;            // Grid Lot Çarpanı
input bool           InpAveraging       = true;           // ✅ Averaging
input double         InpAveragingProfit = 10.0;           // Basket Hedef Kâr ($)

//====================================================================
// INPUT PARAMETRELERİ - 10. DRAWDOWN AZALTMA
//====================================================================
input group "═══════ 10. DRAWDOWN AZALTMA ═══════"
input bool           InpEnableDDRecovery = true;          // ✅ DD Recovery
input int            InpDDRecoveryStart = 4;              // Başlangıç (emir sayısı)
input double         InpDDRecoveryMinProfit = 1.0;        // Min Kâr ($)
input double         InpMaxDDPercent    = 30.0;           // Max DD %

//====================================================================
// INPUT PARAMETRELERİ - 11. BREAKEVEN & TRAILING
//====================================================================
input group "═══════ 11. BREAKEVEN & TRAİLİNG ═══════"
input bool           InpUseBreakeven    = true;           // ✅ Breakeven
input double         InpBE_TriggerPct   = 30.0;           // BE Tetik (TP %)
input int            InpBE_LockPips     = 5;              // BE Kilit (pip)
input bool           InpUseTrailing     = true;           // ✅ Trailing
input ENUM_TRAIL_MODE InpTrailMode      = TRAIL_ATR;      // Trail Modu
input double         InpTrail_StartPct  = 40.0;           // Trail Başlangıç %
input double         InpTrail_ATR_Multi = 1.0;            // Trail ATR Çarpan
input int            InpTrail_FixedPips = 15;             // Trail Sabit (pip)

//====================================================================
// INPUT PARAMETRELERİ - 12. AKILLI KISMİ KAPAMA
//====================================================================
input group "═══════ 12. AKILLI KISMİ KAPAMA ═══════"
input bool           InpUsePartialClose = true;           // ✅ Kısmi Kapama
input double         InpPartial1_Trigger = 30.0;          // 1. Kapama Tetik %
input double         InpPartial1_Close  = 50.0;           // 1. Kapama Lot %
input double         InpPartial2_Trigger = 60.0;          // 2. Kapama Tetik %
input double         InpPartial2_Close  = 30.0;           // 2. Kapama Lot %
input bool           InpPartialMoveToBE = true;           // Kısmi sonrası BE

//====================================================================
// INPUT PARAMETRELERİ - 13. PENDING EMİRLER
//====================================================================
input group "═══════ 13. PENDING EMİRLER ═══════"
input double         InpPendingDistPips = 20.0;           // Emir Mesafesi (pip)
input int            InpPendingExpHours = 24;             // Geçerlilik (saat)

//====================================================================
// INPUT PARAMETRELERİ - 14. FİLTRELER
//====================================================================
input group "═══════ 14. FİLTRELER ═══════"
input int            InpMaxSpreadPips   = 5;              // Max Spread (pip)
input int            InpCooldownBars    = 3;              // Bekleme (bar)
input bool           InpUseTimeFilter   = false;          // ⏰ Zaman Filtresi
input int            InpStartHour       = 8;              // Başlangıç Saati
input int            InpEndHour         = 20;             // Bitiş Saati
input bool           InpUseNewsFilter   = false;          // 📰 Haber Filtresi
input int            InpNewsMinsBefore  = 30;             // Haberden Önce (dk)
input int            InpNewsMinsAfter   = 15;             // Haberden Sonra (dk)

//====================================================================
// INPUT PARAMETRELERİ - 15. MTF ONAY
//====================================================================
input group "═══════ 15. MTF ONAY ═══════"
input bool           InpUseMTF          = false;          // ✅ MTF Kullan
input ENUM_TIMEFRAMES InpMTF_TF         = PERIOD_H1;      // MTF Zaman Dilimi
input int            InpMTF_MA_Period   = 50;             // MTF MA Periyodu

//====================================================================
// INPUT PARAMETRELERİ - 16. GÖRSEL
//====================================================================
input group "═══════ 16. GÖRSEL ═══════"
input bool           InpShowDashboard   = true;           // 📊 Dashboard
input bool           InpShowRegChannel  = true;           // 📈 Regression
input int            InpRegChannelBars  = 100;            // Regression Bar
input color          InpRegChannelColor = clrDodgerBlue;  // Regression Renk
input bool           InpShowDebugLog    = true;           // 🔍 Debug Log

//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================
CTrade            g_trade;
CPositionInfo     g_posInfo;
COrderInfo        g_orderInfo;

//--- İndikatör Handle'ları
int               g_hMA1, g_hMA2, g_hMA3;
int               g_hMACD, g_hRSI, g_hADX, g_hATR;
int               g_hMTF_MA;

//--- Grid/Basket
struct GridPosition {
   ulong             ticket;
   double            openPrice;
   double            lots;
   ENUM_POSITION_TYPE posType;
   double            profit;
};
GridPosition      g_buyGrid[];
GridPosition      g_sellGrid[];
int               g_buyGridCount, g_sellGridCount;
double            g_buyTotalLots, g_sellTotalLots;
double            g_buyTotalProfit, g_sellTotalProfit;
double            g_buyAvgPrice, g_sellAvgPrice;

//--- İstatistikler
int               g_consecutiveWins, g_consecutiveLosses;
int               g_totalTrades, g_winTrades, g_lossTrades;
double            g_totalProfit, g_dailyProfit;
double            g_equityHigh, g_maxDrawdown;
double            g_refBalance;
datetime          g_lastTradeDate;
int               g_dailyTradeCount;

//--- Kontrol
datetime          g_lastBarTime;
int               g_barsSinceTrade;
bool              g_isGridActive;
int               g_lastSignal;
string            g_lastSignalReason;
int               g_lastSignalScore;

//====================================================================
// 🎯 MERKEZİ TREND TAKİP SİSTEMİ - TÜM MODÜLLER BU FLAG'E BAKAR
//====================================================================
int               g_regressionTrend = 0;      // +1=YUKARI, -1=AŞAĞI, 0=YATAY
int               g_allowedTradeDirection = 0; // +1=BUY, -1=SELL, 0=HER İKİSİ DE YOK
bool              g_trendConflict = false;     // Trend çatışması var mı?
bool              g_channelBreakout = false;   // Kanal taşması var mı?

//--- Seviyeler
double            g_pivot, g_r1, g_r2, g_r3, g_s1, g_s2, g_s3;
double            g_fib382, g_fib500, g_fib618;
double            g_support, g_resistance;

//====================================================================
// YARDIMCI FONKSİYONLAR
//====================================================================
double PipToPoints(double pips) {
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int mult = (digits == 3 || digits == 5) ? 10 : 1;
   return pips * mult * point;
}

double PointsToPip(double points) {
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int mult = (digits == 3 || digits == 5) ? 10 : 1;
   if(mult * point == 0) return 0;
   return points / (mult * point);
}

double NormalizePrice(double price) {
   return NormalizeDouble(price, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
}

//====================================================================
// 🎯 MERKEZİ İŞLEM İZİN KONTROLÜ
// Tüm modüller bu fonksiyonu çağırarak işlem açıp açamayacaklarını kontrol eder
//====================================================================
bool IsTradeAllowed(int requestedDirection) {
   // Çatışma veya taşma varsa hiç işlem açma
   if(g_trendConflict || g_channelBreakout || g_allowedTradeDirection == 0) {
      return false;
   }
   
   // BUY işlemi isteniyorsa ve izin var mı?
   if(requestedDirection == 1 && g_allowedTradeDirection == 1) {
      return true;
   }
   
   // SELL işlemi isteniyorsa ve izin var mı?
   if(requestedDirection == -1 && g_allowedTradeDirection == -1) {
      return true;
   }
   
   // İzin yok
   return false;
}

string GetAllowedDirectionString() {
   if(g_trendConflict) return "⚠️ ÇATIŞMA";
   if(g_channelBreakout) return "🚨 TAŞMA";
   if(g_allowedTradeDirection == 1) return "📈 SADECE BUY";
   if(g_allowedTradeDirection == -1) return "📉 SADECE SELL";
   return "⏳ BEKLE";
}

//====================================================================
// 🚨 TREND ZITI POZİSYONLARI OTOMATİK KAPAT
// Regresyon yukarıysa SELL'leri, aşağıysa BUY'ları 1 dakika içinde kapat
// Tam otomatik sistem - kullanıcı müdahalesi gerektirmez!
//====================================================================
input group "═══════ 🚨 OTOMATİK POZİSYON DÜZELTME ═══════"
input bool     InpAutoCloseOpposite   = true;       // ✅ Zıt Pozisyonları Kapat
input int      InpOppositeCloseDelay  = 60;         // ⏱️ Kapatma Gecikmesi (saniye)

void CloseTrendOppositePositions() {
   if(!InpAutoCloseOpposite) return;
   if(g_allowedTradeDirection == 0) return;  // Trend belirsiz, bekle
   
   static datetime lastCloseCheck = 0;
   static datetime oppositeDetectedTime[];
   static ulong oppositeTickets[];
   
   // Her 5 saniyede bir kontrol et
   if(TimeCurrent() - lastCloseCheck < 5) return;
   lastCloseCheck = TimeCurrent();
   
   // Tüm pozisyonları tara
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      long posType = PositionGetInteger(POSITION_TYPE);
      int posDirection = (posType == POSITION_TYPE_BUY) ? 1 : -1;
      
      // Trend yönüne zıt mı?
      bool isOpposite = false;
      string reason = "";
      
      if(g_allowedTradeDirection == 1 && posDirection == -1) {
         isOpposite = true;  // Uptrend'de SELL var - YANLIŞ!
         reason = "Regresyon YUKARI ama SELL pozisyon";
      }
      else if(g_allowedTradeDirection == -1 && posDirection == 1) {
         isOpposite = true;  // Downtrend'de BUY var - YANLIŞ!
         reason = "Regresyon AŞAĞI ama BUY pozisyon";
      }
      
      if(isOpposite) {
         // Bu ticket daha önce tespit edilmiş mi?
         int idx = -1;
         for(int j = 0; j < ArraySize(oppositeTickets); j++) {
            if(oppositeTickets[j] == ticket) {
               idx = j;
               break;
            }
         }
         
         if(idx == -1) {
            // Yeni tespit - zamanlayıcı başlat
            int newSize = ArraySize(oppositeTickets) + 1;
            ArrayResize(oppositeTickets, newSize);
            ArrayResize(oppositeDetectedTime, newSize);
            oppositeTickets[newSize - 1] = ticket;
            oppositeDetectedTime[newSize - 1] = TimeCurrent();
            WriteLog("⏱️ TREND ZITI TESPİT: " + reason + " | Ticket: " + IntegerToString(ticket) + " | " + IntegerToString(InpOppositeCloseDelay) + " sn içinde kapatılacak!");
         }
         else {
            // Süre doldu mu?
            if(TimeCurrent() - oppositeDetectedTime[idx] >= InpOppositeCloseDelay) {
               // Kapat!
               double lots = PositionGetDouble(POSITION_VOLUME);
               double profit = PositionGetDouble(POSITION_PROFIT);
               
               if(g_trade.PositionClose(ticket)) {
                  WriteLog("🚨 OTOMATİK KAPATMA: " + reason + " | Ticket: " + IntegerToString(ticket) + " | Kar/Zarar: $" + DoubleToString(profit, 2));
                  
                  // Listeden kaldır
                  for(int k = idx; k < ArraySize(oppositeTickets) - 1; k++) {
                     oppositeTickets[k] = oppositeTickets[k + 1];
                     oppositeDetectedTime[k] = oppositeDetectedTime[k + 1];
                  }
                  ArrayResize(oppositeTickets, ArraySize(oppositeTickets) - 1);
                  ArrayResize(oppositeDetectedTime, ArraySize(oppositeDetectedTime) - 1);
               }
            }
            else {
               int remaining = InpOppositeCloseDelay - (int)(TimeCurrent() - oppositeDetectedTime[idx]);
               if(remaining % 15 == 0 && remaining > 0) {  // Her 15 sn log
                  WriteLog("⏳ TREND ZITI: Ticket " + IntegerToString(ticket) + " | " + IntegerToString(remaining) + " sn kaldı...");
               }
            }
         }
      }
   }
   
   // Ayrıca zıt yöndeki pending emirleri de iptal et
   CancelOppositePendingOrders();
}

void CancelOppositePendingOrders() {
   if(g_allowedTradeDirection == 0) return;
   
   for(int i = OrdersTotal() - 1; i >= 0; i--) {
      ulong ticket = OrderGetTicket(i);
      if(ticket == 0) continue;
      if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
      
      long orderType = OrderGetInteger(ORDER_TYPE);
      bool isOpposite = false;
      string reason = "";
      
      // BUY emirleri
      if(orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP) {
         if(g_allowedTradeDirection == -1) {
            isOpposite = true;
            reason = "Downtrend'de BUY emir";
         }
      }
      // SELL emirleri
      if(orderType == ORDER_TYPE_SELL_LIMIT || orderType == ORDER_TYPE_SELL_STOP) {
         if(g_allowedTradeDirection == 1) {
            isOpposite = true;
            reason = "Uptrend'de SELL emir";
         }
      }
      
      if(isOpposite) {
         if(g_trade.OrderDelete(ticket)) {
            WriteLog("🗑️ ZITI EMİR İPTAL: " + reason + " | Ticket: " + IntegerToString(ticket));
         }
      }
   }
}

//====================================================================
// 🛡️ SL/TP OLMAYAN POZİSYONLARA OTOMATİK SL/TP EKLE
// Kullanıcı SL/TP koymayı unutursa EA hemen ekler
// Tam otomatik koruma sistemi!
//====================================================================
input group "═══════ 🛡️ OTOMATİK SL/TP KORUMA ═══════"
input bool     InpAutoAddSLTP         = true;       // ✅ Eksik SL/TP Otomatik Ekle
input double   InpAutoSL_Pips         = 50;         // 📉 Otomatik SL (pip)
input double   InpAutoTP_Pips         = 100;        // 📈 Otomatik TP (pip)
input bool     InpUseATRforAutoSLTP   = true;       // 📊 ATR Bazlı SL/TP Kullan

void AutoAddMissingSLTP() {
   if(!InpAutoAddSLTP) return;
   
   static datetime lastCheck = 0;
   
   // Her 2 saniyede bir kontrol et
   if(TimeCurrent() - lastCheck < 2) return;
   lastCheck = TimeCurrent();
   
   double atr = g_signalScorer.GetATR();
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   
   // ATR bazlı veya sabit SL/TP hesapla
   double slDist, tpDist;
   if(InpUseATRforAutoSLTP && atr > 0) {
      slDist = atr * 1.5;  // 1.5 ATR SL
      tpDist = atr * 2.5;  // 2.5 ATR TP (1:1.67 R:R)
   }
   else {
      slDist = PipToPoints(InpAutoSL_Pips);
      tpDist = PipToPoints(InpAutoTP_Pips);
   }
   
   // Tüm pozisyonları tara
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
      
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      long posType = PositionGetInteger(POSITION_TYPE);
      
      // SL veya TP eksik mi?
      bool needSL = (currentSL == 0 || currentSL == EMPTY_VALUE);
      bool needTP = (currentTP == 0 || currentTP == EMPTY_VALUE);
      
      if(!needSL && !needTP) continue;  // İkisi de var, geç
      
      double newSL = currentSL;
      double newTP = currentTP;
      
      if(posType == POSITION_TYPE_BUY) {
         if(needSL) newSL = NormalizeDouble(openPrice - slDist, digits);
         if(needTP) newTP = NormalizeDouble(openPrice + tpDist, digits);
      }
      else {  // SELL
         if(needSL) newSL = NormalizeDouble(openPrice + slDist, digits);
         if(needTP) newTP = NormalizeDouble(openPrice - tpDist, digits);
      }
      
      // SL/TP güncelle
      if(g_trade.PositionModify(ticket, newSL, newTP)) {
         string posTypeStr = (posType == POSITION_TYPE_BUY) ? "BUY" : "SELL";
         string addedStr = "";
         if(needSL) addedStr += "SL: " + DoubleToString(newSL, digits) + " ";
         if(needTP) addedStr += "TP: " + DoubleToString(newTP, digits);
         
         WriteLog("🛡️ OTOMATİK KORUMA: " + posTypeStr + " #" + IntegerToString(ticket) + " | " + addedStr + " eklendi!");
      }
      else {
         WriteLog("⚠️ SL/TP eklenemedi: #" + IntegerToString(ticket) + " | Hata: " + IntegerToString(GetLastError()));
      }
   }
}



double NormalizeLot(double lot) {
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(minLot <= 0) minLot = 0.01;
   if(stepLot <= 0) stepLot = 0.01;
   lot = MathFloor(lot / stepLot) * stepLot;
   lot = MathMax(minLot, MathMin(lot, MathMin(maxLot, InpMaxLot)));
   return MathMax(InpMinLot, NormalizeDouble(lot, 2));
}

//====================================================================
// 📋 AKILLI LOG SİSTEMİ - SPAM ÖNLEYİCİ
// Aynı mesaj 60 saniye içinde tekrar yazılmaz
// Performans için kritik!
//====================================================================
string g_lastLogMessages[];         // Son log mesajları
datetime g_lastLogTimes[];          // Son log zamanları
int g_logMessageCount = 0;          // Toplam mesaj sayısı
const int LOG_THROTTLE_SECONDS = 60; // Minimum saniye aralığı

void WriteLog(string msg) {
   if(!InpShowDebugLog) return;
   
   // Mesaj daha önce yazıldı mı ve 60 saniye geçti mi?
   for(int i = 0; i < g_logMessageCount; i++) {
      if(g_lastLogMessages[i] == msg) {
         // Aynı mesaj - 60 saniye geçti mi?
         if(TimeCurrent() - g_lastLogTimes[i] < LOG_THROTTLE_SECONDS) {
            return;  // SPAM ÖNLE - yazma!
         }
         else {
            // 60 saniye geçti - zamanı güncelle ve yaz
            g_lastLogTimes[i] = TimeCurrent();
            Print("📋 ", msg);
            return;
         }
      }
   }
   
   // Yeni mesaj - listeye ekle
   g_logMessageCount++;
   ArrayResize(g_lastLogMessages, g_logMessageCount);
   ArrayResize(g_lastLogTimes, g_logMessageCount);
   g_lastLogMessages[g_logMessageCount - 1] = msg;
   g_lastLogTimes[g_logMessageCount - 1] = TimeCurrent();
   
   Print("📋 ", msg);
   
   // Liste çok büyükse eski mesajları temizle
   if(g_logMessageCount > 100) {
      // En eski 50 mesajı sil
      for(int i = 0; i < 50; i++) {
         g_lastLogMessages[i] = g_lastLogMessages[i + 50];
         g_lastLogTimes[i] = g_lastLogTimes[i + 50];
      }
      g_logMessageCount = 50;
      ArrayResize(g_lastLogMessages, 50);
      ArrayResize(g_lastLogTimes, 50);
   }
}

// Önemli mesajlar için (spam kontrolü olmadan)
void WriteLogForce(string msg) {
   if(InpShowDebugLog) Print("📋 ", msg);
}

void PrintSeparator(string title = "") {
   if(title == "")
      Print("════════════════════════════════════════════════════════════════");
   else
      Print("═══════════════ ", title, " ═══════════════");
}

//====================================================================
// CLASS: CPriceEngine - LOT VE FİYAT HESAPLAMA
//====================================================================
class CPriceEngine {
public:
   static void GetDynamicSLTP(double atr, double &slDist, double &tpDist) {
      if(InpUseATR && atr > 0) {
         slDist = atr * InpATR_SL_Multi;
         tpDist = atr * InpATR_TP_Multi;
         double minSL = PipToPoints(InpMinSL_Pips);
         double maxSL = PipToPoints(InpMaxSL_Pips);
         slDist = MathMax(minSL, MathMin(slDist, maxSL));
         if(tpDist < slDist * 2.0) tpDist = slDist * 2.0;
      } else {
         slDist = PipToPoints(InpMinSL_Pips);
         tpDist = PipToPoints(InpMinSL_Pips * 2);
      }
   }
   
   static double CalculateLot(double slPips) {
      double lot = InpFixedLot;
      
      switch(InpLotMode) {
         case LOT_FIXED:
            lot = InpFixedLot;
            break;
         case LOT_RISK_PERCENT:
            lot = CalculateRiskLot(slPips);
            break;
         case LOT_KELLY:
            lot = CalculateKellyLot(slPips);
            break;
         case LOT_MARTINGALE:
            if(g_consecutiveLosses > 0)
               lot = InpFixedLot * MathPow(InpLotMultiplier, g_consecutiveLosses);
            break;
         case LOT_ANTI_MARTINGALE:
            if(g_consecutiveWins > 0)
               lot = InpFixedLot * MathPow(InpLotMultiplier, g_consecutiveWins);
            break;
      }
      return NormalizeLot(lot);
   }
   
   static double CalculateRiskLot(double slPips) {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * InpRiskPercent / 100.0;
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      
      if(tickValue <= 0) tickValue = 10.0;
      if(tickSize <= 0) tickSize = point;
      double pipValue = tickValue * (point / tickSize) * 10.0;
      
      if(pipValue <= 0 || slPips <= 0) return InpMinLot;
      return riskAmount / (slPips * pipValue);
   }
   
   static double CalculateKellyLot(double slPips) {
      double winRate = (g_totalTrades > 0) ? (double)g_winTrades / g_totalTrades : 0.5;
      if(winRate <= 0 || winRate >= 1) winRate = 0.5;
      
      double rrRatio = InpATR_TP_Multi / InpATR_SL_Multi;
      double kelly = (winRate * rrRatio - (1 - winRate)) / rrRatio;
      kelly = MathMax(0, MathMin(kelly, 0.25));
      
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * kelly;
      
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if(tickValue <= 0) tickValue = 10.0;
      if(tickSize <= 0) tickSize = point;
      double pipValue = tickValue * (point / tickSize) * 10.0;
      
      if(pipValue <= 0 || slPips <= 0) return InpMinLot;
      return riskAmount / (slPips * pipValue);
   }
};

//====================================================================
// CLASS: CCandleAnalyzer - MUM PATTERN TANIMA
//====================================================================
class CCandleAnalyzer {
public:
   static void GetCandleComponents(int shift, double &bodySize, double &upperWick, 
                                   double &lowerWick, double &range, bool &isBullish) {
      double open = iOpen(_Symbol, InpTimeframe, shift);
      double close = iClose(_Symbol, InpTimeframe, shift);
      double high = iHigh(_Symbol, InpTimeframe, shift);
      double low = iLow(_Symbol, InpTimeframe, shift);
      
      isBullish = (close > open);
      bodySize = MathAbs(close - open);
      range = high - low;
      
      if(isBullish) {
         upperWick = high - close;
         lowerWick = open - low;
      } else {
         upperWick = high - open;
         lowerWick = close - low;
      }
   }
   
   static double GetWickRatio(int shift, bool isUpper) {
      double bodySize, upperWick, lowerWick, range;
      bool isBullish;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      if(range == 0) return 0;
      return isUpper ? upperWick / range : lowerWick / range;
   }
   
   static double GetBodyRatio(int shift) {
      double bodySize, upperWick, lowerWick, range;
      bool isBullish;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      if(range == 0) return 0;
      return bodySize / range;
   }
   
   static bool IsPinBar(int shift, bool &isBullish) {
      double bodySize, upperWick, lowerWick, range;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      if(range == 0) return false;
      if(bodySize / range > InpMaxBodyRatio) return false;
      
      if(lowerWick > upperWick * 2 && lowerWick / range >= InpMinWickRatio) {
         isBullish = true;
         return true;
      }
      if(upperWick > lowerWick * 2 && upperWick / range >= InpMinWickRatio) {
         isBullish = false;
         return true;
      }
      return false;
   }
   
   static bool IsEngulfing(int shift, bool &isBullish) {
      double o1 = iOpen(_Symbol, InpTimeframe, shift);
      double c1 = iClose(_Symbol, InpTimeframe, shift);
      double o2 = iOpen(_Symbol, InpTimeframe, shift + 1);
      double c2 = iClose(_Symbol, InpTimeframe, shift + 1);
      double body1 = MathAbs(c1 - o1);
      double body2 = MathAbs(c2 - o2);
      
      if(body1 <= body2) return false;
      
      // Bullish Engulfing
      if(c2 < o2 && c1 > o1 && c1 > o2 && o1 < c2) {
         isBullish = true;
         return true;
      }
      // Bearish Engulfing
      if(c2 > o2 && c1 < o1 && o1 > c2 && c1 < o2) {
         isBullish = false;
         return true;
      }
      return false;
   }
   
   static bool IsDoji(int shift) {
      return (GetBodyRatio(shift) < 0.1);
   }
   
   static bool IsHammer(int shift, bool &isBullish) {
      double bodySize, upperWick, lowerWick, range;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      if(range == 0 || bodySize / range > 0.3) return false;
      return (lowerWick >= bodySize * 2 && upperWick <= bodySize * 0.5);
   }
   
   static bool IsShootingStar(int shift, bool &isBullish) {
      double bodySize, upperWick, lowerWick, range;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      if(range == 0 || bodySize / range > 0.3) return false;
      return (upperWick >= bodySize * 2 && lowerWick <= bodySize * 0.5);
   }
   
   static bool IsThreeWhiteSoldiers() {
      for(int i = 1; i <= 3; i++) {
         double o = iOpen(_Symbol, InpTimeframe, i);
         double c = iClose(_Symbol, InpTimeframe, i);
         if(c <= o) return false;
         if(i > 1 && o < iClose(_Symbol, InpTimeframe, i+1)) return false;
      }
      return true;
   }
   
   static bool IsThreeBlackCrows() {
      for(int i = 1; i <= 3; i++) {
         double o = iOpen(_Symbol, InpTimeframe, i);
         double c = iClose(_Symbol, InpTimeframe, i);
         if(c >= o) return false;
         if(i > 1 && o > iClose(_Symbol, InpTimeframe, i+1)) return false;
      }
      return true;
   }
   
   static bool IsMorningStar() {
      double o1 = iOpen(_Symbol, InpTimeframe, 3), c1 = iClose(_Symbol, InpTimeframe, 3);
      double o2 = iOpen(_Symbol, InpTimeframe, 2), c2 = iClose(_Symbol, InpTimeframe, 2);
      double o3 = iOpen(_Symbol, InpTimeframe, 1), c3 = iClose(_Symbol, InpTimeframe, 1);
      return (c1 < o1) && (MathAbs(c2 - o2) < MathAbs(c1 - o1) * 0.3) && 
             (c3 > o3) && (c3 > (o1 + c1) / 2);
   }
   
   static bool IsEveningStar() {
      double o1 = iOpen(_Symbol, InpTimeframe, 3), c1 = iClose(_Symbol, InpTimeframe, 3);
      double o2 = iOpen(_Symbol, InpTimeframe, 2), c2 = iClose(_Symbol, InpTimeframe, 2);
      double o3 = iOpen(_Symbol, InpTimeframe, 1), c3 = iClose(_Symbol, InpTimeframe, 1);
      return (c1 > o1) && (MathAbs(c2 - o2) < MathAbs(c1 - o1) * 0.3) && 
             (c3 < o3) && (c3 < (o1 + c1) / 2);
   }
   
   static ENUM_CANDLE_PATTERN DetectPattern(int shift = 1) {
      bool isBullish;
      
      // Gelişmiş patternler
      if(IsThreeWhiteSoldiers()) return PATTERN_THREE_WHITE_SOLDIERS;
      if(IsThreeBlackCrows()) return PATTERN_THREE_BLACK_CROWS;
      if(IsMorningStar()) return PATTERN_MORNING_STAR;
      if(IsEveningStar()) return PATTERN_EVENING_STAR;
      
      // Temel patternler
      if(IsPinBar(shift, isBullish)) 
         return isBullish ? PATTERN_BULLISH_PINBAR : PATTERN_BEARISH_PINBAR;
      if(IsEngulfing(shift, isBullish)) 
         return isBullish ? PATTERN_BULLISH_ENGULFING : PATTERN_BEARISH_ENGULFING;
      if(IsHammer(shift, isBullish)) return PATTERN_HAMMER;
      if(IsShootingStar(shift, isBullish)) return PATTERN_SHOOTING_STAR;
      if(IsDoji(shift)) return PATTERN_DOJI;
      
      return PATTERN_NONE;
   }
   
   static int GetPatternDirection(ENUM_CANDLE_PATTERN pattern) {
      switch(pattern) {
         case PATTERN_BULLISH_PINBAR:
         case PATTERN_BULLISH_ENGULFING:
         case PATTERN_HAMMER:
         case PATTERN_MORNING_STAR:
         case PATTERN_THREE_WHITE_SOLDIERS:
         case PATTERN_BULLISH_HARAMI:
         case PATTERN_TWEEZER_BOTTOM:
            return 1;
         case PATTERN_BEARISH_PINBAR:
         case PATTERN_BEARISH_ENGULFING:
         case PATTERN_SHOOTING_STAR:
         case PATTERN_EVENING_STAR:
         case PATTERN_THREE_BLACK_CROWS:
         case PATTERN_BEARISH_HARAMI:
         case PATTERN_TWEEZER_TOP:
            return -1;
         default:
            return 0;
      }
   }
   
   static int GetPatternScore(ENUM_CANDLE_PATTERN pattern) {
      switch(pattern) {
         case PATTERN_THREE_WHITE_SOLDIERS:
         case PATTERN_THREE_BLACK_CROWS:
            return 100;
         case PATTERN_BULLISH_ENGULFING:
         case PATTERN_BEARISH_ENGULFING:
            return 95;
         case PATTERN_MORNING_STAR:
         case PATTERN_EVENING_STAR:
            return 90;
         case PATTERN_BULLISH_PINBAR:
         case PATTERN_BEARISH_PINBAR:
            return 85;
         case PATTERN_HAMMER:
         case PATTERN_SHOOTING_STAR:
            return 80;
         case PATTERN_DOJI:
            return 50;
         default:
            return 0;
      }
   }
};

//====================================================================
// CLASS: CAdvancedLevels - FİBONACCİ, PİVOT, S/R
//====================================================================
class CAdvancedLevels {
public:
   static void CalculatePivots() {
      double high = iHigh(_Symbol, PERIOD_D1, 1);
      double low = iLow(_Symbol, PERIOD_D1, 1);
      double close = iClose(_Symbol, PERIOD_D1, 1);
      double range = high - low;
      
      switch(InpPivotType) {
         case PIVOT_CLASSIC:
            g_pivot = (high + low + close) / 3.0;
            g_r1 = 2 * g_pivot - low;
            g_s1 = 2 * g_pivot - high;
            g_r2 = g_pivot + range;
            g_s2 = g_pivot - range;
            g_r3 = high + 2 * (g_pivot - low);
            g_s3 = low - 2 * (high - g_pivot);
            break;
            
         case PIVOT_CAMARILLA:
            g_pivot = (high + low + close) / 3.0;
            g_r1 = close + range * 1.1 / 12;
            g_s1 = close - range * 1.1 / 12;
            g_r2 = close + range * 1.1 / 6;
            g_s2 = close - range * 1.1 / 6;
            g_r3 = close + range * 1.1 / 4;
            g_s3 = close - range * 1.1 / 4;
            break;
            
         case PIVOT_WOODIE:
            g_pivot = (high + low + 2 * close) / 4.0;
            g_r1 = 2 * g_pivot - low;
            g_s1 = 2 * g_pivot - high;
            g_r2 = g_pivot + range;
            g_s2 = g_pivot - range;
            g_r3 = g_r1 + range;
            g_s3 = g_s1 - range;
            break;
            
         case PIVOT_FIBONACCI:
            g_pivot = (high + low + close) / 3.0;
            g_r1 = g_pivot + 0.382 * range;
            g_s1 = g_pivot - 0.382 * range;
            g_r2 = g_pivot + 0.618 * range;
            g_s2 = g_pivot - 0.618 * range;
            g_r3 = g_pivot + range;
            g_s3 = g_pivot - range;
            break;
      }
   }
   
   static void CalculateFibonacci() {
      double highest = 0, lowest = 999999;
      for(int i = 1; i <= InpFibLookback; i++) {
         double h = iHigh(_Symbol, InpTimeframe, i);
         double l = iLow(_Symbol, InpTimeframe, i);
         if(h > highest) highest = h;
         if(l < lowest) lowest = l;
      }
      double range = highest - lowest;
      g_fib382 = highest - range * 0.382;
      g_fib500 = highest - range * 0.500;
      g_fib618 = highest - range * 0.618;
      g_resistance = highest;
      g_support = lowest;
   }
   
   static void CalculateDynamicSR() {
      double nearestRes = 999999, nearestSup = 0;
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      for(int i = 2; i < InpSR_Lookback - 2; i++) {
         double h = iHigh(_Symbol, InpTimeframe, i);
         double l = iLow(_Symbol, InpTimeframe, i);
         
         bool isSwingHigh = (h > iHigh(_Symbol, InpTimeframe, i-1)) && 
                            (h > iHigh(_Symbol, InpTimeframe, i-2)) &&
                            (h > iHigh(_Symbol, InpTimeframe, i+1)) && 
                            (h > iHigh(_Symbol, InpTimeframe, i+2));
         bool isSwingLow = (l < iLow(_Symbol, InpTimeframe, i-1)) && 
                           (l < iLow(_Symbol, InpTimeframe, i-2)) &&
                           (l < iLow(_Symbol, InpTimeframe, i+1)) && 
                           (l < iLow(_Symbol, InpTimeframe, i+2));
         
         if(isSwingHigh && h > price && h < nearestRes) nearestRes = h;
         if(isSwingLow && l < price && l > nearestSup) nearestSup = l;
      }
      
      if(nearestRes < 999999) g_resistance = nearestRes;
      if(nearestSup > 0) g_support = nearestSup;
   }
   
   static void UpdateLevels() {
      if(InpUsePivots) CalculatePivots();
      if(InpUseFibonacci) CalculateFibonacci();
      if(InpUseSR) CalculateDynamicSR();
   }
   
   static int GetLevelScore(int direction) {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double zone = PipToPoints(5);
      int score = 50;
      
      if(direction == 1) {
         if(MathAbs(price - g_s1) < zone) score += 20;
         if(MathAbs(price - g_support) < zone) score += 30;
         if(MathAbs(price - g_fib618) < zone) score += 25;
         if(price > g_r1) score -= 15;
         if(price > g_resistance - zone) score -= 25;
      } else if(direction == -1) {
         if(MathAbs(price - g_r1) < zone) score += 20;
         if(MathAbs(price - g_resistance) < zone) score += 30;
         if(MathAbs(price - g_fib382) < zone) score += 25;
         if(price < g_s1) score -= 15;
         if(price < g_support + zone) score -= 25;
      }
      
      return MathMax(0, MathMin(100, score));
   }
};

//====================================================================
// CLASS: CAISignalScorer - AI SİNYAL SKORLAMA
//====================================================================
class CAISignalScorer {
private:
   double m_scores[10];
   double m_lastATR;
   
public:
   CAISignalScorer() : m_lastATR(0) {
      for(int i = 0; i < 10; i++) m_scores[i] = 50;
   }
   
   void UpdateATR() {
      double atr[];
      ArraySetAsSeries(atr, true);
      if(CopyBuffer(g_hATR, 0, 0, 1, atr) >= 1)
         m_lastATR = atr[0];
   }
   
   double GetATR() { return m_lastATR; }
   
   double ScoreMACross(int &direction) {
      double ma1[], ma2[], ma3[];
      ArraySetAsSeries(ma1, true);
      ArraySetAsSeries(ma2, true);
      ArraySetAsSeries(ma3, true);
      
      if(CopyBuffer(g_hMA1, 0, 0, 3, ma1) < 3) return 0;
      if(CopyBuffer(g_hMA2, 0, 0, 3, ma2) < 3) return 0;
      if(CopyBuffer(g_hMA3, 0, 0, 3, ma3) < 3) return 0;
      
      double score = 0;
      
      // Kesişim tespiti
      bool crossUp = (ma1[2] <= ma2[2] && ma1[1] > ma2[1]);
      bool crossDown = (ma1[2] >= ma2[2] && ma1[1] < ma2[1]);
      
      // Triple MA hizalama
      bool perfectBullAlign = (ma1[1] > ma2[1] && ma2[1] > ma3[1]);
      bool perfectBearAlign = (ma1[1] < ma2[1] && ma2[1] < ma3[1]);
      
      // Momentum (spread genişliyor mu?)
      double spread = MathAbs(ma1[1] - ma2[1]);
      double prevSpread = MathAbs(ma1[2] - ma2[2]);
      bool expanding = (spread > prevSpread);
      
      if(crossUp && perfectBullAlign) {
         direction = 1;
         score = expanding ? 100 : 90;
      }
      else if(crossDown && perfectBearAlign) {
         direction = -1;
         score = expanding ? 100 : 90;
      }
      else if(crossUp) {
         direction = 1;
         score = expanding ? 75 : 65;
      }
      else if(crossDown) {
         direction = -1;
         score = expanding ? 75 : 65;
      }
      else if(perfectBullAlign) {
         direction = 1;
         score = 55;
      }
      else if(perfectBearAlign) {
         direction = -1;
         score = 55;
      }
      
      return score;
   }
   
   double ScoreMACD(int direction) {
      if(!InpUseMACD) return 50;
      
      double main[], sig[];
      ArraySetAsSeries(main, true);
      ArraySetAsSeries(sig, true);
      
      if(CopyBuffer(g_hMACD, 0, 0, 2, main) < 2) return 50;
      if(CopyBuffer(g_hMACD, 1, 0, 2, sig) < 2) return 50;
      
      double hist = main[0] - sig[0];
      double prevHist = main[1] - sig[1];
      bool histRising = (hist > prevHist);
      
      double score = 50;
      if(direction == 1) {
         if(hist > 0) score += 20;
         if(histRising) score += 15;
      } else if(direction == -1) {
         if(hist < 0) score += 20;
         if(!histRising) score += 15;
      }
      
      return MathMin(100, score);
   }
   
   double ScoreRSI(int direction) {
      if(!InpUseRSI) return 50;
      
      double rsi[];
      ArraySetAsSeries(rsi, true);
      if(CopyBuffer(g_hRSI, 0, 0, 1, rsi) < 1) return 50;
      
      double val = rsi[0];
      double score = 50;
      
      if(direction == 1) {
         if(val < InpRSI_OS) score = 95;
         else if(val < 40) score = 75;
         else if(val > InpRSI_OB) score = 25;
      } else if(direction == -1) {
         if(val > InpRSI_OB) score = 95;
         else if(val > 60) score = 75;
         else if(val < InpRSI_OS) score = 25;
      }
      
      return score;
   }
   
   double ScoreADX() {
      if(!InpUseADX) return 50;
      
      double adx[];
      ArraySetAsSeries(adx, true);
      if(CopyBuffer(g_hADX, 0, 0, 1, adx) < 1) return 50;
      
      if(adx[0] >= 40) return 100;
      if(adx[0] >= 30) return 85;
      if(adx[0] >= 25) return 70;
      if(adx[0] >= InpADX_Min) return 55;
      return 35;
   }
   
   double ScorePattern(int direction) {
      if(!InpUseCandlePatterns) return 50;
      
      ENUM_CANDLE_PATTERN pattern = CCandleAnalyzer::DetectPattern(1);
      int patDir = CCandleAnalyzer::GetPatternDirection(pattern);
      int patScore = CCandleAnalyzer::GetPatternScore(pattern);
      
      if(patDir == direction) return patScore;
      if(patDir == -direction) return 100 - patScore;
      return 50;
   }
   
   double ScoreWick(int direction) {
      if(!InpUseWickAnalysis) return 50;
      
      double upper = CCandleAnalyzer::GetWickRatio(1, true);
      double lower = CCandleAnalyzer::GetWickRatio(1, false);
      double score = 50;
      
      if(direction == 1) {
         if(lower > 0.4) score = 85;
         else if(lower > 0.3) score = 70;
         if(upper > 0.4) score -= 20;
      } else if(direction == -1) {
         if(upper > 0.4) score = 85;
         else if(upper > 0.3) score = 70;
         if(lower > 0.4) score -= 20;
      }
      
      return MathMax(0, MathMin(100, score));
   }
   
   int CalculateTotalScore(int &outDirection) {
      int direction = 0;
      
      m_scores[0] = ScoreMACross(direction);
      if(direction == 0) return 0;
      
      outDirection = direction;
      m_scores[1] = ScoreMACD(direction);
      m_scores[2] = ScoreRSI(direction);
      m_scores[3] = ScoreADX();
      m_scores[4] = ScorePattern(direction);
      m_scores[5] = ScoreWick(direction);
      m_scores[6] = CAdvancedLevels::GetLevelScore(direction);
      
      double weights[] = {InpWeight_MACross, InpWeight_MACD, InpWeight_RSI, 
                          InpWeight_ADX, InpWeight_Pattern, 5.0, InpWeight_Level};
      double totalW = 0, weighted = 0;
      
      for(int i = 0; i < 7; i++) {
         totalW += weights[i];
         weighted += m_scores[i] * weights[i];
      }
      
      int finalScore = (int)(weighted / totalW);
      
      // Harmony boost
      if(InpUseHarmonyBoost) {
         int highScoreCount = 0;
         for(int i = 0; i < 7; i++) {
            if(m_scores[i] >= 70) highScoreCount++;
         }
         if(highScoreCount >= 5) finalScore += 10;
         else if(highScoreCount >= 4) finalScore += 5;
      }
      
      g_lastSignalScore = finalScore;
      g_lastSignalReason = StringFormat("MA:%.0f MD:%.0f RS:%.0f ADX:%.0f PAT:%.0f WK:%.0f LV:%.0f",
         m_scores[0], m_scores[1], m_scores[2], m_scores[3], m_scores[4], m_scores[5], m_scores[6]);
      
      return MathMin(100, finalScore);
   }
   
   int GetSignal() {
      int direction = 0;
      int score = CalculateTotalScore(direction);
      
      if(score >= InpMinSignalScore && direction != 0) {
         if(InpShowDebugLog) {
            PrintSeparator();
            WriteLog("🤖 AI SKOR: " + IntegerToString(score) + "/100 | Eşik: " + IntegerToString(InpMinSignalScore));
            WriteLog("   📊 " + g_lastSignalReason);
            WriteLog("   ➡️ " + (direction == 1 ? "BUY" : "SELL") + " SİNYALİ");
            PrintSeparator();
         }
         return direction;
      }
      return 0;
   }
};

//====================================================================
// CLASS: CSecurityManager - GÜVENLİK KONTROL
//====================================================================
class CSecurityManager {
public:
   static void Init() {
      g_refBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      g_equityHigh = AccountInfoDouble(ACCOUNT_EQUITY);
      g_dailyTradeCount = 0;
      g_dailyProfit = 0;
   }
   
   static void UpdateReference() {
      MqlDateTime dt;
      TimeCurrent(dt);
      datetime today = StringToTime(IntegerToString(dt.year) + "." + 
                       IntegerToString(dt.mon) + "." + IntegerToString(dt.day));
      
      if(g_lastTradeDate != today) {
         g_lastTradeDate = today;
         g_refBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         g_dailyTradeCount = 0;
         g_dailyProfit = 0;
      }
   }
   
   static bool IsSafeToTrade() {
      UpdateReference();
      
      // Günlük DD kontrolü
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double dailyLoss = g_refBalance - equity;
      if(g_refBalance > 0 && (dailyLoss / g_refBalance * 100) >= InpMaxDailyDD) {
         WriteLog("⛔ GÜNLÜK DD LİMİTİ AŞILDI");
         return false;
      }
      
      // Günlük trade limiti
      if(g_dailyTradeCount >= InpMaxDailyTrades) {
         WriteLog("⛔ GÜNLÜK İŞLEM LİMİTİ");
         return false;
      }
      
      // Spread kontrolü
      long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      if(spread / 10.0 > InpMaxSpreadPips) {
         return false;
      }
      
      // Zaman filtresi
      if(InpUseTimeFilter) {
         MqlDateTime dt;
         TimeCurrent(dt);
         if(dt.hour < InpStartHour || dt.hour >= InpEndHour)
            return false;
      }
      
      return true;
   }
   
   static bool CheckDrawdown() {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      if(equity > g_equityHigh)
         g_equityHigh = equity;
      
      double dd = 0;
      if(g_equityHigh > 0)
         dd = (g_equityHigh - equity) / g_equityHigh * 100;
      
      if(dd > g_maxDrawdown)
         g_maxDrawdown = dd;
      
      return (dd < InpMaxDDPercent);
   }
};

//====================================================================
// CLASS: CGridManager - GRİD/BASKET YÖNETİMİ
//====================================================================
class CGridManager {
public:
   static void UpdateGridPositions() {
      ArrayResize(g_buyGrid, 0);
      ArrayResize(g_sellGrid, 0);
      g_buyGridCount = 0;
      g_sellGridCount = 0;
      g_buyTotalLots = 0;
      g_sellTotalLots = 0;
      g_buyTotalProfit = 0;
      g_sellTotalProfit = 0;
      g_buyAvgPrice = 0;
      g_sellAvgPrice = 0;
      
      double buyPriceSum = 0, sellPriceSum = 0;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         
         GridPosition pos;
         pos.ticket = ticket;
         pos.openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         pos.lots = PositionGetDouble(POSITION_VOLUME);
         pos.posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         pos.profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
         
         if(pos.posType == POSITION_TYPE_BUY) {
            ArrayResize(g_buyGrid, g_buyGridCount + 1);
            g_buyGrid[g_buyGridCount] = pos;
            g_buyGridCount++;
            g_buyTotalLots += pos.lots;
            g_buyTotalProfit += pos.profit;
            buyPriceSum += pos.openPrice * pos.lots;
         } else {
            ArrayResize(g_sellGrid, g_sellGridCount + 1);
            g_sellGrid[g_sellGridCount] = pos;
            g_sellGridCount++;
            g_sellTotalLots += pos.lots;
            g_sellTotalProfit += pos.profit;
            sellPriceSum += pos.openPrice * pos.lots;
         }
      }
      
      if(g_buyTotalLots > 0) g_buyAvgPrice = buyPriceSum / g_buyTotalLots;
      if(g_sellTotalLots > 0) g_sellAvgPrice = sellPriceSum / g_sellTotalLots;
      
      g_isGridActive = (g_buyGridCount > 0 || g_sellGridCount > 0);
   }
   
   static void ManageGrid(double atr) {
      if(!InpUseGrid) return;
      
      double gridStep = PipToPoints(InpGrid_StepPips);
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      // Buy Grid
      if(g_buyGridCount > 0 && g_buyGridCount < InpGrid_MaxLevels) {
         double lowestBuy = 999999;
         for(int i = 0; i < g_buyGridCount; i++) {
            if(g_buyGrid[i].openPrice < lowestBuy)
               lowestBuy = g_buyGrid[i].openPrice;
         }
         
         if(currentPrice <= lowestBuy - gridStep) {
            double newLot = NormalizeLot(g_buyGrid[g_buyGridCount-1].lots * InpGrid_LotMulti);
            OpenGridOrder(1, newLot, atr);
         }
      }
      
      // Sell Grid
      if(g_sellGridCount > 0 && g_sellGridCount < InpGrid_MaxLevels) {
         double highestSell = 0;
         for(int i = 0; i < g_sellGridCount; i++) {
            if(g_sellGrid[i].openPrice > highestSell)
               highestSell = g_sellGrid[i].openPrice;
         }
         
         if(currentPrice >= highestSell + gridStep) {
            double newLot = NormalizeLot(g_sellGrid[g_sellGridCount-1].lots * InpGrid_LotMulti);
            OpenGridOrder(-1, newLot, atr);
         }
      }
   }
   
   static void OpenGridOrder(int direction, double lot, double atr) {
      double slDist, tpDist;
      CPriceEngine::GetDynamicSLTP(atr, slDist, tpDist);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      if(direction == 1) {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double sl = NormalizeDouble(ask - slDist, digits);
         double tp = NormalizeDouble(ask + tpDist, digits);
         g_trade.Buy(lot, _Symbol, 0, sl, tp, InpTradeComment + "_G" + IntegerToString(g_buyGridCount));
      } else {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double sl = NormalizeDouble(bid + slDist, digits);
         double tp = NormalizeDouble(bid - tpDist, digits);
         g_trade.Sell(lot, _Symbol, 0, sl, tp, InpTradeComment + "_G" + IntegerToString(g_sellGridCount));
      }
   }
   
   static void ManageBasket() {
      if(!InpAveraging) return;
      
      // Buy basket hedef kâr
      if(g_buyGridCount > 1 && g_buyTotalProfit >= InpAveragingProfit) {
         PrintSeparator();
         WriteLog("🏆 BUY BASKET KAPANIYOR! Kâr: $" + DoubleToString(g_buyTotalProfit, 2));
         for(int i = 0; i < g_buyGridCount; i++) {
            g_trade.PositionClose(g_buyGrid[i].ticket);
         }
         g_totalProfit += g_buyTotalProfit;
         g_consecutiveWins++;
         g_consecutiveLosses = 0;
         PrintSeparator();
      }
      
      // Sell basket hedef kâr
      if(g_sellGridCount > 1 && g_sellTotalProfit >= InpAveragingProfit) {
         PrintSeparator();
         WriteLog("🏆 SELL BASKET KAPANIYOR! Kâr: $" + DoubleToString(g_sellTotalProfit, 2));
         for(int i = 0; i < g_sellGridCount; i++) {
            g_trade.PositionClose(g_sellGrid[i].ticket);
         }
         g_totalProfit += g_sellTotalProfit;
         g_consecutiveWins++;
         g_consecutiveLosses = 0;
         PrintSeparator();
      }
   }
   
   static void ManageDrawdownRecovery() {
      if(!InpEnableDDRecovery) return;
      
      int totalOrders = g_buyGridCount + g_sellGridCount;
      if(totalOrders < InpDDRecoveryStart) return;
      
      // Buy DD azaltma
      if(g_buyGridCount >= 2) {
         int mostProfitIdx = -1, leastProfitIdx = -1;
         double maxProfit = -999999, minProfit = 999999;
         
         for(int i = 0; i < g_buyGridCount; i++) {
            if(g_buyGrid[i].profit > maxProfit) {
               maxProfit = g_buyGrid[i].profit;
               mostProfitIdx = i;
            }
            if(g_buyGrid[i].profit < minProfit) {
               minProfit = g_buyGrid[i].profit;
               leastProfitIdx = i;
            }
         }
         
         if(mostProfitIdx >= 0 && leastProfitIdx >= 0 && mostProfitIdx != leastProfitIdx) {
            double combinedProfit = maxProfit + minProfit;
            if(combinedProfit >= InpDDRecoveryMinProfit) {
               WriteLog("📉 DD AZALTMA: Kârlı($" + DoubleToString(maxProfit, 2) + 
                        ") + Zararlı($" + DoubleToString(minProfit, 2) + ") = $" + 
                        DoubleToString(combinedProfit, 2));
               g_trade.PositionClose(g_buyGrid[mostProfitIdx].ticket);
               g_trade.PositionClose(g_buyGrid[leastProfitIdx].ticket);
               g_totalProfit += combinedProfit;
            }
         }
      }
      
      // Sell DD azaltma (aynı mantık)
      if(g_sellGridCount >= 2) {
         int mostProfitIdx = -1, leastProfitIdx = -1;
         double maxProfit = -999999, minProfit = 999999;
         
         for(int i = 0; i < g_sellGridCount; i++) {
            if(g_sellGrid[i].profit > maxProfit) {
               maxProfit = g_sellGrid[i].profit;
               mostProfitIdx = i;
            }
            if(g_sellGrid[i].profit < minProfit) {
               minProfit = g_sellGrid[i].profit;
               leastProfitIdx = i;
            }
         }
         
         if(mostProfitIdx >= 0 && leastProfitIdx >= 0 && mostProfitIdx != leastProfitIdx) {
            double combinedProfit = maxProfit + minProfit;
            if(combinedProfit >= InpDDRecoveryMinProfit) {
               g_trade.PositionClose(g_sellGrid[mostProfitIdx].ticket);
               g_trade.PositionClose(g_sellGrid[leastProfitIdx].ticket);
               g_totalProfit += combinedProfit;
            }
         }
      }
   }
};

//====================================================================
// CLASS: CPositionManager - POZİSYON YÖNETİMİ (BE, Trail, Partial)
//====================================================================
class CPositionManager {
public:
   static void ManagePositions(double atr) {
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
         double currentSL = PositionGetDouble(POSITION_SL);
         double currentTP = PositionGetDouble(POSITION_TP);
         double volume = PositionGetDouble(POSITION_VOLUME);
         long posType = PositionGetInteger(POSITION_TYPE);
         int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
         
         if(currentTP == 0) continue;
         
         double tpDist = MathAbs(currentTP - openPrice);
         double profitDist = (posType == POSITION_TYPE_BUY) ? 
                             (currentPrice - openPrice) : (openPrice - currentPrice);
         
         // Kısmi kapama
         if(InpUsePartialClose && tpDist > 0) {
            double minVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
            double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
            
            // 1. Partial
            if(profitDist >= tpDist * (InpPartial1_Trigger / 100.0) && volume > minVol * 2) {
               bool isBE = (MathAbs(currentSL - openPrice) < PipToPoints(InpBE_LockPips + 2));
               if(!isBE) {
                  double closeVol = MathFloor((volume * InpPartial1_Close / 100.0) / lotStep) * lotStep;
                  if(closeVol >= minVol) {
                     g_trade.PositionClosePartial(ticket, closeVol);
                     WriteLog("📊 Kısmi kapama: " + DoubleToString(closeVol, 2) + " lot");
                     
                     if(InpPartialMoveToBE) {
                        double bePrice = (posType == POSITION_TYPE_BUY) ?
                           NormalizePrice(openPrice + PipToPoints(InpBE_LockPips)) :
                           NormalizePrice(openPrice - PipToPoints(InpBE_LockPips));
                        g_trade.PositionModify(ticket, bePrice, currentTP);
                     }
                  }
               }
            }
         }
         
         // Breakeven
         if(InpUseBreakeven && profitDist >= tpDist * (InpBE_TriggerPct / 100.0)) {
            double bePrice;
            if(posType == POSITION_TYPE_BUY) {
               bePrice = NormalizeDouble(openPrice + PipToPoints(InpBE_LockPips), digits);
               if(currentSL < bePrice)
                  g_trade.PositionModify(ticket, bePrice, currentTP);
            } else {
               bePrice = NormalizeDouble(openPrice - PipToPoints(InpBE_LockPips), digits);
               if(currentSL == 0 || currentSL > bePrice)
                  g_trade.PositionModify(ticket, bePrice, currentTP);
            }
         }
         
         // Trailing Stop
         if(InpUseTrailing && profitDist >= tpDist * (InpTrail_StartPct / 100.0)) {
            double trailDist = 0;
            
            switch(InpTrailMode) {
               case TRAIL_FIXED:
                  trailDist = PipToPoints(InpTrail_FixedPips);
                  break;
               case TRAIL_ATR:
                  trailDist = atr * InpTrail_ATR_Multi;
                  break;
               default:
                  trailDist = PipToPoints(InpTrail_FixedPips);
            }
            
            double newSL;
            if(posType == POSITION_TYPE_BUY) {
               newSL = NormalizeDouble(currentPrice - trailDist, digits);
               if(newSL > currentSL)
                  g_trade.PositionModify(ticket, newSL, currentTP);
            } else {
               newSL = NormalizeDouble(currentPrice + trailDist, digits);
               if(currentSL == 0 || newSL < currentSL)
                  g_trade.PositionModify(ticket, newSL, currentTP);
            }
         }
      }
   }
};

//====================================================================
// CLASS: CTradeExecutor - İŞLEM AÇMA
//====================================================================
class CTradeExecutor {
public:
   static bool OpenOrder(int direction, double atr) {
      double slDist, tpDist;
      CPriceEngine::GetDynamicSLTP(atr, slDist, tpDist);
      double slPips = PointsToPip(slDist);
      double lot = CPriceEngine::CalculateLot(slPips);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      bool result = false;
      
      if(InpEntryMode == MODE_MARKET || InpEntryMode == MODE_SMART) {
         if(direction == 1) {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            double sl = NormalizeDouble(ask - slDist, digits);
            double tp = NormalizeDouble(ask + tpDist, digits);
            result = g_trade.Buy(lot, _Symbol, 0, sl, tp, InpTradeComment);
         } else {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            double sl = NormalizeDouble(bid + slDist, digits);
            double tp = NormalizeDouble(bid - tpDist, digits);
            result = g_trade.Sell(lot, _Symbol, 0, sl, tp, InpTradeComment);
         }
      }
      else if(InpEntryMode == MODE_PENDING) {
         result = OpenPendingOrder(direction, atr, lot);
      }
      
      if(result && g_trade.ResultRetcode() == TRADE_RETCODE_DONE) {
         g_dailyTradeCount++;
         g_totalTrades++;
         g_barsSinceTrade = 0;
         WriteLog("✅ " + (direction == 1 ? "BUY" : "SELL") + " açıldı | Lot: " + 
                  DoubleToString(lot, 2) + " | SL: " + DoubleToString(slPips, 1) + " pip");
         return true;
      }
      
      WriteLog("❌ HATA: " + g_trade.ResultRetcodeDescription());
      return false;
   }
   
   static bool OpenPendingOrder(int direction, double atr, double lot) {
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      double pendingDist = PipToPoints(InpPendingDistPips);
      double slDist, tpDist;
      CPriceEngine::GetDynamicSLTP(atr, slDist, tpDist);
      datetime expiration = TimeCurrent() + (InpPendingExpHours * 3600);
      
      if(direction == 1) {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double price = NormalizeDouble(ask - pendingDist, digits);
         double sl = NormalizeDouble(price - slDist, digits);
         double tp = NormalizeDouble(price + tpDist, digits);
         return g_trade.BuyLimit(lot, price, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, InpTradeComment);
      } else {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double price = NormalizeDouble(bid + pendingDist, digits);
         double sl = NormalizeDouble(price + slDist, digits);
         double tp = NormalizeDouble(price - tpDist, digits);
         return g_trade.SellLimit(lot, price, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, InpTradeComment);
      }
   }
   
   static int CountOpenPositions() {
      int count = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber && 
            PositionGetString(POSITION_SYMBOL) == _Symbol)
            count++;
      }
      return count;
   }
};

//====================================================================
// GLOBAL NESNE
//====================================================================
CAISignalScorer g_signalScorer;

//====================================================================
// OnInit - EA BAŞLATMA
//====================================================================
int OnInit() {
   PrintSeparator("ULTIMATE HARMONY EA v1.0");
   
   // Trade ayarları
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(20);
   g_trade.SetTypeFilling(ORDER_FILLING_FOK);
   g_trade.SetMarginMode();
   g_trade.LogLevel(LOG_LEVEL_ERRORS);
   g_trade.SetTypeFillingBySymbol(_Symbol);
   
   // İndikatörler
   g_hMA1 = iMA(_Symbol, InpTimeframe, InpMA1_Period, 0, InpMA_Method, PRICE_CLOSE);
   g_hMA2 = iMA(_Symbol, InpTimeframe, InpMA2_Period, 0, InpMA_Method, PRICE_CLOSE);
   g_hMA3 = iMA(_Symbol, InpTimeframe, InpMA3_Period, 0, InpMA_Method, PRICE_CLOSE);
   g_hMACD = iMACD(_Symbol, InpTimeframe, InpMACD_Fast, InpMACD_Slow, InpMACD_Signal, PRICE_CLOSE);
   g_hRSI = iRSI(_Symbol, InpTimeframe, InpRSI_Period, PRICE_CLOSE);
   g_hADX = iADX(_Symbol, InpTimeframe, InpADX_Period);
   g_hATR = iATR(_Symbol, InpTimeframe, InpATR_Period);
   
   if(InpUseMTF)
      g_hMTF_MA = iMA(_Symbol, InpMTF_TF, InpMTF_MA_Period, 0, MODE_EMA, PRICE_CLOSE);
   
   if(g_hMA1 == INVALID_HANDLE || g_hMA2 == INVALID_HANDLE || g_hATR == INVALID_HANDLE) {
      Print("❌ İndikatörler yüklenemedi!");
      return INIT_FAILED;
   }
   
   // Değişkenleri sıfırla
   g_consecutiveWins = 0;
   g_consecutiveLosses = 0;
   g_totalTrades = 0;
   g_winTrades = 0;
   g_lossTrades = 0;
   g_totalProfit = 0;
   g_lastBarTime = 0;
   g_barsSinceTrade = InpCooldownBars;
   g_isGridActive = false;
   
   CSecurityManager::Init();
   CAdvancedLevels::UpdateLevels();
   CMillionDollarTracker::Init();
   
   WriteLog("🎯 Hedef: $" + DoubleToString(InpTargetBalance, 0) + " | Başlangıç: $" + DoubleToString(InpStartBalance, 2));
   
   WriteLog("Sembol: " + _Symbol);
   WriteLog("Zaman Dilimi: " + EnumToString(InpTimeframe));
   WriteLog("Sinyal Modu: " + EnumToString(InpSignalMode));
   WriteLog("Lot Modu: " + EnumToString(InpLotMode));
   WriteLog("MA: " + IntegerToString(InpMA1_Period) + "/" + 
            IntegerToString(InpMA2_Period) + "/" + IntegerToString(InpMA3_Period));
   PrintSeparator();
   
   return INIT_SUCCEEDED;
}

//====================================================================
// OnDeinit - EA KAPANIŞ
//====================================================================
void OnDeinit(const int reason) {
   IndicatorRelease(g_hMA1);
   IndicatorRelease(g_hMA2);
   IndicatorRelease(g_hMA3);
   IndicatorRelease(g_hMACD);
   IndicatorRelease(g_hRSI);
   IndicatorRelease(g_hADX);
   IndicatorRelease(g_hATR);
   if(g_hMTF_MA != INVALID_HANDLE) IndicatorRelease(g_hMTF_MA);
   
   ObjectsDeleteAll(0, "Harmony_");
   ObjectsDeleteAll(0, "Goal_");
   ObjectsDeleteAll(0, "MS_");
   Comment("");  // Chart comment temizle
   
   PrintSeparator("SONUÇLAR");
   WriteLog("Toplam İşlem: " + IntegerToString(g_totalTrades));
   WriteLog("Kazanan: " + IntegerToString(g_winTrades) + " | Kaybeden: " + IntegerToString(g_lossTrades));
   WriteLog("Max Drawdown: " + DoubleToString(g_maxDrawdown, 2) + "%");
   WriteLog("Toplam Kar: $" + DoubleToString(g_totalProfit, 2));
   PrintSeparator();
}

//====================================================================
// OnTradeTransaction - İŞLEM TAKİBİ
//====================================================================
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result) {
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD) {
      if(HistoryDealSelect(trans.deal)) {
         ulong magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
         if(magic == InpMagicNumber) {
            ENUM_DEAL_ENTRY entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
            
            if(entry == DEAL_ENTRY_OUT || entry == DEAL_ENTRY_OUT_BY) {
               double profit = HistoryDealGetDouble(trans.deal, DEAL_PROFIT);
               double commission = HistoryDealGetDouble(trans.deal, DEAL_COMMISSION);
               double swap = HistoryDealGetDouble(trans.deal, DEAL_SWAP);
               double netProfit = profit + commission + swap;
               
               g_totalProfit += netProfit;
               g_dailyProfit += netProfit;
               
               if(netProfit >= 0) {
                  g_winTrades++;
                  g_consecutiveWins++;
                  g_consecutiveLosses = 0;
                  WriteLog("🏆 KAZANÇ: $" + DoubleToString(netProfit, 2));
               } else {
                  g_lossTrades++;
                  g_consecutiveLosses++;
                  g_consecutiveWins = 0;
                  WriteLog("❌ KAYIP: $" + DoubleToString(netProfit, 2));
               }
            }
         }
      }
   }
}

//====================================================================
// OnTick - ANA DÖNGÜ
//====================================================================
void OnTick() {
   // ═══════════════════════════════════════════════════════════════
   // ADIM 1: ÖNCE MEVCUT POZİSYONLARI KONTROL ET VE YÖNET
   // ═══════════════════════════════════════════════════════════════
   
   // Drawdown kontrolü
   if(!CSecurityManager::CheckDrawdown()) return;
   
   // 📊 Gelişmiş DD Yönetimi - Çok Aşamalı Kontrol
   int ddAction = CEnhancedDDManager::GetDDAction();
   if(ddAction == 3) return; // DD çok yüksek, tüm işlemler yönetiliyor
   
   //====================================================================
   // 🎯 MERKEZİ TREND GÜNCELLEME - TÜM MODÜLLER BU FLAG'E BAKAR
   // OnTick başında bir kez hesapla, tüm modüller bu değeri kullanır
   //====================================================================
   CRegressionChannel::Draw();  // Regresyon hesapla
   g_regressionTrend = CRegressionChannel::GetTrendDirection();
   g_trendConflict = CRegressionChannel::IsTrendConflict();
   g_channelBreakout = CRegressionChannel::IsChannelBreakout();
   
   // İzin verilen işlem yönünü belirle
   if(g_trendConflict || g_channelBreakout) {
      g_allowedTradeDirection = 0;  // Çatışma/taşma - HİÇ işlem açma!
   }
   else if(g_regressionTrend == 1) {
      g_allowedTradeDirection = 1;  // Uptrend - SADECE BUY
   }
   else if(g_regressionTrend == -1) {
      g_allowedTradeDirection = -1; // Downtrend - SADECE SELL
   }
   else {
      g_allowedTradeDirection = 0;  // Yatay - bekle
   }
   
   //====================================================================
   // 🚨 TREND ZITI POZİSYONLARI OTOMATİK KAPAT
   // 60 saniye içinde zıt pozisyonlar kapatılır, zıt emirler iptal edilir
   //====================================================================
   CloseTrendOppositePositions();
   
   //====================================================================
   // 🛡️ SL/TP OLMAYAN POZİSYONLARA OTOMATİK SL/TP EKLE
   // Kullanıcı SL/TP koymayı unutursa EA hemen ekler
   //====================================================================
   AutoAddMissingSLTP();
   
   // ATR güncelle
   g_signalScorer.UpdateATR();
   double atr = g_signalScorer.GetATR();
   
   // 📐 Dinamik Grid Aralığı - ATR bazlı ayarlama
   double dynamicGridSpacing = CDynamicGrid::GetDynamicSpacing(atr);
   
   // 🔄 ÖNCE Ters pozisyon yönetimi (BUY/SELL çakışması) - EN ÖNCELİKLİ
   COppositePositionManager::ManageOppositePositions();
   
   // Pozisyon yönetimi (BE, Trailing, Partial)
   CPositionManager::ManagePositions(atr);
   
   // Grid pozisyonlarını güncelle
   CGridManager::UpdateGridPositions();
   CGridManager::ManageBasket();
   CGridManager::ManageDrawdownRecovery();
   
   // ═══════════════════════════════════════════════════════════════
   // ADIM 2: MEVCUT POZİSYONLAR YÖNETİLDİKTEN SONRA YENİ İŞLEM KONTROL
   // ═══════════════════════════════════════════════════════════════
   
   // 🧠 Akıllı Asistan - Sadece mevcut pozisyonlar yönetildikten sonra
   // Ters pozisyon yoksa pending emir açabilir
   if(!COppositePositionManager::HasOppositePositions()) {
      CSmartTradeAssistant::ExecuteSmartAssistant();
      CSmartTradeAssistant::QuickTickAnalysis();
   }
   
   // Yeni bar kontrolü
   datetime currentBar = iTime(_Symbol, InpTimeframe, 0);
   if(g_lastBarTime == currentBar) {
      if(InpUseGrid) CGridManager::ManageGrid(atr);
      return;
   }
   g_lastBarTime = currentBar;
   g_barsSinceTrade++;
   
   // 📈 TREND TAKİP SİSTEMİ - Piyasayla uyumlu, sadece trend yönünde işlem
   CSymmetricTradingSystem::Execute();
   
   // 🚀 Momentum Yakalama - Volatilite Spike'ları
   if(CMomentumCatcher::DetectVolatilitySpike()) {
      CMomentumCatcher::CatchMomentum();
   }
   
   // Seviyeleri güncelle
   CAdvancedLevels::UpdateLevels();
   
   // Dashboard güncelle
   if(InpShowDashboard) CDashboard::Update();
   
   // 1 Milyon Dolar hedef paneli güncelle
   CMillionDollarTracker::Update();
   CMillionDollarTracker::CheckMilestoneAchievement();
   
   // Regression channel çiz
   if(InpShowRegChannel) CRegressionChannel::Draw();
   
   // Güvenlik kontrolleri
   if(!CSecurityManager::IsSafeToTrade()) return;
   
   // Cooldown kontrolü
   if(g_barsSinceTrade < InpCooldownBars) return;
   
   // Max pozisyon kontrolü
   if(CTradeExecutor::CountOpenPositions() >= InpMaxOpenPos) return;
   
   // 📊 DD seviyesine göre lot küçültme kontrolü
   if(ddAction >= 1) {
      // DD yüksek, sadece mevcut pozisyonları yönet, yeni işlem açma
      return;
   }
   
   // MTF onay kontrolü
   if(InpUseMTF && !CMTFAnalyzer::IsAligned(g_lastSignal)) return;
   
   // News filtresi kontrolü
   if(InpUseNewsFilter && CNewsFilter::IsNewsTime()) return;
   
   // Sinyal al
   int signal = g_signalScorer.GetSignal();
   if(signal == 0) return;
   
   //====================================================================
   // ⚠️ ANA REGRESYON TREND KONTROLÜ
   // Piyasayla kavga etme - sadece trend yönünde işlem aç!
   //====================================================================
   CRegressionChannel::Draw();  // Hesaplamaları güncelle
   int regTrend = CRegressionChannel::GetTrendDirection();
   
   // Trend çatışması veya kanal taşması varsa işlem açma
   if(CRegressionChannel::IsTrendConflict() || CRegressionChannel::IsChannelBreakout()) {
      WriteLog("🚨 ANA SİNYAL: Trend çatışması/taşma - işlem açma ENGELLENDİ!");
      return;
   }
   
   // Regresyon yönüne zıt sinyal ENGELLE!
   if(regTrend == 1 && signal == -1) {
      WriteLog("🚫 ANA SİNYAL: Regresyon YUKARI ama SELL sinyali - ENGELLENDİ!");
      return;  // Uptrend'de SELL açma!
   }
   else if(regTrend == -1 && signal == 1) {
      WriteLog("🚫 ANA SİNYAL: Regresyon AŞAĞI ama BUY sinyali - ENGELLENDİ!");
      return;  // Downtrend'de BUY açma!
   }
   
   g_lastSignal = signal;
   
   // İşlem aç (artık sadece trend yönünde!)
   CTradeExecutor::OpenOrder(signal, atr);
}

//====================================================================
// CLASS: CDashboard - GÖRSEL PANEL
//====================================================================
class CDashboard {
public:
   static void Update() {
      string prefix = "Harmony_";
      int x = 10, y = 30;
      int lineHeight = 18;
      color textColor = clrWhite;
      color bgColor = clrDarkSlateGray;
      
      // Arka plan
      CreateRectangle(prefix + "BG", x-5, y-5, 280, 320, bgColor);
      
      // Başlık
      CreateLabel(prefix + "Title", x, y, "═══ ULTIMATE HARMONY EA v1.0 ═══", clrGold, 10);
      y += lineHeight + 5;
      
      // Hesap bilgileri
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double profit = equity - balance;
      
      CreateLabel(prefix + "Balance", x, y, "💰 Bakiye: $" + DoubleToString(balance, 2), textColor, 9);
      y += lineHeight;
      CreateLabel(prefix + "Equity", x, y, "💎 Equity: $" + DoubleToString(equity, 2), textColor, 9);
      y += lineHeight;
      CreateLabel(prefix + "Profit", x, y, "📈 Kar: $" + DoubleToString(profit, 2), 
                  profit >= 0 ? clrLime : clrRed, 9);
      y += lineHeight + 5;
      
      // İstatistikler
      CreateLabel(prefix + "Trades", x, y, "📊 İşlem: " + IntegerToString(g_totalTrades) + 
                  " (W:" + IntegerToString(g_winTrades) + " L:" + IntegerToString(g_lossTrades) + ")", 
                  textColor, 9);
      y += lineHeight;
      
      double winRate = (g_totalTrades > 0) ? (double)g_winTrades / g_totalTrades * 100 : 0;
      CreateLabel(prefix + "WinRate", x, y, "🎯 Win Rate: " + DoubleToString(winRate, 1) + "%", 
                  winRate >= 50 ? clrLime : clrOrange, 9);
      y += lineHeight;
      
      CreateLabel(prefix + "DD", x, y, "📉 Max DD: " + DoubleToString(g_maxDrawdown, 2) + "%", 
                  g_maxDrawdown < 10 ? clrLime : (g_maxDrawdown < 20 ? clrOrange : clrRed), 9);
      y += lineHeight + 5;
      
      // Grid durumu
      CreateLabel(prefix + "GridBuy", x, y, "🟢 Buy Grid: " + IntegerToString(g_buyGridCount) + 
                  " | $" + DoubleToString(g_buyTotalProfit, 2), textColor, 9);
      y += lineHeight;
      CreateLabel(prefix + "GridSell", x, y, "🔴 Sell Grid: " + IntegerToString(g_sellGridCount) + 
                  " | $" + DoubleToString(g_sellTotalProfit, 2), textColor, 9);
      y += lineHeight + 5;
      
      // Son sinyal
      CreateLabel(prefix + "Signal", x, y, "🤖 Son Skor: " + IntegerToString(g_lastSignalScore) + "/100", 
                  g_lastSignalScore >= InpStrongSignalScore ? clrLime : 
                  (g_lastSignalScore >= InpMinSignalScore ? clrYellow : clrGray), 9);
      y += lineHeight;
      
      // Spread
      long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      CreateLabel(prefix + "Spread", x, y, "📊 Spread: " + DoubleToString(spread / 10.0, 1) + " pip", 
                  spread / 10.0 <= InpMaxSpreadPips ? clrLime : clrRed, 9);
      y += lineHeight;
      
      // ATR
      double atr = g_signalScorer.GetATR();
      CreateLabel(prefix + "ATR", x, y, "📈 ATR: " + DoubleToString(PointsToPip(atr), 1) + " pip", 
                  textColor, 9);
      y += lineHeight + 5;
      
      // Seviyeler
      CreateLabel(prefix + "Pivot", x, y, "📍 Pivot: " + DoubleToString(g_pivot, _Digits), clrAqua, 9);
      y += lineHeight;
      CreateLabel(prefix + "SR", x, y, "📍 S/R: " + DoubleToString(g_support, _Digits) + " / " + 
                  DoubleToString(g_resistance, _Digits), clrAqua, 9);
   }
   
   static void CreateLabel(string name, int x, int y, string text, color clr, int fontSize) {
      if(ObjectFind(0, name) < 0)
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
      ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
   }
   
   static void CreateRectangle(string name, int x, int y, int width, int height, color clr) {
      if(ObjectFind(0, name) < 0)
         ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clrDimGray);
   }
};

//====================================================================
// CLASS: CRegressionChannel - REGRESYON KANALI
//====================================================================
class CRegressionChannel {
public:
   static void Draw() {
      string prefix = "Harmony_Reg_";
      ObjectsDeleteAll(0, prefix);
      
      int bars = InpRegChannelBars;
      double prices[];
      ArrayResize(prices, bars);
      
      // Fiyatları al
      for(int i = 0; i < bars; i++)
         prices[i] = iClose(_Symbol, InpTimeframe, i);
      
      // Lineer regresyon hesapla
      double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
      
      for(int i = 0; i < bars; i++) {
         sumX += i;
         sumY += prices[i];
         sumXY += i * prices[i];
         sumX2 += i * i;
      }
      
      double slope = (bars * sumXY - sumX * sumY) / (bars * sumX2 - sumX * sumX);
      double intercept = (sumY - slope * sumX) / bars;
      
      // Standart sapma hesapla
      double sumDev = 0;
      for(int i = 0; i < bars; i++) {
         double predicted = intercept + slope * i;
         sumDev += MathPow(prices[i] - predicted, 2);
      }
      double stdDev = MathSqrt(sumDev / bars);
      
      // Kanal çizgileri
      datetime time1 = iTime(_Symbol, InpTimeframe, bars - 1);
      datetime time2 = iTime(_Symbol, InpTimeframe, 0);
      
      double price1 = intercept + slope * (bars - 1);
      double price2 = intercept;
      
      // Orta çizgi
      ObjectCreate(0, prefix + "Mid", OBJ_TREND, 0, time1, price1, time2, price2);
      ObjectSetInteger(0, prefix + "Mid", OBJPROP_COLOR, InpRegChannelColor);
      ObjectSetInteger(0, prefix + "Mid", OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, prefix + "Mid", OBJPROP_RAY_RIGHT, true);
      ObjectSetInteger(0, prefix + "Mid", OBJPROP_STYLE, STYLE_SOLID);
      
      // Üst band (+2 stdDev)
      ObjectCreate(0, prefix + "Upper", OBJ_TREND, 0, time1, price1 + 2*stdDev, time2, price2 + 2*stdDev);
      ObjectSetInteger(0, prefix + "Upper", OBJPROP_COLOR, InpRegChannelColor);
      ObjectSetInteger(0, prefix + "Upper", OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, prefix + "Upper", OBJPROP_RAY_RIGHT, true);
      
      // Alt band (-2 stdDev)
      ObjectCreate(0, prefix + "Lower", OBJ_TREND, 0, time1, price1 - 2*stdDev, time2, price2 - 2*stdDev);
      ObjectSetInteger(0, prefix + "Lower", OBJPROP_COLOR, InpRegChannelColor);
      ObjectSetInteger(0, prefix + "Lower", OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, prefix + "Lower", OBJPROP_RAY_RIGHT, true);
      
      // +1 stdDev
      ObjectCreate(0, prefix + "Upper1", OBJ_TREND, 0, time1, price1 + stdDev, time2, price2 + stdDev);
      ObjectSetInteger(0, prefix + "Upper1", OBJPROP_COLOR, InpRegChannelColor);
      ObjectSetInteger(0, prefix + "Upper1", OBJPROP_STYLE, STYLE_DASHDOT);
      ObjectSetInteger(0, prefix + "Upper1", OBJPROP_RAY_RIGHT, true);
      
      // -1 stdDev
      ObjectCreate(0, prefix + "Lower1", OBJ_TREND, 0, time1, price1 - stdDev, time2, price2 - stdDev);
      ObjectSetInteger(0, prefix + "Lower1", OBJPROP_COLOR, InpRegChannelColor);
      ObjectSetInteger(0, prefix + "Lower1", OBJPROP_STYLE, STYLE_DASHDOT);
      ObjectSetInteger(0, prefix + "Lower1", OBJPROP_RAY_RIGHT, true);
      
      //--- Static değişkenleri güncelle (trend analizi için)
      m_slope = slope;
      m_stdDev = stdDev;
      m_midLine = price2;  // Şu anki orta çizgi değeri
      m_upperBand = price2 + 2*stdDev;
      m_lowerBand = price2 - 2*stdDev;
      
      // Trend yönünü belirle
      double slopeThreshold = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * 5;
      if(slope > slopeThreshold) m_trendDirection = 1;      // 📈 YUKARI
      else if(slope < -slopeThreshold) m_trendDirection = -1; // 📉 AŞAĞI
      else m_trendDirection = 0;                             // ➡️ YATAY
   }
   
   //====================================================================
   // TREND YÖN ANALİZİ - Regresyon Eğimine Dayalı
   //====================================================================
   static int GetTrendDirection() {
      return m_trendDirection;
   }
   
   static double GetSlope() {
      return m_slope;
   }
   
   static string GetTrendString() {
      if(m_trendDirection == 1) return "📈 YUKARI";
      if(m_trendDirection == -1) return "📉 AŞAĞI";
      return "➡️ YATAY";
   }
   
   //====================================================================
   // FİYAT KONUMU ANALİZİ - Fiyat Kanal İçinde Nerede?
   //====================================================================
   static int GetPricePosition() {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      // Fiyat kanala göre nerede?
      if(bid > m_upperBand) return 2;       // ⚠️ Üst bandın ÜSTÜNDE (taşma!)
      if(bid > m_midLine) return 1;          // Üst yarıda
      if(bid < m_lowerBand) return -2;       // ⚠️ Alt bandın ALTINDA (taşma!)
      if(bid < m_midLine) return -1;         // Alt yarıda
      return 0;                               // Tam ortada
   }
   
   //====================================================================
   // ⚠️ KANAL TAŞMASI TESPİTİ - TEMKİNLİ DAVRANMA
   // Trend aşağı ama fiyat yukarı taşıyor = DİKKATLİ OL!
   //====================================================================
   static bool IsChannelBreakout() {
      int pricePos = GetPricePosition();
      
      // Fiyat kanal dışına çıkmış mı?
      if(pricePos == 2 || pricePos == -2) return true;
      return false;
   }
   
   static bool IsTrendConflict() {
      // Trend yönü ile fiyat hareketi çelişiyor mu?
      int pricePos = GetPricePosition();
      
      // Trend aşağı ama fiyat üst banda çıkmış = ÇATIŞMA!
      if(m_trendDirection == -1 && pricePos >= 1) {
         WriteLog("⚠️ TREND ÇATIŞMASI: Trend AŞAĞI ama fiyat YUKARI çıkıyor - TEMKİNLİ OL!");
         return true;
      }
      
      // Trend yukarı ama fiyat alt banda düşmüş = ÇATIŞMA!
      if(m_trendDirection == 1 && pricePos <= -1) {
         WriteLog("⚠️ TREND ÇATIŞMASI: Trend YUKARI ama fiyat AŞAĞI düşüyor - TEMKİNLİ OL!");
         return true;
      }
      
      return false;
   }
   
   //====================================================================
   // AKILLI TREND SKORU - Çatışma Durumunda Temkinli
   //====================================================================
   static int GetTrendScore() {
      int score = 0;
      
      // 1. Temel trend yönü skoru
      if(m_trendDirection == 1) score += InpRegWeight;       // Uptrend = +30
      else if(m_trendDirection == -1) score -= InpRegWeight;  // Downtrend = -30
      
      // 2. Fiyat konumu bonusu/cezası
      int pricePos = GetPricePosition();
      
      // Trend yönünde, iyi konumda = bonus
      if(m_trendDirection == 1 && pricePos <= -1) score += 15;  // Uptrend'de dip = alım fırsatı
      if(m_trendDirection == -1 && pricePos >= 1) score -= 15;  // Downtrend'de tepe = satım fırsatı
      
      // 3. ⚠️ ÇATIŞMA CEZASI - Temkinli davran
      if(IsTrendConflict()) {
         // Skoru yarıya düşür - trend değişimi olabilir!
         score = score / 2;
         WriteLog("⚠️ SKOR AZALTILDI: Trend çatışması nedeniyle temkinli mod");
      }
      
      // 4. Kanal taşması kontrolü
      if(IsChannelBreakout()) {
         // Taşma varsa daha da temkinli ol
         score = score / 3;
         WriteLog("🚨 SKOR ÇOK AZALTILDI: Kanal taşması - BEKLE!");
      }
      
      return score;
   }
   
   //====================================================================
   // DURUM RAPORU
   //====================================================================
   static string GetStatus() {
      string conflict = IsTrendConflict() ? " ⚠️ÇATIŞMA!" : "";
      string breakout = IsChannelBreakout() ? " 🚨TAŞMA!" : "";
      
      return StringFormat("📐 Regresyon %s | Eğim: %.6f%s%s",
                          GetTrendString(),
                          m_slope,
                          conflict, breakout);
   }

private:
   // Static değişkenler (trend analizi için)
   static double m_slope;
   static double m_stdDev;
   static double m_midLine;
   static double m_upperBand;
   static double m_lowerBand;
   static int    m_trendDirection;
};

// CRegressionChannel Static değişken tanımları
double CRegressionChannel::m_slope = 0;
double CRegressionChannel::m_stdDev = 0;
double CRegressionChannel::m_midLine = 0;
double CRegressionChannel::m_upperBand = 0;
double CRegressionChannel::m_lowerBand = 0;
int    CRegressionChannel::m_trendDirection = 0;

//====================================================================
// CLASS: CMTFAnalyzer - MULTI-TIMEFRAME ANALİZ
//====================================================================
class CMTFAnalyzer {
public:
   static bool IsAligned(int signalDirection) {
      if(!InpUseMTF || g_hMTF_MA == INVALID_HANDLE) return true;
      
      double mtfMA[];
      ArraySetAsSeries(mtfMA, true);
      
      if(CopyBuffer(g_hMTF_MA, 0, 0, 2, mtfMA) < 2) return true;
      
      double price = iClose(_Symbol, InpMTF_TF, 0);
      bool mtfBullish = (price > mtfMA[0] && mtfMA[0] > mtfMA[1]);
      bool mtfBearish = (price < mtfMA[0] && mtfMA[0] < mtfMA[1]);
      
      if(signalDirection == 1 && mtfBullish) return true;
      if(signalDirection == -1 && mtfBearish) return true;
      
      if(InpShowDebugLog)
         WriteLog("⚠️ MTF onayı yok: " + EnumToString(InpMTF_TF));
      
      return false;
   }
   
   static int GetMTFTrend() {
      if(!InpUseMTF || g_hMTF_MA == INVALID_HANDLE) return 0;
      
      double mtfMA[];
      ArraySetAsSeries(mtfMA, true);
      
      if(CopyBuffer(g_hMTF_MA, 0, 0, 3, mtfMA) < 3) return 0;
      
      double price = iClose(_Symbol, InpMTF_TF, 0);
      
      if(price > mtfMA[0] && mtfMA[0] > mtfMA[1] && mtfMA[1] > mtfMA[2])
         return 1;  // Strong uptrend
      if(price < mtfMA[0] && mtfMA[0] < mtfMA[1] && mtfMA[1] < mtfMA[2])
         return -1; // Strong downtrend
      
      return 0;
   }
};

//====================================================================
// CLASS: CNewsFilter - HABER FİLTRESİ
//====================================================================
class CNewsFilter {
public:
   static bool IsNewsTime() {
      if(!InpUseNewsFilter) return false;
      
      MqlCalendarValue values[];
      datetime start = TimeCurrent() - (InpNewsMinsBefore * 60);
      datetime end = TimeCurrent() + (InpNewsMinsAfter * 60);
      
      string baseCurrency = SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE);
      string quoteCurrency = SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT);
      
      int count = CalendarValueHistory(values, start, end);
      
      if(count > 0) {
         for(int i = 0; i < count; i++) {
            MqlCalendarEvent event;
            if(CalendarEventById(values[i].event_id, event)) {
               MqlCalendarCountry country;
               if(CalendarCountryById(event.country_id, country)) {
                  if(country.currency == baseCurrency || country.currency == quoteCurrency) {
                     if(event.importance >= CALENDAR_IMPORTANCE_MODERATE) {
                        if(InpShowDebugLog)
                           WriteLog("📰 HABER: " + event.name + " (" + country.currency + ")");
                        return true;
                     }
                  }
               }
            }
         }
      }
      
      return false;
   }
};

//====================================================================
// CLASS: CSmartBrain - ZEKİ BEYİN (Performans Adaptasyonu)
//====================================================================
class CSmartBrain {
public:
   static double GetAdaptiveLot(double baseLot) {
      // Son performansa göre lot ayarla
      if(g_consecutiveWins >= 3) {
         // Kazanç serisinde lot artır (max 2x)
         double multiplier = 1.0 + (g_consecutiveWins - 2) * 0.2;
         return NormalizeLot(baseLot * MathMin(multiplier, 2.0));
      }
      else if(g_consecutiveLosses >= 2) {
         // Kayıp serisinde lot azalt (min 0.5x)
         double multiplier = 1.0 - (g_consecutiveLosses - 1) * 0.2;
         return NormalizeLot(baseLot * MathMax(multiplier, 0.5));
      }
      
      return baseLot;
   }
   
   static int GetAdaptiveThreshold() {
      // Performansa göre sinyal eşiği ayarla
      if(g_consecutiveLosses >= 3)
         return InpMinSignalScore + 10;  // Daha seçici ol
      else if(g_consecutiveWins >= 3)
         return InpMinSignalScore - 5;   // Daha agresif ol
      
      return InpMinSignalScore;
   }
   
   static bool ShouldPauseTrading() {
      // Günlük hedef aşıldıysa dur
      if(g_dailyProfit >= AccountInfoDouble(ACCOUNT_BALANCE) * 0.05) {
         if(InpShowDebugLog)
            WriteLog("🎯 GÜNLÜK HEDEF AŞILDI: $" + DoubleToString(g_dailyProfit, 2));
         return true;
      }
      
      // Çok fazla ardışık kayıp
      if(g_consecutiveLosses >= 5) {
         if(InpShowDebugLog)
            WriteLog("⛔ 5 ARDIŞIK KAYIP - MOLA");
         return true;
      }
      
      return false;
   }
};

//====================================================================
// CLASS: CVolatilityAnalyzer - VOLATİLİTE ANALİZİ
//====================================================================
class CVolatilityAnalyzer {
public:
   static string GetMarketRegime(double atr) {
      double avgATR = GetAverageATR(20);
      
      if(avgATR == 0) return "BILINMIYOR";
      
      double ratio = atr / avgATR;
      
      if(ratio > 1.5) return "YUKSEK_VOLATILITE";
      if(ratio < 0.7) return "DUSUK_VOLATILITE";
      if(ratio >= 0.9 && ratio <= 1.1) return "NORMAL";
      
      return "TREND";
   }
   
   static double GetAverageATR(int period) {
      double atr[];
      ArraySetAsSeries(atr, true);
      
      if(CopyBuffer(g_hATR, 0, 0, period, atr) < period)
         return 0;
      
      double sum = 0;
      for(int i = 0; i < period; i++)
         sum += atr[i];
      
      return sum / period;
   }
   
   static bool IsVolatilitySafe(double atr) {
      double avgATR = GetAverageATR(20);
      if(avgATR == 0) return true;
      
      double ratio = atr / avgATR;
      
      // Aşırı volatilitede işlem yapma
      if(ratio > 2.5) return false;
      
      // Çok düşük volatilitede de dikkatli ol
      if(ratio < 0.3) return false;
      
      return true;
   }
};

//====================================================================
// OnChartEvent - KULLANICI ETKİLEŞİMİ
//====================================================================
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
   // Panel butonu tıklamaları için
   if(id == CHARTEVENT_OBJECT_CLICK) {
      if(StringFind(sparam, "Harmony_") >= 0) {
         // Panel etkileşimleri burada işlenebilir
      }
   }
}

//====================================================================
// CLASS: CSmartMoneyConcepts - ICT/SMC ANALİZİ
//====================================================================
class CSmartMoneyConcepts {
public:
   //--- Order Block Tespiti (Büyük kurumsal emirlerin bıraktığı izler)
   static bool DetectOrderBlock(int &direction, double &obHigh, double &obLow) {
      // Son 50 bar'da güçlü hareket arayalım
      int lookback = 50;
      
      for(int i = 3; i < lookback; i++) {
         double open_i = iOpen(_Symbol, InpTimeframe, i);
         double close_i = iClose(_Symbol, InpTimeframe, i);
         double high_i = iHigh(_Symbol, InpTimeframe, i);
         double low_i = iLow(_Symbol, InpTimeframe, i);
         
         double open_prev = iOpen(_Symbol, InpTimeframe, i + 1);
         double close_prev = iClose(_Symbol, InpTimeframe, i + 1);
         
         double bodySize = MathAbs(close_i - open_i);
         double range = high_i - low_i;
         
         // Güçlü momentum bar
         if(bodySize > range * 0.7) {
            // Bullish Order Block
            if(close_i > open_i && close_prev < open_prev) {
               // Önceki düşüş mumu = Order Block
               double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               if(currentPrice > iLow(_Symbol, InpTimeframe, i + 1) && 
                  currentPrice < iHigh(_Symbol, InpTimeframe, i + 1)) {
                  direction = 1;
                  obHigh = iHigh(_Symbol, InpTimeframe, i + 1);
                  obLow = iLow(_Symbol, InpTimeframe, i + 1);
                  return true;
               }
            }
            // Bearish Order Block
            else if(close_i < open_i && close_prev > open_prev) {
               double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               if(currentPrice > iLow(_Symbol, InpTimeframe, i + 1) && 
                  currentPrice < iHigh(_Symbol, InpTimeframe, i + 1)) {
                  direction = -1;
                  obHigh = iHigh(_Symbol, InpTimeframe, i + 1);
                  obLow = iLow(_Symbol, InpTimeframe, i + 1);
                  return true;
               }
            }
         }
      }
      return false;
   }
   
   //--- Fair Value Gap (FVG) Tespiti
   static bool DetectFVG(int &direction, double &fvgHigh, double &fvgLow) {
      int lookback = 30;
      
      for(int i = 2; i < lookback; i++) {
         double high1 = iHigh(_Symbol, InpTimeframe, i + 2);
         double low1 = iLow(_Symbol, InpTimeframe, i + 2);
         double high2 = iHigh(_Symbol, InpTimeframe, i + 1);
         double low2 = iLow(_Symbol, InpTimeframe, i + 1);
         double high3 = iHigh(_Symbol, InpTimeframe, i);
         double low3 = iLow(_Symbol, InpTimeframe, i);
         
         // Bullish FVG: Mum1 High < Mum3 Low
         if(high1 < low3) {
            double gap = low3 - high1;
            double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            
            if(currentPrice >= high1 && currentPrice <= low3) {
               direction = 1;
               fvgHigh = low3;
               fvgLow = high1;
               return true;
            }
         }
         
         // Bearish FVG: Mum1 Low > Mum3 High
         if(low1 > high3) {
            double gap = low1 - high3;
            double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            
            if(currentPrice >= high3 && currentPrice <= low1) {
               direction = -1;
               fvgHigh = low1;
               fvgLow = high3;
               return true;
            }
         }
      }
      return false;
   }
   
   //--- Liquidity Pool Tespiti (Eşit High/Low'lar)
   static bool DetectLiquidityPool(int &direction, double &level) {
      int lookback = 50;
      double tolerance = PipToPoints(2);
      
      // Equal Highs (Sell-side Liquidity)
      double equalHighs[];
      int ehCount = 0;
      
      for(int i = 2; i < lookback; i++) {
         double high_i = iHigh(_Symbol, InpTimeframe, i);
         
         for(int j = i + 1; j < lookback; j++) {
            double high_j = iHigh(_Symbol, InpTimeframe, j);
            
            if(MathAbs(high_i - high_j) < tolerance) {
               // Eşit high bulundu
               double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               if(currentPrice >= high_i - tolerance * 2) {
                  direction = -1;  // Liquidity alındıktan sonra düşüş beklenir
                  level = high_i;
                  return true;
               }
            }
         }
      }
      
      // Equal Lows (Buy-side Liquidity)
      for(int i = 2; i < lookback; i++) {
         double low_i = iLow(_Symbol, InpTimeframe, i);
         
         for(int j = i + 1; j < lookback; j++) {
            double low_j = iLow(_Symbol, InpTimeframe, j);
            
            if(MathAbs(low_i - low_j) < tolerance) {
               double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
               if(currentPrice <= low_i + tolerance * 2) {
                  direction = 1;  // Liquidity alındıktan sonra yükseliş beklenir
                  level = low_i;
                  return true;
               }
            }
         }
      }
      
      return false;
   }
   
   //--- Market Structure (Break of Structure / Change of Character)
   static int AnalyzeMarketStructure() {
      // Son swing high/low'ları bul
      double swingHighs[], swingLows[];
      ArrayResize(swingHighs, 0);
      ArrayResize(swingLows, 0);
      
      int lookback = 50;
      
      for(int i = 2; i < lookback - 2; i++) {
         double high_i = iHigh(_Symbol, InpTimeframe, i);
         double low_i = iLow(_Symbol, InpTimeframe, i);
         
         bool isSwingHigh = (high_i > iHigh(_Symbol, InpTimeframe, i-1) &&
                             high_i > iHigh(_Symbol, InpTimeframe, i-2) &&
                             high_i > iHigh(_Symbol, InpTimeframe, i+1) &&
                             high_i > iHigh(_Symbol, InpTimeframe, i+2));
         
         bool isSwingLow = (low_i < iLow(_Symbol, InpTimeframe, i-1) &&
                            low_i < iLow(_Symbol, InpTimeframe, i-2) &&
                            low_i < iLow(_Symbol, InpTimeframe, i+1) &&
                            low_i < iLow(_Symbol, InpTimeframe, i+2));
         
         if(isSwingHigh) {
            ArrayResize(swingHighs, ArraySize(swingHighs) + 1);
            swingHighs[ArraySize(swingHighs) - 1] = high_i;
         }
         if(isSwingLow) {
            ArrayResize(swingLows, ArraySize(swingLows) + 1);
            swingLows[ArraySize(swingLows) - 1] = low_i;
         }
      }
      
      if(ArraySize(swingHighs) < 2 || ArraySize(swingLows) < 2) return 0;
      
      // Higher Highs & Higher Lows = Uptrend
      if(swingHighs[0] > swingHighs[1] && swingLows[0] > swingLows[1])
         return 1;
      
      // Lower Highs & Lower Lows = Downtrend
      if(swingHighs[0] < swingHighs[1] && swingLows[0] < swingLows[1])
         return -1;
      
      return 0;
   }
   
   //--- SMC Sinyal Skoru
   static int GetSMCScore(int direction) {
      int score = 0;
      
      // Order Block kontrolü
      int obDir = 0;
      double obH, obL;
      if(DetectOrderBlock(obDir, obH, obL) && obDir == direction)
         score += 25;
      
      // FVG kontrolü
      int fvgDir = 0;
      double fvgH, fvgL;
      if(DetectFVG(fvgDir, fvgH, fvgL) && fvgDir == direction)
         score += 20;
      
      // Market Structure
      if(AnalyzeMarketStructure() == direction)
         score += 30;
      
      return score;
   }
};

//====================================================================
// CLASS: CSessionAnalyzer - MARKET SESSION ANALİZİ
//====================================================================
class CSessionAnalyzer {
public:
   static string GetCurrentSession() {
      MqlDateTime dt;
      TimeCurrent(dt);
      int hour = dt.hour;
      
      // GMT+0 bazlı (broker saatine göre ayarla)
      if(hour >= 0 && hour < 8) return "ASIA";
      if(hour >= 8 && hour < 12) return "LONDON";
      if(hour >= 12 && hour < 17) return "OVERLAP";
      if(hour >= 17 && hour < 22) return "NEW_YORK";
      
      return "OFF_HOURS";
   }
   
   static double GetSessionVolatility() {
      string session = GetCurrentSession();
      
      // Session'a göre ortalama volatilite çarpanı
      if(session == "OVERLAP") return 1.3;      // En volatil
      if(session == "LONDON") return 1.2;
      if(session == "NEW_YORK") return 1.1;
      if(session == "ASIA") return 0.7;         // En sakin
      
      return 0.5;  // Off hours
   }
   
   static bool IsHighImpactSession() {
      string session = GetCurrentSession();
      return (session == "LONDON" || session == "OVERLAP" || session == "NEW_YORK");
   }
   
   static color GetSessionColor() {
      string session = GetCurrentSession();
      
      if(session == "ASIA") return clrYellow;
      if(session == "LONDON") return clrDodgerBlue;
      if(session == "OVERLAP") return clrMagenta;
      if(session == "NEW_YORK") return clrOrange;
      
      return clrGray;
   }
};

//====================================================================
// CLASS: CChandelierTrail - CHANDELIER EXIT TRAİLİNG
//====================================================================
class CChandelierTrail {
public:
   static double Calculate(int posType, int period = 22, double multiplier = 3.0) {
      double atr[];
      ArraySetAsSeries(atr, true);
      
      if(CopyBuffer(g_hATR, 0, 0, 1, atr) < 1) return 0;
      
      double chandelier = atr[0] * multiplier;
      
      if(posType == POSITION_TYPE_BUY) {
         // En yüksek high - (ATR * Multiplier)
         double highestHigh = 0;
         for(int i = 0; i < period; i++) {
            double h = iHigh(_Symbol, InpTimeframe, i);
            if(h > highestHigh) highestHigh = h;
         }
         return highestHigh - chandelier;
      }
      else {
         // En düşük low + (ATR * Multiplier)
         double lowestLow = 999999;
         for(int i = 0; i < period; i++) {
            double l = iLow(_Symbol, InpTimeframe, i);
            if(l < lowestLow) lowestLow = l;
         }
         return lowestLow + chandelier;
      }
   }
};

//====================================================================
// CLASS: CParabolicTrail - PARABOLIC SAR TRAİLİNG
//====================================================================
class CParabolicTrail {
private:
   static double m_sar;
   static double m_ep;
   static double m_af;
   static bool m_isLong;
   
public:
   static void Init(bool isLong) {
      m_isLong = isLong;
      m_af = 0.02;
      
      if(isLong) {
         m_sar = iLow(_Symbol, InpTimeframe, 1);
         m_ep = iHigh(_Symbol, InpTimeframe, 1);
      } else {
         m_sar = iHigh(_Symbol, InpTimeframe, 1);
         m_ep = iLow(_Symbol, InpTimeframe, 1);
      }
   }
   
   static double Calculate() {
      double high = iHigh(_Symbol, InpTimeframe, 0);
      double low = iLow(_Symbol, InpTimeframe, 0);
      
      if(m_isLong) {
         if(high > m_ep) {
            m_ep = high;
            m_af = MathMin(m_af + 0.02, 0.2);
         }
         m_sar = m_sar + m_af * (m_ep - m_sar);
         m_sar = MathMin(m_sar, iLow(_Symbol, InpTimeframe, 1));
         m_sar = MathMin(m_sar, iLow(_Symbol, InpTimeframe, 2));
      }
      else {
         if(low < m_ep) {
            m_ep = low;
            m_af = MathMin(m_af + 0.02, 0.2);
         }
         m_sar = m_sar + m_af * (m_ep - m_sar);
         m_sar = MathMax(m_sar, iHigh(_Symbol, InpTimeframe, 1));
         m_sar = MathMax(m_sar, iHigh(_Symbol, InpTimeframe, 2));
      }
      
      return m_sar;
   }
};

// Static değişkenler
double CParabolicTrail::m_sar = 0;
double CParabolicTrail::m_ep = 0;
double CParabolicTrail::m_af = 0.02;
bool CParabolicTrail::m_isLong = true;

//====================================================================
// CLASS: CStochastic - STOCHASTIC SKORLAMASI
//====================================================================
class CStochasticAnalyzer {
private:
   static int m_handle;
   
public:
   static void Init() {
      m_handle = iStochastic(_Symbol, InpTimeframe, 14, 3, 3, MODE_SMA, STO_LOWHIGH);
   }
   
   static void Release() {
      if(m_handle != INVALID_HANDLE) IndicatorRelease(m_handle);
   }
   
   static double GetScore(int direction) {
      if(m_handle == INVALID_HANDLE) return 50;
      
      double k[], d[];
      ArraySetAsSeries(k, true);
      ArraySetAsSeries(d, true);
      
      if(CopyBuffer(m_handle, 0, 0, 2, k) < 2) return 50;
      if(CopyBuffer(m_handle, 1, 0, 2, d) < 2) return 50;
      
      double score = 50;
      bool crossUp = (k[1] <= d[1] && k[0] > d[0]);
      bool crossDown = (k[1] >= d[1] && k[0] < d[0]);
      
      if(direction == 1) {
         if(k[0] < 20) score = 90;        // Oversold
         else if(k[0] < 40) score = 70;
         if(crossUp && k[0] < 50) score += 15;
      }
      else if(direction == -1) {
         if(k[0] > 80) score = 90;        // Overbought
         else if(k[0] > 60) score = 70;
         if(crossDown && k[0] > 50) score += 15;
      }
      
      return MathMin(100, score);
   }
};
int CStochasticAnalyzer::m_handle = INVALID_HANDLE;

//====================================================================
// CLASS: CBollingerBands - BOLLINGER BANDS ANALİZİ
//====================================================================
class CBollingerAnalyzer {
private:
   static int m_handle;
   
public:
   static void Init() {
      m_handle = iBands(_Symbol, InpTimeframe, 20, 0, 2.0, PRICE_CLOSE);
   }
   
   static void Release() {
      if(m_handle != INVALID_HANDLE) IndicatorRelease(m_handle);
   }
   
   static double GetScore(int direction) {
      if(m_handle == INVALID_HANDLE) return 50;
      
      double mid[], upper[], lower[];
      ArraySetAsSeries(mid, true);
      ArraySetAsSeries(upper, true);
      ArraySetAsSeries(lower, true);
      
      if(CopyBuffer(m_handle, 0, 0, 1, mid) < 1) return 50;
      if(CopyBuffer(m_handle, 1, 0, 1, upper) < 1) return 50;
      if(CopyBuffer(m_handle, 2, 0, 1, lower) < 1) return 50;
      
      double price = iClose(_Symbol, InpTimeframe, 0);
      double bandWidth = upper[0] - lower[0];
      double pricePosition = (price - lower[0]) / bandWidth * 100;  // 0-100
      
      double score = 50;
      
      if(direction == 1) {
         if(price <= lower[0]) score = 95;           // Alt banda değdi
         else if(pricePosition < 20) score = 80;     // Alt banda yakın
         else if(pricePosition > 80) score = 30;     // Üst banda yakın
      }
      else if(direction == -1) {
         if(price >= upper[0]) score = 95;           // Üst banda değdi
         else if(pricePosition > 80) score = 80;     // Üst banda yakın
         else if(pricePosition < 20) score = 30;     // Alt banda yakın
      }
      
      return score;
   }
   
   static bool IsSqueeze() {
      if(m_handle == INVALID_HANDLE) return false;
      
      double upper[], lower[];
      ArraySetAsSeries(upper, true);
      ArraySetAsSeries(lower, true);
      
      if(CopyBuffer(m_handle, 1, 0, 20, upper) < 20) return false;
      if(CopyBuffer(m_handle, 2, 0, 20, lower) < 20) return false;
      
      double currentWidth = upper[0] - lower[0];
      double avgWidth = 0;
      for(int i = 0; i < 20; i++)
         avgWidth += (upper[i] - lower[i]);
      avgWidth /= 20;
      
      return (currentWidth < avgWidth * 0.5);  // Squeeze = band çok dar
   }
};
int CBollingerAnalyzer::m_handle = INVALID_HANDLE;

//====================================================================
// CLASS: CEquityCurveFilter - EQUİTY EĞRİSİ FİLTRESİ
//====================================================================
class CEquityCurveFilter {
public:
   static bool ShouldTrade() {
      // Son 10 işlemin performansına bak
      if(g_totalTrades < 10) return true;
      
      // Equity eğrisi pozitifse işlem yap
      double recentWinRate = 0;
      if(g_totalTrades > 0) {
         recentWinRate = (double)g_winTrades / g_totalTrades;
      }
      
      // Win rate %35'in altına düşerse dur
      if(recentWinRate < 0.35) {
         if(InpShowDebugLog)
            WriteLog("⚠️ Win rate düşük: " + DoubleToString(recentWinRate * 100, 1) + "%");
         return false;
      }
      
      // Drawdown çok yüksekse dur
      if(g_maxDrawdown > 25) {
         if(InpShowDebugLog)
            WriteLog("⚠️ DD yüksek: " + DoubleToString(g_maxDrawdown, 1) + "%");
         return false;
      }
      
      return true;
   }
};

//====================================================================
// CLASS: CTradeLogger - İŞLEM KAYIT SİSTEMİ
//====================================================================
class CTradeLogger {
public:
   static void LogTrade(string action, double lot, double price, double sl, double tp) {
      string msg = StringFormat(
         "[%s] %s | Lot: %.2f | Price: %.5f | SL: %.5f | TP: %.5f",
         TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
         action, lot, price, sl, tp
      );
      
      // Dosyaya yaz
      int handle = FileOpen("Harmony_TradeLog.csv", FILE_WRITE | FILE_READ | FILE_CSV | FILE_COMMON);
      if(handle != INVALID_HANDLE) {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, msg);
         FileClose(handle);
      }
      
      Print(msg);
   }
   
   static void LogSignal(int direction, int score, string reason) {
      string msg = StringFormat(
         "[%s] SİNYAL: %s | Skor: %d | %s",
         TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS),
         direction == 1 ? "BUY" : "SELL",
         score, reason
      );
      
      Print(msg);
   }
};

//====================================================================
// CLASS: CAlertManager - BİLDİRİM SİSTEMİ
//====================================================================
class CAlertManager {
public:
   static void SendSignalAlert(int direction, int score) {
      string symbol = _Symbol;
      string dirStr = (direction == 1) ? "BUY" : "SELL";
      string msg = StringFormat("HARMONY EA: %s sinyali | %s | Skor: %d/100", 
                                dirStr, symbol, score);
      
      Alert(msg);
      
      // Push notification (opsiyonel)
      // SendNotification(msg);
   }
   
   static void SendTradeAlert(string action, double profit) {
      string symbol = _Symbol;
      string msg = StringFormat("HARMONY EA: %s | %s | Kar: $%.2f", 
                                action, symbol, profit);
      
      if(profit >= 0)
         Print("🏆 " + msg);
      else
         Print("❌ " + msg);
   }
};

//====================================================================
// CLASS: CHedgeManager - HEDGE KORUMA SİSTEMİ
//====================================================================
class CHedgeManager {
public:
   static bool OpenHedgePosition(ulong mainTicket, double hedgeLotPercent = 50.0) {
      if(!PositionSelectByTicket(mainTicket)) return false;
      
      double mainLot = PositionGetDouble(POSITION_VOLUME);
      double mainProfit = PositionGetDouble(POSITION_PROFIT);
      double mainSL = PositionGetDouble(POSITION_SL);
      double mainEntry = PositionGetDouble(POSITION_PRICE_OPEN);
      long mainType = PositionGetInteger(POSITION_TYPE);
      
      // Sadece kayıpta olan pozisyonları hedge et
      if(mainProfit >= 0) return false;
      
      // SL mesafesinin belli bir yüzdesi kayıpta mı kontrol et
      double slDist = MathAbs(mainEntry - mainSL);
      double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      double lossDistance = (mainType == POSITION_TYPE_BUY) ? 
                            (mainEntry - currentPrice) : (currentPrice - mainEntry);
      
      // %50'den fazla SL'ye yaklaştıysa hedge aç
      if(lossDistance < slDist * 0.5) return false;
      
      double hedgeLot = NormalizeLot(mainLot * hedgeLotPercent / 100.0);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      // Karşı yönde pozisyon aç
      if(mainType == POSITION_TYPE_BUY) {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double sl = NormalizeDouble(bid + slDist * 0.5, digits);
         double tp = NormalizeDouble(bid - slDist * 0.3, digits);
         
         if(g_trade.Sell(hedgeLot, _Symbol, 0, sl, tp, "Hedge_" + InpTradeComment)) {
            WriteLog("🛡️ HEDGE SELL açıldı | Lot: " + DoubleToString(hedgeLot, 2));
            return true;
         }
      }
      else {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double sl = NormalizeDouble(ask - slDist * 0.5, digits);
         double tp = NormalizeDouble(ask + slDist * 0.3, digits);
         
         if(g_trade.Buy(hedgeLot, _Symbol, 0, sl, tp, "Hedge_" + InpTradeComment)) {
            WriteLog("🛡️ HEDGE BUY açıldı | Lot: " + DoubleToString(hedgeLot, 2));
            return true;
         }
      }
      
      return false;
   }
   
   static void CheckAndHedge() {
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         
         string comment = PositionGetString(POSITION_COMMENT);
         if(StringFind(comment, "Hedge_") >= 0) continue;  // Zaten hedge pozisyonu
         
         // Ana pozisyon için hedge kontrolü
         OpenHedgePosition(ticket, 50.0);
      }
   }
};

//====================================================================
// CLASS: CStatePersistence - DURUM SAKLAMA (EA yeniden başladığında)
//====================================================================
class CStatePersistence {
private:
   static string m_filename;
   
public:
   static void Init() {
      m_filename = "Harmony_State_" + _Symbol + ".dat";
   }
   
   static bool SaveState() {
      int handle = FileOpen(m_filename, FILE_WRITE | FILE_BIN | FILE_COMMON);
      if(handle == INVALID_HANDLE) return false;
      
      // İstatistikleri kaydet
      FileWriteInteger(handle, g_totalTrades);
      FileWriteInteger(handle, g_winTrades);
      FileWriteInteger(handle, g_lossTrades);
      FileWriteDouble(handle, g_totalProfit);
      FileWriteDouble(handle, g_maxDrawdown);
      FileWriteInteger(handle, g_consecutiveWins);
      FileWriteInteger(handle, g_consecutiveLosses);
      FileWriteDouble(handle, g_equityHigh);
      FileWriteDouble(handle, g_refBalance);
      FileWriteInteger(handle, g_dailyTradeCount);
      FileWriteDouble(handle, g_dailyProfit);
      
      FileClose(handle);
      WriteLog("💾 Durum kaydedildi: " + m_filename);
      return true;
   }
   
   static bool LoadState() {
      if(!FileIsExist(m_filename, FILE_COMMON)) return false;
      
      int handle = FileOpen(m_filename, FILE_READ | FILE_BIN | FILE_COMMON);
      if(handle == INVALID_HANDLE) return false;
      
      // İstatistikleri yükle
      g_totalTrades = FileReadInteger(handle);
      g_winTrades = FileReadInteger(handle);
      g_lossTrades = FileReadInteger(handle);
      g_totalProfit = FileReadDouble(handle);
      g_maxDrawdown = FileReadDouble(handle);
      g_consecutiveWins = FileReadInteger(handle);
      g_consecutiveLosses = FileReadInteger(handle);
      g_equityHigh = FileReadDouble(handle);
      g_refBalance = FileReadDouble(handle);
      g_dailyTradeCount = FileReadInteger(handle);
      g_dailyProfit = FileReadDouble(handle);
      
      FileClose(handle);
      WriteLog("📂 Durum yüklendi: " + m_filename);
      return true;
   }
   
   static void ClearState() {
      if(FileIsExist(m_filename, FILE_COMMON))
         FileDelete(m_filename, FILE_COMMON);
   }
};
string CStatePersistence::m_filename = "";

//====================================================================
// CLASS: CPositionScaling - POZİSYON ÖLÇEKLENDİRME (Scale-In/Out)
//====================================================================
class CPositionScaling {
public:
   //--- Scale-In: Kârdayken pozisyon ekle
   static bool ScaleIn(ulong mainTicket, double scalePercent = 50.0, double triggerPercent = 40.0) {
      if(!PositionSelectByTicket(mainTicket)) return false;
      
      double mainLot = PositionGetDouble(POSITION_VOLUME);
      double mainEntry = PositionGetDouble(POSITION_PRICE_OPEN);
      double mainTP = PositionGetDouble(POSITION_TP);
      double mainSL = PositionGetDouble(POSITION_SL);
      long mainType = PositionGetInteger(POSITION_TYPE);
      double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
      
      if(mainTP == 0) return false;
      
      double tpDist = MathAbs(mainTP - mainEntry);
      double profitDist = (mainType == POSITION_TYPE_BUY) ? 
                          (currentPrice - mainEntry) : (mainEntry - currentPrice);
      
      // TP'nin %40'ına ulaştıysa scale-in
      if(profitDist < tpDist * (triggerPercent / 100.0)) return false;
      
      double scaleLot = NormalizeLot(mainLot * scalePercent / 100.0);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      // Aynı yönde ek pozisyon
      if(mainType == POSITION_TYPE_BUY) {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         if(g_trade.Buy(scaleLot, _Symbol, 0, mainSL, mainTP, "ScaleIn_" + InpTradeComment)) {
            WriteLog("📈 SCALE-IN BUY | Lot: " + DoubleToString(scaleLot, 2));
            return true;
         }
      }
      else {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(g_trade.Sell(scaleLot, _Symbol, 0, mainSL, mainTP, "ScaleIn_" + InpTradeComment)) {
            WriteLog("📉 SCALE-IN SELL | Lot: " + DoubleToString(scaleLot, 2));
            return true;
         }
      }
      
      return false;
   }
   
   //--- Scale-Out: Kâr elde et, pozisyonu küçült
   static bool ScaleOut(ulong ticket, double closePercent = 25.0) {
      if(!PositionSelectByTicket(ticket)) return false;
      
      double volume = PositionGetDouble(POSITION_VOLUME);
      double minVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      
      double closeVol = MathFloor((volume * closePercent / 100.0) / lotStep) * lotStep;
      if(closeVol < minVol) return false;
      
      if(g_trade.PositionClosePartial(ticket, closeVol)) {
         WriteLog("💰 SCALE-OUT | Kapatılan: " + DoubleToString(closeVol, 2) + " lot");
         return true;
      }
      
      return false;
   }
};

//====================================================================
// CLASS: CCorrelationFilter - ÇİFT KORELASYON FİLTRESİ
//====================================================================
class CCorrelationFilter {
public:
   static double CalculateCorrelation(string symbol1, string symbol2, int period = 50) {
      double prices1[], prices2[];
      ArrayResize(prices1, period);
      ArrayResize(prices2, period);
      
      // Fiyatları al
      for(int i = 0; i < period; i++) {
         prices1[i] = iClose(symbol1, InpTimeframe, i);
         prices2[i] = iClose(symbol2, InpTimeframe, i);
      }
      
      // Ortalamalar
      double mean1 = 0, mean2 = 0;
      for(int i = 0; i < period; i++) {
         mean1 += prices1[i];
         mean2 += prices2[i];
      }
      mean1 /= period;
      mean2 /= period;
      
      // Korelasyon hesapla
      double sumXY = 0, sumX2 = 0, sumY2 = 0;
      for(int i = 0; i < period; i++) {
         double dx = prices1[i] - mean1;
         double dy = prices2[i] - mean2;
         sumXY += dx * dy;
         sumX2 += dx * dx;
         sumY2 += dy * dy;
      }
      
      double denom = MathSqrt(sumX2 * sumY2);
      if(denom == 0) return 0;
      
      return sumXY / denom;  // -1 ile +1 arası
   }
   
   static bool HasHighCorrelation(string otherSymbol, double threshold = 0.7) {
      double corr = CalculateCorrelation(_Symbol, otherSymbol);
      return (MathAbs(corr) >= threshold);
   }
   
   static bool ShouldAvoidTrade(int direction) {
      // Aynı yönde, yüksek korelasyonlu çiftte açık pozisyon var mı?
      string correlatedPairs[];
      
      // Major çiftler için korelasyon kontrolü
      if(_Symbol == "EURUSD" || _Symbol == "GBPUSD") {
         // EURUSD ve GBPUSD pozitif korelasyon
         for(int i = PositionsTotal() - 1; i >= 0; i--) {
            ulong ticket = PositionGetTicket(i);
            if(ticket == 0) continue;
            
            string posSymbol = PositionGetString(POSITION_SYMBOL);
            if(posSymbol == _Symbol) continue;
            
            if((posSymbol == "EURUSD" || posSymbol == "GBPUSD") && 
               HasHighCorrelation(posSymbol)) {
               long posType = PositionGetInteger(POSITION_TYPE);
               int posDir = (posType == POSITION_TYPE_BUY) ? 1 : -1;
               
               if(posDir == direction) {
                  WriteLog("⚠️ Korelasyon uyarısı: " + posSymbol + " zaten açık");
                  return true;  // İşlem yapma
               }
            }
         }
      }
      
      return false;
   }
};

//====================================================================
// CLASS: CTimeBasedExit - ZAMAN BAZLI ÇIKIŞ
//====================================================================
class CTimeBasedExit {
public:
   static void CheckTimeExit(int maxHours = 48) {
      datetime now = TimeCurrent();
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         
         datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
         int hoursOpen = (int)((now - openTime) / 3600);
         
         if(hoursOpen >= maxHours) {
            double profit = PositionGetDouble(POSITION_PROFIT);
            
            // Zaman aşımı - pozisyonu kapat
            if(g_trade.PositionClose(ticket)) {
               WriteLog("⏰ ZAMAN AŞIMI: " + IntegerToString(hoursOpen) + " saat | Kar: $" + 
                        DoubleToString(profit, 2));
            }
         }
      }
   }
   
   static void CheckFridayClose(int fridayHour = 20) {
      MqlDateTime dt;
      TimeCurrent(dt);
      
      // Cuma günü belirli saatten sonra tüm pozisyonları kapat
      if(dt.day_of_week == 5 && dt.hour >= fridayHour) {
         for(int i = PositionsTotal() - 1; i >= 0; i--) {
            ulong ticket = PositionGetTicket(i);
            if(ticket == 0) continue;
            if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
            if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
            
            double profit = PositionGetDouble(POSITION_PROFIT);
            
            if(g_trade.PositionClose(ticket)) {
               WriteLog("📅 CUMA KAPANIŞ | Kar: $" + DoubleToString(profit, 2));
            }
         }
      }
   }
};

//====================================================================
// CLASS: CHTMLReportGenerator - HTML RAPOR OLUŞTURUCU
//====================================================================
class CHTMLReportGenerator {
public:
   static void GenerateReport() {
      string filename = "Harmony_Report_" + _Symbol + ".html";
      int handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
      
      if(handle == INVALID_HANDLE) {
         WriteLog("❌ Rapor dosyası açılamadı");
         return;
      }
      
      // HTML başlık
      string html = "<!DOCTYPE html>\n";
      html += "<html><head><meta charset='UTF-8'>\n";
      html += "<title>Ultimate Harmony EA - Rapor</title>\n";
      html += "<style>\n";
      html += "body { font-family: Arial, sans-serif; background: #1a1a2e; color: #eee; padding: 20px; }\n";
      html += ".container { max-width: 900px; margin: 0 auto; }\n";
      html += "h1 { color: #00d4ff; text-align: center; }\n";
      html += ".card { background: #16213e; padding: 20px; border-radius: 10px; margin: 15px 0; }\n";
      html += ".stat { display: inline-block; width: 30%; text-align: center; padding: 15px; }\n";
      html += ".stat h3 { margin: 0; color: #888; font-size: 14px; }\n";
      html += ".stat p { margin: 5px 0 0 0; font-size: 24px; font-weight: bold; }\n";
      html += ".green { color: #00ff88; }\n";
      html += ".red { color: #ff4444; }\n";
      html += ".yellow { color: #ffcc00; }\n";
      html += "table { width: 100%; border-collapse: collapse; margin-top: 15px; }\n";
      html += "th, td { padding: 12px; text-align: left; border-bottom: 1px solid #333; }\n";
      html += "th { background: #0f3460; color: #00d4ff; }\n";
      html += "</style></head><body>\n";
      
      // Başlık
      html += "<div class='container'>\n";
      html += "<h1>🌟 ULTIMATE HARMONY EA</h1>\n";
      html += "<p style='text-align:center;color:#888;'>Rapor Tarihi: " + 
              TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS) + "</p>\n";
      
      // Özet kartı
      html += "<div class='card'>\n";
      html += "<h2>📊 Performans Özeti</h2>\n";
      
      double winRate = (g_totalTrades > 0) ? (double)g_winTrades / g_totalTrades * 100 : 0;
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      
      html += "<div class='stat'><h3>Toplam İşlem</h3><p>" + IntegerToString(g_totalTrades) + "</p></div>\n";
      html += "<div class='stat'><h3>Kazanan</h3><p class='green'>" + IntegerToString(g_winTrades) + "</p></div>\n";
      html += "<div class='stat'><h3>Kaybeden</h3><p class='red'>" + IntegerToString(g_lossTrades) + "</p></div>\n";
      html += "<div class='stat'><h3>Win Rate</h3><p class='" + (winRate >= 50 ? "green" : "yellow") + "'>" + 
              DoubleToString(winRate, 1) + "%</p></div>\n";
      html += "<div class='stat'><h3>Toplam Kar</h3><p class='" + (g_totalProfit >= 0 ? "green" : "red") + "'>$" + 
              DoubleToString(g_totalProfit, 2) + "</p></div>\n";
      html += "<div class='stat'><h3>Max Drawdown</h3><p class='" + (g_maxDrawdown < 20 ? "green" : "red") + "'>" + 
              DoubleToString(g_maxDrawdown, 2) + "%</p></div>\n";
      html += "</div>\n";
      
      // Hesap bilgileri
      html += "<div class='card'>\n";
      html += "<h2>💰 Hesap Bilgileri</h2>\n";
      html += "<table>\n";
      html += "<tr><td>Bakiye</td><td class='green'>$" + DoubleToString(balance, 2) + "</td></tr>\n";
      html += "<tr><td>Equity</td><td>$" + DoubleToString(equity, 2) + "</td></tr>\n";
      html += "<tr><td>Günlük Kar</td><td class='" + (g_dailyProfit >= 0 ? "green" : "red") + "'>$" + 
              DoubleToString(g_dailyProfit, 2) + "</td></tr>\n";
      html += "<tr><td>Ardışık Kazanç</td><td>" + IntegerToString(g_consecutiveWins) + "</td></tr>\n";
      html += "<tr><td>Ardışık Kayıp</td><td>" + IntegerToString(g_consecutiveLosses) + "</td></tr>\n";
      html += "</table>\n";
      html += "</div>\n";
      
      // Ayarlar
      html += "<div class='card'>\n";
      html += "<h2>⚙️ EA Ayarları</h2>\n";
      html += "<table>\n";
      html += "<tr><td>Sembol</td><td>" + _Symbol + "</td></tr>\n";
      html += "<tr><td>Timeframe</td><td>" + EnumToString(InpTimeframe) + "</td></tr>\n";
      html += "<tr><td>Magic Number</td><td>" + IntegerToString(InpMagicNumber) + "</td></tr>\n";
      html += "<tr><td>Lot Modu</td><td>" + EnumToString(InpLotMode) + "</td></tr>\n";
      html += "<tr><td>Risk %</td><td>" + DoubleToString(InpRiskPercent, 1) + "%</td></tr>\n";
      html += "<tr><td>Min Sinyal Skoru</td><td>" + IntegerToString(InpMinSignalScore) + "</td></tr>\n";
      html += "</table>\n";
      html += "</div>\n";
      
      // Footer
      html += "<p style='text-align:center;color:#666;margin-top:30px;'>\n";
      html += "Ultimate Harmony EA v2.0 | © 2025\n";
      html += "</p>\n";
      
      html += "</div></body></html>";
      
      FileWriteString(handle, html);
      FileClose(handle);
      
      WriteLog("📄 HTML Rapor oluşturuldu: " + filename);
   }
};

//====================================================================
// CLASS: CEmergencyManager - ACİL DURUM YÖNETİMİ
//====================================================================
class CEmergencyManager {
public:
   static void EmergencyCloseAll(string reason = "Acil durum") {
      PrintSeparator();
      WriteLog("🚨 ACİL KAPANIŞ: " + reason);
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         
         double profit = PositionGetDouble(POSITION_PROFIT);
         g_trade.PositionClose(ticket);
         WriteLog("   Kapatıldı: #" + IntegerToString(ticket) + " | Kar: $" + DoubleToString(profit, 2));
      }
      
      // Bekleyen emirleri de iptal et
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetInteger(ORDER_MAGIC) != InpMagicNumber) continue;
         if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
         
         g_trade.OrderDelete(ticket);
         WriteLog("   Emir iptal: #" + IntegerToString(ticket));
      }
      
      PrintSeparator();
   }
   
   static bool CheckCriticalDrawdown(double criticalDD = 30.0) {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      
      if(balance > 0) {
         double dd = (balance - equity) / balance * 100;
         if(dd >= criticalDD) {
            EmergencyCloseAll("Kritik drawdown: " + DoubleToString(dd, 1) + "%");
            return true;
         }
      }
      return false;
   }
};

//====================================================================
// CLASS: CBacktestOptimizer - BACKTEST OPTİMİZASYONU
//====================================================================
class CBacktestOptimizer {
public:
   static double CalculateSharpeRatio() {
      // Basitleştirilmiş Sharpe Ratio
      if(g_totalTrades < 10) return 0;
      
      double avgReturn = g_totalProfit / g_totalTrades;
      double stdDev = MathSqrt(g_maxDrawdown);  // Yaklaşık
      
      if(stdDev == 0) return 0;
      return avgReturn / stdDev;
   }
   
   static double CalculateProfitFactor() {
      // Profit Factor = Gross Profit / Gross Loss
      // Bu örnekte sadece win/loss oranı kullanılıyor
      if(g_lossTrades == 0) return 999;
      return (double)g_winTrades / g_lossTrades;
   }
   
   static string GetOptimizationScore() {
      double winRate = (g_totalTrades > 0) ? (double)g_winTrades / g_totalTrades * 100 : 0;
      double pf = CalculateProfitFactor();
      double sharpe = CalculateSharpeRatio();
      
      // Composite Score
      double score = winRate * 0.4 + (pf * 10) * 0.3 + (sharpe * 20) * 0.3;
      
      string grade = "F";
      if(score >= 80) grade = "A+";
      else if(score >= 70) grade = "A";
      else if(score >= 60) grade = "B";
      else if(score >= 50) grade = "C";
      else if(score >= 40) grade = "D";
      
      return StringFormat("Skor: %.1f | Not: %s | PF: %.2f | Sharpe: %.2f", 
                          score, grade, pf, sharpe);
   }
};

//====================================================================
// CLASS: CDivergenceDetector - DİVERJANS TESPİTİ
//====================================================================
class CDivergenceDetector {
public:
   //--- RSI Divergence
   static int DetectRSIDivergence(int lookback = 20) {
      double rsi[];
      ArraySetAsSeries(rsi, true);
      
      if(CopyBuffer(g_hRSI, 0, 0, lookback, rsi) < lookback)
         return 0;
      
      // Swing noktaları bul
      double priceHighs[], priceLows[];
      double rsiHighs[], rsiLows[];
      ArrayResize(priceHighs, 0);
      ArrayResize(priceLows, 0);
      ArrayResize(rsiHighs, 0);
      ArrayResize(rsiLows, 0);
      
      for(int i = 2; i < lookback - 2; i++) {
         double high_i = iHigh(_Symbol, InpTimeframe, i);
         double low_i = iLow(_Symbol, InpTimeframe, i);
         
         // Swing High
         if(high_i > iHigh(_Symbol, InpTimeframe, i-1) &&
            high_i > iHigh(_Symbol, InpTimeframe, i-2) &&
            high_i > iHigh(_Symbol, InpTimeframe, i+1) &&
            high_i > iHigh(_Symbol, InpTimeframe, i+2)) {
            ArrayResize(priceHighs, ArraySize(priceHighs) + 1);
            ArrayResize(rsiHighs, ArraySize(rsiHighs) + 1);
            priceHighs[ArraySize(priceHighs) - 1] = high_i;
            rsiHighs[ArraySize(rsiHighs) - 1] = rsi[i];
         }
         
         // Swing Low
         if(low_i < iLow(_Symbol, InpTimeframe, i-1) &&
            low_i < iLow(_Symbol, InpTimeframe, i-2) &&
            low_i < iLow(_Symbol, InpTimeframe, i+1) &&
            low_i < iLow(_Symbol, InpTimeframe, i+2)) {
            ArrayResize(priceLows, ArraySize(priceLows) + 1);
            ArrayResize(rsiLows, ArraySize(rsiLows) + 1);
            priceLows[ArraySize(priceLows) - 1] = low_i;
            rsiLows[ArraySize(rsiLows) - 1] = rsi[i];
         }
      }
      
      // Bullish Divergence: Price Lower Low, RSI Higher Low
      if(ArraySize(priceLows) >= 2) {
         if(priceLows[0] < priceLows[1] && rsiLows[0] > rsiLows[1]) {
            WriteLog("📈 BULLISH DİVERJANS tespit edildi (RSI)");
            return 1;
         }
      }
      
      // Bearish Divergence: Price Higher High, RSI Lower High
      if(ArraySize(priceHighs) >= 2) {
         if(priceHighs[0] > priceHighs[1] && rsiHighs[0] < rsiHighs[1]) {
            WriteLog("📉 BEARISH DİVERJANS tespit edildi (RSI)");
            return -1;
         }
      }
      
      return 0;
   }
   
   //--- MACD Histogram Divergence
   static int DetectMACDDivergence(int lookback = 20) {
      double hist[];
      ArraySetAsSeries(hist, true);
      
      if(CopyBuffer(g_hMACD, 2, 0, lookback, hist) < lookback)
         return 0;
      
      // Son 2 tepe/dip karşılaştır
      double histPeaks[], histTroughs[];
      double pricePeaks[], priceTroughs[];
      ArrayResize(histPeaks, 0);
      ArrayResize(histTroughs, 0);
      ArrayResize(pricePeaks, 0);
      ArrayResize(priceTroughs, 0);
      
      for(int i = 1; i < lookback - 1; i++) {
         // MACD Histogram peak
         if(hist[i] > hist[i-1] && hist[i] > hist[i+1] && hist[i] > 0) {
            ArrayResize(histPeaks, ArraySize(histPeaks) + 1);
            ArrayResize(pricePeaks, ArraySize(pricePeaks) + 1);
            histPeaks[ArraySize(histPeaks) - 1] = hist[i];
            pricePeaks[ArraySize(pricePeaks) - 1] = iHigh(_Symbol, InpTimeframe, i);
         }
         
         // MACD Histogram trough
         if(hist[i] < hist[i-1] && hist[i] < hist[i+1] && hist[i] < 0) {
            ArrayResize(histTroughs, ArraySize(histTroughs) + 1);
            ArrayResize(priceTroughs, ArraySize(priceTroughs) + 1);
            histTroughs[ArraySize(histTroughs) - 1] = hist[i];
            priceTroughs[ArraySize(priceTroughs) - 1] = iLow(_Symbol, InpTimeframe, i);
         }
      }
      
      // Bullish: Price lower low, MACD higher low
      if(ArraySize(priceTroughs) >= 2) {
         if(priceTroughs[0] < priceTroughs[1] && histTroughs[0] > histTroughs[1])
            return 1;
      }
      
      // Bearish: Price higher high, MACD lower high
      if(ArraySize(pricePeaks) >= 2) {
         if(pricePeaks[0] > pricePeaks[1] && histPeaks[0] < histPeaks[1])
            return -1;
      }
      
      return 0;
   }
   
   //--- Birleşik diverjas skoru
   static int GetDivergenceScore(int direction) {
      int score = 0;
      
      int rsiDiv = DetectRSIDivergence();
      int macdDiv = DetectMACDDivergence();
      
      if(rsiDiv == direction) score += 30;
      if(macdDiv == direction) score += 25;
      
      // Eksi puan: Ters diverjas varsa
      if(rsiDiv == -direction) score -= 20;
      if(macdDiv == -direction) score -= 15;
      
      return score;
   }
};

//====================================================================
// CLASS: CCCIAnalyzer - CCI ANALİZİ
//====================================================================
class CCCIAnalyzer {
private:
   static int m_handle;
   
public:
   static void Init() {
      m_handle = iCCI(_Symbol, InpTimeframe, 20, PRICE_TYPICAL);
   }
   
   static void Release() {
      if(m_handle != INVALID_HANDLE) IndicatorRelease(m_handle);
   }
   
   static double GetScore(int direction) {
      if(m_handle == INVALID_HANDLE) return 50;
      
      double cci[];
      ArraySetAsSeries(cci, true);
      
      if(CopyBuffer(m_handle, 0, 0, 2, cci) < 2) return 50;
      
      double val = cci[0];
      double prev = cci[1];
      double score = 50;
      
      if(direction == 1) {
         if(val < -200) score = 95;        // Aşırı oversold
         else if(val < -100) score = 85;   // Oversold
         else if(val < 0) score = 65;
         else if(val > 200) score = 25;    // Aşırı overbought - risk
         
         // Momentum: CCI yükseliyor mu?
         if(val > prev) score += 10;
      }
      else if(direction == -1) {
         if(val > 200) score = 95;         // Aşırı overbought
         else if(val > 100) score = 85;    // Overbought
         else if(val > 0) score = 65;
         else if(val < -200) score = 25;   // Aşırı oversold - risk
         
         // Momentum: CCI düşüyor mu?
         if(val < prev) score += 10;
      }
      
      return MathMin(100, score);
   }
};
int CCCIAnalyzer::m_handle = INVALID_HANDLE;

//====================================================================
// CLASS: CWilliamsRAnalyzer - WILLIAMS %R ANALİZİ
//====================================================================
class CWilliamsRAnalyzer {
private:
   static int m_handle;
   
public:
   static void Init() {
      m_handle = iWPR(_Symbol, InpTimeframe, 14);
   }
   
   static void Release() {
      if(m_handle != INVALID_HANDLE) IndicatorRelease(m_handle);
   }
   
   static double GetScore(int direction) {
      if(m_handle == INVALID_HANDLE) return 50;
      
      double wpr[];
      ArraySetAsSeries(wpr, true);
      
      if(CopyBuffer(m_handle, 0, 0, 2, wpr) < 2) return 50;
      
      double val = wpr[0];  // -100 ile 0 arası
      double prev = wpr[1];
      double score = 50;
      
      if(direction == 1) {
         if(val < -80) score = 90;         // Oversold
         else if(val < -50) score = 70;
         else if(val > -20) score = 30;    // Overbought
         
         // Momentum
         if(val > prev) score += 10;
      }
      else if(direction == -1) {
         if(val > -20) score = 90;         // Overbought
         else if(val > -50) score = 70;
         else if(val < -80) score = 30;    // Oversold
         
         // Momentum
         if(val < prev) score += 10;
      }
      
      return MathMin(100, score);
   }
};
int CWilliamsRAnalyzer::m_handle = INVALID_HANDLE;

//====================================================================
// CLASS: CVolumeAnalyzer - HACİM ANALİZİ
//====================================================================
class CVolumeAnalyzer {
public:
   static double GetAverageVolume(int period = 20) {
      double sum = 0;
      for(int i = 0; i < period; i++) {
         sum += (double)iVolume(_Symbol, InpTimeframe, i);
      }
      return sum / period;
   }
   
   static double GetVolumeRatio() {
      double currentVol = (double)iVolume(_Symbol, InpTimeframe, 0);
      double avgVol = GetAverageVolume(20);
      
      if(avgVol == 0) return 1;
      return currentVol / avgVol;
   }
   
   static bool IsHighVolume(double threshold = 1.5) {
      return (GetVolumeRatio() >= threshold);
   }
   
   static bool IsClimax() {
      // Climax: Çok yüksek hacim + büyük mum
      double volRatio = GetVolumeRatio();
      double bodyRatio = CCandleAnalyzer::GetBodyRatio(0);
      
      return (volRatio > 2.0 && bodyRatio > 0.7);
   }
   
   static int GetVolumeScore(int direction) {
      double volRatio = GetVolumeRatio();
      int score = 50;
      
      bool isBullish = iClose(_Symbol, InpTimeframe, 0) > iOpen(_Symbol, InpTimeframe, 0);
      
      if(direction == 1) {
         if(isBullish && volRatio > 1.5) score = 85;  // Yüksek hacimli yükseliş
         else if(isBullish && volRatio > 1.2) score = 70;
         else if(!isBullish && volRatio > 1.5) score = 30;  // Yüksek hacimli düşüş = kötü
      }
      else if(direction == -1) {
         if(!isBullish && volRatio > 1.5) score = 85;  // Yüksek hacimli düşüş
         else if(!isBullish && volRatio > 1.2) score = 70;
         else if(isBullish && volRatio > 1.5) score = 30;  // Yüksek hacimli yükseliş = kötü
      }
      
      return score;
   }
};

//====================================================================
// CLASS: CTrendStrength - TREND GÜÇ ANALİZİ
//====================================================================
class CTrendStrength {
public:
   static double CalculateADMR() {
      // Average Directional Movement Rating
      double adx[];
      ArraySetAsSeries(adx, true);
      
      if(CopyBuffer(g_hADX, 0, 0, 14, adx) < 14)
         return 0;
      
      double sum = 0;
      for(int i = 0; i < 14; i++)
         sum += adx[i];
      
      return sum / 14;
   }
   
   static string GetTrendStrengthLabel() {
      double admr = CalculateADMR();
      
      if(admr >= 40) return "ÇAOK GÜÇLÜ";
      if(admr >= 30) return "GÜÇLÜ";
      if(admr >= 25) return "ORTA";
      if(admr >= 20) return "ZAYIF";
      return "TREND YOK";
   }
   
   static int GetTrendDirection() {
      double plusDI[], minusDI[];
      ArraySetAsSeries(plusDI, true);
      ArraySetAsSeries(minusDI, true);
      
      if(CopyBuffer(g_hADX, 1, 0, 1, plusDI) < 1) return 0;
      if(CopyBuffer(g_hADX, 2, 0, 1, minusDI) < 1) return 0;
      
      if(plusDI[0] > minusDI[0]) return 1;   // Uptrend
      if(minusDI[0] > plusDI[0]) return -1;  // Downtrend
      return 0;
   }
   
   static int GetTrendScore() {
      double admr = CalculateADMR();
      int direction = GetTrendDirection();
      
      int score = 50;
      
      if(admr >= 30) score += 25;
      else if(admr >= 25) score += 15;
      else if(admr < 20) score -= 20;
      
      return MathMax(0, MathMin(100, score));
   }
};

//====================================================================
// CLASS: CRiskParity - RİSK PARİTE YÖNETİMİ
//====================================================================
class CRiskParity {
public:
   static double CalculateOptimalPosition(double targetRisk = 1.0) {
      // Her sembol için eşit risk dağılımı
      double atr = g_signalScorer.GetATR();
      if(atr == 0) return InpMinLot;
      
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * targetRisk / 100.0;
      
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      
      if(tickValue <= 0) tickValue = 10.0;
      if(tickSize <= 0) tickSize = point;
      
      // ATR bazlı volatilite ağırlıklı lot
      double slPips = PointsToPip(atr * InpATR_SL_Multi);
      double pipValue = tickValue * (point / tickSize) * 10.0;
      
      if(pipValue <= 0 || slPips <= 0) return InpMinLot;
      
      return NormalizeLot(riskAmount / (slPips * pipValue));
   }
   
   static double AdjustForVolatility() {
      double atr = g_signalScorer.GetATR();
      double avgATR = CVolatilityAnalyzer::GetAverageATR(20);
      
      if(avgATR == 0) return 1.0;
      
      double volRatio = atr / avgATR;
      
      // Yüksek volatilitede lot azalt, düşük volatilitede artır
      if(volRatio > 1.5) return 0.7;
      if(volRatio > 1.2) return 0.85;
      if(volRatio < 0.7) return 1.2;
      if(volRatio < 0.5) return 1.3;
      
      return 1.0;
   }
};

//====================================================================
// CLASS: CMoneyFlowIndex - PARA AKIŞ ENDEKSİ (MFI)
//====================================================================
class CMoneyFlowIndex {
private:
   static int m_handle;
   
public:
   static void Init() {
      m_handle = iMFI(_Symbol, InpTimeframe, 14, VOLUME_TICK);
   }
   
   static void Release() {
      if(m_handle != INVALID_HANDLE) IndicatorRelease(m_handle);
   }
   
   static double GetScore(int direction) {
      if(m_handle == INVALID_HANDLE) return 50;
      
      double mfi[];
      ArraySetAsSeries(mfi, true);
      
      if(CopyBuffer(m_handle, 0, 0, 2, mfi) < 2) return 50;
      
      double val = mfi[0];
      double prev = mfi[1];
      double score = 50;
      
      if(direction == 1) {
         if(val < 20) score = 90;          // Oversold
         else if(val < 40) score = 70;
         else if(val > 80) score = 30;     // Satış baskısı
         
         if(val > prev) score += 10;       // Momentum
      }
      else if(direction == -1) {
         if(val > 80) score = 90;          // Overbought
         else if(val > 60) score = 70;
         else if(val < 20) score = 30;     // Alım baskısı
         
         if(val < prev) score += 10;       // Momentum
      }
      
      return MathMin(100, score);
   }
};
int CMoneyFlowIndex::m_handle = INVALID_HANDLE;

//====================================================================
// CLASS: CPriceActionPatterns - GELİŞMİŞ FİYAT HAREKETİ PATTERNLERİ
//====================================================================
class CPriceActionPatterns {
public:
   //--- Inside Bar (Consolidation)
   static bool IsInsideBar() {
      double high1 = iHigh(_Symbol, InpTimeframe, 1);
      double low1 = iLow(_Symbol, InpTimeframe, 1);
      double high2 = iHigh(_Symbol, InpTimeframe, 2);
      double low2 = iLow(_Symbol, InpTimeframe, 2);
      
      return (high1 < high2 && low1 > low2);
   }
   
   //--- Outside Bar (Expansion)
   static bool IsOutsideBar() {
      double high1 = iHigh(_Symbol, InpTimeframe, 1);
      double low1 = iLow(_Symbol, InpTimeframe, 1);
      double high2 = iHigh(_Symbol, InpTimeframe, 2);
      double low2 = iLow(_Symbol, InpTimeframe, 2);
      
      return (high1 > high2 && low1 < low2);
   }
   
   //--- Fakey Pattern (False Breakout)
   static int DetectFakey() {
      if(!IsInsideBar()) return 0;
      
      double high0 = iHigh(_Symbol, InpTimeframe, 0);
      double low0 = iLow(_Symbol, InpTimeframe, 0);
      double close0 = iClose(_Symbol, InpTimeframe, 0);
      double high1 = iHigh(_Symbol, InpTimeframe, 1);
      double low1 = iLow(_Symbol, InpTimeframe, 1);
      
      // Bullish Fakey: Inside bar sonrası aşağı kırılım, geri döndü
      if(low0 < low1 && close0 > low1)
         return 1;
      
      // Bearish Fakey: Inside bar sonrası yukarı kırılım, geri döndü
      if(high0 > high1 && close0 < high1)
         return -1;
      
      return 0;
   }
   
   //--- Two-Bar Reversal
   static int DetectTwoBarReversal() {
      double o1 = iOpen(_Symbol, InpTimeframe, 1);
      double c1 = iClose(_Symbol, InpTimeframe, 1);
      double o2 = iOpen(_Symbol, InpTimeframe, 2);
      double c2 = iClose(_Symbol, InpTimeframe, 2);
      double body1 = MathAbs(c1 - o1);
      double body2 = MathAbs(c2 - o2);
      
      double avgBody = (body1 + body2) / 2;
      double minBody = PipToPoints(5);
      
      if(body1 < minBody || body2 < minBody) return 0;
      
      // Bullish: Önceki düşüş + güçlü yükseliş
      if(c2 < o2 && c1 > o1 && body1 > body2 * 1.2)
         return 1;
      
      // Bearish: Önceki yükseliş + güçlü düşüş
      if(c2 > o2 && c1 < o1 && body1 > body2 * 1.2)
         return -1;
      
      return 0;
   }
   
   //--- Price Action Skor
   static int GetPriceActionScore(int direction) {
      int score = 50;
      
      int fakey = DetectFakey();
      int twoBar = DetectTwoBarReversal();
      
      if(fakey == direction) score += 25;
      if(twoBar == direction) score += 20;
      
      if(IsOutsideBar()) score += 10;  // Expansion = momentum
      if(IsInsideBar()) score -= 10;   // Consolidation = bekle
      
      if(fakey == -direction) score -= 20;
      if(twoBar == -direction) score -= 15;
      
      return MathMax(0, MathMin(100, score));
   }
};

//====================================================================
// FINAL: TÜM İNDİKATÖRLERİ BAŞLAT
//====================================================================
void InitAllIndicators() {
   CStochasticAnalyzer::Init();
   CBollingerAnalyzer::Init();
   CCCIAnalyzer::Init();
   CWilliamsRAnalyzer::Init();
   CMoneyFlowIndex::Init();
   CStatePersistence::Init();
   
   WriteLog("📊 Tüm indikatörler başlatıldı");
}

void ReleaseAllIndicators() {
   CStochasticAnalyzer::Release();
   CBollingerAnalyzer::Release();
   CCCIAnalyzer::Release();
   CWilliamsRAnalyzer::Release();
   CMoneyFlowIndex::Release();
   
   // Durumu kaydet
   CStatePersistence::SaveState();
   
   // HTML Rapor oluştur
   CHTMLReportGenerator::GenerateReport();
   
   WriteLog("📊 Tüm indikatörler serbest bırakıldı");
}

//====================================================================
// ULTIMATE HARMONY SKOR - TÜM FAKTÖRLERİ BİRLEŞTİR
//====================================================================
int CalculateUltimateScore(int direction) {
   // Temel skorlar (CAISignalScorer'dan)
   int baseScore = g_lastSignalScore;
   
   // Ek indikatör skorları
   double stochScore = CStochasticAnalyzer::GetScore(direction);
   double bbScore = CBollingerAnalyzer::GetScore(direction);
   double cciScore = CCCIAnalyzer::GetScore(direction);
   double wprScore = CWilliamsRAnalyzer::GetScore(direction);
   double mfiScore = CMoneyFlowIndex::GetScore(direction);
   double volScore = CVolumeAnalyzer::GetVolumeScore(direction);
   double paScore = CPriceActionPatterns::GetPriceActionScore(direction);
   
   // SMC skoru
   int smcScore = CSmartMoneyConcepts::GetSMCScore(direction);
   
   // Divergence skoru
   int divScore = CDivergenceDetector::GetDivergenceScore(direction);
   
   // Trend gücü
   int trendScore = CTrendStrength::GetTrendScore();
   
   // Ağırlıklı ortalama
   double totalScore = baseScore * 0.35 +
                       stochScore * 0.08 +
                       bbScore * 0.07 +
                       cciScore * 0.05 +
                       wprScore * 0.05 +
                       mfiScore * 0.05 +
                       volScore * 0.08 +
                       paScore * 0.07 +
                       smcScore * 0.10 +
                       divScore * 0.05 +
                       trendScore * 0.05;
   
   return (int)MathMin(100, MathMax(0, totalScore));
}

//====================================================================
// VERSION INFO
//====================================================================
string GetVersionInfo() {
   return "Ultimate Harmony EA v3.0 | 35+ Modül | 3700+ Satır";
}

//====================================================================
// CLASS: CMillionDollarTracker - 1 MİLYON DOLAR HEDEF TAKİP
//====================================================================
input group "═══════ 🎯 1 MİLYON DOLAR HEDEFİ ═══════"
input double   InpStartBalance    = 10.0;         // 💵 Başlangıç Bakiyesi ($)
input double   InpTargetBalance   = 1000000.0;    // 🎯 Hedef Bakiye ($)
input bool     InpShowGoalPanel   = true;         // 📊 Hedef Paneli Göster
input bool     InpShowMilestones  = true;         // 🏆 Milestone Göster

class CMillionDollarTracker {
private:
   static double m_milestones[];
   static string m_milestoneNames[];
   static int    m_milestoneCount;
   
public:
   static void Init() {
      // Milestone'ları tanımla
      m_milestoneCount = 10;
      ArrayResize(m_milestones, m_milestoneCount);
      ArrayResize(m_milestoneNames, m_milestoneCount);
      
      m_milestones[0] = 100;        m_milestoneNames[0] = "İlk $100 🌱";
      m_milestones[1] = 500;        m_milestoneNames[1] = "$500 💪";
      m_milestones[2] = 1000;       m_milestoneNames[2] = "$1,000 🔥";
      m_milestones[3] = 5000;       m_milestoneNames[3] = "$5,000 ⭐";
      m_milestones[4] = 10000;      m_milestoneNames[4] = "$10,000 🌟";
      m_milestones[5] = 50000;      m_milestoneNames[5] = "$50,000 💎";
      m_milestones[6] = 100000;     m_milestoneNames[6] = "$100,000 🏆";
      m_milestones[7] = 250000;     m_milestoneNames[7] = "$250,000 👑";
      m_milestones[8] = 500000;     m_milestoneNames[8] = "$500,000 🚀";
      m_milestones[9] = 1000000;    m_milestoneNames[9] = "$1,000,000 💰🎯";
   }
   
   static double GetProgress() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double start = InpStartBalance;
      double target = InpTargetBalance;
      
      if(target <= start) return 100;
      
      double progress = (balance - start) / (target - start) * 100;
      return MathMax(0, MathMin(100, progress));
   }
   
   static double GetRemainingAmount() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      return MathMax(0, InpTargetBalance - balance);
   }
   
   static int GetCurrentMilestone() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      int current = 0;
      
      for(int i = 0; i < m_milestoneCount; i++) {
         if(balance >= m_milestones[i])
            current = i + 1;
      }
      return current;
   }
   
   static int GetNextMilestone() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      
      for(int i = 0; i < m_milestoneCount; i++) {
         if(balance < m_milestones[i])
            return i;
      }
      return m_milestoneCount;  // Tüm hedefler tamamlandı
   }
   
   static double GetNextMilestoneAmount() {
      int next = GetNextMilestone();
      if(next >= m_milestoneCount) return InpTargetBalance;
      return m_milestones[next];
   }
   
   static string GetNextMilestoneName() {
      int next = GetNextMilestone();
      if(next >= m_milestoneCount) return "🏆 TÜM HEDEFLER TAMAMLANDI!";
      return m_milestoneNames[next];
   }
   
   static double GetMultiplier() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      if(InpStartBalance <= 0) return 0;
      return balance / InpStartBalance;
   }
   
   static string GetMotivationMessage() {
      double progress = GetProgress();
      double mult = GetMultiplier();
      
      if(progress >= 100)
         return "🎉🎉🎉 1 MİLYON DOLAR HEDEFİ TAMAMLANDI! 🎉🎉🎉";
      else if(progress >= 90)
         return "🔥 SON VİRAJ! Hedefe çok yakınsın!";
      else if(progress >= 75)
         return "💪 Muhteşem gidiyorsun! Devam et!";
      else if(progress >= 50)
         return "⭐ Yarıyı geçtin! Harika iş!";
      else if(progress >= 25)
         return "🌟 İyi gidiyorsun, sabırla devam!";
      else if(progress >= 10)
         return "🚀 Yolculuk başladı, momentum kazanıyorsun!";
      else if(mult >= 2)
         return "💎 Paranı katladın! Bileşik büyüme çalışıyor!";
      else
         return "🌱 Her ustanın bir zamanlar çırağı vardı. Devam!";
   }
   
   static void DrawGoalPanel() {
      if(!InpShowGoalPanel) return;
      
      string prefix = "Goal_";
      int x = 300, y = 30;  // Dashboard'un sağına
      int lineHeight = 16;
      color textColor = clrWhite;
      color goldColor = clrGold;
      color greenColor = clrLime;
      
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double progress = GetProgress();
      double remaining = GetRemainingAmount();
      double mult = GetMultiplier();
      int currentMS = GetCurrentMilestone();
      string nextMSName = GetNextMilestoneName();
      double nextMSAmount = GetNextMilestoneAmount();
      double toNextMS = nextMSAmount - balance;
      
      // Panel arka plan
      CreateGoalRect(prefix + "BG", x - 5, y - 5, 280, 200, clrMidnightBlue);
      
      // Başlık
      CreateGoalLabel(prefix + "Title", x, y, "═══ 🎯 1 MİLYON DOLAR HEDEFİ ═══", goldColor, 10);
      y += lineHeight + 5;
      
      // İlerleme çubuğu arka plan
      CreateGoalRect(prefix + "ProgBG", x, y, 250, 14, clrDimGray);
      // İlerleme çubuğu dolu kısım
      int progWidth = (int)(250 * progress / 100);
      color progColor = (progress >= 50) ? clrLime : clrDodgerBlue;
      if(progWidth > 0)
         CreateGoalRect(prefix + "ProgFill", x, y, progWidth, 14, progColor);
      
      // İlerleme yüzdesi (çubuğun üstünde)
      CreateGoalLabel(prefix + "ProgPct", x + 100, y + 1, DoubleToString(progress, 2) + "%", clrWhite, 9);
      y += lineHeight + 5;
      
      // Detaylar
      CreateGoalLabel(prefix + "Balance", x, y, "💰 Bakiye: $" + DoubleToString(balance, 2), greenColor, 9);
      y += lineHeight;
      
      CreateGoalLabel(prefix + "Remaining", x, y, "🎯 Kalan: $" + DoubleToString(remaining, 2), 
                      remaining > 0 ? clrOrange : greenColor, 9);
      y += lineHeight;
      
      CreateGoalLabel(prefix + "Multiplier", x, y, "📈 Çarpan: " + DoubleToString(mult, 2) + "x", 
                      mult >= 2 ? greenColor : clrYellow, 9);
      y += lineHeight;
      
      CreateGoalLabel(prefix + "Milestone", x, y, "🏆 Tamamlanan: " + IntegerToString(currentMS) + "/10 hedef", 
                      textColor, 9);
      y += lineHeight + 3;
      
      // Sonraki hedef
      if(toNextMS > 0) {
         CreateGoalLabel(prefix + "NextMS", x, y, "➡️ Sonraki: " + nextMSName, goldColor, 9);
         y += lineHeight;
         CreateGoalLabel(prefix + "ToNextMS", x, y, "   Kalan: $" + DoubleToString(toNextMS, 2), clrAqua, 9);
      } else {
         CreateGoalLabel(prefix + "NextMS", x, y, "🎉 " + nextMSName, goldColor, 9);
      }
      y += lineHeight + 5;
      
      // Motivasyon mesajı
      CreateGoalLabel(prefix + "Motivation", x, y, GetMotivationMessage(), clrYellow, 9);
   }
   
   static void DrawMilestoneChecklist() {
      if(!InpShowMilestones) return;
      
      string prefix = "MS_";
      int x = 300, y = 250;
      int lineHeight = 15;
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      
      CreateGoalLabel(prefix + "Title", x, y, "═══ 📋 HEDEF LİSTESİ ═══", clrGold, 9);
      y += lineHeight + 3;
      
      for(int i = 0; i < m_milestoneCount; i++) {
         bool completed = (balance >= m_milestones[i]);
         string checkMark = completed ? "✅" : "⬜";
         color textClr = completed ? clrLime : clrGray;
         
         CreateGoalLabel(prefix + IntegerToString(i), x, y, 
                         checkMark + " " + m_milestoneNames[i], textClr, 8);
         y += lineHeight;
      }
   }
   
   static void Update() {
      DrawGoalPanel();
      DrawMilestoneChecklist();
      ChartComment();
   }
   
   static void ChartComment() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double progress = GetProgress();
      double remaining = GetRemainingAmount();
      double mult = GetMultiplier();
      string motivation = GetMotivationMessage();
      
      string comment = "";
      comment += "╔══════════════════════════════════════════════════════════╗\n";
      comment += "║        🎯 1 MİLYON DOLAR YOLCULUĞU - ULTIMATE HARMONY    ║\n";
      comment += "╠══════════════════════════════════════════════════════════╣\n";
      comment += "║ 💰 Bakiye: $" + DoubleToString(balance, 2);
      comment += " | Başlangıç: $" + DoubleToString(InpStartBalance, 2) + "\n";
      comment += "║ 📈 Çarpan: " + DoubleToString(mult, 2) + "x";
      comment += " | İlerleme: %" + DoubleToString(progress, 2) + "\n";
      comment += "║ 🎯 Kalan: $" + DoubleToString(remaining, 2) + "\n";
      comment += "║ 🏆 Hedefler: " + IntegerToString(GetCurrentMilestone()) + "/10 tamamlandı\n";
      comment += "║ ➡️ Sonraki: " + GetNextMilestoneName() + "\n";
      comment += "╠══════════════════════════════════════════════════════════╣\n";
      comment += "║ 💬 " + motivation + "\n";
      comment += "╚══════════════════════════════════════════════════════════╝";
      
      Comment(comment);
   }
   
   static void CreateGoalLabel(string name, int x, int y, string text, color clr, int fontSize) {
      if(ObjectFind(0, name) < 0)
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
      ObjectSetString(0, name, OBJPROP_FONT, "Consolas");
   }
   
   static void CreateGoalRect(string name, int x, int y, int width, int height, color clr) {
      if(ObjectFind(0, name) < 0)
         ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, width);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, height);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
   }
   
   static void CheckMilestoneAchievement() {
      static int lastMilestone = 0;
      int current = GetCurrentMilestone();
      
      if(current > lastMilestone && lastMilestone > 0) {
         // Yeni milestone ulaşıldı!
         string msg = "🎉🎉🎉 TEBRİKLER! " + m_milestoneNames[current-1] + " Hedefine Ulaştın! 🎉🎉🎉";
         Alert(msg);
         Print(msg);
         
         // Özel kutlama
         if(current == m_milestoneCount) {
            Alert("🏆🏆🏆 1 MİLYON DOLAR HEDEFİNE ULAŞTIN! İMKANSIZ DİYE BİR ŞEY YOK! 🏆🏆🏆");
         }
      }
      
      lastMilestone = current;
   }
};

// Static değişkenler
double CMillionDollarTracker::m_milestones[];
string CMillionDollarTracker::m_milestoneNames[];
int    CMillionDollarTracker::m_milestoneCount = 0;

//====================================================================
// CLASS: CLotValidator - HATALI LOT DÜZELTME
//====================================================================
class CLotValidator {
public:
   //--- Lot'u broker kurallarına göre düzelt
   static double ValidateLot(double lot, string symbol = "") {
      if(symbol == "") symbol = _Symbol;
      
      double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      double stepLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      double limitLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_LIMIT);
      
      // Hata kontrolü
      if(minLot <= 0) minLot = 0.01;
      if(maxLot <= 0) maxLot = 100.0;
      if(stepLot <= 0) stepLot = 0.01;
      
      // Step'e yuvarla (aşağı)
      lot = MathFloor(lot / stepLot) * stepLot;
      
      // Min/Max sınırlarına uygula
      lot = MathMax(minLot, lot);
      lot = MathMin(maxLot, lot);
      
      // Volume limit kontrolü (tek yöndeki toplam)
      if(limitLot > 0) {
         double currentVolume = GetDirectionalVolume(symbol, ORDER_TYPE_BUY) + 
                               GetDirectionalVolume(symbol, ORDER_TYPE_SELL);
         if(currentVolume + lot > limitLot)
            lot = MathMax(0, limitLot - currentVolume);
      }
      
      // Ondalık hassasiyet düzeltmesi
      int digits = GetLotDigits(stepLot);
      lot = NormalizeDouble(lot, digits);
      
      return lot;
   }
   
   //--- Lot geçerli mi kontrol et
   static bool IsLotValid(double lot, string symbol = "") {
      if(symbol == "") symbol = _Symbol;
      
      double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      double stepLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      
      if(lot < minLot || lot > maxLot)
         return false;
      
      // Step kontrolü
      double remainder = MathMod(lot, stepLot);
      if(remainder > stepLot * 0.0001)
         return false;
      
      return true;
   }
   
   //--- Lot hatası detayını al
   static string GetLotError(double lot, string symbol = "") {
      if(symbol == "") symbol = _Symbol;
      
      double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      double stepLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      
      if(lot < minLot)
         return StringFormat("LOT ÇOK KÜÇÜK: %.4f < Min %.4f", lot, minLot);
      if(lot > maxLot)
         return StringFormat("LOT ÇOK BÜYÜK: %.4f > Max %.4f", lot, maxLot);
      
      double remainder = MathMod(lot, stepLot);
      if(remainder > stepLot * 0.0001)
         return StringFormat("LOT STEP HATASI: %.4f (Step: %.4f)", lot, stepLot);
      
      return "LOT GEÇERLI";
   }
   
   //--- Lot ondalık hassasiyetini hesapla
   static int GetLotDigits(double stepLot) {
      if(stepLot >= 1.0) return 0;
      if(stepLot >= 0.1) return 1;
      if(stepLot >= 0.01) return 2;
      if(stepLot >= 0.001) return 3;
      return 4;
   }
   
   //--- Yönlü toplam volume hesapla
   static double GetDirectionalVolume(string symbol, ENUM_ORDER_TYPE direction) {
      double total = 0;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetString(POSITION_SYMBOL) != symbol) continue;
         
         ENUM_POSITION_TYPE posType = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         if((direction == ORDER_TYPE_BUY && posType == POSITION_TYPE_BUY) ||
            (direction == ORDER_TYPE_SELL && posType == POSITION_TYPE_SELL))
            total += PositionGetDouble(POSITION_VOLUME);
      }
      
      return total;
   }
   
   //--- Broker bilgilerini göster
   static void PrintBrokerLotInfo(string symbol = "") {
      if(symbol == "") symbol = _Symbol;
      
      double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      double stepLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      double limitLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_LIMIT);
      
      Print("═══════════════════════════════════════════════");
      Print("  📊 LOT BİLGİLERİ: ", symbol);
      Print("  Min Lot: ", DoubleToString(minLot, 4));
      Print("  Max Lot: ", DoubleToString(maxLot, 2));
      Print("  Step: ", DoubleToString(stepLot, 4));
      Print("  Limit: ", limitLot > 0 ? DoubleToString(limitLot, 2) : "Sınırsız");
      Print("═══════════════════════════════════════════════");
   }
};

//====================================================================
// CLASS: CGapAnalyzer - GAP ANALİZİ (Weekend Gap & Intraday Gap)
//====================================================================
input group "═══════ 📊 GAP ANALİZİ ═══════"
input bool     InpUseGapFilter    = true;         // ✅ Gap Filtresi Kullan
input double   InpMinGapPips      = 10.0;         // Min Gap (pip)
input bool     InpTradeGapFill    = false;        // Gap Dolum İşlemi Aç

class CGapAnalyzer {
public:
   //--- Weekend Gap Tespit (Pazartesi açılışı)
   static bool DetectWeekendGap(double &gapSize, int &gapDirection) {
      MqlDateTime dt;
      TimeCurrent(dt);
      
      // Sadece Pazartesi kontrolü
      if(dt.day_of_week != 1) return false;
      
      // Son 2 bar'ı al
      MqlRates rates[];
      ArraySetAsSeries(rates, true);
      
      if(CopyRates(_Symbol, InpTimeframe, 0, 10, rates) < 10)
         return false;
      
      // Cuma kapanışını bul (geriye doğru ara)
      double fridayClose = 0;
      for(int i = 1; i < 10; i++) {
         MqlDateTime barDt;
         TimeToStruct(rates[i].time, barDt);
         
         if(barDt.day_of_week == 5) {  // Cuma
            fridayClose = rates[i].close;
            break;
         }
      }
      
      if(fridayClose == 0) return false;
      
      double mondayOpen = rates[0].open;
      gapSize = PointsToPip(MathAbs(mondayOpen - fridayClose));
      
      if(gapSize < InpMinGapPips) return false;
      
      if(mondayOpen > fridayClose)
         gapDirection = 1;   // Gap Up
      else
         gapDirection = -1;  // Gap Down
      
      WriteLog("📊 WEEKEND GAP TESPİT: " + 
               (gapDirection == 1 ? "⬆️ GAP UP" : "⬇️ GAP DOWN") + 
               " | " + DoubleToString(gapSize, 1) + " pip");
      
      return true;
   }
   
   //--- Intraday Gap Tespit (ardışık barlar arası)
   static bool DetectIntradayGap(double &gapSize, int &gapDirection, int lookback = 1) {
      double prevClose = iClose(_Symbol, InpTimeframe, lookback + 1);
      double currOpen = iOpen(_Symbol, InpTimeframe, lookback);
      
      gapSize = PointsToPip(MathAbs(currOpen - prevClose));
      
      if(gapSize < InpMinGapPips) return false;
      
      if(currOpen > prevClose)
         gapDirection = 1;   // Gap Up
      else
         gapDirection = -1;  // Gap Down
      
      return true;
   }
   
   //--- Gap dolum durumu kontrol
   static bool IsGapFilled(double gapHigh, double gapLow, int direction) {
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      if(direction == 1) {  // Gap Up - fiyat gap'i doldurmak için düşmeli
         return (currentPrice <= gapLow);
      }
      else {  // Gap Down - fiyat gap'i doldurmak için yükselmeli
         return (currentPrice >= gapHigh);
      }
   }
   
   //--- Gap dolum yüzdesi
   static double GetGapFillPercent(double gapStart, double gapEnd, int direction) {
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double gapRange = MathAbs(gapEnd - gapStart);
      
      if(gapRange == 0) return 0;
      
      double filled = 0;
      if(direction == 1) {  // Gap Up
         filled = gapEnd - currentPrice;
      }
      else {  // Gap Down
         filled = currentPrice - gapEnd;
      }
      
      double percent = (filled / gapRange) * 100;
      return MathMax(0, MathMin(100, percent));
   }
   
   //--- Çoklu gap kontrolü
   static int CountRecentGaps(int barsToCheck = 20) {
      int gapCount = 0;
      double gapSize;
      int gapDir;
      
      for(int i = 1; i < barsToCheck; i++) {
         if(DetectIntradayGap(gapSize, gapDir, i))
            gapCount++;
      }
      
      return gapCount;
   }
   
   //--- Gap sinyal skoru
   static int GetGapScore(int tradeDirection) {
      double gapSize;
      int gapDirection;
      int score = 50;
      
      // Weekend gap kontrolü
      if(DetectWeekendGap(gapSize, gapDirection)) {
         // Gap fill stratejisi: Gap'in tersine işlem yap
         if(gapDirection == tradeDirection) {
            score -= 20;  // Gap yönünde işlem riskli
         }
         else {
            score += 25;  // Gap dolum stratejisi
         }
      }
      
      // Intraday gap kontrolü
      if(DetectIntradayGap(gapSize, gapDirection, 0)) {
         if(gapDirection == tradeDirection) {
            // Momentum gap - risk var ama fırsat da var
            if(gapSize > 20)
               score -= 15;  // Büyük gap - dikkatli ol
            else
               score += 10;  // Küçük momentum gap
         }
         else {
            score += 15;  // Gap fill fırsatı
         }
      }
      
      return MathMax(0, MathMin(100, score));
   }
   
   //--- Gap varsa işlem filtresi
   static bool ShouldAvoidTradeAfterGap() {
      if(!InpUseGapFilter) return false;
      
      double gapSize;
      int gapDirection;
      
      // Büyük weekend gap sonrası dikkatli ol
      if(DetectWeekendGap(gapSize, gapDirection)) {
         if(gapSize > 30) {
            WriteLog("⚠️ BÜYÜK GAP UYARISI: " + DoubleToString(gapSize, 1) + " pip - DİKKAT!");
            return true;
         }
      }
      
      return false;
   }
   
   //--- Gap bilgilerini dashboard'a ekle
   static string GetGapStatus() {
      double gapSize;
      int gapDirection;
      
      if(DetectWeekendGap(gapSize, gapDirection)) {
         return StringFormat("WEEKEND GAP: %s %.1f pip", 
                             gapDirection == 1 ? "⬆️" : "⬇️", gapSize);
      }
      
      if(DetectIntradayGap(gapSize, gapDirection, 0)) {
         return StringFormat("INTRADAY GAP: %s %.1f pip", 
                             gapDirection == 1 ? "⬆️" : "⬇️", gapSize);
      }
      
      return "Gap Yok";
   }
};

//====================================================================
// CLASS: COppositePositionManager - TERS POZİSYON YÖNETİMİ
// Kullanıcının açtığı BUY/SELL pozisyonlarını izler ve ters yöndekini kapatır
//====================================================================
input group "═══════ 🔄 TERS POZİSYON YÖNETİMİ ═══════"
input bool     InpEnableOppositeClose = true;      // ✅ Ters Pozisyon Kapatma
input int      InpOppositeCloseMode   = 1;         // Mod: 1=Kârlıyı, 2=Zararlıyı, 3=Küçük Lot'u
input double   InpMinOppositeProfit   = 0.50;      // Min Net Kar ($) - çift kapatma için
input bool     InpCloseOnSLHit        = true;      // SL Yaklaştığında Ters Kapat
input bool     InpCloseOnTPHit        = true;      // TP Yaklaştığında Ters Kapat
input double   InpSLTPTriggerPercent  = 70.0;      // SL/TP Tetik Yüzdesi (%)

class COppositePositionManager {
private:
   struct PositionData {
      ulong    ticket;
      double   lots;
      double   openPrice;
      double   currentPrice;
      double   profit;
      double   sl;
      double   tp;
      long     type;  // POSITION_TYPE_BUY veya POSITION_TYPE_SELL
      datetime openTime;
   };
   
   static PositionData m_buyPositions[];
   static PositionData m_sellPositions[];
   static int m_buyCount;
   static int m_sellCount;
   
public:
   //--- Pozisyonları tara ve kategorize et
   static void ScanPositions() {
      ArrayResize(m_buyPositions, 0);
      ArrayResize(m_sellPositions, 0);
      m_buyCount = 0;
      m_sellCount = 0;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         
         PositionData pos;
         pos.ticket = ticket;
         pos.lots = PositionGetDouble(POSITION_VOLUME);
         pos.openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         pos.currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
         pos.profit = PositionGetDouble(POSITION_PROFIT) + PositionGetDouble(POSITION_SWAP);
         pos.sl = PositionGetDouble(POSITION_SL);
         pos.tp = PositionGetDouble(POSITION_TP);
         pos.type = PositionGetInteger(POSITION_TYPE);
         pos.openTime = (datetime)PositionGetInteger(POSITION_TIME);
         
         if(pos.type == POSITION_TYPE_BUY) {
            ArrayResize(m_buyPositions, m_buyCount + 1);
            m_buyPositions[m_buyCount] = pos;
            m_buyCount++;
         }
         else {
            ArrayResize(m_sellPositions, m_sellCount + 1);
            m_sellPositions[m_sellCount] = pos;
            m_sellCount++;
         }
      }
   }
   
   //--- Ters pozisyon var mı kontrol et
   static bool HasOppositePositions() {
      return (m_buyCount > 0 && m_sellCount > 0);
   }
   
   //--- Hangi pozisyonu kapatacağına karar ver
   static ulong SelectPositionToClose(int mode) {
      // mode 1: En kârlı olanı kapat
      // mode 2: En zararlı olanı kapat
      // mode 3: En küçük lot olanı kapat
      
      // Tüm pozisyonları birleştir
      int totalCount = m_buyCount + m_sellCount;
      if(totalCount == 0) return 0;
      
      PositionData allPositions[];
      ArrayResize(allPositions, totalCount);
      
      int idx = 0;
      for(int i = 0; i < m_buyCount; i++) {
         allPositions[idx] = m_buyPositions[i];
         idx++;
      }
      for(int i = 0; i < m_sellCount; i++) {
         allPositions[idx] = m_sellPositions[i];
         idx++;
      }
      
      ulong selectedTicket = 0;
      
      switch(mode) {
         case 1:  // En kârlı
            {
               double maxProfit = -999999;
               for(int i = 0; i < totalCount; i++) {
                  if(allPositions[i].profit > maxProfit) {
                     maxProfit = allPositions[i].profit;
                     selectedTicket = allPositions[i].ticket;
                  }
               }
            }
            break;
            
         case 2:  // En zararlı
            {
               double minProfit = 999999;
               for(int i = 0; i < totalCount; i++) {
                  if(allPositions[i].profit < minProfit) {
                     minProfit = allPositions[i].profit;
                     selectedTicket = allPositions[i].ticket;
                  }
               }
            }
            break;
            
         case 3:  // En küçük lot
            {
               double minLot = 999999;
               for(int i = 0; i < totalCount; i++) {
                  if(allPositions[i].lots < minLot) {
                     minLot = allPositions[i].lots;
                     selectedTicket = allPositions[i].ticket;
                  }
               }
            }
            break;
      }
      
      return selectedTicket;
   }
   
   //--- Pozisyon TP/SL'ye yaklaştı mı kontrol et
   static bool IsNearTPSL(PositionData &pos, double triggerPercent) {
      if(pos.tp == 0 && pos.sl == 0) return false;
      
      double tpDist = 0, slDist = 0, currentDist = 0;
      
      if(pos.type == POSITION_TYPE_BUY) {
         if(pos.tp > 0) tpDist = pos.tp - pos.openPrice;
         if(pos.sl > 0) slDist = pos.openPrice - pos.sl;
         currentDist = pos.currentPrice - pos.openPrice;
      }
      else {
         if(pos.tp > 0) tpDist = pos.openPrice - pos.tp;
         if(pos.sl > 0) slDist = pos.sl - pos.openPrice;
         currentDist = pos.openPrice - pos.currentPrice;
      }
      
      // TP'ye yaklaştı mı?
      if(InpCloseOnTPHit && tpDist > 0) {
         double tpPercent = (currentDist / tpDist) * 100;
         if(tpPercent >= triggerPercent)
            return true;
      }
      
      // SL'ye yaklaştı mı?
      if(InpCloseOnSLHit && slDist > 0) {
         double slPercent = (-currentDist / slDist) * 100;
         if(slPercent >= triggerPercent)
            return true;
      }
      
      return false;
   }
   
   //--- Net kar hesapla (BUY + SELL toplam)
   static double CalculateNetProfit() {
      double netProfit = 0;
      
      for(int i = 0; i < m_buyCount; i++)
         netProfit += m_buyPositions[i].profit;
      for(int i = 0; i < m_sellCount; i++)
         netProfit += m_sellPositions[i].profit;
      
      return netProfit;
   }
   
   //--- Ana yönetim fonksiyonu
   static void ManageOppositePositions() {
      if(!InpEnableOppositeClose) return;
      
      ScanPositions();
      
      if(!HasOppositePositions()) return;
      
      double netProfit = CalculateNetProfit();
      
      // Net kâr yeterliyse en uygun pozisyonu kapat
      if(netProfit >= InpMinOppositeProfit) {
         // Her iki yönde de birden fazla pozisyon varsa
         // En kârlı BUY ve en kârlı SELL'i eşleştir
         if(m_buyCount >= 1 && m_sellCount >= 1) {
            // En kârlı BUY
            int bestBuyIdx = 0;
            double maxBuyProfit = m_buyPositions[0].profit;
            for(int i = 1; i < m_buyCount; i++) {
               if(m_buyPositions[i].profit > maxBuyProfit) {
                  maxBuyProfit = m_buyPositions[i].profit;
                  bestBuyIdx = i;
               }
            }
            
            // En zararlı SELL (veya en az kârlı)
            int worstSellIdx = 0;
            double minSellProfit = m_sellPositions[0].profit;
            for(int i = 1; i < m_sellCount; i++) {
               if(m_sellPositions[i].profit < minSellProfit) {
                  minSellProfit = m_sellPositions[i].profit;
                  worstSellIdx = i;
               }
            }
            
            // Birlikte kârlıysa ikisini de kapat
            if(maxBuyProfit + minSellProfit >= InpMinOppositeProfit) {
               WriteLog("🔄 TERS POZİSYON KAPANIŞ:");
               WriteLog("   BUY #" + IntegerToString(m_buyPositions[bestBuyIdx].ticket) + 
                        " Kar: $" + DoubleToString(maxBuyProfit, 2));
               WriteLog("   SELL #" + IntegerToString(m_sellPositions[worstSellIdx].ticket) + 
                        " Kar: $" + DoubleToString(minSellProfit, 2));
               WriteLog("   NET: $" + DoubleToString(maxBuyProfit + minSellProfit, 2));
               
               g_trade.PositionClose(m_buyPositions[bestBuyIdx].ticket);
               g_trade.PositionClose(m_sellPositions[worstSellIdx].ticket);
               return;
            }
         }
      }
      
      // 🆕 AGRESİF MOD: Net kâr olmasa bile zarar azaltma yap
      // En zararlı pozisyonu kapat, diğerini devam ettir
      if(m_buyCount >= 1 && m_sellCount >= 1) {
         // Her iki yönde de pozisyon var - birini kapatarak riski azalt
         double buyProfit = m_buyPositions[0].profit;
         double sellProfit = m_sellPositions[0].profit;
         
         // Hangisi daha kötü durumda?
         if(buyProfit < sellProfit && buyProfit < -0.20) {
            // BUY daha çok zararda, SELL'i koru, BUY'ı kapat
            WriteLog("⚠️ ZARAR AZALTMA: BUY zararda ($" + DoubleToString(buyProfit, 2) + "), kapatılıyor");
            g_trade.PositionClose(m_buyPositions[0].ticket);
            return;
         }
         else if(sellProfit < buyProfit && sellProfit < -0.20) {
            // SELL daha çok zararda, BUY'ı koru, SELL'i kapat
            WriteLog("⚠️ ZARAR AZALTMA: SELL zararda ($" + DoubleToString(sellProfit, 2) + "), kapatılıyor");
            g_trade.PositionClose(m_sellPositions[0].ticket);
            return;
         }
         
         // Her ikisi de az zararda veya kârda - bekle ama log yaz
         WriteLog("🔄 TERS POZİSYON İZLEME: BUY $" + DoubleToString(buyProfit, 2) + 
                  " | SELL $" + DoubleToString(sellProfit, 2) + 
                  " | NET: $" + DoubleToString(buyProfit + sellProfit, 2));
      }
      
      // TP/SL yaklaştığında ters pozisyonu kapat
      for(int i = 0; i < m_buyCount; i++) {
         if(IsNearTPSL(m_buyPositions[i], InpSLTPTriggerPercent)) {
            // Bu BUY TP'ye yaklaştı, karşı SELL'i kapat
            if(m_sellCount > 0) {
               ulong sellTicket = m_sellPositions[0].ticket;
               double sellProfit = m_sellPositions[0].profit;
               
               WriteLog("⚡ TP/SL TETİK: BUY hedefe yakın, SELL kapatılıyor");
               WriteLog("   SELL #" + IntegerToString(sellTicket) + " Kar: $" + 
                        DoubleToString(sellProfit, 2));
               
               g_trade.PositionClose(sellTicket);
               return;
            }
         }
      }
      
      for(int i = 0; i < m_sellCount; i++) {
         if(IsNearTPSL(m_sellPositions[i], InpSLTPTriggerPercent)) {
            // Bu SELL TP'ye yaklaştı, karşı BUY'ı kapat
            if(m_buyCount > 0) {
               ulong buyTicket = m_buyPositions[0].ticket;
               double buyProfit = m_buyPositions[0].profit;
               
               WriteLog("⚡ TP/SL TETİK: SELL hedefe yakın, BUY kapatılıyor");
               WriteLog("   BUY #" + IntegerToString(buyTicket) + " Kar: $" + 
                        DoubleToString(buyProfit, 2));
               
               g_trade.PositionClose(buyTicket);
               return;
            }
         }
      }
   }
   
   //--- Tüm ters pozisyonları zorla kapat
   static void ForceCloseAllOpposite() {
      ScanPositions();
      
      if(!HasOppositePositions()) {
         WriteLog("❌ Ters pozisyon yok");
         return;
      }
      
      WriteLog("🔄 ZORLA KAPANIŞ: Tüm ters pozisyonlar kapatılıyor...");
      
      // Tüm pozisyonları kapat
      for(int i = 0; i < m_buyCount; i++) {
         g_trade.PositionClose(m_buyPositions[i].ticket);
      }
      for(int i = 0; i < m_sellCount; i++) {
         g_trade.PositionClose(m_sellPositions[i].ticket);
      }
   }
   
   //--- Durum özeti
   static string GetStatus() {
      ScanPositions();
      
      if(!HasOppositePositions())
         return "Tek Yönlü";
      
      double netProfit = CalculateNetProfit();
      return StringFormat("🔄 BUY:%d SELL:%d Net:$%.2f", 
                          m_buyCount, m_sellCount, netProfit);
   }
};

// Static değişkenler
COppositePositionManager::PositionData COppositePositionManager::m_buyPositions[];
COppositePositionManager::PositionData COppositePositionManager::m_sellPositions[];
int COppositePositionManager::m_buyCount = 0;
int COppositePositionManager::m_sellCount = 0;

//====================================================================
// CLASS: CSmartTradeAssistant - AKILLI İŞLEM ASİSTANI
// Kullanıcının açtığı işlemlere göre yön belirler, bekleyen emirler açar
// M1 zaman diliminde hızlı ve akıllı çalışır
//====================================================================
input group "═══════ 🧠 AKILLI İŞLEM ASİSTANI ═══════"
input bool     InpEnableSmartAssist  = true;       // ✅ Akıllı Asistan Aktif
input double   InpAssistLotMulti     = 1.5;        // 📊 Destek Lot Çarpanı
input int      InpPendingDistPips2   = 15;         // 📍 Pending Emir Mesafesi (pip)
input double   InpSmartTPMulti       = 2.0;        // 🎯 Akıllı TP Çarpanı (SL'nin katı)
input int      InpMinBarsToAnalyze   = 5;          // 📊 Min Bar Sayısı Analiz
input int      InpMaxPendingOrders   = 3;          // 📋 Max Bekleyen Emir
input bool     InpUseM1Analysis      = true;       // ⚡ M1 Hızlı Analiz

class CSmartTradeAssistant {
private:
   static int m_userBuyCount;
   static int m_userSellCount;
   static double m_userBuyLots;
   static double m_userSellLots;
   static double m_dominantDirection;  // +1 = BUY baskın, -1 = SELL baskın
   static datetime m_lastAnalysisTime;
   static int m_pendingOrderCount;
   
public:
   //====================================================================
   // BÖLÜM 1: KULLANICI İŞLEMLERİNİ ANALİZ ET
   //====================================================================
   static void AnalyzeUserPositions() {
      m_userBuyCount = 0;
      m_userSellCount = 0;
      m_userBuyLots = 0;
      m_userSellLots = 0;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         
         double lots = PositionGetDouble(POSITION_VOLUME);
         long posType = PositionGetInteger(POSITION_TYPE);
         
         if(posType == POSITION_TYPE_BUY) {
            m_userBuyCount++;
            m_userBuyLots += lots;
         }
         else {
            m_userSellCount++;
            m_userSellLots += lots;
         }
      }
      
      // Baskın yön hesapla
      if(m_userBuyLots > m_userSellLots * 1.2)
         m_dominantDirection = 1;   // BUY baskın
      else if(m_userSellLots > m_userBuyLots * 1.2)
         m_dominantDirection = -1;  // SELL baskın
      else
         m_dominantDirection = 0;   // Nötr/Hedge
   }
   
   //====================================================================
   // BÖLÜM 2: DERİN PİYASA ANALİZİ (M1 HIZINDA)
   //====================================================================
   static int DeepMarketAnalysis() {
      if(!InpUseM1Analysis) return 0;
      
      int score = 0;
      ENUM_TIMEFRAMES tf = PERIOD_M1;  // M1 için hızlı analiz
      
      //--- 1. Son 5 bar momentum analizi
      double momentum = 0;
      for(int i = 1; i <= 5; i++) {
         double o = iOpen(_Symbol, tf, i);
         double c = iClose(_Symbol, tf, i);
         momentum += (c - o);
      }
      if(momentum > 0) score += 15;
      else if(momentum < 0) score -= 15;
      
      //--- 2. Mikro trend (son 10 bar)
      double ma5 = 0, ma10 = 0;
      for(int i = 0; i < 5; i++) ma5 += iClose(_Symbol, tf, i);
      for(int i = 0; i < 10; i++) ma10 += iClose(_Symbol, tf, i);
      ma5 /= 5;
      ma10 /= 10;
      
      if(ma5 > ma10) score += 10;
      else if(ma5 < ma10) score -= 10;
      
      //--- 3. Volatilite spike (son bar büyük mü?)
      double lastRange = iHigh(_Symbol, tf, 1) - iLow(_Symbol, tf, 1);
      double avgRange = 0;
      for(int i = 2; i <= 11; i++)
         avgRange += (iHigh(_Symbol, tf, i) - iLow(_Symbol, tf, i));
      avgRange /= 10;
      
      if(lastRange > avgRange * 1.5) {
         // Büyük mum - yönüne bak
         double lastBody = iClose(_Symbol, tf, 1) - iOpen(_Symbol, tf, 1);
         if(lastBody > 0) score += 20;
         else if(lastBody < 0) score -= 20;
      }
      
      //--- 4. Destek/Direnç yakınlığı
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double pipDist = PipToPoints(10);
      
      // Son 20 bar'ın high/low
      double recentHigh = 0, recentLow = 999999;
      for(int i = 0; i < 20; i++) {
         double h = iHigh(_Symbol, tf, i);
         double l = iLow(_Symbol, tf, i);
         if(h > recentHigh) recentHigh = h;
         if(l < recentLow) recentLow = l;
      }
      
      if(bid <= recentLow + pipDist) score += 15;  // Destek yakını - alım fırsatı
      if(bid >= recentHigh - pipDist) score -= 15; // Direnç yakını - satış fırsatı
      
      //--- 5. Mum pattern (hızlı kontrol)
      bool patternBull = false;
      int bullish = 0;
      if(CCandleAnalyzer::IsEngulfing(1, patternBull) && patternBull) bullish++;
      if(CCandleAnalyzer::IsHammer(1, patternBull)) bullish++;
      if(CCandleAnalyzer::IsThreeWhiteSoldiers()) bullish++;
      
      bool patternBear = false;
      int bearish = 0;
      if(CCandleAnalyzer::IsEngulfing(1, patternBear) && !patternBear) bearish++;
      if(CCandleAnalyzer::IsShootingStar(1, patternBear)) bearish++;
      if(CCandleAnalyzer::IsThreeBlackCrows()) bearish++;
      
      int pattern = (bullish - bearish) * 10;
      score += pattern;
      
      return score;  // + = BUY, - = SELL
   }
   
   //====================================================================
   // BÖLÜM 3: AKILLI TP/SL HESAPLA
   //====================================================================
   static void CalculateSmartTPSL(int direction, double &sl, double &tp) {
      double atr = g_signalScorer.GetATR();
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      // ATR bazlı SL (1.5 * ATR)
      double slDist = atr * 1.5;
      // TP = SL * çarpan
      double tpDist = slDist * InpSmartTPMulti;
      
      if(direction == 1) {  // BUY için
         sl = NormalizeDouble(ask - slDist, digits);
         tp = NormalizeDouble(ask + tpDist, digits);
      }
      else {  // SELL için
         sl = NormalizeDouble(bid + slDist, digits);
         tp = NormalizeDouble(bid - tpDist, digits);
      }
   }
   
   //====================================================================
   // BÖLÜM 4: BEKLEYEn EMİRLER AÇ
   //====================================================================
   static bool PlaceSmartPendingOrders(int direction) {
      if(!InpEnableSmartAssist) return false;
      
      // Max pending kontrol
      CountPendingOrders();
      if(m_pendingOrderCount >= InpMaxPendingOrders) return false;
      
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      double pendingDist = PipToPoints(InpPendingDistPips2);
      
      // Lot hesapla (kullanıcı lotunun katı)
      double userLot = (direction == 1) ? m_userBuyLots : m_userSellLots;
      if(userLot <= 0) userLot = InpMinLot;
      double lot = CLotValidator::ValidateLot(userLot * InpAssistLotMulti);
      
      double sl, tp;
      CalculateSmartTPSL(direction, sl, tp);
      
      datetime expiration = TimeCurrent() + 3600;  // 1 saat geçerli
      
      bool result = false;
      
      if(direction == 1) {
         // BUY LIMIT (düşüşte al)
         double price = NormalizeDouble(bid - pendingDist, digits);
         double limitSL = NormalizeDouble(price - (bid - sl), digits);
         double limitTP = NormalizeDouble(price + (tp - bid), digits);
         
         result = g_trade.BuyLimit(lot, price, _Symbol, limitSL, limitTP, 
                                   ORDER_TIME_SPECIFIED, expiration, "SmartAssist_BL");
         
         if(result) {
            WriteLog("🧠 AKILLI EMİR: BUY LIMIT @ " + DoubleToString(price, digits) + 
                     " | Lot: " + DoubleToString(lot, 2));
         }
         
         // BUY STOP (kırılımda al)
         price = NormalizeDouble(ask + pendingDist, digits);
         double stopSL = NormalizeDouble(price - (bid - sl), digits);
         double stopTP = NormalizeDouble(price + (tp - bid), digits);
         
         if(m_pendingOrderCount < InpMaxPendingOrders - 1) {
            g_trade.BuyStop(lot * 0.5, price, _Symbol, stopSL, stopTP,
                           ORDER_TIME_SPECIFIED, expiration, "SmartAssist_BS");
         }
      }
      else {
         // SELL LIMIT (yükselişte sat)
         double price = NormalizeDouble(ask + pendingDist, digits);
         double limitSL = NormalizeDouble(price + (sl - bid), digits);
         double limitTP = NormalizeDouble(price - (bid - tp), digits);
         
         result = g_trade.SellLimit(lot, price, _Symbol, limitSL, limitTP,
                                    ORDER_TIME_SPECIFIED, expiration, "SmartAssist_SL");
         
         if(result) {
            WriteLog("🧠 AKILLI EMİR: SELL LIMIT @ " + DoubleToString(price, digits) + 
                     " | Lot: " + DoubleToString(lot, 2));
         }
         
         // SELL STOP (kırılımda sat)
         price = NormalizeDouble(bid - pendingDist, digits);
         double stopSL = NormalizeDouble(price + (sl - bid), digits);
         double stopTP = NormalizeDouble(price - (bid - tp), digits);
         
         if(m_pendingOrderCount < InpMaxPendingOrders - 1) {
            g_trade.SellStop(lot * 0.5, price, _Symbol, stopSL, stopTP,
                            ORDER_TIME_SPECIFIED, expiration, "SmartAssist_SS");
         }
      }
      
      return result;
   }
   
   //====================================================================
   // BÖLÜM 5: BEKLEYEN EMİRLERİ SAY
   //====================================================================
   static void CountPendingOrders() {
      m_pendingOrderCount = 0;
      
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
         
         string comment = OrderGetString(ORDER_COMMENT);
         if(StringFind(comment, "SmartAssist") >= 0)
            m_pendingOrderCount++;
      }
   }
   
   //====================================================================
   // BÖLÜM 6: ESKİ EMİRLERİ TEMİZLE
   //====================================================================
   static void CleanupOldOrders() {
      datetime now = TimeCurrent();
      
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
         
         string comment = OrderGetString(ORDER_COMMENT);
         if(StringFind(comment, "SmartAssist") < 0) continue;
         
         datetime orderTime = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
         
         // 30 dakikadan eski emirleri sil
         if(now - orderTime > 1800) {
            g_trade.OrderDelete(ticket);
            WriteLog("🗑️ Eski emir silindi: #" + IntegerToString(ticket));
         }
      }
   }
   
   //====================================================================
   // BÖLÜM 7: KULLANICI YÖNLENDİRMESİ ANALİZİ
   //====================================================================
   static int AnalyzeUserDirection() {
      AnalyzeUserPositions();
      
      // Kullanıcı pozisyonu yoksa piyasa analizine bak
      if(m_userBuyCount == 0 && m_userSellCount == 0) {
         int marketScore = DeepMarketAnalysis();
         if(marketScore >= 30) return 1;    // Güçlü BUY sinyali
         if(marketScore <= -30) return -1;  // Güçlü SELL sinyali
         return 0;
      }
      
      // Kullanıcı yönü + piyasa uyumu
      int marketScore = DeepMarketAnalysis();
      
      if(m_dominantDirection == 1) {
         // Kullanıcı BUY açmış
         if(marketScore > 0) return 1;   // Piyasa da BUY diyor - GÜÇLÜ
         if(marketScore < -20) return 0; // Piyasa tersine gidiyor - bekle
         return 1;  // Kullanıcıyı takip et
      }
      else if(m_dominantDirection == -1) {
         // Kullanıcı SELL açmış
         if(marketScore < 0) return -1;  // Piyasa da SELL diyor - GÜÇLÜ
         if(marketScore > 20) return 0;  // Piyasa tersine gidiyor - bekle
         return -1; // Kullanıcıyı takip et
      }
      
      // Hedge durumu - piyasaya bak
      if(marketScore >= 25) return 1;
      if(marketScore <= -25) return -1;
      
      return 0;
   }
   
   //====================================================================
   // BÖLÜM 8: ANA YÖNETİM FONKSİYONU
   //====================================================================
   static void ExecuteSmartAssistant() {
      if(!InpEnableSmartAssist) return;
      
      // M1'de her bar'da analiz yap
      static datetime lastBar = 0;
      datetime currentBar = iTime(_Symbol, PERIOD_M1, 0);
      
      if(lastBar == currentBar) return;
      lastBar = currentBar;
      
      // Eski emirleri temizle
      CleanupOldOrders();
      
      // Kullanıcı yönlendirmesini analiz et
      int direction = AnalyzeUserDirection();
      
      if(direction == 0) {
         // Sinyal yok - bekle
         return;
      }
      
      //====================================================================
      // ⚠️ REGRESYON TREND TAKİP KONTROLÜ
      // Piyasayla kavga etme - sadece trend yönünde işlem aç!
      //====================================================================
      CRegressionChannel::Draw();  // Hesaplamaları güncelle
      int regTrend = CRegressionChannel::GetTrendDirection();
      
      // Trend çatışması veya kanal taşması varsa işlem açma
      if(CRegressionChannel::IsTrendConflict() || CRegressionChannel::IsChannelBreakout()) {
         WriteLog("⚠️ AKILLI ASİSTAN: Trend çatışması/taşma - işlem açma engellendi!");
         return;
      }
      
      // Regresyon yönüne zıt işlem ENGELLE!
      if(regTrend == 1 && direction == -1) {
         WriteLog("🚫 AKILLI ASİSTAN: Regresyon YUKARI ama SELL istenmiş - ENGELLENDİ!");
         return;  // Uptrend'de SELL açma!
      }
      else if(regTrend == -1 && direction == 1) {
         WriteLog("🚫 AKILLI ASİSTAN: Regresyon AŞAĞI ama BUY istenmiş - ENGELLENDİ!");
         return;  // Downtrend'de BUY açma!
      }
      
      // Bekleyen emirler aç (sadece trend yönünde!)
      PlaceSmartPendingOrders(direction);
      
      m_lastAnalysisTime = TimeCurrent();
   }
   
   //====================================================================
   // BÖLÜM 9: HIZLI TICK ANALİZİ (Her tick'te)
   //====================================================================
   static void QuickTickAnalysis() {
      if(!InpEnableSmartAssist) return;
      
      // Her 10 saniyede bir hızlı kontrol
      static datetime lastQuickCheck = 0;
      if(TimeCurrent() - lastQuickCheck < 10) return;
      lastQuickCheck = TimeCurrent();
      
      AnalyzeUserPositions();
      
      // Kullanıcının açık pozisyonu varsa
      if(m_userBuyCount > 0 || m_userSellCount > 0) {
         // Bekleyen emir yoksa ve piyasa uygunsa
         CountPendingOrders();
         
         if(m_pendingOrderCount == 0) {
            // ⚠️ REGRESYON TREND KONTROLÜ
            CRegressionChannel::Draw();
            int regTrend = CRegressionChannel::GetTrendDirection();
            
            // Trend çatışması veya kanal taşması varsa bekle
            if(CRegressionChannel::IsTrendConflict() || CRegressionChannel::IsChannelBreakout()) {
               return;
            }
            
            int marketScore = DeepMarketAnalysis();
            
            // Güçlü sinyal varsa ve kullanıcı yönüyle uyumluysa VE REGRESYON ONAYLIYSA
            if(m_dominantDirection == 1 && marketScore >= 25 && regTrend >= 0) {
               // Uptrend veya nötr'de BUY açılabilir
               PlaceSmartPendingOrders(1);
            }
            else if(m_dominantDirection == -1 && marketScore <= -25 && regTrend <= 0) {
               // Downtrend veya nötr'de SELL açılabilir
               PlaceSmartPendingOrders(-1);
            }
         }
      }
   }
   
   //====================================================================
   // BÖLÜM 10: DURUM RAPORU
   //====================================================================
   static string GetAssistantStatus() {
      AnalyzeUserPositions();
      CountPendingOrders();
      int marketScore = DeepMarketAnalysis();
      
      string dirStr = "NÖTR";
      if(m_dominantDirection == 1) dirStr = "BUY ⬆️";
      else if(m_dominantDirection == -1) dirStr = "SELL ⬇️";
      
      return StringFormat("🧠 Asistan | Yön: %s | Skor: %d | Pending: %d",
                          dirStr, marketScore, m_pendingOrderCount);
   }
};

// Static değişkenler
int CSmartTradeAssistant::m_userBuyCount = 0;
int CSmartTradeAssistant::m_userSellCount = 0;
double CSmartTradeAssistant::m_userBuyLots = 0;
double CSmartTradeAssistant::m_userSellLots = 0;
double CSmartTradeAssistant::m_dominantDirection = 0;
datetime CSmartTradeAssistant::m_lastAnalysisTime = 0;
int CSmartTradeAssistant::m_pendingOrderCount = 0;

//====================================================================
// REGRESYON TREND ANALİZİ - Ek Input Parametreleri
//====================================================================
input group "═══════ 📐 REGRESYON TREND ANALİZİ ═══════"
input int      InpRegWeight           = 30;         // ⚖️ Trend Skor Ağırlığı

//====================================================================
// CLASS: CTrendFollowSystem - TREND TAKİP SİSTEMİ (PİYASA UYUMU)
// "Piyasayla kavga edilmez, ona uyum sağlanır"
// Trend yukarıysa SADECE BUY, aşağıysa SADECE SELL
//====================================================================
input group "═══════ 📈 TREND TAKİP SİSTEMİ ═══════"
input bool     InpEnableSymmetric     = true;       // ✅ Trend Takip Aktif
input int      InpTrendThreshold      = 25;         // 🎯 Trend Eşiği (skor)
input bool     InpPlaceBothDirections = false;      // 🚫 Her İki Yöne Emir (KAPALI tut!)
input double   InpSymmetricLot        = 0.01;       // 📊 İşlem Lot
input int      InpSymmetricDistPips   = 20;         // 📍 Mesafe (pip)
input double   InpSymmetricRR         = 2.0;        // 🎯 Risk:Ödül Oranı
input int      InpSymmetricExpiryMins = 60;         // ⏱️ Emir Süresi (dakika)

class CSymmetricTradingSystem {
private:
   static datetime m_lastOrderTime;
   static bool m_buyPending;
   static bool m_sellPending;
   
public:
   //====================================================================
   // 7/24 DERİN PİYASA ANALİZİ
   //====================================================================
   static int Analyze247() {
      int buyScore = 0;
      int sellScore = 0;
      
      //--- 1. Multi-Timeframe Analiz
      // M1 Momentum
      double m1Mom = GetMomentum(PERIOD_M1, 10);
      if(m1Mom > 0) buyScore += 10; else sellScore += 10;
      
      // M5 Trend
      double m5Trend = GetMicroTrend(PERIOD_M5);
      if(m5Trend > 0) buyScore += 15; else sellScore += 15;
      
      // M15 Yapı
      double m15Struct = GetMarketStructure(PERIOD_M15);
      if(m15Struct > 0) buyScore += 20; else sellScore += 20;
      
      //--- 2. Teknik Göstergeler
      double rsi = GetRSI(PERIOD_M5);
      if(rsi < 30) buyScore += 25;       // Aşırı satım
      else if(rsi > 70) sellScore += 25; // Aşırı alım
      else if(rsi < 50) buyScore += 10;
      else sellScore += 10;
      
      //--- 3. Volatilite Analizi
      double volRatio = GetVolatilityRatio();
      if(volRatio > 1.5) {
         // Yüksek volatilite - son mumun yönü önemli
         double lastBody = iClose(_Symbol, PERIOD_M1, 1) - iOpen(_Symbol, PERIOD_M1, 1);
         if(lastBody > 0) buyScore += 15;
         else sellScore += 15;
      }
      
      //--- 4. Destek/Direnç Yakınlığı
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double dayHigh = iHigh(_Symbol, PERIOD_D1, 0);
      double dayLow = iLow(_Symbol, PERIOD_D1, 0);
      double range = dayHigh - dayLow;
      
      if(range > 0) {
         double position = (bid - dayLow) / range;
         if(position < 0.3) buyScore += 20;       // Günün dibine yakın
         else if(position > 0.7) sellScore += 20; // Günün tepesine yakın
      }
      
      //--- 5. Son 5 Mum Analizi
      int bullCandles = 0, bearCandles = 0;
      for(int i = 1; i <= 5; i++) {
         if(iClose(_Symbol, PERIOD_M1, i) > iOpen(_Symbol, PERIOD_M1, i))
            bullCandles++;
         else
            bearCandles++;
      }
      if(bullCandles > bearCandles) buyScore += bullCandles * 5;
      else sellScore += bearCandles * 5;
      
      //--- 6. 📐 REGRESYON KANALI - TREND YÖNÜ (EN ÖNEMLİ!)
      // Önce Draw() çağırarak hesaplamaları güncelle
      CRegressionChannel::Draw();
      
      // Eğim yönü piyasanın ana trendini gösterir
      int regScore = CRegressionChannel::GetTrendScore();
      if(regScore > 0) buyScore += regScore;
      else if(regScore < 0) sellScore += MathAbs(regScore);
      
      // Regresyon trend yönü çok güçlüyse ekstra ağırlık
      int regDir = CRegressionChannel::GetTrendDirection();
      if(regDir == 1) {
         buyScore += 10;  // Uptrend onayı
      }
      else if(regDir == -1) {
         sellScore += 10; // Downtrend onayı
      }
      
      //--- 7. ⚠️ TREND ÇATIŞMASI VE KANAL TAŞMASI KONTROLÜ
      // Trend aşağı ama fiyat yukarı taşıyor = TEMKİNLİ OL!
      if(CRegressionChannel::IsTrendConflict()) {
         // Trend çatışması var - skoru sıfırla, işlem açma!
         WriteLog("⚠️ TREND ÇATIŞMASI: İşlem açma engellendi - piyasa yönünü bekle!");
         return 0;  // Nötr skor = işlem açma
      }
      
      if(CRegressionChannel::IsChannelBreakout()) {
         // Kanal taşması var - skoru çok azalt
         buyScore = buyScore / 3;
         sellScore = sellScore / 3;
         WriteLog("🚨 KANAL TAŞMASI: Skor azaltıldı - temkinli mod!");
      }
      
      // Skor farkını döndür (+ = BUY, - = SELL, 0 = Nötr)
      return buyScore - sellScore;
   }
   
   //====================================================================
   // YARDIMCI FONKSİYONLAR
   //====================================================================
   static double GetMomentum(ENUM_TIMEFRAMES tf, int period) {
      double sum = 0;
      for(int i = 1; i <= period; i++) {
         sum += iClose(_Symbol, tf, i) - iOpen(_Symbol, tf, i);
      }
      return sum;
   }
   
   static double GetMicroTrend(ENUM_TIMEFRAMES tf) {
      double ma5 = 0, ma10 = 0;
      for(int i = 0; i < 5; i++) ma5 += iClose(_Symbol, tf, i);
      for(int i = 0; i < 10; i++) ma10 += iClose(_Symbol, tf, i);
      return (ma5 / 5) - (ma10 / 10);
   }
   
   static double GetMarketStructure(ENUM_TIMEFRAMES tf) {
      double high1 = iHigh(_Symbol, tf, 1);
      double high2 = iHigh(_Symbol, tf, 2);
      double low1 = iLow(_Symbol, tf, 1);
      double low2 = iLow(_Symbol, tf, 2);
      
      // Higher High & Higher Low = Uptrend
      if(high1 > high2 && low1 > low2) return 1;
      // Lower High & Lower Low = Downtrend
      if(high1 < high2 && low1 < low2) return -1;
      return 0;
   }
   
   static double GetRSI(ENUM_TIMEFRAMES tf) {
      double rsi[];
      ArraySetAsSeries(rsi, true);
      if(CopyBuffer(g_hRSI, 0, 0, 1, rsi) < 1) return 50;
      return rsi[0];
   }
   
   static double GetVolatilityRatio() {
      double currentRange = iHigh(_Symbol, PERIOD_M1, 0) - iLow(_Symbol, PERIOD_M1, 0);
      double avgRange = 0;
      for(int i = 1; i <= 10; i++)
         avgRange += iHigh(_Symbol, PERIOD_M1, i) - iLow(_Symbol, PERIOD_M1, i);
      avgRange /= 10;
      
      if(avgRange == 0) return 1;
      return currentRange / avgRange;
   }
   
   //====================================================================
   // SİMETRİK PENDING EMİRLER
   //====================================================================
   static void PlaceSymmetricOrders() {
      if(!InpEnableSymmetric) return;
      
      // Son emir zamanını kontrol et (spam önleme)
      if(TimeCurrent() - m_lastOrderTime < 60) return;  // Min 1 dakika bekle
      
      // Mevcut pending emirleri kontrol et
      CheckExistingPendings();
      
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      double dist = PipToPoints(InpSymmetricDistPips);
      double lot = CLotValidator::ValidateLot(InpSymmetricLot);
      datetime expiry = TimeCurrent() + InpSymmetricExpiryMins * 60;
      
      // ATR bazlı SL hesapla
      double atr = g_signalScorer.GetATR();
      double slDist = atr * 1.5;
      double tpDist = slDist * InpSymmetricRR;
      
      int analysis = Analyze247();
      
      //====================================================================
      // 🎯 TREND TAKİP MANTIĞI - PİYASAYLA UYUM
      // Trend yönü belirliyse SADECE o yönde işlem aç
      // Hiçbir zaman zıt yönde pozisyon açma!
      //====================================================================
      
      if(InpPlaceBothDirections) {
         // UYARI: Bu seçenek aktifse kullanıcı piyasayla kavga eder!
         WriteLog("⚠️ UYARI: Her iki yöne emir açmak riskli! Trend takip önerilir.");
         PlaceBuyOrders(ask, dist, slDist, tpDist, lot, expiry, digits);
         PlaceSellOrders(bid, dist, slDist, tpDist, lot, expiry, digits);
      }
      else {
         // 🎯 TREND TAKİP: Sadece analiz yönünde işlem
         if(analysis >= InpTrendThreshold) {
            // Güçlü UPTREND - SADECE BUY
            WriteLog("📈 TREND: Yukarı yönlü (" + IntegerToString(analysis) + ") - SADECE BUY emirleri");
            PlaceBuyOrders(ask, dist, slDist, tpDist, lot, expiry, digits);
         }
         else if(analysis <= -InpTrendThreshold) {
            // Güçlü DOWNTREND - SADECE SELL
            WriteLog("📉 TREND: Aşağı yönlü (" + IntegerToString(analysis) + ") - SADECE SELL emirleri");
            PlaceSellOrders(bid, dist, slDist, tpDist, lot, expiry, digits);
         }
         else {
            // Trend belirsiz - HİÇ İŞLEM AÇMA, bekle!
            WriteLog("⌛ TREND BELİRSİZ (" + IntegerToString(analysis) + ") - Bekleme modunda...");
            // Piyasa yönünü net gösterene kadar işlem yok!
         }
      }
      
      m_lastOrderTime = TimeCurrent();
   }
   
   static void PlaceBuyOrders(double ask, double dist, double sl, double tp, double lot, datetime exp, int dig) {
      if(m_buyPending) return;
      
      // BUY LIMIT - Düşüşte al
      double limitPrice = NormalizeDouble(ask - dist, dig);
      double limitSL = NormalizeDouble(limitPrice - sl, dig);
      double limitTP = NormalizeDouble(limitPrice + tp, dig);
      
      bool result = g_trade.BuyLimit(lot, limitPrice, _Symbol, limitSL, limitTP,
                                     ORDER_TIME_SPECIFIED, exp, "Symmetric_BL");
      if(result) {
         WriteLog("⚖️ SİMETRİK: BUY LIMIT @ " + DoubleToString(limitPrice, dig));
         m_buyPending = true;
      }
      
      // BUY STOP - Kırılımda al
      double stopPrice = NormalizeDouble(ask + dist, dig);
      double stopSL = NormalizeDouble(stopPrice - sl, dig);
      double stopTP = NormalizeDouble(stopPrice + tp, dig);
      
      g_trade.BuyStop(lot, stopPrice, _Symbol, stopSL, stopTP,
                     ORDER_TIME_SPECIFIED, exp, "Symmetric_BS");
   }
   
   static void PlaceSellOrders(double bid, double dist, double sl, double tp, double lot, datetime exp, int dig) {
      if(m_sellPending) return;
      
      // SELL LIMIT - Yükselişte sat
      double limitPrice = NormalizeDouble(bid + dist, dig);
      double limitSL = NormalizeDouble(limitPrice + sl, dig);
      double limitTP = NormalizeDouble(limitPrice - tp, dig);
      
      bool result = g_trade.SellLimit(lot, limitPrice, _Symbol, limitSL, limitTP,
                                      ORDER_TIME_SPECIFIED, exp, "Symmetric_SL");
      if(result) {
         WriteLog("⚖️ SİMETRİK: SELL LIMIT @ " + DoubleToString(limitPrice, dig));
         m_sellPending = true;
      }
      
      // SELL STOP - Kırılımda sat
      double stopPrice = NormalizeDouble(bid - dist, dig);
      double stopSL = NormalizeDouble(stopPrice + sl, dig);
      double stopTP = NormalizeDouble(stopPrice - tp, dig);
      
      g_trade.SellStop(lot, stopPrice, _Symbol, stopSL, stopTP,
                      ORDER_TIME_SPECIFIED, exp, "Symmetric_SS");
   }
   
   //====================================================================
   // MEVCUT PENDING EMİRLERİ KONTROL ET
   //====================================================================
   static void CheckExistingPendings() {
      m_buyPending = false;
      m_sellPending = false;
      
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
         
         string comment = OrderGetString(ORDER_COMMENT);
         if(StringFind(comment, "Symmetric") < 0) continue;
         
         long orderType = OrderGetInteger(ORDER_TYPE);
         if(orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP)
            m_buyPending = true;
         if(orderType == ORDER_TYPE_SELL_LIMIT || orderType == ORDER_TYPE_SELL_STOP)
            m_sellPending = true;
      }
   }
   
   //====================================================================
   // ESKİ EMİRLERİ TEMİZLE
   //====================================================================
   static void CleanupExpiredOrders() {
      datetime now = TimeCurrent();
      
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
         
         string comment = OrderGetString(ORDER_COMMENT);
         if(StringFind(comment, "Symmetric") < 0) continue;
         
         datetime orderTime = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
         
         // Süresi dolmuşları sil
         if(now - orderTime > InpSymmetricExpiryMins * 60) {
            g_trade.OrderDelete(ticket);
            WriteLog("🗑️ Süresi dolan simetrik emir silindi: #" + IntegerToString(ticket));
         }
      }
   }
   
   //====================================================================
   // ANA DÖNGÜ
   //====================================================================
   static void Execute() {
      if(!InpEnableSymmetric) return;
      
      // Her dakika kontrol
      static datetime lastMinute = 0;
      datetime currentMinute = TimeCurrent() / 60;
      
      if(lastMinute == currentMinute) return;
      lastMinute = currentMinute;
      
      // Eski emirleri temizle
      CleanupExpiredOrders();
      
      // Simetrik emirler aç
      PlaceSymmetricOrders();
   }
   
   //====================================================================
   // DURUM RAPORU
   //====================================================================
   static string GetStatus() {
      CheckExistingPendings();
      int analysis = Analyze247();
      
      string dirStr = "⌛ BEKLİYOR";
      if(analysis >= InpTrendThreshold) dirStr = "📈 UPTREND - BUY";
      else if(analysis <= -InpTrendThreshold) dirStr = "📉 DOWNTREND - SELL";
      
      return StringFormat("📈 Trend Takip | %s (%+d) | Pending BUY:%s SELL:%s",
                          dirStr, analysis,
                          m_buyPending ? "✓" : "✗",
                          m_sellPending ? "✓" : "✗");
   }
};

// Static değişkenler
datetime CSymmetricTradingSystem::m_lastOrderTime = 0;
bool CSymmetricTradingSystem::m_buyPending = false;
bool CSymmetricTradingSystem::m_sellPending = false;

//====================================================================
// ARAŞTIRMA SONUCU İYİLEŞTİRMELER
//====================================================================

//====================================================================
// 1. FRACTIONAL KELLY - Güvenli Lot Hesaplama
//====================================================================
input group "═══════ 📊 GELİŞMİŞ PARA YÖNETİMİ ═══════"
input double   InpKellyFraction       = 0.50;       // 📊 Kelly Fraksiyonu (0.25-0.75 önerilir)
input bool     InpUseFractionalKelly  = true;       // ✅ Fractional Kelly Kullan
input double   InpMaxRiskPerTrade     = 2.0;        // 🛡️ Max Risk/Trade (%)
input double   InpNewMaxDrawdown      = 20.0;       // 📉 Yeni Max DD Limiti (%)

class CFractionalKelly {
public:
   static double CalculateLot() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      
      if(!InpUseFractionalKelly) {
         // Normal risk % hesaplama
         return balance * (InpMaxRiskPerTrade / 100) / (InpMinSL_Pips * 10);
      }
      
      // Win rate ve avg win/loss hesapla
      double winRate = (g_totalTrades > 0) ? (double)g_winTrades / g_totalTrades : 0.5;
      double avgWin = (g_winTrades > 0) ? g_totalProfit / g_winTrades : 1.0;
      double avgLoss = (g_lossTrades > 0) ? MathAbs(g_totalProfit) / g_lossTrades : 1.0;
      
      if(avgLoss == 0) avgLoss = 1.0;
      double winLossRatio = avgWin / avgLoss;
      if(winLossRatio == 0) winLossRatio = 1.0;
      
      // Kelly Formula: f = W - (1-W)/R
      double fullKelly = winRate - ((1 - winRate) / winLossRatio);
      
      // Negatif Kelly = edge yok, minimum lot kullan
      if(fullKelly <= 0) {
         WriteLog("⚠️ Kelly negatif - Edge yok, minimum lot kullanılıyor");
         return InpMinLot;
      }
      
      // Fractional Kelly uygula
      double fractionalKelly = fullKelly * InpKellyFraction;
      
      // Max risk limiti
      fractionalKelly = MathMin(fractionalKelly, InpMaxRiskPerTrade / 100);
      
      // Lot hesapla
      double lot = balance * fractionalKelly / (InpMinSL_Pips * 10);
      lot = CLotValidator::ValidateLot(lot);
      
      WriteLog("📊 Fractional Kelly: Full=" + DoubleToString(fullKelly * 100, 1) + 
               "% | Frac=" + DoubleToString(fractionalKelly * 100, 1) + 
               "% | Lot=" + DoubleToString(lot, 2));
      
      return lot;
   }
};

//====================================================================
// 2. DİNAMİK GRİD ARALIĞI - ATR Bazlı
//====================================================================
class CDynamicGrid {
public:
   static double GetDynamicGridStep(double baseStep) {
      double currentATR = g_signalScorer.GetATR();
      
      // Son 20 bar'ın ortalama ATR'si
      double avgATR = 0;
      for(int i = 1; i <= 20; i++) {
         double h = iHigh(_Symbol, InpTimeframe, i);
         double l = iLow(_Symbol, InpTimeframe, i);
         avgATR += (h - l);
      }
      avgATR /= 20;
      
      if(avgATR == 0) return baseStep;
      
      // Volatilite oranı
      double volRatio = currentATR / avgATR;
      
      // Yüksek volatilitede grid genişlet, düşükte daralt
      double dynamicStep = baseStep * volRatio;
      
      // Min/Max sınırları
      dynamicStep = MathMax(baseStep * 0.5, dynamicStep);  // En az yarısı
      dynamicStep = MathMin(baseStep * 2.0, dynamicStep);  // En fazla 2 katı
      
      return dynamicStep;
   }
   
   static string GetVolatilityStatus() {
      double currentATR = g_signalScorer.GetATR();
      double avgATR = 0;
      for(int i = 1; i <= 20; i++) {
         avgATR += iHigh(_Symbol, InpTimeframe, i) - iLow(_Symbol, InpTimeframe, i);
      }
      avgATR /= 20;
      
      if(avgATR == 0) return "NORMAL";
      
      double ratio = currentATR / avgATR;
      
      if(ratio > 1.5) return "YÜKSEK VOL 🔥";
      if(ratio < 0.7) return "DÜŞÜK VOL 😴";
      return "NORMAL 📊";
   }
   
   // GetDynamicSpacing - OnTick'te kullanılan wrapper
   static double GetDynamicSpacing(double currentATR) {
      // ATR bazlı dinamik grid aralığı
      return GetDynamicGridStep(InpGrid_StepPips);
   }
};

//====================================================================
// 3. GELİŞMİŞ DD YÖNETİMİ - Daha Sıkı Kontrol
//====================================================================
class CEnhancedDDManager {
private:
   static double m_peakBalance;
   static double m_currentDD;
   static int    m_ddWarningLevel;
   
public:
   static void Init() {
      m_peakBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      m_currentDD = 0;
      m_ddWarningLevel = 0;
   }
   
   static void Update() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      
      // Peak balance güncelle
      if(balance > m_peakBalance)
         m_peakBalance = balance;
      
      // Current DD hesapla
      m_currentDD = ((m_peakBalance - equity) / m_peakBalance) * 100;
      
      // Uyarı seviyeleri
      if(m_currentDD > InpNewMaxDrawdown) {
         // Kritik DD - Tüm işlemleri kapat
         WriteLog("🚨 KRİTİK DD: %" + DoubleToString(m_currentDD, 1) + " - ACİL KAPANIŞ!");
         CloseAllPositions();
         m_ddWarningLevel = 3;
      }
      else if(m_currentDD > InpNewMaxDrawdown * 0.75) {
         // Yüksek DD - Yeni işlem açma, mevcut işlemleri sıkılaştır
         if(m_ddWarningLevel < 2) {
            WriteLog("⚠️ YÜKSEK DD: %" + DoubleToString(m_currentDD, 1) + " - İşlem açma duraklatıldı");
            m_ddWarningLevel = 2;
         }
      }
      else if(m_currentDD > InpNewMaxDrawdown * 0.5) {
         // Orta DD - Lot küçült
         if(m_ddWarningLevel < 1) {
            WriteLog("⚠️ ORTA DD: %" + DoubleToString(m_currentDD, 1) + " - Lot azaltıldı");
            m_ddWarningLevel = 1;
         }
      }
      else {
         m_ddWarningLevel = 0;
      }
   }
   
   static double GetLotMultiplier() {
      // DD seviyesine göre lot çarpanı
      switch(m_ddWarningLevel) {
         case 1: return 0.5;  // Yarı lot
         case 2: return 0.0;  // İşlem açma
         case 3: return 0.0;  // Acil kapatma
         default: return 1.0; // Normal
      }
   }
   
   static bool CanOpenNewTrade() {
      return (m_ddWarningLevel < 2);
   }
   
   static void CloseAllPositions() {
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetString(POSITION_SYMBOL) == _Symbol) {
            g_trade.PositionClose(ticket);
         }
      }
   }
   
   static string GetDDStatus() {
      return StringFormat("DD: %.1f%% | Peak: $%.2f | Level: %d", 
                          m_currentDD, m_peakBalance, m_ddWarningLevel);
   }
   
   static double GetCurrentDD() { return m_currentDD; }
   
   // GetDDAction - OnTick'te kullanılan wrapper
   // Return: 0=Normal, 1=Orta DD (lot küçült), 2=Yüksek DD (işlem açma), 3=Kritik (kapat)
   static int GetDDAction() {
      Update();  // Önce güncelle
      return m_ddWarningLevel;
   }
};

// Static değişkenler
double CEnhancedDDManager::m_peakBalance = 0;
double CEnhancedDDManager::m_currentDD = 0;
int    CEnhancedDDManager::m_ddWarningLevel = 0;

//====================================================================
// 4. VOLATİLİTE MOMENTUM YAKALAMA - Haber Fırsatları
//====================================================================
input group "═══════ 🚀 MOMENTUM YAKALAMA ═══════"
input bool     InpUseMomentumMode     = true;       // ✅ Momentum Modu Aktif
input double   InpMomentumThreshold   = 1.5;        // 📈 Momentum Eşiği (ATR çarpanı)
input double   InpMomentumLotMulti    = 1.5;        // 📊 Momentum Lot Çarpanı
input int      InpMomentumBars        = 3;          // 📊 Momentum Bar Sayısı

class CMomentumCatcher {
private:
   static datetime m_lastMomentumTime;
   static int m_momentumDirection;
   
public:
   //--- Volatilite spike tespiti (haber/momentum)
   static bool DetectVolatilitySpike() {
      double currentRange = iHigh(_Symbol, PERIOD_M1, 0) - iLow(_Symbol, PERIOD_M1, 0);
      
      // Son 20 bar ortalama range
      double avgRange = 0;
      for(int i = 1; i <= 20; i++) {
         avgRange += iHigh(_Symbol, PERIOD_M1, i) - iLow(_Symbol, PERIOD_M1, i);
      }
      avgRange /= 20;
      
      if(avgRange == 0) return false;
      
      // Threshold aşıldı mı?
      return (currentRange > avgRange * InpMomentumThreshold);
   }
   
   //--- Momentum yönü tespiti
   static int GetMomentumDirection() {
      double momentum = 0;
      
      for(int i = 0; i < InpMomentumBars; i++) {
         double o = iOpen(_Symbol, PERIOD_M1, i);
         double c = iClose(_Symbol, PERIOD_M1, i);
         momentum += (c - o);
      }
      
      if(momentum > 0) return 1;   // Bullish momentum
      if(momentum < 0) return -1;  // Bearish momentum
      return 0;
   }
   
   //--- Momentum fırsatı işlemi
   static void ExecuteMomentumTrade() {
      if(!InpUseMomentumMode) return;
      if(!DetectVolatilitySpike()) return;
      
      // Son momentum işleminden beri en az 5 dakika geçmeli
      if(TimeCurrent() - m_lastMomentumTime < 300) return;
      
      int direction = GetMomentumDirection();
      if(direction == 0) return;
      
      //====================================================================
      // ⚠️ REGRESYON TREND KONTROLÜ - Momentum regresyona zıt mı?
      //====================================================================
      CRegressionChannel::Draw();
      int regTrend = CRegressionChannel::GetTrendDirection();
      
      // Regresyon yönüne zıt momentum ENGELLE!
      if(regTrend == 1 && direction == -1) {
         WriteLog("🚫 MOMENTUM: Regresyon YUKARI ama momentum AŞAĞI - ENGELLENDİ!");
         return;
      }
      else if(regTrend == -1 && direction == 1) {
         WriteLog("🚫 MOMENTUM: Regresyon AŞAĞI ama momentum YUKARI - ENGELLENDİ!");
         return;
      }
      
      // DD kontrolü
      if(!CEnhancedDDManager::CanOpenNewTrade()) return;
      
      double lot = CFractionalKelly::CalculateLot() * InpMomentumLotMulti;
      lot = CLotValidator::ValidateLot(lot);
      
      double atr = g_signalScorer.GetATR();
      double sl = atr * 2.0;  // Geniş SL (volatil piyasa)
      double tp = atr * 3.0;  // 1:1.5 R:R
      
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      if(direction == 1) {
         double slPrice = NormalizeDouble(ask - sl, digits);
         double tpPrice = NormalizeDouble(ask + tp, digits);
         
         if(g_trade.Buy(lot, _Symbol, ask, slPrice, tpPrice, "Momentum_BUY")) {
            WriteLog("🚀 MOMENTUM BUY: Volatilite spike! Lot=" + DoubleToString(lot, 2));
            m_lastMomentumTime = TimeCurrent();
            m_momentumDirection = 1;
         }
      }
      else {
         double slPrice = NormalizeDouble(bid + sl, digits);
         double tpPrice = NormalizeDouble(bid - tp, digits);
         
         if(g_trade.Sell(lot, _Symbol, bid, slPrice, tpPrice, "Momentum_SELL")) {
            WriteLog("🚀 MOMENTUM SELL: Volatilite spike! Lot=" + DoubleToString(lot, 2));
            m_lastMomentumTime = TimeCurrent();
            m_momentumDirection = -1;
         }
      }
   }
   
   //--- Momentum devam işlemi (momentum yönünde ek pozisyon)
   static void ExecuteMomentumContinuation() {
      if(!InpUseMomentumMode) return;
      if(m_momentumDirection == 0) return;
      
      // Momentum hala devam ediyor mu?
      int currentDir = GetMomentumDirection();
      if(currentDir != m_momentumDirection) {
         m_momentumDirection = 0;  // Momentum sona erdi
         return;
      }
      
      // Güçlü momentum devamı - pending emir ekle
      if(DetectVolatilitySpike()) {
         // Son 5 bar aynı yönde mi?
         int sameDir = 0;
         for(int i = 0; i < 5; i++) {
            double o = iOpen(_Symbol, PERIOD_M1, i);
            double c = iClose(_Symbol, PERIOD_M1, i);
            if((m_momentumDirection == 1 && c > o) ||
               (m_momentumDirection == -1 && c < o))
               sameDir++;
         }
         
         if(sameDir >= 4) {
            WriteLog("🔥 GÜÇLÜ MOMENTUM DEVAMI: " + IntegerToString(sameDir) + "/5 bar aynı yönde");
         }
      }
   }
   
   static string GetMomentumStatus() {
      if(!InpUseMomentumMode) return "KAPALI";
      
      if(DetectVolatilitySpike()) {
         int dir = GetMomentumDirection();
         if(dir == 1) return "🚀 BULLISH SPIKE!";
         if(dir == -1) return "🚀 BEARISH SPIKE!";
         return "⚡ VOL SPIKE";
      }
      
      return "Beklemede";
   }
   
   // CatchMomentum - OnTick'te kullanılan wrapper
   static void CatchMomentum() {
      ExecuteMomentumTrade();
      ExecuteMomentumContinuation();
   }
};

// Static değişkenler
datetime CMomentumCatcher::m_lastMomentumTime = 0;
int CMomentumCatcher::m_momentumDirection = 0;
//+------------------------------------------------------------------+
