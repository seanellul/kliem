import 'package:flutter/foundation.dart';
import '../utils/word_translations.dart';

class WordDexEntry {
  final String malteseWord;
  final String englishTranslation;
  final DateTime caughtDate;
  final int attemptsUsed;
  final int? rarity;

  WordDexEntry({
    required this.malteseWord,
    required this.englishTranslation,
    required this.caughtDate,
    required this.attemptsUsed,
    this.rarity,
  });

  Map<String, dynamic> toJson() {
    return {
      'malteseWord': malteseWord,
      'englishTranslation': englishTranslation,
      'caughtDate': caughtDate.toIso8601String(),
      'attemptsUsed': attemptsUsed,
      'rarity': rarity,
    };
  }

  factory WordDexEntry.fromJson(Map<String, dynamic> json) {
    final malteseWord = json['malteseWord'] ?? '';
    final savedTranslation =
        json['englishTranslation'] ?? json['translation'] ?? 'Unknown';

    // Try to get the correct translation if the saved one is 'Unknown'
    final englishTranslation = savedTranslation == 'Unknown'
        ? WordTranslations.getTranslation(malteseWord)
        : savedTranslation;

    return WordDexEntry(
      malteseWord: malteseWord,
      englishTranslation: englishTranslation,
      caughtDate: DateTime.parse(json['caughtDate']),
      attemptsUsed: json['attemptsUsed'] ?? 0,
      rarity: json['rarity'] ?? WordTranslations.getRarity(malteseWord),
    );
  }
}

class WordDex {
  final Map<String, WordDexEntry> entries;

  WordDex({Map<String, WordDexEntry>? entries}) : entries = entries ?? {};

  void addEntry(String word, String translation, int attempts) {
    entries[word] = WordDexEntry(
      malteseWord: word,
      englishTranslation: translation,
      caughtDate: DateTime.now(),
      attemptsUsed: attempts,
      rarity: WordTranslations.getRarity(word),
    );
  }

  WordDexEntry? getEntry(String word) {
    return entries[word];
  }

  bool hasWord(String word) {
    return entries.containsKey(word);
  }

  int get totalWords {
    return entries.length;
  }

  List<WordDexEntry> get allEntries {
    return entries.values.toList()
      ..sort((a, b) => a.caughtDate.compareTo(b.caughtDate));
  }

  Map<String, dynamic> toJson() {
    return {
      'entries': entries.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  factory WordDex.fromJson(Map<String, dynamic> json) {
    final entriesMap = <String, WordDexEntry>{};
    final entriesJson = json['entries'] as Map<String, dynamic>? ?? {};

    for (final entry in entriesJson.entries) {
      try {
        entriesMap[entry.key] = WordDexEntry.fromJson(entry.value);
      } catch (e) {
        // Skip invalid entries
        debugPrint('Warning: Skipping invalid WordDex entry: ${entry.key}');
      }
    }

    return WordDex(entries: entriesMap);
  }
}
