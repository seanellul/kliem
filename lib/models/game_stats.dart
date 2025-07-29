class GameStats {
  int wordsCaught;
  int wordsEscaped;
  int currentStreak;
  int maxStreak;
  Set<String> caughtWords;
  Set<String> escapedWords; // Track individual escaped words

  GameStats({
    this.wordsCaught = 0,
    this.wordsEscaped = 0,
    this.currentStreak = 0,
    this.maxStreak = 0,
    Set<String>? caughtWords,
    Set<String>? escapedWords,
  }) : caughtWords = caughtWords ?? <String>{},
       escapedWords = escapedWords ?? <String>{};

  double get catchRate {
    final total = wordsCaught + wordsEscaped;
    if (total == 0) return 0.0;
    return (wordsCaught / total) * 100;
  }

  int get wordsLeft {
    return 2111 - wordsCaught; // Total words minus caught words
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
    wordsCaught++;
    currentStreak++;
    if (currentStreak > maxStreak) {
      maxStreak = currentStreak;
    }
  }

  void addEscapedWord(String word) {
    escapedWords.add(word);
    wordsEscaped++;
    currentStreak = 0;
  }

  int getEscapeCount(String word) {
    // Count how many times this word has escaped
    // This is a simple implementation - in a real app you might want to track dates
    return escapedWords.contains(word) ? 1 : 0;
  }

  bool hasEscapedWord(String word) {
    return escapedWords.contains(word);
  }
}
