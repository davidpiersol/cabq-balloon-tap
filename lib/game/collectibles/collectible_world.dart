import 'collectible_catalog.dart';

/// One spawned pickup in scroll space (v0.2+). v0.1: list stays empty.
class CollectibleInstance {
  const CollectibleInstance({
    required this.id,
    required this.kind,
    required this.xNorm,
    required this.yNorm,
  });

  final String id;
  final CollectibleKind kind;

  /// 0 = left, 1 = right of playfield (world space before scroll).
  final double xNorm;

  /// Same vertical convention as balloon: 0 top, 1 bottom.
  final double yNorm;
}

/// Hooks for horizontal scrolling + collection (v0.2). Tick is called every frame from the game loop.
class CollectibleWorld {
  CollectibleWorld();

  final List<CollectibleInstance> active = [];

  double scrollXNnorm = 0;

  /// Advance world time; spawn/move/collect logic will live here in v0.2.
  void tick(double dt) {
    // ignore: unused_local_variable — API surface for upcoming scroll
    final _ = dt;
  }

  void clear() {
    active.clear();
    scrollXNnorm = 0;
  }

  /// Future: remove instance and return score delta.
  int collect(CollectibleInstance item) {
    return item.kind.placeholderPoints;
  }
}
