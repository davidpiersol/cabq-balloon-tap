/// User-controlled balloon look (persisted). Sky themes stay separate in UI.
enum BalloonPattern {
  solid,
  stripes,
  patchwork,
}

class BalloonAppearance {
  const BalloonAppearance({
    required this.pattern,
    required this.colorA,
    required this.colorB,
    required this.colorC,
    required this.basketArgb,
  });

  final BalloonPattern pattern;
  final int colorA;
  final int colorB;
  final int colorC;
  final int basketArgb;

  static const BalloonAppearance defaultLook = BalloonAppearance(
    pattern: BalloonPattern.solid,
    colorA: 0xFFE63946,
    colorB: 0xFFF4A261,
    colorC: 0xFF2A9D8F,
    basketArgb: 0xFF5C4033,
  );

  BalloonAppearance copyWith({
    BalloonPattern? pattern,
    int? colorA,
    int? colorB,
    int? colorC,
    int? basketArgb,
  }) {
    return BalloonAppearance(
      pattern: pattern ?? this.pattern,
      colorA: colorA ?? this.colorA,
      colorB: colorB ?? this.colorB,
      colorC: colorC ?? this.colorC,
      basketArgb: basketArgb ?? this.basketArgb,
    );
  }

  Map<String, dynamic> toJson() => {
        'pattern': pattern.name,
        'a': colorA,
        'b': colorB,
        'c': colorC,
        'basket': basketArgb,
      };

  static BalloonAppearance fromJson(Map<String, dynamic> json) {
    final p = BalloonPattern.values.asNameMap()[json['pattern'] as String?] ??
        BalloonPattern.solid;
    return BalloonAppearance(
      pattern: p,
      colorA: (json['a'] as num?)?.toInt() ?? defaultLook.colorA,
      colorB: (json['b'] as num?)?.toInt() ?? defaultLook.colorB,
      colorC: (json['c'] as num?)?.toInt() ?? defaultLook.colorC,
      basketArgb: (json['basket'] as num?)?.toInt() ?? defaultLook.basketArgb,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BalloonAppearance &&
      other.pattern == pattern &&
      other.colorA == colorA &&
      other.colorB == colorB &&
      other.colorC == colorC &&
      other.basketArgb == basketArgb;

  @override
  int get hashCode => Object.hash(pattern, colorA, colorB, colorC, basketArgb);
}
