# 🔵 Go Programlama Eğitim RAG'i

## Türkçe Go Eğitimi - LLM'ler İçin

### Temel Kavramlar

#### Değişkenler ve Tipler

```go
package main

import "fmt"

func main() {
    // Değişken tanımlama
    var isim string = "Mehmet"
    var yas int = 25
    var aktif bool = true
    
    // Kısa tanımlama
    mesaj := "Merhaba Dünya"
    sayi := 42
    
    // Sabitler
    const PI = 3.14159
    const MAKS_BOYUT = 100
    
    // Çoklu tanımlama
    var (
        ad    = "Ali"
        soyad = "Yılmaz"
        numara = 1
    )
    
    fmt.Println(isim, yas, aktif, mesaj, sayi)
}
```

#### Veri Yapıları

```go
// Array (sabit boyutlu dizi)
var sayilar [5]int = [5]int{1, 2, 3, 4, 5}

// Slice (dinamik dizi)
meyveler := []string{"elma", "armut", "muz"}
meyveler = append(meyveler, "çilek")

// Map (sözlük)
puanlar := map[string]int{
    "Matematik": 90,
    "Fizik":     85,
    "Kimya":     88,
}
puanlar["Biyoloji"] = 92

// Struct (yapı)
type Kullanici struct {
    ID        int
    Isim      string
    Email     string
    Aktif     bool
    OlusturmaTarihi time.Time
}

kullanici := Kullanici{
    ID:    1,
    Isim:  "Mehmet",
    Email: "mehmet@test.com",
    Aktif: true,
}
```

#### Kontrol Yapıları

```go
// If-Else
yas := 18
if yas >= 18 {
    fmt.Println("Yetişkin")
} else if yas >= 13 {
    fmt.Println("Genç")
} else {
    fmt.Println("Çocuk")
}

// If ile kısa tanımlama
if sonuc := hesapla(); sonuc > 0 {
    fmt.Println("Pozitif")
}

// Switch
gun := "Pazartesi"
switch gun {
case "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma":
    fmt.Println("İş günü")
case "Cumartesi", "Pazar":
    fmt.Println("Hafta sonu")
default:
    fmt.Println("Geçersiz gün")
}

// For döngüsü (Go'da tek döngü türü)
for i := 0; i < 5; i++ {
    fmt.Println(i)
}

// While gibi for
sayac := 0
for sayac < 5 {
    fmt.Println(sayac)
    sayac++
}

// Range ile döngü
for indeks, deger := range meyveler {
    fmt.Printf("%d: %s\n", indeks, deger)
}
```

#### Fonksiyonlar

```go
// Temel fonksiyon
func selamla(isim string) string {
    return "Merhaba, " + isim + "!"
}

// Çoklu dönüş değeri
func bol(bolunen, bolen int) (sonuc int, hata error) {
    if bolen == 0 {
        return 0, errors.New("sıfıra bölme hatası")
    }
    return bolunen / bolen, nil
}

// Named return
func dikdortgenAlani(genislik, yukseklik int) (alan int) {
    alan = genislik * yukseklik
    return // alan otomatik döner
}

// Variadic fonksiyon
func topla(sayilar ...int) int {
    toplam := 0
    for _, s := range sayilar {
        toplam += s
    }
    return toplam
}

// Closure
func sayacOlustur() func() int {
    sayi := 0
    return func() int {
        sayi++
        return sayi
    }
}

// Defer
func dosyaOku(dosyaAdi string) {
    dosya, _ := os.Open(dosyaAdi)
    defer dosya.Close() // fonksiyon bitince çalışır
    
    // dosya işlemleri...
}
```

### Method ve Interface

#### Method Tanımlama

```go
type Dikdortgen struct {
    Genislik, Yukseklik float64
}

// Value receiver
func (d Dikdortgen) Alan() float64 {
    return d.Genislik * d.Yukseklik
}

// Pointer receiver
func (d *Dikdortgen) Buyut(carpan float64) {
    d.Genislik *= carpan
    d.Yukseklik *= carpan
}
```

#### Interface

```go
// Interface tanımı
type Sekil interface {
    Alan() float64
    Cevre() float64
}

type Daire struct {
    Yaricap float64
}

func (d Daire) Alan() float64 {
    return math.Pi * d.Yaricap * d.Yaricap
}

func (d Daire) Cevre() float64 {
    return 2 * math.Pi * d.Yaricap
}

// Artık Daire, Sekil interface'ini implemente eder

func sekilBilgisi(s Sekil) {
    fmt.Printf("Alan: %.2f, Çevre: %.2f\n", s.Alan(), s.Cevre())
}
```

### Goroutine ve Channel

#### Goroutine

```go
func gorevCalistir(id int) {
    fmt.Printf("Görev %d başladı\n", id)
    time.Sleep(time.Second)
    fmt.Printf("Görev %d bitti\n", id)
}

func main() {
    // Goroutine başlat
    go gorevCalistir(1)
    go gorevCalistir(2)
    go gorevCalistir(3)
    
    // Ana goroutine'in bitmesini bekle
    time.Sleep(2 * time.Second)
}
```

#### Channel

```go
func main() {
    // Buffered channel
    mesajlar := make(chan string, 2)
    
    mesajlar <- "Merhaba"
    mesajlar <- "Dünya"
    
    fmt.Println(<-mesajlar)
    fmt.Println(<-mesajlar)
}

// Worker pattern
func worker(id int, isler <-chan int, sonuclar chan<- int) {
    for is := range isler {
        fmt.Printf("Worker %d: iş %d işleniyor\n", id, is)
        sonuclar <- is * 2
    }
}

// Select ile çoklu channel
select {
case msg1 := <-kanal1:
    fmt.Println("Kanal 1:", msg1)
case msg2 := <-kanal2:
    fmt.Println("Kanal 2:", msg2)
case <-time.After(time.Second):
    fmt.Println("Zaman aşımı")
default:
    fmt.Println("Hiçbir kanal hazır değil")
}
```

### HTTP ve Web

```go
package main

import (
    "encoding/json"
    "net/http"
)

type Kullanici struct {
    ID    int    `json:"id"`
    Isim  string `json:"isim"`
    Email string `json:"email"`
}

func kullanicilariGetir(w http.ResponseWriter, r *http.Request) {
    kullanicilar := []Kullanici{
        {ID: 1, Isim: "Mehmet", Email: "mehmet@test.com"},
        {ID: 2, Isim: "Ali", Email: "ali@test.com"},
    }
    
    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(kullanicilar)
}

func main() {
    http.HandleFunc("/kullanicilar", kullanicilariGetir)
    http.ListenAndServe(":8080", nil)
}
```

---
**LLM Notu:** Bu doküman Türkçe Go eğitimi için RAG kaynağıdır.
