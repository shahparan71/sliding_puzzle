import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:sliding_puzzle/main.dart';

void main() {
  testWidgets('setup page starts with medium number preferences', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Set up your puzzle'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Start puzzle'), findsOneWidget);
    expect(find.text('MEDIUM NUMBER PUZZLE'), findsNothing);
  });

  testWidgets('start opens the puzzle page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Start puzzle'));
    await tester.pumpAndSettle();

    expect(find.text('MEDIUM NUMBER PUZZLE'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.byKey(const ValueKey('tile-1')), findsOneWidget);
  });

  testWidgets('preferences are applied when starting an image puzzle', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Image'));
    await tester.tap(find.text('Easy'));
    await tester.pump();
    await tester.tap(find.text('Start puzzle'));
    await tester.pumpAndSettle();

    expect(find.text('EASY IMAGE PUZZLE'), findsOneWidget);
    expect(find.text('ORIGINAL IMAGE'), findsOneWidget);
    expect(find.byType(SvgPicture), findsWidgets);
  });

  testWidgets('moving a tile starts the timer on the puzzle page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Start puzzle'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('tile-1')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:01'), findsOneWidget);
  });

  testWidgets('settings switches the app to dark mode', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
