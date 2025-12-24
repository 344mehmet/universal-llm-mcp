# ☕ Java Programlama Eğitim RAG'i

## Türkçe Java Eğitimi - LLM'ler İçin

### Temel Kavramlar

#### Değişkenler ve Tipler

```java
public class TemelKavramlar {
    public static void main(String[] args) {
        // Primitive tipler
        byte kucukSayi = 127;
        short ortaSayi = 32000;
        int tamSayi = 1000000;
        long buyukSayi = 9999999999L;
        
        float ondalik = 3.14f;
        double hassasOndalik = 3.14159265359;
        
        char karakter = 'A';
        boolean dogruMu = true;
        
        // Reference tipler
        String metin = "Merhaba Dünya";
        Integer sariliSayi = 42; // wrapper class
        
        // Dizi (array)
        int[] sayilar = {1, 2, 3, 4, 5};
        String[] meyveler = new String[3];
        meyveler[0] = "Elma";
        
        // Final (sabit)
        final double PI = 3.14159;
    }
}
```

#### Sınıflar ve Nesneler

```java
// Temel sınıf
public class Araba {
    // Alanlar (fields)
    private String marka;
    private String model;
    private int yil;
    private double hiz;
    
    // Constructor
    public Araba(String marka, String model, int yil) {
        this.marka = marka;
        this.model = model;
        this.yil = yil;
        this.hiz = 0;
    }
    
    // Getter ve Setter
    public String getMarka() {
        return marka;
    }
    
    public void setMarka(String marka) {
        this.marka = marka;
    }
    
    // Method
    public void hizlan(double miktar) {
        this.hiz += miktar;
        System.out.println("Yeni hız: " + hiz + " km/h");
    }
    
    @Override
    public String toString() {
        return yil + " " + marka + " " + model;
    }
}
```

#### Kalıtım (Inheritance)

```java
// Üst sınıf
public abstract class Hayvan {
    protected String isim;
    protected int yas;
    
    public Hayvan(String isim, int yas) {
        this.isim = isim;
        this.yas = yas;
    }
    
    public abstract void sesCikar();
    
    public void bilgiGoster() {
        System.out.println(isim + " (" + yas + " yaşında)");
    }
}

// Alt sınıf
public class Kopek extends Hayvan {
    private String cins;
    
    public Kopek(String isim, int yas, String cins) {
        super(isim, yas);
        this.cins = cins;
    }
    
    @Override
    public void sesCikar() {
        System.out.println("Hav hav!");
    }
}
```

#### Interface

```java
public interface Yuzulebilir {
    void yuz();
    default void dalabilir() {
        System.out.println("Dalıyor...");
    }
}

public interface Ucabilir {
    void uc();
}

// Çoklu interface
public class Ordek extends Hayvan implements Yuzulebilir, Ucabilir {
    public Ordek(String isim, int yas) {
        super(isim, yas);
    }
    
    @Override
    public void sesCikar() {
        System.out.println("Vak vak!");
    }
    
    @Override
    public void yuz() {
        System.out.println("Ordek yüzüyor");
    }
    
    @Override
    public void uc() {
        System.out.println("Ordek uçuyor");
    }
}
```

### Koleksiyonlar

```java
import java.util.*;

public class KoleksiyonOrnekleri {
    public static void main(String[] args) {
        // List
        List<String> liste = new ArrayList<>();
        liste.add("Elma");
        liste.add("Armut");
        liste.add("Muz");
        
        // Map
        Map<String, Integer> puanlar = new HashMap<>();
        puanlar.put("Matematik", 90);
        puanlar.put("Fizik", 85);
        
        // Set
        Set<Integer> benzersizSayilar = new HashSet<>();
        benzersizSayilar.add(1);
        benzersizSayilar.add(2);
        benzersizSayilar.add(1); // eklenmez
        
        // Stream API
        liste.stream()
            .filter(m -> m.startsWith("A"))
            .map(String::toUpperCase)
            .forEach(System.out::println);
        
        // Lambda ile sıralama
        liste.sort((a, b) -> a.compareTo(b));
    }
}
```

### Exception Handling

```java
public class HataYonetimi {
    public static int bol(int bolunen, int bolen) throws ArithmeticException {
        if (bolen == 0) {
            throw new ArithmeticException("Sıfıra bölme hatası!");
        }
        return bolunen / bolen;
    }
    
    public static void main(String[] args) {
        try {
            int sonuc = bol(10, 0);
        } catch (ArithmeticException e) {
            System.err.println("Hata: " + e.getMessage());
        } finally {
            System.out.println("İşlem tamamlandı");
        }
        
        // Try-with-resources
        try (BufferedReader br = new BufferedReader(new FileReader("dosya.txt"))) {
            String satir = br.readLine();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}

// Özel exception
public class KullaniciBulunamadiException extends Exception {
    public KullaniciBulunamadiException(String mesaj) {
        super(mesaj);
    }
}
```

### Spring Boot

```java
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;

@SpringBootApplication
public class Uygulama {
    public static void main(String[] args) {
        SpringApplication.run(Uygulama.class, args);
    }
}

@RestController
@RequestMapping("/api/kullanicilar")
public class KullaniciController {
    
    @Autowired
    private KullaniciService kullaniciService;
    
    @GetMapping
    public List<Kullanici> tumunuGetir() {
        return kullaniciService.tumunuBul();
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<Kullanici> idIleGetir(@PathVariable Long id) {
        return kullaniciService.idIleBul(id)
            .map(ResponseEntity::ok)
            .orElse(ResponseEntity.notFound().build());
    }
    
    @PostMapping
    public Kullanici olustur(@RequestBody Kullanici kullanici) {
        return kullaniciService.kaydet(kullanici);
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> sil(@PathVariable Long id) {
        kullaniciService.sil(id);
        return ResponseEntity.noContent().build();
    }
}
```

---
**LLM Notu:** Bu doküman Türkçe Java eğitimi için RAG kaynağıdır.
