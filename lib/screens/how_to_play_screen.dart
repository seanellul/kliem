import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../widgets/slide_route.dart';
import 'tutorial_screen.dart';

class HowToPlayScreen extends StatefulWidget {
  final ThemeModel theme;
  final VoidCallback onBack;
  final bool showSkipButton;
  final VoidCallback? onSkip;
  final VoidCallback? onStartTutorial;

  const HowToPlayScreen({
    super.key,
    required this.theme,
    required this.onBack,
    this.showSkipButton = false,
    this.onSkip,
    this.onStartTutorial,
  });

  @override
  State<HowToPlayScreen> createState() => _HowToPlayScreenState();
}

class _HowToPlayScreenState extends State<HowToPlayScreen>
    with SingleTickerProviderStateMixin {
  PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<HowToPlayPage> _pages = [
    HowToPlayPage(
      title: "Welcome to Kliem!",
      subtitle: "Learn Maltese words through discovery",
      content: [
        "Kliem is inspired by Wordle but focuses on discovering and collecting Maltese words.",
        "Each game teaches you new vocabulary while building your personal WordDex collection.",
        "Ready to start your Maltese language adventure?"
      ],
      icon: Icons.language,
    ),
    HowToPlayPage(
      title: "How to Play",
      subtitle: "Guess the 5-letter Maltese word",
      content: [
        "• You have 6 attempts to guess the correct word",
        "• Type your guess using the on-screen keyboard",
        "• Press Enter to submit your guess",
        "• Each letter will show you a clue about the target word"
      ],
      icon: Icons.help_outline,
    ),
    HowToPlayPage(
      title: "Letter Colors",
      subtitle: "Understanding the feedback",
      content: [
        "🟩 Green: Correct letter in the right position",
        "🟨 Yellow: Correct letter but in wrong position", 
        "⬜ Gray: Letter is not in the target word",
        "Use these clues to narrow down your next guess!"
      ],
      icon: Icons.palette,
      showColorExamples: true,
    ),
    HowToPlayPage(
      title: "Word Hunt Mode",
      subtitle: "Progressive difficulty system",
      content: [
        "• Start with common everyday words",
        "• Progress through different difficulty levels",
        "• Unlock more challenging vocabulary as you improve",
        "• Track your progress on the main menu"
      ],
      icon: Icons.trending_up,
    ),
    HowToPlayPage(
      title: "WordDex Collection",
      subtitle: "Build your Maltese vocabulary",
      content: [
        "• Successfully guessed words are added to your WordDex",
        "• View English translations and word details",
        "• Track when you discovered each word",
        "• Never lose progress with automatic backup"
      ],
      icon: Icons.book,
    ),
    HowToPlayPage(
      title: "Ready to Play?",
      subtitle: "Start your first word hunt!",
      content: [
        "You now know the basics of Kliem!",
        "Want to try a guided tutorial first, or jump right into your first word hunt?",
        "Remember: every word you discover becomes part of your collection!"
      ],
      icon: Icons.play_arrow,
      isLastPage: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _startTutorial() {
    Navigator.of(context).push(
      SlideRoute(
        page: TutorialScreen(
          theme: widget.theme,
          onComplete: () {
            Navigator.of(context).pop();
            if (widget.onStartTutorial != null) {
              widget.onStartTutorial!();
            }
          },
        ),
        direction: SlideDirection.rightToLeft,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Add swipe-to-exit gesture
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0 && details.primaryDelta! > 8) {
          widget.onBack();
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
                        onPressed: widget.onBack,
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'How to Play',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      if (widget.showSkipButton)
                        TextButton(
                          onPressed: widget.onSkip,
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Progress indicator
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / _pages.length,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_currentPage + 1} of ${_pages.length}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),

                // Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        itemCount: _pages.length,
                        itemBuilder: (context, index) {
                          return _buildPageContent(_pages[index]);
                        },
                      ),
                    ),
                  ),
                ),

                // Navigation buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (_currentPage > 0)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _previousPage,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      if (_currentPage > 0) const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _currentPage == _pages.length - 1
                              ? (_pages[_currentPage].isLastPage
                                  ? _startTutorial
                                  : _nextPage)
                              : _nextPage,
                          icon: Icon(_currentPage == _pages.length - 1
                              ? Icons.play_arrow
                              : Icons.arrow_forward),
                          label: Text(_currentPage == _pages.length - 1
                              ? 'Start Tutorial'
                              : 'Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.theme.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_currentPage == _pages.length - 1)
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (widget.onStartTutorial != null) {
                            widget.onStartTutorial!();
                          } else {
                            widget.onBack();
                          }
                        },
                        icon: const Icon(Icons.explore),
                        label: const Text('Start Word Hunt'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.theme.secondaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent(HowToPlayPage page) {
    return Container(
      decoration: BoxDecoration(
        color: widget.theme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              page.icon,
              size: 40,
              color: widget.theme.primaryColor,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: widget.theme.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle
          Text(
            page.subtitle,
            style: TextStyle(
              fontSize: 16,
              color: widget.theme.textColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...page.content.map((text) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          text,
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.theme.textColor,
                            height: 1.5,
                          ),
                        ),
                      )),

                  // Color examples for the colors page
                  if (page.showColorExamples) ...[
                    const SizedBox(height: 16),
                    _buildColorExample(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.theme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Example: Guessing "KITEB"',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.theme.textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLetterExample('K', Colors.green),
              _buildLetterExample('O', Colors.grey),
              _buildLetterExample('T', Colors.green),
              _buildLetterExample('B', Colors.yellow),
              _buildLetterExample('A', Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'K & T are correct positions\nB is in the word but wrong spot\nO & A are not in the target word',
            style: TextStyle(
              fontSize: 14,
              color: widget.theme.textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterExample(String letter, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class HowToPlayPage {
  final String title;
  final String subtitle;
  final List<String> content;
  final IconData icon;
  final bool showColorExamples;
  final bool isLastPage;

  HowToPlayPage({
    required this.title,
    required this.subtitle,
    required this.content,
    required this.icon,
    this.showColorExamples = false,
    this.isLastPage = false,
  });
}