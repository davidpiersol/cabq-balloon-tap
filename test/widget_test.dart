import 'package:balloon_tap/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app loads game shell', (tester) async {
    await tester.pumpWidget(const BalloonTapApp());
    expect(find.text('Balloon Tap'), findsOneWidget);
  });
}
