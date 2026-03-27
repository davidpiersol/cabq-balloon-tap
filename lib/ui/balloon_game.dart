import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/score_store.dart';
import '../game/balloon_physics.dart';
import '../theme/cabq_theme.dart';

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

  List<Color> get balloonColors => switch (this) {
        BalloonSkin.fiesta => [
            const Color(0xFFE63946),
            const Color(0xFFF4A261),
            const Color(0xFF2A9D8F),
          ],
        BalloonSkin.sandiaSunset => [
            const Color(0xFFFF6B35),
            const Color(0xFFF7C59F),
            const Color(0xFF9B2335),
          ],
        BalloonSkin.rioDawn => [
            const Color(0xFF4CC9F0),
            const Color(0xFF4361EE),
            const Color(0xFF7209B7),
          ],
      };
}

/// Simple physics: vertical velocity + gravity; tap adds impulse. Bounds lose.
class BalloonGame extends StatefulWidget {
  const BalloonGame({super.key});

  @override
  State<BalloonGame> createState() => _BalloonGameState();
}

class _BalloonGameState extends State<BalloonGame> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  DateTime? _prevFrameTime;

  double _yNorm = 0.55;
  double _vy = 0;

  int _score = 0;
  int _best = 0;
  bool _gameOver = false;
  bool _ready = false;
  BalloonSkin _skin = BalloonSkin.fiesta;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _loadBestAndStart();
  }

  Future<void> _loadBestAndStart() async {
    final loaded = await ScoreStore.loadBest();
    if (!mounted) return;
    setState(() {
      _best = loaded;
      _ready = true;
    });
    _ticker.start();
  }

  void _onTick(Duration _) {
    if (_gameOver) return;
    final now = DateTime.now();
    final dt = _prevFrameTime == null
        ? 0.0
        : now.difference(_prevFrameTime!).inMicroseconds / 1e6;
    _prevFrameTime = now;
    if (dt <= 0 || dt > 0.05) return;

    _vy = BalloonPhysics.applyGravity(_vy, dt);
    setState(() {
      _yNorm = BalloonPhysics.stepPosition(_yNorm, _vy, dt);
      if (BalloonPhysics.isGameOver(_yNorm)) {
        _endRound();
      } else {
        _score += BalloonPhysics.scoreDeltaForFrame(dt);
        if (_score > _best) _best = _score;
      }
    });
  }

  void _endRound() {
    if (_gameOver) return;
    _gameOver = true;
    _ticker.stop();
    HapticFeedback.heavyImpact();
    final finalScore = _score;
    ScoreStore.saveIfBest(finalScore).then((storedBest) {
      if (!mounted) return;
      setState(() => _best = storedBest);
    });
  }

  void _tap() {
    if (_gameOver) {
      HapticFeedback.mediumImpact();
      _restart();
      return;
    }
    HapticFeedback.lightImpact();
    _vy = BalloonPhysics.applyTap(_vy);
  }

  void _restart() {
    setState(() {
      _yNorm = 0.55;
      _vy = 0;
      _score = 0;
      _gameOver = false;
      _prevFrameTime = null;
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(
        child: Semantics(
          label: 'Loading best score',
          child: CircularProgressIndicator(),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final w = constraints.maxWidth;
        final balloonY = h * _yNorm;
        return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _tap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _SkyPainter(skin: _skin),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  top: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _Chip(text: 'Score $_score', semanticLabel: 'Current score, $_score'),
                      _Chip(text: 'Best $_best', semanticLabel: 'Best score, $_best'),
                    ],
                  ),
                ),
                Positioned(
                  left: w * 0.5 - 44,
                  top: balloonY - 70,
                  child: ExcludeSemantics(
                    child: _BalloonWidget(colors: _skin.balloonColors, size: 88),
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
                            : 'Hint: tap the sky to lift the balloon. Avoid the ground and the top of the screen',
                        child: Text(
                          _gameOver ? 'Tap to restart' : 'Tap to lift · stay in the sweet spot',
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

    // Distant mountains (Sandia-ish silhouette)
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
      Paint()..color = Colors.black.withOpacity(0.18),
    );

    // Sun
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.14),
      math.min(size.width, size.height) * 0.06,
      Paint()..color = Colors.white.withOpacity(0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _SkyPainter oldDelegate) => oldDelegate.skin != skin;
}

class _BalloonWidget extends StatelessWidget {
  const _BalloonWidget({required this.colors, required this.size});

  final List<Color> colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.15),
      painter: _BalloonPainter(colors: colors),
    );
  }
}

class _BalloonPainter extends CustomPainter {
  _BalloonPainter({required this.colors});

  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final envelope = Path()
      ..addOval(Rect.fromLTWH(w * 0.1, 0, w * 0.8, h * 0.72));
    final shader = LinearGradient(
      colors: colors.length >= 3 ? colors : [colors.first, colors.last],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(
      envelope,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      envelope,
      Paint()
        ..color = Colors.black26
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Basket
    final basket = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.32, h * 0.68, w * 0.36, h * 0.22),
      const Radius.circular(6),
    );
    canvas.drawRRect(basket, Paint()..color = const Color(0xFF5C4033));
    // Lines
    final p = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(w * 0.35, h * 0.68), Offset(w * 0.38, h * 0.55), p);
    canvas.drawLine(Offset(w * 0.65, h * 0.68), Offset(w * 0.62, h * 0.55), p);
  }

  @override
  bool shouldRepaint(covariant _BalloonPainter oldDelegate) => oldDelegate.colors != colors;
}
