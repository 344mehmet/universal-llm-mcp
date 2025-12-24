//+------------------------------------------------------------------+
//|                                     Titanium_Omega_v30.mq5       |
//|                     © 2025, Systemic Trading Engineering         |
//|  Versiyon: 30.0 (AMA STRATEGY + MULTI ORDER + PENDING MGMT)     |
//+------------------------------------------------------------------+
#property copyright "© 2025, Systemic Trading Engineering"
#property version   "30.00"
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
   STRATEGY_AMA_CROSS         // v30: AMA Cross (En İyi Performans)
};

//--- INPUTS
//--- 1. ANA AYARLAR
input group "=== 1. MAIN SETTINGS ==="
input ulong    InpMagic           = 123456;    // Magic Number
input string   InpComment         = "Titanium Omega v30"; // İşlem Yorumu
input bool     InpShowDashboard   = true;      // Bilgi Paneli Göster
input ENUM_STRATEGY_MODE InpStrategyMode = STRATEGY_AMA_CROSS; // v30: AMA VARSAYILAN

//--- 2. RİSK VE SERMAYE YÖNETİMİ
input group "=== 2. RISK & CAPITAL ==="
input double   InpBaseRiskPercent = 1.0;      // Baz Risk %
input double   InpMaxDailyLoss    = 30.0;     // Günlük Max Zarar % (10$ için %30 = 3$)
input double   InpMaxMoneyDD      = 5.0;      // Günlük Max Zarar $
input double   InpMinMarginLevel  = 50.0;     // Min Marjin Seviyesi % (Düşürüldü)
input bool     InpDetectDeposit   = true;     // Para Yatırma/Çekme Algıla

//--- 3. GRID MATRİSİ
input group "=== 3. GRID MATRIX ==="
input double   InpFixedLot        = 0.01;     // Sabit Lot
input int      InpMaxOrders       = 1;        // Max Basamak Sayısı (10$ için Grid KAPALI)
input int      InpStepPips        = 15;       // Adım Aralığı (Pips)
input int      InpSL_Pips         = 20;       // Stop Loss (Pips)
input int      InpTP_Pips         = 50;       // Take Profit (Pips)
input int      InpExpirationHrs   = 4;        // Bekleyen Emir Ömrü (Saat)

//--- 4. STRATEJİ MOTORU
input group "=== 4. STRATEGY ENGINE ==="
input ENUM_TIMEFRAMES HigherTF    = PERIOD_M15; // MTF Onayı (Hızlandırıldı: H4 -> M15)
input int      MainTrend_MA       = 200;       // Ana Trend Filtresi (HMA Kullanılacak)
input int      InpHMA_Fast        = 20;        // HMA Cross Hızlı Periyot (Mod 2)
input int      InpHMA_Slow        = 50;        // HMA Cross Yavaş Periyot (Mod 2)
input int      Regime_Lookback    = 50;        // Volatilite Ortalaması İçin Bar Sayısı
input double   Vol_Explosion_Mul  = 1.8;       // Volatilite Patlama Çarpanı

//--- 5. AMA AYARLARI (v30)
input group "=== 5. AMA SETTINGS (v30) ==="
input int      InpAMA_Period      = 50;        // AMA Periyodu
input int      InpAMA_Fast        = 5;         // AMA Hızlı Periyot
input int      InpAMA_Slow        = 100;       // AMA Yavaş Periyot

//--- 6. GÜVENLİK VE STRES TESTİ
input group "=== 6. SAFETY & STRESS ==="
input int      InpMaxSpreadPips   = 6;        // Max Spread
input bool     InpUseTimeFilter   = false;    // Zaman Filtresi (Test için KAPALI)
input int      InpStartHour       = 8;        // Başlangıç
input int      InpEndHour         = 20;       // Bitiş
input bool     StressTest_Mode    = false;    // STRES TESTİ (Slippage Simülasyonu)
input int      Simulated_Slippage = 10;       // Simüle Kayma (Points)

