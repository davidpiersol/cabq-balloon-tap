import 'package:balloon_tap/ui/mass_ascension_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PLAY dismisses splash via callback', (tester) async {
    var played = false;
    await tester.pumpWidget(
      MaterialApp(
        home: MassAscensionSplash(onPlay: () => played = true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Balloon Tap 2.0'), findsOneWidget);
    expect(find.text('Mass Ascension Adventure'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('splash_play_button')));
    expect(played, isTrue);
  });
}
