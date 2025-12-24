# 🟣 C# Programlama Eğitim RAG'i

## Türkçe C# Eğitimi - LLM'ler İçin

### Temel Kavramlar

```csharp
using System;
using System.Collections.Generic;

// Ana program
class Program
{
    static void Main(string[] args)
    {
        // Değişkenler
        string isim = "Mehmet";
        int yas = 25;
        double maas = 15000.50;
        bool aktif = true;
        
        // Nullable
        int? opsiyonelSayi = null;
        
        // Var (implicit typing)
        var mesaj = "Merhaba Dünya";
        
        // String interpolation
        Console.WriteLine($"İsim: {isim}, Yaş: {yas}");
        
        // Array
        int[] sayilar = { 1, 2, 3, 4, 5 };
        
        // List
        List<string> meyveler = new List<string> { "elma", "armut", "muz" };
        meyveler.Add("çilek");
        
        // Dictionary
        Dictionary<string, int> puanlar = new Dictionary<string, int>
        {
            { "Matematik", 90 },
            { "Fizik", 85 }
        };
    }
}
```

### Sınıflar

```csharp
public class Araba
{
    // Properties
    public string Marka { get; set; }
    public string Model { get; set; }
    public int Yil { get; private set; }
    private double _hiz;
    
    // Constructor
    public Araba(string marka, string model, int yil)
    {
        Marka = marka;
        Model = model;
        Yil = yil;
        _hiz = 0;
    }
    
    // Method
    public void Hizlan(double miktar)
    {
        _hiz += miktar;
        Console.WriteLine($"Yeni hız: {_hiz} km/h");
    }
    
    // Override
    public override string ToString()
    {
        return $"{Yil} {Marka} {Model}";
    }
}

// Kalıtım
public class ElektrikliAraba : Araba
{
    public int BataryaKapasitesi { get; set; }
    
    public ElektrikliAraba(string marka, string model, int yil, int batarya) 
        : base(marka, model, yil)
    {
        BataryaKapasitesi = batarya;
    }
    
    public void SarjEt()
    {
        Console.WriteLine("Şarj ediliyor...");
    }
}
```

### Interface ve Abstract

```csharp
// Interface
public interface IYuzulebilir
{
    void Yuz();
    int DerinliligeIn(int metre);
}

// Abstract class
public abstract class Sekil
{
    public abstract double Alan { get; }
    public abstract double Cevre { get; }
    
    public virtual void BilgiYazdir()
    {
        Console.WriteLine($"Alan: {Alan}, Çevre: {Cevre}");
    }
}

public class Dikdortgen : Sekil
{
    public double Genislik { get; set; }
    public double Yukseklik { get; set; }
    
    public override double Alan => Genislik * Yukseklik;
    public override double Cevre => 2 * (Genislik + Yukseklik);
}
```

### Async/Await

```csharp
using System.Net.Http;
using System.Threading.Tasks;

public class VeriServisi
{
    private readonly HttpClient _client;
    
    public VeriServisi()
    {
        _client = new HttpClient();
    }
    
    public async Task<string> VeriCekAsync(string url)
    {
        try
        {
            var yanit = await _client.GetStringAsync(url);
            return yanit;
        }
        catch (HttpRequestException hata)
        {
            Console.WriteLine($"Hata: {hata.Message}");
            throw;
        }
    }
    
    public async Task<List<string>> ParalelCekAsync(List<string> urls)
    {
        var gorevler = urls.Select(url => VeriCekAsync(url));
        var sonuclar = await Task.WhenAll(gorevler);
        return sonuclar.ToList();
    }
}
```

### LINQ

```csharp
using System.Linq;

var kullanicilar = new List<Kullanici>
{
    new Kullanici { Id = 1, Isim = "Mehmet", Yas = 25 },
    new Kullanici { Id = 2, Isim = "Ali", Yas = 30 },
    new Kullanici { Id = 3, Isim = "Ayşe", Yas = 28 }
};

// Query syntax
var gencler = from k in kullanicilar
              where k.Yas < 30
              orderby k.Isim
              select k;

// Method syntax
var gencler2 = kullanicilar
    .Where(k => k.Yas < 30)
    .OrderBy(k => k.Isim)
    .ToList();

// Aggregation
var ortalamaYas = kullanicilar.Average(k => k.Yas);
var toplamYas = kullanicilar.Sum(k => k.Yas);
var enGenc = kullanicilar.Min(k => k.Yas);

// GroupBy
var yasGruplari = kullanicilar
    .GroupBy(k => k.Yas / 10 * 10)
    .Select(g => new { YasAraligi = g.Key, Sayi = g.Count() });
```

### ASP.NET Core

```csharp
using Microsoft.AspNetCore.Mvc;

[ApiController]
[Route("api/[controller]")]
public class KullanicilarController : ControllerBase
{
    private readonly IKullaniciServisi _servis;
    
    public KullanicilarController(IKullaniciServisi servis)
    {
        _servis = servis;
    }
    
    [HttpGet]
    public async Task<ActionResult<List<Kullanici>>> TumunuGetir()
    {
        var kullanicilar = await _servis.TumunuGetirAsync();
        return Ok(kullanicilar);
    }
    
    [HttpGet("{id}")]
    public async Task<ActionResult<Kullanici>> IdIleGetir(int id)
    {
        var kullanici = await _servis.IdIleGetirAsync(id);
        if (kullanici == null)
            return NotFound();
            
        return Ok(kullanici);
    }
    
    [HttpPost]
    public async Task<ActionResult<Kullanici>> Olustur([FromBody] Kullanici kullanici)
    {
        var yeni = await _servis.OlusturAsync(kullanici);
        return CreatedAtAction(nameof(IdIleGetir), new { id = yeni.Id }, yeni);
    }
}
```

---
**LLM Notu:** Bu doküman Türkçe C# eğitimi için RAG kaynağıdır.
