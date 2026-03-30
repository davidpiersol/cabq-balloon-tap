import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../theme/cabq_theme.dart';

class OnboardingOverlay extends StatelessWidget {
  const OnboardingOverlay({super.key, required this.onContinue});

  final VoidCallback onContinue;

  static const lottieAsset = 'assets/lottie/nm_sparkle.json';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.black54,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Semantics(
              label: 'Welcome to Balloon Tap. How to play.',
              child: Card(
                elevation: 8,
                clipBehavior: Clip.antiAlias,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 120,
                          child: Lottie.asset(
                            lottieAsset,
                            fit: BoxFit.contain,
                            repeat: true,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Balloon Tap',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: CabqTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'New Mexico skies, Balloon Fiesta energy.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: CabqTheme.accent,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _Bullet(text: 'Hold anywhere to fire the burner and rise.'),
                        const _Bullet(text: 'Release to coast briefly, then you descend.'),
                        const _Bullet(text: 'Collect icons for bonus points — stay aloft!'),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: onContinue,
                          child: const Text("Let's fly"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.wb_sunny_outlined, size: 20, color: CabqTheme.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
