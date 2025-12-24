# 🗄️ SQL & Shell Programlama Eğitim RAG'i

## Türkçe SQL ve Shell Eğitimi - LLM'ler İçin

---

# 🗄️ SQL

### Temel Sorgular

```sql
-- Veritabanı oluştur
CREATE DATABASE sirket_db;
USE sirket_db;

-- Tablo oluştur
CREATE TABLE kullanicilar (
    id INT PRIMARY KEY AUTO_INCREMENT,
    isim VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    yas INT,
    aktif BOOLEAN DEFAULT true,
    olusturma_tarihi TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Veri ekle
INSERT INTO kullanicilar (isim, email, yas) VALUES
    ('Mehmet', 'mehmet@test.com', 25),
    ('Ali', 'ali@test.com', 30),
    ('Ayşe', 'ayse@test.com', 28);

-- Basit sorgular
SELECT * FROM kullanicilar;
SELECT isim, email FROM kullanicilar WHERE yas > 25;
SELECT * FROM kullanicilar ORDER BY isim ASC;
SELECT * FROM kullanicilar LIMIT 10 OFFSET 0;

-- Güncelle
UPDATE kullanicilar SET yas = 26 WHERE isim = 'Mehmet';

-- Sil
DELETE FROM kullanicilar WHERE id = 3;
```

### İleri Düzey SQL

```sql
-- JOIN işlemleri
SELECT 
    k.isim AS kullanici_adi,
    s.baslik AS siparis_basligi,
    s.tutar
FROM kullanicilar k
INNER JOIN siparisler s ON k.id = s.kullanici_id
WHERE s.tutar > 100;

-- LEFT JOIN
SELECT 
    k.isim,
    COUNT(s.id) AS siparis_sayisi
FROM kullanicilar k
LEFT JOIN siparisler s ON k.id = s.kullanici_id
GROUP BY k.id;

-- Subquery
SELECT * FROM kullanicilar
WHERE id IN (
    SELECT kullanici_id FROM siparisler
    WHERE tutar > 500
);

-- CTE (Common Table Expression)
WITH aylik_satis AS (
    SELECT 
        DATE_FORMAT(tarih, '%Y-%m') AS ay,
        SUM(tutar) AS toplam_satis
    FROM siparisler
    GROUP BY DATE_FORMAT(tarih, '%Y-%m')
)
SELECT * FROM aylik_satis WHERE toplam_satis > 10000;

-- Window fonksiyonları
SELECT 
    isim,
    tutar,
    ROW_NUMBER() OVER (ORDER BY tutar DESC) AS sira,
    SUM(tutar) OVER () AS genel_toplam,
    tutar / SUM(tutar) OVER () * 100 AS yuzde
FROM siparisler;

-- CASE WHEN
SELECT 
    isim,
    yas,
    CASE 
        WHEN yas < 18 THEN 'Çocuk'
        WHEN yas < 30 THEN 'Genç'
        WHEN yas < 50 THEN 'Orta Yaş'
        ELSE 'Yaşlı'
    END AS yas_grubu
FROM kullanicilar;
```

### Stored Procedure

```sql
DELIMITER //

CREATE PROCEDURE kullanici_ekle(
    IN p_isim VARCHAR(100),
    IN p_email VARCHAR(255),
    IN p_yas INT
)
BEGIN
    INSERT INTO kullanicilar (isim, email, yas)
    VALUES (p_isim, p_email, p_yas);
    
    SELECT LAST_INSERT_ID() AS yeni_id;
END //

DELIMITER ;

-- Kullanım
CALL kullanici_ekle('Veli', 'veli@test.com', 35);
```

---

# 🐚 Shell/Bash

### Temel Komutlar

```bash
#!/bin/bash

# Değişkenler
isim="Mehmet"
yas=25
echo "Merhaba, $isim! Yaşın: $yas"

# Kullanıcı girdisi
read -p "İsminizi girin: " kullanici_ismi
echo "Hoş geldiniz, $kullanici_ismi"

# Komut çıktısını değişkene atama
bugun=$(date +%Y-%m-%d)
dosya_sayisi=$(ls | wc -l)

# Dizi (array)
meyveler=("elma" "armut" "muz")
echo "İlk meyve: ${meyveler[0]}"
echo "Tüm meyveler: ${meyveler[@]}"
echo "Meyve sayısı: ${#meyveler[@]}"
```

### Kontrol Yapıları

```bash
#!/bin/bash

# If-Else
yas=18
if [ $yas -ge 18 ]; then
    echo "Yetişkin"
elif [ $yas -ge 13 ]; then
    echo "Genç"
else
    echo "Çocuk"
fi

# Dosya kontrolleri
dosya="/tmp/test.txt"
if [ -f "$dosya" ]; then
    echo "Dosya mevcut"
elif [ -d "$dosya" ]; then
    echo "Bu bir dizin"
else
    echo "Dosya bulunamadı"
fi

# Case
read -p "Gün seçin (1-7): " gun
case $gun in
    1) echo "Pazartesi" ;;
    2) echo "Salı" ;;
    3) echo "Çarşamba" ;;
    4) echo "Perşembe" ;;
    5) echo "Cuma" ;;
    6|7) echo "Hafta sonu" ;;
    *) echo "Geçersiz gün" ;;
esac

# For döngüsü
for meyve in "${meyveler[@]}"; do
    echo "Meyve: $meyve"
done

for i in {1..5}; do
    echo "Sayı: $i"
done

# While döngüsü
sayac=0
while [ $sayac -lt 5 ]; do
    echo "Sayaç: $sayac"
    ((sayac++))
done
```

### Fonksiyonlar

```bash
#!/bin/bash

# Fonksiyon tanımı
selamla() {
    local isim=$1
    echo "Merhaba, $isim!"
}

# Dönüş değeri ile
hesapla() {
    local a=$1
    local b=$2
    echo $((a + b))
}

# Kullanım
selamla "Mehmet"
sonuc=$(hesapla 5 3)
echo "Sonuç: $sonuc"
```

### Pratik Örnekler

```bash
#!/bin/bash

# Log dosyası yedekleme
yedekle() {
    local kaynak=$1
    local hedef=$2
    local tarih=$(date +%Y%m%d_%H%M%S)
    
    if [ -f "$kaynak" ]; then
        cp "$kaynak" "${hedef}/backup_${tarih}.log"
        echo "Yedekleme başarılı"
    else
        echo "Dosya bulunamadı: $kaynak"
        return 1
    fi
}

# Disk kullanımı kontrolü
disk_kontrol() {
    local limit=${1:-80}
    local kullanim=$(df / | tail -1 | awk '{print $5}' | tr -d '%')
    
    if [ $kullanim -gt $limit ]; then
        echo "⚠️ Uyarı: Disk kullanımı %$kullanim"
        return 1
    else
        echo "✅ Disk durumu iyi: %$kullanim"
        return 0
    fi
}
```

---
**LLM Notu:** Bu doküman Türkçe SQL ve Shell eğitimi için RAG kaynağıdır.
