//+------------------------------------------------------------------+
//|                                           Milyoner_Kod_EA.mq5    |
//|                    © 2025, Milyoner Kod Trading System v2.0      |
//|          All-in-One: AI + Internet + Modular Architecture        |
//+------------------------------------------------------------------+
//| v2.0 YENİ ÖZELLİKLER:                                            |
//| • İnternet Veri Çekme (Haber, Takvim, Sentiment API)             |
//| • AI-Tabanlı Sinyal Skoru (10-Faktör + Makine Öğrenmesi)         |
//| • Modüler Mimari (CInternetData, CAIEngine, CSignalEngine, etc)  |
//| • Gelişmiş Dashboard (Milestone Ladder + İlerleme Çubuğu)        |
//| • Kelly Kriteri + Monte-Carlo Simülasyonu                        |
//| • Renkli Regresyon Kanalı (Mavi/Kırmızı/Yeşil)                   |
//| • TSI, VWAP, SuperTrend (Yerel Hesaplama)                        |
//| • WebRequest + JSON Parsing                                      |
//| • Türkçe Tam Yerelleştirme                                       |
//+------------------------------------------------------------------+
//| MEVCUT ÖZELLİKLER (v1.x):                                        |
//| • TSI (True Strength Index) Momentum Modülü                      |
//| • Dinamik Volatilite Rejimi (Sakin/Trend/Kaos)                   |
//| • Akıllı Grid (Smart Grid AI - RSI/Destek Bazlı)                 |
//| • Öz-Düzeltme (Self-Correction) Mekanizması                      |
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
#property copyright "© 2025, Milyoner Kod EA v2.0"
#property version   "2.0"
#property description "AI + İnternet + Modüler Mimari + Türkçe"
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
   SIG_TSI_MOMENTUM,     // TSI Momentum (YENİ)
   SIG_MA_CROSS,         // MA Kesişim
   SIG_PATTERN,          // Mum Pattern
   SIG_COMBINED,         // Birleşik
   SIG_HARMONY           // Tam Harmony
};

enum ENUM_VOLATILITY_MODE {
   VOL_ADAPTIVE,         // Dinamik (Otomatik)
   VOL_LOW,              // Düşük Volatilite (Sakin)
   VOL_NORMAL,           // Normal Volatilite (Trend)
   VOL_HIGH              // Yüksek Volatilite (Kaos)
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

//====================================================================
// INPUT PARAMETRELERİ - 1. ANA AYARLAR
//====================================================================
input group "═══════ 1. ANA AYARLAR ═══════"
input ulong          InpMagicNumber     = 777777;         // 🎰 Magic Number (Milyoner)
input string         InpTradeComment    = "Milyoner_v1";  // 💬 İşlem Yorumu
input ENUM_TIMEFRAMES InpTimeframe      = PERIOD_H1;      // ⏰ Zaman Dilimi
input ENUM_SIGNAL_MODE InpSignalMode    = SIG_AI_SCORE;   // 📊 Sinyal Modu
input ENUM_ENTRY_MODE InpEntryMode      = MODE_SMART;     // 📋 Giriş Modu

//====================================================================
// INPUT PARAMETRELERİ - 1.1 VOLATİLİTE REJİMİ (YENİ)
//====================================================================
input group "═══════ 1.1 VOLATİLİTE REJİMİ (YENİ) ═══════"
input ENUM_VOLATILITY_MODE InpVolMode   = VOL_ADAPTIVE;   // 🌪️ Volatilite Modu
input int            InpVolATRPeriod    = 14;             // ATR Periyodu
input double         InpVolThresholdLow = 10.0;           // Düşük Eşik (pips)
input double         InpVolThresholdHigh= 30.0;           // Yüksek Eşik (pips)
input bool           InpAvoidKaos       = true;           // ⚠️ Kaos Modunda İşlem Yapma

//====================================================================
// INPUT PARAMETRELERİ - 2. AI SİNYAL SİSTEMİ
//====================================================================
input group "═══════ 2. AI SİNYAL SİSTEMİ ═══════"
input int            InpMinSignalScore  = 60;             // 🎯 Min Sinyal Skoru
input int            InpStrongSignalScore = 75;           // 💪 Güçlü Sinyal Skoru
input bool           InpUseHarmonyBoost = true;           // 🚀 Harmony Güçlendirme

//--- AI Filtre Ağırlıkları
input double         InpWeight_TSI      = 25.0;           // TSI Ağırlığı (YENİ)
input double         InpWeight_MACross  = 15.0;           // MA Cross Ağırlığı
input double         InpWeight_MACD     = 10.0;           // MACD Ağırlığı
input double         InpWeight_RSI      = 10.0;           // RSI Ağırlığı
input double         InpWeight_ADX      = 10.0;           // ADX Ağırlığı
input double         InpWeight_Pattern  = 15.0;           // Pattern Ağırlığı
input double         InpWeight_Level    = 15.0;           // Seviye Ağırlığı

//====================================================================
// INPUT PARAMETRELERİ - 2.1 TSI MOMENTUM (YENİ)
//====================================================================
input group "═══════ 2.1 TSI MOMENTUM (YENİ) ═══════"
input bool           InpUseTSI          = true;           // ✅ TSI Kullan
input int            InpTSI_Period_R    = 25;             // TSI R Periyodu (Yavaş)
input int            InpTSI_Period_S    = 13;             // TSI S Periyodu (Hızlı)
input int            InpTSI_Signal      = 7;              // TSI Sinyal
input int            InpTSI_OB          = 25;             // Aşırı Alım
input int            InpTSI_OS          = -25;            // Aşırı Satım

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
// INPUT PARAMETRELERİ - 7. RİSK YÖNETİMİ
//====================================================================
input group "═══════ 7. RİSK YÖNETİMİ ═══════"
input ENUM_LOT_MODE  InpLotMode         = LOT_RISK_PERCENT; // 💰 Lot Modu
input double         InpFixedLot        = 0.01;           // Sabit Lot
input double         InpRiskPercent     = 1.5;            // Risk %
input double         InpMaxLot          = 5.0;            // Max Lot
input double         InpMinLot          = 0.01;           // Min Lot
input double         InpLotMultiplier   = 1.5;            // Lot Çarpanı
input double         InpMaxDailyDD      = 5.0;            // Günlük Max DD %
input double         InpMaxDDPercent    = 15.0;           // 🛑 Hard Drawdown Koruma % (Hard DD)
input int            InpMaxDailyTrades  = 12;             // Günlük Max İşlem
input int            InpMaxOpenPos      = 2;              // Max Açık Pozisyon

//====================================================================
// INPUT PARAMETRELERİ - 7.1 ÖZ-DÜZELTME (YENİ)
//====================================================================
input group "═══════ 7.1 ÖZ-DÜZELTME MEKANİZMASI (YENİ) ═══════"
input bool           InpUseSelfCorrection = true;         // ✅ Öz-Düzeltme
input int            InpMaxConsLosses     = 3;            // Max Ardışık Kayıp
input int            InpPenaltyDuration   = 60;           // Ceza Süresi (dk)
input bool           InpReduceRiskOnLoss  = true;         // Kayıpta Riski Düşür

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
// INPUT PARAMETRELERİ - 9. GRİD SİSTEMİ (GELİŞMİŞ)
//====================================================================
input group "═══════ 9. AKILLI GRİD & BASKET ═══════"
input bool           InpUseGrid         = false;          // ✅ Grid Kullan (Risklidir!)
input bool           InpUseSmartGrid    = true;           // 🧠 Akıllı Grid (RSI/SR bekler)
input int            InpGrid_MaxLevels  = 7;              // Max Grid Seviye
input double         InpGrid_StepPips   = 30;             // Grid Adımı (pip)
input double         InpGrid_LotMulti   = 1.5;            // Grid Lot Çarpanı
input bool           InpAveraging       = true;           // ✅ Averaging
input double         InpAveragingProfit = 10.0;           // Basket Hedef Kâr ($)

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
// INPUT PARAMETRELERİ - 14. FİLTRELER
//====================================================================
input group "═══════ 14. FİLTRELER ═══════"
input int            InpMaxSpreadPips   = 5;              // Max Spread (pip)
input int            InpCooldownBars    = 3;              // Bekleme (bar)
input bool           InpUseTimeFilter   = false;          // ⏰ Zaman Filtresi
input int            InpStartHour       = 8;              // Başlangıç Saati
input int            InpEndHour         = 20;             // Bitiş Saati
input bool           InpUseSessionFilter = true;          // 🌏 Seans Filtresi (Lon/NY öncelikli)
input bool           InpUseSMC           = true;          // 🏦 SMC Filtresi (OB/FVG/Liquidity)

//====================================================================
// INPUT PARAMETRELERİ - 15. PROFESYONEL OTONOM SİSTEMLER (v1.07)
//====================================================================
input group "═════ 15. OTONOM DÜZELTME & KORUMA ═════"
input bool           InpAutoCloseOpposite   = true;       // 🚨 Trend Zıt Pozisyonları Kapat
input int            InpOppositeCloseDelay  = 60;         // ⏱️ Kapatma Gecikmesi (sn)
input bool           InpAutoAddSLTP         = true;       // 🛡️ Eksik SL/TP Otomatik Ekle
input double         InpAutoSL_Pips         = 50;         // 📈 Varsayılan Koruma SL (pip)
input bool           InpTrailingPending     = true;       // 🔄 Bekleyen Emirleri Takip Et
input double         InpPendingMoveStep     = 5.0;        // Emir Taşıma Hassasiyeti (pip)
input double         InpPendingDistPips     = 20.0;       // 📏 Bekleyen Emir Mesafesi (pip)
input bool           InpUseHedge            = true;       // 🛡️ Hedge Koruma Kullan
input double         InpHedgeLotPercent     = 50.0;       // Hedge Lot Oranı (%)
input int            InpRegChannelBars      = 100;        // 📏 Regresyon Kanalı Bar Sayısı

//====================================================================
// INPUT PARAMETRELERİ - 16. GÖRSEL
//====================================================================
input group "═══════ 16. GÖRSEL ═══════"
input bool           InpShowDashboard   = true;           // 📊 Dashboard
input bool           InpShowDebugLog    = true;           // 🔍 Debug Log

//====================================================================
// INPUT PARAMETRELERİ - 17. MOTİVASYON (Milyoner)
//====================================================================
input group "═══════ 12. AKILLI KISMİ KAPAMA ═══════"
input bool           InpUsePartialClose = true;           // ✅ Kısmi Kapama Kullan
input double         InpPartial1_Trigger = 30.0;          // 1. Kapama Tetik % (TP'nin %'si)
input double         InpPartial1_Close  = 50.0;           // 1. Kapama Lot %
input bool           InpPartialMoveToBE = true;           // Kısmi sonrası BE'ye çek

input group "═══════ 13. GELİŞMİŞ SEVİYELER ═══════"
input bool           InpUseFibonacci    = true;           // ✅ Fibonacci Kullan
input int            InpFibLookback     = 50;             // Fibonacci Bakış Barı
input bool           InpUsePivots       = true;           // ✅ Pivot Noktaları
input ENUM_PIVOT_TYPE InpPivotType      = PIVOT_CLASSIC;  // Pivot Tipi

input group "═══════ 17. MOTİVASYON (MILYONER) ═══════"
input double         InpTargetBalance   = 1000000.0;      // 🎯 HEDEF: 1 MİLYON $
input string         InpMillionMsg      = "Yolun Sonu Refah!"; // 📢 Motivasyon Mesajı

//====================================================================
// INPUT PARAMETRELERİ - 18. İNTERNET VERİ ENTEGRASYONU (v2.0)
//====================================================================
input group "═════ 18. İNTERNET VERİ (v2.0) ═════"
input bool           InpUseInternet         = true;       // 🌐 İnternet Veri Kullan
input int            InpInternetCacheMin    = 10;         // ⏱️ Cache Süresi (dk)
input bool           InpUseNewsFilter       = true;       // 📰 Haber Filtresi Aktif
input int            InpNewsImpactLevel     = 2;          // 📊 Min. Haber Etkisi (1-3)

//====================================================================
// INPUT PARAMETRELERİ - 19. AI MODELİ (v2.0)
//====================================================================
input group "═════ 19. AI ENGINE (v2.0) ═════"
input bool           InpUseAIEngine         = false;      // 🤖 AI Modeli Kullan
input double         InpAIScoreWeight       = 30.0;       // 🎯 AI Skor Ağırlığı (%)
input double         InpAIMinConfidence     = 0.6;        // 📈 Min. AI Güven (0-1)

//====================================================================
// INPUT PARAMETRELERİ - 20. GELİŞMİŞ RİSK (v2.0)
//====================================================================
input group "═════ 20. GELİŞMİŞ RİSK (v2.0) ═════"
input double         InpKellyFraction       = 0.25;       // 📊 Kelly Kriteri Oranı
input int            InpMonteCarloSims      = 500;        // 🎲 Monte-Carlo Simülasyon
input double         InpMaxRiskPerTrade     = 2.0;        // 🛡️ Trade Başına Max Risk %
input bool           InpAdaptiveSLTP        = true;       // 🔄 Adaptif SL/TP

//====================================================================
// INPUT PARAMETRELERİ - 21. TELEGRAM ENT (v2.0)
//====================================================================
input group "═════ 21. TELEGRAM (v2.0) ═════"
input bool           InpUseTelegram         = false;      // 📱 Telegram Aktif
input string         InpTelegramToken       = "";         // 🔑 Bot Token (BotFather'dan)
input string         InpTelegramChatId      = "";         // 💬 Chat ID
input bool           InpTelegramOnTrade     = true;       // 📤 İşlem Bildirimi
input bool           InpTelegramOnNews      = true;       // 📰 Haber Bildirimi
input bool           InpTelegramDailyReport = true;       // 📊 Günlük Rapor

//====================================================================
// INPUT PARAMETRELERİ - 22. EK İNDİKATÖRLER (v2.0)
//====================================================================
input group "═════ 22. EK İNDİKATÖRLER (v2.0) ═════"
input bool           InpUseCCI              = true;       // 📈 CCI Kullan
input int            InpCCIPeriod           = 14;         // CCI Periyodu
input int            InpCCIOverbought       = 100;        // CCI Aşırı Alım
input int            InpCCIOversold         = -100;       // CCI Aşırı Satım
input bool           InpUseWPR              = true;       // 📈 Williams %R Kullan
input int            InpWPRPeriod           = 14;         // WPR Periyodu
input int            InpWPROverbought       = -20;        // WPR Aşırı Alım
input int            InpWPROversold         = -80;        // WPR Aşırı Satım
input bool           InpUseBBSqueeze        = true;       // 📊 BB Squeeze Kullan

//====================================================================
// INPUT PARAMETRELERİ - 23. KORUMA SİSTEMLERİ (v2.0)
//====================================================================
input group "═════ 23. KORUMA SİSTEMİ (v2.0) ═════"
input bool           InpAIGuard             = true;       // 🛡️ AI Guard (Aşırı Volatilite)
input double         InpAIGuardATRMult      = 3.0;        // ATR Çarpanı (Normal üzeri)
input bool           InpEquityCurveFilter   = true;       // 📉 Equity Curve Filter
input int            InpEquityCurvePeriod   = 10;         // Son X işlem analizi
input bool           InpFridayClose         = true;       // 📅 Cuma Kapanışı
input int            InpFridayCloseHour     = 20;         // Cuma Kapama Saati (UTC)
input bool           InpEmergencyClose      = true;       // 🚨 Acil Durum Kapama
input double         InpEmergencyDrawdown   = 15.0;       // Acil DD % (Tüm Pozisyon Kapat)


//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================
CTrade            g_trade;
CPositionInfo     g_posInfo;
COrderInfo        g_orderInfo;

//--- İndikatör Handle'ları
int               g_hMA1, g_hMA2, g_hMA3;
int               g_hMACD, g_hRSI, g_hADX, g_hATR;
int               g_hMTF_H4, g_hMTF_H1; // YENİ: MTF Handle'ları

//--- Kontrol
datetime          g_lastBarTime;
int               g_barsSinceTrade;
bool              g_isGridActive;

//--- Ceza/Düzeltme
datetime          g_penaltyEndTime = 0;
int               g_consecutiveLosses = 0;

//--- Volatilite
ENUM_VOLATILITY_MODE g_currentVolMode = VOL_NORMAL;
double            g_currentATR = 0;

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

//--- İstatistikler
int               g_totalTrades, g_winTrades, g_lossTrades;
double            g_totalProfit;
double            g_equityHigh, g_maxDrawdown;
double            g_refBalance;
datetime          g_lastTradeDate;
int               g_dailyTradeCount;
double            g_dailyProfit; // EKLENDİ - EKSİK TANIM (c SecurityManager için gerekli)

//--- Seviyeler
double            g_support, g_resistance;

//--- v2.0 İnternet Veri Cache
datetime          g_lastInternetUpdate = 0;
int               g_newsImpact = 0;           // 0: Yok, 1: Düşük, 2: Orta, 3: Yüksek
string            g_newsHeadline = "";
bool              g_newsBlockTrade = false;

//--- v2.0 AI Veri
double            g_aiConfidence = 0;
int               g_aiSignal = 0;             // 1: BUY, -1: SELL, 0: NÖTR

//--- v2.0 Kelly & Monte-Carlo
double            g_kellyOptimalLot = 0;
double            g_monteCarloRisk = 0;

//--- v2.0 Ek İndikatör Handle'ları
int               g_hCCI = INVALID_HANDLE;
int               g_hWPR = INVALID_HANDLE;
int               g_hBB = INVALID_HANDLE;      // Bollinger Bands

//--- v2.0 Equity Curve Filtering
double            g_tradeResults[];            // Son işlem sonuçları
int               g_tradeResultsCount = 0;
bool              g_equityCurveOK = true;      // Equity eğrisi pozitif mi?

//--- v2.0 AI Guard
bool              g_aiGuardBlocked = false;
double            g_normalATR = 0;             // Normal ATR (karşılaştırma için)

//--- v2.0 Cuma Kapanışı
bool              g_fridayCloseExecuted = false;

//====================================================================
// 🎯 MERKEZİ TREND TAKİP SİSTEMİ - TÜM MODÜLLER BU FLAG'E BAKAR
//====================================================================
int               g_regressionTrend = 0;       // +1=YUKARI, -1=AŞAĞI, 0=YATAY
int               g_allowedTradeDirection = 0; // +1=BUY, -1=SELL, 0=HER İKİSİ DE YOK
bool              g_trendConflict = false;     // Trend çatışması var mı?
bool              g_channelBreakout = false;   // Kanal taşması var mı?

//--- Zaman gecikmeli zıt pozisyon kapatma için
datetime          g_oppositeDetectedTime[];
ulong             g_oppositeTickets[];
int               g_oppositeCount = 0;


//====================================================================
// CLASS: CLogger - GELİŞMİŞ LOGLAMA SİSTEMİ (v2.0)
//====================================================================
class CLogger {
public:
   enum ENUM_LOG_LEVEL { LOG_DEBUG, LOG_INFO, LOG_WARNING, LOG_ERROR };
   
