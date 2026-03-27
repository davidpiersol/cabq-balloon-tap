import 'package:balloon_tap/ui/balloon/flame_painter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FlameBurst is a brief burner-style pulse, not a long flame', () {
    expect(FlameBurst.lifetime, lessThan(0.25));
    expect(FlameBurst.lifetime, greaterThan(0.08));
    final f = FlameBurst(xNorm: 0.5, yNorm: 0.5);
    expect(f.isDead, isFalse);
    f.age = FlameBurst.lifetime;
    expect(f.isDead, isTrue);
  });
}
