/// Pure Dart game math for Balloon Tap (unit-testable, no Flutter imports).
abstract final class BalloonPhysics {
  BalloonPhysics._();

  static const double gravity = 1.1e-6;
  static const double tapImpulse = 0.00045;
  static const double maxVy = 0.0016;
  static const double loseLow = 0.02;
  static const double loseHigh = 0.98;

  /// Intro: balloon starts near ground and rises to play band.
  static const double introStartYNorm = 0.90;
  static const double introTargetYNorm = 0.52;
  static const double introRiseVy = -0.0009;

  static bool isIntroComplete(double yNorm) => yNorm <= introTargetYNorm;

  /// Integrate gravity for one frame ([dt] in seconds).
  static double applyGravity(double vy, double dt) {
    return (vy + gravity * dt).clamp(-maxVy, maxVy);
  }

  /// Player tap: upward impulse (negative velocity change in this model).
  static double applyTap(double vy) {
    return (vy - tapImpulse).clamp(-maxVy, maxVy);
  }

  /// Normalized vertical position after one frame ([dt] in seconds).
  static double stepPosition(double yNorm, double vy, double dt) {
    return (yNorm + vy * dt * 60).clamp(0.0, 1.0);
  }

  static bool isGameOver(double yNorm) =>
      yNorm <= loseLow || yNorm >= loseHigh;

  static int scoreDeltaForFrame(double dt) => (dt * 12).floor();
}
