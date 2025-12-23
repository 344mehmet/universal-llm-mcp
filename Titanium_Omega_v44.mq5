//+------------------------------------------------------------------+
//|                                     Titanium_Omega_v44.mq5       |
//|                     © 2025, Systemic Trading Engineering         |
//|  Versiyon: 44.0 (NATIVE MA MASTER - STABLE RELEASE)             |
//+------------------------------------------------------------------+
#property copyright "© 2025, Systemic Trading Engineering"
#property version   "44.00"
#property strict

#include <Trade\Trade.mqh>

//--- ENUMS
enum ENUM_MARKET_REGIME {
   REGIME_HIGH_VOLATILITY, // Yüksek Volatilite (Bekle)
   REGIME_TRENDING,        // Trend (İşlem Yap)
   REGIME_RANGING          // Yatay (Dikkatli Ol)
};

enum ENUM_STRATEGY_MODE {
   STRATEGY_FRACTAL_REVERSAL, // Mevcut: Dönüş Yakalama (Sniper)
   STRATEGY_HMA_CROSS,        // HMA Cross: Trend Takip
   STRATEGY_AMA_CROSS,        // v30: AMA Cross
   STRATEGY_MA_MASTER         // v42: Native MA Master (SMA+EMA)
};

// v35: Emir Tipi Seçimi
enum ENUM_ORDER_TYPE_MODE {
   ORDER_MODE_MARKET,         // Anında Market Emri
   ORDER_MODE_STOP,           // Bekleyen Stop Emir (BuyStop/SellStop)
   ORDER_MODE_LIMIT           // Bekleyen Limit Emir (BuyLimit/SellLimit)
};

//--- INPUTS
//--- 1. ANA AYARLAR
input group "=== 1. MAIN SETTINGS ==="
input ulong    InpMagic           = 123456;    // Magic Number
input string   InpComment         = "Titanium Omega v42"; // İşlem Yorumu
input bool     InpShowDashboard   = true;      // Bilgi Paneli Göster
input ENUM_STRATEGY_MODE InpStrategyMode = STRATEGY_MA_MASTER; // v42: MA MASTER VARSAYILAN
input bool     InpStrictInitChecks = true;  // Sıkı Başlangıç Kontrolleri (Safety)

//--- 2. RİSK VE SERMAYE YÖNETİMİ
input group "=== 2. RISK & CAPITAL ==="
input double   InpBaseRiskPercent = 1.0;      // Baz Risk %
input double   InpMaxDailyLoss    = 30.0;     // Günlük Max Zarar %
input double   InpMaxMoneyDD      = 5.0;      // Günlük Max Zarar $
input double   InpMinMarginLevel  = 50.0;     // Min Marjin Seviyesi %
input bool     InpDetectDeposit   = true;     // Para Yatırma/Çekme Algıla
input bool     InpMultiOrder      = true;     // Çoklu Emir Aç
input int      InpMaxOpenOrders   = 5;        // Max Açık Emir Sayısı
input bool     InpCancelOnReverse = true;     // Yön Değişince Bekleyenleri Sil
input bool     InpAllowHedging    = true;     // Hedging İzni (Ters Yön)

//--- 3. GRID MATRIX (v40: SCALPING)
input group "=== 3. GRID MATRIX (v40 SCALPING) ==="
input double   InpFixedLot        = 0.01;     // v40: Sabit Lot (Mikro)
input int      InpMaxOrders       = 1;        // Max Basamak Sayısı
input int      InpStepPips        = 10;       // Adım Aralığı / Stop Offset (Pips)
input int      InpSL_Pips         = 20;       // v40: Stop Loss (Pips) - Scalping
input int      InpTP_Pips         = 25;       // v40: Take Profit (Pips) - Quick Exit  
input int      InpExpirationHrs   = 4;        // Bekleyen Emir Ömrü (Saat)

//--- 4. STRATEJİ MOTORU
input group "=== 4. STRATEGY ENGINE ==="
input ENUM_TIMEFRAMES HigherTF    = PERIOD_M15; // MTF Onayı
input int      MainTrend_MA       = 200;       // Ana Trend Filtresi (HMA)
input int      InpHMA_Fast        = 20;        // HMA Cross Hızlı
input int      InpHMA_Slow        = 50;        // HMA Cross Yavaş
input int      Regime_Lookback    = 50;        // Volatilite Lookback
input double   Vol_Explosion_Mul  = 1.8;       // Volatilite Patlama Çarpanı

//--- 5. AMA AYARLARI (v30)
input group "=== 5. AMA SETTINGS (v30) ==="
input int      InpAMA_Period      = 50;        // AMA Periyodu
input int      InpAMA_Fast        = 5;         // AMA Hızlı
input int      InpAMA_Slow        = 100;       // AMA Yavaş

//--- 6. GÜVENLİK VE STRES TESTİ
input group "=== 6. SAFETY & STRESS ==="
input int      InpMaxSpreadPips   = 6;        // Max Spread
input bool     InpUseTimeFilter   = false;    // Zaman Filtresi
input int      InpStartHour       = 8;        // Başlangıç Saati
input int      InpEndHour         = 20;       // Bitiş Saati
input bool     StressTest_Mode    = false;    // Stres Testi
input int      Simulated_Slippage = 10;       // Kayma (Points)

//--- 7. OPERASYONEL (v40: SCALPING OPTIMIZED)
input group "=== 7. OPS & MANAGEMENT (v40) ==="
input bool     InpUseBreakeven    = true;     // v40: Tight Breakeven - 10 pips
input bool     InpUseTrailing     = true;     // Trailing Stop Kullan
input int      InpTrailingStart   = 10;       // Trailing Başlangıç (Pips)
input int      InpTrailingStep    = 5;        // Trailing Adım (Pips)
input bool     InpUseSmartPartial = true;     // Akıllı Kısmi Kapama
input bool     InpManageManual    = true;     // Manuel İşlemleri de Yönet

//--- 8. AI & HABER
input group "=== 7. AI & NEWS FILTER ==="
input bool     InpUseNewsFilter   = true;     // Haber Filtresi (Ekonomik Takvim)
input int      InpNewsPauseMins   = 60;       // Haber Öncesi/Sonrası Bekleme (Dk)
input bool     InpUseDynamicLot   = true;     // Dinamik Lot (ATR Bazlı)
input bool     InpUsePerformance  = true;     // Performans Analizi (Basit ML)
input int      InpMaxLoseStreak   = 3;        // Üst Üste Max Zarar (Duraklatma İçin)

//--- 8. RULE ENFORCER (GÜVENLİK v24)
input group "=== 8. TANK SECURITY (v24) ==="
input int      InpMaxTradesPerDay      = 0;        // Günlük Maks İşlem (v29: 0 = SINIRSIZ)
input int      InpMinRequestIntervalMs = 100;      // Emirler Arası Bekleme (Anti-Spam, ms)
//--- 8. MA MASTER SETTINGS (v42)
input group "=== 8. MA MASTER SETTINGS (v42) ==="
input int      InpTrend_SMA        = 200;      // Ana Trend SMA (Filitre)
input int      InpPullback_SMA     = 50;       // Pullback/Destek SMA (Ekleme)
input int      InpSignal_EMA_Fast  = 8;        // Sinyal Hızlı EMA
input int      InpSignal_EMA_Slow  = 21;       // Sinyal Yavaş EMA
input bool     InpPyramiding       = true;     // Kazanan Trende Ekleme Yap
input int      InpPyramidStepPips  = 20;       // Ekleme Adımı (Pips)

//--- 9. RULE ENFORCER (GÜVENLİK v24)
input group "=== 9. AGGRESSIVE MODE (v29) ==="
input bool     InpUseReverse       = true;      // Zarar Sonrası Yön Değiştir
input bool     InpUseScaleUp       = true;      // Kâr Sonrası Lot Artır
input double   InpScaleUpMultiplier = 1.5;      // Scale Up Çarpanı (%50 artış)
input int      InpWinStreakForScale = 2;        // Kaç Üst Üste Kâr Scale Up Tetikler

//--- 10. TEST & DEBUG
input group "=== 10. TEST & DEBUG (v37) ==="
input bool     InpAutoTestTrade        = true;      // v37: Başlatırken Otomatik Test İşlemi Aç
input bool     InpTestMode             = true;      // v37: Test Modu (Hızlı İşlem)
input bool     InpRelaxChecks          = true;      // v37: Tester'da Kontrolleri Gevşet
input bool     InpForceShowDashboard   = true;     // Dashboard'ı Her Zaman Göster

//--- 11. HESAP KURTARMA (v27)
input group "=== 11. RECOVERY MODE (v27) ==="
input bool     InpUseRecovery      = true;      // Kurtarma Modu
input double   InpRecoveryTrigger  = 20.0;      // Kurtarma Tetikleme (% Zarar)
input double   InpRecoveryTarget   = 10.0;      // Kurtarma Hedefi (% Geri Kazanım)
input double   InpRecoveryLotMul   = 0.5;       // Kurtarma Lot Çarpanı

//--- 12. FON YÖNETİMİ (v27)
input group "=== 12. FUND MANAGEMENT (v27) ==="
input double   InpDailyProfitTarget   = 0;      // Günlük Kâr Hedefi $ (0=Kapalı)
input double   InpWeeklyProfitTarget  = 0;      // Haftalık Kâr Hedefi $
input bool     InpPauseOnTarget       = true;   // Hedefe Ulaşınca Durdur

//--- 13. GELİŞMİŞ RİSK YÖNETİMİ (v31 - KARLILIK)
input group "=== 13. ADVANCED RISK (v31) ==="
input bool     InpUseRiskBasedLot  = true;      // Risk % Bazlı Lot Hesapla
input double   InpRiskPerTrade     = 1.0;       // İşlem Başı Risk %
input bool     InpUseATRStops      = true;      // ATR Bazlı SL/TP
input int      InpATRPeriod        = 14;        // ATR Periyodu
input double   InpATRMultiplierSL  = 2.0;       // Stop Loss ATR Çarpanı
input double   InpATRMultiplierTP  = 3.0;       // Take Profit ATR Çarpanı
input double   InpMinRiskReward    = 2.0;       // Minimum Risk/Reward Oranı
input double   InpMaxDrawdownStop  = 30.0;      // Emergency Stop Drawdown %
input int      InpCooldownMinutes  = 60;        // Drawdown Sonrası Bekleme (dk)

//--- 14. KONSENSÜS SİNYALLERİ (v31 - KOLAY SİNYAL)
input group "=== 14. TRIPLE MA SIGNALS (v31) ==="
input bool     InpUseConsensus     = true;      // Konsensüs Sinyali Kullan
input int      InpMA_Fast          = 10;        // Hızlı MA Periyot (Scalp)
input int      InpMA_Medium        = 20;        // Orta MA Periyot (Trend)
input int      InpMA_Slow          = 50;        // Yavaş MA Periyot (Ana Trend)
input ENUM_MA_METHOD InpMA_Method  = MODE_EMA;  // MA Tipi (EMA/SMA)
input bool     InpRequireAlignment = true;      // Tam Hizalama Gerekli (Fast>Med>Slow)
//--- 16. GELİŞMİŞ EMİR TİPLERİ (v35)
input group "=== 16. ADVANCED ORDER TYPES (v35) ==="
input ENUM_ORDER_TYPE_MODE InpOrderMode = ORDER_MODE_STOP;   // Emir Tipi (STOP = Breakout)
input int      InpLimitOffset      = 10;        // Limit Emir Mesafesi (Pips)
input bool     InpUseDynamicLimitOffset = true; // Limit Offset ATR Bazlı
input double   InpSmartPartialPercent = 50.0;  // Kısmi Kapama Oranı %
input double   InpSmartPartialLevel = 50.0;    // Kısmi Kapama Seviyesi (TP %)

