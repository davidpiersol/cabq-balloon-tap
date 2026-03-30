import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../data/appearance_store.dart';
import '../data/score_store.dart';
import '../game/balloon_appearance.dart';
import '../game/balloon_physics.dart';
import '../game/collectibles/collectible_world.dart';
import '../layout/ad_banner_reserve.dart';
import '../theme/cabq_theme.dart';
import 'balloon/balloon_envelope_painter.dart';
import 'balloon/balloon_layout.dart';
import 'balloon/customize_sheet.dart';
import 'balloon/flame_painter.dart';
import 'collectible_sprite_painter.dart';
import 'motion/rive_hud_accent.dart';
import 'onboarding_overlay.dart';
import 'parallax_background_painter.dart';

enum BalloonSkin {
  fiesta,
  sandiaSunset,
  rioDawn,
}

extension on BalloonSkin {
  String get label => switch (this) {
        BalloonSkin.fiesta => 'Balloon Fiesta',
        BalloonSkin.sandiaSunset => 'Sandia Sunset',
        BalloonSkin.rioDawn => 'Rio Dawn',
      };

  (Color, Color) get skyColors => switch (this) {
        // Fiesta: deep cerulean to warm golden sand
        BalloonSkin.fiesta => (const Color(0xFF4A8FC7), const Color(0xFFE8B46A)),
        // Sandia Sunset: deep orange to rich magenta-purple
        BalloonSkin.sandiaSunset => (const Color(0xFFFF8C3A), const Color(0xFF5C1F52)),
        // Rio Dawn: pre-dawn indigo to cobalt
        BalloonSkin.rioDawn => (const Color(0xFF152340), const Color(0xFF3A7CC4)),
      };

  Color? get skyHorizon => switch (this) {
        BalloonSkin.fiesta => const Color(0xFFFFD4A0),
        BalloonSkin.sandiaSunset => const Color(0xFFE8566A),
        BalloonSkin.rioDawn => const Color(0xFF2D5A8E),
      };
}

/// Hold to burn (sustained flame); release → short coast then matched descent (same speed as climb).
/// Parallax background scrolls left for horizontal illusion.
class BalloonGame extends StatefulWidget {
  const BalloonGame({super.key});

  @override
  State<BalloonGame> createState() => _BalloonGameState();
}

