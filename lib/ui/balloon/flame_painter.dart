import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// One burner pulse (tap anywhere triggers; drawn at [burnerPosition], not at tap).
class FlameBurst {
  FlameBurst({this.age = 0});

  double age;

  /// Short trigger pull — matches a quick burner blast.
  static const double lifetime = 0.14;

  bool get isDead => age >= lifetime;
}

class FlamePainter extends CustomPainter {
  FlamePainter({
    required this.flames,
    required this.size,
    required this.burnerPosition,
  });

  final List<FlameBurst> flames;
  final Size size;

  /// Stack coordinates: tip of flame shoots upward (−Y) toward the envelope.
  final Offset burnerPosition;

  static double _burstCurve(double t) {
    final u = (1.0 - t.clamp(0.0, 1.0));
    return u * u * u;
  }

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final cx = burnerPosition.dx.clamp(0.0, size.width);
    final cy = burnerPosition.dy.clamp(0.0, size.height);

    for (final f in flames) {
      final t = (f.age / FlameBurst.lifetime).clamp(0.0, 1.0);
      final pulse = _burstCurve(t);

      final maxH = size.shortestSide * 0.11 * (0.92 + 0.08 * pulse);
      final h = maxH * (0.35 + 0.65 * pulse);
      final baseW = size.shortestSide * 0.018 * (0.7 + 0.3 * pulse);
      final midW = baseW * (1.15 + 0.25 * (1 - t));

      final tipY = cy - h;
      final baseY = cy + baseW * 0.8;

      final outerPath = Path()
        ..moveTo(cx, tipY - h * 0.04)
        ..quadraticBezierTo(cx - midW * 2.2, cy - h * 0.35, cx - baseW, baseY)
        ..quadraticBezierTo(cx - baseW * 0.4, baseY + baseW * 0.5, cx, baseY + baseW * 0.35)
        ..quadraticBezierTo(cx + baseW * 0.4, baseY + baseW * 0.5, cx + baseW, baseY)
        ..quadraticBezierTo(cx + midW * 2.2, cy - h * 0.35, cx, tipY - h * 0.04)
        ..close();

      final outerAlpha = (0.42 * pulse).clamp(0.0, 1.0);
      canvas.drawPath(
        outerPath,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(cx, tipY),
            Offset(cx, baseY + baseW),
            [
              const Color(0xFFFFF8E1).withValues(alpha: 0.15 * outerAlpha),
              const Color(0xFFFF9800).withValues(alpha: 0.55 * outerAlpha),
              const Color(0xFFE65100).withValues(alpha: 0.35 * outerAlpha),
            ],
            const [0.0, 0.5, 1.0],
          ),
      );

      final innerPath = Path()
        ..moveTo(cx, tipY)
        ..quadraticBezierTo(cx - midW * 1.1, cy - h * 0.42, cx - baseW * 0.55, baseY)
        ..quadraticBezierTo(cx, baseY + baseW * 0.15, cx + baseW * 0.55, baseY)
        ..quadraticBezierTo(cx + midW * 1.1, cy - h * 0.42, cx, tipY)
        ..close();

      final coreAlpha = (0.95 * pulse).clamp(0.0, 1.0);
      canvas.drawPath(
        innerPath,
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(cx, tipY - h * 0.02),
            Offset(cx, baseY + baseW * 0.2),
            [
              const Color(0xFFFFFFFF).withValues(alpha: 0.92 * coreAlpha),
              const Color(0xFFFFEA00).withValues(alpha: 0.88 * coreAlpha),
              const Color(0xFFFF6D00).withValues(alpha: 0.75 * coreAlpha),
              const Color(0xFFFF3D00).withValues(alpha: 0.45 * coreAlpha),
            ],
            const [0.0, 0.22, 0.55, 1.0],
          ),
      );

      final nozzleH = baseW * 2.2;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx, baseY + baseW * 0.25),
          width: baseW * 2.4,
          height: nozzleH,
        ),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset(cx, baseY - nozzleH),
            Offset(cx, baseY + nozzleH),
            [
              const Color(0xFF64B5F6).withValues(alpha: 0.35 * pulse),
              const Color(0xFF1565C0).withValues(alpha: 0.08 * pulse),
            ],
          ),
      );

      if (t < 0.35) {
        final glint = (1.0 - t / 0.35).clamp(0.0, 1.0);
        canvas.drawCircle(
          Offset(cx, cy - h * 0.55),
          baseW * 0.9 * math.sqrt(glint),
          Paint()..color = Color.fromARGB((220 * glint * pulse).round(), 255, 255, 255),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant FlamePainter oldDelegate) => true;
}
