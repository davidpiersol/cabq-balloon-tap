import 'package:balloon_tap/ui/onboarding_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Continue invokes callback', (tester) async {
    var called = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OnboardingOverlay(
            onContinue: () => called = true,
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text("Let's fly"), findsOneWidget);
    await tester.tap(find.text("Let's fly"));
    expect(called, isTrue);
  });
}
