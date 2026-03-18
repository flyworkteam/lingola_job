import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_app/theme/colors.dart';
import 'package:lingola_app/theme/radius.dart';
import 'package:lingola_app/theme/spacing.dart';
import 'package:lingola_app/theme/typography.dart';

/// Premium bilgi ekranı. RevenueCat yapılandırılmamışken Profil > Premium
/// tıklandığında açılır; avantajları ve "bu sürümde satın alma aktif değil" mesajını gösterir.
class PremiumInfoScreen extends StatelessWidget {
  const PremiumInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F5FC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Transform.translate(
            offset: const Offset(6, 0),
            child: Transform.scale(
              scaleX: -1,
              child: SvgPicture.asset(
                'assets/icons/icon_arrow_right.svg',
                width: 20,
                height: 9,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF000000),
                  BlendMode.srcIn,
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.tr('profile.premium_menu'),
          style: AppTypography.titleLarge.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),
            _buildBenefitsCard(context),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                context.tr('profile.premium_info_unavailable'),
                style: AppTypography.body.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsCard(BuildContext context) {
    final benefits = [
      context.tr('notifications.premium_benefit_1'),
      context.tr('notifications.premium_benefit_2'),
      context.tr('notifications.premium_benefit_3'),
      context.tr('notifications.premium_benefit_4'),
      context.tr('notifications.premium_benefit_5'),
      context.tr('notifications.premium_benefit_6'),
      context.tr('notifications.premium_benefit_7'),
    ];
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.splashGradientStart,
            AppColors.splashGradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDropShadow.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/kupa.svg',
                width: 48,
                height: 48,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                fit: BoxFit.contain,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  context.tr('notifications.premium_benefits'),
                  style: AppTypography.title.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            context.tr('notifications.premium_benefits_desc'),
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...benefits.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      b,
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
