import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lingola_app/Services/revenuecat_service.dart';
import 'package:lingola_app/firebase_options.dart';
import 'package:lingola_app/navigation/app_router.dart';
import 'package:lingola_app/theme/app_theme.dart';

/// Tek instance: locale değişince MaterialApp yeniden build olur ama router aynı kalır,
/// böylece onboarding ortasında dil değişince başa dönülmez.
final _appRouter = createAppRouter();
const _supportedLocales = <Locale>[
  Locale('tr'),
  Locale('en'),
  Locale('de'),
  Locale('fr'),
  Locale('es'),
  Locale('it'),
  Locale('pt'),
  Locale('ru'),
  Locale('ja'),
  Locale('ko'),
  Locale('hi'),
];
const _fallbackLocale = Locale('en');
const _keyProfileAppLanguage = 'profile_app_language';
const _keyOnboardingCompleted = 'onboarding_completed';

Locale _resolveInitialLocale(String? savedLanguageId) {
  const languageIdToCode = <String, String>{
    'turkish': 'tr',
    'english': 'en',
    'german': 'de',
    'french': 'fr',
    'spanish': 'es',
    'italian': 'it',
    'portuguese': 'pt',
    'russian': 'ru',
    'japanese': 'ja',
    'korean': 'ko',
    'hindi': 'hi',
  };

  if (savedLanguageId != null) {
    final savedCode = languageIdToCode[savedLanguageId];
    if (savedCode != null) {
      for (final locale in _supportedLocales) {
        if (locale.languageCode == savedCode) return locale;
      }
    }
  }

  final deviceCode =
      WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  for (final locale in _supportedLocales) {
    if (locale.languageCode == deviceCode) return locale;
  }
  return _fallbackLocale;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool(_keyOnboardingCompleted) ?? false;
  final initialLocale = _resolveInitialLocale(
    onboardingCompleted ? prefs.getString(_keyProfileAppLanguage) : null,
  );
  await RevenueCatService.configureIfAvailable();
  runApp(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: _supportedLocales,
      fallbackLocale: _fallbackLocale,
      startLocale: initialLocale,
      useFallbackTranslations: true,
      saveLocale: false,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Lingola',
        theme: AppTheme.light,
        routerConfig: _appRouter,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
      ),
    );
  }
}
