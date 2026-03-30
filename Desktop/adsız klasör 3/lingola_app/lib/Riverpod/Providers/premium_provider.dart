import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:lingola_app/Services/revenuecat_service.dart';

/// Geliştirmede premium testi: `flutter run --dart-define=FORCE_PREMIUM_DEV=true`
/// App Store derlemesinde varsayılan **false** (gerçek RevenueCat aboneliği kullanılır).
const bool kForcePremiumForDev =
    bool.fromEnvironment('FORCE_PREMIUM_DEV', defaultValue: false);

/// RevenueCat dashboard'da tanımlı entitlement identifier (örn. "premium").
const String kPremiumEntitlementId = 'premium';

/// Kullanıcının premium (abonelik) durumunu RevenueCat'ten okur.
/// Satın alma veya restore sonrası [ref.refresh(premiumProvider)] ile güncellenir.
final premiumProvider = FutureProvider<bool>((ref) async {
  if (kForcePremiumForDev) return true;
  if (!RevenueCatService.isConfiguredForCurrentPlatform) return false;
  try {
    final info = await Purchases.getCustomerInfo();
    if (info.entitlements.active.containsKey(kPremiumEntitlementId)) return true;
    return info.entitlements.active.isNotEmpty;
  } catch (_) {
    return false;
  }
});
