import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_menu_screen.dart';
import 'screens/wordle_game_screen.dart';
import 'screens/word_dex_screen.dart';
import 'screens/end_condition_screen.dart';
import 'screens/settings_screen.dart';
import 'models/game_stats.dart';
import 'models/theme_model.dart';
import 'models/word_dex.dart';
import 'utils/word_translations.dart';
import 'utils/difficulty_manager.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const MalteseWordleApp());
}

class MalteseWordleApp extends StatelessWidget {
  const MalteseWordleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kliem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: const AppWrapper(),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  GameMode gameMode = GameMode.menu;
  String currentWord = '';
  bool showStyles = false;
  String currentTheme = 'default';
  GameStats stats = GameStats();
  WordDex wordDex = WordDex();
  late ThemeModel theme;

  // End condition data
  bool? lastGameWon;
  int? lastGameAttempts;

  @override
  void initState() {
    super.initState();
    theme = ThemeModel.getTheme(currentTheme);
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    // Check for data recovery first
    await StorageService.checkAndRecoverData();

    // Load stats using StorageService
    final loadedStats = await StorageService.loadGameStats();
    
    // Load Word-Dex using StorageService with backup fallback
    final loadedWordDex = await StorageService.loadWordDex();

    setState(() {
      stats = loadedStats;
      wordDex = loadedWordDex;
    });

    // Load theme
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('kelma-theme') ?? 'default';
    setState(() {
      currentTheme = savedTheme;
      theme = ThemeModel.getTheme(currentTheme);
    });
  }

  Future<void> _saveStats() async {
    // Save both stats and WordDex using StorageService
    await StorageService.saveGameStats(stats);
    await StorageService.saveWordDex(wordDex);
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kelma-theme', currentTheme);
  }

  void handlePlayAdventure() {
    setState(() {
      // Use the difficulty manager to get the next appropriate word
      currentWord =
          DifficultyManager.getNextWord(stats.caughtWords, stats.escapedWords);
      gameMode = GameMode.adventure;
    });
  }

  void handleShowWordDex() {
    setState(() {
      gameMode = GameMode.wordDex;
    });
  }

  void handleShowSettings() {
    setState(() {
      gameMode = GameMode.settings;
    });
  }

  void handleBackToMenu() {
    setState(() {
      gameMode = GameMode.menu;
    });
  }

  void handleGameComplete(bool won, int attempts) {
    if (won) {
      // Word caught!
      setState(() {
        stats.addCaughtWord(currentWord);
        wordDex.addEntry(
          currentWord,
          WordTranslations.getTranslation(currentWord),
          attempts,
        );
      });
    } else {
      // Word escaped!
      setState(() {
        stats.addEscapedWord(currentWord);
      });
    }

    // Store end condition data and show end screen
    setState(() {
      lastGameWon = won;
      lastGameAttempts = attempts;
      gameMode = GameMode.endCondition;
    });

    _saveStats();
  }

  void handleThemeSelect(String themeId) {
    setState(() {
      currentTheme = themeId;
      theme = ThemeModel.getTheme(themeId);
    });
    _saveTheme();
  }

  @override
  Widget build(BuildContext context) {
    if (gameMode == GameMode.menu) {
      return MainMenuScreen(
        onPlayAdventure: handlePlayAdventure,
        onShowWordDex: handleShowWordDex,
        onShowSettings: handleShowSettings,
        stats: stats,
        wordDex: wordDex,
        theme: theme,
      );
    } else if (gameMode == GameMode.wordDex) {
      return WordDexScreen(
        wordDex: wordDex,
        theme: theme,
        onBack: handleBackToMenu,
        stats: stats,
      );
    } else if (gameMode == GameMode.settings) {
      return SettingsScreen(
        theme: theme,
        currentTheme: currentTheme,
        onThemeSelect: handleThemeSelect,
        onDataChanged: _loadSavedData,
        onBack: handleBackToMenu,
      );
    } else if (gameMode == GameMode.endCondition) {
      return EndConditionScreen(
        won: lastGameWon!,
        word: currentWord,
        attempts: lastGameAttempts!,
        theme: theme,
        onBackToMenu: handleBackToMenu,
        wasPreviouslyEscaped: stats.hasEscapedWord(currentWord),
      );
    }

    return WordleGameScreen(
      onBack: handleBackToMenu,
      targetWord: currentWord,
      onGameComplete: handleGameComplete,
      theme: theme,
    );
  }
}

enum GameMode { menu, adventure, wordDex, endCondition, settings }
