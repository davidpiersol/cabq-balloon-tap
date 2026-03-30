import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// First-launch cinematic splash inspired by concept frame 1.
class TitleSplashOverlay extends StatelessWidget {
  const TitleSplashOverlay({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _SkyBackdrop(),
          Center(
            child: Container(
              width: math.min(MediaQuery.of(context).size.width * 0.88, 430),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
              decoration: BoxDecoration(
                color: const Color(0x5510162A),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Balloon Tap 2.0',
                        key: const ValueKey<String>('title_splash_label'),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: const Color(0xFFFFE6B6),
                              fontWeight: FontWeight.w900,
                              height: 1.0,
                              shadows: const [
                                Shadow(
                                  blurRadius: 12,
                                  color: Color(0xAA000000),
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Mass Ascension Adventure',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              letterSpacing: 0.8,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        key: const ValueKey<String>(
                          'title_splash_start_button',
                        ),
                        onPressed: onStart,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFF4AF3A),
                          foregroundColor: const Color(0xFF2A1E12),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 42,
                            vertical: 14,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                        child: const Text('PLAY'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkyBackdrop extends StatelessWidget {
  const _SkyBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F3277), Color(0xFFBE86B3), Color(0xFFF6C08B)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _BalloonDot(alignment: Alignment(-0.72, -0.44), size: 42),
          _BalloonDot(alignment: Alignment(-0.34, -0.52), size: 28),
          _BalloonDot(alignment: Alignment(0.52, -0.46), size: 36),
          _BalloonDot(alignment: Alignment(0.77, -0.26), size: 22),
          _BalloonDot(alignment: Alignment(0.08, -0.2), size: 18),
          _RidgeBand(yAlign: 0.58, height: 170, color: Color(0x77556688)),
          _RidgeBand(yAlign: 0.72, height: 190, color: Color(0x992F3550)),
        ],
      ),
    );
  }
}

class _BalloonDot extends StatelessWidget {
  const _BalloonDot({required this.alignment, required this.size});

  final Alignment alignment;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size * 1.2,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _RidgeBand extends StatelessWidget {
  const _RidgeBand({
    required this.yAlign,
    required this.height,
    required this.color,
  });

  final double yAlign;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0, yAlign),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(180)),
        ),
      ),
    );
  }
}
