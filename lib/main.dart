import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'screens/main_menu_screen.dart';
import 'screens/wordle_game_screen.dart';
import 'screens/word_dex_screen.dart';
import 'screens/end_condition_screen.dart';
import 'models/game_stats.dart';
import 'models/theme_model.dart';
import 'models/word_dex.dart';
import 'utils/word_translations.dart';
import 'utils/difficulty_manager.dart';

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
    final prefs = await SharedPreferences.getInstance();

    // Load stats
    final wordsCaught = prefs.getInt('kelma-stats-wordsCaught') ?? 0;
    final wordsEscaped = prefs.getInt('kelma-stats-wordsEscaped') ?? 0;
    final currentStreak = prefs.getInt('kelma-stats-currentStreak') ?? 0;
    final maxStreak = prefs.getInt('kelma-stats-maxStreak') ?? 0;
    final caughtWordsJson = prefs.getString('kelma-stats-caughtWords') ?? '[]';
    final caughtWords = Set<String>.from(jsonDecode(caughtWordsJson));
    final escapedWordsJson =
        prefs.getString('kelma-stats-escapedWords') ?? '[]';
    final escapedWords = Set<String>.from(jsonDecode(escapedWordsJson));

    // Load Word-Dex
    final wordDexJson = prefs.getString('kelma-worddex') ?? '{"entries":{}}';
    final wordDexData = jsonDecode(wordDexJson);

    setState(() {
      stats = GameStats(
        wordsCaught: wordsCaught,
        wordsEscaped: wordsEscaped,
        currentStreak: currentStreak,
        maxStreak: maxStreak,
        caughtWords: caughtWords,
        escapedWords: escapedWords,
      );
      wordDex = WordDex.fromJson(wordDexData);
    });

    // Load theme
    final savedTheme = prefs.getString('kelma-theme') ?? 'default';
    setState(() {
      currentTheme = savedTheme;
      theme = ThemeModel.getTheme(currentTheme);
    });
  }

  Future<void> _saveStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('kelma-stats-wordsCaught', stats.wordsCaught);
    await prefs.setInt('kelma-stats-wordsEscaped', stats.wordsEscaped);
    await prefs.setInt('kelma-stats-currentStreak', stats.currentStreak);
    await prefs.setInt('kelma-stats-maxStreak', stats.maxStreak);
    await prefs.setString(
        'kelma-stats-caughtWords', jsonEncode(stats.caughtWords.toList()));
    await prefs.setString(
        'kelma-stats-escapedWords', jsonEncode(stats.escapedWords.toList()));
    await prefs.setString('kelma-worddex', jsonEncode(wordDex.toJson()));
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
        onShowStyles: () => setState(() => showStyles = true),
        stats: stats,
        wordDex: wordDex,
        theme: theme,
        onThemeSelect: handleThemeSelect,
        showStyles: showStyles,
        onCloseStyles: () => setState(() => showStyles = false),
        currentTheme: currentTheme,
      );
    } else if (gameMode == GameMode.wordDex) {
      return WordDexScreen(
        wordDex: wordDex,
        theme: theme,
        onBack: handleBackToMenu,
        stats: stats,
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

enum GameMode { menu, adventure, wordDex, endCondition }
