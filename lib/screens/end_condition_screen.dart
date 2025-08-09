import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:super_clipboard/super_clipboard.dart';
import '../models/theme_model.dart';
import '../utils/word_translations.dart';
import 'dart:typed_data';

class EndConditionScreen extends StatefulWidget {
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
  State<EndConditionScreen> createState() => _EndConditionScreenState();
}

class _EndConditionScreenState extends State<EndConditionScreen> {
  final GlobalKey _captureKey = GlobalKey();

  Future<Uint8List> _capturePngBytes() async {
    final boundary =
        _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Consistent action button builder
  Expanded _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: widget.theme.textColor),
          label: Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.theme.surfaceColor,
            foregroundColor: widget.theme.textColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withOpacity(0.15)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareResult() async {
    try {
      final bytes = await _capturePngBytes();

      final tempDir = await getTemporaryDirectory();
      final file = await File(
              '${tempDir.path}/kliem_${DateTime.now().millisecondsSinceEpoch}.png')
          .create();
      await file.writeAsBytes(bytes);

      final verb = widget.won ? 'caught' : 'missed';
      final text =
          'I $verb "${widget.word.toUpperCase()}" in ${widget.attempts}/6 on KLIEM. 🇲🇹';
      await Share.shareXFiles([
        XFile(
          file.path,
          mimeType: 'image/png',
          name: 'kliem_${widget.word.toLowerCase()}.png',
        )
      ], text: text, subject: 'KLIEM');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to share right now.')),
      );
    }
  }

  Future<void> _copyImage() async {
    try {
      final bytes = await _capturePngBytes();
      final item = DataWriterItem();
      item.add(Formats.png(bytes));
      final clipboard = SystemClipboard.instance;
      if (clipboard != null) {
        await clipboard.write([item]);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Image copied')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Failed to copy image')));
    }
  }

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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Capture area (shareable)
                  RepaintBoundary(
                    key: _captureKey,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.theme.backgroundGradient,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        // Result Icon
                        Icon(
                          widget.won ? Icons.check_circle : Icons.cancel,
                          size: 80,
                          color: widget.won ? Colors.green : Colors.red,
                        ),
                        const SizedBox(height: 12),

                        // Result Text
                        Text(
                          widget.won
                              ? 'You found a new word!'
                              : 'The lost a word...',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: widget.theme.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Word Display
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: widget.theme.surfaceColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                widget.word.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: widget.theme.textColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                WordTranslations.getTranslation(widget.word),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: widget.theme.textSecondaryColor,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Rarity Badge (if won)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: WordTranslations.getRarityColor(
                                      WordTranslations.getRarity(widget.word) ??
                                          1)
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: WordTranslations.getRarityColor(
                                    WordTranslations.getRarity(widget.word) ??
                                        1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              WordTranslations.getRarityName(
                                  WordTranslations.getRarity(widget.word) ?? 1),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: WordTranslations.getRarityColor(
                                    WordTranslations.getRarity(widget.word) ??
                                        1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                        // Attempts & date
                        const SizedBox(height: 4),
                        Text(
                          'Attempts: ${widget.attempts}/6  •  ${_formatDate(DateTime.now())}',
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.theme.textSecondaryColor,
                          ),
                        ),

                        // Previously Escaped Message
                        if (widget.won && widget.wasPreviouslyEscaped) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.orange,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.replay,
                                  color: Colors.orange,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
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
                        ],
                        const SizedBox(height: 12),
                        // Watermark
                        Opacity(
                          opacity: 0.9,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: widget.theme.surfaceColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.15)),
                            ),
                            child: Text(
                              'KLIEM',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: widget.theme.textSecondaryColor,
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    children: [
                      _buildActionButton(
                        icon: Icons.copy,
                        label: 'Copy',
                        onPressed: _copyImage,
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.ios_share,
                        label: 'Share',
                        onPressed: _shareResult,
                      ),
                      const SizedBox(width: 12),
                      _buildActionButton(
                        icon: Icons.home_outlined,
                        label: 'Home',
                        onPressed: widget.onBackToMenu,
                      ),
                    ],
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