// GLOBAL KONTROL DEĞİŞKENLERİ
string g_StateReason = "Başlatılıyor...";
int    g_tradesTodayCount = 0;
datetime g_today_start = 0;
long   g_lastTradeOperationTime = 0;

// v27 - Recovery & Fund Management Global Değişkenleri
bool   g_recoveryMode = false;           // Kurtarma modu aktif mi?
double g_recoveryStartBalance = 0;       // Kurtarma başlangıç bakiyesi
double g_weeklyStartBalance = 0;         // Haftalık başlangıç bakiyesi
datetime g_weekStart = 0;                // Hafta başlangıcı
int    g_totalWins = 0;                  // Toplam kazanılan işlem
int    g_totalLosses = 0;                // Toplam kaybedilen işlem

// v29 - Agresif Strateji Global Değişkenleri
int    g_consecutiveWins = 0;            // Üst üste kazanılan işlem
int    g_consecutiveLosses = 0;          // Üst üste kaybedilen işlem
int    g_lastTradeDirection = 0;         // Son işlem yönü (1=Buy, -1=Sell)
double g_currentLotMultiplier = 1.0;     // Mevcut lot çarpanı

// v31 - KARLILIK Global Değişkenleri
datetime g_cooldownUntil = 0;            // Drawdown sonrası bekleme süresi
double g_grossProfit = 0;                // Toplam brüt kâr
double g_grossLoss = 0;                  // Toplam brüt zarar
double g_maxDrawdownReached = 0;         // Ulaşılan maksimum drawdown
double g_peakEquity = 0;                 // En yüksek equity
double g_profitHistory[];                // Son işlem kârları (Sharpe için)
int    g_profitHistoryIndex = 0;         // Kâr geçmişi indeksi

//====================================================================
// CLASS: PRICE ENGINE
//====================================================================
class CPriceEngine
{
public:
   static double PipToPoints(int pips)
   {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      return pips * 10.0 * point;
   }

   // Broker StopLevel Kontrolü
   static bool CheckStopLevel(double entry, double sl, double tp, int direction)
   {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      long stopLevelPts = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
      double stopLevel = (double)stopLevelPts * point;
      
      if(stopLevel == 0) 
         stopLevel = (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD) * point;
      
      double safeDist = 10 * point; // Güvenlik payı

      if(direction == 1) // BUY
         return (sl < entry - safeDist) && (tp > entry + safeDist) && 
                (entry - sl >= stopLevel) && (tp - entry >= stopLevel);
      else if(direction == -1) // SELL
         return (sl > entry + safeDist) && (tp < entry - safeDist) && 
                (sl - entry >= stopLevel) && (entry - tp >= stopLevel);
      
      return false;
   }
   
   // --- ANTI-SPAM (v24) ---
   static void EnforceRequestInterval()
   {
      if (InpMinRequestIntervalMs <= 0) return;

      long current_tick_count = GetTickCount();
      long elapsed = current_tick_count - g_lastTradeOperationTime;

      if (elapsed < InpMinRequestIntervalMs)
      {
         long time_to_sleep = InpMinRequestIntervalMs - elapsed;
         if (time_to_sleep > 0) Sleep((int)time_to_sleep);
      }
      g_lastTradeOperationTime = GetTickCount(); // Süreç sıfırlandı
   }
};

//====================================================================
// CLASS: SECURITY MANAGER
//====================================================================
class CSecurityManager
{
private:
   double            m_refBalance;
   double            m_lastKnownBalance;
   ulong             m_lastProcessedTicket; // v42: Sonsuz döngü engelleme
   int               m_dayOfYear;

public:
   CSecurityManager() : m_refBalance(0), m_lastKnownBalance(0), m_lastProcessedTicket(0), m_dayOfYear(-1) {}

   void Init() { UpdateReference(true); }

   void UpdateReference(bool forceReset = false)
   {
      MqlDateTime dt; 
      TimeCurrent(dt);
      if(forceReset || dt.day_of_year != m_dayOfYear)
      {
         m_dayOfYear = dt.day_of_year;
         m_refBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         m_lastKnownBalance = m_refBalance;
         Print("GÜNLÜK REFERANS GÜNCELLENDİ: ", m_refBalance);
      }
   }

   bool IsSafeToTrade()
   {
      UpdateReference();

      // Para Transferi Algılama
      double currentBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      if(InpDetectDeposit && MathAbs(currentBalance - m_lastKnownBalance) > 0.001)
      {
         if(PositionsTotal() == 0) 
         {
            m_refBalance += (currentBalance - m_lastKnownBalance);
            Print("PARA TRANSFERİ ALGILANDI. Referans güncellendi.");
         }
         m_lastKnownBalance = currentBalance;
      }

      // Günlük Zarar Kontrolü
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double loss = m_refBalance - equity;
      
      if(loss >= InpMaxMoneyDD || (m_refBalance > 0 && (loss/m_refBalance)*100.0 >= InpMaxDailyLoss))
      {
         g_StateReason = "GÜNLÜK ZARAR LİMİTİ DOLDU";
         return false;
      }

      // Marjin ve Sembol Kontrolü
      double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
      if(marginLevel > 0 && marginLevel < InpMinMarginLevel) 
      {
         g_StateReason = "DÜŞÜK MARJİN: %" + DoubleToString(marginLevel, 1);
         return false;
      }
      
      if(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL) 
      {
         g_StateReason = "SEMBOL İŞLEME KAPALI";
         return false;
      }

      // Zaman Filtresi
      if(InpUseTimeFilter)
      {
         MqlDateTime dt; 
         TimeCurrent(dt);
         if(dt.hour < InpStartHour || dt.hour >= InpEndHour) 
         {
            g_StateReason = "ZAMAN FİLTRESİ: " + IntegerToString(dt.hour) + ":00";
            return false;
         }
      }
      
      // Spread Kontrolü
      long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      double spreadPips = spread * point / CPriceEngine::PipToPoints(1);
      
      if(spreadPips > InpMaxSpreadPips)
      {
          g_StateReason = "YÜKSEK SPREAD: " + DoubleToString(spreadPips, 1);
          return false;
      }

      return true;
   }
     
   double GetDailyPL() 
   { 
      return AccountInfoDouble(ACCOUNT_EQUITY) - m_refBalance; 
   }
   
   // --- v29: AGRESİF PERFORMANS ANALİZİ ---
   // Artık durdurmak yerine: Zarar = Yön Değiştir, Kâr = Lot Artır
   void UpdateStreak()
   {
      HistorySelect(0, TimeCurrent());
      int total = HistoryDealsTotal();
      if(total == 0) return;
      
      // Son kapanan işlemi bul
      for(int i = total - 1; i >= 0; i--)
      {
         ulong ticket = HistoryDealGetTicket(i);
         // v42: Zaten işlenmiş bileti tekrar sayma
         if(ticket <= m_lastProcessedTicket) continue;
         
         if(ticket > 0 && HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
         {
            m_lastProcessedTicket = ticket; // Bileti işaretle
            
            double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
            long dealType = HistoryDealGetInteger(ticket, DEAL_TYPE);
            
            // Son işlem yönünü kaydet
            if(dealType == DEAL_TYPE_BUY)
               g_lastTradeDirection = 1;
            else if(dealType == DEAL_TYPE_SELL)
               g_lastTradeDirection = -1;
            
            if(profit > 0)
            {
               g_consecutiveWins++;
               g_consecutiveLosses = 0;
               g_totalWins++;
               
               // Scale Up kontrolü
               if(InpUseScaleUp && g_consecutiveWins >= InpWinStreakForScale)
               {
                  g_currentLotMultiplier = InpScaleUpMultiplier;
                  Print("📈 ", g_consecutiveWins, " ÜSTTE ÜST KÂR! Lot çarpanı: ", g_currentLotMultiplier);
               }
            }
            else if(profit < 0)
            {
               g_consecutiveLosses++;
               g_consecutiveWins = 0;
               g_totalLosses++;
               g_currentLotMultiplier = 1.0; // Zarar sonrası normale dön
               
               Print("⚠️ ZARAR! Üst üste: ", g_consecutiveLosses);
            }
            
            break; // Sadece son işlemi kontrol et
         }
      }
   }
   
   // Reverse Trading: Zarar sonrası ters yön sinyali
   int GetReverseSignal()
   {
      if(!InpUseReverse) return 0;
      if(g_consecutiveLosses == 0) return 0;
      if(g_lastTradeDirection == 0) return 0;
      
      // Zarar sonrası ters yön
      int reverseDir = -g_lastTradeDirection;
      Print("🔄 REVERSE SİNYAL! Son yön: ", (g_lastTradeDirection == 1 ? "BUY" : "SELL"), 
            " -> Yeni yön: ", (reverseDir == 1 ? "BUY" : "SELL"));
      
      g_StateReason = "REVERSE TRADING (Zarar Sonrası)";
      return reverseDir;
   }
   
   // Scale Up: Lot çarpanını döndür
   double GetScaledLot(double baseLot)
   {
      double scaledLot = baseLot * g_currentLotMultiplier;
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      
      // Lot sınırlarını uygula
      scaledLot = MathMax(minLot, MathMin(scaledLot, maxLot));
      scaledLot = MathFloor(scaledLot / lotStep) * lotStep;
      
      return scaledLot;
   }
   
   // v29: CheckPerformance artık durdurmak yerine true döndürüyor
   bool CheckPerformance()
   {
      // Her zaman true döndür - durdurmak yok!
      // UpdateStreak OnTick'te çağrılacak
      return true;
   }
};

// Extra brace removed
// DUPLICATE CLASSES REMOVED (Lines 438-844 deleted)
// The correct classes are defined later in the file (lines 1560+)

// DUPLICATE CLASSES REMOVED (Lines 442-861 deleted)
// The correct classes CRiskManager, CConsensusEngine, CHedgingManager are defined later.

//====================================================================
// CLASS: NEWS MANAGER
//====================================================================
// #include <Calendar\Calendar.mqh> // Kaldırıldı: Built-in kullanılıyor

class CNewsManager
{
public:
   bool IsNewsTime()
   {
      if(!InpUseNewsFilter) return false;
      
      MqlCalendarValue values[];
      datetime start = TimeCurrent() - (InpNewsPauseMins * 60);
      datetime end   = TimeCurrent() + (InpNewsPauseMins * 60);
      
      // USD Haberleri
      if(CalendarValueHistory(values, start, end, "USD", NULL) > 0)
      {
         for(int i=0; i<ArraySize(values); i++)
         {
            MqlCalendarEvent event;
            if(CalendarEventById(values[i].event_id, event))
            {
               if(event.importance == CALENDAR_IMPORTANCE_HIGH)
               {
                  g_StateReason = "HABER FİLTRESİ (USD)";
                  return true;
               }
            }
         }
      }
      
      // EUR Haberleri
      if(CalendarValueHistory(values, start, end, "EUR", NULL) > 0)
      {
         for(int i=0; i<ArraySize(values); i++)
         {
            MqlCalendarEvent event;
            if(CalendarEventById(values[i].event_id, event))
            {
               if(event.importance == CALENDAR_IMPORTANCE_HIGH)
               {
                  g_StateReason = "HABER FİLTRESİ (EUR)";
                  return true;
               }
            }
         }
      }
      
      return false;
   }
};

//====================================================================
// CLASS: RECOVERY MANAGER (v27) - Hesap Kurtarma
//====================================================================
class CRecoveryManager
{
private:
   double m_peakBalance;        // En yüksek bakiye
   double m_triggerBalance;     // Kurtarma tetiklendiğindeki bakiye
   
public:
   void Init()
   {
      m_peakBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      m_triggerBalance = 0;
      g_recoveryMode = false;
      Print("🛡️ Recovery Manager başlatıldı. Peak: ", m_peakBalance);
   }
   
