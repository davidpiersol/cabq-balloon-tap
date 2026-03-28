import 'dart:math' as math;

import 'collectible_catalog.dart';

class CollectibleInstance {
  CollectibleInstance({
    required this.id,
    required this.kind,
    required this.worldX,
    required this.yNorm,
  });

  final String id;
  final CollectibleKind kind;

  /// Horizontal position in the same pixel space as [scrollPx] (world scroll).
  final double worldX;

  /// 0 = top, 1 = bottom of screen.
  final double yNorm;
}

/// Spawns a modest stream of NM-themed pickups; scroll matches background parallax.
class CollectibleWorld {
  CollectibleWorld();

  final List<CollectibleInstance> active = [];

  double scrollXNnorm = 0;
  double _spawnCountdown = 0.6;
  int _nextId = 0;
  final math.Random _rng = math.Random();

  /// Cap so the sky never feels crowded.
  static const int maxActive = 6;

  static const double spawnMinSec = 1.75;
  static const double spawnMaxSec = 2.65;

  static const List<CollectibleKind> spawnPool = [
    CollectibleKind.redChile,
    CollectibleKind.greenChile,
    CollectibleKind.zia,
    CollectibleKind.route66,
    CollectibleKind.roadRunner,
    CollectibleKind.sandia,
    CollectibleKind.burqueHeart,
    CollectibleKind.hotAirBalloon,
    CollectibleKind.taco,
    CollectibleKind.coin,
  ];

  void clear() {
    active.clear();
    scrollXNnorm = 0;
    _spawnCountdown = 0.6;
    _nextId = 0;
  }

  /// Returns bonus score from pickups collected this frame.
  int tickAndCollect({
    required double dt,
    required double screenWidth,
    required double screenHeight,
    required double scrollPx,
    required double balloonXNorm,
    required double balloonYNorm,
  }) {
    scrollXNnorm = screenWidth > 0 ? (scrollPx / screenWidth) % 1.0 : 0;

    _spawnCountdown -= dt;
    if (_spawnCountdown <= 0 && active.length < maxActive) {
      _spawnCountdown = spawnMinSec + _rng.nextDouble() * (spawnMaxSec - spawnMinSec);
      final kind = spawnPool[_rng.nextInt(spawnPool.length)];
      final margin = 24.0 + _rng.nextDouble() * 100;
      active.add(
        CollectibleInstance(
          id: 'c${_nextId++}',
          kind: kind,
          worldX: scrollPx + screenWidth + margin,
          yNorm: 0.16 + _rng.nextDouble() * 0.58,
        ),
      );
    }

    active.removeWhere((c) => c.worldX - scrollPx < -64);

    final bCx = balloonXNorm * screenWidth;
    final bCy = balloonYNorm * screenHeight - screenHeight * 0.055;
    const collectR = 56.0;

    var bonus = 0;
    active.removeWhere((c) {
      final sx = c.worldX - scrollPx;
      final sy = c.yNorm * screenHeight;
      final dx = sx - bCx;
      final dy = sy - bCy;
      if (dx * dx + dy * dy < collectR * collectR) {
        bonus += c.kind.points;
        return true;
      }
      return false;
    });

    return bonus;
  }
}
