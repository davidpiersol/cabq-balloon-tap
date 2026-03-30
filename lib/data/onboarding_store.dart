import 'package:shared_preferences/shared_preferences.dart';

/// First-run onboarding for v2 (hold / release / coast).
abstract final class OnboardingStore {
  OnboardingStore._();

  /// SharedPreferences key (exposed for tests and migration scripts).
  static const prefsKeyOnboardingV2Done = 'balloon_tap_onboarding_v2_done';

  static const _key = prefsKeyOnboardingV2Done;

  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
