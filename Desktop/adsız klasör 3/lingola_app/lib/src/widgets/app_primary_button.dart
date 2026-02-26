import 'package:flutter/material.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

/// Ortak primary buton: marka mavisi, iç gölge, tek kaynaktan stiller.
/// Tüm ekranlarda bu bileşen kullanılır; çıplak FilledButton/InkWell ile buton yazılmaz.
class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  /// true ise genişlik double.infinity (varsayılan).
  final bool expand;

  static const double _buttonRadius = 50;

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(_buttonRadius),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primaryBrand,
            borderRadius: BorderRadius.circular(_buttonRadius),
          ),
          child: Center(
            child: AppLabel(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.onPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );

    if (expand) {
      return SizedBox(
        width: double.infinity,
        child: child,
      );
    }
    return child;
  }
}
