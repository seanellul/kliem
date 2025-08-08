import 'package:flutter/material.dart';
import '../models/game_stats.dart';
import '../models/theme_model.dart';
import '../models/word_dex.dart';
import '../utils/difficulty_manager.dart';

class MainMenuScreen extends StatelessWidget {
  final VoidCallback onPlayAdventure;
  final VoidCallback onShowWordDex;
  final VoidCallback onShowSettings;
  final GameStats stats;
  final WordDex wordDex;
  final ThemeModel theme;

  const MainMenuScreen({
    super.key,
    required this.onPlayAdventure,
    required this.onShowWordDex,
    required this.onShowSettings,
    required this.stats,
    required this.wordDex,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
            child: SafeArea(
              child: Column(
                children: [
                  // Top bar with settings icon
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: IconButton(
                            onPressed: onShowSettings,
                            icon: Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 24,
                            ),
                            tooltip: 'Settings',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Main content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                    // Title
                    Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              theme.secondaryColor,
                              theme.accentColor,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'KLIEM',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Discover Maltese Words',
                          style: TextStyle(
                            fontSize: 18,
                            color: theme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Stats Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons.check_circle,
                                  iconColor: Colors.green,
                                  label: 'Caught',
                                  value: stats.wordsCaught.toString(),
                                ),
                              ),
                              // Expanded(
                              //   child: _buildStatItem(
                              //     icon: Icons.cancel,
                              //     iconColor: Colors.red,
                              //     label: 'Escaped',
                              //     value: stats.wordsEscaped.toString(),
                              //   ),
                              // ),
                              Expanded(
                                child: _buildStatItem(
                                  icon: Icons.book,
                                  iconColor: Colors.blue,
                                  label: 'Left',
                                  value: stats.wordsLeft.toString(),
                                ),
                              ),
                            ],
                          ),
                          // const SizedBox(height: 16),
                          // Row(
                          //   children: [

                          //     Expanded(
                          //       child: _buildStatItem(
                          //         icon: Icons.trending_up,
                          //         iconColor: Colors.orange,
                          //         label: 'Rate',
                          //         value: '${stats.catchRate.round()}%',
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Progression Card
                    _buildProgressionCard(),
                    const SizedBox(height: 40),

                    // Game Mode Buttons
                    Container(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Column(
                        children: [
                          _buildGameButton(
                            onPressed: onPlayAdventure,
                            text: '🗺️ Word Hunt',
                            gradient: LinearGradient(
                              colors: [
                                theme.secondaryColor,
                                theme.secondaryColor.withOpacity(0.8)
                              ],
                            ),
                            icon: Icons.explore,
                          ),
                          const SizedBox(height: 20),
                          _buildGameButton(
                            onPressed: onShowWordDex,
                            text: '📚 Word-Dex',
                            gradient: LinearGradient(
                              colors: [
                                theme.accentColor,
                                theme.accentColor.withOpacity(0.8)
                              ],
                            ),
                            icon: Icons.book,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressionCard() {
    final totalWordsAttempted = stats.totalWords;
    final difficultyDescription =
        DifficultyManager.getDifficultyDescription(totalWordsAttempted);
    final phaseProgress =
        DifficultyManager.getPhaseProgress(totalWordsAttempted);
    final wordsRemaining =
        DifficultyManager.getWordsRemainingInPhase(totalWordsAttempted);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: theme.accentColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Progression',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficultyDescription,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (wordsRemaining > 0)
                      Text(
                        '$wordsRemaining words to next level',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textSecondaryColor,
                        ),
                      )
                    else
                      Text(
                        'Expert level unlocked!',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              CircularProgressIndicator(
                value: phaseProgress.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
                strokeWidth: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildGameButton({
    required VoidCallback onPressed,
    required String text,
    required Gradient gradient,
    Color? textColor,
    bool border = false,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        border:
            border ? Border.all(color: Colors.white.withOpacity(0.2)) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: textColor ?? Colors.white, size: 20),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor ?? Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
