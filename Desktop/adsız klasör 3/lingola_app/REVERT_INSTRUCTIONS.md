# Geri Alma Talimatları (Production / Ücretli Apple Hesabı)

Bu dosya, **kişisel geliştirme** için yapılan geçici değişikliklerin nasıl eski haline getirileceğini açıklar. Ücretli Apple Developer hesabına geçtiğinizde veya production build alacağınızda aşağıdakileri uygulayın.

---

## 1. iOS: Sign In with Apple ve Push Notifications

**Dosya:** `ios/Runner/Runner.entitlements`

**Şu an:** İçerik boş (kişisel/dev olmayan hesap ile build için yetenekler kapatıldı).

**Müşteriye teslim / production:** Ücretli Apple Developer hesabı olan kişi (siz veya müşteri) build alırken **mutlaka** bu adımı uygulamalı. Aksi halde uygulamada “Apple ile giriş” kullanıldığında **Error 1000** alınır.

**Eski haline getirmek için** `ios/Runner/Runner.entitlements` dosyasının `<dict>...</dict>` kısmını aşağıdaki ile değiştirin:

```xml
<dict>
	<key>aps-environment</key>
	<string>development</string>
	<key>com.apple.developer.applesignin</key>
	<array>
		<string>Default</string>
	</array>
</dict>
```

(XML yorum satırını silin; sadece yukarıdaki key/string/array kalsın.)

---

## 2. Android: speech_to_text paketi

**Dosya:** `pubspec.yaml`

**Şu an:** `speech_to_text: ^7.3.0` (Android Kotlin hatası için yükseltildi).

**Eski haline getirmek için** ilgili satırı şu şekilde yapın (isterseniz tekrar 6.6.0 deneyebilirsiniz; 6.6.0 eski Flutter embedding kullandığı için bazı ortamlarda Android build hatası verebilir):

```yaml
  speech_to_text: ^6.6.0
```

Üstteki `# GEÇİCİ: ...` yorum satırını da silebilirsiniz.

**Not:** 6.6.0 ile Android’de “Unresolved reference: Registrar” hatası alırsanız, 7.x sürümü kullanmaya devam etmeniz gerekir; API değişikliği nedeniyle 6.6.0 artık yeni Flutter/Android sürümleriyle uyumlu olmayabilir.

---

## Özet

| Ne değişti           | Dosya                          | Eski değer / içerik                          |
|----------------------|--------------------------------|----------------------------------------------|
| iOS yetenekleri      | `ios/Runner/Runner.entitlements` | `aps-environment` + `com.apple.developer.applesignin` ekle |
| speech_to_text       | `pubspec.yaml`                 | `speech_to_text: ^6.6.0` (ve yorumu kaldır)  |

Değişiklikleri yaptıktan sonra:

- iOS: `flutter clean` sonra `cd ios && pod install` (gerekirse) ve Xcode’da tekrar build.
- Android: `flutter pub get` (ve gerekirse `flutter clean`).
