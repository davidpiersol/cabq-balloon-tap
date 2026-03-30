import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/cabq_theme.dart';

/// Mass ascension dawn splash matching mockup 1.
/// Animated gradient sky, floating mini-balloons, title, and play CTA.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onPlay});

  final VoidCallback onPlay;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          painter: _SplashPainter(timeSec: _ctrl.value * 20),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Spacer(flex: 2),
                  Text(
                    'Balloon Tap',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(blurRadius: 12, color: Colors.black45),
                            Shadow(blurRadius: 4, color: Colors.black26),
                          ],
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '2.0',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: CabqTheme.gold,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 6,
                          shadows: const [
                            Shadow(blurRadius: 8, color: Colors.black38),
                          ],
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'New Mexico skies await',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const Spacer(flex: 3),
                  Padding(
                    padding: EdgeInsets.only(bottom: mq.padding.bottom + 48),
                    child: FilledButton.icon(
                      onPressed: widget.onPlay,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('TAP TO PLAY'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SplashPainter extends CustomPainter {
  _SplashPainter({required this.timeSec});

  final double timeSec;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    // Dawn gradient: deep indigo → Sandia pink → peach gold
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          colors: [
            Color(0xFF1A1A3E),
            Color(0xFF4A2060),
            Color(0xFFFF8FA3),
            Color(0xFFFFCC80),
          ],
          stops: [0.0, 0.28, 0.58, 1.0],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(rect),
    );

    // Sun glow at horizon
    final sunX = size.width * 0.5;
    final sunY = size.height * 0.62;
    canvas.drawCircle(
      Offset(sunX, sunY),
      size.width * 0.22,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(sunX, sunY),
          size.width * 0.22,
          [
            Colors.white.withValues(alpha: 0.30),
            Colors.white.withValues(alpha: 0.0),
          ],
        ),
    );

    // Mountain ridges
    _ridge(canvas, size, shift: timeSec * 2, baseY: size.height * 0.65,
        waveLen: 300, amp: size.height * 0.04,
        fill: const Color(0xFF2A1A3E).withValues(alpha: 0.6));
    _ridge(canvas, size, shift: timeSec * 5, baseY: size.height * 0.72,
        waveLen: 200, amp: size.height * 0.05,
        fill: const Color(0xFF1A1028).withValues(alpha: 0.7));
    _ridge(canvas, size, shift: timeSec * 8, baseY: size.height * 0.80,
        waveLen: 160, amp: size.height * 0.035,
        fill: const Color(0xFF0D0A14).withValues(alpha: 0.85));

    // Mini balloon silhouettes
    _miniBalloons(canvas, size);
  }

  void _ridge(Canvas canvas, Size size,
      {required double shift,
      required double baseY,
      required double waveLen,
      required double amp,
      required Color fill}) {
    final w = size.width;
    final h = size.height;
    final path = Path()..moveTo(-50, h);
    for (var x = -50.0; x <= w + 50; x += 5) {
      final t = (x + shift) * 2 * math.pi / waveLen;
      final y = baseY + math.sin(t) * amp + math.sin(t * 1.7 + 0.8) * amp * 0.3;
      path.lineTo(x, y);
    }
    path.lineTo(w + 50, h);
    path.close();
    canvas.drawPath(path, Paint()..color = fill);
  }

  void _miniBalloons(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const balloons = [
      (0.15, 0.35, 8.0, Color(0xFFE63946)),
      (0.40, 0.28, 6.0, Color(0xFFF4A261)),
      (0.65, 0.38, 7.0, Color(0xFF2A9D8F)),
      (0.80, 0.22, 5.0, Color(0xFFFFD700)),
      (0.30, 0.45, 5.5, Color(0xFF457B9D)),
      (0.55, 0.18, 4.5, Color(0xFFE76F51)),
      (0.90, 0.42, 6.5, Color(0xFF264653)),
    ];
    for (final (xN, yN, r, color) in balloons) {
      final bx = w * xN + math.sin(timeSec * 0.3 + xN * 10) * 3;
      final by = h * yN + math.cos(timeSec * 0.25 + yN * 8) * 2;
      final envelope = Path()..addOval(Rect.fromCenter(
        center: Offset(bx, by), width: r * 2, height: r * 2.6));
      canvas.drawPath(envelope, Paint()..color = color.withValues(alpha: 0.7));
      // Basket dot
      canvas.drawRect(
        Rect.fromCenter(center: Offset(bx, by + r * 1.6), width: r * 0.8, height: r * 0.5),
        Paint()..color = const Color(0xFF5C4033).withValues(alpha: 0.6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplashPainter oldDelegate) => true;
}
