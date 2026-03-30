import 'package:balloon_tap/app.dart';
import 'package:balloon_tap/data/onboarding_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await RiveNative.init();
  });

  testWidgets('app loads game with HUD after splash and onboarding skipped', (tester) async {
    SharedPreferences.setMockInitialValues({
      OnboardingStore.prefsKeyOnboardingV2Done: true,
    });
    await tester.pumpWidget(const BalloonTapApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('PLAY'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('splash_play_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(find.textContaining('Score'), findsOneWidget);
  });
}
