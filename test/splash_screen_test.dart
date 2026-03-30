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

    expect(find.text('Balloon'), findsOneWidget);
    expect(find.text('Tap'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
    expect(find.text('TAP TO PLAY'), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    expect(played, isTrue);
  });
}
