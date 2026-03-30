import 'package:balloon_tap/ui/title_splash_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('title splash renders and start callback fires', (tester) async {
    var called = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: TitleSplashOverlay(onStart: () => called = true)),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('title_splash_label')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('title_splash_start_button')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('title_splash_start_button')),
    );
    await tester.pump();
    expect(called, isTrue);
  });
}
