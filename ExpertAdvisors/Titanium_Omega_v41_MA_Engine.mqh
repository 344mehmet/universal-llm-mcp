
//====================================================================
// CLASS: MA MASTER ENGINE (v41) - SMA+EMA Power System
//====================================================================
class CMAMasterEngine
{
private:
   int m_hSMA_Trend;     // 200 SMA
   int m_hSMA_Pullback;  // 50 SMA
   int m_hEMA_Fast;      // 8 EMA
   int m_hEMA_Slow;      // 21 EMA

public:
   CMAMasterEngine() : m_hSMA_Trend(INVALID_HANDLE), m_hSMA_Pullback(INVALID_HANDLE),
                       m_hEMA_Fast(INVALID_HANDLE), m_hEMA_Slow(INVALID_HANDLE) {}

   ~CMAMasterEngine()
   {
      if(m_hSMA_Trend != INVALID_HANDLE) IndicatorRelease(m_hSMA_Trend);
      if(m_hSMA_Pullback != INVALID_HANDLE) IndicatorRelease(m_hSMA_Pullback);
      if(m_hEMA_Fast != INVALID_HANDLE) IndicatorRelease(m_hEMA_Fast);
      if(m_hEMA_Slow != INVALID_HANDLE) IndicatorRelease(m_hEMA_Slow);
   }

   bool Init()
   {
      m_hSMA_Trend = iMA(_Symbol, PERIOD_CURRENT, InpTrend_SMA, 0, MODE_SMA, PRICE_CLOSE);
      m_hSMA_Pullback = iMA(_Symbol, PERIOD_CURRENT, InpPullback_SMA, 0, MODE_SMA, PRICE_CLOSE);
      m_hEMA_Fast = iMA(_Symbol, PERIOD_CURRENT, InpSignal_EMA_Fast, 0, MODE_EMA, PRICE_CLOSE);
      m_hEMA_Slow = iMA(_Symbol, PERIOD_CURRENT, InpSignal_EMA_Slow, 0, MODE_EMA, PRICE_CLOSE);

      bool valid = (m_hSMA_Trend != INVALID_HANDLE && m_hSMA_Pullback != INVALID_HANDLE &&
                    m_hEMA_Fast != INVALID_HANDLE && m_hEMA_Slow != INVALID_HANDLE);
      
      if(valid) Print("✅ v41: MA Master Engine Loaded (SMA 200/50 + EMA 8/21)");
      else Print("❌ v41: MA Master Indicators Failed!");
      
      return valid;
   }

   // 1. Ana Trendi Belirle (200 SMA)
   // 1 = Yükseliş, -1 = Düşüş, 0 = Nötr
   int GetMainTrend()
   {
      double smaTrend[];
      ArraySetAsSeries(smaTrend, true);
      CopyBuffer(m_hSMA_Trend, 0, 0, 1, smaTrend);
      
      double price = iClose(_Symbol, PERIOD_CURRENT, 0);
      
      if(price > smaTrend[0]) return 1;  // Bullish
      if(price < smaTrend[0]) return -1; // Bearish
      return 0;
   }

   // 2. EMA Cross Sinyali (8/21)
   // 1 = Golden Cross, -1 = Death Cross, 0 = Yok
   int GetEMACrossSignal()
   {
      double fast[2], slow[2];
      ArraySetAsSeries(fast, true);
      ArraySetAsSeries(slow, true);
      
      CopyBuffer(m_hEMA_Fast, 0, 0, 2, fast);
      CopyBuffer(m_hEMA_Slow, 0, 0, 2, slow);
      
      // Golden Cross (Alış)
      if(fast[1] <= slow[1] && fast[0] > slow[0]) return 1;
      
      // Death Cross (Satış)
      if(fast[1] >= slow[1] && fast[0] < slow[0]) return -1;
      
      // Sinyal Devam Ediyor mu? (Trend İçi Giriş)
      if(fast[0] > slow[0]) return 2; // Alış bölgesinde
      if(fast[0] < slow[0]) return -2; // Satış bölgesinde
      
      return 0;
   }

   // 3. Pullback Fırsatı (50 SMA)
   // Trend güçlü ama fiyat 50 SMA'ya değdi ve sekti
   int GetPullbackSignal(int mainTrend)
   {
      double smaPullback[2];
      double low[2], high[2], close[2];
      ArraySetAsSeries(smaPullback, true);
      ArraySetAsSeries(low, true);
      ArraySetAsSeries(high, true);
      ArraySetAsSeries(close, true);
      
      CopyBuffer(m_hSMA_Pullback, 0, 0, 2, smaPullback);
      CopyLow(_Symbol, PERIOD_CURRENT, 0, 2, low);
      CopyHigh(_Symbol, PERIOD_CURRENT, 0, 2, high);
      CopyClose(_Symbol, PERIOD_CURRENT, 0, 2, close);
      
      // BUY Pullback: Yükseliş trendinde, fiyat 50 SMA'ya düştü ama üzerinde kapandı
      if(mainTrend == 1)
      {
         // Önceki bar veya şu anki bar SMA'ya dokundu/yaklaştı
         // Ama Kapanış SMA'nın üzerinde (Destek çalıştı)
         if(low[0] <= smaPullback[0] && close[0] > smaPullback[0]) 
            return 1;
      }
      
      // SELL Pullback: Düşüş trendinde, fiyat 50 SMA'ya çıktı ama altında kapandı
      if(mainTrend == -1)
      {
         // Kapanış SMA'nın altında (Direnç çalıştı)
         if(high[0] >= smaPullback[0] && close[0] < smaPullback[0])
            return -1;
      }
      
      return 0;
   }

   // Kombine Master Sinyal
   int GetMasterSignal()
   {
      int trend = GetMainTrend();
      int emaSignal = GetEMACrossSignal();
      
      // Eğer ana trend yoksa işlem yok
      if(trend == 0) return 0;
      
      // 1. Durum: Güçlü Trend Başlangıcı (Cross + Trend Onayı)
      if(trend == 1 && emaSignal == 1) 
      {
         g_StateReason = "MA MASTER: BUY CROSS (200 SMA Onaylı)";
         return 1;
      }
      if(trend == -1 && emaSignal == -1) 
      {
         g_StateReason = "MA MASTER: SELL CROSS (200 SMA Onaylı)";
         return -1;
      }
      
      // 2. Durum: Pullback / Pyramiding Fırsatı
      if(InpPyramiding)
      {
         int pullback = GetPullbackSignal(trend);
         if(pullback == trend)
         {
            // Ekleme yapmadan önce mesafe kontrolü (Bunu grid class'ında da yapıyoruz ama burada sinyal üretelim)
            g_StateReason = "MA MASTER: PULLBACK FIRSATI (Ekleme)";
            return trend; // Trend yönünde sinyal gönder
         }
      }
      
      return 0;
   }
};
