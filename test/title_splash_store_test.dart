import 'package:balloon_tap/data/title_splash_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('isSplashComplete is false by default', () async {
    expect(await TitleSplashStore.isSplashComplete(), false);
  });

  test('markSplashComplete persists', () async {
    await TitleSplashStore.markSplashComplete();
    expect(await TitleSplashStore.isSplashComplete(), true);
  });
}