//--- 7. OPERASYONEL
input group "=== 7. OPS & MANAGEMENT ==="
input bool     InpUseBreakeven    = true;     // Breakeven Kullan
input bool     InpUseTrailing     = true;     // Trailing Stop (İzleyen Stop) Kullan
input int      InpTrailingStart   = 10;       // Trailing Başlangıç (Pips)
input int      InpTrailingStep    = 5;        // Trailing Adım (Pips)
input bool     InpUseSmartPartial = true;     // Akıllı Kısmi Kapama
input bool     InpManageManual    = true;     // Manuel İşlemleri de Yönet
input bool     InpMultiOrder      = true;     // v30: Çoklu Emir Aç
input int      InpMaxOpenOrders   = 5;        // v30: Max Açık Emir Sayısı
input bool     InpCancelOnReverse = true;     // v30: Yön Değişince Bekleyenleri Sil

//--- 7. AI & HABER
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
input bool     InpStrictInitChecks     = true;     // Başlangıçta Sıkı Veri Kontrolü

//--- 9. AGGRESSİF STRATEDİ (v29)
input group "=== 9. AGGRESSIVE MODE (v29) ==="
input bool     InpUseReverse       = true;      // Zarar Sonrası Yön Değiştir
input bool     InpUseScaleUp       = true;      // Kâr Sonrası Lot Artır
input double   InpScaleUpMultiplier = 1.5;      // Scale Up Çarpanı (%50 artış)
input int      InpWinStreakForScale = 2;        // Kaç Üst Üste Kâr Scale Up Tetikler

//--- 10. TEST & DEBUG
input group "=== 10. TEST & DEBUG (v26) ==="
input bool     InpTestMode             = false;    // Test Modu (Başlangıçta İşlem Aç)
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
   int               m_dayOfYear;

