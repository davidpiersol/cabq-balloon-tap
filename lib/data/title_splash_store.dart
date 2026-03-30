import 'package:shared_preferences/shared_preferences.dart';

/// First-launch title splash gate for the v2 visual reveal.
abstract final class TitleSplashStore {
  TitleSplashStore._();

  /// SharedPreferences key (exposed for tests).
  static const prefsKeySplashV2Done = 'balloon_tap_title_splash_v2_done';

  static const _key = prefsKeySplashV2Done;

  static Future<bool> isSplashComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> markSplashComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