class _BalloonGameState extends State<BalloonGame> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  DateTime? _prevFrameTime;

  double _yNorm = BalloonPhysics.groundStartYNorm;
  double _vy = 0;
  // ignore: prefer_final_fields
  double _balloonXNorm = 0.25;

  int _score = 0;
  int _best = 0;
  bool _gameOver = false;
  bool _ready = false;

  bool _burnHeld = false;
  double _coastRemaining = 0;
  double _scrollPx = 0;
  double _elapsedSec = 0;

  BalloonSkin _skin = BalloonSkin.fiesta;
  BalloonAppearance _appearance = BalloonAppearance.defaultLook;

  final CollectibleWorld _world = CollectibleWorld();

  double _layoutWidth = 400;
  double _layoutHeight = 800;

  /// True when the last finished round beat the best score at round start (Lottie accent).
  bool _newBestOnLastGameOver = false;

  /// Personal best at the moment this round began (survives in-round `_best` updates).
  int _roundStartBest = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final best = await ScoreStore.loadBest();
    final look = await AppearanceStore.load();
    if (!mounted) return;
    setState(() {
      _best = best;
      _roundStartBest = best;
      _appearance = look;
      _ready = true;
    });
    unawaited(_ticker.start());
  }

  void _onTick(Duration _) {
    if (_gameOver) return;
    final now = DateTime.now();
    final dt = _prevFrameTime == null
        ? 0.0
        : now.difference(_prevFrameTime!).inMicroseconds / 1e6;
    _prevFrameTime = now;
    if (dt <= 0 || dt > 0.05) return;

    final w = _layoutWidth;
    final h = _layoutHeight;
    final nextElapsed = _elapsedSec + dt;
    final nextScroll = _scrollPx + w * BalloonPhysics.parallaxScrollPerSec * dt;
    final collectBonus = _world.tickAndCollect(
      dt: dt,
      screenWidth: w,
      screenHeight: h,
      scrollPx: nextScroll,
      balloonXNorm: _balloonXNorm,
      balloonYNorm: _yNorm,
    );

    var nextCoast = _coastRemaining;
    if (!_burnHeld && nextCoast > 0) {
      nextCoast -= dt;
      if (nextCoast < 0) nextCoast = 0;
    }

    double nextVy = _vy;
    if (_burnHeld) {
      nextVy = BalloonPhysics.applyBurnerLift(_vy, dt);
    } else if (nextCoast > 0) {
      nextVy = BalloonPhysics.applyCoastDamping(_vy, dt);
    } else {
      nextVy = BalloonPhysics.applyDescentPull(_vy, dt);
    }

    final nextY = BalloonPhysics.stepPosition(_yNorm, nextVy, dt);
    final lost = BalloonPhysics.isGameOver(nextY);

    if (lost) {
      setState(() {
        _elapsedSec = nextElapsed;
        _scrollPx = nextScroll;
        _coastRemaining = nextCoast;
        _yNorm = nextY;
        _vy = nextVy;
        if (collectBonus > 0) {
          _score += collectBonus;
          if (_score > _best) _best = _score;
          HapticFeedback.lightImpact();
        }
      });
      _endRound();
      return;
    }

    if (collectBonus > 0) {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _elapsedSec = nextElapsed;
      _scrollPx = nextScroll;
      _coastRemaining = nextCoast;
      _yNorm = nextY;
      _vy = nextVy;
      _score += BalloonPhysics.scoreDeltaForFrame(dt) + collectBonus;
      if (_score > _best) _best = _score;
    });
  }

  void _endRound() {
    if (_gameOver) return;
    final newBest = _score > _roundStartBest;
    _gameOver = true;
    _burnHeld = false;
    _coastRemaining = 0;
    _ticker.stop();
    HapticFeedback.heavyImpact();
    setState(() => _newBestOnLastGameOver = newBest);
    final finalScore = _score;
    ScoreStore.saveIfBest(finalScore).then((storedBest) {
      if (!mounted) return;
      setState(() => _best = storedBest);
    });
  }

  double get _flameStrength {
    if (_burnHeld) return 1.0;
    if (_coastRemaining <= 0) return 0.0;
    return (_coastRemaining / BalloonPhysics.coastDuration).clamp(0.0, 1.0);
  }

  void _onPointerDown() {
    if (!_ready || _gameOver) return;
    HapticFeedback.selectionClick();
    setState(() {
      _burnHeld = true;
      _coastRemaining = 0;
    });
  }

  void _onPointerUpOrCancel() {
    if (!_ready || _gameOver) return;
    setState(() {
      if (_burnHeld) {
        _coastRemaining = BalloonPhysics.coastDuration;
      }
      _burnHeld = false;
    });
  }

  void _restart() {
    setState(() {
      _roundStartBest = _best;
      _yNorm = BalloonPhysics.groundStartYNorm;
      _vy = 0;
      _score = 0;
      _gameOver = false;
      _newBestOnLastGameOver = false;
      _burnHeld = false;
      _coastRemaining = 0;
      _scrollPx = 0;
      _elapsedSec = 0;
      _prevFrameTime = null;
      _world.clear();
    });
    unawaited(_ticker.start());
  }

  Future<void> _openCustomize(BuildContext context) async {
    await showBalloonCustomizeSheet(
      context,
      initial: _appearance,
      onApply: (next) => setState(() => _appearance = next),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Center(
        child: Semantics(
          label: 'Loading best score',
          child: const CircularProgressIndicator(),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final w = constraints.maxWidth;
        _layoutWidth = w;
        _layoutHeight = h;
        final balloonY = h * _yNorm;
        final size = Size(w, h);
        final burner = BalloonLayout.burnerScreenOffset(
          screenW: w,
          screenH: h,
          balloonCenterYNorm: _yNorm,
          balloonXNorm: _balloonXNorm,
        );
        final (skyTop, skyBottom) = _skin.skyColors;
        final skyMid = _skin.skyHorizon;
        final mq = MediaQuery.of(context);
        final bottomInset = math.max(
          16.0,
          mq.padding.bottom + AdBannerReserve.gameHudBottomInset,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: CustomPaint(
                painter: ParallaxBackgroundPainter(
                  skyTop: skyTop,
                  skyBottom: skyBottom,
                  skyHorizon: skyMid,
                  scrollPx: _scrollPx,
                  timeSec: _elapsedSec,
                ),
                size: size,
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                painter: CollectiblesPainter(
                  instances: List.of(_world.active),
                  scrollPx: _scrollPx,
                  timeSec: _elapsedSec,
                ),
                size: size,
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: _gameOver,
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (_) => _onPointerDown(),
                  onPointerUp: (_) => _onPointerUpOrCancel(),
                  onPointerCancel: (_) => _onPointerUpOrCancel(),
                ),
              ),
            ),
            Positioned(
              left: w * _balloonXNorm - BalloonLayout.positionedHalfWidth,
              top: balloonY - BalloonLayout.positionedTopOffset,
              child: IgnorePointer(
                child: Transform.scale(
                  scale: 1.0 + 0.026 * _flameStrength,
                  alignment: Alignment.bottomCenter,
                  child: CustomPaint(
                    size: const Size(BalloonLayout.width, BalloonLayout.height),
                    painter: BalloonEnvelopePainter(
                      appearance: _appearance,
                      // Gentle sway: ±2.5° sinusoidal with velocity influence
                      swayDeg: math.sin(_elapsedSec * 1.4) * 2.5 +
                          (_vy * 8).clamp(-4.0, 4.0),
                    ),
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                painter: FlamePainter(
                  flameStrength: _flameStrength,
                  size: size,
                  burnerPosition: burner,
                  timeSec: _elapsedSec,
                ),
                size: size,
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              top: mq.padding.top + 8,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _HudChip(text: 'Score $_score', semanticLabel: 'Current score, $_score'),
                        _HudChip(text: 'Best $_best', semanticLabel: 'Best score, $_best'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const IgnorePointer(child: RiveHudAccent(size: 40)),
                  IconButton.filledTonal(
                    tooltip: 'Balloon colors and pattern',
                    onPressed: () => _openCustomize(context),
                    icon: const Icon(Icons.palette_outlined),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (_gameOver) ...[
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _restart();
                  },
                  child: Container(color: Colors.black.withValues(alpha: 0.22)),
                ),
              ),
              Center(
                child: Semantics(
                  liveRegion: true,
                  label:
                      'Game over. Score $_score. Personal best $_best. Use the Play again button.',
                  child: Card(
                    elevation: 16,
                    margin: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_newBestOnLastGameOver) ...[
                            SizedBox(
                              height: 80,
                              child: Lottie.asset(
                                OnboardingOverlay.lottieAsset,
                                repeat: false,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Text(
                              '★  New personal best!',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: CabqTheme.accent,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.4,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                          ] else ...[
                            Text(
                              'Balloon Down!',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                          ],
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _ScoreStat(label: 'Score', value: _score),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.black12,
                              ),
                              _ScoreStat(label: 'Best', value: _best),
                            ],
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              _restart();
                            },
                            icon: const Icon(Icons.replay_rounded, size: 18),
                            label: const Text('Play again',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomInset,
              child: Column(
                children: [
                  Semantics(
                    label: _gameOver
                        ? 'Hint: tap to play again'
                        : 'Hold to burn and rise. Release to coast, then descend at the same speed. Background scrolls for forward motion.',
                    child: Text(
                      _gameOver
                          ? 'Tap to restart'
                          : 'Hold to burn · release to coast · sky moves past you',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            shadows: const [Shadow(blurRadius: 4, color: Colors.black45)],
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SegmentedButton<BalloonSkin>(
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      segments: BalloonSkin.values
                          .map(
                            (s) => ButtonSegment<BalloonSkin>(
                              value: s,
                              label: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  s.label,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      selected: {_skin},
                      onSelectionChanged: (set) {
                        setState(() => _skin = set.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScoreStat extends StatelessWidget {
  const _ScoreStat({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.black45,
                letterSpacing: 0.8,
              ),
        ),
      ],
    );
  }
}

class _HudChip extends StatelessWidget {
  const _HudChip({required this.text, required this.semanticLabel});

  final String text;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      container: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white24),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  shadows: [Shadow(blurRadius: 3, color: Colors.black38)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
