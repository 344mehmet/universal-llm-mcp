//+------------------------------------------------------------------+
//|                                          CTrade_Complete_EA.mq5  |
//|                     © 2025, CTrade Sınıfı Tam Kullanım Örneği    |
//|                     Trade.mqh'deki TÜM metodlar burada           |
//+------------------------------------------------------------------+
//| Bu EA, MQL5 Standart Kütüphanesi'ndeki CTrade sınıfının          |
//| HER BİR metodunu, özelliğini ve yapısını kullanarak              |
//| kapsamlı bir trading sistemi oluşturur.                          |
//+------------------------------------------------------------------+
#property copyright "© 2025, CTrade Complete EA"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//====================================================================
// INCLUDE - Trade Kütüphanesi
//====================================================================
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>

//====================================================================
// ENUM TANIMLARI - CTrade'deki ENUM_LOG_LEVELS Karşılığı
//====================================================================
// CTrade içinde tanımlı: LOG_LEVEL_NO=0, LOG_LEVEL_ERRORS=1, LOG_LEVEL_ALL=2
enum ENUM_EA_LOG_LEVEL
  {
   EA_LOG_NONE   = 0,    // Hiç log yazma
   EA_LOG_ERRORS = 1,    // Sadece hatalar
   EA_LOG_ALL    = 2     // Tüm işlemler
  };

enum ENUM_DEMO_MODE
  {
   DEMO_POSITION_OPS,     // Pozisyon İşlemleri Demo
   DEMO_PENDING_OPS,      // Bekleyen Emir Demo
   DEMO_REQUEST_INFO,     // Request Bilgileri Demo
   DEMO_RESULT_INFO,      // Result Bilgileri Demo
   DEMO_CHECK_INFO,       // CheckResult Bilgileri Demo
   DEMO_FORMAT_FUNCS,     // Format Fonksiyonları Demo
   DEMO_ALL_FEATURES      // Tüm Özellikler
  };

//====================================================================
// INPUT PARAMETRELERİ
//====================================================================

//--- 1. ANA AYARLAR
input group "═══ 1. ANA TRADE AYARLARI ═══"
input ulong          InpMagicNumber    = 123456;        // 🎰 Magic Number (m_magic)
input ulong          InpDeviation      = 10;            // 📊 Slippage/Deviation (m_deviation)
input ENUM_ORDER_TYPE_FILLING InpFilling = ORDER_FILLING_FOK; // 📋 Filling Tipi (m_type_filling)
input bool           InpAsyncMode      = false;         // ⚡ Asenkron Mod (m_async_mode)
input ENUM_EA_LOG_LEVEL InpLogLevel    = EA_LOG_ALL;    // 📝 Log Seviyesi (m_log_level)

//--- 2. LOT VE RİSK
input group "═══ 2. LOT VE RİSK AYARLARI ═══"
input double         InpLotSize        = 0.01;          // 💰 İşlem Lot Miktarı
input double         InpSLPips         = 20.0;          // 🛑 Stop Loss (pip)
input double         InpTPPips         = 40.0;          // 🎯 Take Profit (pip)
input double         InpMaxRiskPercent = 2.0;           // ⚖️ Max Risk %

//--- 3. POZİSYON İŞLEMLERİ
input group "═══ 3. POZİSYON İŞLEMLERİ ═══"
input bool           InpEnablePositionOpen   = true;    // PositionOpen() Aktif
input bool           InpEnablePositionModify = true;    // PositionModify() Aktif
input bool           InpEnablePositionClose  = true;    // PositionClose() Aktif
input bool           InpEnableCloseBy        = true;    // PositionCloseBy() Aktif
input bool           InpEnableClosePartial   = true;    // PositionClosePartial() Aktif

//--- 4. BEKLEYEN EMİR İŞLEMLERİ
input group "═══ 4. BEKLEYEN EMİR İŞLEMLERİ ═══"
input bool           InpEnableOrderOpen      = true;    // OrderOpen() Aktif
input bool           InpEnableOrderModify    = true;    // OrderModify() Aktif
input bool           InpEnableOrderDelete    = true;    // OrderDelete() Aktif
input int            InpPendingDistPips      = 50;      // Bekleyen Emir Mesafesi (pip)

//--- 5. KISAYOL METODLARI
input group "═══ 5. KISAYOL METODLARI ═══"
input bool           InpUseBuy               = true;    // Buy() Kullan
input bool           InpUseSell              = true;    // Sell() Kullan
input bool           InpUseBuyLimit          = true;    // BuyLimit() Kullan
input bool           InpUseBuyStop           = true;    // BuyStop() Kullan
input bool           InpUseSellLimit         = true;    // SellLimit() Kullan
input bool           InpUseSellStop          = true;    // SellStop() Kullan

//--- 6. DEMO MODU
input group "═══ 6. DEMO VE TEST ═══"
input ENUM_DEMO_MODE InpDemoMode             = DEMO_ALL_FEATURES; // Demo Modu
input bool           InpShowAllRequestInfo   = true;    // Tüm Request Bilgilerini Göster
input bool           InpShowAllResultInfo    = true;    // Tüm Result Bilgilerini Göster
input bool           InpShowAllCheckInfo     = true;    // Tüm CheckResult Bilgilerini Göster
input bool           InpShowFormatFunctions  = true;    // Format Fonksiyonlarını Göster

//====================================================================
// GLOBAL DEĞİŞKENLER
//====================================================================

//--- Ana Trade Nesnesi - CTrade sınıfı instance'ı
CTrade            g_trade;                // Ana trade nesnesi

//--- Yardımcı Sınıf Nesneleri
CPositionInfo     g_positionInfo;         // Pozisyon bilgisi
COrderInfo        g_orderInfo;            // Emir bilgisi
CDealInfo         g_dealInfo;             // Deal bilgisi
CHistoryOrderInfo g_historyOrder;         // Geçmiş emir bilgisi

//--- CTrade'den çekilen yapılar (m_request, m_result, m_check_result karşılıkları)
MqlTradeRequest   g_lastRequest;          // Son request yapısı
MqlTradeResult    g_lastResult;           // Son result yapısı
MqlTradeCheckResult g_lastCheckResult;    // Son check result yapısı

//--- İstatistikler
int               g_totalBuyOrders     = 0;
int               g_totalSellOrders    = 0;
int               g_totalPendingOrders = 0;
int               g_totalModifications = 0;
int               g_totalClosures      = 0;
int               g_totalErrors        = 0;
double            g_totalProfit        = 0;

//--- Kontrol Değişkenleri
datetime          g_lastActionTime     = 0;
bool              g_isInitialized      = false;
string            g_lastErrorMsg       = "";

//====================================================================
// YARDIMCI FONKSİYONLAR
//====================================================================

//+------------------------------------------------------------------+
//| Pip'i Point'e Çevir                                              |
//+------------------------------------------------------------------+
double PipsToPoints(double pips)
  {
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int multiplier = (digits == 3 || digits == 5) ? 10 : 1;
   return pips * multiplier * point;
  }

//+------------------------------------------------------------------+
//| Point'i Pip'e Çevir                                              |
//+------------------------------------------------------------------+
double PointsToPips(double points)
  {
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   int multiplier = (digits == 3 || digits == 5) ? 10 : 1;
   if(multiplier * point == 0) return 0;
   return points / (multiplier * point);
  }

//+------------------------------------------------------------------+
//| Fiyatı Normalize Et                                              |
//+------------------------------------------------------------------+
double NormalizePrice(double price)
  {
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   return NormalizeDouble(price, digits);
  }

