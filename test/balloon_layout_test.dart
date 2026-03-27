import 'package:balloon_tap/ui/balloon/balloon_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('burner is centered horizontally under balloon rig', () {
    const w = 400.0;
    const h = 800.0;
    const xNorm = 0.5;
    const yNorm = 0.5;
    final p = BalloonLayout.burnerScreenOffset(
      screenW: w,
      screenH: h,
      balloonCenterYNorm: yNorm,
      balloonXNorm: xNorm,
    );
    expect(p.dx, w * xNorm);
  });

  test('burner Y lies between basket and envelope band', () {
    const w = 400.0;
    const h = 800.0;
    final p = BalloonLayout.burnerScreenOffset(
      screenW: w,
      screenH: h,
      balloonCenterYNorm: 0.5,
      balloonXNorm: 0.5,
    );
    const top = h * 0.5 - BalloonLayout.positionedTopOffset;
    const envBottom = top + BalloonLayout.height * 0.72;
    const basketTop = top + BalloonLayout.height * 0.68;
    expect(p.dy, greaterThanOrEqualTo(basketTop - 2));
    expect(p.dy, lessThanOrEqualTo(envBottom + 2));
  });
}
