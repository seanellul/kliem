import 'package:flutter/material.dart';
import '../models/word_dex.dart';
import '../models/game_stats.dart';
import '../models/theme_model.dart';
import '../utils/word_translations.dart';
import '../utils/maltese_digraphs.dart';

class WordDexDetailScreen extends StatelessWidget {
  final WordDexEntry entry;
  final ThemeModel theme;
  final VoidCallback onBack;
  final GameStats stats;

  const WordDexDetailScreen({
    super.key,
    required this.entry,
    required this.theme,
    required this.onBack,
    required this.stats,
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
              theme.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBack,
                      icon: Icon(Icons.arrow_back, color: theme.textColor),
                    ),
                    Expanded(
                      child: Text(
                        '📚 Word Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // Balance the header
                  ],
                ),
              ),

              // Word Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.surfaceColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    // Main word
                    Text(
                      MalteseDigraphs.formatForDisplay(entry.malteseWord),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.textColor,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Basic translation
                    Text(
                      entry.englishTranslation == 'Unknown'
                          ? WordTranslations.getTranslation(entry.malteseWord)
                          : entry.englishTranslation,
                      style: TextStyle(
                        fontSize: 18,
                        color: theme.textSecondaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    if (WordTranslations.getPhonetic(entry.malteseWord) !=
                        null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '/${WordTranslations.getPhonetic(entry.malteseWord)}/',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[300],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Lexicon Information
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Part of Speech
                      if (WordTranslations.getPartOfSpeech(entry.malteseWord) !=
                          null)
                        _buildInfoCard(
                          'Part of Speech',
                          WordTranslations.getPartOfSpeech(entry.malteseWord)!,
                          Icons.category,
                          Colors.purple,
                        ),

                      // Root
                      if (WordTranslations.getRoot(entry.malteseWord) != null)
                        _buildInfoCard(
                          'Root',
                          WordTranslations.getRoot(entry.malteseWord)!,
                          Icons.forest,
                          Colors.green,
                        ),

                      // Sources
                      if (WordTranslations.getSources(entry.malteseWord)
                          .isNotEmpty)
                        _buildInfoCard(
                          'Sources',
                          WordTranslations.getSources(entry.malteseWord)
                              .join(', '),
                          Icons.source,
                          Colors.orange,
                        ),

                      // Glosses
                      if (WordTranslations.getGlosses(entry.malteseWord)
                          .isNotEmpty) ...[
                        _buildGlossesSection(),
                        const SizedBox(height: 16),
                      ],

                      // Frequency and Rarity
                      if (WordTranslations.getFrequency(entry.malteseWord) !=
                              null ||
                          WordTranslations.getRarity(entry.malteseWord) != null)
                        _buildStatsSection(),

                      // Catch Information
                      _buildCatchInfo(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlossesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.translate, color: Colors.teal, size: 24),
              const SizedBox(width: 12),
              Text(
                'Translations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...WordTranslations.getGlosses(entry.malteseWord)
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key;
            final gloss = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ${gloss['gloss'] ?? ''}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.textColor,
                    ),
                  ),
                  if (gloss['examples'] != null &&
                      (gloss['examples'] as List).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...(gloss['examples'] as List).map((example) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 4),
                          child: Text(
                            '• $example',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textSecondaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          if (WordTranslations.getFrequency(entry.malteseWord) != null)
            Expanded(
              child: _buildStatItem(
                'Frequency',
                WordTranslations.getFrequency(entry.malteseWord)!
                    .toStringAsFixed(2),
                Icons.trending_up,
                Colors.blue,
              ),
            ),
          if (WordTranslations.getRarity(entry.malteseWord) != null) ...[
            if (WordTranslations.getFrequency(entry.malteseWord) != null)
              const SizedBox(width: 16),
            Expanded(
              child: _buildRarityItem(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: theme.textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: theme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRarityItem() {
    final rarity = WordTranslations.getRarity(entry.malteseWord);
    if (rarity == null) return const SizedBox.shrink();

    final rarityName = WordTranslations.getRarityName(rarity);
    final rarityColor = WordTranslations.getRarityColor(rarity);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: rarityColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: rarityColor, width: 1),
          ),
          child: Text(
            rarityName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: rarityColor,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rarity',
          style: TextStyle(
            fontSize: 10,
            color: theme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCatchInfo() {
    final escapeCount = stats.getEscapeCount(entry.malteseWord);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Caught on ${_formatDate(entry.caughtDate)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Attempts: ${entry.attemptsUsed}/6',
                      style: TextStyle(
                        fontSize: 12,
                        color: entry.attemptsUsed <= 3
                            ? Colors.green
                            : entry.attemptsUsed <= 5
                                ? Colors.orange
                                : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (escapeCount > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.replay, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Previously escaped $escapeCount time${escapeCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
