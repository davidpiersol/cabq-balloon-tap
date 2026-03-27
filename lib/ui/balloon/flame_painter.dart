import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Burner jet at [burnerPosition]. [flameStrength] 0–1: held = 1, fades with coast after release.
class FlamePainter extends CustomPainter {
  FlamePainter({
    required this.flameStrength,
    required this.size,
    required this.burnerPosition,
    required this.timeSec,
  });

  final double flameStrength;
  final Size size;
  final Offset burnerPosition;
  final double timeSec;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (flameStrength < 0.02) return;

    final cx = burnerPosition.dx.clamp(0.0, size.width);
    final cy = burnerPosition.dy.clamp(0.0, size.height);

    final flicker = 0.88 + 0.12 * math.sin(timeSec * 26);
    final pulse = (flameStrength * flicker).clamp(0.0, 1.0);

    final maxH = size.shortestSide * 0.11 * (0.9 + 0.1 * pulse);
    final h = maxH * (0.55 + 0.45 * pulse);
    final baseW = size.shortestSide * 0.018 * (0.75 + 0.25 * pulse);
    final midW = baseW * (1.12 + 0.2 * pulse);

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

    if (pulse > 0.35) {
      final glint = (pulse - 0.35) / 0.65;
      canvas.drawCircle(
        Offset(cx, cy - h * 0.55),
        baseW * 0.85 * math.sqrt(glint),
        Paint()..color = Color.fromARGB((200 * glint * pulse).round(), 255, 255, 255),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FlamePainter oldDelegate) => true;
}
