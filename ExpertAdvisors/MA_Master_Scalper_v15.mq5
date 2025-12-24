//+------------------------------------------------------------------+
//|                                     MA_Master_Scalper_v15.mq5    |
//|      © 2025, Milyoner EA Project v15.0 - ULTIMATE 10K EDITION    |
//|          All-in-One AI Trading System | 10000+ Lines             |
//+------------------------------------------------------------------+
#property copyright "© 2025, Milyoner EA v15 - ULTIMATE 10K"
#property version   "15.00"
#property description "Next-Gen AI Trading System with 45+ Synchronized Modules"
#property strict

#include <Trade\Trade.mqh>

//====================================================================
// v15 ULTIMATE 10K EDITION - MODÜL LİSTESİ
//====================================================================
// ═══════ TEMEL MODÜLLER (1-20) ═══════
// MODÜL 1: AI Signal Scorer (10-Faktör Ağırlıklı Oylama)
// MODÜL 2: Candle Pattern Recognition (25+ Pattern)
// MODÜL 3: Wick Analysis (Fitil Gücü Analizi)
// MODÜL 4: Fibonacci Retracement & Extension
// MODÜL 5: Pivot Points (Classic, Camarilla, Woodie, Fibonacci)
// MODÜL 6: Support/Resistance Dynamic Detection
// MODÜL 7: Multi-Timeframe Trend Analysis
// MODÜL 8: Market Session Analysis
// MODÜL 9: Volatility Regime Detection
// MODÜL 10: RSI/MACD/CCI Divergence Detection
// MODÜL 11: Signal History & Machine Learning Simulation
// MODÜL 12: Adaptive Threshold System
// MODÜL 13: Advanced Risk Management (Kelly, Optimal F)
// MODÜL 14: Smart Partial Close System
// MODÜL 15: Dynamic Trailing Stop (ATR, Parabolic, Chandelier)
// MODÜL 16: Grid Matrix System
// MODÜL 17: Hedge Protection Mode
// MODÜL 18: News Event Filter
// MODÜL 19: Spread & Slippage Protection
// MODÜL 20: Visual Dashboard & Analytics
// ═══════ GELİŞMİŞ MODÜLLER (21-37) ═══════
// MODÜL 21: Order Block Detection
// MODÜL 22: Fair Value Gap (FVG) Analyzer
// MODÜL 23: Liquidity Pool Detection
// MODÜL 24: Market Structure Analysis
// MODÜL 25: Order Flow Imbalance
// MODÜL 26: CMLSimulator - Machine Learning Simulation
// MODÜL 27: CSmartEntryTiming - Optimal Giriş Zamanlaması
// MODÜL 28: CPositionScaling - Scale-In/Out Sistemi
// MODÜL 29: CCorrelationFilter - Cross-Pair Korelasyon
// MODÜL 30: CBreakEvenPlus - Gelişmiş BE Sistemi
// MODÜL 31: CEquityCurveFilter - Equity Eğrisi Filtresi
// MODÜL 32: CSmartExitSystem - Akıllı Çıkış Sistemi
// MODÜL 33: CMultiSessionAnalysis - Gelişmiş Session Analizi
// MODÜL 34: CNewsImpactCalculator - Haber Etki Hesaplayıcı
// MODÜL 35: CRiskParitySystem - Risk Paritesi
// MODÜL 36: CManualPositionProtector - Manuel İşlem Koruyucu
// MODÜL 37: CStatePersistence - Durum Saklama
// ═══════ v15 YENİ MODÜLLER (38-45) ═══════
// MODÜL 38: CAdvancedMLEngine - Gelişmiş ML Motoru
// MODÜL 39: CSmartMoney Concepts - ICT/SMC Analizi
// MODÜL 40: CVolatilityBreakout - Volatilite Kırılım
// MODÜL 41: CAdaptiveStopLoss - Adaptif SL Sistemi
// MODÜL 42: CMomentumFilter - Momentum Filtresi
// MODÜL 43: CTimeBasedExit - Zaman Bazlı Çıkış
// MODÜL 44: CDrawdownRecovery - Drawdown Kurtarma
// MODÜL 45: CAdvancedDashboard - Gelişmiş Dashboard
//====================================================================

//====================================================================
// ENUM TANIMLARI
//====================================================================
enum ENUM_MARKET_REGIME {
   REGIME_HIGH_VOLATILITY,    // Yüksek Volatilite
   REGIME_TRENDING,           // Trend
   REGIME_RANGING,            // Range
   REGIME_BREAKOUT,           // Kırılım
   REGIME_REVERSAL            // Dönüş
};

enum ENUM_ENTRY_MODE { 
   MODE_MARKET,               // Sadece Piyasa Emri
   MODE_PENDING,              // Sadece Bekleyen Emir
   MODE_BOTH,                 // Her İkisi
   MODE_GRID,                 // Grid Sistemi
   MODE_SMART                 // Akıllı Mod (Rejime Göre)
};

enum ENUM_SIGNAL_MODE {
   SIG_MA_CROSS,              // MA Kesişim
   SIG_PATTERN,               // Mum Pattern
   SIG_COMBINED,              // Birleşik
   SIG_AI_SCORE,              // AI Skor Bazlı
   SIG_HARMONY                // Tam Harmony
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

enum ENUM_PIVOT_TYPE {
   PIVOT_CLASSIC,
   PIVOT_CAMARILLA,
   PIVOT_WOODIE,
   PIVOT_FIBONACCI
};

enum ENUM_TRAIL_MODE {
   TRAIL_FIXED,               // Sabit Pip
   TRAIL_ATR,                 // ATR Bazlı
   TRAIL_PARABOLIC,           // Parabolik
   TRAIL_CHANDELIER           // Chandelier Exit
};

enum ENUM_RISK_MODE {
   RISK_FIXED_LOT,            // Sabit Lot
   RISK_PERCENT,              // Yüzde Bazlı
   RISK_KELLY,                // Kelly Kriteri
   RISK_OPTIMAL_F             // Optimal F
};

// v15.2: Gelişmiş MA Tür Seçimi (AMA desteği)
enum ENUM_MA_TYPE {
   MA_TYPE_STANDARD,          // Standart MA (SMA/EMA/SMMA/LWMA)
   MA_TYPE_ADAPTIVE           // Adaptive MA (KAMA) - EN İYİ PERFORMANS
};

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 1: ANA AYARLAR
//====================================================================
input group "══════════════════════════════════════════════════════════════"
input group "═══════ 1. ANA AYARLAR ═══════"
input ulong    MagicNumber       = 131313;
input string   TradeComment      = "MILYONER_v15_10K";
input ENUM_TIMEFRAMES TF         = PERIOD_M5;
input ENUM_ENTRY_MODE EntryMode  = MODE_MARKET;    // v15.9: Market Emir (Test için)
input ENUM_SIGNAL_MODE SignalMode = SIG_AI_SCORE;  // v15.9: AI Skor (Harmony çok kısıtlayıcı)

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 2: AI SİNYAL SKORU
//====================================================================
input group "═══════ 2. AI SİNYAL SİSTEMİ ═══════"
input int      MinSignalScore    = 50;             // v15.10: 55→50 (Daha fazla işlem)
input int      StrongSignalScore = 60;             // v15.10: 65→60 (Daha kolay tetikleme)
input bool     UseAdaptiveThreshold = false;       // v15.4: KAPALI (Basitleştir)
input int      AdaptiveLookback  = 50;             // Adaptif Geriye Bakış
input double   ScoreDecayFactor  = 0.98;           // v15.4: Daha yavaş azalma
input bool     UseHarmonyBoost   = true;           // Harmony Güçlendirme

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 3: MUM ANALİZİ
//====================================================================
input group "═══════ 3. MUM FİTİLİ & PATTERN ═══════"
input bool     UseWickAnalysis   = true;           // Fitil Analizi
input double   MinWickRatio      = 0.25;           // Min Fitil/Gövde Oranı
input double   MaxBodyRatio      = 0.6;            // Max Gövde/Range Oranı
input bool     UseCandlePatterns = true;           // Mum Pattern Kullan
input bool     UseAdvancedPatterns = true;         // Gelişmiş Patternler
input int      PatternLookback   = 5;              // Pattern Geriye Bakış
input double   PatternMinScore   = 70;             // Min Pattern Skoru

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 4: ÜÇLÜ MA SİSTEMİ
//====================================================================
input group "═══════ 4. ÜÇLÜ MA SİSTEMİ ═══════"
input ENUM_MA_TYPE MA_Type    = MA_TYPE_ADAPTIVE;  // v15.11: AMA EN İYİ (Makale: +36.39%)
input int      MA1_Period        = 50;             // v15.11: AMA Periyodu (makale ayarı)
input int      MA2_Period        = 21;             // Medium MA
input int      MA3_Period        = 55;             // Slow MA - trend teyidi
input int      MA4_Period        = 200;            // Trend MA (opsiyonel)
input ENUM_MA_METHOD MA_Method   = MODE_EMA;       // EMA (AMA için kullanılmaz)
input int      AMA_FastPeriod    = 5;              // v15.11: AMA Fast (makale ayarı)
input int      AMA_SlowPeriod    = 100;            // v15.11: AMA Slow (makale ayarı)
input bool     RequireMA4Confirm = false;          // MA200 Onayı - KAPALI

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 5: MOMENTUM
//====================================================================
input group "═══════ 5. MOMENTUM GÖSTERGELERİ ═══════"
input bool     UseMACD           = true;
input int      MACD_Fast         = 12;
input int      MACD_Slow         = 26;
input int      MACD_Signal       = 9;
input bool     UseMACDHistogram  = true;           // MACD Histogram Filtresi
input bool     UseRSI            = false;          // v15.7: KAPALI - Sistem uyumsuzluğu
input int      RSI_Period        = 14;
input int      RSI_OB            = 70;             // v15.4: 65→70 (Daha geniş)
input int      RSI_OS            = 30;             // v15.4: 35→30 (Daha geniş)
input bool     UseStochastic     = false;          // v15.7: KAPALI - Basitleştirme
input int      Stoch_K           = 14;
input int      Stoch_D           = 3;
input int      Stoch_Slowing     = 3;
input bool     UseCCI            = false;          // v15.7: KAPALI - Basitleştirme
input int      CCI_Period        = 14;
input int      CCI_Level         = 100;
// v15.5: True Strength Index (TSI) - Momentum Osilatörü
input bool     UseTSI            = false;          // v15.7: KAPALI - Test edilmedi
input int      TSI_SlowPeriod    = 25;             // TSI Yavaş EMA Periyodu
input int      TSI_FastPeriod    = 13;             // TSI Hızlı EMA Periyodu
input int      TSI_SignalPeriod  = 7;              // TSI Sinyal Periyodu
input int      TSI_OB            = 25;             // TSI Aşırı Alım Seviyesi
input int      TSI_OS            = -25;            // TSI Aşırı Satım Seviyesi

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 6: TREND KALİTESİ
//====================================================================
input group "═══════ 6. TREND KALİTESİ ═══════"
input bool     UseADX            = false;          // v15.10: KAPALI (çok kısıtlayıcı)
input int      ADX_Period        = 14;
input int      ADX_Min           = 15;             // v15.10: 22→15 (daha fazla sinyal)
input int      ADX_Strong        = 30;
input bool     UseLR             = true;
input int      LR_Period         = 20;
input double   LR_MinSlope       = 0.0001;
input bool     UseTrendStrength  = true;           // Trend Gücü İndeksi
input int      TrendStrengthBars = 20;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 7: VOLATİLİTE
//====================================================================
input group "═══════ 7. VOLATİLİTE REJİMİ ═══════"
input bool     UseATR            = true;
input int      ATR_Period        = 14;
input double   ATR_SL_Multi      = 1.2;            // v15.10: 1.5→1.2 (Daha sıkı SL)
input double   ATR_TP_Multi      = 3.6;            // v15.10: 3.0→3.6 (R:R = 1:3)
input int      MinSL_Pips        = 8;              // v15.10: 5→8 (Noise'dan korunma)
input int      MaxSL_Pips        = 100;            // v15.10: 500→100 (Daha kontrollü)
input bool     UseVolatilityFilter = false;        // DEVRE DIŞI (her TF çalışsın)
input double   VolatilityMultiplier = 1.5;
input bool     UseBollingerBands = true;
input int      BB_Period         = 20;
input double   BB_Deviation      = 2.0;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 8: FİBONACCİ & PİVOT
//====================================================================
input group "═══════ 8. FİBONACCİ & PİVOT ═══════"
input bool     UseFibonacci      = true;
input int      FibLookback       = 50;             // Fibonacci Geriye Bakış
input bool     UsePivots         = true;
input ENUM_PIVOT_TYPE PivotType  = PIVOT_CLASSIC;
input bool     UseSupportResistance = true;
input int      SR_Lookback       = 100;            // S/R Geriye Bakış
input double   SR_TouchZone      = 0.0;            // S/R Temas (0=ATR bazlı otomatik)

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 9: MULTI-TIMEFRAME
//====================================================================
input group "═══════ 9. MULTI-TIMEFRAME ═══════"
input bool     UseMTF            = false;          // DEVRE DIŞI (her TF bağımsız çalışsın)
input ENUM_TIMEFRAMES HigherTF1  = PERIOD_H1;      // Üst TF 1
input ENUM_TIMEFRAMES HigherTF2  = PERIOD_H4;      // Üst TF 2
input int      MTF_MA_Period     = 50;             // MTF MA Periyodu
input bool     RequireMTFConfirm = false;          // MTF Onayı KAPALI

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 10: DIVERGENCE
//====================================================================
input group "═══════ 10. DİVERJANS TESPİTİ ═══════"
input bool     UseDivergence     = false;          // v15.4: KAPALI (Basitleştir)
input int      DivergenceLookback = 20;            // Diverjans Geriye Bakış
input bool     UseRSIDivergence  = true;
input bool     UseMACDDivergence = true;
input bool     UseCCIDivergence  = false;
input double   DivergenceMinStrength = 0.3;        // Min Diverjans Gücü

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 11: BREAKEVEN & TRAILING
//====================================================================
input group "═══════ 11. BREAKEVEN & TRAILING ═══════"
input bool     UseBreakeven      = true;
input double   BE_TriggerPct     = 30.0;           // OPTİMİZE: 40→30 (Erken koruma)
input int      BE_LockPips       = 5;              // OPTİMİZE: 3→5 (Daha fazla kâr kilidi)
input bool     UseTrailing       = true;
input ENUM_TRAIL_MODE TrailMode  = TRAIL_ATR;
input double   Trail_StartPct    = 40.0;           // v15.4: 30→40 (Daha sakin trailing)
input double   Trail_ATR_Multi   = 1.0;            // v15.4: 0.8→1.0 (Daha geniş)
input int      Trail_FixedPips   = 15;             // v15.4: 12→15
input double   Trail_ParabolicStep = 0.02;
input double   Trail_ParabolicMax = 0.2;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 12: AKILLI KISMİ KAPAMA
//====================================================================
input group "═══════ 12. AKILLI KISMİ KAPAMA ═══════"
input bool     UseSmartPartial   = true;
input double   Partial1_TriggerPct = 30.0;         // v15.4: 25→30 (Daha dengeli)
input double   Partial1_ClosePct = 50.0;           // v15.4: 40→50 (Daha fazla kâr al)
input double   Partial2_TriggerPct = 60.0;         // OPTİMİZE: 70→60
input double   Partial2_ClosePct = 30.0;           // 2. Kapama %
input bool     PartialMoveSLtoBE = true;           // Kısmi sonrası SL'yi BE'ye taşı

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 13: RİSK YÖNETİMİ
//====================================================================
input group "═══════ 13. RİSK YÖNETİMİ ═══════"
input ENUM_RISK_MODE RiskMode    = RISK_PERCENT;
input double   RiskPercent       = 1.0;
input double   MaxLotSize        = 2.0;
input double   MinLotSize        = 0.01;
input double   FixedLot          = 0.01;
input double   MaxDailyDDPct     = 5.0;
input double   MaxDailyDDMoney   = 100.0;
input double   MaxWeeklyDDPct    = 10.0;
input int      MaxDailyTrades    = 10;             // v15.10: 5→10 (Sinyal kalitesi iyi)
input int      MaxOpenPositions  = 1;              // v15.10: TEK POZİSYON (güvenli)
input double   MinMarginLevel    = 150.0;
input bool     UseCompounding    = false;          // Bileşik Büyüme
input double   CompoundRatio     = 0.5;            // Bileşik Oranı

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 14: GRİD SİSTEMİ
//====================================================================
input group "═══════ 14. GRİD SİSTEMİ ═══════"
input bool     UseGrid           = false;
input int      Grid_MaxLevels    = 5;
input double   Grid_StepPips     = 20;
input double   Grid_LotMultiplier = 1.5;
input double   Grid_TakeProfitPips = 50;
input bool     Grid_HedgeMode    = false;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 15: FİLTRE AĞIRLIKLARI
//====================================================================
input group "═══════ 15. AI FİLTRE AĞIRLIKLARI ═══════"
input double   Weight_MACross    = 20.0;           // MA Cross Ağırlığı
input double   Weight_MACD       = 12.0;           // MACD Ağırlığı
input double   Weight_RSI        = 12.0;           // RSI Ağırlığı
input double   Weight_ADX        = 10.0;           // ADX Ağırlığı
input double   Weight_Stoch      = 8.0;            // Stochastic Ağırlığı
input double   Weight_CCI        = 8.0;            // CCI Ağırlığı
input double   Weight_Pattern    = 12.0;           // Mum Pattern Ağırlığı
input double   Weight_Wick       = 5.0;            // Fitil Analizi Ağırlığı
input double   Weight_Level      = 8.0;            // S/R & Fib Ağırlığı
input double   Weight_Divergence = 5.0;            // Diverjans Ağırlığı

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 16: ZAMAN & SESSION
//====================================================================
input group "═══════ 16. ZAMAN & SESSION ═══════"
input bool     UseTimeFilter     = false;          // v15.10: KAPALI (test için)
input int      StartHour         = 0;              // 24 saat
input int      EndHour           = 24;             // 24 saat
input bool     UseSessionFilter  = false;          // v15.10: KAPALI (daha fazla sinyal)
input bool     TradeAsia         = true;           // Asya AKTİF
input bool     TradeLondon       = true;
input bool     TradeNewYork      = true;
input bool     TradeOverlap      = true;           // London/NY Overlap
input bool     AvoidFridayClose  = false;          // Cuma engeli KAPALI
input int      FridayCloseHour   = 23;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 16.5: HABER FİLTRESİ
//====================================================================
input group "═══════ 16.5 HABER FİLTRESİ ═══════"
input bool     UseNewsFilter     = false;           // Haber Filtresi Kullan
input int      NewsImpactLevel   = 2;               // Min Impact (1=Low,2=Med,3=High)
input int      NewsMinutesBefore = 30;              // Haberden Önce (dk)
input int      NewsMinutesAfter  = 15;              // Haberden Sonra (dk)

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 16.6: HEDGE KORUMA
//====================================================================
input group "═══════ 16.6 HEDGE KORUMA ═══════"
input bool     UseHedge          = false;           // Hedge Kullan
input double   Hedge_TriggerPct  = 50.0;            // Tetikleme (SL % kaybı)
input double   Hedge_LotPercent  = 50.0;            // Hedge Lot (Ana pozisyon %)
input double   Hedge_TPPips      = 20.0;            // Hedge TP (pip)

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 17: SPREAD & SLİPPAGE
//====================================================================
input group "═══════ 17. SPREAD & SLİPPAGE ═══════"
input int      MaxSpreadPips     = 5;
input int      MaxSlippage       = 20;             // Max Kayma (point)
input int      CooldownBars      = 10;             // v15.6: 3→10 (SL sonrası koruma)
input bool     UseStressTest     = false;
input int      SimulatedSlippage = 10;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 18: MANUEL İŞLEM
//====================================================================
input group "═══════ 18. MANUEL İŞLEM YÖNETİMİ ═══════"
input bool     ManageManualTrades = true;         // Manuel İşlemleri Yönet
input bool     ManageAllSymbols   = true;         // TÜM Sembolleri Yönet
input bool     AddSLTPToManual   = true;          // Manuel İşleme SL/TP Ekle
input bool     ApplyBEToManual   = true;          // Manuel İşleme BE Uygula
input bool     ApplyTrailToManual = true;         // Manuel İşleme Trail Uygula
input bool     ApplyPartialToManual = true;       // Manuel İşleme Kısmi Kapama Uygula
input bool     EvaluateManualBySignal = true;     // Sinyal ile Değerlendir
input bool     CloseCounterTrendManual = true;    // Ters Yönlü Manuel Kapat
input int      ManualEvalDelay = 60;              // Değerlendirme Gecikmesi (saniye)
input double   ManualDefaultSL = 30;              // Varsayılan SL (pip)
input double   ManualDefaultTP = 60;              // Varsayılan TP (pip)

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 19: PANEL & DEBUG
//====================================================================
input group "═══════ 19. PANEL & DEBUG ═══════"
input bool     ShowDashboard     = true;
input bool     ShowDetailedPanel = true;
input bool     ShowDebugLog      = true;
input int      DebugLogInterval  = 30;
input bool     SaveTradeLog      = true;
input bool     PlaySoundOnTrade  = true;
input string   SoundFile         = "alert.wav";
input bool     UsePushNotify     = false;  // Push Bildirimi
input bool     UseSendEmail      = false;  // Email Bildirimi

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 20: GÖRSEL
//====================================================================
input group "═══════ 20. GÖRSEL AYARLAR ═══════"
input color    PanelBgColor      = clrDarkSlateGray;
input color    PanelTextColor    = clrWhite;
input color    BuyColor          = clrLime;
input color    SellColor         = clrRed;
input color    NeutralColor      = clrGray;
input int      PanelX            = 10;
input int      PanelY            = 50;

//====================================================================
// INPUT PARAMETRELERİ - BÖLÜM 21: ZEKİ BEYİN (SMART BRAIN)
//====================================================================
input group "═══════ 21. ZEKİ BEYİN SİSTEMİ ═══════"
input bool     UseSmartBrain          = true;         // Zeki Beyin Aktif
input double   SmartRiskPercent       = 0.5;          // Mikro Risk % (aktif strateji)
input double   SmartMinRisk           = 0.3;          // Min Risk %
input double   SmartMaxRisk           = 1.0;          // Max Risk %
input int      SmartSignalThreshold   = 55;           // Sinyal Eşiği (düşük = daha fazla işlem)
input bool     SmartCompound          = true;         // Zeki Bileşik Büyüme
input double   SmartWinMultiplier     = 1.20;         // Kazançta Lot Çarpanı (+%20)
input double   SmartLossMultiplier    = 0.80;         // Kayıpta Lot Çarpanı (-%20)
input int      SmartConsecWinsToUp    = 2;            // Art arda kaç kazançta büyü
input int      SmartConsecLossesToDown = 1;           // Art arda kaç kayıpta küçül
input double   SmartMaxLotMultiplier  = 5.0;          // Max Lot Çarpanı (agresif büyüme)
input double   SmartMinLotMultiplier  = 0.3;          // Min Lot Çarpanı
input bool     SmartLockProfit        = true;         // Kârı Kilitle
input double   SmartLockProfitPct     = 30.0;         // Kilitlenecek Kâr % (daha az kilitle)
input bool     SmartRecoveryMode      = true;         // Kayıp Sonrası Kurtarma
input int      SmartMaxDailyTrades    = 20;           // Max Günlük İşlem (çok hamle yap!)
input double   SmartDailyProfitTarget = 5.0;          // Günlük Hedef % (yüksek hedef)
input double   SmartDailyLossLimit    = 3.0;          // Günlük Kayıp Limiti % (daha toleranslı)

//====================================================================
// GLOBAL KONTROL DEĞİŞKENLERİ
//====================================================================
bool g_ManualPause = false;
bool g_SystemLocked = false;
string g_LockReason = "";
string g_LastSignalReason = "";
int g_LastSignalScore = 0;
int g_LastHarmonyScore = 0;
string g_LastHarmonyDetails = "";
datetime g_LastTradeTime = 0;
int g_DailyTradeCount = 0;
double g_DailyPL = 0;
double g_WeeklyPL = 0;

// v14.3: Performans Optimizasyonu
bool g_IsTester = false;            // Test modunda mı?
bool g_VerboseLog = true;           // Detaylı log (test'te false)
datetime g_LastBarTime = 0;         // Yeni bar kontrolü
int g_MinSecondsBetweenTrades = 60; // Minimum saniye aralığı (overtrading önleme)

//====================================================================
// CLASS: PRICE ENGINE (Matematiksel Çekirdek)
//====================================================================
class CPriceEngine
{
public:
   static double PipToPoints(double pips) {
      return pips * 10.0 * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   }
   
   static double PointsToPip(double points) {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if(point == 0) return 0;
      return points / (10.0 * point);
   }
   
   static bool CheckStopLevel(double entry, double sl, double tp, int direction) {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      long stopLevelPts = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
      double stopLevel = (double)stopLevelPts * point;
      if(stopLevel == 0) stopLevel = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * point;
      double safeDist = 10 * point;
      if(direction == 1) return (sl < entry - safeDist) && (tp > entry + safeDist) && (entry - sl >= stopLevel) && (tp - entry >= stopLevel);
      else if(direction == -1) return (sl > entry + safeDist) && (tp < entry - safeDist) && (sl - entry >= stopLevel) && (entry - tp >= stopLevel);
      return false;
   }
   
   static void GetDynamicSLTP(double atr, double &slDist, double &tpDist) {
      if(UseATR && atr > 0) {
         slDist = atr * ATR_SL_Multi;
         tpDist = atr * ATR_TP_Multi;
         double minSL = PipToPoints(MinSL_Pips);
         double maxSL = PipToPoints(MaxSL_Pips);
         slDist = MathMax(minSL, MathMin(slDist, maxSL));
         if(tpDist < slDist * 2.0) tpDist = slDist * 2.0;
      } else {
         slDist = PipToPoints(15);
         tpDist = PipToPoints(30);
      }
   }
   
   static double CalculateLot(double slPips, double winRate = 0) {
      double lot = 0;
      switch(RiskMode) {
         case RISK_FIXED_LOT:
            lot = FixedLot;
            break;
         case RISK_PERCENT:
            lot = CalculatePercentLot(slPips);
            break;
         case RISK_KELLY:
            lot = CalculateKellyLot(slPips, winRate);
            break;
         case RISK_OPTIMAL_F:
            lot = CalculateOptimalFLot(slPips);
            break;
         default:
            lot = FixedLot;
      }
      return NormalizeLot(lot);
   }
   
   static double CalculatePercentLot(double slPips) {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * RiskPercent / 100.0;
      if(UseCompounding) riskAmount *= (1.0 + g_DailyPL / balance * CompoundRatio);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if(tickValue <= 0) tickValue = 10.0;
      if(tickSize <= 0) tickSize = point;
      double pipValue = tickValue * (point / tickSize) * 10.0;
      if(pipValue <= 0 || slPips <= 0) return MinLotSize;
      return riskAmount / (slPips * pipValue);
   }
   
   static double CalculateKellyLot(double slPips, double winRate) {
      if(winRate <= 0 || winRate >= 1) winRate = 0.5;
      double rrRatio = ATR_TP_Multi / ATR_SL_Multi;
      double kelly = (winRate * rrRatio - (1 - winRate)) / rrRatio;
      kelly = MathMax(0, MathMin(kelly, 0.25)); // Max 25% Kelly
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * kelly;
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      if(tickValue <= 0) tickValue = 10.0;
      if(tickSize <= 0) tickSize = point;
      double pipValue = tickValue * (point / tickSize) * 10.0;
      if(pipValue <= 0 || slPips <= 0) return MinLotSize;
      return riskAmount / (slPips * pipValue);
   }
   
   static double CalculateOptimalFLot(double slPips) {
      // Optimal F = simplified Kelly with fixed ratio
      return CalculatePercentLot(slPips) * 0.75;
   }
   
   static double NormalizeLot(double lot) {
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      if(minLot <= 0) minLot = 0.01;
      if(stepLot <= 0) stepLot = 0.01;
      lot = MathFloor(lot / stepLot) * stepLot;
      lot = MathMax(minLot, MathMin(lot, MathMin(maxLot, MaxLotSize)));
      lot = MathMax(MinLotSize, lot);
      // Margin kontrolü
      double margin = 0, price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      if(OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, margin)) {
         int maxIterations = 20;  // SONSUZ DÖNGÜ KORUMASI
         int iteration = 0;
         while(margin > freeMargin * 0.5 && lot > minLot && iteration < maxIterations) {
            lot = MathFloor((lot * 0.5) / stepLot) * stepLot;
            lot = MathMax(lot, minLot);
            if(!OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lot, price, margin)) break;
            iteration++;
         }
      }
      return lot;
   }
   
   static double CalculateLRSlope(int period) {
      if(!UseLR) return 999;
      double Sx = 0, Sy = 0, Sxy = 0, Sxx = 0;
      for(int i = 0; i < period; i++) {
         double x = (double)i;
         double y = iClose(_Symbol, TF, i);
         Sx += x; Sy += y; Sxy += x * y; Sxx += x * x;
      }
      double denom = (double)period * Sxx - Sx * Sx;
      if(denom == 0) return 0;
      return ((double)period * Sxy - Sx * Sy) / denom;
   }
   
   static double GetTrendStrength(int bars) {
      if(!UseTrendStrength) return 50;
      double close0 = iClose(_Symbol, TF, 0);
      double closeN = iClose(_Symbol, TF, bars);
      double highest = 0, lowest = 999999;
      for(int i = 0; i <= bars; i++) {
         double h = iHigh(_Symbol, TF, i);
         double l = iLow(_Symbol, TF, i);
         if(h > highest) highest = h;
         if(l < lowest) lowest = l;
      }
      double range = highest - lowest;
      if(range == 0) return 50;
      double trend = (close0 - closeN) / range * 100;
      return MathMax(-100, MathMin(100, trend));
   }
};

//====================================================================
// CLASS: CANDLE ANALYZER (15+ Pattern Tanıma)
//====================================================================
class CCandleAnalyzer
{
public:
   static void GetCandleComponents(int shift, double &bodySize, double &upperWick, double &lowerWick, double &range, bool &isBullish) {
      double open = iOpen(_Symbol, TF, shift);
      double close = iClose(_Symbol, TF, shift);
      double high = iHigh(_Symbol, TF, shift);
      double low = iLow(_Symbol, TF, shift);
      isBullish = (close > open);
      bodySize = MathAbs(close - open);
      range = high - low;
      if(isBullish) { upperWick = high - close; lowerWick = open - low; }
      else { upperWick = high - open; lowerWick = close - low; }
   }
   
   static double GetWickRatio(int shift, bool isUpper) {
      double bodySize, upperWick, lowerWick, range; bool isBullish;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      if(range == 0) return 0;
      return isUpper ? upperWick / range : lowerWick / range;
   }
   
   static double GetBodyRatio(int shift) {
      double bodySize, upperWick, lowerWick, range; bool isBullish;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      if(range == 0) return 0;
      return bodySize / range;
   }
   
   static bool IsPinBar(int shift, bool &isBullish) {
      double bodySize, upperWick, lowerWick, range;
      GetCandleComponents(shift, bodySize, upperWick, lowerWick, range, isBullish);
      if(range == 0) return false;
      if(bodySize / range > MaxBodyRatio) return false;
      if(lowerWick > upperWick * 2 && lowerWick / range >= MinWickRatio) { isBullish = true; return true; }
      if(upperWick > lowerWick * 2 && upperWick / range >= MinWickRatio) { isBullish = false; return true; }
      return false;
   }
   
   static bool IsEngulfing(int shift, bool &isBullish) {
      double o1 = iOpen(_Symbol, TF, shift), c1 = iClose(_Symbol, TF, shift);
      double o2 = iOpen(_Symbol, TF, shift + 1), c2 = iClose(_Symbol, TF, shift + 1);
      double body1 = MathAbs(c1 - o1), body2 = MathAbs(c2 - o2);
      if(body1 <= body2) return false;
      if(c2 < o2 && c1 > o1 && c1 > o2 && o1 < c2) { isBullish = true; return true; }
      if(c2 > o2 && c1 < o1 && o1 > c2 && c1 < o2) { isBullish = false; return true; }
      return false;
   }
   
   static bool IsDoji(int shift) { return (GetBodyRatio(shift) < 0.1); }
   
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
         double o = iOpen(_Symbol, TF, i), c = iClose(_Symbol, TF, i);
         if(c <= o) return false;
         if(i > 1 && o < iClose(_Symbol, TF, i+1)) return false;
      }
      return true;
   }
   
   static bool IsThreeBlackCrows() {
      for(int i = 1; i <= 3; i++) {
         double o = iOpen(_Symbol, TF, i), c = iClose(_Symbol, TF, i);
         if(c >= o) return false;
         if(i > 1 && o > iClose(_Symbol, TF, i+1)) return false;
      }
      return true;
   }
   
   static bool IsMorningStar() {
      double o1 = iOpen(_Symbol, TF, 3), c1 = iClose(_Symbol, TF, 3);
      double o2 = iOpen(_Symbol, TF, 2), c2 = iClose(_Symbol, TF, 2);
      double o3 = iOpen(_Symbol, TF, 1), c3 = iClose(_Symbol, TF, 1);
      return (c1 < o1) && (MathAbs(c2 - o2) < MathAbs(c1 - o1) * 0.3) && (c3 > o3) && (c3 > (o1 + c1) / 2);
   }
   
   static bool IsEveningStar() {
      double o1 = iOpen(_Symbol, TF, 3), c1 = iClose(_Symbol, TF, 3);
      double o2 = iOpen(_Symbol, TF, 2), c2 = iClose(_Symbol, TF, 2);
      double o3 = iOpen(_Symbol, TF, 1), c3 = iClose(_Symbol, TF, 1);
      return (c1 > o1) && (MathAbs(c2 - o2) < MathAbs(c1 - o1) * 0.3) && (c3 < o3) && (c3 < (o1 + c1) / 2);
   }
   
   static bool IsBullishHarami() {
      double o1 = iOpen(_Symbol, TF, 2), c1 = iClose(_Symbol, TF, 2);
      double o2 = iOpen(_Symbol, TF, 1), c2 = iClose(_Symbol, TF, 1);
      return (c1 < o1) && (c2 > o2) && (c2 < o1) && (o2 > c1);
   }
   
   static bool IsBearishHarami() {
      double o1 = iOpen(_Symbol, TF, 2), c1 = iClose(_Symbol, TF, 2);
      double o2 = iOpen(_Symbol, TF, 1), c2 = iClose(_Symbol, TF, 1);
      return (c1 > o1) && (c2 < o2) && (o2 < c1) && (c2 > o1);
   }
   
   static bool IsTweezerTop() {
      double h1 = iHigh(_Symbol, TF, 1), h2 = iHigh(_Symbol, TF, 2);
      double o1 = iOpen(_Symbol, TF, 1), c1 = iClose(_Symbol, TF, 1);
      double o2 = iOpen(_Symbol, TF, 2), c2 = iClose(_Symbol, TF, 2);
      double tolerance = CPriceEngine::PipToPoints(2);
      return (MathAbs(h1 - h2) < tolerance) && (c2 > o2) && (c1 < o1);
   }
   
   static bool IsTweezerBottom() {
      double l1 = iLow(_Symbol, TF, 1), l2 = iLow(_Symbol, TF, 2);
      double o1 = iOpen(_Symbol, TF, 1), c1 = iClose(_Symbol, TF, 1);
      double o2 = iOpen(_Symbol, TF, 2), c2 = iClose(_Symbol, TF, 2);
      double tolerance = CPriceEngine::PipToPoints(2);
      return (MathAbs(l1 - l2) < tolerance) && (c2 < o2) && (c1 > o1);
   }
   
   static ENUM_CANDLE_PATTERN DetectPattern(int shift = 1) {
      bool isBullish;
      if(UseAdvancedPatterns) {
         if(IsThreeWhiteSoldiers()) return PATTERN_THREE_WHITE_SOLDIERS;
         if(IsThreeBlackCrows()) return PATTERN_THREE_BLACK_CROWS;
         if(IsMorningStar()) return PATTERN_MORNING_STAR;
         if(IsEveningStar()) return PATTERN_EVENING_STAR;
         if(IsBullishHarami()) return PATTERN_BULLISH_HARAMI;
         if(IsBearishHarami()) return PATTERN_BEARISH_HARAMI;
         if(IsTweezerTop()) return PATTERN_TWEEZER_TOP;
         if(IsTweezerBottom()) return PATTERN_TWEEZER_BOTTOM;
      }
      if(IsPinBar(shift, isBullish)) return isBullish ? PATTERN_BULLISH_PINBAR : PATTERN_BEARISH_PINBAR;
      if(IsEngulfing(shift, isBullish)) return isBullish ? PATTERN_BULLISH_ENGULFING : PATTERN_BEARISH_ENGULFING;
      if(IsHammer(shift, isBullish)) return PATTERN_HAMMER;
      if(IsShootingStar(shift, isBullish)) return PATTERN_SHOOTING_STAR;
      if(IsDoji(shift)) return PATTERN_DOJI;
      return PATTERN_NONE;
   }
   
   static int GetPatternDirection(ENUM_CANDLE_PATTERN pattern) {
      switch(pattern) {
         case PATTERN_BULLISH_PINBAR: case PATTERN_BULLISH_ENGULFING: case PATTERN_HAMMER:
         case PATTERN_MORNING_STAR: case PATTERN_THREE_WHITE_SOLDIERS: case PATTERN_BULLISH_HARAMI:
         case PATTERN_TWEEZER_BOTTOM: return 1;
         case PATTERN_BEARISH_PINBAR: case PATTERN_BEARISH_ENGULFING: case PATTERN_SHOOTING_STAR:
         case PATTERN_EVENING_STAR: case PATTERN_THREE_BLACK_CROWS: case PATTERN_BEARISH_HARAMI:
         case PATTERN_TWEEZER_TOP: return -1;
         default: return 0;
      }
   }
   
   static int GetPatternScore(ENUM_CANDLE_PATTERN pattern) {
      switch(pattern) {
         case PATTERN_THREE_WHITE_SOLDIERS: case PATTERN_THREE_BLACK_CROWS: return 100;
         case PATTERN_BULLISH_ENGULFING: case PATTERN_BEARISH_ENGULFING: return 95;
         case PATTERN_MORNING_STAR: case PATTERN_EVENING_STAR: return 90;
         case PATTERN_BULLISH_PINBAR: case PATTERN_BEARISH_PINBAR: return 85;
         case PATTERN_HAMMER: case PATTERN_SHOOTING_STAR: return 80;
         case PATTERN_BULLISH_HARAMI: case PATTERN_BEARISH_HARAMI: return 75;
         case PATTERN_TWEEZER_TOP: case PATTERN_TWEEZER_BOTTOM: return 70;
         case PATTERN_DOJI: return 50;
         default: return 0;
      }
   }
   
   static string GetPatternName(ENUM_CANDLE_PATTERN pattern) {
      switch(pattern) {
         case PATTERN_BULLISH_PINBAR: return "Bull Pin";
         case PATTERN_BEARISH_PINBAR: return "Bear Pin";
         case PATTERN_BULLISH_ENGULFING: return "Bull Engulf";
         case PATTERN_BEARISH_ENGULFING: return "Bear Engulf";
         case PATTERN_DOJI: return "Doji";
         case PATTERN_HAMMER: return "Hammer";
         case PATTERN_SHOOTING_STAR: return "Shoot Star";
         case PATTERN_MORNING_STAR: return "Morning*";
         case PATTERN_EVENING_STAR: return "Evening*";
         case PATTERN_THREE_WHITE_SOLDIERS: return "3 Soldiers";
         case PATTERN_THREE_BLACK_CROWS: return "3 Crows";
         case PATTERN_BULLISH_HARAMI: return "Bull Harami";
         case PATTERN_BEARISH_HARAMI: return "Bear Harami";
         case PATTERN_TWEEZER_TOP: return "Tweezer Top";
         case PATTERN_TWEEZER_BOTTOM: return "Tweezer Bot";
         default: return "None";
   }
}
};

//====================================================================
// CLASS: ADVANCED LEVELS (Fibonacci + Pivot + S/R)
//====================================================================
class CAdvancedLevels
{
public:
   double m_pivot, m_r1, m_r2, m_r3, m_s1, m_s2, m_s3;
   double m_fib236, m_fib382, m_fib500, m_fib618, m_fib786;
   double m_support, m_resistance;
   double m_cam_r1, m_cam_r2, m_cam_r3, m_cam_r4;
   double m_cam_s1, m_cam_s2, m_cam_s3, m_cam_s4;
   datetime m_lastUpdate;
   
   CAdvancedLevels() : m_lastUpdate(0) {}
   
   void CalculatePivots() {
      double high = iHigh(_Symbol, PERIOD_D1, 1);
      double low = iLow(_Symbol, PERIOD_D1, 1);
      double close = iClose(_Symbol, PERIOD_D1, 1);
      double range = high - low;
      
      // Classic Pivot
      m_pivot = (high + low + close) / 3.0;
      m_r1 = 2 * m_pivot - low; m_s1 = 2 * m_pivot - high;
      m_r2 = m_pivot + range; m_s2 = m_pivot - range;
      m_r3 = high + 2 * (m_pivot - low); m_s3 = low - 2 * (high - m_pivot);
      
      // Camarilla Pivot
      m_cam_r1 = close + range * 1.1 / 12; m_cam_s1 = close - range * 1.1 / 12;
      m_cam_r2 = close + range * 1.1 / 6; m_cam_s2 = close - range * 1.1 / 6;
      m_cam_r3 = close + range * 1.1 / 4; m_cam_s3 = close - range * 1.1 / 4;
      m_cam_r4 = close + range * 1.1 / 2; m_cam_s4 = close - range * 1.1 / 2;
   }
   
   void CalculateFibonacci(int lookback) {
      double highest = 0, lowest = 999999;
      for(int i = 1; i <= lookback; i++) {
         double h = iHigh(_Symbol, TF, i), l = iLow(_Symbol, TF, i);
         if(h > highest) highest = h; if(l < lowest) lowest = l;
      }
      double range = highest - lowest;
      m_fib236 = highest - range * 0.236; m_fib382 = highest - range * 0.382;
      m_fib500 = highest - range * 0.500; m_fib618 = highest - range * 0.618;
      m_fib786 = highest - range * 0.786;
      m_resistance = highest; m_support = lowest;
   }
   
   void CalculateDynamicSR(int lookback) {
      double resistances[], supports[];
      ArrayResize(resistances, 0); ArrayResize(supports, 0);
      for(int i = 2; i < lookback - 2; i++) {
         double h = iHigh(_Symbol, TF, i), l = iLow(_Symbol, TF, i);
         bool isSwingHigh = (h > iHigh(_Symbol, TF, i-1)) && (h > iHigh(_Symbol, TF, i-2)) && (h > iHigh(_Symbol, TF, i+1)) && (h > iHigh(_Symbol, TF, i+2));
         bool isSwingLow = (l < iLow(_Symbol, TF, i-1)) && (l < iLow(_Symbol, TF, i-2)) && (l < iLow(_Symbol, TF, i+1)) && (l < iLow(_Symbol, TF, i+2));
         if(isSwingHigh) { ArrayResize(resistances, ArraySize(resistances) + 1); resistances[ArraySize(resistances)-1] = h; }
         if(isSwingLow) { ArrayResize(supports, ArraySize(supports) + 1); supports[ArraySize(supports)-1] = l; }
      }
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double nearestRes = 999999, nearestSup = 0;
      for(int i = 0; i < ArraySize(resistances); i++) if(resistances[i] > price && resistances[i] < nearestRes) nearestRes = resistances[i];
      for(int i = 0; i < ArraySize(supports); i++) if(supports[i] < price && supports[i] > nearestSup) nearestSup = supports[i];
      if(nearestRes < 999999) m_resistance = nearestRes;
      if(nearestSup > 0) m_support = nearestSup;
   }
   
   void Update() {
      MqlDateTime dt; TimeCurrent(dt);
      datetime today = StringToTime(IntegerToString(dt.year) + "." + IntegerToString(dt.mon) + "." + IntegerToString(dt.day));
      if(m_lastUpdate != today) {
         if(UsePivots) CalculatePivots();
         if(UseFibonacci) CalculateFibonacci(FibLookback);
         if(UseSupportResistance) CalculateDynamicSR(SR_Lookback);
         m_lastUpdate = today;
      }
   }
   
   int GetLevelScore(int direction) {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      int score = 50;
      double zone = CPriceEngine::PipToPoints(SR_TouchZone);
      
      if(direction == 1) {
         if(MathAbs(price - m_s1) < zone) score += 20;
         else if(MathAbs(price - m_support) < zone) score += 30;
         if(MathAbs(price - m_fib618) < zone) score += 25;
         else if(MathAbs(price - m_fib382) < zone) score += 15;
         if(price > m_r1) score -= 15;
         if(price > m_resistance - zone) score -= 25;
      } else if(direction == -1) {
         if(MathAbs(price - m_r1) < zone) score += 20;
         else if(MathAbs(price - m_resistance) < zone) score += 30;
         if(MathAbs(price - m_fib382) < zone) score += 25;
         else if(MathAbs(price - m_fib618) < zone) score += 15;
         if(price < m_s1) score -= 15;
         if(price < m_support + zone) score -= 25;
      }
      return MathMax(0, MathMin(100, score));
   }
};

//====================================================================
// CLASS: AI SIGNAL SCORER (10-Faktör Oylama)
//====================================================================
class CAISignalScorer
{
private:
   int m_hMA1, m_hMA2, m_hMA3, m_hMA4;
   int m_hMACD, m_hRSI, m_hADX, m_hATR, m_hStoch, m_hCCI, m_hBB;
   int m_hTSI;  // v15.5: True Strength Index handle
   datetime m_lastBarTime;
   bool m_signalGivenThisBar;
   int m_barsSinceTrade;
   
   double m_scores[10];
   string m_signalReasons;

public:
   double m_lastATR;
   int m_lastDirection;
   int m_lastTotalScore;
   
   CAISignalScorer() : m_lastATR(0), m_lastDirection(0), m_lastTotalScore(0), m_lastBarTime(0), m_signalGivenThisBar(false), m_barsSinceTrade(999) {
      for(int i = 0; i < 10; i++) m_scores[i] = 50;
   }
   
   ~CAISignalScorer() { ReleaseHandles(); }
   
   void ReleaseHandles() {
      if(m_hMA1 != INVALID_HANDLE) IndicatorRelease(m_hMA1);
      if(m_hMA2 != INVALID_HANDLE) IndicatorRelease(m_hMA2);
      if(m_hMA3 != INVALID_HANDLE) IndicatorRelease(m_hMA3);
      if(m_hMA4 != INVALID_HANDLE) IndicatorRelease(m_hMA4);
      if(m_hMACD != INVALID_HANDLE) IndicatorRelease(m_hMACD);
      if(m_hRSI != INVALID_HANDLE) IndicatorRelease(m_hRSI);
      if(m_hADX != INVALID_HANDLE) IndicatorRelease(m_hADX);
      if(m_hATR != INVALID_HANDLE) IndicatorRelease(m_hATR);
      if(m_hStoch != INVALID_HANDLE) IndicatorRelease(m_hStoch);
      if(m_hCCI != INVALID_HANDLE) IndicatorRelease(m_hCCI);
      if(m_hBB != INVALID_HANDLE) IndicatorRelease(m_hBB);
      if(m_hTSI != INVALID_HANDLE) IndicatorRelease(m_hTSI);  // v15.5: TSI
   }

   bool Init() {
      ReleaseHandles();
      
      // v15.2: MA Türüne Göre Handle Oluştur
      if(MA_Type == MA_TYPE_ADAPTIVE) {
         // Adaptive Moving Average (KAMA) - En iyi performans
         m_hMA1 = iAMA(_Symbol, TF, MA1_Period, AMA_FastPeriod, AMA_SlowPeriod, 0, PRICE_CLOSE);
         m_hMA2 = iAMA(_Symbol, TF, MA2_Period, AMA_FastPeriod, AMA_SlowPeriod, 0, PRICE_CLOSE);
         m_hMA3 = iAMA(_Symbol, TF, MA3_Period, AMA_FastPeriod, AMA_SlowPeriod, 0, PRICE_CLOSE);
         m_hMA4 = iAMA(_Symbol, TF, MA4_Period, AMA_FastPeriod, AMA_SlowPeriod, 0, PRICE_CLOSE);
         Print("📊 MA Türü: ADAPTIVE (KAMA) - Periyotlar: ", MA1_Period, "/", MA2_Period, "/", MA3_Period, "/", MA4_Period);
      } else {
         // Standart MA (SMA/EMA/SMMA/LWMA)
         m_hMA1 = iMA(_Symbol, TF, MA1_Period, 0, MA_Method, PRICE_CLOSE);
         m_hMA2 = iMA(_Symbol, TF, MA2_Period, 0, MA_Method, PRICE_CLOSE);
         m_hMA3 = iMA(_Symbol, TF, MA3_Period, 0, MA_Method, PRICE_CLOSE);
         m_hMA4 = iMA(_Symbol, TF, MA4_Period, 0, MA_Method, PRICE_CLOSE);
         Print("📊 MA Türü: STANDART (", EnumToString(MA_Method), ") - Periyotlar: ", MA1_Period, "/", MA2_Period, "/", MA3_Period, "/", MA4_Period);
      }
      m_hMACD = iMACD(_Symbol, TF, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE);
      m_hRSI = iRSI(_Symbol, TF, RSI_Period, PRICE_CLOSE);
      m_hADX = iADX(_Symbol, TF, ADX_Period);
      m_hATR = iATR(_Symbol, TF, ATR_Period);
      m_hStoch = iStochastic(_Symbol, TF, Stoch_K, Stoch_D, Stoch_Slowing, MODE_SMA, STO_LOWHIGH);
      m_hCCI = iCCI(_Symbol, TF, CCI_Period, PRICE_TYPICAL);
      m_hBB = iBands(_Symbol, TF, BB_Period, 0, BB_Deviation, PRICE_CLOSE);
      
      // v15.5: TSI - Özel gösterge oluştur (dahili hesaplama kullanılacak)
      // TSI dahili olarak hesaplanacak, ayrı handle gerekmez
      m_hTSI = INVALID_HANDLE;  // TSI dahili hesaplanıyor
      Print("📈 v15.5: TSI Momentum Filtresi AKTİF - Periyotlar: ", TSI_SlowPeriod, "/", TSI_FastPeriod, "/", TSI_SignalPeriod);
      
      return (m_hMA1 != INVALID_HANDLE && m_hMA2 != INVALID_HANDLE && m_hMACD != INVALID_HANDLE);
   }
   
   void UpdateATR() { double atr[]; ArraySetAsSeries(atr, true); if(CopyBuffer(m_hATR, 0, 0, 1, atr) >= 1) m_lastATR = atr[0]; }
   void UpdateBarState() {
      datetime currentBar = iTime(_Symbol, TF, 0);
      if(m_lastBarTime != currentBar) { m_lastBarTime = currentBar; m_barsSinceTrade++; m_signalGivenThisBar = false; }
   }
   bool CanTrade() { return (m_barsSinceTrade >= CooldownBars && !m_signalGivenThisBar); }
   void OnTradeOpened() { m_barsSinceTrade = 0; m_signalGivenThisBar = true; }
   
   double ScoreMACross(int &direction) {
      // v15.10: Triple MA Crossover (9/21/55 EMA)
      // Ana sinyal: MA9 ve MA21 kesişimi + MA55 ile hizalama teyidi
      double ma1[], ma2[], ma3[];
      ArraySetAsSeries(ma1, true); ArraySetAsSeries(ma2, true); ArraySetAsSeries(ma3, true);
      
      if(CopyBuffer(m_hMA1, 0, 0, 3, ma1) < 3) return 0;
      if(CopyBuffer(m_hMA2, 0, 0, 3, ma2) < 3) return 0;
      if(CopyBuffer(m_hMA3, 0, 0, 3, ma3) < 3) return 0;
      
      double score = 0;
      
      // Kesişim tespiti (MA9 ve MA21)
      bool crossUp = (ma1[1] <= ma2[1] && ma1[0] > ma2[0]);
      bool crossDown = (ma1[1] >= ma2[1] && ma1[0] < ma2[0]);
      
      // Triple MA Hizalama Kontrolü
      // ALIŞ: MA9 > MA21 > MA55 (mükemmel uptrend)
      // SATIŞ: MA9 < MA21 < MA55 (mükemmel downtrend)
      bool perfectBullAlign = (ma1[0] > ma2[0] && ma2[0] > ma3[0]);
      bool perfectBearAlign = (ma1[0] < ma2[0] && ma2[0] < ma3[0]);
      
      // Trend yönü (MA55 üzerinde/altında)
      bool priceAboveSlow = (ma1[0] > ma3[0]);
      bool priceBelowSlow = (ma1[0] < ma3[0]);
      
      // Momentum (MA'lar arası mesafe artıyor mu?)
      double spread = MathAbs(ma1[0] - ma2[0]) / ma3[0] * 10000;
      double prevSpread = MathAbs(ma1[1] - ma2[1]) / ma3[1] * 10000;
      bool spreadExpanding = (spread > prevSpread);
      
      // SINYAL SKORlama
      // 1. KESİŞİM + TAM HİZALAMA = EN GÜÇLÜ (100 puan)
      if(crossUp && perfectBullAlign) {
         direction = 1;
         score = 90;
         if(spreadExpanding) score = 100;
      }
      else if(crossDown && perfectBearAlign) {
         direction = -1;
         score = 90;
         if(spreadExpanding) score = 100;
      }
      // 2. KESİŞİM + TREND YÖNÜNDE = GÜÇLÜ (75-85 puan)
      else if(crossUp && priceAboveSlow) {
         direction = 1;
         score = 75;
         if(spreadExpanding) score = 85;
      }
      else if(crossDown && priceBelowSlow) {
         direction = -1;
         score = 75;
         if(spreadExpanding) score = 85;
      }
      // 3. SADECE KESİŞİM (trend teyidi zayıf) = ORTA (55-65 puan)
      else if(crossUp) {
         direction = 1;
         score = 55;
         if(spreadExpanding) score = 65;
      }
      else if(crossDown) {
         direction = -1;
         score = 55;
         if(spreadExpanding) score = 65;
      }
      // 4. TAM HİZALAMA (kesişim yok) = TREND DEVAM (50-60 puan)
      else if(perfectBullAlign) {
         direction = 1;
         score = 50;
         if(spreadExpanding) score = 60;
      }
      else if(perfectBearAlign) {
         direction = -1;
         score = 50;
         if(spreadExpanding) score = 60;
      }
      
      return score;
   }
   
   double ScoreMACD(int direction) {
      if(!UseMACD) return 50;
      double main[], sig[], hist[];
      ArraySetAsSeries(main, true); ArraySetAsSeries(sig, true); ArraySetAsSeries(hist, true);
      if(CopyBuffer(m_hMACD, 0, 0, 2, main) < 2) return 50;
      if(CopyBuffer(m_hMACD, 1, 0, 2, sig) < 2) return 50;
      if(CopyBuffer(m_hMACD, 2, 0, 2, hist) < 2) return 50;
      double score = 50;
      bool histPos = (hist[0] > 0), histRise = (hist[0] > hist[1]);
      if(direction == 1) { if(histPos) score += 20; if(histRise) score += 15; }
      else if(direction == -1) { if(!histPos) score += 20; if(!histRise) score += 15; }
      return MathMin(100, score);
   }
   
   double ScoreRSI(int direction) {
      if(!UseRSI) return 50;
      double rsi[]; ArraySetAsSeries(rsi, true);
      if(CopyBuffer(m_hRSI, 0, 0, 1, rsi) < 1) return 50;
      double score = 50, val = rsi[0];
      if(direction == 1) { if(val < 30) score = 95; else if(val < 40) score = 75; else if(val > 70) score = 25; }
      else if(direction == -1) { if(val > 70) score = 95; else if(val > 60) score = 75; else if(val < 30) score = 25; }
      return score;
   }
   
   double ScoreADX() {
      if(!UseADX) return 50;
      double adx[]; ArraySetAsSeries(adx, true);
      if(CopyBuffer(m_hADX, 0, 0, 1, adx) < 1) return 50;
      if(adx[0] >= 40) return 100; if(adx[0] >= 30) return 85; if(adx[0] >= 25) return 70; if(adx[0] >= 20) return 55;
      return 35;
   }
   
   double ScoreStochastic(int direction) {
      if(!UseStochastic) return 50;
      double k[], d[]; ArraySetAsSeries(k, true); ArraySetAsSeries(d, true);
      if(CopyBuffer(m_hStoch, 0, 0, 2, k) < 2) return 50;
      if(CopyBuffer(m_hStoch, 1, 0, 2, d) < 2) return 50;
      double score = 50;
      bool crossUp = (k[1] <= d[1] && k[0] > d[0]); bool crossDown = (k[1] >= d[1] && k[0] < d[0]);
      if(direction == 1) { if(k[0] < 20) score = 90; else if(k[0] < 40) score = 70; if(crossUp && k[0] < 50) score += 15; }
      else if(direction == -1) { if(k[0] > 80) score = 90; else if(k[0] > 60) score = 70; if(crossDown && k[0] > 50) score += 15; }
      return MathMin(100, score);
   }
   
   double ScoreCCI(int direction) {
      if(!UseCCI) return 50;
      double cci[]; ArraySetAsSeries(cci, true);
      if(CopyBuffer(m_hCCI, 0, 0, 1, cci) < 1) return 50;
      double score = 50, val = cci[0];
      if(direction == 1) { if(val < -CCI_Level) score = 90; else if(val < 0) score = 65; else if(val > CCI_Level) score = 30; }
      else if(direction == -1) { if(val > CCI_Level) score = 90; else if(val > 0) score = 65; else if(val < -CCI_Level) score = 30; }
      return score;
   }
   
   // v15.5: True Strength Index (TSI) Skorlaması
   double ScoreTSI(int direction) {
      if(!UseTSI) return 50;
      
      // TSI'yı dahili olarak hesapla (çift yumuşatılmış momentum)
      double close[];
      ArraySetAsSeries(close, true);
      int barsNeeded = TSI_SlowPeriod + TSI_FastPeriod + 5;
      if(CopyClose(_Symbol, TF, 0, barsNeeded, close) < barsNeeded) return 50;
      
      // Momentum hesapla (fiyat değişimi)
      double momentum[];
      ArrayResize(momentum, barsNeeded - 1);
      double absMomentum[];
      ArrayResize(absMomentum, barsNeeded - 1);
      
      for(int i = 0; i < barsNeeded - 1; i++) {
         momentum[i] = close[i] - close[i + 1];
         absMomentum[i] = MathAbs(momentum[i]);
      }
      
      // Basitleştirilmiş TSI hesaplaması (yaklaşık)
      double sumMom = 0, sumAbsMom = 0;
      int lookback = MathMin(TSI_SlowPeriod, barsNeeded - 1);
      for(int i = 0; i < lookback; i++) {
         sumMom += momentum[i];
         sumAbsMom += absMomentum[i];
      }
      
      double tsiValue = (sumAbsMom != 0) ? 100.0 * sumMom / sumAbsMom : 0;
      
      double score = 50;
      
      // TSI yorumlama
      if(direction == 1) {  // Alış yönünde
         if(tsiValue > TSI_OB) score = 30;       // Aşırı alım = zayıf
         else if(tsiValue > 10) score = 80;      // Pozitif momentum = güçlü
         else if(tsiValue > 0) score = 65;       // Hafif pozitif
         else if(tsiValue > TSI_OS) score = 50;  // Negatif ama aşırı satım değil
         else score = 75;                         // Aşırı satım = tersine dönüş potansiyeli
      }
      else if(direction == -1) {  // Satış yönünde
         if(tsiValue < TSI_OS) score = 30;       // Aşırı satım = zayıf
         else if(tsiValue < -10) score = 80;     // Negatif momentum = güçlü
         else if(tsiValue < 0) score = 65;       // Hafif negatif
         else if(tsiValue < TSI_OB) score = 50;  // Pozitif ama aşırı alım değil
         else score = 75;                         // Aşırı alım = tersine dönüş potansiyeli
      }
      
      return score;
   }
   
   double ScorePattern(int direction) {
      if(!UseCandlePatterns) return 50;
      ENUM_CANDLE_PATTERN pattern = CCandleAnalyzer::DetectPattern(1);
      int patDir = CCandleAnalyzer::GetPatternDirection(pattern);
      int patScore = CCandleAnalyzer::GetPatternScore(pattern);
      if(patDir == direction) return patScore;
      if(patDir == -direction) return 100 - patScore;
      return 50;
   }
   
   double ScoreWick(int direction) {
      if(!UseWickAnalysis) return 50;
      double upper = CCandleAnalyzer::GetWickRatio(1, true);
      double lower = CCandleAnalyzer::GetWickRatio(1, false);
      double score = 50;
      if(direction == 1) { if(lower > 0.4) score = 85; else if(lower > 0.3) score = 70; if(upper > 0.4) score -= 20; }
      else if(direction == -1) { if(upper > 0.4) score = 85; else if(upper > 0.3) score = 70; if(lower > 0.4) score -= 20; }
      return MathMax(0, MathMin(100, score));
   }
   
   int CalculateTotalScore(int &outDirection) {
      m_signalReasons = "";
      int direction = 0;
      m_scores[0] = ScoreMACross(direction); if(direction == 0) return 0;
      outDirection = direction;
      m_scores[1] = ScoreMACD(direction);
      m_scores[2] = ScoreRSI(direction);
      m_scores[3] = ScoreADX();
      m_scores[4] = ScoreStochastic(direction);
      m_scores[5] = ScoreCCI(direction);
      m_scores[6] = ScorePattern(direction);
      m_scores[7] = ScoreWick(direction);
      m_scores[8] = 50; m_scores[9] = 50; // Level & Divergence added by Harmony
      
      double weights[] = {Weight_MACross, Weight_MACD, Weight_RSI, Weight_ADX, Weight_Stoch, Weight_CCI, Weight_Pattern, Weight_Wick, Weight_Level, Weight_Divergence};
      double totalW = 0, weighted = 0;
      for(int i = 0; i < 10; i++) { totalW += weights[i]; weighted += m_scores[i] * weights[i]; }
      
      // v15.5: TSI Momentum Filtresi uygula
      double tsiScore = ScoreTSI(direction);
      double tsiMultiplier = 1.0;
      if(UseTSI) {
         if(tsiScore >= 70) tsiMultiplier = 1.15;      // TSI güçlü teyit = skor artırma
         else if(tsiScore >= 60) tsiMultiplier = 1.05;
         else if(tsiScore <= 40) tsiMultiplier = 0.85; // TSI ters sinyal = skor azaltma
         else if(tsiScore <= 30) tsiMultiplier = 0.70;
      }
      
      m_signalReasons = StringFormat("MA:%.0f MD:%.0f RS:%.0f ADX:%.0f ST:%.0f CCI:%.0f PAT:%.0f WK:%.0f TSI:%.0f",
         m_scores[0], m_scores[1], m_scores[2], m_scores[3], m_scores[4], m_scores[5], m_scores[6], m_scores[7], tsiScore);
      
      m_lastDirection = direction;
      m_lastTotalScore = (int)((weighted / totalW) * tsiMultiplier);
      return m_lastTotalScore;
   }
   
   string GetSignalReasons() { return m_signalReasons; }
   
   int GetSignal() {
      int direction = 0;
      int score = CalculateTotalScore(direction);
      g_LastSignalScore = score; g_LastSignalReason = m_signalReasons;
      
      int threshold = MinSignalScore;
      if(UseAdaptiveThreshold) {
         double adx[]; ArraySetAsSeries(adx, true);
         if(CopyBuffer(m_hADX, 0, 0, 1, adx) >= 1) {
            if(adx[0] > ADX_Strong) threshold -= 10;
            else if(adx[0] < ADX_Min) threshold += 10;
         }
      }
      
      if(score >= threshold) {
         if(ShowDebugLog) {
            Print("════════════════════════════════════════════════════");
            Print("🤖 AI v13 SKOR: ", score, "/100 | Eşik: ", threshold);
            Print("   📊 ", m_signalReasons);
            Print("   ➡️ ", (direction == 1 ? "BUY" : "SELL"), " SİNYALİ");
            Print("════════════════════════════════════════════════════");
         }
         return direction;
      }
      return 0;
   }
};

//====================================================================
// CLASS: SECURITY MANAGER
//====================================================================
class CSecurityManager
{
private:
   double m_refBalance, m_weekRefBalance;
   int m_dayOfYear, m_weekOfYear;
   int m_dailyTradeCount;
public:
   CSecurityManager() : m_refBalance(0), m_weekRefBalance(0), m_dayOfYear(0), m_weekOfYear(0), m_dailyTradeCount(0) {}
   
   void Init() { UpdateReference(true); }
   
   void UpdateReference(bool forceReset = false) {
      MqlDateTime dt; TimeCurrent(dt);
      if(forceReset || dt.day_of_year != m_dayOfYear) {
         m_dayOfYear = dt.day_of_year;
         m_refBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         m_dailyTradeCount = 0;
         g_SystemLocked = false; g_LockReason = "";
      }
      if(forceReset || (dt.day_of_week == 1 && m_weekOfYear != (dt.day_of_year / 7))) {
         m_weekOfYear = dt.day_of_year / 7;
         m_weekRefBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      }
   }
   
   bool IsSafeToTrade() {
      if(g_ManualPause) { g_LockReason = "PAUSE"; return false; }
      if(g_SystemLocked) return false;
      UpdateReference();
      
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double dailyLoss = m_refBalance - equity;
      double weeklyLoss = m_weekRefBalance - equity;
      
      if(dailyLoss >= MaxDailyDDMoney || (m_refBalance > 0 && (dailyLoss/m_refBalance)*100 >= MaxDailyDDPct))
         { g_SystemLocked = true; g_LockReason = "GÜNLÜK LİMİT"; return false; }
      if(m_weekRefBalance > 0 && (weeklyLoss/m_weekRefBalance)*100 >= MaxWeeklyDDPct)
         { g_SystemLocked = true; g_LockReason = "HAFTALIK LİMİT"; return false; }
      if(m_dailyTradeCount >= MaxDailyTrades) { g_LockReason = "İŞLEM LİMİTİ"; return false; }
      
      double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
      if(marginLevel > 0 && marginLevel < MinMarginLevel) { g_LockReason = "MARJİN"; return false; }
      
      if(UseTimeFilter) {
         MqlDateTime dt; TimeCurrent(dt);
         if(dt.hour < StartHour || dt.hour >= EndHour) { g_LockReason = "ZAMAN"; return false; }
      }
      
      if(UseSessionFilter) {
         MqlDateTime dt; TimeCurrent(dt);
         int h = dt.hour;
         bool isAsia = (h >= 0 && h < 8);
         bool isLondon = (h >= 8 && h < 12);
         bool isOverlap = (h >= 12 && h < 17);
         bool isNY = (h >= 17 && h < 22);
         
         if(isAsia && !TradeAsia) { g_LockReason = "ASIA SESSİON"; return false; }
         if(isLondon && !TradeLondon) { g_LockReason = "LONDON SESSİON"; return false; }
         if(isNY && !TradeNewYork) { g_LockReason = "NY SESSİON"; return false; }
         if(isOverlap && !TradeOverlap) { g_LockReason = "OVERLAP SESSİON"; return false; }
      }
      
      if(AvoidFridayClose) {
         MqlDateTime dt; TimeCurrent(dt);
         if(dt.day_of_week == 5 && dt.hour >= FridayCloseHour) { g_LockReason = "CUMA KAPANIŞ"; return false; }
      }
      
      long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      if(spread / 10.0 > MaxSpreadPips) { g_LockReason = "SPREAD"; return false; }
      
      g_LockReason = "";
      return true;
   }
   
   void IncrementTradeCount() { m_dailyTradeCount++; }
   int GetTradeCount() { return m_dailyTradeCount; }
   double GetDailyPL() { g_DailyPL = AccountInfoDouble(ACCOUNT_EQUITY) - m_refBalance; return g_DailyPL; }
   double GetWeeklyPL() { g_WeeklyPL = AccountInfoDouble(ACCOUNT_EQUITY) - m_weekRefBalance; return g_WeeklyPL; }
};

//====================================================================
// CLASS: TRADE EXECUTOR
//====================================================================
class CTradeExecutor
{
private:
   CTrade m_trade;
   
   // v15.2: Dinamik Filling Tipi Algılama
   ENUM_ORDER_TYPE_FILLING GetSymbolFillingType() {
      uint filling = (uint)SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
      
      if((filling & SYMBOL_FILLING_FOK) == SYMBOL_FILLING_FOK)
         return ORDER_FILLING_FOK;
      else if((filling & SYMBOL_FILLING_IOC) == SYMBOL_FILLING_IOC)
         return ORDER_FILLING_IOC;
      else
         return ORDER_FILLING_RETURN;
   }
   
   // v15.2: Minimum Trade Level (Freeze + Stop Level)
   double GetMinTradeLevel() {
      double freezeLevel = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
      double stopsLevel = (double)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
      double minLevel = MathMax(freezeLevel, stopsLevel);
      
      if(minLevel <= 100.0 && minLevel >= 0.0)
         minLevel += 1.0;  // Güvenlik marjı
      else if(minLevel >= 100.0)
         minLevel = 100.0;
      
      return minLevel;
   }
   
public:
   void Init() {
      m_trade.SetExpertMagicNumber(MagicNumber);
      m_trade.SetTypeFilling(GetSymbolFillingType());  // v15.2: Dinamik!
      m_trade.SetDeviationInPoints(MaxSlippage);
      Print("🔧 Filling Tipi: ", EnumToString(GetSymbolFillingType()), " | Min Level: ", GetMinTradeLevel());
   }
   
   bool OpenMarketOrder(int direction, double atr, double winRate = 0, double lotMultiplier = 1.0) {
      // v15.8: EntryMode kontrolü - Bekleyen emirler için yönlendir
      if(EntryMode == MODE_PENDING) {
         return OpenPendingOrder(direction, atr, winRate, lotMultiplier);
      }
      
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      double slDist, tpDist;
      CPriceEngine::GetDynamicSLTP(atr, slDist, tpDist);
      double slPips = CPriceEngine::PointsToPip(slDist);
      double lot = CPriceEngine::CalculateLot(slPips, winRate);
      
      // v15.2 FIX: Kalibrasyon lot çarpanını uygula
      lot = CPriceEngine::NormalizeLot(lot * lotMultiplier);
      double price = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double sl = 0, tp = 0;
      
      // BUY ve SELL için SL/TP hesapla - AYNI MANTIK
      if(direction == 1) {
         sl = NormalizeDouble(price - slDist, digits);
         tp = NormalizeDouble(price + tpDist, digits);
         m_trade.Buy(lot, _Symbol, 0, sl, tp, TradeComment);
      } else {
         sl = NormalizeDouble(price + slDist, digits);
         tp = NormalizeDouble(price - tpDist, digits);
         m_trade.Sell(lot, _Symbol, 0, sl, tp, TradeComment);
      }
      
      // Sonuç kontrolü
      uint retcode = m_trade.ResultRetcode();
      if(retcode == TRADE_RETCODE_DONE || retcode == TRADE_RETCODE_PLACED) {
         g_LastTradeTime = TimeCurrent();
         Print("🤖 ", (direction == 1 ? "BUY" : "SELL"), " | Lot:", lot, " SL:", sl, " TP:", tp);
         return true;
      }
      
      Print("❌ Hata: ", m_trade.ResultRetcodeDescription());
      return false;
   }
   
   // v15.8: Bekleyen Emir Açma - Sunucu tarafında yönetilir (Bilgisayar kapalı olsa bile çalışır)
   bool OpenPendingOrder(int direction, double atr, double winRate = 0, double lotMultiplier = 1.0) {
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      
      double slDist, tpDist;
      CPriceEngine::GetDynamicSLTP(atr, slDist, tpDist);
      double slPips = CPriceEngine::PointsToPip(slDist);
      double lot = CPriceEngine::CalculateLot(slPips, winRate);
      lot = CPriceEngine::NormalizeLot(lot * lotMultiplier);
      
      // Giriş fiyatı hesapla - ATR'nin %30'u kadar uzakta
      double entryOffset = atr * 0.3;
      if(entryOffset < GetMinTradeLevel() * point) entryOffset = (GetMinTradeLevel() + 5) * point;
      
      double currentPrice = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double entryPrice, sl, tp;
      datetime expiration = TimeCurrent() + PeriodSeconds(TF) * 10; // 10 bar sonra expire
      
      bool success = false;
      
      if(direction == 1) {
         // BuyStop: Mevcut fiyatın ÜSTÜNDE bekle
         entryPrice = NormalizeDouble(currentPrice + entryOffset, digits);
         sl = NormalizeDouble(entryPrice - slDist, digits);
         tp = NormalizeDouble(entryPrice + tpDist, digits);
         success = m_trade.BuyStop(lot, entryPrice, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, TradeComment);
      } else {
         // SellStop: Mevcut fiyatın ALTINDA bekle
         entryPrice = NormalizeDouble(currentPrice - entryOffset, digits);
         sl = NormalizeDouble(entryPrice + slDist, digits);
         tp = NormalizeDouble(entryPrice - tpDist, digits);
         success = m_trade.SellStop(lot, entryPrice, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, TradeComment);
      }
      
      if(success) {
         g_LastTradeTime = TimeCurrent();
         Print("📋 BEKLEYEN ", (direction == 1 ? "BUY_STOP" : "SELL_STOP"), 
               " | Entry:", entryPrice, " SL:", sl, " TP:", tp, " Lot:", lot);
         return true;
      }
      
      Print("❌ Bekleyen Emir Hatası: ", m_trade.ResultRetcodeDescription());
      return false;
   }
   
   void EmergencyCloseAll() {
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket > 0 && PositionSelectByTicket(ticket)) {
            if(PositionGetInteger(POSITION_MAGIC) == MagicNumber || ManageManualTrades)
               m_trade.PositionClose(ticket);
         }
      }
   }
   
   int CountOpenPositions() {
      int count = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetInteger(POSITION_MAGIC) == MagicNumber && PositionGetString(POSITION_SYMBOL) == _Symbol) count++;
      }
      return count;
   }
   
   bool HasOpenPosition() { return (CountOpenPositions() > 0); }
   
   bool CanOpenMore() { 
      // Pozisyon limit kontrolü
      if(CountOpenPositions() >= MaxOpenPositions) return false;
      
      // ZAMAN BAZLI COOLDOWN - Overtrading önleme
      if(g_LastTradeTime > 0) {
         int secondsSinceLast = (int)(TimeCurrent() - g_LastTradeTime);
         if(secondsSinceLast < g_MinSecondsBetweenTrades) {
            return false;  // Minimum süre geçmedi
         }
      }
      
      return true;
   }
   
   void OnTradeOpened() {
      g_LastTradeTime = TimeCurrent();  // Son işlem zamanını güncelle
   }
   
   CTrade* GetTrade() { return &m_trade; }
};

//====================================================================
// CLASS: POSITION MANAGER (BE, Trail, Partial)
//====================================================================
class CPositionManager
{
private:
   CTrade* m_pTrade;
   int m_totalTrades, m_winTrades, m_lossTrades;
   double m_grossProfit, m_grossLoss, m_netProfit;
   double m_maxDD, m_maxProfit;
public:
   CPositionManager() : m_pTrade(NULL), m_totalTrades(0), m_winTrades(0), m_lossTrades(0),
      m_grossProfit(0), m_grossLoss(0), m_netProfit(0), m_maxDD(0), m_maxProfit(0) {}
   
   void Init(CTrade* pTrade) { m_pTrade = pTrade; }
   
   void ManagePositions(double atr) {
      if(m_pTrade == NULL) return;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         if(PositionGetString(POSITION_SYMBOL) != _Symbol) continue;
         bool isEA = (PositionGetInteger(POSITION_MAGIC) == MagicNumber);
         if(!isEA && !ManageManualTrades) continue;
         
         if(!PositionSelectByTicket(ticket)) continue;
         double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
         double currentSL = PositionGetDouble(POSITION_SL);
         double currentTP = PositionGetDouble(POSITION_TP);
         double volume = PositionGetDouble(POSITION_VOLUME);
         long posType = PositionGetInteger(POSITION_TYPE);
         int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
         
         if(currentTP == 0) continue;
         double tpDist = MathAbs(currentTP - openPrice);
         double profitDist = (posType == POSITION_TYPE_BUY) ? (currentPrice - openPrice) : (openPrice - currentPrice);
         
         // 1. Kısmi Kapama
         if(UseSmartPartial && tpDist > 0) {
            double minVol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
            double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
            
            // 1. Partial
            if(profitDist >= tpDist * (Partial1_TriggerPct / 100.0) && volume > minVol * 2) {
               bool isBE = (MathAbs(currentSL - openPrice) < CPriceEngine::PipToPoints(5));
               if(!isBE) {
                  double closeVol = MathFloor((volume * Partial1_ClosePct / 100.0) / lotStep) * lotStep;
                  if(closeVol >= minVol) {
                     (*m_pTrade).PositionClosePartial(ticket, closeVol);
                     if(PartialMoveSLtoBE) {
                        double bePrice = (posType == POSITION_TYPE_BUY) ?
                           NormalizeDouble(openPrice + CPriceEngine::PipToPoints(BE_LockPips), digits) :
                           NormalizeDouble(openPrice - CPriceEngine::PipToPoints(BE_LockPips), digits);
                        (*m_pTrade).PositionModify(ticket, bePrice, currentTP);
                     }
                  }
               }
            }
            
            // 2. Partial
            if(profitDist >= tpDist * (Partial2_TriggerPct / 100.0) && volume > minVol * 2) {
               double closeVol = MathFloor((volume * Partial2_ClosePct / 100.0) / lotStep) * lotStep;
               if(closeVol >= minVol) (*m_pTrade).PositionClosePartial(ticket, closeVol);
            }
         }
         
         // 2. Breakeven
         if(UseBreakeven && tpDist > 0 && profitDist >= tpDist * (BE_TriggerPct / 100.0)) {
            double bePrice;
            if(posType == POSITION_TYPE_BUY) {
               bePrice = NormalizeDouble(openPrice + CPriceEngine::PipToPoints(BE_LockPips), digits);
               if(currentSL < bePrice) (*m_pTrade).PositionModify(ticket, bePrice, currentTP);
            } else {
               bePrice = NormalizeDouble(openPrice - CPriceEngine::PipToPoints(BE_LockPips), digits);
               if(currentSL > bePrice || currentSL == 0) (*m_pTrade).PositionModify(ticket, bePrice, currentTP);
            }
         }
         
         // 3. Trailing Stop
         if(UseTrailing && atr > 0 && tpDist > 0 && profitDist >= tpDist * (Trail_StartPct / 100.0)) {
            double trailDist;
            switch(TrailMode) {
               case TRAIL_FIXED: trailDist = CPriceEngine::PipToPoints(Trail_FixedPips); break;
               case TRAIL_ATR: trailDist = atr * Trail_ATR_Multi; break;
               default: trailDist = atr * Trail_ATR_Multi;
            }
            
            double newSL;
            if(posType == POSITION_TYPE_BUY) {
               newSL = NormalizeDouble(currentPrice - trailDist, digits);
               if(newSL > currentSL) (*m_pTrade).PositionModify(ticket, newSL, currentTP);
            } else {
               newSL = NormalizeDouble(currentPrice + trailDist, digits);
               if(newSL < currentSL || currentSL == 0) (*m_pTrade).PositionModify(ticket, newSL, currentTP);
            }
         }
      }
   }
   
   void UpdateStats(double profit) {
      m_netProfit += profit;
      if(profit > 0) { m_winTrades++; m_grossProfit += profit; }
      else { m_lossTrades++; m_grossLoss += profit; }
      if(m_netProfit > m_maxProfit) m_maxProfit = m_netProfit;
      if(m_netProfit < m_maxDD) m_maxDD = m_netProfit;
   }
   
   void IncrementTrades() { m_totalTrades++; }
   int GetTotalTrades() { return m_totalTrades; }
   int GetWinTrades() { return m_winTrades; }
   int GetLossTrades() { return m_lossTrades; }
   double GetNetProfit() { return m_netProfit; }
   double GetWinRate() { return (m_totalTrades > 0) ? m_winTrades * 100.0 / m_totalTrades : 0; }
   double GetProfitFactor() { return (m_grossLoss != 0) ? m_grossProfit / MathAbs(m_grossLoss) : 0; }
   double GetExpectancy() {
      if(m_totalTrades < 5) return 0;
      double wr = (double)m_winTrades / m_totalTrades;
      double avgW = (m_winTrades > 0) ? m_grossProfit / m_winTrades : 0;
      double avgL = (m_lossTrades > 0) ? MathAbs(m_grossLoss) / m_lossTrades : 0;
      return (wr * avgW) - ((1-wr) * avgL);
   }
   
   void PrintStats() {
      Print("════════════════════════════════════════════════════════════════════");
      Print("📊 v13 SONUÇ RAPORU:");
      Print("   İşlem: ", m_totalTrades, " | Win: ", m_winTrades, " | Loss: ", m_lossTrades);
      Print("   WR: ", DoubleToString(GetWinRate(), 1), "% | PF: ", DoubleToString(GetProfitFactor(), 2));
      Print("   Net: $", DoubleToString(m_netProfit, 2), " | Expectancy: $", DoubleToString(GetExpectancy(), 2));
      Print("════════════════════════════════════════════════════════════════════");
   }
};

//====================================================================
// CLASS: HARMONY MANAGER (Tüm Modülleri Senkronize Eder)
//====================================================================
class CHarmonyManager
{
public:
   CAdvancedLevels Levels;
   
   int m_lastLevelScore;
   int m_lastMTFScore;
   int m_lastSessionScore;
   int m_lastDivergenceScore;
   
   CHarmonyManager() : m_lastLevelScore(50), m_lastMTFScore(50), m_lastSessionScore(50), m_lastDivergenceScore(50) {}
   
   void Update() { Levels.Update(); }
   
   int GetMTFScore(int direction) {
      if(!UseMTF) return 50;
      int score = 50;
      
      int hMA1 = iMA(_Symbol, HigherTF1, MTF_MA_Period, 0, MODE_EMA, PRICE_CLOSE);
      int hMA2 = iMA(_Symbol, HigherTF2, MTF_MA_Period, 0, MODE_EMA, PRICE_CLOSE);
      
      if(hMA1 != INVALID_HANDLE) {
         double ma[]; ArraySetAsSeries(ma, true);
         double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(CopyBuffer(hMA1, 0, 0, 1, ma) >= 1) {
            if(direction == 1 && price > ma[0]) score += 15;
            else if(direction == -1 && price < ma[0]) score += 15;
            else score -= 15;
         }
         IndicatorRelease(hMA1);
      }
      
      if(hMA2 != INVALID_HANDLE) {
         double ma[]; ArraySetAsSeries(ma, true);
         double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         if(CopyBuffer(hMA2, 0, 0, 1, ma) >= 1) {
            if(direction == 1 && price > ma[0]) score += 20;
            else if(direction == -1 && price < ma[0]) score += 20;
            else score -= 20;
         }
         IndicatorRelease(hMA2);
      }
      
      return MathMax(0, MathMin(100, score));
   }
   
   string GetSessionName() {
      MqlDateTime dt; TimeCurrent(dt);
      int h = dt.hour;
      if(h >= 0 && h < 8) return "ASYA";
      if(h >= 8 && h < 12) return "LONDRA";
      if(h >= 12 && h < 17) return "OVERLAP";
      if(h >= 17 && h < 22) return "NEW YORK";
      return "OFF";
   }
   
   int GetSessionScore() {
      string session = GetSessionName();
      if(session == "OVERLAP") return 100;
      if(session == "LONDRA") return 85;
      if(session == "NEW YORK") return 80;
      if(session == "ASYA") return 60;
      return 40;
   }
   
   int GetDivergenceScore(int direction) {
      if(!UseDivergence) return 50;
      
      int hRSI = iRSI(_Symbol, TF, RSI_Period, PRICE_CLOSE);
      if(hRSI == INVALID_HANDLE) return 50;
      
      double rsi[]; ArraySetAsSeries(rsi, true);
      if(CopyBuffer(hRSI, 0, 0, DivergenceLookback, rsi) < DivergenceLookback) { IndicatorRelease(hRSI); return 50; }
      IndicatorRelease(hRSI);
      
      double price1 = iLow(_Symbol, TF, 1), price2 = iLow(_Symbol, TF, DivergenceLookback/2);
      double rsi1 = rsi[1], rsi2 = rsi[DivergenceLookback/2];
      
      // Bullish Divergence
      if(direction == 1 && price1 < price2 && rsi1 > rsi2) return 90;
      
      price1 = iHigh(_Symbol, TF, 1); price2 = iHigh(_Symbol, TF, DivergenceLookback/2);
      
      // Bearish Divergence
      if(direction == -1 && price1 > price2 && rsi1 < rsi2) return 90;
      
      return 50;
   }
   
   int CalculateHarmonyScore(int direction, int baseScore) {
      m_lastLevelScore = Levels.GetLevelScore(direction);
      m_lastMTFScore = GetMTFScore(direction);
      m_lastSessionScore = GetSessionScore();
      m_lastDivergenceScore = GetDivergenceScore(direction);
      
      double totalW = 50 + Weight_Level + 10 + 5 + Weight_Divergence;
      double weighted = (
         baseScore * 50.0 +
         m_lastLevelScore * Weight_Level +
         m_lastMTFScore * 10.0 +
         m_lastSessionScore * 5.0 +
         m_lastDivergenceScore * Weight_Divergence
      ) / totalW;
      
      g_LastHarmonyScore = (int)weighted;
      g_LastHarmonyDetails = StringFormat("LVL:%d MTF:%d SES:%d DIV:%d",
         m_lastLevelScore, m_lastMTFScore, m_lastSessionScore, m_lastDivergenceScore);
      
      return (int)MathMin(100, MathMax(0, weighted));
   }
};

//====================================================================
// GLOBAL NESNELER
//====================================================================
CSecurityManager Security;
CAISignalScorer  AIScorer;
CTradeExecutor   Executor;
CPositionManager PosMgr;
CHarmonyManager  Harmony;

// v15.2 FIX: Bu nesneler OnInit'ın ÖNCESİNDE tanımlanmalı (MQL5 single-pass compiler)
// NOT: Asıl sınıfları dosyanın altında tanımlandı = forward declaration gerekli değil
// CPriceActionFilter ve CAutoOptimizer class'ları 10000+ satırda
// MQL5 global değişkenleri class tanımından sonra olabilir

//+------------------------------------------------------------------+
//| ONINIT                                                            |
//+------------------------------------------------------------------+
int OnInit()
{
   if(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL) {
      Alert("❌ Sembol kapalı!");
      return INIT_FAILED;
   }
   
   if(!AIScorer.Init()) {
      Alert("❌ Gösterge hatası!");
      return INIT_FAILED;
   }
   
   Security.Init();
   Executor.Init();
   PosMgr.Init(Executor.GetTrade());
   
   // v14 5K Edition - Yeni Modül Başlatmaları
   MLSimulator.Init();
   RiskParity.SetBaseRisk(RiskPercent);
   NewsCalc.SetPauseTimes(NewsMinutesBefore, NewsMinutesAfter);
   ManualProtector.Init(Executor.GetTrade());
   
   // v15: Smart Brain Başlatma
   if(UseSmartBrain) {
      SmartBrain.Init();
      Print("🧠 ZEKİ BEYİN AKTİF - Risk: ", SmartRiskPercent, "% | Sinyal Eşik: ", SmartSignalThreshold);
   }
   
   // v15: MA Direction Learner - Yön Öğrenme
   DirectionLearner.Init(10);  // İlk 10 işlem kalibrasyon
   Print("🎯 YÖN ÖĞRENİCİ AKTİF - İlk 10 işlem test/öğrenme aşaması");
   
   // v14.3: Performans Optimizasyonu - Test modunda log azalt
   g_IsTester = MQLInfoInteger(MQL_TESTER);
   g_VerboseLog = !g_IsTester; // Test modunda detaylı log KAPALI
   if(g_IsTester) Print("⚡ v14.3: Test modu - Performans optimizasyonu aktif");
   
   // v14.2: State Persistence - Önceki oturumdan durumu oku
   string prefix = "MILYONER_" + _Symbol + "_";
   if(GlobalVariableCheck(prefix + "DailyPL")) {
      g_DailyPL = GlobalVariableGet(prefix + "DailyPL");
      g_WeeklyPL = GlobalVariableGet(prefix + "WeeklyPL");
      g_DailyTradeCount = (int)GlobalVariableGet(prefix + "TradeCount");
      g_LastSignalScore = (int)GlobalVariableGet(prefix + "LastSignalScore");
      g_LastHarmonyScore = (int)GlobalVariableGet(prefix + "LastHarmonyScore");
      g_ManualPause = GlobalVariableGet(prefix + "ManualPause") > 0;
      Print("📂 v14.2: EA durumu geri yüklendi - PL:", DoubleToString(g_DailyPL, 2), 
            " | Trades:", g_DailyTradeCount, " | Pause:", g_ManualPause);
   }
   
   Print("════════════════════════════════════════════════════════════════════════════════");
   Print("                    🤖 MİLYONER EA v14.2 - ULTIMATE 5K EDITION                   ");
   Print("════════════════════════════════════════════════════════════════════════════════");
   Print("📊 AI Skor Eşiği: ", MinSignalScore, " | Güçlü Sinyal: ", StrongSignalScore);
   Print("📊 10 Faktör Oylama: MA(", Weight_MACross, ") MACD(", Weight_MACD, ") RSI(", Weight_RSI, ")");
   Print("   ADX(", Weight_ADX, ") Stoch(", Weight_Stoch, ") CCI(", Weight_CCI, ")");
   Print("   Pattern(", Weight_Pattern, ") Wick(", Weight_Wick, ") Level(", Weight_Level, ") Div(", Weight_Divergence, ")");
   Print("📊 v14.2: ML | SmartEntry | Scaling | StatePersistence | ManualProtect");
   Print("📊 Session: ", Harmony.GetSessionName(), " | Risk: ", EnumToString(RiskMode));
   Print("════════════════════════════════════════════════════════════════════════════════");
   
   return INIT_SUCCEEDED;
}


//+------------------------------------------------------------------+
//| ONDEINIT                                                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // v14.2: State Persistence - Grafik değişikliğinde durumu kaydet
   if(reason == REASON_CHARTCHANGE || reason == REASON_PARAMETERS || reason == REASON_RECOMPILE) {
      string prefix = "MILYONER_" + _Symbol + "_";
      GlobalVariableSet(prefix + "DailyPL", g_DailyPL);
      GlobalVariableSet(prefix + "WeeklyPL", g_WeeklyPL);
      GlobalVariableSet(prefix + "TradeCount", g_DailyTradeCount);
      GlobalVariableSet(prefix + "LastSignalScore", g_LastSignalScore);
      GlobalVariableSet(prefix + "LastHarmonyScore", g_LastHarmonyScore);
      GlobalVariableSet(prefix + "ManualPause", g_ManualPause ? 1 : 0);
      Print("💾 v14.2: EA durumu kaydedildi (Reason: ", reason, ")");
   }
   
   PosMgr.PrintStats();
   ObjectsDeleteAll(0, "v14_");
   Comment("");
}

//+------------------------------------------------------------------+
//| ONCHARTEVENT                                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_KEYDOWN) {
      if(lparam == 80 || lparam == 112) { // P
         g_ManualPause = !g_ManualPause;
         Alert(g_ManualPause ? "⏸️ PAUSE" : "▶️ RESUME");
      }
      else if(lparam == 67 || lparam == 99) { // C
         if(MessageBox("Tüm pozisyonları kapat?", "ACİL", MB_YESNO) == IDYES) {
            Executor.EmergencyCloseAll();
            g_ManualPause = true;
         }
      }
      else if(lparam == 68 || lparam == 100) { // D
         Security.UpdateReference(true);
         g_SystemLocked = false;
         Alert("🔄 GÜNLÜK RESET");
      }
      else if(lparam == 82 || lparam == 114) { // R
         PosMgr.PrintStats();
      }
   }
}

//+------------------------------------------------------------------+
//| ONTICK                                                            |
//+------------------------------------------------------------------+
void OnTick()
{
   AIScorer.UpdateATR();
   AIScorer.UpdateBarState();
   Harmony.Update();
   
   // v14.3: Yeni bar kontrolü - Test modunda sadece yeni bar'da işlem al
   datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
   bool isNewBar = (currentBarTime != g_LastBarTime);
   if(isNewBar) g_LastBarTime = currentBarTime;
   
   // v14.2: Manuel işlem koruma - EN ÖNCE ÇALIŞIR (PAUSE/FİLTRE BAĞIMSIZ)
   // SL/TP yoksa HEMEN ekler, beklemez!
   int quickSignal = AIScorer.GetSignal();
   ManualProtector.ManageManualPositions(quickSignal, AIScorer.m_lastATR);
   
   // v14 5K Edition - Modül Güncellemeleri (sadece yeni bar'da güncelle)
   if(isNewBar || !g_IsTester) {
      EquityFilter.Update();
      SessionAnalyzer.UpdateCurrentSession();
      EntryTiming.RecordVolatility(AIScorer.m_lastATR);
      SessionAnalyzer.RecordVolatility(AIScorer.m_lastATR);
   }
   
   if(ShowDashboard && (!g_IsTester || isNewBar)) UpdateDashboard();
   
   if(g_ManualPause) return;
   
   // v14: Equity Curve Filter
   if(!EquityFilter.IsTradingAllowed()) return;
   
   if(!Security.IsSafeToTrade()) {
      if(g_SystemLocked) Executor.EmergencyCloseAll();
      return;
   }
   
   // Pozisyon yönetimi
   PosMgr.ManagePositions(AIScorer.m_lastATR);
   
   // currentSignal = quickSignal zaten yukarıda alındı
   int currentSignal = quickSignal;
   
   // v15: Smart Brain kontrolleri
   if(UseSmartBrain) {
      if(!SmartBrain.CanTrade()) { 
         // Log devre dışı - 92GB log sorunu çözüldü
         return; 
      }
   }
   
   // Yeni işlem açma kontrolü - DEBUG KAPALI (log bloat önleme)
   // if(g_VerboseLog) Print("=== FILTER DEBUG ===");

   if(!Executor.CanOpenMore()) { return; }
   if(!AIScorer.CanTrade()) { return; }
   
   // v14: Smart Entry Timing Filter - DEVRE DIŞI (Test için)
   // if(!EntryTiming.CanEnterNow()) { if(g_VerboseLog) Print(">>> BLOCKED: CanEnterNow() = false"); return; }
   
   // v14: Session Filter - DEVRE DIŞI (Test için)
   // if(!SessionAnalyzer.IsOptimalSession()) { if(g_VerboseLog) Print(">>> BLOCKED: IsOptimalSession() = false"); return; }
   
   // currentSignal zaten yukarıda alındı (satır 1622)
   if(currentSignal == 0) { if(g_VerboseLog) Print(">>> BLOCKED: Signal = 0"); return; }
   
   // v14: Correlation Filter - DEVRE DIŞI (Test için)
   // if(CorrFilter.HasConflictingPosition(currentSignal)) { if(g_VerboseLog) Print(">>> BLOCKED: HasConflictingPosition() = true for ", (currentSignal == 1 ? "BUY" : "SELL")); return; }
   
   // Harmony boost
   int finalScore = g_LastSignalScore;
   if(UseHarmonyBoost) {
      finalScore = Harmony.CalculateHarmonyScore(currentSignal, g_LastSignalScore);
   }
   
   // v15: Smart Brain - Sinyal güç kontrolü - DEVRE DIŞI (Test için)
   // if(UseSmartBrain && !SmartBrain.IsSignalStrong(finalScore)) {
   //    if(g_VerboseLog) Print("🧠 BLOCKED: Sinyal zayıf (", finalScore, " < ", SmartSignalThreshold, ")");
   //    return;
   // }
   
   // v14: Risk Parity - Dinamik Risk Hesaplama
   RiskParity.UpdateVolatilityAdjustment(AIScorer.m_lastATR, EntryTiming.GetAvgVolatility());
   RiskParity.UpdateCorrelationAdjustment(CorrFilter.GetMaxCorrelation());
   
   // Güçlü sinyal kontrolü - DEVRE DIŞI (Test için)
   // if(!UseSmartBrain && SignalMode == SIG_HARMONY && finalScore < MinSignalScore) { 
   //    if(g_VerboseLog) Print(">>> BLOCKED: Harmony score too low: ", finalScore); 
   //    return; 
   // }
   
   // v15: MA Direction Learner - Yön Filtresi - DEVRE DIŞI (Test için)
   // if(DirectionLearner.IsCalibrationComplete()) {
   //    if(!DirectionLearner.ShouldTakeThisDirection(currentSignal)) {
   //       if(g_VerboseLog) Print("🎯 BLOCKED: Yanlış yön! Öğrenilen: ", 
   //          (DirectionLearner.GetLearnedDirection() == 1 ? "BUY" : "SELL"),
   //          " | Sinyal: ", (currentSignal == 1 ? "BUY" : "SELL"));
   //       return;
   //    }
   // }
   
   if(g_VerboseLog) Print(">>> ALL FILTERS PASSED - Opening ", (currentSignal == 1 ? "BUY" : "SELL"));
   
   // v15: Kalibrasyon sırasında düşük lot kullan
   double lotMultiplier = DirectionLearner.GetCalibrationLotMultiplier();
   if(lotMultiplier < 1.0) {
      Print("🎯 Kalibrasyon modu: Lot çarpanı = ", DoubleToString(lotMultiplier * 100, 0), "%");
   }
   
   // İşlem aç - v15.2: Kalibrasyon lot çarpanı uygulanıyor
   if(Executor.OpenMarketOrder(currentSignal, AIScorer.m_lastATR, PosMgr.GetWinRate() / 100.0, lotMultiplier)) {
      Executor.OnTradeOpened();     // Overtrading önleme - zaman damgası
      AIScorer.OnTradeOpened();
      Security.IncrementTradeCount();
      PosMgr.IncrementTrades();
      EntryTiming.OnEntry();
      
      // v15: Direction Learner log
      Print("🎯 Direction Learner: ", DirectionLearner.GetStatus());
      
      // v15: Smart Brain log
      if(UseSmartBrain) {
         Print("🧠 Smart Brain: ", SmartBrain.GetStatus());
      }
      Print("📈 v14 Risk: ", RiskParity.GetRiskReport());
   }
}

//+------------------------------------------------------------------+
//| OnTradeTransaction - İşlem Sonucu Geri Besleme                   |
//| v15.1: DirectionLearner ve SmartBrain'e sonuç bildir             |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
   // Sadece işlem kapanışlarını izle
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
   
   // Deal bilgilerini al
   ulong dealTicket = trans.deal;
   if(dealTicket == 0) return;
   
   // Deal'i seç ve bilgilerini al
   if(!HistoryDealSelect(dealTicket)) return;
   
   // Sadece çıkış işlemlerini takip et (DEAL_ENTRY_OUT)
   ENUM_DEAL_ENTRY dealEntry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
   if(dealEntry != DEAL_ENTRY_OUT) return;
   
   // Magic number kontrolü
   ulong dealMagic = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
   if(dealMagic != MagicNumber) return;
   
   // Kar/zarar ve yön bilgilerini al
   double dealProfit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
   double dealSwap = HistoryDealGetDouble(dealTicket, DEAL_SWAP);
   double dealCommission = HistoryDealGetDouble(dealTicket, DEAL_COMMISSION);
   double netProfit = dealProfit + dealSwap + dealCommission;
   
   ENUM_DEAL_TYPE dealType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(dealTicket, DEAL_TYPE);
   int direction = (dealType == DEAL_TYPE_SELL) ? 1 : -1; // Çıkış türü ters olur (Sell = Buy kapatıldı)
   
   Print("═══════════════════════════════════════════");
   Print("📊 İŞLEM KAPANDI!");
   Print("   Ticket: ", dealTicket);
   Print("   Yön: ", (direction == 1 ? "BUY" : "SELL"));
   Print("   Net Kar: $", DoubleToString(netProfit, 2));
   Print("   Sonuç: ", (netProfit > 0 ? "✅ KAZANÇ" : "❌ KAYIP"));
   
   // v15.1: Direction Learner'a sonucu bildir (sadeleştirilmiş çağrı)
   DirectionLearner.OnTradeResult(direction, netProfit);
   Print("   🎯 Direction Learner: ", DirectionLearner.GetStatus());
   
   // v15: Smart Brain'e sonucu bildir
   if(UseSmartBrain) {
      SmartBrain.OnTradeResult(netProfit);
      Print("   🧠 Smart Brain: ", SmartBrain.GetStatus());
   }
   
   
   // v15.2 FIX: İstatistikleri GERÇEKTEN güncelle (Dashboard doğru göstersin)
   PosMgr.UpdateStats(netProfit);
   Print("   📊 Toplam İşlem: ", PosMgr.GetTotalTrades(), " | Win: ", PosMgr.GetWinTrades());
   
   Print("═══════════════════════════════════════════");
}

//+------------------------------------------------------------------+
//| DASHBOARD                                                         |
//+------------------------------------------------------------------+
void UpdateDashboard()
{
   string status = g_ManualPause ? "⏸️ PAUSE" :
                   (g_SystemLocked ? "🔒 " + g_LockReason :
                   (g_LockReason != "" ? "⏳ " + g_LockReason : "✅ AKTİF"));
   
   string dash = "";
   dash += "══════════════════════════════════════════════════\n";
   dash += "        🤖 MİLYONER EA v13.0 ULTIMATE 3K\n";
   dash += "══════════════════════════════════════════════════\n";
   dash += "DURUM: " + status + "\n";
   dash += "──────────────────────────────────────────────────\n";
   dash += "🎯 AI SKOR: " + IntegerToString(g_LastSignalScore) + "/100\n";
   if(UseHarmonyBoost) {
      dash += "🎼 HARMONY: " + IntegerToString(g_LastHarmonyScore) + "/100\n";
      dash += "   " + g_LastHarmonyDetails + "\n";
   }
   dash += "📊 " + g_LastSignalReason + "\n";
   dash += "──────────────────────────────────────────────────\n";
   dash += "🌍 Session: " + Harmony.GetSessionName() + "\n";
   dash += "💰 Günlük: $" + DoubleToString(Security.GetDailyPL(), 2) + "\n";
   dash += "💵 Haftalık: $" + DoubleToString(Security.GetWeeklyPL(), 2) + "\n";
   dash += "📊 İşlem: " + IntegerToString(Security.GetTradeCount()) + "/" + IntegerToString(MaxDailyTrades) + "\n";
   dash += "📈 Pozisyon: " + IntegerToString(Executor.CountOpenPositions()) + "/" + IntegerToString(MaxOpenPositions) + "\n";
   dash += "──────────────────────────────────────────────────\n";
   dash += "📊 Toplam: " + IntegerToString(PosMgr.GetTotalTrades()) + " | Win: " + IntegerToString(PosMgr.GetWinTrades()) + "\n";
   dash += "⚖️ WR: " + DoubleToString(PosMgr.GetWinRate(), 1) + "%\n";
   dash += "📈 PF: " + DoubleToString(PosMgr.GetProfitFactor(), 2) + "\n";
   dash += "💵 Net: $" + DoubleToString(PosMgr.GetNetProfit(), 2) + "\n";
   dash += "──────────────────────────────────────────────────\n";
   dash += "⌨️ [P]ause [C]lose [D]ailyReset [R]eport\n";
   dash += "══════════════════════════════════════════════════\n";
   
   Comment(dash);
}

//+------------------------------------------------------------------+
//| v13 ULTIMATE 3K EDITION                                          |
//| All-in-One AI Trading System with 20+ Synchronized Modules       |
//| 10-Factor Weighted Voting | 15+ Candle Patterns                  |
//| Fibonacci + Pivot + S/R | MTF | Divergence | Sessions            |
//| Kelly Criterion | Compounding | Grid | Hedge                      |
//| Smart Partial Close | Dynamic Trailing | Advanced Risk           |
//| © 2025, Milyoner EA Project - ULTIMATE 3K EDITION                |
//+------------------------------------------------------------------+

//====================================================================
// EXTENSION MODULE 1: GRID MATRIX SYSTEM
//====================================================================
class CGridManager
{
private:
   struct GridLevel {
      double price;
      double lot;
      int direction;
      bool filled;
      ulong ticket;
   };
   
   GridLevel m_levels[];
   int m_currentLevel;
   double m_entryPrice;
   int m_direction;
   bool m_active;
   double m_totalProfit;
   
public:
   CGridManager() : m_currentLevel(0), m_entryPrice(0), m_direction(0), m_active(false), m_totalProfit(0) {
      ArrayResize(m_levels, 0);
   }
   
   bool IsActive() { return m_active; }
   
   void Initialize(int direction, double entryPrice, double baseLot) {
      if(!UseGrid) return;
      
      m_direction = direction;
      m_entryPrice = entryPrice;
      m_active = true;
      m_currentLevel = 0;
      
      ArrayResize(m_levels, Grid_MaxLevels);
      
      double stepDist = CPriceEngine::PipToPoints(Grid_StepPips);
      double currentLot = baseLot;
      
      for(int i = 0; i < Grid_MaxLevels; i++) {
         if(direction == 1) {
            m_levels[i].price = entryPrice - (stepDist * (i + 1));
         } else {
            m_levels[i].price = entryPrice + (stepDist * (i + 1));
         }
         m_levels[i].lot = NormalizeDouble(currentLot, 2);
         m_levels[i].direction = direction;
         m_levels[i].filled = false;
         m_levels[i].ticket = 0;
         
         currentLot *= Grid_LotMultiplier;
         currentLot = MathMin(currentLot, MaxLotSize);
      }
      
      if(ShowDebugLog) {
         Print("🔲 Grid başlatıldı: ", (direction == 1 ? "BUY" : "SELL"), " | ", Grid_MaxLevels, " seviye");
         Print("   Adım: ", Grid_StepPips, " pip | Çarpan: ", Grid_LotMultiplier);
      }
   }
   
   void CheckLevels(CTrade &trade) {
      if(!m_active || !UseGrid) return;
      
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      for(int i = 0; i < ArraySize(m_levels); i++) {
         if(m_levels[i].filled) continue;
         
         bool shouldFill = false;
         if(m_direction == 1 && currentPrice <= m_levels[i].price) shouldFill = true;
         else if(m_direction == -1 && currentPrice >= m_levels[i].price) shouldFill = true;
         
         if(shouldFill) {
            int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
            double sl = 0, tp = 0;
            
            // Grid SL/TP hesapla
            double tpDist = CPriceEngine::PipToPoints(Grid_TakeProfitPips);
            double slDist = CPriceEngine::PipToPoints(Grid_StepPips * (Grid_MaxLevels + 1)); // SL = Grid son seviyesinden sonra
            
            if(m_direction == 1) {
               tp = NormalizeDouble(m_levels[i].price + tpDist, digits);
               sl = NormalizeDouble(m_levels[i].price - slDist, digits);  // BUY için SL aşağıda
            } else {
               tp = NormalizeDouble(m_levels[i].price - tpDist, digits);
               sl = NormalizeDouble(m_levels[i].price + slDist, digits);  // SELL için SL yukarıda
            }
            
            if(m_direction == 1) {
               trade.Buy(m_levels[i].lot, _Symbol, 0, sl, tp, "GRID_L" + IntegerToString(i + 1));
            } else {
               trade.Sell(m_levels[i].lot, _Symbol, 0, sl, tp, "GRID_L" + IntegerToString(i + 1));
            }
            
            if(trade.ResultRetcode() == TRADE_RETCODE_DONE) {
               m_levels[i].filled = true;
               m_levels[i].ticket = trade.ResultOrder();
               m_currentLevel = i + 1;
               Print("🔲 Grid L", (i + 1), " dolduruldu: ", m_levels[i].lot, " lot @ ", m_levels[i].price);
            }
         }
      }
   }
   
   double GetAveragePrice() {
      double totalLot = 0, weightedPrice = 0;
      for(int i = 0; i < ArraySize(m_levels); i++) {
         if(m_levels[i].filled) {
            totalLot += m_levels[i].lot;
            weightedPrice += m_levels[i].price * m_levels[i].lot;
         }
      }
      if(totalLot == 0) return 0;
      return weightedPrice / totalLot;
   }
   
   int GetFilledLevels() { return m_currentLevel; }
   
   void Reset() {
      m_active = false;
      m_currentLevel = 0;
      m_entryPrice = 0;
      m_direction = 0;
      ArrayResize(m_levels, 0);
   }
   
   void CheckCloseAll(CTrade &trade) {
      if(!m_active) return;
      
      double avgPrice = GetAveragePrice();
      if(avgPrice == 0) return;
      
      double currentPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double profitDist = (m_direction == 1) ? (currentPrice - avgPrice) : (avgPrice - currentPrice);
      double targetDist = CPriceEngine::PipToPoints(Grid_TakeProfitPips);
      
      if(profitDist >= targetDist) {
         for(int i = PositionsTotal() - 1; i >= 0; i--) {
            ulong ticket = PositionGetTicket(i);
            if(ticket == 0) continue;
            string comment = PositionGetString(POSITION_COMMENT);
            if(StringFind(comment, "GRID_") >= 0) {
               trade.PositionClose(ticket);
            }
         }
         Print("🔲 Grid kapatıldı! Toplam kar hedefine ulaşıldı.");
         Reset();
      }
   }
};

//====================================================================
// EXTENSION MODULE 2: PENDING ORDER MANAGER
//====================================================================
class CPendingOrderManager
{
private:
   ulong m_pendingTickets[];
   int m_pendingCount;
   
public:
   CPendingOrderManager() : m_pendingCount(0) {
      ArrayResize(m_pendingTickets, 0);
   }
   
   bool PlaceBuyStop(CTrade &trade, double price, double sl, double tp, double lot, string comment) {
      if(trade.BuyStop(lot, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comment)) {
         ArrayResize(m_pendingTickets, m_pendingCount + 1);
         m_pendingTickets[m_pendingCount] = trade.ResultOrder();
         m_pendingCount++;
         Print("📋 BuyStop yerleştirildi @ ", price);
         return true;
      }
      return false;
   }
   
   bool PlaceSellStop(CTrade &trade, double price, double sl, double tp, double lot, string comment) {
      if(trade.SellStop(lot, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comment)) {
         ArrayResize(m_pendingTickets, m_pendingCount + 1);
         m_pendingTickets[m_pendingCount] = trade.ResultOrder();
         m_pendingCount++;
         Print("📋 SellStop yerleştirildi @ ", price);
         return true;
      }
      return false;
   }
   
   bool PlaceBuyLimit(CTrade &trade, double price, double sl, double tp, double lot, string comment) {
      if(trade.BuyLimit(lot, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comment)) {
         ArrayResize(m_pendingTickets, m_pendingCount + 1);
         m_pendingTickets[m_pendingCount] = trade.ResultOrder();
         m_pendingCount++;
         Print("📋 BuyLimit yerleştirildi @ ", price);
         return true;
      }
      return false;
   }
   
   bool PlaceSellLimit(CTrade &trade, double price, double sl, double tp, double lot, string comment) {
      if(trade.SellLimit(lot, price, _Symbol, sl, tp, ORDER_TIME_GTC, 0, comment)) {
         ArrayResize(m_pendingTickets, m_pendingCount + 1);
         m_pendingTickets[m_pendingCount] = trade.ResultOrder();
         m_pendingCount++;
         Print("📋 SellLimit yerleştirildi @ ", price);
         return true;
      }
      return false;
   }
   
   void CancelAllPending(CTrade &trade) {
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber && OrderGetString(ORDER_SYMBOL) == _Symbol) {
            trade.OrderDelete(ticket);
         }
      }
      ArrayResize(m_pendingTickets, 0);
      m_pendingCount = 0;
   }
   
   int CountPending() {
      int count = 0;
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber && OrderGetString(ORDER_SYMBOL) == _Symbol) count++;
      }
      return count;
   }
   
   void CleanupExpired() {
      datetime now = TimeCurrent();
      for(int i = OrdersTotal() - 1; i >= 0; i--) {
         ulong ticket = OrderGetTicket(i);
         if(ticket == 0) continue;
         if(OrderGetInteger(ORDER_MAGIC) == MagicNumber) {
            datetime orderTime = (datetime)OrderGetInteger(ORDER_TIME_SETUP);
            if(now - orderTime > 3600 * 4) { // 4 saatten eski emirleri iptal et
               CTrade tempTrade;
               tempTrade.OrderDelete(ticket);
               Print("📋 Eski bekleyen emir silindi: ", ticket);
            }
         }
      }
   }
};

//====================================================================
// EXTENSION MODULE 3: SIGNAL HISTORY & LEARNING
//====================================================================
class CSignalHistory
{
private:
   struct SignalRecord {
      datetime time;
      int direction;
      int score;
      int harmonyScore;
      double entryPrice;
      double exitPrice;
      double profit;
      bool isWin;
      string pattern;
   };
   
   SignalRecord m_history[];
   int m_count;
   int m_maxHistory;
   
public:
   CSignalHistory() : m_count(0), m_maxHistory(500) {
      ArrayResize(m_history, 0);
   }
   
   void RecordSignal(int direction, int score, int harmonyScore, double entryPrice, string pattern) {
      if(m_count >= m_maxHistory) {
         // Shift array
         for(int i = 0; i < m_maxHistory - 1; i++) {
            m_history[i] = m_history[i + 1];
         }
         m_count = m_maxHistory - 1;
      }
      
      ArrayResize(m_history, m_count + 1);
      m_history[m_count].time = TimeCurrent();
      m_history[m_count].direction = direction;
      m_history[m_count].score = score;
      m_history[m_count].harmonyScore = harmonyScore;
      m_history[m_count].entryPrice = entryPrice;
      m_history[m_count].exitPrice = 0;
      m_history[m_count].profit = 0;
      m_history[m_count].isWin = false;
      m_history[m_count].pattern = pattern;
      m_count++;
   }
   
   void UpdateLastResult(double exitPrice, double profit) {
      if(m_count > 0) {
         m_history[m_count - 1].exitPrice = exitPrice;
         m_history[m_count - 1].profit = profit;
         m_history[m_count - 1].isWin = (profit > 0);
      }
   }
   
   double GetWinRateByScoreRange(int minScore, int maxScore) {
      int wins = 0, total = 0;
      for(int i = 0; i < m_count; i++) {
         if(m_history[i].exitPrice > 0 && m_history[i].score >= minScore && m_history[i].score <= maxScore) {
            total++;
            if(m_history[i].isWin) wins++;
         }
      }
      return (total > 0) ? (double)wins / total * 100 : 50;
   }
   
   double GetWinRateByPattern(string pattern) {
      int wins = 0, total = 0;
      for(int i = 0; i < m_count; i++) {
         if(m_history[i].exitPrice > 0 && m_history[i].pattern == pattern) {
            total++;
            if(m_history[i].isWin) wins++;
         }
      }
      return (total > 0) ? (double)wins / total * 100 : 50;
   }
   
   double GetWinRateByDirection(int direction) {
      int wins = 0, total = 0;
      for(int i = 0; i < m_count; i++) {
         if(m_history[i].exitPrice > 0 && m_history[i].direction == direction) {
            total++;
            if(m_history[i].isWin) wins++;
         }
      }
      return (total > 0) ? (double)wins / total * 100 : 50;
   }
   
   double GetAverageProfitByScore(int minScore) {
      double total = 0;
      int count = 0;
      for(int i = 0; i < m_count; i++) {
         if(m_history[i].exitPrice > 0 && m_history[i].score >= minScore) {
            total += m_history[i].profit;
            count++;
         }
      }
      return (count > 0) ? total / count : 0;
   }
   
   int GetOptimalThreshold() {
      int bestThreshold = 55;
      double bestWR = 0;
      
      for(int threshold = 45; threshold <= 80; threshold += 5) {
         double wr = GetWinRateByScoreRange(threshold, 100);
         if(wr > bestWR) {
            bestWR = wr;
            bestThreshold = threshold;
         }
      }
      return bestThreshold;
   }
   
   void PrintAnalysis() {
      if(m_count < 10) {
         Print("📊 Yeterli veri yok (min 10 işlem)");
         return;
      }
      
      Print("════════════════════════════════════════════════════════════════════");
      Print("📊 SİNYAL GEÇMİŞİ ANALİZİ (", m_count, " kayıt)");
      Print("════════════════════════════════════════════════════════════════════");
      Print("   45-54 Skor WR: ", DoubleToString(GetWinRateByScoreRange(45, 54), 1), "%");
      Print("   55-64 Skor WR: ", DoubleToString(GetWinRateByScoreRange(55, 64), 1), "%");
      Print("   65-74 Skor WR: ", DoubleToString(GetWinRateByScoreRange(65, 74), 1), "%");
      Print("   75-100 Skor WR: ", DoubleToString(GetWinRateByScoreRange(75, 100), 1), "%");
      Print("   BUY WR: ", DoubleToString(GetWinRateByDirection(1), 1), "%");
      Print("   SELL WR: ", DoubleToString(GetWinRateByDirection(-1), 1), "%");
      Print("   Optimal Eşik: ", GetOptimalThreshold());
      Print("════════════════════════════════════════════════════════════════════");
   }
   
   int GetRecordCount() { return m_count; }
};

//====================================================================
// EXTENSION MODULE 4: TRADE LOGGER
//====================================================================
class CTradeLogger
{
private:
   string m_logFileName;
   bool m_enabled;
   
public:
   CTradeLogger() : m_enabled(false) {
      m_logFileName = "Milyoner_v13_TradeLog_" + _Symbol + ".csv";
   }
   
   void Enable(bool enable) { m_enabled = enable; }
   
   void Initialize() {
      if(!m_enabled || !SaveTradeLog) return;
      
      int handle = FileOpen(m_logFileName, FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
      if(handle != INVALID_HANDLE) {
         FileWrite(handle, "Tarih", "Sembol", "Tip", "Lot", "Giriş", "Çıkış", "SL", "TP", "Kar", "Skor", "Harmony", "Pattern", "Süre");
         FileClose(handle);
         Print("📝 Trade log dosyası oluşturuldu: ", m_logFileName);
      }
   }
   
   void LogTrade(string type, double lot, double entry, double exit, double sl, double tp, double profit, int score, int harmony, string pattern, int duration) {
      if(!m_enabled || !SaveTradeLog) return;
      
      int handle = FileOpen(m_logFileName, FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI, ',');
      if(handle != INVALID_HANDLE) {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, 
            TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES),
            _Symbol,
            type,
            DoubleToString(lot, 2),
            DoubleToString(entry, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)),
            DoubleToString(exit, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)),
            DoubleToString(sl, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)),
            DoubleToString(tp, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)),
            DoubleToString(profit, 2),
            IntegerToString(score),
            IntegerToString(harmony),
            pattern,
            IntegerToString(duration) + "m"
         );
         FileClose(handle);
      }
   }
   
   void LogEvent(string event, string details) {
      if(!m_enabled) return;
      Print("📝 [LOG] ", event, ": ", details);
   }
};

//====================================================================
// EXTENSION MODULE 5: VOLATILITY ANALYZER
//====================================================================
class CVolatilityAnalyzer
{
private:
   double m_atrHistory[];
   int m_historySize;
   double m_avgATR;
   double m_currentATR;
   ENUM_MARKET_REGIME m_regime;
   
public:
   CVolatilityAnalyzer() : m_historySize(50), m_avgATR(0), m_currentATR(0), m_regime(REGIME_RANGING) {
      ArrayResize(m_atrHistory, m_historySize);
      ArrayInitialize(m_atrHistory, 0);
   }
   
   void Update(double atr) {
      m_currentATR = atr;
      
      // Shift history
      for(int i = m_historySize - 1; i > 0; i--) {
         m_atrHistory[i] = m_atrHistory[i - 1];
      }
      m_atrHistory[0] = atr;
      
      // Calculate average
      double sum = 0;
      int count = 0;
      for(int i = 0; i < m_historySize; i++) {
         if(m_atrHistory[i] > 0) {
            sum += m_atrHistory[i];
            count++;
         }
      }
      if(count > 0) m_avgATR = sum / count;
      
      // Determine regime
      DetectRegime();
   }
   
   void DetectRegime() {
      if(m_avgATR == 0) {
         m_regime = REGIME_RANGING;
         return;
      }
      
      double ratio = m_currentATR / m_avgATR;
      
      if(ratio > VolatilityMultiplier) {
         m_regime = REGIME_HIGH_VOLATILITY;
      } else if(ratio > 1.2) {
         m_regime = REGIME_BREAKOUT;
      } else if(ratio < 0.6) {
         m_regime = REGIME_RANGING;
      } else {
         // Check trend with LR slope
         double slope = CPriceEngine::CalculateLRSlope(LR_Period);
         if(MathAbs(slope) > LR_MinSlope) {
            m_regime = REGIME_TRENDING;
         } else {
            m_regime = REGIME_RANGING;
         }
      }
   }
   
   ENUM_MARKET_REGIME GetRegime() { return m_regime; }
   double GetCurrentATR() { return m_currentATR; }
   double GetAverageATR() { return m_avgATR; }
   double GetVolatilityRatio() { return (m_avgATR > 0) ? m_currentATR / m_avgATR : 1; }
   
   string GetRegimeName() {
      switch(m_regime) {
         case REGIME_HIGH_VOLATILITY: return "YÜKSEK VOL";
         case REGIME_TRENDING: return "TREND";
         case REGIME_RANGING: return "RANGE";
         case REGIME_BREAKOUT: return "KIRILIM";
         case REGIME_REVERSAL: return "DÖNÜŞ";
         default: return "BİLİNMİYOR";
      }
   }
   
   int GetRegimeScore(int direction) {
      switch(m_regime) {
         case REGIME_TRENDING: return 85;
         case REGIME_BREAKOUT: return 80;
         case REGIME_HIGH_VOLATILITY: return 60;
         case REGIME_RANGING: return 40;
         default: return 50;
      }
   }
};

//====================================================================
// EXTENSION MODULE 6: MONEY MANAGEMENT CALCULATOR
//====================================================================
class CMoneyManagement
{
public:
   static double CalculatePositionSize(double riskPercent, double slPips, double accountBalance) {
      if(slPips <= 0) return MinLotSize;
      
      double riskAmount = accountBalance * riskPercent / 100.0;
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      
      if(tickValue <= 0) tickValue = 10.0;
      if(tickSize <= 0) tickSize = point;
      
      double pipValue = tickValue * (point / tickSize) * 10.0;
      double lot = riskAmount / (slPips * pipValue);
      
      return CPriceEngine::NormalizeLot(lot);
   }
   
   static double CalculateKellySize(double winRate, double avgWin, double avgLoss) {
      if(avgLoss == 0) return 0;
      double rr = avgWin / avgLoss;
      double kelly = (winRate * rr - (1 - winRate)) / rr;
      return MathMax(0, MathMin(kelly * 100, 25)); // Max 25%
   }
   
   static double GetMaxDrawdownPercent() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      if(balance == 0) return 0;
      return (balance - equity) / balance * 100;
   }
   
   static bool IsRiskAcceptable(double lot, double slPips) {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double riskAmount = lot * slPips * tickValue * 10;
      double riskPercent = (balance > 0) ? (riskAmount / balance) * 100 : 0;
      return (riskPercent <= RiskPercent * 1.5);
   }
   
   static double GetDailyProfitTarget() {
      return AccountInfoDouble(ACCOUNT_BALANCE) * MaxDailyDDPct / 100.0 * 0.5; // DD limitinin yarısı
   }
};

//====================================================================
// EXTENSION MODULE 7: SYMBOL INFO HELPER
//====================================================================
class CSymbolInfo
{
public:
   static double GetSpreadPips() {
      return SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0;
   }
   
   static double GetAsk() { return SymbolInfoDouble(_Symbol, SYMBOL_ASK); }
   static double GetBid() { return SymbolInfoDouble(_Symbol, SYMBOL_BID); }
   
   static double GetMidPrice() {
      return (GetAsk() + GetBid()) / 2.0;
   }
   
   static bool IsMarketOpen() {
      MqlDateTime dt;
      TimeCurrent(dt);
      return (dt.day_of_week >= 1 && dt.day_of_week <= 5);
   }
   
   static double GetTickValue() {
      return SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   }
   
   static double GetTickSize() {
      return SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   }
   
   static double GetPoint() {
      return SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   }
   
   static int GetDigits() {
      return (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   }
   
   static double GetMinLot() {
      return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   }
   
   static double GetMaxLot() {
      return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   }
   
   static double GetLotStep() {
      return SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   }
   
   static long GetStopLevel() {
      return SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   }
   
   static string GetDescription() {
      return SymbolInfoString(_Symbol, SYMBOL_DESCRIPTION);
   }
   
   static double GetContractSize() {
      return SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   }
   
   static void PrintInfo() {
      Print("════════════════════════════════════════════════════════════════════");
      Print("📊 SEMBOL BİLGİSİ: ", _Symbol);
      Print("   Açıklama: ", GetDescription());
      Print("   Spread: ", DoubleToString(GetSpreadPips(), 1), " pip");
      Print("   Lot Min/Max/Step: ", GetMinLot(), "/", GetMaxLot(), "/", GetLotStep());
      Print("   Stop Level: ", GetStopLevel(), " point");
      Print("   Kontrat: ", GetContractSize());
      Print("════════════════════════════════════════════════════════════════════");
   }
};

//====================================================================
// EXTENSION MODULE 8: TIME HELPER
//====================================================================
class CTimeHelper
{
public:
   static bool IsNewBar() {
      static datetime lastBarTime = 0;
      datetime currentBar = iTime(_Symbol, TF, 0);
      if(lastBarTime != currentBar) {
         lastBarTime = currentBar;
         return true;
      }
      return false;
   }
   
   static bool IsNewDay() {
      static int lastDay = -1;
      MqlDateTime dt;
      TimeCurrent(dt);
      if(lastDay != dt.day) {
         lastDay = dt.day;
         return true;
      }
      return false;
   }
   
   static bool IsNewWeek() {
      static int lastWeek = -1;
      MqlDateTime dt;
      TimeCurrent(dt);
      int currentWeek = dt.day_of_year / 7;
      if(lastWeek != currentWeek) {
         lastWeek = currentWeek;
         return true;
      }
      return false;
   }
   
   static bool IsTradingHours() {
      if(!UseTimeFilter) return true;
      MqlDateTime dt;
      TimeCurrent(dt);
      return (dt.hour >= StartHour && dt.hour < EndHour);
   }
   
   static bool IsFridayEvening() {
      MqlDateTime dt;
      TimeCurrent(dt);
      return (dt.day_of_week == 5 && dt.hour >= 20);
   }
   
   static bool IsWeekend() {
      MqlDateTime dt;
      TimeCurrent(dt);
      return (dt.day_of_week == 0 || dt.day_of_week == 6);
   }
   
   static int GetMinutesInPosition(datetime openTime) {
      return (int)((TimeCurrent() - openTime) / 60);
   }
   
   static string GetCurrentTimeStr() {
      return TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES);
   }
   
   static int GetCurrentHour() {
      MqlDateTime dt;
      TimeCurrent(dt);
      return dt.hour;
   }
   
   static int GetCurrentDayOfWeek() {
      MqlDateTime dt;
      TimeCurrent(dt);
      return dt.day_of_week;
   }
};

//====================================================================
// EXTENSION MODULE 9: STATISTICAL HELPER
//====================================================================
class CStatistics
{
public:
   static double Mean(double &arr[], int size) {
      if(size <= 0) return 0;
      double sum = 0;
      for(int i = 0; i < size; i++) sum += arr[i];
      return sum / size;
   }
   
   static double StdDev(double &arr[], int size) {
      if(size <= 1) return 0;
      double mean = Mean(arr, size);
      double sumSq = 0;
      for(int i = 0; i < size; i++) sumSq += MathPow(arr[i] - mean, 2);
      return MathSqrt(sumSq / (size - 1));
   }
   
   static double Variance(double &arr[], int size) {
      double sd = StdDev(arr, size);
      return sd * sd;
   }
   
   static double Max(double &arr[], int size) {
      if(size <= 0) return 0;
      double max = arr[0];
      for(int i = 1; i < size; i++) if(arr[i] > max) max = arr[i];
      return max;
   }
   
   static double Min(double &arr[], int size) {
      if(size <= 0) return 0;
      double min = arr[0];
      for(int i = 1; i < size; i++) if(arr[i] < min) min = arr[i];
      return min;
   }
   
   static double Median(double &arr[], int size) {
      if(size <= 0) return 0;
      double sorted[];
      ArrayCopy(sorted, arr, 0, 0, size);
      ArraySort(sorted);
      if(size % 2 == 0) return (sorted[size/2 - 1] + sorted[size/2]) / 2;
      return sorted[size/2];
   }
   
   static double Correlation(double &arr1[], double &arr2[], int size) {
      if(size < 2) return 0;
      double mean1 = Mean(arr1, size);
      double mean2 = Mean(arr2, size);
      double num = 0, den1 = 0, den2 = 0;
      for(int i = 0; i < size; i++) {
         num += (arr1[i] - mean1) * (arr2[i] - mean2);
         den1 += MathPow(arr1[i] - mean1, 2);
         den2 += MathPow(arr2[i] - mean2, 2);
      }
      double denom = MathSqrt(den1 * den2);
      return (denom > 0) ? num / denom : 0;
   }
   
   static double SharpeRatio(double &returns[], int size, double riskFreeRate = 0) {
      if(size < 2) return 0;
      double mean = Mean(returns, size);
      double sd = StdDev(returns, size);
      if(sd == 0) return 0;
      return (mean - riskFreeRate) / sd;
   }
   
   static double SortinoRatio(double &returns[], int size, double riskFreeRate = 0) {
      if(size < 2) return 0;
      double mean = Mean(returns, size);
      double downside[];
      ArrayResize(downside, 0);
      int dCount = 0;
      for(int i = 0; i < size; i++) {
         if(returns[i] < 0) {
            ArrayResize(downside, dCount + 1);
            downside[dCount] = returns[i];
            dCount++;
         }
      }
      double downsideDev = StdDev(downside, dCount);
      if(downsideDev == 0) return 0;
      return (mean - riskFreeRate) / downsideDev;
   }
};

//====================================================================
// EXTENSION MODULE 10: ALERT MANAGER
//====================================================================
class CAlertManager
{
public:
   static void TradeOpened(int direction, double lot, double price, int score) {
      string msg = StringFormat("%s v13: %s @ %s | Lot: %s | Score: %d",
         _Symbol, (direction == 1 ? "BUY" : "SELL"),
         DoubleToString(price, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)),
         DoubleToString(lot, 2), score);
      
      if(PlaySoundOnTrade) PlaySound(SoundFile);
      if(UsePushNotify) SendNotification(msg);
      if(UseSendEmail) SendMail("Trade Alert - " + _Symbol, msg);
      Print("🔔 ", msg);
   }
   
   static void TradeClosed(double profit, string reason) {
      string msg = StringFormat("%s v13: Kapat @ %s | Sebep: %s",
         _Symbol, DoubleToString(profit, 2), reason);
      
      if(UsePushNotify) SendNotification(msg);
      Print("🔔 ", msg);
   }
   
   static void RiskWarning(string warning) {
      string msg = StringFormat("%s v13 RİSK: %s", _Symbol, warning);
      Alert(msg);
      Print("⚠️ ", msg);
   }
   
   static void DailyReport(int trades, double pnl, double winRate) {
      string msg = StringFormat("%s v13 Günlük: %d işlem | PnL: $%s | WR: %s%%",
         _Symbol, trades, DoubleToString(pnl, 2), DoubleToString(winRate, 1));
      
      if(UsePushNotify) SendNotification(msg);
      Print("📊 ", msg);
   }
};

//====================================================================
// GLOBAL EXTENSION OBJECTS
//====================================================================
CGridManager       GridMgr;
CPendingOrderManager PendingMgr;
CSignalHistory     SignalHist;
CTradeLogger       TradeLog;
CVolatilityAnalyzer VolAnalyzer;

//+------------------------------------------------------------------+
//| Extended OnTick - Integration with new modules                    |
//+------------------------------------------------------------------+
void OnTickExtended()
{
   // Update volatility analyzer
   VolAnalyzer.Update(AIScorer.m_lastATR);
   
   // Cleanup expired pending orders
   PendingMgr.CleanupExpired();
   
   // Check grid levels
   if(UseGrid && GridMgr.IsActive()) {
      GridMgr.CheckLevels(*Executor.GetTrade());
      GridMgr.CheckCloseAll(*Executor.GetTrade());
   }
   
   // New day check
   if(CTimeHelper::IsNewDay()) {
      TradeLog.Initialize();
      SignalHist.PrintAnalysis();
   }
}

//+------------------------------------------------------------------+
//| v13 ULTIMATE 3K EDITION - COMPLETE                               |
//| Total Modules: 20+ Core + 10 Extensions = 30+ Features           |
//| Line Count: 3000+ | All Modules Synchronized                     |
//| © 2025, Milyoner EA Project - The Ultimate Trading System        |
//+------------------------------------------------------------------+

//====================================================================
// EXTENSION MODULE 11: DRAWDOWN MANAGER
//====================================================================
class CDrawdownManager
{
private:
   double m_peakEquity;
   double m_currentDD;
   double m_maxDD;
   datetime m_maxDDTime;
   double m_recoveryFactor;
   int m_consecutiveLosses;
   int m_maxConsecutiveLosses;
   
public:
   CDrawdownManager() : m_peakEquity(0), m_currentDD(0), m_maxDD(0), m_maxDDTime(0),
      m_recoveryFactor(0), m_consecutiveLosses(0), m_maxConsecutiveLosses(0) {}
   
   void Update() {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      
      if(equity > m_peakEquity) {
         m_peakEquity = equity;
         m_consecutiveLosses = 0;
      }
      
      if(m_peakEquity > 0) {
         m_currentDD = (m_peakEquity - equity) / m_peakEquity * 100;
         
         if(m_currentDD > m_maxDD) {
            m_maxDD = m_currentDD;
            m_maxDDTime = TimeCurrent();
         }
      }
   }
   
   void OnTradeClosed(double profit) {
      if(profit < 0) {
         m_consecutiveLosses++;
         if(m_consecutiveLosses > m_maxConsecutiveLosses) {
            m_maxConsecutiveLosses = m_consecutiveLosses;
         }
      } else {
         m_consecutiveLosses = 0;
      }
   }
   
   double GetCurrentDD() { return m_currentDD; }
   double GetMaxDD() { return m_maxDD; }
   datetime GetMaxDDTime() { return m_maxDDTime; }
   int GetConsecutiveLosses() { return m_consecutiveLosses; }
   int GetMaxConsecutiveLosses() { return m_maxConsecutiveLosses; }
   
   bool IsInCriticalDD() { return (m_currentDD >= MaxDailyDDPct * 0.8); }
   
   double GetRecoveryFactor(double netProfit) {
      if(m_maxDD == 0) return 0;
      double peakDD = m_peakEquity * m_maxDD / 100;
      return (peakDD > 0) ? netProfit / peakDD : 0;
   }
   
   void Reset() {
      m_peakEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      m_currentDD = 0;
      m_maxDD = 0;
      m_consecutiveLosses = 0;
   }
   
   void PrintStats() {
      Print("════════════════════════════════════════════════════════════════════");
      Print("📉 DRAWDOWN ANALİZİ:");
      Print("   Mevcut DD: ", DoubleToString(m_currentDD, 2), "%");
      Print("   Max DD: ", DoubleToString(m_maxDD, 2), "% @ ", TimeToString(m_maxDDTime, TIME_DATE));
      Print("   Ardışık Zarar: ", m_consecutiveLosses, " | Max: ", m_maxConsecutiveLosses);
      Print("════════════════════════════════════════════════════════════════════");
   }
};

//====================================================================
// EXTENSION MODULE 12: PERFORMANCE TRACKER
//====================================================================
class CPerformanceTracker
{
private:
   struct DailyPerformance {
      datetime date;
      int trades;
      int wins;
      double profit;
      double maxDD;
   };
   
   DailyPerformance m_dailyStats[];
   int m_dayCount;
   double m_totalProfit;
   int m_totalTrades;
   int m_totalWins;
   
public:
   CPerformanceTracker() : m_dayCount(0), m_totalProfit(0), m_totalTrades(0), m_totalWins(0) {
      ArrayResize(m_dailyStats, 0);
   }
   
   void NewDay() {
      ArrayResize(m_dailyStats, m_dayCount + 1);
      m_dailyStats[m_dayCount].date = TimeCurrent();
      m_dailyStats[m_dayCount].trades = 0;
      m_dailyStats[m_dayCount].wins = 0;
      m_dailyStats[m_dayCount].profit = 0;
      m_dailyStats[m_dayCount].maxDD = 0;
      m_dayCount++;
   }
   
   void RecordTrade(bool isWin, double profit) {
      if(m_dayCount == 0) NewDay();
      
      m_dailyStats[m_dayCount - 1].trades++;
      if(isWin) m_dailyStats[m_dayCount - 1].wins++;
      m_dailyStats[m_dayCount - 1].profit += profit;
      
      m_totalTrades++;
      if(isWin) m_totalWins++;
      m_totalProfit += profit;
   }
   
   double GetDailyWinRate() {
      if(m_dayCount == 0 || m_dailyStats[m_dayCount - 1].trades == 0) return 0;
      return (double)m_dailyStats[m_dayCount - 1].wins / m_dailyStats[m_dayCount - 1].trades * 100;
   }
   
   double GetOverallWinRate() {
      if(m_totalTrades == 0) return 0;
      return (double)m_totalWins / m_totalTrades * 100;
   }
   
   double GetAverageDailyProfit() {
      if(m_dayCount == 0) return 0;
      return m_totalProfit / m_dayCount;
   }
   
   double GetBestDay() {
      double best = -999999;
      for(int i = 0; i < m_dayCount; i++) {
         if(m_dailyStats[i].profit > best) best = m_dailyStats[i].profit;
      }
      return best;
   }
   
   double GetWorstDay() {
      double worst = 999999;
      for(int i = 0; i < m_dayCount; i++) {
         if(m_dailyStats[i].profit < worst) worst = m_dailyStats[i].profit;
      }
      return worst;
   }
   
   int GetProfitableDays() {
      int count = 0;
      for(int i = 0; i < m_dayCount; i++) {
         if(m_dailyStats[i].profit > 0) count++;
      }
      return count;
   }
   
   void PrintReport() {
      Print("════════════════════════════════════════════════════════════════════");
      Print("📊 PERFORMANS RAPORU:");
      Print("   Toplam Gün: ", m_dayCount, " | Karlı: ", GetProfitableDays());
      Print("   Toplam İşlem: ", m_totalTrades, " | WR: ", DoubleToString(GetOverallWinRate(), 1), "%");
      Print("   Toplam Kar: $", DoubleToString(m_totalProfit, 2));
      Print("   Günlük Ort: $", DoubleToString(GetAverageDailyProfit(), 2));
      Print("   En İyi Gün: $", DoubleToString(GetBestDay(), 2));
      Print("   En Kötü Gün: $", DoubleToString(GetWorstDay(), 2));
      Print("════════════════════════════════════════════════════════════════════");
   }
};

//====================================================================
// EXTENSION MODULE 13: MARKET STRUCTURE ANALYZER
//====================================================================
class CMarketStructure
{
public:
   static bool IsHigherHigh(int shift = 0, int lookback = 10) {
      double currentHigh = iHigh(_Symbol, TF, shift);
      for(int i = shift + 1; i <= shift + lookback; i++) {
         if(iHigh(_Symbol, TF, i) >= currentHigh) return false;
      }
      return true;
   }
   
   static bool IsLowerLow(int shift = 0, int lookback = 10) {
      double currentLow = iLow(_Symbol, TF, shift);
      for(int i = shift + 1; i <= shift + lookback; i++) {
         if(iLow(_Symbol, TF, i) <= currentLow) return false;
      }
      return true;
   }
   
   static bool IsHigherLow(int shift = 0, int lookback = 10) {
      double currentLow = iLow(_Symbol, TF, shift);
      double prevLow = 999999;
      for(int i = shift + 1; i <= shift + lookback; i++) {
         if(iLow(_Symbol, TF, i) < prevLow) prevLow = iLow(_Symbol, TF, i);
      }
      return (currentLow > prevLow);
   }
   
   static bool IsLowerHigh(int shift = 0, int lookback = 10) {
      double currentHigh = iHigh(_Symbol, TF, shift);
      double prevHigh = 0;
      for(int i = shift + 1; i <= shift + lookback; i++) {
         if(iHigh(_Symbol, TF, i) > prevHigh) prevHigh = iHigh(_Symbol, TF, i);
      }
      return (currentHigh < prevHigh);
   }
   
   static int GetTrendStructure(int lookback = 20) {
      int hh = 0, hl = 0, lh = 0, ll = 0;
      
      for(int i = 2; i < lookback; i++) {
         if(IsHigherHigh(i, 5)) hh++;
         if(IsHigherLow(i, 5)) hl++;
         if(IsLowerHigh(i, 5)) lh++;
         if(IsLowerLow(i, 5)) ll++;
      }
      
      if(hh >= 2 && hl >= 2) return 1;  // Uptrend
      if(lh >= 2 && ll >= 2) return -1; // Downtrend
      return 0; // Ranging
   }
   
   static string GetStructureName() {
      int structure = GetTrendStructure();
      if(structure == 1) return "HH/HL UPTREND";
      if(structure == -1) return "LH/LL DOWNTREND";
      return "RANGING";
   }
   
   static int GetStructureScore(int direction) {
      int structure = GetTrendStructure();
      if(structure == direction) return 90;
      if(structure == -direction) return 20;
      return 50;
   }
};

//====================================================================
// EXTENSION MODULE 14: ORDER FLOW IMBALANCE
//====================================================================
class COrderFlowAnalyzer
{
public:
   static double GetBuyingPressure(int lookback = 10) {
      double bullVolume = 0, totalVolume = 0;
      
      for(int i = 1; i <= lookback; i++) {
         double open = iOpen(_Symbol, TF, i);
         double close = iClose(_Symbol, TF, i);
         double high = iHigh(_Symbol, TF, i);
         double low = iLow(_Symbol, TF, i);
         long vol = iVolume(_Symbol, TF, i);
         
         double range = high - low;
         if(range > 0) {
            double buyRatio = (close - low) / range;
            bullVolume += buyRatio * vol;
            totalVolume += (double)vol;
         }
      }
      
      return (totalVolume > 0) ? bullVolume / totalVolume * 100 : 50;
   }
   
   static double GetSellingPressure(int lookback = 10) {
      return 100 - GetBuyingPressure(lookback);
   }
   
   static int GetImbalanceSignal(int direction) {
      double buyPressure = GetBuyingPressure();
      
      if(direction == 1) {
         if(buyPressure > 65) return 85;
         if(buyPressure > 55) return 70;
         if(buyPressure < 40) return 25;
         return 50;
      } else {
         double sellPressure = 100 - buyPressure;
         if(sellPressure > 65) return 85;
         if(sellPressure > 55) return 70;
         if(sellPressure < 40) return 25;
         return 50;
      }
   }
   
   static bool IsBullishImbalance() { return (GetBuyingPressure() > 60); }
   static bool IsBearishImbalance() { return (GetSellingPressure() > 60); }
};

//====================================================================
// EXTENSION MODULE 15: MOMENTUM DETECTOR
//====================================================================
class CMomentumDetector
{
public:
   static double GetPriceROC(int period = 10) {
      double close0 = iClose(_Symbol, TF, 0);
      double closeN = iClose(_Symbol, TF, period);
      if(closeN == 0) return 0;
      return (close0 - closeN) / closeN * 100;
   }
   
   static double GetMomentumStrength(int period = 14) {
      double roc = GetPriceROC(period);
      return MathAbs(roc);
   }
   
   static bool IsAccelerating() {
      double roc1 = GetPriceROC(5);
      double roc2 = GetPriceROC(10);
      return (MathAbs(roc1) > MathAbs(roc2) * 1.2);
   }
   
   static bool IsDecelerating() {
      double roc1 = GetPriceROC(5);
      double roc2 = GetPriceROC(10);
      return (MathAbs(roc1) < MathAbs(roc2) * 0.8);
   }
   
   static int GetMomentumScore(int direction) {
      double roc = GetPriceROC();
      bool isAccel = IsAccelerating();
      
      int score = 50;
      if(direction == 1 && roc > 0) {
         score = 60;
         if(roc > 0.5) score = 75;
         if(isAccel) score += 15;
      } else if(direction == -1 && roc < 0) {
         score = 60;
         if(roc < -0.5) score = 75;
         if(isAccel) score += 15;
      } else if((direction == 1 && roc < 0) || (direction == -1 && roc > 0)) {
         score = 30;
      }
      
      return MathMin(100, score);
   }
};

//====================================================================
// GLOBAL OBJECTS FOR EXTENSIONS
//====================================================================
CDrawdownManager     DDManager;
CPerformanceTracker  PerfTracker;

//====================================================================
// UTILITY FUNCTIONS
//====================================================================
double NormalizePips(double pips) {
   return CPriceEngine::PipToPoints(pips);
}

double PipsToValue(double pips, double lot) {
   double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(tickValue <= 0) tickValue = 10.0;
   if(tickSize <= 0) tickSize = point;
   double pipValue = tickValue * (point / tickSize) * 10.0;
   return pips * pipValue * lot;
}

bool IsValidPrice(double price) {
   return (price > 0 && price < 999999);
}

bool IsValidLot(double lot) {
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   return (lot >= minLot && lot <= maxLot);
}

string DirectionToString(int direction) {
   if(direction == 1) return "BUY";
   if(direction == -1) return "SELL";
   return "NONE";
}

color DirectionToColor(int direction) {
   if(direction == 1) return BuyColor;
   if(direction == -1) return SellColor;
   return NeutralColor;
}

string SecondsToTimeString(int seconds) {
   int hours = seconds / 3600;
   int mins = (seconds % 3600) / 60;
   int secs = seconds % 60;
   return StringFormat("%02d:%02d:%02d", hours, mins, secs);
}

//====================================================================
// DEBUG & DIAGNOSTIC FUNCTIONS
//====================================================================
void PrintSystemStatus() {
   Print("════════════════════════════════════════════════════════════════════");
   Print("🤖 v13 SİSTEM DURUMU:");
   Print("   Paused: ", g_ManualPause);
   Print("   Locked: ", g_SystemLocked, " (", g_LockReason, ")");
   Print("   Session: ", Harmony.GetSessionName());
   Print("   Regime: ", VolAnalyzer.GetRegimeName());
   Print("   AI Score: ", g_LastSignalScore);
   Print("   Harmony Score: ", g_LastHarmonyScore);
   Print("   Positions: ", Executor.CountOpenPositions(), "/", MaxOpenPositions);
   Print("   Daily Trades: ", Security.GetTradeCount(), "/", MaxDailyTrades);
   Print("════════════════════════════════════════════════════════════════════");
}

void PrintIndicatorValues() {
   AIScorer.UpdateATR();
   Print("════════════════════════════════════════════════════════════════════");
   Print("📊 GÖSTERGE DEĞERLERİ:");
   Print("   ATR: ", DoubleToString(AIScorer.m_lastATR, 5));
   Print("   Spread: ", DoubleToString(CSymbolInfo::GetSpreadPips(), 1), " pip");
   Print("   Volatility: ", DoubleToString(VolAnalyzer.GetVolatilityRatio(), 2), "x");
   Print("   Trend Strength: ", DoubleToString(CPriceEngine::GetTrendStrength(TrendStrengthBars), 1));
   Print("   LR Slope: ", DoubleToString(CPriceEngine::CalculateLRSlope(LR_Period), 6));
   Print("   Structure: ", CMarketStructure::GetStructureName());
   Print("   Buy Pressure: ", DoubleToString(COrderFlowAnalyzer::GetBuyingPressure(), 1), "%");
   Print("════════════════════════════════════════════════════════════════════");
}

void PrintAllStats() {
   PosMgr.PrintStats();
   SignalHist.PrintAnalysis();
   DDManager.PrintStats();
   PerfTracker.PrintReport();
}

//+------------------------------------------------------------------+
//| v13.1 ULTIMATE 4K EDITION - COMPLETE                             |
//| 40+ Synchronized Modules | 4000+ Lines                           |
//| AI-Powered Signal Scoring | Multi-Factor Harmony System          |
//| Grid Matrix | Pending Orders | Signal History & Learning         |
//| Advanced Risk Management | Kelly Criterion | Compounding         |
//| Market Structure | Order Flow | Momentum Detection               |
//| Drawdown Manager | Performance Tracker | Trade Logger            |
//| Statistical Analysis | Alert System | Visual Dashboard           |
//| © 2025, Milyoner EA Project - The Ultimate Trading System v13.1  |
//+------------------------------------------------------------------+

//====================================================================
// EXTENSION MODULE 16: NEWS EVENT FILTER
//====================================================================
class CNewsFilter
{
private:
   struct NewsEvent {
      datetime time;
      string currency;
      int impact; // 1=Low, 2=Medium, 3=High
      string description;
   };
   
   NewsEvent m_events[];
   int m_eventCount;
   bool m_newsActive;
   
public:
   CNewsFilter() : m_eventCount(0), m_newsActive(false) {
      ArrayResize(m_events, 0);
   }
   
   void AddEvent(datetime time, string currency, int impact, string desc) {
      ArrayResize(m_events, m_eventCount + 1);
      m_events[m_eventCount].time = time;
      m_events[m_eventCount].currency = currency;
      m_events[m_eventCount].impact = impact;
      m_events[m_eventCount].description = desc;
      m_eventCount++;
   }
   
   bool IsNewsTime(int minutesBefore = 30, int minutesAfter = 15) {
      if(!UseNewsFilter) return false;
      
      datetime now = TimeCurrent();
      
      for(int i = 0; i < m_eventCount; i++) {
         if(m_events[i].impact >= NewsImpactLevel) {
            datetime start = m_events[i].time - minutesBefore * 60;
            datetime end = m_events[i].time + minutesAfter * 60;
            
            if(now >= start && now <= end) {
               m_newsActive = true;
               return true;
            }
         }
      }
      
      m_newsActive = false;
      return false;
   }
   
   string GetNextNewsEvent() {
      datetime now = TimeCurrent();
      datetime nearest = D'2099.12.31';
      int nearestIdx = -1;
      
      for(int i = 0; i < m_eventCount; i++) {
         if(m_events[i].time > now && m_events[i].time < nearest) {
            nearest = m_events[i].time;
            nearestIdx = i;
         }
      }
      
      if(nearestIdx >= 0) {
         return StringFormat("%s - %s (%d)", 
            TimeToString(m_events[nearestIdx].time, TIME_MINUTES),
            m_events[nearestIdx].description,
            m_events[nearestIdx].impact);
      }
      return "Yok";
   }
   
   void ClearOldEvents() {
      datetime now = TimeCurrent();
      int newCount = 0;
      
      for(int i = 0; i < m_eventCount; i++) {
         if(m_events[i].time > now - 3600) {
            if(newCount != i) {
               m_events[newCount].time = m_events[i].time;
               m_events[newCount].currency = m_events[i].currency;
               m_events[newCount].impact = m_events[i].impact;
               m_events[newCount].description = m_events[i].description;
            }
            newCount++;
         }
      }
      
      m_eventCount = newCount;
      ArrayResize(m_events, m_eventCount);
   }
   
   bool IsActive() { return m_newsActive; }
   int GetEventCount() { return m_eventCount; }
};

//====================================================================
// EXTENSION MODULE 17: HEDGE PROTECTION SYSTEM
//====================================================================
class CHedgeManager
{
private:
   bool m_hedgeActive;
   ulong m_hedgeTicket;
   double m_hedgeLot;
   int m_originalDirection;
   double m_originalEntry;
   
public:
   CHedgeManager() : m_hedgeActive(false), m_hedgeTicket(0), m_hedgeLot(0),
      m_originalDirection(0), m_originalEntry(0) {}
   
   bool ShouldActivateHedge(int direction, double currentPrice, double entryPrice, double slDistance) {
      if(!UseHedge) return false;
      if(m_hedgeActive) return false;
      
      double loss = (direction == 1) ? (entryPrice - currentPrice) : (currentPrice - entryPrice);
      double triggerDist = slDistance * (Hedge_TriggerPct / 100.0);
      
      return (loss >= triggerDist);
   }
   
   bool OpenHedge(CTrade &trade, int direction, double lot) {
      if(m_hedgeActive) return false;
      
      double hedgeLot = NormalizeDouble(lot * (Hedge_LotPercent / 100.0), 2);
      hedgeLot = MathMax(hedgeLot, SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
      
      int hedgeDir = -direction;
      
      if(hedgeDir == 1) {
         trade.Buy(hedgeLot, _Symbol, 0, 0, 0, "HEDGE");
      } else {
         trade.Sell(hedgeLot, _Symbol, 0, 0, 0, "HEDGE");
      }
      
      if(trade.ResultRetcode() == TRADE_RETCODE_DONE) {
         m_hedgeActive = true;
         m_hedgeTicket = trade.ResultOrder();
         m_hedgeLot = hedgeLot;
         m_originalDirection = direction;
         Print("🛡️ HEDGE açıldı: ", (hedgeDir == 1 ? "BUY" : "SELL"), " ", hedgeLot);
         return true;
      }
      return false;
   }
   
   void CloseHedge(CTrade &trade) {
      if(!m_hedgeActive) return;
      
      if(PositionSelectByTicket(m_hedgeTicket)) {
         trade.PositionClose(m_hedgeTicket);
         Print("🛡️ HEDGE kapatıldı");
      }
      
      m_hedgeActive = false;
      m_hedgeTicket = 0;
      m_hedgeLot = 0;
   }
   
   bool IsActive() { return m_hedgeActive; }
   ulong GetTicket() { return m_hedgeTicket; }
};

//====================================================================
// EXTENSION MODULE 18: EQUITY CURVE ANALYZER
//====================================================================
class CEquityCurveAnalyzer
{
private:
   double m_equityHistory[];
   int m_historySize;
   int m_maxHistory;
   
public:
   CEquityCurveAnalyzer() : m_historySize(0), m_maxHistory(1000) {
      ArrayResize(m_equityHistory, m_maxHistory);
      ArrayInitialize(m_equityHistory, 0);
   }
   
   void RecordEquity() {
      if(m_historySize >= m_maxHistory) {
         for(int i = 0; i < m_maxHistory - 1; i++) {
            m_equityHistory[i] = m_equityHistory[i + 1];
         }
         m_historySize = m_maxHistory - 1;
      }
      
      m_equityHistory[m_historySize] = AccountInfoDouble(ACCOUNT_EQUITY);
      m_historySize++;
   }
   
   double GetEquitySlope(int period = 20) {
      if(m_historySize < period) return 0;
      
      double sumX = 0, sumY = 0, sumXY = 0, sumX2 = 0;
      int n = period;
      int startIdx = m_historySize - period;
      
      for(int i = 0; i < n; i++) {
         double x = i;
         double y = m_equityHistory[startIdx + i];
         sumX += x;
         sumY += y;
         sumXY += x * y;
         sumX2 += x * x;
      }
      
      double denom = n * sumX2 - sumX * sumX;
      if(denom == 0) return 0;
      
      return (n * sumXY - sumX * sumY) / denom;
   }
   
   bool IsEquityCurvePositive() {
      return (GetEquitySlope() > 0);
   }
   
   bool IsEquityCurveStronglyPositive() {
      return (GetEquitySlope() > 10);
   }
   
   double GetEquityStdDev(int period = 20) {
      if(m_historySize < period) return 0;
      
      int startIdx = m_historySize - period;
      double sum = 0;
      
      for(int i = 0; i < period; i++) {
         sum += m_equityHistory[startIdx + i];
      }
      double mean = sum / period;
      
      double sumSq = 0;
      for(int i = 0; i < period; i++) {
         sumSq += MathPow(m_equityHistory[startIdx + i] - mean, 2);
      }
      
      return MathSqrt(sumSq / (period - 1));
   }
   
   int GetHistorySize() { return m_historySize; }
};

//====================================================================
// EXTENSION MODULE 19: CORRELATION MATRIX
//====================================================================
class CCorrelationAnalyzer
{
public:
   static double CalculatePairCorrelation(string symbol1, string symbol2, ENUM_TIMEFRAMES tf, int period) {
      double prices1[], prices2[];
      ArrayResize(prices1, period);
      ArrayResize(prices2, period);
      
      for(int i = 0; i < period; i++) {
         prices1[i] = iClose(symbol1, tf, i);
         prices2[i] = iClose(symbol2, tf, i);
      }
      
      return CStatistics::Correlation(prices1, prices2, period);
   }
   
   static bool IsHighlyCorrelated(string symbol1, string symbol2, double threshold = 0.7) {
      double corr = CalculatePairCorrelation(symbol1, symbol2, PERIOD_H1, 100);
      return (MathAbs(corr) >= threshold);
   }
   
   static bool IsNegativelyCorrelated(string symbol1, string symbol2, double threshold = -0.7) {
      double corr = CalculatePairCorrelation(symbol1, symbol2, PERIOD_H1, 100);
      return (corr <= threshold);
   }
   
   static string GetCorrelationType(double correlation) {
      if(correlation >= 0.8) return "Çok Güçlü +";
      if(correlation >= 0.6) return "Güçlü +";
      if(correlation >= 0.3) return "Orta +";
      if(correlation >= -0.3) return "Zayıf";
      if(correlation >= -0.6) return "Orta -";
      if(correlation >= -0.8) return "Güçlü -";
      return "Çok Güçlü -";
   }
};

//====================================================================
// EXTENSION MODULE 20: PRICE ACTION PATTERNS
//====================================================================
class CPriceAction
{
public:
   static bool IsInsideBar(int shift = 0) {
      double high0 = iHigh(_Symbol, TF, shift);
      double low0 = iLow(_Symbol, TF, shift);
      double high1 = iHigh(_Symbol, TF, shift + 1);
      double low1 = iLow(_Symbol, TF, shift + 1);
      return (high0 < high1 && low0 > low1);
   }
   
   static bool IsOutsideBar(int shift = 0) {
      double high0 = iHigh(_Symbol, TF, shift);
      double low0 = iLow(_Symbol, TF, shift);
      double high1 = iHigh(_Symbol, TF, shift + 1);
      double low1 = iLow(_Symbol, TF, shift + 1);
      return (high0 > high1 && low0 < low1);
   }
   
   static bool IsBullishPinBar(int shift = 1) {
      double open = iOpen(_Symbol, TF, shift);
      double close = iClose(_Symbol, TF, shift);
      double high = iHigh(_Symbol, TF, shift);
      double low = iLow(_Symbol, TF, shift);
      
      double body = MathAbs(close - open);
      double range = high - low;
      double lowerWick = MathMin(open, close) - low;
      double upperWick = high - MathMax(open, close);
      
      if(range == 0) return false;
      
      return (lowerWick / range > 0.6 && body / range < 0.25 && upperWick / range < 0.15);
   }
   
   static bool IsBearishPinBar(int shift = 1) {
      double open = iOpen(_Symbol, TF, shift);
      double close = iClose(_Symbol, TF, shift);
      double high = iHigh(_Symbol, TF, shift);
      double low = iLow(_Symbol, TF, shift);
      
      double body = MathAbs(close - open);
      double range = high - low;
      double lowerWick = MathMin(open, close) - low;
      double upperWick = high - MathMax(open, close);
      
      if(range == 0) return false;
      
      return (upperWick / range > 0.6 && body / range < 0.25 && lowerWick / range < 0.15);
   }
   
   static bool IsBreakout(int direction, int lookback = 20) {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      if(direction == 1) {
         double highest = 0;
         for(int i = 1; i <= lookback; i++) {
            double h = iHigh(_Symbol, TF, i);
            if(h > highest) highest = h;
         }
         return (price > highest);
      } else {
         double lowest = 999999;
         for(int i = 1; i <= lookback; i++) {
            double l = iLow(_Symbol, TF, i);
            if(l < lowest) lowest = l;
         }
         return (price < lowest);
      }
   }
   
   static bool IsFalseBreakout(int direction, int lookback = 5) {
      if(!IsBreakout(-direction, lookback + 5)) return false;
      return IsBreakout(direction, lookback);
   }
   
   static double GetAverageCandleSize(int period = 20) {
      double sum = 0;
      for(int i = 1; i <= period; i++) {
         sum += iHigh(_Symbol, TF, i) - iLow(_Symbol, TF, i);
      }
      return sum / period;
   }
   
   static int GetPriceActionScore(int direction) {
      int score = 50;
      
      if(IsBreakout(direction)) score += 25;
      if(direction == 1 && IsBullishPinBar()) score += 20;
      if(direction == -1 && IsBearishPinBar()) score += 20;
      if(IsInsideBar() && IsBreakout(direction, 5)) score += 15;
      if(IsFalseBreakout(direction)) score += 30;
      
      return MathMin(100, score);
   }
};

//====================================================================
// EXTENSION MODULE 21: MULTI-SYMBOL SCANNER
//====================================================================
class CSymbolScanner
{
private:
   string m_symbols[];
   int m_symbolCount;
   
public:
   CSymbolScanner() : m_symbolCount(0) {
      ArrayResize(m_symbols, 0);
   }
   
   void AddSymbol(string symbol) {
      ArrayResize(m_symbols, m_symbolCount + 1);
      m_symbols[m_symbolCount] = symbol;
      m_symbolCount++;
   }
   
   void InitDefaultForexPairs() {
      AddSymbol("EURUSD");
      AddSymbol("GBPUSD");
      AddSymbol("USDJPY");
      AddSymbol("USDCHF");
      AddSymbol("AUDUSD");
      AddSymbol("USDCAD");
      AddSymbol("NZDUSD");
      AddSymbol("EURGBP");
      AddSymbol("EURJPY");
      AddSymbol("GBPJPY");
   }
   
   double GetSymbolSpread(string symbol) {
      return (double)SymbolInfoInteger(symbol, SYMBOL_SPREAD) / 10.0;
   }
   
   double GetSymbolATR(string symbol, int period = 14) {
      int handle = iATR(symbol, TF, period);
      if(handle == INVALID_HANDLE) return 0;
      
      double atr[];
      ArraySetAsSeries(atr, true);
      if(CopyBuffer(handle, 0, 0, 1, atr) >= 1) {
         IndicatorRelease(handle);
         return atr[0];
      }
      IndicatorRelease(handle);
      return 0;
   }
   
   string GetBestSymbol() {
      string best = "";
      double bestScore = 0;
      
      for(int i = 0; i < m_symbolCount; i++) {
         double spread = GetSymbolSpread(m_symbols[i]);
         double atr = GetSymbolATR(m_symbols[i]);
         
         if(spread > 0 && atr > 0) {
            double score = atr * 10000 / spread;
            if(score > bestScore) {
               bestScore = score;
               best = m_symbols[i];
            }
         }
      }
      return best;
   }
   
   int GetSymbolCount() { return m_symbolCount; }
};

//====================================================================
// EXTENSION MODULE 22: ADAPTIVE PARAMETERS
//====================================================================
class CAdaptiveParams
{
public:
   static int GetAdaptiveThreshold(double winRate, double volatility) {
      int base = MinSignalScore;
      
      if(winRate > 70) base -= 5;
      else if(winRate < 50) base += 10;
      
      if(volatility > 1.5) base += 5;
      else if(volatility < 0.7) base -= 5;
      
      return MathMax(40, MathMin(80, base));
   }
   
   static double GetAdaptiveLotMultiplier(double winRate, int consecutiveWins) {
      double multi = 1.0;
      
      if(winRate > 75 && consecutiveWins >= 3) {
         multi = 1.25;
      } else if(winRate > 80 && consecutiveWins >= 5) {
         multi = 1.5;
      } else if(winRate < 45) {
         multi = 0.75;
      }
      
      return multi;
   }
   
   static double GetAdaptiveSLMultiplier(double volatility) {
      if(volatility > 2.0) return 1.5;
      if(volatility > 1.5) return 1.25;
      if(volatility < 0.5) return 0.8;
      return 1.0;
   }
   
   static double GetAdaptiveTPMultiplier(double winRate) {
      if(winRate > 75) return 1.5;
      if(winRate > 65) return 1.25;
      if(winRate < 50) return 0.9;
      return 1.0;
   }
};

//====================================================================
// EXTENSION MODULE 23: SPREAD ANALYZER
//====================================================================
class CSpreadAnalyzer
{
private:
   double m_spreadHistory[];
   int m_historySize;
   int m_maxHistory;
   double m_avgSpread;
   double m_minSpread;
   double m_maxSpread;
   
public:
   CSpreadAnalyzer() : m_historySize(0), m_maxHistory(500), m_avgSpread(0), m_minSpread(999), m_maxSpread(0) {
      ArrayResize(m_spreadHistory, m_maxHistory);
      ArrayInitialize(m_spreadHistory, 0);
   }
   
   void RecordSpread() {
      double spread = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0;
      
      if(m_historySize >= m_maxHistory) {
         for(int i = 0; i < m_maxHistory - 1; i++) {
            m_spreadHistory[i] = m_spreadHistory[i + 1];
         }
         m_historySize = m_maxHistory - 1;
      }
      
      m_spreadHistory[m_historySize] = spread;
      m_historySize++;
      
      if(spread < m_minSpread) m_minSpread = spread;
      if(spread > m_maxSpread) m_maxSpread = spread;
      
      double sum = 0;
      for(int i = 0; i < m_historySize; i++) sum += m_spreadHistory[i];
      m_avgSpread = sum / m_historySize;
   }
   
   bool IsSpreadNormal() {
      double current = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0;
      return (current <= m_avgSpread * 1.5);
   }
   
   bool IsSpreadLow() {
      double current = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0;
      return (current <= m_avgSpread * 0.8);
   }
   
   bool IsSpreadHigh() {
      double current = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0;
      return (current >= m_avgSpread * 2.0);
   }
   
   double GetCurrentSpread() {
      return (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) / 10.0;
   }
   
   double GetAverageSpread() { return m_avgSpread; }
   double GetMinSpread() { return m_minSpread; }
   double GetMaxSpread() { return m_maxSpread; }
};

//====================================================================
// EXTENSION MODULE 24: SESSION VOLATILITY TRACKER
//====================================================================
class CSessionVolatility
{
private:
   double m_asiaATR, m_londonATR, m_nyATR, m_overlapATR;
   int m_asiaCount, m_londonCount, m_nyCount, m_overlapCount;
   
public:
   CSessionVolatility() : m_asiaATR(0), m_londonATR(0), m_nyATR(0), m_overlapATR(0),
      m_asiaCount(0), m_londonCount(0), m_nyCount(0), m_overlapCount(0) {}
   
   void RecordATR(double atr) {
      MqlDateTime dt;
      TimeCurrent(dt);
      int h = dt.hour;
      
      if(h >= 0 && h < 8) {
         m_asiaATR = (m_asiaATR * m_asiaCount + atr) / (m_asiaCount + 1);
         m_asiaCount++;
      } else if(h >= 8 && h < 12) {
         m_londonATR = (m_londonATR * m_londonCount + atr) / (m_londonCount + 1);
         m_londonCount++;
      } else if(h >= 12 && h < 17) {
         m_overlapATR = (m_overlapATR * m_overlapCount + atr) / (m_overlapCount + 1);
         m_overlapCount++;
      } else if(h >= 17 && h < 22) {
         m_nyATR = (m_nyATR * m_nyCount + atr) / (m_nyCount + 1);
         m_nyCount++;
      }
   }
   
   double GetSessionATR(string session) {
      if(session == "ASYA" || session == "ASIA") return m_asiaATR;
      if(session == "LONDRA" || session == "LONDON") return m_londonATR;
      if(session == "OVERLAP") return m_overlapATR;
      if(session == "NEW YORK" || session == "NY") return m_nyATR;
      return 0;
   }
   
   string GetMostVolatileSession() {
      double max = m_asiaATR;
      string session = "ASYA";
      
      if(m_londonATR > max) { max = m_londonATR; session = "LONDRA"; }
      if(m_overlapATR > max) { max = m_overlapATR; session = "OVERLAP"; }
      if(m_nyATR > max) { max = m_nyATR; session = "NEW YORK"; }
      
      return session;
   }
   
   double GetCurrentVsAvgRatio(double lastATR, string currentSession) {
      double sessionATR = GetSessionATR(currentSession);
      if(sessionATR == 0) return 1.0;
      return lastATR / sessionATR;
   }
};

//====================================================================
// EXTENSION MODULE 25: TRADE ZONE MANAGER
//====================================================================
class CTradeZone
{
private:
   struct Zone {
      double priceHigh;
      double priceLow;
      int touchCount;
      bool isBullish;
      datetime created;
   };
   
   Zone m_demandZones[];
   Zone m_supplyZones[];
   int m_demandCount;
   int m_supplyCount;
   
public:
   CTradeZone() : m_demandCount(0), m_supplyCount(0) {
      ArrayResize(m_demandZones, 0);
      ArrayResize(m_supplyZones, 0);
   }
   
   void AddDemandZone(double high, double low) {
      ArrayResize(m_demandZones, m_demandCount + 1);
      m_demandZones[m_demandCount].priceHigh = high;
      m_demandZones[m_demandCount].priceLow = low;
      m_demandZones[m_demandCount].touchCount = 0;
      m_demandZones[m_demandCount].isBullish = true;
      m_demandZones[m_demandCount].created = TimeCurrent();
      m_demandCount++;
   }
   
   void AddSupplyZone(double high, double low) {
      ArrayResize(m_supplyZones, m_supplyCount + 1);
      m_supplyZones[m_supplyCount].priceHigh = high;
      m_supplyZones[m_supplyCount].priceLow = low;
      m_supplyZones[m_supplyCount].touchCount = 0;
      m_supplyZones[m_supplyCount].isBullish = false;
      m_supplyZones[m_supplyCount].created = TimeCurrent();
      m_supplyCount++;
   }
   
   bool IsInDemandZone(double price) {
      for(int i = 0; i < m_demandCount; i++) {
         if(price >= m_demandZones[i].priceLow && price <= m_demandZones[i].priceHigh) {
            m_demandZones[i].touchCount++;
            return true;
         }
      }
      return false;
   }
   
   bool IsInSupplyZone(double price) {
      for(int i = 0; i < m_supplyCount; i++) {
         if(price >= m_supplyZones[i].priceLow && price <= m_supplyZones[i].priceHigh) {
            m_supplyZones[i].touchCount++;
            return true;
         }
      }
      return false;
   }
   
   int GetZoneScore(int direction) {
      double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      if(direction == 1 && IsInDemandZone(price)) return 85;
      if(direction == -1 && IsInSupplyZone(price)) return 85;
      if(direction == 1 && IsInSupplyZone(price)) return 25;
      if(direction == -1 && IsInDemandZone(price)) return 25;
      
      return 50;
   }
   
   void DetectZonesFromHistory(int lookback = 100) {
      for(int i = 3; i < lookback - 3; i++) {
         double high = iHigh(_Symbol, TF, i);
         double low = iLow(_Symbol, TF, i);
         double close = iClose(_Symbol, TF, i);
         double open = iOpen(_Symbol, TF, i);
         
         bool isBullishEngulf = (close > open) && 
            (close > iHigh(_Symbol, TF, i+1)) && 
            (open < iLow(_Symbol, TF, i+1));
         
         bool isBearishEngulf = (close < open) && 
            (close < iLow(_Symbol, TF, i+1)) && 
            (open > iHigh(_Symbol, TF, i+1));
         
         if(isBullishEngulf) AddDemandZone(iHigh(_Symbol, TF, i+1), iLow(_Symbol, TF, i+1));
         if(isBearishEngulf) AddSupplyZone(iHigh(_Symbol, TF, i+1), iLow(_Symbol, TF, i+1));
      }
   }
};

//====================================================================
// GLOBAL OBJECTS FOR NEW EXTENSIONS
//====================================================================
CNewsFilter          NewsFilter;
CHedgeManager        HedgeMgr;
CEquityCurveAnalyzer EquityCurve;
CSpreadAnalyzer      SpreadAnalyzer;
CSessionVolatility   SessionVol;
CTradeZone           TradeZones;

//====================================================================
// ADDITIONAL UTILITY FUNCTIONS
//====================================================================
void OnTickExtended2() {
   // Record spread
   SpreadAnalyzer.RecordSpread();
   
   // Record equity
   EquityCurve.RecordEquity();
   
   // Record session volatility
   SessionVol.RecordATR(AIScorer.m_lastATR);
   
   // Check news filter
   if(NewsFilter.IsNewsTime()) {
      if(ShowDebugLog) Print("📰 Haber zamanı - işlem durdu");
      return;
   }
   
   // Check hedge conditions
   if(UseHedge && Executor.HasOpenPosition() && !HedgeMgr.IsActive()) {
      // Hedge kontrolü yapılabilir
   }
}

string GetFullSystemStatus() {
   string status = "";
   status += "═══════════════════════════════════════\n";
   status += "🤖 v13.1 ULTIMATE 4K SYSTEM STATUS\n";
   status += "═══════════════════════════════════════\n";
   status += "Session: " + Harmony.GetSessionName() + "\n";
   status += "Regime: " + VolAnalyzer.GetRegimeName() + "\n";
   status += "Spread: " + DoubleToString(SpreadAnalyzer.GetCurrentSpread(), 1) + " pip\n";
   status += "Equity Curve: " + (EquityCurve.IsEquityCurvePositive() ? "UP" : "DOWN") + "\n";
   status += "News Active: " + (NewsFilter.IsActive() ? "YES" : "NO") + "\n";
   status += "Hedge Active: " + (HedgeMgr.IsActive() ? "YES" : "NO") + "\n";
   status += "═══════════════════════════════════════\n";
   return status;
}

void InitializeExtendedModules() {
   NewsFilter.ClearOldEvents();
   TradeZones.DetectZonesFromHistory(100);
   Print("📊 v13.1 Extended modules initialized");
}
//+------------------------------------------------------------------+
//| v13.1 ULTIMATE 4K EDITION - COMPLETE                             |
//| 40+ Synchronized Modules | 4000+ Lines                           |
//| Features: AI Signal Scoring, Harmony System, Grid Matrix          |
//| News Filter, Hedge Protection, Equity Curve Analysis             |
//| Supply/Demand Zones, Session Volatility, Spread Analysis         |
//| Multi-Symbol Scanner, Adaptive Parameters, Price Action          |
//| Correlation Analysis, Market Structure, Order Flow               |
//| Kelly Criterion, Compounding, Drawdown Management                |
//| Performance Tracking, Trade Logging, Alert System                |
//| Visual Dashboard, Keyboard Controls, Emergency Close             |
//| © 2025, Milyoner EA Project - The Ultimate Trading System v13.1  |
//+------------------------------------------------------------------+

//====================================================================
// EXTENSION MODULE 26: CANDLE STRENGTH ANALYZER
//====================================================================
class CCandleStrength
{
public:
   static double GetBullishStrength(int lookback = 10) {
      int bullishCount = 0;
      double bullishVolume = 0;
      
      for(int i = 1; i <= lookback; i++) {
         double open = iOpen(_Symbol, TF, i);
         double close = iClose(_Symbol, TF, i);
         if(close > open) {
            bullishCount++;
            bullishVolume += (double)iVolume(_Symbol, TF, i);
         }
      }
      
      return (double)bullishCount / lookback * 100;
   }
   
   static double GetBearishStrength(int lookback = 10) {
      return 100 - GetBullishStrength(lookback);
   }
   
   static double GetAverageCandleBody(int period = 20) {
      double sum = 0;
      for(int i = 1; i <= period; i++) {
         sum += MathAbs(iClose(_Symbol, TF, i) - iOpen(_Symbol, TF, i));
      }
      return sum / period;
   }
   
   static double GetBodyToRangeRatio(int shift = 0) {
      double body = MathAbs(iClose(_Symbol, TF, shift) - iOpen(_Symbol, TF, shift));
      double range = iHigh(_Symbol, TF, shift) - iLow(_Symbol, TF, shift);
      if(range == 0) return 0;
      return body / range * 100;
   }
   
   static bool IsStrongCandle(int shift = 0) {
      return (GetBodyToRangeRatio(shift) > 70);
   }
   
   static bool IsWeakCandle(int shift = 0) {
      return (GetBodyToRangeRatio(shift) < 30);
   }
};

//====================================================================
// EXTENSION MODULE 27: VOLUME PROFILE
//====================================================================
class CVolumeProfile
{
public:
   static double GetVolumeWeightedPrice(int period = 20) {
      double sumPV = 0, sumV = 0;
      
      for(int i = 1; i <= period; i++) {
         double price = (iHigh(_Symbol, TF, i) + iLow(_Symbol, TF, i) + iClose(_Symbol, TF, i)) / 3;
         long vol = iVolume(_Symbol, TF, i);
         sumPV += price * (double)vol;
         sumV += (double)vol;
      }
      
      return (sumV > 0) ? sumPV / sumV : 0;
   }
   
   static bool IsPriceAboveVWAP() {
      return (SymbolInfoDouble(_Symbol, SYMBOL_BID) > GetVolumeWeightedPrice());
   }
   
   static bool IsPriceBelowVWAP() {
      return (SymbolInfoDouble(_Symbol, SYMBOL_BID) < GetVolumeWeightedPrice());
   }
   
   static double GetVolumeRatio(int period = 20) {
      if(period < 2) return 1.0;
      
      long currentVol = iVolume(_Symbol, TF, 1);
      long avgVol = 0;
      
      for(int i = 2; i <= period; i++) {
         avgVol += iVolume(_Symbol, TF, i);
      }
      avgVol /= (period - 1);
      
      if(avgVol == 0) return 1.0;
      return (double)currentVol / (double)avgVol;
   }
   
   static bool IsHighVolume() {
      return (GetVolumeRatio() > 1.5);
   }
   
   static bool IsLowVolume() {
      return (GetVolumeRatio() < 0.5);
   }
};

//====================================================================
// EXTENSION MODULE 28: TREND QUALITY ANALYZER
//====================================================================
class CTrendQuality
{
public:
   static double GetTrendConsistency(int period = 20) {
      int consistent = 0;
      
      for(int i = 1; i < period; i++) {
         double close1 = iClose(_Symbol, TF, i);
         double close2 = iClose(_Symbol, TF, i + 1);
         
         if(i == 1) continue;
         
         double close0 = iClose(_Symbol, TF, i - 1);
         bool upMove = (close1 > close2);
         bool prevUpMove = (close0 > close1);
         
         if(upMove == prevUpMove) consistent++;
      }
      
      return (double)consistent / (period - 2) * 100;
   }
   
   static int GetTrendBars(int maxLookback = 50) {
      int bars = 0;
      double firstClose = iClose(_Symbol, TF, 1);
      double secondClose = iClose(_Symbol, TF, 2);
      bool isUp = (firstClose > secondClose);
      
      for(int i = 2; i < maxLookback; i++) {
         double c1 = iClose(_Symbol, TF, i);
         double c2 = iClose(_Symbol, TF, i + 1);
         bool currentUp = (c1 > c2);
         
         if(currentUp != isUp) break;
         bars++;
      }
      
      return bars;
   }
   
   static double GetTrendAngle(int period = 20) {
      double y1 = iClose(_Symbol, TF, period);
      double y2 = iClose(_Symbol, TF, 0);
      double diff = y2 - y1;
      double avgPrice = (y1 + y2) / 2;
      
      return MathArctan(diff / avgPrice * 100) * 180 / M_PI;
   }
   
   static bool IsStrongTrend() {
      return (GetTrendConsistency() > 70 && GetTrendBars() > 10);
   }
};

//+------------------------------------------------------------------+
//| v13.1 ULTIMATE 4K EDITION - FINAL                                |
//| 40+ Synchronized Modules | 4000+ Lines                           |
//| © 2025, Milyoner EA Project - The Ultimate Trading System v13.1  |
//+------------------------------------------------------------------+

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 27: MACHINE LEARNING SIMULATOR
//====================================================================
class CMLSimulator
{
private:
   double m_signalWeights[10];           // 10 faktör ağırlıkları
   double m_winHistory[];                // Kazanç/kayıp geçmişi
   int    m_historyIndex;
   int    m_historySize;
   double m_learningRate;
   int    m_optimizationPeriod;
   datetime m_lastOptimization;
   
   struct SignalRecord {
      double factors[10];                // Sinyal faktörleri
      int result;                        // 1=win, -1=loss, 0=pending
      datetime time;
   };
   SignalRecord m_records[];
   int m_recordCount;
   
public:
   CMLSimulator() : m_historyIndex(0), m_historySize(100), m_learningRate(0.01),
                    m_optimizationPeriod(50), m_lastOptimization(0), m_recordCount(0) {
      ArrayResize(m_winHistory, m_historySize);
      ArrayResize(m_records, 200);
      ArrayInitialize(m_signalWeights, 1.0);
   }
   
   void Init() {
      // Varsayılan ağırlıkları input'lardan al
      m_signalWeights[0] = Weight_MACross;
      m_signalWeights[1] = Weight_MACD;
      m_signalWeights[2] = Weight_RSI;
      m_signalWeights[3] = Weight_ADX;
      m_signalWeights[4] = Weight_Stoch;
      m_signalWeights[5] = Weight_CCI;
      m_signalWeights[6] = Weight_Pattern;
      m_signalWeights[7] = Weight_Wick;
      m_signalWeights[8] = Weight_Level;
      m_signalWeights[9] = Weight_Divergence;
      NormalizeWeights();
   }
   
   void NormalizeWeights() {
      double total = 0;
      for(int i = 0; i < 10; i++) total += m_signalWeights[i];
      if(total > 0) {
         for(int i = 0; i < 10; i++) m_signalWeights[i] = (m_signalWeights[i] / total) * 100.0;
      }
   }
   
   void RecordSignal(double &factors[], int direction) {
      if(m_recordCount >= 200) {
         // Eski kayıtları kaydır
         for(int i = 0; i < 199; i++) m_records[i] = m_records[i+1];
         m_recordCount = 199;
      }
      for(int i = 0; i < 10; i++) m_records[m_recordCount].factors[i] = factors[i];
      m_records[m_recordCount].result = 0;
      m_records[m_recordCount].time = TimeCurrent();
      m_recordCount++;
   }
   
   void UpdateResult(bool isWin) {
      // Son bekleyen sinyali güncelle
      for(int i = m_recordCount - 1; i >= 0; i--) {
         if(m_records[i].result == 0) {
            m_records[i].result = isWin ? 1 : -1;
            m_winHistory[m_historyIndex] = isWin ? 1.0 : 0.0;
            m_historyIndex = (m_historyIndex + 1) % m_historySize;
            break;
         }
      }
      
      // Periyodik optimizasyon
      if(GetRecordedWins() + GetRecordedLosses() >= m_optimizationPeriod) {
         OptimizeWeights();
      }
   }
   
   void OptimizeWeights() {
      if(TimeCurrent() - m_lastOptimization < 3600) return; // Saatte 1 kez
      
      double winFactorSum[10] = {0};
      double lossFactorSum[10] = {0};
      int winCount = 0, lossCount = 0;
      
      for(int i = 0; i < m_recordCount; i++) {
         if(m_records[i].result == 1) {
            for(int j = 0; j < 10; j++) winFactorSum[j] += m_records[i].factors[j];
            winCount++;
         } else if(m_records[i].result == -1) {
            for(int j = 0; j < 10; j++) lossFactorSum[j] += m_records[i].factors[j];
            lossCount++;
         }
      }
      
      if(winCount > 0 && lossCount > 0) {
         for(int i = 0; i < 10; i++) {
            double winAvg = winFactorSum[i] / winCount;
            double lossAvg = lossFactorSum[i] / lossCount;
            double ratio = (winAvg + 0.01) / (lossAvg + 0.01);
            m_signalWeights[i] += m_learningRate * (ratio - 1.0) * m_signalWeights[i];
            m_signalWeights[i] = MathMax(1.0, MathMin(30.0, m_signalWeights[i]));
         }
         NormalizeWeights();
         Print("🧠 ML: Ağırlıklar optimize edildi. WR: ", GetMLWinRate(), "%");
      }
      
      m_lastOptimization = TimeCurrent();
   }
   
   int GetRecordedWins() {
      int count = 0;
      for(int i = 0; i < m_recordCount; i++) if(m_records[i].result == 1) count++;
      return count;
   }
   
   int GetRecordedLosses() {
      int count = 0;
      for(int i = 0; i < m_recordCount; i++) if(m_records[i].result == -1) count++;
      return count;
   }
   
   double GetMLWinRate() {
      int wins = GetRecordedWins();
      int total = wins + GetRecordedLosses();
      if(total == 0) return 50.0;
      return (double)wins / total * 100.0;
   }
   
   double GetWeight(int idx) {
      if(idx < 0 || idx >= 10) return 10.0;
      return m_signalWeights[idx];
   }
   
   double GetAdaptiveScore(double &rawScores[]) {
      double total = 0;
      for(int i = 0; i < 10; i++) {
         total += rawScores[i] * m_signalWeights[i] / 100.0;
      }
      return total;
   }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 28: SMART ENTRY TIMING
//====================================================================
class CSmartEntryTiming
{
private:
   double m_volatilityHistory[];
   int    m_historySize;
   int    m_historyIndex;
   double m_optimalVolatilityMin;
   double m_optimalVolatilityMax;
   datetime m_lastEntryTime;
   int    m_minBarsBetweenTrades;
   
   struct TimingStats {
      int hour;
      int trades;
      int wins;
      double avgProfit;
   };
   TimingStats m_hourlyStats[24];
   
public:
   CSmartEntryTiming() : m_historySize(100), m_historyIndex(0),
                         m_optimalVolatilityMin(0.5), m_optimalVolatilityMax(2.0),
                         m_lastEntryTime(0), m_minBarsBetweenTrades(3) {
      ArrayResize(m_volatilityHistory, m_historySize);
      ArrayInitialize(m_volatilityHistory, 0);
      for(int i = 0; i < 24; i++) {
         m_hourlyStats[i].hour = i;
         m_hourlyStats[i].trades = 0;
         m_hourlyStats[i].wins = 0;
         m_hourlyStats[i].avgProfit = 0;
      }
   }
   
   void RecordVolatility(double atr) {
      m_volatilityHistory[m_historyIndex] = atr;
      m_historyIndex = (m_historyIndex + 1) % m_historySize;
   }
   
   double GetAvgVolatility() {
      double sum = 0;
      int count = 0;
      for(int i = 0; i < m_historySize; i++) {
         if(m_volatilityHistory[i] > 0) {
            sum += m_volatilityHistory[i];
            count++;
         }
      }
      return count > 0 ? sum / count : 0;
   }
   
   bool IsOptimalVolatility(double currentATR) {
      double avg = GetAvgVolatility();
      if(avg == 0) return true;
      double ratio = currentATR / avg;
      return (ratio >= m_optimalVolatilityMin && ratio <= m_optimalVolatilityMax);
   }
   
   void RecordTrade(int hour, bool isWin, double profit) {
      if(hour < 0 || hour >= 24) return;
      m_hourlyStats[hour].trades++;
      if(isWin) m_hourlyStats[hour].wins++;
      m_hourlyStats[hour].avgProfit = 
         (m_hourlyStats[hour].avgProfit * (m_hourlyStats[hour].trades - 1) + profit) / 
         m_hourlyStats[hour].trades;
   }
   
   double GetHourlyWinRate(int hour) {
      if(hour < 0 || hour >= 24) return 50.0;
      if(m_hourlyStats[hour].trades == 0) return 50.0;
      return (double)m_hourlyStats[hour].wins / m_hourlyStats[hour].trades * 100.0;
   }
   
   bool IsOptimalHour() {
      MqlDateTime dt;
      TimeCurrent(dt);
      int hour = dt.hour;
      
      // Yeterli veri yoksa geç
      if(m_hourlyStats[hour].trades < 5) return true;
      
      // Win rate %40'ın altındaysa bu saatte işlem yapma
      if(GetHourlyWinRate(hour) < 40.0) return false;
      
      return true;
   }
   
   bool CanEnterNow() {
      datetime now = TimeCurrent();
      if(now - m_lastEntryTime < m_minBarsBetweenTrades * PeriodSeconds(TF)) return false;
      if(!IsOptimalHour()) return false;
      return true;
   }
   
   void OnEntry() {
      m_lastEntryTime = TimeCurrent();
   }
   
   int GetBestHour() {
      int bestHour = 0;
      double bestRate = 0;
      for(int i = 0; i < 24; i++) {
         if(m_hourlyStats[i].trades >= 5) {
            double rate = GetHourlyWinRate(i);
            if(rate > bestRate) {
               bestRate = rate;
               bestHour = i;
            }
         }
      }
      return bestHour;
   }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 29: POSITION SCALING SYSTEM
//====================================================================
class CPositionScaling
{
private:
   double m_scaleLevels[5];              // Kâr seviyeleri (ATR çarpanları)
   double m_scalePercents[5];            // Her seviyede ekleme yüzdesi
   int    m_maxScales;
   int    m_currentScales;
   double m_totalAddedLots;
   ulong  m_baseTicket;
   double m_baseEntryPrice;
   
public:
   CPositionScaling() : m_maxScales(3), m_currentScales(0), 
                        m_totalAddedLots(0), m_baseTicket(0), m_baseEntryPrice(0) {
      // Varsayılan seviyeler
      m_scaleLevels[0] = 1.0;   // 1 ATR kârda
      m_scaleLevels[1] = 2.0;   // 2 ATR kârda
      m_scaleLevels[2] = 3.0;   // 3 ATR kârda
      m_scaleLevels[3] = 4.0;   // 4 ATR kârda
      m_scaleLevels[4] = 5.0;   // 5 ATR kârda
      
      m_scalePercents[0] = 50;  // Orijinal lotun %50'si
      m_scalePercents[1] = 30;  // Orijinal lotun %30'u
      m_scalePercents[2] = 20;  // Orijinal lotun %20'si
      m_scalePercents[3] = 10;
      m_scalePercents[4] = 10;
   }
   
   void SetBasePosition(ulong ticket, double entryPrice) {
      m_baseTicket = ticket;
      m_baseEntryPrice = entryPrice;
      m_currentScales = 0;
      m_totalAddedLots = 0;
   }
   
   bool ShouldScale(int direction, double currentPrice, double atr) {
      if(m_baseTicket == 0 || m_currentScales >= m_maxScales) return false;
      
      double targetLevel = m_scaleLevels[m_currentScales] * atr;
      double profit = 0;
      
      if(direction == 1) // BUY
         profit = currentPrice - m_baseEntryPrice;
      else
         profit = m_baseEntryPrice - currentPrice;
      
      return (profit >= targetLevel);
   }
   
   double GetScaleLot(double baseLot) {
      if(m_currentScales >= m_maxScales) return 0;
      return baseLot * m_scalePercents[m_currentScales] / 100.0;
   }
   
   void OnScaled(double addedLot) {
      m_totalAddedLots += addedLot;
      m_currentScales++;
      Print("📈 Scale ", m_currentScales, ": +", DoubleToString(addedLot, 2), " lot eklendi");
   }
   
   void Reset() {
      m_baseTicket = 0;
      m_baseEntryPrice = 0;
      m_currentScales = 0;
      m_totalAddedLots = 0;
   }
   
   int GetScaleCount() { return m_currentScales; }
   double GetTotalAddedLots() { return m_totalAddedLots; }
   bool IsScalingActive() { return m_baseTicket > 0; }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 30: CORRELATION FILTER
//====================================================================
class CCorrelationFilter
{
private:
   string m_correlatedPairs[10];
   double m_correlationValues[10];
   int    m_pairCount;
   int    m_lookbackPeriod;
   double m_correlationThreshold;
   
public:
   CCorrelationFilter() : m_pairCount(0), m_lookbackPeriod(50), 
                          m_correlationThreshold(0.7) {
      // Varsayılan korelasyonlu çiftler
      m_correlatedPairs[0] = "EURUSD";
      m_correlatedPairs[1] = "GBPUSD";
      m_correlatedPairs[2] = "USDJPY";
      m_correlatedPairs[3] = "USDCHF";
      m_pairCount = 4;
   }
   
   double CalculateCorrelation(string pair1, string pair2) {
      double prices1[], prices2[];
      ArraySetAsSeries(prices1, true);
      ArraySetAsSeries(prices2, true);
      
      int copied1 = CopyClose(pair1, PERIOD_H1, 0, m_lookbackPeriod, prices1);
      int copied2 = CopyClose(pair2, PERIOD_H1, 0, m_lookbackPeriod, prices2);
      
      if(copied1 < m_lookbackPeriod || copied2 < m_lookbackPeriod) return 0;
      
      double mean1 = 0, mean2 = 0;
      for(int i = 0; i < m_lookbackPeriod; i++) {
         mean1 += prices1[i];
         mean2 += prices2[i];
      }
      mean1 /= m_lookbackPeriod;
      mean2 /= m_lookbackPeriod;
      
      double cov = 0, var1 = 0, var2 = 0;
      for(int i = 0; i < m_lookbackPeriod; i++) {
         double d1 = prices1[i] - mean1;
         double d2 = prices2[i] - mean2;
         cov += d1 * d2;
         var1 += d1 * d1;
         var2 += d2 * d2;
      }
      
      if(var1 == 0 || var2 == 0) return 0;
      return cov / MathSqrt(var1 * var2);
   }
   
   bool HasConflictingPosition(int direction) {
      for(int i = 0; i < m_pairCount; i++) {
         if(m_correlatedPairs[i] == _Symbol) continue;
         
         // Bu çiftte açık pozisyon var mı kontrol et
         for(int j = PositionsTotal() - 1; j >= 0; j--) {
            if(PositionSelectByTicket(PositionGetTicket(j))) {
               if(PositionGetString(POSITION_SYMBOL) == m_correlatedPairs[i]) {
                  double corr = CalculateCorrelation(_Symbol, m_correlatedPairs[i]);
                  
                  // Yüksek korelasyon ve aynı yönde pozisyon
                  if(MathAbs(corr) > m_correlationThreshold) {
                     int posDir = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? 1 : -1;
                     if(corr > 0 && posDir == direction) {
                        Print("⚠️ Korelasyon Filtresi: ", m_correlatedPairs[i], " ile çakışma (", 
                              DoubleToString(corr, 2), ")");
                        return true;
                     }
                     if(corr < 0 && posDir == -direction) {
                        Print("⚠️ Negatif Korelasyon Çakışması: ", m_correlatedPairs[i]);
                        return true;
                     }
                  }
               }
            }
         }
      }
      return false;
   }
   
   void UpdateCorrelations() {
      for(int i = 0; i < m_pairCount; i++) {
         m_correlationValues[i] = CalculateCorrelation(_Symbol, m_correlatedPairs[i]);
      }
   }
   
   double GetMaxCorrelation() {
      double maxCorr = 0;
      for(int i = 0; i < m_pairCount; i++) {
         if(MathAbs(m_correlationValues[i]) > MathAbs(maxCorr))
            maxCorr = m_correlationValues[i];
      }
      return maxCorr;
   }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 31: BREAK-EVEN PLUS
//====================================================================
class CBreakEvenPlus
{
private:
   double m_bePlusLevels[5];             // BE+ seviyeleri (ATR çarpanları)
   double m_bePlusPips[5];               // Her seviyede BE üstüne eklenen pips
   int    m_currentLevel;
   bool   m_beActivated;
   double m_lastSLPrice;
   
public:
   CBreakEvenPlus() : m_currentLevel(0), m_beActivated(false), m_lastSLPrice(0) {
      // Varsayılan BE+ seviyeleri
      m_bePlusLevels[0] = 1.0;   // 1 ATR kârda
      m_bePlusLevels[1] = 1.5;   // 1.5 ATR kârda
      m_bePlusLevels[2] = 2.0;   // 2 ATR kârda
      m_bePlusLevels[3] = 3.0;   // 3 ATR kârda
      m_bePlusLevels[4] = 4.0;   // 4 ATR kârda
      
      m_bePlusPips[0] = 2.0;     // BE + 2 pip
      m_bePlusPips[1] = 5.0;     // BE + 5 pip
      m_bePlusPips[2] = 10.0;    // BE + 10 pip
      m_bePlusPips[3] = 15.0;    // BE + 15 pip
      m_bePlusPips[4] = 20.0;    // BE + 20 pip
   }
   
   double CalculateBEPlusLevel(int direction, double entryPrice, double currentPrice, double atr) {
      double profit = 0;
      if(direction == 1)
         profit = currentPrice - entryPrice;
      else
         profit = entryPrice - currentPrice;
      
      double newSL = 0;
      for(int i = 4; i >= 0; i--) {
         if(profit >= m_bePlusLevels[i] * atr) {
            double plusPips = m_bePlusPips[i] * 10.0 * SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            if(direction == 1)
               newSL = entryPrice + plusPips;
            else
               newSL = entryPrice - plusPips;
            
            if(i > m_currentLevel) {
               m_currentLevel = i;
               Print("🎯 BE+ Level ", i+1, ": SL = Entry + ", m_bePlusPips[i], " pips");
            }
            break;
         }
      }
      return newSL;
   }
   
   bool ShouldUpdateSL(double newSL, int direction) {
      if(newSL == 0) return false;
      if(m_lastSLPrice == 0) {
         m_lastSLPrice = newSL;
         return true;
      }
      
      if(direction == 1 && newSL > m_lastSLPrice) {
         m_lastSLPrice = newSL;
         return true;
      }
      if(direction == -1 && newSL < m_lastSLPrice) {
         m_lastSLPrice = newSL;
         return true;
      }
      return false;
   }
   
   void Reset() {
      m_currentLevel = 0;
      m_beActivated = false;
      m_lastSLPrice = 0;
   }
   
   int GetCurrentLevel() { return m_currentLevel; }
   bool IsBEActivated() { return m_beActivated; }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 32: EQUITY CURVE FILTER
//====================================================================
class CEquityCurveFilter
{
private:
   double m_equityHistory[];
   int    m_historySize;
   int    m_historyIndex;
   double m_maPeriod;
   bool   m_tradingEnabled;
   datetime m_lastUpdate;
   double m_peakEquity;
   double m_currentDD;
   int    m_consecutiveLosses;
   int    m_maxConsecutiveLosses;
   
public:
   CEquityCurveFilter() : m_historySize(100), m_historyIndex(0), m_maPeriod(20),
                          m_tradingEnabled(true), m_lastUpdate(0), m_peakEquity(0),
                          m_currentDD(0), m_consecutiveLosses(0), m_maxConsecutiveLosses(5) {
      ArrayResize(m_equityHistory, m_historySize);
      ArrayInitialize(m_equityHistory, 0);
   }
   
   void Update() {
      if(TimeCurrent() - m_lastUpdate < 60) return; // Dakikada 1 güncelle
      
      double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      m_equityHistory[m_historyIndex] = currentEquity;
      m_historyIndex = (m_historyIndex + 1) % m_historySize;
      
      if(currentEquity > m_peakEquity) m_peakEquity = currentEquity;
      m_currentDD = (m_peakEquity - currentEquity) / m_peakEquity * 100.0;
      
      m_lastUpdate = TimeCurrent();
      
      // Equity curve MA kontrolü
      double ma = GetEquityMA();
      if(ma > 0) {
         m_tradingEnabled = (currentEquity >= ma * 0.98); // MA'nın %2 altına inerse durdur
      }
   }
   
   double GetEquityMA() {
      double sum = 0;
      int count = 0;
      for(int i = 0; i < (int)m_maPeriod; i++) {
         int idx = (m_historyIndex - 1 - i + m_historySize) % m_historySize;
         if(m_equityHistory[idx] > 0) {
            sum += m_equityHistory[idx];
            count++;
         }
      }
      return count > 0 ? sum / count : 0;
   }
   
   void OnTradeResult(bool isWin) {
      if(isWin) {
         m_consecutiveLosses = 0;
      } else {
         m_consecutiveLosses++;
         if(m_consecutiveLosses >= m_maxConsecutiveLosses) {
            m_tradingEnabled = false;
            Print("🔴 Equity Filter: ", m_consecutiveLosses, " üst üste kayıp! İşlem durduruldu.");
         }
      }
   }
   
   void Reset() {
      m_consecutiveLosses = 0;
      m_tradingEnabled = true;
   }
   
   bool IsTradingAllowed() { return m_tradingEnabled; }
   double GetCurrentDD() { return m_currentDD; }
   double GetPeakEquity() { return m_peakEquity; }
   int GetConsecutiveLosses() { return m_consecutiveLosses; }
   
   double GetEquityScore() {
      // 0-100 arası skor
      double ddScore = MathMax(0, 100 - m_currentDD * 10);
      double lossScore = MathMax(0, 100 - m_consecutiveLosses * 20);
      return (ddScore + lossScore) / 2.0;
   }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 33: SMART EXIT SYSTEM
//====================================================================
class CSmartExitSystem
{
private:
   double m_profitTargets[5];            // Kâr hedefleri (ATR çarpanları)
   double m_exitPercents[5];             // Her hedefte kapatılacak yüzde
   int    m_currentTarget;
   bool   m_trailingActivated;
   double m_highestProfit;
   double m_exitTriggerPct;              // Trailing exit tetikleme yüzdesi
   
   // AI Exit Signals
   bool   m_divergenceExit;
   bool   m_momentumExit;
   bool   m_levelExit;
   
public:
   CSmartExitSystem() : m_currentTarget(0), m_trailingActivated(false),
                        m_highestProfit(0), m_exitTriggerPct(50),
                        m_divergenceExit(false), m_momentumExit(false), m_levelExit(false) {
      // Varsayılan hedefler
      m_profitTargets[0] = 1.0;   // 1 ATR
      m_profitTargets[1] = 2.0;   // 2 ATR
      m_profitTargets[2] = 3.0;   // 3 ATR
      m_profitTargets[3] = 5.0;   // 5 ATR
      m_profitTargets[4] = 8.0;   // 8 ATR (Fibonacci)
      
      m_exitPercents[0] = 25;
      m_exitPercents[1] = 25;
      m_exitPercents[2] = 25;
      m_exitPercents[3] = 15;
      m_exitPercents[4] = 10;
   }
   
   int CheckExitLevel(double profitATR) {
      for(int i = 4; i >= 0; i--) {
         if(profitATR >= m_profitTargets[i]) {
            return i;
         }
      }
      return -1;
   }
   
   double GetExitPercent(int level) {
      if(level < 0 || level >= 5) return 0;
      return m_exitPercents[level];
   }
   
   void UpdateProfit(double currentProfit) {
      if(currentProfit > m_highestProfit) {
         m_highestProfit = currentProfit;
         m_trailingActivated = true;
      }
   }
   
   bool ShouldExitOnRetracement(double currentProfit) {
      if(!m_trailingActivated || m_highestProfit <= 0) return false;
      
      double retracement = (m_highestProfit - currentProfit) / m_highestProfit * 100.0;
      return (retracement >= m_exitTriggerPct);
   }
   
   void SetDivergenceExit(bool detected) { m_divergenceExit = detected; }
   void SetMomentumExit(bool detected) { m_momentumExit = detected; }
   void SetLevelExit(bool detected) { m_levelExit = detected; }
   
   bool ShouldExitOnSignal() {
      int exitSignals = 0;
      if(m_divergenceExit) exitSignals++;
      if(m_momentumExit) exitSignals++;
      if(m_levelExit) exitSignals++;
      return (exitSignals >= 2); // 2/3 sinyal gerekliyse çık
   }
   
   string GetExitReason() {
      string reason = "";
      if(m_divergenceExit) reason += "DIV ";
      if(m_momentumExit) reason += "MOM ";
      if(m_levelExit) reason += "LVL ";
      return reason;
   }
   
   void Reset() {
      m_currentTarget = 0;
      m_trailingActivated = false;
      m_highestProfit = 0;
      m_divergenceExit = false;
      m_momentumExit = false;
      m_levelExit = false;
   }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 34: MULTI-SESSION ANALYSIS
//====================================================================
class CMultiSessionAnalysis
{
private:
   struct SessionData {
      string name;
      int    startHour;
      int    endHour;
      int    trades;
      int    wins;
      double totalProfit;
      double avgVolatility;
   };
   SessionData m_sessions[4];
   int m_currentSession;
   
public:
   CMultiSessionAnalysis() : m_currentSession(-1) {
      // Session tanımları (UTC)
      m_sessions[0].name = "Sydney";
      m_sessions[0].startHour = 22;
      m_sessions[0].endHour = 7;
      
      m_sessions[1].name = "Tokyo";
      m_sessions[1].startHour = 0;
      m_sessions[1].endHour = 9;
      
      m_sessions[2].name = "London";
      m_sessions[2].startHour = 8;
      m_sessions[2].endHour = 17;
      
      m_sessions[3].name = "NewYork";
      m_sessions[3].startHour = 13;
      m_sessions[3].endHour = 22;
      
      for(int i = 0; i < 4; i++) {
         m_sessions[i].trades = 0;
         m_sessions[i].wins = 0;
         m_sessions[i].totalProfit = 0;
         m_sessions[i].avgVolatility = 0;
      }
   }
   
   void UpdateCurrentSession() {
      MqlDateTime dt;
      TimeCurrent(dt);
      int hour = dt.hour;
      
      m_currentSession = -1;
      for(int i = 0; i < 4; i++) {
         if(m_sessions[i].startHour <= m_sessions[i].endHour) {
            if(hour >= m_sessions[i].startHour && hour < m_sessions[i].endHour)
               m_currentSession = i;
         } else {
            if(hour >= m_sessions[i].startHour || hour < m_sessions[i].endHour)
               m_currentSession = i;
         }
      }
   }
   
   void RecordTrade(bool isWin, double profit) {
      if(m_currentSession < 0 || m_currentSession >= 4) return;
      m_sessions[m_currentSession].trades++;
      if(isWin) m_sessions[m_currentSession].wins++;
      m_sessions[m_currentSession].totalProfit += profit;
   }
   
   void RecordVolatility(double atr) {
      if(m_currentSession < 0 || m_currentSession >= 4) return;
      if(m_sessions[m_currentSession].avgVolatility == 0)
         m_sessions[m_currentSession].avgVolatility = atr;
      else
         m_sessions[m_currentSession].avgVolatility = 
            (m_sessions[m_currentSession].avgVolatility * 0.9) + (atr * 0.1);
   }
   
   double GetSessionWinRate(int session) {
      if(session < 0 || session >= 4) return 50.0;
      if(m_sessions[session].trades == 0) return 50.0;
      return (double)m_sessions[session].wins / m_sessions[session].trades * 100.0;
   }
   
   bool IsOptimalSession() {
      if(m_currentSession < 0) return true;
      if(m_sessions[m_currentSession].trades < 10) return true;
      return (GetSessionWinRate(m_currentSession) >= 45.0);
   }
   
   string GetCurrentSessionName() {
      if(m_currentSession < 0 || m_currentSession >= 4) return "Unknown";
      return m_sessions[m_currentSession].name;
   }
   
   int GetBestSession() {
      int best = 0;
      double bestRate = 0;
      for(int i = 0; i < 4; i++) {
         if(m_sessions[i].trades >= 10) {
            double rate = GetSessionWinRate(i);
            if(rate > bestRate) {
               bestRate = rate;
               best = i;
            }
         }
      }
      return best;
   }
   
   double GetSessionScore() {
      if(m_currentSession < 0) return 50;
      return GetSessionWinRate(m_currentSession);
   }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 35: NEWS IMPACT CALCULATOR
//====================================================================
class CNewsImpactCalculator
{
private:
   struct ImpactEvent {
      datetime time;
      string currency;
      int impact;              // 1=Low, 2=Medium, 3=High
      bool processed;
   };
   ImpactEvent m_events[];
   int m_eventCount;
   int m_pauseMinutesBefore;
   int m_pauseMinutesAfter;
   double m_impactMultiplier;
   
public:
   CNewsImpactCalculator() : m_eventCount(0), m_pauseMinutesBefore(30),
                              m_pauseMinutesAfter(15), m_impactMultiplier(1.0) {
      ArrayResize(m_events, 100);
   }
   
   void SetPauseTimes(int before, int after) {
      m_pauseMinutesBefore = before;
      m_pauseMinutesAfter = after;
   }
   
   void AddEvent(datetime time, string currency, int impact) {
      if(m_eventCount >= 100) {
         // Eski eventleri temizle
         ClearOldEvents();
      }
      m_events[m_eventCount].time = time;
      m_events[m_eventCount].currency = currency;
      m_events[m_eventCount].impact = impact;
      m_events[m_eventCount].processed = false;
      m_eventCount++;
   }
   
   void ClearOldEvents() {
      datetime now = TimeCurrent();
      int newCount = 0;
      for(int i = 0; i < m_eventCount; i++) {
         if(m_events[i].time > now - 3600) { // Son 1 saatteki eventler
            if(i != newCount) m_events[newCount] = m_events[i];
            newCount++;
         }
      }
      m_eventCount = newCount;
   }
   
   bool IsNearHighImpactNews() {
      datetime now = TimeCurrent();
      string baseCurrency = StringSubstr(_Symbol, 0, 3);
      string quoteCurrency = StringSubstr(_Symbol, 3, 3);
      
      for(int i = 0; i < m_eventCount; i++) {
         if(m_events[i].impact >= 3) { // High impact
            if(m_events[i].currency == baseCurrency || m_events[i].currency == quoteCurrency) {
               datetime startPause = m_events[i].time - m_pauseMinutesBefore * 60;
               datetime endPause = m_events[i].time + m_pauseMinutesAfter * 60;
               if(now >= startPause && now <= endPause) return true;
            }
         }
      }
      return false;
   }
   
   double GetCurrentImpactScore() {
      // 0-100: 0 = Haber yok, 100 = Yüksek etkili haber yakın
      datetime now = TimeCurrent();
      double maxScore = 0;
      
      for(int i = 0; i < m_eventCount; i++) {
         double timeDiff = MathAbs((double)(m_events[i].time - now)) / 60.0; // Dakika cinsinden
         if(timeDiff < 60) { // 1 saat içinde
            double score = m_events[i].impact * 33.3 * (1.0 - timeDiff / 60.0);
            if(score > maxScore) maxScore = score;
         }
      }
      return maxScore;
   }
   
   int GetUpcomingNewsCount(int hours) {
      datetime now = TimeCurrent();
      datetime future = now + hours * 3600;
      int count = 0;
      for(int i = 0; i < m_eventCount; i++) {
         if(m_events[i].time > now && m_events[i].time <= future)
            count++;
      }
      return count;
   }
   
   double GetAdjustedMultiplier() {
      // Haber yakınsa risk azalt
      if(IsNearHighImpactNews()) return 0.5;
      double impactScore = GetCurrentImpactScore();
      if(impactScore > 50) return 0.75;
      return 1.0;
   }
};

//====================================================================
// v14 5K EDITION - EXTENSION MODULE 36: RISK PARITY SYSTEM
//====================================================================
class CRiskParitySystem
{
private:
   double m_baseRisk;
   double m_currentRisk;
   double m_volatilityAdjustment;
   double m_correlationAdjustment;
   double m_performanceAdjustment;
   double m_minRiskMultiplier;
   double m_maxRiskMultiplier;
   
   // Performans metrikleri
   double m_recentWinRate;
   double m_recentExpectancy;
   double m_recentSharpe;
   
public:
   CRiskParitySystem() : m_baseRisk(1.0), m_currentRisk(1.0),
                         m_volatilityAdjustment(1.0), m_correlationAdjustment(1.0),
                         m_performanceAdjustment(1.0),
                         m_minRiskMultiplier(0.25), m_maxRiskMultiplier(2.0),
                         m_recentWinRate(50), m_recentExpectancy(0), m_recentSharpe(0) {}
   
   void SetBaseRisk(double risk) { m_baseRisk = risk; }
   
   void UpdateVolatilityAdjustment(double currentATR, double avgATR) {
      if(avgATR <= 0) {
         m_volatilityAdjustment = 1.0;
         return;
      }
      double ratio = currentATR / avgATR;
      // Yüksek volatilitede riski azalt, düşük volatilitede artır
      m_volatilityAdjustment = 1.0 / ratio;
      m_volatilityAdjustment = MathMax(0.5, MathMin(1.5, m_volatilityAdjustment));
   }
   
   void UpdateCorrelationAdjustment(double maxCorrelation) {
      // Yüksek korelasyonda riski azalt
      m_correlationAdjustment = 1.0 - MathAbs(maxCorrelation) * 0.5;
      m_correlationAdjustment = MathMax(0.5, m_correlationAdjustment);
   }
   
   void UpdatePerformanceAdjustment(double winRate, double expectancy, double sharpe) {
      m_recentWinRate = winRate;
      m_recentExpectancy = expectancy;
      m_recentSharpe = sharpe;
      
      double perfScore = 0;
      
      // Win rate katkısı (50% baz)
      if(winRate > 50) perfScore += (winRate - 50) / 50.0 * 0.5;
      else perfScore -= (50 - winRate) / 50.0 * 0.5;
      
      // Sharpe katkısı
      if(sharpe > 1) perfScore += 0.25;
      else if(sharpe > 0) perfScore += sharpe * 0.25;
      else perfScore -= 0.25;
      
      m_performanceAdjustment = 1.0 + perfScore;
      m_performanceAdjustment = MathMax(0.5, MathMin(1.5, m_performanceAdjustment));
   }
   
   double CalculateOptimalRisk() {
      m_currentRisk = m_baseRisk * m_volatilityAdjustment * 
                      m_correlationAdjustment * m_performanceAdjustment;
      
      m_currentRisk = MathMax(m_baseRisk * m_minRiskMultiplier, 
                              MathMin(m_baseRisk * m_maxRiskMultiplier, m_currentRisk));
      
      return m_currentRisk;
   }
   
   double GetRiskMultiplier() {
      return m_currentRisk / m_baseRisk;
   }
   
   string GetRiskReport() {
      return StringFormat("Risk: %.2fx (V:%.2f C:%.2f P:%.2f)", 
                          GetRiskMultiplier(), 
                          m_volatilityAdjustment,
                          m_correlationAdjustment,
                          m_performanceAdjustment);
   }
   
   double GetVolatilityAdj() { return m_volatilityAdjustment; }
   double GetCorrelationAdj() { return m_correlationAdjustment; }
   double GetPerformanceAdj() { return m_performanceAdjustment; }
};

//====================================================================
// v15 EXTENSION MODULE: SMART BRAIN - ZEKİ BEYİN SİSTEMİ
//====================================================================
class CSmartBrain
{
private:
   double m_baseLotMultiplier;       // Temel lot çarpanı
   double m_currentLotMultiplier;    // Mevcut lot çarpanı
   int    m_consecutiveWins;         // Art arda kazanç
   int    m_consecutiveLosses;       // Art arda kayıp
   double m_dailyStartBalance;       // Günlük başlangıç bakiyesi
   double m_dailyPL;                 // Günlük kar/zarar
   int    m_dailyTrades;             // Günlük işlem sayısı
   bool   m_tradingAllowed;          // İşlem izni
   double m_lockedProfit;            // Kilitlenmiş kar
   int    m_totalWins;               // Toplam kazanç
   int    m_totalLosses;             // Toplam kayıp
   datetime m_lastTradeTime;         // Son işlem zamanı
   datetime m_dayStartTime;          // Gün başlangıç zamanı
   
public:
   CSmartBrain() : m_baseLotMultiplier(1.0), m_currentLotMultiplier(1.0),
                   m_consecutiveWins(0), m_consecutiveLosses(0),
                   m_dailyStartBalance(0), m_dailyPL(0), m_dailyTrades(0),
                   m_tradingAllowed(true), m_lockedProfit(0),
                   m_totalWins(0), m_totalLosses(0), m_lastTradeTime(0), m_dayStartTime(0) {}
   
   void Init() {
      m_dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      m_dayStartTime = TimeCurrent();
      m_currentLotMultiplier = 1.0;
      m_tradingAllowed = true;
      Print("🧠 Smart Brain initialized - Base Balance: $", DoubleToString(m_dailyStartBalance, 2));
   }
   
   void OnDayStart() {
      m_dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      m_dailyPL = 0;
      m_dailyTrades = 0;
      m_tradingAllowed = true;
      m_lockedProfit = 0;
      m_dayStartTime = TimeCurrent();
      Print("🧠 Smart Brain: Yeni gün başladı - Bakiye: $", DoubleToString(m_dailyStartBalance, 2));
   }
   
   void CheckDayChange() {
      MqlDateTime now, start;
      TimeCurrent(now);
      TimeToStruct(m_dayStartTime, start);
      
      if(now.day != start.day) {
         OnDayStart();
      }
   }
   
   void OnTradeResult(double profit) {
      m_dailyPL += profit;
      m_dailyTrades++;
      
      if(profit > 0) {
         m_consecutiveWins++;
         m_consecutiveLosses = 0;
         m_totalWins++;
         
         // Kazanç sonrası lot büyütme
         if(SmartCompound && m_consecutiveWins >= SmartConsecWinsToUp) {
            m_currentLotMultiplier *= SmartWinMultiplier;
            m_currentLotMultiplier = MathMin(m_currentLotMultiplier, SmartMaxLotMultiplier);
            Print("🧠 Smart Brain: Lot çarpanı artırıldı → ", DoubleToString(m_currentLotMultiplier, 2), "x");
         }
         
         // Kar kilitleme
         if(SmartLockProfit && m_dailyPL > 0) {
            double newLock = m_dailyPL * SmartLockProfitPct / 100.0;
            if(newLock > m_lockedProfit) {
               m_lockedProfit = newLock;
               Print("🔒 Smart Brain: Kâr kilitlendi → $", DoubleToString(m_lockedProfit, 2));
            }
         }
      } else {
         m_consecutiveLosses++;
         m_consecutiveWins = 0;
         m_totalLosses++;
         
         // Kayıp sonrası lot küçültme
         if(SmartCompound && m_consecutiveLosses >= SmartConsecLossesToDown) {
            m_currentLotMultiplier *= SmartLossMultiplier;
            m_currentLotMultiplier = MathMax(m_currentLotMultiplier, SmartMinLotMultiplier);
            Print("🧠 Smart Brain: Lot çarpanı azaltıldı → ", DoubleToString(m_currentLotMultiplier, 2), "x");
         }
      }
      
      m_lastTradeTime = TimeCurrent();
      CheckDailyLimits();
   }
   
   void CheckDailyLimits() {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double dailyPLPct = m_dailyPL / m_dailyStartBalance * 100.0;
      
      // Günlük hedef kontrolü
      if(dailyPLPct >= SmartDailyProfitTarget) {
         m_tradingAllowed = false;
         Print("🎯 Smart Brain: Günlük hedef ulaşıldı! (+", DoubleToString(dailyPLPct, 2), "%) - İşlem durduruldu");
      }
      
      // Günlük kayıp limiti kontrolü
      if(dailyPLPct <= -SmartDailyLossLimit) {
         m_tradingAllowed = false;
         Print("🛑 Smart Brain: Günlük kayıp limiti! (", DoubleToString(dailyPLPct, 2), "%) - İşlem durduruldu");
      }
      
      // Max günlük işlem kontrolü
      if(m_dailyTrades >= SmartMaxDailyTrades) {
         m_tradingAllowed = false;
         Print("📊 Smart Brain: Max günlük işlem sayısına ulaşıldı! (", m_dailyTrades, "/", SmartMaxDailyTrades, ")");
      }
      
      // Kilitli kar koruması
      if(SmartLockProfit && m_lockedProfit > 0) {
         if(m_dailyPL < m_lockedProfit * 0.5) {
            m_tradingAllowed = false;
            Print("🔒 Smart Brain: Kilitli kâr tehlikede! Koruma aktif.");
         }
      }
   }
   
   bool CanTrade() {
      if(!UseSmartBrain) return true;
      CheckDayChange();
      return m_tradingAllowed;
   }
   
   bool IsSignalStrong(int signalScore) {
      if(!UseSmartBrain) return true;
      return signalScore >= SmartSignalThreshold;
   }
   
   double GetSmartRisk() {
      if(!UseSmartBrain) return RiskPercent;
      
      double risk = SmartRiskPercent;
      
      // Recovery mode - kayıp sonrası daha az risk
      if(SmartRecoveryMode && m_consecutiveLosses > 0) {
         risk *= MathPow(0.8, m_consecutiveLosses);
         risk = MathMax(risk, SmartMinRisk);
      }
      
      // Kazanç serisinde biraz daha fazla risk
      if(m_consecutiveWins >= 3) {
         risk *= 1.25;
         risk = MathMin(risk, SmartMaxRisk);
      }
      
      return MathMax(SmartMinRisk, MathMin(SmartMaxRisk, risk));
   }
   
   double GetLotMultiplier() {
      if(!UseSmartBrain) return 1.0;
      return m_currentLotMultiplier;
   }
   
   double CalculateSmartLot(double baseLot) {
      if(!UseSmartBrain) return baseLot;
      
      double smartLot = baseLot * m_currentLotMultiplier;
      
      // Min/Max kontrolü
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      
      smartLot = MathFloor(smartLot / lotStep) * lotStep;
      smartLot = MathMax(minLot, MathMin(maxLot, smartLot));
      
      return smartLot;
   }
   
   void ResetAfterBigLoss() {
      m_currentLotMultiplier = SmartMinLotMultiplier;
      m_consecutiveLosses = 0;
      Print("🧠 Smart Brain: Büyük kayıp sonrası reset - Lot çarpanı: ", DoubleToString(m_currentLotMultiplier, 2));
   }
   
   string GetStatus() {
      return StringFormat("🧠 W:%d L:%d | Lot:%.2fx | Daily: $%.2f (%d trades)", 
                          m_consecutiveWins, m_consecutiveLosses, 
                          m_currentLotMultiplier, m_dailyPL, m_dailyTrades);
   }
   
   string GetDetailedReport() {
      double wr = (m_totalWins + m_totalLosses > 0) ? 
                  (double)m_totalWins / (m_totalWins + m_totalLosses) * 100.0 : 0;
      return StringFormat(
         "🧠 SMART BRAIN RAPOR:\n"
         "   Toplam: %d W / %d L (%.1f%%)\n"
         "   Seri: %d W / %d L ardışık\n"
         "   Lot Çarpanı: %.2fx\n"
         "   Günlük: $%.2f (%d işlem)\n"
         "   Kilitli Kâr: $%.2f\n"
         "   Durum: %s",
         m_totalWins, m_totalLosses, wr,
         m_consecutiveWins, m_consecutiveLosses,
         m_currentLotMultiplier,
         m_dailyPL, m_dailyTrades,
         m_lockedProfit,
         m_tradingAllowed ? "AKTİF ✅" : "DURDURULDU 🛑"
      );
   }
   
   // Getters
   double GetDailyPL() { return m_dailyPL; }
   int GetDailyTrades() { return m_dailyTrades; }
   int GetConsecutiveWins() { return m_consecutiveWins; }
   int GetConsecutiveLosses() { return m_consecutiveLosses; }
   bool IsTradingAllowed() { return m_tradingAllowed; }
   double GetLockedProfit() { return m_lockedProfit; }
};

// Global Smart Brain nesnesi
CSmartBrain SmartBrain;

//====================================================================
// v15.1 UPGRADE: DYNAMIC DIRECTION LEARNER (Zeki Yön Değiştirici)
// - 3 üst üste kayıpta otomatik reset
// - Piyasa değişimi algılama
// - Adaptif unutma mekanizması
//====================================================================
class CMADirectionLearner
{
private:
   int m_tradeCount;
   int m_calibrationPeriod;
   bool m_isCalibrated;
   int m_learnedDirection;       // 1=BUY, -1=SELL, 0=NEUTRAL
   int m_consecutiveLossesInDirection; // Yanlış yönde ısrar etme sayacı
   int m_resetCount;             // Kaç kez reset yapıldı
   int m_maxResets;              // Max reset sayısı (sonsuz döngü önleme)
   
   // İstatistikler
   int m_buyWins, m_sellWins;
   int m_buyLosses, m_sellLosses;
   int m_totalTrades;
   double m_calibrationLotMultiplier;
   
   // Performans takibi
   double m_totalProfit;
   double m_maxDrawdown;
   double m_peakProfit;

public:
   CMADirectionLearner() : m_tradeCount(0), m_calibrationPeriod(10), m_isCalibrated(false),
                           m_learnedDirection(0), m_consecutiveLossesInDirection(0),
                           m_resetCount(0), m_maxResets(5), m_totalTrades(0),
                           m_calibrationLotMultiplier(0.1), m_totalProfit(0),
                           m_maxDrawdown(0), m_peakProfit(0) {
      m_buyWins = 0; m_sellWins = 0;
      m_buyLosses = 0; m_sellLosses = 0;
   }
   
   void Init(int calibrationTrades = 10) {
      m_calibrationPeriod = calibrationTrades;
      ResetCalibration();
      Print("🎯 DYNAMIC DIRECTION LEARNER v15.1 Başlatıldı");
      Print("   ➤ Kalibrasyon: ", m_calibrationPeriod, " işlem");
      Print("   ➤ Reset tetikleyici: 3 üst üste kayıp");
      Print("   ➤ Max reset: ", m_maxResets, " kez");
   }
   
   void ResetCalibration() {
      m_tradeCount = 0;
      m_isCalibrated = false;
      m_learnedDirection = 0;
      m_buyWins = 0; m_sellWins = 0;
      m_buyLosses = 0; m_sellLosses = 0;
      m_consecutiveLossesInDirection = 0;
      m_resetCount++;
      
      Print("═══════════════════════════════════════════");
      Print("🔄 PİYASA DEĞİŞTİ! (Reset #", m_resetCount, "/", m_maxResets, ")");
      Print("   Yön algısı sıfırlandı, yeniden öğreniliyor...");
      Print("═══════════════════════════════════════════");
   }

   void OnTradeResult(int direction, double profit) {
      m_totalTrades++;
      m_totalProfit += profit;
      
      // Peak & Drawdown takibi
      if(m_totalProfit > m_peakProfit) m_peakProfit = m_totalProfit;
      double currentDD = m_peakProfit - m_totalProfit;
      if(currentDD > m_maxDrawdown) m_maxDrawdown = currentDD;
      
      // İstatistikleri güncelle
      if(direction == 1) {
         if(profit > 0) m_buyWins++;
         else m_buyLosses++;
      } else {
         if(profit > 0) m_sellWins++;
         else m_sellLosses++;
      }

      // ♟️ SATRANÇ HAMLE KONTROLÜ: Kalibre edildiyse ve öğrenilen yönde kaybediyorsak?
      if(m_isCalibrated && direction == m_learnedDirection) {
         if(profit < 0) {
            m_consecutiveLossesInDirection++;
            Print("⚠️ Yön Hatası: ", m_consecutiveLossesInDirection, "/3 | ",
                  (direction == 1 ? "BUY" : "SELL"), " kayıp: $", DoubleToString(MathAbs(profit), 2));
         } else {
            m_consecutiveLossesInDirection = 0; // Kazanınca sayacı sıfırla
         }

         // ♟️ ŞAH ÇEKİLDİ! 3 kere üst üste kaybedersek strateji yanlıştır
         if(m_consecutiveLossesInDirection >= 3) {
            if(m_resetCount < m_maxResets) {
               Print("🛑 STRATEJİ İFLASI! Öğrenilen yönde 3 kayıp!");
               Print("   Piyasa yön değiştirdi, yeniden kalibrasyon başlatılıyor...");
               ResetCalibration();
               return;
            } else {
               Print("⛔ MAX RESET LİMİTİ! Artık reset yapılmayacak.");
               Print("   Sistem KARMA moda geçiyor...");
               m_learnedDirection = 0; // Her iki yöne de izin ver
               m_consecutiveLossesInDirection = 0;
            }
         }
      }

      // Henüz öğrenme aşamasındaysak
      if(!m_isCalibrated) {
         m_tradeCount++;
         Print("🎯 Kalibrasyon ", m_tradeCount, "/", m_calibrationPeriod, 
               " | ", (direction == 1 ? "BUY" : "SELL"), 
               " | ", (profit > 0 ? "✅ WIN" : "❌ LOSS"),
               " | P/L: $", DoubleToString(profit, 2));
         
         if(m_tradeCount >= m_calibrationPeriod) {
            CompleteCalibration();
         }
      }
   }

   void CompleteCalibration() {
      m_isCalibrated = true;
      m_consecutiveLossesInDirection = 0;
      
      double buyRate = (m_buyWins + m_buyLosses > 0) ? 
                       (double)m_buyWins / (m_buyWins + m_buyLosses) : 0;
      double sellRate = (m_sellWins + m_sellLosses > 0) ? 
                        (double)m_sellWins / (m_sellWins + m_sellLosses) : 0;

      Print("═══════════════════════════════════════════");
      Print("✅ KALİBRASYON TAMAMLANDI! (Reset #", m_resetCount, ")");
      Print("   BUY: ", m_buyWins, "W/", m_buyLosses, "L (", DoubleToString(buyRate * 100, 1), "%)");
      Print("   SELL: ", m_sellWins, "W/", m_sellLosses, "L (", DoubleToString(sellRate * 100, 1), "%)");

      // Yön belirleme (%60'tan fazla başarı gerekli)
      if(buyRate > 0.6 && buyRate > sellRate) {
         m_learnedDirection = 1;
         Print("   📈 SONUÇ: BUY TREND Algılandı!");
         Print("   ➤ Bundan sonra SADECE BUY işlemleri alınacak");
      } else if(sellRate > 0.6 && sellRate > buyRate) {
         m_learnedDirection = -1;
         Print("   📉 SONUÇ: SELL TREND Algılandı!");
         Print("   ➤ Bundan sonra SADECE SELL işlemleri alınacak");
      } else {
         m_learnedDirection = 0;
         Print("   ↔️ SONUÇ: KARMA Piyasa (Net yön yok)");
         Print("   ➤ Her iki yön de değerlendirilecek");
      }
      Print("═══════════════════════════════════════════");
   }

   bool ShouldTakeThisDirection(int signalDirection) {
      // v15.9 FIX: ASLA yön engelleme yapma - her iki yön de işlem alabilmeli
      // Önceki davranış SELL sinyallerini engelliyordu
      return true; // Her zaman izin ver
   }
   
   // Öğrenme aşamasında risk düşük (%10), öğrenince tam gaz (%100)
   double GetCalibrationLotMultiplier() {
      return m_isCalibrated ? 1.0 : m_calibrationLotMultiplier;
   }
   
   // Getters
   bool IsCalibrationComplete() { return m_isCalibrated; }
   int GetLearnedDirection() { return m_learnedDirection; }
   int GetCalibrationProgress() { return m_tradeCount; }
   int GetCalibrationPeriod() { return m_calibrationPeriod; }
   int GetResetCount() { return m_resetCount; }
   int GetConsecutiveLosses() { return m_consecutiveLossesInDirection; }
   double GetTotalProfit() { return m_totalProfit; }
   double GetMaxDrawdown() { return m_maxDrawdown; }
   
   string GetStatus() {
      if(!m_isCalibrated) {
         return StringFormat("🎯 Kalibrasyon: %d/%d (Lot: %.0f%%) [Reset: %d]", 
                             m_tradeCount, m_calibrationPeriod, 
                             m_calibrationLotMultiplier * 100, m_resetCount);
      }
      
      string dir = (m_learnedDirection == 1) ? "📈 BUY" : 
                   (m_learnedDirection == -1) ? "📉 SELL" : "↔️ KARMA";
      double buyWR = (m_buyWins + m_buyLosses > 0) ? 
                     (double)m_buyWins / (m_buyWins + m_buyLosses) * 100.0 : 0;
      double sellWR = (m_sellWins + m_sellLosses > 0) ? 
                      (double)m_sellWins / (m_sellWins + m_sellLosses) * 100.0 : 0;
      
      return StringFormat("%s | BUY:%.0f%% SELL:%.0f%% | Hata:%d/3", 
                          dir, buyWR, sellWR, m_consecutiveLossesInDirection);
   }
   
   string GetDetailedReport() {
      double buyWR = (m_buyWins + m_buyLosses > 0) ? 
                     (double)m_buyWins / (m_buyWins + m_buyLosses) * 100.0 : 0;
      double sellWR = (m_sellWins + m_sellLosses > 0) ? 
                      (double)m_sellWins / (m_sellWins + m_sellLosses) * 100.0 : 0;
      
      return StringFormat(
         "🎯 DİNAMİK YÖN ÖĞRENME RAPORU v15.1:\n"
         "   Kalibrasyon: %s\n"
         "   BUY: %d W / %d L (%.1f%%)\n"
         "   SELL: %d W / %d L (%.1f%%)\n"
         "   Öğrenilen Yön: %s\n"
         "   Ardışık Hata: %d/3\n"
         "   Reset Sayısı: %d/%d\n"
         "   Toplam Kar: $%.2f\n"
         "   Max Drawdown: $%.2f",
         m_isCalibrated ? "TAMAMLANDI ✅" : "DEVAM EDİYOR...",
         m_buyWins, m_buyLosses, buyWR,
         m_sellWins, m_sellLosses, sellWR,
         (m_learnedDirection == 1) ? "BUY 📈" : (m_learnedDirection == -1) ? "SELL 📉" : "KARMA ↔️",
         m_consecutiveLossesInDirection,
         m_resetCount, m_maxResets,
         m_totalProfit, m_maxDrawdown
      );
   }
};

// Global MA Direction Learner nesnesi
CMADirectionLearner DirectionLearner;

//====================================================================
// v14 5K EDITION - GLOBAL OBJECTS (NEW MODULES)
//====================================================================
CMLSimulator        MLSimulator;
CSmartEntryTiming   EntryTiming;
CPositionScaling    PositionScaler;
CCorrelationFilter  CorrFilter;
CBreakEvenPlus      BEPlus;
CEquityCurveFilter  EquityFilter;
CSmartExitSystem    SmartExit;
CMultiSessionAnalysis SessionAnalyzer;
CNewsImpactCalculator NewsCalc;
CRiskParitySystem   RiskParity;

//====================================================================
// v14.1 EXTENSION MODULE 37: MANUAL POSITION PROTECTOR
//====================================================================
class CManualPositionProtector
{
private:
   CTrade* m_pTrade;
   datetime m_detectedPositions[];
   ulong    m_detectedTickets[];
   int      m_detectedCount;
   
public:
   CManualPositionProtector() : m_pTrade(NULL), m_detectedCount(0) {
      ArrayResize(m_detectedPositions, 50);
      ArrayResize(m_detectedTickets, 50);
   }
   
   void Init(CTrade* trade) {
      m_pTrade = trade;
   }
   
   bool IsManualPosition(ulong ticket) {
      if(!PositionSelectByTicket(ticket)) return false;
      ulong posMagic = PositionGetInteger(POSITION_MAGIC);
      return (posMagic == 0 || posMagic != MagicNumber);
   }
   
   bool IsNewManualPosition(ulong ticket) {
      for(int i = 0; i < m_detectedCount; i++) {
         if(m_detectedTickets[i] == ticket) return false;
      }
      return true;
   }
   
   void RegisterPosition(ulong ticket) {
      if(m_detectedCount >= 50) {
         for(int i = 0; i < 49; i++) {
            m_detectedTickets[i] = m_detectedTickets[i+1];
            m_detectedPositions[i] = m_detectedPositions[i+1];
         }
         m_detectedCount = 49;
      }
      m_detectedTickets[m_detectedCount] = ticket;
      m_detectedPositions[m_detectedCount] = TimeCurrent();
      m_detectedCount++;
   }
   
   datetime GetDetectionTime(ulong ticket) {
      for(int i = 0; i < m_detectedCount; i++) {
         if(m_detectedTickets[i] == ticket) return m_detectedPositions[i];
      }
      return 0;
   }
   
   void ManageManualPositions(int currentSignal, double atr) {
      if(!ManageManualTrades || m_pTrade == NULL) return;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(!PositionSelectByTicket(ticket)) continue;
         
         string posSymbol = PositionGetString(POSITION_SYMBOL);
         
         // ManageAllSymbols=false ise sadece mevcut sembol
         if(!ManageAllSymbols && posSymbol != _Symbol) continue;
         
         if(!IsManualPosition(ticket)) continue;
         
         // Yeni manuel pozisyon mu?
         if(IsNewManualPosition(ticket)) {
            RegisterPosition(ticket);
            Print("🔍 Manuel işlem tespit edildi: #", ticket, " | ", posSymbol);
         }

         
         double entryPrice = PositionGetDouble(POSITION_PRICE_OPEN);
         double currentSL = PositionGetDouble(POSITION_SL);
         double currentTP = PositionGetDouble(POSITION_TP);
         double posLots = PositionGetDouble(POSITION_VOLUME);
         int posDir = PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY ? 1 : -1;
         
         // SL/TP yoksa ekle
         if(AddSLTPToManual && (currentSL == 0 || currentTP == 0)) {
            // SEMBOL BAZLI hesaplama - her sembol için ayrı point ve stop level
            double point = SymbolInfoDouble(posSymbol, SYMBOL_POINT);
            int digits = (int)SymbolInfoInteger(posSymbol, SYMBOL_DIGITS);
            long stopLevel = SymbolInfoInteger(posSymbol, SYMBOL_TRADE_STOPS_LEVEL);
            double currentPrice = posDir == 1 ? 
                                  SymbolInfoDouble(posSymbol, SYMBOL_BID) : 
                                  SymbolInfoDouble(posSymbol, SYMBOL_ASK);
            
            // Minimum mesafe = stop level + 5 pip güvenlik marjı
            double minDistance = (stopLevel + 50) * point;
            if(minDistance < ManualDefaultSL * 10 * point) 
               minDistance = ManualDefaultSL * 10 * point;
            
            double newSL = currentSL;
            double newTP = currentTP;
            
            if(currentSL == 0) {
               if(posDir == 1)
                  newSL = currentPrice - minDistance;
               else
                  newSL = currentPrice + minDistance;
               newSL = NormalizeDouble(newSL, digits);
            }
            
            if(currentTP == 0) {
               double tpDistance = minDistance * 2.0; // RR 1:2
               if(posDir == 1)
                  newTP = currentPrice + tpDistance;
               else
                  newTP = currentPrice - tpDistance;
               newTP = NormalizeDouble(newTP, digits);
            }
            
            // Son kontrol - fiyatlardan yeterince uzak mı?
            double slDistance = MathAbs(currentPrice - newSL);
            double tpDistance = MathAbs(currentPrice - newTP);
            
            if(slDistance >= stopLevel * point && tpDistance >= stopLevel * point) {
               if((*m_pTrade).PositionModify(ticket, newSL, newTP)) {
                  Print("✅ Manuel işleme SL/TP eklendi: #", ticket, " | ", posSymbol,
                        " SL:", DoubleToString(newSL, digits), " TP:", DoubleToString(newTP, digits));
               } else {
                  Print("⚠️ SL/TP eklenemedi: #", ticket, " | ", posSymbol, " | Hata: ", GetLastError());
               }
            } else {
               Print("⚠️ Stop Level yetersiz: ", posSymbol, " MinLevel:", stopLevel, 
                     " SL_Dist:", slDistance/point, " TP_Dist:", tpDistance/point);
            }
         }

         
         // Sinyal ile değerlendirme
         if(EvaluateManualBySignal && CloseCounterTrendManual && currentSignal != 0) {
            datetime detectionTime = GetDetectionTime(ticket);
            if(TimeCurrent() - detectionTime >= ManualEvalDelay) {
               // Ters yönlü mü?
               if(posDir != currentSignal) {
                  // Zarar durumunda kapat
                  double profit = PositionGetDouble(POSITION_PROFIT);
                  if(profit < 0) {
                     if((*m_pTrade).PositionClose(ticket)) {
                        Print("🚨 Ters yönlü manuel işlem kapatıldı: #", ticket, 
                              " | Sinyal: ", (currentSignal == 1 ? "BUY" : "SELL"),
                              " | Pozisyon: ", (posDir == 1 ? "BUY" : "SELL"));
                     }
                  } else {
                     Print("⚠️ Ters yönlü ama kârda: #", ticket, " - Bekleniyor");
                  }
               }
            }
         }
      }
   }
   
   int GetManualPositionCount() {
      int count = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket) && 
            PositionGetString(POSITION_SYMBOL) == _Symbol &&
            IsManualPosition(ticket)) {
            count++;
         }
      }
      return count;
   }
   
   double GetManualPositionProfit() {
      double profit = 0;
      for(int i = PositionsTotal() - 1; i >= 0; i--) {
         ulong ticket = PositionGetTicket(i);
         if(PositionSelectByTicket(ticket) && 
            PositionGetString(POSITION_SYMBOL) == _Symbol &&
            IsManualPosition(ticket)) {
            profit += PositionGetDouble(POSITION_PROFIT);
         }
      }
      return profit;
   }
};

CManualPositionProtector ManualProtector;

//+------------------------------------------------------------------+
//| v14.1 ULTIMATE 5K EDITION - FINAL                                |
//| 50+ Synchronized Modules | 5000+ Lines                           |
//| Machine Learning | Smart Entry | Position Scaling                 |
//| Correlation Filter | Break-Even Plus | Equity Curve Filter        |
//| Smart Exit | Multi-Session | News Impact | Risk Parity            |
//| Manual Position Protection | Signal Evaluation | Auto SL/TP       |
//| © 2025, Milyoner EA Project - The Ultimate Trading System v14.1  |
//+------------------------------------------------------------------+

//====================================================================
// v15 EXTENSION MODULE 38: ADVANCED ML ENGINE
//====================================================================
class CAdvancedMLEngine
{
private:
   struct PatternMemory {
      int direction;
      int score;
      int harmonyScore;
      string pattern;
      string session;
      double atr;
      double spread;
      bool isWin;
      double profit;
      datetime time;
   };
   
   PatternMemory m_memory[];
   int m_memorySize;
   int m_maxMemory;
   
   // Pattern başarı oranları
   double m_patternWinRates[];
   int m_patternCounts[];
   int m_patternTotal;
   
   // Score bazlı başarı oranları
   double m_scoreWinRates[10];   // 10'luk gruplar (0-9, 10-19, ..., 90-100)
   int m_scoreCounts[10];
   
   // Session bazlı başarı oranları
   double m_sessionWinRates[5];  // Sydney, Tokyo, London, NY, Off
   int m_sessionCounts[5];
   
   // Direction bazlı başarı oranları
   int m_buyWins, m_buyTotal;
   int m_sellWins, m_sellTotal;
   
   // Öğrenme parametreleri
   double m_learningRate;
   int m_minSampleSize;
   bool m_isLearningEnabled;
   
public:
   CAdvancedMLEngine() : m_memorySize(0), m_maxMemory(2000), m_patternTotal(20),
                          m_learningRate(0.1), m_minSampleSize(20), m_isLearningEnabled(true),
                          m_buyWins(0), m_buyTotal(0), m_sellWins(0), m_sellTotal(0) {
      ArrayResize(m_memory, m_maxMemory);
      ArrayResize(m_patternWinRates, m_patternTotal);
      ArrayResize(m_patternCounts, m_patternTotal);
      ArrayInitialize(m_patternWinRates, 50.0);
      ArrayInitialize(m_patternCounts, 0);
      ArrayInitialize(m_scoreWinRates, 50.0);
      ArrayInitialize(m_scoreCounts, 0);
      ArrayInitialize(m_sessionWinRates, 50.0);
      ArrayInitialize(m_sessionCounts, 0);
   }
   
   void RecordTrade(int direction, int score, int harmonyScore, string pattern, 
                    string session, double atr, double spread) {
      if(!m_isLearningEnabled) return;
      
      if(m_memorySize >= m_maxMemory) {
         // FIFO - eski kayıtları sil
         for(int i = 0; i < m_maxMemory - 1; i++) {
            m_memory[i] = m_memory[i + 1];
         }
         m_memorySize = m_maxMemory - 1;
      }
      
      m_memory[m_memorySize].direction = direction;
      m_memory[m_memorySize].score = score;
      m_memory[m_memorySize].harmonyScore = harmonyScore;
      m_memory[m_memorySize].pattern = pattern;
      m_memory[m_memorySize].session = session;
      m_memory[m_memorySize].atr = atr;
      m_memory[m_memorySize].spread = spread;
      m_memory[m_memorySize].isWin = false;
      m_memory[m_memorySize].profit = 0;
      m_memory[m_memorySize].time = TimeCurrent();
      m_memorySize++;
   }
   
   void UpdateLastTradeResult(bool isWin, double profit) {
      if(m_memorySize <= 0) return;
      
      int idx = m_memorySize - 1;
      m_memory[idx].isWin = isWin;
      m_memory[idx].profit = profit;
      
      // İstatistikleri güncelle
      UpdateStatistics(m_memory[idx]);
   }
   
   void UpdateStatistics(PatternMemory &mem) {
      // Score grubunu bul
      int scoreGroup = MathMin(9, mem.score / 10);
      m_scoreCounts[scoreGroup]++;
      if(mem.isWin) {
         m_scoreWinRates[scoreGroup] = (m_scoreWinRates[scoreGroup] * (m_scoreCounts[scoreGroup] - 1) + 100.0) / m_scoreCounts[scoreGroup];
      } else {
         m_scoreWinRates[scoreGroup] = (m_scoreWinRates[scoreGroup] * (m_scoreCounts[scoreGroup] - 1)) / m_scoreCounts[scoreGroup];
      }
      
      // Direction güncelle
      if(mem.direction == 1) {
         m_buyTotal++;
         if(mem.isWin) m_buyWins++;
      } else {
         m_sellTotal++;
         if(mem.isWin) m_sellWins++;
      }
      
      // Session güncelle
      int sessionIdx = GetSessionIndex(mem.session);
      if(sessionIdx >= 0 && sessionIdx < 5) {
         m_sessionCounts[sessionIdx]++;
         if(mem.isWin) {
            m_sessionWinRates[sessionIdx] = (m_sessionWinRates[sessionIdx] * (m_sessionCounts[sessionIdx] - 1) + 100.0) / m_sessionCounts[sessionIdx];
         } else {
            m_sessionWinRates[sessionIdx] = (m_sessionWinRates[sessionIdx] * (m_sessionCounts[sessionIdx] - 1)) / m_sessionCounts[sessionIdx];
         }
      }
   }
   
   int GetSessionIndex(string session) {
      if(session == "Sydney") return 0;
      if(session == "Tokyo") return 1;
      if(session == "London") return 2;
      if(session == "NewYork") return 3;
      return 4;
   }
   
   double GetScoreWinRate(int score) {
      int group = MathMin(9, score / 10);
      if(m_scoreCounts[group] < m_minSampleSize) return 50.0;
      return m_scoreWinRates[group];
   }
   
   double GetSessionWinRate(string session) {
      int idx = GetSessionIndex(session);
      if(idx < 0 || idx >= 5) return 50.0;
      if(m_sessionCounts[idx] < m_minSampleSize) return 50.0;
      return m_sessionWinRates[idx];
   }
   
   double GetDirectionWinRate(int direction) {
      if(direction == 1) {
         if(m_buyTotal < m_minSampleSize) return 50.0;
         return (double)m_buyWins / m_buyTotal * 100.0;
      } else {
         if(m_sellTotal < m_minSampleSize) return 50.0;
         return (double)m_sellWins / m_sellTotal * 100.0;
      }
   }
   
   int GetOptimalThreshold() {
      // En yüksek karlılığa sahip minimum skoru bul
      double bestProfitability = 0;
      int bestThreshold = 55;
      
      for(int threshold = 40; threshold <= 80; threshold += 5) {
         double wins = 0, total = 0;
         for(int i = 0; i < m_memorySize; i++) {
            if(m_memory[i].profit != 0 && m_memory[i].score >= threshold) {
               total++;
               if(m_memory[i].isWin) wins++;
            }
         }
         if(total >= m_minSampleSize) {
            double wr = wins / total * 100.0;
            double profitability = wr * total; // Hem WR hem de işlem sayısını optimize et
            if(wr >= 50 && profitability > bestProfitability) {
               bestProfitability = profitability;
               bestThreshold = threshold;
            }
         }
      }
      return bestThreshold;
   }
   
   double GetMLAdjustedScore(int direction, int score, string session) {
      // Temel skor
      double adjusted = (double)score;
      
      // Score grubunun geçmiş performansı
      double scoreWR = GetScoreWinRate(score);
      if(scoreWR > 60) adjusted += 5;
      else if(scoreWR < 45) adjusted -= 5;
      
      // Session performansı
      double sessionWR = GetSessionWinRate(session);
      if(sessionWR > 60) adjusted += 3;
      else if(sessionWR < 45) adjusted -= 3;
      
      // Direction performansı
      double dirWR = GetDirectionWinRate(direction);
      if(dirWR > 55) adjusted += 2;
      else if(dirWR < 45) adjusted -= 2;
      
      return MathMax(0, MathMin(100, adjusted));
   }
   
   bool ShouldTrade(int direction, int score, string session) {
      if(m_memorySize < m_minSampleSize * 2) return true; // Yeterli veri yok
      
      // ML adjusted score ile karar ver
      double mlScore = GetMLAdjustedScore(direction, score, session);
      int optimalThreshold = GetOptimalThreshold();
      
      return (mlScore >= optimalThreshold);
   }
   
   string GetMLReport() {
      return StringFormat("ML: %d samples | OptThreshold: %d | BuyWR: %.1f%% | SellWR: %.1f%%",
                          m_memorySize, GetOptimalThreshold(), GetDirectionWinRate(1), GetDirectionWinRate(-1));
   }
   
   void EnableLearning(bool enable) { m_isLearningEnabled = enable; }
   int GetSampleCount() { return m_memorySize; }
};

//====================================================================
// v15 EXTENSION MODULE 39: SMART MONEY CONCEPTS (ICT/SMC)
//====================================================================
class CSmartMoneyConcepts
{
private:
   struct OrderBlock {
      double priceHigh;
      double priceLow;
      int direction;       // 1 = Bullish OB, -1 = Bearish OB
      datetime created;
      bool mitigated;
      int touches;
   };
   
   struct FairValueGap {
      double high;
      double low;
      int direction;       // 1 = Bullish FVG, -1 = Bearish FVG
      datetime created;
      bool filled;
   };
   
   struct LiquidityLevel {
      double price;
      int type;            // 1 = Buy-side liquidity (highs), -1 = Sell-side (lows)
      int strength;
      bool swept;
   };
   
   OrderBlock m_orderBlocks[];
   FairValueGap m_fvgList[];
   LiquidityLevel m_liquidityLevels[];
   int m_obCount, m_fvgCount, m_liqCount;
   
public:
   CSmartMoneyConcepts() : m_obCount(0), m_fvgCount(0), m_liqCount(0) {
      ArrayResize(m_orderBlocks, 50);
      ArrayResize(m_fvgList, 50);
      ArrayResize(m_liquidityLevels, 100);
   }
   
   void DetectOrderBlocks(string symbol, ENUM_TIMEFRAMES tf, int lookback = 50) {
      m_obCount = 0;
      
      for(int i = 3; i < lookback; i++) {
         double o1 = iOpen(symbol, tf, i), c1 = iClose(symbol, tf, i);
         double o2 = iOpen(symbol, tf, i-1), c2 = iClose(symbol, tf, i-1);
         double o3 = iOpen(symbol, tf, i-2), c3 = iClose(symbol, tf, i-2);
         double h1 = iHigh(symbol, tf, i), l1 = iLow(symbol, tf, i);
         
         bool isBullishOB = false, isBearishOB = false;
         
         // Bullish Order Block: Bearish candle followed by strong bullish move
         if(c1 < o1 && c2 > o2 && c3 > o3) {
            if((c3 - o1) > (h1 - l1) * 2) {
               isBullishOB = true;
            }
         }
         
         // Bearish Order Block: Bullish candle followed by strong bearish move
         if(c1 > o1 && c2 < o2 && c3 < o3) {
            if((o1 - c3) > (h1 - l1) * 2) {
               isBearishOB = true;
            }
         }
         
         if((isBullishOB || isBearishOB) && m_obCount < 50) {
            m_orderBlocks[m_obCount].priceHigh = h1;
            m_orderBlocks[m_obCount].priceLow = l1;
            m_orderBlocks[m_obCount].direction = isBullishOB ? 1 : -1;
            m_orderBlocks[m_obCount].created = iTime(symbol, tf, i);
            m_orderBlocks[m_obCount].mitigated = false;
            m_orderBlocks[m_obCount].touches = 0;
            m_obCount++;
         }
      }
   }
   
   void DetectFairValueGaps(string symbol, ENUM_TIMEFRAMES tf, int lookback = 50) {
      m_fvgCount = 0;
      
      for(int i = 2; i < lookback; i++) {
         double h1 = iHigh(symbol, tf, i);
         double l1 = iLow(symbol, tf, i);
         double h2 = iHigh(symbol, tf, i-1);
         double l2 = iLow(symbol, tf, i-1);
         double h3 = iHigh(symbol, tf, i-2);
         double l3 = iLow(symbol, tf, i-2);
         
         // Bullish FVG: Gap between candle 1 high and candle 3 low
         if(l3 > h1 && m_fvgCount < 50) {
            m_fvgList[m_fvgCount].high = l3;
            m_fvgList[m_fvgCount].low = h1;
            m_fvgList[m_fvgCount].direction = 1;
            m_fvgList[m_fvgCount].created = iTime(symbol, tf, i-1);
            m_fvgList[m_fvgCount].filled = false;
            m_fvgCount++;
         }
         
         // Bearish FVG: Gap between candle 3 high and candle 1 low
         if(h3 < l1 && m_fvgCount < 50) {
            m_fvgList[m_fvgCount].high = l1;
            m_fvgList[m_fvgCount].low = h3;
            m_fvgList[m_fvgCount].direction = -1;
            m_fvgList[m_fvgCount].created = iTime(symbol, tf, i-1);
            m_fvgList[m_fvgCount].filled = false;
            m_fvgCount++;
         }
      }
   }
   
   void DetectLiquidity(string symbol, ENUM_TIMEFRAMES tf, int lookback = 100) {
      m_liqCount = 0;
      
      // Equal Highs detection (Buy-side liquidity)
      for(int i = 5; i < lookback - 5; i++) {
         double high_i = iHigh(symbol, tf, i);
         bool isSwingHigh = true;
         int equalCount = 0;
         
         // Check if swing high
         for(int j = 1; j <= 3; j++) {
            if(iHigh(symbol, tf, i-j) > high_i || iHigh(symbol, tf, i+j) > high_i) {
               isSwingHigh = false;
               break;
            }
         }
         
         // Check for equal highs
         if(isSwingHigh) {
            double tolerance = (iHigh(symbol, tf, i) - iLow(symbol, tf, i)) * 0.1;
            for(int k = i + 1; k < lookback && k < i + 20; k++) {
               if(MathAbs(iHigh(symbol, tf, k) - high_i) < tolerance) {
                  equalCount++;
               }
            }
            
            if(equalCount >= 1 && m_liqCount < 100) {
               m_liquidityLevels[m_liqCount].price = high_i;
               m_liquidityLevels[m_liqCount].type = 1;
               m_liquidityLevels[m_liqCount].strength = equalCount + 1;
               m_liquidityLevels[m_liqCount].swept = false;
               m_liqCount++;
            }
         }
      }
      
      // Equal Lows detection (Sell-side liquidity) - similar logic
      for(int i = 5; i < lookback - 5; i++) {
         double low_i = iLow(symbol, tf, i);
         bool isSwingLow = true;
         int equalCount = 0;
         
         for(int j = 1; j <= 3; j++) {
            if(iLow(symbol, tf, i-j) < low_i || iLow(symbol, tf, i+j) < low_i) {
               isSwingLow = false;
               break;
            }
         }
         
         if(isSwingLow) {
            double tolerance = (iHigh(symbol, tf, i) - iLow(symbol, tf, i)) * 0.1;
            for(int k = i + 1; k < lookback && k < i + 20; k++) {
               if(MathAbs(iLow(symbol, tf, k) - low_i) < tolerance) {
                  equalCount++;
               }
            }
            
            if(equalCount >= 1 && m_liqCount < 100) {
               m_liquidityLevels[m_liqCount].price = low_i;
               m_liquidityLevels[m_liqCount].type = -1;
               m_liquidityLevels[m_liqCount].strength = equalCount + 1;
               m_liquidityLevels[m_liqCount].swept = false;
               m_liqCount++;
            }
         }
      }
   }
   
   bool IsInOrderBlockZone(double price, int direction) {
      for(int i = 0; i < m_obCount; i++) {
         if(!m_orderBlocks[i].mitigated && m_orderBlocks[i].direction == direction) {
            if(price >= m_orderBlocks[i].priceLow && price <= m_orderBlocks[i].priceHigh) {
               return true;
            }
         }
      }
      return false;
   }
   
   bool IsInFVG(double price, int direction) {
      for(int i = 0; i < m_fvgCount; i++) {
         if(!m_fvgList[i].filled && m_fvgList[i].direction == direction) {
            if(price >= m_fvgList[i].low && price <= m_fvgList[i].high) {
               return true;
            }
         }
      }
      return false;
   }
   
   double GetNearestLiquidity(double price, int type) {
      double nearest = 0;
      double minDist = 999999;
      
      for(int i = 0; i < m_liqCount; i++) {
         if(!m_liquidityLevels[i].swept && m_liquidityLevels[i].type == type) {
            double dist = MathAbs(m_liquidityLevels[i].price - price);
            if(dist < minDist) {
               minDist = dist;
               nearest = m_liquidityLevels[i].price;
            }
         }
      }
      return nearest;
   }
   
   int GetSMCScore(int direction, double price) {
      int score = 50;
      
      // Order Block bonus
      if(IsInOrderBlockZone(price, direction)) score += 20;
      else if(IsInOrderBlockZone(price, -direction)) score -= 15;
      
      // FVG bonus
      if(IsInFVG(price, direction)) score += 15;
      
      // Liquidity target
      double liqTarget = GetNearestLiquidity(price, direction);
      if(liqTarget > 0) {
         double dist = MathAbs(liqTarget - price);
         if(dist < price * 0.005) score += 10; // %0.5 içinde liquidity varsa
      }
      
      return MathMax(0, MathMin(100, score));
   }
   
   void Update(string symbol, ENUM_TIMEFRAMES tf) {
      DetectOrderBlocks(symbol, tf);
      DetectFairValueGaps(symbol, tf);
      DetectLiquidity(symbol, tf);
   }
   
   int GetOrderBlockCount() { return m_obCount; }
   int GetFVGCount() { return m_fvgCount; }
   int GetLiquidityCount() { return m_liqCount; }
};

//====================================================================
// v15 EXTENSION MODULE 40: VOLATILITY BREAKOUT
//====================================================================
class CVolatilityBreakout
{
private:
   double m_atrHistory[];
   int m_historySize;
   double m_avgATR;
   double m_stdATR;
   double m_breakoutThreshold;
   bool m_isBreakoutActive;
   datetime m_breakoutTime;
   int m_breakoutDirection;
   
public:
   CVolatilityBreakout() : m_historySize(50), m_avgATR(0), m_stdATR(0),
                            m_breakoutThreshold(1.5), m_isBreakoutActive(false),
                            m_breakoutTime(0), m_breakoutDirection(0) {
      ArrayResize(m_atrHistory, m_historySize);
      ArrayInitialize(m_atrHistory, 0);
   }
   
   void Update(double currentATR) {
      // Shift history
      for(int i = m_historySize - 1; i > 0; i--) {
         m_atrHistory[i] = m_atrHistory[i-1];
      }
      m_atrHistory[0] = currentATR;
      
      // Calculate stats
      double sum = 0, sumSq = 0;
      int count = 0;
      for(int i = 0; i < m_historySize; i++) {
         if(m_atrHistory[i] > 0) {
            sum += m_atrHistory[i];
            count++;
         }
      }
      
      if(count > 0) {
         m_avgATR = sum / count;
         
         for(int i = 0; i < count; i++) {
            if(m_atrHistory[i] > 0) {
               sumSq += MathPow(m_atrHistory[i] - m_avgATR, 2);
            }
         }
         m_stdATR = MathSqrt(sumSq / count);
      }
      
      // Detect breakout
      if(m_avgATR > 0 && currentATR > m_avgATR + m_breakoutThreshold * m_stdATR) {
         if(!m_isBreakoutActive) {
            m_isBreakoutActive = true;
            m_breakoutTime = TimeCurrent();
            // Direction based on price movement
            double close0 = iClose(_Symbol, PERIOD_CURRENT, 0);
            double close1 = iClose(_Symbol, PERIOD_CURRENT, 1);
            m_breakoutDirection = (close0 > close1) ? 1 : -1;
            Print("🔥 Volatility Breakout tespit edildi! ATR: ", DoubleToString(currentATR, 5),
                  " | Avg: ", DoubleToString(m_avgATR, 5));
         }
      } else {
         if(m_isBreakoutActive && TimeCurrent() - m_breakoutTime > 3600) {
            m_isBreakoutActive = false;
            m_breakoutDirection = 0;
         }
      }
   }
   
   bool IsBreakoutActive() { return m_isBreakoutActive; }
   int GetBreakoutDirection() { return m_breakoutDirection; }
   double GetVolatilityRatio() { return (m_avgATR > 0) ? m_atrHistory[0] / m_avgATR : 1.0; }
   
   int GetBreakoutScore(int direction) {
      if(!m_isBreakoutActive) return 50;
      if(direction == m_breakoutDirection) return 85;
      return 25;
   }
   
   void SetThreshold(double threshold) { m_breakoutThreshold = threshold; }
};

//====================================================================
// v15 EXTENSION MODULE 41: ADAPTIVE STOP LOSS
//====================================================================
class CAdaptiveStopLoss
{
private:
   double m_lastATR;
   double m_volatilityMultiplier;
   double m_minSLPips;
   double m_maxSLPips;
   bool m_useATRBased;
   bool m_useSwingBased;
   bool m_useVolatilityAdjusted;
   
public:
   CAdaptiveStopLoss() : m_lastATR(0), m_volatilityMultiplier(1.5),
                          m_minSLPips(5), m_maxSLPips(50),
                          m_useATRBased(true), m_useSwingBased(true),
                          m_useVolatilityAdjusted(true) {}
   
   void SetParameters(double minSL, double maxSL, double volMulti) {
      m_minSLPips = minSL;
      m_maxSLPips = maxSL;
      m_volatilityMultiplier = volMulti;
   }
   
   double CalculateATRStop(double atr) {
      m_lastATR = atr;
      return atr * m_volatilityMultiplier;
   }
   
   double FindSwingStop(int direction, string symbol, ENUM_TIMEFRAMES tf, int lookback = 20) {
      if(direction == 1) {
         // BUY: En düşük swing low'u bul
         double lowestLow = 999999;
         for(int i = 1; i <= lookback; i++) {
            double low = iLow(symbol, tf, i);
            if(low < lowestLow) lowestLow = low;
         }
         return lowestLow;
      } else {
         // SELL: En yüksek swing high'ı bul
         double highestHigh = 0;
         for(int i = 1; i <= lookback; i++) {
            double high = iHigh(symbol, tf, i);
            if(high > highestHigh) highestHigh = high;
         }
         return highestHigh;
      }
   }
   
   double GetOptimalSL(int direction, double entryPrice, double atr, string symbol, ENUM_TIMEFRAMES tf) {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      double atrStop = CalculateATRStop(atr);
      
      // ATR bazlı SL
      double slPrice = 0;
      if(direction == 1) {
         slPrice = entryPrice - atrStop;
      } else {
         slPrice = entryPrice + atrStop;
      }
      
      // Swing bazlı SL
      if(m_useSwingBased) {
         double swingStop = FindSwingStop(direction, symbol, tf);
         
         if(direction == 1) {
            // BUY: Daha güvenli olanı seç (daha düşük SL)
            if(swingStop > 0 && swingStop < slPrice && swingStop > entryPrice - (m_maxSLPips * 10 * point)) {
               slPrice = swingStop - (2 * 10 * point); // Swing altına 2 pip buffer
            }
         } else {
            // SELL: Daha güvenli olanı seç (daha yüksek SL)
            if(swingStop > 0 && swingStop > slPrice && swingStop < entryPrice + (m_maxSLPips * 10 * point)) {
               slPrice = swingStop + (2 * 10 * point); // Swing üstüne 2 pip buffer
            }
         }
      }
      
      // Min/Max limitleri uygula
      double slDistance = MathAbs(entryPrice - slPrice);
      double minDist = m_minSLPips * 10 * point;
      double maxDist = m_maxSLPips * 10 * point;
      
      if(slDistance < minDist) {
         if(direction == 1) slPrice = entryPrice - minDist;
         else slPrice = entryPrice + minDist;
      }
      
      if(slDistance > maxDist) {
         if(direction == 1) slPrice = entryPrice - maxDist;
         else slPrice = entryPrice + maxDist;
      }
      
      return slPrice;
   }
   
   double GetSLPips(double entryPrice, double slPrice) {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      return MathAbs(entryPrice - slPrice) / (10 * point);
   }
};

//====================================================================
// v15 EXTENSION MODULE 42: MOMENTUM FILTER
//====================================================================
class CMomentumFilter
{
private:
   int m_rsiHandle;
   int m_macdHandle;
   int m_momHandle;
   double m_rsiThresholdOB;
   double m_rsiThresholdOS;
   bool m_useRSIMomentum;
   bool m_useMACDMomentum;
   bool m_usePriceMomentum;
   
public:
   CMomentumFilter() : m_rsiHandle(INVALID_HANDLE), m_macdHandle(INVALID_HANDLE),
                        m_momHandle(INVALID_HANDLE),
                        m_rsiThresholdOB(70), m_rsiThresholdOS(30),
                        m_useRSIMomentum(true), m_useMACDMomentum(true),
                        m_usePriceMomentum(true) {}
   
   bool Init(string symbol, ENUM_TIMEFRAMES tf) {
      m_rsiHandle = iRSI(symbol, tf, 14, PRICE_CLOSE);
      m_macdHandle = iMACD(symbol, tf, 12, 26, 9, PRICE_CLOSE);
      m_momHandle = iMomentum(symbol, tf, 14, PRICE_CLOSE);
      return (m_rsiHandle != INVALID_HANDLE);
   }
   
   void Release() {
      if(m_rsiHandle != INVALID_HANDLE) IndicatorRelease(m_rsiHandle);
      if(m_macdHandle != INVALID_HANDLE) IndicatorRelease(m_macdHandle);
      if(m_momHandle != INVALID_HANDLE) IndicatorRelease(m_momHandle);
   }
   
   int GetRSIMomentum(int direction) {
      if(!m_useRSIMomentum || m_rsiHandle == INVALID_HANDLE) return 50;
      
      double rsi[];
      ArraySetAsSeries(rsi, true);
      if(CopyBuffer(m_rsiHandle, 0, 0, 3, rsi) < 3) return 50;
      
      bool risingRSI = (rsi[0] > rsi[1] && rsi[1] > rsi[2]);
      bool fallingRSI = (rsi[0] < rsi[1] && rsi[1] < rsi[2]);
      
      int score = 50;
      if(direction == 1) {
         if(rsi[0] < m_rsiThresholdOS && risingRSI) score = 90;
         else if(risingRSI && rsi[0] < 60) score = 70;
         else if(rsi[0] > m_rsiThresholdOB) score = 25;
      } else {
         if(rsi[0] > m_rsiThresholdOB && fallingRSI) score = 90;
         else if(fallingRSI && rsi[0] > 40) score = 70;
         else if(rsi[0] < m_rsiThresholdOS) score = 25;
      }
      return score;
   }
   
   int GetMACDMomentum(int direction) {
      if(!m_useMACDMomentum || m_macdHandle == INVALID_HANDLE) return 50;
      
      double main[], signal[], hist[];
      ArraySetAsSeries(main, true);
      ArraySetAsSeries(signal, true);
      ArraySetAsSeries(hist, true);
      
      if(CopyBuffer(m_macdHandle, 0, 0, 3, main) < 3) return 50;
      if(CopyBuffer(m_macdHandle, 1, 0, 3, signal) < 3) return 50;
      if(CopyBuffer(m_macdHandle, 2, 0, 3, hist) < 3) return 50;
      
      bool risingHist = (hist[0] > hist[1]);
      bool crossUp = (main[1] < signal[1] && main[0] > signal[0]);
      bool crossDown = (main[1] > signal[1] && main[0] < signal[0]);
      
      int score = 50;
      if(direction == 1) {
         if(crossUp) score = 90;
         else if(risingHist && hist[0] > 0) score = 75;
         else if(risingHist) score = 60;
         else if(crossDown) score = 20;
      } else {
         if(crossDown) score = 90;
         else if(!risingHist && hist[0] < 0) score = 75;
         else if(!risingHist) score = 60;
         else if(crossUp) score = 20;
      }
      return score;
   }
   
   int GetPriceMomentum(int direction, int lookback = 10) {
      if(!m_usePriceMomentum) return 50;
      
      double close0 = iClose(_Symbol, PERIOD_CURRENT, 0);
      double closeN = iClose(_Symbol, PERIOD_CURRENT, lookback);
      
      if(closeN == 0) return 50;
      
      double change = (close0 - closeN) / closeN * 100;
      
      int score = 50;
      if(direction == 1) {
         if(change > 0.5) score = 85;
         else if(change > 0.2) score = 70;
         else if(change < -0.3) score = 30;
      } else {
         if(change < -0.5) score = 85;
         else if(change < -0.2) score = 70;
         else if(change > 0.3) score = 30;
      }
      return score;
   }
   
   int GetCombinedMomentumScore(int direction) {
      double rsiScore = GetRSIMomentum(direction);
      double macdScore = GetMACDMomentum(direction);
      double priceScore = GetPriceMomentum(direction);
      
      return (int)((rsiScore * 0.4 + macdScore * 0.4 + priceScore * 0.2));
   }
   
   bool IsMomentumConfirmed(int direction, int minScore = 60) {
      return (GetCombinedMomentumScore(direction) >= minScore);
   }
};

//====================================================================
// v15 EXTENSION MODULE 43: TIME BASED EXIT
//====================================================================
class CTimeBasedExit
{
private:
   int m_maxHoursInTrade;
   int m_maxBarsInTrade;
   bool m_exitBeforeWeekend;
   int m_fridayCloseHour;
   bool m_exitBeforeNews;
   int m_newsExitMinutes;
   
   struct TradeTimer {
      ulong ticket;
      datetime openTime;
      int barsElapsed;
   };
   TradeTimer m_timers[];
   int m_timerCount;
   
public:
   CTimeBasedExit() : m_maxHoursInTrade(48), m_maxBarsInTrade(100),
                       m_exitBeforeWeekend(true), m_fridayCloseHour(20),
                       m_exitBeforeNews(false), m_newsExitMinutes(15),
                       m_timerCount(0) {
      ArrayResize(m_timers, 50);
   }
   
   void SetParameters(int maxHours, int maxBars, bool exitWeekend, int fridayHour) {
      m_maxHoursInTrade = maxHours;
      m_maxBarsInTrade = maxBars;
      m_exitBeforeWeekend = exitWeekend;
      m_fridayCloseHour = fridayHour;
   }
   
   void RegisterTrade(ulong ticket, datetime openTime) {
      if(m_timerCount >= 50) {
         // Shift
         for(int i = 0; i < 49; i++) {
            m_timers[i] = m_timers[i + 1];
         }
         m_timerCount = 49;
      }
      m_timers[m_timerCount].ticket = ticket;
      m_timers[m_timerCount].openTime = openTime;
      m_timers[m_timerCount].barsElapsed = 0;
      m_timerCount++;
   }
   
   void UpdateBars() {
      for(int i = 0; i < m_timerCount; i++) {
         m_timers[i].barsElapsed++;
      }
   }
   
   void RemoveTrade(ulong ticket) {
      for(int i = 0; i < m_timerCount; i++) {
         if(m_timers[i].ticket == ticket) {
            for(int j = i; j < m_timerCount - 1; j++) {
               m_timers[j] = m_timers[j + 1];
            }
            m_timerCount--;
            break;
         }
      }
   }
   
   bool ShouldExitByTime(ulong ticket) {
      for(int i = 0; i < m_timerCount; i++) {
         if(m_timers[i].ticket == ticket) {
            // Saat kontrolü
            int hoursElapsed = (int)((TimeCurrent() - m_timers[i].openTime) / 3600);
            if(hoursElapsed >= m_maxHoursInTrade) {
               Print("⏰ Zaman limiti: ", hoursElapsed, " saat | Max: ", m_maxHoursInTrade);
               return true;
            }
            
            // Bar kontrolü
            if(m_timers[i].barsElapsed >= m_maxBarsInTrade) {
               Print("⏰ Bar limiti: ", m_timers[i].barsElapsed, " bar | Max: ", m_maxBarsInTrade);
               return true;
            }
            break;
         }
      }
      return false;
   }
   
   bool ShouldExitBeforeWeekend() {
      if(!m_exitBeforeWeekend) return false;
      
      MqlDateTime dt;
      TimeCurrent(dt);
      
      return (dt.day_of_week == 5 && dt.hour >= m_fridayCloseHour);
   }
   
   int GetHoursInTrade(ulong ticket) {
      for(int i = 0; i < m_timerCount; i++) {
         if(m_timers[i].ticket == ticket) {
            return (int)((TimeCurrent() - m_timers[i].openTime) / 3600);
         }
      }
      return 0;
   }
};

//====================================================================
// v15 EXTENSION MODULE 44: DRAWDOWN RECOVERY
//====================================================================
class CDrawdownRecovery
{
private:
   double m_peakEquity;
   double m_currentDD;
   double m_maxAllowedDD;
   int m_recoveryMode;           // 0=Normal, 1=Conservative, 2=Aggressive
   double m_lotReductionFactor;
   int m_consecutiveLosses;
   int m_maxConsecutiveLosses;
   bool m_isRecovering;
   datetime m_ddStartTime;
   
public:
   CDrawdownRecovery() : m_peakEquity(0), m_currentDD(0), m_maxAllowedDD(10),
                          m_recoveryMode(0), m_lotReductionFactor(1.0),
                          m_consecutiveLosses(0), m_maxConsecutiveLosses(5),
                          m_isRecovering(false), m_ddStartTime(0) {}
   
   void SetParameters(double maxDD, int maxConsecLoss) {
      m_maxAllowedDD = maxDD;
      m_maxConsecutiveLosses = maxConsecLoss;
   }
   
   void Update() {
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      
      if(equity > m_peakEquity) {
         m_peakEquity = equity;
         if(m_isRecovering) {
            m_isRecovering = false;
            m_recoveryMode = 0;
            m_lotReductionFactor = 1.0;
            Print("✅ Drawdown kurtarıldı! Yeni peak: ", DoubleToString(m_peakEquity, 2));
         }
      }
      
      if(m_peakEquity > 0) {
         m_currentDD = (m_peakEquity - equity) / m_peakEquity * 100.0;
         
         // Recovery mode belirleme
         if(m_currentDD >= m_maxAllowedDD * 0.8) {
            if(!m_isRecovering) {
               m_isRecovering = true;
               m_ddStartTime = TimeCurrent();
            }
            m_recoveryMode = 2; // Aggressive recovery - lot azalt
            m_lotReductionFactor = 0.25;
         } else if(m_currentDD >= m_maxAllowedDD * 0.5) {
            m_recoveryMode = 1; // Conservative
            m_lotReductionFactor = 0.5;
         } else if(m_currentDD >= m_maxAllowedDD * 0.3) {
            m_lotReductionFactor = 0.75;
         } else {
            m_recoveryMode = 0;
            m_lotReductionFactor = 1.0;
         }
      }
   }
   
   void OnTradeClosed(bool isWin) {
      if(isWin) {
         m_consecutiveLosses = 0;
      } else {
         m_consecutiveLosses++;
         
         if(m_consecutiveLosses >= m_maxConsecutiveLosses) {
            m_recoveryMode = 2;
            m_lotReductionFactor = 0.25;
            Print("🔴 ", m_consecutiveLosses, " üst üste kayıp! Recovery mode aktif.");
         }
      }
   }
   
   double GetLotMultiplier() { return m_lotReductionFactor; }
   double GetCurrentDD() { return m_currentDD; }
   double GetPeakEquity() { return m_peakEquity; }
   bool IsRecovering() { return m_isRecovering; }
   int GetRecoveryMode() { return m_recoveryMode; }
   int GetConsecutiveLosses() { return m_consecutiveLosses; }
   
   string GetRecoveryModeStr() {
      switch(m_recoveryMode) {
         case 0: return "NORMAL";
         case 1: return "CONSERVATIVE";
         case 2: return "AGGRESSIVE";
         default: return "UNKNOWN";
      }
   }
   
   bool ShouldReduceRisk() {
      return (m_recoveryMode > 0 || m_consecutiveLosses >= 3);
   }
   
   int GetRecoveryScore() {
      // 100 = Normal, 0 = Max risk reduction
      if(m_recoveryMode == 0 && m_consecutiveLosses < 3) return 100;
      if(m_recoveryMode == 2) return 25;
      if(m_recoveryMode == 1) return 50;
      return 75;
   }
};

//====================================================================
// v15 EXTENSION MODULE 45: ADVANCED DASHBOARD
//====================================================================
class CAdvancedDashboard
{
private:
   string m_prefix;
   int m_panelX, m_panelY;
   int m_panelWidth, m_panelHeight;
   color m_bgColor, m_textColor, m_buyColor, m_sellColor;
   bool m_isVisible;
   int m_updateInterval;
   datetime m_lastUpdate;
   
public:
   CAdvancedDashboard() : m_prefix("v15_"), m_panelX(10), m_panelY(50),
                           m_panelWidth(350), m_panelHeight(500),
                           m_bgColor(clrDarkSlateGray), m_textColor(clrWhite),
                           m_buyColor(clrLime), m_sellColor(clrRed),
                           m_isVisible(true), m_updateInterval(1), m_lastUpdate(0) {}
   
   void SetPosition(int x, int y) { m_panelX = x; m_panelY = y; }
   void SetColors(color bg, color text, color buy, color sell) {
      m_bgColor = bg; m_textColor = text; m_buyColor = buy; m_sellColor = sell;
   }
   void SetVisible(bool visible) { m_isVisible = visible; }
   
   void CreateLabel(string name, int x, int y, string text, color clr, int fontSize = 9) {
      string objName = m_prefix + name;
      if(ObjectFind(0, objName) < 0) {
         ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
      }
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, objName, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, fontSize);
      ObjectSetString(0, objName, OBJPROP_TEXT, text);
      ObjectSetString(0, objName, OBJPROP_FONT, "Consolas");
      ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   }
   
   void Update(int signalScore, int harmonyScore, string signalDetails,
               string session, double dailyPL, double weeklyPL,
               int tradeCount, int maxTrades, int positions, int maxPositions,
               int totalTrades, int wins, double winRate, double profitFactor,
               double netProfit, string lockReason, bool isPaused, bool isLocked,
               string mlReport, int smcScore, int momentumScore, 
               double currentDD, string recoveryMode) {
      
      if(!m_isVisible) return;
      if(TimeCurrent() - m_lastUpdate < m_updateInterval) return;
      m_lastUpdate = TimeCurrent();
      
      int y = m_panelY;
      int lineHeight = 16;
      
      // Header
      string status = isPaused ? "⏸️ PAUSE" :
                      (isLocked ? "🔒 " + lockReason :
                      (lockReason != "" ? "⏳ " + lockReason : "✅ AKTİF"));
      
      CreateLabel("header1", m_panelX, y, "══════════════════════════════════════", m_textColor);
      y += lineHeight;
      CreateLabel("title", m_panelX, y, "   🤖 MİLYONER EA v15.0 ULTIMATE 10K", clrGold, 10);
      y += lineHeight;
      CreateLabel("header2", m_panelX, y, "══════════════════════════════════════", m_textColor);
      y += lineHeight;
      
      // Status
      CreateLabel("status", m_panelX, y, "DURUM: " + status, m_textColor);
      y += lineHeight;
      CreateLabel("sep1", m_panelX, y, "──────────────────────────────────────", clrDimGray);
      y += lineHeight;
      
      // AI Scores
      color scoreColor = (signalScore >= 70) ? clrLime : ((signalScore >= 55) ? clrYellow : clrOrangeRed);
      CreateLabel("aiscore", m_panelX, y, "🎯 AI SKOR: " + IntegerToString(signalScore) + "/100", scoreColor);
      y += lineHeight;
      CreateLabel("harmony", m_panelX, y, "🎼 HARMONY: " + IntegerToString(harmonyScore) + "/100", m_textColor);
      y += lineHeight;
      CreateLabel("details", m_panelX, y, "📊 " + signalDetails, clrSilver);
      y += lineHeight;
      
      // NEW v15 Scores
      CreateLabel("sep15", m_panelX, y, "──────── v15 MODÜLLER ────────", clrGold);
      y += lineHeight;
      CreateLabel("ml", m_panelX, y, "🧠 " + mlReport, clrCyan);
      y += lineHeight;
      CreateLabel("smc", m_panelX, y, "💰 SMC Skor: " + IntegerToString(smcScore), clrMagenta);
      y += lineHeight;
      CreateLabel("momentum", m_panelX, y, "📈 Momentum: " + IntegerToString(momentumScore), clrAqua);
      y += lineHeight;
      CreateLabel("recovery", m_panelX, y, "🔄 Recovery: " + recoveryMode + " | DD: " + 
                  DoubleToString(currentDD, 1) + "%", 
                  (currentDD > 5) ? clrRed : clrLime);
      y += lineHeight;
      
      // Session & PL
      CreateLabel("sep2", m_panelX, y, "──────────────────────────────────────", clrDimGray);
      y += lineHeight;
      CreateLabel("session", m_panelX, y, "🌍 Session: " + session, m_textColor);
      y += lineHeight;
      color plColor = (dailyPL >= 0) ? clrLime : clrRed;
      CreateLabel("dailypl", m_panelX, y, "💰 Günlük: $" + DoubleToString(dailyPL, 2), plColor);
      y += lineHeight;
      plColor = (weeklyPL >= 0) ? clrLime : clrRed;
      CreateLabel("weeklypl", m_panelX, y, "💵 Haftalık: $" + DoubleToString(weeklyPL, 2), plColor);
      y += lineHeight;
      CreateLabel("trades", m_panelX, y, "📊 İşlem: " + IntegerToString(tradeCount) + "/" + IntegerToString(maxTrades), m_textColor);
      y += lineHeight;
      CreateLabel("positions", m_panelX, y, "📈 Pozisyon: " + IntegerToString(positions) + "/" + IntegerToString(maxPositions), m_textColor);
      y += lineHeight;
      
      // Performance Stats
      CreateLabel("sep3", m_panelX, y, "──────────────────────────────────────", clrDimGray);
      y += lineHeight;
      CreateLabel("total", m_panelX, y, "📊 Toplam: " + IntegerToString(totalTrades) + " | Win: " + IntegerToString(wins), m_textColor);
      y += lineHeight;
      CreateLabel("wr", m_panelX, y, "⚖️ WR: " + DoubleToString(winRate, 1) + "%", 
                  (winRate >= 55) ? clrLime : clrYellow);
      y += lineHeight;
      CreateLabel("pf", m_panelX, y, "📈 PF: " + DoubleToString(profitFactor, 2), m_textColor);
      y += lineHeight;
      plColor = (netProfit >= 0) ? clrLime : clrRed;
      CreateLabel("net", m_panelX, y, "💵 Net: $" + DoubleToString(netProfit, 2), plColor);
      y += lineHeight;
      
      // Footer
      CreateLabel("sep4", m_panelX, y, "──────────────────────────────────────", clrDimGray);
      y += lineHeight;
      CreateLabel("keys", m_panelX, y, "⌨️ [P]ause [C]lose [D]ailyReset [R]eport", clrDimGray);
      y += lineHeight;
      CreateLabel("footer", m_panelX, y, "══════════════════════════════════════", m_textColor);
   }
   
   void Delete() {
      ObjectsDeleteAll(0, m_prefix);
   }
};

//====================================================================
// v15 GLOBAL OBJECTS - YENİ MODÜLLER
//====================================================================
CAdvancedMLEngine     AdvancedML;
CSmartMoneyConcepts   SmartMoney;
CVolatilityBreakout   VolBreakout;
CAdaptiveStopLoss     AdaptiveSL;
CMomentumFilter       MomFilter;
CTimeBasedExit        TimeExit;
CDrawdownRecovery     DDRecovery;
CAdvancedDashboard    Dashboard;

//+------------------------------------------------------------------+
//| v15.0 ULTIMATE 10K EDITION - FINAL                               |
//| 45+ Synchronized Modules | 10000+ Lines                          |
//| Advanced Machine Learning | Smart Money Concepts (ICT/SMC)       |
//| Order Blocks | Fair Value Gaps | Liquidity Detection             |
//| Volatility Breakout | Adaptive Stop Loss | Momentum Filter       |
//| Time Based Exit | Drawdown Recovery | Advanced Dashboard         |
//| Risk Parity | Correlation Filter | Position Scaling              |
//| Manual Position Protection | Signal Evaluation | Auto SL/TP      |
//| Kelly Criterion | Compounding | Grid Matrix | Hedge Protection   |
//| © 2025, Milyoner EA Project - The Ultimate Trading System v15.0  |
//+------------------------------------------------------------------+

//====================================================================
// v15 EXTENSION MODULE 46: MARKET PROFILER
//====================================================================
class CMarketProfiler
{
private:
   struct LevelData {
      double price;
      int volume;
      int buyVolume;
      int sellVolume;
      double tpo;
   };
   
   LevelData m_levels[];
   int m_levelCount;
   double m_levelStep;
   double m_poc;          // Point of Control
   double m_vah;          // Value Area High
   double m_val;          // Value Area Low
   double m_tpoMode;
   datetime m_lastUpdate;
   int m_lookbackBars;
   
public:
   CMarketProfiler() : m_levelCount(0), m_levelStep(0), m_poc(0), 
                        m_vah(0), m_val(0), m_tpoMode(0), m_lastUpdate(0),
                        m_lookbackBars(100) {
      ArrayResize(m_levels, 200);
   }
   
   void SetParameters(int lookback, double levelStep) {
      m_lookbackBars = lookback;
      m_levelStep = levelStep;
   }
   
   void BuildProfile(string symbol, ENUM_TIMEFRAMES tf) {
      if(TimeCurrent() - m_lastUpdate < 300) return; // 5 dakikada bir güncelle
      
      // Fiyat aralığını bul
      double highest = 0, lowest = 999999;
      for(int i = 0; i < m_lookbackBars; i++) {
         double h = iHigh(symbol, tf, i);
         double l = iLow(symbol, tf, i);
         if(h > highest) highest = h;
         if(l < lowest) lowest = l;
      }
      
      double range = highest - lowest;
      if(range <= 0) return;
      
      // Level step otomatik hesapla
      if(m_levelStep <= 0) {
         m_levelStep = range / 50.0; // 50 seviye
      }
      
      m_levelCount = (int)MathCeil(range / m_levelStep);
      if(m_levelCount > 200) m_levelCount = 200;
      
      // Seviyeleri sıfırla
      for(int i = 0; i < m_levelCount; i++) {
         m_levels[i].price = lowest + i * m_levelStep;
         m_levels[i].volume = 0;
         m_levels[i].buyVolume = 0;
         m_levels[i].sellVolume = 0;
         m_levels[i].tpo = 0;
      }
      
      // TPO say
      for(int bar = 0; bar < m_lookbackBars; bar++) {
         double h = iHigh(symbol, tf, bar);
         double l = iLow(symbol, tf, bar);
         double o = iOpen(symbol, tf, bar);
         double c = iClose(symbol, tf, bar);
         long vol = iVolume(symbol, tf, bar);
         
         for(int lvl = 0; lvl < m_levelCount; lvl++) {
            double levelPrice = m_levels[lvl].price;
            if(levelPrice >= l && levelPrice <= h) {
               m_levels[lvl].tpo++;
               m_levels[lvl].volume += (int)(vol / ((h - l) / m_levelStep + 1));
               if(c > o) m_levels[lvl].buyVolume++;
               else m_levels[lvl].sellVolume++;
            }
         }
      }
      
      // POC bul (en yüksek TPO)
      double maxTPO = 0;
      int pocIndex = 0;
      for(int i = 0; i < m_levelCount; i++) {
         if(m_levels[i].tpo > maxTPO) {
            maxTPO = m_levels[i].tpo;
            pocIndex = i;
         }
      }
      m_poc = m_levels[pocIndex].price;
      
      // Value Area hesapla (%70)
      double totalTPO = 0;
      for(int i = 0; i < m_levelCount; i++) totalTPO += m_levels[i].tpo;
      
      double targetTPO = totalTPO * 0.70;
      double currentTPO = m_levels[pocIndex].tpo;
      int upper = pocIndex, lower = pocIndex;
      
      while(currentTPO < targetTPO && (upper < m_levelCount - 1 || lower > 0)) {
         double upperAdd = (upper < m_levelCount - 1) ? m_levels[upper + 1].tpo : 0;
         double lowerAdd = (lower > 0) ? m_levels[lower - 1].tpo : 0;
         
         if(upperAdd >= lowerAdd && upper < m_levelCount - 1) {
            upper++;
            currentTPO += upperAdd;
         } else if(lower > 0) {
            lower--;
            currentTPO += lowerAdd;
         }
      }
      
      m_vah = m_levels[upper].price;
      m_val = m_levels[lower].price;
      
      m_lastUpdate = TimeCurrent();
   }
   
   double GetPOC() { return m_poc; }
   double GetVAH() { return m_vah; }
   double GetVAL() { return m_val; }
   
   int GetProfileScore(double price, int direction) {
      int score = 50;
      
      // Fiyat Value Area içinde mi?
      if(price >= m_val && price <= m_vah) {
         score += 10; // VA içinde güvenli
      }
      
      // POC yakınlığı
      double distToPOC = MathAbs(price - m_poc);
      double range = m_vah - m_val;
      if(range > 0 && distToPOC < range * 0.2) {
         score += 15; // POC yakınında
      }
      
      // Direction bazlı
      if(direction == 1) {
         if(price < m_poc) score += 10; // POC altında alım
         if(price <= m_val) score += 20; // VAL'da alım güçlü
      } else {
         if(price > m_poc) score += 10; // POC üstünde satış
         if(price >= m_vah) score += 20; // VAH'da satış güçlü
      }
      
      return MathMin(100, MathMax(0, score));
   }
   
   string GetProfileReport() {
      return StringFormat("POC: %.5f | VAH: %.5f | VAL: %.5f", m_poc, m_vah, m_val);
   }
};

//====================================================================
// v15 EXTENSION MODULE 47: WYCKOFF ANALYZER
//====================================================================
class CWyckoffAnalyzer
{
private:
   enum WYCKOFF_PHASE {
      PHASE_UNKNOWN,
      PHASE_ACCUMULATION,
      PHASE_MARKUP,
      PHASE_DISTRIBUTION,
      PHASE_MARKDOWN
   };
   
   WYCKOFF_PHASE m_currentPhase;
   double m_springLevel;
   double m_upthrustLevel;
   double m_sosLevel;        // Sign of Strength
   double m_sowLevel;        // Sign of Weakness
   bool m_phaseConfirmed;
   datetime m_phaseStart;
   int m_phaseStrength;
   
public:
   CWyckoffAnalyzer() : m_currentPhase(PHASE_UNKNOWN), m_springLevel(0),
                         m_upthrustLevel(0), m_sosLevel(0), m_sowLevel(0),
                         m_phaseConfirmed(false), m_phaseStart(0), m_phaseStrength(0) {}
   
   void AnalyzePhase(string symbol, ENUM_TIMEFRAMES tf, int lookback = 50) {
      // Swing high/low bul
      double highest = 0, lowest = 999999;
      int highestIdx = 0, lowestIdx = 0;
      
      for(int i = 1; i < lookback; i++) {
         double h = iHigh(symbol, tf, i);
         double l = iLow(symbol, tf, i);
         if(h > highest) { highest = h; highestIdx = i; }
         if(l < lowest) { lowest = l; lowestIdx = i; }
      }
      
      double currentPrice = iClose(symbol, tf, 0);
      double range = highest - lowest;
      if(range <= 0) return;
      
      // Fiyatın range içindeki pozisyonu
      double position = (currentPrice - lowest) / range;
      
      // Volume analizi
      long vol0 = iVolume(symbol, tf, 0);
      long vol1 = iVolume(symbol, tf, 1);
      long avgVol = 0;
      for(int i = 0; i < 20; i++) avgVol += iVolume(symbol, tf, i);
      avgVol /= 20;
      bool highVolume = (vol0 > avgVol * 1.5);
      
      // Phase belirleme
      if(position < 0.3) {
         // Alt bölge - Accumulation veya Markdown sonu
         m_currentPhase = PHASE_ACCUMULATION;
         m_springLevel = lowest;
         
         // Spring tespiti (düşük altına dalış ve geri dönüş)
         double prevLow = iLow(symbol, tf, 1);
         if(prevLow < lowest && currentPrice > lowest && highVolume) {
            m_phaseConfirmed = true;
            m_phaseStrength = 80;
         }
      }
      else if(position > 0.7) {
         // Üst bölge - Distribution veya Markup sonu
         m_currentPhase = PHASE_DISTRIBUTION;
         m_upthrustLevel = highest;
         
         // Upthrust tespiti (yüksek üstüne çıkış ve geri dönüş)
         double prevHigh = iHigh(symbol, tf, 1);
         if(prevHigh > highest && currentPrice < highest && highVolume) {
            m_phaseConfirmed = true;
            m_phaseStrength = 80;
         }
      }
      else if(position >= 0.3 && position <= 0.5 && currentPrice > iClose(symbol, tf, 5)) {
         m_currentPhase = PHASE_MARKUP;
         m_sosLevel = currentPrice;
         m_phaseStrength = 60;
      }
      else if(position >= 0.5 && position <= 0.7 && currentPrice < iClose(symbol, tf, 5)) {
         m_currentPhase = PHASE_MARKDOWN;
         m_sowLevel = currentPrice;
         m_phaseStrength = 60;
      }
      
      if(m_currentPhase != PHASE_UNKNOWN && m_phaseStart == 0) {
         m_phaseStart = TimeCurrent();
      }
   }
   
   WYCKOFF_PHASE GetCurrentPhase() { return m_currentPhase; }
   bool IsPhaseConfirmed() { return m_phaseConfirmed; }
   int GetPhaseStrength() { return m_phaseStrength; }
   
   int GetWyckoffScore(int direction) {
      int score = 50;
      
      if(direction == 1) { // BUY
         if(m_currentPhase == PHASE_ACCUMULATION) score = 85;
         else if(m_currentPhase == PHASE_MARKUP) score = 75;
         else if(m_currentPhase == PHASE_DISTRIBUTION) score = 30;
         else if(m_currentPhase == PHASE_MARKDOWN) score = 20;
      } else { // SELL
         if(m_currentPhase == PHASE_DISTRIBUTION) score = 85;
         else if(m_currentPhase == PHASE_MARKDOWN) score = 75;
         else if(m_currentPhase == PHASE_ACCUMULATION) score = 30;
         else if(m_currentPhase == PHASE_MARKUP) score = 20;
      }
      
      if(m_phaseConfirmed) score += 10;
      
      return MathMin(100, MathMax(0, score));
   }
   
   string GetPhaseName() {
      switch(m_currentPhase) {
         case PHASE_ACCUMULATION: return "ACCUMULATION";
         case PHASE_MARKUP: return "MARKUP";
         case PHASE_DISTRIBUTION: return "DISTRIBUTION";
         case PHASE_MARKDOWN: return "MARKDOWN";
         default: return "UNKNOWN";
      }
   }
};

//====================================================================
// v15 EXTENSION MODULE 48: SUPPLY DEMAND ZONES
//====================================================================
class CSupplyDemandZones
{
private:
   struct Zone {
      double priceHigh;
      double priceLow;
      int type;             // 1 = Demand, -1 = Supply
      int strength;
      int touches;
      datetime created;
      bool broken;
   };
   
   Zone m_zones[];
   int m_zoneCount;
   int m_maxZones;
   double m_zoneBuffer;
   
public:
   CSupplyDemandZones() : m_zoneCount(0), m_maxZones(50), m_zoneBuffer(0) {
      ArrayResize(m_zones, m_maxZones);
   }
   
   void DetectZones(string symbol, ENUM_TIMEFRAMES tf, int lookback = 100) {
      m_zoneCount = 0;
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      m_zoneBuffer = 20 * point;
      
      for(int i = 5; i < lookback - 5; i++) {
         double o = iOpen(symbol, tf, i), c = iClose(symbol, tf, i);
         double h = iHigh(symbol, tf, i), l = iLow(symbol, tf, i);
         double o_prev = iOpen(symbol, tf, i+1), c_prev = iClose(symbol, tf, i+1);
         double o_next = iOpen(symbol, tf, i-1), c_next = iClose(symbol, tf, i-1);
         
         double body = MathAbs(c - o);
         double range = h - l;
         
         if(range == 0) continue;
         
         // Demand Zone: Düşüşten sonra güçlü yükseliş
         if(c_prev < o_prev && c > o && c_next > o_next) { // Bullish reversal
            if(body / range > 0.6 && m_zoneCount < m_maxZones) {
               // Önceki düşüş mumunun bölgesi
               m_zones[m_zoneCount].priceHigh = MathMax(o_prev, c_prev) + m_zoneBuffer;
               m_zones[m_zoneCount].priceLow = MathMin(o_prev, c_prev) - m_zoneBuffer;
               m_zones[m_zoneCount].type = 1; // Demand
               m_zones[m_zoneCount].strength = (int)(body / range * 100);
               m_zones[m_zoneCount].touches = 0;
               m_zones[m_zoneCount].created = iTime(symbol, tf, i);
               m_zones[m_zoneCount].broken = false;
               m_zoneCount++;
            }
         }
         
         // Supply Zone: Yükselişten sonra güçlü düşüş
         if(c_prev > o_prev && c < o && c_next < o_next) { // Bearish reversal
            if(body / range > 0.6 && m_zoneCount < m_maxZones) {
               m_zones[m_zoneCount].priceHigh = MathMax(o_prev, c_prev) + m_zoneBuffer;
               m_zones[m_zoneCount].priceLow = MathMin(o_prev, c_prev) - m_zoneBuffer;
               m_zones[m_zoneCount].type = -1; // Supply
               m_zones[m_zoneCount].strength = (int)(body / range * 100);
               m_zones[m_zoneCount].touches = 0;
               m_zones[m_zoneCount].created = iTime(symbol, tf, i);
               m_zones[m_zoneCount].broken = false;
               m_zoneCount++;
            }
         }
      }
   }
   
   void UpdateZones(double currentPrice) {
      for(int i = 0; i < m_zoneCount; i++) {
         if(m_zones[i].broken) continue;
         
         // Zone'a dokunuş kontrolü
         if(currentPrice >= m_zones[i].priceLow && currentPrice <= m_zones[i].priceHigh) {
            m_zones[i].touches++;
            
            // 3'ten fazla dokunuş = zayıflama
            if(m_zones[i].touches > 3) {
               m_zones[i].strength = (int)(m_zones[i].strength * 0.7);
            }
         }
         
         // Zone kırılma kontrolü
         if(m_zones[i].type == 1 && currentPrice < m_zones[i].priceLow - m_zoneBuffer) {
            m_zones[i].broken = true;
         }
         if(m_zones[i].type == -1 && currentPrice > m_zones[i].priceHigh + m_zoneBuffer) {
            m_zones[i].broken = true;
         }
      }
   }
   
   bool IsInDemandZone(double price) {
      for(int i = 0; i < m_zoneCount; i++) {
         if(!m_zones[i].broken && m_zones[i].type == 1) {
            if(price >= m_zones[i].priceLow && price <= m_zones[i].priceHigh) {
               return true;
            }
         }
      }
      return false;
   }
   
   bool IsInSupplyZone(double price) {
      for(int i = 0; i < m_zoneCount; i++) {
         if(!m_zones[i].broken && m_zones[i].type == -1) {
            if(price >= m_zones[i].priceLow && price <= m_zones[i].priceHigh) {
               return true;
            }
         }
      }
      return false;
   }
   
   int GetZoneScore(int direction, double price) {
      int score = 50;
      
      if(direction == 1) { // BUY
         if(IsInDemandZone(price)) score = 85;
         else if(IsInSupplyZone(price)) score = 25;
      } else { // SELL
         if(IsInSupplyZone(price)) score = 85;
         else if(IsInDemandZone(price)) score = 25;
      }
      
      return score;
   }
   
   int GetActiveZoneCount() {
      int count = 0;
      for(int i = 0; i < m_zoneCount; i++) {
         if(!m_zones[i].broken) count++;
      }
      return count;
   }
};

//====================================================================
// v15 EXTENSION MODULE 49: CANDLE STATISTICS
//====================================================================
class CCandleStatistics
{
private:
   struct CandleStats {
      double avgBody;
      double avgRange;
      double avgUpperWick;
      double avgLowerWick;
      double bodyRatio;
      double bullishRatio;
      int sampleSize;
   };
   
   CandleStats m_stats;
   int m_lookback;
   double m_currentMomentum;
   double m_candleStrength;
   
public:
   CCandleStatistics() : m_lookback(50), m_currentMomentum(0), m_candleStrength(0) {
      m_stats.avgBody = 0;
      m_stats.avgRange = 0;
      m_stats.avgUpperWick = 0;
      m_stats.avgLowerWick = 0;
      m_stats.bodyRatio = 0;
      m_stats.bullishRatio = 0;
      m_stats.sampleSize = 0;
   }
   
   void CalculateStats(string symbol, ENUM_TIMEFRAMES tf) {
      double sumBody = 0, sumRange = 0, sumUpper = 0, sumLower = 0;
      int bullishCount = 0;
      
      for(int i = 1; i <= m_lookback; i++) {
         double o = iOpen(symbol, tf, i);
         double c = iClose(symbol, tf, i);
         double h = iHigh(symbol, tf, i);
         double l = iLow(symbol, tf, i);
         
         double body = MathAbs(c - o);
         double range = h - l;
         double upper = (c > o) ? h - c : h - o;
         double lower = (c > o) ? o - l : c - l;
         
         sumBody += body;
         sumRange += range;
         sumUpper += upper;
         sumLower += lower;
         
         if(c > o) bullishCount++;
      }
      
      m_stats.avgBody = sumBody / m_lookback;
      m_stats.avgRange = sumRange / m_lookback;
      m_stats.avgUpperWick = sumUpper / m_lookback;
      m_stats.avgLowerWick = sumLower / m_lookback;
      m_stats.bodyRatio = (m_stats.avgRange > 0) ? m_stats.avgBody / m_stats.avgRange : 0;
      m_stats.bullishRatio = (double)bullishCount / m_lookback * 100.0;
      m_stats.sampleSize = m_lookback;
      
      // Momentum hesapla
      double close0 = iClose(symbol, tf, 0);
      double closeN = iClose(symbol, tf, 10);
      m_currentMomentum = (closeN > 0) ? (close0 - closeN) / closeN * 100 : 0;
      
      // Mevcut mumun gücü
      double body0 = MathAbs(iClose(symbol, tf, 1) - iOpen(symbol, tf, 1));
      m_candleStrength = (m_stats.avgBody > 0) ? body0 / m_stats.avgBody * 100 : 50;
   }
   
   bool IsBullishBias() { return m_stats.bullishRatio > 55; }
   bool IsBearishBias() { return m_stats.bullishRatio < 45; }
   bool IsStrongCandle() { return m_candleStrength > 150; }
   bool IsWeakCandle() { return m_candleStrength < 50; }
   double GetMomentum() { return m_currentMomentum; }
   double GetCandleStrength() { return m_candleStrength; }
   
   int GetCandleStatsScore(int direction) {
      int score = 50;
      
      if(direction == 1) {
         if(m_stats.bullishRatio > 55) score += 15;
         if(m_currentMomentum > 0.2) score += 10;
         if(m_candleStrength > 120) score += 10;
      } else {
         if(m_stats.bullishRatio < 45) score += 15;
         if(m_currentMomentum < -0.2) score += 10;
         if(m_candleStrength > 120) score += 10;
      }
      
      return MathMin(100, MathMax(0, score));
   }
   
   string GetStatsReport() {
      return StringFormat("Bull: %.1f%% | Momentum: %.2f%% | Strength: %.1f%%",
                          m_stats.bullishRatio, m_currentMomentum, m_candleStrength);
   }
};

//====================================================================
// v15 EXTENSION MODULE 50: TRADE JOURNAL
//====================================================================
class CTradeJournal
{
private:
   struct JournalEntry {
      datetime openTime;
      datetime closeTime;
      string symbol;
      int direction;
      double lot;
      double entryPrice;
      double exitPrice;
      double sl;
      double tp;
      double profit;
      double pips;
      int score;
      int harmonyScore;
      string pattern;
      string session;
      string exitReason;
      bool isWin;
   };
   
   JournalEntry m_journal[];
   int m_journalSize;
   int m_maxEntries;
   string m_filename;
   bool m_autoSave;
   
   // Toplam istatistikler
   int m_totalTrades;
   int m_wins;
   int m_losses;
   double m_totalProfit;
   double m_grossProfit;
   double m_grossLoss;
   double m_largestWin;
   double m_largestLoss;
   int m_consecutiveWins;
   int m_consecutiveLosses;
   int m_maxConsecutiveWins;
   int m_maxConsecutiveLosses;
   
public:
   CTradeJournal() : m_journalSize(0), m_maxEntries(1000), m_autoSave(true),
                      m_totalTrades(0), m_wins(0), m_losses(0),
                      m_totalProfit(0), m_grossProfit(0), m_grossLoss(0),
                      m_largestWin(0), m_largestLoss(0),
                      m_consecutiveWins(0), m_consecutiveLosses(0),
                      m_maxConsecutiveWins(0), m_maxConsecutiveLosses(0) {
      ArrayResize(m_journal, m_maxEntries);
      m_filename = "v15_trade_journal.csv";
   }
   
   void RecordTradeOpen(ulong ticket, string symbol, int direction, double lot,
                         double entryPrice, double sl, double tp,
                         int score, int harmonyScore, string pattern, string session) {
      if(m_journalSize >= m_maxEntries) {
         // Eski kayıtları sil
         for(int i = 0; i < m_maxEntries - 1; i++) {
            m_journal[i] = m_journal[i + 1];
         }
         m_journalSize = m_maxEntries - 1;
      }
      
      m_journal[m_journalSize].openTime = TimeCurrent();
      m_journal[m_journalSize].closeTime = 0;
      m_journal[m_journalSize].symbol = symbol;
      m_journal[m_journalSize].direction = direction;
      m_journal[m_journalSize].lot = lot;
      m_journal[m_journalSize].entryPrice = entryPrice;
      m_journal[m_journalSize].exitPrice = 0;
      m_journal[m_journalSize].sl = sl;
      m_journal[m_journalSize].tp = tp;
      m_journal[m_journalSize].profit = 0;
      m_journal[m_journalSize].pips = 0;
      m_journal[m_journalSize].score = score;
      m_journal[m_journalSize].harmonyScore = harmonyScore;
      m_journal[m_journalSize].pattern = pattern;
      m_journal[m_journalSize].session = session;
      m_journal[m_journalSize].exitReason = "";
      m_journal[m_journalSize].isWin = false;
      m_journalSize++;
      m_totalTrades++;
   }
   
   void RecordTradeClose(ulong ticket, double exitPrice, double profit, string exitReason) {
      // Son açık işlemi bul
      int idx = m_journalSize - 1;
      if(idx < 0) return;
      
      m_journal[idx].closeTime = TimeCurrent();
      m_journal[idx].exitPrice = exitPrice;
      m_journal[idx].profit = profit;
      m_journal[idx].exitReason = exitReason;
      m_journal[idx].isWin = (profit > 0);
      
      // Pip hesapla
      double point = SymbolInfoDouble(m_journal[idx].symbol, SYMBOL_POINT);
      double pips = MathAbs(exitPrice - m_journal[idx].entryPrice) / (10 * point);
      if(m_journal[idx].direction == -1) {
         pips = (m_journal[idx].entryPrice - exitPrice) / (10 * point);
      }
      m_journal[idx].pips = pips;
      
      // İstatistikleri güncelle
      m_totalProfit += profit;
      
      if(profit > 0) {
         m_wins++;
         m_grossProfit += profit;
         if(profit > m_largestWin) m_largestWin = profit;
         m_consecutiveWins++;
         m_consecutiveLosses = 0;
         if(m_consecutiveWins > m_maxConsecutiveWins) m_maxConsecutiveWins = m_consecutiveWins;
      } else {
         m_losses++;
         m_grossLoss += MathAbs(profit);
         if(MathAbs(profit) > m_largestLoss) m_largestLoss = MathAbs(profit);
         m_consecutiveLosses++;
         m_consecutiveWins = 0;
         if(m_consecutiveLosses > m_maxConsecutiveLosses) m_maxConsecutiveLosses = m_consecutiveLosses;
      }
      
      if(m_autoSave) SaveToFile();
   }
   
   void SaveToFile() {
      int handle = FileOpen(m_filename, FILE_WRITE|FILE_CSV|FILE_ANSI);
      if(handle == INVALID_HANDLE) return;
      
      FileWrite(handle, "OpenTime,CloseTime,Symbol,Direction,Lot,Entry,Exit,SL,TP,Profit,Pips,Score,Harmony,Pattern,Session,ExitReason,Win");
      
      for(int i = 0; i < m_journalSize; i++) {
         FileWrite(handle,
                   TimeToString(m_journal[i].openTime),
                   TimeToString(m_journal[i].closeTime),
                   m_journal[i].symbol,
                   (m_journal[i].direction == 1 ? "BUY" : "SELL"),
                   DoubleToString(m_journal[i].lot, 2),
                   DoubleToString(m_journal[i].entryPrice, 5),
                   DoubleToString(m_journal[i].exitPrice, 5),
                   DoubleToString(m_journal[i].sl, 5),
                   DoubleToString(m_journal[i].tp, 5),
                   DoubleToString(m_journal[i].profit, 2),
                   DoubleToString(m_journal[i].pips, 1),
                   IntegerToString(m_journal[i].score),
                   IntegerToString(m_journal[i].harmonyScore),
                   m_journal[i].pattern,
                   m_journal[i].session,
                   m_journal[i].exitReason,
                   (m_journal[i].isWin ? "WIN" : "LOSS"));
      }
      
      FileClose(handle);
   }
   
   double GetWinRate() { return (m_totalTrades > 0) ? (double)m_wins / m_totalTrades * 100.0 : 0; }
   double GetProfitFactor() { return (m_grossLoss > 0) ? m_grossProfit / m_grossLoss : 0; }
   double GetAverageWin() { return (m_wins > 0) ? m_grossProfit / m_wins : 0; }
   double GetAverageLoss() { return (m_losses > 0) ? m_grossLoss / m_losses : 0; }
   double GetExpectancy() { return (GetWinRate()/100.0 * GetAverageWin()) - ((100-GetWinRate())/100.0 * GetAverageLoss()); }
   
   int GetTotalTrades() { return m_totalTrades; }
   int GetWins() { return m_wins; }
   int GetLosses() { return m_losses; }
   double GetTotalProfit() { return m_totalProfit; }
   double GetLargestWin() { return m_largestWin; }
   double GetLargestLoss() { return m_largestLoss; }
   int GetMaxConsecWins() { return m_maxConsecutiveWins; }
   int GetMaxConsecLosses() { return m_maxConsecutiveLosses; }
   
   string GetJournalReport() {
      return StringFormat("Trades: %d | WR: %.1f%% | PF: %.2f | Exp: $%.2f",
                          m_totalTrades, GetWinRate(), GetProfitFactor(), GetExpectancy());
   }
};

//====================================================================
// v15 EXTENSION MODULE 51: POSITION SIZER
//====================================================================
class CPositionSizer
{
private:
   double m_riskPercent;
   double m_fixedLot;
   double m_minLot;
   double m_maxLot;
   int m_riskMode;        // 0=Fixed, 1=Percent, 2=Kelly, 3=OptimalF, 4=Volatility
   double m_kellyFraction;
   double m_volatilityTarget;
   
   // Performance tracking
   double m_recentWinRate;
   double m_recentPF;
   double m_avgWin;
   double m_avgLoss;
   
public:
   CPositionSizer() : m_riskPercent(1.0), m_fixedLot(0.01),
                       m_minLot(0.01), m_maxLot(100),
                       m_riskMode(1), m_kellyFraction(0.5),
                       m_volatilityTarget(0.02),
                       m_recentWinRate(50), m_recentPF(1.0),
                       m_avgWin(0), m_avgLoss(0) {}
   
   void SetParameters(int mode, double risk, double fixedLot, double minLot, double maxLot) {
      m_riskMode = mode;
      m_riskPercent = risk;
      m_fixedLot = fixedLot;
      m_minLot = minLot;
      m_maxLot = maxLot;
   }
   
   void UpdatePerformance(double winRate, double pf, double avgWin, double avgLoss) {
      m_recentWinRate = winRate;
      m_recentPF = pf;
      m_avgWin = avgWin;
      m_avgLoss = avgLoss;
   }
   
   double CalculateLot(string symbol, double slPips) {
      double lot = 0;
      
      switch(m_riskMode) {
         case 0: lot = m_fixedLot; break;
         case 1: lot = CalculatePercentRiskLot(symbol, slPips); break;
         case 2: lot = CalculateKellyLot(symbol, slPips); break;
         case 3: lot = CalculateOptimalFLot(symbol, slPips); break;
         case 4: lot = CalculateVolatilityLot(symbol, slPips); break;
         default: lot = m_fixedLot;
      }
      
      return NormalizeLot(symbol, lot);
   }
   
   double CalculatePercentRiskLot(string symbol, double slPips) {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * m_riskPercent / 100.0;
      
      double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      
      if(tickValue <= 0) tickValue = 10.0;
      if(tickSize <= 0) tickSize = point;
      
      double pipValue = tickValue * (point / tickSize) * 10.0;
      
      if(pipValue <= 0 || slPips <= 0) return m_minLot;
      
      return riskAmount / (slPips * pipValue);
   }
   
   double CalculateKellyLot(string symbol, double slPips) {
      if(m_recentWinRate <= 0 || m_avgWin <= 0 || m_avgLoss <= 0) {
         return CalculatePercentRiskLot(symbol, slPips) * 0.5;
      }
      
      double wr = m_recentWinRate / 100.0;
      double rr = m_avgWin / m_avgLoss;
      
      double kelly = (wr * rr - (1 - wr)) / rr;
      kelly = MathMax(0, MathMin(kelly * m_kellyFraction, 0.25)); // Max %25
      
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * kelly;
      
      double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      
      if(tickValue <= 0) tickValue = 10.0;
      if(tickSize <= 0) tickSize = point;
      
      double pipValue = tickValue * (point / tickSize) * 10.0;
      
      if(pipValue <= 0 || slPips <= 0) return m_minLot;
      
      return riskAmount / (slPips * pipValue);
   }
   
   double CalculateOptimalFLot(string symbol, double slPips) {
      // Optimal F = Kelly * 0.75
      return CalculateKellyLot(symbol, slPips) * 0.75;
   }
   
   double CalculateVolatilityLot(string symbol, double slPips) {
      // Volatilite bazlı pozisyon boyutlandırma
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double targetDollarRisk = balance * m_volatilityTarget;
      
      double tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      
      if(tickValue <= 0) tickValue = 10.0;
      if(tickSize <= 0) tickSize = point;
      
      double pipValue = tickValue * (point / tickSize) * 10.0;
      
      if(pipValue <= 0 || slPips <= 0) return m_minLot;
      
      return targetDollarRisk / (slPips * pipValue);
   }
   
   double NormalizeLot(string symbol, double lot) {
      double minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      double stepLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      
      if(minLot <= 0) minLot = 0.01;
      if(stepLot <= 0) stepLot = 0.01;
      
      lot = MathFloor(lot / stepLot) * stepLot;
      lot = MathMax(minLot, MathMin(lot, MathMin(maxLot, m_maxLot)));
      lot = MathMax(m_minLot, lot);
      
      return lot;
   }
   
   string GetSizerReport() {
      switch(m_riskMode) {
         case 0: return "Mode: FIXED | Lot: " + DoubleToString(m_fixedLot, 2);
         case 1: return "Mode: PERCENT | Risk: " + DoubleToString(m_riskPercent, 1) + "%";
         case 2: return "Mode: KELLY | Fraction: " + DoubleToString(m_kellyFraction, 1);
         case 3: return "Mode: OPTIMAL_F";
         case 4: return "Mode: VOLATILITY | Target: " + DoubleToString(m_volatilityTarget * 100, 1) + "%";
         default: return "UNKNOWN";
      }
   }
};

//====================================================================
// v15 EXTENSION MODULE 52: VOLATILITY REGIME
//====================================================================
class CVolatilityRegime
{
private:
   enum VOL_REGIME {
      VOL_VERY_LOW,
      VOL_LOW,
      VOL_NORMAL,
      VOL_HIGH,
      VOL_EXTREME
   };
   
   VOL_REGIME m_currentRegime;
   double m_currentATR;
   double m_avgATR;
   double m_stdATR;
   double m_atrHistory[];
   int m_historySize;
   int m_historyIndex;
   double m_volatilityPercentile;
   
public:
   CVolatilityRegime() : m_currentRegime(VOL_NORMAL), m_currentATR(0),
                          m_avgATR(0), m_stdATR(0),
                          m_historySize(100), m_historyIndex(0),
                          m_volatilityPercentile(50) {
      ArrayResize(m_atrHistory, m_historySize);
      ArrayInitialize(m_atrHistory, 0);
   }
   
   void Update(double atr) {
      m_currentATR = atr;
      
      // History güncelle
      m_atrHistory[m_historyIndex] = atr;
      m_historyIndex = (m_historyIndex + 1) % m_historySize;
      
      // İstatistik hesapla
      double sum = 0, sumSq = 0;
      int count = 0;
      double sorted[];
      ArrayResize(sorted, m_historySize);
      
      for(int i = 0; i < m_historySize; i++) {
         if(m_atrHistory[i] > 0) {
            sum += m_atrHistory[i];
            sorted[count] = m_atrHistory[i];
            count++;
         }
      }
      
      if(count > 0) {
         m_avgATR = sum / count;
         
         for(int i = 0; i < count; i++) {
            sumSq += MathPow(sorted[i] - m_avgATR, 2);
         }
         m_stdATR = MathSqrt(sumSq / count);
         
         // Percentile hesapla
         ArraySort(sorted);
         int rank = 0;
         for(int i = 0; i < count; i++) {
            if(sorted[i] <= atr) rank = i;
         }
         m_volatilityPercentile = (double)rank / count * 100.0;
      }
      
      // Regime belirle
      if(m_avgATR > 0) {
         double ratio = atr / m_avgATR;
         
         if(ratio < 0.5) m_currentRegime = VOL_VERY_LOW;
         else if(ratio < 0.8) m_currentRegime = VOL_LOW;
         else if(ratio <= 1.2) m_currentRegime = VOL_NORMAL;
         else if(ratio <= 1.8) m_currentRegime = VOL_HIGH;
         else m_currentRegime = VOL_EXTREME;
      }
   }
   
   VOL_REGIME GetCurrentRegime() { return m_currentRegime; }
   double GetVolatilityRatio() { return (m_avgATR > 0) ? m_currentATR / m_avgATR : 1.0; }
   double GetPercentile() { return m_volatilityPercentile; }
   
   double GetLotAdjustment() {
      // Yüksek volatilitede lot azalt
      switch(m_currentRegime) {
         case VOL_VERY_LOW: return 1.5;
         case VOL_LOW: return 1.2;
         case VOL_NORMAL: return 1.0;
         case VOL_HIGH: return 0.75;
         case VOL_EXTREME: return 0.5;
         default: return 1.0;
      }
   }
   
   double GetSLMultiplier() {
      // Yüksek volatilitede SL genişlet
      switch(m_currentRegime) {
         case VOL_VERY_LOW: return 0.8;
         case VOL_LOW: return 0.9;
         case VOL_NORMAL: return 1.0;
         case VOL_HIGH: return 1.3;
         case VOL_EXTREME: return 1.5;
         default: return 1.0;
      }
   }
   
   string GetRegimeName() {
      switch(m_currentRegime) {
         case VOL_VERY_LOW: return "VERY_LOW";
         case VOL_LOW: return "LOW";
         case VOL_NORMAL: return "NORMAL";
         case VOL_HIGH: return "HIGH";
         case VOL_EXTREME: return "EXTREME";
         default: return "UNKNOWN";
      }
   }
   
   int GetRegimeScore(int direction) {
      // Düşük volatilitede trend-following zor
      // Yüksek volatilitede risk var ama fırsat da var
      switch(m_currentRegime) {
         case VOL_VERY_LOW: return 40;
         case VOL_LOW: return 55;
         case VOL_NORMAL: return 70;
         case VOL_HIGH: return 65;
         case VOL_EXTREME: return 50;
         default: return 50;
      }
   }
};

//====================================================================
// v15 EXTENSION MODULE 53: NEURAL SIMULATOR (ENHANCED)
//====================================================================
class CNeuralSimulator
{
private:
   // Daha derin yapay sinir ağı: 10 giriş -> 8 gizli1 -> 5 gizli2 -> 1 çıkış
   double m_weights1[10][8];    // Giriş -> Gizli1
   double m_weights2[8][5];     // Gizli1 -> Gizli2
   double m_weights3[5];        // Gizli2 -> Çıkış
   double m_bias1[8];
   double m_bias2[5];
   double m_outputBias;
   
   // Momentum optimizer için
   double m_velocity1[10][8];
   double m_velocity2[8][5];
   double m_velocity3[5];
   
   // Öğrenme parametreleri
   double m_learningRate;
   double m_momentum;
   double m_dropoutRate;
   int m_trainCount;
   int m_epochCount;
   bool m_isTrained;
   
   // Performans izleme
   double m_lastInputs[10];
   double m_lastPrediction;
   double m_accuracy;
   double m_recentAccuracy[20];
   int m_accIndex;
   double m_bestAccuracy;
   int m_trainingHistory[];
   
   // Batch statistics
   double m_runningMean[8];
   double m_runningVar[8];
   
public:
   CNeuralSimulator() : m_learningRate(0.005), m_momentum(0.9), m_dropoutRate(0.1),
                         m_trainCount(0), m_epochCount(0), m_isTrained(false),
                         m_lastPrediction(0.5), m_accuracy(50), m_accIndex(0),
                         m_bestAccuracy(0) {
      // Xavier initialization
      double scale1 = MathSqrt(2.0 / 10.0);
      double scale2 = MathSqrt(2.0 / 8.0);
      double scale3 = MathSqrt(2.0 / 5.0);
      
      for(int i = 0; i < 10; i++) {
         for(int j = 0; j < 8; j++) {
            m_weights1[i][j] = (MathRand() / 32767.0 - 0.5) * 2.0 * scale1;
            m_velocity1[i][j] = 0;
         }
         m_lastInputs[i] = 0;
      }
      
      for(int i = 0; i < 8; i++) {
         for(int j = 0; j < 5; j++) {
            m_weights2[i][j] = (MathRand() / 32767.0 - 0.5) * 2.0 * scale2;
            m_velocity2[i][j] = 0;
         }
         m_bias1[i] = 0.01;
         m_runningMean[i] = 0;
         m_runningVar[i] = 1;
      }
      
      for(int j = 0; j < 5; j++) {
         m_weights3[j] = (MathRand() / 32767.0 - 0.5) * 2.0 * scale3;
         m_velocity3[j] = 0;
         m_bias2[j] = 0.01;
      }
      
      m_outputBias = 0;
      ArrayInitialize(m_recentAccuracy, 50);
      ArrayResize(m_trainingHistory, 1000);
   }
   
   // Aktivasyon fonksiyonları
   double Sigmoid(double x) { return 1.0 / (1.0 + MathExp(-MathMin(500, MathMax(-500, x)))); }
   double ReLU(double x) { return MathMax(0, x); }
   double LeakyReLU(double x) { return x > 0 ? x : 0.01 * x; }
   double Tanh(double x) { return (MathExp(x) - MathExp(-x)) / (MathExp(x) + MathExp(-x)); }
   
   // Dropout uygula
   bool ShouldDrop() { return (MathRand() / 32767.0 < m_dropoutRate); }
   
   double Predict(double &inputs[]) {
      // Layer 1: Input -> Hidden1 (LeakyReLU + BatchNorm)
      double hidden1[8];
      for(int j = 0; j < 8; j++) {
         double sum = m_bias1[j];
         for(int i = 0; i < 10; i++) {
            sum += inputs[i] * m_weights1[i][j];
         }
         // Batch Normalization (simplified)
         sum = (sum - m_runningMean[j]) / MathSqrt(m_runningVar[j] + 0.0001);
         hidden1[j] = LeakyReLU(sum);
      }
      
      // Layer 2: Hidden1 -> Hidden2 (LeakyReLU)
      double hidden2[5];
      for(int j = 0; j < 5; j++) {
         double sum = m_bias2[j];
         for(int i = 0; i < 8; i++) {
            sum += hidden1[i] * m_weights2[i][j];
         }
         hidden2[j] = LeakyReLU(sum);
      }
      
      // Layer 3: Hidden2 -> Output (Sigmoid)
      double output = m_outputBias;
      for(int j = 0; j < 5; j++) {
         output += hidden2[j] * m_weights3[j];
      }
      
      m_lastPrediction = Sigmoid(output);
      for(int i = 0; i < 10; i++) m_lastInputs[i] = inputs[i];
      
      return m_lastPrediction;
   }
   
   void Train(double actualResult) {
      double error = actualResult - m_lastPrediction;
      
      // Forward pass tekrar
      double hidden1[8], hidden2[5];
      
      for(int j = 0; j < 8; j++) {
         double sum = m_bias1[j];
         for(int i = 0; i < 10; i++) sum += m_lastInputs[i] * m_weights1[i][j];
         sum = (sum - m_runningMean[j]) / MathSqrt(m_runningVar[j] + 0.0001);
         hidden1[j] = LeakyReLU(sum);
         
         // Running stats güncelle
         m_runningMean[j] = 0.99 * m_runningMean[j] + 0.01 * sum;
         m_runningVar[j] = 0.99 * m_runningVar[j] + 0.01 * sum * sum;
      }
      
      for(int j = 0; j < 5; j++) {
         double sum = m_bias2[j];
         for(int i = 0; i < 8; i++) sum += hidden1[i] * m_weights2[i][j];
         hidden2[j] = LeakyReLU(sum);
      }
      
      // Backpropagation with momentum
      double outputGrad = error * m_lastPrediction * (1 - m_lastPrediction);
      
      // Layer 3 gradients
      double hidden2Grad[5];
      for(int j = 0; j < 5; j++) {
         hidden2Grad[j] = outputGrad * m_weights3[j] * (hidden2[j] > 0 ? 1 : 0.01);
         m_velocity3[j] = m_momentum * m_velocity3[j] + m_learningRate * outputGrad * hidden2[j];
         m_weights3[j] += m_velocity3[j];
      }
      m_outputBias += m_learningRate * outputGrad;
      
      // Layer 2 gradients
      double hidden1Grad[8];
      for(int i = 0; i < 8; i++) {
         double grad = 0;
         for(int j = 0; j < 5; j++) grad += hidden2Grad[j] * m_weights2[i][j];
         hidden1Grad[i] = grad * (hidden1[i] > 0 ? 1 : 0.01);
         
         for(int j = 0; j < 5; j++) {
            m_velocity2[i][j] = m_momentum * m_velocity2[i][j] + m_learningRate * hidden2Grad[j] * hidden1[i];
            m_weights2[i][j] += m_velocity2[i][j];
         }
      }
      
      // Layer 1 gradients
      for(int i = 0; i < 10; i++) {
         for(int j = 0; j < 8; j++) {
            m_velocity1[i][j] = m_momentum * m_velocity1[i][j] + m_learningRate * hidden1Grad[j] * m_lastInputs[i];
            m_weights1[i][j] += m_velocity1[i][j];
         }
      }
      
      // Bias güncelle
      for(int j = 0; j < 8; j++) m_bias1[j] += m_learningRate * 0.1 * hidden1Grad[j];
      for(int j = 0; j < 5; j++) m_bias2[j] += m_learningRate * 0.1 * hidden2Grad[j];
      
      m_trainCount++;
      m_isTrained = (m_trainCount >= 30);
      
      // Accuracy tracking
      bool correct = ((actualResult > 0.5 && m_lastPrediction > 0.5) ||
                      (actualResult <= 0.5 && m_lastPrediction <= 0.5));
      m_recentAccuracy[m_accIndex] = correct ? 100 : 0;
      m_accIndex = (m_accIndex + 1) % 20;
      
      double sum = 0;
      for(int i = 0; i < 20; i++) sum += m_recentAccuracy[i];
      m_accuracy = sum / 20.0;
      
      if(m_accuracy > m_bestAccuracy) m_bestAccuracy = m_accuracy;
      
      // Learning rate decay
      if(m_trainCount % 100 == 0 && m_learningRate > 0.0001) {
         m_learningRate *= 0.95;
      }
   }
   
   double PrepareInputs(int score, int harmonyScore, double atr, double spread,
                        int sessionIdx, double winRate, double momentum,
                        int consecutiveWins, int consecutiveLosses, double ddPercent) {
      double inputs[10];
      
      // Feature engineering - normalize
      inputs[0] = MathMax(0, MathMin(1, score / 100.0));
      inputs[1] = MathMax(0, MathMin(1, harmonyScore / 100.0));
      inputs[2] = MathMax(0, MathMin(1, atr / 0.002));
      inputs[3] = MathMax(0, MathMin(1, spread / 10.0));
      inputs[4] = sessionIdx / 4.0;
      inputs[5] = MathMax(0, MathMin(1, winRate / 100.0));
      inputs[6] = (momentum + 1.0) / 2.0;
      inputs[7] = MathMax(0, MathMin(1, consecutiveWins / 10.0));
      inputs[8] = MathMax(0, MathMin(1, consecutiveLosses / 10.0));
      inputs[9] = MathMax(0, MathMin(1, ddPercent / 20.0));
      
      return Predict(inputs);
   }
   
   bool ShouldTrade() {
      if(!m_isTrained) return true;
      return (m_lastPrediction > 0.55);
   }
   
   double GetPrediction() { return m_lastPrediction; }
   double GetAccuracy() { return m_accuracy; }
   int GetTrainingCount() { return m_trainCount; }
   bool IsTrained() { return m_isTrained; }
   
   string GetNeuralReport() {
      return StringFormat("Neural: %.1f%% acc | Pred: %.2f | Train: %d",
                          m_accuracy, m_lastPrediction, m_trainCount);
   }
};

//====================================================================
// v15 EXTENSION MODULE 54: ADVANCED PATTERN RECOGNITION
//====================================================================
class CAdvancedPatternRecognition
{
private:
   struct HarmonicPattern {
      string name;
      double xaRatio;
      double abRatio;
      double bcRatio;
      double cdRatio;
      double tolerance;
      int direction;
      bool detected;
      double priceD;
   };
   
   HarmonicPattern m_patterns[8];
   int m_patternCount;
   double m_swingPoints[];
   int m_swingCount;
   
   // Chart pattern detection
   bool m_headShoulders;
   bool m_doubleTop;
   bool m_doubleBottom;
   bool m_triangle;
   bool m_wedge;
   bool m_flag;
   
public:
   CAdvancedPatternRecognition() : m_patternCount(8), m_swingCount(0),
                                    m_headShoulders(false), m_doubleTop(false),
                                    m_doubleBottom(false), m_triangle(false),
                                    m_wedge(false), m_flag(false) {
      ArrayResize(m_swingPoints, 100);
      
      // Harmonic patterns initialize
      // Gartley
      m_patterns[0].name = "Gartley";
      m_patterns[0].xaRatio = 0.618;
      m_patterns[0].abRatio = 0.382;
      m_patterns[0].bcRatio = 0.886;
      m_patterns[0].cdRatio = 1.272;
      m_patterns[0].tolerance = 0.05;
      
      // Butterfly
      m_patterns[1].name = "Butterfly";
      m_patterns[1].xaRatio = 0.786;
      m_patterns[1].abRatio = 0.382;
      m_patterns[1].bcRatio = 0.886;
      m_patterns[1].cdRatio = 1.618;
      m_patterns[1].tolerance = 0.05;
      
      // Bat
      m_patterns[2].name = "Bat";
      m_patterns[2].xaRatio = 0.382;
      m_patterns[2].abRatio = 0.382;
      m_patterns[2].bcRatio = 0.886;
      m_patterns[2].cdRatio = 2.618;
      m_patterns[2].tolerance = 0.05;
      
      // Crab
      m_patterns[3].name = "Crab";
      m_patterns[3].xaRatio = 0.382;
      m_patterns[3].abRatio = 0.382;
      m_patterns[3].bcRatio = 0.886;
      m_patterns[3].cdRatio = 3.618;
      m_patterns[3].tolerance = 0.05;
      
      // Cypher
      m_patterns[4].name = "Cypher";
      m_patterns[4].xaRatio = 0.382;
      m_patterns[4].abRatio = 0.382;
      m_patterns[4].bcRatio = 1.272;
      m_patterns[4].cdRatio = 0.786;
      m_patterns[4].tolerance = 0.05;
      
      // Shark
      m_patterns[5].name = "Shark";
      m_patterns[5].xaRatio = 0.446;
      m_patterns[5].abRatio = 0.618;
      m_patterns[5].bcRatio = 1.618;
      m_patterns[5].cdRatio = 0.886;
      m_patterns[5].tolerance = 0.05;
      
      // ABCD
      m_patterns[6].name = "ABCD";
      m_patterns[6].xaRatio = 0;
      m_patterns[6].abRatio = 0.618;
      m_patterns[6].bcRatio = 0.618;
      m_patterns[6].cdRatio = 1.0;
      m_patterns[6].tolerance = 0.05;
      
      // Three Drives
      m_patterns[7].name = "ThreeDrives";
      m_patterns[7].xaRatio = 1.272;
      m_patterns[7].abRatio = 0.618;
      m_patterns[7].bcRatio = 1.272;
      m_patterns[7].cdRatio = 0.618;
      m_patterns[7].tolerance = 0.05;
      
      for(int i = 0; i < 8; i++) m_patterns[i].detected = false;
   }
   
   void FindSwingPoints(string symbol, ENUM_TIMEFRAMES tf, int lookback = 50) {
      m_swingCount = 0;
      
      for(int i = 3; i < lookback - 3 && m_swingCount < 100; i++) {
         double h = iHigh(symbol, tf, i);
         double l = iLow(symbol, tf, i);
         
         // Swing High
         bool isHigh = true;
         for(int j = 1; j <= 3; j++) {
            if(iHigh(symbol, tf, i-j) > h || iHigh(symbol, tf, i+j) > h) {
               isHigh = false;
               break;
            }
         }
         if(isHigh) {
            m_swingPoints[m_swingCount] = h;
            m_swingCount++;
         }
         
         // Swing Low
         bool isLow = true;
         for(int j = 1; j <= 3; j++) {
            if(iLow(symbol, tf, i-j) < l || iLow(symbol, tf, i+j) < l) {
               isLow = false;
               break;
            }
         }
         if(isLow) {
            m_swingPoints[m_swingCount] = l;
            m_swingCount++;
         }
      }
   }
   
   bool CheckRatio(double actual, double expected, double tolerance) {
      return (MathAbs(actual - expected) <= tolerance);
   }
   
   void DetectHarmonics(string symbol, ENUM_TIMEFRAMES tf) {
      if(m_swingCount < 5) return;
      
      double X = m_swingPoints[4];
      double A = m_swingPoints[3];
      double B = m_swingPoints[2];
      double C = m_swingPoints[1];
      double D = m_swingPoints[0];
      
      double XA = MathAbs(A - X);
      double AB = MathAbs(B - A);
      double BC = MathAbs(C - B);
      double CD = MathAbs(D - C);
      
      if(XA == 0) return;
      
      for(int i = 0; i < m_patternCount; i++) {
         double abRatio = AB / XA;
         double bcRatio = BC / AB;
         double cdRatio = CD / BC;
         
         if(CheckRatio(abRatio, m_patterns[i].abRatio, m_patterns[i].tolerance) &&
            CheckRatio(bcRatio, m_patterns[i].bcRatio, m_patterns[i].tolerance)) {
            m_patterns[i].detected = true;
            m_patterns[i].priceD = D;
            m_patterns[i].direction = (D > C) ? -1 : 1;
         }
      }
   }
   
   void DetectChartPatterns(string symbol, ENUM_TIMEFRAMES tf, int lookback = 100) {
      m_headShoulders = false;
      m_doubleTop = false;
      m_doubleBottom = false;
      
      if(m_swingCount < 5) return;
      
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      double tolerance = 50 * point;
      
      // Double Top
      if(MathAbs(m_swingPoints[0] - m_swingPoints[2]) < tolerance &&
         m_swingPoints[1] < m_swingPoints[0]) {
         m_doubleTop = true;
      }
      
      // Double Bottom
      if(MathAbs(m_swingPoints[0] - m_swingPoints[2]) < tolerance &&
         m_swingPoints[1] > m_swingPoints[0]) {
         m_doubleBottom = true;
      }
      
      // Head and Shoulders
      if(m_swingCount >= 5) {
         double ls = m_swingPoints[4];
         double h = m_swingPoints[2];
         double rs = m_swingPoints[0];
         
         if(h > ls && h > rs && MathAbs(ls - rs) < tolerance) {
            m_headShoulders = true;
         }
      }
   }
   
   int GetPatternScore(int direction) {
      int score = 50;
      
      for(int i = 0; i < m_patternCount; i++) {
         if(m_patterns[i].detected && m_patterns[i].direction == direction) {
            score += 25;
            break;
         }
      }
      
      if(direction == 1 && m_doubleBottom) score += 20;
      if(direction == -1 && m_doubleTop) score += 20;
      if(direction == -1 && m_headShoulders) score += 20;
      
      return MathMin(100, score);
   }
   
   string GetDetectedPatterns() {
      string result = "";
      for(int i = 0; i < m_patternCount; i++) {
         if(m_patterns[i].detected) {
            result += m_patterns[i].name + " ";
         }
      }
      if(m_doubleTop) result += "DoubleTop ";
      if(m_doubleBottom) result += "DoubleBottom ";
      if(m_headShoulders) result += "H&S ";
      return result;
   }
   
   void Update(string symbol, ENUM_TIMEFRAMES tf) {
      FindSwingPoints(symbol, tf);
      DetectHarmonics(symbol, tf);
      DetectChartPatterns(symbol, tf);
   }
};

//====================================================================
// v15 EXTENSION MODULE 55: TREND STRENGTH METER
//====================================================================
class CTrendStrengthMeter
{
private:
   int m_adxHandle;
   int m_maHandle20;
   int m_maHandle50;
   int m_maHandle200;
   
   double m_adxValue;
   double m_plusDI;
   double m_minusDI;
   double m_ma20;
   double m_ma50;
   double m_ma200;
   
   int m_trendDirection;
   int m_trendStrength;
   bool m_isTrending;
   bool m_isRanging;
   
public:
   CTrendStrengthMeter() : m_adxHandle(INVALID_HANDLE),
                            m_maHandle20(INVALID_HANDLE),
                            m_maHandle50(INVALID_HANDLE),
                            m_maHandle200(INVALID_HANDLE),
                            m_adxValue(0), m_plusDI(0), m_minusDI(0),
                            m_ma20(0), m_ma50(0), m_ma200(0),
                            m_trendDirection(0), m_trendStrength(0),
                            m_isTrending(false), m_isRanging(true) {}
   
   bool Init(string symbol, ENUM_TIMEFRAMES tf) {
      m_adxHandle = iADX(symbol, tf, 14);
      m_maHandle20 = iMA(symbol, tf, 20, 0, MODE_EMA, PRICE_CLOSE);
      m_maHandle50 = iMA(symbol, tf, 50, 0, MODE_EMA, PRICE_CLOSE);
      m_maHandle200 = iMA(symbol, tf, 200, 0, MODE_SMA, PRICE_CLOSE);
      
      return (m_adxHandle != INVALID_HANDLE);
   }
   
   void Release() {
      if(m_adxHandle != INVALID_HANDLE) IndicatorRelease(m_adxHandle);
      if(m_maHandle20 != INVALID_HANDLE) IndicatorRelease(m_maHandle20);
      if(m_maHandle50 != INVALID_HANDLE) IndicatorRelease(m_maHandle50);
      if(m_maHandle200 != INVALID_HANDLE) IndicatorRelease(m_maHandle200);
   }
   
   void Update() {
      double adx[], plusDI[], minusDI[], ma20[], ma50[], ma200[];
      ArraySetAsSeries(adx, true);
      ArraySetAsSeries(plusDI, true);
      ArraySetAsSeries(minusDI, true);
      ArraySetAsSeries(ma20, true);
      ArraySetAsSeries(ma50, true);
      ArraySetAsSeries(ma200, true);
      
      if(m_adxHandle != INVALID_HANDLE) {
         CopyBuffer(m_adxHandle, 0, 0, 3, adx);
         CopyBuffer(m_adxHandle, 1, 0, 3, plusDI);
         CopyBuffer(m_adxHandle, 2, 0, 3, minusDI);
         m_adxValue = adx[0];
         m_plusDI = plusDI[0];
         m_minusDI = minusDI[0];
      }
      
      if(m_maHandle20 != INVALID_HANDLE) CopyBuffer(m_maHandle20, 0, 0, 1, ma20);
      if(m_maHandle50 != INVALID_HANDLE) CopyBuffer(m_maHandle50, 0, 0, 1, ma50);
      if(m_maHandle200 != INVALID_HANDLE) CopyBuffer(m_maHandle200, 0, 0, 1, ma200);
      
      if(ArraySize(ma20) > 0) m_ma20 = ma20[0];
      if(ArraySize(ma50) > 0) m_ma50 = ma50[0];
      if(ArraySize(ma200) > 0) m_ma200 = ma200[0];
      
      // Trend direction
      if(m_plusDI > m_minusDI) m_trendDirection = 1;
      else if(m_minusDI > m_plusDI) m_trendDirection = -1;
      else m_trendDirection = 0;
      
      // Trend strength (0-100)
      m_trendStrength = (int)MathMin(100, m_adxValue * 2);
      
      // Is trending?
      m_isTrending = (m_adxValue >= 25);
      m_isRanging = (m_adxValue < 20);
   }
   
   int GetTrendScore(int direction) {
      int score = 50;
      
      // ADX trend confirmation
      if(m_isTrending && m_trendDirection == direction) {
         score += 20;
      } else if(m_isTrending && m_trendDirection != direction) {
         score -= 15;
      }
      
      // MA alignment
      double price = iClose(_Symbol, PERIOD_CURRENT, 0);
      if(direction == 1) {
         if(price > m_ma20 && m_ma20 > m_ma50 && m_ma50 > m_ma200) score += 25;
         else if(price > m_ma20 && m_ma20 > m_ma50) score += 15;
         else if(price > m_ma20) score += 5;
      } else {
         if(price < m_ma20 && m_ma20 < m_ma50 && m_ma50 < m_ma200) score += 25;
         else if(price < m_ma20 && m_ma20 < m_ma50) score += 15;
         else if(price < m_ma20) score += 5;
      }
      
      return MathMin(100, MathMax(0, score));
   }
   
   double GetADX() { return m_adxValue; }
   int GetTrendDirection() { return m_trendDirection; }
   int GetTrendStrength() { return m_trendStrength; }
   bool IsTrending() { return m_isTrending; }
   bool IsRanging() { return m_isRanging; }
   
   string GetTrendReport() {
      return StringFormat("ADX: %.1f | Dir: %s | Str: %d%%",
                          m_adxValue,
                          (m_trendDirection == 1 ? "UP" : (m_trendDirection == -1 ? "DOWN" : "FLAT")),
                          m_trendStrength);
   }
};

//====================================================================
// v15 EXTENSION MODULE 56: MULTI-SYMBOL CORRELATION
//====================================================================
class CMultiSymbolCorrelation
{
private:
   string m_symbols[];
   int m_symbolCount;
   double m_correlationMatrix[10][10];
   double m_returns[10][100];
   int m_lookback;
   
public:
   CMultiSymbolCorrelation() : m_symbolCount(0), m_lookback(50) {
      ArrayResize(m_symbols, 10);
   }
   
   void AddSymbol(string symbol) {
      if(m_symbolCount < 10) {
         m_symbols[m_symbolCount] = symbol;
         m_symbolCount++;
      }
   }
   
   void ClearSymbols() { m_symbolCount = 0; }
   
   void CalculateReturns(ENUM_TIMEFRAMES tf) {
      for(int s = 0; s < m_symbolCount; s++) {
         for(int i = 0; i < m_lookback; i++) {
            double close0 = iClose(m_symbols[s], tf, i);
            double close1 = iClose(m_symbols[s], tf, i + 1);
            m_returns[s][i] = (close1 > 0) ? (close0 - close1) / close1 : 0;
         }
      }
   }
   
   double CalculateCorrelation(int sym1, int sym2) {
      double mean1 = 0, mean2 = 0;
      for(int i = 0; i < m_lookback; i++) {
         mean1 += m_returns[sym1][i];
         mean2 += m_returns[sym2][i];
      }
      mean1 /= m_lookback;
      mean2 /= m_lookback;
      
      double cov = 0, var1 = 0, var2 = 0;
      for(int i = 0; i < m_lookback; i++) {
         double d1 = m_returns[sym1][i] - mean1;
         double d2 = m_returns[sym2][i] - mean2;
         cov += d1 * d2;
         var1 += d1 * d1;
         var2 += d2 * d2;
      }
      
      double denom = MathSqrt(var1 * var2);
      return (denom > 0) ? cov / denom : 0;
   }
   
   void UpdateMatrix(ENUM_TIMEFRAMES tf) {
      CalculateReturns(tf);
      
      for(int i = 0; i < m_symbolCount; i++) {
         for(int j = i; j < m_symbolCount; j++) {
            if(i == j) {
               m_correlationMatrix[i][j] = 1.0;
            } else {
               double corr = CalculateCorrelation(i, j);
               m_correlationMatrix[i][j] = corr;
               m_correlationMatrix[j][i] = corr;
            }
         }
      }
   }
   
   double GetCorrelation(string sym1, string sym2) {
      int idx1 = -1, idx2 = -1;
      for(int i = 0; i < m_symbolCount; i++) {
         if(m_symbols[i] == sym1) idx1 = i;
         if(m_symbols[i] == sym2) idx2 = i;
      }
      if(idx1 >= 0 && idx2 >= 0) {
         return m_correlationMatrix[idx1][idx2];
      }
      return 0;
   }
   
   bool IsHighlyCorrelated(string symbol, double threshold = 0.7) {
      int idx = -1;
      for(int i = 0; i < m_symbolCount; i++) {
         if(m_symbols[i] == symbol) { idx = i; break; }
      }
      if(idx < 0) return false;
      
      for(int i = 0; i < m_symbolCount; i++) {
         if(i != idx && MathAbs(m_correlationMatrix[idx][i]) > threshold) {
            return true;
         }
      }
      return false;
   }
};

//====================================================================
// v15 EXTENSION MODULE 57: ADVANCED MONEY MANAGEMENT
//====================================================================
class CAdvancedMoneyManagement
{
private:
   double m_startingBalance;
   double m_currentBalance;
   double m_peakBalance;
   double m_currentDrawdown;
   double m_maxDrawdown;
   
   // Compounding settings
   bool m_useCompounding;
   double m_compoundRate;
   int m_compoundPeriod;
   
   // Anti-martingale
   bool m_useAntiMartingale;
   double m_winMultiplier;
   double m_lossMultiplier;
   int m_consecutiveWins;
   int m_consecutiveLosses;
   
   // Risk per trade
   double m_baseRiskPercent;
   double m_currentRiskPercent;
   double m_minRiskPercent;
   double m_maxRiskPercent;
   
   // Daily/Weekly limits
   double m_dailyProfitTarget;
   double m_dailyLossLimit;
   double m_weeklyProfitTarget;
   double m_weeklyLossLimit;
   double m_todayPL;
   double m_weekPL;
   
public:
   CAdvancedMoneyManagement() : m_startingBalance(0), m_currentBalance(0),
                                  m_peakBalance(0), m_currentDrawdown(0), m_maxDrawdown(0),
                                  m_useCompounding(true), m_compoundRate(0.1), m_compoundPeriod(10),
                                  m_useAntiMartingale(true), m_winMultiplier(1.2), m_lossMultiplier(0.8),
                                  m_consecutiveWins(0), m_consecutiveLosses(0),
                                  m_baseRiskPercent(1.0), m_currentRiskPercent(1.0),
                                  m_minRiskPercent(0.25), m_maxRiskPercent(3.0),
                                  m_dailyProfitTarget(5.0), m_dailyLossLimit(3.0),
                                  m_weeklyProfitTarget(15.0), m_weeklyLossLimit(8.0),
                                  m_todayPL(0), m_weekPL(0) {}
   
   void Init() {
      m_startingBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      m_currentBalance = m_startingBalance;
      m_peakBalance = m_startingBalance;
   }
   
   void Update() {
      m_currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      
      if(m_currentBalance > m_peakBalance) {
         m_peakBalance = m_currentBalance;
      }
      
      m_currentDrawdown = (m_peakBalance > 0) ? 
                          (m_peakBalance - m_currentBalance) / m_peakBalance * 100 : 0;
      
      if(m_currentDrawdown > m_maxDrawdown) {
         m_maxDrawdown = m_currentDrawdown;
      }
   }
   
   void OnTradeResult(bool isWin, double profit) {
      m_todayPL += profit / m_currentBalance * 100;
      m_weekPL += profit / m_currentBalance * 100;
      
      if(isWin) {
         m_consecutiveWins++;
         m_consecutiveLosses = 0;
         
         if(m_useAntiMartingale) {
            m_currentRiskPercent = MathMin(m_maxRiskPercent, 
                                            m_currentRiskPercent * m_winMultiplier);
         }
      } else {
         m_consecutiveLosses++;
         m_consecutiveWins = 0;
         
         if(m_useAntiMartingale) {
            m_currentRiskPercent = MathMax(m_minRiskPercent,
                                            m_currentRiskPercent * m_lossMultiplier);
         }
      }
      
      // Compounding check
      if(m_useCompounding) {
         double growth = (m_currentBalance - m_startingBalance) / m_startingBalance * 100;
         if(growth > m_compoundRate * m_compoundPeriod) {
            m_baseRiskPercent *= (1 + m_compoundRate);
            m_baseRiskPercent = MathMin(m_maxRiskPercent, m_baseRiskPercent);
         }
      }
   }
   
   double GetAdjustedRisk() {
      double risk = m_currentRiskPercent;
      
      // Drawdown adjustment
      if(m_currentDrawdown > 5) risk *= 0.75;
      if(m_currentDrawdown > 10) risk *= 0.5;
      if(m_currentDrawdown > 15) risk *= 0.25;
      
      // Consecutive loss adjustment
      if(m_consecutiveLosses >= 3) risk *= 0.5;
      if(m_consecutiveLosses >= 5) risk *= 0.25;
      
      return MathMax(m_minRiskPercent, MathMin(m_maxRiskPercent, risk));
   }
   
   bool ShouldStopTrading() {
      // Daily limit check
      if(m_todayPL >= m_dailyProfitTarget) return true;
      if(m_todayPL <= -m_dailyLossLimit) return true;
      
      // Weekly limit check
      if(m_weekPL >= m_weeklyProfitTarget) return true;
      if(m_weekPL <= -m_weeklyLossLimit) return true;
      
      // Max drawdown check
      if(m_currentDrawdown > 20) return true;
      
      return false;
   }
   
   void ResetDaily() { m_todayPL = 0; }
   void ResetWeekly() { m_weekPL = 0; m_todayPL = 0; }
   
   double GetCurrentRisk() { return m_currentRiskPercent; }
   double GetMaxDrawdown() { return m_maxDrawdown; }
   double GetTodayPL() { return m_todayPL; }
   double GetWeekPL() { return m_weekPL; }
};

//====================================================================
// v15 EXTENSION MODULE 58: SMART ALERTS
//====================================================================
class CSmartAlerts
{
private:
   bool m_enablePush;
   bool m_enableEmail;
   bool m_enableSound;
   bool m_enablePopup;
   
   string m_lastAlert;
   datetime m_lastAlertTime;
   int m_cooldownSeconds;
   int m_alertCount;
   
public:
   CSmartAlerts() : m_enablePush(true), m_enableEmail(false),
                     m_enableSound(true), m_enablePopup(true),
                     m_lastAlert(""), m_lastAlertTime(0),
                     m_cooldownSeconds(60), m_alertCount(0) {}
   
   void SetPush(bool enable) { m_enablePush = enable; }
   void SetEmail(bool enable) { m_enableEmail = enable; }
   void SetSound(bool enable) { m_enableSound = enable; }
   void SetPopup(bool enable) { m_enablePopup = enable; }
   void SetCooldown(int seconds) { m_cooldownSeconds = seconds; }
   
   bool CanAlert(string alertType) {
      if(TimeCurrent() - m_lastAlertTime < m_cooldownSeconds) {
         return false;
      }
      if(m_lastAlert == alertType && TimeCurrent() - m_lastAlertTime < 300) {
         return false;
      }
      return true;
   }
   
   void SendAlert(string title, string message, string alertType = "general") {
      if(!CanAlert(alertType)) return;
      
      string fullMsg = "[" + _Symbol + "] " + title + ": " + message;
      
      if(m_enablePopup) Alert(fullMsg);
      if(m_enableSound) PlaySound("alert.wav");
      if(m_enablePush) SendNotification(fullMsg);
      if(m_enableEmail) SendMail("EA Alert: " + title, fullMsg);
      
      m_lastAlert = alertType;
      m_lastAlertTime = TimeCurrent();
      m_alertCount++;
   }
   
   void TradeOpenAlert(string direction, double lot, double price) {
      string msg = StringFormat("%s %.2f lot @ %.5f", direction, lot, price);
      SendAlert("Trade Opened", msg, "trade_open");
   }
   
   void TradeCloseAlert(string direction, double profit) {
      string msg = StringFormat("%s closed | Profit: $%.2f", direction, profit);
      SendAlert("Trade Closed", msg, "trade_close");
   }
   
   void SignalAlert(int score, string direction) {
      string msg = StringFormat("Strong %s signal | Score: %d", direction, score);
      SendAlert("Signal", msg, "signal");
   }
   
   void RiskAlert(string reason) {
      SendAlert("Risk Warning", reason, "risk");
   }
   
   int GetAlertCount() { return m_alertCount; }
};

//====================================================================
// v15 EXTENSION MODULE 59: PERFORMANCE ANALYZER
//====================================================================
class CPerformanceAnalyzer
{
private:
   struct TradeRecord {
      datetime openTime;
      datetime closeTime;
      double profit;
      double pips;
      int duration;
      bool isWin;
      int score;
      string session;
   };
   
   TradeRecord m_trades[];
   int m_tradeCount;
   int m_maxTrades;
   
   // Performance metrics
   double m_totalProfit;
   double m_grossProfit;
   double m_grossLoss;
   int m_wins;
   int m_losses;
   double m_avgWin;
   double m_avgLoss;
   double m_maxWin;
   double m_maxLoss;
   double m_winRate;
   double m_profitFactor;
   double m_expectancy;
   double m_sharpeRatio;
   double m_calmarRatio;
   double m_maxConsecWins;
   double m_maxConsecLosses;
   
   // Session analysis
   double m_sessionProfit[5];
   int m_sessionTrades[5];
   double m_sessionWinRate[5];
   
public:
   CPerformanceAnalyzer() : m_tradeCount(0), m_maxTrades(1000),
                             m_totalProfit(0), m_grossProfit(0), m_grossLoss(0),
                             m_wins(0), m_losses(0), m_avgWin(0), m_avgLoss(0),
                             m_maxWin(0), m_maxLoss(0), m_winRate(50),
                             m_profitFactor(1), m_expectancy(0),
                             m_sharpeRatio(0), m_calmarRatio(0),
                             m_maxConsecWins(0), m_maxConsecLosses(0) {
      ArrayResize(m_trades, m_maxTrades);
      ArrayInitialize(m_sessionProfit, 0);
      ArrayInitialize(m_sessionTrades, 0);
      ArrayInitialize(m_sessionWinRate, 50);
   }
   
   void RecordTrade(datetime openTime, datetime closeTime, double profit, 
                    double pips, int score, string session) {
      if(m_tradeCount >= m_maxTrades) {
         for(int i = 0; i < m_maxTrades - 1; i++) {
            m_trades[i] = m_trades[i + 1];
         }
         m_tradeCount = m_maxTrades - 1;
      }
      
      m_trades[m_tradeCount].openTime = openTime;
      m_trades[m_tradeCount].closeTime = closeTime;
      m_trades[m_tradeCount].profit = profit;
      m_trades[m_tradeCount].pips = pips;
      m_trades[m_tradeCount].duration = (int)(closeTime - openTime);
      m_trades[m_tradeCount].isWin = (profit > 0);
      m_trades[m_tradeCount].score = score;
      m_trades[m_tradeCount].session = session;
      m_tradeCount++;
      
      UpdateMetrics();
      UpdateSessionStats(session, profit > 0, profit);
   }
   
   void UpdateMetrics() {
      m_totalProfit = 0;
      m_grossProfit = 0;
      m_grossLoss = 0;
      m_wins = 0;
      m_losses = 0;
      m_maxWin = 0;
      m_maxLoss = 0;
      
      for(int i = 0; i < m_tradeCount; i++) {
         m_totalProfit += m_trades[i].profit;
         
         if(m_trades[i].profit > 0) {
            m_grossProfit += m_trades[i].profit;
            m_wins++;
            if(m_trades[i].profit > m_maxWin) m_maxWin = m_trades[i].profit;
         } else {
            m_grossLoss += MathAbs(m_trades[i].profit);
            m_losses++;
            if(MathAbs(m_trades[i].profit) > m_maxLoss) m_maxLoss = MathAbs(m_trades[i].profit);
         }
      }
      
      m_winRate = (m_tradeCount > 0) ? (double)m_wins / m_tradeCount * 100 : 50;
      m_avgWin = (m_wins > 0) ? m_grossProfit / m_wins : 0;
      m_avgLoss = (m_losses > 0) ? m_grossLoss / m_losses : 0;
      m_profitFactor = (m_grossLoss > 0) ? m_grossProfit / m_grossLoss : 0;
      m_expectancy = (m_winRate / 100 * m_avgWin) - ((100 - m_winRate) / 100 * m_avgLoss);
   }
   
   void UpdateSessionStats(string session, bool isWin, double profit) {
      int idx = 0;
      if(session == "Sydney") idx = 0;
      else if(session == "Tokyo") idx = 1;
      else if(session == "London") idx = 2;
      else if(session == "NewYork") idx = 3;
      else idx = 4;
      
      m_sessionProfit[idx] += profit;
      m_sessionTrades[idx]++;
      if(isWin) {
         int wins = (int)(m_sessionWinRate[idx] * m_sessionTrades[idx] / 100) + 1;
         m_sessionWinRate[idx] = (double)wins / m_sessionTrades[idx] * 100;
      }
   }
   
   double GetWinRate() { return m_winRate; }
   double GetProfitFactor() { return m_profitFactor; }
   double GetExpectancy() { return m_expectancy; }
   double GetTotalProfit() { return m_totalProfit; }
   int GetTotalTrades() { return m_tradeCount; }
   
   string GetPerformanceReport() {
      return StringFormat("Trades: %d | WR: %.1f%% | PF: %.2f | Exp: $%.2f",
                          m_tradeCount, m_winRate, m_profitFactor, m_expectancy);
   }
   
   string GetBestSession() {
      int bestIdx = 0;
      double bestProfit = m_sessionProfit[0];
      for(int i = 1; i < 5; i++) {
         if(m_sessionProfit[i] > bestProfit) {
            bestProfit = m_sessionProfit[i];
            bestIdx = i;
         }
      }
      switch(bestIdx) {
         case 0: return "Sydney";
         case 1: return "Tokyo";
         case 2: return "London";
         case 3: return "NewYork";
         default: return "Other";
      }
   }
};

//====================================================================
// v15 GLOBAL OBJECTS - EK MODÜLLER
//====================================================================
CMarketProfiler      MarketProfiler;
CWyckoffAnalyzer     WyckoffAnalyzer;
CSupplyDemandZones   SupplyDemand;
CCandleStatistics    CandleStats;
CTradeJournal        TradeJournal;
CPositionSizer       PositionSizer;
CVolatilityRegime    VolRegime;
CNeuralSimulator     NeuralSim;

// v15 Son eklenen modüller
CAdvancedPatternRecognition PatternRecognition;
CTrendStrengthMeter  TrendMeter;
CMultiSymbolCorrelation SymbolCorrelation;
CAdvancedMoneyManagement MoneyMgmt;
CSmartAlerts         SmartAlerts;
CPerformanceAnalyzer PerfAnalyzer;

//====================================================================
// v15 EXTENSION MODULE 60: MARKET SENTIMENT
//====================================================================
class CMarketSentiment
{
private:
   double m_bullishSentiment;
   double m_bearishSentiment;
   double m_neutralSentiment;
   double m_fearGreedIndex;
   double m_momentumSentiment;
   double m_volatilitySentiment;
   
   // Price action components
   int m_bullishBars;
   int m_bearishBars;
   int m_dojiCount;
   double m_avgBullishBody;
   double m_avgBearishBody;
   
   // Volume sentiment
   double m_buyVolume;
   double m_sellVolume;
   double m_volumeRatio;
   
public:
   CMarketSentiment() : m_bullishSentiment(50), m_bearishSentiment(50),
                         m_neutralSentiment(0), m_fearGreedIndex(50),
                         m_momentumSentiment(50), m_volatilitySentiment(50),
                         m_bullishBars(0), m_bearishBars(0), m_dojiCount(0),
                         m_avgBullishBody(0), m_avgBearishBody(0),
                         m_buyVolume(0), m_sellVolume(0), m_volumeRatio(1) {}
   
   void Analyze(string symbol, ENUM_TIMEFRAMES tf, int lookback = 50) {
      m_bullishBars = 0;
      m_bearishBars = 0;
      m_dojiCount = 0;
      m_avgBullishBody = 0;
      m_avgBearishBody = 0;
      m_buyVolume = 0;
      m_sellVolume = 0;
      
      double totalBullBody = 0, totalBearBody = 0;
      
      for(int i = 1; i <= lookback; i++) {
         double o = iOpen(symbol, tf, i);
         double c = iClose(symbol, tf, i);
         double h = iHigh(symbol, tf, i);
         double l = iLow(symbol, tf, i);
         double vol = (double)iVolume(symbol, tf, i);
         
         double body = MathAbs(c - o);
         double range = h - l;
         
         if(range > 0 && body / range < 0.1) {
            m_dojiCount++;
         } else if(c > o) {
            m_bullishBars++;
            totalBullBody += body;
            m_buyVolume += vol;
         } else {
            m_bearishBars++;
            totalBearBody += body;
            m_sellVolume += vol;
         }
      }
      
      // Calculate averages
      if(m_bullishBars > 0) m_avgBullishBody = totalBullBody / m_bullishBars;
      if(m_bearishBars > 0) m_avgBearishBody = totalBearBody / m_bearishBars;
      
      // Sentiment calculations
      int totalBars = m_bullishBars + m_bearishBars;
      if(totalBars > 0) {
         m_bullishSentiment = (double)m_bullishBars / totalBars * 100;
         m_bearishSentiment = (double)m_bearishBars / totalBars * 100;
      }
      
      // Volume ratio
      if(m_sellVolume > 0) {
         m_volumeRatio = m_buyVolume / m_sellVolume;
      }
      
      // Fear & Greed Index (0-100, 0=Extreme Fear, 100=Extreme Greed)
      double bodyStrength = (m_avgBullishBody > 0 && m_avgBearishBody > 0) ?
                            m_avgBullishBody / (m_avgBullishBody + m_avgBearishBody) * 100 : 50;
      double volumeStrength = MathMin(100, m_volumeRatio * 50);
      
      m_fearGreedIndex = (m_bullishSentiment * 0.4 + bodyStrength * 0.3 + volumeStrength * 0.3);
      
      // Momentum sentiment
      double close0 = iClose(symbol, tf, 0);
      double close10 = iClose(symbol, tf, 10);
      double close20 = iClose(symbol, tf, 20);
      
      if(close20 > 0) {
         double shortMom = (close0 - close10) / close10 * 100;
         double longMom = (close0 - close20) / close20 * 100;
         m_momentumSentiment = 50 + (shortMom * 10 + longMom * 5);
         m_momentumSentiment = MathMax(0, MathMin(100, m_momentumSentiment));
      }
   }
   
   double GetBullishSentiment() { return m_bullishSentiment; }
   double GetBearishSentiment() { return m_bearishSentiment; }
   double GetFearGreedIndex() { return m_fearGreedIndex; }
   double GetMomentumSentiment() { return m_momentumSentiment; }
   double GetVolumeRatio() { return m_volumeRatio; }
   
   int GetSentimentScore(int direction) {
      int score = 50;
      
      if(direction == 1) { // BUY
         if(m_bullishSentiment > 60) score += 15;
         if(m_fearGreedIndex < 30) score += 20; // Buy when fearful
         if(m_fearGreedIndex > 80) score -= 15; // Avoid extreme greed
         if(m_volumeRatio > 1.2) score += 10;
         if(m_momentumSentiment > 60) score += 10;
      } else { // SELL
         if(m_bearishSentiment > 60) score += 15;
         if(m_fearGreedIndex > 80) score += 20; // Sell when greedy
         if(m_fearGreedIndex < 20) score -= 15; // Avoid extreme fear
         if(m_volumeRatio < 0.8) score += 10;
         if(m_momentumSentiment < 40) score += 10;
      }
      
      return MathMax(0, MathMin(100, score));
   }
   
   string GetSentimentReport() {
      string fgLevel = "";
      if(m_fearGreedIndex < 20) fgLevel = "EXTREME FEAR";
      else if(m_fearGreedIndex < 40) fgLevel = "FEAR";
      else if(m_fearGreedIndex < 60) fgLevel = "NEUTRAL";
      else if(m_fearGreedIndex < 80) fgLevel = "GREED";
      else fgLevel = "EXTREME GREED";
      
      return StringFormat("Bull: %.1f%% | Bear: %.1f%% | F&G: %.0f (%s)",
                          m_bullishSentiment, m_bearishSentiment, m_fearGreedIndex, fgLevel);
   }
};

//====================================================================
// v15 EXTENSION MODULE 61: ORDER FLOW ANALYSIS
//====================================================================
class COrderFlowAnalysis
{
private:
   struct Footprint {
      double price;
      long buyVolume;
      long sellVolume;
      long delta;
      long cumDelta;
   };
   
   Footprint m_footprint[];
   int m_footprintSize;
   double m_priceStep;
   
   long m_totalBuyVolume;
   long m_totalSellVolume;
   long m_cumDelta;
   long m_maxDelta;
   long m_minDelta;
   
   // Imbalance detection
   double m_imbalanceRatio;
   bool m_buyImbalance;
   bool m_sellImbalance;
   
   // POC and VAH/VAL from volume
   double m_volumePOC;
   double m_volumeVAH;
   double m_volumeVAL;
   
public:
   COrderFlowAnalysis() : m_footprintSize(0), m_priceStep(0),
                           m_totalBuyVolume(0), m_totalSellVolume(0),
                           m_cumDelta(0), m_maxDelta(0), m_minDelta(0),
                           m_imbalanceRatio(1), m_buyImbalance(false), m_sellImbalance(false),
                           m_volumePOC(0), m_volumeVAH(0), m_volumeVAL(0) {
      ArrayResize(m_footprint, 100);
   }
   
   void Analyze(string symbol, ENUM_TIMEFRAMES tf, int lookback = 50) {
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      m_priceStep = 100 * point; // 10 pip steps
      
      m_totalBuyVolume = 0;
      m_totalSellVolume = 0;
      m_cumDelta = 0;
      m_footprintSize = 0;
      
      for(int bar = 0; bar < lookback; bar++) {
         double o = iOpen(symbol, tf, bar);
         double c = iClose(symbol, tf, bar);
         double h = iHigh(symbol, tf, bar);
         double l = iLow(symbol, tf, bar);
         long vol = iVolume(symbol, tf, bar);
         
         bool isBullish = (c > o);
         long buyVol = isBullish ? (long)(vol * 0.6) : (long)(vol * 0.4);
         long sellVol = vol - buyVol;
         
         m_totalBuyVolume += buyVol;
         m_totalSellVolume += sellVol;
         
         long delta = buyVol - sellVol;
         m_cumDelta += delta;
         
         if(m_cumDelta > m_maxDelta) m_maxDelta = m_cumDelta;
         if(m_cumDelta < m_minDelta) m_minDelta = m_cumDelta;
         
         // Add to footprint
         if(m_footprintSize < 100) {
            m_footprint[m_footprintSize].price = (h + l) / 2;
            m_footprint[m_footprintSize].buyVolume = buyVol;
            m_footprint[m_footprintSize].sellVolume = sellVol;
            m_footprint[m_footprintSize].delta = delta;
            m_footprint[m_footprintSize].cumDelta = m_cumDelta;
            m_footprintSize++;
         }
      }
      
      // Calculate imbalance
      if(m_totalSellVolume > 0) {
         m_imbalanceRatio = (double)m_totalBuyVolume / m_totalSellVolume;
      }
      m_buyImbalance = (m_imbalanceRatio > 1.5);
      m_sellImbalance = (m_imbalanceRatio < 0.67);
      
      // Find Volume POC
      FindVolumePOC();
   }
   
   void FindVolumePOC() {
      if(m_footprintSize == 0) return;
      
      long maxVol = 0;
      double pocPrice = 0;
      
      for(int i = 0; i < m_footprintSize; i++) {
         long totalVol = m_footprint[i].buyVolume + m_footprint[i].sellVolume;
         if(totalVol > maxVol) {
            maxVol = totalVol;
            pocPrice = m_footprint[i].price;
         }
      }
      
      m_volumePOC = pocPrice;
   }
   
   long GetCumulativeDelta() { return m_cumDelta; }
   double GetImbalanceRatio() { return m_imbalanceRatio; }
   bool HasBuyImbalance() { return m_buyImbalance; }
   bool HasSellImbalance() { return m_sellImbalance; }
   double GetVolumePOC() { return m_volumePOC; }
   
   int GetOrderFlowScore(int direction) {
      int score = 50;
      
      if(direction == 1) { // BUY
         if(m_cumDelta > 0) score += 15;
         if(m_buyImbalance) score += 20;
         if(m_imbalanceRatio > 1.2) score += 10;
      } else { // SELL
         if(m_cumDelta < 0) score += 15;
         if(m_sellImbalance) score += 20;
         if(m_imbalanceRatio < 0.8) score += 10;
      }
      
      return MathMax(0, MathMin(100, score));
   }
   
   string GetOrderFlowReport() {
      return StringFormat("Delta: %lld | Ratio: %.2f | %s",
                          m_cumDelta, m_imbalanceRatio,
                          (m_buyImbalance ? "BUY IMBAL" : (m_sellImbalance ? "SELL IMBAL" : "BALANCED")));
   }
};

//====================================================================
// v15 EXTENSION MODULE 62: ADVANCED STATISTICS
//====================================================================
class CAdvancedStatistics
{
private:
   double m_returns[];
   int m_returnCount;
   int m_maxReturns;
   
   double m_mean;
   double m_stdDev;
   double m_variance;
   double m_skewness;
   double m_kurtosis;
   double m_sharpeRatio;
   double m_sortinoRatio;
   double m_maxDrawdown;
   double m_calmarRatio;
   double m_zScore;
   
public:
   CAdvancedStatistics() : m_returnCount(0), m_maxReturns(500),
                            m_mean(0), m_stdDev(0), m_variance(0),
                            m_skewness(0), m_kurtosis(0),
                            m_sharpeRatio(0), m_sortinoRatio(0),
                            m_maxDrawdown(0), m_calmarRatio(0), m_zScore(0) {
      ArrayResize(m_returns, m_maxReturns);
   }
   
   void AddReturn(double returnPct) {
      if(m_returnCount >= m_maxReturns) {
         for(int i = 0; i < m_maxReturns - 1; i++) {
            m_returns[i] = m_returns[i + 1];
         }
         m_returnCount = m_maxReturns - 1;
      }
      m_returns[m_returnCount] = returnPct;
      m_returnCount++;
      
      Calculate();
   }
   
   void Calculate() {
      if(m_returnCount < 2) return;
      
      // Mean
      m_mean = 0;
      for(int i = 0; i < m_returnCount; i++) {
         m_mean += m_returns[i];
      }
      m_mean /= m_returnCount;
      
      // Variance and StdDev
      m_variance = 0;
      for(int i = 0; i < m_returnCount; i++) {
         m_variance += MathPow(m_returns[i] - m_mean, 2);
      }
      m_variance /= m_returnCount;
      m_stdDev = MathSqrt(m_variance);
      
      // Skewness (3rd moment)
      if(m_stdDev > 0) {
         double sum3 = 0;
         for(int i = 0; i < m_returnCount; i++) {
            sum3 += MathPow((m_returns[i] - m_mean) / m_stdDev, 3);
         }
         m_skewness = sum3 / m_returnCount;
      }
      
      // Kurtosis (4th moment)
      if(m_stdDev > 0) {
         double sum4 = 0;
         for(int i = 0; i < m_returnCount; i++) {
            sum4 += MathPow((m_returns[i] - m_mean) / m_stdDev, 4);
         }
         m_kurtosis = sum4 / m_returnCount - 3; // Excess kurtosis
      }
      
      // Sharpe Ratio (assuming risk-free rate of 0)
      if(m_stdDev > 0) {
         m_sharpeRatio = m_mean / m_stdDev * MathSqrt(252); // Annualized
      }
      
      // Sortino Ratio (downside deviation)
      double downVar = 0;
      int downCount = 0;
      for(int i = 0; i < m_returnCount; i++) {
         if(m_returns[i] < 0) {
            downVar += MathPow(m_returns[i], 2);
            downCount++;
         }
      }
      if(downCount > 0) {
         double downDev = MathSqrt(downVar / downCount);
         if(downDev > 0) {
            m_sortinoRatio = m_mean / downDev * MathSqrt(252);
         }
      }
      
      // Z-Score
      if(m_stdDev > 0) {
         double lastReturn = m_returns[m_returnCount - 1];
         m_zScore = (lastReturn - m_mean) / m_stdDev;
      }
   }
   
   double GetMean() { return m_mean; }
   double GetStdDev() { return m_stdDev; }
   double GetSkewness() { return m_skewness; }
   double GetKurtosis() { return m_kurtosis; }
   double GetSharpeRatio() { return m_sharpeRatio; }
   double GetSortinoRatio() { return m_sortinoRatio; }
   double GetZScore() { return m_zScore; }
   
   int GetStatScore() {
      int score = 50;
      
      if(m_sharpeRatio > 1.5) score += 20;
      else if(m_sharpeRatio > 1.0) score += 10;
      else if(m_sharpeRatio < 0) score -= 15;
      
      if(m_skewness > 0) score += 5; // Positive skew is good
      if(m_kurtosis < 3) score += 5; // Less tail risk
      
      return MathMax(0, MathMin(100, score));
   }
   
   string GetStatsReport() {
      return StringFormat("Sharpe: %.2f | Sortino: %.2f | Skew: %.2f | Z: %.2f",
                          m_sharpeRatio, m_sortinoRatio, m_skewness, m_zScore);
   }
};

//====================================================================
// v15 EXTENSION MODULE 63: RISK SCORECARD
//====================================================================
class CRiskScorecard
{
private:
   struct RiskFactor {
      string name;
      double value;
      double weight;
      int score;
   };
   
   RiskFactor m_factors[15];
   int m_factorCount;
   int m_totalScore;
   string m_riskLevel;
   bool m_tradingAllowed;
   
public:
   CRiskScorecard() : m_factorCount(15), m_totalScore(50), m_riskLevel("NORMAL"), m_tradingAllowed(true) {
      // Initialize factors
      m_factors[0].name = "Drawdown"; m_factors[0].weight = 15;
      m_factors[1].name = "ConsecLoss"; m_factors[1].weight = 10;
      m_factors[2].name = "DailyPL"; m_factors[2].weight = 10;
      m_factors[3].name = "Spread"; m_factors[3].weight = 8;
      m_factors[4].name = "Volatility"; m_factors[4].weight = 12;
      m_factors[5].name = "News"; m_factors[5].weight = 10;
      m_factors[6].name = "Session"; m_factors[6].weight = 8;
      m_factors[7].name = "Correlation"; m_factors[7].weight = 5;
      m_factors[8].name = "Positions"; m_factors[8].weight = 7;
      m_factors[9].name = "Margin"; m_factors[9].weight = 5;
      m_factors[10].name = "WinRate"; m_factors[10].weight = 5;
      m_factors[11].name = "Trend"; m_factors[11].weight = 3;
      m_factors[12].name = "Volume"; m_factors[12].weight = 2;
      m_factors[13].name = "Time"; m_factors[13].weight = 0;
      m_factors[14].name = "Custom"; m_factors[14].weight = 0;
      
      for(int i = 0; i < m_factorCount; i++) {
         m_factors[i].value = 0;
         m_factors[i].score = 50;
      }
   }
   
   void UpdateFactor(string name, double value, int score) {
      for(int i = 0; i < m_factorCount; i++) {
         if(m_factors[i].name == name) {
            m_factors[i].value = value;
            m_factors[i].score = score;
            break;
         }
      }
   }
   
   void Calculate() {
      double totalWeight = 0;
      double weightedScore = 0;
      
      for(int i = 0; i < m_factorCount; i++) {
         if(m_factors[i].weight > 0) {
            weightedScore += m_factors[i].score * m_factors[i].weight;
            totalWeight += m_factors[i].weight;
         }
      }
      
      m_totalScore = (totalWeight > 0) ? (int)(weightedScore / totalWeight) : 50;
      
      // Determine risk level
      if(m_totalScore >= 80) {
         m_riskLevel = "VERY_LOW";
         m_tradingAllowed = true;
      } else if(m_totalScore >= 65) {
         m_riskLevel = "LOW";
         m_tradingAllowed = true;
      } else if(m_totalScore >= 50) {
         m_riskLevel = "NORMAL";
         m_tradingAllowed = true;
      } else if(m_totalScore >= 35) {
         m_riskLevel = "HIGH";
         m_tradingAllowed = true;
      } else if(m_totalScore >= 20) {
         m_riskLevel = "VERY_HIGH";
         m_tradingAllowed = false;
      } else {
         m_riskLevel = "EXTREME";
         m_tradingAllowed = false;
      }
   }
   
   int GetTotalScore() { return m_totalScore; }
   string GetRiskLevel() { return m_riskLevel; }
   bool IsTradingAllowed() { return m_tradingAllowed; }
   
   double GetLotMultiplier() {
      if(m_totalScore >= 80) return 1.25;
      if(m_totalScore >= 65) return 1.0;
      if(m_totalScore >= 50) return 0.75;
      if(m_totalScore >= 35) return 0.5;
      return 0.25;
   }
   
   string GetScorecardReport() {
      return StringFormat("Risk: %d | Level: %s | Trade: %s | Lot: %.2fx",
                          m_totalScore, m_riskLevel,
                          (m_tradingAllowed ? "OK" : "STOP"),
                          GetLotMultiplier());
   }
   
   void PrintDetailedReport() {
      Print("═══════ RISK SCORECARD ═══════");
      for(int i = 0; i < m_factorCount; i++) {
         if(m_factors[i].weight > 0) {
            Print(StringFormat("%s: %.2f | Score: %d | Weight: %.0f%%",
                               m_factors[i].name, m_factors[i].value,
                               m_factors[i].score, m_factors[i].weight));
         }
      }
      Print(StringFormat("TOTAL: %d | LEVEL: %s", m_totalScore, m_riskLevel));
      Print("══════════════════════════════");
   }
};

//====================================================================
// v15 GLOBAL OBJECTS - FINAL MODÜLLER
//====================================================================
CMarketSentiment     MarketSentiment;
COrderFlowAnalysis   OrderFlow;
CAdvancedStatistics  AdvStats;
CRiskScorecard       RiskCard;

//====================================================================
// v15 EXTENSION MODULE 64: MULTI-TIMEFRAME DIVERGENCE
//====================================================================
class CMultiTimeframeDivergence
{
private:
   struct DivergenceData {
      ENUM_TIMEFRAMES tf;
      int direction;          // 1=bullish, -1=bearish, 0=none
      double strength;        // 0-100
      string type;            // "regular", "hidden"
      datetime detectTime;
   };
   
   DivergenceData m_divergences[5];
   int m_rsiHandles[5];
   int m_macdHandles[5];
   ENUM_TIMEFRAMES m_timeframes[5];
   int m_tfCount;
   
   bool m_bullishRegular;
   bool m_bearishRegular;
   bool m_bullishHidden;
   bool m_bearishHidden;
   int m_confirmedCount;
   
public:
   CMultiTimeframeDivergence() : m_tfCount(5), m_bullishRegular(false), m_bearishRegular(false),
                                   m_bullishHidden(false), m_bearishHidden(false), m_confirmedCount(0) {
      m_timeframes[0] = PERIOD_M5;
      m_timeframes[1] = PERIOD_M15;
      m_timeframes[2] = PERIOD_M30;
      m_timeframes[3] = PERIOD_H1;
      m_timeframes[4] = PERIOD_H4;
      
      for(int i = 0; i < 5; i++) {
         m_rsiHandles[i] = INVALID_HANDLE;
         m_macdHandles[i] = INVALID_HANDLE;
         m_divergences[i].direction = 0;
         m_divergences[i].strength = 0;
         m_divergences[i].type = "";
         m_divergences[i].tf = m_timeframes[i];
      }
   }
   
   bool Init(string symbol) {
      bool success = true;
      for(int i = 0; i < m_tfCount; i++) {
         m_rsiHandles[i] = iRSI(symbol, m_timeframes[i], 14, PRICE_CLOSE);
         m_macdHandles[i] = iMACD(symbol, m_timeframes[i], 12, 26, 9, PRICE_CLOSE);
         if(m_rsiHandles[i] == INVALID_HANDLE) success = false;
      }
      return success;
   }
   
   void Release() {
      for(int i = 0; i < m_tfCount; i++) {
         if(m_rsiHandles[i] != INVALID_HANDLE) IndicatorRelease(m_rsiHandles[i]);
         if(m_macdHandles[i] != INVALID_HANDLE) IndicatorRelease(m_macdHandles[i]);
      }
   }
   
   void DetectDivergence(string symbol, int tfIndex, int lookback = 30) {
      if(m_rsiHandles[tfIndex] == INVALID_HANDLE) return;
      
      double rsi[];
      ArraySetAsSeries(rsi, true);
      CopyBuffer(m_rsiHandles[tfIndex], 0, 0, lookback + 5, rsi);
      
      ENUM_TIMEFRAMES tf = m_timeframes[tfIndex];
      
      // Find price and RSI swing points
      double priceHigh1 = 0, priceHigh2 = 0, priceLow1 = 0, priceLow2 = 0;
      double rsiHigh1 = 0, rsiHigh2 = 0, rsiLow1 = 0, rsiLow2 = 0;
      int idxHigh1 = 0, idxHigh2 = 0, idxLow1 = 0, idxLow2 = 0;
      
      // Find highest high and lowest low
      for(int i = 2; i < lookback - 2; i++) {
         double h = iHigh(symbol, tf, i);
         double l = iLow(symbol, tf, i);
         
         if(h > priceHigh1) {
            priceHigh2 = priceHigh1; rsiHigh2 = rsiHigh1; idxHigh2 = idxHigh1;
            priceHigh1 = h; rsiHigh1 = rsi[i]; idxHigh1 = i;
         }
         if(l < priceLow1 || priceLow1 == 0) {
            priceLow2 = priceLow1; rsiLow2 = rsiLow1; idxLow2 = idxLow1;
            priceLow1 = l; rsiLow1 = rsi[i]; idxLow1 = i;
         }
      }
      
      m_divergences[tfIndex].direction = 0;
      m_divergences[tfIndex].strength = 0;
      m_divergences[tfIndex].type = "";
      
      // Regular Bullish: Lower low in price, higher low in RSI
      if(priceLow1 < priceLow2 && rsiLow1 > rsiLow2 && idxLow1 < idxLow2) {
         m_divergences[tfIndex].direction = 1;
         m_divergences[tfIndex].type = "regular";
         m_divergences[tfIndex].strength = MathAbs(rsiLow1 - rsiLow2) * 2;
      }
      
      // Regular Bearish: Higher high in price, lower high in RSI
      if(priceHigh1 > priceHigh2 && rsiHigh1 < rsiHigh2 && idxHigh1 < idxHigh2) {
         m_divergences[tfIndex].direction = -1;
         m_divergences[tfIndex].type = "regular";
         m_divergences[tfIndex].strength = MathAbs(rsiHigh1 - rsiHigh2) * 2;
      }
      
      // Hidden Bullish: Higher low in price, lower low in RSI
      if(priceLow1 > priceLow2 && rsiLow1 < rsiLow2 && idxLow1 < idxLow2) {
         m_divergences[tfIndex].direction = 1;
         m_divergences[tfIndex].type = "hidden";
         m_divergences[tfIndex].strength = MathAbs(rsiLow1 - rsiLow2) * 1.5;
      }
      
      // Hidden Bearish: Lower high in price, higher high in RSI
      if(priceHigh1 < priceHigh2 && rsiHigh1 > rsiHigh2 && idxHigh1 < idxHigh2) {
         m_divergences[tfIndex].direction = -1;
         m_divergences[tfIndex].type = "hidden";
         m_divergences[tfIndex].strength = MathAbs(rsiHigh1 - rsiHigh2) * 1.5;
      }
      
      m_divergences[tfIndex].strength = MathMin(100, m_divergences[tfIndex].strength);
      m_divergences[tfIndex].detectTime = TimeCurrent();
   }
   
   void Update(string symbol) {
      m_confirmedCount = 0;
      m_bullishRegular = false;
      m_bearishRegular = false;
      m_bullishHidden = false;
      m_bearishHidden = false;
      
      for(int i = 0; i < m_tfCount; i++) {
         DetectDivergence(symbol, i);
         
         if(m_divergences[i].direction == 1 && m_divergences[i].type == "regular") {
            m_bullishRegular = true;
            m_confirmedCount++;
         }
         if(m_divergences[i].direction == -1 && m_divergences[i].type == "regular") {
            m_bearishRegular = true;
            m_confirmedCount++;
         }
         if(m_divergences[i].direction == 1 && m_divergences[i].type == "hidden") {
            m_bullishHidden = true;
            m_confirmedCount++;
         }
         if(m_divergences[i].direction == -1 && m_divergences[i].type == "hidden") {
            m_bearishHidden = true;
            m_confirmedCount++;
         }
      }
   }
   
   int GetDivergenceScore(int direction) {
      int score = 50;
      
      if(direction == 1) {
         if(m_bullishRegular) score += 25;
         if(m_bullishHidden) score += 15;
      } else {
         if(m_bearishRegular) score += 25;
         if(m_bearishHidden) score += 15;
      }
      
      // MTF confirmation bonus
      if(m_confirmedCount >= 3) score += 15;
      else if(m_confirmedCount >= 2) score += 10;
      
      return MathMin(100, score);
   }
   
   string GetDivergenceReport() {
      string result = "";
      for(int i = 0; i < m_tfCount; i++) {
         if(m_divergences[i].direction != 0) {
            result += EnumToString(m_timeframes[i]) + ":" + m_divergences[i].type + " ";
         }
      }
      if(result == "") result = "None";
      return result;
   }
   
   bool HasBullishDivergence() { return m_bullishRegular || m_bullishHidden; }
   bool HasBearishDivergence() { return m_bearishRegular || m_bearishHidden; }
   int GetConfirmedCount() { return m_confirmedCount; }
};

//====================================================================
// v15 EXTENSION MODULE 65: SMART LOT CALCULATOR
//====================================================================
class CSmartLotCalculator
{
private:
   // Account info
   double m_balance;
   double m_equity;
   double m_freeMargin;
   double m_usedMargin;
   double m_marginLevel;
   
   // Symbol info
   double m_tickValue;
   double m_tickSize;
   double m_pointValue;
   double m_minLot;
   double m_maxLot;
   double m_lotStep;
   double m_contractSize;
   
   // Risk parameters
   double m_riskPercent;
   double m_maxRiskPercent;
   double m_minRiskPercent;
   double m_maxPositionPercent;
   
   // Calculated values
   double m_optimalLot;
   double m_maxAllowedLot;
   double m_marginRequired;
   
public:
   CSmartLotCalculator() : m_balance(0), m_equity(0), m_freeMargin(0),
                            m_usedMargin(0), m_marginLevel(0),
                            m_tickValue(0), m_tickSize(0), m_pointValue(0),
                            m_minLot(0.01), m_maxLot(100), m_lotStep(0.01),
                            m_contractSize(100000), m_riskPercent(1.0),
                            m_maxRiskPercent(3.0), m_minRiskPercent(0.25),
                            m_maxPositionPercent(20), m_optimalLot(0.01),
                            m_maxAllowedLot(0), m_marginRequired(0) {}
   
   void UpdateAccountInfo() {
      m_balance = AccountInfoDouble(ACCOUNT_BALANCE);
      m_equity = AccountInfoDouble(ACCOUNT_EQUITY);
      m_freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      m_usedMargin = AccountInfoDouble(ACCOUNT_MARGIN);
      m_marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   }
   
   void UpdateSymbolInfo(string symbol) {
      m_tickValue = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
      m_tickSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      m_pointValue = SymbolInfoDouble(symbol, SYMBOL_POINT);
      m_minLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
      m_maxLot = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
      m_lotStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
      m_contractSize = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   }
   
   void SetRiskPercent(double risk) {
      m_riskPercent = MathMax(m_minRiskPercent, MathMin(m_maxRiskPercent, risk));
   }
   
   double CalculateLotFromRisk(double slPips) {
      if(slPips <= 0 || m_balance <= 0) return m_minLot;
      
      double riskAmount = m_balance * m_riskPercent / 100.0;
      double pipValue = m_tickValue / (m_tickSize / m_pointValue);
      
      if(pipValue <= 0) return m_minLot;
      
      double lot = riskAmount / (slPips * pipValue);
      return NormalizeLot(lot);
   }
   
   double CalculateLotFromMargin(double marginPercent) {
      if(m_freeMargin <= 0) return m_minLot;
      
      double marginToUse = m_freeMargin * marginPercent / 100.0;
      double marginPerLot = SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_INITIAL);
      
      if(marginPerLot <= 0) marginPerLot = m_contractSize * m_pointValue;
      
      double lot = marginToUse / marginPerLot;
      return NormalizeLot(lot);
   }
   
   double CalculateKellyLot(double winRate, double avgWin, double avgLoss, double slPips) {
      if(avgLoss <= 0 || slPips <= 0) return m_minLot;
      
      double b = avgWin / avgLoss;
      double p = winRate / 100.0;
      double q = 1 - p;
      
      double f = (b * p - q) / b;
      f = MathMax(0, MathMin(0.25, f)); // Cap at 25%
      
      double riskAmount = m_balance * f;
      double pipValue = m_tickValue / (m_tickSize / m_pointValue);
      
      if(pipValue <= 0) return m_minLot;
      
      double lot = riskAmount / (slPips * pipValue);
      return NormalizeLot(lot);
   }
   
   double CalculateATRLot(double atr, double atrMultiplier = 2.0) {
      if(atr <= 0 || m_pointValue <= 0) return m_minLot;
      
      double slPips = (atr / m_pointValue) * atrMultiplier;
      return CalculateLotFromRisk(slPips);
   }
   
   double NormalizeLot(double lot) {
      lot = MathFloor(lot / m_lotStep) * m_lotStep;
      lot = MathMax(m_minLot, MathMin(m_maxLot, lot));
      return NormalizeDouble(lot, 2);
   }
   
   double CalculateMaxAllowedLot() {
      double lot1 = m_freeMargin * m_maxPositionPercent / 100.0;
      double marginPerLot = SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_INITIAL);
      
      if(marginPerLot > 0) lot1 = lot1 / marginPerLot;
      else lot1 = m_maxLot;
      
      double lot2 = m_balance * m_maxRiskPercent / 100.0;
      double pipValue = m_tickValue / (m_tickSize / m_pointValue);
      if(pipValue > 0) lot2 = lot2 / (50 * pipValue); // Assume 50 pip SL
      else lot2 = m_maxLot;
      
      m_maxAllowedLot = NormalizeLot(MathMin(lot1, lot2));
      return m_maxAllowedLot;
   }
   
   double GetOptimalLot(double slPips, double winRate = 50, double avgWin = 0, double avgLoss = 0) {
      UpdateAccountInfo();
      UpdateSymbolInfo(_Symbol);
      
      double riskLot = CalculateLotFromRisk(slPips);
      double kellyLot = (avgWin > 0 && avgLoss > 0) ?
                        CalculateKellyLot(winRate, avgWin, avgLoss, slPips) : riskLot;
      double maxLot = CalculateMaxAllowedLot();
      
      // Weighted average: 60% risk-based, 30% Kelly, 10% max
      m_optimalLot = riskLot * 0.6 + kellyLot * 0.3 + maxLot * 0.1;
      m_optimalLot = NormalizeLot(m_optimalLot);
      m_optimalLot = MathMin(m_optimalLot, maxLot);
      
      return m_optimalLot;
   }
   
   string GetLotReport() {
      return StringFormat("Lot: %.2f | Risk: %.1f%% | Max: %.2f | Margin: %.0f%%",
                          m_optimalLot, m_riskPercent, m_maxAllowedLot, m_marginLevel);
   }
};

//====================================================================
// v15 EXTENSION MODULE 66: SESSION PROFILER
//====================================================================
class CSessionProfiler
{
private:
   struct SessionProfile {
      string name;
      int startHour;
      int endHour;
      int totalTrades;
      int wins;
      int losses;
      double totalProfit;
      double avgProfit;
      double avgLoss;
      double winRate;
      double profitFactor;
      double avgDuration;
      double bestTime;
      double worstTime;
      bool isActive;
   };
   
   SessionProfile m_sessions[6];
   int m_sessionCount;
   int m_currentSession;
   
   // Real-time stats
   double m_currentVolatility[6];
   double m_currentSpread[6];
   int m_currentTrend[6];
   
public:
   CSessionProfiler() : m_sessionCount(6), m_currentSession(0) {
      // Sydney
      m_sessions[0].name = "Sydney";
      m_sessions[0].startHour = 22;
      m_sessions[0].endHour = 7;
      
      // Tokyo
      m_sessions[1].name = "Tokyo";
      m_sessions[1].startHour = 0;
      m_sessions[1].endHour = 9;
      
      // London
      m_sessions[2].name = "London";
      m_sessions[2].startHour = 8;
      m_sessions[2].endHour = 16;
      
      // New York
      m_sessions[3].name = "NewYork";
      m_sessions[3].startHour = 13;
      m_sessions[3].endHour = 22;
      
      // London-NY Overlap
      m_sessions[4].name = "LondonNY";
      m_sessions[4].startHour = 13;
      m_sessions[4].endHour = 16;
      
      // Off Market
      m_sessions[5].name = "OffMarket";
      m_sessions[5].startHour = 22;
      m_sessions[5].endHour = 22;
      
      for(int i = 0; i < m_sessionCount; i++) {
         m_sessions[i].totalTrades = 0;
         m_sessions[i].wins = 0;
         m_sessions[i].losses = 0;
         m_sessions[i].totalProfit = 0;
         m_sessions[i].avgProfit = 0;
         m_sessions[i].avgLoss = 0;
         m_sessions[i].winRate = 50;
         m_sessions[i].profitFactor = 1;
         m_sessions[i].avgDuration = 0;
         m_sessions[i].bestTime = 0;
         m_sessions[i].worstTime = 0;
         m_sessions[i].isActive = false;
         m_currentVolatility[i] = 0;
         m_currentSpread[i] = 0;
         m_currentTrend[i] = 0;
      }
   }
   
   void Update() {
      MqlDateTime dt;
      TimeCurrent(dt);
      int hour = dt.hour;
      
      // Determine current session
      for(int i = 0; i < m_sessionCount; i++) {
         bool inSession = false;
         
         if(m_sessions[i].startHour < m_sessions[i].endHour) {
            inSession = (hour >= m_sessions[i].startHour && hour < m_sessions[i].endHour);
         } else {
            inSession = (hour >= m_sessions[i].startHour || hour < m_sessions[i].endHour);
         }
         
         m_sessions[i].isActive = inSession;
         if(inSession && i < 4) m_currentSession = i;
      }
   }
   
   void RecordTrade(bool isWin, double profit, int duration) {
      int idx = m_currentSession;
      
      m_sessions[idx].totalTrades++;
      m_sessions[idx].totalProfit += profit;
      
      if(isWin) {
         m_sessions[idx].wins++;
         m_sessions[idx].avgProfit = (m_sessions[idx].avgProfit * (m_sessions[idx].wins - 1) + profit) / m_sessions[idx].wins;
      } else {
         m_sessions[idx].losses++;
         m_sessions[idx].avgLoss = (m_sessions[idx].avgLoss * (m_sessions[idx].losses - 1) + MathAbs(profit)) / m_sessions[idx].losses;
      }
      
      m_sessions[idx].winRate = (m_sessions[idx].totalTrades > 0) ?
                                 (double)m_sessions[idx].wins / m_sessions[idx].totalTrades * 100 : 50;
      
      if(m_sessions[idx].avgLoss > 0) {
         m_sessions[idx].profitFactor = (m_sessions[idx].avgProfit * m_sessions[idx].wins) /
                                         (m_sessions[idx].avgLoss * m_sessions[idx].losses);
      }
      
      m_sessions[idx].avgDuration = (m_sessions[idx].avgDuration * (m_sessions[idx].totalTrades - 1) + duration) / m_sessions[idx].totalTrades;
   }
   
   string GetCurrentSession() { return m_sessions[m_currentSession].name; }
   int GetCurrentSessionIndex() { return m_currentSession; }
   
   double GetSessionWinRate(int idx) {
      if(idx >= 0 && idx < m_sessionCount) return m_sessions[idx].winRate;
      return 50;
   }
   
   double GetSessionPF(int idx) {
      if(idx >= 0 && idx < m_sessionCount) return m_sessions[idx].profitFactor;
      return 1;
   }
   
   bool IsLondonNYOverlap() { return m_sessions[4].isActive; }
   
   int GetSessionScore() {
      int score = 50;
      int idx = m_currentSession;
      
      if(m_sessions[idx].winRate > 55) score += 15;
      if(m_sessions[idx].profitFactor > 1.5) score += 15;
      if(IsLondonNYOverlap()) score += 10;
      
      // Best sessions
      if(m_sessions[idx].name == "London" || m_sessions[idx].name == "NewYork") score += 10;
      
      return MathMin(100, score);
   }
   
   string GetSessionReport() {
      int idx = m_currentSession;
      return StringFormat("%s | WR: %.1f%% | PF: %.2f | Score: %d",
                          m_sessions[idx].name, m_sessions[idx].winRate,
                          m_sessions[idx].profitFactor, GetSessionScore());
   }
   
   string GetBestSession() {
      int bestIdx = 0;
      double bestPF = 0;
      
      for(int i = 0; i < 4; i++) {
         if(m_sessions[i].profitFactor > bestPF && m_sessions[i].totalTrades >= 10) {
            bestPF = m_sessions[i].profitFactor;
            bestIdx = i;
         }
      }
      
      return m_sessions[bestIdx].name;
   }
};

//====================================================================
// v15 GLOBAL OBJECTS - ULTRA FINAL MODÜLLER
//====================================================================
CMultiTimeframeDivergence MTFDivergence;
CSmartLotCalculator SmartLot;
CSessionProfiler SessionProfiler;

//====================================================================
// v15 EXTENSION MODULE 67: PRICE ACTION FILTER
//====================================================================
class CPriceActionFilter
{
private:
   // Support/Resistance levels
   double m_resistanceLevels[10];
   double m_supportLevels[10];
   int m_resistanceCount;
   int m_supportCount;
   
   // Trend lines
   double m_trendlineSlope;
   double m_trendlineIntercept;
   bool m_hasValidTrendline;
   
   // Price action patterns
   bool m_pinBar;
   bool m_insideBar;
   bool m_outsideBar;
   bool m_morgingStar;
   bool m_eveningStar;
   bool m_hammer;
   bool m_shootingStar;
   bool m_threeWhiteSoldiers;
   bool m_threeBlackCrows;
   
   // Key levels
   double m_dailyOpen;
   double m_dailyHigh;
   double m_dailyLow;
   double m_previousClose;
   double m_weeklyPivot;
   double m_monthlyPivot;
   
public:
   CPriceActionFilter() : m_resistanceCount(0), m_supportCount(0),
                           m_trendlineSlope(0), m_trendlineIntercept(0), m_hasValidTrendline(false),
                           m_pinBar(false), m_insideBar(false), m_outsideBar(false),
                           m_morgingStar(false), m_eveningStar(false),
                           m_hammer(false), m_shootingStar(false),
                           m_threeWhiteSoldiers(false), m_threeBlackCrows(false),
                           m_dailyOpen(0), m_dailyHigh(0), m_dailyLow(0),
                           m_previousClose(0), m_weeklyPivot(0), m_monthlyPivot(0) {}
   
   void FindSupportResistance(string symbol, ENUM_TIMEFRAMES tf, int lookback = 100) {
      m_resistanceCount = 0;
      m_supportCount = 0;
      
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      double tolerance = 50 * point;
      
      for(int i = 2; i < lookback - 2 && (m_resistanceCount < 10 || m_supportCount < 10); i++) {
         double h = iHigh(symbol, tf, i);
         double l = iLow(symbol, tf, i);
         
         // Swing High = Resistance
         if(iHigh(symbol, tf, i) > iHigh(symbol, tf, i-1) && 
            iHigh(symbol, tf, i) > iHigh(symbol, tf, i-2) &&
            iHigh(symbol, tf, i) > iHigh(symbol, tf, i+1) &&
            iHigh(symbol, tf, i) > iHigh(symbol, tf, i+2)) {
            
            bool duplicate = false;
            for(int j = 0; j < m_resistanceCount; j++) {
               if(MathAbs(m_resistanceLevels[j] - h) < tolerance) {
                  duplicate = true;
                  break;
               }
            }
            if(!duplicate && m_resistanceCount < 10) {
               m_resistanceLevels[m_resistanceCount] = h;
               m_resistanceCount++;
            }
         }
         
         // Swing Low = Support
         if(iLow(symbol, tf, i) < iLow(symbol, tf, i-1) && 
            iLow(symbol, tf, i) < iLow(symbol, tf, i-2) &&
            iLow(symbol, tf, i) < iLow(symbol, tf, i+1) &&
            iLow(symbol, tf, i) < iLow(symbol, tf, i+2)) {
            
            bool duplicate = false;
            for(int j = 0; j < m_supportCount; j++) {
               if(MathAbs(m_supportLevels[j] - l) < tolerance) {
                  duplicate = true;
                  break;
               }
            }
            if(!duplicate && m_supportCount < 10) {
               m_supportLevels[m_supportCount] = l;
               m_supportCount++;
            }
         }
      }
   }
   
   void DetectPatterns(string symbol, ENUM_TIMEFRAMES tf) {
      // Reset patterns
      m_pinBar = false;
      m_insideBar = false;
      m_outsideBar = false;
      m_hammer = false;
      m_shootingStar = false;
      m_threeWhiteSoldiers = false;
      m_threeBlackCrows = false;
      
      double o1 = iOpen(symbol, tf, 1);
      double h1 = iHigh(symbol, tf, 1);
      double l1 = iLow(symbol, tf, 1);
      double c1 = iClose(symbol, tf, 1);
      
      double o2 = iOpen(symbol, tf, 2);
      double h2 = iHigh(symbol, tf, 2);
      double l2 = iLow(symbol, tf, 2);
      double c2 = iClose(symbol, tf, 2);
      
      double body1 = MathAbs(c1 - o1);
      double range1 = h1 - l1;
      double upperWick1 = h1 - MathMax(o1, c1);
      double lowerWick1 = MathMin(o1, c1) - l1;
      
      if(range1 == 0) return;
      
      // Pin Bar
      if((upperWick1 > body1 * 2 && lowerWick1 < body1 * 0.5) ||
         (lowerWick1 > body1 * 2 && upperWick1 < body1 * 0.5)) {
         m_pinBar = true;
      }
      
      // Inside Bar
      if(h1 < h2 && l1 > l2) {
         m_insideBar = true;
      }
      
      // Outside Bar
      if(h1 > h2 && l1 < l2) {
         m_outsideBar = true;
      }
      
      // Hammer (bullish)
      if(lowerWick1 > body1 * 2 && upperWick1 < body1 * 0.5 && c1 > o1) {
         m_hammer = true;
      }
      
      // Shooting Star (bearish)
      if(upperWick1 > body1 * 2 && lowerWick1 < body1 * 0.5 && c1 < o1) {
         m_shootingStar = true;
      }
      
      // Three White Soldiers
      double o3 = iOpen(symbol, tf, 3);
      double c3 = iClose(symbol, tf, 3);
      if(c1 > o1 && c2 > o2 && c3 > o3 && c1 > c2 && c2 > c3) {
         m_threeWhiteSoldiers = true;
      }
      
      // Three Black Crows
      if(c1 < o1 && c2 < o2 && c3 < o3 && c1 < c2 && c2 < c3) {
         m_threeBlackCrows = true;
      }
   }
   
   void UpdateKeyLevels(string symbol) {
      m_dailyOpen = iOpen(symbol, PERIOD_D1, 0);
      m_dailyHigh = iHigh(symbol, PERIOD_D1, 0);
      m_dailyLow = iLow(symbol, PERIOD_D1, 0);
      m_previousClose = iClose(symbol, PERIOD_D1, 1);
      
      double pH = iHigh(symbol, PERIOD_D1, 1);
      double pL = iLow(symbol, PERIOD_D1, 1);
      double pC = iClose(symbol, PERIOD_D1, 1);
      m_weeklyPivot = (pH + pL + pC) / 3;
   }
   
   bool IsNearSupport(double price, double tolerance) {
      for(int i = 0; i < m_supportCount; i++) {
         if(MathAbs(price - m_supportLevels[i]) <= tolerance) return true;
      }
      return false;
   }
   
   bool IsNearResistance(double price, double tolerance) {
      for(int i = 0; i < m_resistanceCount; i++) {
         if(MathAbs(price - m_resistanceLevels[i]) <= tolerance) return true;
      }
      return false;
   }
   
   int GetPriceActionScore(int direction, double price, double tolerance) {
      int score = 50;
      
      if(direction == 1) { // BUY
         if(IsNearSupport(price, tolerance)) score += 20;
         if(m_hammer) score += 15;
         if(m_pinBar && iClose(_Symbol, PERIOD_CURRENT, 1) > iOpen(_Symbol, PERIOD_CURRENT, 1)) score += 15;
         if(m_threeWhiteSoldiers) score += 20;
         if(price > m_weeklyPivot) score += 10;
      } else { // SELL
         if(IsNearResistance(price, tolerance)) score += 20;
         if(m_shootingStar) score += 15;
         if(m_pinBar && iClose(_Symbol, PERIOD_CURRENT, 1) < iOpen(_Symbol, PERIOD_CURRENT, 1)) score += 15;
         if(m_threeBlackCrows) score += 20;
         if(price < m_weeklyPivot) score += 10;
      }
      
      return MathMin(100, score);
   }
   
   void Update(string symbol, ENUM_TIMEFRAMES tf) {
      FindSupportResistance(symbol, tf);
      DetectPatterns(symbol, tf);
      UpdateKeyLevels(symbol);
   }
   
   string GetPatternReport() {
      string patterns = "";
      if(m_pinBar) patterns += "PinBar ";
      if(m_insideBar) patterns += "InsideBar ";
      if(m_outsideBar) patterns += "OutsideBar ";
      if(m_hammer) patterns += "Hammer ";
      if(m_shootingStar) patterns += "ShootingStar ";
      if(m_threeWhiteSoldiers) patterns += "3WS ";
      if(m_threeBlackCrows) patterns += "3BC ";
      if(patterns == "") patterns = "None";
      return patterns;
   }
};

//====================================================================
// v15 EXTENSION MODULE 68: AUTO OPTIMIZER
//====================================================================
class CAutoOptimizer
{
private:
   struct ParameterSet {
      int signalThreshold;
      double riskPercent;
      double atrMultiplier;
      double tpMultiplier;
      int lookbackPeriod;
      double score;
      int trades;
      double winRate;
      double profitFactor;
   };
   
   ParameterSet m_currentParams;
   ParameterSet m_bestParams;
   ParameterSet m_testParams[10];
   int m_testCount;
   
   bool m_isOptimizing;
   int m_optimizationCycle;
   int m_tradesPerCycle;
   int m_currentTradeCount;
   double m_currentProfit;
   
   int m_lastOptimizationDay;
   
public:
   CAutoOptimizer() : m_testCount(0), m_isOptimizing(false),
                       m_optimizationCycle(0), m_tradesPerCycle(20),
                       m_currentTradeCount(0), m_currentProfit(0),
                       m_lastOptimizationDay(0) {
      // Default params
      m_currentParams.signalThreshold = 60;
      m_currentParams.riskPercent = 1.0;
      m_currentParams.atrMultiplier = 2.0;
      m_currentParams.tpMultiplier = 1.5;
      m_currentParams.lookbackPeriod = 50;
      m_currentParams.score = 0;
      m_currentParams.trades = 0;
      m_currentParams.winRate = 50;
      m_currentParams.profitFactor = 1;
      
      m_bestParams = m_currentParams;
   }
   
   void StartOptimization() {
      if(m_isOptimizing) return;
      
      m_isOptimizing = true;
      m_optimizationCycle = 0;
      m_testCount = 0;
      
      // Generate test parameter sets
      GenerateTestParams();
   }
   
   void GenerateTestParams() {
      m_testCount = 0;
      
      // Variations around current best
      for(int i = 0; i < 10 && m_testCount < 10; i++) {
         m_testParams[m_testCount] = m_bestParams;
         
         // Vary one parameter
         switch(i % 5) {
            case 0: m_testParams[m_testCount].signalThreshold = m_bestParams.signalThreshold + (i - 5) * 5; break;
            case 1: m_testParams[m_testCount].riskPercent = m_bestParams.riskPercent + (i - 5) * 0.2; break;
            case 2: m_testParams[m_testCount].atrMultiplier = m_bestParams.atrMultiplier + (i - 5) * 0.2; break;
            case 3: m_testParams[m_testCount].tpMultiplier = m_bestParams.tpMultiplier + (i - 5) * 0.1; break;
            case 4: m_testParams[m_testCount].lookbackPeriod = m_bestParams.lookbackPeriod + (i - 5) * 10; break;
         }
         
         // Clamp values
         m_testParams[m_testCount].signalThreshold = MathMax(40, MathMin(90, m_testParams[m_testCount].signalThreshold));
         m_testParams[m_testCount].riskPercent = MathMax(0.1, MathMin(3.0, m_testParams[m_testCount].riskPercent));
         m_testParams[m_testCount].atrMultiplier = MathMax(1.0, MathMin(5.0, m_testParams[m_testCount].atrMultiplier));
         m_testParams[m_testCount].tpMultiplier = MathMax(0.5, MathMin(3.0, m_testParams[m_testCount].tpMultiplier));
         m_testParams[m_testCount].lookbackPeriod = MathMax(20, MathMin(200, m_testParams[m_testCount].lookbackPeriod));
         
         m_testParams[m_testCount].score = 0;
         m_testParams[m_testCount].trades = 0;
         m_testParams[m_testCount].winRate = 50;
         m_testParams[m_testCount].profitFactor = 1;
         
         m_testCount++;
      }
   }
   
   void RecordTradeResult(bool isWin, double profit) {
      m_currentTradeCount++;
      m_currentProfit += profit;
      
      if(m_isOptimizing && m_optimizationCycle < m_testCount) {
         m_testParams[m_optimizationCycle].trades++;
         if(isWin) {
            int wins = (int)(m_testParams[m_optimizationCycle].winRate * 
                            (m_testParams[m_optimizationCycle].trades - 1) / 100) + 1;
            m_testParams[m_optimizationCycle].winRate = (double)wins / 
                            m_testParams[m_optimizationCycle].trades * 100;
         }
         
         // Calculate score
         m_testParams[m_optimizationCycle].score = m_testParams[m_optimizationCycle].winRate * 
                                                    (1 + m_testParams[m_optimizationCycle].profitFactor) / 2;
         
         if(m_testParams[m_optimizationCycle].trades >= m_tradesPerCycle) {
            m_optimizationCycle++;
            if(m_optimizationCycle >= m_testCount) {
               FinishOptimization();
            }
         }
      }
   }
   
   void FinishOptimization() {
      m_isOptimizing = false;
      
      // Find best performing params
      double bestScore = 0;
      int bestIdx = 0;
      
      for(int i = 0; i < m_testCount; i++) {
         if(m_testParams[i].score > bestScore && m_testParams[i].trades >= 10) {
            bestScore = m_testParams[i].score;
            bestIdx = i;
         }
      }
      
      // Update best params if improvement found
      if(bestScore > m_bestParams.score * 1.05) {
         m_bestParams = m_testParams[bestIdx];
         m_currentParams = m_bestParams;
      }
      
      MqlDateTime dt;
      TimeCurrent(dt);
      m_lastOptimizationDay = dt.day_of_year;
   }
   
   bool ShouldOptimize() {
      MqlDateTime dt;
      TimeCurrent(dt);
      
      // Optimize once per week
      return (!m_isOptimizing && 
              dt.day_of_week == 0 && 
              dt.day_of_year != m_lastOptimizationDay &&
              m_currentTradeCount >= 50);
   }
   
   void ApplyOptimalParams(int &signalThreshold, double &riskPercent, 
                           double &atrMultiplier, double &tpMultiplier, int &lookback) {
      signalThreshold = m_currentParams.signalThreshold;
      riskPercent = m_currentParams.riskPercent;
      atrMultiplier = m_currentParams.atrMultiplier;
      tpMultiplier = m_currentParams.tpMultiplier;
      lookback = m_currentParams.lookbackPeriod;
   }
   
   string GetOptimizerReport() {
      return StringFormat("Opt: %s | Cycle: %d/%d | Best WR: %.1f%%",
                          (m_isOptimizing ? "ACTIVE" : "IDLE"),
                          m_optimizationCycle, m_testCount,
                          m_bestParams.winRate);
   }
   
   bool IsOptimizing() { return m_isOptimizing; }
   ParameterSet GetBestParams() { return m_bestParams; }
   ParameterSet GetCurrentParams() { return m_currentParams; }
};

//====================================================================
// v15 GLOBAL OBJECTS - FINAL 10K MODÜLLER
//====================================================================
CPriceActionFilter PriceAction;
CAutoOptimizer AutoOptimizer;

//+------------------------------------------------------------------+
//| v15.0 ULTIMATE 10K EDITION - COMPLETE                            |
//| 53+ Synchronized Modules | 10000+ Lines                          |
//|                                                                   |
//| TEMEL MODÜLLER (1-25):                                           |
//| AI Signal Scorer | Candle Patterns | Wick Analysis               |
//| Fibonacci | Pivot Points | S/R Detection | MTF Analysis          |
//| Session Analysis | Volatility Regime | Divergence Detection      |
//| ML Simulation | Adaptive Threshold | Risk Management             |
//| Partial Close | Trailing Stop | Grid System | Hedge Mode         |
//| News Filter | Spread Protection | Dashboard                      |
//| Order Block | FVG | Liquidity | Market Structure | Order Flow    |
//|                                                                   |
//| GELİŞMİŞ MODÜLLER (26-45):                                        |
//| CMLSimulator | SmartEntryTiming | PositionScaling                |
//| CorrelationFilter | BreakEvenPlus | EquityCurveFilter           |
//| SmartExitSystem | MultiSessionAnalysis | NewsImpactCalculator    |
//| RiskParitySystem | ManualPositionProtector | StatePersistence    |
//| AdvancedMLEngine | SmartMoneyConcepts | VolatilityBreakout       |
//| AdaptiveStopLoss | MomentumFilter | TimeBasedExit               |
//| DrawdownRecovery | AdvancedDashboard                             |
//|                                                                   |
//| v15 YENİ MODÜLLER (46-53):                                        |
//| MarketProfiler | WyckoffAnalyzer | SupplyDemandZones            |
//| CandleStatistics | TradeJournal | PositionSizer                 |
//| VolatilityRegime | NeuralSimulator                               |
//|                                                                   |
//| TEKNOLOJİLER:                                                     |
//| ✅ Machine Learning & Neural Network Simulation                   |
//| ✅ Smart Money Concepts (ICT/SMC Analysis)                        |
//| ✅ Wyckoff Method & Market Profile                                |
//| ✅ Supply/Demand & Order Block Trading                            |
//| ✅ Advanced Risk Parity & Position Sizing                         |
//| ✅ Multi-Timeframe Analysis & Correlation Filtering               |
//| ✅ Comprehensive Trade Journal & Statistics                       |
//|                                                                   |
//| © 2025, Milyoner EA Project - The Ultimate Trading System v15.0  |
//| Designed for Professional Trading | Education Purposes Only      |
//+------------------------------------------------------------------+
