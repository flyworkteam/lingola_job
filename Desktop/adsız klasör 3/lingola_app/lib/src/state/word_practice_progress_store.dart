import 'package:shared_preferences/shared_preferences.dart';

import 'package:lingola_app/Models/word_item.dart';
import 'package:lingola_app/Services/word_database_service.dart';
import 'package:lingola_app/src/utils/user_level.dart';

class WordPracticeProgressSnapshot {
  const WordPracticeProgressSnapshot({
    required this.currentLevel,
    required this.completedWords,
    required this.totalWords,
  });

  final String currentLevel;
  final int completedWords;
  final int totalWords;

  double get progress {
    if (totalWords <= 0) return 0;
    return (completedWords / totalWords).clamp(0.0, 1.0);
  }

  int get progressPercent => (progress * 100).round();
}

abstract final class WordPracticeProgressStore {
  WordPracticeProgressStore._();

  static const String _keyProfileLevel = 'profile_level';
  static const String _seenIdsPrefix = 'word_practice_seen_ids';
  static const int xpPerLevel = 500;

  static Future<WordPracticeProgressSnapshot> getCurrentProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final currentLevel = _normalizedProfileLevel(
      prefs.getString(_keyProfileLevel),
    );
    final completedWords = _seenWordIdsForLevel(
      prefs,
      currentLevel,
    ).length.clamp(0, totalWordsForLevel(currentLevel));

    return WordPracticeProgressSnapshot(
      currentLevel: currentLevel,
      completedWords: completedWords,
      totalWords: totalWordsForLevel(currentLevel),
    );
  }

  static Future<WordPracticeProgressSnapshot> markWordCompleted(
    WordItem word,
  ) async {
    final wordLevel = UserLevel.normalizedLevel(word.level);
    if (wordLevel == null || word.id <= 0) {
      return getCurrentProgress();
    }

    final prefs = await SharedPreferences.getInstance();
    final seenIds = _seenWordIdsForLevel(prefs, wordLevel);
    seenIds.add(word.id.toString());
    await prefs.setStringList(_seenIdsKey(wordLevel), seenIds.toList()..sort());

    var currentLevel = _normalizedProfileLevel(prefs.getString(_keyProfileLevel));
    if (currentLevel == wordLevel &&
        seenIds.length >= totalWordsForLevel(wordLevel)) {
      final nextLevel = UserLevel.nextLevel(currentLevel);
      if (nextLevel != null) {
        currentLevel = nextLevel;
        await prefs.setString(_keyProfileLevel, nextLevel);
      }
    }

    final completedWords = _seenWordIdsForLevel(
      prefs,
      currentLevel,
    ).length.clamp(0, totalWordsForLevel(currentLevel));

    return WordPracticeProgressSnapshot(
      currentLevel: currentLevel,
      completedWords: completedWords,
      totalWords: totalWordsForLevel(currentLevel),
    );
  }

  static int totalWordsForLevel(String level) {
    switch (level) {
      case 'a1':
        return WordDatabaseService.a1Count;
      case 'a2':
        return WordDatabaseService.a2Count;
      case 'b1':
        return WordDatabaseService.b1Count;
      case 'b2':
        return WordDatabaseService.b2Count;
      case 'c1':
        return WordDatabaseService.c1Count;
      case 'c2':
        return WordDatabaseService.c2Count;
      default:
        return WordDatabaseService.a1Count;
    }
  }

  static String _normalizedProfileLevel(String? level) {
    return UserLevel.normalizedLevel(level) ?? UserLevel.orderedLevels.first;
  }

  static double xpProgressForLevel({
    required int totalXp,
    required String currentLevel,
  }) {
    final levelIndex = UserLevel.orderedLevels.indexOf(currentLevel);
    final normalizedIndex = levelIndex < 0 ? 0 : levelIndex;
    final levelStartXp = normalizedIndex * xpPerLevel;
    final levelXp = (totalXp - levelStartXp).clamp(0, xpPerLevel);
    return levelXp / xpPerLevel;
  }

  static double combinedProgress({
    required WordPracticeProgressSnapshot snapshot,
    required int totalXp,
  }) {
    final wordProgress = snapshot.progress;
    final xpProgress = xpProgressForLevel(
      totalXp: totalXp,
      currentLevel: snapshot.currentLevel,
    );
    return wordProgress > xpProgress ? wordProgress : xpProgress;
  }

  static int combinedProgressPercent({
    required WordPracticeProgressSnapshot snapshot,
    required int totalXp,
  }) {
    return (combinedProgress(snapshot: snapshot, totalXp: totalXp) * 100).round();
  }

  static Set<String> _seenWordIdsForLevel(
    SharedPreferences prefs,
    String level,
  ) {
    return (prefs.getStringList(_seenIdsKey(level)) ?? <String>[]).toSet();
  }

  static String _seenIdsKey(String level) => '${_seenIdsPrefix}_$level';
}
