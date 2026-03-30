import 'package:balloon_tap/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SplashScreen renders title and play button', (tester) async {
    var played = false;
    await tester.pumpWidget(
      MaterialApp(
        home: SplashScreen(onPlay: () => played = true),
      ),
    );
    await tester.pump();

    expect(find.text('Balloon Tap'), findsOneWidget);
    expect(find.text('2.0'), findsOneWidget);
    expect(find.text('TAP TO PLAY'), findsOneWidget);

    await tester.tap(find.text('TAP TO PLAY'));
    expect(played, isTrue);
  });
}
