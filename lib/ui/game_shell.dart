import 'package:flutter/material.dart';

import '../security/safe_links.dart';
import '../theme/cabq_theme.dart';
import 'balloon_game.dart';

class GameShell extends StatelessWidget {
  const GameShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balloon Tap'),
        actions: [
          IconButton(
            tooltip: 'About and City of Albuquerque links',
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAbout(context),
          ),
        ],
      ),
      body: const BalloonGame(),
    );
  }

  Future<void> _showAbout(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'City of Albuquerque',
                style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                      color: CabqTheme.primary,
                      letterSpacing: 0.4,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Balloon Tap',
                style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tap anywhere to give the balloon lift. Keep it in the sky — '
                'don’t let it touch the ground or float away. Skins celebrate '
                'Balloon Fiesta and Albuquerque skies.',
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  final ok = await openCabqLearnMore(
                    'https://www.cabq.gov/culturalservices/balloonmuseum',
                  );
                  if (!ctx.mounted) return;
                  if (!ok) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Could not open link.')),
                    );
                  }
                },
                icon: const Icon(Icons.museum_outlined),
                label: const Text('Balloon Museum — cabq.gov'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  await openCabqLearnMore('https://www.cabq.gov/');
                },
                icon: const Icon(Icons.public),
                label: const Text('cabq.gov home'),
              ),
            ],
          ),
        );
      },
    );
  }
}
