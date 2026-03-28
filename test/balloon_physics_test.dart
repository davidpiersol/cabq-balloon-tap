import 'package:balloon_tap/game/balloon_physics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BalloonPhysics', () {
    test('applyDescentPull pulls vy toward downward target (symmetric to burner)', () {
      var vy = 0.0;
      for (var i = 0; i < 200; i++) {
        vy = BalloonPhysics.applyDescentPull(vy, 0.016);
      }
      expect(vy, greaterThan(0));
      expect(vy, lessThanOrEqualTo(BalloonPhysics.maxVy));
      expect(vy, closeTo(-BalloonPhysics.burnerTargetVy, 2e-5));
    });

    test('applyBurnerLift pulls vy toward upward target', () {
      var vy = 0.0;
      for (var i = 0; i < 200; i++) {
        vy = BalloonPhysics.applyBurnerLift(vy, 0.016);
      }
      expect(vy, lessThan(0));
      expect(vy, greaterThanOrEqualTo(-BalloonPhysics.maxVy));
    });

    test('applyCoastDamping moves vy toward zero', () {
      var vy = -0.0008;
      for (var i = 0; i < 100; i++) {
        vy = BalloonPhysics.applyCoastDamping(vy, 0.016);
      }
      expect(vy.abs(), lessThan(0.0002));
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
    });

    test('scoreDeltaForFrame scales with dt', () {
      expect(BalloonPhysics.scoreDeltaForFrame(0.1), 1);
      expect(BalloonPhysics.scoreDeltaForFrame(0.0), 0);
    });
  });
}
