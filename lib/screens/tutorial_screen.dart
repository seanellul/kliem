import 'package:flutter/material.dart';
import 'dart:async';
import '../models/theme_model.dart';

class TutorialScreen extends StatefulWidget {
  final ThemeModel theme;
  final VoidCallback onComplete;

  const TutorialScreen({
    super.key,
    required this.theme,
    required this.onComplete,
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  String _currentGuess = '';
  List<String> _guesses = [];
  List<List<LetterState>> _guessStates = [];
  bool _isAnimating = false;
  String _instructions = '';
  bool _canInput = true;
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;

  // Tutorial steps and expected states
  final List<TutorialStep> _steps = [
    TutorialStep(
      guess: 'HOUSE',
      instruction: "Let's start with your first guess. Try typing 'HOUSE'",
      expectedStates: [
        LetterState.absent,
        LetterState.absent,
        LetterState.absent,
        LetterState.absent,
        LetterState.present
      ],
    ),
    TutorialStep(
      guess: 'FLAME',
      instruction:
          "Good! The 'E' is in the word but wrong position. Try 'FLAME'",
      expectedStates: [
        LetterState.absent,
        LetterState.present,
        LetterState.correct,
        LetterState.correct,
        LetterState.correct
      ],
    ),
    TutorialStep(
      guess: 'KELMA',
      instruction: "Excellent! Now you can see the pattern. Try 'KELMA'",
      expectedStates: [
        LetterState.correct,
        LetterState.correct,
        LetterState.correct,
        LetterState.correct,
        LetterState.correct
      ],
    ),
  ];

  final List<List<String>> _keyboard = [
    ['Q', 'W', 'E', 'R', 'T', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'Ġ', 'H', 'Ħ', 'J', 'K', 'L'],
    ['Z', 'Ż', 'X', 'Ċ', 'V', 'B', 'N', 'M', 'DELETE']
  ];

  Map<String, LetterState> _keyboardStates = {};

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _shakeAnimation = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _startTutorial();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _startTutorial() {
    setState(() {
      _instructions = _steps[_currentStep].instruction;
    });
    _pulseController.repeat(reverse: true);
  }

  void _onKeyPressed(String key) {
    if (!_canInput || _isAnimating) return;

    if (key == 'ENTER') {
      _submitGuess();
    } else if (key == 'DELETE') {
      _deleteLastLetter();
    } else if (_currentGuess.length < 5) {
      _addLetter(key);
    }
  }

  void _addLetter(String letter) {
    if (_currentGuess.length < 5) {
      setState(() {
        _currentGuess += letter;
      });
    }
  }

  void _deleteLastLetter() {
    if (_currentGuess.isNotEmpty) {
      setState(() {
        _currentGuess = _currentGuess.substring(0, _currentGuess.length - 1);
      });
    }
  }

  void _submitGuess() async {
    if (_currentGuess.length != 5) {
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });
      return;
    }

    final expectedGuess = _steps[_currentStep].guess;
    if (_currentGuess.toUpperCase() != expectedGuess) {
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });
      _showHint(expectedGuess);
      return;
    }

    setState(() {
      _isAnimating = true;
      _canInput = false;
    });

    // Add guess and calculate states
    _guesses.add(_currentGuess);
    final states = _steps[_currentStep].expectedStates;
    _guessStates.add(states);

    // Update keyboard states
    for (int i = 0; i < _currentGuess.length; i++) {
      final letter = _currentGuess[i];
      final state = states[i];
      if (_keyboardStates[letter] == null ||
          state.index > (_keyboardStates[letter]?.index ?? 0)) {
        _keyboardStates[letter] = state;
      }
    }

    // Animate the reveal
    await _animateGuessReveal();

    setState(() {
      _currentGuess = '';
      _isAnimating = false;
    });

    // Check if tutorial is complete
    if (_currentStep == _steps.length - 1) {
      _completeTutorial();
    } else {
      _nextStep();
    }
  }

  Future<void> _animateGuessReveal() async {
    // Simulate the letter-by-letter reveal animation
    for (int i = 0; i < 5; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      // Letter reveal animation would go here
    }
  }

  void _nextStep() {
    setState(() {
      _currentStep++;
      _instructions = _steps[_currentStep].instruction;
      _canInput = true;
    });
  }

  void _completeTutorial() async {
    setState(() {
      _instructions = "Congratulations! You've mastered the basics of Kliem!";
    });

    await Future.delayed(const Duration(seconds: 2));
    widget.onComplete();
  }

  void _showHint(String expectedWord) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: widget.theme.surfaceColor,
        title: Text(
          'Tutorial Hint',
          style: TextStyle(color: widget.theme.textColor),
        ),
        content: Text(
          'For this tutorial, try typing: $expectedWord',
          style: TextStyle(color: widget.theme.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it!',
              style: TextStyle(color: widget.theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0 && details.primaryDelta! > 8) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.theme.primaryColor,
                widget.theme.primaryColor.withOpacity(0.8),
                widget.theme.primaryColor.withOpacity(0.6),
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
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Interactive Tutorial',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Step ${_currentStep + 1}/${_steps.length}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Instructions
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: widget.theme.accentColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          _instructions,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // Game Board (grid only)
                Expanded(
                  child: Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: widget.theme.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _buildWordGrid(),
                      ),
                    ),
                  ),
                ),

                // Virtual Keyboard (separate, like main game)
                _buildKeyboard(),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWordGrid() {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: List.generate(6, (rowIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (colIndex) {
                String letter = '';
                LetterState state = LetterState.empty;

                if (rowIndex < _guesses.length) {
                  letter = _guesses[rowIndex][colIndex];
                  state = _guessStates[rowIndex][colIndex];
                } else if (rowIndex == _guesses.length &&
                    colIndex < _currentGuess.length) {
                  letter = _currentGuess[colIndex];
                  state = LetterState.input;
                }

                return AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: rowIndex == _guesses.length
                          ? Offset(_shakeAnimation.value, 0)
                          : Offset.zero,
                      child: _buildLetterTile(letter, state),
                    );
                  },
                );
              }),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLetterTile(String letter, LetterState state) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    switch (state) {
      case LetterState.empty:
        backgroundColor = Colors.transparent;
        borderColor = const Color(0xFF9CA3AF); // Same gray as main game
        textColor = widget.theme.textColor;
        break;
      case LetterState.input:
        backgroundColor = Colors.transparent;
        borderColor = widget.theme.textColor.withOpacity(0.6);
        textColor = widget.theme.textColor;
        break;
      case LetterState.absent:
        backgroundColor = const Color(0xFF4B5563); // Same as main game
        borderColor = const Color(0xFF4B5563);
        textColor = Colors.white;
        break;
      case LetterState.present:
        backgroundColor = const Color(0xFFEAB308); // Same as main game
        borderColor = const Color(0xFFEAB308);
        textColor = Colors.white;
        break;
      case LetterState.correct:
        backgroundColor = const Color(0xFF22C55E); // Same as main game
        borderColor = const Color(0xFF22C55E);
        textColor = Colors.white;
        break;
    }

    return Container(
      width: 52, // Same size as main game
      height: 52,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6), // Same radius as main game
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 20, // Same size as main game
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Letter Keys
          Column(
            children: _keyboard.asMap().entries.map((rowEntry) {
              final row = rowEntry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: row.map((key) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        child: Material(
                          color: _getKeyColor(key),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () => _onKeyPressed(key),
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
                color: _currentGuess.length == 5
                    ? const Color(0xFF22C55E)
                    : const Color(0xFF6B7280),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: _currentGuess.length == 5
                      ? () => _onKeyPressed('ENTER')
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
    );
  }

  // Match main game keyboard key coloring
  Color _getKeyColor(String key) {
    final state = _keyboardStates[key];
    switch (state) {
      case LetterState.correct:
        return const Color(0xFF22C55E);
      case LetterState.present:
        return const Color(0xFFEAB308);
      case LetterState.absent:
        return const Color(0xFF4B5563);
      case LetterState.empty:
      case LetterState.input:
      default:
        return widget.theme.surfaceColor;
    }
  }
}

class TutorialStep {
  final String guess;
  final String instruction;
  final List<LetterState> expectedStates;

  TutorialStep({
    required this.guess,
    required this.instruction,
    required this.expectedStates,
  });
}

enum LetterState {
  empty,
  input,
  absent,
  present,
  correct,
}
