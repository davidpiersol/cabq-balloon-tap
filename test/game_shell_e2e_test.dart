import 'package:balloon_tap/app.dart';
import 'package:balloon_tap/data/onboarding_store.dart';
import 'package:balloon_tap/data/title_splash_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await RiveNative.init();
  });

  testWidgets('About sheet opens from header button', (tester) async {
    SharedPreferences.setMockInitialValues({
      OnboardingStore.prefsKeyOnboardingV2Done: true,
      TitleSplashStore.prefsKeySplashV2Done: false,
    });
    await tester.pumpWidget(const BalloonTapApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byKey(const ValueKey<String>('splash_play_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    await tester.tap(find.byKey(const ValueKey<String>('about_cabq_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('City of Albuquerque'), findsOneWidget);
    expect(find.textContaining('Balloon Tap'), findsWidgets);
    expect(find.text('Balloon Museum — cabq.gov'), findsOneWidget);
    expect(find.text('cabq.gov home'), findsOneWidget);
  });
}
