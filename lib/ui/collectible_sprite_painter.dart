import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../game/collectibles/collectible_catalog.dart';
import '../game/collectibles/collectible_world.dart';

/// Vector sprites for NM-themed pickups. Sprites are 48 px radius budget.
/// [timeSec] drives the glow-pulse ring on each collectible.
class CollectiblesPainter extends CustomPainter {
  const CollectiblesPainter({
    required this.instances,
    required this.scrollPx,
    this.timeSec = 0,
  });

  final List<CollectibleInstance> instances;
  final double scrollPx;
  final double timeSec;

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in instances) {
      final sx = c.worldX - scrollPx;
      if (sx < -64 || sx > size.width + 64) continue;
      final sy = c.yNorm * size.height;
      _drawKind(canvas, Offset(sx, sy), c.kind);
    }
  }

  // ─── dispatch ────────────────────────────────────────────────────────────────

  void _drawKind(Canvas canvas, Offset c, CollectibleKind k) {
    // Animated glow pulse ring behind each collectible
    _glowRing(canvas, c);

    switch (k) {
      case CollectibleKind.redChile:
        _chile(canvas, c, const Color(0xFFCC1A1A));
      case CollectibleKind.greenChile:
        _chile(canvas, c, const Color(0xFF2D7A1F));
      case CollectibleKind.zia:
        _zia(canvas, c);
      case CollectibleKind.route66:
        _route66(canvas, c);
      case CollectibleKind.roadRunner:
        _roadRunner(canvas, c);
      case CollectibleKind.sandia:
        _sandia(canvas, c);
      case CollectibleKind.burqueHeart:
        _heart(canvas, c, const Color(0xFFE91E63));
      case CollectibleKind.hotAirBalloon:
        _miniBalloon(canvas, c);
      case CollectibleKind.taco:
        _taco(canvas, c);
      case CollectibleKind.coin:
        _coin(canvas, c);
    }
  }

  // ─── glow ring ───────────────────────────────────────────────────────────────

  void _glowRing(Canvas canvas, Offset c) {
    final pulse = 0.55 + 0.45 * math.sin(timeSec * 3.2);
    final r = 22.0 + pulse * 4;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          c,
          r,
          [
            Colors.white.withValues(alpha: 0.22 * pulse),
            Colors.white.withValues(alpha: 0.0),
          ],
          const [0.4, 1.0],
        ),
    );
  }

  // ─── sprites ─────────────────────────────────────────────────────────────────

  void _chile(Canvas canvas, Offset c, Color fill) {
    // Body
    final body = Path()
      ..moveTo(c.dx, c.dy - 20)
      ..cubicTo(c.dx + 26, c.dy - 16, c.dx + 28, c.dy + 6, c.dx + 10, c.dy + 22)
      ..cubicTo(c.dx + 2, c.dy + 26, c.dx - 4, c.dy + 24, c.dx - 8, c.dy + 14)
      ..cubicTo(c.dx - 14, c.dy + 2, c.dx - 8, c.dy - 16, c.dx, c.dy - 20)
      ..close();
    canvas.drawPath(body, Paint()..color = fill);

    // Highlight
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.transparent,
          ],
          begin: Alignment.topLeft,
          end: Alignment.center,
        ).createShader(Rect.fromCenter(center: c, width: 56, height: 56)),
    );

    // Stem
    canvas.drawLine(
      Offset(c.dx, c.dy - 20),
      Offset(c.dx + 4, c.dy - 30),
      Paint()
        ..color = const Color(0xFF388E3C)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Outline
    canvas.drawPath(
      body,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
  }

  void _zia(Canvas canvas, Offset c) {
    const r = 26.0;
    // Outer circle
    canvas.drawCircle(
      c,
      r * 0.38,
      Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      c,
      r * 0.38,
      Paint()
        ..color = const Color(0xFFE65100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // 4 groups of 4 rays
    final rayPaint = Paint()
      ..color = const Color(0xFFE65100)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;

    for (var g = 0; g < 4; g++) {
      final groupAngle = g * math.pi / 2;
      for (var i = 0; i < 4; i++) {
        final a = groupAngle - 0.3 + i * 0.2;
        const innerR = r * 0.42;
        final outerR = r * (0.70 + i * 0.075);
        canvas.drawLine(
          Offset(c.dx + math.cos(a) * innerR, c.dy + math.sin(a) * innerR),
          Offset(c.dx + math.cos(a) * outerR, c.dy + math.sin(a) * outerR),
          rayPaint,
        );
      }
    }
  }

  void _route66(Canvas canvas, Offset c) {
    // Shield shape
    final shield = Path()
      ..moveTo(c.dx, c.dy - 24)
      ..lineTo(c.dx + 18, c.dy - 10)
      ..lineTo(c.dx + 16, c.dy + 16)
      ..lineTo(c.dx - 16, c.dy + 16)
      ..lineTo(c.dx - 18, c.dy - 10)
      ..close();

    canvas.drawPath(shield, Paint()..color = const Color(0xFF5D4037));
    canvas.drawPath(
      shield,
      Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // "66" text
    final tp = TextPainter(
      text: const TextSpan(
        text: '66',
        style: TextStyle(
          color: Color(0xFFFFD54F),
          fontSize: 15,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2 - 1));
  }

  void _roadRunner(Canvas canvas, Offset c) {
    // Body
    final body = Path()
      ..moveTo(c.dx - 22, c.dy + 6)
      ..quadraticBezierTo(c.dx - 6, c.dy - 18, c.dx + 12, c.dy - 10)
      ..quadraticBezierTo(c.dx + 26, c.dy - 4, c.dx + 24, c.dy + 12)
      ..quadraticBezierTo(c.dx + 6, c.dy + 18, c.dx - 22, c.dy + 6)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF37474F));

    // Beak
    canvas.drawPath(
      Path()
        ..moveTo(c.dx + 20, c.dy - 8)
        ..lineTo(c.dx + 34, c.dy - 13)
        ..lineTo(c.dx + 24, c.dy + 2)
        ..close(),
      Paint()..color = const Color(0xFFFFB74D),
    );

    // Eye
    canvas.drawOval(
      Rect.fromCenter(center: Offset(c.dx - 8, c.dy - 12), width: 9, height: 11),
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(Offset(c.dx - 8, c.dy - 12), 3, Paint()..color = Colors.black87);

    // Crest
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy - 10)
        ..quadraticBezierTo(c.dx + 4, c.dy - 24, c.dx + 8, c.dy - 18),
      Paint()
        ..color = const Color(0xFF8BC34A)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  void _sandia(Canvas canvas, Offset c) {
    // Mountain triangle
    final Offset peak = Offset(c.dx, c.dy - 22);
    final Offset bL = Offset(c.dx - 26, c.dy + 16);
    final Offset bR = Offset(c.dx + 26, c.dy + 16);

    final mtn = Path()
      ..moveTo(peak.dx, peak.dy)
      ..lineTo(bR.dx, bR.dy)
      ..lineTo(bL.dx, bL.dy)
      ..close();

    canvas.drawPath(mtn, Paint()..color = const Color(0xFF2E7D32));

    // Snow cap
    final snow = Path()
      ..moveTo(peak.dx, peak.dy)
      ..lineTo(peak.dx + 10, peak.dy + 10)
      ..lineTo(peak.dx - 10, peak.dy + 10)
      ..close();
    canvas.drawPath(snow, Paint()..color = Colors.white.withValues(alpha: 0.85));

    // Outline
    canvas.drawPath(
      mtn,
      Paint()
        ..color = const Color(0xFF1B5E20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _heart(Canvas canvas, Offset c, Color fill) {
    final p = Path()
      ..moveTo(c.dx, c.dy + 14)
      ..cubicTo(c.dx - 22, c.dy, c.dx - 22, c.dy - 16, c.dx - 8, c.dy - 16)
      ..cubicTo(c.dx, c.dy - 20, c.dx, c.dy - 12, c.dx, c.dy - 12)
      ..cubicTo(c.dx, c.dy - 12, c.dx, c.dy - 20, c.dx + 8, c.dy - 16)
      ..cubicTo(c.dx + 22, c.dy - 16, c.dx + 22, c.dy, c.dx, c.dy + 14)
      ..close();
    canvas.drawPath(p, Paint()..color = fill);
    // Highlight
    canvas.drawPath(
      p,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withValues(alpha: 0.35), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.center,
        ).createShader(Rect.fromCenter(center: c, width: 50, height: 50)),
    );
  }

  void _miniBalloon(Canvas canvas, Offset c) {
    // Envelope
    canvas.drawOval(
      Rect.fromCenter(center: Offset(c.dx, c.dy - 8), width: 28, height: 36),
      Paint()..color = const Color(0xFFE53935),
    );

    // Stripes
    canvas.save();
    canvas.clipRect(Rect.fromCenter(center: Offset(c.dx, c.dy - 8), width: 28, height: 36));
    for (var i = 0; i < 4; i++) {
      canvas.drawRect(
        Rect.fromLTWH(c.dx - 14 + i * 7, c.dy - 26, 3.5, 36),
        Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.55),
      );
    }
    canvas.restore();

    // Basket
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(c.dx, c.dy + 14), width: 14, height: 8),
        const Radius.circular(2),
      ),
      Paint()..color = const Color(0xFF5D4037),
    );

    // Ropes
    final rp = Paint()..color = Colors.black38..strokeWidth = 1.2;
    canvas.drawLine(Offset(c.dx - 4, c.dy + 10), Offset(c.dx - 6, c.dy + 4), rp);
    canvas.drawLine(Offset(c.dx + 4, c.dy + 10), Offset(c.dx + 6, c.dy + 4), rp);
  }

  void _taco(Canvas canvas, Offset c) {
    // Shell
    final shell = Path()
      ..moveTo(c.dx - 24, c.dy + 8)
      ..quadraticBezierTo(c.dx, c.dy - 18, c.dx + 24, c.dy + 8)
      ..close();
    canvas.drawPath(shell, Paint()..color = const Color(0xFFFFB300));
    canvas.drawPath(
      shell,
      Paint()
        ..color = const Color(0xFF795548)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Lettuce
    canvas.drawArc(
      Rect.fromCenter(center: Offset(c.dx, c.dy + 3), width: 30, height: 12),
      0.05, 3.03, false,
      Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    // Meat squiggle
    canvas.drawArc(
      Rect.fromCenter(center: Offset(c.dx, c.dy - 1), width: 24, height: 8),
      0.15, 2.8, false,
      Paint()
        ..color = const Color(0xFF795548)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _coin(Canvas canvas, Offset c) {
    // Outer coin
    canvas.drawCircle(c, 18, Paint()..color = const Color(0xFFFFD54F));

    // Rim
    canvas.drawCircle(
      c, 18,
      Paint()
        ..color = const Color(0xFFF9A825)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Inner face
    canvas.drawCircle(c, 12, Paint()..color = const Color(0xFFF9A825));

    // Star mark in center (simple 5-point star)
    final starPath = Path();
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5 - math.pi / 2;
      const outer = 6.0;
      const inner = 2.8;
      if (i == 0) {
        starPath.moveTo(c.dx + math.cos(a) * outer, c.dy + math.sin(a) * outer);
      } else {
        starPath.lineTo(c.dx + math.cos(a) * outer, c.dy + math.sin(a) * outer);
      }
      final ai = a + math.pi / 5;
      starPath.lineTo(c.dx + math.cos(ai) * inner, c.dy + math.sin(ai) * inner);
    }
    starPath.close();
    canvas.drawPath(starPath, Paint()..color = const Color(0xFFFFD54F));
  }

  // ─── repaint ─────────────────────────────────────────────────────────────────

  @override
  bool shouldRepaint(covariant CollectiblesPainter old) =>
      old.scrollPx != scrollPx ||
      old.instances.length != instances.length ||
      old.instances != instances ||
      (old.timeSec - timeSec).abs() > 0.016;
}
