import 'package:flutter/material.dart';

/// Image-based parallax background with three scrolling layers:
/// sky (slow), mesas (medium), ground (fast).
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
            _TilingLayer(
              asset: skyAsset,
              scrollPx: scrollPx * 0.05,
              screenWidth: w,
              height: h,
              alignment: Alignment.topCenter,
              fit: BoxFit.cover,
            ),
            _TilingLayer(
              asset: mesaAsset,
              scrollPx: scrollPx * 0.3,
              screenWidth: w,
              height: h,
              alignment: Alignment.bottomCenter,
              fit: BoxFit.fitWidth,
            ),
            _TilingLayer(
              asset: groundAsset,
              scrollPx: scrollPx * 0.7,
              screenWidth: w,
              height: h * 0.35,
              alignment: Alignment.bottomCenter,
              fit: BoxFit.fitWidth,
              bottomAligned: true,
            ),
          ],
        );
      },
    );
  }
}

class _TilingLayer extends StatelessWidget {
  const _TilingLayer({
    required this.asset,
    required this.scrollPx,
    required this.screenWidth,
    required this.height,
    required this.alignment,
    required this.fit,
    this.bottomAligned = false,
  });

  final String asset;
  final double scrollPx;
  final double screenWidth;
  final double height;
  final Alignment alignment;
  final BoxFit fit;
  final bool bottomAligned;

  @override
  Widget build(BuildContext context) {
    final offset = -(scrollPx % (screenWidth * 2));
    if (bottomAligned) {
      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        height: height,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.bottomLeft,
            maxWidth: screenWidth * 3,
            child: Transform.translate(
              offset: Offset(offset, 0),
              child: Row(
                children: List.generate(3, (_) => Image.asset(
                  asset,
                  width: screenWidth,
                  height: height,
                  fit: fit,
                )),
              ),
            ),
          ),
        ),
      );
    }
    return Positioned.fill(
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.centerLeft,
          maxWidth: screenWidth * 3,
          child: Transform.translate(
            offset: Offset(offset, 0),
            child: Row(
              children: List.generate(3, (_) => Image.asset(
                asset,
                width: screenWidth,
                height: height,
                fit: fit,
              )),
            ),
          ),
        ),
      ),
    );
  }
}
