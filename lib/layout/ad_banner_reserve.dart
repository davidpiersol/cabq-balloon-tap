import 'package:flutter/material.dart';

/// Reserved space and constants for a future **v3** non-intrusive sponsor banner.
/// v2 does **not** render ads; gameplay only adds modest bottom inset for hints.
abstract final class AdBannerReserve {
  AdBannerReserve._();

  /// Typical mobile banner height (pt) — use when integrating Google Mobile Ads / similar.
  static const double suggestedBannerHeight = 50;

  /// Extra padding above the safe area for score hint + skin picker (v2).
  static const double gameHudBottomInset = 12;

  /// Total bottom inset for the playfield (safe area + HUD + optional v3 slot).
  static double playfieldBottomInset(MediaQueryData mq, {bool includeV3BannerSlot = false}) {
    final safe = mq.padding.bottom;
    final banner = includeV3BannerSlot ? suggestedBannerHeight : 0.0;
    return safe + gameHudBottomInset + banner;
  }
}
