import 'package:flutter/material.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/spacing.dart';

/// Ortak kart bileşeni: beyaz arka plan, gölge, yuvarlatılmış köşe.
/// Tüm liste kartları (A1-Beginner, Continue Lesson vb.) bu bileşeni kullanır.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  final Widget child;
  /// Varsayılan: `EdgeInsets.all(AppSpacing.lg)`
  final EdgeInsetsGeometry? padding;
  /// Varsayılan: 16
  final double? borderRadius;

  static const double _defaultRadius = 16;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? _defaultRadius;
    return Container(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
