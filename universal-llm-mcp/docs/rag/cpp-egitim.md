# ⚡ C/C++ Programlama Eğitim RAG'i

## Türkçe C/C++ Eğitimi - LLM'ler İçin

### C Dili Temelleri

#### Değişkenler ve Tipler

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    // Temel tipler
    char karakter = 'A';
    int tamSayi = 42;
    short kucukSayi = 100;
    long buyukSayi = 1000000L;
    float ondalik = 3.14f;
    double hassasOndalik = 3.14159265359;
    
    // Unsigned (işaretsiz)
    unsigned int pozitifSayi = 100;
    
    // Diziler
    int sayilar[5] = {1, 2, 3, 4, 5};
    char metin[] = "Merhaba";
    
    // Pointer (işaretçi)
    int *ptr = &tamSayi;
    printf("Değer: %d, Adres: %p\n", *ptr, (void*)ptr);
    
    // Dinamik bellek
    int *dinamikDizi = (int*)malloc(10 * sizeof(int));
    if (dinamikDizi == NULL) {
        printf("Bellek ayrılamadı!\n");
        return 1;
    }
    free(dinamikDizi);
    
    return 0;
}
```

#### Yapılar (Struct)

```c
// Struct tanımı
struct Kullanici {
    int id;
    char isim[50];
    char email[100];
    int yas;
};

// typedef ile kısaltma
typedef struct {
    double x;
    double y;
} Nokta;

// Kullanım
struct Kullanici k1;
k1.id = 1;
strcpy(k1.isim, "Mehmet");
k1.yas = 25;

Nokta p1 = {10.5, 20.3};

// Pointer ile struct
struct Kullanici *kPtr = &k1;
printf("İsim: %s\n", kPtr->isim);
```

#### Fonksiyonlar

```c
// Temel fonksiyon
int topla(int a, int b) {
    return a + b;
}

// Pointer parametre (değiştirilebilir)
void degistir(int *a, int *b) {
    int gecici = *a;
    *a = *b;
    *b = gecici;
}

// Dizi parametre
void diziYazdir(int dizi[], int boyut) {
    for (int i = 0; i < boyut; i++) {
        printf("%d ", dizi[i]);
    }
    printf("\n");
}

// Fonksiyon pointer
int (*islemPtr)(int, int);
islemPtr = topla;
int sonuc = islemPtr(5, 3);
```

### C++ Temelleri

#### Sınıflar

```cpp
#include <iostream>
#include <string>
#include <vector>

class Araba {
private:
    std::string marka;
    std::string model;
    int yil;
    double hiz;

public:
    // Constructor
    Araba(const std::string& marka, const std::string& model, int yil)
        : marka(marka), model(model), yil(yil), hiz(0) {}
    
    // Destructor
    ~Araba() {
        std::cout << "Araba silindi: " << marka << std::endl;
    }
    
    // Copy constructor
    Araba(const Araba& diger)
        : marka(diger.marka), model(diger.model), 
          yil(diger.yil), hiz(diger.hiz) {}
    
    // Move constructor
    Araba(Araba&& diger) noexcept
        : marka(std::move(diger.marka)), model(std::move(diger.model)),
          yil(diger.yil), hiz(diger.hiz) {}
    
    // Getter ve Setter
    std::string getMarka() const { return marka; }
    void setMarka(const std::string& m) { marka = m; }
    
    // Metodlar
    void hizlan(double miktar) {
        hiz += miktar;
        std::cout << "Yeni hız: " << hiz << " km/h" << std::endl;
    }
    
    // Operator overloading
    bool operator==(const Araba& diger) const {
        return marka == diger.marka && model == diger.model;
    }
    
    // Friend function
    friend std::ostream& operator<<(std::ostream& os, const Araba& a);
};

std::ostream& operator<<(std::ostream& os, const Araba& a) {
    os << a.yil << " " << a.marka << " " << a.model;
    return os;
}
```

#### Kalıtım

```cpp
// Abstract base class
class Sekil {
public:
    virtual double alan() const = 0;
    virtual double cevre() const = 0;
    virtual ~Sekil() = default;
};

class Dikdortgen : public Sekil {
private:
    double genislik, yukseklik;

public:
    Dikdortgen(double g, double y) : genislik(g), yukseklik(y) {}
    
    double alan() const override {
        return genislik * yukseklik;
    }
    
    double cevre() const override {
        return 2 * (genislik + yukseklik);
    }
};

class Daire : public Sekil {
private:
    double yaricap;

public:
    Daire(double r) : yaricap(r) {}
    
    double alan() const override {
        return 3.14159 * yaricap * yaricap;
    }
    
    double cevre() const override {
        return 2 * 3.14159 * yaricap;
    }
};
```

#### Templates (Şablonlar)

```cpp
// Fonksiyon template
template <typename T>
T maksimum(T a, T b) {
    return (a > b) ? a : b;
}

// Sınıf template
template <typename T>
class Kutu {
private:
    T icerik;

public:
    Kutu(T deger) : icerik(deger) {}
    
    T getIcerik() const { return icerik; }
    void setIcerik(T deger) { icerik = deger; }
};

// Kullanım
int m1 = maksimum(5, 10);
double m2 = maksimum(3.14, 2.71);

Kutu<int> sayiKutusu(42);
Kutu<std::string> metinKutusu("Merhaba");
```

#### Modern C++ (C++11/14/17/20)

```cpp
#include <memory>
#include <vector>
#include <algorithm>

// Smart pointers
auto ptr = std::make_unique<Araba>("Toyota", "Corolla", 2024);
auto sharedPtr = std::make_shared<Araba>("Honda", "Civic", 2023);

// Lambda expressions
auto topla = [](int a, int b) { return a + b; };
auto sonuc = topla(5, 3);

// Range-based for
std::vector<int> sayilar = {1, 2, 3, 4, 5};
for (const auto& s : sayilar) {
    std::cout << s << " ";
}

// Auto ve decltype
auto x = 42;
decltype(x) y = 100;

// STL Algorithms
std::vector<int> v = {5, 2, 8, 1, 9};
std::sort(v.begin(), v.end());
auto it = std::find(v.begin(), v.end(), 8);

// Structured bindings (C++17)
std::pair<int, std::string> p = {1, "bir"};
auto [sayi, metin] = p;

// Concepts (C++20)
template <typename T>
concept Sayisal = std::integral<T> || std::floating_point<T>;

template <Sayisal T>
T ikiKati(T x) {
    return x * 2;
}
```

---
**LLM Notu:** Bu doküman Türkçe C/C++ eğitimi için RAG kaynağıdır.
