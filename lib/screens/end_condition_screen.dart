import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../utils/word_translations.dart';

class EndConditionScreen extends StatelessWidget {
  final bool won;
  final String word;
  final int attempts;
  final ThemeModel theme;
  final VoidCallback onBackToMenu;
  final bool wasPreviouslyEscaped;

  const EndConditionScreen({
    super.key,
    required this.won,
    required this.word,
    required this.attempts,
    required this.theme,
    required this.onBackToMenu,
    required this.wasPreviouslyEscaped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor,
              theme.primaryColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Result Icon
                  Icon(
                    won ? Icons.check_circle : Icons.cancel,
                    size: 80,
                    color: won ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 24),

                  // Result Text
                  Text(
                    won
                        ? 'You have captured the word!'
                        : 'The word has escaped...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Word Display
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          word.toUpperCase(),
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          WordTranslations.getTranslation(word),
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textSecondaryColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rarity Badge (if won)
                  if (won) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: WordTranslations.getRarityColor(
                                WordTranslations.getRarity(word) ?? 1)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: WordTranslations.getRarityColor(
                              WordTranslations.getRarity(word) ?? 1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        WordTranslations.getRarityName(
                            WordTranslations.getRarity(word) ?? 1),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: WordTranslations.getRarityColor(
                              WordTranslations.getRarity(word) ?? 1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Attempts (if won)
                  if (won) ...[
                    Text(
                      'Attempts: $attempts/6',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Previously Escaped Message
                  if (won && wasPreviouslyEscaped) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.replay,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Previously escaped!',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Back to Menu Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onBackToMenu,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.surfaceColor,
                        foregroundColor: theme.textColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Back to Main Menu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
