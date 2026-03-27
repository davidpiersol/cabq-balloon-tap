import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Short-lived burner burst at a screen-normalized point (tap).
class FlameBurst {
  FlameBurst({
    required this.xNorm,
    required this.yNorm,
    this.age = 0,
  });

  final double xNorm;
  final double yNorm;
  double age;

  static const double lifetime = 0.38;

  bool get isDead => age >= lifetime;
}

class FlamePainter extends CustomPainter {
  FlamePainter({required this.flames, required this.size});

  final List<FlameBurst> flames;
  final Size size;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    for (final f in flames) {
      final t = (f.age / FlameBurst.lifetime).clamp(0.0, 1.0);
      final cx = f.xNorm * size.width;
      final cy = f.yNorm * size.height;
      final h = 36 + 28 * (1 - t);
      final w = 18 + 10 * (1 - t);

      final path = Path()
        ..moveTo(cx, cy + h * 0.35)
        ..quadraticBezierTo(cx - w, cy + h * 0.2, cx - w * 0.35, cy - h * 0.5)
        ..quadraticBezierTo(cx, cy - h, cx + w * 0.35, cy - h * 0.5)
        ..quadraticBezierTo(cx + w, cy + h * 0.2, cx, cy + h * 0.35)
        ..close();

      final paint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx, cy - h),
          Offset(cx, cy + h * 0.4),
          [
            Colors.yellow.withValues(alpha: 0.95 * (1 - t * 0.5)),
            Colors.deepOrange.withValues(alpha: 0.85 * (1 - t * 0.3)),
            Colors.red.withValues(alpha: 0.5 * (1 - t)),
          ],
          [0, 0.45, 1],
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FlamePainter oldDelegate) => true;
}
