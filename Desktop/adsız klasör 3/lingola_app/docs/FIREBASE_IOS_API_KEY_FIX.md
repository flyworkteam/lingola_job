# iOS Giriş Hatası: API_KEY_IOS_APP_BLOCKED

**Hata:** "Requests from this iOS client application com.flywork.lingolajobapp are blocked."  
**Sebep:** Google Cloud’da kullanılan API anahtarı, bu iOS bundle ID’sine izin vermiyor (veya kısıtlamalar yanlış).

## 1. Google Cloud Console’da API anahtarını düzelt

1. **Google Cloud Console**’a gir: https://console.cloud.google.com/
2. Projeyi seç: **lingola-backend** (veya proje numarası: **542145601165**).
3. Sol menüden **APIs & Services** → **Credentials** sayfasına git.
4. Listede **API key**’leri bul. iOS/Firebase için kullanılan anahtar genelde:
   - İsmi “iOS key” / “Firebase” vb. olan,
   - veya `GoogleService-Info.plist` içindeki **API_KEY** değeri:  
     `AIzaSyDop2nfRuJa6UuOr1tTCwrXfEXvhoR7KYQ`  
   Bu anahtara tıkla (düzenle).

5. **Application restrictions** bölümünde:
   - **“Don’t restrict key”** seçiliyse ve yine de 403 alıyorsan, aşağıdaki “Identity Toolkit” adımına geç.
   - **“iOS apps”** seçiliyse:
     - **Bundle ID** listesinde şunların **ikisi de** tanımlı olduğundan emin ol:
       - `com.flywork.lingolajobapp`
       - `com.flywork.lingolajobapp.dev` (Debug build için)
     - Eksikse “Add an item” ile ekle, **Save** ile kaydet.

6. **API restrictions** bölümünde:
   - “Don’t restrict key” **veya**
   - “Restrict key” seçiliyse listede şunların **açık** olduğundan emin ol:
     - **Identity Toolkit API** (Firebase Auth bunu kullanır)
     - İstersen “Firebase Authentication” ile ilgili diğer API’leri de açabilirsin.  
   Kaydedip birkaç dakika bekle.

## 2. Firebase Console’da iOS uygulamasını kontrol et

1. **Firebase Console**: https://console.firebase.google.com/
2. **lingola-backend** projesini aç.
3. **Project settings** (dişli) → **Your apps**.
4. iOS uygulaması **com.flywork.lingolajobapp** ile kayıtlı mı kontrol et.
5. Xcode’da **Debug** build’de `com.flywork.lingolajobapp.dev` kullanıyorsan, Firebase’e **ikinci bir iOS app** ekle:
   - “Add app” → iOS → Bundle ID: `com.flywork.lingolajobapp.dev`
   - Yeni indirdiğin `GoogleService-Info.plist`’i **sadece .dev için** ayrı bir config ile kullanmak gerekebilir (genelde production’da tek bundle ID kullanılır).

Özet: En azından **com.flywork.lingolajobapp** Firebase’de kayıtlı olmalı ve Google Cloud’daki API anahtarı bu bundle ID’ye izin vermeli.

## 3. Identity Toolkit API’nin açık olduğundan emin ol

1. Google Cloud Console → **APIs & Services** → **Library**.
2. “Identity Toolkit API” ara ve aç.
3. **Enable** ise zaten açık; **Disable** ise **Enable** yap.

## 4. Değişiklikten sonra

- API key / API ayarlarını kaydettikten sonra **2–5 dakika** bekleyin.
- Uygulamayı **tamamen kapatıp** yeniden açın (veya temiz build: `flutter clean && flutter run`).
- Hâlâ 403 alırsanız:
  - Farklı bir API key “iOS apps” kısıtlamasında kullanılıyor olabilir; Credentials sayfasındaki **tüm** API key’leri kontrol edin.
  - Firebase’de **Authentication → Sign-in method** içinde Apple / Google / E-posta’yı açtığınızdan emin olun.

## Projedeki bundle ID’ler

| Ortam   | Bundle ID                      | Kullanım |
|--------|---------------------------------|----------|
| Release | `com.flywork.lingolajobapp`     | GoogleService-Info.plist, production |
| Debug   | `com.flywork.lingolajobapp.dev` | Xcode Debug/Profile (project.pbxproj) |

Debug’da `.dev` ile giriş yapıyorsanız, Google Cloud’da “iOS apps” kısıtlamasına **com.flywork.lingolajobapp.dev** mutlaka eklenmeli; gerekirse Firebase’e bu bundle ID ile ikinci bir iOS app ekleyin.
