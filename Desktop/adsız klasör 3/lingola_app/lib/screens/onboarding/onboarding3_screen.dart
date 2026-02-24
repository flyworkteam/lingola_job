import 'package:flutter/material.dart';
import 'package:lingola_app/screens/onboarding/onboarding2_screen.dart';
import 'package:lingola_app/src/navigation/route_transitions.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/dismiss_keyboard.dart';
import 'package:lingola_app/src/widgets/onboarding_bottom_bar.dart';

/// Onboarding 3. sayfa: "Describe your profession in three words."
class Onboarding3Screen extends StatefulWidget {
  const Onboarding3Screen({super.key});

  @override
  State<Onboarding3Screen> createState() => _Onboarding3ScreenState();
}

class _Onboarding3ScreenState extends State<Onboarding3Screen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canProceed = _controller.text.trim().isNotEmpty;
    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
        top: true,
        bottom: true,
        left: false,
        right: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProgressIndicator(1),
                    SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Describe your profession in three words.',
                      style: AppTypography.onboardingTitle.copyWith(
                        fontSize: 28,
                        color: AppColors.onboardingText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      width: double.infinity,
                      child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.surfaceVariant),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Ui/Ux Designer',
                          hintStyle: AppTypography.body.copyWith(
                            color: AppColors.outline,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: AppTypography.body.copyWith(
                          fontSize: 16,
                          color: AppColors.onboardingText,
                        ),
                      ),
                    ),
                    ),
                  ],
                ),
              ),
            ),
            OnboardingBottomBar(
              onBack: () => pushReplacementWithBackAnimation(
                context,
                const Onboarding2Screen(),
              ),
              onNext: () {
                if (!canProceed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please describe your profession'),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pushReplacementNamed('/onboarding4');
              },
              nextEnabled: canProceed,
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildProgressIndicator(int activeIndex) {
    return Row(
      children: List.generate(5, (index) {
        final isActive = index <= activeIndex;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < 4 ? AppSpacing.xs : 0),
            height: 3,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryBrand : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
