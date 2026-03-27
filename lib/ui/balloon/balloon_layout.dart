import 'package:flutter/material.dart';

/// Must match [BalloonEnvelopePainter] geometry and [BalloonGame] positioning.
abstract final class BalloonLayout {
  static const double width = 88;
  static const double height = width * 1.15;

  /// [Positioned.left] uses `screenW * xNorm - this`.
  static const double positionedHalfWidth = width / 2;

  /// [Positioned.top] uses `balloonCenterY - this` (visual anchor).
  static const double positionedTopOffset = 70;

  /// Burner: horizontal center of the rig.
  static const double burnerXNormInWidget = 0.5;

  /// Between envelope bottom (~0.72h) and basket top (~0.68h); slightly in the neck.
  static const double burnerYNormInWidget = 0.695;

  /// Screen-space burner center for stack / flame layer.
  static Offset burnerScreenOffset({
    required double screenW,
    required double balloonCenterYNorm,
    required double screenH,
    required double balloonXNorm,
  }) {
    final balloonY = screenH * balloonCenterYNorm;
    final left = screenW * balloonXNorm - positionedHalfWidth;
    final top = balloonY - positionedTopOffset;
    return Offset(
      left + width * burnerXNormInWidget,
      top + height * burnerYNormInWidget,
    );
  }
}
