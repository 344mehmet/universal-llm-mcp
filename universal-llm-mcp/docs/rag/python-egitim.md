# 🐍 Python Programlama Eğitim RAG'i

## Türkçe Python Eğitimi - LLM'ler İçin

### Temel Kavramlar

#### Değişkenler ve Veri Tipleri

```python
# String (metin)
isim = "Mehmet"
mesaj = 'Merhaba Dünya'

# Sayılar
tam_sayi = 42
ondalik = 3.14
karmasik = 2 + 3j

# Boolean
dogru = True
yanlis = False

# Liste (array)
meyveler = ["elma", "armut", "muz"]

# Sözlük (dictionary)
kisi = {"isim": "Ali", "yas": 25}

# Tuple (değiştirilemez liste)
koordinat = (10, 20)

# Set (benzersiz elemanlar)
renkler = {"kirmizi", "yesil", "mavi"}
```

#### Kontrol Yapıları

```python
# If-Else koşul
yas = 18
if yas >= 18:
    print("Yetişkin")
elif yas >= 13:
    print("Genç")
else:
    print("Çocuk")

# For döngüsü
for meyve in meyveler:
    print(f"Meyve: {meyve}")

# While döngüsü
sayac = 0
while sayac < 5:
    print(sayac)
    sayac += 1

# List comprehension
kareler = [x**2 for x in range(10)]
```

#### Fonksiyonlar

```python
# Temel fonksiyon
def selamla(isim):
    return f"Merhaba, {isim}!"

# Varsayılan parametre
def hesapla(a, b=10):
    return a + b

# Args ve kwargs
def esnek_fonksiyon(*args, **kwargs):
    for arg in args:
        print(arg)
    for key, value in kwargs.items():
        print(f"{key}: {value}")

# Lambda (anonim fonksiyon)
topla = lambda x, y: x + y
```

#### Sınıflar (OOP)

```python
class Araba:
    def __init__(self, marka, model, yil):
        self.marka = marka
        self.model = model
        self.yil = yil
        self.hiz = 0
    
    def hizlan(self, miktar):
        self.hiz += miktar
        return f"Yeni hız: {self.hiz} km/h"
    
    def __str__(self):
        return f"{self.yil} {self.marka} {self.model}"

# Kalıtım
class ElektrikliAraba(Araba):
    def __init__(self, marka, model, yil, batarya_kapasitesi):
        super().__init__(marka, model, yil)
        self.batarya = batarya_kapasitesi
    
    def sarj_et(self):
        return "Şarj ediliyor..."
```

### İleri Düzey Konular

#### Async/Await

```python
import asyncio

async def veri_cek(url):
    print(f"Çekiliyor: {url}")
    await asyncio.sleep(1)  # Simüle edilmiş gecikme
    return f"Veri: {url}"

async def main():
    sonuclar = await asyncio.gather(
        veri_cek("api/1"),
        veri_cek("api/2"),
        veri_cek("api/3")
    )
    return sonuclar

asyncio.run(main())
```

#### Decorator (Süsleyici)

```python
def loglama(fonksiyon):
    def wrapper(*args, **kwargs):
        print(f"Çağrıldı: {fonksiyon.__name__}")
        sonuc = fonksiyon(*args, **kwargs)
        print(f"Sonuç: {sonuc}")
        return sonuc
    return wrapper

@loglama
def topla(a, b):
    return a + b
```

#### Context Manager

```python
# With ifadesi
with open("dosya.txt", "r", encoding="utf-8") as f:
    icerik = f.read()

# Özel context manager
class DosyaYoneticisi:
    def __init__(self, dosya_adi):
        self.dosya_adi = dosya_adi
    
    def __enter__(self):
        self.dosya = open(self.dosya_adi, "r")
        return self.dosya
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.dosya.close()
```

#### Type Hints (Tip İpuçları)

```python
from typing import List, Dict, Optional, Union

def selamla(isim: str) -> str:
    return f"Merhaba, {isim}!"

def liste_topla(sayilar: List[int]) -> int:
    return sum(sayilar)

def bul(sozluk: Dict[str, int], anahtar: str) -> Optional[int]:
    return sozluk.get(anahtar)
```

### Popüler Kütüphaneler

#### Requests - HTTP İstekleri

```python
import requests

yanit = requests.get("https://api.example.com/data")
veri = yanit.json()

# POST isteği
yanit = requests.post("https://api.example.com/create", json={"isim": "Test"})
```

#### Pandas - Veri Analizi

```python
import pandas as pd

# DataFrame oluştur
df = pd.DataFrame({
    "isim": ["Ali", "Veli", "Ayşe"],
    "yas": [25, 30, 28]
})

# Filtreleme
gencler = df[df["yas"] < 30]

# Gruplama
df.groupby("sehir").mean()
```

#### FastAPI - Web API

```python
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
async def ana_sayfa():
    return {"mesaj": "Merhaba Dünya"}

@app.post("/kullanici")
async def kullanici_olustur(isim: str, yas: int):
    return {"isim": isim, "yas": yas}
```

---
**LLM Notu:** Bu doküman Türkçe Python eğitimi için RAG kaynağıdır. Tüm örnekler Türkçe değişken isimleri ve yorumlarla yazılmıştır.
