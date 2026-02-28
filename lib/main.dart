import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'odds.dart';

void main() {
  runApp(const EvBetCalculatorApp());
}

class EvBetCalculatorApp extends StatelessWidget {
  const EvBetCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bet EV Calculator',
      theme: ThemeData(useMaterial3: true),
      home: const EvCalculatorScreen(),
    );
  }
}

class EvCalculatorScreen extends StatefulWidget {
  const EvCalculatorScreen({super.key});

  @override
  State<EvCalculatorScreen> createState() => _EvCalculatorScreenState();
}

class _EvCalculatorScreenState extends State<EvCalculatorScreen> {
  // Defaults
  static const _defaultStake = '10';
  static const _defaultOdds = '-110';
  static const _defaultPWin = '55';
  static const _defaultPPush = '5';

  // Pref keys
  static const _kStake = 'stake';
  static const _kOdds = 'odds';
  static const _kPWin = 'p_win';
  static const _kPPush = 'p_push';

  final _stakeCtrl = TextEditingController(text: _defaultStake);
  final _oddsCtrl = TextEditingController(text: _defaultOdds);
  final _pWinCtrl = TextEditingController(text: _defaultPWin); // percent
  final _pPushCtrl = TextEditingController(text: _defaultPPush); // percent

  Timer? _saveDebounce;
  bool _hydrating = true;

  String? _error;

  double? _decimalOdds;
  double? _pImplied;

  double? _pWin;
  double? _pPush;
  double? _pLose;

  double? _profitIfWin;
  double? _ev;
  double? _evPct;
  double? _expectedReturn;
  double? _edge; // pWin - pImplied

  @override
  void initState() {
    super.initState();

    _stakeCtrl.addListener(_onInputsChanged);
    _oddsCtrl.addListener(_onInputsChanged);
    _pWinCtrl.addListener(_onInputsChanged);
    _pPushCtrl.addListener(_onInputsChanged);

    _loadPrefs();
  }

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _stakeCtrl.dispose();
    _oddsCtrl.dispose();
    _pWinCtrl.dispose();
    _pPushCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final stake = prefs.getString(_kStake);
    final odds = prefs.getString(_kOdds);
    final pWin = prefs.getString(_kPWin);
    final pPush = prefs.getString(_kPPush);

    if (stake != null) _stakeCtrl.text = stake;
    if (odds != null) _oddsCtrl.text = odds;
    if (pWin != null) _pWinCtrl.text = pWin;
    if (pPush != null) _pPushCtrl.text = pPush;