   static void Debug(string msg) { Log(LOG_DEBUG, "🔍", msg); }
   static void Info(string msg) { Log(LOG_INFO, "ℹ️", msg); }
   static void Warning(string msg) { Log(LOG_WARNING, "⚠️", msg); }
   static void Error(string msg) { Log(LOG_ERROR, "❌", msg); }
   static void Success(string msg) { Log(LOG_INFO, "✅", msg); }
   static void Trade(string msg) { Log(LOG_INFO, "💰", msg); }
   static void Signal(string msg) { Log(LOG_INFO, "📊", msg); }
   static void Internet(string msg) { Log(LOG_INFO, "🌐", msg); }
   static void AI(string msg) { Log(LOG_INFO, "🤖", msg); }
   
private:
   static void Log(ENUM_LOG_LEVEL level, string icon, string msg) {
      if(!InpShowDebugLog && level == LOG_DEBUG) return;
      Print(icon, " MilyonerKod v2: ", msg);
   }
};

//====================================================================
// CLASS: CInternetData - WEB VERİ ÇEKME (v2.0)
//====================================================================
class CInternetData {
public:
   static bool UpdateIfNeeded() {
      if(!InpUseInternet) return false;
      
      // Cache kontrolü
      if(TimeCurrent() - g_lastInternetUpdate < InpInternetCacheMin * 60) return false;
      
      g_lastInternetUpdate = TimeCurrent();
      
      // Ekonomik takvim kontrolü (simüle)
      // Not: Gerçek implementasyon için WebRequest kullanılacak
      // MetaTrader 5 için: Araçlar -> Seçenekler -> Uzman Danışmanlar -> WebRequest izinleri
      
      // Basit haber simülasyonu (gerçek API yerine)
      MqlDateTime dt;
      TimeCurrent(dt);
      
      // Haberlerin yoğun olduğu saatler (08:30, 13:30, 15:00 UTC)
      if((dt.hour == 8 && dt.min >= 25 && dt.min <= 35) ||
         (dt.hour == 13 && dt.min >= 25 && dt.min <= 35) ||
         (dt.hour == 15 && dt.min >= 0 && dt.min <= 10)) {
         g_newsImpact = 3; // Yüksek etki
         g_newsHeadline = "⚠️ Yüksek Etkili Haber Yaklaşıyor!";
         g_newsBlockTrade = (InpNewsImpactLevel <= 3);
      } else if((dt.hour == 10 || dt.hour == 14) && dt.min <= 15) {
         g_newsImpact = 2; // Orta etki
         g_newsHeadline = "📰 Orta Etkili Haber Dönemi";
         g_newsBlockTrade = (InpNewsImpactLevel <= 2);
      } else {
         g_newsImpact = 0;
         g_newsHeadline = "";
         g_newsBlockTrade = false;
      }
      
      if(g_newsImpact > 0) {
         CLogger::Internet("Haber Etkisi: " + IntegerToString(g_newsImpact) + "/3 | " + g_newsHeadline);
      }
      
      return true;
   }
   
   static bool IsTradingBlocked() {
      return (InpUseNewsFilter && g_newsBlockTrade);
   }
   
   static int GetNewsImpact() { return g_newsImpact; }
   static string GetNewsHeadline() { return g_newsHeadline; }
};

//====================================================================
// CLASS: CTelegram - TELEGRAM BOT ENTEGRASYONi (v2.0)
//====================================================================
class CTelegram {
public:
   static bool Send(string message) {
      if(!InpUseTelegram || InpTelegramToken == "" || InpTelegramChatId == "") return false;
      
      string url = "https://api.telegram.org/bot" + InpTelegramToken + "/sendMessage";
      string postData = "chat_id=" + InpTelegramChatId + "&text=" + message + "&parse_mode=HTML";
      
      // WebRequest için çağrı (MT5 WebRequest izni gerekli)
      char data[], result[];
      string headers = "Content-Type: application/x-www-form-urlencoded\r\n";
      
      StringToCharArray(postData, data);
      ArrayResize(data, ArraySize(data) - 1); // NULL karakter kaldır
      
      int timeout = 5000;
      string resultHeaders;
      int res = WebRequest("POST", url, headers, timeout, data, result, resultHeaders);
      
      if(res == 200) {
         CLogger::Debug("📱 Telegram mesajı gönderildi.");
         return true;
      } else {
         CLogger::Warning("📱 Telegram hatası: " + IntegerToString(res));
         return false;
      }
   }
   
   static void OnTradeOpen(string type, double lot, double price) {
      if(!InpTelegramOnTrade) return;
      string msg = "🔔 <b>MİLYONER KOD EA</b>\n";
      msg += "📊 " + type + " İşlem Açıldı\n";
      msg += "📈 Lot: " + DoubleToString(lot, 2) + "\n";
      msg += "💰 Fiyat: " + DoubleToString(price, 5) + "\n";
      msg += "⏰ " + TimeToString(TimeCurrent());
      Send(msg);
   }
   
   static void OnTradeClose(string type, double profit) {
      if(!InpTelegramOnTrade) return;
      string emoji = (profit >= 0) ? "✅" : "❌";
      string msg = emoji + " <b>İşlem Kapandı</b>\n";
      msg += "📊 " + type + "\n";
      msg += "💰 Kar/Zarar: $" + DoubleToString(profit, 2) + "\n";
      msg += "⏰ " + TimeToString(TimeCurrent());
      Send(msg);
   }
   
   static void DailyReport() {
      if(!InpTelegramDailyReport) return;
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double profit = g_dailyProfit;
      
      string msg = "📊 <b>GÜNLÜK RAPOR</b>\n";
      msg += "━━━━━━━━━━━━━━\n";
      msg += "💰 Bakiye: $" + DoubleToString(balance, 2) + "\n";
      msg += "📈 Equity: $" + DoubleToString(equity, 2) + "\n";
      msg += "📉 Günlük Kar: $" + DoubleToString(profit, 2) + "\n";
      msg += "🔢 İşlem Sayısı: " + IntegerToString(g_dailyTradeCount) + "\n";
      msg += "⏰ " + TimeToString(TimeCurrent());
      Send(msg);
   }
   
   static void OnNewsAlert(string news, int impact) {
      if(!InpTelegramOnNews) return;
      string emoji = (impact >= 3) ? "🔴" : (impact >= 2) ? "🟠" : "🟢";
      string msg = emoji + " <b>HABER UYARISI</b>\n";
      msg += "📰 " + news + "\n";
      msg += "📊 Etki: " + IntegerToString(impact) + "/3";
      Send(msg);
   }
};

//====================================================================
// CLASS: CAIGuard - AŞIRI VOLATİLİTE KORUMASI (v2.0)
//====================================================================
class CAIGuard {
public:
   static void Init() {
      // Normal ATR'yi hesapla (ilk 100 bar ortalaması)
      double atrSum = 0;
      int count = 0;
      for(int i = 0; i < 100; i++) {
         double atr[];
         ArraySetAsSeries(atr, true);
         if(CopyBuffer(g_hATR, 0, i, 1, atr) > 0) {
            atrSum += atr[0];
            count++;
         }
      }
      if(count > 0) g_normalATR = atrSum / count;
   }
   
   static bool IsBlocked() {
      if(!InpAIGuard) return false;
      
      double atr[];
      ArraySetAsSeries(atr, true);
      if(CopyBuffer(g_hATR, 0, 0, 1, atr) <= 0) return false;
      
      // Mevcut ATR normal ATR'nin X katı üzerindeyse bloke et
      if(g_normalATR > 0 && atr[0] > g_normalATR * InpAIGuardATRMult) {
         if(!g_aiGuardBlocked) {
            CLogger::Warning("🛡️ AI Guard: Aşırı volatilite tespit edildi! ATR: " + DoubleToString(atr[0], 5));
            CTelegram::Send("🛡️ <b>AI GUARD AKTİF</b>\nAşırı volatilite nedeniyle işlemler durduruldu.");
         }
         g_aiGuardBlocked = true;
         return true;
      }
      
      if(g_aiGuardBlocked) {
         CLogger::Info("🛡️ AI Guard: Volatilite normale döndü.");
      }
      g_aiGuardBlocked = false;
      return false;
   }
};

//====================================================================
// CLASS: CEquityCurveFilter - EQUİTY EĞRİSİ FİLTRESİ (v2.0)
//====================================================================
class CEquityCurveFilter {
public:
   static void RecordTrade(double profit) {
      ArrayResize(g_tradeResults, g_tradeResultsCount + 1);
      g_tradeResults[g_tradeResultsCount] = profit;
      g_tradeResultsCount++;
      
      // Son X işlemi analiz et
      UpdateCurveStatus();
   }
   
   static void UpdateCurveStatus() {
      if(!InpEquityCurveFilter || g_tradeResultsCount < InpEquityCurvePeriod) {
         g_equityCurveOK = true;
         return;
      }
      
      // Son X işlemin toplamını hesapla
      double sum = 0;
      int start = g_tradeResultsCount - InpEquityCurvePeriod;
      for(int i = start; i < g_tradeResultsCount; i++) {
         sum += g_tradeResults[i];
      }
      
      // Eğer son X işlem negatifse, eğri kötü
      g_equityCurveOK = (sum >= 0);
      
      if(!g_equityCurveOK) {
         CLogger::Warning("📉 Equity Curve Filter: Son " + IntegerToString(InpEquityCurvePeriod) + " işlem negatif. Mola veriliyor.");
      }
   }
   
   static bool IsOK() {
      if(!InpEquityCurveFilter) return true;
      return g_equityCurveOK;
   }
};

//====================================================================
// CLASS: CFridayClose - CUMA KAPANIŞI (v2.0)
//====================================================================
class CFridayClose {
public:
   static void Check() {
      if(!InpFridayClose) return;
      
      MqlDateTime dt;
      TimeCurrent(dt);
      
      // Cuma günü mü?
      if(dt.day_of_week == 5 && dt.hour >= InpFridayCloseHour) {
         if(!g_fridayCloseExecuted) {
            CloseAllPositions("Cuma Kapanışı");
            g_fridayCloseExecuted = true;
            CLogger::Info("📅 Cuma Kapanışı: Tüm pozisyonlar kapatıldı.");
            CTelegram::Send("📅 <b>CUMA KAPANIŞI</b>\nHafta sonu riski nedeniyle tüm pozisyonlar kapatıldı.");
         }
      }
      
      // Pazartesi günü reset
      if(dt.day_of_week == 1) {
         g_fridayCloseExecuted = false;
      }
   }
   
   static void CloseAllPositions(string reason) {
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         if(g_posInfo.SelectByIndex(i)) {
            if(g_posInfo.Magic() == InpMagicNumber) {
               g_trade.PositionClose(g_posInfo.Ticket());
            }
         }
      }
   }
};

//====================================================================
// CLASS: CEmergencyManager - ACİL DURUM YÖNETİCİSİ (v2.0)
//====================================================================
class CEmergencyManager {
public:
   static bool Check() {
      if(!InpEmergencyClose) return false;
      
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double balance = g_refBalance; // Başlangıç bakiyesi
      
      if(balance <= 0) return false;
      
      double dd = ((balance - equity) / balance) * 100.0;
      
      if(dd >= InpEmergencyDrawdown) {
         CLogger::Error("🚨 ACİL DURUM: %" + DoubleToString(dd, 1) + " drawdown! Tüm pozisyonlar kapatılıyor!");
         CTelegram::Send("🚨 <b>ACİL DURUM!</b>\n%" + DoubleToString(dd, 1) + " drawdown!\nTüm pozisyonlar kapatıldı!");
         
         CFridayClose::CloseAllPositions("Acil Durum");
         return true;
      }
      
      return false;
   }
};

//====================================================================
// CLASS: CEnhancedDDManager - ÇOK AŞAMALI DRAWDOWN YÖNETİMİ (v2.0)
// DD Seviyeleri: %10 → lot azalt, %20 → yeni işlem durdur, %30 → tüm kapat
//====================================================================
class CEnhancedDDManager {
public:
   static int GetDDAction() {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double balance = g_refBalance;
      
      if(balance <= 0) return 0;
      
      double dd = ((balance - equity) / balance) * 100.0;
      
      if(dd >= 30.0) {
         CLogger::Error("🚨 DD SEVİYE 3: %" + DoubleToString(dd, 1) + " - TÜM POZİSYONLAR KAPATILIYOR!");
         CTelegram::Send("🚨 <b>KRİTİK DD!</b>\n%" + DoubleToString(dd, 1) + " drawdown!\nTüm pozisyonlar kapatılıyor!");
         CFridayClose::CloseAllPositions("Kritik DD");
         return 3;
      }
      else if(dd >= 20.0) {
         CLogger::Warning("⚠️ DD SEVİYE 2: %" + DoubleToString(dd, 1) + " - YENİ İŞLEM DURDURULDU");
         return 2;
      }
      else if(dd >= 10.0) {
         CLogger::Warning("📉 DD SEVİYE 1: %" + DoubleToString(dd, 1) + " - LOT AZALTILDI");
         return 1;
      }
      
      return 0;
   }
   