   void Update()
   {
      if(!InpUseRecovery) return;
      
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      
      // Peak bakiyeyi güncelle
      if(balance > m_peakBalance)
      {
         m_peakBalance = balance;
         
         // Kurtarma modundayken hedefe ulaştıysa çık
         if(g_recoveryMode)
         {
            double recovered = ((balance - g_recoveryStartBalance) / g_recoveryStartBalance) * 100.0;
            if(recovered >= InpRecoveryTarget)
            {
               g_recoveryMode = false;
               Print("✅ KURTARMA BAŞARILI! Geri kazanım: %", DoubleToString(recovered, 1));
            }
         }
      }
      
      // Kurtarma moduna giriş kontrolü
      if(!g_recoveryMode && m_peakBalance > 0)
      {
         double drawdown = ((m_peakBalance - balance) / m_peakBalance) * 100.0;
         if(drawdown >= InpRecoveryTrigger)
         {
            g_recoveryMode = true;
            g_recoveryStartBalance = balance;
            Print("⚠️ KURTARMA MODU AKTİF! Drawdown: %", DoubleToString(drawdown, 1));
         }
      }
   }
   
   bool IsRecoveryMode() { return g_recoveryMode; }
   
   double GetLotMultiplier()
   {
      return g_recoveryMode ? InpRecoveryLotMul : 1.0;
   }
   
   double GetDrawdownPercent()
   {
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      if(m_peakBalance > 0)
         return ((m_peakBalance - balance) / m_peakBalance) * 100.0;
      return 0;
   }
};

//====================================================================
// CLASS: FUND MANAGER (v27) - Fon Yönetimi
//====================================================================
class CFundManager
{
private:
   double m_dailyStartBalance;
   int    m_lastDayOfYear;
   
public:
   void Init()
   {
      m_dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
      g_weeklyStartBalance = m_dailyStartBalance;
      
      MqlDateTime dt;
      TimeCurrent(dt);
      m_lastDayOfYear = dt.day_of_year;
      g_weekStart = TimeCurrent();
      
      // İşlem istatistiklerini sıfırla
      g_totalWins = 0;
      g_totalLosses = 0;
      
      Print("💰 Fund Manager başlatıldı. Başlangıç: ", m_dailyStartBalance);
   }
   
   void Update()
   {
      MqlDateTime dt;
      TimeCurrent(dt);
      
      // Yeni gün kontrolü
      if(dt.day_of_year != m_lastDayOfYear)
      {
         m_lastDayOfYear = dt.day_of_year;
         m_dailyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         Print("📅 Yeni gün! Günlük başlangıç güncellendi: ", m_dailyStartBalance);
      }
      
      // Yeni hafta kontrolü (Pazartesi)
      if(dt.day_of_week == 1 && TimeCurrent() - g_weekStart > 86400)
      {
         g_weekStart = TimeCurrent();
         g_weeklyStartBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         Print("📆 Yeni hafta! Haftalık başlangıç güncellendi: ", g_weeklyStartBalance);
      }
   }
   
   double GetDailyProfit()
   {
      return AccountInfoDouble(ACCOUNT_BALANCE) - m_dailyStartBalance;
   }
   
   double GetWeeklyProfit()
   {
      return AccountInfoDouble(ACCOUNT_BALANCE) - g_weeklyStartBalance;
   }
   
   bool IsDailyTargetReached()
   {
      if(InpDailyProfitTarget <= 0) return false;
      return GetDailyProfit() >= InpDailyProfitTarget;
   }
   
   bool IsWeeklyTargetReached()
   {
      if(InpWeeklyProfitTarget <= 0) return false;
      return GetWeeklyProfit() >= InpWeeklyProfitTarget;
   }
   
   bool ShouldPauseTrading()
   {
      if(!InpPauseOnTarget) return false;
      
      if(IsDailyTargetReached())
      {
         g_StateReason = "GÜNLÜK HEDEF DOLDU: $" + DoubleToString(GetDailyProfit(), 2);
         return true;
      }
      
      if(IsWeeklyTargetReached())
      {
         g_StateReason = "HAFTALIK HEDEF DOLDU: $" + DoubleToString(GetWeeklyProfit(), 2);
         return true;
      }
      
      return false;
   }
   
   double GetWinRate()
   {
      int total = g_totalWins + g_totalLosses;
      if(total == 0) return 0;
      return (double)g_totalWins / total * 100.0;
   }
   
   void RecordTrade(double profit)
   {
      if(profit > 0) g_totalWins++;
      else if(profit < 0) g_totalLosses++;
   }
};

//====================================================================
// CLASS: SIGNAL ENGINE
//====================================================================
class CSignalEngine
{
private:
   int               m_hFrac;
   int               m_hBands;
   int               m_hADX;
   
   // HMA İçin Gerekli Handle'lar
   int               m_hWMA_Half; // WMA(n/2)
   int               m_hWMA_Full; // WMA(n)
   int               m_hmaPeriod;
   
   // HMA Cross Handle'ları (Mod 2)
   int               m_hHMA_Fast_Half;
   int               m_hHMA_Fast_Full;
   int               m_hHMA_Slow_Half;
   int               m_hHMA_Slow_Full;
   
   // v30: AMA Handle
   int               m_hAMA;
   
   // v42: MA Master Handles (Native)
   int               m_hSMA_Trend;     // 200 SMA
   int               m_hSMA_Pullback;  // 50 SMA
   int               m_hEMA_Fast;      // 8 EMA
   int               m_hEMA_Slow;      // 21 EMA

   datetime          m_lastSignalTime; // Son sinyal zamanı

public:
   CSignalEngine() : m_lastSignalTime(0) {}

   void ReleaseHandles()
   {
      IndicatorRelease(m_hFrac);
      IndicatorRelease(m_hBands);
      IndicatorRelease(m_hADX);
      IndicatorRelease(m_hWMA_Half);
      IndicatorRelease(m_hWMA_Full);
      if(m_hHMA_Fast_Half != INVALID_HANDLE) IndicatorRelease(m_hHMA_Fast_Half);
      if(m_hHMA_Fast_Full != INVALID_HANDLE) IndicatorRelease(m_hHMA_Fast_Full);
      if(m_hHMA_Slow_Half != INVALID_HANDLE) IndicatorRelease(m_hHMA_Slow_Half);
      if(m_hHMA_Slow_Full != INVALID_HANDLE) IndicatorRelease(m_hHMA_Slow_Full);
      if(m_hAMA != INVALID_HANDLE) IndicatorRelease(m_hAMA);
      // v42 Handles
      if(m_hSMA_Trend != INVALID_HANDLE) IndicatorRelease(m_hSMA_Trend);
      if(m_hSMA_Pullback != INVALID_HANDLE) IndicatorRelease(m_hSMA_Pullback);
      if(m_hEMA_Fast != INVALID_HANDLE) IndicatorRelease(m_hEMA_Fast);
      if(m_hEMA_Slow != INVALID_HANDLE) IndicatorRelease(m_hEMA_Slow);
   }

