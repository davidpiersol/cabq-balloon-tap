import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Rich NM-sky parallax: 3-stop gradient, animated sun halo, drifting cloud puffs,
/// mesa silhouettes with flat-top ridgelines, atmospheric ground fog.
class ParallaxBackgroundPainter extends CustomPainter {
  const ParallaxBackgroundPainter({
    required this.skyTop,
    required this.skyBottom,
    required this.scrollPx,
    required this.timeSec,
    this.skyHorizon,
  });

  final Color skyTop;
  final Color skyBottom;

  /// Optional mid-sky colour (Sandia pink / warm haze at the horizon band).
  final Color? skyHorizon;
  final double scrollPx;
  final double timeSec;

  // ─── palette helpers ────────────────────────────────────────────────────────

  static Color _withA(Color c, double a) => c.withValues(alpha: a.clamp(0, 1));

  // ─── paint ──────────────────────────────────────────────────────────────────

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    // 1 ── Sky gradient (3-stop with optional horizon band) ──────────────────
    final colors = skyHorizon == null
        ? <Color>[skyTop, skyBottom]
        : <Color>[skyTop, skyHorizon!, skyBottom];
    final stops = skyHorizon == null ? null : <double>[0.0, 0.48, 1.0];
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

    // 2 ── Sun with radial halo ───────────────────────────────────────────────
    _paintSun(canvas, size);

    // 3 ── High clouds (distant, slow scroll) ────────────────────────────────
    _paintClouds(canvas, size, layer: 0, scrollFactor: 0.04, yBand: 0.12, alpha: 0.18);

    // 4 ── Mid clouds ────────────────────────────────────────────────────────
    _paintClouds(canvas, size, layer: 1, scrollFactor: 0.09, yBand: 0.22, alpha: 0.14);

    // 5 ── Mesa ridgelines (4 layers, back→front) ────────────────────────────
    _mesa(canvas, size,
        shift: scrollPx * 0.10,
        baseY: h * 0.56,
        profile: _MesaProfile.distant,
        fill: _withA(const Color(0xFF8AADB8), 0.42));

    _mesa(canvas, size,
        shift: scrollPx * 0.22,
        baseY: h * 0.63,
        profile: _MesaProfile.mid,
        fill: _withA(const Color(0xFF5A7480), 0.55));

    _mesa(canvas, size,
        shift: scrollPx * 0.42,
        baseY: h * 0.72,
        profile: _MesaProfile.near,
        fill: _withA(const Color(0xFF3A4E57), 0.72));

    _mesa(canvas, size,
        shift: scrollPx * 0.70,
        baseY: h * 0.81,
        profile: _MesaProfile.foreground,
        fill: _withA(const Color(0xFF22323A), 0.88));

    // 6 ── Ground strip with warm sand colour ────────────────────────────────
    _paintGround(canvas, size);

