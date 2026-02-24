import 'dart:math';
import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../models/replay_data.dart';
import '../utils/maltese_digraphs.dart';
import '../utils/maltese_words.dart';

enum LetterState { correct, present, absent, empty }

class CellData {
  String letter;
  LetterState state;

  CellData({this.letter = '', this.state = LetterState.empty});
}

class WordleGameScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String targetWord;
  final Function(bool, int, {List<List<CellData>>? gridData}) onGameComplete;
  final ThemeModel theme;
  final bool colorblindMode;
  final ReplayData? replayData;

  const WordleGameScreen({
    super.key,
    required this.onBack,
    required this.targetWord,
    required this.onGameComplete,
    required this.theme,
    this.colorblindMode = false,
    this.replayData,
  });

  @override
  State<WordleGameScreen> createState() => _WordleGameScreenState();
}

class _WordleGameScreenState extends State<WordleGameScreen>
    with SingleTickerProviderStateMixin {
  late List<List<CellData>> grid;
  int currentRow = 0;
  int currentCol = 0;
  bool gameOver = false;
  bool won = false;
  bool _isAnimating = false;
  Map<String, LetterState> keyboardState = {};

  // Shake animation for invalid words
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Pre-computed normalized word set for O(1) lookup
  late final Set<String> _normalizedValidWords;

  final List<List<String>> malteseKeyboard = [
    ['Q', 'W', 'E', 'R', 'T', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', '\u0120', 'H', '\u0126', 'J', 'K', 'L'],
    ['Z', '\u017B', 'X', '\u010A', 'V', 'B', 'N', 'M', 'DELETE']
  ];

  @override
  void initState() {
    super.initState();
    _initializeGrid();
    _normalizedValidWords = MalteseWords.getWords()
        .map((w) => w.toUpperCase())
        .toSet();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  bool get _isReplayMode => widget.replayData != null;

  void _initializeGrid() {
    grid = List.generate(6, (row) {
      return List.generate(5, (col) => CellData());
    });

    // In replay mode, pre-fill row 0 with the hint row
    if (widget.replayData != null) {
      final hintRow = widget.replayData!.hintRow;
      for (int i = 0; i < 5 && i < hintRow.length; i++) {
        grid[0][i] = CellData(
          letter: hintRow[i].letter,
          state: hintRow[i].state,
        );
      }
      currentRow = 1;
      currentCol = 0;
      _populateKeyboardFromHintRow(hintRow);
    }
  }

  void _populateKeyboardFromHintRow(List<CellData> hintRow) {
    for (final cell in hintRow) {
      if (cell.letter.isEmpty) continue;
      if (cell.letter == 'IE') {
        _updateKeyboardState('I', cell.state, keyboardState);
        _updateKeyboardState('E', cell.state, keyboardState);
      } else if (cell.letter == 'G\u0126') {
        _updateKeyboardState('G', cell.state, keyboardState);
        _updateKeyboardState('\u0126', cell.state, keyboardState);
      } else {
        _updateKeyboardState(cell.letter, cell.state, keyboardState);
      }
    }
  }

  void handleKeyPress(String key) {
    if (gameOver || _isAnimating) return;

    if (key == 'ENTER') {
      if (currentCol == 5) {
        submitGuess();
      }
    } else if (key == 'DELETE') {
      if (currentCol > 0) {
        setState(() {
          // Check if we're deleting a digraph
          final currentCell = grid[currentRow][currentCol - 1];
          if (currentCell.letter == 'IE' || currentCell.letter == 'G\u0126') {
            // Delete the entire digraph
            grid[currentRow][currentCol - 1] = CellData();
            currentCol--;
          } else {
            // Check if previous cell is part of a digraph
            if (currentCol > 1) {
              final prevCell = grid[currentRow][currentCol - 2];
              if ((prevCell.letter == 'I' && currentCell.letter == 'E') ||
                  (prevCell.letter == 'G' && currentCell.letter == '\u0126')) {
                // Delete both parts of the digraph
                grid[currentRow][currentCol - 2] = CellData();
                grid[currentRow][currentCol - 1] = CellData();
                currentCol -= 2;
              } else {
                // Delete single letter
                grid[currentRow][currentCol - 1] = CellData();
                currentCol--;
              }
            } else {
              // Delete single letter
              grid[currentRow][currentCol - 1] = CellData();
              currentCol--;
            }
          }
        });
      }
    } else if (currentCol < 5) {
      setState(() {
        // Check if this key could be part of a digraph
        if (key == 'I' || key == 'G') {
          // Store the first part of potential digraph
          grid[currentRow][currentCol] = CellData(letter: key);
          currentCol++;
        } else if (key == 'E' && currentCol > 0) {
          // Check if previous letter was 'I'
          final prevCell = grid[currentRow][currentCol - 1];
          if (prevCell.letter == 'I') {
            // Form the digraph 'IE'
            grid[currentRow][currentCol - 1] = CellData(letter: 'IE');
            // Don't increment currentCol since we're replacing the previous cell
          } else {
            // Regular 'E'
            grid[currentRow][currentCol] = CellData(letter: key);
            currentCol++;
          }
        } else if (key == '\u0126' && currentCol > 0) {
          // Check if previous letter was 'G'
          final prevCell = grid[currentRow][currentCol - 1];
          if (prevCell.letter == 'G') {
            // Form the digraph 'GH'
            grid[currentRow][currentCol - 1] = CellData(letter: 'G\u0126');
            // Don't increment currentCol since we're replacing the previous cell
          } else {
            // Regular 'H'
            grid[currentRow][currentCol] = CellData(letter: key);
            currentCol++;
          }
        } else {
          // Regular letter
          grid[currentRow][currentCol] = CellData(letter: key);
          currentCol++;
        }
      });
    }
  }

  bool _isValidWord(String guess) {
    return _normalizedValidWords.contains(guess.toUpperCase());
  }

  void submitGuess() {
    // Get the guess as individual letters (including digraphs)
    final guessLetters = grid[currentRow]
        .where((cell) => cell.letter.isNotEmpty)
        .map((cell) => cell.letter)
        .toList();

    // Join letters and normalize
    final guess = MalteseDigraphs.joinLetters(guessLetters).toLowerCase();

    // Validate against word list
    if (!_isValidWord(guess)) {
      _shakeController.forward();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text(
              'Not in word list',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF424242),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            width: 200,
          ),
        );
      return;
    }

    // Lock input during animation
    _isAnimating = true;

    final newKeyboardState = Map<String, LetterState>.from(keyboardState);

    // Split target into letters for comparison
    final targetLetters = MalteseDigraphs.splitIntoLetters(widget.targetWord);
    final guessLetterList =
        MalteseDigraphs.splitIntoLetters(guess.toUpperCase());

    // Check each letter with animation delay
    for (int i = 0; i < 5; i++) {
      final guessLetter = i < guessLetterList.length ? guessLetterList[i] : '';
      final targetLetter = i < targetLetters.length ? targetLetters[i] : '';
      LetterState state = LetterState.absent;

      if (targetLetter == guessLetter && guessLetter.isNotEmpty) {
        state = LetterState.correct;
      } else if (targetLetters.contains(guessLetter) &&
          guessLetter.isNotEmpty) {
        state = LetterState.present;
      }

      // Animate each cell with a slight delay
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          setState(() {
            grid[currentRow][i].state = state;
          });
        }
      });

      // Update keyboard state for individual characters
      if (guessLetter.isNotEmpty) {
        // For digraphs, update both individual characters
        if (guessLetter == 'IE') {
          _updateKeyboardState('I', state, newKeyboardState);
          _updateKeyboardState('E', state, newKeyboardState);
        } else if (guessLetter == 'G\u0126') {
          _updateKeyboardState('G', state, newKeyboardState);
          _updateKeyboardState('\u0126', state, newKeyboardState);
        } else {
          _updateKeyboardState(guessLetter, state, newKeyboardState);
        }
      }
    }

    // Update keyboard state after animations
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          keyboardState = newKeyboardState;
        });
      }
    });

    // Check if won after animations complete
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        // Compare normalized words
        final normalizedGuess = MalteseDigraphs.normalizeWord(guess);
        final normalizedTarget =
            MalteseDigraphs.normalizeWord(widget.targetWord);

        if (normalizedGuess == normalizedTarget) {
          setState(() {
            won = true;
            gameOver = true;
            _isAnimating = false;
          });
          widget.onGameComplete(true, currentRow + 1);
        } else if (currentRow == 5) {
          setState(() {
            gameOver = true;
            _isAnimating = false;
          });
          widget.onGameComplete(false, 6, gridData: grid);
        } else {
          setState(() {
            currentRow++;
            currentCol = 0;
            _isAnimating = false;
          });
        }
      }
    });
  }

  void _updateKeyboardState(String letter, LetterState state,
      Map<String, LetterState> keyboardState) {
    // Update keyboard state (only upgrade, never downgrade)
    if (!keyboardState.containsKey(letter) ||
        (keyboardState[letter] == LetterState.absent &&
            state != LetterState.absent) ||
        (keyboardState[letter] == LetterState.present &&
            state == LetterState.correct)) {
      keyboardState[letter] = state;
    }
  }

  void resetGame() {
    setState(() {
      _initializeGrid();
      currentRow = 0;
      currentCol = 0;
      gameOver = false;
      won = false;
      _isAnimating = false;
      keyboardState.clear();
    });
  }

  Color getCellColor(LetterState state) {
    switch (state) {
      case LetterState.correct:
        return widget.colorblindMode
            ? ThemeModel.colorblindCorrect
            : widget.theme.correctColor;
      case LetterState.present:
        return widget.colorblindMode
            ? ThemeModel.colorblindPresent
            : widget.theme.presentColor;
      case LetterState.absent:
        return widget.colorblindMode
            ? ThemeModel.colorblindAbsent
            : widget.theme.absentColor;
      case LetterState.empty:
        return Colors.transparent;
    }
  }

  Color getKeyColor(String key) {
    final state = keyboardState[key];
    switch (state) {
      case LetterState.correct:
        return widget.colorblindMode
            ? ThemeModel.colorblindCorrect
            : widget.theme.correctColor;
      case LetterState.present:
        return widget.colorblindMode
            ? ThemeModel.colorblindPresent
            : widget.theme.presentColor;
      case LetterState.absent:
        return widget.colorblindMode
            ? ThemeModel.colorblindAbsent
            : widget.theme.absentColor;
      default:
        return widget.theme.surfaceColor;
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
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: widget.onBack,
                      icon: Icon(Icons.arrow_back,
                          color: widget.theme.textColor, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Game Grid
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: grid.asMap().entries.map((rowEntry) {
                              final rowIndex = rowEntry.key;
                              final row = rowEntry.value;
                              final isCurrentRow = rowIndex == currentRow;
                              final isLockedHintRow = _isReplayMode && rowIndex == 0;
                              return AnimatedBuilder(
                                animation: _shakeAnimation,
                                builder: (context, child) {
                                  double offset = 0;
                                  if (isCurrentRow &&
                                      _shakeController.isAnimating) {
                                    offset = sin(_shakeAnimation.value *
                                            3 *
                                            pi) *
                                        8;
                                  }
                                  return Transform.translate(
                                    offset: Offset(offset, 0),
                                    child: child,
                                  );
                                },
                                child: Opacity(
                                  opacity: isLockedHintRow ? 0.6 : 1.0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (isLockedHintRow)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 4),
                                            child: Icon(
                                              Icons.lock,
                                              size: 14,
                                              color: widget.theme.textColor.withOpacity(0.5),
                                            ),
                                          ),
                                        ...row.asMap().entries.map((colEntry) {
                                          final cell = colEntry.value;
                                          return Container(
                                            width: 52,
                                            height: 52,
                                            margin: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: getCellColor(cell.state),
                                              border: Border.all(
                                                color:
                                                    cell.state == LetterState.empty
                                                        ? const Color(0xFF9CA3AF)
                                                        : getCellColor(cell.state),
                                                width: 2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Center(
                                              child: Text(
                                                cell.letter,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: cell.state ==
                                                          LetterState.empty
                                                      ? widget.theme.textColor
                                                      : Colors.white,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),

                        // Game Status
                        if (gameOver)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: won
                                    ? const Color(0xFF22C55E).withOpacity(0.2)
                                    : const Color(0xFFEF4444).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: won
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFEF4444),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                won ? 'Word Caught! \u{1F389}' : 'Word Escaped! \u{1F4A8}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: won
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFEF4444),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Virtual Keyboard
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Letter Keys
                      Column(
                        children:
                            malteseKeyboard.asMap().entries.map((rowEntry) {
                          final row = rowEntry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: row.map((key) {
                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    child: Material(
                                      color: getKeyColor(key),
                                      borderRadius: BorderRadius.circular(8),
                                      child: InkWell(
                                        onTap: () => handleKeyPress(key),
                                        borderRadius: BorderRadius.circular(8),
                                        child: SizedBox(
                                          height: 45,
                                          child: Center(
                                            child: Text(
                                              key == 'DELETE' ? '\u232B' : key,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: widget.theme.textColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }).toList(),
                      ),

                      // ENTER Button at bottom
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: currentCol == 5 && !_isAnimating
                                      ? widget.theme.primaryButtonGradient
                                      : [
                                          widget.theme.surfaceColor,
                                          widget.theme.surfaceColor,
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.15),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: currentCol == 5 && !_isAnimating
                                      ? () => handleKeyPress('ENTER')
                                      : null,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Center(
                                    child: Text(
                                      'ENTER',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: widget.theme.textColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
