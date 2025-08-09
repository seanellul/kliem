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
            colors: widget.theme.backgroundGradient,
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

              // Stats Card (aligned and animated)
              Builder(builder: (context) {
                // Compute rarity data
                final rarityCounts = <int, int>{};
                for (final entry in widget.wordDex.allEntries) {
                  if (entry.rarity != null) {
                    rarityCounts[entry.rarity!] =
                        (rarityCounts[entry.rarity!] ?? 0) + 1;
                  }
                }
                int? rarestRarity;
                if (rarityCounts.isNotEmpty) {
                  rarestRarity =
                      rarityCounts.keys.reduce((a, b) => a > b ? a : b);
                }

                final totalCaught = widget.wordDex.totalWords;
                final progressPct =
                    ((totalCaught / 2111) * 100).clamp(0, 100).round();
                final rarityLevels = rarityCounts.length;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.theme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSummaryStat(
                          icon: Icons.check_circle,
                          iconColor: Colors.green,
                          label: 'Caught',
                          value: totalCaught.toDouble(),
                          format: (v) => v.toInt().toString(),
                          extra: rarestRarity != null
                              ? _rarityChip(
                                  'Rarest: ' +
                                      WordTranslations.getRarityName(
                                          rarestRarity),
                                  WordTranslations.getRarityColor(rarestRarity))
                              : _infoPill('No words yet'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildSummaryStat(
                          icon: Icons.trending_up,
                          iconColor: Colors.orange,
                          label: 'Progress',
                          value: progressPct.toDouble(),
                          format: (v) => '${v.toInt()}%',
                          extra: _infoPill(
                              '$rarityLevels rarity level${rarityLevels == 1 ? '' : 's'}'),
                        ),
                      ),
                    ],
                  ),
                );
              }),

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
                          return _buildEntryItem(entry, index);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Summary stat with animated value and aligned extra content
  Widget _buildSummaryStat({
    required IconData icon,
    required Color iconColor,
    required String label,
    required double value,
    required String Function(double) format,
    Widget? extra,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, v, _) => Text(
            format(v),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: widget.theme.textColor,
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: widget.theme.textSecondaryColor,
          ),
        ),
        const SizedBox(height: 8),
        if (extra != null) extra,
      ],
    );
  }

  Widget _infoPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: widget.theme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: widget.theme.textSecondaryColor,
        ),
      ),
    );
  }

  Widget _rarityChip(String label, Color color) {
    // Theme-aware chip: blends with surface to avoid clashes
    final blendedBg = Color.alphaBlend(
        color.withOpacity(0.18), (widget.theme.surfaceColor.withOpacity(0.9)));
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: blendedBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEntryItem(WordDexEntry entry, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 250 + (index * 40).clamp(0, 400)),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - t)),
          child: child,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: widget.theme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Accent bar
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(colors: [
                      widget.theme.accentColor.withOpacity(0.8),
                      widget.theme.primaryColor.withOpacity(0.6),
                    ]),
                  ),
                ),
                const SizedBox(width: 12),
                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MalteseDigraphs.formatForDisplay(entry.malteseWord),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.theme.textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.englishTranslation == 'Unknown'
                            ? WordTranslations.getTranslation(entry.malteseWord)
                            : entry.englishTranslation,
                        style: TextStyle(
                          fontSize: 13,
                          color: widget.theme.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(entry.caughtDate),
                      style: TextStyle(
                        fontSize: 10,
                        color: widget.theme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (entry.rarity != null)
                      _rarityChip(
                        WordTranslations.getRarityName(entry.rarity!),
                        WordTranslations.getRarityColor(entry.rarity!),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
