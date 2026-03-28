import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../game/balloon_appearance.dart';

abstract final class AppearanceStore {
  AppearanceStore._();

  static const _key = 'balloon_tap_appearance_v1';

  /// Cap stored JSON size to limit decode / memory abuse from corrupted prefs.
  static const int maxJsonChars = 8192;

  static Future<BalloonAppearance> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return BalloonAppearance.defaultLook;
    if (raw.length > maxJsonChars) return BalloonAppearance.defaultLook;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return BalloonAppearance.fromJson(map);
    } catch (_) {
      return BalloonAppearance.defaultLook;
    }
  }

  static Future<void> save(BalloonAppearance a) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(a.toJson()));
  }
}