   bool Init()
   {
      ReleaseHandles();
      
      m_hFrac    = iFractals(_Symbol, PERIOD_CURRENT);
      m_hBands   = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
      m_hADX     = iADX(_Symbol, PERIOD_CURRENT, 14);
      
      // HMA Hazırlığı: HMA = WMA( 2*WMA(n/2) - WMA(n) ) , sqrt(n)
      m_hmaPeriod = MainTrend_MA;
      m_hWMA_Half = iMA(_Symbol, HigherTF, m_hmaPeriod / 2, 0, MODE_LWMA, PRICE_CLOSE);
      m_hWMA_Full = iMA(_Symbol, HigherTF, m_hmaPeriod, 0, MODE_LWMA, PRICE_CLOSE);
      
      // HMA Cross Hazırlığı (Mod 2)
      if(InpStrategyMode == STRATEGY_HMA_CROSS)
      {
         m_hHMA_Fast_Half = iMA(_Symbol, PERIOD_CURRENT, InpHMA_Fast / 2, 0, MODE_LWMA, PRICE_CLOSE);
         m_hHMA_Fast_Full = iMA(_Symbol, PERIOD_CURRENT, InpHMA_Fast, 0, MODE_LWMA, PRICE_CLOSE);
         m_hHMA_Slow_Half = iMA(_Symbol, PERIOD_CURRENT, InpHMA_Slow / 2, 0, MODE_LWMA, PRICE_CLOSE);
         m_hHMA_Slow_Full = iMA(_Symbol, PERIOD_CURRENT, InpHMA_Slow, 0, MODE_LWMA, PRICE_CLOSE);
      }
      
      // v30: AMA Hazırlığı
      if(InpStrategyMode == STRATEGY_AMA_CROSS)
      {
         m_hAMA = iAMA(_Symbol, PERIOD_CURRENT, InpAMA_Period, InpAMA_Fast, InpAMA_Slow, 0, PRICE_CLOSE);
         if(m_hAMA == INVALID_HANDLE)
         {
            Print("❌ v30: AMA göstergesi yüklenemedi!");
            return false;
         }
         Print("✅ v30: AMA göstergesi yüklendi. Periyot: ", InpAMA_Period, " Hızlı: ", InpAMA_Fast, " Yavaş: ", InpAMA_Slow);
      }
      
      // v42: MA Master Init
      if(InpStrategyMode == STRATEGY_MA_MASTER)
      {
         m_hSMA_Trend = iMA(_Symbol, PERIOD_CURRENT, InpTrend_SMA, 0, MODE_SMA, PRICE_CLOSE);
         m_hSMA_Pullback = iMA(_Symbol, PERIOD_CURRENT, InpPullback_SMA, 0, MODE_SMA, PRICE_CLOSE);
         m_hEMA_Fast = iMA(_Symbol, PERIOD_CURRENT, InpSignal_EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
         m_hEMA_Slow = iMA(_Symbol, PERIOD_CURRENT, InpSignal_EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);
         
         if(m_hSMA_Trend == INVALID_HANDLE || m_hEMA_Fast == INVALID_HANDLE || m_hEMA_Slow == INVALID_HANDLE)
         {
            Print("❌ v42: MA Master göstergeleri yüklenemedi!");
            return false;
         }
         Print("✅ v42: MA Master (Native) yüklendi.");
         // v42 tek başına yeterli
         return true;
      }

      bool allValid = (m_hFrac != INVALID_HANDLE) && 
                      (m_hBands != INVALID_HANDLE) && 
                      (m_hADX != INVALID_HANDLE) && 
                      (m_hWMA_Half != INVALID_HANDLE) &&
                      (m_hWMA_Full != INVALID_HANDLE);
      
      if(InpStrategyMode == STRATEGY_HMA_CROSS)
      {
         allValid &= (m_hHMA_Fast_Half != INVALID_HANDLE) &&
                     (m_hHMA_Fast_Full != INVALID_HANDLE) &&
                     (m_hHMA_Slow_Half != INVALID_HANDLE) &&
                     (m_hHMA_Slow_Full != INVALID_HANDLE);
      }
      
      if(InpStrategyMode == STRATEGY_AMA_CROSS)
      {
         allValid &= (m_hAMA != INVALID_HANDLE);
      }
      
      if(!allValid)
         Print("UYARI: Bazı indikatörler yüklenemedi!");
      
      return allValid;
   }

   ENUM_MARKET_REGIME GetRegime()
   {
      double upper[], lower[], adx[];
      ArraySetAsSeries(upper, true); 
      ArraySetAsSeries(lower, true); 
      ArraySetAsSeries(adx, true);
      
      if(CopyBuffer(m_hBands, 1, 0, Regime_Lookback, upper) < Regime_Lookback) 
         return REGIME_HIGH_VOLATILITY;
      if(CopyBuffer(m_hBands, 2, 0, Regime_Lookback, lower) < Regime_Lookback) 
         return REGIME_HIGH_VOLATILITY;
      if(CopyBuffer(m_hADX, 0, 0, 1, adx) < 1) 
         return REGIME_HIGH_VOLATILITY;

      double sumWidth = 0;
      for(int i = 1; i < Regime_Lookback; i++) 
         sumWidth += (upper[i] - lower[i]);
      
      double avgWidth = sumWidth / (double)(Regime_Lookback - 1);
      double curWidth = upper[0] - lower[0];

      if(avgWidth > 0 && curWidth > avgWidth * Vol_Explosion_Mul) 
         return REGIME_HIGH_VOLATILITY;
      
      if(adx[0] > 25) 
         return REGIME_TRENDING;
      
      return REGIME_RANGING;
   }

   // Genel HMA Hesaplayıcı (Parametrik)
   double CalculateHMA_Generic(int period, int hHalf, int hFull, int shift)
   {
      int sqrtPeriod = (int)MathSqrt(period);
      int lookback = sqrtPeriod + 1;
      
      double wmaHalf[], wmaFull[];
      ArraySetAsSeries(wmaHalf, true);
      ArraySetAsSeries(wmaFull, true);
      
      if(CopyBuffer(hHalf, 0, shift, lookback, wmaHalf) < lookback) return 0;
      if(CopyBuffer(hFull, 0, shift, lookback, wmaFull) < lookback) return 0;
      
      double rawHMA[];
      ArrayResize(rawHMA, lookback);
      for(int i=0; i<lookback; i++)
         rawHMA[i] = (2 * wmaHalf[i]) - wmaFull[i];
      
      double hmaVal = 0;
      double weightSum = 0;
      for(int i=0; i<sqrtPeriod; i++)
      {
         double weight = sqrtPeriod - i;
         hmaVal += rawHMA[i] * weight;
         weightSum += weight;
      }
      
      if(weightSum > 0) return hmaVal / weightSum;
      return 0;
   }

   // HMA Hesaplama Fonksiyonu (Trend Filtresi İçin)
   double CalculateHMA(int shift)
   {
      return CalculateHMA_Generic(m_hmaPeriod, m_hWMA_Half, m_hWMA_Full, shift);
   }
   
   // HMA Cross Sinyali (Mod 2) - v28: MATEMATİKSEL DETAYLI LOG
   int GetHMACrossSignal()
   {
      double fastHMA_Curr = CalculateHMA_Generic(InpHMA_Fast, m_hHMA_Fast_Half, m_hHMA_Fast_Full, 0);
      double fastHMA_Prev = CalculateHMA_Generic(InpHMA_Fast, m_hHMA_Fast_Half, m_hHMA_Fast_Full, 1);
      
      double slowHMA_Curr = CalculateHMA_Generic(InpHMA_Slow, m_hHMA_Slow_Half, m_hHMA_Slow_Full, 0);
      double slowHMA_Prev = CalculateHMA_Generic(InpHMA_Slow, m_hHMA_Slow_Half, m_hHMA_Slow_Full, 1);
      
      if(fastHMA_Curr == 0 || slowHMA_Curr == 0) 
      {
         g_StateReason = "HMA HESAPLANAMADI";
         return 0;
      }
      
      // v28 - MATEMATİKSEL HESAPLAMA LOGU
      double fark_onceki = fastHMA_Prev - slowHMA_Prev;
      double fark_simdi  = fastHMA_Curr - slowHMA_Curr;
      double price = iClose(_Symbol, PERIOD_CURRENT, 0);
      
      string mathLog = "\n+=============== HMA MATEMATİK ANALİZİ (v28) ===============+";
      mathLog += "\n| Fiyat          : " + DoubleToString(price, 5);
      mathLog += "\n| HMA Hizli(" + IntegerToString(InpHMA_Fast) + ")  : " + DoubleToString(fastHMA_Curr, 5) + " (Onceki: " + DoubleToString(fastHMA_Prev, 5) + ")";
      mathLog += "\n| HMA Yavas(" + IntegerToString(InpHMA_Slow) + ")  : " + DoubleToString(slowHMA_Curr, 5) + " (Onceki: " + DoubleToString(slowHMA_Prev, 5) + ")";
      mathLog += "\n| FARK (Hizli-Yavas):";
      mathLog += "\n|   Onceki Bar   : " + DoubleToString(fark_onceki, 5) + (fark_onceki > 0 ? " [HIZLI USTTE]" : " [YAVAS USTTE]");
      mathLog += "\n|   Simdi        : " + DoubleToString(fark_simdi, 5) + (fark_simdi > 0 ? " [HIZLI USTTE]" : " [YAVAS USTTE]");
      mathLog += "\n+----------------------------------------------------------+";
      
      // Kesişim kontrolü
      bool goldenCross = (fark_onceki < 0 && fark_simdi > 0); // Yukarı kesişim
      bool deathCross  = (fark_onceki > 0 && fark_simdi < 0); // Aşağı kesişim
      
      if(goldenCross)
      {
         mathLog += "\n| >>> GOLDEN CROSS TESPIT! ALIS SINYALI <<<";
         mathLog += "\n+=========================================================+";
         Print(mathLog);
         g_StateReason = "HMA CROSS (ALIS)";
         return 1;
      }
      
      if(deathCross)
      {
         mathLog += "\n| >>> DEATH CROSS TESPIT! SATIS SINYALI <<<";
         mathLog += "\n+=========================================================+";
         Print(mathLog);
         g_StateReason = "HMA CROSS (SATIS)";
         return -1;
      }
      
      // Kesişim yok ama durumu logla
      mathLog += "\n| SONUC: KESISIM YOK - Sinyal bekleniyor...";
      mathLog += "\n+=========================================================+";
      
      // HER YENİ BAR'da log bas (Experts sekmesine)
      static datetime lastBarTime = 0;
      datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
      if(currentBarTime != lastBarTime)
      {
         Print(mathLog);
         lastBarTime = currentBarTime;
      }
      
      g_StateReason = "HMA SINYAL BEKLENIYOR";
      return 0;
   }
   
   // v30: AMA Cross Sinyali (Makaleden: En İyi Performans)
   int GetAMACrossSignal()
   {
      MqlRates priceArray[];
      double amaArray[];
      
      ArraySetAsSeries(priceArray, true);
      ArraySetAsSeries(amaArray, true);
      
      if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 3, priceArray) < 3) return 0;
      if(CopyBuffer(m_hAMA, 0, 0, 3, amaArray) < 3) return 0;
      
      double lastClose = priceArray[1].close;
      double prevClose = priceArray[2].close;
      double amaVal = NormalizeDouble(amaArray[1], _Digits);
      double prevAmaVal = NormalizeDouble(amaArray[2], _Digits);
      double currentPrice = priceArray[0].close;
      
      // v30 - MATEMATİKSEL HESAPLAMA LOGU
      string mathLog = "\n+=============== AMA MATEMATİK ANALİZİ (v30) ===============+";
      mathLog += "\n| Fiyat Şimdi    : " + DoubleToString(currentPrice, 5);
      mathLog += "\n| Son Kapanış    : " + DoubleToString(lastClose, 5);
      mathLog += "\n| Önceki Kapanış : " + DoubleToString(prevClose, 5);
      mathLog += "\n| AMA Şimdi      : " + DoubleToString(amaVal, 5);
      mathLog += "\n| AMA Önceki     : " + DoubleToString(prevAmaVal, 5);
      mathLog += "\n+----------------------------------------------------------+";
      mathLog += "\n| Konum Şimdi    : " + (lastClose > amaVal ? "FİYAT > AMA [YUKARI]" : "FİYAT < AMA [AŞAĞI]");
      mathLog += "\n| Konum Önceki   : " + (prevClose > prevAmaVal ? "FİYAT > AMA [YUKARI]" : "FİYAT < AMA [AŞAĞI]");
      mathLog += "\n+----------------------------------------------------------+";
      
      // Crossover Kontrolü (Makaleden)
      bool buySignal = (lastClose > amaVal && prevClose < prevAmaVal);
      bool sellSignal = (lastClose < amaVal && prevClose > prevAmaVal);
      
      if(buySignal)
      {
         mathLog += "\n| >>> AMA ALIS CROSSOVER! ALIS SINYALI <<<";
         mathLog += "\n+==========================================================+";
         Print(mathLog);
         g_StateReason = "AMA CROSS (ALIŞ)";
         return 1;
      }
      
      if(sellSignal)
      {
         mathLog += "\n| >>> AMA SATIŞ CROSSOVER! SATIŞ SINYALI <<<";
         mathLog += "\n+==========================================================+";
         Print(mathLog);
         g_StateReason = "AMA CROSS (SATIŞ)";
         return -1;
      }
      
      // Kesişim yok
      mathLog += "\n| SONUC: CROSSOVER YOK - Sinyal bekleniyor...";
      mathLog += "\n+==========================================================+";
      
      // HER YENİ BAR'da log bas
      static datetime lastAMABarTime = 0;
      datetime currentBarTime = iTime(_Symbol, PERIOD_CURRENT, 0);
      if(currentBarTime != lastAMABarTime)
      {
         Print(mathLog);
         lastAMABarTime = currentBarTime;
      }
      
      g_StateReason = "AMA SINYAL BEKLENIYOR";
      return 0;
   }

   int GetDirection(ENUM_MARKET_REGIME regime)
   {
      // v42: MA Master (Native) - ÖNCELİKLİ KONTROL
      if(InpStrategyMode == STRATEGY_MA_MASTER)
      {
         return GetMAMasterSignal();
      }

      // v30: AMA Cross (En İyi Performanslı)
      if(InpStrategyMode == STRATEGY_AMA_CROSS)
      {
         return GetAMACrossSignal();
      }
      
      // Mod 2: HMA Cross
      if(InpStrategyMode == STRATEGY_HMA_CROSS)
      {
         return GetHMACrossSignal();
      }
      
      // Mod 1: Fractal Reversal (Mevcut Strateji)
      if(regime == REGIME_HIGH_VOLATILITY) 
      {
         g_StateReason = "YÜKSEK VOLATİLİTE (BEKLE)";
         return 0;
      }

      double up[], down[];
      if(CopyBuffer(m_hFrac, 0, 0, 5, up) < 5 || 
         CopyBuffer(m_hFrac, 1, 0, 5, down) < 5) 
         return 0;

      bool isDip = (down[2] != 0.0 && down[2] != EMPTY_VALUE);
      bool isTop = (up[2] != 0.0 && up[2] != EMPTY_VALUE);
      
      datetime barTime = iTime(_Symbol, PERIOD_CURRENT, 2);
      if(barTime <= m_lastSignalTime) 
      {
         g_StateReason = "SİNYAL BEKLENİYOR (FRACTAL)";
         return 0;
      }

      // Trend Filtresi Değişkenleri
      double bufMA[], bufClose[];
      ArraySetAsSeries(bufMA, true); 
      ArraySetAsSeries(bufClose, true);
      double maVal = 0;
      double price = 0;
      string trendLog = "";
      bool trendFilterPass = true;

      // Trend Filtresi (MTF)
      if(regime == REGIME_TRENDING)
      {
         if(CopyClose(_Symbol, HigherTF, 0, 1, bufClose) == 1)
         {
            maVal = CalculateHMA(0); // HMA Kullan
            price = bufClose[0];
            
            if(maVal != 0)
            {
               trendLog = "   • Trend Filtresi (HMA): Fiyat(" + DoubleToString(price, 5) + ") " + (price > maVal ? ">" : "<") + " HMA(" + DoubleToString(maVal, 5) + ") -> " + (price > maVal ? "YUKARI" : "AŞAĞI");

               if(isDip && price < maVal) 
               {
                  g_StateReason = "TREND FİLTRESİ (FİYAT < HMA)";
                  trendFilterPass = false;
               }
               if(isTop && price > maVal) 
               {
                  g_StateReason = "TREND FİLTRESİ (FİYAT > HMA)";
                  trendFilterPass = false;
               }
            }
         }
      }

      // --- SİNYAL LOGLAMA ---
      string sigLog = "📡 SİNYAL ANALİZİ (" + EnumToString(regime) + "):\n";
      sigLog += "   • Fractal Dip : " + (isDip ? "VAR" : "YOK") + "\n";
      sigLog += "   • Fractal Tepe: " + (isTop ? "VAR" : "YOK") + "\n";
      
      if(regime == REGIME_TRENDING)
      {
         sigLog += trendLog;
      }
      
      if(isDip || isTop) Print(sigLog);
      
      if(!trendFilterPass) return 0;

      if(isDip) 
      { 
         m_lastSignalTime = barTime; 
         g_StateReason = "🟢 ALIŞ SİNYALİ";
         return 1; 
      }
      if(isTop) 
      { 
         m_lastSignalTime = barTime; 
         g_StateReason = "🔴 SATIŞ SİNYALİ";
         return -1; 
      }
      
      g_StateReason = "🔎 SİNYAL ARANIYOR";
      return 0;
   }
   
