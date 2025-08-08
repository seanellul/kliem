import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/theme_model.dart';

class AppInfoScreen extends StatelessWidget {
  final ThemeModel theme;
  final VoidCallback onBack;

  const AppInfoScreen({
    super.key,
    required this.theme,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Add swipe-to-exit gesture
      onHorizontalDragUpdate: (details) {
        // Detect right swipe (positive delta)
        if (details.delta.dx > 0) {
          // Add some resistance by requiring minimum swipe distance
          if (details.primaryDelta! > 8) {
            onBack();
          }
        }
      },
      child: Scaffold(
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
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBack,
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'App Info',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                    color: theme.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      // App Icon and Name
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.language,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Kliem',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: theme.textColor,
                              ),
                            ),
                            Text(
                              'Maltese Word Game',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.textColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Version Info
                      _buildInfoCard(
                        title: 'Version Information',
                        children: [
                          _buildInfoRow('Version', '1.0.1'),
                          _buildInfoRow('Build', '1'),
                          _buildInfoRow(
                              'Platform', Theme.of(context).platform.name),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // About the Game
                      _buildInfoCard(
                        title: 'About the Game',
                        children: [
                          Text(
                            'Kliem is a Maltese word guessing game inspired by Wordle. '
                            'Discover and collect Maltese words while learning their meanings. '
                            'Challenge yourself with different difficulty levels and build your WordDex collection!'
                            'Data collected and organised from Gabra.mt',
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.textColor.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Features
                      _buildInfoCard(
                        title: 'Features',
                        children: [
                          _buildFeatureItem('🎮', 'Adventure Mode',
                              'Progressive difficulty system'),
                          _buildFeatureItem('📚', 'WordDex Collection',
                              'Save discovered words'),
                          _buildFeatureItem('🎨', 'Multiple Themes',
                              'Customize your experience'),
                          _buildFeatureItem(
                              '💾', 'Data Backup', 'Never lose your progress'),
                          _buildFeatureItem(
                              '📊', 'Statistics', 'Track your performance'),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Developer Info
                      _buildInfoCard(
                        title: 'Developer',
                        children: [
                          _buildInfoRow('Created by', 'Sean Ellul'),
                          _buildInfoRow('Language', 'Maltese & English'),
                          _buildInfoRow('Framework', 'Flutter'),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Support
                      _buildInfoCard(
                        title: 'Support',
                        children: [
                          Text(
                            'Having issues or suggestions? We\'d love to hear from you!',
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.textColor.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _copyEmail,
                            icon: const Icon(Icons.email),
                            label: const Text('Contact Support'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Credits
                      _buildInfoCard(
                        title: 'Credits',
                        children: [
                          Text(
                            'Special thanks to the Maltese language community, especially Gabra.mt and '
                            'all the players who provide feedback to improve the game. '
                            'Special thanks to the developers of the original Wordle game, '
                            'and sites like Kelma.mt.',
                            style: TextStyle(
                              fontSize: 16,
                              color: theme.textColor.withOpacity(0.8),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
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

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.textColor,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textColor.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: theme.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.textColor,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyEmail() {
    const email = 'support@kliem.app'; // Replace with actual support email
    Clipboard.setData(const ClipboardData(text: email));
    // Note: You might want to show a snackbar here, but we don't have access to context
  }
}
