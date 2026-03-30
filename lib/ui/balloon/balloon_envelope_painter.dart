import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../game/balloon_appearance.dart';

/// Renders the balloon envelope with 3-D depth (radial highlight + shadow),
/// 4-point wicker-look basket, and proper rope rigging.
class BalloonEnvelopePainter extends CustomPainter {
  const BalloonEnvelopePainter({required this.appearance, this.swayDeg = 0});

  final BalloonAppearance appearance;

  /// Subtle sway angle in degrees (positive = lean right). 0 = upright.
  final double swayDeg;

  Color get _a => Color(appearance.colorA);
  Color get _b => Color(appearance.colorB);
  Color get _c => Color(appearance.colorC);

  // ─── paint ──────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.save();
    // Slight sway pivot at basket neck
    if (swayDeg != 0) {
      canvas.translate(w * 0.5, h * 0.72);
      canvas.rotate(swayDeg * math.pi / 180);
      canvas.translate(-w * 0.5, -h * 0.72);
    }

    final envelopeRect = Rect.fromLTWH(w * 0.08, 0, w * 0.84, h * 0.74);
    final envelope = Path()..addOval(envelopeRect);

    // ── fill with pattern ────────────────────────────────────────────────────
    canvas.save();
    canvas.clipPath(envelope);
    switch (appearance.pattern) {
      case BalloonPattern.solid:
        _paintSolid(canvas, w, h);
      case BalloonPattern.stripes:
        _paintStripes(canvas, w, h);
      case BalloonPattern.patchwork:
        _paintPatchwork(canvas, w, h);
    }
    canvas.restore();

    // ── radial specular highlight (3-D sphere feel) ───────────────────────────
    final cx = w * 0.38;
    final cy = h * 0.22;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: w * 0.38, height: h * 0.28),
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, cy),
          w * 0.22,
          [
            Colors.white.withValues(alpha: 0.55),
            Colors.white.withValues(alpha: 0.18),
            Colors.transparent,
          ],
          const [0.0, 0.45, 1.0],
        ),
    );

    // ── shadow on bottom-right ────────────────────────────────────────────────
    canvas.save();
    canvas.clipPath(envelope);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.65, h * 0.58),
        width: w * 0.6,
        height: h * 0.5,
      ),
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(w * 0.65, h * 0.58),
          w * 0.4,
          [
            Colors.black.withValues(alpha: 0.28),
            Colors.transparent,
          ],
          const [0.0, 1.0],
        ),
    );
    canvas.restore();

    // ── outline ───────────────────────────────────────────────────────────────
    canvas.drawPath(
      envelope,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // ── 4-point rope rigging ──────────────────────────────────────────────────
    _drawRopes(canvas, w, h);

    // ── wicker basket ─────────────────────────────────────────────────────────
    _drawBasket(canvas, w, h);

    canvas.restore();
  }

  // ─── fill patterns ──────────────────────────────────────────────────────────

  void _paintSolid(Canvas canvas, double w, double h) {
    final shader = LinearGradient(
      colors: [_a, _b, _c],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(w * 0.08, 0, w * 0.84, h * 0.74));
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.74),
      Paint()..shader = shader,
    );
  }

  void _paintStripes(Canvas canvas, double w, double h) {
    final colors = [_a, _b, _c];
    final panelW = w / 8;
    for (var i = 0; i < 8; i++) {
      final c = colors[i % colors.length];
      // Slight shading variation per panel using HSL lightness
      final shade = i.isEven ? 0.0 : -0.08;
      final hsl = HSLColor.fromColor(c);
      final shaded = hsl
          .withLightness((hsl.lightness + shade).clamp(0.0, 1.0))
          .toColor();
      canvas.drawRect(
        Rect.fromLTWH(i * panelW, 0, panelW + 1, h * 0.74),
        Paint()..color = shaded,
      );
    }
  }

  void _paintPatchwork(Canvas canvas, double w, double h) {
    final colors = [_a, _b, _c];
    final bandH = h * 0.74 / 3;
    for (var i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(0, i * bandH, w, bandH + 1),
        Paint()..color = colors[i],
      );
      // Divider seam
      canvas.drawLine(
        Offset(0, i * bandH),
        Offset(w, i * bandH),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..strokeWidth = 1.2,
      );
    }
  }

  // ─── ropes ──────────────────────────────────────────────────────────────────

  void _drawRopes(Canvas canvas, double w, double h) {
    final ropePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.42)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    // 4 ropes: inner-left, outer-left, inner-right, outer-right
    final ropeAnchors = [
      Offset(w * 0.35, h * 0.67), // envelope bottom-left inner
      Offset(w * 0.26, h * 0.62), // envelope bottom-left outer
      Offset(w * 0.65, h * 0.67), // envelope bottom-right inner
      Offset(w * 0.74, h * 0.62), // envelope bottom-right outer
    ];
    final basketTop = [
      Offset(w * 0.38, h * 0.74), // basket left inner
      Offset(w * 0.33, h * 0.74), // basket left outer
      Offset(w * 0.62, h * 0.74), // basket right inner
      Offset(w * 0.67, h * 0.74), // basket right outer
    ];
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(ropeAnchors[i], basketTop[i], ropePaint);
    }
  }

  // ─── basket ──────────────────────────────────────────────────────────────────

  void _drawBasket(Canvas canvas, double w, double h) {
    final basketColor = Color(appearance.basketArgb);
    final shadowColor = HSLColor.fromColor(basketColor)
        .withLightness(
          (HSLColor.fromColor(basketColor).lightness - 0.18).clamp(0.0, 1.0),
        )
        .toColor();
    final highlightColor = HSLColor.fromColor(basketColor)
        .withLightness(
          (HSLColor.fromColor(basketColor).lightness + 0.16).clamp(0.0, 1.0),
        )
        .toColor();

    final basketRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.30, h * 0.74, w * 0.40, h * 0.22),
      const Radius.circular(5),
    );

    // Main fill with gradient
    canvas.drawRRect(
      basketRect,
      Paint()
        ..shader = LinearGradient(
          colors: [highlightColor, basketColor, shadowColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(basketRect.outerRect),
    );

    // Wicker weave lines
    final wickerPaint = Paint()
      ..color = shadowColor.withValues(alpha: 0.55)
      ..strokeWidth = 1.0;

    final bx = w * 0.30;
    final by = h * 0.74;
    final bw = w * 0.40;
    final bh = h * 0.22;

    canvas.save();
    canvas.clipRRect(basketRect);

    // Horizontal strands
    for (var i = 1; i < 4; i++) {
      final y = by + i * (bh / 4);
      canvas.drawLine(Offset(bx, y), Offset(bx + bw, y), wickerPaint);
    }
    // Vertical strands
    for (var i = 1; i < 6; i++) {
      final x = bx + i * (bw / 6);
      canvas.drawLine(Offset(x, by), Offset(x, by + bh), wickerPaint);
    }
    canvas.restore();

    // Outline
    canvas.drawRRect(
      basketRect,
      Paint()
        ..color = shadowColor.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  // ─── repaint ────────────────────────────────────────────────────────────────

  @override
  bool shouldRepaint(covariant BalloonEnvelopePainter old) =>
      old.appearance != appearance || old.swayDeg != swayDeg;
}
