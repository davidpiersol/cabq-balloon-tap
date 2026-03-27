import 'dart:async';
import 'dart:math' as math;

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
import 'balloon/customize_sheet.dart';
import 'balloon/flame_painter.dart';

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
}

enum _Phase { intro, playing }

/// Physics + intro ascent + burner flames + appearance + collectible world stub.
class BalloonGame extends StatefulWidget {
  const BalloonGame({super.key});

  @override
  State<BalloonGame> createState() => _BalloonGameState();
}

class _BalloonGameState extends State<BalloonGame> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  DateTime? _prevFrameTime;

  double _yNorm = BalloonPhysics.introStartYNorm;
  double _vy = 0;
  // v0.2: tie to world scroll / input.
  // ignore: prefer_final_fields
  double _balloonXNorm = 0.5;

  int _score = 0;
  int _best = 0;
  bool _gameOver = false;
  bool _ready = false;
  _Phase _phase = _Phase.intro;

  BalloonSkin _skin = BalloonSkin.fiesta;
  BalloonAppearance _appearance = BalloonAppearance.defaultLook;

  final List<FlameBurst> _flames = [];
  final CollectibleWorld _world = CollectibleWorld();

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

    for (final f in _flames) {
      f.age += dt;
    }
    _flames.removeWhere((f) => f.isDead);
    _world.tick(dt);

    double nextY = _yNorm;
    double nextVy = _vy;
    var nextPhase = _phase;
    var lost = false;
    var scoreAdd = 0;

    if (_phase == _Phase.intro) {
      nextVy = BalloonPhysics.introRiseVy;
      nextY = BalloonPhysics.stepPosition(_yNorm, nextVy, dt);
      if (BalloonPhysics.isIntroComplete(nextY)) {
        nextPhase = _Phase.playing;
        nextVy = 0;
      }
      if (BalloonPhysics.isGameOver(nextY)) lost = true;
    } else {
      nextVy = BalloonPhysics.applyGravity(_vy, dt);
      nextY = BalloonPhysics.stepPosition(_yNorm, nextVy, dt);
      if (BalloonPhysics.isGameOver(nextY)) {
        lost = true;
      } else {
        scoreAdd = BalloonPhysics.scoreDeltaForFrame(dt);
      }
    }

    if (lost) {
      setState(() {
        _yNorm = nextY;
        _vy = nextVy;
        _phase = nextPhase;
      });
      _endRound();
      return;
    }

    setState(() {
      _yNorm = nextY;
      _vy = nextVy;
      _phase = nextPhase;
      _score += scoreAdd;
      if (_score > _best) _best = _score;
    });
  }

  void _endRound() {
    if (_gameOver) return;
    _gameOver = true;
    _ticker.stop();
    HapticFeedback.heavyImpact();
    setState(() {});
    final finalScore = _score;
    ScoreStore.saveIfBest(finalScore).then((storedBest) {
      if (!mounted) return;
      setState(() => _best = storedBest);
    });
  }

  void _onTapDown(TapDownDetails d, double w, double h) {
    if (!_ready) return;
    if (_gameOver) {
      HapticFeedback.mediumImpact();
      _restart();
      return;
    }
    final lx = (d.localPosition.dx / w).clamp(0.0, 1.0);
    final ly = (d.localPosition.dy / h).clamp(0.0, 1.0);
    if (_phase == _Phase.playing) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }
    setState(() {
      _flames.add(FlameBurst(xNorm: lx, yNorm: ly));
      if (_phase == _Phase.playing) {
        _vy = BalloonPhysics.applyTap(_vy);
      }
    });
  }

  void _restart() {
    setState(() {
      _yNorm = BalloonPhysics.introStartYNorm;
      _vy = 0;
      _score = 0;
      _gameOver = false;
      _phase = _Phase.intro;
      _prevFrameTime = null;
      _flames.clear();
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
        final balloonY = h * _yNorm;
        final size = Size(w, h);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) => _onTapDown(d, w, h),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _SkyPainter(skin: _skin),
              ),
              CustomPaint(
                painter: FlamePainter(flames: _flames, size: size),
                size: size,
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
              Positioned(
                left: w * _balloonXNorm - 44,
                top: balloonY - 70,
                child: ExcludeSemantics(
                  child: CustomPaint(
                    size: const Size(88, 88 * 1.15),
                    painter: BalloonEnvelopePainter(appearance: _appearance),
                  ),
                ),
              ),
              if (_gameOver)
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
                              onPressed: _restart,
                              child: const Text('Play again'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Column(
                  children: [
                    Semantics(
                      label: _gameOver
                          ? 'Hint: tap the sky area to play again'
                          : _phase == _Phase.intro
                              ? 'Rising from the ground to the sweet spot. Then tap to burn and lift.'
                              : 'Hint: tap to create a burner flame and lift the balloon',
                      child: Text(
                        _gameOver
                            ? 'Tap to restart'
                            : _phase == _Phase.intro
                                ? 'Rising to the sweet spot…'
                                : 'Tap for flame · stay in the sweet spot',
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
          ),
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

class _SkyPainter extends CustomPainter {
  _SkyPainter({required this.skin});

  final BalloonSkin skin;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final top = switch (skin) {
      BalloonSkin.fiesta => CabqTheme.skyTop,
      BalloonSkin.sandiaSunset => const Color(0xFFFFB347),
      BalloonSkin.rioDawn => const Color(0xFF1E3A5F),
    };
    final bottom = switch (skin) {
      BalloonSkin.fiesta => CabqTheme.skyBottom,
      BalloonSkin.sandiaSunset => const Color(0xFF6B2D5C),
      BalloonSkin.rioDawn => const Color(0xFF4A90D9),
    };
    final g = Paint()
      ..shader = LinearGradient(
        colors: [top, bottom],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    canvas.drawRect(rect, g);

    final path = Path()
      ..moveTo(0, size.height * 0.72)
      ..lineTo(size.width * 0.2, size.height * 0.55)
      ..lineTo(size.width * 0.45, size.height * 0.62)
      ..lineTo(size.width * 0.7, size.height * 0.48)
      ..lineTo(size.width, size.height * 0.58)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.14),
      math.min(size.width, size.height) * 0.06,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) => oldDelegate.skin != skin;
}
