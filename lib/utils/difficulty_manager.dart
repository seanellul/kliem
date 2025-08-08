import 'dart:math';
import 'maltese_words.dart';
import 'word_translations.dart';

class DifficultyManager {
  static const String _firstWord = 'KELMA'; // KLIEM - meaning "a word"

  /// Gets the next word based on progression and difficulty
  static String getNextWord(Set<String> caughtWords, Set<String> escapedWords) {
    final totalWordsAttempted = caughtWords.length + escapedWords.length;

    // First word is always KELMA (KLIEM)
    if (totalWordsAttempted == 0) {
      return _firstWord;
    }

    // Get available words (not caught yet)
    final availableWords = MalteseWords.getWords()
        .where((word) => !caughtWords.contains(word))
        .toList();

    if (availableWords.isEmpty) {
      // Fallback if all words are caught (shouldn't happen with 2111 words)
      return MalteseWords.getRandomWord();
    }

    // Determine difficulty phase based on progress
    final difficultyPhase = _getDifficultyPhase(totalWordsAttempted);

    // Get words suitable for current difficulty
    final suitableWords = _getWordsForDifficulty(
        availableWords, difficultyPhase, totalWordsAttempted);

    if (suitableWords.isEmpty) {
      // Fallback to any available word
      return availableWords[Random().nextInt(availableWords.length)];
    }

    return suitableWords[Random().nextInt(suitableWords.length)];
  }

  /// Determines the current difficulty phase based on progress
  static DifficultyPhase _getDifficultyPhase(int totalWordsAttempted) {
    if (totalWordsAttempted <= 20) {
      return DifficultyPhase.beginner;
    } else if (totalWordsAttempted <= 50) {
      return DifficultyPhase.intermediate;
    } else if (totalWordsAttempted <= 100) {
      return DifficultyPhase.advanced;
    } else {
      return DifficultyPhase.expert;
    }
  }

  /// Gets words appropriate for the current difficulty phase
  static List<String> _getWordsForDifficulty(List<String> availableWords,
      DifficultyPhase phase, int totalWordsAttempted) {
    final wordsWithRarity = <MapEntry<String, int>>[];

    // Calculate rarity for each available word
    for (final word in availableWords) {
      final rarity = WordTranslations.getRarity(word) ??
          11; // Default to hardest if no data
      wordsWithRarity.add(MapEntry(word, rarity));
    }

    // Check if we should inject a challenge word (every 5-10 words)
    final shouldInjectChallenge = _shouldInjectChallenge(totalWordsAttempted);

    List<String> suitableWords;

    switch (phase) {
      case DifficultyPhase.beginner:
        // Rarity 1-3 (Very Common to Uncommon)
        suitableWords = wordsWithRarity
            .where((entry) => entry.value >= 1 && entry.value <= 3)
            .map((entry) => entry.key)
            .toList();

        if (shouldInjectChallenge) {
          // Occasionally add a level 4-5 word for challenge
          final challengeWords = wordsWithRarity
              .where((entry) => entry.value >= 4 && entry.value <= 5)
              .map((entry) => entry.key)
              .toList();
          suitableWords.addAll(challengeWords.take(challengeWords.length ~/ 4));
        }
        break;

      case DifficultyPhase.intermediate:
        // Rarity 2-5 (Common to Average) with occasional harder words
        suitableWords = wordsWithRarity
            .where((entry) => entry.value >= 2 && entry.value <= 5)
            .map((entry) => entry.key)
            .toList();

        if (shouldInjectChallenge) {
          // Add some rarity 6-7 words for challenge
          final challengeWords = wordsWithRarity
              .where((entry) => entry.value >= 6 && entry.value <= 7)
              .map((entry) => entry.key)
              .toList();
          suitableWords.addAll(challengeWords.take(challengeWords.length ~/ 3));
        }
        break;

      case DifficultyPhase.advanced:
        // Rarity 3-7 (Uncommon to Rare) with occasional very rare words
        suitableWords = wordsWithRarity
            .where((entry) => entry.value >= 3 && entry.value <= 7)
            .map((entry) => entry.key)
            .toList();

        if (shouldInjectChallenge) {
          // Add some rarity 8-9 words for challenge
          final challengeWords = wordsWithRarity
              .where((entry) => entry.value >= 8 && entry.value <= 9)
              .map((entry) => entry.key)
              .toList();
          suitableWords.addAll(challengeWords.take(challengeWords.length ~/ 2));
        }
        break;

      case DifficultyPhase.expert:
        // All difficulty levels, weighted towards harder words
        final easyWords = wordsWithRarity
            .where((entry) => entry.value >= 1 && entry.value <= 4)
            .map((entry) => entry.key)
            .toList();
        final mediumWords = wordsWithRarity
            .where((entry) => entry.value >= 5 && entry.value <= 7)
            .map((entry) => entry.key)
            .toList();
        final hardWords = wordsWithRarity
            .where((entry) => entry.value >= 8 && entry.value <= 11)
            .map((entry) => entry.key)
            .toList();

        suitableWords = [];
        // 30% easy, 40% medium, 30% hard
        suitableWords.addAll(easyWords.take((easyWords.length * 0.3).round()));
        suitableWords
            .addAll(mediumWords.take((mediumWords.length * 0.4).round()));
        suitableWords.addAll(hardWords.take((hardWords.length * 0.3).round()));
        break;
    }

    // Ensure we have at least some words to choose from
    if (suitableWords.isEmpty) {
      // Fallback to any words in a broader range
      suitableWords = wordsWithRarity
          .where((entry) => entry.value >= 1 && entry.value <= 6)
          .map((entry) => entry.key)
          .toList();
    }

    return suitableWords;
  }

