import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../game/collectibles/collectible_catalog.dart';
import '../game/collectibles/collectible_world.dart';

/// Simple vector sprites for NM-themed pickups (scrolls with world X).
class CollectiblesPainter extends CustomPainter {
  CollectiblesPainter({
    required this.instances,
    required this.scrollPx,
  });

  final List<CollectibleInstance> instances;
  final double scrollPx;

  @override
  void paint(Canvas canvas, Size size) {
    for (final c in instances) {
      final sx = c.worldX - scrollPx;
      if (sx < -48 || sx > size.width + 48) continue;
      final sy = c.yNorm * size.height;
      _drawKind(canvas, Offset(sx, sy), c.kind);
    }
  }

  void _drawKind(Canvas canvas, Offset c, CollectibleKind k) {
    switch (k) {
      case CollectibleKind.redChile:
        _chile(canvas, c, const Color(0xFFB71C1C));
        break;
      case CollectibleKind.greenChile:
        _chile(canvas, c, const Color(0xFF2E7D32));
        break;
      case CollectibleKind.zia:
        _zia(canvas, c);
        break;
      case CollectibleKind.route66:
        _route66(canvas, c);
        break;
      case CollectibleKind.roadRunner:
        _roadRunner(canvas, c);
        break;
      case CollectibleKind.sandia:
        _sandia(canvas, c);
        break;
      case CollectibleKind.burqueHeart:
        _heart(canvas, c, const Color(0xFFE91E63));
        break;
      case CollectibleKind.hotAirBalloon:
        _miniBalloon(canvas, c);
        break;
      case CollectibleKind.taco:
        _taco(canvas, c);
        break;
      case CollectibleKind.coin:
        _coin(canvas, c);
        break;
    }
  }

