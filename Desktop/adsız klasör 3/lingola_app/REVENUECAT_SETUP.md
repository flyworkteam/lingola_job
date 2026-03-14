# RevenueCat Paywall'ının Görünmesi İçin

Premium'a tıklandığında **RevenueCat Dashboard'daki paywall**'ın açılması için API anahtarlarının tanımlı olması gerekir.

---

## Anahtarları ekleme

1. [RevenueCat Dashboard](https://app.revenuecat.com) → projenizi seçin → **Project settings** → **API Keys**.
2. **Apple** (iOS) ve **Google Play** (Android) için gösterilen **Public API key** değerlerini kopyalayın.
3. Projede **`lib/src/config/revenuecat_keys.dart`** dosyasını açın.
4. `revenueCatAppleApiKey` ve `revenueCatAndroidApiKey` sabitlerine bu anahtarları yapıştırın (tırnak içinde).

Örnek:

```dart
const String revenueCatAppleApiKey = 'appl_xxxxxxxxxxxx';
const String revenueCatAndroidApiKey = 'goog_xxxxxxxxxxxx';
```

5. Uygulamayı yeniden çalıştırın (`flutter run`). Premium'a bastığınızda RevenueCat’te tasarladığınız paywall ekranı açılacaktır.

---

## "No Play Store products registered" / ConfigurationError

Terminalde şu hata görünüyorsa:

```text
ConfigurationError … there are no Play Store products registered in the RevenueCat dashboard for your offerings
```

**Sebep:** RevenueCat’te **Offerings** ve mağaza ürünleri tanımlı değil.

**Yapılacaklar:**

1. [RevenueCat Dashboard](https://app.revenuecat.com) → projeniz → **Products**.
2. **+ New** ile Android (Google Play) ve iOS (App Store) için **in-app product / subscription ID**’lerinizi ekleyin (Google Play Console ve App Store Connect’teki ID’lerle birebir aynı olmalı).
3. **Offerings** sekmesine gidin → bir **Offering** oluşturun veya düzenleyin → bu ürünleri offering’e **Package** olarak ekleyin (örn. monthly, annual).
4. **Paywalls** sekmesinde paywall’ınızı bu offering’e bağlayın.

Detay: [rev.cat/how-to-configure-offerings](https://rev.cat/how-to-configure-offerings) ve [rev.cat/why-are-offerings-empty](https://rev.cat/why-are-offerings-empty).

Bu adımları yapana kadar uygulama paywall yerine “Satın alma bu cihazda kullanılamıyor” benzeri mesaj gösterebilir; hata logları RevenueCat SDK’dan gelir ve yapılandırma tamamlanınca düzelir.

---

## Alternatif: dart-define ile

Derleme sırasında anahtarları vermek isterseniz:

```bash
flutter run --dart-define=REVENUECAT_APPLE_API_KEY=appl_xxx --dart-define=REVENUECAT_ANDROID_API_KEY=goog_xxx
```

Env ile verilen anahtarlar, `revenuecat_keys.dart` içindekilere göre önceliklidir.
