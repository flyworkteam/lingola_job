import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // MissingPluginException
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import 'package:lingola_app/Models/saved_word_item.dart';
import 'package:lingola_app/Riverpod/Providers/all_providers.dart';
import 'package:lingola_app/Services/word_database_service.dart';
import 'package:lingola_app/Services/word_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lingola_app/src/navigation/app_routes.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/app_bottom_nav_bar.dart';
import 'package:lingola_app/src/widgets/word_card.dart';

/// Most Frequently Used Terms — mesleki kelimeler (professional_words) ile Learn New Words
/// mantığında: üstte kelime, altında okunuş, çeviri, örnek cümle; swipe ile ilerleme.
class MostFrequentlyUsedTermsScreen extends ConsumerStatefulWidget {
  const MostFrequentlyUsedTermsScreen({super.key});

  @override
  ConsumerState<MostFrequentlyUsedTermsScreen> createState() =>
      _MostFrequentlyUsedTermsScreenState();
}

class _MostFrequentlyUsedTermsScreenState
    extends ConsumerState<MostFrequentlyUsedTermsScreen> {
  OverlayEntry? _tutorialOverlay;

  List<WordCardData>? _cards;
  bool _loading = true;
  String? _errorMessage;
  int _currentCardIndex = 0;
  int _lastSwipeDirection = 1;
  String? _lastLoadedLocaleCode;
  final Set<String> _translationRequested = {};
  final Set<String> _phoneticRequested = {};
  final Set<String> _exampleRequested = {};
  final Set<String> _hintRevealed = {};
  FlutterTts? _flutterTts;
  bool _ttsInitialized = false;

  static const List<AppNavItem> _navItems = [
    AppNavItem(iconAsset: 'assets/icons/nav_home.svg', label: 'nav.home'),
    AppNavItem(iconAsset: 'assets/icons/nav_learn.svg', label: 'nav.learn'),
    AppNavItem(iconAsset: 'assets/icons/nav_library.svg', label: 'nav.library'),
    AppNavItem(iconAsset: 'assets/icons/nav_profil.svg', label: 'nav.profile'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _insertTutorialOverlay();
      _loadWords();
      _initTts();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentLocale = context.locale.languageCode;
    if (_lastLoadedLocaleCode != null && _lastLoadedLocaleCode != currentLocale) {
      _lastLoadedLocaleCode = currentLocale;
      _loadWords();
    }
  }

  @override
  void dispose() {
    _removeTutorialOverlay();
    _flutterTts?.stop();
    super.dispose();
  }

  static const String _keyProfileProfession = 'profile_profession';

  Future<void> _loadWords() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final prefs = await SharedPreferences.getInstance();
    final professionId = prefs.getString(_keyProfileProfession);
    final category = WordDatabaseService.professionIdToCategory(professionId);
    final localeCode = context.locale.languageCode;

    final rawList = await WordDatabaseService.getProfessionalWords(
      category: category,
    );

    // Kartları hemen oluştur; çeviri/okunuş/örnek cümle görüntülenen karta göre lazy yüklenecek (ekran donmasını önler).
    final cards = <WordCardData>[];
    for (final m in rawList) {
      final word = (m['word'] as String?)?.trim() ?? '';
      if (word.isEmpty) continue;

      final basePhonetic = (m['phonetic'] as String?)?.trim() ?? '';
      final exampleEn = (m['example'] as String?)?.trim() ?? '';
      final exampleTr = (m['example_translation'] as String?)?.trim() ?? '';

      cards.add(
        WordCardData(
          word: word,
          phonetic: basePhonetic,
          translations: '',
          exampleEn: exampleEn,
          exampleTr: exampleTr,
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _cards = cards;
      _loading = false;
      _errorMessage = cards.isEmpty ? 'word_practice.words_load_error' : null;
      _currentCardIndex = 0;
      _lastLoadedLocaleCode = localeCode;
    });
  }

  Future<void> _initTts() async {
    if (_ttsInitialized) return;
    _flutterTts ??= FlutterTts();
    await _flutterTts!.awaitSpeakCompletion(true);
    try {
      await _flutterTts!.setSharedInstance(true);
    } on MissingPluginException catch (_) {} on Exception catch (_) {}
    try {
      await _flutterTts!.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.allowBluetooth,
          IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    } on MissingPluginException catch (_) {} on Exception catch (_) {}
    _flutterTts!.setErrorHandler((msg) {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(
            content: Text('Ses hatası: $msg'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
    _ttsInitialized = true;
  }

  Future<void> _speakCurrentWord() async {
    final card = _currentCard;
    if (card == null || card.word.trim().isEmpty) return;
    await _initTts();
    if (_flutterTts == null) return;
    await _flutterTts!.setVolume(1.0);
    await _flutterTts!.setSpeechRate(0.5);
    try {
      await _flutterTts!.setLanguage('en-US');
    } catch (_) {
      try {
        await _flutterTts!.setLanguage('en');
      } catch (_) {}
    }
    await _flutterTts!.speak(card.word.trim());
  }

  void _insertTutorialOverlay() {
    if (!mounted || _tutorialOverlay != null) return;
    final entry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: _TutorialFullScreenOverlay(onDismiss: _removeTutorialOverlay),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(entry);
    _tutorialOverlay = entry;
  }

  void _removeTutorialOverlay() {
    _tutorialOverlay?.remove();
    _tutorialOverlay = null;
  }

  void _goNextCard() {
    final cards = _cards;
    if (cards == null || cards.isEmpty) return;
    setState(() {
      _lastSwipeDirection = 1;
      _currentCardIndex = (_currentCardIndex + 1) % cards.length;
    });
  }

  void _goPrevCard() {
    final cards = _cards;
    if (cards == null || cards.isEmpty) return;
    setState(() {
      _lastSwipeDirection = -1;
      _currentCardIndex =
          (_currentCardIndex - 1) < 0 ? (cards.length - 1) : (_currentCardIndex - 1);
    });
  }

  Future<void> _fetchTranslationForCurrentCard() async {
    final card = _currentCard;
    if (card == null || card.translations.trim().isNotEmpty) return;
    final localeCode = context.locale.languageCode;
    final translation =
        await WordService.fetchAndCacheTranslationForLocale(card.word, localeCode);
    if (!mounted || translation.isEmpty) return;
    final cards = _cards;
    if (cards == null || cards.isEmpty) return;
    final idx = _currentCardIndex.clamp(0, cards.length - 1);
    final c = cards[idx];
    if (c.word != card.word) return;
    setState(() {
      _cards = [
        ...cards.sublist(0, idx),
        WordCardData(
          word: c.word,
          phonetic: c.phonetic,
          translations: translation,
          exampleEn: c.exampleEn,
          exampleTr: c.exampleTr,
        ),
        ...cards.sublist(idx + 1),
      ];
    });
  }

  Future<void> _fetchPhoneticForCurrentCard() async {
    final card = _currentCard;
    if (card == null || card.phonetic.trim().isNotEmpty) return;
    final phonetic = await WordService.fetchAndCachePhonetic(card.word);
    if (!mounted || phonetic.isEmpty) return;
    final cards = _cards;
    if (cards == null || cards.isEmpty) return;
    final idx = _currentCardIndex.clamp(0, cards.length - 1);
    final c = cards[idx];
    if (c.word != card.word) return;
    setState(() {
      _cards = [
        ...cards.sublist(0, idx),
        WordCardData(
          word: c.word,
          phonetic: phonetic,
          translations: c.translations,
          exampleEn: c.exampleEn,
          exampleTr: c.exampleTr,
        ),
        ...cards.sublist(idx + 1),
      ];
    });
  }

  Future<void> _fetchExampleForCurrentCard() async {
    final card = _currentCard;
    if (card == null) return;
    final localeCode = context.locale.languageCode;
    final result = await WordService.getExampleForWord(card.word, localeCode);
    if (!mounted ||
        (result.exampleEn.isEmpty && result.exampleTr.isEmpty)) {
      return;
    }
    final exampleTr =
        result.exampleTr.isNotEmpty ? result.exampleTr : result.exampleEn;
    // Sadece Türkçe dilinde DB'deki örnek cümleyi kalıcı olarak güncelle.
    if (localeCode.toLowerCase() == 'tr') {
      await WordDatabaseService.updateProfessionalWordExampleByWord(
        word: card.word,
        example: result.exampleEn,
        exampleTranslation: exampleTr,
      );
    }
    final cards = _cards;
    if (cards == null || cards.isEmpty) return;
    final idx = _currentCardIndex.clamp(0, cards.length - 1);
    final c = cards[idx];
    if (c.word != card.word) return;
    if (!mounted) return;

    // Eğer kartta zaten bir örnek cümle varsa, sadece Türkçe dilinde
    // (uygulamanın ana dili) onu koruyalım. Diğer dillerde mevcut
    // Türkçe çeviriyi yeni dile göre güncelleyelim.
    final hasExistingExample =
        c.exampleEn.trim().isNotEmpty || c.exampleTr.trim().isNotEmpty;
    final isTurkishLocale = localeCode.toLowerCase() == 'tr';
    if (hasExistingExample && isTurkishLocale) return;

    setState(() {
      _cards = [
        ...cards.sublist(0, idx),
        WordCardData(
          word: c.word,
          phonetic: c.phonetic,
          translations: c.translations,
          exampleEn: result.exampleEn,
          exampleTr: exampleTr,
        ),
        ...cards.sublist(idx + 1),
      ];
    });
  }

  WordCardData? get _currentCard {
    final cards = _cards;
    if (cards == null || cards.isEmpty) return null;
    return cards[_currentCardIndex.clamp(0, cards.length - 1)];
  }

  void _revealHintForCurrentCard() {
    final card = _currentCard;
    if (card == null || !mounted) return;
    final key = '${card.word}|${context.locale.languageCode}';
    setState(() {
      if (_hintRevealed.contains(key)) {
        _hintRevealed.remove(key);
      } else {
        _hintRevealed.add(key);
      }
    });
  }

  void _onNavTap(int index) {
    context.go(AppPaths.home, extra: HomeRouteArgs(initialIndex: index));
  }

  static const double _headerExpandedHeight = 80;

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      final msg = _errorMessage!.startsWith('word_practice.')
          ? _errorMessage!.tr()
          : _errorMessage!;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                msg,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.lg),
              TextButton(
                onPressed: _loadWords,
                child: Text('word_practice.retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }
    final card = _currentCard;
    if (card == null) {
      return Center(
        child: Text(
          'word_practice.no_words'.tr(),
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium
              .copyWith(color: AppColors.onSurfaceVariant),
        ),
      );
    }
    if (card.translations.trim().isEmpty &&
        !_translationRequested.contains(card.word)) {
      _translationRequested.add(card.word);
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _fetchTranslationForCurrentCard());
    }
    if (card.phonetic.trim().isEmpty &&
        !_phoneticRequested.contains(card.word)) {
      _phoneticRequested.add(card.word);
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _fetchPhoneticForCurrentCard());
    }
    final exampleKey = '${card.word}|${context.locale.languageCode}';
    if (!_exampleRequested.contains(exampleKey)) {
      _exampleRequested.add(exampleKey);
      WidgetsBinding.instance.addPostFrameCallback(
          (_) => _fetchExampleForCurrentCard());
    }
    final hintKey = '${card.word}|${context.locale.languageCode}';
    final isHintRevealed = _hintRevealed.contains(hintKey);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WordCard3D(
          onSwipeLeft: _goPrevCard,
          onSwipeRight: _goNextCard,
          childKey: ValueKey<int>(_currentCardIndex),
          lastSwipeDirection: _lastSwipeDirection,
          child: WordCardBody(
            data: card,
            hideTranslationAndExamples: !isHintRevealed,
            onSaveWord: () async {
              final notifier = ref.read(savedWordsProvider.notifier);
              await notifier.add(SavedWordItem(
                word: card.word,
                phonetic: card.phonetic,
                translations: card.translations,
                exampleEn: card.exampleEn,
                exampleTr: card.exampleTr,
              ));
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('word_practice.saved'.tr()),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onListen: _speakCurrentWord,
            onHint: _revealHintForCurrentCard,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5FC),
      body: Stack(
        children: [
          SafeArea(
            top: false,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: _headerExpandedHeight,
                  pinned: false,
                  floating: false,
                  stretch: true,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  backgroundColor: const Color(0xFFF2F5FC),
                  surfaceTintColor: Colors.transparent,
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
                  titleSpacing: 4,
                  title: Text(
                    'home.mfut_title'.tr(),
                    style: AppTypography.titleLarge.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  centerTitle: false,
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl, 0, AppSpacing.xl, 120),
                    child: Center(child: _buildBody()),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNavBar(
              items: _navItems,
              currentIndex: 0,
              onTap: _onNavTap,
            ),
          ),
        ],
      ),
    );
  }
}

/// Word Practice ile aynı overlay — Swipe Finger tutorial. Tıklanınca kapanır.
class _TutorialFullScreenOverlay extends StatefulWidget {
  const _TutorialFullScreenOverlay({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<_TutorialFullScreenOverlay> createState() =>
      _TutorialFullScreenOverlayState();
}

class _TutorialFullScreenOverlayState extends State<_TutorialFullScreenOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _handController;
  late final Animation<double> _handAnimation;

  @override
  void initState() {
    super.initState();
    _handController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _handAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _handController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _handController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: widget.onDismiss,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/icon_tutorial_arrow_prev.svg',
                          width: 52,
                          height: 22,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'tutorial.previous'.tr(),
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    AnimatedBuilder(
                      animation: _handAnimation,
                      builder: (context, child) {
                        final t = _handAnimation.value;
                        final dx = t * 40;
                        final angle = t * (math.pi / 12);
                        return Transform.translate(
                          offset: Offset(dx, 0),
                          child: Transform.rotate(
                            angle: angle,
                            alignment: Alignment.center,
                            child: child,
                          ),
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/icons/icon_tutorial_hand.svg',
                        width: 72,
                        height: 78,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/icon_tutorial_arrow_next.svg',
                          width: 52,
                          height: 22,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'tutorial.next'.tr(),
                          style: AppTypography.caption.copyWith(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'tutorial.swipe_finger'.tr(),
                  style: AppTypography.title.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
