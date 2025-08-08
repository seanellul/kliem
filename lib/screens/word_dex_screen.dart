import 'package:flutter/material.dart';
import '../models/word_dex.dart';
import '../models/game_stats.dart';
import '../models/theme_model.dart';
import '../utils/word_translations.dart';
import '../utils/maltese_digraphs.dart';
import 'word_dex_detail_screen.dart';

enum SortOption { alphabetical, rarity, date }

class WordDexScreen extends StatefulWidget {
  final WordDex wordDex;
  final ThemeModel theme;
  final VoidCallback onBack;
  final GameStats stats;

  const WordDexScreen({
    super.key,
    required this.wordDex,
    required this.theme,
    required this.onBack,
    required this.stats,
  });

  @override
  State<WordDexScreen> createState() => _WordDexScreenState();
}

class _WordDexScreenState extends State<WordDexScreen> {
  SortOption _currentSort = SortOption.date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.theme.primaryColor,
              widget.theme.primaryColor.withOpacity(0.8),
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
                      onPressed: widget.onBack,
                      icon:
                          Icon(Icons.arrow_back, color: widget.theme.textColor),
                    ),
                    Expanded(
                      child: Text(
                        '📚 Word-Dex',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: widget.theme.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      onPressed: _showSortDialog,
                      icon: Icon(Icons.sort, color: widget.theme.textColor),
                    ),
                  ],
                ),
              ),

              // Stats Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.theme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Caught', '${widget.wordDex.totalWords}',
                            Icons.check_circle, Colors.green),
                        _buildStatItem(
                            'Progress',
                            '${((widget.wordDex.totalWords / 2111) * 100).round()}%',
                            Icons.trending_up,
                            Colors.orange),
                      ],
                    ),
                    if (widget.wordDex.totalWords > 0) ...[
                      const SizedBox(height: 12),
                      _buildRaritySummary(),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Words List
              Expanded(
                child: widget.wordDex.allEntries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 64,
                              color: widget.theme.textColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No words caught yet!',
                              style: TextStyle(
                                fontSize: 18,
                                color: widget.theme.textColor.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Start playing to catch words!',
                              style: TextStyle(
                                fontSize: 14,
                                color: widget.theme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _getSortedEntries().length,
                        itemBuilder: (context, index) {
                          final entry = _getSortedEntries()[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: widget.theme.surfaceColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.1)),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WordDexDetailScreen(
                                      entry: entry,
                                      theme: widget.theme,
                                      onBack: () => Navigator.pop(context),
                                      stats: widget.stats,
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                title: Text(
                                  MalteseDigraphs.formatForDisplay(
                                      entry.malteseWord),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: widget.theme.textColor,
                                  ),
                                ),
                                subtitle: Text(
                                  entry.englishTranslation == 'Unknown'
                                      ? WordTranslations.getTranslation(
                                          entry.malteseWord)
                                      : entry.englishTranslation,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: widget.theme.textSecondaryColor,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (WordTranslations.getPhonetic(
                                                entry.malteseWord) !=
                                            null ||
                                        WordTranslations.getPartOfSpeech(
                                                entry.malteseWord) !=
                                            null ||
                                        WordTranslations.getRoot(
                                                entry.malteseWord) !=
                                            null)
                                      const SizedBox(width: 8),
                                    if (entry.rarity != null)
                                      const SizedBox(width: 8),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (entry.rarity != null)
                                          Text(
                                            _formatDate(entry.caughtDate),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: widget
                                                  .theme.textSecondaryColor,
                                            ),
                                          ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color:
                                                WordTranslations.getRarityColor(
                                                        entry.rarity!)
                                                    .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                              color: WordTranslations
                                                  .getRarityColor(
                                                      entry.rarity!),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            WordTranslations.getRarityName(
                                                entry.rarity!),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: WordTranslations
                                                  .getRarityColor(
                                                      entry.rarity!),
                                            ),
                                          ),
                                        ),
                                        // const SizedBox(height: 4),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: widget.theme.textColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: widget.theme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildRaritySummary() {
    // Count words by rarity
    final rarityCounts = <int, int>{};
    for (final entry in widget.wordDex.allEntries) {
      if (entry.rarity != null) {
        rarityCounts[entry.rarity!] = (rarityCounts[entry.rarity!] ?? 0) + 1;
      }
    }

    // Find the rarest word caught
    int? rarestRarity;
    if (rarityCounts.isNotEmpty) {
      rarestRarity = rarityCounts.keys.reduce((a, b) => a > b ? a : b);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        if (rarestRarity != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: WordTranslations.getRarityColor(rarestRarity)
                  .withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: WordTranslations.getRarityColor(rarestRarity),
                width: 1,
              ),
            ),
            child: Text(
              'Rarest: ${WordTranslations.getRarityName(rarestRarity)}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: WordTranslations.getRarityColor(rarestRarity),
              ),
            ),
          ),
        ],
        Text(
          '${rarityCounts.length} rarity levels',
          style: TextStyle(
            fontSize: 10,
            color: widget.theme.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: widget.theme.surfaceColor,
          title: Text(
            'Sort Words',
            style: TextStyle(
              color: widget.theme.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption(SortOption.date, 'By Date (Newest First)'),
              _buildSortOption(SortOption.alphabetical, 'Alphabetically'),
              _buildSortOption(SortOption.rarity, 'By Rarity (Rarest First)'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(SortOption option, String title) {
    final isSelected = _currentSort == option;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Colors.blue : widget.theme.textSecondaryColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? widget.theme.textColor
              : widget.theme.textSecondaryColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() {
          _currentSort = option;
        });
        Navigator.of(context).pop();
      },
    );
  }

  List<WordDexEntry> _getSortedEntries() {
    final entries = List<WordDexEntry>.from(widget.wordDex.allEntries);

    switch (_currentSort) {
      case SortOption.alphabetical:
        entries.sort((a, b) => a.malteseWord.compareTo(b.malteseWord));
        break;
      case SortOption.rarity:
        entries.sort((a, b) {
          final aRarity = a.rarity ?? 0;
          final bRarity = b.rarity ?? 0;
          return bRarity.compareTo(aRarity); // Rarest first
        });
        break;
      case SortOption.date:
        entries.sort(
            (a, b) => b.caughtDate.compareTo(a.caughtDate)); // Newest first
        break;
    }

    return entries;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
