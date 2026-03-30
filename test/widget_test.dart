import 'package:balloon_tap/app.dart';
import 'package:balloon_tap/data/onboarding_store.dart';
import 'package:balloon_tap/ui/splash_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app shows splash screen on launch', (tester) async {
    SharedPreferences.setMockInitialValues({
      OnboardingStore.prefsKeyOnboardingV2Done: true,
    });
    await tester.pumpWidget(const BalloonTapApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Balloon'), findsOneWidget);
    expect(find.text('Tap'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets('tapping play transitions to game', (tester) async {
    SharedPreferences.setMockInitialValues({
      OnboardingStore.prefsKeyOnboardingV2Done: true,
    });
    await tester.pumpWidget(const BalloonTapApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('Score'), findsOneWidget);
  });
}
