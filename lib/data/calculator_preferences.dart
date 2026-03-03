import 'package:shared_preferences/shared_preferences.dart';

/// Default values for the calculator form (used on first run and reset).
class CalculatorDefaults {
  const CalculatorDefaults._();
  static const String stake = '10';
  static const String odds = '-110';
  static const String pWin = '55';
  static const String pPush = '5';
}

/// Persists and loads calculator inputs via SharedPreferences.
class CalculatorPreferences {
  CalculatorPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _kStake = 'stake';
  static const _kOdds = 'odds';
  static const _kPWin = 'p_win';
  static const _kPPush = 'p_push';

  /// Loads saved values; returns defaults for missing keys.
  CalculatorFormSnapshot load() {
    return CalculatorFormSnapshot(
      stake: _prefs.getString(_kStake) ?? CalculatorDefaults.stake,
      odds: _prefs.getString(_kOdds) ?? CalculatorDefaults.odds,
      pWin: _prefs.getString(_kPWin) ?? CalculatorDefaults.pWin,
      pPush: _prefs.getString(_kPPush) ?? CalculatorDefaults.pPush,
    );
  }

  /// Saves the current form values.
  Future<void> save(CalculatorFormSnapshot snapshot) async {
    await _prefs.setString(_kStake, snapshot.stake);
    await _prefs.setString(_kOdds, snapshot.odds);
    await _prefs.setString(_kPWin, snapshot.pWin);
    await _prefs.setString(_kPPush, snapshot.pPush);
  }

  /// Clears saved values (e.g. after reset to defaults).
  Future<void> clear() async {
    await _prefs.remove(_kStake);
    await _prefs.remove(_kOdds);
    await _prefs.remove(_kPWin);
    await _prefs.remove(_kPPush);
  }
}

/// Immutable snapshot of the four calculator text inputs.
class CalculatorFormSnapshot {
  const CalculatorFormSnapshot({
    required this.stake,
    required this.odds,
    required this.pWin,
    required this.pPush,
  });

  final String stake;
  final String odds;
  final String pWin;
  final String pPush;
}
