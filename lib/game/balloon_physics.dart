import 'dart:math' as math;

/// Pure Dart game math for Balloon Tap (unit-testable, no Flutter imports).
abstract final class BalloonPhysics {
  BalloonPhysics._();

  static const double maxVy = 0.0024;
  static const double loseLow = 0.02;
  static const double loseHigh = 0.98;

  static const double groundStartYNorm = 0.90;

  static const double burnerTargetVy = -0.00082;
  static const double burnerResponse = 8.5;

  static const double coastDuration = 0.35;
  static const double coastDamping = 5.2;

  static const double parallaxScrollPerSec = 0.042;

  static double applyBurnerLift(double vy, double dt) {
    final blend = 1.0 - math.exp(-burnerResponse * dt);
    return (vy + (burnerTargetVy - vy) * blend).clamp(-maxVy, maxVy);
  }

  /// Same easing as [applyBurnerLift], toward +[burnerTargetVy] so descent matches ascent.
  static double applyDescentPull(double vy, double dt) {
    final target = -burnerTargetVy;
    final blend = 1.0 - math.exp(-burnerResponse * dt);
    return (vy + (target - vy) * blend).clamp(-maxVy, maxVy);
  }

  static double applyCoastDamping(double vy, double dt) {
    return (vy * math.exp(-coastDamping * dt)).clamp(-maxVy, maxVy);
  }

  static double stepPosition(double yNorm, double vy, double dt) {
    return (yNorm + vy * dt * 60).clamp(0.0, 1.0);
  }

  static bool isGameOver(double yNorm) =>
      yNorm <= loseLow || yNorm >= loseHigh;

  static int scoreDeltaForFrame(double dt) => (dt * 12).floor();
}
