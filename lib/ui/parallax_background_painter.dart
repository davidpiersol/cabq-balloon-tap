import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Layered, tiled ridge silhouettes that scroll left (balloon appears to drift right).
class ParallaxBackgroundPainter extends CustomPainter {
  ParallaxBackgroundPainter({
    required this.skyTop,
    required this.skyBottom,
    required this.scrollPx,
    required this.timeSec,
  });

  final Color skyTop;
  final Color skyBottom;
  final double scrollPx;
  final double timeSec;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [skyTop, skyBottom],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect),
    );

    final sunX = size.width * 0.82 - scrollPx * 0.08;
    final sunY = size.height * 0.14 + math.sin(timeSec * 0.4) * 3;
    canvas.drawCircle(
      Offset(sunX, sunY),
      math.min(size.width, size.height) * 0.055,
      Paint()..color = Colors.white.withValues(alpha: 0.38),
    );

    _ridge(
      canvas,
      size,
      shift: scrollPx * 0.12,
      baseY: size.height * 0.58,
      waveLen: 280,
      amp: size.height * 0.045,
      fill: const Color(0xFF7B9BA8).withValues(alpha: 0.45),
      harmonics: 0.4,
    );
    _ridge(
      canvas,
      size,
      shift: scrollPx * 0.28,
      baseY: size.height * 0.66,
      waveLen: 220,
      amp: size.height * 0.055,
      fill: const Color(0xFF5C6B73).withValues(alpha: 0.55),
      harmonics: 0.55,
    );
    _ridge(
      canvas,
      size,
      shift: scrollPx * 0.48,
      baseY: size.height * 0.74,
      waveLen: 180,
      amp: size.height * 0.065,
      fill: const Color(0xFF3D4549).withValues(alpha: 0.72),
      harmonics: 0.65,
    );
    _ridge(
      canvas,
      size,
      shift: scrollPx * 0.72,
      baseY: size.height * 0.82,
      waveLen: 140,
      amp: size.height * 0.048,
      fill: const Color(0xFF2A3035).withValues(alpha: 0.88),
      harmonics: 0.5,
    );
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
      oldDelegate.scrollPx != scrollPx ||
      (oldDelegate.timeSec - timeSec).abs() > 0.02;
}
