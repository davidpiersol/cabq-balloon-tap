import 'package:balloon_tap/game/collectibles/collectible_catalog.dart';
import 'package:balloon_tap/game/collectibles/collectible_world.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CollectibleKind labels and points are valid', () {
    for (final k in CollectibleKind.values) {
      expect(k.label.isNotEmpty, isTrue);
      expect(k.points, greaterThan(0));
    }
  });

  test('CollectibleWorld tickAndCollect is safe with no overlap', () {
    final w = CollectibleWorld();
    w.tickAndCollect(
      dt: 0.016,
      screenWidth: 400,
      screenHeight: 800,
      scrollPx: 0,
      balloonXNorm: 0.25,
      balloonYNorm: 0.9,
    );
    expect(w.active.length, lessThanOrEqualTo(CollectibleWorld.maxActive));
    w.clear();
    expect(w.scrollXNnorm, 0);
    expect(w.active, isEmpty);
  });
}
