import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lingola_app/Models/saved_word_item.dart';
import 'package:lingola_app/src/state/saved_words_store.dart';

/// Kayıtlı kelimeler için global provider.
/// Uygulama genelinde `savedWordsProvider` ile erişilir.
final savedWordsProvider = StateNotifierProvider<SavedWordsNotifier, List<SavedWordItem>>(
  (ref) => SavedWordsNotifier(),
);

