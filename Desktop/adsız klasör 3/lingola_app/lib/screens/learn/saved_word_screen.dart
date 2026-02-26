import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_app/src/state/saved_words_store.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/word_card.dart';
import 'package:lingola_app/src/widgets/word_card_buttons.dart';

/// Saved Word sayfası — Word Practice ile aynı kart ve önizleme.
/// Kaydedilen kelimeler arasında swipe ile gezinilir.
/// [returnToHomeOnPop]: Anasayfadan girildiyse true; çıkışta anasayfaya dönmek için kullanılır.
class SavedWordScreen extends StatefulWidget {
  const SavedWordScreen({
    super.key,
    this.savedWordsCount = 0,
    this.returnToHomeOnPop = false,
  });

  final int savedWordsCount;
  final bool returnToHomeOnPop;

  @override
  State<SavedWordScreen> createState() => _SavedWordScreenState();
}

class _SavedWordScreenState extends State<SavedWordScreen> {

  static const List<SavedWordItem> _placeholderWords = [
    SavedWordItem(
      word: 'Friend',
      phonetic: '/frend/',
      translations: 'Arkadaş, Dost, Yoldaş',
      exampleEn: '"A good friend is hard to find."',
      exampleTr: 'İyi bir arkadaş bulmak zordur.',
    ),
    SavedWordItem(
      word: 'Journey',
      phonetic: '/ˈdʒɜː.ni/',
      translations: 'Yolculuk, Seyahat',
      exampleEn: 'The journey was longer than we expected.',
      exampleTr: 'Yolculuk beklediğimizden daha uzundu.',
    ),
    SavedWordItem(
      word: 'Improve',
      phonetic: '/ɪmˈpruːv/',
      translations: 'Geliştirmek, İyileştirmek',
      exampleEn: 'Practice every day to improve your skills.',
      exampleTr: 'Becerilerini geliştirmek için her gün pratik yap.',
    ),
  ];

  int _currentIndex = 0;
  int _lastSwipeDirection = 1;

  /// Store'da kayıtlı kelime varsa onları, yoksa placeholder kartları gösterir.
  List<SavedWordItem> get _cards {
    if (SavedWordsStore.items.isNotEmpty) return SavedWordsStore.items;
    return _placeholderWords;
  }

  void _goNext() {
    final cards = _cards;
    if (cards.isEmpty) return;
    setState(() {
      _lastSwipeDirection = 1;
      _currentIndex = (_currentIndex + 1) % cards.length;
    });
  }

  void _goPrev() {
    final cards = _cards;
    if (cards.isEmpty) return;
    setState(() {
      _lastSwipeDirection = -1;
      _currentIndex = (_currentIndex - 1) < 0 ? cards.length - 1 : _currentIndex - 1;
    });
  }

  void _handleBack() {
    Navigator.of(context).pop(widget.returnToHomeOnPop);
  }

  @override
  Widget build(BuildContext context) {
    final cards = _cards;
    final index = _currentIndex.clamp(0, cards.length - 1);
    final currentCard = cards[index];

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 120),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WordCard3D(
                    onSwipeLeft: _goPrev,
                    onSwipeRight: _goNext,
                    childKey: ValueKey<int>(_currentIndex),
                    lastSwipeDirection: _lastSwipeDirection,
                    child: WordCardBody(
                    data: WordCardData.fromSavedWordItem(currentCard),
                    showSaveWord: false,
                    savedWordStyle: true,
                    onListen: () {},
                    onHint: () {},
                  ),
                  ),
                  const SizedBox(height: 96),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BackNextButton(
                        label: 'Back',
                        isPrimary: false,
                        onTap: _goPrev,
                      ),
                      const SizedBox(width: 32),
                      BackNextButton(
                        label: 'Next',
                        isPrimary: true,
                        onTap: _goNext,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
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
        onPressed: _handleBack,
      ),
      titleSpacing: 4,
      title: Text(
        'Saved Word',
        style: AppTypography.titleLarge.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/icons/frame_saved_words.svg',
            width: 80,
            height: 80,
            colorFilter: const ColorFilter.mode(Color(0xFF0575E6), BlendMode.srcIn),
            fit: BoxFit.contain,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No saved words yet',
            style: AppTypography.title.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save words from Word Practice\nto review them here.',
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

}

