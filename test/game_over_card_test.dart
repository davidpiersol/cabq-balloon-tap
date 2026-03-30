import 'package:balloon_tap/ui/game_over_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('GameOverCard shows score and play again', (tester) async {
    var restarted = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameOverCard(
            score: 42,
            best: 100,
            isNewBest: false,
            onRestart: () => restarted = true,
            lottieAsset: 'assets/lottie/nm_sparkle.json',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Balloon down!'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('100'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);

    await tester.tap(find.text('Play again'));
    expect(restarted, isTrue);
  });

  testWidgets('GameOverCard shows new best when isNewBest', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameOverCard(
            score: 512,
            best: 512,
            isNewBest: true,
            onRestart: () {},
            lottieAsset: 'assets/lottie/nm_sparkle.json',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('New personal best!'), findsOneWidget);
    expect(find.text('512'), findsNWidgets(2));
  });
}
