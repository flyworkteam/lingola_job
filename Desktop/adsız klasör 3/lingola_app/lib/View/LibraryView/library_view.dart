import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lingola_app/Models/saved_word_item.dart';
import 'package:lingola_app/Riverpod/Controllers/all_controllers.dart';
import 'package:lingola_app/Riverpod/Providers/all_providers.dart';
import 'package:lingola_app/Services/word_database_service.dart';
import 'package:lingola_app/Services/word_services.dart';
import 'package:lingola_app/src/theme/colors.dart';
import 'package:lingola_app/src/theme/radius.dart';
import 'package:lingola_app/src/theme/spacing.dart';
import 'package:lingola_app/src/theme/typography.dart';
import 'package:lingola_app/src/widgets/dismiss_keyboard.dart';

/// Library sayfası: header, arama + filtre butonu, Library / Dictionary sekmeleri.
/// Sekme, filtre ve favori durumu Riverpod [libraryControllerProvider] ile yönetilir.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({
    super.key,
    this.onBackTap,
    this.initialTabIndex,
    this.onInitialTabHandled,
  });

  final VoidCallback? onBackTap;
  /// Ana sayfadan Dictionary kartı ile geldiğinde açılacak sekme (1 = Dictionary).
  final int? initialTabIndex;
  final VoidCallback? onInitialTabHandled;

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  static const double _headerExpandedHeight = 200;

  List<Map<String, dynamic>>? _professionalWordsLoaded;
  bool _dictionaryLoading = true;
  FlutterTts? _flutterTts;
  bool _ttsInitialized = false;
  String? _lastLocaleCode;

  Future<void> _loadDictionaryWords() async {
    try {
      // Sözlük ve kütüphane çevirileri uygulamanın aktif diline göre gösterilsin.
      final localeCode = context.locale.languageCode.toLowerCase();
      final raw = await WordDatabaseService.getProfessionalWords();

      // Seçilen dile göre çeviri map'ini al (asset + cache)
      final translationMap =
          await WordService.getTranslationMapForLocale(localeCode);

      // Kelimeleri, seçilen dile göre çeviriyle zenginleştir
      final processed = raw
          .where((m) => ((m['word'] as String?) ?? '').trim().isNotEmpty)
          .map((m) {
        final word = ((m['word'] as String?) ?? '').trim();
        final key = word.toLowerCase();
        final translated = (translationMap[key] ?? '').trim();
        final existingTranslation =
            ((m['translation'] as String?) ?? '').trim();
        final updated = Map<String, dynamic>.from(m);

        // Üstte her zaman İngilizce kelime, altta seçili dil.
        if (localeCode == 'en') {
          updated['translation'] = word;
        } else if (localeCode == 'tr') {
          // Türkçe için eski veriyle geriye dönük uyumluluk: yoksa İngilizceye düş.
          updated['translation'] = translated.isNotEmpty
              ? translated
              : (existingTranslation.isNotEmpty ? existingTranslation : word);
        } else {
          // Diğer dillerde asla Türkçe'ye düşme; bulunamazsa İngilizce kelimeyi göster.
          updated['translation'] =
              translated.isNotEmpty ? translated : word;
        }
        return updated;
      }).toList();

      if (!mounted) return;
      setState(() {
        _professionalWordsLoaded = processed;
        _dictionaryLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        // Hata olsa bile sonsuz yüklemede kalmasın.
        _professionalWordsLoaded = const [];
        _dictionaryLoading = false;
      });
    }
  }

  bool _wordMatches(String left, String right) =>
      left.trim().toLowerCase() == right.trim().toLowerCase();

  Map<String, dynamic>? _dictionaryEntryForWord(String word) {
    final list = _professionalWordsLoaded;
    if (list == null) return null;
    for (final entry in list) {
      final candidate = (entry['word'] as String?)?.trim() ?? '';
      if (_wordMatches(candidate, word)) {
        return entry;
      }
    }
    return null;
  }

  String _categoryForWord(String word) {
    final entry = _dictionaryEntryForWord(word);
    final category = (entry?['category'] as String?)?.trim() ?? '';
    return category.isEmpty ? 'Other' : category;
  }

  bool _isSavedWord(List<SavedWordItem> items, String word) {
    return items.any((item) => _wordMatches(item.word, word));
  }

  Future<void> _toggleSavedWord(_DictionaryWordItem item) async {
    final notifier = ref.read(savedWordsProvider.notifier);
    final currentItems = ref.read(savedWordsProvider);
    final isSaved = _isSavedWord(currentItems, item.word);
    if (isSaved) {
      await notifier.remove(item.word);
      return;
    }

    await notifier.add(
      SavedWordItem(
        word: item.word,
        phonetic: item.phonetic,
        translations: item.translation,
        exampleEn: item.exampleEn,
        exampleTr: item.exampleTr,
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('word_practice.saved'.tr()),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _initTts() async {
    if (_ttsInitialized) return;
    _flutterTts ??= FlutterTts();
    await _flutterTts!.awaitSpeakCompletion(true);
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

  Future<void> _speakWord(String word) async {
    if (word.trim().isEmpty) return;
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
    await _flutterTts!.speak(word.trim());
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref
          .read(libraryControllerProvider.notifier)
          .setSearchQuery(_searchController.text);
    });
    // EasyLocalization context'i initState içinde tam hazır olmadığı için
    // ilk frame'den sonra locale'e göre sözlüğü yükle.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _lastLocaleCode = context.locale.languageCode.toLowerCase();
      _loadDictionaryWords();
    });
    if (widget.initialTabIndex != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(libraryControllerProvider.notifier)
              .setTab(widget.initialTabIndex!);
        }
        widget.onInitialTabHandled?.call();
      });
    }
  }

  @override
  void didUpdateWidget(LibraryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTabIndex != null &&
        widget.initialTabIndex != oldWidget.initialTabIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(libraryControllerProvider.notifier)
              .setTab(widget.initialTabIndex!);
        }
        widget.onInitialTabHandled?.call();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Uygulama dili değiştiğinde sözlüğü yeniden yükle.
    final currentLocaleCode = context.locale.languageCode.toLowerCase();
    if (_lastLocaleCode != null && _lastLocaleCode != currentLocaleCode) {
      _lastLocaleCode = currentLocaleCode;
      _dictionaryLoading = true;
      _professionalWordsLoaded = null;
      _loadDictionaryWords();
    }
  }

  @override
  void dispose() {
    _flutterTts?.stop();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(libraryControllerProvider);
    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5FC),
        body: SafeArea(
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
                flexibleSpace: FlexibleSpaceBar(
                  background: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(child: _buildSearchInput()),
                              const SizedBox(width: AppSpacing.sm),
                              _buildFilterButton(),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _buildTabButtons(),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                sliver: state.selectedTabIndex == 0
                    ? _buildLibrarySliverList(state)
                    : _buildDictionarySliverList(state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Profil sayfasındaki gibi: geri butonu + başlık.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onBackTap ?? () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(12),
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
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            context.tr('library.title'),
            style: AppTypography.titleLarge.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: context.tr('library.search_hint'),
          hintStyle: AppTypography.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: SvgPicture.asset(
              'assets/icons/icon_search_library.svg',
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                AppColors.onSurfaceVariant,
                BlendMode.srcIn,
              ),
              fit: BoxFit.contain,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: 14,
            bottom: 10,
          ),
        ),
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  /// Attığın Button.svg ile aynı stil: mavi yuvarlak köşe, filtre ikonu.
  Widget _buildFilterButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showFilterBottomSheet,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 52,
          height: 37,
          child: SvgPicture.asset(
            'assets/icons/icon_filter_button.svg',
            width: 52,
            height: 37,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final current = ref.read(libraryControllerProvider);
        return _LibraryFilterBottomSheet(
          initialSelectedIds: Set.from(current.selectedFilterIds),
          onSave: (selectedIds) {
            ref
                .read(libraryControllerProvider.notifier)
                .setFilters(selectedIds);
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  Widget _buildTabButtons() {
    final state = ref.watch(libraryControllerProvider);
    return Row(
      children: [
        Expanded(
          child: _buildTabButton(
            label: context.tr('library.library_tab'),
            isSelected: state.selectedTabIndex == 0,
            onTap: () =>
                ref.read(libraryControllerProvider.notifier).setTab(0),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildTabButton(
            label: context.tr('library.dictionary_tab'),
            isSelected: state.selectedTabIndex == 1,
            onTap: () =>
                ref.read(libraryControllerProvider.notifier).setTab(1),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryBrand
                : AppColors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryDropShadow.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.primaryBrand,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<_LibraryWordItem> _filteredWords(
    LibraryState state,
    List<SavedWordItem> savedWords,
  ) {
    var filtered = savedWords.map((item) {
      final entry = _dictionaryEntryForWord(item.word);
      return _LibraryWordItem(
        word: item.word,
        category: _categoryForWord(item.word),
        translation: item.translations.trim().isNotEmpty
            ? item.translations
            : (entry?['translation'] as String?)?.trim() ?? '',
        exampleEn: item.exampleEn.trim().isNotEmpty
            ? item.exampleEn
            : (entry?['example'] as String?)?.trim() ?? '',
        exampleTr: item.exampleTr.trim().isNotEmpty
            ? item.exampleTr
            : (entry?['example_translation'] as String?)?.trim() ?? '',
      );
    }).toList();

    if (state.selectedFilterIds.isNotEmpty) {
      filtered = filtered
          .where((item) => state.selectedFilterIds.contains(item.category))
          .toList();
    }

    final q = state.searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.word.toLowerCase().contains(q) ||
            item.translation.toLowerCase().contains(q) ||
            item.category.toLowerCase().contains(q);
      }).toList();
    }

    return filtered;
  }

  Widget _buildLibrarySliverList(LibraryState state) {
    if (_professionalWordsLoaded == null) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final savedWords = ref.watch(savedWordsProvider);
    final words = _filteredWords(state, savedWords);
    if (words.isEmpty) {
      final hasSavedWords = savedWords.isNotEmpty;
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              hasSavedWords
                  ? context.tr('library.no_results')
                  : context.tr('saved_word.empty_title'),
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall.copyWith(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildListDelegate([
        ...words.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _LibraryWordCard(
              item: item,
              isFavorited: _isSavedWord(savedWords, item.word),
              onListenTap: () => _speakWord(item.word),
              onStarTap: _isSavedWord(savedWords, item.word)
                  ? () {
                      ref.read(savedWordsProvider.notifier).remove(item.word);
                    }
                  : null,
            ),
        )),
        const SizedBox(height: 120),
      ]),
    );
  }

  List<_DictionaryWordItem> _filteredDictionaryWords(LibraryState state) {
    final list = _professionalWordsLoaded;
    if (list == null) return const [];
    var filtered = list;
    if (state.selectedFilterIds.isNotEmpty) {
      filtered = filtered
          .where((m) =>
              state.selectedFilterIds
                  .contains((m['category'] as String?)?.trim() ?? ''))
          .toList();
    }
    final q = state.searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((m) {
        final word = (m['word'] as String?) ?? '';
        final translation = (m['translation'] as String?) ?? '';
        return word.toLowerCase().contains(q) ||
            translation.toLowerCase().contains(q);
      }).toList();
    }
    return filtered
        .map((m) => _DictionaryWordItem(
              word: (m['word'] as String?)?.trim() ?? '',
              phonetic: (m['phonetic'] as String?)?.trim() ?? '',
              translation: (m['translation'] as String?)?.trim() ?? '',
              exampleEn: (m['example'] as String?)?.trim() ?? '',
              exampleTr: (m['example_translation'] as String?)?.trim() ?? '',
            ))
        .toList();
  }

  Widget _buildDictionarySliverList(LibraryState state) {
    if (_dictionaryLoading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final savedWords = ref.watch(savedWordsProvider);
    final words = _filteredDictionaryWords(state);
    return SliverList(
      delegate: SliverChildListDelegate([
        ...words.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _DictionaryWordCard(
            item: item,
            isFavorited: _isSavedWord(savedWords, item.word),
            onListenTap: () => _speakWord(item.word),
            onStarTap: () async {
              await _toggleSavedWord(item);
            },
          ),
        )),
        const SizedBox(height: 120),
      ]),
    );
  }
}

class _DictionaryWordItem {
  const _DictionaryWordItem({
    required this.word,
    required this.phonetic,
    required this.translation,
    this.exampleEn = '',
    this.exampleTr = '',
  });
  final String word;
  final String phonetic;
  final String translation;
  final String exampleEn;
  final String exampleTr;
}

const Map<String, String> _libraryCategoryTranslationKeys = {
  'Academic': 'library.filter_academic',
  'Psychology': 'library.filter_psychology',
  'Business': 'library.filter_business',
  'Finance': 'library.filter_finance',
  'Technology': 'library.filter_technology',
  'Marketing': 'library.filter_marketing',
  'Engineering': 'library.filter_engineering',
  'Medicine': 'library.filter_medicine',
  'Legal': 'library.filter_legal',
  'Other': 'library.other',
};

String _localizedLibraryCategory(BuildContext context, String category) {
  final key = _libraryCategoryTranslationKeys[category];
  if (key == null) return category;
  return context.tr(key);
}

class _LibraryWordItem {
  const _LibraryWordItem({
    required this.word,
    required this.category,
    required this.translation,
    this.exampleEn = '',
    this.exampleTr = '',
  });
  final String word;
  final String category;
  final String translation;
  final String exampleEn;
  final String exampleTr;
}

/// Beyaz kart: kelime, kategori etiketi, çeviri, ses ve yıldız ikonu.
class _LibraryWordCard extends StatelessWidget {
  const _LibraryWordCard({
    required this.item,
    this.isFavorited = false,
    this.onListenTap,
    this.onStarTap,
  });

  final _LibraryWordItem item;
  final bool isFavorited;
  final VoidCallback? onListenTap;
  final VoidCallback? onStarTap;

  @override
  Widget build(BuildContext context) {
    final starWidget = Transform.translate(
      offset: const Offset(0, -4),
      child: SvgPicture.asset(
        'assets/icons/yıldız.svg',
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(
          AppColors.primaryBrand,
          BlendMode.srcIn,
        ),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Text(
                      item.word,
                      style: AppTypography.title.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0575E6).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _localizedLibraryCategory(context, item.category),
                        style: AppTypography.label.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.translation,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (item.exampleEn.trim().isNotEmpty ||
                    item.exampleTr.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  if (item.exampleEn.trim().isNotEmpty)
                    Text(
                      '"${item.exampleEn.trim()}"',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  if (item.exampleTr.trim().isNotEmpty) ...[
                    if (item.exampleEn.trim().isNotEmpty)
                      const SizedBox(height: 4),
                    Text(
                      item.exampleTr.trim(),
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant
                            .withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onListenTap,
                icon: SvgPicture.asset(
                  'assets/icons/ses.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF9B9B9B),
                    BlendMode.srcIn,
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              if (onStarTap != null)
                GestureDetector(
                  onTap: onStarTap,
                  behavior: HitTestBehavior.opaque,
                  child: starWidget,
                )
              else
                starWidget,
            ],
          ),
        ],
      ),
    );
  }
}

/// Dictionary kelime kartı: kelime, çeviri, örnek cümle, ses ve yıldız ikonu.
class _DictionaryWordCard extends StatelessWidget {
  const _DictionaryWordCard({
    required this.item,
    required this.isFavorited,
    required this.onListenTap,
    required this.onStarTap,
  });

  final _DictionaryWordItem item;
  final bool isFavorited;
  final VoidCallback onListenTap;
  final VoidCallback onStarTap;

  @override
  Widget build(BuildContext context) {
    final hasExample =
        item.exampleEn.trim().isNotEmpty || item.exampleTr.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.word,
                  style: AppTypography.title.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.translation,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (hasExample) ...[
                  const SizedBox(height: 10),
                  if (item.exampleEn.trim().isNotEmpty)
                    Text(
                      '"${item.exampleEn.trim()}"',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  if (item.exampleTr.trim().isNotEmpty) ...[
                    if (item.exampleEn.trim().isNotEmpty)
                      const SizedBox(height: 4),
                    Text(
                      item.exampleTr.trim(),
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant
                            .withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onListenTap,
                icon: SvgPicture.asset(
                  'assets/icons/ses.svg',
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFF9B9B9B),
                    BlendMode.srcIn,
                  ),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
              GestureDetector(
                onTap: onStarTap,
                behavior: HitTestBehavior.opaque,
                child: Transform.translate(
                    offset: const Offset(0, -4),
                    child: SvgPicture.asset(
                      'assets/icons/yıldız.svg',
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isFavorited ? AppColors.primaryBrand : const Color(0xFFD9D9D9),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Filtre bottom sheet: üstte tutacak çizgi, pill etiketler, Save butonu.
class _LibraryFilterBottomSheet extends StatefulWidget {
  const _LibraryFilterBottomSheet({
    required this.initialSelectedIds,
    required this.onSave,
  });

  final Set<String> initialSelectedIds;
  final void Function(Set<String> selectedIds) onSave;

  @override
  State<_LibraryFilterBottomSheet> createState() => _LibraryFilterBottomSheetState();
}

class _LibraryFilterBottomSheetState extends State<_LibraryFilterBottomSheet> {
  static const List<String> _filterCategories = [
    'Academic',
    'Psychology',
    'Business',
    'Finance',
    'Technology',
    'Marketing',
    'Engineering',
    'Medicine',
    'Legal',
  ];

  static const Map<String, String> _filterCategoryKeys = {
    'Academic': 'library.filter_academic',
    'Psychology': 'library.filter_psychology',
    'Business': 'library.filter_business',
    'Finance': 'library.filter_finance',
    'Technology': 'library.filter_technology',
    'Marketing': 'library.filter_marketing',
    'Engineering': 'library.filter_engineering',
    'Medicine': 'library.filter_medicine',
    'Legal': 'library.filter_legal',
  };

  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.md, AppSpacing.xl, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Üstte tutacak çizgi (grab handle)
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Pill etiketler
              Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: _filterCategories.map((category) {
                  final isSelected = _selectedIds.contains(category);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        final next = Set<String>.from(_selectedIds);
                        if (isSelected) {
                          next.remove(category);
                        } else {
                          next.add(category);
                        }
                        _selectedIds = next;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBrand : AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryBrand
                              : AppColors.outline.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        context.tr(_filterCategoryKeys[category] ?? category),
                        style: AppTypography.labelLarge.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Save butonu
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => widget.onSave(_selectedIds),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryBrand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.tr('common.save'),
                    style: AppTypography.labelLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

