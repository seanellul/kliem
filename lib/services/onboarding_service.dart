import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _hasCompletedOnboardingKey = 'has_completed_onboarding';
  static const String _hasSeenTutorialKey = 'has_seen_tutorial';
  static const String _onboardingVersionKey = 'onboarding_version';
  static const String _currentOnboardingVersion = '1.0';

  /// Check if user has completed onboarding
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompleted = prefs.getBool(_hasCompletedOnboardingKey) ?? false;
    final version = prefs.getString(_onboardingVersionKey) ?? '';
    
    // If onboarding version has changed, show onboarding again
    return hasCompleted && version == _currentOnboardingVersion;
  }

  /// Mark onboarding as completed
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedOnboardingKey, true);
    await prefs.setString(_onboardingVersionKey, _currentOnboardingVersion);
  }

  /// Check if user has seen the tutorial
  static Future<bool> hasSeenTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenTutorialKey) ?? false;
  }

  /// Mark tutorial as seen
  static Future<void> markTutorialSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenTutorialKey, true);
  }

  /// Reset onboarding (for testing or settings)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasCompletedOnboardingKey);
    await prefs.remove(_hasSeenTutorialKey);
    await prefs.remove(_onboardingVersionKey);
  }

  /// Check if this is the very first app launch
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final hasLaunched = prefs.getBool('has_launched_before') ?? false;
    
    if (!hasLaunched) {
      await prefs.setBool('has_launched_before', true);
      return true;
    }
    
    return false;
  }

  /// Get onboarding preferences for customization
  static Future<OnboardingPreferences> getPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    return OnboardingPreferences(
      skipTutorial: prefs.getBool('onboarding_skip_tutorial') ?? false,
      showTips: prefs.getBool('onboarding_show_tips') ?? true,
    );
  }

  /// Save onboarding preferences
  static Future<void> savePreferences(OnboardingPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_skip_tutorial', preferences.skipTutorial);
    await prefs.setBool('onboarding_show_tips', preferences.showTips);
  }
}

class OnboardingPreferences {
  final bool skipTutorial;
  final bool showTips;

  OnboardingPreferences({
    required this.skipTutorial,
    required this.showTips,
  });
}