//+------------------------------------------------------------------+
//| Lot Miktarını Normalize Et                                       |
//+------------------------------------------------------------------+
double NormalizeLot(double lot)
  {
   double minLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double stepLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   lot = MathFloor(lot / stepLot) * stepLot;
   lot = MathMax(minLot, MathMin(lot, maxLot));
   
   return NormalizeDouble(lot, 2);
  }

//+------------------------------------------------------------------+
//| Log Yaz - Log seviyesine göre                                    |
//+------------------------------------------------------------------+
void WriteLog(string message, int level = 2)
  {
   if(InpLogLevel >= level)
     {
      Print(message);
     }
  }

//+------------------------------------------------------------------+
//| Ayırıcı Çizgi Yazdır                                             |
//+------------------------------------------------------------------+
void PrintSeparator(string title = "")
  {
   if(title == "")
      Print("════════════════════════════════════════════════════════════════");
   else
      Print("═══════════════ ", title, " ═══════════════");
  }

//====================================================================
// OnInit - EA BAŞLATMA
// CTrade Ayar Metodlarının TÜMÜ burada kullanılıyor:
// - SetExpertMagicNumber() : m_magic değişkenini ayarlar
// - SetDeviationInPoints() : m_deviation değişkenini ayarlar
// - SetTypeFilling()       : m_type_filling değişkenini ayarlar
// - SetMarginMode()        : m_margin_mode değişkenini ayarlar
// - SetAsyncMode()         : m_async_mode değişkenini ayarlar
// - LogLevel()             : m_log_level değişkenini ayarlar
// - SetTypeFillingBySymbol(): Sembole göre otomatik filling
//====================================================================
int OnInit()
  {
   PrintSeparator("CTrade COMPLETE EA - BAŞLATILIYOR");
   
   //=================================================================
   // 1. SetExpertMagicNumber() - Magic Number Ayarı
   // CTrade::SetExpertMagicNumber(const ulong magic)
   // m_magic = magic; şeklinde çalışır
   //=================================================================
   g_trade.SetExpertMagicNumber(InpMagicNumber);
   WriteLog("✅ SetExpertMagicNumber(" + IntegerToString(InpMagicNumber) + ") çağrıldı");
   
   //=================================================================
   // 2. SetDeviationInPoints() - Slippage/Deviation Ayarı
   // CTrade::SetDeviationInPoints(const ulong deviation)
   // m_deviation = deviation; şeklinde çalışır
   //=================================================================
   g_trade.SetDeviationInPoints(InpDeviation);
   WriteLog("✅ SetDeviationInPoints(" + IntegerToString(InpDeviation) + ") çağrıldı");
   
   //=================================================================
   // 3. SetTypeFilling() - Order Filling Tipi
   // CTrade::SetTypeFilling(const ENUM_ORDER_TYPE_FILLING filling)
   // m_type_filling = filling; şeklinde çalışır
   // Tipler: ORDER_FILLING_FOK, ORDER_FILLING_IOC, ORDER_FILLING_RETURN
   //=================================================================
   g_trade.SetTypeFilling(InpFilling);
   WriteLog("✅ SetTypeFilling(" + EnumToString(InpFilling) + ") çağrıldı");
   
   //=================================================================
   // 4. SetMarginMode() - Hesap Margin Modu
   // CTrade::SetMarginMode()
   // m_margin_mode = AccountInfoInteger(ACCOUNT_MARGIN_MODE)
   // Modlar: ACCOUNT_MARGIN_MODE_RETAIL_NETTING, 
   //         ACCOUNT_MARGIN_MODE_RETAIL_HEDGING,
   //         ACCOUNT_MARGIN_MODE_EXCHANGE
   //=================================================================
   g_trade.SetMarginMode();
   ENUM_ACCOUNT_MARGIN_MODE marginMode = (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
   WriteLog("✅ SetMarginMode() çağrıldı - Mod: " + EnumToString(marginMode));
   
   //=================================================================
   // 5. SetAsyncMode() - Asenkron Trade Modu
   // CTrade::SetAsyncMode(const bool mode)
   // m_async_mode = mode;
   // true: OrderSendAsync kullanılır
   // false: Normal OrderSend kullanılır
   //=================================================================
   g_trade.SetAsyncMode(InpAsyncMode);
   WriteLog("✅ SetAsyncMode(" + (InpAsyncMode ? "true" : "false") + ") çağrıldı");
   
   //=================================================================
   // 6. LogLevel() - Log Seviyesi Ayarı
   // CTrade::LogLevel(const ENUM_LOG_LEVELS log_level)
   // m_log_level = log_level;
   // LOG_LEVEL_NO=0, LOG_LEVEL_ERRORS=1, LOG_LEVEL_ALL=2
   //=================================================================
   // CTrade'deki ENUM_LOG_LEVELS'a dönüştür
   if(InpLogLevel == EA_LOG_NONE)
      g_trade.LogLevel(LOG_LEVEL_NO);
   else if(InpLogLevel == EA_LOG_ERRORS)
      g_trade.LogLevel(LOG_LEVEL_ERRORS);
   else
      g_trade.LogLevel(LOG_LEVEL_ALL);
   WriteLog("✅ LogLevel(" + IntegerToString(InpLogLevel) + ") çağrıldı");
   
   //=================================================================
   // 7. SetTypeFillingBySymbol() - Sembole Göre Otomatik Filling
   // bool CTrade::SetTypeFillingBySymbol(const string symbol)
   // Sembolün desteklediği filling tipini otomatik algılar
   //=================================================================
   bool fillingResult = g_trade.SetTypeFillingBySymbol(_Symbol);
   WriteLog("✅ SetTypeFillingBySymbol(" + _Symbol + ") = " + (fillingResult ? "başarılı" : "başarısız"));
   
   //--- Başlatma bilgileri
   PrintSeparator();
   WriteLog("📊 Sembol: " + _Symbol);
   WriteLog("💰 Lot: " + DoubleToString(InpLotSize, 2));
   WriteLog("🛑 SL: " + DoubleToString(InpSLPips, 1) + " pip");
   WriteLog("🎯 TP: " + DoubleToString(InpTPPips, 1) + " pip");
   WriteLog("🎰 Magic: " + IntegerToString(InpMagicNumber));
   WriteLog("📋 Filling: " + EnumToString(InpFilling));
   WriteLog("⚡ Async: " + (InpAsyncMode ? "EVET" : "HAYIR"));
   WriteLog("📝 Log Level: " + IntegerToString(InpLogLevel));
   PrintSeparator();
   
   g_isInitialized = true;
   return INIT_SUCCEEDED;
  }

//====================================================================
// OnDeinit - EA KAPANIŞ
//====================================================================
void OnDeinit(const int reason)
  {
   PrintSeparator("CTrade COMPLETE EA - SONUÇLAR");
   WriteLog("📊 Toplam BUY: " + IntegerToString(g_totalBuyOrders));
   WriteLog("📊 Toplam SELL: " + IntegerToString(g_totalSellOrders));
   WriteLog("📊 Toplam Pending: " + IntegerToString(g_totalPendingOrders));
   WriteLog("📊 Toplam Modifikasyon: " + IntegerToString(g_totalModifications));
   WriteLog("📊 Toplam Kapatma: " + IntegerToString(g_totalClosures));
   WriteLog("❌ Toplam Hata: " + IntegerToString(g_totalErrors));
   WriteLog("💰 Toplam Kar/Zarar: " + DoubleToString(g_totalProfit, 2));
   PrintSeparator();
  }

//====================================================================
// REQUEST BİLGİLERİNİ GÖSTER
// CTrade'deki TÜM Request erişim metodları burada kullanılıyor
//====================================================================
void ShowAllRequestInfo()
  {
   PrintSeparator("MqlTradeRequest BİLGİLERİ");
   
   //--- Request yapısını CTrade'den al
   // void CTrade::Request(MqlTradeRequest &request) const
   g_trade.Request(g_lastRequest);
   WriteLog("✅ Request() ile yapı alındı");
   
   //--- RequestAction() - İşlem tipi
   // ENUM_TRADE_REQUEST_ACTIONS RequestAction() const
   // return m_request.action;
   ENUM_TRADE_REQUEST_ACTIONS action = g_trade.RequestAction();
   WriteLog("📋 RequestAction(): " + EnumToString(action));
   
   //--- RequestActionDescription() - İşlem tipi açıklaması
   // string RequestActionDescription() const
   // FormatRequest() kullanarak string döndürür
   string actionDesc = g_trade.RequestActionDescription();
   WriteLog("📝 RequestActionDescription(): " + actionDesc);
   
   //--- RequestMagic() - Magic number
   // ulong RequestMagic() const { return m_request.magic; }
   ulong magic = g_trade.RequestMagic();
   WriteLog("🎰 RequestMagic(): " + IntegerToString(magic));
   
   //--- RequestOrder() - Emir ticket
   // ulong RequestOrder() const { return m_request.order; }
   ulong orderTicket = g_trade.RequestOrder();
   WriteLog("🎫 RequestOrder(): " + IntegerToString(orderTicket));
   
   //--- RequestPosition() - Pozisyon ticket
   // ulong RequestPosition() const { return m_request.position; }
   ulong posTicket = g_trade.RequestPosition();
   WriteLog("📊 RequestPosition(): " + IntegerToString(posTicket));
   
   //--- RequestPositionBy() - CloseBy için karşı pozisyon
   // ulong RequestPositionBy() const { return m_request.position_by; }
   ulong posByTicket = g_trade.RequestPositionBy();
   WriteLog("🔄 RequestPositionBy(): " + IntegerToString(posByTicket));
   
   //--- RequestSymbol() - Sembol
   // string RequestSymbol() const { return m_request.symbol; }
   string symbol = g_trade.RequestSymbol();
   WriteLog("💱 RequestSymbol(): " + symbol);
   
   //--- RequestVolume() - Lot miktarı
   // double RequestVolume() const { return m_request.volume; }
   double volume = g_trade.RequestVolume();
   WriteLog("💰 RequestVolume(): " + DoubleToString(volume, 2));
   
   //--- RequestPrice() - Fiyat
   // double RequestPrice() const { return m_request.price; }
   double price = g_trade.RequestPrice();
   WriteLog("💵 RequestPrice(): " + DoubleToString(price, _Digits));
   
   //--- RequestStopLimit() - Stop Limit fiyatı
   // double RequestStopLimit() const { return m_request.stoplimit; }
   double stopLimit = g_trade.RequestStopLimit();
   WriteLog("🔃 RequestStopLimit(): " + DoubleToString(stopLimit, _Digits));
   
   //--- RequestSL() - Stop Loss
   // double RequestSL() const { return m_request.sl; }
   double sl = g_trade.RequestSL();
   WriteLog("🛑 RequestSL(): " + DoubleToString(sl, _Digits));
   
   //--- RequestTP() - Take Profit
   // double RequestTP() const { return m_request.tp; }
   double tp = g_trade.RequestTP();
   WriteLog("🎯 RequestTP(): " + DoubleToString(tp, _Digits));
   
   //--- RequestDeviation() - Slippage
   // ulong RequestDeviation() const { return m_request.deviation; }
   ulong deviation = g_trade.RequestDeviation();
   WriteLog("📊 RequestDeviation(): " + IntegerToString(deviation));
   
   //--- RequestType() - Emir tipi
   // ENUM_ORDER_TYPE RequestType() const { return m_request.type; }
   ENUM_ORDER_TYPE orderType = g_trade.RequestType();
   WriteLog("📋 RequestType(): " + EnumToString(orderType));
   
   //--- RequestTypeDescription() - Emir tipi açıklaması
   // string RequestTypeDescription() const
   string typeDesc = g_trade.RequestTypeDescription();
   WriteLog("📝 RequestTypeDescription(): " + typeDesc);
   
   //--- RequestTypeFilling() - Filling tipi
   // ENUM_ORDER_TYPE_FILLING RequestTypeFilling() const
   ENUM_ORDER_TYPE_FILLING filling = g_trade.RequestTypeFilling();
   WriteLog("📋 RequestTypeFilling(): " + EnumToString(filling));
   
   //--- RequestTypeFillingDescription() - Filling açıklaması
   // string RequestTypeFillingDescription() const
   string fillingDesc = g_trade.RequestTypeFillingDescription();
   WriteLog("📝 RequestTypeFillingDescription(): " + fillingDesc);
   
   //--- RequestTypeTime() - Zaman tipi
   // ENUM_ORDER_TYPE_TIME RequestTypeTime() const
   ENUM_ORDER_TYPE_TIME typeTime = g_trade.RequestTypeTime();
   WriteLog("⏰ RequestTypeTime(): " + EnumToString(typeTime));
   
   //--- RequestTypeTimeDescription() - Zaman tipi açıklaması
   // string RequestTypeTimeDescription() const
   string timeDesc = g_trade.RequestTypeTimeDescription();
   WriteLog("📝 RequestTypeTimeDescription(): " + timeDesc);
   
   //--- RequestExpiration() - Son kullanma tarihi
   // datetime RequestExpiration() const { return m_request.expiration; }
   datetime expiration = g_trade.RequestExpiration();
   WriteLog("📅 RequestExpiration(): " + TimeToString(expiration));
   
   //--- RequestComment() - Yorum
   // string RequestComment() const { return m_request.comment; }
   string comment = g_trade.RequestComment();
   WriteLog("💬 RequestComment(): " + comment);
   
   PrintSeparator();
  }

//====================================================================
// RESULT BİLGİLERİNİ GÖSTER
// CTrade'deki TÜM Result erişim metodları burada kullanılıyor
//====================================================================
void ShowAllResultInfo()
  {
   PrintSeparator("MqlTradeResult BİLGİLERİ");
   
   //--- Result yapısını CTrade'den al
   // void CTrade::Result(MqlTradeResult &result) const
   g_trade.Result(g_lastResult);
   WriteLog("✅ Result() ile yapı alındı");
   
   //--- ResultRetcode() - Sonuç kodu
   // uint ResultRetcode() const { return m_result.retcode; }
   uint retcode = g_trade.ResultRetcode();
   WriteLog("📋 ResultRetcode(): " + IntegerToString(retcode));
   
   //--- ResultRetcodeDescription() - Sonuç kodu açıklaması
   // string ResultRetcodeDescription() const
   string retcodeDesc = g_trade.ResultRetcodeDescription();
   WriteLog("📝 ResultRetcodeDescription(): " + retcodeDesc);
   
   //--- ResultRetcodeExternal() - Harici sonuç kodu
   // int ResultRetcodeExternal() const { return m_result.retcode_external; }
   int externalCode = g_trade.ResultRetcodeExternal();
   WriteLog("🔗 ResultRetcodeExternal(): " + IntegerToString(externalCode));
   
   //--- ResultDeal() - Deal ticket
   // ulong ResultDeal() const { return m_result.deal; }
   ulong dealTicket = g_trade.ResultDeal();
   WriteLog("🎫 ResultDeal(): " + IntegerToString(dealTicket));
   
   //--- ResultOrder() - Emir ticket
   // ulong ResultOrder() const { return m_result.order; }
   ulong orderTicket = g_trade.ResultOrder();
   WriteLog("🎫 ResultOrder(): " + IntegerToString(orderTicket));
   
   //--- ResultVolume() - Gerçekleşen lot
   // double ResultVolume() const { return m_result.volume; }
   double volume = g_trade.ResultVolume();
   WriteLog("💰 ResultVolume(): " + DoubleToString(volume, 2));
   
   //--- ResultPrice() - Gerçekleşen fiyat
   // double ResultPrice() const { return m_result.price; }
   double price = g_trade.ResultPrice();
   WriteLog("💵 ResultPrice(): " + DoubleToString(price, _Digits));
   
   //--- ResultBid() - Bid fiyatı
   // double ResultBid() const { return m_result.bid; }
   double bid = g_trade.ResultBid();
   WriteLog("📊 ResultBid(): " + DoubleToString(bid, _Digits));
   
   //--- ResultAsk() - Ask fiyatı
   // double ResultAsk() const { return m_result.ask; }
   double ask = g_trade.ResultAsk();
   WriteLog("📊 ResultAsk(): " + DoubleToString(ask, _Digits));
   
   //--- ResultComment() - Sonuç yorumu
   // string ResultComment() const { return m_result.comment; }
   string comment = g_trade.ResultComment();
   WriteLog("💬 ResultComment(): " + comment);
   
   PrintSeparator();
  }

//====================================================================
// CHECK RESULT BİLGİLERİNİ GÖSTER
// CTrade'deki TÜM CheckResult erişim metodları burada kullanılıyor
//====================================================================
void ShowAllCheckResultInfo()
  {
   PrintSeparator("MqlTradeCheckResult BİLGİLERİ");
   
   //--- CheckResult yapısını CTrade'den al
   // void CTrade::CheckResult(MqlTradeCheckResult &check_result) const
   g_trade.CheckResult(g_lastCheckResult);
   WriteLog("✅ CheckResult() ile yapı alındı");
   
   //--- CheckResultRetcode() - Kontrol sonuç kodu
   // uint CheckResultRetcode() const { return m_check_result.retcode; }
   uint retcode = g_trade.CheckResultRetcode();
   WriteLog("📋 CheckResultRetcode(): " + IntegerToString(retcode));
   
   //--- CheckResultRetcodeDescription() - Kontrol sonuç açıklaması
   // string CheckResultRetcodeDescription() const
   string retcodeDesc = g_trade.CheckResultRetcodeDescription();
   WriteLog("📝 CheckResultRetcodeDescription(): " + retcodeDesc);
   
   //--- CheckResultBalance() - İşlem sonrası bakiye
   // double CheckResultBalance() const { return m_check_result.balance; }
   double balance = g_trade.CheckResultBalance();
   WriteLog("💰 CheckResultBalance(): " + DoubleToString(balance, 2));
   
   //--- CheckResultEquity() - İşlem sonrası özkaynak
   // double CheckResultEquity() const { return m_check_result.equity; }
   double equity = g_trade.CheckResultEquity();
   WriteLog("💎 CheckResultEquity(): " + DoubleToString(equity, 2));
   
   //--- CheckResultProfit() - Tahmini kar/zarar
   // double CheckResultProfit() const { return m_check_result.profit; }
   double profit = g_trade.CheckResultProfit();
   WriteLog("📈 CheckResultProfit(): " + DoubleToString(profit, 2));
   
   //--- CheckResultMargin() - Gerekli marjin
   // double CheckResultMargin() const { return m_check_result.margin; }
   double margin = g_trade.CheckResultMargin();
   WriteLog("📊 CheckResultMargin(): " + DoubleToString(margin, 2));
   
   //--- CheckResultMarginFree() - Serbest marjin
   // double CheckResultMarginFree() const { return m_check_result.margin_free; }
   double marginFree = g_trade.CheckResultMarginFree();
   WriteLog("💵 CheckResultMarginFree(): " + DoubleToString(marginFree, 2));
   
   //--- CheckResultMarginLevel() - Marjin seviyesi
   // double CheckResultMarginLevel() const { return m_check_result.margin_level; }
   double marginLevel = g_trade.CheckResultMarginLevel();
   WriteLog("📈 CheckResultMarginLevel(): " + DoubleToString(marginLevel, 2) + "%");
   
   //--- CheckResultComment() - Kontrol yorumu
   // string CheckResultComment() const { return m_check_result.comment; }
   string comment = g_trade.CheckResultComment();
   WriteLog("💬 CheckResultComment(): " + comment);
   
   PrintSeparator();
  }

//====================================================================
// POZİSYON İŞLEMLERİ - CTrade Pozisyon Metodları
// PositionOpen, PositionModify, PositionClose, PositionCloseBy, PositionClosePartial
//====================================================================

//+------------------------------------------------------------------+
//| PositionOpen() Demo                                              |
//| bool PositionOpen(symbol, order_type, volume, price, sl, tp, comment)|
//+------------------------------------------------------------------+
bool DemoPositionOpen(ENUM_ORDER_TYPE orderType)
  {
   PrintSeparator("PositionOpen() DEMOsu");
   
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double price = (orderType == ORDER_TYPE_BUY) ? ask : bid;
   
   // SL ve TP hesapla
   double slDist = PipsToPoints(InpSLPips);
   double tpDist = PipsToPoints(InpTPPips);
   
   double sl, tp;
   if(orderType == ORDER_TYPE_BUY)
     {
      sl = NormalizePrice(price - slDist);
      tp = NormalizePrice(price + tpDist);
     }
   else
     {
      sl = NormalizePrice(price + slDist);
      tp = NormalizePrice(price - tpDist);
     }
   
   double lot = NormalizeLot(InpLotSize);
   string comment = "CTrade_PositionOpen_" + EnumToString(orderType);
   
   //=================================================================
   // PositionOpen() Metodu
   // bool CTrade::PositionOpen(const string symbol,
   //                           const ENUM_ORDER_TYPE order_type,
   //                           const double volume,
   //                           const double price,
   //                           const double sl,
   //                           const double tp,
   //                           const string comment)
   //=================================================================
   bool result = g_trade.PositionOpen(_Symbol, orderType, lot, price, sl, tp, comment);
   
   WriteLog("📊 PositionOpen(" + _Symbol + ", " + EnumToString(orderType) + ", " + 
            DoubleToString(lot, 2) + ", " + DoubleToString(price, _Digits) + ")");
   WriteLog("🛑 SL: " + DoubleToString(sl, _Digits) + " | 🎯 TP: " + DoubleToString(tp, _Digits));
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI" : "BAŞARISIZ"));
   
   // Result bilgilerini göster
   if(result)
     {
      WriteLog("🎫 Ticket: " + IntegerToString(g_trade.ResultOrder()));
      WriteLog("💵 Fiyat: " + DoubleToString(g_trade.ResultPrice(), _Digits));
      if(orderType == ORDER_TYPE_BUY)
         g_totalBuyOrders++;
      else
         g_totalSellOrders++;
     }
   else
     {
      WriteLog("❌ Hata: " + g_trade.ResultRetcodeDescription());
      g_totalErrors++;
     }
   
   // PrintRequest ve PrintResult demo
   //=================================================================
   // PrintRequest() - Request bilgilerini logla
   // void CTrade::PrintRequest() const
   // m_log_level >= LOG_LEVEL_ALL ise çalışır
   //=================================================================
   g_trade.PrintRequest();
   
   //=================================================================
   // PrintResult() - Result bilgilerini logla
   // void CTrade::PrintResult() const
   // m_log_level >= LOG_LEVEL_ALL ise çalışır
   //=================================================================
   g_trade.PrintResult();
   
   PrintSeparator();
   return result;
  }

//+------------------------------------------------------------------+
//| PositionModify() Demo - Sembol ile                               |
//| bool PositionModify(const string symbol, sl, tp)                 |
//+------------------------------------------------------------------+
bool DemoPositionModifyBySymbol()
  {
   PrintSeparator("PositionModify(symbol) DEMOsu");
   
   // Açık pozisyon var mı kontrol et
   if(!PositionSelect(_Symbol))
     {
      WriteLog("⚠️ Açık pozisyon yok!");
      return false;
     }
   
   double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   long posType = PositionGetInteger(POSITION_TYPE);
   
   // Yeni SL/TP hesapla (mevcut fiyata 5 pip ekle/çıkar)
   double newSlDist = PipsToPoints(InpSLPips + 5);
   double newTpDist = PipsToPoints(InpTPPips + 5);
   
   double newSL, newTP;
   if(posType == POSITION_TYPE_BUY)
     {
      newSL = NormalizePrice(openPrice - newSlDist);
      newTP = NormalizePrice(openPrice + newTpDist);
     }
   else
     {
      newSL = NormalizePrice(openPrice + newSlDist);
      newTP = NormalizePrice(openPrice - newTpDist);
     }
   
   //=================================================================
   // PositionModify() - Sembol ile
   // bool CTrade::PositionModify(const string symbol,
   //                             const double sl,
   //                             const double tp)
   //=================================================================
   bool result = g_trade.PositionModify(_Symbol, newSL, newTP);
   
   WriteLog("📊 PositionModify(" + _Symbol + ", " + 
            DoubleToString(newSL, _Digits) + ", " + DoubleToString(newTP, _Digits) + ")");
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
      g_totalModifications++;
   else
      g_totalErrors++;
   
   PrintSeparator();
   return result;
  }

//+------------------------------------------------------------------+
//| PositionModify() Demo - Ticket ile                               |
//| bool PositionModify(const ulong ticket, sl, tp)                  |
//+------------------------------------------------------------------+
bool DemoPositionModifyByTicket(ulong ticket)
  {
   PrintSeparator("PositionModify(ticket) DEMOsu");
   
   if(!PositionSelectByTicket(ticket))
     {
      WriteLog("⚠️ Ticket bulunamadı: " + IntegerToString(ticket));
      return false;
     }
   
   double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
   long posType = PositionGetInteger(POSITION_TYPE);
   
   double newSlDist = PipsToPoints(InpSLPips + 10);
   double newTpDist = PipsToPoints(InpTPPips + 10);
   
   double newSL, newTP;
   if(posType == POSITION_TYPE_BUY)
     {
      newSL = NormalizePrice(openPrice - newSlDist);
      newTP = NormalizePrice(openPrice + newTpDist);
     }
   else
     {
      newSL = NormalizePrice(openPrice + newSlDist);
      newTP = NormalizePrice(openPrice - newTpDist);
     }
   
   //=================================================================
   // PositionModify() - Ticket ile
   // bool CTrade::PositionModify(const ulong ticket,
   //                             const double sl,
   //                             const double tp)
   //=================================================================
   bool result = g_trade.PositionModify(ticket, newSL, newTP);
   
   WriteLog("📊 PositionModify(#" + IntegerToString(ticket) + ", " + 
            DoubleToString(newSL, _Digits) + ", " + DoubleToString(newTP, _Digits) + ")");
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
      g_totalModifications++;
   else
      g_totalErrors++;
   
   PrintSeparator();
   return result;
  }

//+------------------------------------------------------------------+
//| PositionClose() Demo - Sembol ile                                |
//| bool PositionClose(const string symbol, const ulong deviation)   |
//+------------------------------------------------------------------+
bool DemoPositionCloseBySymbol()
  {
   PrintSeparator("PositionClose(symbol) DEMOsu");
   
   //=================================================================
   // PositionClose() - Sembol ile
   // bool CTrade::PositionClose(const string symbol,
   //                            const ulong deviation=ULONG_MAX)
   // deviation = ULONG_MAX ise m_deviation kullanılır
   //=================================================================
   bool result = g_trade.PositionClose(_Symbol);
   
   WriteLog("📊 PositionClose(" + _Symbol + ")");
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
      g_totalClosures++;
   else
      g_totalErrors++;
   
   PrintSeparator();
   return result;
  }

//+------------------------------------------------------------------+
//| PositionClose() Demo - Ticket ile                                |
//| bool PositionClose(const ulong ticket, const ulong deviation)    |
//+------------------------------------------------------------------+
bool DemoPositionCloseByTicket(ulong ticket)
  {
   PrintSeparator("PositionClose(ticket) DEMOsu");
   
   //=================================================================
   // PositionClose() - Ticket ile
   // bool CTrade::PositionClose(const ulong ticket,
   //                            const ulong deviation=ULONG_MAX)
   //=================================================================
   bool result = g_trade.PositionClose(ticket, InpDeviation);
   
   WriteLog("📊 PositionClose(#" + IntegerToString(ticket) + ")");
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
      g_totalClosures++;
   else
      g_totalErrors++;
   
   PrintSeparator();
   return result;
  }

//+------------------------------------------------------------------+
//| PositionCloseBy() Demo - Hedging modunda iki pozisyonu kapat     |
//| bool PositionCloseBy(const ulong ticket, const ulong ticket_by)  |
//+------------------------------------------------------------------+
bool DemoPositionCloseBy(ulong ticket1, ulong ticket2)
  {
   PrintSeparator("PositionCloseBy() DEMOsu");
   
   //=================================================================
   // PositionCloseBy() - İki pozisyonu birbirine karşı kapat
   // bool CTrade::PositionCloseBy(const ulong ticket,
   //                              const ulong ticket_by)
   // SADECE HEDGING modunda çalışır!
   // Zıt yönlü iki pozisyon gerektirir
   //=================================================================
   bool result = g_trade.PositionCloseBy(ticket1, ticket2);
   
   WriteLog("📊 PositionCloseBy(#" + IntegerToString(ticket1) + ", #" + IntegerToString(ticket2) + ")");
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
      g_totalClosures += 2;
   else
      g_totalErrors++;
   
   PrintSeparator();
   return result;
  }

//+------------------------------------------------------------------+
//| PositionClosePartial() Demo - Sembol ile                         |
//| bool PositionClosePartial(symbol, volume, deviation)             |
//+------------------------------------------------------------------+
bool DemoPositionClosePartialBySymbol(double closeVolume)
  {
   PrintSeparator("PositionClosePartial(symbol) DEMOsu");
   
   //=================================================================
   // PositionClosePartial() - Kısmi kapatma (Sembol ile)
   // bool CTrade::PositionClosePartial(const string symbol,
   //                                   const double volume,
   //                                   const ulong deviation=ULONG_MAX)
   // SADECE HEDGING modunda çalışır!
   //=================================================================
   bool result = g_trade.PositionClosePartial(_Symbol, closeVolume);
   
   WriteLog("📊 PositionClosePartial(" + _Symbol + ", " + DoubleToString(closeVolume, 2) + ")");
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
      g_totalClosures++;
   else
      g_totalErrors++;
   
   PrintSeparator();
   return result;
  }

//+------------------------------------------------------------------+
//| PositionClosePartial() Demo - Ticket ile                         |
//| bool PositionClosePartial(ticket, volume, deviation)             |
//+------------------------------------------------------------------+
bool DemoPositionClosePartialByTicket(ulong ticket, double closeVolume)
  {
   PrintSeparator("PositionClosePartial(ticket) DEMOsu");
   
   //=================================================================
   // PositionClosePartial() - Kısmi kapatma (Ticket ile)
   // bool CTrade::PositionClosePartial(const ulong ticket,
   //                                   const double volume,
   //                                   const ulong deviation=ULONG_MAX)
   // SADECE HEDGING modunda çalışır!
   //=================================================================
   bool result = g_trade.PositionClosePartial(ticket, closeVolume);
   
   WriteLog("📊 PositionClosePartial(#" + IntegerToString(ticket) + ", " + DoubleToString(closeVolume, 2) + ")");
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
      g_totalClosures++;
   else
      g_totalErrors++;
   
   PrintSeparator();
   return result;
  }

//====================================================================
// BEKLEYEN EMİR İŞLEMLERİ - CTrade Order Metodları
// OrderOpen, OrderModify, OrderDelete
//====================================================================

//+------------------------------------------------------------------+
//| OrderOpen() Demo                                                 |
//| bool OrderOpen(symbol, order_type, volume, limit_price,          |
//|                price, sl, tp, type_time, expiration, comment)    |
//+------------------------------------------------------------------+
bool DemoOrderOpen(ENUM_ORDER_TYPE orderType)
  {
   PrintSeparator("OrderOpen() DEMOsu");
   
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double pendingDist = PipsToPoints(InpPendingDistPips);
   
   double price, sl, tp, limitPrice = 0;
   double slDist = PipsToPoints(InpSLPips);
   double tpDist = PipsToPoints(InpTPPips);
   
   switch(orderType)
     {
      case ORDER_TYPE_BUY_LIMIT:
         price = NormalizePrice(ask - pendingDist);
         sl = NormalizePrice(price - slDist);
         tp = NormalizePrice(price + tpDist);
         break;
      case ORDER_TYPE_BUY_STOP:
         price = NormalizePrice(ask + pendingDist);
         sl = NormalizePrice(price - slDist);
         tp = NormalizePrice(price + tpDist);
         break;
      case ORDER_TYPE_SELL_LIMIT:
         price = NormalizePrice(bid + pendingDist);
         sl = NormalizePrice(price + slDist);
         tp = NormalizePrice(price - tpDist);
         break;
      case ORDER_TYPE_SELL_STOP:
         price = NormalizePrice(bid - pendingDist);
         sl = NormalizePrice(price + slDist);
         tp = NormalizePrice(price - tpDist);
         break;
      default:
         WriteLog("⚠️ Geçersiz pending order tipi!");
         return false;
     }
   
   double lot = NormalizeLot(InpLotSize);
   string comment = "CTrade_OrderOpen_" + EnumToString(orderType);
   
   // Son kullanma: 1 gün sonra
   datetime expiration = TimeCurrent() + 86400;
   
   //=================================================================
   // OrderOpen() - Bekleyen emir aç
   // bool CTrade::OrderOpen(const string symbol,
   //                        const ENUM_ORDER_TYPE order_type,
   //                        const double volume,
   //                        const double limit_price,  // Stop-Limit için
   //                        const double price,
   //                        const double sl,
   //                        const double tp,
   //                        ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,
   //                        const datetime expiration=0,
   //                        const string comment="")
   //=================================================================
   bool result = g_trade.OrderOpen(_Symbol, orderType, lot, limitPrice, price, sl, tp, 
                                    ORDER_TIME_DAY, expiration, comment);
   
   WriteLog("📊 OrderOpen(" + _Symbol + ", " + EnumToString(orderType) + ")");
   WriteLog("💵 Fiyat: " + DoubleToString(price, _Digits));
   WriteLog("🛑 SL: " + DoubleToString(sl, _Digits) + " | 🎯 TP: " + DoubleToString(tp, _Digits));
   WriteLog("📅 Expiration: " + TimeToString(expiration));
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
     {
      WriteLog("🎫 Order Ticket: " + IntegerToString(g_trade.ResultOrder()));
      g_totalPendingOrders++;
     }
   else
     {
      WriteLog("❌ Hata: " + g_trade.ResultRetcodeDescription());
      g_totalErrors++;
     }
   
   PrintSeparator();
   return result;
  }

//+------------------------------------------------------------------+
//| OrderModify() Demo                                               |
//| bool OrderModify(ticket, price, sl, tp, type_time, expiration,   |
//|                  stoplimit)                                      |
//+------------------------------------------------------------------+
bool DemoOrderModify(ulong ticket)
  {
   PrintSeparator("OrderModify() DEMOsu");
   
   if(!OrderSelect(ticket))
     {
      WriteLog("⚠️ Order bulunamadı: " + IntegerToString(ticket));
      return false;
     }
   
   double currentPrice = OrderGetDouble(ORDER_PRICE_OPEN);
   double currentSL = OrderGetDouble(ORDER_SL);
   double currentTP = OrderGetDouble(ORDER_TP);
   ENUM_ORDER_TYPE orderType = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
   datetime currentExpiration = (datetime)OrderGetInteger(ORDER_TIME_EXPIRATION);
   
   // Fiyatı 5 pip kaydır
   double priceShift = PipsToPoints(5);
   double newPrice, newSL, newTP;
   
   if(orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP)
     {
      newPrice = NormalizePrice(currentPrice + priceShift);
      newSL = NormalizePrice(newPrice - PipsToPoints(InpSLPips));
      newTP = NormalizePrice(newPrice + PipsToPoints(InpTPPips));
     }
   else
     {
      newPrice = NormalizePrice(currentPrice - priceShift);
      newSL = NormalizePrice(newPrice + PipsToPoints(InpSLPips));
      newTP = NormalizePrice(newPrice - PipsToPoints(InpTPPips));
     }
   
   // Yeni expiration: 2 gün sonra
   datetime newExpiration = TimeCurrent() + 172800;
   
   //=================================================================
   // OrderModify() - Bekleyen emri değiştir
   // bool CTrade::OrderModify(const ulong ticket,
   //                          const double price,
   //                          const double sl,
   //                          const double tp,
   //                          const ENUM_ORDER_TYPE_TIME type_time,
   //                          const datetime expiration,
   //                          const double stoplimit=0.0)
   //=================================================================
   bool result = g_trade.OrderModify(ticket, newPrice, newSL, newTP, ORDER_TIME_DAY, newExpiration, 0.0);
   
   WriteLog("📊 OrderModify(#" + IntegerToString(ticket) + ")");
   WriteLog("💵 Yeni Fiyat: " + DoubleToString(newPrice, _Digits));
   WriteLog("🛑 Yeni SL: " + DoubleToString(newSL, _Digits) + " | 🎯 Yeni TP: " + DoubleToString(newTP, _Digits));
   WriteLog("📅 Yeni Expiration: " + TimeToString(newExpiration));
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
      g_totalModifications++;
   else
      g_totalErrors++;
   
   PrintSeparator();
   return result;
  }

//+------------------------------------------------------------------+
//| OrderDelete() Demo                                               |
//| bool OrderDelete(const ulong ticket)                             |
//+------------------------------------------------------------------+
bool DemoOrderDelete(ulong ticket)
  {
   PrintSeparator("OrderDelete() DEMOsu");
   
   //=================================================================
   // OrderDelete() - Bekleyen emri sil
   // bool CTrade::OrderDelete(const ulong ticket)
   //=================================================================
   bool result = g_trade.OrderDelete(ticket);
   
   WriteLog("📊 OrderDelete(#" + IntegerToString(ticket) + ")");
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
      g_totalClosures++;
   else
      g_totalErrors++;
   
   PrintSeparator();
   return result;
  }

//====================================================================
// KISAYOL METODLARI - Buy, Sell, BuyLimit, BuyStop, SellLimit, SellStop
//====================================================================

//+------------------------------------------------------------------+
//| Buy() Demo                                                       |
//| bool Buy(volume, symbol, price, sl, tp, comment)                 |
//+------------------------------------------------------------------+
bool DemoBuy()
  {
   PrintSeparator("Buy() DEMOsu");
   
   double lot = NormalizeLot(InpLotSize);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double sl = NormalizePrice(ask - PipsToPoints(InpSLPips));
   double tp = NormalizePrice(ask + PipsToPoints(InpTPPips));
   
   //=================================================================
   // Buy() - Market BUY emri
   // bool CTrade::Buy(const double volume,
   //                  const string symbol=NULL,
   //                  double price=0.0,
   //                  const double sl=0.0,
   //                  const double tp=0.0,
   //                  const string comment="")
   // price=0 ise otomatik ASK fiyatı kullanılır
   // symbol=NULL ise _Symbol kullanılır
   //=================================================================
   bool result = g_trade.Buy(lot, _Symbol, 0, sl, tp, "CTrade_Buy");
   
   WriteLog("📊 Buy(" + DoubleToString(lot, 2) + ", " + _Symbol + ")");
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
     {
      WriteLog("🎫 Ticket: " + IntegerToString(g_trade.ResultOrder()));
      g_totalBuyOrders++;
     }
   else
     {
      WriteLog("❌ Hata: " + g_trade.ResultRetcodeDescription());
      g_totalErrors++;
     }
   
   PrintSeparator();
   return result;
  }

//+------------------------------------------------------------------+
//| Sell() Demo                                                      |
//| bool Sell(volume, symbol, price, sl, tp, comment)                |
//+------------------------------------------------------------------+
bool DemoSell()
  {
   PrintSeparator("Sell() DEMOsu");
   
   double lot = NormalizeLot(InpLotSize);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double sl = NormalizePrice(bid + PipsToPoints(InpSLPips));
   double tp = NormalizePrice(bid - PipsToPoints(InpTPPips));
   
   //=================================================================
   // Sell() - Market SELL emri
   // bool CTrade::Sell(const double volume,
   //                   const string symbol=NULL,
   //                   double price=0.0,
   //                   const double sl=0.0,
   //                   const double tp=0.0,
   //                   const string comment="")
   // price=0 ise otomatik BID fiyatı kullanılır
   //=================================================================
   bool result = g_trade.Sell(lot, _Symbol, 0, sl, tp, "CTrade_Sell");
   
   WriteLog("📊 Sell(" + DoubleToString(lot, 2) + ", " + _Symbol + ")");
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
     {
      WriteLog("🎫 Ticket: " + IntegerToString(g_trade.ResultOrder()));
      g_totalSellOrders++;
     }
   else
     {
      WriteLog("❌ Hata: " + g_trade.ResultRetcodeDescription());
      g_totalErrors++;
     }
   
   PrintSeparator();
   return result;
  }

//+------------------------------------------------------------------+
//| BuyLimit() Demo                                                  |
//| bool BuyLimit(volume, price, symbol, sl, tp, type_time, exp, comment)|
//+------------------------------------------------------------------+
bool DemoBuyLimit()
  {
   PrintSeparator("BuyLimit() DEMOsu");
   
   double lot = NormalizeLot(InpLotSize);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double price = NormalizePrice(ask - PipsToPoints(InpPendingDistPips));
   double sl = NormalizePrice(price - PipsToPoints(InpSLPips));
   double tp = NormalizePrice(price + PipsToPoints(InpTPPips));
   
   //=================================================================
   // BuyLimit() - Buy Limit emri
   // bool CTrade::BuyLimit(const double volume,
   //                       const double price,
   //                       const string symbol=NULL,
   //                       const double sl=0.0,
   //                       const double tp=0.0,
   //                       const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,
   //                       const datetime expiration=0,
   //                       const string comment="")
   //=================================================================
   bool result = g_trade.BuyLimit(lot, price, _Symbol, sl, tp, ORDER_TIME_DAY, 0, "CTrade_BuyLimit");
   
   WriteLog("📊 BuyLimit(" + DoubleToString(lot, 2) + ", " + DoubleToString(price, _Digits) + ")");
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
     {
      WriteLog("🎫 Order: " + IntegerToString(g_trade.ResultOrder()));
      g_totalPendingOrders++;
     }
   else
      g_totalErrors++;
   
   PrintSeparator();
   return result;
  }

//+------------------------------------------------------------------+
//| BuyStop() Demo                                                   |
//| bool BuyStop(volume, price, symbol, sl, tp, type_time, exp, comment)|
//+------------------------------------------------------------------+
bool DemoBuyStop()
  {
   PrintSeparator("BuyStop() DEMOsu");
   
   double lot = NormalizeLot(InpLotSize);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double price = NormalizePrice(ask + PipsToPoints(InpPendingDistPips));
   double sl = NormalizePrice(price - PipsToPoints(InpSLPips));
   double tp = NormalizePrice(price + PipsToPoints(InpTPPips));
   
   //=================================================================
   // BuyStop() - Buy Stop emri
   // bool CTrade::BuyStop(const double volume,
   //                      const double price,
   //                      const string symbol=NULL,
   //                      const double sl=0.0,
   //                      const double tp=0.0,
   //                      const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,
   //                      const datetime expiration=0,
   //                      const string comment="")
   //=================================================================
   bool result = g_trade.BuyStop(lot, price, _Symbol, sl, tp, ORDER_TIME_DAY, 0, "CTrade_BuyStop");
   
   WriteLog("📊 BuyStop(" + DoubleToString(lot, 2) + ", " + DoubleToString(price, _Digits) + ")");
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
     {
      WriteLog("🎫 Order: " + IntegerToString(g_trade.ResultOrder()));
      g_totalPendingOrders++;
     }
   else
      g_totalErrors++;
   
   PrintSeparator();
   return result;
  }

//+------------------------------------------------------------------+
//| SellLimit() Demo                                                 |
//| bool SellLimit(volume, price, symbol, sl, tp, type_time, exp, comment)|
//+------------------------------------------------------------------+
bool DemoSellLimit()
  {
   PrintSeparator("SellLimit() DEMOsu");
   
   double lot = NormalizeLot(InpLotSize);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double price = NormalizePrice(bid + PipsToPoints(InpPendingDistPips));
   double sl = NormalizePrice(price + PipsToPoints(InpSLPips));
   double tp = NormalizePrice(price - PipsToPoints(InpTPPips));
   
   //=================================================================
   // SellLimit() - Sell Limit emri
   // bool CTrade::SellLimit(const double volume,
   //                        const double price,
   //                        const string symbol=NULL,
   //                        const double sl=0.0,
   //                        const double tp=0.0,
   //                        const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,
   //                        const datetime expiration=0,
   //                        const string comment="")
   //=================================================================
   bool result = g_trade.SellLimit(lot, price, _Symbol, sl, tp, ORDER_TIME_DAY, 0, "CTrade_SellLimit");
   
   WriteLog("📊 SellLimit(" + DoubleToString(lot, 2) + ", " + DoubleToString(price, _Digits) + ")");
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
     {
      WriteLog("🎫 Order: " + IntegerToString(g_trade.ResultOrder()));
      g_totalPendingOrders++;
     }
   else
      g_totalErrors++;
   
   PrintSeparator();
   return result;
  }

//+------------------------------------------------------------------+
//| SellStop() Demo                                                  |
//| bool SellStop(volume, price, symbol, sl, tp, type_time, exp, comment)|
//+------------------------------------------------------------------+
bool DemoSellStop()
  {
   PrintSeparator("SellStop() DEMOsu");
   
   double lot = NormalizeLot(InpLotSize);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double price = NormalizePrice(bid - PipsToPoints(InpPendingDistPips));
   double sl = NormalizePrice(price + PipsToPoints(InpSLPips));
   double tp = NormalizePrice(price - PipsToPoints(InpTPPips));
   
   //=================================================================
   // SellStop() - Sell Stop emri
   // bool CTrade::SellStop(const double volume,
   //                       const double price,
   //                       const string symbol=NULL,
   //                       const double sl=0.0,
   //                       const double tp=0.0,
   //                       const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,
   //                       const datetime expiration=0,
   //                       const string comment="")
   //=================================================================
   bool result = g_trade.SellStop(lot, price, _Symbol, sl, tp, ORDER_TIME_DAY, 0, "CTrade_SellStop");
   
   WriteLog("📊 SellStop(" + DoubleToString(lot, 2) + ", " + DoubleToString(price, _Digits) + ")");
   WriteLog("📋 Sonuç: " + (result ? "BAŞARILI ✅" : "BAŞARISIZ ❌"));
   
   if(result)
     {
      WriteLog("🎫 Order: " + IntegerToString(g_trade.ResultOrder()));
      g_totalPendingOrders++;
     }
   else
      g_totalErrors++;
   
   PrintSeparator();
   return result;
  }

//====================================================================
// KONTROL VE YARDIMCI METODLAR
//====================================================================

//+------------------------------------------------------------------+
//| CheckVolume() Demo                                               |
//| double CheckVolume(symbol, volume, price, order_type)            |
//+------------------------------------------------------------------+
double DemoCheckVolume()
  {
   PrintSeparator("CheckVolume() DEMOsu");
   
   double lot = 1.0;  // Test için 1 lot
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   //=================================================================
   // CheckVolume() - Lot kontrolü
   // virtual double CTrade::CheckVolume(const string symbol,
   //                                    double volume,
   //                                    double price,
   //                                    ENUM_ORDER_TYPE order_type)
   // Serbest marjine göre izin verilen max lot döndürür
   //=================================================================
   double checkedVolume = g_trade.CheckVolume(_Symbol, lot, ask, ORDER_TYPE_BUY);
   
   WriteLog("📊 CheckVolume(" + _Symbol + ", " + DoubleToString(lot, 2) + ", " + 
            DoubleToString(ask, _Digits) + ", ORDER_TYPE_BUY)");
   WriteLog("💰 İstenen: " + DoubleToString(lot, 2) + " lot");
   WriteLog("✅ İzin verilen: " + DoubleToString(checkedVolume, 2) + " lot");
   
   PrintSeparator();
   return checkedVolume;
  }

//+------------------------------------------------------------------+
//| OrderCheck() Demo                                                |
//| bool OrderCheck(const MqlTradeRequest &request,                  |
//|                 MqlTradeCheckResult &check_result)               |
//+------------------------------------------------------------------+
bool DemoOrderCheck()
  {
   PrintSeparator("OrderCheck() DEMOsu");
   
   // Manuel request oluştur
   MqlTradeRequest request;
   MqlTradeCheckResult checkResult;
   ZeroMemory(request);
   ZeroMemory(checkResult);
   
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = NormalizeLot(InpLotSize);
   request.type = ORDER_TYPE_BUY;
   request.price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   request.sl = NormalizePrice(request.price - PipsToPoints(InpSLPips));
   request.tp = NormalizePrice(request.price + PipsToPoints(InpTPPips));
   request.deviation = InpDeviation;
   request.magic = InpMagicNumber;
   request.comment = "CTrade_OrderCheck_Test";
   
   //=================================================================
   // OrderCheck() - Emir kontrolü
   // virtual bool CTrade::OrderCheck(const MqlTradeRequest &request,
   //                                 MqlTradeCheckResult &check_result)
   // Emrin geçerli olup olmadığını kontrol eder
   //=================================================================
   bool result = g_trade.OrderCheck(request, checkResult);
   
   WriteLog("📊 OrderCheck() - " + _Symbol + " BUY " + DoubleToString(request.volume, 2));
   WriteLog("📋 Sonuç: " + (result ? "GEÇERLİ ✅" : "GEÇERSİZ ❌"));
   WriteLog("💰 Bakiye: " + DoubleToString(checkResult.balance, 2));
   WriteLog("💎 Equity: " + DoubleToString(checkResult.equity, 2));
   WriteLog("📊 Marjin: " + DoubleToString(checkResult.margin, 2));
   WriteLog("💵 Serbest Marjin: " + DoubleToString(checkResult.margin_free, 2));
   WriteLog("📈 Marjin Level: " + DoubleToString(checkResult.margin_level, 2) + "%");
   WriteLog("💬 Yorum: " + checkResult.comment);
   
   PrintSeparator();
   return result;
  }

//====================================================================
// OnTick - ANA DÖNGÜ
//====================================================================
void OnTick()
  {
   static bool demoExecuted = false;
   
   // İlk tick'te tüm demo fonksiyonlarını çalıştır
   if(!demoExecuted)
     {
      PrintSeparator("CTrade TÜM METODLAR DEMO");
      WriteLog("⏰ Zaman: " + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));
      
      //--- Request bilgilerini göster (başlangıçta boş olacak)
      if(InpShowAllRequestInfo)
         ShowAllRequestInfo();
      
      //--- CheckVolume testi
      DemoCheckVolume();
      
      //--- OrderCheck testi
      DemoOrderCheck();
      
      //--- CheckResult bilgilerini göster (OrderCheck sonrası dolu olacak)
      if(InpShowAllCheckInfo)
         ShowAllCheckResultInfo();
      
      //--- Tüm demo modlarını çalıştır
      switch(InpDemoMode)
        {
         case DEMO_POSITION_OPS:
            // Sadece pozisyon işlemleri
            if(InpUseBuy) DemoBuy();
            break;
            
         case DEMO_PENDING_OPS:
            // Sadece bekleyen emirler
            if(InpUseBuyLimit) DemoBuyLimit();
            break;
            
         case DEMO_REQUEST_INFO:
            // Sadece request bilgileri
            ShowAllRequestInfo();
            break;
            
         case DEMO_RESULT_INFO:
            // Sadece result bilgileri
            ShowAllResultInfo();
            break;
            
         case DEMO_CHECK_INFO:
            // Sadece check result bilgileri
            ShowAllCheckResultInfo();
            break;
            
         case DEMO_ALL_FEATURES:
            // TÜM ÖZELLİKLER
            
            //--- 1. Market emirleri
            if(InpUseBuy)
              {
               WriteLog("🔷 BUY İŞLEMİ AÇILIYOR...");
               DemoBuy();
              }
            
            //--- 2. Result bilgilerini göster (işlem sonrası)
            if(InpShowAllResultInfo)
               ShowAllResultInfo();
            
            //--- 3. Request bilgilerini göster
            if(InpShowAllRequestInfo)
               ShowAllRequestInfo();
            
            //--- 4. Bekleyen emirler
            if(InpUseBuyLimit)
              {
               WriteLog("🔷 BUY LIMIT EMRİ AÇILIYOR...");
               DemoBuyLimit();
              }
            
            if(InpUseBuyStop)
              {
               WriteLog("🔷 BUY STOP EMRİ AÇILIYOR...");
               DemoBuyStop();
              }
            
            if(InpUseSellLimit)
              {
               WriteLog("🔷 SELL LIMIT EMRİ AÇILIYOR...");
               DemoSellLimit();
              }
            
            if(InpUseSellStop)
              {
               WriteLog("🔷 SELL STOP EMRİ AÇILIYOR...");
               DemoSellStop();
              }
            
            break;
            
         default:
            break;
        }
      
      demoExecuted = true;
      PrintSeparator("DEMO TAMAMLANDI");
      WriteLog("📊 Toplam işlem: " + IntegerToString(g_totalBuyOrders + g_totalSellOrders + g_totalPendingOrders));
     }
  }
