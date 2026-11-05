import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/l10n/formatters.dart';

import '../support/l10n.dart';

/// The same formatters in French: decimal comma, the euro sign behind the
/// amount, the 24-hour clock, day before month.
void main() {
  setUpAll(initFrenchDateSymbols);

  final l10n = frL10n;

  test('durations use a decimal comma', () {
    expect(formatDuration(l10n, 4300), '4,3 s');
    expect(formatDuration(l10n, 65000), '1:05 min');
    expect(formatPerTask(l10n, 4321), '4,3 s');
    expect(formatTotalTime(l10n, (3 * 60 + 12) * 60000), '3 h 12 min');
  });

  test('money has the euro sign behind and a decimal comma', () {
    expect(formatEuro(l10n, 250), '2,50 €');
    expect(formatEuro(l10n, 5), '0,05 €');
    expect(formatPiece(l10n, 50), '50 c');
    expect(formatPiece(l10n, 200), '2 €');
  });

  test('times of day are on a 24-hour clock', () {
    expect(formatClockTime(l10n, DateTime(2026, 9, 5, 9, 5)), '9:05');
    expect(formatClockTime(l10n, DateTime(2026, 9, 5, 14, 32)), '14:32');
    expect(
      formatDayAndTime(l10n, DateTime(2026, 9, 5, 14, 32)),
      '05/09 · 14:32',
    );
  });

  test('the wait is spoken in whole minutes', () {
    expect(formatRemaining(l10n, const Duration(seconds: 0)), 'bientôt');
    expect(
      formatRemaining(l10n, const Duration(seconds: 61)),
      'encore 2 minutes',
    );
  });
}
