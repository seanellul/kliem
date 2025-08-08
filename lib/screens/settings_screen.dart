import 'package:flutter/material.dart';
import '../models/theme_model.dart';
import '../widgets/backup_dialog.dart';
import 'styles_modal.dart';
import 'app_info_screen.dart';

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
    return Scaffold(
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
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                              iconColor: theme.secondaryColor,
                              title: 'Backup WordDex',
                              subtitle: 'Save and restore your collection',
                              onTap: () => _showBackupDialog(context),
                            ),
                            
                            const SizedBox(height: 24),
                            _buildSectionTitle('Help'),
                            _buildSettingsTile(
                              icon: Icons.help_outline,
                              iconColor: theme.primaryColor,
                              title: 'How to Play',
                              subtitle: 'Learn the basics',
                              onTap: () => _showHowToPlay(context),
                              showSoon: true,
                            ),
                            _buildSettingsTile(
                              icon: Icons.ondemand_video,
                              iconColor: theme.primaryColor,
                              title: 'Tutorial',
                              subtitle: 'Interactive walkthrough',
                              onTap: () => _showTutorial(context),
                              showSoon: true,
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
    );
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
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
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
        theme: theme,
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
      MaterialPageRoute(
        builder: (context) => AppInfoScreen(
          theme: theme,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    // TODO: Implement How to Play screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('How to Play coming soon!'),
        backgroundColor: theme.primaryColor,
      ),
    );
  }

  void _showTutorial(BuildContext context) {
    // TODO: Implement Tutorial/Onboarding
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Interactive tutorial coming soon!'),
        backgroundColor: theme.primaryColor,
      ),
    );
  }
}