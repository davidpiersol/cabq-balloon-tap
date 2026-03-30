import 'package:flutter/material.dart';

/// Single illustrated background that scrolls horizontally for parallax.
/// Uses one full-bleed image (no transparency, no layering issues).
class ParallaxBackground extends StatelessWidget {
  const ParallaxBackground({
    super.key,
    required this.scrollPx,
    this.asset = 'assets/images/gameplay_background.png',
  });

  final double scrollPx;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final offset = -(scrollPx * 0.15) % w;
        return ClipRect(
          child: Transform.translate(
            offset: Offset(offset, 0),
            child: OverflowBox(
              alignment: Alignment.centerLeft,
              maxWidth: w * 3,
              maxHeight: constraints.maxHeight,
              child: Row(
                children: List.generate(
                  3,
                  (_) => SizedBox(
                    width: w,
                    height: constraints.maxHeight,
                    child: Image.asset(asset, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
