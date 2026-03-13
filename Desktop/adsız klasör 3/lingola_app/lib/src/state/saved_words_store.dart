import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lingola_app/Models/saved_word_item.dart';

const String _kSavedWordsKey = 'saved_words';

/// Reaktif kayıtlı kelimeler store'u.
/// [SavedWordItem] listesini SharedPreferences ile kalıcı tutar; Riverpod StateNotifier ile reaktif.
class SavedWordsNotifier extends StateNotifier<List<SavedWordItem>> {
  SavedWordsNotifier() : super(const []) {
    _load();
  }

  bool _loaded = false;

  /// Yüklü liste (salt okunur). Değişiklikler [add] / [remove] ile yapılır.
  List<SavedWordItem> get items => List.unmodifiable(state);

  int get count => state.length;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kSavedWordsKey);
      if (raw != null && raw.isNotEmpty) {
        state = SavedWordItem.decodeList(raw);
      } else {
        state = const [];
      }
    } catch (_) {
      state = const [];
    } finally {
      _loaded = true;
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSavedWordsKey, SavedWordItem.encodeList(state));
    } catch (_) {}
  }

  /// Kelime ekler; aynı [word] varsa eklemez. Diske yazar ve dinleyicileri günceller.
  Future<void> add(SavedWordItem item) async {
    await _ensureLoaded();
    if (state.any((e) => e.word == item.word)) return;
    state = [...state, item];
    await _save();
  }

  /// Kelimeyi listeden kaldırır. Diske yazar ve dinleyicileri günceller.
  Future<void> remove(String word) async {
    await _ensureLoaded();
    state = [
      for (final item in state)
        if (item.word != word) item,
    ];
    await _save();
  }

  /// Kelimenin kayıtlı olup olmadığını döner (yükleme tamamlandıktan sonra anlamlı).
  Future<bool> contains(String word) async {
    await _ensureLoaded();
    return state.any((e) => e.word == word);
  }
}
