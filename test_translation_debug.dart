import 'lib/utils/word_translations.dart';
import 'lib/utils/maltese_words.dart';

void main() {
  print('Testing translations...');

  // Test a few words from the Maltese words list
  final testWords = ['ABBON', 'ABJAD', 'ABTAR', 'ADULT', 'ADURA'];

  for (final word in testWords) {
    print('\nWord: $word');
    print('  getTranslation(): "${WordTranslations.getTranslation(word)}"');
    print('  hasTranslation(): ${WordTranslations.hasTranslation(word)}');
    print('  getFrequency(): ${WordTranslations.getFrequency(word)}');
    print('  getRarity(): ${WordTranslations.getRarity(word)}');
  }

  // Test with lowercase
  print('\n--- Testing with lowercase ---');
  for (final word in testWords) {
    final lowerWord = word.toLowerCase();
    print('\nWord: $lowerWord');
    print(
        '  getTranslation(): "${WordTranslations.getTranslation(lowerWord)}"');
    print('  hasTranslation(): ${WordTranslations.hasTranslation(lowerWord)}');
  }
}
