import 'package:balloon_tap/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('About sheet opens from app bar', (tester) async {
    await tester.pumpWidget(const BalloonTapApp());
    // BalloonGame runs a continuous Ticker — avoid pumpAndSettle (never idle).
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('City of Albuquerque'), findsOneWidget);
    expect(find.textContaining('Balloon Tap'), findsWidgets);
    expect(find.text('Balloon Museum — cabq.gov'), findsOneWidget);
    expect(find.text('cabq.gov home'), findsOneWidget);
  });
}
