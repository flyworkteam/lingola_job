import 'package:flutter/material.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

/// Gradient (pill) buton: Get Premium vb. aksiyonlar için.
/// Turuncu gradient, yuvarlak köşe (radius 50), gölge.
class AppGradientButton extends StatelessWidget {
  const AppGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.gradient,
    this.textColor = Colors.black,
    this.fontSize = 13,
  });

  final String label;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final Color textColor;
  final double fontSize;

  static const Gradient _defaultGradient = LinearGradient(
    colors: [Color(0xFFFF9800), Color(0xFFFFB300)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Widget build(BuildContext context) {
    final gradientToUse = gradient ?? _defaultGradient;
    return Container(
      decoration: BoxDecoration(
        gradient: gradientToUse,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
