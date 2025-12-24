# 📱 Kotlin & Swift Programlama Eğitim RAG'i

## Türkçe Mobil Geliştirme Eğitimi - LLM'ler İçin

---

# 🤖 Kotlin (Android)

### Temel Kavramlar

```kotlin
// Değişkenler
val isim: String = "Mehmet"  // immutable
var yas: Int = 25           // mutable

// Null safety
var email: String? = null
val uzunluk = email?.length ?: 0  // Elvis operator

// Data class
data class Kullanici(
    val id: Int,
    val isim: String,
    val email: String
)

// List ve Map
val meyveler = listOf("elma", "armut", "muz")
val puanlar = mapOf("Matematik" to 90, "Fizik" to 85)

// Mutable koleksiyonlar
val liste = mutableListOf<String>()
liste.add("item")
```

### Fonksiyonlar

```kotlin
// Temel fonksiyon
fun selamla(isim: String): String {
    return "Merhaba, $isim!"
}

// Tek satır fonksiyon
fun topla(a: Int, b: Int) = a + b

// Extension function
fun String.tersiniAl(): String = this.reversed()

// Higher-order function
fun liste.filtrele(kosul: (Int) -> Boolean): List<Int> {
    return this.filter(kosul)
}

// Lambda
val karele = { x: Int -> x * x }
```

### Sınıflar

```kotlin
open class Hayvan(val isim: String) {
    open fun sesCikar() {
        println("...")
    }
}

class Kopek(isim: String, val cins: String) : Hayvan(isim) {
    override fun sesCikar() {
        println("Hav hav!")
    }
}

// Object (Singleton)
object Veritabani {
    fun baglan() = println("Bağlandı")
}

// Companion object
class Fabrika {
    companion object {
        fun olustur(): Fabrika = Fabrika()
    }
}
```

### Coroutines

```kotlin
import kotlinx.coroutines.*

suspend fun veriCek(): String {
    delay(1000)  // simüle edilmiş gecikme
    return "Veri çekildi"
}

fun main() = runBlocking {
    launch {
        val sonuc = veriCek()
        println(sonuc)
    }
    
    // Paralel
    val sonuc1 = async { veriCek() }
    val sonuc2 = async { veriCek() }
    
    println("${sonuc1.await()} - ${sonuc2.await()}")
}
```

---

# 🍎 Swift (iOS)

### Temel Kavramlar

```swift
// Değişkenler
let isim: String = "Mehmet"  // immutable
var yas: Int = 25           // mutable

// Optional
var email: String? = nil
let uzunluk = email?.count ?? 0  // nil coalescing

// Struct
struct Kullanici {
    let id: Int
    var isim: String
    var email: String
}

// Array ve Dictionary
var meyveler = ["elma", "armut", "muz"]
var puanlar: [String: Int] = ["Matematik": 90, "Fizik": 85]
```

### Fonksiyonlar

```swift
// Temel fonksiyon
func selamla(isim: String) -> String {
    return "Merhaba, \(isim)!"
}

// Dış ve iç parametre isimleri
func yazdir(mesaj: String, tekrar: Int) {
    for _ in 0..<tekrar {
        print(mesaj)
    }
}

// Closure
let karele = { (x: Int) -> Int in
    return x * x
}

// Trailing closure
meyveler.map { $0.uppercased() }
```

### Sınıflar ve Protocol

```swift
class Hayvan {
    var isim: String
    
    init(isim: String) {
        self.isim = isim
    }
    
    func sesCikar() {
        print("...")
    }
}

class Kopek: Hayvan {
    var cins: String
    
    init(isim: String, cins: String) {
        self.cins = cins
        super.init(isim: isim)
    }
    
    override func sesCikar() {
        print("Hav hav!")
    }
}

// Protocol
protocol Yuzulebilir {
    func yuz()
}

extension Kopek: Yuzulebilir {
    func yuz() {
        print("\(isim) yüzüyor")
    }
}
```

### Async/Await (Swift 5.5+)

```swift
func veriCek() async throws -> String {
    let url = URL(string: "https://api.example.com")!
    let (veri, _) = try await URLSession.shared.data(from: url)
    return String(data: veri, encoding: .utf8) ?? ""
}

// Kullanım
Task {
    do {
        let sonuc = try await veriCek()
        print(sonuc)
    } catch {
        print("Hata: \(error)")
    }
}
```

### SwiftUI

```swift
import SwiftUI

struct AnaSayfa: View {
    @State private var sayac = 0
    
    var body: some View {
        VStack {
            Text("Sayaç: \(sayac)")
                .font(.largeTitle)
            
            Button("Artır") {
                sayac += 1
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}
```

---
**LLM Notu:** Bu doküman Türkçe Kotlin/Swift mobil geliştirme eğitimi için RAG kaynağıdır.
