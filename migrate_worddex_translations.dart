import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'lib/utils/word_translations.dart';

class WordDexMigrator {
  static Future<void> main() async {
    print('🔄 Migrating Word-Dex translations...');
    print('');

    final prefs = await SharedPreferences.getInstance();

    // Load current Word-Dex data
    final wordDexJson = prefs.getString('kelma-worddex') ?? '{"entries":{}}';
    final wordDexData = jsonDecode(wordDexJson);

    print('📊 Current Word-Dex entries: ${wordDexData['entries'].length}');

    int updated = 0;
    int unchanged = 0;

    // Update each entry
    final entriesJson = wordDexData['entries'] as Map<String, dynamic>;
    final updatedEntries = <String, Map<String, dynamic>>{};

    for (final entry in entriesJson.entries) {
      final word = entry.key;
      final entryData = entry.value as Map<String, dynamic>;
      final currentTranslation = entryData['englishTranslation'] ??
          entryData['translation'] ??
          'Unknown';

      // Get the correct translation
      final correctTranslation = WordTranslations.getTranslation(word);

      if (currentTranslation == 'Unknown' && correctTranslation != 'Unknown') {
        print('🔄 Updating "$word": "Unknown" → "$correctTranslation"');
        updated++;

        // Update the entry
        final updatedEntry = Map<String, dynamic>.from(entryData);
        updatedEntry['englishTranslation'] = correctTranslation;
        updatedEntries[word] = updatedEntry;
      } else {
        print('✅ Keeping "$word": "$currentTranslation"');
        unchanged++;
        updatedEntries[word] = entryData;
      }
    }

    // Save the updated data
    final updatedWordDexData = {'entries': updatedEntries};
    await prefs.setString('kelma-worddex', jsonEncode(updatedWordDexData));

    print('');
    print('✅ Migration complete!');
    print('📊 Summary:');
    print('   • Updated: $updated entries');
    print('   • Unchanged: $unchanged entries');
    print('   • Total: ${updated + unchanged} entries');
  }
}

void main() async {
  await WordDexMigrator.main();
}
