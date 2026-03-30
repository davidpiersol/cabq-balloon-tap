import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Multi-jet burner flame at [burnerPosition].
/// Three nozzle jets (left-lean, centre, right-lean) with heat shimmer bands and
/// a radial glow corona.  [flameStrength] 0–1; [timeSec] drives flicker.
class FlamePainter extends CustomPainter {
  const FlamePainter({
    required this.flameStrength,
    required this.size,
    required this.burnerPosition,
    required this.timeSec,
  });

  final double flameStrength;
  final Size size;
  final Offset burnerPosition;
  final double timeSec;

  // ─── paint ──────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size canvasSize) {
    if (flameStrength < 0.02) return;

    final cx = burnerPosition.dx.clamp(0.0, size.width);
    final cy = burnerPosition.dy.clamp(0.0, size.height);

    final flicker = 0.86 + 0.14 * math.sin(timeSec * 28.0);
    final flutter = 0.92 + 0.08 * math.sin(timeSec * 41.0);
    final pulse = (flameStrength * flicker * flutter).clamp(0.0, 1.0);

    // ── corona glow (wide radial behind all jets) ───────────────────────────
    final glowR = size.shortestSide * 0.10 * (0.8 + 0.2 * pulse);
    final glowCenter = Offset(cx, cy - glowR * 0.25);
    canvas.drawCircle(
      glowCenter,
      glowR,
      Paint()
        ..shader = ui.Gradient.radial(
          glowCenter,
          glowR,
          [
            const Color(0xFFFF9800).withValues(alpha: 0.32 * pulse),
            const Color(0xFFFF6D00).withValues(alpha: 0.14 * pulse),
            Colors.transparent,
          ],
          const [0.0, 0.55, 1.0],
        ),
    );

    // ── three jets: offsets relative to burner centre ───────────────────────
    final List<_JetConfig> jets = [
      _JetConfig(dx: -size.shortestSide * 0.025, leanFactor: -1.4),
      const _JetConfig(dx: 0, leanFactor: 0),
      _JetConfig(dx: size.shortestSide * 0.025, leanFactor: 1.4),
    ];

    for (final j in jets) {
      _paintJet(canvas, cx + j.dx, cy, pulse, j.leanFactor);
    }

    // ── heat shimmer bands (wavy semi-transparent lines above nozzle) ───────
    if (pulse > 0.3) {
      _paintShimmer(canvas, cx, cy, pulse);
    }
  }

  // ─── single jet ─────────────────────────────────────────────────────────────

  void _paintJet(
      Canvas canvas, double cx, double cy, double pulse, double leanFactor) {
    final maxH = size.shortestSide * 0.13 * (0.85 + 0.15 * pulse);
    final h = maxH * (0.50 + 0.50 * pulse);
    final baseW = size.shortestSide * 0.014 * (0.7 + 0.3 * pulse);
    final midW = baseW * (1.15 + 0.22 * pulse);
    final lean = leanFactor * baseW * 0.6;

    final tipY = cy - h;
    final baseY = cy + baseW * 0.7;

    // Outer envelope
    final outerPath = Path()
      ..moveTo(cx + lean * 0.9, tipY - h * 0.03)
      ..quadraticBezierTo(cx - midW * 2.0 + lean, cy - h * 0.35, cx - baseW, baseY)
      ..quadraticBezierTo(cx - baseW * 0.35, baseY + baseW * 0.4, cx, baseY + baseW * 0.3)
      ..quadraticBezierTo(cx + baseW * 0.35, baseY + baseW * 0.4, cx + baseW, baseY)
      ..quadraticBezierTo(cx + midW * 2.0 + lean, cy - h * 0.35, cx + lean * 0.9, tipY - h * 0.03)
      ..close();

    canvas.drawPath(
      outerPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx, tipY),
          Offset(cx, baseY + baseW),
          [
            const Color(0xFFFFF8E1).withValues(alpha: 0.1 * pulse),
            const Color(0xFFFF9800).withValues(alpha: 0.45 * pulse),
            const Color(0xFFE65100).withValues(alpha: 0.28 * pulse),
          ],
          const [0.0, 0.5, 1.0],
        ),
    );

    // Inner hot core
    final innerPath = Path()
      ..moveTo(cx + lean * 0.7, tipY)
      ..quadraticBezierTo(cx - midW * 0.95 + lean, cy - h * 0.4, cx - baseW * 0.5, baseY)
      ..quadraticBezierTo(cx, baseY + baseW * 0.12, cx + baseW * 0.5, baseY)
      ..quadraticBezierTo(cx + midW * 0.95 + lean, cy - h * 0.4, cx + lean * 0.7, tipY)
      ..close();

    canvas.drawPath(
      innerPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx, tipY - h * 0.02),
          Offset(cx, baseY + baseW * 0.15),
          [
            Colors.white.withValues(alpha: 0.92 * pulse),
            const Color(0xFFFFEA00).withValues(alpha: 0.88 * pulse),
            const Color(0xFFFF6D00).withValues(alpha: 0.72 * pulse),
            const Color(0xFFFF3D00).withValues(alpha: 0.42 * pulse),
          ],
          const [0.0, 0.2, 0.55, 1.0],
        ),
    );

    // Blue nozzle ring
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, baseY + baseW * 0.2),
        width: baseW * 2.2,
        height: baseW * 2.0,
      ),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx, baseY - baseW),
          Offset(cx, baseY + baseW),
          [
            const Color(0xFF64B5F6).withValues(alpha: 0.38 * pulse),
            const Color(0xFF1565C0).withValues(alpha: 0.06 * pulse),
          ],
        ),
    );
  }

  // ─── shimmer ─────────────────────────────────────────────────────────────────

  void _paintShimmer(Canvas canvas, double cx, double cy, double pulse) {
    final shimmerAlpha = (pulse - 0.3) / 0.7 * 0.22;
    final maxH = size.shortestSide * 0.13 * pulse;
    for (var i = 0; i < 5; i++) {
      final t = timeSec * 18 + i * 1.3;
      final waveDx = math.sin(t) * 3.5;
      final y = cy - maxH * (0.1 + i * 0.17);
      canvas.drawLine(
        Offset(cx - 10 + waveDx, y),
        Offset(cx + 10 + waveDx, y),
        Paint()
          ..color =
              Colors.white.withValues(alpha: shimmerAlpha * (1 - i * 0.16))
          ..strokeWidth = 1.2,
      );
    }
  }

  // ─── repaint ────────────────────────────────────────────────────────────────

  @override
  bool shouldRepaint(covariant FlamePainter _) => true;
}

class _JetConfig {
  const _JetConfig({required this.dx, required this.leanFactor});
  final double dx;
  final double leanFactor;
}
