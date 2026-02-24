import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/word_card.dart';
import 'package:lingola_app/src/widgets/word_card_buttons.dart';

/// Reading Test sayfası — Word Practice ile aynı mavi kart + header + button bar.
class ReadingTestScreen extends StatelessWidget {
  const ReadingTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F5FC),
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
                colorFilter: const ColorFilter.mode(Color(0xFF000000), BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 4,
        title: Text(
          'Reading Test',
          style: AppTypography.titleLarge.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 120),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              WordCard3D(
                height: 300,
                child: WordCardReadingTestBody(
                  word: 'Friend',
                  phonetic: '/frend/',
                  translation: 'Arkadaş, Dost, Yoldaş',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WordCardHintButton(onTap: () {}),
                  const SizedBox(width: 12),
                  _MicButton(onTap: () {}),
                ],
              ),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BackNextButton(
                    label: 'Back',
                    isPrimary: false,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 32),
                  BackNextButton(
                    label: 'Next',
                    isPrimary: true,
                    onTap: () {},
                  ),
                ],
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }

}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0575E6),
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: SvgPicture.asset(
            'assets/icons/icon_mic.svg',
            width: 24,
            height: 28,
            colorFilter: const ColorFilter.mode(Color(0xFFFFFFFF), BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