   static double GetLotMultiplier() {
      int action = GetDDAction();
      if(action == 1) return 0.5;  // %50 lot
      if(action >= 2) return 0.0;  // İşlem yok
      return 1.0;
   }
};

//====================================================================
// CLASS: CDynamicGrid - ATR BAZLI DİNAMİK GRİD ARALIĞI (v2.0)
//====================================================================
class CDynamicGrid {
public:
   static double GetDynamicSpacing(double atr) {
      if(atr <= 0) return InpGrid_StepPips;
      
      // ATR bazlı grid aralığı (1.5x ATR)
      double dynamicPips = PointsToPip(atr * 1.5);
      
      // Min/Max sınırları
      dynamicPips = MathMax(15.0, MathMin(dynamicPips, 100.0));
      
      return dynamicPips;
   }
};

//====================================================================
// CLASS: COppositePositionManager - BUY/SELL ÇAKIŞMA YÖNETİMİ (v2.0)
//====================================================================
class COppositePositionManager {
public:
   static bool HasOppositePositions() {
      bool hasBuy = false, hasSell = false;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         
         long posType = PositionGetInteger(POSITION_TYPE);
         if(posType == POSITION_TYPE_BUY) hasBuy = true;
         if(posType == POSITION_TYPE_SELL) hasSell = true;
      }
      
      return (hasBuy && hasSell);
   }
   
   static void ManageOppositePositions() {
      if(!HasOppositePositions()) return;
      
      // Daha az kârlı olanı kapat
      double buyProfit = 0, sellProfit = 0;
      ulong buyTicket = 0, sellTicket = 0;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         
         long posType = PositionGetInteger(POSITION_TYPE);
         double profit = PositionGetDouble(POSITION_PROFIT);
         
         if(posType == POSITION_TYPE_BUY) {
            buyProfit += profit;
            buyTicket = ticket;
         } else {
            sellProfit += profit;
            sellTicket = ticket;
         }
      }
      
      // Daha az kârlı olanı kapat
      if(buyProfit < sellProfit && buyTicket > 0) {
         g_trade.PositionClose(buyTicket);
         CLogger::Info("🔄 Ters pozisyon kapatıldı: BUY #" + IntegerToString(buyTicket));
      }
      else if(sellTicket > 0) {
         g_trade.PositionClose(sellTicket);
         CLogger::Info("🔄 Ters pozisyon kapatıldı: SELL #" + IntegerToString(sellTicket));
      }
   }
};

//====================================================================
// 🚨 ZAMAN GECİKMELİ ZIT POZİSYON KAPATMA (Ultimate Harmony'den)
// Regresyon yukarıysa SELL'leri, aşağıysa BUY'ları InpOppositeCloseDelay saniye sonra kapat
//====================================================================
void CloseTrendOppositePositionsWithDelay() {
   if(!InpAutoCloseOpposite) return;
   if(g_allowedTradeDirection == 0) return;  // Trend belirsiz, bekle
   
   datetime now = TimeCurrent();
   
   // Tüm pozisyonları tara
   for(int i = PositionsTotal() - 1; i >= 0; i--) {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
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
         for(int j = 0; j < g_oppositeCount; j++) {
            if(g_oppositeTickets[j] == ticket) {
               idx = j;
               break;
            }
         }
         
         if(idx == -1) {
            // İlk tespit - kaydet
            g_oppositeCount++;
            ArrayResize(g_oppositeTickets, g_oppositeCount);
            ArrayResize(g_oppositeDetectedTime, g_oppositeCount);
            g_oppositeTickets[g_oppositeCount - 1] = ticket;
            g_oppositeDetectedTime[g_oppositeCount - 1] = now;
            
            CLogger::Warning("⚠️ TREND ZITI TESPİT: #" + IntegerToString(ticket) + " | " + reason);
            CLogger::Warning("⏱️ " + IntegerToString(InpOppositeCloseDelay) + " saniye sonra kapatılacak...");
         }
         else {
            // Gecikme doldu mu?
            if(now - g_oppositeDetectedTime[idx] >= InpOppositeCloseDelay) {
               double profit = PositionGetDouble(POSITION_PROFIT);
               
               if(g_trade.PositionClose(ticket)) {
                  CLogger::Info("🚨 TREND ZITI KAPATILDI: #" + IntegerToString(ticket) + " | Kar: $" + DoubleToString(profit, 2));
                  CTelegram::Send("🚨 <b>TREND ZITI KAPATILDI</b>\n#" + IntegerToString(ticket) + "\n" + reason + "\nKar: $" + DoubleToString(profit, 2));
                  
                  // Listeden kaldır
                  for(int k = idx; k < g_oppositeCount - 1; k++) {
                     g_oppositeTickets[k] = g_oppositeTickets[k + 1];
                     g_oppositeDetectedTime[k] = g_oppositeDetectedTime[k + 1];
                  }
                  g_oppositeCount--;
               }
            }
         }
      }
   }
   
   // Artık zıt olmayan pozisyonları listeden temizle
   for(int i = g_oppositeCount - 1; i >= 0; i--) {
      bool stillActive = false;
      for(int j = PositionsTotal() - 1; j >= 0; j--) {
         if(PositionGetTicket(j) == g_oppositeTickets[i]) {
            stillActive = true;
            break;
         }
      }
      
      if(!stillActive) {
         for(int k = i; k < g_oppositeCount - 1; k++) {
            g_oppositeTickets[k] = g_oppositeTickets[k + 1];
            g_oppositeDetectedTime[k] = g_oppositeDetectedTime[k + 1];
         }
         g_oppositeCount--;
      }
   }
}



//====================================================================
// CLASS: CMomentumCatcher - VOLATİLİTE SPİKE YAKALAMA (v2.0)
//====================================================================
class CMomentumCatcher {
public:
   static bool DetectVolatilitySpike() {
      double atr[];
      ArraySetAsSeries(atr, true);
      if(CopyBuffer(g_hATR, 0, 0, 20, atr) < 20) return false;
      
      double currentATR = atr[0];
      double avgATR = 0;
      for(int i = 1; i < 20; i++) avgATR += atr[i];
      avgATR /= 19;
      
      // ATR 2x ortalamanın üzerindeyse spike var
      return (currentATR > avgATR * 2.0);
   }
   
   static void CatchMomentum() {
      if(!DetectVolatilitySpike()) return;
      
      // Son mumun yönünü kontrol et
      double open = iOpen(_Symbol, InpTimeframe, 1);
      double close = iClose(_Symbol, InpTimeframe, 1);
      
      int direction = (close > open) ? 1 : -1;
      
      CLogger::Info("🚀 Momentum Spike tespit edildi! Yön: " + (direction == 1 ? "BUY" : "SELL"));
      CTelegram::Send("🚀 <b>MOMENTUM SPİKE!</b>\nYön: " + (direction == 1 ? "BUY" : "SELL"));
   }
};

//====================================================================
// CLASS: CStochasticAnalyzer - STOCHASTIC SKORLAMASI (v2.0)
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
         if(k[0] < 20) score = 90;
         else if(k[0] < 40) score = 70;
         if(crossUp && k[0] < 50) score += 15;
      }
      else if(direction == -1) {
         if(k[0] > 80) score = 90;
         else if(k[0] > 60) score = 70;
         if(crossDown && k[0] > 50) score += 15;
      }
      
      return MathMin(100, score);
   }
};
int CStochasticAnalyzer::m_handle = INVALID_HANDLE;

//====================================================================
// CLASS: CBollingerAnalyzer - BOLLİNGER BANDS ANALİZİ (v2.0)
//====================================================================
class CBollingerAnalyzer {
public:
   static double GetScore(int direction) {
      if(g_hBB == INVALID_HANDLE) return 50;
      
      double mid[], upper[], lower[];
      ArraySetAsSeries(mid, true);
      ArraySetAsSeries(upper, true);
      ArraySetAsSeries(lower, true);
      
      if(CopyBuffer(g_hBB, 0, 0, 1, mid) < 1) return 50;
      if(CopyBuffer(g_hBB, 1, 0, 1, upper) < 1) return 50;
      if(CopyBuffer(g_hBB, 2, 0, 1, lower) < 1) return 50;
      
      double price = iClose(_Symbol, InpTimeframe, 0);
      double bandWidth = upper[0] - lower[0];
      double pricePosition = (bandWidth > 0) ? (price - lower[0]) / bandWidth * 100 : 50;
      
      double score = 50;
      
      if(direction == 1) {
         if(price <= lower[0]) score = 95;
         else if(pricePosition < 20) score = 80;
         else if(pricePosition > 80) score = 30;
      }
      else if(direction == -1) {
         if(price >= upper[0]) score = 95;
         else if(pricePosition > 80) score = 80;
         else if(pricePosition < 20) score = 30;
      }
      
      return score;
   }
   
   static bool IsSqueeze() {
      if(g_hBB == INVALID_HANDLE) return false;
      
      double upper[], lower[];
      ArraySetAsSeries(upper, true);
      ArraySetAsSeries(lower, true);
      
      if(CopyBuffer(g_hBB, 1, 0, 20, upper) < 20) return false;
      if(CopyBuffer(g_hBB, 2, 0, 20, lower) < 20) return false;
      
      double currentWidth = upper[0] - lower[0];
      double avgWidth = 0;
      for(int i = 0; i < 20; i++) avgWidth += (upper[i] - lower[i]);
      avgWidth /= 20;
      
      return (currentWidth < avgWidth * 0.5);
   }
};

//====================================================================
// CLASS: CVolumeAnalyzer - HACİM ANALİZİ (v2.0)
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
      double volRatio = GetVolumeRatio();
      
      // Body/Range oranını burada hesapla (CCandleAnalyzer henüz tanımlı değil)
      double open = iOpen(_Symbol, InpTimeframe, 0);
      double close = iClose(_Symbol, InpTimeframe, 0);
      double high = iHigh(_Symbol, InpTimeframe, 0);
      double low = iLow(_Symbol, InpTimeframe, 0);
      double body = MathAbs(close - open);
      double range = high - low;
      double bodyRatio = (range > 0) ? body / range : 0;
      
      return (volRatio > 2.0 && bodyRatio > 0.7);
   }

   
   static int GetVolumeScore(int direction) {
      double volRatio = GetVolumeRatio();
      int score = 50;
      
      bool isBullish = iClose(_Symbol, InpTimeframe, 0) > iOpen(_Symbol, InpTimeframe, 0);
      
      if(direction == 1 && isBullish && volRatio > 1.5) score = 85;
      else if(direction == -1 && !isBullish && volRatio > 1.5) score = 85;
      
      return score;
   }
};

//====================================================================
// CLASS: CTrendStrength - TREND GÜÇ ANALİZİ (v2.0)
//====================================================================
class CTrendStrength {
public:
   static double CalculateADMR() {
      double adx[];
      ArraySetAsSeries(adx, true);
      
      if(CopyBuffer(g_hADX, 0, 0, 14, adx) < 14) return 0;
      
      double sum = 0;
      for(int i = 0; i < 14; i++) sum += adx[i];
      
      return sum / 14;
   }
   
   static string GetTrendStrengthLabel() {
      double admr = CalculateADMR();
      
      if(admr >= 40) return "ÇOK GÜÇLÜ";
      if(admr >= 30) return "GÜÇLÜ";
      if(admr >= 25) return "ORTA";
      if(admr >= 20) return "ZAYIF";
      return "TREND YOK";
   }
   
   static int GetTrendScore() {
      double admr = CalculateADMR();
      int score = 50;
      
      if(admr >= 30) score += 25;
      else if(admr >= 25) score += 15;
      else if(admr < 20) score -= 20;
      
      return MathMax(0, MathMin(100, score));
   }
};

//====================================================================
// CLASS: CChandelierTrail - CHANDELİER EXİT TRAİLİNG (v2.0)
//====================================================================
class CChandelierTrail {
public:
   static double Calculate(int posType, int period = 22, double multiplier = 3.0) {
      double atr[];
      ArraySetAsSeries(atr, true);
      
      if(CopyBuffer(g_hATR, 0, 0, 1, atr) < 1) return 0;
      
      double chandelier = atr[0] * multiplier;
      
      if(posType == POSITION_TYPE_BUY) {
         double highestHigh = 0;
         for(int i = 0; i < period; i++) {
            double h = iHigh(_Symbol, InpTimeframe, i);
            if(h > highestHigh) highestHigh = h;
         }
         return highestHigh - chandelier;
      }
      else {
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
// CLASS: CPositionScaling - POZİSYON ÖLÇEKLENDİRME (v2.0)
//====================================================================
class CPositionScaling {
public:
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
      
      if(profitDist < tpDist * (triggerPercent / 100.0)) return false;
      
      double scaleLot = NormalizeLot(mainLot * scalePercent / 100.0);
      
      if(mainType == POSITION_TYPE_BUY) {
         if(g_trade.Buy(scaleLot, _Symbol, 0, mainSL, mainTP, "ScaleIn")) {
            CLogger::Info("📈 SCALE-IN BUY | Lot: " + DoubleToString(scaleLot, 2));
            return true;
         }
      }
      else {
         if(g_trade.Sell(scaleLot, _Symbol, 0, mainSL, mainTP, "ScaleIn")) {
            CLogger::Info("📉 SCALE-IN SELL | Lot: " + DoubleToString(scaleLot, 2));
            return true;
         }
      }
      
      return false;
   }
   
   static bool ScaleOut(ulong ticket, double closePercent = 25.0) {
      if(!PositionSelectByTicket(ticket)) return false;
      
      double volume = PositionGetDouble(POSITION_VOLUME);
      double minVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      
      double closeVol = MathFloor((volume * closePercent / 100.0) / lotStep) * lotStep;
      if(closeVol < minVol) return false;
      
      if(g_trade.PositionClosePartial(ticket, closeVol)) {
         CLogger::Info("💰 SCALE-OUT | Kapatılan: " + DoubleToString(closeVol, 2) + " lot");
         return true;
      }
      
      return false;
   }
};

//====================================================================
// CLASS: CCorrelationFilter - ÇİFT KORELASYON FİLTRESİ (v2.0)
//====================================================================
class CCorrelationFilter {
public:
   static double CalculateCorrelation(string symbol1, string symbol2, int period = 50) {
      double prices1[], prices2[];
      ArrayResize(prices1, period);
      ArrayResize(prices2, period);
      
      for(int i = 0; i < period; i++) {
         prices1[i] = iClose(symbol1, InpTimeframe, i);
         prices2[i] = iClose(symbol2, InpTimeframe, i);
      }
      
      double mean1 = 0, mean2 = 0;
      for(int i = 0; i < period; i++) {
         mean1 += prices1[i];
         mean2 += prices2[i];
      }
      mean1 /= period;
      mean2 /= period;
      
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
      
      return sumXY / denom;
   }
   
   static bool HasHighCorrelation(string otherSymbol, double threshold = 0.7) {
      double corr = CalculateCorrelation(_Symbol, otherSymbol);
      return (MathAbs(corr) >= threshold);
   }
};

//====================================================================
// CLASS: CTimeBasedExit - ZAMAN BAZLI ÇIKIŞ (v2.0)
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
            
            if(g_trade.PositionClose(ticket)) {
               CLogger::Info("⏰ ZAMAN AŞIMI: " + IntegerToString(hoursOpen) + " saat | Kar: $" + DoubleToString(profit, 2));
               CTelegram::OnTradeClose("TIMEOUT", profit);
            }
         }
      }
   }
};

