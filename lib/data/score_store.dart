import 'package:shared_preferences/shared_preferences.dart';

/// Local best score only (no network, no PII).
abstract final class ScoreStore {
  static const _key = 'balloon_tap_best_score_v1';

  static Future<int> loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  /// Persists [score] if it exceeds the stored value.
  static Future<int> saveIfBest(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key) ?? 0;
    if (score > current) {
      await prefs.setInt(_key, score);
      return score;
    }
    return current;
  }
}
