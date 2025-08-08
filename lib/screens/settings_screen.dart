import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../widgets/backup_dialog.dart';
import '../widgets/slide_route.dart';
import '../services/onboarding_service.dart';
import 'styles_modal.dart';
import 'app_info_screen.dart';
import 'how_to_play_screen.dart';
import 'tutorial_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeModel theme;
  final String currentTheme;
  final Function(String) onThemeSelect;
  final VoidCallback? onDataChanged;
  final VoidCallback onBack;

  const SettingsScreen({
    super.key,
    required this.theme,
    required this.currentTheme,
    required this.onThemeSelect,
    this.onDataChanged,
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
                            color: theme.textColor,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.textColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Settings Content
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      decoration: BoxDecoration(
                        color: theme.surfaceColor,
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: [
                                _buildSectionTitle('Appearance'),
                                _buildSettingsTile(
                                  icon: Icons.palette,
                                  iconColor: theme.accentColor,
                                  title: 'Themes',
                                  subtitle: 'Choose your favorite colors',
                                  onTap: () => _showStylesModal(context),
                                ),
                                const SizedBox(height: 24),
                                _buildSectionTitle('Data'),
                                _buildSettingsTile(
                                  icon: Icons.backup,
                                  iconColor: theme.accentColor,
                                  title: 'Backup WordDex',
                                  subtitle: 'Save and restore your collection',
                                  onTap: () => _showBackupDialog(context),
                                ),
                                const SizedBox(height: 24),
                                _buildSectionTitle('Help'),
                                _buildSettingsTile(
                                  icon: Icons.help_outline,
                                  iconColor: theme.accentColor,
                                  title: 'How to Play',
                                  subtitle: 'Learn the basics',
                                  onTap: () => _showHowToPlay(context),
                                ),
                                _buildSettingsTile(
                                  icon: Icons.ondemand_video,
                                  iconColor: theme.accentColor,
                                  title: 'Tutorial',
                                  subtitle: 'Interactive walkthrough',
                                  onTap: () => _showTutorial(context),
                                ),
                                _buildSettingsTile(
                                  icon: Icons.refresh,
                                  iconColor: theme.accentColor,
                                  title: 'Reset Onboarding',
                                  subtitle: 'Show welcome flow again',
                                  onTap: () => _resetOnboarding(context),
                                ),
                                const SizedBox(height: 24),
                                _buildSectionTitle('About'),
                                _buildSettingsTile(
                                  icon: Icons.info_outline,
                                  iconColor: theme.accentColor,
                                  title: 'App Info',
                                  subtitle: 'Version, credits, and more',
                                  onTap: () => _showAppInfo(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.textColor,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showSoon = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.backgroundColor.withOpacity(0.5)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.textColor,
              ),
            ),
            if (showSoon) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Soon',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.accentColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: theme.textColor.withOpacity(0.7),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.textColor.withOpacity(0.5),
        ),
        onTap: showSoon ? null : onTap,
      ),
    );
  }

  void _showStylesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StylesModal(
        isOpen: true,
        currentTheme: currentTheme,
        onThemeSelect: onThemeSelect,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BackupDialog(
        theme: theme,
        onDataChanged: () {
          if (onDataChanged != null) {
            onDataChanged!();
          }
        },
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    Navigator.of(context).push(
      SlideRoute(
        page: AppInfoScreen(
          theme: theme,
          onBack: () => Navigator.of(context).pop(),
        ),
        direction: SlideDirection.rightToLeft,
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    Navigator.of(context).push(
      SlideRoute(
        page: HowToPlayScreen(
          theme: theme,
          onBack: () => Navigator.of(context).pop(),
        ),
        direction: SlideDirection.rightToLeft,
      ),
    );
  }

  void _showTutorial(BuildContext context) {
    Navigator.of(context).push(
      SlideRoute(
        page: TutorialScreen(
          theme: theme,
          onComplete: () {
            Navigator.of(context).pop();
          },
        ),
        direction: SlideDirection.rightToLeft,
      ),
    );
  }

  void _resetOnboarding(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.primaryColor,
        title: Text(
          'Reset Onboarding',
          style: TextStyle(color: theme.textColor),
        ),
        content: Text(
          'This will show the welcome flow again when you restart the app. Continue?',
          style: TextStyle(color: theme.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.textColor.withOpacity(0.7)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Reset',
              style: TextStyle(color: theme.accentColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await OnboardingService.resetOnboarding();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Onboarding reset! Restart the app to see the welcome flow.'),
          backgroundColor: theme.primaryColor,
        ),
      );
    }
  }
}
