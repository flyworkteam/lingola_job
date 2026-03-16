import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lingola_app/state/xp_store.dart';

/// Kullanıcı XP'si için global provider (testlerden kazanılan puanlar).
final xpProvider = StateNotifierProvider<XpNotifier, int>(
  (ref) => XpNotifier(),
);