   // Manuel İşlem Kontrolü İçin Trend Yönü
   int GetTrendDirection()
   {
      double hmaVal = CalculateHMA(0);
      double closePrice = iClose(_Symbol, HigherTF, 0);
      
      if(hmaVal == 0) return 0;
         
      if(closePrice > hmaVal) return 1; // Trend Yukarı
      if(closePrice < hmaVal) return -1; // Trend Aşağı
      return 0;
   }
   
   // --- v42: MA MASTER SIGNAL LOGIC ---
   int GetMAMasterSignal()
   {
      // 1. Veri Okuma
      double smaTrend[], fast[], slow[];
      ArrayResize(smaTrend, 1);
      ArrayResize(fast, 2);
      ArrayResize(slow, 2);
      
      ArraySetAsSeries(smaTrend, true);
      ArraySetAsSeries(fast, true);
      ArraySetAsSeries(slow, true);
      
      CopyBuffer(m_hSMA_Trend, 0, 0, 1, smaTrend);
      CopyBuffer(m_hEMA_Fast, 0, 0, 2, fast);
      CopyBuffer(m_hEMA_Slow, 0, 0, 2, slow);
      
      double price = iClose(_Symbol, PERIOD_CURRENT, 0);
      
      // 2. Trend Yönü (SMA 200)
      int trend = 0;
      if(price > smaTrend[0]) trend = 1;
      else if(price < smaTrend[0]) trend = -1;
      
      if(trend == 0) return 0;
      
      // 3. EMA Cross Sinyali (8/21)
      bool goldenCross = (fast[1] <= slow[1] && fast[0] > slow[0]);
      bool deathCross  = (fast[1] >= slow[1] && fast[0] < slow[0]);
      
      // 4. Ana Sinyal (Trend Yönünde Cross)
      if(trend == 1 && goldenCross)
      {
         g_StateReason = "MA MASTER: TREND + CROSS BUY";
         return 1;
      }
      if(trend == -1 && deathCross)
      {
         g_StateReason = "MA MASTER: TREND + CROSS SELL";
         return -1;
      }
      
      return 0;
   }
};

//====================================================================
// CLASS: RISK MANAGER (v31 - Karlılık Odaklı)
//====================================================================
class CRiskManager
{
private:
   double m_equityHigh;          // Equity zirvesi
   double m_maxDrawdown;         // Maksimum drawdown
   
public:
   bool Init()
   {
      m_equityHigh = AccountInfoDouble(ACCOUNT_EQUITY);
      m_maxDrawdown = 0;
      ArrayResize(g_profitHistory, 100); // Son 100 işlem için yer ayır
      return true;
   }

   // 1. Emergency Drawdown Kontrolü
   bool CheckEmergencyDrawdown()
   {
      double currentEquity = AccountInfoDouble(ACCOUNT_EQUITY);
      if(currentEquity > m_equityHigh) m_equityHigh = currentEquity;
      
      double ddPercent = 0;
      if(m_equityHigh > 0)
         ddPercent = (m_equityHigh - currentEquity) / m_equityHigh * 100.0;
         
      g_maxDrawdownReached = MathMax(g_maxDrawdownReached, ddPercent);
      
      if(ddPercent >= InpMaxDrawdownStop)
      {
         // Cooldown başlat
         g_cooldownUntil = TimeCurrent() + (InpCooldownMinutes * 60);
         return true; // ACİL DURDURMA
      }
      return false;
   }
   
   // 2. Cooldown Kontrolü
   bool IsInCooldown()
   {
      if(g_cooldownUntil > 0 && TimeCurrent() < g_cooldownUntil)
      {
         g_StateReason = "COOLDOWN: " + TimeToString(g_cooldownUntil);
         return true;
      }
      g_cooldownUntil = 0;
      return false;
   }
   
   // 3. Risk Bazlı Lot Hesaplama
   double GetRiskBasedLot()
   {
      if(!InpUseRiskBasedLot) return InpFixedLot;
      
      double balance = AccountInfoDouble(ACCOUNT_BALANCE);
      double riskAmount = balance * (InpRiskPerTrade / 100.0);
      
      double slPoints = CPriceEngine::PipToPoints(InpSL_Pips);
      if(InpUseATRStops)
      {
         int hATR = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
         double atr[1];
         CopyBuffer(hATR, 0, 0, 1, atr);
         IndicatorRelease(hATR);
         slPoints = atr[0] * InpATRMultiplierSL / SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      }
      
      if(slPoints <= 0) return InpFixedLot;
      
      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double lot = riskAmount / (slPoints * tickValue);
      
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      
      lot = MathFloor(lot / stepLot) * stepLot;
      return MathMax(minLot, MathMin(lot, maxLot)); 
   }
   
   // 4. İstatistiksel Metrikler
   double GetProfitFactor()
   {
      if(g_grossLoss == 0) return g_grossProfit > 0 ? 100.0 : 0.0;
      return g_grossProfit / g_grossLoss;
   }
   
   double GetSharpeRatio()
   {
      // Basitleştirilmiş Sharpe (Gerçek hesaplama için dizi geçmişi gerek)
      if(g_totalLosses == 0) return 0;
      double avgWin = g_grossProfit / (g_totalWins > 0 ? g_totalWins : 1);
      double avgLoss = g_grossLoss / g_totalLosses;
      double stdDev = (avgWin + avgLoss) / 2.0; // Basit sapma tahmini
      if(stdDev == 0) return 0;
      return (avgWin - avgLoss) / stdDev;
   }
   
   double GetMaxDrawdown() { return g_maxDrawdownReached; }
   
   double GetATRPips()
   {
      int hMA = iATR(_Symbol, PERIOD_CURRENT, 14);
      double val[1];
      CopyBuffer(hMA, 0, 0, 1, val);
      IndicatorRelease(hMA);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      return val[0] / point / 10.0; // Pips
   }
   
   // ATR Bazlı SL/TP Helperları
   double GetATRStopLoss(int direction)
   {
      if(!InpUseATRStops) return 0; // Sabit Pips Kullan
      int hATR = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
      double atr[1];
      CopyBuffer(hATR, 0, 0, 1, atr);
      IndicatorRelease(hATR);
      
      double slDist = atr[0] * InpATRMultiplierSL;
      if(direction == 1) return SymbolInfoDouble(_Symbol, SYMBOL_ASK) - slDist;
      else return SymbolInfoDouble(_Symbol, SYMBOL_BID) + slDist;
   }
   
   double GetATRTakeProfit(int direction)
   {
      if(!InpUseATRStops) return 0;
      int hATR = iATR(_Symbol, PERIOD_CURRENT, InpATRPeriod);
      double atr[1];
      CopyBuffer(hATR, 0, 0, 1, atr);
      IndicatorRelease(hATR);
      
      double tpDist = atr[0] * InpATRMultiplierTP;
      if(direction == 1) return SymbolInfoDouble(_Symbol, SYMBOL_ASK) + tpDist;
      else return SymbolInfoDouble(_Symbol, SYMBOL_BID) - tpDist;
   }
   
   bool CheckRiskReward(double entry, double sl, double tp, int direction)
   {
      if(sl == 0 || tp == 0) return true; // Sabit SL/TP kullanılıyorsa geç
      
      double risk = MathAbs(entry - sl);
      double reward = MathAbs(tp - entry);
      
      if(risk <= 0) return false;
      
      double rr = reward / risk;
      if(rr < InpMinRiskReward)
      {
         g_StateReason = "DÜŞÜK R:R ORANI (" + DoubleToString(rr, 2) + ")";
         return false;
      }
      return true;
   }
};

//====================================================================
// CLASS: CONSENSUS ENGINE (v31)
//====================================================================
class CConsensusEngine
{
private:
   int m_hFast;
   int m_hMedium;
   int m_hSlow;
   
public:
   bool Init()
   {
      m_hFast = iMA(_Symbol, PERIOD_CURRENT, InpMA_Fast, 0, InpMA_Method, PRICE_CLOSE);
      m_hMedium = iMA(_Symbol, PERIOD_CURRENT, InpMA_Medium, 0, InpMA_Method, PRICE_CLOSE);
      m_hSlow = iMA(_Symbol, PERIOD_CURRENT, InpMA_Slow, 0, InpMA_Method, PRICE_CLOSE);
      
      if(m_hFast == INVALID_HANDLE || m_hMedium == INVALID_HANDLE || m_hSlow == INVALID_HANDLE)
         return false;
         
      return true;
   }
   
   void Release()
   {
      IndicatorRelease(m_hFast);
      IndicatorRelease(m_hMedium);
      IndicatorRelease(m_hSlow);
   }
   
   int GetConsensusSignal()
   {
      double f[1], m[1], s[1];
      CopyBuffer(m_hFast, 0, 0, 1, f);
      CopyBuffer(m_hMedium, 0, 0, 1, m);
      CopyBuffer(m_hSlow, 0, 0, 1, s);
      
      double price = iClose(_Symbol, PERIOD_CURRENT, 0);
      
      // Güçlü Alış: Fiyat > Fast > Medium > Slow
      // Zayıf Alış: Fiyat > Hepsi (Sıralama şart değil)
      
      if(InpRequireAlignment)
      {
         if(price > f[0] && f[0] > m[0] && m[0] > s[0]) return 1;
         if(price < f[0] && f[0] < m[0] && m[0] < s[0]) return -1;
      }
      else
      {
         int buyVotes = 0;
         int sellVotes = 0;
         
         if(price > f[0]) buyVotes++; else sellVotes++;
         if(price > m[0]) buyVotes++; else sellVotes++;
         if(price > s[0]) buyVotes++; else sellVotes++;
         
         if(buyVotes == 3) return 1;
         if(sellVotes == 3) return -1;
      }
      
      return 0;
   }
};

//====================================================================
// CLASS: HEDGING MANAGER (v31)
//====================================================================
class CHedgingManager
{
public:
   // İlgili sembolde o yönde pozisyon var mı?
   bool HasPosition(int direction)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         
         if(PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            long posType = PositionGetInteger(POSITION_TYPE);
            if((direction == 1 && posType == POSITION_TYPE_BUY) ||
               (direction == -1 && posType == POSITION_TYPE_SELL))
            {
               return true;
            }
         }
      }
      return false;
   }
   
   // Ters yönde pozisyon var mı?
   bool HasOppositePosition(int direction)
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         
         if(PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            long posType = PositionGetInteger(POSITION_TYPE);
            if((direction == 1 && posType == POSITION_TYPE_SELL) ||
               (direction == -1 && posType == POSITION_TYPE_BUY))
            {
               return true;
            }
         }
      }
      return false;
   }
   
   // v31: İşlem açmadan önce hedging kontrolü
   bool CanOpenPosition(int direction)
   {
      // Hedging izni varsa her şeye izin ver
      if(InpAllowHedging) return true;
      
      // Ters pozisyon varsa reddet
      if(HasOppositePosition(direction))
      {
         g_StateReason = "HEDGING ENGELLENDİ: Ters pozisyon mevcut";
         return false;
      }
      
      return true;
   }
};