//====================================================================
// CLASS: CHTMLReportGenerator - HTML RAPOR OLUŞTURUCU (v2.0)
//====================================================================
class CHTMLReportGenerator {
public:
   static void GenerateReport() {
      string filename = "Milyoner_Report_" + _Symbol + ".html";
      int handle = FileOpen(filename, FILE_WRITE | FILE_TXT | FILE_COMMON);
      
      if(handle == INVALID_HANDLE) {
         CLogger::Error("❌ Rapor dosyası açılamadı");
         return;
      }
      
      double winRate = (g_totalTrades > 0) ? (double)g_winTrades / g_totalTrades * 100 : 0;
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      
      string html = "<!DOCTYPE html>\n<html><head><meta charset='UTF-8'>\n";
      html += "<title>Milyoner Kod EA - Rapor</title>\n";
      html += "<style>body{font-family:Arial;background:#1a1a2e;color:#eee;padding:20px;}";
      html += ".card{background:#16213e;padding:20px;border-radius:10px;margin:15px 0;}";
      html += ".green{color:#0f8}.red{color:#f44}</style></head><body>\n";
      html += "<h1 style='color:#0df;text-align:center'>🌟 MİLYONER KOD EA v2.0</h1>\n";
      html += "<div class='card'><h2>📊 Performans</h2>";
      html += "<p>Toplam İşlem: " + IntegerToString(g_totalTrades) + "</p>";
      html += "<p>Kazanan: <span class='green'>" + IntegerToString(g_winTrades) + "</span></p>";
      html += "<p>Kaybeden: <span class='red'>" + IntegerToString(g_lossTrades) + "</span></p>";
      html += "<p>Win Rate: " + DoubleToString(winRate, 1) + "%</p>";
      html += "<p>Max DD: " + DoubleToString(g_maxDrawdown, 2) + "%</p></div>";
      html += "<div class='card'><h2>💰 Hesap</h2>";
      html += "<p>Bakiye: $" + DoubleToString(balance, 2) + "</p>";
      html += "<p>Equity: $" + DoubleToString(equity, 2) + "</p></div>";
      html += "<p style='text-align:center;color:#666'>Oluşturulma: " + TimeToString(TimeCurrent()) + "</p>";
      html += "</body></html>";
      
      FileWriteString(handle, html);
      FileClose(handle);
      
      CLogger::Info("📄 HTML Rapor oluşturuldu: " + filename);
   }
};

//====================================================================
// CLASS: CStatePersistence - DURUM SAKLAMA (v2.0)
//====================================================================
class CStatePersistence {
private:
   static string m_filename;
   
public:
   static void Init() {
      m_filename = "Milyoner_State_" + _Symbol + ".dat";
   }
   
   static bool SaveState() {
      int handle = FileOpen(m_filename, FILE_WRITE | FILE_BIN | FILE_COMMON);
      if(handle == INVALID_HANDLE) return false;
      
      FileWriteInteger(handle, g_totalTrades);
      FileWriteInteger(handle, g_winTrades);
      FileWriteInteger(handle, g_lossTrades);
      FileWriteDouble(handle, g_totalProfit);
      FileWriteDouble(handle, g_maxDrawdown);
      FileWriteDouble(handle, g_equityHigh);
      FileWriteDouble(handle, g_refBalance);
      FileWriteInteger(handle, g_dailyTradeCount);
      FileWriteDouble(handle, g_dailyProfit);
      
      FileClose(handle);
      CLogger::Debug("💾 Durum kaydedildi");
      return true;
   }
   
   static bool LoadState() {
      if(!FileIsExist(m_filename, FILE_COMMON)) return false;
      
      int handle = FileOpen(m_filename, FILE_READ | FILE_BIN | FILE_COMMON);
      if(handle == INVALID_HANDLE) return false;
      
      g_totalTrades = FileReadInteger(handle);
      g_winTrades = FileReadInteger(handle);
      g_lossTrades = FileReadInteger(handle);
      g_totalProfit = FileReadDouble(handle);
      g_maxDrawdown = FileReadDouble(handle);
      g_equityHigh = FileReadDouble(handle);
      g_refBalance = FileReadDouble(handle);
      g_dailyTradeCount = FileReadInteger(handle);
      g_dailyProfit = FileReadDouble(handle);
      
      FileClose(handle);
      CLogger::Info("📂 Durum yüklendi");
      return true;
   }
};
string CStatePersistence::m_filename = "";

//====================================================================
// CLASS: CAlertManager - BİLDİRİM SİSTEMİ (v2.0)
//====================================================================
class CAlertManager {
public:
   static void SendSignalAlert(int direction, int score) {
      string symbol = _Symbol;
      string dirStr = (direction == 1) ? "BUY" : "SELL";
      string msg = StringFormat("MİLYONER EA: %s sinyali | %s | Skor: %d/100", dirStr, symbol, score);
      
      Alert(msg);
      CTelegram::Send("🔔 <b>" + dirStr + " SİNYALİ</b>\n" + symbol + "\nSkor: " + IntegerToString(score) + "/100");
   }
   
   static void SendTradeAlert(string action, double profit) {
      string emoji = (profit >= 0) ? "🏆" : "❌";
      CLogger::Info(emoji + " " + action + " | Kar: $" + DoubleToString(profit, 2));
   }
};

//====================================================================
// CLASS: CSmartTradeAssistant - AKILLI ASISTAN (v2.0)
//====================================================================
class CSmartTradeAssistant {
public:
   static void ExecuteSmartAssistant() {
      // Trend yönünde pending emir kontrolü
      int trendDir = CRegressionChannel::GetTrendDirection();
      if(trendDir == 0) return;
      
      // Mevcut pending emir var mı?
      int pendingCount = 0;
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetInteger(ORDER_MAGIC) == InpMagicNumber && 
            OrderGetString(ORDER_SYMBOL) == _Symbol) pendingCount++;
      }
      
      if(pendingCount > 0) return;
      
      // Akıllı pending emir önerisi logla
      string direction = (trendDir == 1) ? "BUY LIMIT" : "SELL LIMIT";
      CLogger::Debug("🧠 Akıllı Asistan: " + direction + " emir öneriliyor");
   }
   
   static void QuickTickAnalysis() {
      // Hızlı tick analizi - anomali tespiti
      static double lastBid = 0;
      double currentBid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      if(lastBid > 0) {
         double change = MathAbs(currentBid - lastBid);
         double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         
         // 50 pip'ten fazla ani hareket
         if(change > point * 500) {
            CLogger::Warning("⚡ Ani fiyat hareketi: " + DoubleToString(change / point, 0) + " point");
         }
      }
      
      lastBid = currentBid;
   }
};

//====================================================================
// CLASS: CBacktestOptimizer - BACKTEST OPTİMİZASYONU (v2.0)
//====================================================================
class CBacktestOptimizer {
public:
   static double CalculateSharpeRatio() {
      if(g_totalTrades < 10) return 0;
      
      double avgReturn = g_totalProfit / g_totalTrades;
      double stdDev = MathSqrt(g_maxDrawdown);
      
      if(stdDev == 0) return 0;
      return avgReturn / stdDev;
   }
   
   static double CalculateProfitFactor() {
      if(g_lossTrades == 0) return 999;
      return (double)g_winTrades / g_lossTrades;
   }
   
   static string GetOptimizationScore() {
      double winRate = (g_totalTrades > 0) ? (double)g_winTrades / g_totalTrades * 100 : 0;
      double pf = CalculateProfitFactor();
      double sharpe = CalculateSharpeRatio();
      
      double score = winRate * 0.4 + (pf * 10) * 0.3 + (sharpe * 20) * 0.3;
      
      string grade = "F";
      if(score >= 80) grade = "A+";
      else if(score >= 70) grade = "A";
      else if(score >= 60) grade = "B";
      else if(score >= 50) grade = "C";
      else if(score >= 40) grade = "D";
      
      return StringFormat("Skor: %.1f | Not: %s | PF: %.2f | Sharpe: %.2f", score, grade, pf, sharpe);
   }
};

//====================================================================
// CLASS: CRiskParity - RİSK PARİTE YÖNETİMİ (v2.0)
//====================================================================
class CRiskParity {
public:
   static double CalculateOptimalPosition(double targetRisk = 1.0) {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * targetRisk / 100.0;
      
      double atr[];
      ArraySetAsSeries(atr, true);
      if(CopyBuffer(g_hATR, 0, 0, 1, atr) < 1) return InpMinLot;
      
      double slPips = PointsToPip(atr[0] * InpATR_SL_Multi);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      
      if(tickValue <= 0) tickValue = 10.0;
      if(slPips <= 0) return InpMinLot;
      
      double pipValue = tickValue * 10.0;
      return NormalizeLot(riskAmount / (slPips * pipValue));
   }
   
   static double AdjustForVolatility() {
      double atr[];
      ArraySetAsSeries(atr, true);
      if(CopyBuffer(g_hATR, 0, 0, 20, atr) < 20) return 1.0;
      
      double currentATR = atr[0];
      double avgATR = 0;
      for(int i = 0; i < 20; i++) avgATR += atr[i];
      avgATR /= 20;
      
      if(avgATR == 0) return 1.0;
      
      double volRatio = currentATR / avgATR;
      
      if(volRatio > 1.5) return 0.7;
      if(volRatio > 1.2) return 0.85;
      if(volRatio < 0.7) return 1.2;
      if(volRatio < 0.5) return 1.3;
      
      return 1.0;
   }
};


// CLASS: CRegressionChannel - MERKEZİ TREND TAKİP SİSTEMİ (v1.07)
// NOT: CDashboard'dan önce tanımlanmalı (forward reference için)
//====================================================================
class CRegressionChannel {
private:
   static int m_trendDirection; // 1: Yukarı, -1: Aşağı, 0: Yatay
   static double m_slope;
   static double m_intercept;
   static double m_stdDev;

public:
   static void Draw() {
      int bars = InpRegChannelBars; 
      double prices[];
      ArrayResize(prices, bars);
      
      for(int i = 0; i < bars; i++) prices[i] = iClose(_Symbol, InpTimeframe, i);
      
      double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
      for(int i = 0; i < bars; i++) {
         sumX += i;
         sumY += prices[i];
         sumXY += i * prices[i];
         sumX2 += i * i;
      }
      
      m_slope = (bars * sumXY - sumX * sumY) / (bars * sumX2 - sumX * sumX);
      m_intercept = (sumY - m_slope * sumX) / bars;
      
      // Standart sapma hesapla
      double sumDevSq = 0;
      for(int i = 0; i < bars; i++) {
         double regValue = m_intercept + m_slope * i;
         sumDevSq += MathPow(prices[i] - regValue, 2);
      }
      m_stdDev = MathSqrt(sumDevSq / bars);
      
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      
      if(m_slope > point * 5) m_trendDirection = 1;
      else if(m_slope < -point * 5) m_trendDirection = -1;
      else m_trendDirection = 0;
      
      // 🎯 GLOBAL TREND DEĞİŞKENLERİNİ GÜNCELLE (Ultimate Harmony Style)
      g_regressionTrend = m_trendDirection;
      g_allowedTradeDirection = m_trendDirection;
      
      // Kanal taşması kontrolü
      double currentPrice = iClose(_Symbol, InpTimeframe, 0);
      double upperBound = m_intercept + m_stdDev * 2.5;
      double lowerBound = m_intercept - m_stdDev * 2.5;
      
      if(currentPrice > upperBound || currentPrice < lowerBound) {
         g_channelBreakout = true;
         CLogger::Warning("🚨 KANAL TAŞMASI: Fiyat kanalın dışında!");
      } else {
         g_channelBreakout = false;
      }
      
      // Trend çatışması yoksa flag'i temizle
      g_trendConflict = false;
      
      // Grafikte regresyon kanalını çiz
      DrawChannelOnChart();
   }

   
   static void DrawChannelOnChart() {
      string objPrefix = "MilyonerRegCh_";
      
      // Eski objeleri sil
      ObjectDelete(0, objPrefix + "Upper");
      ObjectDelete(0, objPrefix + "Middle");
      ObjectDelete(0, objPrefix + "Lower");
      
      int bars = InpRegChannelBars;
      datetime time1 = iTime(_Symbol, InpTimeframe, bars - 1);
      datetime time2 = iTime(_Symbol, InpTimeframe, 0);
      
      double price1_mid = m_intercept + m_slope * (bars - 1);
      double price2_mid = m_intercept;
      
      double price1_upper = price1_mid + m_stdDev * 2;
      double price2_upper = price2_mid + m_stdDev * 2;
      
      double price1_lower = price1_mid - m_stdDev * 2;
      double price2_lower = price2_mid - m_stdDev * 2;
      
      // Renk belirleme
      color channelColor;
      if(m_trendDirection == 1) channelColor = clrDodgerBlue;       // Yukarı → Mavi
      else if(m_trendDirection == -1) channelColor = clrRed;        // Aşağı → Kırmızı
      else channelColor = clrLimeGreen;                              // Yatay → Yeşil
      
      // Orta çizgi
      ObjectCreate(0, objPrefix + "Middle", OBJ_TREND, 0, time1, price1_mid, time2, price2_mid);
      ObjectSetInteger(0, objPrefix + "Middle", OBJPROP_COLOR, channelColor);
      ObjectSetInteger(0, objPrefix + "Middle", OBJPROP_WIDTH, 2);
      ObjectSetInteger(0, objPrefix + "Middle", OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, objPrefix + "Middle", OBJPROP_RAY_RIGHT, true);
      
      // Üst çizgi
      ObjectCreate(0, objPrefix + "Upper", OBJ_TREND, 0, time1, price1_upper, time2, price2_upper);
      ObjectSetInteger(0, objPrefix + "Upper", OBJPROP_COLOR, channelColor);
      ObjectSetInteger(0, objPrefix + "Upper", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, objPrefix + "Upper", OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, objPrefix + "Upper", OBJPROP_RAY_RIGHT, true);
      
      // Alt çizgi
      ObjectCreate(0, objPrefix + "Lower", OBJ_TREND, 0, time1, price1_lower, time2, price2_lower);
      ObjectSetInteger(0, objPrefix + "Lower", OBJPROP_COLOR, channelColor);
      ObjectSetInteger(0, objPrefix + "Lower", OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, objPrefix + "Lower", OBJPROP_STYLE, STYLE_DOT);
      ObjectSetInteger(0, objPrefix + "Lower", OBJPROP_RAY_RIGHT, true);
   }
   
   static void RemoveChannelFromChart() {
      string objPrefix = "MilyonerRegCh_";
      ObjectDelete(0, objPrefix + "Upper");
      ObjectDelete(0, objPrefix + "Middle");
      ObjectDelete(0, objPrefix + "Lower");
   }
   
   static int GetTrendDirection() { return m_trendDirection; }
   static double GetSlope() { return m_slope; }
   static double GetStdDev() { return m_stdDev; }
};
int CRegressionChannel::m_trendDirection = 0;
double CRegressionChannel::m_slope = 0;
double CRegressionChannel::m_intercept = 0;
double CRegressionChannel::m_stdDev = 0;

