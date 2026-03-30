import 'package:balloon_tap/app.dart';
import 'package:balloon_tap/data/onboarding_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await RiveNative.init();
  });

  testWidgets('app loads game with HUD after onboarding skipped', (tester) async {
    SharedPreferences.setMockInitialValues({
      OnboardingStore.prefsKeyOnboardingV2Done: true,
    });
    await tester.pumpWidget(const BalloonTapApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.textContaining('Score'), findsOneWidget);
  });
}
