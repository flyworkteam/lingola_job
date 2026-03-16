import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lingola_app/View/Onboarding4View/onboarding4_view.dart';
import 'package:lingola_app/navigation/app_routes.dart';
import 'package:lingola_app/navigation/route_transitions.dart';
import 'package:lingola_app/theme/colors.dart';
import 'package:lingola_app/theme/radius.dart';
import 'package:lingola_app/theme/spacing.dart';
import 'package:lingola_app/theme/typography.dart';

/// Onboarding 5. sayfa: "What is your current language level"
class Onboarding5Screen extends StatefulWidget {
  const Onboarding5Screen({super.key});

  @override
  State<Onboarding5Screen> createState() => _Onboarding5ScreenState();
}

class _Onboarding5ScreenState extends State<Onboarding5Screen> {
  String? _selectedLevel;

  static const String _keyProfileLevel = 'profile_level';

  Future<void> _saveLevelAndGoNext(BuildContext context) async {
    final level = _selectedLevel;
    if (level == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfileLevel, level);
    if (!context.mounted) return;
    context.go(AppPaths.onboarding6);
  }

  static const _levels = [
    _Level(id: 'a1', iconAsset: 'assets/seviye/message-circle.svg'),
    _Level(id: 'a2', iconAsset: 'assets/seviye/ai-users.svg'),
    _Level(id: 'b1', iconAsset: 'assets/seviye/Clip path group (4).svg'),
    _Level(id: 'b2', iconAsset: 'assets/seviye/Clip path group (5).svg'),
    _Level(id: 'c1', iconAsset: 'assets/seviye/star-4 (1).svg'),
    _Level(id: 'c2', iconAsset: 'assets/seviye/award (2).svg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl + MediaQuery.paddingOf(context).top,
                AppSpacing.xl,
                AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProgressIndicator(3),
                  SizedBox(height: AppSpacing.xxl),
                  Text(
                    context.tr('onboarding.level_title'),
                    style: AppTypography.onboardingTitle.copyWith(
                      fontSize: 28,
                      color: AppColors.onboardingText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  ..._levels.map(
                    (level) => Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: _LevelCard(
                        level: level,
                        isSelected: _selectedLevel == level.id,
                        onTap: () => setState(() => _selectedLevel = level.id),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => pushReplacementWithBackAnimation(
                            context,
                            const Onboarding4Screen(),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: AppColors.surfaceVariant
                                .withValues(alpha: 0.5),
                            foregroundColor: AppColors.onSurface,
                            side: BorderSide(color: AppColors.surfaceVariant),
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.lg,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                          child: Text(
                            context.tr('common.back'),
                            style: AppTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Opacity(
                          opacity: _selectedLevel != null ? 1.0 : 0.5,
                          child: IgnorePointer(
                            ignoring: _selectedLevel == null,
                            child: Material(
                              color: AppColors.primaryBrand,
                              borderRadius: BorderRadius.circular(50),
                              child: InkWell(
                                onTap: _selectedLevel != null
                                    ? () => _saveLevelAndGoNext(context)
                                    : null,
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppSpacing.lg,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    context.tr('common.next'),
                                    style: AppTypography.labelLarge.copyWith(
                                      color: AppColors.onPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
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
              color: isActive
                  ? AppColors.primaryBrand
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _Level {
  const _Level({required this.id, required this.iconAsset});
  final String id;
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
            color: isSelected
                ? AppColors.primaryBrand
                : AppColors.surfaceVariant,
            width: 2,
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
                  colorFilter: isSelected
                      ? ColorFilter.mode(
                          AppColors.primaryBrand,
                          BlendMode.srcIn,
                        )
                      : level.id == 'b2'
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
                    context.tr('profile_settings.level_${level.id}'),
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.onboardingText,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    context.tr('onboarding.level_descriptions.${level.id}'),
                    style: AppTypography.body.copyWith(
                      color: AppColors.onboardingText,
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
