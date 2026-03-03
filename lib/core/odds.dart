/// Odds parsing + EV math for a single-outcome bet.
///
/// Supported odds formats:
/// - Decimal: "1.91"
/// - American: "-110", "+150"
/// - Fractional: "5/4"
///
/// Semantics:
/// - "Profit if win" is net profit excluding returned stake.
/// - Push outcomes return stake and yield zero profit.
/// - EV is expected profit (currency), not expected payout.
class OddsParseResult {
  const OddsParseResult(this.decimalOdds);
  final double decimalOdds; // e.g. 1.91
}

OddsParseResult parseOdds(String raw) {
  final s = raw.trim();

  // Fractional: "5/4"
  final frac = RegExp(r'^(\d+)\s*/\s*(\d+)$').firstMatch(s);
  if (frac != null) {
    final n = double.parse(frac.group(1)!);
    final d = double.parse(frac.group(2)!);
    if (d == 0) throw const FormatException('Fractional odds denominator cannot be 0.');
    final decimal = 1.0 + (n / d);
    if (decimal <= 1.0) throw const FormatException('Decimal odds must be > 1.0.');
    return OddsParseResult(decimal);
  }

  // American: "+150" or "-110"
  if (RegExp(r'^[+-]\d+$').hasMatch(s)) {
    final a = int.parse(s);
    if (a == 0) throw const FormatException('American odds cannot be 0.');
    final decimal = a > 0 ? 1.0 + (a / 100.0) : 1.0 + (100.0 / a.abs());
    if (decimal <= 1.0) throw const FormatException('Decimal odds must be > 1.0.');
    return OddsParseResult(decimal);
  }

  // Decimal: "1.91"
  final decimal = double.tryParse(s);
  if (decimal != null) {
    if (decimal <= 1.0) throw const FormatException('Decimal odds must be > 1.0.');
    return OddsParseResult(decimal);
  }

  throw FormatException('Unrecognized odds format: "$raw"');
}

double impliedProbabilityFromDecimal(double decimalOdds) {
  if (decimalOdds <= 1.0) throw ArgumentError('Decimal odds must be > 1.0.');
  return 1.0 / decimalOdds;
}

double profitIfWin(double stake, double decimalOdds) {
  if (stake <= 0) throw ArgumentError('Stake must be > 0.');
  if (decimalOdds <= 1.0) throw ArgumentError('Decimal odds must be > 1.0.');
  return stake * (decimalOdds - 1.0);
}

/// Expected *profit* with push outcomes.
///
/// Inputs:
/// - stake S > 0
/// - decimal odds D > 1
/// - pWin in [0,1]
/// - pPush in [0,1]
/// - pWin + pPush <= 1
///
/// Derived:
/// - pLose = 1 - pWin - pPush
///
/// EV (expected profit):
///   EV = pWin * (S*(D-1)) - pLose * S
///
/// Push contributes 0 profit (stake returned).
double expectedValueProfitWithPush({
  required double stake,
  required double decimalOdds,
  required double pWin,
  required double pPush,
}) {
  if (stake <= 0) throw ArgumentError('Stake must be > 0.');
  if (decimalOdds <= 1.0) throw ArgumentError('Decimal odds must be > 1.0.');
  if (pWin < 0 || pWin > 1) throw ArgumentError('pWin must be in [0,1].');
  if (pPush < 0 || pPush > 1) throw ArgumentError('pPush must be in [0,1].');
  if (pWin + pPush > 1.0 + 1e-9) throw ArgumentError('pWin + pPush must be <= 1.');

  final pLose = 1.0 - pWin - pPush;
  final winProfit = profitIfWin(stake, decimalOdds);
  return pWin * winProfit - pLose * stake;
}
