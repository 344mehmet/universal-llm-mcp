# MQL5 CTrade Sınıfı - Kapsamlı Referans

Bu belge, MetaTrader 5 için resmi CTrade sınıfının tam dokümantasyonunu içerir.

## Temel Bilgiler

CTrade sınıfı `<Trade/Trade.mqh>` dosyasında tanımlıdır ve şu işlemleri yapmanızı sağlar:

- Market emirleri (Buy/Sell)
- Pending emirler (Limit/Stop)
- Pozisyon yönetimi (SL/TP değiştirme, kapatma)
- İşlem doğrulama ve hata yönetimi

## İmport

```mql5
#include <Trade/Trade.mqh>

CTrade m_trade;
```

## Constructor ve Ayarlar

```mql5
// Magic number ayarla (EA'yı tanımlar)
m_trade.SetExpertMagicNumber(123456);

// Slippage/deviation ayarla (pip cinsinden)
m_trade.SetDeviationInPoints(20);

// Doldurma tipini ayarla
m_trade.SetTypeFilling(ORDER_FILLING_FOK);

// Log seviyesi (LOG_LEVEL_NO, LOG_LEVEL_ERRORS, LOG_LEVEL_ALL)
m_trade.LogLevel(LOG_LEVEL_ERRORS);

// Asenkron mod (beklemeden devam)
m_trade.SetAsyncMode(false);
```

## Market Emirleri

### Buy - Al Emri

```mql5
bool CTrade::Buy(
    const double volume,                    // Lot miktarı (zorunlu)
    const string symbol=NULL,               // Sembol (NULL = mevcut)
    double price=0.0,                       // Fiyat (0 = SYMBOL_ASK)
    const double sl=0.0,                    // Stop Loss (0 = yok)
    const double tp=0.0,                    // Take Profit (0 = yok)
    const string comment=""                 // Yorum
);

// Örnek kullanım:
m_trade.Buy(0.1, _Symbol, 0, 1.2050, 1.2150, "Buy örnek");
```

### Sell - Sat Emri

```mql5
bool CTrade::Sell(
    const double volume,
    const string symbol=NULL,
    double price=0.0,                       // Fiyat (0 = SYMBOL_BID)
    const double sl=0.0,
    const double tp=0.0,
    const string comment=""
);

// Örnek:
m_trade.Sell(0.1, _Symbol, 0, 1.2150, 1.2050, "Sell örnek");
```

## Pending (Bekleyen) Emirler

### BuyLimit - Limit Al

Mevcut fiyatın ALTINDA al emri beklet.

```mql5
bool CTrade::BuyLimit(
    const double volume,                    // Lot
    const double price,                     // Giriş fiyatı (mevcut Ask'ın altında)
    const string symbol=NULL,
    const double sl=0.0,
    const double tp=0.0,
    const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,  // Süre tipi
    const datetime expiration=0,            // Bitiş zamanı
    const string comment=""
);
```

### BuyStop - Stop Al

Mevcut fiyatın ÜSTÜNDE al emri beklet.

```mql5
bool CTrade::BuyStop(
    const double volume,
    const double price,                     // Giriş fiyatı (mevcut Ask'ın üstünde)
    const string symbol=NULL,
    const double sl=0.0,
    const double tp=0.0,
    const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,
    const datetime expiration=0,
    const string comment=""
);
```

### SellLimit - Limit Sat

Mevcut fiyatın ÜSTÜNDE sat emri beklet.

```mql5
bool CTrade::SellLimit(
    const double volume,
    const double price,                     // Giriş fiyatı (mevcut Bid'in üstünde)
    ...
);
```

### SellStop - Stop Sat

Mevcut fiyatın ALTINDA sat emri beklet.

```mql5
bool CTrade::SellStop(
    const double volume,
    const double price,                     // Giriş fiyatı (mevcut Bid'in altında)
    ...
);
```

## Pozisyon Yönetimi

### PositionOpen - Pozisyon Aç

```mql5
bool CTrade::PositionOpen(
    const string symbol,
    const ENUM_ORDER_TYPE order_type,       // ORDER_TYPE_BUY veya ORDER_TYPE_SELL
    const double volume,
    const double price,
    const double sl,
    const double tp,
    const string comment=""
);
```

### PositionModify - SL/TP Değiştir

```mql5
// Sembol ile
bool CTrade::PositionModify(const string symbol, const double sl, const double tp);

// Ticket ile
bool CTrade::PositionModify(const ulong ticket, const double sl, const double tp);

// Örnek:
m_trade.PositionModify(ticket, newSL, newTP);
```

### PositionClose - Pozisyon Kapat

```mql5
// Sembol ile
bool CTrade::PositionClose(const string symbol, const ulong deviation=ULONG_MAX);

// Ticket ile
bool CTrade::PositionClose(const ulong ticket, const ulong deviation=ULONG_MAX);
```

### PositionClosePartial - Kısmi Kapatma (Hedging Modu)

```mql5
bool CTrade::PositionClosePartial(
    const ulong ticket,
    const double volume,                    // Kapatılacak miktar
    const ulong deviation=ULONG_MAX
);

// Örnek: Pozisyonun %50'sini kapat
double closeVol = positionVolume * 0.5;
m_trade.PositionClosePartial(ticket, closeVol);
```

### PositionCloseBy - Karşılıklı Kapatma (Hedging)

