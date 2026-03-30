import 'package:balloon_tap/app.dart';
import 'package:balloon_tap/data/onboarding_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('About sheet opens after navigating through splash', (tester) async {
    SharedPreferences.setMockInitialValues({
      OnboardingStore.prefsKeyOnboardingV2Done: true,
    });
    await tester.pumpWidget(const BalloonTapApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Tap play on splash
    await tester.tap(find.text('PLAY'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Now tap about
    await tester.tap(find.byKey(const ValueKey<String>('about_cabq_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Balloon Tap 2.0'), findsWidgets);
    expect(find.text('Balloon Museum — cabq.gov'), findsOneWidget);
    expect(find.text('cabq.gov home'), findsOneWidget);
  });
}
