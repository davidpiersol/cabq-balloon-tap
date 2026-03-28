import 'package:balloon_tap/game/balloon_physics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Long deterministic stepping to catch NaN / runaway velocity without running the full UI.
void main() {
  group('physics simulation', () {
    test('descent pull keeps yNorm in bounds for simulated 30s', () {
      var yNorm = BalloonPhysics.groundStartYNorm;
      var vy = 0.0;
      const dt = 1 / 120;
      var t = 0.0;
      while (t < 30.0) {
        vy = BalloonPhysics.applyDescentPull(vy, dt);
        yNorm = BalloonPhysics.stepPosition(yNorm, vy, dt);
        expect(yNorm, inInclusiveRange(0.0, 1.0));
        expect(vy.isFinite, isTrue);
        t += dt;
      }
    });

    test('alternating burn and descent stays finite and in bounds', () {
      var yNorm = 0.5;
      var vy = 0.0;
      const dt = 1 / 60;
      for (var step = 0; step < 60 * 40; step++) {
        final burn = (step ~/ 120).isEven;
        if (burn) {
          vy = BalloonPhysics.applyBurnerLift(vy, dt);
        } else {
          vy = BalloonPhysics.applyDescentPull(vy, dt);
        }
        yNorm = BalloonPhysics.stepPosition(yNorm, vy, dt);
        expect(yNorm, inInclusiveRange(0.0, 1.0));
        expect(vy.isFinite, isTrue);
      }
    });

    test('coast then descent from upward velocity', () {
      var vy = -BalloonPhysics.burnerTargetVy;
      var yNorm = 0.4;
      const dt = 1 / 60;
      var coastLeft = BalloonPhysics.coastDuration;
      var t = 0.0;
      while (t < 12.0) {
        if (coastLeft > 0) {
          coastLeft -= dt;
          if (coastLeft < 0) coastLeft = 0;
          vy = BalloonPhysics.applyCoastDamping(vy, dt);
        } else {
          vy = BalloonPhysics.applyDescentPull(vy, dt);
        }
        yNorm = BalloonPhysics.stepPosition(yNorm, vy, dt);
        expect(yNorm, inInclusiveRange(0.0, 1.0));
        expect(vy.isFinite, isTrue);
        t += dt;
      }
    });
  });
}
