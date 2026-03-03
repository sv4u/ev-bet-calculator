import 'package:flutter_test/flutter_test.dart';
import 'package:ev_bet_calculator/core/odds.dart';

void main() {
  group('parseOdds', () {
    test('decimal odds', () {
      expect(parseOdds('1.91').decimalOdds, closeTo(1.91, 1e-9));
      expect(parseOdds('2.0').decimalOdds, closeTo(2.0, 1e-9));
      expect(parseOdds('  2.5  ').decimalOdds, closeTo(2.5, 1e-9));
    });

    test('American positive', () {
      expect(parseOdds('+150').decimalOdds, closeTo(2.5, 1e-9));
      expect(parseOdds('+100').decimalOdds, closeTo(2.0, 1e-9));
      expect(parseOdds('+200').decimalOdds, closeTo(3.0, 1e-9));
    });

    test('American negative', () {
      expect(parseOdds('-110').decimalOdds, closeTo(1.909090909, 1e-3));
      expect(parseOdds('-200').decimalOdds, closeTo(1.5, 1e-9));
      expect(parseOdds('-100').decimalOdds, closeTo(2.0, 1e-9));
    });

    test('fractional', () {
      expect(parseOdds('5/4').decimalOdds, closeTo(2.25, 1e-9));
      expect(parseOdds('1/1').decimalOdds, closeTo(2.0, 1e-9));
      expect(parseOdds('  3 / 2  ').decimalOdds, closeTo(2.5, 1e-9));
    });

    test('rejects invalid odds', () {
      expect(() => parseOdds('0/1'), throwsFormatException);
      expect(() => parseOdds('+0'), throwsFormatException);
      expect(() => parseOdds('-0'), throwsFormatException);
      expect(() => parseOdds('1.0'), throwsFormatException);
      expect(() => parseOdds('0.5'), throwsFormatException);
      expect(() => parseOdds('abc'), throwsFormatException);
      expect(() => parseOdds(''), throwsFormatException);
    });
  });

  group('impliedProbabilityFromDecimal', () {
    test('correct implied probability', () {
      expect(impliedProbabilityFromDecimal(2.0), closeTo(0.5, 1e-9));
      expect(impliedProbabilityFromDecimal(1.91), closeTo(1 / 1.91, 1e-9));
      expect(impliedProbabilityFromDecimal(10.0), closeTo(0.1, 1e-9));
    });

    test('rejects decimalOdds <= 1.0', () {
      expect(() => impliedProbabilityFromDecimal(1.0), throwsArgumentError);
      expect(() => impliedProbabilityFromDecimal(0.5), throwsArgumentError);
    });
  });

  group('profitIfWin', () {
    test('correct profit', () {
      expect(profitIfWin(100, 2.0), closeTo(100.0, 1e-9));
      expect(profitIfWin(10, 1.91), closeTo(9.1, 1e-9));
      expect(profitIfWin(50, 3.0), closeTo(100.0, 1e-9));
    });

    test('rejects invalid stake or odds', () {
      expect(() => profitIfWin(0, 2.0), throwsArgumentError);
      expect(() => profitIfWin(-10, 2.0), throwsArgumentError);
      expect(() => profitIfWin(100, 1.0), throwsArgumentError);
    });
  });

  group('expectedValueProfitWithPush', () {
    test('always win yields full profit', () {
      final ev = expectedValueProfitWithPush(
        stake: 100,
        decimalOdds: 2.0,
        pWin: 1.0,
        pPush: 0.0,
      );
      expect(ev, closeTo(100.0, 1e-9));
    });

    test('always lose yields negative stake', () {
      final ev = expectedValueProfitWithPush(
        stake: 100,
        decimalOdds: 2.0,
        pWin: 0.0,
        pPush: 0.0,
      );
      expect(ev, closeTo(-100.0, 1e-9));
    });

    test('always push yields zero', () {
      final ev = expectedValueProfitWithPush(
        stake: 100,
        decimalOdds: 2.0,
        pWin: 0.0,
        pPush: 1.0,
      );
      expect(ev, closeTo(0.0, 1e-9));
    });

    test('mixed probabilities', () {
      final ev = expectedValueProfitWithPush(
        stake: 10,
        decimalOdds: 1.91,
        pWin: 0.55,
        pPush: 0.05,
      );
      // pLose = 0.4, winProfit = 9.1, EV = 0.55*9.1 - 0.4*10 = 5.005 - 4 = 1.005
      expect(ev, closeTo(1.005, 1e-6));
    });

    test('rejects invalid inputs', () {
      expect(
        () => expectedValueProfitWithPush(
          stake: 0,
          decimalOdds: 2.0,
          pWin: 0.5,
          pPush: 0.0,
        ),
        throwsArgumentError,
      );
      expect(
        () => expectedValueProfitWithPush(
          stake: 100,
          decimalOdds: 1.0,
          pWin: 0.5,
          pPush: 0.0,
        ),
        throwsArgumentError,
      );
      expect(
        () => expectedValueProfitWithPush(
          stake: 100,
          decimalOdds: 2.0,
          pWin: 1.5,
          pPush: 0.0,
        ),
        throwsArgumentError,
      );
      expect(
        () => expectedValueProfitWithPush(
          stake: 100,
          decimalOdds: 2.0,
          pWin: 0.5,
          pPush: 0.6,
        ),
        throwsArgumentError,
      );
    });
  });
}
