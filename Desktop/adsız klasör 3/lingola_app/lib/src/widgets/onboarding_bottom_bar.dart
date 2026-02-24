import 'package:flutter/material.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

/// Onboarding sayfalarında kullanılan sabit Back / Next buton çubuğu.
/// Padding ve stil tüm sayfalarda tutarlıdır.
class OnboardingBottomBar extends StatelessWidget {
  const OnboardingBottomBar({
    super.key,
    required this.onBack,
    required this.onNext,
    this.nextLabel = 'Next',
    this.nextEnabled = true,
  });

  final VoidCallback onBack;
  final VoidCallback onNext;
  final String nextLabel;
  /// Next butonu etkin mi? false ise tıklanamaz ve soluk görünür.
  final bool nextEnabled;

  static const double _btnWidth = 155;
  static const double _btnHeight = 46;
  static const double _radius = 50;
  static const double _gap = 32;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl + AppSpacing.lg,
        AppSpacing.xl,
        MediaQuery.paddingOf(context).bottom * 0.25,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: _btnWidth,
            height: _btnHeight,
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                foregroundColor: AppColors.onSurface,
                side: BorderSide(color: AppColors.surfaceVariant),
                padding: EdgeInsets.zero,
                minimumSize: const Size(155, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_radius),
                ),
              ),
              child: Text(
                'Back',
                style: AppTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: _gap),
          SizedBox(
            width: _btnWidth,
            height: _btnHeight,
            child: Opacity(
              opacity: nextEnabled ? 1.0 : 0.5,
              child: IgnorePointer(
                ignoring: !nextEnabled,
                child: Material(
                  color: AppColors.primaryBrand,
                  borderRadius: BorderRadius.circular(_radius),
                  child: InkWell(
                    onTap: onNext,
                    borderRadius: BorderRadius.circular(_radius),
                    child: Center(
                      child: Text(
                        nextLabel,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.onPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
