import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _kXpKey = 'user_xp';

/// Kullanıcının toplam XP'sini tutar (testlerden, vb. kazanılan).
/// SharedPreferences ile kalıcı; Riverpod StateNotifier ile reaktif.
class XpNotifier extends StateNotifier<int> {
  XpNotifier() : super(0) {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getInt(_kXpKey) ?? 0;
    } catch (_) {
      state = 0;
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kXpKey, state);
    } catch (_) {}
  }

  /// Puan ekler (test doğruları vb.). Negatif değer verilirse 0'ın altına düşmez.
  Future<void> addXp(int amount) async {
    if (amount <= 0) return;
    state = (state + amount).clamp(0, 1 << 31);
    await _save();
  }
}
