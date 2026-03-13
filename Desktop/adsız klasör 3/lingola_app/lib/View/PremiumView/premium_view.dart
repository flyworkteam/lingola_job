import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:lingola_app/Riverpod/Providers/all_providers.dart';
import 'package:lingola_app/Services/revenuecat_service.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

class PremiumBenefitsScreen extends ConsumerStatefulWidget {
  const PremiumBenefitsScreen({super.key});

  @override
  ConsumerState<PremiumBenefitsScreen> createState() =>
      _PremiumBenefitsScreenState();
}

class _PremiumBenefitsScreenState extends ConsumerState<PremiumBenefitsScreen> {
  static const String _revenueCatUnavailableMessage =
      'Premium ayarlari henuz yapilandirilmadi.';
  static const _benefits = <String>[
    'Sınırsız mesleki kelime öğrenme ve tekrar erişimi',
    'Sınırsız kelime kaydetme',
    'Öğrenilen mesleki kelimeler için akıllı tekrar hatırlatmaları',
    'Günlük ve haftalık öğrenme hedefleri',
    'Öğrenilen kelimelerle mesleki testler yapma',
    'Öncelikli destek',
    'Yeni özelliklere erken erişim',
  ];

  List<Package> _packages = [];
  bool _loadingOfferings = true;
  String? _offeringsError;
  int _selectedPackageIndex = 0;
  bool _purchasing = false;
  bool _restoring = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _loadingOfferings = true;
      _offeringsError = null;
    });
    if (!RevenueCatService.isConfiguredForCurrentPlatform) {
      if (!mounted) return;
      setState(() {
        _packages = [];
        _loadingOfferings = false;
        _offeringsError = _revenueCatUnavailableMessage;
      });
      return;
    }
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current != null && current.availablePackages.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _packages = current.availablePackages;
          _selectedPackageIndex =
              _selectedPackageIndex.clamp(0, current.availablePackages.length - 1);
          _loadingOfferings = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _packages = [];
          _loadingOfferings = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _packages = [];
        _loadingOfferings = false;
        _offeringsError = e.toString();
      });
    }
  }

  Future<void> _purchase(Package package) async {
    if (_purchasing) return;
    if (!RevenueCatService.isConfiguredForCurrentPlatform) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_revenueCatUnavailableMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _purchasing = true);
    try {
      await Purchases.purchase(PurchaseParams.package(package));
      if (!mounted) return;
      ref.invalidate(premiumProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium hesabınız aktif.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      final cancelled = e is PlatformException &&
          PurchasesErrorHelper.getErrorCode(e) ==
              PurchasesErrorCode.purchaseCancelledError;
      if (!cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Satın alınamadı: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _restore() async {
    if (_restoring) return;
    if (!RevenueCatService.isConfiguredForCurrentPlatform) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_revenueCatUnavailableMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _restoring = true);
    try {
      await Purchases.restorePurchases();
      if (!mounted) return;
      ref.invalidate(premiumProvider);
      final isPremium = ref.read(premiumProvider).valueOrNull ?? false;
      if (isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Satın alımlarınız geri yüklendi.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aktif abonelik bulunamadı.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Geri yükleme hatası: ${e.toString()}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final revenueCatReady = RevenueCatService.isConfiguredForCurrentPlatform;
    final canPurchase = revenueCatReady && _packages.isNotEmpty && !_purchasing;
    final isLoading = _loadingOfferings || _purchasing;

    final hasMultiplePackages = _packages.length > 1;

    final selectedPackage =
        _packages.isNotEmpty ? _packages[_selectedPackageIndex] : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main scrollable content
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    0,
                    AppSpacing.xxl,
                    0,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: _buildHeaderCard(),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: _buildBenefitsList(),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Divider(
                        height: AppSpacing.xl,
                        thickness: 2,
                        color: Color(0xFFE4E5EC),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: _buildPlanSelector(
                          theme: theme,
                          hasMultiplePackages: hasMultiplePackages,
                          canPurchase: canPurchase,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (_offeringsError != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppSpacing.xs,
                            left: AppSpacing.xl,
                            right: AppSpacing.xl,
                          ),
                          child: Text(
                            _offeringsError!,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          0,
                          AppSpacing.xl,
                          AppSpacing.lg,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style:
                                    theme.elevatedButtonTheme.style?.copyWith(
                                          minimumSize: WidgetStateProperty.all(
                                            const Size.fromHeight(52),
                                          ),
                                          backgroundColor:
                                              WidgetStateProperty.all(
                                            const Color(0xFF0974E7),
                                          ),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ) ??
                                        ElevatedButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(52),
                                          backgroundColor:
                                              const Color(0xFF0974E7),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                onPressed:
                                    canPurchase && selectedPackage != null
                                        ? () => _purchase(selectedPackage)
                                        : null,
                                child: isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        selectedPackage != null &&
                                                selectedPackage.storeProduct
                                                    .priceString.isNotEmpty
                                            ? 'Continue — ${selectedPackage.storeProduct.priceString}'
                                            : 'Continue',
                                        style:
                                            AppTypography.labelLarge.copyWith(
                                          color: canPurchase
                                              ? Colors.white
                                              : Colors.white
                                                  .withValues(alpha: 0.8),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _buildFooterLinks(
                              revenueCatReady: revenueCatReady,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Close button (X) with circular border background, drawn on top
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                ),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E4E9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE4E4E9),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 18,
                    onPressed: () => context.pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.black87,
                      size: 18,
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

  Widget _buildHeaderCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/app_icon.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Get Lingola Job Pro',
          textAlign: TextAlign.center,
          style: AppTypography.titleLarge.copyWith(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Our most advanced features, for our most dedicated users.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsList() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: const Color(0xFFF4F4F5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _benefits
            .map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBrand.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: AppColors.primaryBrand,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        b,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.onSurface,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildPlanSelector({
    required ThemeData theme,
    required bool hasMultiplePackages,
    required bool canPurchase,
  }) {
    final yearlySelected = _selectedPackageIndex == 0;
    final monthlySelected = hasMultiplePackages && _selectedPackageIndex == 1;

    String yearlyPrice = '';
    String monthlyPrice = '';

    if (_packages.isNotEmpty) {
      yearlyPrice = _packages.first.storeProduct.priceString;
      if (hasMultiplePackages) {
        monthlyPrice = _packages[1].storeProduct.priceString;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasMultiplePackages)
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF0D7AFF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '19% OFF',
                style: AppTypography.labelLarge.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        if (hasMultiplePackages) const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildPlanOption(
                title: 'Yearly',
                priceLabel: '\$5.83/mo',
                billedLabel: 'Billed at \$69.99/yr',
                isSelected: yearlySelected,
                onTap: () {
                  setState(() => _selectedPackageIndex = 0);
                },
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildPlanOption(
                title: 'Monthly',
                priceLabel: '\$9.99/mo',
                billedLabel: 'Billed at \$9.99/mo.',
                isSelected: monthlySelected,
                onTap: () {
                  setState(() => _selectedPackageIndex = 1);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanOption({
    required String title,
    required String priceLabel,
    String? billedLabel,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.md,
            bottom: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0xFFE7F0FF) : const Color(0xFFF2F2F7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color:
                  isSelected ? const Color(0xFF0D7AFF) : const Color(0xFFC5C5C7),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.left,
                      style: AppTypography.labelLarge.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: const Color(0xFF020814),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priceLabel,
                      textAlign: TextAlign.left,
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Noto Sans Japanese',
                        color: AppColors.onSurface,
                      ),
                    ),
                    if (billedLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        billedLabel,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        softWrap: false,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 10,
                          color: const Color(0xFF77737E),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _buildPlanCheckIndicator(isSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCheckIndicator(bool isSelected) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: isSelected ? const Color(0xFF0D7AFF) : const Color(0xFFC5C5C7),
          width: 2,
        ),
      ),
      child: isSelected
          ? Container(
              margin: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF0D7AFF),
              ),
              child: const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Widget _buildFooterLinks({required bool revenueCatReady}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed:
              (_restoring || _loadingOfferings || !revenueCatReady) ? null : _restore,
          child: Text(
            'Restore Purchases',
            style: AppTypography.labelLarge.copyWith(
              color: const Color(0xFF0974E7),
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        TextButton(
          onPressed: () {
            // TODO: Terms URL
          },
          child: Text(
            'Terms',
            style: AppTypography.labelLarge.copyWith(
              color: const Color(0xFF0974E7),
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        TextButton(
          onPressed: () {
            // TODO: Privacy URL
          },
          child: Text(
            'Privacy',
            style: AppTypography.labelLarge.copyWith(
              color: const Color(0xFF0974E7),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueCatUnavailableNotice() {
    return const SizedBox.shrink();
  }
}
