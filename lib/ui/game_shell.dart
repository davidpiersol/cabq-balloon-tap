import 'package:flutter/material.dart';

import '../data/onboarding_store.dart';
import '../security/safe_links.dart';
import '../theme/cabq_theme.dart';
import '../theme/concept_assets.dart';
import 'balloon_game.dart';
import 'onboarding_overlay.dart';

class GameShell extends StatefulWidget {
  const GameShell({super.key});

  @override
  State<GameShell> createState() => _GameShellState();
}

class _GameShellState extends State<GameShell> {
  bool? _onboardingDone;

  @override
  void initState() {
    super.initState();
    _loadOnboarding();
  }

  Future<void> _loadOnboarding() async {
    final done = await OnboardingStore.isOnboardingComplete();
    if (!mounted) return;
    setState(() => _onboardingDone = done);
  }

  Future<void> _completeOnboarding() async {
    await OnboardingStore.markOnboardingComplete();
    if (!mounted) return;
    setState(() => _onboardingDone = true);
  }

  Future<void> _showAbout(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: SingleChildScrollView(
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
                  'Hold the screen to fire the burner and rise. Release to coast briefly, '
                  'then glide down. Keep the balloon off the ground and collect Albuquerque‑themed '
                  'pickups for bonus points. Skins celebrate Balloon Fiesta and New Mexico skies.',
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
                    final ok = await openCabqLearnMore('https://www.cabq.gov/');
                    if (!ctx.mounted) return;
                    if (!ok) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Could not open link.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.public),
                  label: const Text('cabq.gov home'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingDone == null) {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                ConceptAssets.dawnMassAscension,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF1A1A2E)),
              ),
            ),
            Positioned.fill(
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.4)),
            ),
            Center(
              child: Semantics(
                label: 'Loading',
                child: const CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BalloonGame(),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, right: 4),
                child: Material(
                  color: Colors.black38,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: IconButton(
                    key: const ValueKey<String>('about_cabq_button'),
                    tooltip: 'About and City of Albuquerque links',
                    onPressed: () => _showAbout(context),
                    icon: const Icon(Icons.info_outline, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          if (_onboardingDone == false)
            OnboardingOverlay(onContinue: _completeOnboarding),
        ],
      ),
    );
  }
}
