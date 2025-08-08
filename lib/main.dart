import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_menu_screen.dart';
import 'screens/wordle_game_screen.dart';
import 'screens/word_dex_screen.dart';
import 'screens/end_condition_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/how_to_play_screen.dart';
import 'models/game_stats.dart';
import 'models/theme_model.dart';
import 'models/word_dex.dart';
import 'utils/word_translations.dart';
import 'utils/difficulty_manager.dart';
import 'services/storage_service.dart';
import 'services/onboarding_service.dart';

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
  GameMode? lastGameMode;
  String currentWord = '';
  bool showStyles = false;
  String currentTheme = 'default';
  GameStats stats = GameStats();
  WordDex wordDex = WordDex();
  late ThemeModel theme;
  bool _shouldShowOnboarding = false;
  bool _isCheckingOnboarding = true;

  // End condition data
  bool? lastGameWon;
  int? lastGameAttempts;

  @override
  void initState() {
    super.initState();
    theme = ThemeModel.getTheme(currentTheme);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Check if onboarding should be shown
    final shouldShowOnboarding = !(await OnboardingService.hasCompletedOnboarding());
    
    setState(() {
      _shouldShowOnboarding = shouldShowOnboarding;
      _isCheckingOnboarding = false;
    });
    
    await _loadSavedData();
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
      lastGameMode = gameMode;
      gameMode = GameMode.adventure;
    });
  }

  void handleShowWordDex() {
    setState(() {
      lastGameMode = gameMode;
      gameMode = GameMode.wordDex;
    });
  }

  void handleShowSettings() {
    setState(() {
      lastGameMode = gameMode;
      gameMode = GameMode.settings;
    });
  }

  void handleBackToMenu() {
    setState(() {
      lastGameMode = gameMode;
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
      lastGameMode = gameMode;
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

  void _completeOnboarding() async {
    await OnboardingService.completeOnboarding();
    setState(() {
      _shouldShowOnboarding = false;
    });
  }

  void _skipOnboarding() async {
    await OnboardingService.completeOnboarding();
    setState(() {
      _shouldShowOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading screen while checking onboarding status
    if (_isCheckingOnboarding) {
      return MaterialApp(
        home: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.8),
                  theme.primaryColor.withOpacity(0.6),
                ],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        ),
      );
    }

    // Show onboarding if needed
    if (_shouldShowOnboarding) {
      return MaterialApp(
        home: HowToPlayScreen(
          theme: theme,
          showSkipButton: true,
          onBack: _completeOnboarding,
          onSkip: _skipOnboarding,
          onStartTutorial: _completeOnboarding,
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Different animations based on the game mode
        if (child.key == const ValueKey('settings')) {
          // Slide from right for settings
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        } else if (child.key == const ValueKey('menu') && 
                  lastGameMode == GameMode.settings) {
          // Slide to right when returning from settings
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        }
        // Default fade transition for other screens
        return FadeTransition(opacity: animation, child: child);
      },
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    Widget screen;
    String screenKey;
    
    if (gameMode == GameMode.menu) {
      screenKey = 'menu';
      screen = MainMenuScreen(
        onPlayAdventure: handlePlayAdventure,
        onShowWordDex: handleShowWordDex,
        onShowSettings: handleShowSettings,
        stats: stats,
        wordDex: wordDex,
        theme: theme,
      );
    } else if (gameMode == GameMode.wordDex) {
      screenKey = 'wordDex';
      screen = WordDexScreen(
        wordDex: wordDex,
        theme: theme,
        onBack: handleBackToMenu,
        stats: stats,
      );
    } else if (gameMode == GameMode.settings) {
      screenKey = 'settings';
      screen = SettingsScreen(
        theme: theme,
        currentTheme: currentTheme,
        onThemeSelect: handleThemeSelect,
        onDataChanged: _loadSavedData,
        onBack: handleBackToMenu,
      );
    } else if (gameMode == GameMode.endCondition) {
      screenKey = 'endCondition';
      screen = EndConditionScreen(
        won: lastGameWon!,
        word: currentWord,
        attempts: lastGameAttempts!,
        theme: theme,
        onBackToMenu: handleBackToMenu,
        wasPreviouslyEscaped: stats.hasEscapedWord(currentWord),
      );
    } else {
      screenKey = 'game';
      screen = WordleGameScreen(
        onBack: handleBackToMenu,
        targetWord: currentWord,
        onGameComplete: handleGameComplete,
        theme: theme,
      );
    }

    return KeyedSubtree(
      key: ValueKey(screenKey),
      child: screen,
    );
  }
}

enum GameMode { menu, adventure, wordDex, endCondition, settings }
