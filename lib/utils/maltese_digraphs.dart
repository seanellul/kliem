class MalteseDigraphs {
  static const Map<String, String> _digraphs = {
    'IE': 'Ie',
    'Ie': 'Ie',
    'ie': 'ie',
    'GĦ': 'Għ',
    'Għ': 'Għ',
    'għ': 'għ',
  };

  static const List<String> _digraphPatterns = ['IE', 'GĦ'];

  /// Checks if a string starts with a Maltese digraph
  static bool startsWithDigraph(String text) {
    final upperText = text.toUpperCase();
    return _digraphPatterns.any((pattern) => upperText.startsWith(pattern));
  }

  /// Gets the digraph if the text starts with one, otherwise returns null
  static String? getDigraph(String text) {
    final upperText = text.toUpperCase();
    for (final pattern in _digraphPatterns) {
      if (upperText.startsWith(pattern)) {
        return _digraphs[pattern] ?? pattern;
      }
    }
    return null;
  }

  /// Normalizes a word by converting digraphs to their standard form
  static String normalizeWord(String word) {
    String normalized = word.toUpperCase();

    // Replace IE with Ie
    normalized = normalized.replaceAll('IE', 'Ie');

    // Replace GĦ with Għ
    normalized = normalized.replaceAll('GĦ', 'Għ');

    return normalized;
  }

  /// Formats a word for display with proper digraph capitalization
  static String formatForDisplay(String word) {
    String formatted = word.toUpperCase();

    // Keep IE as IE (all caps)
    // Keep GĦ as GĦ (all caps)
    // No replacements needed - just ensure everything is uppercase

    return formatted;
  }

  /// Checks if a character is part of a digraph
  static bool isDigraphPart(String char) {
    return 'IEGĦ'.contains(char.toUpperCase());
  }

  /// Gets the length of a word considering digraphs as single letters
  static int getWordLength(String word) {
    String normalized = word.toUpperCase();

    // Count digraphs as single letters
    int length = normalized.length;

    // Subtract extra characters from digraphs
    length -= (normalized.split('IE').length - 1); // IE becomes Ie (1 letter)
    length -= (normalized.split('GĦ').length - 1); // GĦ becomes Għ (1 letter)

    return length;
  }

  /// Splits a word into individual letters (including digraphs as single letters)
  static List<String> splitIntoLetters(String word) {
    String normalized = word.toUpperCase();
    List<String> letters = [];

    int i = 0;
    while (i < normalized.length) {
      if (i + 1 < normalized.length) {
        String twoChars = normalized.substring(i, i + 2);
        if (twoChars == 'IE' || twoChars == 'GĦ') {
          letters.add(_digraphs[twoChars] ?? twoChars);
          i += 2;
          continue;
        }
      }
      letters.add(normalized[i]);
      i++;
    }

    return letters;
  }

  /// Joins letters back into a word
  static String joinLetters(List<String> letters) {
    return letters.join('');
  }
}