//====================================================================
// CLASS: GRID EXECUTOR
//====================================================================
class CGridExecutor
{
private:
   CTrade m_trade;

public:
   void Init() 
   { 
      m_trade.SetExpertMagicNumber(InpMagic);
      
      // --- OTOMATIK FILLING MODE (v26) ---
      if(!m_trade.SetTypeFillingBySymbol(_Symbol))
      {
         // Fallback: Broker desteklemiyorsa FOK kullan
         m_trade.SetTypeFilling(ORDER_FILLING_FOK);
         Print("⚠️ v26: Otomatik Filling Mode ayarlanamadı, FOK kullanılıyor.");
      }
      else
      {
         Print("✅ v26: Otomatik Filling Mode başarıyla ayarlandı.");
      }
      
      m_trade.SetDeviationInPoints(10);
   }

   int CalculateSafeOrderCount(int direction)
   {
      // --- DİNAMİK LOT (ATR BAZLI) ---
      double lotToUse = InpFixedLot;
      if(InpUseDynamicLot)
      {
         int hATR = iATR(_Symbol, PERIOD_CURRENT, 14);
         double atrVal[];
         ArraySetAsSeries(atrVal, true);
         if(CopyBuffer(hATR, 0, 0, 1, atrVal) == 1)
         {
            // ATR çok yüksekse lotu yarıya düşür
            double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            if(atrVal[0] > 0.0020) // Örnek eşik
            {
               lotToUse = InpFixedLot / 2.0;
               double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
               if(lotToUse < minLot) lotToUse = minLot;
            }
         }
         IndicatorRelease(hATR);
      }
      
      ENUM_ORDER_TYPE type = (direction == 1) ? ORDER_TYPE_BUY_STOP : ORDER_TYPE_SELL_STOP;
      double price = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      double marginReq = 0;
      if(!OrderCalcMargin(type, _Symbol, lotToUse, price, marginReq)) 
         return 0;
      
      if(marginReq <= 0) 
         return 0;
      
      double freeMargin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
      int maxByMargin = (int)MathFloor(freeMargin / marginReq);
      
      // Risk bazlı limit hesabı
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double dailyRisk = AccountInfoDouble(ACCOUNT_BALANCE) * (InpBaseRiskPercent / 100.0);
      double remainingRisk = dailyRisk - MathMax(0, AccountInfoDouble(ACCOUNT_BALANCE) - equity);
      
      if(remainingRisk <= 0) 
         return 0;

      double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      
      if(tickSize <= 0 || point <= 0) 
         return 0;
      
      double pipValue = (tickValue / tickSize) * (10 * point);
      double lossPerTrade = lotToUse * InpSL_Pips * pipValue;
      
      if(lossPerTrade <= 0) 
         return 0;
      
      int maxByRisk = (int)MathFloor(remainingRisk / lossPerTrade);
      
      return MathMin(MathMin(maxByMargin, maxByRisk), InpMaxOrders);
   }

   void PlaceGrid(int direction)
   {
      // v40: Verbose log removed for clean output
      
      // v34: Test modunda mevcut pozisyon kontrolünü gevşet
      if(!InpRelaxChecks)
      {
         if(PositionsTotal() > 0 || OrdersTotal() > 0) 
            return;
      }
      else
      {
         // Relax modda sadece aynı yönde çok fazla pozisyon varsa engelle
         int maxPos = InpMultiOrder ? InpMaxOpenOrders : 1;
         if(PositionsTotal() >= maxPos)
            return;
      }

      // v34: Test modunda count hesaplamasını basitleştir
      int count = 1; // Varsayılan: 1 işlem
      if(!InpRelaxChecks)
      {
         count = CalculateSafeOrderCount(direction);
         if(count <= 0) 
         {
            // Güvenli emir sayısı 0 ise en az 1 dene
            Print("⚠️ v34: SafeOrderCount=0, Test modunda 1 olarak ayarlandı.");
            count = 1;
         }
      }

      // --- LOT HESAPLAMA ---
      double lotToUse = InpFixedLot;
      
      // Scale Up çarpanı uygula
      if(g_currentLotMultiplier > 1.0)
      {
         lotToUse = Security.GetScaledLot(lotToUse);
      }
      
      // Min lot kontrolü
      double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
      double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
      double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
      
      lotToUse = MathMax(minLot, MathMin(lotToUse, maxLot));
      lotToUse = MathFloor(lotToUse / lotStep) * lotStep;
      
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      double slSize = CPriceEngine::PipToPoints(InpSL_Pips);
      double tpSize = CPriceEngine::PipToPoints(InpTP_Pips);

      // ===============================================================
      // v35: EMİR TİPİ SEÇİMİ (Market/Stop/Limit)
      // ===============================================================
      
      // === MARKET EMİR ===
      if(InpOrderMode == ORDER_MODE_MARKET)
      {
         // v40: Clean mode
         double sl = 0, tp = 0;
         
         if(direction == 1) // BUY
         {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            sl = NormalizeDouble(ask - slSize, digits);
            tp = NormalizeDouble(ask + tpSize, digits);
            
            // v40: Concise logging
            
            CPriceEngine::EnforceRequestInterval();
            
            if(m_trade.Buy(lotToUse, _Symbol, 0, sl, tp, InpComment))
            {
               g_tradesTodayCount++;
               Print("✅ BUY #", m_trade.ResultOrder(), " | Lot:", lotToUse);
            }
            else
            {
               Print("❌ v35: Market BUY hatası: ", m_trade.ResultRetcodeDescription());
            }
         }
         else // SELL
         {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            sl = NormalizeDouble(bid + slSize, digits);
            tp = NormalizeDouble(bid - tpSize, digits);
            
            // v40: Concise logging
            
            CPriceEngine::EnforceRequestInterval();
            
            if(m_trade.Sell(lotToUse, _Symbol, 0, sl, tp, InpComment))
            {
               g_tradesTodayCount++;
               Print("✅ SELL #", m_trade.ResultOrder(), " | Lot:", lotToUse);
            }
            else
            {
               Print("❌ v35: Market SELL hatası: ", m_trade.ResultRetcodeDescription());
            }
         }
         
         return; // Market emri açıldı, çık
      }
      
      // === LIMIT EMİR (v35 YENİ) ===
      if(InpOrderMode == ORDER_MODE_LIMIT)
      {
         // Limit offset hesapla (ATR bazlı veya sabit)
         double limitOffsetPips = (double)InpLimitOffset;
         if(InpUseDynamicLimitOffset && RiskMgr.GetATRPips() > 0)
         {
            limitOffsetPips = RiskMgr.GetATRPips() * 0.5; // ATR'nin yarısı
         }
         double limitOffset = CPriceEngine::PipToPoints((int)limitOffsetPips);
         
         datetime expiration = TimeCurrent() + (InpExpirationHrs * 3600);
         double sl = 0, tp = 0, entry = 0;
         
         if(direction == 1) // BUY LIMIT - Mevcut fiyatın ALTINDA
         {
            double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
            entry = NormalizeDouble(ask - limitOffset, digits);
            sl = NormalizeDouble(entry - slSize, digits);
            tp = NormalizeDouble(entry + tpSize, digits);
            
            Print("📍 v35: BuyLimit açılıyor... Entry:", DoubleToString(entry, digits),
                  " Lot:", DoubleToString(lotToUse, 2), " SL:", DoubleToString(sl, digits), 
                  " TP:", DoubleToString(tp, digits));
            
            CPriceEngine::EnforceRequestInterval();
            
            if(m_trade.BuyLimit(lotToUse, entry, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, "OmegaBuyLimit"))
            {
               g_tradesTodayCount++;
               Print("✅ v35: BuyLimit başarılı! Entry:", entry);
            }
            else
            {
               Print("❌ v35: BuyLimit hatası: ", m_trade.ResultRetcodeDescription());
            }
         }
         else // SELL LIMIT - Mevcut fiyatın ÜSTÜNDE
         {
            double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
            entry = NormalizeDouble(bid + limitOffset, digits);
            sl = NormalizeDouble(entry + slSize, digits);
            tp = NormalizeDouble(entry - tpSize, digits);
            
            Print("📍 v35: SellLimit açılıyor... Entry:", DoubleToString(entry, digits),
                  " Lot:", DoubleToString(lotToUse, 2), " SL:", DoubleToString(sl, digits), 
                  " TP:", DoubleToString(tp, digits));
            
            CPriceEngine::EnforceRequestInterval();
            
            if(m_trade.SellLimit(lotToUse, entry, _Symbol, sl, tp, ORDER_TIME_SPECIFIED, expiration, "OmegaSellLimit"))
            {
               g_tradesTodayCount++;
               Print("✅ v35: SellLimit başarılı! Entry:", entry);
            }
            else
            {
               Print("❌ v35: SellLimit hatası: ", m_trade.ResultRetcodeDescription());
            }
         }
         
         return; // Limit emri açıldı, çık
      }
      
      // === STOP EMİR (Varsayılan) ===
      // InpOrderMode == ORDER_MODE_STOP veya diğer durumlar

      // ===============================================================
      // BEKLEYEN EMİR MODU (InpInstantTrade = false)
      // ===============================================================
      double basePrice = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      if(StressTest_Mode)
      {
         double slip = Simulated_Slippage * point;
         basePrice += (direction == 1) ? slip : -slip;
      }

      datetime expiration = TimeCurrent() + (InpExpirationHrs * 3600);
      double stepSize = CPriceEngine::PipToPoints(InpStepPips);

      for(int i = 0; i < count; i++)
      {
         double entry = 0, sl = 0, tp = 0;
         
         if(direction == 1) // BUY
         {
            entry = basePrice + ((i + 1) * stepSize);
            sl    = entry - slSize;
            tp    = entry + tpSize;
            
            // v34: Test modunda stop level kontrolünü gevşet
            if(!InpRelaxChecks && !CPriceEngine::CheckStopLevel(entry, sl, tp, 1)) 
               continue;
            
            CPriceEngine::EnforceRequestInterval();
            
            if(!m_trade.BuyStop(lotToUse, NormalizeDouble(entry, digits), _Symbol, 
               NormalizeDouble(sl, digits), NormalizeDouble(tp, digits), 
               ORDER_TIME_SPECIFIED, expiration, "OmegaBuy_" + IntegerToString(i)))
            {
               Print("❌ BuyStop Hatası [#", i, "]: ", m_trade.ResultRetcodeDescription());
               
               if(m_trade.ResultRetcode() == 10014)
               {
                  Print("💰 Yetersiz bakiye nedeniyle grid sonlandırıldı.");
                  break;
               }
            }
            else
            {
               g_tradesTodayCount++;
               Print("✅ BuyStop [#", i, "] başarıyla açıldı. Fiyat: ", entry);
            }
         }
         else // SELL
         {
            entry = basePrice - ((i + 1) * stepSize);
            sl    = entry + slSize;
            tp    = entry - tpSize;
            
            // v34: Test modunda stop level kontrolünü gevşet
            if(!InpRelaxChecks && !CPriceEngine::CheckStopLevel(entry, sl, tp, -1)) 
               continue;
            
            CPriceEngine::EnforceRequestInterval();
            
            if(!m_trade.SellStop(lotToUse, NormalizeDouble(entry, digits), _Symbol, 
               NormalizeDouble(sl, digits), NormalizeDouble(tp, digits), 
               ORDER_TIME_SPECIFIED, expiration, "OmegaSell_" + IntegerToString(i)))
            {
               Print("❌ SellStop Hatası [#", i, "]: ", m_trade.ResultRetcodeDescription());
               
               if(m_trade.ResultRetcode() == 10014)
               {
                  Print("💰 Yetersiz bakiye nedeniyle grid sonlandırıldı.");
                  break;
               }
            }
            else
            {
               g_tradesTodayCount++;
               Print("✅ SellStop [#", i, "] başarıyla açıldı. Fiyat: ", entry);
            }
         }
      }
   }

