import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../utils/maltese_digraphs.dart';

enum LetterState { correct, present, absent, empty }

class CellData {
  String letter;
  LetterState state;

  CellData({this.letter = '', this.state = LetterState.empty});
}

class WordleGameScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String targetWord;
  final Function(bool, int) onGameComplete;
  final ThemeModel theme;

  const WordleGameScreen({
    super.key,
    required this.onBack,
    required this.targetWord,
    required this.onGameComplete,
    required this.theme,
  });

  @override
  State<WordleGameScreen> createState() => _WordleGameScreenState();
}

class _WordleGameScreenState extends State<WordleGameScreen> {
  late List<List<CellData>> grid;
  int currentRow = 0;
  int currentCol = 0;
  bool gameOver = false;
  bool won = false;
  Map<String, LetterState> keyboardState = {};

  final List<List<String>> malteseKeyboard = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'Ġ', 'H', 'Ħ', 'J', 'K', 'L'],
    ['Z', 'Ż', 'X', 'C', 'V', 'B', 'N', 'M', 'DELETE']
  ];

  @override
  void initState() {
    super.initState();
    _initializeGrid();
  }

  void _initializeGrid() {
    grid = List.generate(6, (row) {
      return List.generate(5, (col) => CellData());
    });
  }

  void handleKeyPress(String key) {
    if (gameOver) return;

    if (key == 'ENTER') {
      if (currentCol == 5) {
        submitGuess();
      }
    } else if (key == 'DELETE') {
      if (currentCol > 0) {
        setState(() {
          // Check if we're deleting a digraph
          final currentCell = grid[currentRow][currentCol - 1];
          if (currentCell.letter == 'Ie' || currentCell.letter == 'Għ') {
            // Delete the entire digraph
            grid[currentRow][currentCol - 1] = CellData();
            currentCol--;
          } else {
            // Check if previous cell is part of a digraph
            if (currentCol > 1) {
              final prevCell = grid[currentRow][currentCol - 2];
              if ((prevCell.letter == 'I' && currentCell.letter == 'E') ||
                  (prevCell.letter == 'G' && currentCell.letter == 'Ħ')) {
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
            // Form the digraph 'Ie'
            grid[currentRow][currentCol - 1] = CellData(letter: 'IE');
            // Don't increment currentCol since we're replacing the previous cell
          } else {
            // Regular 'E'
            grid[currentRow][currentCol] = CellData(letter: key);
            currentCol++;
          }
        } else if (key == 'Ħ' && currentCol > 0) {
          // Check if previous letter was 'G'
          final prevCell = grid[currentRow][currentCol - 1];
          if (prevCell.letter == 'G') {
            // Form the digraph 'Għ'
            grid[currentRow][currentCol - 1] = CellData(letter: 'GĦ');
            // Don't increment currentCol since we're replacing the previous cell
          } else {
            // Regular 'Ħ'
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

  void submitGuess() {
    // Get the guess as individual letters (including digraphs)
    final guessLetters = grid[currentRow]
        .where((cell) => cell.letter.isNotEmpty)
        .map((cell) => cell.letter)
        .toList();

    // Join letters and normalize
    final guess = MalteseDigraphs.joinLetters(guessLetters).toLowerCase();
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
        if (guessLetter == 'Ie') {
          _updateKeyboardState('I', state, newKeyboardState);
          _updateKeyboardState('E', state, newKeyboardState);
        } else if (guessLetter == 'Għ') {
          _updateKeyboardState('G', state, newKeyboardState);
          _updateKeyboardState('Ħ', state, newKeyboardState);
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
          });
          widget.onGameComplete(true, currentRow + 1);
        } else if (currentRow == 5) {
          setState(() {
            gameOver = true;
          });
          widget.onGameComplete(false, 6);
        } else {
          setState(() {
            currentRow++;
            currentCol = 0;
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
      keyboardState.clear();
    });
  }

  Color getCellColor(LetterState state) {
    switch (state) {
      case LetterState.correct:
        return const Color(0xFF22C55E); // Green-500
      case LetterState.present:
        return const Color(0xFFEAB308); // Yellow-500
      case LetterState.absent:
        return const Color(0xFF4B5563); // Gray-600
      case LetterState.empty:
        return Colors.transparent;
    }
  }

  Color getKeyColor(String key) {
    final state = keyboardState[key];
    switch (state) {
      case LetterState.correct:
        return const Color(0xFF22C55E); // Green-500
      case LetterState.present:
        return const Color(0xFFEAB308); // Yellow-500
      case LetterState.absent:
        return const Color(0xFF4B5563); // Gray-600
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
            colors: [
              widget.theme.primaryColor,
              widget.theme.primaryColor.withValues(alpha: 0.8),
            ],
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
                      icon:
                          Icon(Icons.arrow_back, color: widget.theme.textColor),
                    ),
                    Text(
                      'kelma.mt',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.textColor,
                      ),
                    ),
                    IconButton(
                      onPressed: resetGame,
                      icon: Icon(Icons.refresh, color: widget.theme.textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Game Grid
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: grid.asMap().entries.map((rowEntry) {
                              final row = rowEntry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: row.asMap().entries.map((colEntry) {
                                    final cell = colEntry.value;
                                    return Container(
                                      width: 52,
                                      height: 52,
                                      margin: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: getCellColor(cell.state),
                                        border: Border.all(
                                          color: cell.state == LetterState.empty
                                              ? const Color(0xFF9CA3AF)
                                              : getCellColor(cell.state),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Center(
                                        child: Text(
                                          cell.letter,
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                cell.state == LetterState.empty
                                                    ? widget.theme.textColor
                                                    : Colors.white,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
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
                                    ? const Color(0xFF22C55E)
                                        .withValues(alpha: 0.2)
                                    : const Color(0xFFEF4444)
                                        .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: won
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFEF4444),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                won ? 'Word Caught! 🎉' : 'Word Escaped! 💨',
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
                                              key == 'DELETE' ? '⌫' : key,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
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
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: Material(
                            color: currentCol == 5
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF6B7280),
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: currentCol == 5
                                  ? () => handleKeyPress('ENTER')
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                              child: Center(
                                child: Text(
                                  'ENTER',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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