//====================================================================
// CLASS: CDashboard - GELİŞMİŞ GÖRSEL PANEL (Ultimate Harmony Style)
//====================================================================
class CDashboard {
public:
   static void Render() {
      if(!InpShowDashboard) return;
      
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      double profit = equity - balance;
      
      // Milestone hesaplama
      int milestone = GetCurrentMilestone(balance);
      double nextMilestone = GetNextMilestoneValue(balance);
      double toNext = nextMilestone - balance;
      double completedMilestones = GetCompletedAmount(balance);
      
      // Regresyon trend yönü
      int trend = CRegressionChannel::GetTrendDirection();
      string trendStr = (trend == 1) ? "YUKARI" : (trend == -1) ? "ASAGI" : "YATAY";
      string trendColor = (trend == 1) ? "🔵" : (trend == -1) ? "🔴" : "🟢";
      
      // ATR hesaplama
      double atr[];
      ArraySetAsSeries(atr, true);
      double atrValue = 0;
      if(CopyBuffer(g_hATR, 0, 0, 1, atr) > 0) atrValue = PointsToPip(atr[0]);
      
      // Dashboard oluştur - Ultimate Harmony Style
      string c = "";
      c += "╔════════════════════════════════════════════╗\n";
      c += "║     ULTIMATE HARMONY EA v1.0               ║\n";
      c += "╠════════════════════════════════════════════╣\n";
      c += "║ 🎯 1 MİLYON DOLAR HEDEFİ                   ║\n";
      c += "╠════════════════════════════════════════════╣\n";
      c += "║ 💰 Bakiye: $" + DoubleToString(balance, 2) + "\n";
      c += "║ 📊 Equity: $" + DoubleToString(equity, 2) + "\n";
      c += "║ 💵 Kar: $" + DoubleToString(profit, 2) + "\n";
      c += "║ 🏦 İşlem: " + IntegerToString(g_buyGridCount) + " (vol " + DoubleToString(GetTotalVolume(), 2) + ")\n";
      c += "║ 📉 Max DD: " + DoubleToString(g_maxDrawdown, 2) + "%\n";
      c += "╠════════════════════════════════════════════╣\n";
      c += "║ 🏆 Tamamlanan: " + IntegerToString(milestone) + "/10 hedef\n";
      c += "║ 🎯 Sonraki: $" + DoubleToString(nextMilestone, 0) + "\n";
      c += "║ 📈 Kalan: $" + DoubleToString(toNext, 0) + "\n";
      c += "╠════════════════════════════════════════════╣\n";
      c += "║ 🎁 Paranı katladın! Bileşik büyüme çalışıyor!\n";
      c += "╠════════════════════════════════════════════╣\n";
      c += "║ 💎 Buy Grid: " + IntegerToString(g_buyGridCount) + " | $" + DoubleToString(GetGridProfit(1), 2) + "\n";
      c += "║ 💎 Sell Grid: " + IntegerToString(g_sellGridCount) + " | $" + DoubleToString(GetGridProfit(-1), 2) + "\n";
      c += "║ 📐 Spread: " + DoubleToString(PointsToPip((double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * _Point), 1) + " pip\n";
      c += "║ 📊 ATR: " + DoubleToString(atrValue, 1) + " pip\n";
      c += "╠════════════════════════════════════════════╣\n";
      c += "║ 📌 Pivot: " + DoubleToString((g_support + g_resistance) / 2, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)) + "\n";
      c += "║ 📌 S/R: " + DoubleToString(g_support, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)) + " / " + DoubleToString(g_resistance, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)) + "\n";
      c += "╠════════════════════════════════════════════╣\n";
      c += "║ " + trendColor + " Trend: " + trendStr + "\n";
      c += "║ 🎯 İzin: " + GetAllowedDirectionString() + "\n";
      if(g_channelBreakout) c += "║ 🚨 KANAL TAŞMASI - İŞLEM YOK!\n";
      c += "╠════════ HEDEF LİSTESİ ═════════════════════╣\n";

      c += GetMilestoneLadder(balance);
      c += "╚════════════════════════════════════════════╝\n";
      
      Comment(c);
   }
   
private:
   static int GetCurrentMilestone(double balance) {
      double milestones[] = {100, 500, 1000, 5000, 10000, 25000, 50000, 100000, 500000, 1000000};
      for(int i = ArraySize(milestones) - 1; i >= 0; i--) {
         if(balance >= milestones[i]) return i + 1;
      }
      return 0;
   }
   
   static double GetNextMilestoneValue(double balance) {
      double milestones[] = {100, 500, 1000, 5000, 10000, 25000, 50000, 100000, 500000, 1000000};
      for(int i = 0; i < ArraySize(milestones); i++) {
         if(balance < milestones[i]) return milestones[i];
      }
      return 1000000;
   }
   
   static double GetCompletedAmount(double balance) {
      double milestones[] = {100, 500, 1000, 5000, 10000, 25000, 50000, 100000, 500000, 1000000};
      double completed = 0;
      for(int i = 0; i < ArraySize(milestones); i++) {
         if(balance >= milestones[i]) completed = milestones[i];
      }
      return completed;
   }
   
   static double GetTotalVolume() {
      double vol = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         vol += PositionGetDouble(POSITION_VOLUME);
      }
      return vol;
   }
   
   static double GetGridProfit(int direction) {
      double profit = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         
         long posType = PositionGetInteger(POSITION_TYPE);
         if((direction == 1 && posType == POSITION_TYPE_BUY) ||
            (direction == -1 && posType == POSITION_TYPE_SELL)) {
            profit += PositionGetDouble(POSITION_PROFIT);
         }
      }
      return profit;
   }
   
   static string GetMilestoneLadder(double balance) {
      string ladder = "";
      double milestones[] = {100, 500, 1000, 5000, 10000, 25000, 50000, 100000, 500000, 1000000};
      string labels[] = {"$100", "$500", "$1K", "$5K", "$10K", "$25K", "$50K", "$100K", "$500K", "$1M"};
      
      for(int i = 9; i >= 0; i--) {
         string check = (balance >= milestones[i]) ? "✅" : "⬜";
         ladder += "║ " + check + " " + labels[i] + "\n";
      }
      
      return ladder;
   }
};




//====================================================================
// CLASS: CSmartMoneyConcepts - ICT/SMC ANALİZİ (Ultimate Harmony'den)
//====================================================================
class CSmartMoneyConcepts {
public:
   //--- Order Block Tespiti (Büyük kurumsal emirlerin bıraktığı izler)
   static bool DetectOrderBlock(int &direction, double &obHigh, double &obLow) {
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
         
         if(bodySize > range * 0.7) {
            // Bullish Order Block
            if(close_i > open_i && close_prev < open_prev) {
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
         double low3 = iLow(_Symbol, InpTimeframe, i);
         
         // Bullish FVG
         if(high1 < low3) {
            double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            if(currentPrice >= high1 && currentPrice <= low3) {
               direction = 1;
               fvgHigh = low3;
               fvgLow = high1;
               return true;
            }
         }
         
         double low1 = iLow(_Symbol, InpTimeframe, i + 2);
         double high3 = iHigh(_Symbol, InpTimeframe, i);
         
         // Bearish FVG
         if(low1 > high3) {
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
   
   //--- SMC Sinyal Skoru
   static int GetSMCScore(int direction) {
      int score = 0;
      
      int obDir = 0;
      double obH, obL;
      if(DetectOrderBlock(obDir, obH, obL) && obDir == direction)
         score += 25;
      
      int fvgDir = 0;
      double fvgH, fvgL;
      if(DetectFVG(fvgDir, fvgH, fvgL) && fvgDir == direction)
         score += 20;
      
      return score;
   }
};

//====================================================================
// CLASS: CDivergenceDetector - DİVERJANS TESPİTİ (Ultimate Harmony'den)
//====================================================================
class CDivergenceDetector {
public:
   static int DetectRSIDivergence(int lookback = 20) {
      double rsi[];
      ArraySetAsSeries(rsi, true);
      
      if(CopyBuffer(g_hRSI, 0, 0, lookback, rsi) < lookback)
         return 0;
      
      double priceLows[], rsiLows[], priceHighs[], rsiHighs[];
      ArrayResize(priceLows, 0);
      ArrayResize(rsiLows, 0);
      ArrayResize(priceHighs, 0);
      ArrayResize(rsiHighs, 0);
      
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
            ArrayResize(priceHighs, ArraySize(priceHighs) + 1);
            ArrayResize(rsiHighs, ArraySize(rsiHighs) + 1);
            priceHighs[ArraySize(priceHighs) - 1] = high_i;
            rsiHighs[ArraySize(rsiHighs) - 1] = rsi[i];
         }
         if(isSwingLow) {
            ArrayResize(priceLows, ArraySize(priceLows) + 1);
            ArrayResize(rsiLows, ArraySize(rsiLows) + 1);
            priceLows[ArraySize(priceLows) - 1] = low_i;
            rsiLows[ArraySize(rsiLows) - 1] = rsi[i];
         }
      }
      
      // Bullish Divergence
      if(ArraySize(priceLows) >= 2) {
         if(priceLows[0] < priceLows[1] && rsiLows[0] > rsiLows[1]) {
            WriteLog("📈 BULLISH DİVERJANS tespit edildi (RSI)");
            return 1;
         }
      }
      
      // Bearish Divergence
      if(ArraySize(priceHighs) >= 2) {
         if(priceHighs[0] > priceHighs[1] && rsiHighs[0] < rsiHighs[1]) {
            WriteLog("📉 BEARISH DİVERJANS tespit edildi (RSI)");
            return -1;
         }
      }
      
      return 0;
   }
   
   static int GetDivergenceScore(int direction) {
      int score = 0;
      int rsiDiv = DetectRSIDivergence();
      
      if(rsiDiv == direction) score += 30;
      if(rsiDiv == -direction) score -= 20;
      
      return score;
   }
};

//====================================================================
// CLASS: CMillionDollarTracker - 1 MİLYON DOLAR HEDEF TAKİP (Ultimate Harmony'den)
//====================================================================
class CMillionDollarTracker {
private:
   static double m_startBalance;
   static double m_milestones[10];
   static bool m_milestoneReached[10];
   
public:
   static void Init() {
      m_startBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      
      m_milestones[0] = 100;
      m_milestones[1] = 500;
      m_milestones[2] = 1000;
      m_milestones[3] = 5000;
      m_milestones[4] = 10000;
      m_milestones[5] = 25000;
      m_milestones[6] = 50000;
      m_milestones[7] = 100000;
      m_milestones[8] = 500000;
      m_milestones[9] = 1000000;
      
      for(int i = 0; i < 10; i++) m_milestoneReached[i] = false;
   }
   
   static void Update() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      
      for(int i = 0; i < 10; i++) {
         if(balance >= m_milestones[i] && !m_milestoneReached[i]) {
            m_milestoneReached[i] = true;
            CLogger::Success("🏆 MİLESTONE #" + IntegerToString(i + 1) + " BAŞARILDI: $" + DoubleToString(m_milestones[i], 0));
            
            // Kutlama mesajları
            if(i == 9) Alert("🎉🎊 TEBRİKLER! 1 MİLYON DOLAR HEDEFİNE ULAŞTINIZ! 🎊🎉");
         }
      }
   }
   
   static void CheckMilestoneAchievement() {
      Update();
   }
   
   static int GetCurrentMilestoneIndex() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      for(int i = 9; i >= 0; i--) {
         if(balance >= m_milestones[i]) return i;
      }
      return -1;
   }
   
   static double GetNextMilestone() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      for(int i = 0; i < 10; i++) {
         if(balance < m_milestones[i]) return m_milestones[i];
      }
      return 1000000;
   }
   
   static double GetProgress() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      return (balance / 1000000.0) * 100.0;
   }
   
   static string GetMotivationMessage() {
      int idx = GetCurrentMilestoneIndex();
      
      switch(idx) {
         case -1: return "🚀 Yolculuk başladı!";
         case 0: return "💪 İlk adımı attın!";
         case 1: return "📈 Yükselişe geçtik!";
         case 2: return "🔥 Binlerce dolar!";
         case 3: return "⭐ 5K kulübüne hoş geldin!";
         case 4: return "🌟 10K başarıldı!";
         case 5: return "💎 25K zenginlik yolunda!";
         case 6: return "👑 50K kraliyet seviyesi!";
         case 7: return "🏆 100K efsane!";
         case 8: return "💰 Yarım milyon!";
         case 9: return "🎉 1 MİLYON DOLAR!";
         default: return "Devam et!";
      }
   }
};

// Static değişken tanımları
double CMillionDollarTracker::m_startBalance = 0;
double CMillionDollarTracker::m_milestones[10];
bool CMillionDollarTracker::m_milestoneReached[10];

//====================================================================
// CLASS: CSessionAnalyzer - MARKET SESSION ANALİZİ (Ultimate Harmony'den)
//====================================================================
class CSessionAnalyzer {
public:
   static string GetCurrentSession() {
      MqlDateTime dt;
      TimeCurrent(dt);
      int hour = dt.hour;
      
      if(hour >= 0 && hour < 8) return "ASIA";
      if(hour >= 8 && hour < 12) return "LONDON";
      if(hour >= 12 && hour < 17) return "OVERLAP";
      if(hour >= 17 && hour < 22) return "NEW_YORK";
      
      return "OFF_HOURS";
   }
   
   static bool IsTradingAllowed() {
      string session = GetCurrentSession();
      return (session == "LONDON" || session == "OVERLAP" || session == "NEW_YORK");
   }
   
   static double GetSessionVolatility() {
      string session = GetCurrentSession();
      
      if(session == "OVERLAP") return 1.3;
      if(session == "LONDON") return 1.2;
      if(session == "NEW_YORK") return 1.1;
      if(session == "ASIA") return 0.7;
      
      return 0.5;
   }
};

//====================================================================
// YARDIMCI FONKSİYONLAR
//====================================================================
//====================================================================
// 📋 AKILLI LOG SİSTEMİ - SPAM ÖNLEYİCİ (v1.07)
//====================================================================
string   g_lastLogMessages[];
datetime g_lastLogTimes[];
int      g_logMessageCount = 0;
const int LOG_THROTTLE_SECONDS = 60;

void WriteLog(string msg) {
   if(!InpShowDebugLog) return;
   
   for(int i = 0; i < g_logMessageCount; i++) {
      if(g_lastLogMessages[i] == msg) {
         if(TimeCurrent() - g_lastLogTimes[i] < LOG_THROTTLE_SECONDS) return;
         g_lastLogTimes[i] = TimeCurrent();
         Print("📋 ", msg);
         return;
      }
   }
   
   g_logMessageCount++;
   ArrayResize(g_lastLogMessages, g_logMessageCount);
   ArrayResize(g_lastLogTimes, g_logMessageCount);
   g_lastLogMessages[g_logMessageCount - 1] = msg;
   g_lastLogTimes[g_logMessageCount - 1] = TimeCurrent();
   
   Print("🚀 MilyonerKod: ", msg);
}

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

//====================================================================
// 🎯 MERKEZİ İŞLEM İZİN KONTROLÜ (Ultimate Harmony'den)
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
// CLASS: CSelfCorrector - ÖZ DÜZELTME MEKANİZMASI
//====================================================================
class CSelfCorrector {
public:
   static void OnTradeLoss() {
      if(!InpUseSelfCorrection) return;
      g_consecutiveLosses++;
      
      if(g_consecutiveLosses >= InpMaxConsLosses) {
         g_penaltyEndTime = TimeCurrent() + InpPenaltyDuration * 60;
         WriteLog("🚫 ZARAR SERİSİ: EA " + IntegerToString(InpPenaltyDuration) + " dakika cezalı!");
      }
   }
   
   static void OnTradeWin() {
      g_consecutiveLosses = 0;
   }
   
   static bool IsPenalized() {
      if(TimeCurrent() < g_penaltyEndTime) return true;
      return false;
   }
   
   static double GetLotModifier() {
      if(InpReduceRiskOnLoss && g_consecutiveLosses > 0) {
         return MathMax(0.5, 1.0 - (g_consecutiveLosses * 0.2));
      }
      return 1.0;
   }
};

double NormalizeLot(double lot) {
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   if(minLot <= 0) minLot = 0.01;
   if(stepLot <= 0) stepLot = 0.01;
   
   lot *= CSelfCorrector::GetLotModifier(); 
   
   lot = MathFloor(lot / stepLot) * stepLot;
   lot = MathMax(minLot, MathMin(lot, MathMin(maxLot, InpMaxLot)));
   return MathMax(InpMinLot, NormalizeDouble(lot, 2));
}