    // 7 ── Atmospheric fog at the horizon ────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.50, w, h * 0.18),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            _withA(skyBottom, 0.18),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, h * 0.50, w, h * 0.18)),
    );
  }

  // ─── sun ────────────────────────────────────────────────────────────────────

  void _paintSun(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Sun drifts slightly with scroll and oscillates vertically (slow drift).
    final sx = (w * 0.80 - scrollPx * 0.06).clamp(w * 0.55, w * 0.98);
    final sy = h * 0.12 + math.sin(timeSec * 0.35) * 2.5;
    final r = math.min(w, h) * 0.052;

    // Outer glow
    canvas.drawCircle(
      Offset(sx, sy),
      r * 3.2,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(sx, sy),
          r * 3.2,
          [
            _withA(Colors.white, 0.18),
            _withA(Colors.white, 0.06),
            Colors.transparent,
          ],
          const [0.0, 0.4, 1.0],
        ),
    );

    // Mid halo
    canvas.drawCircle(
      Offset(sx, sy),
      r * 1.5,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(sx, sy),
          r * 1.5,
          [
            _withA(Colors.white, 0.42),
            _withA(const Color(0xFFFFEFBF), 0.28),
            Colors.transparent,
          ],
          const [0.0, 0.55, 1.0],
        ),
    );

    // Core disc
    canvas.drawCircle(
      Offset(sx, sy),
      r,
      Paint()..color = Colors.white.withValues(alpha: 0.88),
    );
  }

  // ─── clouds ─────────────────────────────────────────────────────────────────

  void _paintClouds(
    Canvas canvas,
    Size size, {
    required int layer,
    required double scrollFactor,
    required double yBand,
    required double alpha,
  }) {
    final w = size.width;
    final h = size.height;
    const rng = _CloudRng();
    // Each layer has 5 cloud puffs tiled across 2× screen width.
    const tileW = 5;
    final shift = (scrollPx * scrollFactor + layer * 173.0) % (w * 2);

    for (var i = 0; i < tileW; i++) {
      final cx = (i / tileW * w * 2 - shift + w * 2) % (w * 2) - w * 0.2;
      if (cx < -w * 0.3 || cx > w * 1.3) continue;
      final cy = h * yBand + rng.offsetY(layer * 5 + i, h * 0.06);
      final scale = 0.6 + rng.scale(layer * 5 + i) * 0.8;
      _drawCloudPuff(canvas, Offset(cx, cy), scale, alpha);
    }
  }

  void _drawCloudPuff(Canvas canvas, Offset center, double scale, double alpha) {
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha);
    final r = 22.0 * scale;
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center.translate(-r * 0.65, r * 0.1), r * 0.72, paint);
    canvas.drawCircle(center.translate(r * 0.65, r * 0.12), r * 0.68, paint);
    canvas.drawCircle(center.translate(-r * 0.3, -r * 0.45), r * 0.58, paint);
    canvas.drawCircle(center.translate(r * 0.3, -r * 0.38), r * 0.52, paint);
  }

  // ─── mesa ridgelines ────────────────────────────────────────────────────────

  void _mesa(
    Canvas canvas,
    Size size, {
    required double shift,
    required double baseY,
    required _MesaProfile profile,
    required Color fill,
  }) {
    final w = size.width;
    final h = size.height;
    const step = 4.0;
    final path = Path();
    path.moveTo(-120, h);

    var x = -120.0;
    while (x <= w + 120) {
      final y = _mesaY(x, shift, baseY, h, profile);
      path.lineTo(x, y);
      x += step;
    }
    path.lineTo(w + 120, h);
    path.close();
    canvas.drawPath(path, Paint()..color = fill);
  }

  double _mesaY(
      double x, double shift, double baseY, double h, _MesaProfile p) {
    final t = x + shift;
    return switch (p) {
      _MesaProfile.distant => baseY +
          math.sin(t * 2 * math.pi / 300) * h * 0.035 +
          math.sin(t * 2 * math.pi / 80) * h * 0.012,
      _MesaProfile.mid => baseY +
          _flatTop(t, 240, h * 0.028) +
          math.sin(t * 2 * math.pi / 60) * h * 0.014,
      _MesaProfile.near => baseY +
          _flatTop(t, 180, h * 0.038) +
          math.sin(t * 2 * math.pi / 45 + 1.2) * h * 0.016,
      _MesaProfile.foreground => baseY +
          _flatTop(t, 140, h * 0.042) +
          math.sin(t * 2 * math.pi / 35 + 2.4) * h * 0.018,
    };
  }

  /// Creates mesa flat-tops: the min() clamps peaks into plateaus.
  double _flatTop(double t, double period, double amp) {
    final raw = math.sin(t * 2 * math.pi / period) * amp;
    return math.min(raw, amp * 0.35);
  }

  // ─── ground ─────────────────────────────────────────────────────────────────

  void _paintGround(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final groundRect = Rect.fromLTWH(0, h * 0.88, w, h * 0.12);
    canvas.drawRect(
      groundRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFFC4A882),
            Color(0xFF9E7B56),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(groundRect),
    );
    // Subtle surface scratches / wind lines
    final linePaint = Paint()
      ..color = const Color(0xFF7A5C3A).withValues(alpha: 0.18)
      ..strokeWidth = 1;
    for (var i = 0; i < 6; i++) {
      final y = h * (0.895 + i * 0.018);
      canvas.drawLine(Offset(0, y), Offset(w, y), linePaint);
    }
  }

  // ─── repaint ────────────────────────────────────────────────────────────────

  @override
  bool shouldRepaint(covariant ParallaxBackgroundPainter old) =>
      old.skyTop != skyTop ||
      old.skyBottom != skyBottom ||
      old.skyHorizon != skyHorizon ||
      old.scrollPx != scrollPx ||
      (old.timeSec - timeSec).abs() > 0.016;
}

// ─── internal helpers ──────────────────────────────────────────────────────────

enum _MesaProfile { distant, mid, near, foreground }

/// Deterministic "random" offsets for cloud puffs — no dart:math Random needed.
class _CloudRng {
  const _CloudRng();

  double offsetY(int seed, double range) {
    return ((seed * 1664525 + 1013904223) & 0x7FFFFFFF) / 0x7FFFFFFF * range -
        range / 2;
  }

  double scale(int seed) {
    return ((seed * 22695477 + 1) & 0x7FFFFFFF) / 0x7FFFFFFF;
  }
}
