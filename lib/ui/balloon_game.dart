import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/appearance_store.dart';
import '../data/score_store.dart';
import '../game/balloon_appearance.dart';
import '../game/balloon_physics.dart';
import '../game/collectibles/collectible_world.dart';
import '../theme/cabq_theme.dart';
import 'balloon/balloon_envelope_painter.dart';
import 'balloon/balloon_layout.dart';
import 'balloon/customize_sheet.dart';
import 'balloon/flame_painter.dart';
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
        BalloonSkin.fiesta => (CabqTheme.skyTop, CabqTheme.skyBottom),
        BalloonSkin.sandiaSunset => (const Color(0xFFFFB347), const Color(0xFF6B2D5C)),
        BalloonSkin.rioDawn => (const Color(0xFF1E3A5F), const Color(0xFF4A90D9)),
      };
}

/// Hold to burn (sustained flame); release → short coast then gravity drift.
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
  double _balloonXNorm = 0.5;

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
    final nextElapsed = _elapsedSec + dt;
    final nextScroll = _scrollPx + w * BalloonPhysics.parallaxScrollPerSec * dt;
    _world.scrollXNnorm = (nextScroll / w) % 1.0;
    _world.tick(dt);

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
      nextVy = BalloonPhysics.applyGravity(_vy, dt);
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
      });
      _endRound();
      return;
    }

    setState(() {
      _elapsedSec = nextElapsed;
      _scrollPx = nextScroll;
      _coastRemaining = nextCoast;
      _yNorm = nextY;
      _vy = nextVy;
      _score += BalloonPhysics.scoreDeltaForFrame(dt);
      if (_score > _best) _best = _score;
    });
  }

  void _endRound() {
    if (_gameOver) return;
    _gameOver = true;
    _burnHeld = false;
    _coastRemaining = 0;
    _ticker.stop();
    HapticFeedback.heavyImpact();
    setState(() {});
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
      _yNorm = BalloonPhysics.groundStartYNorm;
      _vy = 0;
      _score = 0;
      _gameOver = false;
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
        final balloonY = h * _yNorm;
        final size = Size(w, h);
        final burner = BalloonLayout.burnerScreenOffset(
          screenW: w,
          screenH: h,
          balloonCenterYNorm: _yNorm,
          balloonXNorm: _balloonXNorm,
        );
        final (skyTop, skyBottom) = _skin.skyColors;

        return Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: CustomPaint(
                painter: ParallaxBackgroundPainter(
                  skyTop: skyTop,
                  skyBottom: skyBottom,
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
                child: CustomPaint(
                  size: const Size(BalloonLayout.width, BalloonLayout.height),
                  painter: BalloonEnvelopePainter(appearance: _appearance),
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
              left: 16,
              right: 16,
              top: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _Chip(text: 'Score $_score', semanticLabel: 'Current score, $_score'),
                        _Chip(text: 'Best $_best', semanticLabel: 'Best score, $_best'),
                      ],
                    ),
                  ),
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
                    margin: const EdgeInsets.all(24),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Balloon down!',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text('Score: $_score · Best: $_best'),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              _restart();
                            },
                            child: const Text('Play again'),
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
              bottom: 16,
              child: Column(
                children: [
                  Semantics(
                    label: _gameOver
                        ? 'Hint: tap to play again'
                        : 'Hold to burn and rise. Release to coast, then drift down. Background scrolls for forward motion.',
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

class _Chip extends StatelessWidget {
  const _Chip({required this.text, required this.semanticLabel});

  final String text;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            text,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
