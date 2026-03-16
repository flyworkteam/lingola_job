import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:lingola_app/config/revenuecat_keys.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Önce --dart-define ile verilen env, yoksa lib/config/revenuecat_keys.dart
const String _kEnvApple = String.fromEnvironment('REVENUECAT_APPLE_API_KEY');
const String _kEnvAndroid = String.fromEnvironment('REVENUECAT_ANDROID_API_KEY');

class RevenueCatService {
  RevenueCatService._();

  static bool get isConfiguredForCurrentPlatform => apiKey.isNotEmpty;

  static String get apiKey {
    if (kIsWeb) return '';
    if (Platform.isIOS) {
      if (_kEnvApple.isNotEmpty) return _kEnvApple;
      return revenueCatAppleApiKey;
    }
    if (Platform.isAndroid) {
      if (_kEnvAndroid.isNotEmpty) return _kEnvAndroid;
      return revenueCatAndroidApiKey;
    }
    return '';
  }

  static Future<void> configureIfAvailable() async {
    if (!isConfiguredForCurrentPlatform) return;
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  /// RevenueCat Dashboard'da tanımlı paywall'u gösterir (tasarladığınız ekran buradan gelir).
  /// [displayCloseButton] true ise kullanıcı X ile kapatabilir.
  /// Platform yapılandırılmamışsa null döner.
  static Future<dynamic> presentPaywall({
    bool displayCloseButton = true,
  }) async {
    if (!isConfiguredForCurrentPlatform) return null;
    return RevenueCatUI.presentPaywall(displayCloseButton: displayCloseButton);
  }

  /// Paywall'ı çökme riskini azaltarak açar: önce offerings kontrol edilir, billing yoksa
  /// paywall açılmaz. true = paywall gösterildi ve kapatıldı, false = gösterilmedi (mesaj gösterin).
  static Future<bool> tryPresentPaywallSafe({
    bool displayCloseButton = true,
  }) async {
    if (!isConfiguredForCurrentPlatform) return false;
    try {
      await Purchases.getOfferings();
    } catch (e) {
      if (getBillingUnavailableMessageKey(e) != null) return false;
      final s = e.toString();
      if (s.contains('ConfigurationError') ||
          s.contains('configuration') ||
          s.contains('offerings') ||
          s.contains('no Play Store products')) return false;
      rethrow;
    }
    try {
      await RevenueCatUI.presentPaywall(displayCloseButton: displayCloseButton);
      return true;
    } catch (e) {
      if (getBillingUnavailableMessageKey(e) != null) return false;
      final s = e.toString();
      if (s.contains('ConfigurationError') ||
          s.contains('configuration') ||
          s.contains('PAYWALLS_') ||
          s.contains('Error 23')) return false;
      rethrow;
    }
  }

  /// Billing/PurchaseNotAllowed veya paywall activity hatası ise kullanıcıya gösterilecek çeviri anahtarını döner.
  /// Örn. emülatör, cihazda faturalandırma kapalı, veya PAYWALLS_MISSING_WRONG_ACTIVITY.
  static String? getBillingUnavailableMessageKey(Object error) {
    final s = error.toString();
    if (s.contains('PurchaseNotAllowedError') ||
        s.contains('BILLING_UNAVAILABLE') ||
        s.contains('Billing is not available') ||
        s.contains('Billing service unavailable') ||
        s.contains('not allowed to make the purchase') ||
        s.contains('PAYWALLS_MISSING_WRONG_ACTIVITY') ||
        s.contains('FlutterFragmentActivity')) {
      return 'profile.premium_billing_unavailable';
    }
    return null;
  }
}