  void _chile(Canvas canvas, Offset c, Color fill) {
    final p = Path()
      ..moveTo(c.dx, c.dy - 14)
      ..quadraticBezierTo(c.dx + 18, c.dy + 4, c.dx + 6, c.dy + 16)
      ..quadraticBezierTo(c.dx - 10, c.dy + 8, c.dx, c.dy - 14)
      ..close();
    canvas.drawPath(
      p,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      p,
      Paint()
        ..color = const Color(0xFF3E2723)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  void _zia(Canvas canvas, Offset c) {
    const r = 22.0;
    final center = c;
    final paint = Paint()
      ..color = const Color(0xFFFFD54F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    for (var g = 0; g < 4; g++) {
      final a0 = g * math.pi / 2 - math.pi / 4;
      for (var i = 0; i < 4; i++) {
        final a = a0 + i * 0.22;
        final len = r * (0.55 + i * 0.12);
        canvas.drawLine(
          center,
          Offset(center.dx + math.cos(a) * len, center.dy + math.sin(a) * len),
          paint,
        );
      }
    }
    canvas.drawCircle(center, 3.2, Paint()..color = const Color(0xFFFFD54F));
  }

  void _route66(Canvas canvas, Offset c) {
    final shield = Path()
      ..moveTo(c.dx, c.dy - 20)
      ..lineTo(c.dx + 16, c.dy - 8)
      ..lineTo(c.dx + 14, c.dy + 14)
      ..lineTo(c.dx - 14, c.dy + 14)
      ..lineTo(c.dx - 16, c.dy - 8)
      ..close();
    canvas.drawPath(shield, Paint()..color = const Color(0xFF5D4037));
    canvas.drawPath(
      shield,
      Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final tp = TextPainter(
      text: const TextSpan(
        text: '66',
        style: TextStyle(
          color: Color(0xFFFFD54F),
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(c.dx - tp.width / 2, c.dy - tp.height / 2 - 2));
  }

  void _roadRunner(Canvas canvas, Offset c) {
    final body = Path()
      ..moveTo(c.dx - 18, c.dy + 4)
      ..quadraticBezierTo(c.dx - 6, c.dy - 14, c.dx + 10, c.dy - 8)
      ..quadraticBezierTo(c.dx + 22, c.dy - 2, c.dx + 20, c.dy + 10)
      ..quadraticBezierTo(c.dx + 4, c.dy + 14, c.dx - 18, c.dy + 4)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFF37474F));
    canvas.drawPath(
      Path()
        ..moveTo(c.dx + 18, c.dy - 6)
        ..lineTo(c.dx + 30, c.dy - 10)
        ..lineTo(c.dx + 22, c.dy + 2)
        ..close(),
      Paint()..color = const Color(0xFFFFB74D),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(c.dx - 8, c.dy - 10), width: 8, height: 10),
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(Offset(c.dx - 8, c.dy - 10), 2.5, Paint()..color = Colors.black87);
  }

  void _sandia(Canvas canvas, Offset c) {
    final tri = Path()
      ..moveTo(c.dx, c.dy - 18)
      ..lineTo(c.dx + 22, c.dy + 14)
      ..lineTo(c.dx - 22, c.dy + 14)
      ..close();
    canvas.drawPath(tri, Paint()..color = const Color(0xFF2E7D32));
    canvas.drawPath(
      tri,
      Paint()
        ..color = const Color(0xFF1B5E20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(c.dx - 6, c.dy + 2),
      Offset(c.dx + 8, c.dy + 8),
      Paint()
        ..color = const Color(0xFF8BC34A)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _heart(Canvas canvas, Offset c, Color fill) {
    final p = Path()
      ..moveTo(c.dx, c.dy + 10)
      ..cubicTo(c.dx - 18, c.dy - 2, c.dx - 18, c.dy - 14, c.dx - 6, c.dy - 14)
      ..cubicTo(c.dx, c.dy - 18, c.dx, c.dy - 10, c.dx, c.dy - 10)
      ..cubicTo(c.dx, c.dy - 10, c.dx, c.dy - 18, c.dx + 6, c.dy - 14)
      ..cubicTo(c.dx + 18, c.dy - 14, c.dx + 18, c.dy - 2, c.dx, c.dy + 10)
      ..close();
    canvas.drawPath(p, Paint()..color = fill);
  }

  void _miniBalloon(Canvas canvas, Offset c) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(c.dx, c.dy - 4), width: 22, height: 28),
      Paint()..color = const Color(0xFFE53935),
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(c.dx, c.dy + 14), width: 10, height: 8),
      Paint()..color = const Color(0xFF5D4037),
    );
    canvas.drawLine(
      Offset(c.dx, c.dy + 8),
      Offset(c.dx, c.dy + 10),
      Paint()..color = const Color(0xFF3E2723)..strokeWidth = 1.5,
    );
  }

  void _taco(Canvas canvas, Offset c) {
    final shell = Path()
      ..moveTo(c.dx - 20, c.dy + 6)
      ..quadraticBezierTo(c.dx, c.dy - 14, c.dx + 20, c.dy + 6)
      ..close();
    canvas.drawPath(shell, Paint()..color = const Color(0xFFFFB300));
    canvas.drawPath(
      shell,
      Paint()
        ..color = const Color(0xFF795548)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawArc(
      Rect.fromCenter(center: Offset(c.dx, c.dy + 2), width: 24, height: 10),
      0.1,
      2.9,
      false,
      Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _coin(Canvas canvas, Offset c) {
    canvas.drawCircle(c, 14, Paint()..color = const Color(0xFFFFD54F));
    canvas.drawCircle(
      c,
      14,
      Paint()
        ..color = const Color(0xFFF9A825)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(c, 9, Paint()..color = const Color(0xFFF9A825));
  }

  @override
  bool shouldRepaint(covariant CollectiblesPainter oldDelegate) {
    return oldDelegate.scrollPx != scrollPx ||
        oldDelegate.instances.length != instances.length ||
        oldDelegate.instances != instances;
  }
}
