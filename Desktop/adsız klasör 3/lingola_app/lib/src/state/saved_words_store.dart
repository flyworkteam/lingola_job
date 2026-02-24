/// Word Practice'tan kaydedilen kelimeler. Saved Word sayfası bu listeyi kullanır.
class SavedWordItem {
  const SavedWordItem({
    required this.word,
    required this.phonetic,
    required this.translations,
    required this.exampleEn,
    required this.exampleTr,
  });

  final String word;
  final String phonetic;
  final String translations;
  final String exampleEn;
  final String exampleTr;
}

abstract final class SavedWordsStore {
  SavedWordsStore._();

  static final List<SavedWordItem> items = [];

  static void add(SavedWordItem item) {
    if (items.any((e) => e.word == item.word)) return;
    items.add(item);
  }

  static int get count => items.length;
}