  /// Determines if we should inject a challenge word
  static bool _shouldInjectChallenge(int totalWordsAttempted) {
    // Inject challenge every 7-8 words on average
    return (totalWordsAttempted % 7 == 0) || (totalWordsAttempted % 8 == 0);
  }

  /// Gets the difficulty description for UI display
  static String getDifficultyDescription(int totalWordsAttempted) {
    final phase = _getDifficultyPhase(totalWordsAttempted);
    switch (phase) {
      case DifficultyPhase.beginner:
        return 'Beginner (Common Words)';
      case DifficultyPhase.intermediate:
        return 'Intermediate (Mixed Difficulty)';
      case DifficultyPhase.advanced:
        return 'Advanced (Challenging Words)';
      case DifficultyPhase.expert:
        return 'Expert (All Difficulties)';
    }
  }

  /// Gets the current progress within the phase
  static double getPhaseProgress(int totalWordsAttempted) {
    final phase = _getDifficultyPhase(totalWordsAttempted);
    switch (phase) {
      case DifficultyPhase.beginner:
        return totalWordsAttempted / 20.0;
      case DifficultyPhase.intermediate:
        return (totalWordsAttempted - 20) / 30.0;
      case DifficultyPhase.advanced:
        return (totalWordsAttempted - 50) / 50.0;
      case DifficultyPhase.expert:
        return 1.0; // Always full for expert
    }
  }

  /// Gets words remaining in current phase
  static int getWordsRemainingInPhase(int totalWordsAttempted) {
    final phase = _getDifficultyPhase(totalWordsAttempted);
    switch (phase) {
      case DifficultyPhase.beginner:
        return 20 - totalWordsAttempted;
      case DifficultyPhase.intermediate:
        return 50 - totalWordsAttempted;
      case DifficultyPhase.advanced:
        return 100 - totalWordsAttempted;
      case DifficultyPhase.expert:
        return 0; // No limit for expert
    }
  }
}

enum DifficultyPhase {
  beginner, // Words 0-20: Rarity 1-3 (Very Common to Uncommon)
  intermediate, // Words 21-50: Rarity 2-5 (Common to Average)
  advanced, // Words 51-100: Rarity 3-7 (Uncommon to Rare)
  expert, // Words 100+: All rarities with weighted distribution
}
