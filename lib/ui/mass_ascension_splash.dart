import 'package:flutter/material.dart';

import '../theme/cabq_theme.dart';

/// Full-screen title screen aligned with concept frame 1 (mass ascension dawn).
/// No municipal branding on-splash; About sheet remains the CABQ link surface.
class MassAscensionSplash extends StatelessWidget {
  const MassAscensionSplash({super.key, required this.onPlay});

  static const assetPath = 'assets/images/splash_mass_ascension.png';

  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Semantics(
              label: 'Balloon Tap 2.0 mass ascension sky',
              excludeSemantics: true,
              child: Image.asset(
                assetPath,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1E2A4A),
                        CabqTheme.skyTop,
                        CabqTheme.skyBottom,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.45),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Balloon Tap 2.0',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFFFFF8E7),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      shadows: const [
                        Shadow(blurRadius: 12, color: Colors.black54),
                        Shadow(blurRadius: 4, color: Colors.black45),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mass Ascension Adventure',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: const Color(0xFFE8C078),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.6,
                      shadows: const [Shadow(blurRadius: 8, color: Colors.black54)],
                    ),
                  ),
                  const Spacer(),
                  Semantics(
                    label: 'Play, start game',
                    button: true,
                    child: FilledButton(
                      key: const ValueKey<String>('splash_play_button'),
                      onPressed: onPlay,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: CabqTheme.accent,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'PLAY',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
