import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../theme/cabq_theme.dart';

/// Game-over overlay matching mockup 4: darkened bg, celebration card,
/// optional Lottie burst for new personal best.
class GameOverCard extends StatelessWidget {
  const GameOverCard({
    super.key,
    required this.score,
    required this.best,
    required this.isNewBest,
    required this.onRestart,
    required this.lottieAsset,
  });

  final int score;
  final int best;
  final bool isNewBest;
  final VoidCallback onRestart;
  final String lottieAsset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.mediumImpact();
            onRestart();
          },
          child: Container(color: Colors.black.withValues(alpha: 0.45)),
        ),
        Center(
          child: Semantics(
            liveRegion: true,
            label: 'Game over. Score $score. Personal best $best.',
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isNewBest)
                  SizedBox(
                    height: 90,
                    width: 200,
                    child: Lottie.asset(lottieAsset, repeat: false, fit: BoxFit.contain),
                  ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isNewBest) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star_rounded, color: CabqTheme.gold, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                'New personal best!',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: CabqTheme.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(
                          'Balloon down!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ScoreBadge(label: 'Score', value: score),
                            const SizedBox(width: 16),
                            _ScoreBadge(label: 'Best', value: best),
                          ],
                        ),
                        const SizedBox(height: 20),
                        FilledButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            onRestart();
                          },
                          icon: const Icon(Icons.replay_rounded),
                          label: const Text('Play again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.grey,
                letterSpacing: 1,
              ),
        ),
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}