    setState(() => _hydrating = false);
    _recalc();
  }

  void _onInputsChanged() {
    _recalc();

    if (_hydrating) return;

    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 250), () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kStake, _stakeCtrl.text.trim());
      await prefs.setString(_kOdds, _oddsCtrl.text.trim());
      await prefs.setString(_kPWin, _pWinCtrl.text.trim());
      await prefs.setString(_kPPush, _pPushCtrl.text.trim());
    });
  }

  Future<void> _resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() => _hydrating = true);

    _stakeCtrl.text = _defaultStake;
    _oddsCtrl.text = _defaultOdds;
    _pWinCtrl.text = _defaultPWin;
    _pPushCtrl.text = _defaultPPush;

    await prefs.remove(_kStake);
    await prefs.remove(_kOdds);
    await prefs.remove(_kPWin);
    await prefs.remove(_kPPush);

    setState(() => _hydrating = false);
    _recalc();
  }

  void _recalc() {
    setState(() {
      _error = null;

      _decimalOdds = null;
      _pImplied = null;

      _pWin = null;
      _pPush = null;
      _pLose = null;

      _profitIfWin = null;
      _ev = null;
      _evPct = null;
      _expectedReturn = null;
      _edge = null;

      try {
        final stake = double.parse(_stakeCtrl.text.trim());
        if (stake <= 0) {
          throw const FormatException('Stake must be greater than 0.');
        }

        final oddsRes = parseOdds(_oddsCtrl.text);
        final decimalOdds = oddsRes.decimalOdds;

        final pWinPercent = double.parse(_pWinCtrl.text.trim());
        if (pWinPercent < 0 || pWinPercent > 100) {
          throw const FormatException('Win probability must be between 0 and 100.');
        }
        final pWin = pWinPercent / 100.0;

        final pPushPercent = double.parse(_pPushCtrl.text.trim());
        if (pPushPercent < 0 || pPushPercent > 100) {
          throw const FormatException('Push probability must be between 0 and 100.');
        }
        final pPush = pPushPercent / 100.0;

        if (pWin + pPush > 1.0) {
          throw const FormatException('Win% + Push% must be <= 100.');
        }

        final pLose = 1.0 - pWin - pPush;

        final pImplied = impliedProbabilityFromDecimal(decimalOdds);
        final profit = profitIfWin(stake, decimalOdds);

        final ev = expectedValueProfitWithPush(
          stake: stake,
          decimalOdds: decimalOdds,
          pWin: pWin,
          pPush: pPush,
        );

        final evPct = ev / stake;
        final expectedReturn = stake + ev;
        final edge = pWin - pImplied;

        _decimalOdds = decimalOdds;
        _pImplied = pImplied;

        _pWin = pWin;
        _pPush = pPush;
        _pLose = pLose;

        _profitIfWin = profit;
        _ev = ev;
        _evPct = evPct;
        _expectedReturn = expectedReturn;
        _edge = edge;
      } on FormatException catch (e) {
        _error = e.message;
      } on ArgumentError catch (e) {
        _error = e.message;
      } catch (_) {
        _error = 'Invalid input.';
      }
    });
  }

  String _fmtMoney(double v) => v.toStringAsFixed(2);
  String _fmtPct(double v01) => '${(v01 * 100).toStringAsFixed(2)}%';

  @override
  Widget build(BuildContext context) {
    final hasResults = _error == null && _decimalOdds != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bet EV Calculator'),
        actions: [
          IconButton(
            tooltip: 'Reset to defaults',
            onPressed: _resetToDefaults,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _stakeCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Stake (bet amount)',
                hintText: 'e.g., 10',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _oddsCtrl,
              decoration: const InputDecoration(
                labelText: 'Odds',
                hintText: 'Decimal (1.91), American (-110, +150), Fractional (5/4)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pWinCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Your win probability (%)',
                hintText: '0 to 100',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pPushCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Your push probability (%)',
                hintText: '0 to 100',
              ),
            ),
            const SizedBox(height: 16),
            if (_error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              ),
            if (hasResults)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ResultRow(label: 'Decimal odds', value: _decimalOdds!.toStringAsFixed(4)),
                      _ResultRow(label: 'Implied probability', value: _fmtPct(_pImplied!)),
                      _ResultRow(label: 'Profit if win', value: _fmtMoney(_profitIfWin!)),
                      const Divider(),
                      _ResultRow(label: 'Win probability', value: _fmtPct(_pWin!)),
                      _ResultRow(label: 'Push probability', value: _fmtPct(_pPush!)),
                      _ResultRow(label: 'Loss probability', value: _fmtPct(_pLose!)),
                      const Divider(),
                      _ResultRow(label: 'EV (expected profit)', value: _fmtMoney(_ev!)),
                      _ResultRow(label: 'EV%', value: _fmtPct(_evPct!)),
                      _ResultRow(
                        label: 'Expected return (stake + EV)',
                        value: _fmtMoney(_expectedReturn!),
                      ),
                      _ResultRow(label: 'Edge (p_win - p_implied)', value: _fmtPct(_edge!)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'Notes:\n'
              '- EV shown is expected profit. Push returns stake with zero profit.\n'
              '- This does not account for multi-leg parlays, partial cashouts, or fees.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;

  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 12),
          Text(value),
        ],
      ),
    );
  }
}
