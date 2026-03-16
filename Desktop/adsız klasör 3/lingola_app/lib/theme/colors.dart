import 'package:flutter/material.dart';

/// Uygulama renk paleti. Hex değerler sadece bu dosyada tanımlanır;
/// widget'larda doğrudan hex (#...) kullanılmaz.
abstract final class AppColors {
  AppColors._();

  // --- Palette (tek kaynak, hex burada)
  static const int _primaryValue = 0xFF6750A4;
  static const int _onPrimaryValue = 0xFFFFFFFF;
  static const int _primaryContainerValue = 0xFFEADDFF;
  static const int _onPrimaryContainerValue = 0xFF21005D;
  static const int _secondaryValue = 0xFF625B71;
  static const int _onSecondaryValue = 0xFFFFFFFF;
  static const int _secondaryContainerValue = 0xFFE8DEF8;
  static const int _onSecondaryContainerValue = 0xFF1D192B;
  static const int _surfaceValue = 0xFFFFFBFE;
  static const int _onSurfaceValue = 0xFF1C1B1F;
  static const int _surfaceVariantValue = 0xFFE0E0E0;
  static const int _onSurfaceVariantValue = 0xFF49454F;
  static const int _outlineValue = 0xFF79747E;
  static const int _errorValue = 0xFFB3261E;
  static const int _onErrorValue = 0xFFFFFFFF;
  static const int _backgroundValue = 0xFFFFFBFE;
  static const int _onBackgroundValue = 0xFF1C1B1F;
  static const int _splashGradientStartValue = 0xFF0575E6;
  static const int _splashGradientEndValue = 0xFF021B79;
  static const int _blackValue = 0xFF000000;
  static const int _primaryDropShadowValue = 0xFF004182;
  static const int _onboardingTextValue = 0xFF1D1D1D;
  static const int _placeholderBarValue = 0xFFEDEDED;
  static const int _whiteValue = 0xFFFFFFFF;

  /// Semantic renkler (widget'larda bunlar kullanılır)
  static const Color primary = Color(_primaryValue);
  static const Color onPrimary = Color(_onPrimaryValue);
  static const Color primaryContainer = Color(_primaryContainerValue);
  static const Color onPrimaryContainer = Color(_onPrimaryContainerValue);
  static const Color secondary = Color(_secondaryValue);
  static const Color onSecondary = Color(_onSecondaryValue);
  static const Color secondaryContainer = Color(_secondaryContainerValue);
  static const Color onSecondaryContainer = Color(_onSecondaryContainerValue);
  static const Color surface = Color(_surfaceValue);
  static const Color onSurface = Color(_onSurfaceValue);
  static const Color surfaceVariant = Color(_surfaceVariantValue);
  static const Color onSurfaceVariant = Color(_onSurfaceVariantValue);
  static const Color outline = Color(_outlineValue);
  static const Color error = Color(_errorValue);
  static const Color onError = Color(_onErrorValue);
  static const Color background = Color(_backgroundValue);
  static const Color onBackground = Color(_onBackgroundValue);

  /// Splash ekranı gradient: soldan (#0575E6) sağa (#021B79)
  static const Color splashGradientStart = Color(_splashGradientStartValue);
  static const Color splashGradientEnd = Color(_splashGradientEndValue);

  /// Onboarding başlık rengi (siyah)
  static const Color onboardingTitle = Color(_blackValue);

  /// Marka mavisi (#0575E6) – buton, imleç, sayfa göstergesi.
  static const Color primaryBrand = Color(_splashGradientStartValue);

  /// Primary Drop Shadow rengi (#004182)
  static const Color primaryDropShadow = Color(_primaryDropShadowValue);

  /// Kart / panel dış gölgesi (hafif koyu)
  static const Color cardShadow = Color(0x1A000000);

  /// Onboarding metin rengi (koyu gri)
  static const Color onboardingText = Color(_onboardingTextValue);

  /// Placeholder / skeleton çizgi rengi (açık gri)
  static const Color placeholderBar = Color(_placeholderBarValue);

  /// Saf beyaz (konuşma balonu, buton vb.)
  static const Color white = Color(_whiteValue);
}
