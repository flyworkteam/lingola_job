import 'package:flutter/material.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

/// İlk açılışta gösterilen splash ekranı.
/// Soldan sağa gradient (AppColors.splashGradientStart → splashGradientEnd).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future<void>.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/onboarding1');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.splashGradientStart,
              AppColors.splashGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Transform.translate(
              offset: const Offset(0, 100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/splash/Layer_1.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppTitle(
                    'Lingola Job',
                    style: AppTypography.splashBrandTitle.copyWith(
                      color: Colors.white,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