   void CleanUp()
   {
      for(int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if(ticket > 0 && OrderGetInteger(ORDER_MAGIC) == InpMagic)
            m_trade.OrderDelete(ticket);
      }
   }
     
   void EmergencyCloseAll()
   {
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket > 0 && PositionSelectByTicket(ticket))
         {
            bool myTrade = (PositionGetInteger(POSITION_MAGIC) == InpMagic);
            if(myTrade || InpManageManual)
               m_trade.PositionClose(ticket);
         }
      }
      CleanUp();
   }
     
   void ManagePositions()
   {
      ManageManualTrades(); // Manuel işlemleri kontrol et

      if(!InpUseBreakeven && !InpUseSmartPartial) 
         return;
      
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         
         bool myTrade = (PositionGetInteger(POSITION_MAGIC) == InpMagic);
         if(!myTrade && !InpManageManual) continue;
         
         if(PositionSelectByTicket(ticket))
         {
            double open = PositionGetDouble(POSITION_PRICE_OPEN);
            double curr = PositionGetDouble(POSITION_PRICE_CURRENT);
            double sl   = PositionGetDouble(POSITION_SL);
            double tp   = PositionGetDouble(POSITION_TP);
            long type   = PositionGetInteger(POSITION_TYPE);
            double vol  = PositionGetDouble(POSITION_VOLUME);
            double pt   = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            
            if(InpUseSmartPartial && tp != 0)
            {
               double profitDist = MathAbs(curr - open);
               double targetDist = MathAbs(tp - open);
               
               if(targetDist > 0 && profitDist >= targetDist * 0.5)
               {
                  bool isBE = (MathAbs(sl - open) < (5 * pt));
                  if(!isBE && vol > SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
                  {
                     double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
                     double closeVol = MathFloor((vol * 0.5) / lotStep) * lotStep;
                     if(closeVol >= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN))
                        m_trade.PositionClosePartial(ticket, closeVol);
                  }
               }
            }

            if(InpUseBreakeven)
            {
               double beTrigger = CPriceEngine::PipToPoints(10);
               double extraPips = CPriceEngine::PipToPoints(2);

               if(type == POSITION_TYPE_BUY && curr > open + beTrigger)
               {
                  if(sl < open || sl == 0)
                     m_trade.PositionModify(ticket, open + extraPips, tp);
               }
               else if(type == POSITION_TYPE_SELL && curr < open - beTrigger)
               {
                  if(sl > open || sl == 0)
                     m_trade.PositionModify(ticket, open - extraPips, tp);
               }
            }
            
            // --- TRAILING STOP (İZLEYEN STOP) ---
            if(InpUseTrailing)
            {
               double trailStart = CPriceEngine::PipToPoints(InpTrailingStart);
               double trailStep  = CPriceEngine::PipToPoints(InpTrailingStep);
               
               if(type == POSITION_TYPE_BUY)
               {
                  if(curr - open > trailStart) // Kâr başlangıç seviyesini geçtiyse
                  {
                     double newSL = curr - trailStart;
                     if(newSL > sl + trailStep) // Sadece yukarı taşı
                     {
                        m_trade.PositionModify(ticket, newSL, tp);
                     }
                  }
               }
               else if(type == POSITION_TYPE_SELL)
               {
                  if(open - curr > trailStart) // Kâr başlangıç seviyesini geçtiyse
                  {
                     double newSL = curr + trailStart;
                     if(sl == 0 || newSL < sl - trailStep) // Sadece aşağı taşı
                     {
                        m_trade.PositionModify(ticket, newSL, tp);
                     }
                  }
               }
            }
         }
      }
   }
   
   void ManageManualTrades()
   {
      int trend = Signal.GetTrendDirection();
      
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         ulong ticket = PositionGetTicket(i);
         if(ticket == 0) continue;
         
         // Sadece Manuel İşlemler (Magic = 0)
         if(PositionGetInteger(POSITION_MAGIC) != 0) continue;
         
         if(PositionSelectByTicket(ticket))
         {
            long type = PositionGetInteger(POSITION_TYPE);
            
            // 1. Ters Yön Kontrolü
            if(trend == 1 && type == POSITION_TYPE_SELL) // Trend Yukarı ama Satış açılmış
            {
               Print("UYARI: Trend tersine açılan manuel işlem kapatılıyor! Ticket: ", ticket);
               m_trade.PositionClose(ticket);
               continue;
            }
            if(trend == -1 && type == POSITION_TYPE_BUY) // Trend Aşağı ama Alış açılmış
            {
               Print("UYARI: Trend tersine açılan manuel işlem kapatılıyor! Ticket: ", ticket);
               m_trade.PositionClose(ticket);
               continue;
            }
            
            // 2. SL/TP Ekleme
            double sl = PositionGetDouble(POSITION_SL);
            double tp = PositionGetDouble(POSITION_TP);
            double open = PositionGetDouble(POSITION_PRICE_OPEN);
            double pt = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
            int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
            
            bool modified = false;
            double newSL = sl;
            double newTP = tp;
            
            double slDist = CPriceEngine::PipToPoints(InpSL_Pips);
            double tpDist = CPriceEngine::PipToPoints(InpTP_Pips);
            
            if(sl == 0)
            {
               newSL = (type == POSITION_TYPE_BUY) ? open - slDist : open + slDist;
               modified = true;
            }
            
            if(tp == 0)
            {
               newTP = (type == POSITION_TYPE_BUY) ? open + tpDist : open - tpDist;
               modified = true;
            }
            
            if(modified)
            {
               if(CPriceEngine::CheckStopLevel(open, newSL, newTP, (type == POSITION_TYPE_BUY ? 1 : -1)))
               {
                  m_trade.PositionModify(ticket, NormalizeDouble(newSL, digits), NormalizeDouble(newTP, digits));
                  Print("Manuel işleme SL/TP eklendi. Ticket: ", ticket);
               }
            }
         }
      }
   }
};

//====================================================================
// GLOBAL OBJECTS
//====================================================================
CNewsManager     News;
CSecurityManager Security;
CSignalEngine    Signal;
CGridExecutor    Executor;
CRecoveryManager Recovery;   // v27
CFundManager     Fund;       // v27
CRiskManager     RiskMgr;    // v31 - Karlılık
CConsensusEngine Consensus;  // v31 - Konsensüs
CHedgingManager  Hedging;    // v31 - Hedging

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   // --- SIKI BAŞLANGIÇ KONTROLLERİ (v24) ---
   if(InpStrictInitChecks)
   {
      if(SymbolInfoDouble(_Symbol, SYMBOL_POINT) <= 0) { Print("⛔ HATA: Point değeri geçersiz!"); return INIT_FAILED; }
      if(SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) <= 0) { Print("⛔ HATA: Tick Value geçersiz!"); return INIT_FAILED; }
      if(SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP) <= 0) { Print("⛔ HATA: Volume Step geçersiz!"); return INIT_FAILED; }
      Print("✅ Sıkı Başlangıç Kontrolleri: BAŞARILI");
   }

   if(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL)
   {
      Alert("HATA: Bu sembolde işlem izni yok!");
      return INIT_FAILED;
   }
   
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(InpFixedLot < minLot || InpFixedLot > maxLot)
   {
      Alert("HATA: Lot boyutu uygun değil! Min: ", minLot, " Max: ", maxLot);
      return INIT_FAILED;
   }
   
   Security.Init();
   if(!Signal.Init()) return INIT_FAILED;
   Executor.Init();
   Recovery.Init();   // v27
   Fund.Init();       // v27
   
   // v31 - Karlılık Modülleri
   if(!RiskMgr.Init()) return INIT_FAILED;
   if(!Consensus.Init()) return INIT_FAILED;
   Print("✅ v40: Tüm modüller başlatıldı (PROFIT-FOCUSED SCALPER).");
   
   // v42 - Başlangıç Mesajı
   Print("=================================================");
   Print("TITANIUM OMEGA v42.0 - MA MASTER (NATIVE)");
   Print("=================================================");
   Print("💰 Bakıye: ", AccountInfoDouble(ACCOUNT_BALANCE), " ", AccountInfoString(ACCOUNT_CURRENCY));
   Print("📈 Trend SMA: ", InpTrend_SMA, " | Sinyal EMA: ", InpSignal_EMA_Fast, "/", InpSignal_EMA_Slow);
   Print("✅ Mod: MA MASTER (Single File)");
   Print("=================================================");
   
   // v37 - OTOMATİK TEST İŞLEMİ
   if(InpAutoTestTrade)
   {
      Print("🧪 v37: Otomatik test işlemi açılıyor...");
      Sleep(2000); // 2 saniye bekle
      
      CTrade testTrade;
      testTrade.SetExpertMagicNumber(InpMagic);
      
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double lot = InpFixedLot;
      
      // SL ve TP hesapla
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      double slSize = CPriceEngine::PipToPoints(InpSL_Pips);
      double tpSize = CPriceEngine::PipToPoints(InpTP_Pips);
      
      // ===== BUY İŞLEMİ =====
      double slBuy = NormalizeDouble(ask - slSize, digits);
      double tpBuy = NormalizeDouble(ask + tpSize, digits);
      
      Print("🚀 v37 TEST: Market BUY açılıyor...");
      Print("   Ask: ", ask, " SL: ", slBuy, " TP: ", tpBuy);
      
      if(testTrade.Buy(lot, _Symbol, 0, slBuy, tpBuy, "v37 Test BUY"))
      {
         Print("✅ v37 TEST: BUY BAŞARILI! Ticket: ", testTrade.ResultOrder());
      }
      else
      {
         Print("❌ v37 TEST: BUY BAŞARISIZ! Error: ", testTrade.ResultRetcode(), " - ", testTrade.ResultRetcodeDescription());
      }
      
      Sleep(1000); // 1 saniye ara
      
      // ===== SELL İŞLEMİ =====
      double slSell = NormalizeDouble(bid + slSize, digits);
      double tpSell = NormalizeDouble(bid - tpSize, digits);
      
      Print("🚀 v37 TEST: Market SELL açılıyor...");
      Print("   Bid: ", bid, " SL: ", slSell, " TP: ", tpSell);
      
      if(testTrade.Sell(lot, _Symbol, 0, slSell, tpSell, "v37 Test SELL"))
      {
         Print("✅ v37 TEST: SELL BAŞARILI! Ticket: ", testTrade.ResultOrder());
      }
      else
      {
         Print("❌ v37 TEST: SELL BAŞARISIZ! Error: ", testTrade.ResultRetcode(), " - ", testTrade.ResultRetcodeDescription());
      }
      
      Print("🧪 v37: Test işlem süreci tamamlandı.");
   }
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Signal.ReleaseHandles();
   Executor.CleanUp();
   Comment("");
}

