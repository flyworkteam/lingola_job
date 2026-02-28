import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/word_card_buttons.dart';

class DailyTestScreen extends StatefulWidget {
  const DailyTestScreen({super.key});

  @override
  State<DailyTestScreen> createState() => _DailyTestScreenState();
}

class _DailyTestScreenState extends State<DailyTestScreen> {
  static const double _cardWidth = 330;
  static const double _cardRadius = 30;
  static const Color _blue = Color(0xFF0575E6);
  static const Color _optionBorder = Color(0xFFBABABA);
  static const Color _wrongColor = Color(0xFFFF0000);
  static const Color _correctColor = Color(0xFF00DF00);

  int? _selectedIndex;
  int _currentCardIndex = 0; // 0: soru kartı, 1: doğru cevap kartı

  static const List<String> _options = ['to read', 'read', 'reading', 'reads'];
  static const int _correctAnswerIndex = 3; // "reads"

  void _onOptionTap(int i) {
    if (_currentCardIndex == 1) return; // Doğru cevap kartındayken seçim yapma
    setState(() {
      _selectedIndex = i;
      if (i != _correctAnswerIndex) {
        _currentCardIndex = 1; // Yanlış seçildi -> 2. kartta doğru cevabı göster
      }
    });
  }

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
          'Test',
          style: GoogleFonts.quicksand(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Beyaz kart: soru + seçenekler (veya doğru cevap kartı)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey<int>(_currentCardIndex),
                    width: _cardWidth,
                    constraints: const BoxConstraints(minHeight: 500),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(_cardRadius),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 28),
                        // Soru metni (My father + kesikli çizgi)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              'My father ',
                              style: GoogleFonts.quicksand(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              height: 28,
                              child: CustomPaint(
                                painter: _DashedLinePainter(
                                  color: AppColors.onSurface,
                                  strokeWidth: 2,
                                  dashWidth: 8,
                                  gapWidth: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'newspaper every',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'morning.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.quicksand(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // 2. kartta: yanlış seçili kırmızı, doğru cevap yeşil; 1. kartta: seçenekler tıklanabilir
                        ...List.generate(_options.length, (i) {
                          final showCorrectAnswer = _currentCardIndex == 1;
                          final isCorrectOption = i == _correctAnswerIndex;
                          final selected = _selectedIndex == i;
                          final isWrong = selected && i != _correctAnswerIndex;
                          final isCorrect = selected && i == _correctAnswerIndex;
                          final borderColor = showCorrectAnswer
                              ? (isCorrectOption ? _correctColor : (isWrong ? _wrongColor : _optionBorder))
                              : (isWrong
                                  ? _wrongColor
                                  : (isCorrect ? _correctColor : _optionBorder));
                          final textColor = showCorrectAnswer
                              ? (isCorrectOption ? _correctColor : (isWrong ? _wrongColor : const Color(0xFF1E1E1E)))
                              : (isWrong
                                  ? _wrongColor
                                  : (isCorrect ? _correctColor : const Color(0xFF1E1E1E)));
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: const Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: showCorrectAnswer ? null : () => _onOptionTap(i),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFFFF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: borderColor, width: 1),
                                  ),
                                  child: Text(
                                    _options[i],
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 102),
                // Back | Next butonları
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    BackNextButton(
                      label: 'Back',
                      isPrimary: false,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
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

/// Yatay kesikli çizgi çizer (soru kartındaki boşluk için).
class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.gapWidth,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double gapWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final y = size.height -1;
    double x = 0;
    while (x < size.width) {
      final endX = (x + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, y), Offset(endX, y), paint);
      x += dashWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
