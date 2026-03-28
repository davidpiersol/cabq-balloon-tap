import 'package:shared_preferences/shared_preferences.dart';

/// Local best score only (no network, no PII).
abstract final class ScoreStore {
  ScoreStore._();

  static const _key = 'balloon_tap_best_score_v1';

  /// Reject negative or absurd values from storage or callers (tamper / corruption).
  static const int maxReasonableScore = 2000000000;

  static int sanitizeScore(int value) => value.clamp(0, maxReasonableScore);

  static Future<int> loadBest() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getInt(_key);
    if (raw == null) return 0;
    return sanitizeScore(raw);
  }

  /// Persists [score] if it exceeds the stored value.
  static Future<int> saveIfBest(int score) async {
    final safe = sanitizeScore(score);
    final prefs = await SharedPreferences.getInstance();
    final current = sanitizeScore(prefs.getInt(_key) ?? 0);
    if (safe > current) {
      await prefs.setInt(_key, safe);
      return safe;
    }
    return current;
  }
}
