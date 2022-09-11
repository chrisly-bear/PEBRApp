// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pebrapp/screens/MainScreen.dart';

void main() {
  testWidgets("Main Screen has an 'add patient' button",
      (WidgetTester tester) async {
    // wrap MainScreen in a MediaQuery
    Widget testWidget = new MediaQuery(
        data: new MediaQueryData(),
        child: new MaterialApp(home: MainScreen(true)));

    await tester.pumpWidget(testWidget);

    final Finder addButtonFinder = find.byIcon(Icons.add);
    expect(addButtonFinder, findsOneWidget);
  });
}