public:
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
         if(ticket > 0 && HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
         {
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

   datetime          m_lastSignalTime;

public:
   CSignalEngine() : 
      m_hFrac(INVALID_HANDLE), 
      m_hBands(INVALID_HANDLE), 
      m_hADX(INVALID_HANDLE),
      m_hWMA_Half(INVALID_HANDLE),
      m_hWMA_Full(INVALID_HANDLE),
      m_hmaPeriod(0),
      m_hHMA_Fast_Half(INVALID_HANDLE),
      m_hHMA_Fast_Full(INVALID_HANDLE),
      m_hHMA_Slow_Half(INVALID_HANDLE),
      m_hHMA_Slow_Full(INVALID_HANDLE),
      m_hAMA(INVALID_HANDLE),
      m_lastSignalTime(0) {}
   
   ~CSignalEngine() 
   { 
      ReleaseHandles();
   }
   
   void ReleaseHandles()
   {
      if(m_hFrac != INVALID_HANDLE) { IndicatorRelease(m_hFrac); }
      if(m_hBands != INVALID_HANDLE) { IndicatorRelease(m_hBands); }
      if(m_hADX != INVALID_HANDLE) { IndicatorRelease(m_hADX); }
      if(m_hWMA_Half != INVALID_HANDLE) { IndicatorRelease(m_hWMA_Half); }
      if(m_hWMA_Full != INVALID_HANDLE) { IndicatorRelease(m_hWMA_Full); }
      
      if(m_hHMA_Fast_Half != INVALID_HANDLE) { IndicatorRelease(m_hHMA_Fast_Half); }
      if(m_hHMA_Fast_Full != INVALID_HANDLE) { IndicatorRelease(m_hHMA_Fast_Full); }
      if(m_hHMA_Slow_Half != INVALID_HANDLE) { IndicatorRelease(m_hHMA_Slow_Half); }
      if(m_hHMA_Slow_Full != INVALID_HANDLE) { IndicatorRelease(m_hHMA_Slow_Full); }
      
      // v30: AMA Release
      if(m_hAMA != INVALID_HANDLE) { IndicatorRelease(m_hAMA); }
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
      if(PositionsTotal() > 0 || OrdersTotal() > 0) 
         return;

      int count = CalculateSafeOrderCount(direction);
      if(count <= 0) 
         return;

      // --- DİNAMİK LOT TEKRAR HESAP ---
      double lotToUse = InpFixedLot;
      if(InpUseDynamicLot)
      {
         int hATR = iATR(_Symbol, PERIOD_CURRENT, 14);
         double atrVal[];
         ArraySetAsSeries(atrVal, true);
         if(CopyBuffer(hATR, 0, 0, 1, atrVal) == 1)
         {
            if(atrVal[0] > 0.0020) 
            {
               lotToUse = InpFixedLot / 2.0;
               double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
               if(lotToUse < minLot) lotToUse = minLot;
            }
         }
         IndicatorRelease(hATR);
      }
      
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
      double basePrice = (direction == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      
      if(StressTest_Mode)
      {
         double slip = Simulated_Slippage * point;
         basePrice += (direction == 1) ? slip : -slip;
      }

      datetime expiration = TimeCurrent() + (InpExpirationHrs * 3600);
      double stepSize = CPriceEngine::PipToPoints(InpStepPips);
      double slSize   = CPriceEngine::PipToPoints(InpSL_Pips);
      double tpSize   = CPriceEngine::PipToPoints(InpTP_Pips);

      for(int i = 0; i < count; i++)
      {
         double entry = 0, sl = 0, tp = 0;
         
         if(direction == 1) // BUY
         {
            entry = basePrice + ((i + 1) * stepSize);
            sl    = entry - slSize;
            tp    = entry + tpSize;
            
            if(!CPriceEngine::CheckStopLevel(entry, sl, tp, 1)) 
               continue;
            
            CPriceEngine::EnforceRequestInterval(); // Anti-Spam
            
            if(!m_trade.BuyStop(lotToUse, NormalizeDouble(entry, digits), _Symbol, 
               NormalizeDouble(sl, digits), NormalizeDouble(tp, digits), 
               ORDER_TIME_SPECIFIED, expiration, "OmegaBuy_" + IntegerToString(i)))
            {
               // --- DETAYLI HATA LOGLAMA (v26) ---
               Print("❌ BuyStop Hatası [#", i, "]: ", m_trade.ResultRetcodeDescription());
               
               if(m_trade.ResultRetcode() == 10014) // TRADE_RETCODE_NO_MONEY
               {
                  Print("💰 Yetersiz bakiye nedeniyle grid sonlandırıldı.");
                  break;
               }
            }
            else
            {
               g_tradesTodayCount++; // İşlem sayacını artır
               Print("✅ BuyStop [#", i, "] başarıyla açıldı. Fiyat: ", entry);
            }
         }
         else // SELL
         {
            entry = basePrice - ((i + 1) * stepSize);
            sl    = entry + slSize;
            tp    = entry - tpSize;
            
            if(!CPriceEngine::CheckStopLevel(entry, sl, tp, -1)) 
               continue;
            
            CPriceEngine::EnforceRequestInterval(); // Anti-Spam
            
            if(!m_trade.SellStop(lotToUse, NormalizeDouble(entry, digits), _Symbol, 
               NormalizeDouble(sl, digits), NormalizeDouble(tp, digits), 
               ORDER_TIME_SPECIFIED, expiration, "OmegaSell_" + IntegerToString(i)))
            {
               // --- DETAYLI HATA LOGLAMA (v26) ---
               Print("❌ SellStop Hatası [#", i, "]: ", m_trade.ResultRetcodeDescription());
               
               if(m_trade.ResultRetcode() == 10014) // TRADE_RETCODE_NO_MONEY
               {
                  Print("💰 Yetersiz bakiye nedeniyle grid sonlandırıldı.");
                  break;
               }
            }
            else
            {
               g_tradesTodayCount++; // İşlem sayacını artır
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
   
   // Günlük sayaç sıfırlama
   g_today_start = iTime(_Symbol, PERIOD_D1, 0);
   g_tradesTodayCount = 0;
   
   Print("=");
   Print("TITANIUM OMEGA v27.0 ULTIMATE BAŞLATILDI");
   Print("Bakiye: ", AccountInfoDouble(ACCOUNT_BALANCE), " ", AccountInfoString(ACCOUNT_CURRENCY));
   Print("Strateji: ", InpStrategyMode == STRATEGY_FRACTAL_REVERSAL ? "Fractal Reversal" : "HMA Cross");
   Print("Kurtarma Modu: ", InpUseRecovery ? "Aktif (Tetik: %" + DoubleToString(InpRecoveryTrigger, 0) + ")" : "Pasif");
   Print("Fon Yönetimi: ", (InpDailyProfitTarget > 0 || InpWeeklyProfitTarget > 0) ? "Aktif" : "Pasif");
   Print("=");
   
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
   
   // Reverse yok ise normal sinyal
   if(signal == 0)
   {
      ENUM_MARKET_REGIME regime = Signal.GetRegime();
      signal = Signal.GetDirection(regime);
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
   
   // v30 - Çoklu Emir Açma
   if(safeToOpen && signal != 0)
   {
      int currentOpenOrders = PositionsTotal() + OrdersTotal();
      int maxOrders = InpMultiOrder ? InpMaxOpenOrders : 1;
      
      if(currentOpenOrders < maxOrders)
      {
         g_lastSignalDirection = signal; // Son sinyal yönünü kaydet
         Executor.PlaceGrid(signal);
      }
   }
   
   // v30 Dashboard - AMA + Multi Order Gösterim
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
      
      // Strateji adı
      string stratName = "FRACTAL";
      if(InpStrategyMode == STRATEGY_HMA_CROSS) stratName = "HMA CROSS";
      else if(InpStrategyMode == STRATEGY_AMA_CROSS) stratName = "AMA CROSS";
      
      string dash = "+============================================+\n";
      dash += "|   TITANIUM OMEGA v30.0 AMA + MULTI ORDER   |\n";
      dash += "+============================================+\n";
      dash += "| DURUM    : " + recoveryStatus + scaleStatus + (safeToOpen ? "[AKTIF]" : "[BEKLIYOR]") + "\n";
      dash += "| STRATEJI : " + stratName + "\n";
      dash += "| NEDEN    : " + g_StateReason + "\n";
      dash += "+--------------------------------------------+\n";
      dash += "| PIYASA   : " + regimeText + "\n";
      dash += "| DRAWDOWN : %" + DoubleToString(Recovery.GetDrawdownPercent(), 1) + "\n";
      dash += "+--------------------------------------------+\n";
      dash += "| POZISYON : " + IntegerToString(PositionsTotal()) + "/" + IntegerToString(InpMaxOpenOrders) + "\n";
      dash += "| BEKLEYEN : " + IntegerToString(OrdersTotal()) + "\n";
      dash += "| LOT CARP.: x" + DoubleToString(g_currentLotMultiplier, 1) + "\n";
      dash += "+--------------------------------------------+\n";
      dash += "| GUNLUK P/L: $" + DoubleToString(Fund.GetDailyProfit(), 2) + "\n";
      dash += "| WIN RATE  : %" + DoubleToString(Fund.GetWinRate(), 1) + "\n";
      dash += "| TRADES    : " + IntegerToString(g_tradesTodayCount) + (InpMaxTradesPerDay > 0 ? "/" + IntegerToString(InpMaxTradesPerDay) : " (SINIRSIZ)") + "\n";
      dash += "+============================================+";
      
      Comment(dash);
   }
   else
   {
      Comment("");
   }
}
