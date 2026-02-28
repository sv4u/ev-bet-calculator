// Smoke test for the EV Bet Calculator app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ev_bet_calculator/main.dart';

void main() {
  testWidgets('App loads and shows calculator title', (WidgetTester tester) async {
    await tester.pumpWidget(const EvBetCalculatorApp());
    expect(find.text('Bet EV Calculator'), findsOneWidget);
  });
}
