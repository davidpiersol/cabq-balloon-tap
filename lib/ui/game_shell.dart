import 'package:flutter/material.dart';

import '../data/onboarding_store.dart';
import '../security/safe_links.dart';
import 'balloon_game.dart';
import 'onboarding_overlay.dart';
import 'splash_screen.dart';

enum _ShellState { loading, splash, onboarding, playing }

class GameShell extends StatefulWidget {
  const GameShell({super.key});

  @override
  State<GameShell> createState() => _GameShellState();
}

class _GameShellState extends State<GameShell> {
  _ShellState _state = _ShellState.loading;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final done = await OnboardingStore.isOnboardingComplete();
    if (!mounted) return;
    setState(() => _state = _ShellState.splash);
    if (!done) {
      // Will show onboarding after splash → play tap
    }
  }

  void _onSplashPlay() async {
    final done = await OnboardingStore.isOnboardingComplete();
    if (!mounted) return;
    setState(() => _state = done ? _ShellState.playing : _ShellState.onboarding);
  }

  Future<void> _completeOnboarding() async {
    await OnboardingStore.markOnboardingComplete();
    if (!mounted) return;
    setState(() => _state = _ShellState.playing);
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
                  'Balloon Tap 2.0',
                  style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hold the screen to fire the burner and rise. Release to coast briefly, '
                  'then glide down. Keep the balloon off the ground and collect New Mexico '
                  'themed pickups for bonus points.',
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
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: switch (_state) {
        _ShellState.loading => Center(
            child: Semantics(
              label: 'Loading',
              child: const CircularProgressIndicator(),
            ),
          ),
        _ShellState.splash => SplashScreen(onPlay: _onSplashPlay),
        _ShellState.onboarding => OnboardingOverlay(onContinue: _completeOnboarding),
        _ShellState.playing => Stack(
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
                        tooltip: 'About',
                        onPressed: () => _showAbout(context),
                        icon: const Icon(Icons.info_outline, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      },
    );
  }
}
