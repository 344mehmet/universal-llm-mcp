# 📘 TypeScript/JavaScript Programlama Eğitim RAG'i

## Türkçe TypeScript Eğitimi - LLM'ler İçin

### Temel Kavramlar

#### Değişkenler ve Tipler

```typescript
// Temel tipler
let isim: string = "Mehmet";
let yas: number = 25;
let aktif: boolean = true;

// Array (dizi)
let sayilar: number[] = [1, 2, 3, 4, 5];
let meyveler: Array<string> = ["elma", "armut"];

// Tuple
let koordinat: [number, number] = [10, 20];

// Enum
enum Durum {
    Beklemede = "BEKLEMEDE",
    Aktif = "AKTIF",
    Tamamlandi = "TAMAMLANDI"
}

// Any ve Unknown
let bilinmeyen: unknown = "test";
let hersey: any = 42;

// Union tipler
let id: string | number = "abc123";

// Literal tipler
type Yön = "kuzey" | "güney" | "doğu" | "batı";
```

#### Interface ve Type

```typescript
// Interface tanımı
interface Kullanici {
    id: number;
    isim: string;
    email: string;
    yas?: number; // opsiyonel
    readonly olusturmaTarihi: Date;
}

// Type alias
type Koordinat = {
    x: number;
    y: number;
};

// Genişletme (extend)
interface Admin extends Kullanici {
    yetkiler: string[];
}

// Intersection
type KullaniciVeAdmin = Kullanici & { yetkiler: string[] };
```

#### Fonksiyonlar

```typescript
// Temel fonksiyon
function selamla(isim: string): string {
    return `Merhaba, ${isim}!`;
}

// Arrow function
const topla = (a: number, b: number): number => a + b;

// Opsiyonel ve varsayılan parametreler
function konfigur(ayar: string, deger: number = 10): void {
    console.log(`${ayar}: ${deger}`);
}

// Rest parametreler
function hepsiniTopla(...sayilar: number[]): number {
    return sayilar.reduce((t, s) => t + s, 0);
}

// Generic fonksiyon
function ilkElemani<T>(dizi: T[]): T | undefined {
    return dizi[0];
}

// Overload
function isle(x: string): string;
function isle(x: number): number;
function isle(x: string | number): string | number {
    if (typeof x === "string") return x.toUpperCase();
    return x * 2;
}
```

#### Sınıflar

```typescript
class Araba {
    private marka: string;
    protected model: string;
    public yil: number;
    
    constructor(marka: string, model: string, yil: number) {
        this.marka = marka;
        this.model = model;
        this.yil = yil;
    }
    
    get bilgi(): string {
        return `${this.yil} ${this.marka} ${this.model}`;
    }
    
    sur(): void {
        console.log("Araba sürülüyor...");
    }
}

// Kalıtım
class ElektrikliAraba extends Araba {
    private bataryaKapasitesi: number;
    
    constructor(marka: string, model: string, yil: number, batarya: number) {
        super(marka, model, yil);
        this.bataryaKapasitesi = batarya;
    }
    
    sarjEt(): void {
        console.log("Şarj ediliyor...");
    }
}

// Abstract sınıf
abstract class Sekil {
    abstract alan(): number;
    abstract cevre(): number;
}
```

### İleri Düzey Konular

#### Generics

```typescript
// Generic interface
interface Depo<T> {
    getir(id: string): T;
    kaydet(item: T): void;
    sil(id: string): boolean;
}

// Generic sınıf
class VeriDepom<T> implements Depo<T> {
    private items: Map<string, T> = new Map();
    
    getir(id: string): T {
        return this.items.get(id)!;
    }
    
    kaydet(item: T): void {
        // kaydet
    }
    
    sil(id: string): boolean {
        return this.items.delete(id);
    }
}

// Constraints (kısıtlamalar)
interface Uzunluklu {
    length: number;
}

function uzunlukBildir<T extends Uzunluklu>(item: T): number {
    return item.length;
}
```

#### Async/Await

```typescript
// Promise
async function veriCek(url: string): Promise<any> {
    const yanit = await fetch(url);
    const veri = await yanit.json();
    return veri;
}

// Paralel işlemler
async function tumunuCek(urls: string[]): Promise<any[]> {
    const sonuclar = await Promise.all(urls.map(url => veriCek(url)));
    return sonuclar;
}

// Try-catch
async function guvenliCek(url: string): Promise<any | null> {
    try {
        return await veriCek(url);
    } catch (hata) {
        console.error("Hata:", hata);
        return null;
    }
}
```

#### Decorators

```typescript
// Method decorator
function Log(target: any, key: string, descriptor: PropertyDescriptor) {
    const orijinal = descriptor.value;
    descriptor.value = function(...args: any[]) {
        console.log(`Çağrıldı: ${key}`);
        return orijinal.apply(this, args);
    };
}

class Servis {
    @Log
    veriAl() {
        return "veri";
    }
}
```

### Node.js & Express

```typescript
import express, { Request, Response } from 'express';

const app = express();
app.use(express.json());

interface Kullanici {
    id: number;
    isim: string;
}

const kullanicilar: Kullanici[] = [];

app.get('/kullanicilar', (req: Request, res: Response) => {
    res.json(kullanicilar);
});

app.post('/kullanici', (req: Request, res: Response) => {
    const yeniKullanici: Kullanici = req.body;
    kullanicilar.push(yeniKullanici);
    res.status(201).json(yeniKullanici);
});

app.listen(3000, () => {
    console.log('Sunucu 3000 portunda çalışıyor');
});
```

### React & Next.js

```tsx
import { useState, useEffect } from 'react';

interface Props {
    baslik: string;
    aciklama?: string;
}

const Kart: React.FC<Props> = ({ baslik, aciklama }) => {
    const [aktif, setAktif] = useState(false);
    
    useEffect(() => {
        console.log('Bileşen yüklendi');
        return () => console.log('Bileşen kaldırıldı');
    }, []);
    
    return (
        <div className={`kart ${aktif ? 'aktif' : ''}`}>
            <h2>{baslik}</h2>
            {aciklama && <p>{aciklama}</p>}
            <button onClick={() => setAktif(!aktif)}>
                {aktif ? 'Kapat' : 'Aç'}
            </button>
        </div>
    );
};

export default Kart;
```

---
**LLM Notu:** Bu doküman Türkçe TypeScript/JavaScript eğitimi için RAG kaynağıdır.
