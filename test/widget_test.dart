// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:sliding_puzzle/main.dart';

void main() {
  testWidgets('starts with the medium puzzle and timer', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('MEDIUM BOARD'), findsOneWidget);
    expect(find.text('00:00'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
  });

  testWidgets('switching difficulty creates the selected board', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Easy'));
    await tester.pump();
    expect(find.text('EASY BOARD'), findsOneWidget);
    expect(find.byKey(const ValueKey('tile-1')), findsOneWidget);

    await tester.tap(find.text('Hard'));
    await tester.pump();
    expect(find.text('HARD BOARD'), findsOneWidget);
  });

  testWidgets('moving a tile starts the timer', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const ValueKey('tile-1')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('00:01'), findsOneWidget);
  });

  testWidgets('settings switches the app to dark mode', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Appearance'), findsOneWidget);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });

  testWidgets('switching to image mode renders image puzzle tiles', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Image'));
    await tester.pump();

    expect(find.text('Slide the picture back together'), findsOneWidget);
    expect(find.byType(SvgPicture), findsWidgets);
  });

  testWidgets('image mode lets the player choose the reference picture', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Image'));
    await tester.pump();
    expect(find.text('ORIGINAL IMAGE'), findsOneWidget);

    await tester.tap(find.text('Ladybug'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fruit').last);
    await tester.pump();

    expect(find.text('Fruit'), findsOneWidget);
  });
}
