# 💎 Ruby & PHP Programlama Eğitim RAG'i

## Türkçe Ruby ve PHP Eğitimi - LLM'ler İçin

---

# 💎 Ruby

### Temel Kavramlar

```ruby
# Değişkenler
isim = "Mehmet"
yas = 25
aktif = true

# Semboller
durum = :beklemede

# Array
meyveler = ["elma", "armut", "muz"]
meyveler << "çilek"  # ekleme

# Hash
kullanici = {
  isim: "Ali",
  yas: 30,
  email: "ali@test.com"
}

# Bloklar
[1, 2, 3].each do |sayi|
  puts sayi * 2
end

# Tek satır blok
[1, 2, 3].map { |s| s ** 2 }
```

### Sınıflar

```ruby
class Araba
  attr_accessor :marka, :model
  attr_reader :yil
  
  def initialize(marka, model, yil)
    @marka = marka
    @model = model
    @yil = yil
    @hiz = 0
  end
  
  def hizlan(miktar)
    @hiz += miktar
    puts "Yeni hız: #{@hiz} km/h"
  end
  
  def to_s
    "#{@yil} #{@marka} #{@model}"
  end
end

# Kalıtım
class ElektrikliAraba < Araba
  def initialize(marka, model, yil, batarya)
    super(marka, model, yil)
    @batarya = batarya
  end
  
  def sarj_et
    puts "Şarj ediliyor..."
  end
end
```

### Rails Örneği

```ruby
# Model
class Kullanici < ApplicationRecord
  validates :isim, presence: true
  validates :email, uniqueness: true
  
  has_many :yazilar
  belongs_to :sirket
end

# Controller
class KullanicilarController < ApplicationController
  def index
    @kullanicilar = Kullanici.all
  end
  
  def create
    @kullanici = Kullanici.new(kullanici_params)
    if @kullanici.save
      redirect_to @kullanici
    else
      render :new
    end
  end
  
  private
  
  def kullanici_params
    params.require(:kullanici).permit(:isim, :email, :sifre)
  end
end
```

---

# 🐘 PHP

### Temel Kavramlar

```php
<?php
// Değişkenler
$isim = "Mehmet";
$yas = 25;
$aktif = true;

// Array
$meyveler = ["elma", "armut", "muz"];
$meyveler[] = "çilek";  // ekleme

// Associative array
$kullanici = [
    "isim" => "Ali",
    "yas" => 30,
    "email" => "ali@test.com"
];

// Foreach
foreach ($meyveler as $meyve) {
    echo $meyve . "<br>";
}

// Key-value ile
foreach ($kullanici as $anahtar => $deger) {
    echo "$anahtar: $deger<br>";
}
?>
```

### Sınıflar

```php
<?php
class Araba {
    private string $marka;
    private string $model;
    private int $yil;
    private float $hiz = 0;
    
    public function __construct(
        string $marka, 
        string $model, 
        int $yil
    ) {
        $this->marka = $marka;
        $this->model = $model;
        $this->yil = $yil;
    }
    
    public function getMarka(): string {
        return $this->marka;
    }
    
    public function hizlan(float $miktar): void {
        $this->hiz += $miktar;
        echo "Yeni hız: {$this->hiz} km/h";
    }
    
    public function __toString(): string {
        return "{$this->yil} {$this->marka} {$this->model}";
    }
}

// Interface
interface YuzulebilirInterface {
    public function yuz(): void;
}

// Trait
trait LoglanabilirTrait {
    public function logla(string $mesaj): void {
        error_log("[LOG] $mesaj");
    }
}
?>
```

### Laravel Örneği

```php
<?php
// Model
namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Kullanici extends Model
{
    protected $fillable = ['isim', 'email', 'sifre'];
    
    public function yazilar()
    {
        return $this->hasMany(Yazi::class);
    }
}

// Controller
namespace App\Http\Controllers;

class KullaniciController extends Controller
{
    public function index()
    {
        $kullanicilar = Kullanici::all();
        return view('kullanicilar.index', compact('kullanicilar'));
    }
    
    public function store(Request $request)
    {
        $validated = $request->validate([
            'isim' => 'required|string|max:255',
            'email' => 'required|email|unique:kullanicilar',
        ]);
        
        Kullanici::create($validated);
        
        return redirect()->route('kullanicilar.index')
            ->with('basarili', 'Kullanıcı oluşturuldu!');
    }
}
?>
```

---
**LLM Notu:** Bu doküman Türkçe Ruby ve PHP eğitimi için RAG kaynağıdır.
