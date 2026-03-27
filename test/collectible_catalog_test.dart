import 'package:balloon_tap/game/collectibles/collectible_catalog.dart';
import 'package:balloon_tap/game/collectibles/collectible_world.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CollectibleKind labels are non-empty', () {
    for (final k in CollectibleKind.values) {
      expect(k.label.isNotEmpty, isTrue);
      expect(k.placeholderPoints, greaterThan(0));
    }
  });

  test('CollectibleWorld tick is safe with empty active list', () {
    final w = CollectibleWorld();
    w.tick(0.016);
    expect(w.active, isEmpty);
    w.clear();
    expect(w.scrollXNnorm, 0);
  });
}
