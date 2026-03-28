/// Pickup kinds — stable enum order for any future persistence.
enum CollectibleKind {
  redChile,
  greenChile,
  zia,
  route66,
  roadRunner,
  sandia,
  burqueHeart,
  hotAirBalloon,
  taco,
  coin,
}

extension CollectibleKindX on CollectibleKind {
  String get label => switch (this) {
        CollectibleKind.redChile => 'Red chile',
        CollectibleKind.greenChile => 'Green chile',
        CollectibleKind.zia => 'Zia',
        CollectibleKind.route66 => 'Route 66',
        CollectibleKind.roadRunner => 'Roadrunner',
        CollectibleKind.sandia => 'Sandía',
        CollectibleKind.burqueHeart => 'Burque',
        CollectibleKind.hotAirBalloon => 'Balloon',
        CollectibleKind.taco => 'Taco',
        CollectibleKind.coin => 'Coin',
      };

  int get points => switch (this) {
        CollectibleKind.zia => 5,
        CollectibleKind.route66 => 4,
        CollectibleKind.roadRunner => 4,
        CollectibleKind.sandia => 3,
        CollectibleKind.redChile => 2,
        CollectibleKind.greenChile => 2,
        CollectibleKind.burqueHeart => 3,
        CollectibleKind.hotAirBalloon => 2,
        CollectibleKind.taco => 2,
        CollectibleKind.coin => 1,
      };
}
