import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import '../models/word_dex.dart';
import '../models/game_stats.dart';

class StorageService {
  static const String _wordDexKey = 'kelma-worddex';
  static const String _wordDexBackupKey = 'kelma-worddex-backup';
  static const String _versionKey = 'kelma-version';
  static const String _fileBackupName = 'worddex_backup.json';
  static const String _currentVersion = '1.0';

  /// Load WordDex data with multiple fallback strategies
  static Future<WordDex> loadWordDex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Try primary storage first
      String? wordDexJson = prefs.getString(_wordDexKey);
      
      if (wordDexJson != null && wordDexJson.isNotEmpty) {
        try {
          final wordDexData = jsonDecode(wordDexJson);
          final wordDex = WordDex.fromJson(wordDexData);
          
          // If primary data is good, create backup
          await _createBackup(wordDex);
          return wordDex;
        } catch (e) {
          debugPrint('Error loading primary WordDex data: $e');
        }
      }
      
      // Try backup in SharedPreferences
      String? backupJson = prefs.getString(_wordDexBackupKey);
      if (backupJson != null && backupJson.isNotEmpty) {
        try {
          final wordDexData = jsonDecode(backupJson);
          final wordDex = WordDex.fromJson(wordDexData);
          debugPrint('Restored WordDex from SharedPreferences backup');
          
          // Restore to primary storage
          await prefs.setString(_wordDexKey, backupJson);
          return wordDex;
        } catch (e) {
          debugPrint('Error loading backup WordDex data: $e');
        }
      }
      
      // Try file system backup
      final fileBackup = await _loadFromFileBackup();
      if (fileBackup != null) {
        debugPrint('Restored WordDex from file backup');
        
        // Restore to primary storage
        await prefs.setString(_wordDexKey, jsonEncode(fileBackup.toJson()));
        return fileBackup;
      }
      
      // If all else fails, return empty WordDex
      debugPrint('No WordDex data found, starting fresh');
      return WordDex();
      
    } catch (e) {
      debugPrint('Error in loadWordDex: $e');
      return WordDex();
    }
  }

  /// Save WordDex data with multiple backup strategies
  static Future<void> saveWordDex(WordDex wordDex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(wordDex.toJson());
      
      // Save to primary location
      await prefs.setString(_wordDexKey, jsonData);
      
      // Save to backup location in SharedPreferences
      await prefs.setString(_wordDexBackupKey, jsonData);
      
      // Save to file system backup
      await _saveToFileBackup(wordDex);
      
      // Update version info
      await prefs.setString(_versionKey, _currentVersion);
      
    } catch (e) {
      debugPrint('Error saving WordDex: $e');
    }
  }

  /// Create multiple backups of WordDex data
  static Future<void> _createBackup(WordDex wordDex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = jsonEncode(wordDex.toJson());
      
      // Backup to SharedPreferences
      await prefs.setString(_wordDexBackupKey, jsonData);
      
      // Backup to file system
      await _saveToFileBackup(wordDex);
      
    } catch (e) {
      debugPrint('Error creating backup: $e');
    }
  }

  /// Save WordDex to file system backup
  static Future<void> _saveToFileBackup(WordDex wordDex) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileBackupName');
      
      final backupData = {
        'version': _currentVersion,
        'timestamp': DateTime.now().toIso8601String(),
        'wordDex': wordDex.toJson(),
      };
      
      await file.writeAsString(jsonEncode(backupData));
    } catch (e) {
      debugPrint('Error saving file backup: $e');
    }
  }

  /// Load WordDex from file system backup
  static Future<WordDex?> _loadFromFileBackup() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileBackupName');
      
      if (!await file.exists()) {
        return null;
      }
      
      final contents = await file.readAsString();
      final backupData = jsonDecode(contents);
      
      // Validate backup data
      if (backupData['wordDex'] != null) {
        return WordDex.fromJson(backupData['wordDex']);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error loading file backup: $e');
      return null;
    }
  }

  /// Load game stats with fallback
  static Future<GameStats> loadGameStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final wordsCaught = prefs.getInt('kelma-stats-wordsCaught') ?? 0;
      final wordsEscaped = prefs.getInt('kelma-stats-wordsEscaped') ?? 0;
      final currentStreak = prefs.getInt('kelma-stats-currentStreak') ?? 0;
      final maxStreak = prefs.getInt('kelma-stats-maxStreak') ?? 0;
      final caughtWordsJson = prefs.getString('kelma-stats-caughtWords') ?? '[]';
      final caughtWords = Set<String>.from(jsonDecode(caughtWordsJson));
      final escapedWordsJson = prefs.getString('kelma-stats-escapedWords') ?? '[]';
      final escapedWords = Set<String>.from(jsonDecode(escapedWordsJson));

      return GameStats(
        wordsCaught: wordsCaught,
        wordsEscaped: wordsEscaped,
        currentStreak: currentStreak,
        maxStreak: maxStreak,
        caughtWords: caughtWords,
        escapedWords: escapedWords,
      );
    } catch (e) {
      debugPrint('Error loading game stats: $e');
      return GameStats();
    }
  }

  /// Save game stats
  static Future<void> saveGameStats(GameStats stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('kelma-stats-wordsCaught', stats.wordsCaught);
      await prefs.setInt('kelma-stats-wordsEscaped', stats.wordsEscaped);
      await prefs.setInt('kelma-stats-currentStreak', stats.currentStreak);
      await prefs.setInt('kelma-stats-maxStreak', stats.maxStreak);
      await prefs.setString('kelma-stats-caughtWords', jsonEncode(stats.caughtWords.toList()));
      await prefs.setString('kelma-stats-escapedWords', jsonEncode(stats.escapedWords.toList()));
    } catch (e) {
      debugPrint('Error saving game stats: $e');
    }
  }

  /// Check if this is a first run after an update/reinstall and attempt recovery
  static Future<bool> checkAndRecoverData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedVersion = prefs.getString(_versionKey);
      
      if (savedVersion == null) {
        // First run or after data loss - try to recover
        debugPrint('First run detected, attempting data recovery...');
        
        final recoveredWordDex = await _loadFromFileBackup();
        if (recoveredWordDex != null && recoveredWordDex.totalWords > 0) {
          await saveWordDex(recoveredWordDex);
          debugPrint('Successfully recovered ${recoveredWordDex.totalWords} words from backup');
          return true;
        }
      }
      
      return false;
    } catch (e) {
      debugPrint('Error in checkAndRecoverData: $e');
      return false;
    }
  }

  /// Export WordDex data for manual backup (returns JSON string)
  static Future<String?> exportWordDex() async {
    try {
      final wordDex = await loadWordDex();
      if (wordDex.totalWords == 0) {
        return null;
      }
      
      final exportData = {
        'version': _currentVersion,
        'exportDate': DateTime.now().toIso8601String(),
        'totalWords': wordDex.totalWords,
        'wordDex': wordDex.toJson(),
      };
      
      return jsonEncode(exportData);
    } catch (e) {
      debugPrint('Error exporting WordDex: $e');
      return null;
    }
  }

  /// Import WordDex data from manual backup
  static Future<bool> importWordDex(String jsonData) async {
    try {
      final importData = jsonDecode(jsonData);
      
      if (importData['wordDex'] != null) {
        final wordDex = WordDex.fromJson(importData['wordDex']);
        await saveWordDex(wordDex);
        debugPrint('Successfully imported ${wordDex.totalWords} words');
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error importing WordDex: $e');
      return false;
    }
  }
}