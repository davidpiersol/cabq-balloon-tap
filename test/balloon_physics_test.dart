import 'package:balloon_tap/game/balloon_physics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BalloonPhysics', () {
    test('applyGravity increases downward velocity', () {
      var vy = 0.0;
      vy = BalloonPhysics.applyGravity(vy, 0.016);
      expect(vy, greaterThan(0));
      vy = BalloonPhysics.applyGravity(vy, 0.016);
      expect(vy, greaterThan(0));
    });

    test('applyGravity clamps to maxVy', () {
      final vy = BalloonPhysics.applyGravity(1e6, 1.0);
      expect(vy, BalloonPhysics.maxVy);
    });

    test('applyTap reduces velocity (lift)', () {
      const vy = 0.0;
      final after = BalloonPhysics.applyTap(vy);
      expect(after, lessThan(vy));
    });

    test('stepPosition stays within 0..1', () {
      expect(BalloonPhysics.stepPosition(0.5, 0, 1), 0.5);
      expect(BalloonPhysics.stepPosition(0.5, 1e6, 1), 1.0);
      expect(BalloonPhysics.stepPosition(0.5, -1e6, 1), 0.0);
    });

    test('isGameOver at thresholds', () {
      expect(BalloonPhysics.isGameOver(BalloonPhysics.loseLow), isTrue);
      expect(BalloonPhysics.isGameOver(BalloonPhysics.loseHigh), isTrue);
      expect(BalloonPhysics.isGameOver(0.5), isFalse);
      expect(BalloonPhysics.isGameOver(0.021), isFalse);
      expect(BalloonPhysics.isGameOver(0.979), isFalse);
    });

    test('scoreDeltaForFrame scales with dt', () {
      expect(BalloonPhysics.scoreDeltaForFrame(0.1), 1);
      expect(BalloonPhysics.scoreDeltaForFrame(0.0), 0);
    });

    test('intro rises toward target', () {
      var y = BalloonPhysics.introStartYNorm;
      expect(BalloonPhysics.isIntroComplete(y), isFalse);
      for (var i = 0; i < 5000; i++) {
        y = BalloonPhysics.stepPosition(y, BalloonPhysics.introRiseVy, 0.016);
        if (BalloonPhysics.isIntroComplete(y)) break;
      }
      expect(BalloonPhysics.isIntroComplete(y), isTrue);
    });
  });
}
