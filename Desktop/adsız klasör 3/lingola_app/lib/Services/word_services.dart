import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

/// Kelime paketi (`words.json`) asset'ten yükler.
/// Seviye ataması: sıralı indekse göre A1 -> C2.
/// Çeviri: her dil için `word_translations_<lang>.json`
/// (`tr`, `en`, `de`, `fr`, `es`, `it`, `pt`, `ru`, `ja`, `ko`, `hi`) ve disk cache kullanır.
class WordService {
  WordService._();

  static const String _assetPath = 'assets/words.json';
  static const String _phoneticsPath = 'assets/word_phonetics.json';
  static const String _examplesPath = 'assets/word_examples.json';
  static const String _cacheFileName = 'translation_cache.json';
  static const String _phoneticCacheFileName = 'phonetic_cache.json';
  static const String _exampleCacheFileName = 'example_cache.json';
  static const String _sentenceTranslationCacheFileName = 'sentence_translation_cache.json';

  static Map<String, String>? _translationCache;
  static Map<String, String>? _phoneticsMap;
  static Map<String, String>? _phoneticCache;
  static Map<String, String>? _exampleCache;
  static Map<String, String>? _sentenceTranslationCache;

  /// Disk üzerindeki çeviri cache'ini yükler (API'dan alınan çeviriler).
  static Future<Map<String, String>> _loadTranslationCache() async {
    if (_translationCache != null) return _translationCache!;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_cacheFileName');
      if (!await file.exists()) return _translationCache = {};
      final jsonString = await file.readAsString();
      final map = jsonDecode(jsonString) as Map<String, dynamic>?;
      if (map == null || map.isEmpty) return _translationCache = {};
      _translationCache = map.map((k, v) =>
          MapEntry(k.toString().trim().toLowerCase(), v?.toString() ?? ''));
      return _translationCache!;
    } catch (_) {
      _translationCache = {};
      return _translationCache!;
    }
  }

  /// Tüm çeviri kaynaklarını birleştirir: asset sözlük ve disk cache
  /// (locale yok, geriye dönük uyumluluk).
  static Future<Map<String, String>> _getFullTranslationMap() async {
    return _getFullTranslationMapForLocale('tr');
  }

  /// Verilen dil için çeviri map'i: `word_translations_<lang>.json`
  /// ve o dildeki disk cache (`word|lang` anahtarı).
  static Future<Map<String, String>> _getFullTranslationMapForLocale(String lang) async {
    final localeMap = await _loadTranslationMapForLocale(lang);
    final cache = await _loadTranslationCache();
    final suffix = '|${lang.toLowerCase()}';
    final cacheForLang = <String, String>{};
    for (final e in cache.entries) {
      if (e.key.endsWith(suffix)) {
        final wordKey = e.key.substring(0, e.key.length - suffix.length);
        if (wordKey.isNotEmpty) cacheForLang[wordKey] = e.value;
      }
    }
    return {...localeMap, ...cacheForLang};
  }

  /// word_phonetics.json (kelime -> IPA okunuşu) yükler.
  static Future<Map<String, String>> _loadPhoneticsMap() async {
    if (_phoneticsMap != null) return _phoneticsMap!;
    try {
      final jsonString = await rootBundle.loadString(_phoneticsPath);
      final map = jsonDecode(jsonString) as Map<String, dynamic>?;
      if (map == null || map.isEmpty) return _phoneticsMap = {};
      _phoneticsMap = map.map((k, v) =>
          MapEntry(k.toString().trim().toLowerCase(), v?.toString() ?? ''));
      return _phoneticsMap!;
    } catch (_) {
      _phoneticsMap = {};
      return _phoneticsMap!;
    }
  }

  /// Disk üzerindeki okunuş cache'ini yükler (API'dan alınan okunuşlar).
  static Future<Map<String, String>> _loadPhoneticCache() async {
    if (_phoneticCache != null) return _phoneticCache!;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_phoneticCacheFileName');
      if (!await file.exists()) return _phoneticCache = {};
      final jsonString = await file.readAsString();
      final map = jsonDecode(jsonString) as Map<String, dynamic>?;
      if (map == null || map.isEmpty) return _phoneticCache = {};
      _phoneticCache = map.map((k, v) =>
          MapEntry(k.toString().trim().toLowerCase(), v?.toString() ?? ''));
      return _phoneticCache!;
    } catch (_) {
      _phoneticCache = {};
      return _phoneticCache!;
    }
  }

  static Future<void> _savePhoneticCache() async {
    final cache = _phoneticCache;
    if (cache == null || cache.isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_phoneticCacheFileName');
      await file.writeAsString(jsonEncode(cache));
    } catch (_) {}
  }

  static Future<Map<String, String>> _loadExampleCache() async {
    if (_exampleCache != null) return _exampleCache!;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_exampleCacheFileName');
      if (!await file.exists()) return _exampleCache = {};
      final jsonString = await file.readAsString();
      final map = jsonDecode(jsonString) as Map<String, dynamic>?;
      if (map == null || map.isEmpty) return _exampleCache = {};
      _exampleCache = map.map((k, v) =>
          MapEntry(k.toString().trim().toLowerCase(), v?.toString() ?? ''));
      return _exampleCache!;
    } catch (_) {
      _exampleCache = {};
      return _exampleCache!;
    }
  }

  static Future<void> _saveExampleCache() async {
    final cache = _exampleCache;
    if (cache == null || cache.isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_exampleCacheFileName');
      await file.writeAsString(jsonEncode(cache));
    } catch (_) {}
  }

  static Future<Map<String, String>> _loadSentenceTranslationCache() async {
    if (_sentenceTranslationCache != null) return _sentenceTranslationCache!;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_sentenceTranslationCacheFileName');
      if (!await file.exists()) return _sentenceTranslationCache = {};
      final jsonString = await file.readAsString();
      final map = jsonDecode(jsonString) as Map<String, dynamic>?;
      if (map == null || map.isEmpty) return _sentenceTranslationCache = {};
      _sentenceTranslationCache = map.map((k, v) =>
          MapEntry(k.toString(), v?.toString() ?? ''));
      return _sentenceTranslationCache!;
    } catch (_) {
      _sentenceTranslationCache = {};
      return _sentenceTranslationCache!;
    }
  }

  static Future<void> _saveSentenceTranslationCache() async {
    final cache = _sentenceTranslationCache;
    if (cache == null || cache.isEmpty) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_sentenceTranslationCacheFileName');
      await file.writeAsString(jsonEncode(cache));
    } catch (_) {}
  }

  /// Dictionary API yanıtından ilk örnek cümleyi çıkarır.
  static String? _extractFirstExample(Map<String, dynamic>? entry) {
    final meanings = entry?['meanings'] as List<dynamic>?;
    if (meanings == null) return null;
    for (final m in meanings) {
      final defs = (m as Map<String, dynamic>?)?['definitions'] as List<dynamic>?;
      if (defs == null) continue;
      for (final d in defs) {
        final ex = (d as Map<String, dynamic>?)?['example']?.toString().trim();
        if (ex != null && ex.isNotEmpty) return ex;
      }
    }
    return null;
  }

  static const String _dictionaryApiBase = 'https://api.dictionaryapi.dev/api/v2/entries/en';

  /// Free Dictionary API'den kelime bilgisi çeker (okunuş + örnek cümle). Ağ hatasında null döner.
  static Future<({String? phonetic, String? exampleEn})> _fetchFromDictionaryApi(String word) async {
    final w = word.trim();
    if (w.isEmpty) return (phonetic: null, exampleEn: null);
    try {
      final uri = Uri.parse('$_dictionaryApiBase/${Uri.encodeComponent(w)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return (phonetic: null, exampleEn: null);
      final list = jsonDecode(response.body) as List<dynamic>?;
      if (list == null || list.isEmpty) return (phonetic: null, exampleEn: null);
      final entry = list.first as Map<String, dynamic>?;
      if (entry == null) return (phonetic: null, exampleEn: null);
      String? phonetic = entry['phonetic']?.toString().trim();
      if (phonetic == null || phonetic.isEmpty) {
        final phonetics = entry['phonetics'] as List<dynamic>?;
        if (phonetics != null && phonetics.isNotEmpty) {
          final first = phonetics.first as Map<String, dynamic>?;
          phonetic = first?['text']?.toString().trim();
        }
      }
      final exampleEn = _extractFirstExample(entry);
      return (phonetic: phonetic, exampleEn: exampleEn);
    } catch (_) {
      return (phonetic: null, exampleEn: null);
    }
  }

  static const String _myMemoryBase = 'https://api.mymemory.translated.net/get';

  /// MyMemory API ile metni hedef dile çevirir (en -> tr). Ağ hatasında boş döner.
  static Future<String> _fetchTranslationViaApi(String text, String targetLang) async {
    final t = text.trim();
    if (t.isEmpty) return '';
    final lang = targetLang.toLowerCase();
    if (lang == 'en') return t;
    try {
      final uri = Uri.parse('$_myMemoryBase?q=${Uri.encodeComponent(t)}&langpair=en|$lang');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return '';
      final map = jsonDecode(response.body) as Map<String, dynamic>?;
      final responseData = map?['responseData'] as Map<String, dynamic>?;
      final translated = responseData?['translatedText']?.toString().trim();
      return translated ?? '';
    } catch (_) {
      return '';
    }
  }

  /// Tüm okunuş kaynaklarını birleştirir: word_phonetics.json + disk cache.
  static Future<Map<String, String>> _getFullPhoneticsMap() async {
    final staticMap = await _loadPhoneticsMap();
    final cacheMap = await _loadPhoneticCache();
    return {...staticMap, ...cacheMap};
  }

  static String _replaceAllFromMap(String input, Map<String, String> replacements) {
    var output = input;
    for (final entry in replacements.entries) {
      output = output.replaceAll(entry.key, entry.value);
    }
    return output;
  }

  static String _applyLocalePhoneticStyle(String input, String localeCode) {
    switch (localeCode.toLowerCase()) {
      case 'tr':
        return _replaceAllFromMap(input, const {
          'jh': 'c',
          'sh': 'ş',
          'zh': 'j',
          'ch': 'ç',
          'dh': 'd',
          'th': 't',
          'y': 'y',
          'w': 'v',
        });
      case 'de':
        return _replaceAllFromMap(input, const {
          'jh': 'dsch',
          'sh': 'sch',
          'zh': 'j',
          'ch': 'tsch',
          'dh': 'd',
          'th': 't',
          'y': 'j',
          'w': 'w',
        });
      case 'fr':
        return _replaceAllFromMap(input, const {
          'jh': 'dj',
          'sh': 'ch',
          'zh': 'j',
          'ch': 'tch',
          'dh': 'd',
          'th': 't',
          'y': 'y',
          'w': 'ou',
        });
      case 'es':
        return _replaceAllFromMap(input, const {
          'jh': 'y',
          'sh': 'sh',
          'zh': 'y',
          'ch': 'ch',
          'dh': 'd',
          'th': 't',
          'y': 'y',
          'w': 'u',
        });
      case 'it':
        return _replaceAllFromMap(input, const {
          'jh': 'g',
          'sh': 'sc',
          'zh': 'gi',
          'ch': 'c',
          'dh': 'd',
          'th': 't',
          'y': 'i',
          'w': 'u',
        });
      case 'pt':
        return _replaceAllFromMap(input, const {
          'jh': 'dj',
          'sh': 'x',
          'zh': 'j',
          'ch': 'tch',
          'dh': 'd',
          'th': 't',
          'y': 'i',
          'w': 'u',
        });
      default:
        return _replaceAllFromMap(input, const {
          'jh': 'j',
          'sh': 'sh',
          'zh': 'zh',
          'ch': 'ch',
          'dh': 'd',
          'th': 'th',
          'y': 'y',
          'w': 'w',
        });
    }
  }

  /// IPA metnini seçili dile göre sade bir okunuşa çevirir.
  static String ipaToPlain(
    String s, {
    String localeCode = 'tr',
  }) {
    if (s.isEmpty) return s;
    final normalized = s
        .toLowerCase()
        .replaceAll('/', '')
        .replaceAll('tʃ', 'ch')
        .replaceAll('dʒ', 'jh')
        .replaceAll('eɪ', 'ey')
        .replaceAll('aɪ', 'ay')
        .replaceAll('ɔɪ', 'oy')
        .replaceAll('aʊ', 'av')
        .replaceAll('oʊ', 'ou')
        .replaceAll('əʊ', 'ou')
        .replaceAll('juː', 'yu')
        .replaceAll('iː', 'ii')
        .replaceAll('uː', 'uu')
        .replaceAll('ɑː', 'aa')
        .replaceAll('ɔː', 'oo')
        .replaceAll('ɜː', 'ör')
        .replaceAll('ɚ', 'ır')
        .replaceAll('ɝ', 'ır')
        .replaceAll('ər', 'ır')
        .replaceAll('ð', 'dh')
        .replaceAll('θ', 'th')
        .replaceAll('æ', 'a')
        .replaceAll('ə', 'e')
        .replaceAll('ɛ', 'e')
        .replaceAll('ɜ', 'ö')
        .replaceAll('ɹ', 'r')
        .replaceAll('ʃ', 'sh')
        .replaceAll('ʒ', 'zh')
        .replaceAll('ŋ', 'ng')
        .replaceAll('ɡ', 'g')
        .replaceAll('g', 'g')
        .replaceAll('ɔ', 'o')
        .replaceAll('ɑ', 'a')
        .replaceAll('ɪ', 'i')
        .replaceAll('i', 'i')
        .replaceAll('ʊ', 'u')
        .replaceAll('ʌ', 'a')
        .replaceAll('ɒ', 'o')
        .replaceAll('ɫ', 'l')
        .replaceAll('ɾ', 'r')
        .replaceAll('j', 'y')
        .replaceAll('w', 'w')
        .replaceAll('ʔ', '')
        .replaceAll('ʰ', 'h')
        .replaceAll('ː', '')
        .replaceAll('ˈ', '')
        .replaceAll('ˌ', '')
        .replaceAll('́', '')
        .replaceAll('̃', '')
        .replaceAll('̈', '')
        .replaceAll('.', '')
        .replaceAll(' ', '');

    final localized = _applyLocalePhoneticStyle(normalized, localeCode);

    return localized
        .replaceAll(RegExp(r'[^a-zçğıöşü]'), '')
        .trim();
  }

  /// Okunuşu önce yerel kaynaklardan (word_phonetics.json + disk cache) döner; yoksa Free Dictionary API ile çekip cache'ler.
  /// Dönen değer ham fonetik metindir; ekranda [ipaToPlain] ile locale'e göre gösterilir.
  static Future<String> fetchAndCachePhonetic(String word) async {
    final w = word.trim();
    if (w.isEmpty) return '';
    final key = w.toLowerCase();
    final full = await _getFullPhoneticsMap();
    var text = full[key];
    if (text != null && text.isNotEmpty) return text;
    try {
      final api = await _fetchFromDictionaryApi(w);
      if (api.phonetic != null && api.phonetic!.isNotEmpty) {
        _phoneticCache ??= await _loadPhoneticCache();
        _phoneticCache![key] = api.phonetic!;
        await _savePhoneticCache();
        return api.phonetic!;
      }
    } catch (_) {}
    return '';
  }

  /// Örnek cümleyi yalnızca yerel cache'den döner. İnternet çağrısı yok.
  static Future<String> fetchAndCacheExample(String word) async {
    final w = word.trim();
    if (w.isEmpty) return '';
    final key = w.toLowerCase();
    final existing = _exampleCache?[key] ?? (await _loadExampleCache())[key];
    return existing ?? '';
  }

  static Future<String> _fetchAndCacheDictionaryExample(String word) async {
    final w = word.trim();
    if (w.isEmpty) return '';
    final key = w.toLowerCase();
    _exampleCache ??= await _loadExampleCache();
    final cached = _exampleCache![key]?.trim() ?? '';
    if (cached.isNotEmpty) return cached;

    final api = await _fetchFromDictionaryApi(w);
    final example = api.exampleEn?.trim() ?? '';
    if (example.isEmpty) return '';

    _exampleCache![key] = example;
    await _saveExampleCache();
    return example;
  }

  /// Cümle çevirisini yalnızca yerel cache'den döner. İnternet çağrısı yok.
  static Future<String> translateSentence(String sentence, String targetLangCode) async {
    final s = sentence.trim();
    if (s.isEmpty) return '';
    if (targetLangCode.toLowerCase() == 'en') return s;
    final cacheKey = '$s|${targetLangCode.toLowerCase()}';
    final existing = _sentenceTranslationCache?[cacheKey] ??
        (await _loadSentenceTranslationCache())[cacheKey];
    return existing ?? '';
  }

  /// Örnek cümleyi seçili dile çevirir: önce cache, yoksa MyMemory API ile çekip cache'ler.
  static Future<String> translateAndCacheSentence(String sentence, String targetLangCode) async {
    final s = sentence.trim();
    if (s.isEmpty) return '';
    final lang = targetLangCode.toLowerCase();
    if (lang == 'en') return s;
    final cacheKey = '$s|$lang';
    _sentenceTranslationCache ??= await _loadSentenceTranslationCache();
    final cached = _sentenceTranslationCache![cacheKey];
    if (cached != null && cached.isNotEmpty) return cached;
    final translated = await _fetchTranslationViaApi(s, lang);
    if (translated.isNotEmpty) {
      _sentenceTranslationCache![cacheKey] = translated;
      await _saveSentenceTranslationCache();
    }
    return translated.isEmpty ? s : translated;
  }

  /// Verilen dil için tam çeviri map'ini döner (asset + cache). Diğer servisler için public.
  static Future<Map<String, String>> getTranslationMapForLocale(String lang) =>
      _getFullTranslationMapForLocale(lang.toLowerCase());

  /// 11 dil için yerel çeviri asset'ini yükler
  /// (`assets/word_translations_<lang>.json`).
  /// en için boş map (kelime aynen gösterilir). Dosya yoksa boş map döner.
  static Future<Map<String, String>> _loadTranslationMapForLocale(String lang) async {
    if (lang == 'en') return {};
    try {
      final path = 'assets/word_translations_$lang.json';
      final jsonString = await rootBundle.loadString(path);
      final map = jsonDecode(jsonString) as Map<String, dynamic>?;
      if (map == null || map.isEmpty) return {};
      return map.map((k, v) =>
          MapEntry(k.toString().trim().toLowerCase(), v?.toString() ?? ''));
    } catch (_) {
      return {};
    }
  }

  /// Çeviriyi yalnızca yerel kaynaklardan döner
  /// (`word_translations.json` ve disk cache). İnternet çağrısı yok.
  static Future<String> fetchAndCacheTranslation(String word) async {
    final w = word.trim();
    if (w.isEmpty) return '';
    final key = w.toLowerCase();
    final full = await _getFullTranslationMap();
    final result = full[key]?.trim() ?? '';
    return result.isNotEmpty ? result : w;
  }

  /// Seçilen uygulama diline göre çeviriyi döner: sadece o dildeki asset
  /// (`word_translations_<lang>.json`) ve cache kullanılır.
  /// Yoksa İngilizce kelimenin kendisi döner (çeviri yok demek).
  static Future<String> fetchAndCacheTranslationForLocale(
    String word,
    String localeCode,
  ) async {
    final w = word.trim();
    if (w.isEmpty) return '';
    final lang = localeCode.toLowerCase();
    final key = w.toLowerCase();

    if (lang == 'en') return w;

    final fullMap = await _getFullTranslationMapForLocale(lang);
    final result = fullMap[key]?.trim() ?? '';
    return result.isNotEmpty ? result : w;
  }

  /// `word_examples.json` dosyasını yükler
  /// (kelime -> `en`, `tr`, `de`, ...). Her çağrıda asset'ten okur.
  static Future<Map<String, Map<String, String>>> _loadExamplesMap() async {
    try {
      final jsonString = await rootBundle.loadString(_examplesPath);
      final map = jsonDecode(jsonString) as Map<String, dynamic>?;
      if (map == null || map.isEmpty) return {};
      final result = <String, Map<String, String>>{};
      for (final e in map.entries) {
        final key = e.key.toString().trim().toLowerCase();
        final val = e.value;
        if (val is! Map<String, dynamic>) continue;
        final langMap = <String, String>{};
        for (final le in val.entries) {
          final lang = le.key.toString().toLowerCase();
          final text = le.value?.toString().trim() ?? '';
          if (text.isNotEmpty) langMap[lang] = text;
        }
        if (langMap.isNotEmpty) result[key] = langMap;
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  /// Yerel örnek yoksa kullanılan, kelime öğrenmeye daha uygun fallback şablonları.
  static const List<(String, String)> _fallbackExampleTemplates = [
    (
      r'I learned the word {w_en} today.',
      r'Bugün {w_local} kelimesini öğrendim.',
    ),
    (
      r'My teacher explained the word {w_en}.',
      r'Öğretmenim {w_local} kelimesini açıkladı.',
    ),
    (
      r'I wrote {w_en} in my notebook.',
      r'{w_local} kelimesini defterime yazdım.',
    ),
    (
      r'This lesson includes the word {w_en}.',
      r'Bu derste {w_local} kelimesi geçiyor.',
    ),
    (
      r'I want to practice the word {w_en} again.',
      r'{w_local} kelimesini tekrar çalışmak istiyorum.',
    ),
    (
      r'Please use {w_en} in a sentence.',
      r'Lütfen {w_local} kelimesini bir cümlede kullan.',
    ),
    (
      r'I can remember the word {w_en} now.',
      r'Artık {w_local} kelimesini hatırlayabiliyorum.',
    ),
    (
      r'The meaning of {w_en} is easy to remember.',
      r'{w_local} kelimesinin anlamını hatırlamak kolaydır.',
    ),
  ];

  static String _replaceWordInLocalizedSentence({
    required String sentence,
    required String sourceWord,
    required String localizedWord,
  }) {
    final baseSentence = sentence.trim();
    final englishWord = sourceWord.trim();
    final translatedWord = localizedWord.trim();
    if (baseSentence.isEmpty ||
        englishWord.isEmpty ||
        translatedWord.isEmpty ||
        englishWord.toLowerCase() == translatedWord.toLowerCase()) {
      return baseSentence;
    }
    final pattern = RegExp(
      '\\b${RegExp.escape(englishWord)}\\b',
      caseSensitive: false,
    );
    return baseSentence.replaceAll(pattern, translatedWord);
  }

  /// Kelime için örnek cümle. word_examples.json'da seçili dil yoksa cümle API ile çevrilir ve cache'lenir.
  static Future<({String exampleEn, String exampleTr})> getExampleForWord(
    String word,
    String localeCode,
  ) async {
    final w = word.trim();
    if (w.isEmpty) return (exampleEn: '', exampleTr: '');
    final key = w.toLowerCase();
    final lang = localeCode.toLowerCase();
    final localizedWord = await fetchAndCacheTranslationForLocale(w, lang);
    final map = await _loadExamplesMap();
    final entry = map[key];
    String exampleEn;
    String exampleTr;
    if (entry != null && entry.isNotEmpty) {
      exampleEn = entry['en'] ?? entry.values.first;
      if (lang == 'en') {
        exampleTr = exampleEn;
      } else if (entry[lang] != null && entry[lang]!.isNotEmpty) {
        exampleTr = entry[lang]!;
      } else {
        // word_examples.json'da bu dil yok; İngilizce cümleyi seçili dile çevir (API + cache).
        exampleTr = await translateAndCacheSentence(exampleEn, lang);
        if (exampleTr.isEmpty) exampleTr = exampleEn;
      }
      exampleTr = _replaceWordInLocalizedSentence(
        sentence: exampleTr,
        sourceWord: w,
        localizedWord: localizedWord,
      );
      return (exampleEn: exampleEn, exampleTr: exampleTr);
    }

    final apiExample = await _fetchAndCacheDictionaryExample(w);
    if (apiExample.isNotEmpty) {
      exampleEn = apiExample;
      if (lang == 'en') {
        exampleTr = exampleEn;
      } else {
        exampleTr = await translateAndCacheSentence(exampleEn, lang);
        if (exampleTr.isEmpty) exampleTr = exampleEn;
      }
      exampleTr = _replaceWordInLocalizedSentence(
        sentence: exampleTr,
        sourceWord: w,
        localizedWord: localizedWord,
      );
      return (exampleEn: exampleEn, exampleTr: exampleTr);
    }

    final idx = key.hashCode.abs() % _fallbackExampleTemplates.length;
    final t = _fallbackExampleTemplates[idx];
    final localizedFallbackWord = localizedWord.trim().isEmpty ? w : localizedWord;
    final en = t.$1.replaceAll('{w_en}', w);
    if (lang == 'tr') {
      final tr = t.$2.replaceAll('{w_local}', localizedFallbackWord);
      return (exampleEn: en, exampleTr: tr);
    }
    if (lang == 'en') {
      return (exampleEn: en, exampleTr: en);
    }
    // Diğer diller: İngilizce cümleyi API ile çevir.
    exampleTr = await translateAndCacheSentence(en, lang);
    if (exampleTr.isEmpty) exampleTr = en;
    exampleTr = _replaceWordInLocalizedSentence(
      sentence: exampleTr,
      sourceWord: w,
      localizedWord: localizedFallbackWord,
    );
    return (exampleEn: en, exampleTr: exampleTr);
  }

  /// Önce [assets/words.json], yoksa [assets/words/words.json] dener.
  /// Çeviri: word_translations.json + disk cache ile doldurulur.
  static Future<List<Map<String, dynamic>>> loadWordsFromAsset() async {
    String jsonString;
    try {
      jsonString = await rootBundle.loadString(_assetPath);
    } catch (_) {
      jsonString = await rootBundle.loadString('assets/words/words.json');
    }
    final list = jsonDecode(jsonString) as List<dynamic>?;
    if (list == null || list.isEmpty) return [];

    // Not: Burada artık yalnızca asset içindeki ham veriyi kullanıyoruz.
    // Çeviriler seçili dile göre daha sonra [enrichWordsWithTranslations] ile doldurulacak.
    final phoneticsMap = await _getFullPhoneticsMap();

    final levels = ['a1', 'a2', 'b1', 'b2', 'c1', 'c2'];
    const a1End = 2000;
    const a2End = 5000;
    const b1End = 10000;
    const b2End = 20000;
    const c1End = 50000;

    String levelForIndex(int i) {
      if (i < a1End) return levels[0];
      if (i < a2End) return levels[1];
      if (i < b1End) return levels[2];
      if (i < b2End) return levels[3];
      if (i < c1End) return levels[4];
      return levels[5];
    }

    final result = <Map<String, dynamic>>[];
    for (var i = 0; i < list.length; i++) {
      final item = list[i];
      final map = item is Map<String, dynamic>
          ? Map<String, dynamic>.from(item)
          : <String, dynamic>{};
      final word = map['word']?.toString().trim() ?? '';
      if (word.isEmpty) continue;
      // Asset'te varsa çeviri aynen alınır, yoksa boş bırakılır.
      // Böylece kartlar seçilen dile göre sonradan doldurulur.
      final translation = map['translation']?.toString().trim() ?? '';
      final rawPhonetic = map['phonetic']?.toString().trim() ?? '';
      final phonetic = rawPhonetic.isNotEmpty
          ? rawPhonetic
          : (phoneticsMap[word.toLowerCase()] ?? '');
      result.add({
        'id': i + 1,
        'learning_track_id': 0,
        'word': word,
        'translation': translation,
        'phonetic': phonetic,
        'level': levelForIndex(i),
        'sort_order': i,
      });
    }
    return result;
  }

  /// Verilen kelime listesinde çeviri, okunuş ve örnek cümle boş olanları sözlükten doldurur.
  /// Çeviri seçilen dildeki `word_translations_<locale>.json` dosyasından doldurulur.
  static Future<List<Map<String, dynamic>>> enrichWordsWithTranslations(
    List<Map<String, dynamic>> words, {
    String? localeCode,
  }) async {
    if (words.isEmpty) return words;
    final lang = (localeCode ?? 'tr').toLowerCase();
    final translationMap = await _getFullTranslationMapForLocale(lang);
    final phoneticsMap = await _getFullPhoneticsMap();
    final examplesMap = await _loadExamplesMap();
    return words.map((e) {
      final word = e['word']?.toString().trim() ?? '';
      final key = word.toLowerCase();
      final out = Map<String, dynamic>.from(e);
      // Kartta çeviri her zaman seçili dilde gösterilsin (üstte İngilizce, altta seçili dil).
      if (word.isNotEmpty) {
        final translated = lang == 'en' ? word : (translationMap[key] ?? '');
        out['translation'] = translated.trim().isEmpty ? word : translated;
      }
      if ((e['phonetic']?.toString().trim() ?? '').isEmpty && word.isNotEmpty) {
        out['phonetic'] = phoneticsMap[key] ?? '';
      }
      // Örnek cümle: İngilizce sabit, alttaki seçili dilde.
      final ex = examplesMap[key];
      if (ex != null && ex.isNotEmpty) {
        final valEn = ex['en'] ?? ex.values.first;
        final valLocale = ex[lang] ?? ex['en'] ?? ex.values.first;
        out['example_en'] = valEn;
        out['exampleEn'] = valEn;
        out['example_tr'] = valLocale;
        out['exampleTr'] = valLocale;
      }
      return out;
    }).toList();
  }
}
