import '../utils/maltese_words.dart';

class GameStats {
  int currentStreak;
  int maxStreak;
  Set<String> caughtWords;
  Set<String> escapedWords;

  GameStats({
    int wordsCaught = 0,
    int wordsEscaped = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    Set<String>? caughtWords,
    Set<String>? escapedWords,
  }) : caughtWords = caughtWords ?? <String>{},
       escapedWords = escapedWords ?? <String>{};

  int get wordsCaught => caughtWords.length;

  int get wordsEscaped => escapedWords.length;

  double get catchRate {
    final total = wordsCaught + wordsEscaped;
    if (total == 0) return 0.0;
    return (wordsCaught / total) * 100;
  }

  int get wordsLeft {
    return MalteseWords.getWords().length - wordsCaught;
  }

  int get totalWords {
    return wordsCaught + wordsEscaped;
  }

  int get level {
    return (wordsCaught / 10).floor() + 1;
  }

  bool hasCaughtWord(String word) {
    return caughtWords.contains(word);
  }

  void addCaughtWord(String word) {
    caughtWords.add(word);
    currentStreak++;
    if (currentStreak > maxStreak) {
      maxStreak = currentStreak;
    }
  }

  void addEscapedWord(String word) {
    escapedWords.add(word);
    currentStreak = 0;
  }

  int getEscapeCount(String word) {
    return escapedWords.contains(word) ? 1 : 0;
  }

  bool hasEscapedWord(String word) {
    return escapedWords.contains(word);
  }
}