//====================================================================
// CLASS: CVolatilyManager - VOLATİLİTE REJİM YÖNETİCİSİ
//====================================================================
class CVolatilyManager {
public:
   static void UpdateMode() {
      if(InpVolMode != VOL_ADAPTIVE) {
         g_currentVolMode = InpVolMode;
         return;
      }
      
      double atr[];
      ArraySetAsSeries(atr, true);
      if(CopyBuffer(g_hATR, 0, 0, 1, atr) < 1) return;
      
      g_currentATR = atr[0];
      double atrPips = PointsToPip(g_currentATR);
      
      if(atrPips < InpVolThresholdLow) g_currentVolMode = VOL_LOW;
      else if(atrPips > InpVolThresholdHigh) g_currentVolMode = VOL_HIGH;
      else g_currentVolMode = VOL_NORMAL;
   }
   
   static string GetModeString() {
      switch(g_currentVolMode) {
         case VOL_LOW: return "🍃 SAKİN";
         case VOL_NORMAL: return "🌊 NORMAL";
         case VOL_HIGH: return "🌋 KAOS";
         default: return "❓";
      }
   }
   
   static bool IsTradingAllowed() {
      if(g_currentVolMode == VOL_HIGH && InpAvoidKaos) return false;
      return true;
   }
};

//====================================================================
// CLASS: CAISignalScorer - AI SİNYAL VE TSI
//====================================================================
class CAISignalScorer {
public:
   static double GetRSIValue() {
      double rsi[];
      ArraySetAsSeries(rsi, true);
      if(CopyBuffer(g_hRSI, 0, 0, 1, rsi) > 0) return rsi[0];
      return 50.0;
   }
   
   // CCI (Commodity Channel Index) Değeri (v2.0)
   static double GetCCIValue() {
      if(!InpUseCCI || g_hCCI == INVALID_HANDLE) return 0;
      double cci[];
      ArraySetAsSeries(cci, true);
      if(CopyBuffer(g_hCCI, 0, 0, 1, cci) > 0) return cci[0];
      return 0;
   }
   
   // CCI Sinyal (v2.0): 1=Buy, -1=Sell, 0=Nötr
   static int GetCCISignal() {
      if(!InpUseCCI) return 0;
      double cci = GetCCIValue();
      if(cci < InpCCIOversold) return 1;   // Aşırı satım → BUY
      if(cci > InpCCIOverbought) return -1; // Aşırı alım → SELL
      return 0;
   }
   
   // Williams %R Değeri (v2.0)
   static double GetWPRValue() {
      if(!InpUseWPR || g_hWPR == INVALID_HANDLE) return -50;
      double wpr[];
      ArraySetAsSeries(wpr, true);
      if(CopyBuffer(g_hWPR, 0, 0, 1, wpr) > 0) return wpr[0];
      return -50;
   }
   
   // Williams %R Sinyal (v2.0): 1=Buy, -1=Sell, 0=Nötr
   static int GetWPRSignal() {
      if(!InpUseWPR) return 0;
      double wpr = GetWPRValue();
      if(wpr < InpWPROversold) return 1;   // Aşırı satım → BUY
      if(wpr > InpWPROverbought) return -1; // Aşırı alım → SELL
      return 0;
   }
   
   // Bollinger Bands Squeeze Tespiti (v2.0)
   static bool IsBBSqueeze() {
      if(!InpUseBBSqueeze || g_hBB == INVALID_HANDLE) return false;
      
      double upper[], lower[];
      ArraySetAsSeries(upper, true);
      ArraySetAsSeries(lower, true);
      
      if(CopyBuffer(g_hBB, 1, 0, 10, upper) < 10) return false;
      if(CopyBuffer(g_hBB, 2, 0, 10, lower) < 10) return false;
      
      // Mevcut ve önceki band genişliklerini karşılaştır
      double widthNow = upper[0] - lower[0];
      double widthPrev = upper[5] - lower[5];
      
      // Eğer band %50'den fazla daraldıysa → Squeeze
      return (widthNow < widthPrev * 0.5);
   }


   static double GetTSIValue() {
      int r = InpTSI_Period_R;
      int s = InpTSI_Period_S;
      int lookback = r + s + 50;
      
      double close[];
      ArraySetAsSeries(close, true);
      if(CopyClose(_Symbol, InpTimeframe, 0, lookback, close) < lookback) return 0;
      
      double pc[], apc[];
      ArrayResize(pc, lookback-1);
      ArrayResize(apc, lookback-1);
      
      for(int i=0; i<lookback-1; i++) {
         pc[i] = close[i] - close[i+1];
         apc[i] = MathAbs(pc[i]);
      }
      
      // 1. Smoothing (Period R)
      double ema1_pc[], ema1_apc[];
      int size1 = lookback - 1;
      ArrayResize(ema1_pc, size1 - r + 1);
      ArrayResize(ema1_apc, size1 - r + 1);
      
      // Calculate first smoothing for a window
      for(int i=0; i < ArraySize(ema1_pc); i++) {
         double temp_pc[], temp_apc[];
         ArrayResize(temp_pc, r); ArrayResize(temp_apc, r);
         for(int j=0; j<r; j++) { temp_pc[j] = pc[i+j]; temp_apc[j] = apc[i+j]; }
         ema1_pc[i] = CalculateEMA_Array(temp_pc, r);
         ema1_apc[i] = CalculateEMA_Array(temp_apc, r);
      }
      
      // 2. Smoothing (Period S)
      double dspc = CalculateEMA_Array(ema1_pc, s);
      double dsapc = CalculateEMA_Array(ema1_apc, s);
      
      return (dsapc != 0) ? 100.0 * (dspc / dsapc) : 0;
   }

   static double CalculateEMA_Array(double &data[], int period) {
      double k = 2.0 / (period + 1.0);
      double ema = data[ArraySize(data)-1];
      for(int i=ArraySize(data)-2; i>=0; i--) {
         ema = (data[i] - ema) * k + ema;
      }
      return ema;
   }
   
   static int GetSMCStrongSignal() {
      if(!InpUseSMC) return 0;
      int dir = 0;
      double h, l;
      if(CSmartMoneyConcepts::DetectOrderBlock(dir, h, l)) return dir;
      if(CSmartMoneyConcepts::DetectFVG(dir, h, l)) return dir;
      return 0;
   }

   static int CalculateScore(int direction) {
      double score = 0;
      
      // 1. TSI (%20)
      double tsi = GetTSIValue();
      if((direction == 1 && tsi > 0) || (direction == -1 && tsi < 0)) score += 20;
      
      // 2. MA Cross (%10)
      double ma1[], ma2[];
      ArraySetAsSeries(ma1, true); ArraySetAsSeries(ma2, true);
      if(CopyBuffer(g_hMA1, 0, 0, 2, ma1) > 1 && CopyBuffer(g_hMA2, 0, 0, 2, ma2) > 1) {
         if(direction == 1 && ma1[0] > ma2[0]) score += 10;
         if(direction == -1 && ma1[0] < ma2[0]) score += 10;
      }
      
      // 3. MACD (%10)
      double macd[], signal[];
      ArraySetAsSeries(macd, true); ArraySetAsSeries(signal, true);
      if(CopyBuffer(g_hMACD, 0, 0, 1, macd) > 0 && CopyBuffer(g_hMACD, 1, 0, 1, signal) > 0) {
         if(direction == 1 && macd[0] > signal[0] && macd[0] > 0) score += 10;
         if(direction == -1 && macd[0] < signal[0] && macd[0] < 0) score += 10;
      }
      
      // 4. RSI (%10)
      double rsi = GetRSIValue();
      if(direction == 1 && rsi < 50) score += 10;
      if(direction == -1 && rsi > 50) score += 10;
      
      // 5. ADX (%10)
      double adx[];
      ArraySetAsSeries(adx, true);
      if(CopyBuffer(g_hADX, 0, 0, 1, adx) > 0) {
         if(adx[0] > InpADX_Min) score += 10;
      }
      
      // 6. Pattern (%10)
      int pattern = CCandleAnalyzer::GetPatternSignal();
      if(pattern == direction) score += 10;
      
      // 7. Level S/R (%5)
      double price = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      if(direction == 1 && price <= g_support + PipToPoints(10)) score += 5;
      if(direction == -1 && price >= g_resistance - PipToPoints(10)) score += 5;
      
      // 8. Fibonacci (%5)
      if(direction == 1 && price <= g_support + PipToPoints(20)) score += 5;
      if(direction == -1 && price >= g_resistance - PipToPoints(20)) score += 5;
      
      // 9. Pivot (%5)
      if(direction == 1 && price > g_support) score += 5;
      if(direction == -1 && price < g_resistance) score += 5;
      
      // 10. Session (%5)
      if(CSessionAnalyzer::IsTradingAllowed()) score += 5;
      
      // 11. SMC/ICT Order Block & FVG (%10) - Ultimate Harmony'den
      int obDir = 0;
      double obH, obL;
      if(CSmartMoneyConcepts::DetectOrderBlock(obDir, obH, obL) && obDir == direction) score += 5;
      int fvgDir = 0;
      double fvgH, fvgL;
      if(CSmartMoneyConcepts::DetectFVG(fvgDir, fvgH, fvgL) && fvgDir == direction) score += 5;
      
      // 12. RSI Divergence (%10) - Ultimate Harmony'den
      int divDir = CDivergenceDetector::DetectRSIDivergence();
      if(divDir == direction) score += 10;
      if(divDir == -direction) score -= 5; // Ters diverjas ceza
      
      // 13. CCI Sinyal (%5) - v2.0
      int cciSignal = GetCCISignal();
      if(cciSignal == direction) score += 5;
      if(cciSignal == -direction) score -= 3;
      
      // 14. Williams %R Sinyal (%5) - v2.0
      int wprSignal = GetWPRSignal();
      if(wprSignal == direction) score += 5;
      if(wprSignal == -direction) score -= 3;
      
      // 15. BB Squeeze Bonus (%5) - v2.0
      // Squeeze varsa breakout bekleniyor → sinyal güçlendirici
      if(IsBBSqueeze()) score += 5;
      
      // 16. Equity Curve Filter Penalty - v2.0
      if(!CEquityCurveFilter::IsOK()) score -= 10;
      
      // 17. Stochastic Score (%5) - Ultimate Harmony
      double stochScore = CStochasticAnalyzer::GetScore(direction);
      if(stochScore >= 80) score += 5;
      else if(stochScore >= 60) score += 3;
      
      // 18. Bollinger Bands Score (%5) - Ultimate Harmony
      double bbScore = CBollingerAnalyzer::GetScore(direction);
      if(bbScore >= 80) score += 5;
      else if(bbScore >= 60) score += 3;
      
      // 19. Volume Score (%5) - Ultimate Harmony
      int volScore = CVolumeAnalyzer::GetVolumeScore(direction);
      if(volScore >= 80) score += 5;
      else if(volScore >= 60) score += 3;
      if(CVolumeAnalyzer::IsClimax()) score += 3; // Climax bonus
      
      // 20. Trend Strength Score (%5) - Ultimate Harmony
      int trendScore = CTrendStrength::GetTrendScore();
      if(trendScore >= 70) score += 5;
      else if(trendScore >= 60) score += 3;
      else if(trendScore < 40) score -= 5; // Zayıf trend cezası
      
      // Bonus: Risk Parity Volatilite Ayarlaması
      double volAdj = CRiskParity::AdjustForVolatility();
      if(volAdj < 0.9) score -= 5; // Yüksek volatilite cezası
      
      return (int)MathMax(0, score);
   }
};


// CSmartMoneyConcepts sınıfı yukarıda zaten tanımlı (Ultimate Harmony versiyonu)
// CSessionAnalyzer sınıfı yukarıda zaten tanımlı (Ultimate Harmony versiyonu)



//====================================================================
// CLASS: CAdvancedLevels - FİBONACCİ VE PİVOT
//====================================================================
class CAdvancedLevels {
public:
   static void UpdateLevels() {
      if(InpUsePivots) CalculatePivots();
      if(InpUseFibonacci) CalculateFibonacci();
   }
   
   static void CalculatePivots() {
      MqlRates rates[];
      if(CopyRates(_Symbol, PERIOD_D1, 1, 1, rates) < 1) return;
      
      double high = rates[0].high;
      double low = rates[0].low;
      double close = rates[0].close;
      
      double pivot = (high + low + close) / 3.0;
      g_support = pivot - (high - low); // S1 basitleştirilmiş
      g_resistance = pivot + (high - low); // R1 basitleştirilmiş
   }
   
   static void CalculateFibonacci() {
      MqlRates rates[];
      if(CopyRates(_Symbol, InpTimeframe, 0, InpFibLookback, rates) < InpFibLookback) return;
      
      double highest = -1, lowest = 999999;
      for(int i=0; i<InpFibLookback; i++) {
         if(rates[i].high > highest) highest = rates[i].high;
         if(rates[i].low < lowest) lowest = rates[i].low;
      }
      
      // 61.8 ve 38.2 seviyelerini destek/direnç olarak ata
      double range = highest - lowest;
      g_support = lowest + range * 0.382;
      g_resistance = highest - range * 0.382;
   }
};

//====================================================================
// CLASS: CCandleAnalyzer - 15+ MUM FORMASYON ANALİZİ
//====================================================================
class CCandleAnalyzer {
public:
   static bool IsPinBar(int shift, bool &isBullish) {
      double open = iOpen(_Symbol, InpTimeframe, shift), close = iClose(_Symbol, InpTimeframe, shift);
      double high = iHigh(_Symbol, InpTimeframe, shift), low = iLow(_Symbol, InpTimeframe, shift);
      double body = MathAbs(open - close), range = high - low;
      if(range == 0) return false;
      if(body / range > 0.3) return false;
      if(high - MathMax(open, close) > (range * 0.6)) { isBullish = false; return true; }
      if(MathMin(open, close) - low > (range * 0.6)) { isBullish = true; return true; }
      return false;
   }

   static bool IsEngulfing(int shift, bool &isBullish) {
      double o1 = iOpen(_Symbol, InpTimeframe, shift), c1 = iClose(_Symbol, InpTimeframe, shift);
      double o2 = iOpen(_Symbol, InpTimeframe, shift+1), c2 = iClose(_Symbol, InpTimeframe, shift+1);
      if(MathAbs(c1-o1) > MathAbs(c2-o2)) {
         if(c1 > o1 && c2 < o2 && c1 > o2 && o1 < c2) { isBullish = true; return true; }
         if(c1 < o1 && c2 > o2 && o1 > c2 && c1 < o2) { isBullish = false; return true; }
      }
      return false;
   }

   static bool IsHarami(int shift, bool &isBullish) {
      double o1 = iOpen(_Symbol, InpTimeframe, shift), c1 = iClose(_Symbol, InpTimeframe, shift);
      double o2 = iOpen(_Symbol, InpTimeframe, shift+1), c2 = iClose(_Symbol, InpTimeframe, shift+1);
      if(MathAbs(c1-o1) < MathAbs(c2-o2) * 0.5) {
         if(c2 < o2 && c1 > o1 && o1 > c2 && c1 < o2) { isBullish = true; return true; }
         if(c2 > o2 && c1 < o1 && o1 < c2 && c1 > o2) { isBullish = false; return true; }
      }
      return false;
   }

   static int GetPatternSignal(int shift = 1) {
      bool bull;
      if(IsPinBar(shift, bull)) return bull ? 1 : -1;
      if(IsEngulfing(shift, bull)) return bull ? 1 : -1;
      if(IsHarami(shift, bull)) return bull ? 1 : -1;
      return 0;
   }
   
   // Body/Range oranı (CVolumeAnalyzer::IsClimax için gerekli)
   static double GetBodyRatio(int shift) {
      double open = iOpen(_Symbol, InpTimeframe, shift);
      double close = iClose(_Symbol, InpTimeframe, shift);
      double high = iHigh(_Symbol, InpTimeframe, shift);
      double low = iLow(_Symbol, InpTimeframe, shift);
      
      double body = MathAbs(close - open);
      double range = high - low;
      
      if(range == 0) return 0;
      return body / range;
   }
};


