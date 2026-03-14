# Apple ile Girişin Başarılı Olması İçin

Projede **Sign in with Apple** entitlement'ı tanımlı. Aşağıdakileri **Apple Developer hesabı olan kişi** (siz veya müşteri) tamamlamalı.

---

## 1. Apple Developer Program

- **Ücretli hesap** gerekir: [developer.apple.com](https://developer.apple.com) → Apple Developer Program ($99/yıl).
- Giriş yapacak cihazda test için bu hesap yeterli (Team’i Xcode’da seçeceksiniz).

---

## 2. Developer Portal’da App ID Ayarı

1. [developer.apple.com](https://developer.apple.com) → **Account** → **Certificates, Identifiers & Profiles**.
2. Soldan **Identifiers** → uygulamanızın **App ID**’sini seçin (örn. `com.flywork.lingolajobapp`).
3. **Sign in with Apple** kutusunu **işaretleyin** → **Save**.

---

## 3. Xcode’da Capability Ekleme

1. Projeyi Xcode ile açın: `ios/Runner.xcworkspace` (`.xcproject` değil).
2. Sol taraftan **Runner** target’ını seçin.
3. Üstten **Signing & Capabilities** sekmesine girin.
4. **+ Capability** → **Sign in with Apple** ekleyin.  
   (Zaten `Runner.entitlements` içinde tanımlıysa Xcode bunu gösterebilir; yoksa bu adımda eklenir.)

---

## 4. Signing (Team) Kontrolü

- **Signing & Capabilities** içinde **Team** alanında ücretli Apple Developer hesabınızı seçin.
- **Bundle Identifier**’ın portal’daki App ID ile birebir aynı olduğundan emin olun.

---

## 5. Temiz Build ve Test

1. Xcode: **Product → Clean Build Folder**.
2. Cihaz/simulator’dan uygulamayı **silin**.
3. `flutter clean` → `cd ios && pod install` → tekrar `flutter run` veya Xcode’dan Run.

---

## Özet Kontrol Listesi

| Adım | Yapıldı mı? |
|------|-------------|
| Ücretli Apple Developer hesabı var | ☐ |
| Portal’da App ID’de “Sign in with Apple” açık | ☐ |
| Xcode’da Runner → Sign in with Apple capability eklendi | ☐ |
| Team seçili, temiz build + uygulama yeniden yüklendi | ☐ |

Bu adımlar tamamsa Apple ile giriş başarılı olur. Hâlâ **error 1000** alırsanız: capability’nin **tüm** build konfigürasyonlarında (Debug/Release) ve provisioning profile’da olduğundan emin olun; gerekirse Xcode’da **Signing** bölümünden provisioning profile’ı “Automatically manage signing” ile yenileyin.
