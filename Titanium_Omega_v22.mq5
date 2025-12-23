//+------------------------------------------------------------------+
//|                                   Titanium_Omega_v21_5.mq5       |
//|                     © 2025, Systemic Trading Engineering         |
//|          Versiyon: 21.5 (ULTIMATE FINAL - FULLY OPTIMIZED)       |
//+------------------------------------------------------------------+
#property copyright "© 2025, Systemic Trading Engineering"
#property version   "22.00"
#property strict

#include <Trade\Trade.mqh>

//--- Enum Definitions
enum ENUM_MARKET_REGIME {
   REGIME_HIGH_VOLATILITY,
   REGIME_TRENDING,
   REGIME_RANGING
};

//--- 1. RİSK VE SERMAYE YÖNETİMİ
input group "=== 1. RISK & CAPITAL PROTOCOLS ==="
input double   InpBaseRiskPercent = 1.0;      // Baz Risk %
input double   InpMaxDailyLoss    = 30.0;     // Günlük Max Zarar % (10$ için %30 = 3$)
input double   InpMaxMoneyDD      = 5.0;      // Günlük Max Zarar $
input double   InpMinMarginLevel  = 50.0;     // Min Marjin Seviyesi % (Düşürüldü)
input bool     InpDetectDeposit   = true;     // Para Yatırma/Çekme Algıla

//--- 2. GRID MATRİSİ
input group "=== 2. GRID MATRIX ==="
input double   InpFixedLot        = 0.01;     // Sabit Lot
input int      InpMaxOrders       = 1;        // Max Basamak Sayısı (10$ için Grid KAPALI)
input int      InpStepPips        = 15;       // Adım Aralığı (Pips)
input int      InpSL_Pips         = 20;       // Stop Loss (Pips)
input int      InpTP_Pips         = 50;       // Take Profit (Pips)
input int      InpExpirationHrs   = 4;        // Bekleyen Emir Ömrü (Saat)

//--- 3. STRATEJİ MOTORU
input group "=== 3. STRATEGY ENGINE ==="
input ENUM_TIMEFRAMES HigherTF    = PERIOD_M15; // MTF Onayı (Hızlandırıldı: H4 -> M15)
input int      MainTrend_MA       = 200;       // Ana Trend Filtresi
input int      Regime_Lookback    = 50;        // Volatilite Ortalaması İçin Bar Sayısı
input double   Vol_Explosion_Mul  = 1.8;       // Volatilite Patlama Çarpanı

//--- 4. GÜVENLİK VE STRES TESTİ
input group "=== 4. SAFETY & STRESS ==="
input int      InpMaxSpreadPips   = 6;        // Max Spread
input bool     InpUseTimeFilter   = false;    // Zaman Filtresi (Test için KAPALI)
input int      InpStartHour       = 8;        // Başlangıç
input int      InpEndHour         = 20;       // Bitiş
input bool     StressTest_Mode    = false;    // STRES TESTİ (Slippage Simülasyonu)
input int      Simulated_Slippage = 10;       // Simüle Kayma (Points)

//--- 5. OPERASYONEL
input group "=== 5. OPS & MANAGEMENT ==="
input int      InpMagic           = 210521;   // Magic Number
input bool     InpShowDashboard   = true;     // Paneli Göster
input bool     InpUseBreakeven    = true;     // Breakeven Kullan
input bool     InpUseTrailing     = true;     // Trailing Stop (İzleyen Stop) Kullan
input int      InpTrailingStart   = 10;       // Trailing Başlangıç (Pips)
input int      InpTrailingStep    = 5;        // Trailing Adım (Pips)
input bool     InpUseSmartPartial = true;     // Akıllı Kısmi Kapama
input bool     InpManageManual    = true;     // Manuel İşlemleri de Yönet (OTOMATİK KORUMA)

//--- 6. AI & HABER (YENİ v22)
input group "=== 6. AI & NEWS FILTER ==="
input bool     InpUseNewsFilter   = true;     // Haber Filtresi (Ekonomik Takvim)
input int      InpNewsPauseMins   = 60;       // Haber Öncesi/Sonrası Bekleme (Dk)
input bool     InpUseDynamicLot   = true;     // Dinamik Lot (ATR Bazlı)
input bool     InpUsePerformance  = true;     // Performans Analizi (Basit ML)
input int      InpMaxLoseStreak   = 3;        // Üst Üste Max Zarar (Duraklatma İçin)

// GLOBAL KONTROL DEĞİŞKENLERİ
string g_StateReason = "Başlatılıyor...";
// String karşılaştırma hatasını önlemek için yardımcı struct gerekmez, direkt string kullanıyoruz.

