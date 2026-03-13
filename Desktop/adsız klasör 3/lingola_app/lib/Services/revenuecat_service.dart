import 'dart:io' show Platform;

import 'package:purchases_flutter/purchases_flutter.dart';

const String _kRevenueCatAppleApiKey = String.fromEnvironment(
  'REVENUECAT_APPLE_API_KEY',
);
const String _kRevenueCatAndroidApiKey = String.fromEnvironment(
  'REVENUECAT_ANDROID_API_KEY',
);

class RevenueCatService {
  RevenueCatService._();

  static bool get isConfiguredForCurrentPlatform => apiKey.isNotEmpty;

  static String get apiKey {
    if (Platform.isIOS) return _kRevenueCatAppleApiKey;
    if (Platform.isAndroid) return _kRevenueCatAndroidApiKey;
    return '';
  }

  static Future<void> configureIfAvailable() async {
    if (!isConfiguredForCurrentPlatform) return;
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }
}