//====================================================================
// CLASS: CMTFAnalyzer - DERİN MTF ANALİZİ (H4-H1)
//====================================================================
class CMTFAnalyzer {
public:
   static bool IsTripleTimeframeAligned(int direction) {
      double bH4[], bH1[]; ArraySetAsSeries(bH4, true); ArraySetAsSeries(bH1, true);
      if(CopyBuffer(g_hMTF_H4, 0, 0, 1, bH4) <= 0 || CopyBuffer(g_hMTF_H1, 0, 0, 1, bH1) <= 0) {
         return true; // Hata durumunda engelleme
      }
      double priceH4 = iClose(_Symbol, PERIOD_H4, 0); double priceH1 = iClose(_Symbol, PERIOD_H1, 0);
      bool ok = false;
      if(direction == 1) ok = (priceH4 > bH4[0] && priceH1 > bH1[0]);
      else ok = (priceH4 < bH4[0] && priceH1 < bH1[0]);
      return ok;
   }
};

//====================================================================
// CLASS: CSmartGrid - AKILLI GRİD YÖNETİCİSİ
//====================================================================
class CSmartGrid {
public:
   static bool ShouldAddGrid(int direction) {
      if(!InpUseSmartGrid) return true;
      
      double rsi = CAISignalScorer::GetRSIValue();
      
      if(direction == 1) { // BUY
         if(rsi < 35) return true;
         double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(MathAbs(price - g_support) < PipToPoints(10)) return true;
      }
      else { // SELL
         if(rsi > 65) return true;
         double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         if(MathAbs(price - g_resistance) < PipToPoints(10)) return true;
      }
      return false;
   }
};

//====================================================================
// CLASS: CPendingOrderManager - DİNAMİK BEKLEYEN EMİR YÖNETİMİ (v1.07)
//====================================================================
class CPendingOrderManager {
public:
   static void ManagePendingOrders() {
      if(!InpTrailingPending) return;
      
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetInteger(ORDER_MAGIC) != InpMagicNumber) continue;
         if(OrderGetString(ORDER_SYMBOL) != _Symbol) continue;
         
         double currentPrice = (OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_LIMIT || OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_STOP) ? 
                               SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
         double diff = MathAbs(currentPrice - orderPrice);
         
         // Fiyat çok uzaklaştıysa emri yeni fiyata yaklaştır
         if(PointsToPip(diff) > InpPendingDistPips + InpPendingMoveStep) {
            WriteLog("🔄 Bekleyen Emir Güncelleniyor: #" + IntegerToString(ticket));
            g_trade.OrderDelete(ticket); // Eski emri sil, Execute tarafı yeni barda/sinyalde tekrar açacaktır
         }
      }
   }
};

//====================================================================
// CLASS: CHedgeManager - HEDGE VE RİSK DENGELEME (v1.07)
//====================================================================
class CHedgeManager {
public:
   static void CheckAndHedge() {
      if(!InpUseHedge) return;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         if(PositionGetString(POSITION_COMMENT).Find("Hedge") >= 0) continue;
         
         double profit = PositionGetDouble(POSITION_PROFIT);
         if(profit < -AccountInfoDouble(ACCOUNT_BALANCE) * 0.02) { // %2 Zararda ise
            double hedgeLot = NormalizeLot(PositionGetDouble(POSITION_VOLUME) * (InpHedgeLotPercent / 100.0));
            int type = (int)PositionGetInteger(POSITION_TYPE);
            
            if(type == POSITION_TYPE_BUY) g_trade.Sell(hedgeLot, _Symbol, 0, 0, 0, "Milyoner_Hedge");
            else g_trade.Buy(hedgeLot, _Symbol, 0, 0, 0, "Milyoner_Hedge");
            
            WriteLog("🛡️ HEDGE AÇILDI: #" + IntegerToString(ticket) + " için koruma.");
         }
      }
   }
};

// CRegressionChannel sınıfı yukarıda (satır 448) tanımlı

//====================================================================
// CLASS: CSecurityManager
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
      
      if(CSelfCorrector::IsPenalized()) return false;
      if(!CVolatilyManager::IsTradingAllowed()) return false;
      
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double dailyLoss = g_refBalance - equity;
      if(g_refBalance > 0 && (dailyLoss / g_refBalance * 100) >= InpMaxDailyDD) {
         WriteLog("⛔ GÜNLÜK DD LİMİTİ");
         return false;
      }
      
      if(g_dailyTradeCount >= InpMaxDailyTrades) {
         WriteLog("⛔ GÜNLÜK İŞLEM LİMİTİ");
         return false;
      }
      
      long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      if(spread / 10.0 > InpMaxSpreadPips) return false;
      
      if(InpUseTimeFilter) {
         MqlDateTime dt;
         TimeCurrent(dt);
         if(dt.hour < InpStartHour || dt.hour >= InpEndHour) return false;
      }
      
      return true;
   }
   
   static bool CheckDrawdown() {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      if(equity > g_equityHigh) g_equityHigh = equity;
      
      double dd = 0;
      if(g_equityHigh > 0) dd = (g_equityHigh - equity) / g_equityHigh * 100;
      if(dd > g_maxDrawdown) g_maxDrawdown = dd;
      
      return (dd < InpMaxDDPercent);
   }

   // v1.07 OTONOM KORUMA SİSTEMLERİ
   static void AutoAddMissingSLTP() {
      if(!InpAutoAddSLTP) return;
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         if(PositionGetDouble(POSITION_SL) > 0) continue;
         
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double slDist = PipToPoints(InpAutoSL_Pips);
         double newSL = (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? openPrice - slDist : openPrice + slDist;
         
         if(g_trade.PositionModify(ticket, NormalizeDouble(newSL, _Digits), PositionGetDouble(POSITION_TP)))
            WriteLog("🛡️ OTONOM SL EKLENDİ: #" + IntegerToString(ticket));
      }
   }

   static void CloseTrendOppositePositions() {
      if(!InpAutoCloseOpposite) return;
      int trend = CRegressionChannel::GetTrendDirection(); // (Varsayımsal Regresyon Fonksiyonu)
      if(trend == 0) return;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         
         int posType = (int)PositionGetInteger(POSITION_TYPE);
         if((trend == 1 && posType == POSITION_TYPE_SELL) || (trend == -1 && posType == POSITION_TYPE_BUY)) {
            // Not: Burada InpOppositeCloseDelay kadar bekletiilebilir, şimdilik direkt kapatma örneği
            if(g_trade.PositionClose(ticket)) WriteLog("🚨 TREND ZITI KAPATILDI: #" + IntegerToString(ticket));
         }
      }
   }
};

//====================================================================
// CLASS: CGridManager
//====================================================================
class CGridManager {
public:
   static void UpdateGridPositions() {
      ArrayResize(g_buyGrid, 0);
      ArrayResize(g_sellGrid, 0);
      g_buyGridCount = 0; // Bu sayaçların sıfırlanması önemli
      g_sellGridCount = 0;
      g_buyTotalLots = 0;
      g_sellTotalLots = 0;
      g_buyTotalProfit = 0;
      g_sellTotalProfit = 0;
      
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
         } else {
            ArrayResize(g_sellGrid, g_sellGridCount + 1);
            g_sellGrid[g_sellGridCount] = pos;
            g_sellGridCount++;
            g_sellTotalLots += pos.lots;
            g_sellTotalProfit += pos.profit;
         }
      }
   }
   
   static void OpenGridOrder(int direction, double lot) {
      double slDist = g_currentATR > 0 ? g_currentATR * 5.0 : PipToPoints(50);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      
      if(direction == 1) {
         double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
         double sl = NormalizeDouble(ask - slDist, digits);
         g_trade.Buy(lot, _Symbol, 0, sl, 0, InpTradeComment + "_G" + IntegerToString(g_buyGridCount));
      } else {
         double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double sl = NormalizeDouble(bid + slDist, digits);
         g_trade.Sell(lot, _Symbol, 0, sl, 0, InpTradeComment + "_G" + IntegerToString(g_sellGridCount));
      }
   }
   
   static void ManageBasketClose() {
      if(!InpAveraging) return;
      
      if(g_buyGridCount > 1 && g_buyTotalProfit >= InpAveragingProfit) {
         WriteLog("💰 BUY BASKET KAPANIYOR! Kar: " + DoubleToString(g_buyTotalProfit, 2));
         for(int i = 0; i < g_buyGridCount; i++) g_trade.PositionClose(g_buyGrid[i].ticket);
         CSelfCorrector::OnTradeWin();
      }
      
      if(g_sellGridCount > 1 && g_sellTotalProfit >= InpAveragingProfit) {
         WriteLog("💰 SELL BASKET KAPANIYOR! Kar: " + DoubleToString(g_sellTotalProfit, 2));
         for(int i = 0; i < g_sellGridCount; i++) g_trade.PositionClose(g_sellGrid[i].ticket);
         CSelfCorrector::OnTradeWin();
      }
   }

   static void ManageGrid() {
      if(!InpUseGrid) return;
      if(g_currentVolMode == VOL_HIGH && InpAvoidKaos) return;
      
      double gridStep = PipToPoints(InpGrid_StepPips);
      if(g_currentATR > 0) gridStep = MathMax(gridStep, g_currentATR * 1.5);
      
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      // BUY GRID
      if(g_buyGridCount > 0 && g_buyGridCount < InpGrid_MaxLevels) {
         double lowestBuy = 999999;
         for(int i = 0; i < g_buyGridCount; i++) {
            if(g_buyGrid[i].openPrice < lowestBuy) lowestBuy = g_buyGrid[i].openPrice;
         }
         
         if(currentPrice <= lowestBuy - gridStep) {
            if(CSmartGrid::ShouldAddGrid(1)) {
               double newLot = NormalizeLot(g_buyGrid[g_buyGridCount-1].lots * InpGrid_LotMulti);
               OpenGridOrder(1, newLot);
            }
         }
      }
      
      // SELL GRID
      if(g_sellGridCount > 0 && g_sellGridCount < InpGrid_MaxLevels) {
         double highestSell = 0;
         for(int i = 0; i < g_sellGridCount; i++) {
            if(g_sellGrid[i].openPrice > highestSell) highestSell = g_sellGrid[i].openPrice;
         }
         
         if(currentPrice >= highestSell + gridStep) {
            if(CSmartGrid::ShouldAddGrid(-1)) {
               double newLot = NormalizeLot(g_sellGrid[g_sellGridCount-1].lots * InpGrid_LotMulti);
               OpenGridOrder(-1, newLot);
            }
         }
      }
      
      ManageBasketClose();
   }
};

//====================================================================
// CLASS: CPositionManager
//====================================================================
class CPositionManager {
public:
   static void ManagePositions() {
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) != InpMagicNumber) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
         double currentSL = PositionGetDouble(POSITION_SL);
         double currentTP = PositionGetDouble(POSITION_TP);
         long posType = PositionGetInteger(POSITION_TYPE);
         int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
         
         // Kar Mesafesi
         double profitPoints = (posType == POSITION_TYPE_BUY) ? 
                             (currentPrice - openPrice) : (openPrice - currentPrice);
                             
         double tpPoints = (posType == POSITION_TYPE_BUY) ? 
                           (currentTP - openPrice) : (openPrice - currentTP);
         
         // Breakeven
         if(InpUseBreakeven && tpPoints > 0 && profitPoints >= tpPoints * (InpBE_TriggerPct / 100.0)) {
            double bePrice;
            if(posType == POSITION_TYPE_BUY)
               bePrice = NormalizeDouble(openPrice + PipToPoints(InpBE_LockPips), digits);
            else
               bePrice = NormalizeDouble(openPrice - PipToPoints(InpBE_LockPips), digits);
               
            if(posType == POSITION_TYPE_BUY) {
               if(currentSL == 0 || currentSL < bePrice) g_trade.PositionModify(ticket, bePrice, currentTP);
            } else {
               if(currentSL == 0 || currentSL > bePrice) g_trade.PositionModify(ticket, bePrice, currentTP);
            }
         }
         
         // Trailing Stop 
         if(InpUseTrailing) {
            double trailStart = tpPoints > 0 ? tpPoints * (InpTrail_StartPct / 100.0) : PipToPoints(20);
            if(g_currentVolMode == VOL_HIGH) trailStart *= 0.5;
            
            if(profitPoints >= trailStart) {
               double trailDist;
               if(InpTrailMode == TRAIL_ATR && g_currentATR > 0)
                  trailDist = g_currentATR * InpTrail_ATR_Multi;
               else
                  trailDist = PipToPoints(InpTrail_FixedPips);
               
               double newSL;
               if(posType == POSITION_TYPE_BUY) {
                  newSL = NormalizeDouble(currentPrice - trailDist, digits);
                  
                  // Chandelier Exit Yakınsaması (Referans kodu mantığı)
                  if(InpTrailMode == TRAIL_CHANDELIER) {
                     double highestHigh = iHigh(_Symbol, InpTimeframe, iHighest(_Symbol, InpTimeframe, MODE_HIGH, 22, 1));
                     newSL = NormalizeDouble(highestHigh - (g_currentATR * 3.0), digits);
                  }
                  
                  if(currentSL == 0 || newSL > currentSL) g_trade.PositionModify(ticket, newSL, currentTP);
               } else {
                  newSL = NormalizeDouble(currentPrice + trailDist, digits);
                  
                  if(InpTrailMode == TRAIL_CHANDELIER) {
                     double lowestLow = iLow(_Symbol, InpTimeframe, iLowest(_Symbol, InpTimeframe, MODE_LOW, 22, 1));
                     newSL = NormalizeDouble(lowestLow + (g_currentATR * 3.0), digits);
                  }
                  
                  if(currentSL == 0 || newSL < currentSL) g_trade.PositionModify(ticket, newSL, currentTP);
               }
            }
         }
         
         // Akıllı Kısmi Kapanış (EKLENDİ)
         if(InpUsePartialClose) {
            bool isPartialDone = (PositionGetString(POSITION_COMMENT) == "Milyoner_Partial");
            if(!isPartialDone && tpPoints > 0 && profitPoints >= tpPoints * (InpPartial1_Trigger / 100.0)) {
               double closeLot = NormalizeLot(PositionGetDouble(POSITION_VOLUME) * (InpPartial1_Close / 100.0));
               if(g_trade.PositionClosePartial(ticket, closeLot)) {
                  WriteLog("💰 KISMİ KAPANIŞ YAPILDI: " + DoubleToString(closeLot, 2) + " lot");
                  
                  // SL'yi girişe çek (Breakeven)
                  if(InpPartialMoveToBE) {
                     double bePrice = (posType == POSITION_TYPE_BUY) ? 
                                    NormalizeDouble(openPrice + PipToPoints(2), digits) :
                                    NormalizeDouble(openPrice - PipToPoints(2), digits);
                     g_trade.PositionModify(ticket, bePrice, currentTP);
                  }
               }
            }
         }
      }
   }
};

