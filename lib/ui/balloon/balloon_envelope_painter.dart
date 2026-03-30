import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../game/balloon_appearance.dart';

/// Renders the balloon envelope + basket with v2 highlight/shadow depth.
class BalloonEnvelopePainter extends CustomPainter {
  BalloonEnvelopePainter({required this.appearance});

  final BalloonAppearance appearance;

  Color get _a => Color(appearance.colorA);
  Color get _b => Color(appearance.colorB);
  Color get _c => Color(appearance.colorC);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final envelope = Path()
      ..addOval(Rect.fromLTWH(w * 0.1, 0, w * 0.8, h * 0.72));

    switch (appearance.pattern) {
      case BalloonPattern.solid:
        _paintSolid(canvas, envelope, w, h);
      case BalloonPattern.stripes:
        _paintStripes(canvas, envelope, w, h);
      case BalloonPattern.patchwork:
        _paintPatchwork(canvas, envelope, w, h);
    }

    // Specular highlight on the upper-left
    canvas.save();
    canvas.clipPath(envelope);
    canvas.drawOval(
      Rect.fromLTWH(w * 0.15, h * 0.02, w * 0.4, h * 0.35),
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(w * 0.35, h * 0.12),
          w * 0.25,
          [
            Colors.white.withValues(alpha: 0.38),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
    );
    // Shadow on the lower-right
    canvas.drawOval(
      Rect.fromLTWH(w * 0.45, h * 0.35, w * 0.42, h * 0.35),
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(w * 0.65, h * 0.52),
          w * 0.22,
          [
            Colors.black.withValues(alpha: 0.18),
            Colors.black.withValues(alpha: 0.0),
          ],
        ),
    );
    canvas.restore();

    // Outline
    canvas.drawPath(
      envelope,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Basket
    final basket = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.32, h * 0.68, w * 0.36, h * 0.22),
      const Radius.circular(6),
    );
    final basketColor = Color(appearance.basketArgb);
    canvas.drawRRect(
      basket,
      Paint()
        ..shader = LinearGradient(
          colors: [basketColor, Color.lerp(basketColor, Colors.black, 0.25)!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(w * 0.32, h * 0.68, w * 0.36, h * 0.22)),
    );

    // Rigging lines
    final rig = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(w * 0.35, h * 0.68), Offset(w * 0.38, h * 0.55), rig);
    canvas.drawLine(Offset(w * 0.65, h * 0.68), Offset(w * 0.62, h * 0.55), rig);
    // Additional center rigging for depth
    canvas.drawLine(Offset(w * 0.42, h * 0.68), Offset(w * 0.45, h * 0.58), rig);
    canvas.drawLine(Offset(w * 0.58, h * 0.68), Offset(w * 0.55, h * 0.58), rig);
  }

  void _paintSolid(Canvas canvas, Path envelope, double w, double h) {
    final shader = LinearGradient(
      colors: [_a, _b, _c],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(envelope, Paint()..shader = shader);
  }

  void _paintStripes(Canvas canvas, Path envelope, double w, double h) {
    canvas.save();
    canvas.clipPath(envelope);
    final stripeW = w * 0.12;
    var x = 0.0;
    var i = 0;
    while (x < w) {
      final color = [_a, _b, _c][i % 3];
      canvas.drawRect(
          Rect.fromLTWH(x, 0, stripeW + 1, h * 0.72), Paint()..color = color);
      x += stripeW;
      i++;
    }
    canvas.restore();
  }

  void _paintPatchwork(Canvas canvas, Path envelope, double w, double h) {
    canvas.save();
    canvas.clipPath(envelope);
    final bandH = h * 0.72 / 3;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, w * 0.8 + w * 0.2, bandH), Paint()..color = _a);
    canvas.drawRect(
        Rect.fromLTWH(0, bandH, w, bandH), Paint()..color = _b);
    canvas.drawRect(
        Rect.fromLTWH(0, bandH * 2, w, bandH + 2), Paint()..color = _c);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BalloonEnvelopePainter oldDelegate) =>
      oldDelegate.appearance != appearance;
}
