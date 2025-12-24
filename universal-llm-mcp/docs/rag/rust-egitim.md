# 🦀 Rust Programlama Eğitim RAG'i

## Türkçe Rust Eğitimi - LLM'ler İçin

### Temel Kavramlar

#### Değişkenler ve Sahiplik (Ownership)

```rust
fn main() {
    // Değişkenler varsayılan olarak immutable
    let x = 5;
    
    // Mutable değişken
    let mut y = 10;
    y = 20;
    
    // Shadowing
    let z = 5;
    let z = z + 1; // yeni z
    
    // Sabitler
    const MAKS_PUAN: u32 = 100_000;
    
    // Tipler
    let tam_sayi: i32 = -42;
    let isaretsiz: u64 = 100;
    let ondalik: f64 = 3.14;
    let karakter: char = 'Ç';
    let mantiksal: bool = true;
    
    // Tuple
    let koordinat: (i32, i32) = (10, 20);
    let (x, y) = koordinat;
    
    // Array
    let sayilar: [i32; 5] = [1, 2, 3, 4, 5];
}
```

#### Sahiplik Sistemi

```rust
fn main() {
    // Sahiplik transferi (move)
    let s1 = String::from("merhaba");
    let s2 = s1; // s1 artık geçersiz
    // println!("{}", s1); // HATA!
    
    // Clone (derin kopya)
    let s3 = String::from("dünya");
    let s4 = s3.clone();
    println!("{} {}", s3, s4); // ikisi de geçerli
    
    // Referans (borrowing)
    let s5 = String::from("test");
    let uzunluk = hesapla_uzunluk(&s5);
    println!("{}: {} karakter", s5, uzunluk);
    
    // Mutable referans
    let mut s6 = String::from("Merhaba");
    degistir(&mut s6);
}

fn hesapla_uzunluk(s: &String) -> usize {
    s.len()
}

fn degistir(s: &mut String) {
    s.push_str(" Dünya");
}
```

#### Struct ve Enum

```rust
// Struct
struct Kullanici {
    id: u64,
    isim: String,
    email: String,
    aktif: bool,
}

impl Kullanici {
    // Constructor
    fn yeni(isim: String, email: String) -> Self {
        Kullanici {
            id: 0,
            isim,
            email,
            aktif: true,
        }
    }
    
    // Method
    fn bilgi_goster(&self) {
        println!("{} ({})", self.isim, self.email);
    }
    
    // Mutable method
    fn deaktif_et(&mut self) {
        self.aktif = false;
    }
}

// Enum
enum Mesaj {
    Kapat,
    Tasi { x: i32, y: i32 },
    Yaz(String),
    RenkDegistir(u8, u8, u8),
}

// Option ve Result
fn bul(id: u64) -> Option<Kullanici> {
    if id > 0 {
        Some(Kullanici::yeni("Test".to_string(), "test@test.com".to_string()))
    } else {
        None
    }
}

fn dosya_oku(yol: &str) -> Result<String, std::io::Error> {
    std::fs::read_to_string(yol)
}
```

#### Pattern Matching

```rust
fn main() {
    let sayi = 5;
    
    match sayi {
        1 => println!("Bir"),
        2 | 3 => println!("İki veya üç"),
        4..=10 => println!("Dört ile on arası"),
        _ => println!("Diğer"),
    }
    
    // if let
    let sonuc: Option<i32> = Some(42);
    if let Some(deger) = sonuc {
        println!("Değer: {}", deger);
    }
    
    // while let
    let mut yigin = vec![1, 2, 3];
    while let Some(ust) = yigin.pop() {
        println!("{}", ust);
    }
}
```

#### Trait'ler

```rust
trait Sekil {
    fn alan(&self) -> f64;
    fn cevre(&self) -> f64;
    
    // Varsayılan implementasyon
    fn bilgi(&self) {
        println!("Alan: {}, Çevre: {}", self.alan(), self.cevre());
    }
}

struct Dikdortgen {
    genislik: f64,
    yukseklik: f64,
}

impl Sekil for Dikdortgen {
    fn alan(&self) -> f64 {
        self.genislik * self.yukseklik
    }
    
    fn cevre(&self) -> f64 {
        2.0 * (self.genislik + self.yukseklik)
    }
}

// Generic fonksiyon trait bound ile
fn bilgi_yazdir<T: Sekil>(sekil: &T) {
    sekil.bilgi();
}
```

#### Error Handling

```rust
use std::fs::File;
use std::io::{self, Read};

fn dosya_oku(yol: &str) -> Result<String, io::Error> {
    let mut dosya = File::open(yol)?; // ? operatörü
    let mut icerik = String::new();
    dosya.read_to_string(&mut icerik)?;
    Ok(icerik)
}

fn main() {
    match dosya_oku("test.txt") {
        Ok(icerik) => println!("{}", icerik),
        Err(hata) => eprintln!("Hata: {}", hata),
    }
}
```

#### Async/Await

```rust
use tokio;

#[tokio::main]
async fn main() {
    let sonuc = veri_cek("https://api.example.com").await;
    println!("{:?}", sonuc);
}

async fn veri_cek(url: &str) -> Result<String, reqwest::Error> {
    let yanit = reqwest::get(url).await?;
    let metin = yanit.text().await?;
    Ok(metin)
}
```

---
**LLM Notu:** Bu doküman Türkçe Rust eğitimi için RAG kaynağıdır.