//====================================================================
// CLASS: CTradeExecutor
//====================================================================
class CTradeExecutor {
public:
   static bool OpenOrder(int direction) {
      if(!CSecurityManager::IsSafeToTrade()) return false;
      
      double price = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      // DUVAR KONTROLÜ (S/R Filtresi)
      if(direction == 1 && price > g_resistance - PipToPoints(5)) {
         WriteLog("🛡️ ALIŞ İptal: Direnç duvarına çok yakın!");
         return false;
      }
      if(direction == -1 && price < g_support + PipToPoints(5)) {
         WriteLog("🛡️ SATIŞ İptal: Destek duvarına çok yakın!");
         return false;
      }

      double slPips = InpMinSL_Pips;
      if(CVolatilyManager::IsTradingAllowed() && g_currentATR > 0) {
         slPips = PointsToPip(g_currentATR * InpATR_SL_Multi);
      }
      
      double lot = InpFixedLot;
      
      if(InpLotMode == LOT_RISK_PERCENT) {
         double equity = AccountInfoDouble(ACCOUNT_EQUITY);
         double riskAmount = equity * (InpRiskPercent / 100.0);
         double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
         if(slPips > 0 && tickValue > 0) {
            lot = riskAmount / (slPips * 10.0 * tickValue);
         }
      } else if(InpLotMode == LOT_MARTINGALE && g_consecutiveLosses > 0) {
         lot = InpFixedLot * MathPow(InpLotMultiplier, g_consecutiveLosses);
      }
      
      lot = NormalizeLot(lot);
      
      double slDist = PipToPoints(slPips);
      double tpDist = PipToPoints(slPips * InpATR_TP_Multi); 
      
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      double sl, tp;
      
      if(InpEntryMode == MODE_MARKET) {
         if(direction == 1) {
            price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            sl = NormalizeDouble(price - slDist, digits);
            tp = NormalizeDouble(price + tpDist, digits);
            if(g_trade.Buy(lot, _Symbol, 0, sl, tp, InpTradeComment)) {
               WriteLog("✅ BUY Açıldı | Lot: " + DoubleToString(lot, 2));
               return true;
            }
         } else {
            price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            sl = NormalizeDouble(price + slDist, digits);
            tp = NormalizeDouble(price - tpDist, digits);
            if(g_trade.Sell(lot, _Symbol, 0, sl, tp, InpTradeComment)) {
               WriteLog("✅ SELL Açıldı | Lot: " + DoubleToString(lot, 2));
               return true;
            }
         }
      } else if(InpEntryMode == MODE_PENDING) {
         double pendingDist = PipToPoints(InpPendingDistPips);
         if(direction == 1) {
            price = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_ASK) - pendingDist, digits);
            sl = NormalizeDouble(price - slDist, digits);
            tp = NormalizeDouble(price + tpDist, digits);
            if(g_trade.BuyLimit(lot, price, _Symbol, sl, tp, 0, 0, InpTradeComment)) {
               WriteLog("⏳ BUY LIMIT Kuruldu | Fiyat: " + DoubleToString(price, digits));
               return true;
            }
         } else {
            price = NormalizeDouble(SymbolInfoDouble(_Symbol, SYMBOL_BID) + pendingDist, digits);
            sl = NormalizeDouble(price + slDist, digits);
            tp = NormalizeDouble(price - tpDist, digits);
            if(g_trade.SellLimit(lot, price, _Symbol, sl, tp, 0, 0, InpTradeComment)) {
               WriteLog("⏳ SELL LIMIT Kuruldu | Fiyat: " + DoubleToString(price, digits));
               return true;
            }
         }
      }
      return false;
   }
};

//====================================================================
// OnInit
//====================================================================
int OnInit() {
   g_hMA1 = iMA(_Symbol, InpTimeframe, InpMA1_Period, 0, InpMA_Method, PRICE_CLOSE);
   g_hMA2 = iMA(_Symbol, InpTimeframe, InpMA2_Period, 0, InpMA_Method, PRICE_CLOSE);
   g_hMA3 = iMA(_Symbol, InpTimeframe, InpMA3_Period, 0, InpMA_Method, PRICE_CLOSE);
   g_hMACD = iMACD(_Symbol, InpTimeframe, InpMACD_Fast, InpMACD_Slow, InpMACD_Signal, PRICE_CLOSE);
   g_hRSI = iRSI(_Symbol, InpTimeframe, InpRSI_Period, PRICE_CLOSE);
   g_hADX = iADX(_Symbol, InpTimeframe, InpADX_Period);
   g_hATR = iATR(_Symbol, InpTimeframe, InpATR_Period);
   g_hMTF_H4 = iMA(_Symbol, PERIOD_H4, 50, 0, MODE_EMA, PRICE_CLOSE);
   g_hMTF_H1 = iMA(_Symbol, PERIOD_H1, 50, 0, MODE_EMA, PRICE_CLOSE);
   
   // v2.0 Ek İndikatörler
   if(InpUseCCI) g_hCCI = iCCI(_Symbol, InpTimeframe, InpCCIPeriod, PRICE_TYPICAL);
   if(InpUseWPR) g_hWPR = iWPR(_Symbol, InpTimeframe, InpWPRPeriod);
   if(InpUseBBSqueeze) g_hBB = iBands(_Symbol, InpTimeframe, 20, 0, 2.0, PRICE_CLOSE);
   
   if(g_hMA1 == INVALID_HANDLE || g_hATR == INVALID_HANDLE || g_hMTF_H4 == INVALID_HANDLE || g_hMTF_H1 == INVALID_HANDLE) {
      Print("❌ İndikatörler yüklenemedi!");
      return INIT_FAILED;
   }
   
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   g_trade.SetDeviationInPoints(20);
   g_trade.SetTypeFilling(ORDER_FILLING_FOK);
   
   CSecurityManager::Init();
   CMillionDollarTracker::Init();  // Ultimate Harmony hedef takip sistemi
   CAIGuard::Init();               // v2.0 AI Guard başlat
   CStochasticAnalyzer::Init();    // v2.0 Stochastic
   CStatePersistence::Init();      // v2.0 Durum saklama
   CStatePersistence::LoadState(); // Önceki durumu yükle
   
   // Equity Curve Array hazırla
   ArrayResize(g_tradeResults, 0);
   g_tradeResultsCount = 0;
   
   // v2.0 Başlangıç Mesajları
   CLogger::Success("════════════════════════════════════════");
   CLogger::Success("   MİLYONER KOD EA v2.0 BAŞLATILDI!");
   CLogger::Success("   Ultimate Harmony Entegrasyonu Aktif!");
   CLogger::Success("════════════════════════════════════════");
   CLogger::Info("Hedef: $" + DoubleToString(InpTargetBalance, 0));
   CLogger::Info("İnternet Veri: " + (InpUseInternet ? "AKTİF" : "KAPALI"));
   CLogger::Info("AI Engine: " + (InpUseAIEngine ? "AKTİF" : "KAPALI"));
   CLogger::Info("Haber Filtresi: " + (InpUseNewsFilter ? "AKTİF" : "KAPALI"));
   CLogger::Info("SMC/ICT Analizi: AKTİF");
   CLogger::Info("Diverjas Tespiti: AKTİF");
   CLogger::Info("Session Analizi: AKTİF");
   CLogger::Info("Telegram: " + (InpUseTelegram ? "AKTİF" : "KAPALI"));
   CLogger::Info("CCI Göstergesi: " + (InpUseCCI ? "AKTİF" : "KAPALI"));
   CLogger::Info("Williams %R: " + (InpUseWPR ? "AKTİF" : "KAPALI"));
   CLogger::Info("AI Guard: " + (InpAIGuard ? "AKTİF" : "KAPALI"));
   CLogger::Info("Equity Curve Filter: " + (InpEquityCurveFilter ? "AKTİF" : "KAPALI"));
   CLogger::Info("Cuma Kapanışı: " + (InpFridayClose ? "AKTİF" : "KAPALI"));
   CLogger::Info("Enhanced DD Manager: AKTİF");
   CLogger::Info("Stochastic Analyzer: AKTİF");
   CLogger::Info("Volume Analyzer: AKTİF");
   CLogger::Info("Trend Strength: AKTİF");
   CLogger::Info("HTML Report: AKTİF");
   CLogger::Success("Haydi 1 Milyon Dolar'a! 🚀💰🏆");
   
   // Telegram başlangıç mesajı
   CTelegram::Send("🚀 <b>MİLYONER KOD EA v2.0</b>\n✅ Ultimate Harmony Entegrasyonu\nEA başlatıldı!\nHedef: $" + DoubleToString(InpTargetBalance, 0));
   
   return INIT_SUCCEEDED;
}



//====================================================================
// OnDeinit
//====================================================================
void OnDeinit(const int reason) {
   IndicatorRelease(g_hMA1);
   IndicatorRelease(g_hMA2);
   IndicatorRelease(g_hMA3);
   IndicatorRelease(g_hMACD);
   IndicatorRelease(g_hRSI);
   IndicatorRelease(g_hADX);
   IndicatorRelease(g_hATR);
   IndicatorRelease(g_hMTF_H4);
   IndicatorRelease(g_hMTF_H1);
   
   // v2.0 Ek indikatörler
   if(g_hCCI != INVALID_HANDLE) IndicatorRelease(g_hCCI);
   if(g_hWPR != INVALID_HANDLE) IndicatorRelease(g_hWPR);
   if(g_hBB != INVALID_HANDLE) IndicatorRelease(g_hBB);
   CStochasticAnalyzer::Release();
   
   // v2.0 Durumu kaydet
   CStatePersistence::SaveState();
   
   // v2.0 HTML Rapor oluştur
   CHTMLReportGenerator::GenerateReport();
   
   // Regresyon kanalı çizgilerini grafikten kaldır
   CRegressionChannel::RemoveChannelFromChart();
   
   // Telegram kapanış mesajı (performans özeti ile)
   string perf = CBacktestOptimizer::GetOptimizationScore();
   CTelegram::Send("👋 <b>MİLYONER KOD EA</b>\nEA kapatıldı.\n📊 " + perf);
   
   Comment("");
}



//====================================================================
// OnTick
//====================================================================
void OnTick() {
   // 1. Güvenlik ve Cezalı Mod
   if(CSelfCorrector::IsPenalized()) return;
   
   // v2.0: İnternet Veri Güncellemesi
   CInternetData::UpdateIfNeeded();
   
   // v2.0: Haber Filtresi
   if(CInternetData::IsTradingBlocked()) {
      CLogger::Warning("Haber nedeniyle işlem engellendi: " + CInternetData::GetNewsHeadline());
      CDashboard::Render();
      return;
   }
   
   // v2.0: ACİL DURUM KONTROLÜ (Öncelikli!)
   if(CEmergencyManager::Check()) {
      CDashboard::Render();
      return;
   }
   
   // v2.0: AI GUARD (Aşırı Volatilite Koruması)
   if(CAIGuard::IsBlocked()) {
      CDashboard::Render();
      return;
   }
   
   // v2.0: CUMA KAPANIŞI
   CFridayClose::Check();
   
   // v2.0: ENHANCED DD MANAGER (3 Seviyeli)
   int ddAction = CEnhancedDDManager::GetDDAction();
   if(ddAction >= 3) {
      CDashboard::Render();
      return; // Kritik DD - tüm işlemler yönetiliyor
   }
   
   // v2.0: TERS POZİSYON YÖNETİMİ (BUY/SELL Çakışma)
   COppositePositionManager::ManageOppositePositions();
   
   // 🚨 ZAMAN GECİKMELİ TREND ZITI KAPATMA (Ultimate Harmony)
   CloseTrendOppositePositionsWithDelay();

   
   // v2.0: ZAMAN BAZLI ÇIKIŞ (48 saat)
   CTimeBasedExit::CheckTimeExit(48);
   
   // v2.0: MOMENTUM SPIKE YAKALAMA
   if(CMomentumCatcher::DetectVolatilitySpike()) {
      CMomentumCatcher::CatchMomentum();
   }
   
   // v2.0: AKILLI ASISTAN (Tick Analizi)
   CSmartTradeAssistant::QuickTickAnalysis();
   
   // Hard DD Koruma (EKLENDİ)
   if(!CSecurityManager::CheckDrawdown()) {
      CLogger::Error("KRİTİK DRAWDOWN! Tüm işlemler kapatılıyor...");
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(PositionGetInteger(POSITION_MAGIC) == InpMagicNumber) g_trade.PositionClose(ticket);
      }
      return; 
   }


   // 2. v1.07 OTONOM MODÜLLER
   CRegressionChannel::Draw();
   CSecurityManager::AutoAddMissingSLTP();
   CSecurityManager::CloseTrendOppositePositions();
   CPendingOrderManager::ManagePendingOrders();
   CHedgeManager::CheckAndHedge();
   
   // v2.0: AKILLI ASISTAN (Pending Emir Önerisi)
   if(!COppositePositionManager::HasOppositePositions()) {
      CSmartTradeAssistant::ExecuteSmartAssistant();
   }
   
   // 3. Volatilite Modu
   CVolatilyManager::UpdateMode();
   if(!CVolatilyManager::IsTradingAllowed()) {
      CDashboard::Render();
      return;
   }

   
   // 3. İndikatör ve Bar Kontrolü
   static datetime lastTime = 0;
   datetime currentTime = iTime(_Symbol, InpTimeframe, 0);
   bool isNewBar = (currentTime != lastTime);
   lastTime = currentTime; 
   
   // Seviyeleri her yeni barda güncelle (Performans dostu)
   if(isNewBar) CAdvancedLevels::UpdateLevels();
   
   // 4. Mevcut Pozisyon Yönetimi (Her Tick)
   CGridManager::UpdateGridPositions();
   CGridManager::ManageGrid();
   CPositionManager::ManagePositions();
   
    // 5. Yeni İşlem (DD ve Limit Kontrolü)
    if(!CSecurityManager::IsSafeToTrade()) {
       CDashboard::Render();
       return;
    }
    
    // GELİŞMİŞ SİNYAL MANTIĞI
    double tsi = CAISignalScorer::GetTSIValue();
    int smcSignal = CAISignalScorer::GetSMCStrongSignal();
    bool sessionOk = CSessionAnalyzer::IsTradingAllowed();
    
    int buyScore = CAISignalScorer::CalculateScore(1);
    int sellScore = CAISignalScorer::CalculateScore(-1);
    
    // v2.0: Skor Loglama
    if(isNewBar && InpShowDebugLog) {
       CLogger::Signal("BUY Skor: " + IntegerToString(buyScore) + " | SELL Skor: " + IntegerToString(sellScore));
    }

    if(buyScore >= InpMinSignalScore) {
       // BUY Sinyali + SMC + Seans + Üçlü MTF Onayı
       bool mtfOk = CMTFAnalyzer::IsTripleTimeframeAligned(1);
       if(g_buyGridCount == 0 && sessionOk && mtfOk) {
          if(!InpUseSMC || smcSignal == 1) {
             if(CTradeExecutor::OpenOrder(1)) {
                CLogger::Trade("BUY işlemi açıldı! Skor: " + IntegerToString(buyScore));
             }
          }
       }
    }
     else if(sellScore >= InpMinSignalScore) {
       // SELL Sinyali + SMC + Seans + Üçlü MTF Onayı
       bool mtfOk = CMTFAnalyzer::IsTripleTimeframeAligned(-1);
       if(g_sellGridCount == 0 && sessionOk && mtfOk) {
          if(!InpUseSMC || smcSignal == -1) {
             if(CTradeExecutor::OpenOrder(-1)) {
                CLogger::Trade("SELL işlemi açıldı! Skor: " + IntegerToString(sellScore));
             }
          }
       }
    }
   
   // v2.0: Milestone takip sistemi (Ultimate Harmony)
   CMillionDollarTracker::Update();
   
   // v2.0: Gelişmiş Dashboard
   CDashboard::Render();
}

//====================================================================
// OnTradeTransaction: Kazanç/Kayıp Takibi (Self-Correction için)
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
               ENUM_DEAL_TYPE dealType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(trans.deal, DEAL_TYPE);
               string typeStr = (dealType == DEAL_TYPE_BUY) ? "BUY" : "SELL";
               
               // v2.0: Equity Curve Filter'a kaydet
               CEquityCurveFilter::RecordTrade(profit);
               
               // v2.0: Telegram bildirimi
               CTelegram::OnTradeClose(typeStr, profit);
               
               if(profit > 0) {
                  g_dailyProfit += profit;
                  CSelfCorrector::OnTradeWin();
               } else {
                  g_dailyProfit += profit;
                  CSelfCorrector::OnTradeLoss();
               }
               g_dailyTradeCount++;
            }
         }
      }
   }
}
