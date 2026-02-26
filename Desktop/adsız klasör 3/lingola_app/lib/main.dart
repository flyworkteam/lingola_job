import 'package:flutter/material.dart';
import 'package:lingola_app/screens/main/main_screen.dart';
import 'package:lingola_app/screens/splash/splash_screen.dart';
import 'package:lingola_app/screens/splash/splash1_screen.dart';
import 'package:lingola_app/screens/splash/splash2_screen.dart';
import 'package:lingola_app/screens/splash/splash3_screen.dart';
import 'package:lingola_app/screens/splash/splash_intro_screen.dart';
import 'package:lingola_app/screens/onboarding/onboarding_screen.dart';
import 'package:lingola_app/screens/onboarding/onboarding2_screen.dart';
import 'package:lingola_app/screens/onboarding/onboarding3_screen.dart';
import 'package:lingola_app/screens/onboarding/onboarding4_screen.dart';
import 'package:lingola_app/screens/onboarding/onboarding5_screen.dart';
import 'package:lingola_app/screens/onboarding/onboarding6_screen.dart';
import 'package:lingola_app/screens/onboarding/onboarding7_screen.dart';
import 'package:lingola_app/screens/notifications/notifications_screen.dart';
import 'package:lingola_app/screens/faq/faq_screen.dart';
import 'package:lingola_app/screens/home/most_frequently_used_terms_screen.dart';
import 'package:lingola_app/screens/profile/profile_settings_screen.dart';
import 'package:lingola_app/src/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lingola',
      theme: AppTheme.light,
      initialRoute: '/splash',
      routes: <String, WidgetBuilder>{
        '/splash': (_) => const SplashScreen(),
        '/splash_intro': (_) => const SplashIntroScreen(),
        '/splash1': (_) => const Splash1Screen(),
        '/splash2': (_) => const Splash2Screen(),
        '/splash3': (_) => const Splash3Screen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/onboarding2': (_) => const Onboarding2Screen(),
        '/onboarding3': (_) => const Onboarding3Screen(),
        '/onboarding4': (_) => const Onboarding4Screen(),
        '/onboarding5': (_) => const Onboarding5Screen(),
        '/onboarding6': (_) => const Onboarding6Screen(),
        '/onboarding7': (_) => const Onboarding7Screen(),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return MainScreen(
            isPremium: true,
            initialIndex: args?['initialIndex'] as int? ?? 0,
          );
        },
        '/notifications': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return NotificationsScreen(isPremium: args?['isPremium'] as bool? ?? false);
        },
        '/profile_settings': (context) {
          return const ProfileSettingsScreen(initialName: '');
        },
        '/faq': (_) => const FaqScreen(),
        '/most_frequently_used_terms': (_) => const MostFrequentlyUsedTermsScreen(),
      },
    );
  }
}