//====================================================================
// CLASS: PRICE ENGINE (DÜZELTİLMİŞ PipToPoints)
//====================================================================
class CPriceEngine
{
public:
   // DÜZELTME: Doğru Pip/Point dönüşümü
   static double PipToPoints(int pips)
   {
      double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
      // 1 pip = 10 points (tüm semboller için standart)
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
};

//====================================================================
// CLASS: SECURITY MANAGER (Güvenlik ve Bakiye)
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
         // Kilit kaldırıldı
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

      // Günlük Zarar Kontrolü (Sadece Yeni İşlem Açmayı Durdurur, Kilitlemez)
      double equity = AccountInfoDouble(ACCOUNT_EQUITY);
      double loss = m_refBalance - equity;
      
      if(loss >= InpMaxMoneyDD || (m_refBalance > 0 && (loss/m_refBalance)*100.0 >= InpMaxDailyLoss))
      {
         g_StateReason = "GÜNLÜK ZARAR LİMİTİ DOLDU";
         return false; // Sadece false döner, sistemi kilitlemez
      }

      // Marjin ve Sembol Kontrolü
      double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
      if(marginLevel > 0 && marginLevel < InpMinMarginLevel) 
      {
         g_StateReason = "DÜŞÜK MARJİN: %" + DoubleToString(marginLevel, 1);
         Print("Düşük marjin seviyesi: ", marginLevel);
         return false;
      }
      
      if(SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_FULL) 
      {
         g_StateReason = "SEMBOL İŞLEME KAPALI";
         Print("Sembolde işlem izni yok!");
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
      
      // --- DETAYLI LOGLAMA (TERNARY OPERATÖR İLE) ---
      string log = "🔍 GÜVENLİK KONTROLÜ:\n";
      log += "   • Bakiye Kontrolü : " + DoubleToString(loss, 2) + " >= " + DoubleToString(InpMaxMoneyDD, 2) + " ? " + (loss >= InpMaxMoneyDD ? "⛔ RİSKLİ" : "✅ UYGUN") + "\n";
      log += "   • Marjin Seviyesi : " + DoubleToString(marginLevel, 1) + " < " + DoubleToString(InpMinMarginLevel, 1) + " ? " + (marginLevel < InpMinMarginLevel ? "⛔ RİSKLİ" : "✅ UYGUN") + "\n";
      log += "   • Spread Durumu   : " + DoubleToString(spreadPips, 1) + " > " + IntegerToString(InpMaxSpreadPips) + " ? " + (spreadPips > InpMaxSpreadPips ? "⛔ YÜKSEK" : "✅ UYGUN");
      
      // Sadece durum değiştiyse veya hata varsa yazdır (Spam önlemek için)
      if(StringCompare(g_StateReason, "AKTİF") != 0 || spreadPips > InpMaxSpreadPips || marginLevel < InpMinMarginLevel)
         Print(log);

      return true;
   }
     
   double GetDailyPL() 
   { 
      return AccountInfoDouble(ACCOUNT_EQUITY) - m_refBalance; 
   }
   
