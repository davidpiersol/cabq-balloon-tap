/// Future pickups (v0.2+). Values are stable for save-game compatibility.
enum CollectibleKind {
  coin,
  taco,
  redChile,
  greenChile,
  zia,
  hotAirBalloon,
  sandia,
  route66,
  burqueHeart,
}

extension CollectibleKindX on CollectibleKind {
  /// Human label for debug / future UI.
  String get label => switch (this) {
        CollectibleKind.coin => 'Coin',
        CollectibleKind.taco => 'Taco',
        CollectibleKind.redChile => 'Red chile',
        CollectibleKind.greenChile => 'Green chile',
        CollectibleKind.zia => 'Zia',
        CollectibleKind.hotAirBalloon => 'Balloon',
        CollectibleKind.sandia => 'Sandia',
        CollectibleKind.route66 => 'Route 66',
        CollectibleKind.burqueHeart => 'Burque',
      };

  /// Placeholder points until balancing in v0.2+.
  int get placeholderPoints => 1;
}
