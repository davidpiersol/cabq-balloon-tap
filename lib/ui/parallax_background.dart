import 'package:flutter/material.dart';

/// Image-based parallax background with three layers stacked:
///   1. Sky — fills entire screen, scrolls slowly
///   2. Mesas — bottom-aligned, scrolls medium (transparent top blends over sky)
///   3. Ground — bottom-aligned, scrolls fast (transparent top blends over mesas)
class ParallaxBackground extends StatelessWidget {
  const ParallaxBackground({
    super.key,
    required this.scrollPx,
    this.skyAsset = 'assets/images/bg_sky_layer.png',
    this.mesaAsset = 'assets/images/bg_mesa_layer.png',
    this.groundAsset = 'assets/images/bg_ground_layer.png',
  });

  final double scrollPx;
  final String skyAsset;
  final String mesaAsset;
  final String groundAsset;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Sky — covers the entire screen
            Positioned.fill(
              child: _ScrollingImage(
                asset: skyAsset,
                scrollPx: scrollPx * 0.05,
                screenWidth: w,
                fit: BoxFit.cover,
              ),
            ),
            // Layer 2: Mesas — bottom 55% of screen
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: h * 0.55,
              child: _ScrollingImage(
                asset: mesaAsset,
                scrollPx: scrollPx * 0.25,
                screenWidth: w,
                fit: BoxFit.cover,
              ),
            ),
            // Layer 3: Desert ground — bottom 28% of screen
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: h * 0.28,
              child: _ScrollingImage(
                asset: groundAsset,
                scrollPx: scrollPx * 0.65,
                screenWidth: w,
                fit: BoxFit.cover,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Horizontally-scrolling image that tiles seamlessly.
class _ScrollingImage extends StatelessWidget {
  const _ScrollingImage({
    required this.asset,
    required this.scrollPx,
    required this.screenWidth,
    required this.fit,
  });

  final String asset;
  final double scrollPx;
  final double screenWidth;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final tileWidth = screenWidth;
    final offset = -(scrollPx % tileWidth);
    return ClipRect(
      child: Transform.translate(
        offset: Offset(offset, 0),
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          maxWidth: tileWidth * 3,
          maxHeight: double.infinity,
          child: Row(
            children: List.generate(3, (_) => SizedBox(
              width: tileWidth,
              child: Image.asset(asset, fit: fit),
            )),
          ),
        ),
      ),
    );
  }
}
