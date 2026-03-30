import 'package:balloon_tap/layout/ad_banner_reserve.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('playfieldBottomInset adds safe area and HUD gap', () {
    const mq = MediaQueryData(
      padding: EdgeInsets.only(bottom: 34),
      size: Size(400, 800),
    );
    final inset = AdBannerReserve.playfieldBottomInset(mq, includeV3BannerSlot: false);
    expect(inset, 34 + AdBannerReserve.gameHudBottomInset);
  });

  test('playfieldBottomInset optional v3 banner slot', () {
    const mq = MediaQueryData(
      padding: EdgeInsets.zero,
      size: Size(400, 800),
    );
    final inset = AdBannerReserve.playfieldBottomInset(mq, includeV3BannerSlot: true);
    expect(
      inset,
      AdBannerReserve.gameHudBottomInset + AdBannerReserve.suggestedBannerHeight,
    );
  });
}
