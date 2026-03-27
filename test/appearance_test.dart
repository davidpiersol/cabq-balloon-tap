import 'package:balloon_tap/data/appearance_store.dart';
import 'package:balloon_tap/game/balloon_appearance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BalloonAppearance', () {
    test('json roundtrip', () {
      const a = BalloonAppearance(
        pattern: BalloonPattern.stripes,
        colorA: 0xFF112233,
        colorB: 0xFF445566,
        colorC: 0xFF778899,
        basketArgb: 0xFFABCDEF,
      );
      final b = BalloonAppearance.fromJson(a.toJson());
      expect(b, a);
    });
  });

  group('AppearanceStore', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('save and load', () async {
      expect(await AppearanceStore.load(), BalloonAppearance.defaultLook);
      const custom = BalloonAppearance(
        pattern: BalloonPattern.patchwork,
        colorA: 0xFFFF0000,
        colorB: 0xFF00FF00,
        colorC: 0xFF0000FF,
        basketArgb: 0xFF111111,
      );
      await AppearanceStore.save(custom);
      expect(await AppearanceStore.load(), custom);
    });
  });
}
