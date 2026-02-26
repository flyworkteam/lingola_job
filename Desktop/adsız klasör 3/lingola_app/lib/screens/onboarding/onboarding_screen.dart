import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';

/// Onboarding ekranı: splash1_screen yapısında, onboard.png kullanır.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _fade;
  Animation<Offset>? _slide;

  void _ensureAnimations() {
    if (_controller != null) return;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.easeOutCubic),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller!, curve: Curves.easeOutCubic));
    _controller!.forward();
  }

  @override
  void initState() {
    super.initState();
    _ensureAnimations();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _ensureAnimations();
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                child: SizedBox(
                  width: 447,
                  height: 503,
                  child: Image.asset(
                    'assets/onboard/onboard.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 470,
            child: FadeTransition(
              opacity: _fade!,
              child: SlideTransition(
                position: _slide!,
                child: Container(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xl),
                  topRight: Radius.circular(AppRadius.xl),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 20,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: AppTitle(
                          'Welcome',
                          style: AppTypography.onboardingTitle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: AppBody(
                          'I am happy to see you. You can\ncontinue where you left off by logging in',
                          style: AppTypography.onboardingDescription,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xl),
                      ..._buildLoginButtons(context),
                      SizedBox(height: AppSpacing.xl),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTypography.onboardingDescription.copyWith(
                            color: AppColors.onboardingText,
                            fontSize: 12,
                          ),
                          children: [
                            const TextSpan(text: 'By signing up for swipe, you agree to our '),
                            TextSpan(
                              text: 'Terms of Service',
                              style: TextStyle(
                                color: AppColors.onboardingText,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: '. Learn how we process your data in our '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(
                                color: AppColors.onboardingText,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Cookies Policy',
                              style: TextStyle(
                                color: AppColors.onboardingText,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  List<Widget> _buildLoginButtons(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final facebookButton = Expanded(
      child: _SocialButton(
        icon: SvgPicture.asset(
          'assets/icons/facebook.svg',
          width: 20,
          height: 20,
        ),
        label: 'Facebook',
        onPressed: () => Navigator.of(context).pushReplacementNamed('/onboarding2'),
      ),
    );

    final guestButton = Expanded(
      child: _SocialButton(
        icon: Icon(Icons.person_outline, color: Colors.black, size: 20),
        label: 'Guest',
        onPressed: () => Navigator.of(context).pushReplacementNamed('/onboarding2'),
      ),
    );

    if (isIOS) {
      return [
        SizedBox(
          width: double.infinity,
          child: _SocialButton(
            icon: SvgPicture.asset(
              'assets/icons/apple.svg',
              width: 20,
              height: 20,
            ),
            label: 'Apple',
            onPressed: () => Navigator.of(context).pushReplacementNamed('/onboarding2'),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                icon: SvgPicture.asset(
                  'assets/icons/google.svg',
                  width: 20,
                  height: 20,
                ),
                label: 'Google',
                onPressed: () => Navigator.of(context).pushReplacementNamed('/onboarding2'),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            facebookButton,
            SizedBox(width: AppSpacing.md),
            guestButton,
          ],
        ),
      ];
    } else {
      return [
        SizedBox(
          width: double.infinity,
          child: _SocialButton(
            icon: SvgPicture.asset(
              'assets/icons/google.svg',
              width: 20,
              height: 20,
            ),
            label: 'Google',
            onPressed: () => Navigator.of(context).pushReplacementNamed('/onboarding2'),
          ),
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                icon: SvgPicture.asset(
                  'assets/icons/apple.svg',
                  width: 20,
                  height: 20,
                ),
                label: 'Apple',
                onPressed: () => Navigator.of(context).pushReplacementNamed('/onboarding2'),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            facebookButton,
            SizedBox(width: AppSpacing.md),
            guestButton,
          ],
        ),
      ];
    }
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Widget icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        side: BorderSide(color: AppColors.surfaceVariant),
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
