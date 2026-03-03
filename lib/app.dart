import 'package:flutter/material.dart';

import 'features/calculator/calculator_screen.dart';

/// Root Material app for the Bet EV Calculator.
class EvBetCalculatorApp extends StatelessWidget {
  const EvBetCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bet EV Calculator',
      theme: ThemeData(useMaterial3: true),
      home: const CalculatorScreen(),
    );
  }
}
