import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_app/screens/onboarding/onboarding4_screen.dart';
import 'package:lingola_app/src/navigation/route_transitions.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/widgets/onboarding_bottom_bar.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

/// Onboarding 5. sayfa: "What is your current language level"
class Onboarding5Screen extends StatefulWidget {
  const Onboarding5Screen({super.key});

  @override
  State<Onboarding5Screen> createState() => _Onboarding5ScreenState();
}

class _Onboarding5ScreenState extends State<Onboarding5Screen> {
  String? _selectedLevel;

  static const _levels = [
    _Level(
      id: 'a1',
      title: 'A1 Beginner',
      description: 'Can understand and use familiar every day expressions.',
      iconAsset: 'assets/seviye/message-circle.svg',
    ),
    _Level(
      id: 'a2',
      title: 'A2 Elementary',
      description: 'Can communicate in simple and routine tasks',
      iconAsset: 'assets/seviye/ai-users.svg',
    ),
    _Level(
      id: 'b1',
      title: 'B1 Intermediate',
      description: 'Can deal with most situations likely to arise whilst traveling.',
      iconAsset: 'assets/seviye/Clip path group (4).svg',
    ),
    _Level(
      id: 'b2',
      title: 'B2 Upper-Intermediate',
      description: 'Can lead business meetings comfortably',
      iconAsset: 'assets/seviye/Clip path group (5).svg',
    ),
    _Level(
      id: 'c1',
      title: 'C1 Advanced',
      description: 'Can express ideas fluently and spontaneously.',
      iconAsset: 'assets/seviye/star-4 (1).svg',
    ),
    _Level(
      id: 'c2',
      title: 'C2 Proficient',
      description: 'Can understand with ease virtually everything heard to read.',
      iconAsset: 'assets/seviye/award (2).svg',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    _buildProgressIndicator(3),
                    SizedBox(height: AppSpacing.xxl),
                    Text(
                      'What is your current\nlanguage level?',
                      style: AppTypography.onboardingTitle.copyWith(
                        fontSize: 28,
                        color: AppColors.onboardingText,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: AppSpacing.xl),
                    ..._levels.map((level) => Padding(
                          padding: EdgeInsets.only(bottom: AppSpacing.md),
                          child: _LevelCard(
                            level: level,
                            isSelected: _selectedLevel == level.id,
                            onTap: () =>
                                setState(() => _selectedLevel = level.id),
                          ),
                        )),
                    SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
            OnboardingBottomBar(
              onBack: () => pushReplacementWithBackAnimation(
                context,
                const Onboarding4Screen(),
              ),
              onNext: () {
                if (_selectedLevel == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select your language level'),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pushReplacementNamed('/onboarding6');
              },
              nextEnabled: _selectedLevel != null,
            ),
          ],
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

class _Level {
  const _Level({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
  });
  final String id;
  final String title;
  final String description;
  final String iconAsset;
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  final _Level level;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.primaryBrand : AppColors.surfaceVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.sm),
              child: SizedBox(
                width: 44,
                height: 44,
                child: SvgPicture.asset(
                  level.iconAsset,
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                  colorFilter: level.id == 'b2'
                      ? const ColorFilter.mode(
                          Color(0xFF79747E),
                          BlendMode.srcIn,
                        )
                      : null,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.onboardingText,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    level.description,
                    style: AppTypography.body.copyWith(
                      color: AppColors.outline,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
