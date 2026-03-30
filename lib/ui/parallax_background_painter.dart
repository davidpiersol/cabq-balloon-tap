import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Layered, tiled ridge silhouettes that scroll left (balloon appears to drift right).
/// v2: sun glow, soft cloud wisps, cactus silhouettes on nearest ridge.
class ParallaxBackgroundPainter extends CustomPainter {
  ParallaxBackgroundPainter({
    required this.skyTop,
    required this.skyBottom,
    required this.scrollPx,
    required this.timeSec,
    this.skyHorizon,
  });

  final Color skyTop;
  final Color skyBottom;
  final Color? skyHorizon;
  final double scrollPx;
  final double timeSec;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final colors = skyHorizon == null
        ? <Color>[skyTop, skyBottom]
        : <Color>[skyTop, skyHorizon!, skyBottom];
    final stops = skyHorizon == null ? null : <double>[0.0, 0.52, 1.0];
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: colors,
          stops: stops,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect),
    );

    _paintSunGlow(canvas, size);
    _paintClouds(canvas, size);

    _ridge(canvas, size,
        shift: scrollPx * 0.12,
        baseY: size.height * 0.58,
        waveLen: 280,
        amp: size.height * 0.045,
        fill: const Color(0xFF7B9BA8).withValues(alpha: 0.45),
        harmonics: 0.4);
    _ridge(canvas, size,
        shift: scrollPx * 0.28,
        baseY: size.height * 0.66,
        waveLen: 220,
        amp: size.height * 0.055,
        fill: const Color(0xFF5C6B73).withValues(alpha: 0.55),
        harmonics: 0.55);
    _ridge(canvas, size,
        shift: scrollPx * 0.48,
        baseY: size.height * 0.74,
        waveLen: 180,
        amp: size.height * 0.065,
        fill: const Color(0xFF3D4549).withValues(alpha: 0.72),
        harmonics: 0.65);
    _ridge(canvas, size,
        shift: scrollPx * 0.72,
        baseY: size.height * 0.82,
        waveLen: 140,
        amp: size.height * 0.048,
        fill: const Color(0xFF2A3035).withValues(alpha: 0.88),
        harmonics: 0.5);

    _paintCacti(canvas, size);
  }

  void _paintSunGlow(Canvas canvas, Size size) {
    final sunX = size.width * 0.82 - scrollPx * 0.08;
    final sunY = size.height * 0.14 + math.sin(timeSec * 0.4) * 3;
    final r = math.min(size.width, size.height) * 0.055;

    // Outer glow
    canvas.drawCircle(
      Offset(sunX, sunY),
      r * 3.5,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(sunX, sunY),
          r * 3.5,
          [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
    );

    // Sun disc
    canvas.drawCircle(
      Offset(sunX, sunY),
      r,
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );

    // Bright core
    canvas.drawCircle(
      Offset(sunX, sunY),
      r * 0.5,
      Paint()..color = Colors.white.withValues(alpha: 0.75),
    );
  }

  void _paintClouds(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final p = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < 4; i++) {
      final drift = scrollPx * (0.04 + i * 0.015);
      final cx = (w * (0.15 + i * 0.25) - drift) % (w + 200) - 100;
      final cy = h * (0.08 + i * 0.06) + math.sin(timeSec * 0.3 + i * 1.2) * 2;
      final scale = 0.7 + i * 0.12;

      p.color = Colors.white.withValues(alpha: 0.12 - i * 0.02);
      final path = Path();
      path.addOval(Rect.fromCenter(
          center: Offset(cx, cy), width: 90 * scale, height: 22 * scale));
      path.addOval(Rect.fromCenter(
          center: Offset(cx - 30 * scale, cy + 4), width: 60 * scale, height: 18 * scale));
      path.addOval(Rect.fromCenter(
          center: Offset(cx + 35 * scale, cy + 3), width: 55 * scale, height: 16 * scale));
      canvas.drawPath(path, p);
    }
  }

  void _paintCacti(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final groundY = h * 0.84;
    const spacing = 180.0;
    final offsetX = -(scrollPx * 0.72) % spacing;

    final p = Paint()..color = const Color(0xFF1A1E22).withValues(alpha: 0.7);

    for (var x = offsetX; x < w + 60; x += spacing) {
      final trunkH = 18 + 6 * math.sin(x * 0.07);
      const trunkW = 3.5;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - trunkW / 2, groundY - trunkH, trunkW, trunkH),
          const Radius.circular(1.5),
        ),
        p,
      );
      // Left arm
      final armY = groundY - trunkH * 0.6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - trunkW / 2 - 6, armY, 6, 2.5),
          const Radius.circular(1),
        ),
        p,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - trunkW / 2 - 6, armY - 8, 2.5, 8),
          const Radius.circular(1),
        ),
        p,
      );
      // Right arm
      final armY2 = groundY - trunkH * 0.45;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + trunkW / 2, armY2, 5, 2.5),
          const Radius.circular(1),
        ),
        p,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x + trunkW / 2 + 3, armY2 - 6, 2.5, 6),
          const Radius.circular(1),
        ),
        p,
      );
    }
  }

  void _ridge(
    Canvas canvas,
    Size size, {
    required double shift,
    required double baseY,
    required double waveLen,
    required double amp,
    required Color fill,
    required double harmonics,
  }) {
    final w = size.width;
    final h = size.height;
    final path = Path();
    const step = 5.0;
    path.moveTo(-100, h);
    for (var x = -100.0; x <= w + 100; x += step) {
      final t = (x + shift) * 2 * math.pi / waveLen;
      final y = baseY +
          math.sin(t) * amp +
          math.sin(t * 1.7 + 0.8) * amp * harmonics * 0.35 +
          math.sin(t * 0.35 + 2.1) * amp * 0.22;
      path.lineTo(x, y);
    }
    path.lineTo(w + 100, h);
    path.close();
    canvas.drawPath(path, Paint()..color = fill);
  }

  @override
  bool shouldRepaint(covariant ParallaxBackgroundPainter oldDelegate) =>
      oldDelegate.skyTop != skyTop ||
      oldDelegate.skyBottom != skyBottom ||
      oldDelegate.skyHorizon != skyHorizon ||
      oldDelegate.scrollPx != scrollPx ||
      (oldDelegate.timeSec - timeSec).abs() > 0.02;
}