```mql5
bool CTrade::PositionCloseBy(const ulong ticket, const ulong ticket_by);
```

## Pending Emir Yönetimi

### OrderModify - Emir Değiştir

```mql5
bool CTrade::OrderModify(
    const ulong ticket,                     // Emir ticket
    const double price,                     // Yeni fiyat
    const double sl,
    const double tp,
    const ENUM_ORDER_TYPE_TIME type_time,
    const datetime expiration,
    const double stoplimit=0.0
);
```

### OrderDelete - Emir İptal

```mql5
bool CTrade::OrderDelete(const ulong ticket);
```

## Sonuç Kontrolü

### İşlem Sonrası Kontrol

```mql5
// İşlem sonucu kodu
uint retcode = m_trade.ResultRetcode();

// Başarılı kontrol
if(m_trade.ResultRetcode() == TRADE_RETCODE_DONE)
{
    ulong ticket = m_trade.ResultOrder();   // Emir ticket
    double price = m_trade.ResultPrice();   // İşlem fiyatı
    double volume = m_trade.ResultVolume(); // İşlem miktarı
}

// Hata açıklaması
string hata = m_trade.ResultRetcodeDescription();
```

### Yaygın RetCode Değerleri

| Kod | Sabit | Açıklama |
|-----|-------|----------|
| 10009 | TRADE_RETCODE_DONE | Başarılı |
| 10008 | TRADE_RETCODE_PLACED | Emir yerleştirildi |
| 10004 | TRADE_RETCODE_REQUOTE | Requote |
| 10006 | TRADE_RETCODE_REJECT | Reddedildi |
| 10019 | TRADE_RETCODE_NO_MONEY | Yetersiz bakiye |
| 10016 | TRADE_RETCODE_INVALID_STOPS | Geçersiz SL/TP |
| 10014 | TRADE_RETCODE_INVALID_VOLUME | Geçersiz lot |

## Request Bilgileri

```mql5
// İstek bilgilerine erişim
ENUM_TRADE_REQUEST_ACTIONS action = m_trade.RequestAction();
ulong magic = m_trade.RequestMagic();
string symbol = m_trade.RequestSymbol();
double volume = m_trade.RequestVolume();
double price = m_trade.RequestPrice();
double sl = m_trade.RequestSL();
double tp = m_trade.RequestTP();
ENUM_ORDER_TYPE type = m_trade.RequestType();
```

## Tam Örnek: Güvenli İşlem Açma

```mql5
#include <Trade/Trade.mqh>

CTrade m_trade;

int OnInit()
{
    m_trade.SetExpertMagicNumber(123456);
    m_trade.SetDeviationInPoints(20);
    m_trade.SetTypeFilling(ORDER_FILLING_FOK);
    return INIT_SUCCEEDED;
}

void OpenBuyTrade(double lot, double sl, double tp)
{
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
    
    sl = NormalizeDouble(sl, digits);
    tp = NormalizeDouble(tp, digits);
    
    ResetLastError();
    
    if(m_trade.Buy(lot, _Symbol, 0, sl, tp, "My EA"))
    {
        if(m_trade.ResultRetcode() == TRADE_RETCODE_DONE)
        {
            Print("✅ BUY başarılı! Ticket: ", m_trade.ResultOrder());
        }
    }
    else
    {
        Print("❌ HATA: ", m_trade.ResultRetcodeDescription());
        Print("LastError: ", GetLastError());
    }
}
```

## ENUM Tanımları

### ENUM_ORDER_TYPE

- ORDER_TYPE_BUY
- ORDER_TYPE_SELL
- ORDER_TYPE_BUY_LIMIT
- ORDER_TYPE_SELL_LIMIT
- ORDER_TYPE_BUY_STOP
- ORDER_TYPE_SELL_STOP
- ORDER_TYPE_BUY_STOP_LIMIT
- ORDER_TYPE_SELL_STOP_LIMIT

### ENUM_ORDER_TYPE_FILLING

- ORDER_FILLING_FOK (Fill or Kill)
- ORDER_FILLING_IOC (Immediate or Cancel)
- ORDER_FILLING_RETURN (Kalan döner)

### ENUM_ORDER_TYPE_TIME

- ORDER_TIME_GTC (Good Till Cancelled)
- ORDER_TIME_DAY (Gün sonuna kadar)
- ORDER_TIME_SPECIFIED (Belirtilen zamana kadar)

## Hedging vs Netting Modu

```mql5
// Hesap modunu kontrol et
ENUM_ACCOUNT_MARGIN_MODE mode = (ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);

if(mode == ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
{
    // Hedging: Aynı sembole birden çok pozisyon açılabilir
    // PositionClosePartial ve PositionCloseBy kullanılabilir
}
else
{
    // Netting: Tek pozisyon, yeni işlemler mevcut pozisyonu değiştirir
}
```

## Önemli Notlar

1. **Her zaman NormalizeDouble kullanın** - Fiyatları SYMBOL_DIGITS ile normalize edin
2. **StopLevel kontrolü yapın** - Broker minimum SL/TP mesafesi gerektirebilir
3. **Spread kontrolü** - Yüksek spread'de işlem açmayın
4. **Volume limitleri** - SYMBOL_VOLUME_MIN, SYMBOL_VOLUME_MAX, SYMBOL_VOLUME_STEP kontrol edin
5. **ResultRetcode kontrolü zorunlu** - Her işlemden sonra sonucu kontrol edin