//+------------------------------------------------------------------+
//| v33: STRATEGY TESTER CUSTOM OPTIMIZATION CRITERIA                |
//| Anti-Overfitting: PF/DD Ratio + Min Trade Count                  |
//+------------------------------------------------------------------+
double OnTester()
{
   // --- TEMEL İSTATİSTİKLER ---
   double totalTrades = TesterStatistics(STAT_TRADES);
   double profitFactor = TesterStatistics(STAT_PROFIT_FACTOR);
   double maxDDPercent = TesterStatistics(STAT_BALANCE_DD_RELATIVE);
   double netProfit = TesterStatistics(STAT_PROFIT);
   double winRate = TesterStatistics(STAT_TRADES) > 0 ? 
                    (TesterStatistics(STAT_PROFIT_TRADES) / TesterStatistics(STAT_TRADES)) * 100.0 : 0;
   double sharpeRatio = TesterStatistics(STAT_SHARPE_RATIO);
   
   // --- v33: ANTİ-OVERFITTING KRİTERLERİ ---
   
   // 1. Minimum İşlem Sayısı (Overfitting'i önler)
   double minTradesRequired = 50.0;  // En az 50 işlem olmalı
   if(totalTrades < minTradesRequired)
   {
      Print("❌ v33: Yetersiz işlem sayısı: ", totalTrades, " < ", minTradesRequired);
      return 0.0; // Yetersiz veri = geçersiz sonuç
   }
   
   // 2. Minimum Profit Factor
   if(profitFactor < 1.0)
   {
      Print("❌ v33: Zararlı strateji. PF: ", DoubleToString(profitFactor, 2));
      return 0.0;
   }
   
   // 3. Maximum Drawdown Limiti
   double maxAllowedDD = 30.0;  // %30'dan fazla DD kabul edilmez
   if(maxDDPercent > maxAllowedDD)
   {
      Print("❌ v33: Aşırı drawdown: %", DoubleToString(maxDDPercent, 1), " > %", DoubleToString(maxAllowedDD, 1));
      return 0.0;
   }
   
   // --- v33: ROBUST OPTIMIZATION SCORE ---
   // Formül: (Profit Factor / Max Drawdown %) × √(Total Trades) × (Win Rate / 50)
   // Bu formül:
   // - Yüksek PF ödüllendirir
   // - Düşük DD ödüllendirir  
   // - Çok işlem = güvenilir sonuç (ama aşırı değil)
   // - Yüksek win rate bonusu
   
   double ddFactor = maxDDPercent > 0 ? (100.0 / maxDDPercent) : 1.0;
   double tradeFactor = MathSqrt(MathMin(totalTrades, 500.0));  // 500'den sonra katkı azalır
   double winFactor = winRate / 50.0;  // %50 win rate = 1.0 çarpan
   double sharpeFactor = MathMax(0.5, MathMin(sharpeRatio, 3.0)) / 2.0; // 0.25 - 1.5 arası
   
   double robustScore = profitFactor * ddFactor * tradeFactor * winFactor * sharpeFactor;
   
   // Normalize (0-1000 arası)
   robustScore = MathMin(robustScore, 1000.0);
   
   // --- DETAYLI LOG ---
   Print("=== v33 OPTIMIZATION RESULT ===");
   Print("📊 Trades: ", (int)totalTrades, " | Net: $", DoubleToString(netProfit, 2));
   Print("📈 PF: ", DoubleToString(profitFactor, 2), " | Win Rate: %", DoubleToString(winRate, 1));
   Print("📉 Max DD: %", DoubleToString(maxDDPercent, 1), " | Sharpe: ", DoubleToString(sharpeRatio, 2));
   Print("🎯 ROBUST SCORE: ", DoubleToString(robustScore, 2));
   Print("================================");
   
   return robustScore;
}

// Yeni Gün Kontrolü
void CheckNewDay()
{
   datetime current_day = iTime(_Symbol, PERIOD_D1, 0);
   if(g_today_start != current_day)
   {
      g_today_start = current_day;
      g_tradesTodayCount = 0;
      Print("📅 YENİ GÜN: İşlem sayacı sıfırlandı.");
   }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   CheckNewDay();
   
   // v29 - Agresif Strateji Güncellemesi
   Security.UpdateStreak();
   
   // v27 - Manager Güncellemeleri
   Recovery.Update();
   Fund.Update();

   // Güvenlik Kontrolü
   bool safeToOpen = Security.IsSafeToTrade();
   // Debug log kaldırıldı (v39: Production)
   
   // v31 - Emergency Drawdown Kontrolü
   if(safeToOpen && RiskMgr.CheckEmergencyDrawdown())
   {
      safeToOpen = false;
      Executor.EmergencyCloseAll();
      Print("⛔ v31: EMERGENCY STOP! Tüm pozisyonlar kapatıldı.");
   }
   
   // v31 - Cooldown Kontrolü
   if(safeToOpen && RiskMgr.IsInCooldown())
   {
      safeToOpen = false;
   }
   
   // v27 - Fon Yönetimi Hedef Kontrolü
   if(safeToOpen && Fund.ShouldPauseTrading()) safeToOpen = false;
   
   // Günlük İşlem Limiti Kontrolü (v29: 0 = sınırsız)
   if(InpMaxTradesPerDay > 0 && g_tradesTodayCount >= InpMaxTradesPerDay)
   {
      safeToOpen = false;
      g_StateReason = "GÜNLÜK İŞLEM LİMİTİ (" + IntegerToString(g_tradesTodayCount) + "/" + IntegerToString(InpMaxTradesPerDay) + ")";
   }
   
   // v29: CheckPerformance artık durdurmaz
   Security.CheckPerformance();
   
   // Haber Filtresi
   if(safeToOpen && News.IsNewsTime()) safeToOpen = false;
   
   // Pozisyon Yönetimi (Manuel + Otomatik)
   Executor.ManagePositions();
   
   // v30 - Sinyal Analizi ve Yön Tespiti
   int signal = 0;
   static int g_lastSignalDirection = 0; // Son sinyal yönü
   
   // Önce Reverse sinyal kontrol et
   signal = Security.GetReverseSignal();
   
   // Reverse yok ise stratejiye göre sinyal al
   if(signal == 0)
   {
      if(InpStrategyMode == STRATEGY_MA_MASTER)
      {
         // v42: Native MA Master Signal
         signal = Signal.GetMAMasterSignal();
      }
      else
      {
         // Eski Stratejiler
         ENUM_MARKET_REGIME regime = Signal.GetRegime();
         signal = Signal.GetDirection(regime);
      }
   }
   
   // v31: Konsensüs sinyali ile doğrulama
   // Debug log kaldırıldı (v39: Production)
   if(signal != 0 && InpUseConsensus)
   {
      int consensusSignal = Consensus.GetConsensusSignal();
      if(consensusSignal != 0 && consensusSignal != signal)
      {
         signal = 0; // Konsensüs uyuşmazlığı
         g_StateReason = "KONSENSÜS UYUŞMAZLIĞI";
      }
      else if(consensusSignal == signal)
      {
         g_StateReason = "KONSENSÜS ONAYLADI (" + IntegerToString(signal == 1 ? 1 : -1) + ")";
      }
   }
   
   // v30: Yön değişikliğinde bekleyen emirleri sil
   if(InpCancelOnReverse && signal != 0 && signal != g_lastSignalDirection && g_lastSignalDirection != 0)
   {
      int deletedOrders = 0;
      for(int i = OrdersTotal() - 1; i >= 0; i--)
      {
         ulong ticket = OrderGetTicket(i);
         if(ticket > 0 && OrderGetString(ORDER_SYMBOL) == _Symbol)
         {
            ulong orderMagic = OrderGetInteger(ORDER_MAGIC);
            if(orderMagic == InpMagic || InpManageManual)
            {
               CTrade trade;
               trade.SetExpertMagicNumber(InpMagic);
               if(trade.OrderDelete(ticket))
               {
                  deletedOrders++;
               }
            }
         }
      }
      if(deletedOrders > 0)
      {
         Print("🔄 v30: YÖN DEĞİŞİMİ! ", deletedOrders, " bekleyen emir silindi. Yeni yön: ", (signal == 1 ? "BUY" : "SELL"));
      }
   }
   
   // v31 - Çoklu Emir Açma + Hedging + RR Kontrolü
   if(safeToOpen && signal != 0)
   {
      // Debug log kaldırıldı (v39: Production)
      // v31: Hedging kontrolü
      if(!Hedging.CanOpenPosition(signal))
      {
         safeToOpen = false;
      }
      
      // v31: Risk/Reward kontrolü
      if(safeToOpen)
      {
         double entryPrice = (signal == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
         double slPrice = RiskMgr.GetATRStopLoss(signal);
         double tpPrice = RiskMgr.GetATRTakeProfit(signal);
         
         if(!RiskMgr.CheckRiskReward(entryPrice, slPrice, tpPrice, signal))
         {
            safeToOpen = false;
         }
      }
      
      if(safeToOpen)
      {
         // Debug log kaldırıldı (v39: Production)
         int currentOpenOrders = PositionsTotal() + OrdersTotal();
         int maxOrders = InpMultiOrder ? InpMaxOpenOrders : 1;
         
         if(currentOpenOrders < maxOrders)
         {
            g_lastSignalDirection = signal; // Son sinyal yönünü kaydet
            Executor.PlaceGrid(signal);
         }
      }
   }
   
   // v31 Dashboard - PROFIT MAXIMIZER
   if(InpShowDashboard || InpForceShowDashboard)
   {
      string regimeText = "HESAPLANIYOR";
      ENUM_MARKET_REGIME regime = Signal.GetRegime();
      switch(regime)
      {
         case REGIME_HIGH_VOLATILITY: regimeText = "YUKSEK VOL."; break;
         case REGIME_TRENDING: regimeText = "TREND"; break;
         case REGIME_RANGING: regimeText = "YATAY"; break;
      }
      
      string recoveryStatus = g_recoveryMode ? "[KURTARMA] " : "";
      string scaleStatus = g_currentLotMultiplier > 1.0 ? "[SCALE-UP] " : "";
      string cooldownStatus = (g_cooldownUntil > 0 && TimeCurrent() < g_cooldownUntil) ? "[COOLDOWN] " : "";
      
      // Strateji adı
      string stratName = "FRACTAL";
      if(InpStrategyMode == STRATEGY_HMA_CROSS) stratName = "HMA CROSS";
      else if(InpStrategyMode == STRATEGY_AMA_CROSS) stratName = "AMA CROSS";
      else if(InpStrategyMode == STRATEGY_MA_MASTER) stratName = "MA MASTER (NATIVE)";
      
      // v31 Metrikler
      double profitFactor = RiskMgr.GetProfitFactor();
      double sharpeRatio = RiskMgr.GetSharpeRatio();
      double maxDD = RiskMgr.GetMaxDrawdown();
      double atrPips = RiskMgr.GetATRPips();
      double riskLot = RiskMgr.GetRiskBasedLot();
      
      string dash = "+================================================+\n";
      dash += "|   TITANIUM OMEGA v42.0 MA MASTER NATIVE        |\n";
      dash += "+================================================+\n";
      dash += "| DURUM    : " + recoveryStatus + scaleStatus + cooldownStatus + (safeToOpen ? "[AKTIF]" : "[BEKLIYOR]") + "\n";
      dash += "| STRATEJI : " + stratName + "\n";
      dash += "| NEDEN    : " + g_StateReason + "\n";
      dash += "+------------------------------------------------+\n";
      dash += "| PIYASA   : " + regimeText + " | ATR: " + DoubleToString(atrPips, 1) + " pips\n";
      dash += "| DRAWDOWN : %" + DoubleToString(Recovery.GetDrawdownPercent(), 1) + " | MAX: %" + DoubleToString(maxDD, 1) + "\n";
      dash += "+------------------------------------------------+\n";
      dash += "| POZISYON : " + IntegerToString(PositionsTotal()) + "/" + IntegerToString(InpMaxOpenOrders) + " | BEKLEYEN: " + IntegerToString(OrdersTotal()) + "\n";
      dash += "| LOT      : " + DoubleToString(riskLot, 2) + " (Risk: %" + DoubleToString(InpRiskPerTrade, 1) + ")\n";
      dash += "+------------------------------------------------+\n";
      dash += "| GUNLUK P/L : $" + DoubleToString(Fund.GetDailyProfit(), 2) + "\n";
      dash += "| WIN RATE   : %" + DoubleToString(Fund.GetWinRate(), 1) + "\n";
      dash += "| PROFIT FAC : " + DoubleToString(profitFactor, 2) + "\n";
      dash += "| SHARPE     : " + DoubleToString(sharpeRatio, 2) + "\n";
      dash += "| TRADES     : " + IntegerToString(g_tradesTodayCount) + (InpMaxTradesPerDay > 0 ? "/" + IntegerToString(InpMaxTradesPerDay) : " (SINIRSIZ)") + "\n";
      dash += "+================================================+";
      
      Comment(dash);
   }
   else
   {
      Comment("");
   }
}
