import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Small decorative Rive mark (placeholder art from Rive test bundle).
/// Fails silently to an empty box if the runtime cannot load the file.
class RiveHudAccent extends StatelessWidget {
  const RiveHudAccent({super.key, this.size = 44});

  final double size;

  static const assetPath = 'assets/rive/hud_accent.riv';

  @override
  Widget build(BuildContext context) {
    if (!RiveNative.isInitialized) {
      return SizedBox(width: size, height: size);
    }
    return SizedBox(
      width: size,
      height: size,
      child: RiveWidgetBuilder(
        // Flutter renderer: works in `flutter test` and on-device (Skia/Impeller).
        // `Factory.rive` can abort the VM test harness without full native Rive setup.
        fileLoader: FileLoader.fromAsset(
          assetPath,
          riveFactory: Factory.flutter,
        ),
        builder: (context, state) {
          return switch (state) {
            RiveLoading() => SizedBox(width: size, height: size),
            RiveLoaded(:final controller) => RiveWidget(
                controller: controller,
                fit: Fit.contain,
                alignment: Alignment.center,
              ),
            RiveFailed() => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