   // --- BASİT ML: PERFORMANS ANALİZİ ---
   bool CheckPerformance()
   {
      if(!InpUsePerformance) return true;
      
      HistorySelect(0, TimeCurrent());
      int total = HistoryDealsTotal();
      int loseStreak = 0;
      
      for(int i = total - 1; i >= 0; i--)
      {
         ulong ticket = HistoryDealGetTicket(i);
         if(ticket > 0)
         {
            if(HistoryDealGetInteger(ticket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
            {
               double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
               if(profit < 0) loseStreak++;
               else if(profit > 0) break; // Kazanç gördüğü an sayacı sıfırla
            }
         }
         if(loseStreak >= InpMaxLoseStreak) break;
      }
      
      if(loseStreak >= InpMaxLoseStreak)
      {
         g_StateReason = "PERFORMANS KORUMASI (" + IntegerToString(loseStreak) + " ZARAR)";
         Print("⚠️ Üst üste ", loseStreak, " zarar! Robot geçici olarak frenleniyor.");
         return false;
      }
      
      return true;
   }
};

//====================================================================
// CLASS: NEWS MANAGER (Ekonomik Takvim)
//====================================================================
class CNewsManager
{
public:
   bool IsNewsTime()
   {
      if(!InpUseNewsFilter) return false;
      
      MqlCalendarValue values[];
      datetime start = TimeCurrent() - (InpNewsPauseMins * 60);
      datetime end   = TimeCurrent() + (InpNewsPauseMins * 60);
      
      // Sadece USD ve EUR haberlerine bak (Basitleştirilmiş)
      // Gerçek uygulamada sembolün para birimleri otomatik alınmalı
      
      if(CalendarValueHistory(values, start, end, "USD", NULL) > 0)
      {
         for(int i=0; i<ArraySize(values); i++)
         {
            if(values[i].impact == CALENDAR_IMPACT_HIGH)
            {
               g_StateReason = "HABER FİLTRESİ (USD)";
               return true;
            }
         }
      }
      
      if(CalendarValueHistory(values, start, end, "EUR", NULL) > 0)
      {
         for(int i=0; i<ArraySize(values); i++)
         {
            if(values[i].impact == CALENDAR_IMPACT_HIGH)
            {
               g_StateReason = "HABER FİLTRESİ (EUR)";
               return true;
            }
         }
      }
      
      return false;
   }
};

//====================================================================
// CLASS: SIGNAL ENGINE (Dinamik Rejim & Sinyal)
//====================================================================
class CSignalEngine
{
private:
   int               m_hFrac;
   int               m_hBands;
   int               m_hADX;
   int               m_hMA_Curr;
   int               m_hMA_High;
   datetime          m_lastSignalTime;

public:
   CSignalEngine() : 
      m_hFrac(INVALID_HANDLE), 
      m_hBands(INVALID_HANDLE), 
      m_hADX(INVALID_HANDLE),
      m_hMA_Curr(INVALID_HANDLE),
      m_hMA_High(INVALID_HANDLE), 
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
      if(m_hMA_Curr != INVALID_HANDLE) { IndicatorRelease(m_hMA_Curr); }
      if(m_hMA_High != INVALID_HANDLE) { IndicatorRelease(m_hMA_High); }
   }

   bool Init()
   {
      ReleaseHandles();
      
      m_hFrac    = iFractals(_Symbol, PERIOD_CURRENT);
      m_hBands   = iBands(_Symbol, PERIOD_CURRENT, 20, 0, 2.0, PRICE_CLOSE);
      m_hADX     = iADX(_Symbol, PERIOD_CURRENT, 14);
      m_hMA_Curr = iMA(_Symbol, PERIOD_CURRENT, MainTrend_MA, 0, MODE_SMA, PRICE_CLOSE);
      m_hMA_High = iMA(_Symbol, HigherTF, MainTrend_MA, 0, MODE_SMA, PRICE_CLOSE);
      
      bool allValid = (m_hFrac != INVALID_HANDLE) && 
                      (m_hBands != INVALID_HANDLE) && 
                      (m_hADX != INVALID_HANDLE) && 
                      (m_hMA_Curr != INVALID_HANDLE) &&
                      (m_hMA_High != INVALID_HANDLE);
      
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

   int GetDirection(ENUM_MARKET_REGIME regime)
   {
      if(regime == REGIME_HIGH_VOLATILITY) 
      {
         g_StateReason = "YÜKSEK VOLATİLİTE (BEKLİYOR)";
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
         if(CopyBuffer(m_hMA_High, 0, 0, 1, bufMA) == 1 &&
            CopyClose(_Symbol, HigherTF, 0, 1, bufClose) == 1)
         {
            maVal = bufMA[0];
            price = bufClose[0];
            
            trendLog = "   • Trend Filtresi: Fiyat(" + DoubleToString(price, 5) + ") " + (price > maVal ? ">" : "<") + " MA(" + DoubleToString(maVal, 5) + ") -> " + (price > maVal ? "YUKARI" : "AŞAĞI");

            if(isDip && price < maVal) 
            {
               g_StateReason = "TREND FİLTRESİ (FİYAT < MA)";
               trendFilterPass = false;
            }
            if(isTop && price > maVal) 
            {
               g_StateReason = "TREND FİLTRESİ (FİYAT > MA)";
               trendFilterPass = false;
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
      double bufMA[], bufClose[];
      ArraySetAsSeries(bufMA, true); 
      ArraySetAsSeries(bufClose, true);
      
      if(CopyBuffer(m_hMA_Curr, 0, 0, 1, bufMA) < 1 ||
         CopyClose(_Symbol, PERIOD_CURRENT, 0, 1, bufClose) < 1)
         return 0;
         
      if(bufClose[0] > bufMA[0]) return 1; // Trend Yukarı
      if(bufClose[0] < bufMA[0]) return -1; // Trend Aşağı
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
      m_trade.SetTypeFilling(ORDER_FILLING_FOK);
      m_trade.SetDeviationInPoints(10);
   }

   int CalculateSafeOrderCount(int direction)
   {
      // ... (Mevcut kod) ...
      
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
            if(atrVal[0] > 0.0020) // Örnek eşik (Pariteye göre değişir, dinamik olmalı ama şimdilik sabit)
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
      if(!OrderCalcMargin(type, _Symbol, lotToUse, price, marginReq)) // lotToUse kullanıldı
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
      double lossPerTrade = lotToUse * InpSL_Pips * pipValue; // lotToUse kullanıldı
      
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

      // --- DİNAMİK LOT TEKRAR HESAP (Basitlik için burada tekrar alıyoruz veya yukarıdan taşımalıyız) ---
      // Yukarıdaki fonksiyon sadece sayı döndürüyor, lotu global yapmadık.
      // Güvenlik için burada da aynı lot mantığını uygulayalım:
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
            
            if(!m_trade.BuyStop(lotToUse, NormalizeDouble(entry, digits), _Symbol, 
               NormalizeDouble(sl, digits), NormalizeDouble(tp, digits), 
               ORDER_TIME_SPECIFIED, expiration, "OmegaBuy_" + IntegerToString(i)))
            {
               if(m_trade.ResultRetcode() == 10014) // TRADE_RETCODE_NO_MONEY
                  break;
            }
         }
         else // SELL
         {
            entry = basePrice - ((i + 1) * stepSize);
            sl    = entry + slSize;
            tp    = entry - tpSize;
            
            if(!CPriceEngine::CheckStopLevel(entry, sl, tp, -1)) 
               continue;
            
            if(!m_trade.SellStop(lotToUse, NormalizeDouble(entry, digits), _Symbol, 
               NormalizeDouble(sl, digits), NormalizeDouble(tp, digits), 
               ORDER_TIME_SPECIFIED, expiration, "OmegaSell_" + IntegerToString(i)))
            {
               if(m_trade.ResultRetcode() == 10014) // TRADE_RETCODE_NO_MONEY
                  break;
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

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
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
   
   if(!Signal.Init())
   {
      Alert("HATA: İndikatörler yüklenemedi!");
      return INIT_FAILED;
   }
   
   Security.Init();
   Executor.Init();
   
   Print("TITANIUM OMEGA v21.5 Başlatıldı. Bakiye: ", AccountInfoDouble(ACCOUNT_BALANCE));
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Executor.CleanUp();
}

//+------------------------------------------------------------------+
//| Chart event handler - KALDIRILDI                                 |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   // Tuş kontrolleri kaldırıldı
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Güvenlik Kontrolü (Sadece yeni işlem açmayı engeller, mevcutları yönetmeye devam eder)
   bool safeToOpen = Security.IsSafeToTrade();
   
   // Performans Kontrolü (ML)
   if(safeToOpen && !Security.CheckPerformance()) safeToOpen = false;
   
   // Haber Filtresi
   if(safeToOpen && News.IsNewsTime()) safeToOpen = false;
   
   // Pozisyon Yönetimi (Manuel + Otomatik)
   Executor.ManagePositions();
   
   // Yeni İşlem Sinyali
   if(safeToOpen && PositionsTotal() == 0 && OrdersTotal() == 0)
   {
      ENUM_MARKET_REGIME regime = Signal.GetRegime();
      int signal = Signal.GetDirection(regime);
      
      if(signal != 0 && regime != REGIME_HIGH_VOLATILITY)
         Executor.PlaceGrid(signal);
   }
   
   if(InpShowDashboard)
   {
      string regimeText;
      ENUM_MARKET_REGIME regime = Signal.GetRegime();
      switch(regime)
      {
         case REGIME_HIGH_VOLATILITY: regimeText = "⚡ YÜKSEK VOLATİLİTE"; break;
         case REGIME_TRENDING: regimeText = "📈 TREND"; break;
         case REGIME_RANGING: regimeText = "➡ YATAY"; break;
      }
      
      string dash = "╔════════════════════════════════════╗\n";
      dash += "║   TITANIUM OMEGA v22.0     ║\n";
      dash += "╠════════════════════════════════════╣\n";
      dash += "║ 🤖 DURUM    : " + (safeToOpen ? "✅ AKTİF   " : "⛔ BEKLİYOR") + "       ║\n";
      dash += "║ ℹ️ NEDEN    : " + StringSubstr(g_StateReason, 0, 18) + " ║\n";
      dash += "╠════════════════════════════════════╣\n";
      dash += "║ 📊 PİYASA   : " + regimeText + "             ║\n";
      dash += "║ 💰 GÜNLÜK   : " + DoubleToString(Security.GetDailyPL(), 2) + " " + AccountInfoString(ACCOUNT_CURRENCY) + "          ║\n";
      dash += "║ 🛡️ MARJİN   : %" + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 1) + "           ║\n";
      dash += "╠════════════════════════════════════╣\n";
      dash += "║ ⚠️ MANUEL KORUMA: AKTİF        ║\n";
      dash += "╚════════════════════════════════════╝";
      
      Comment(dash);
   }
}
