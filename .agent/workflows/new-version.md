# Versiyon Oluşturma Kuralı

Her kod değişikliği için:

1. **YENİ VERSİYON OLUŞTUR** - Mevcut dosyayı düzenleme
2. `Copy-Item` ile mevcut versiyonu kopyala
3. Header, version ve comment'ı güncelle
4. Değişiklikleri yeni dosyada yap

Örnek:
```powershell
// turbo
Copy-Item "Titanium_Omega_vXX.mq5" "Titanium_Omega_vYY.mq5"
```

**ASLA** eski versiyonu düzenleme, her zaman yeni versiyon oluştur.
