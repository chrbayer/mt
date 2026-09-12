import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/history_range.dart';

/// The run log is narrowed by whole calendar days, not by rolling hours.
void main() {
  final now = DateTime(2026, 9, 12, 14, 30);
  final today = DateTime(2026, 9, 12);

  test('all reaches back without a limit', () {
    expect(historySince(HistoryRange.all, now), isNull);
  });

  test('today starts at midnight, not an hour ago', () {
    expect(historySince(HistoryRange.today, now),
        today.millisecondsSinceEpoch);
  });

  test('a week is today and the six days before it', () {
    expect(historySince(HistoryRange.week, now),
        DateTime(2026, 9, 6).millisecondsSinceEpoch);
  });

  test('a month is thirty days, counted the same way', () {
    expect(historySince(HistoryRange.month, now),
        DateTime(2026, 8, 14).millisecondsSinceEpoch);
  });

  test('the boundary stays on midnight across a daylight-saving change', () {
    // Germany turns the clocks back on the last Sunday in October. Counting
    // 6 * 86400000 ms back from midnight would land at 23:00 the day before
    // and quietly take an extra day in.
    final afterTheChange = DateTime(2026, 10, 28, 9);
    final since = historySince(HistoryRange.week, afterTheChange)!;
    final asDate = DateTime.fromMillisecondsSinceEpoch(since);
    expect(asDate.hour, 0);
    expect(asDate.minute, 0);
    expect(asDate.day, 22);
  });

  test('every range has a title and a phrase for the question', () {
    for (final range in HistoryRange.values) {
      expect(historyRangeTitle(range), isNotEmpty);
      expect(historyRangePhrase(range), isNotEmpty);
    }
  });

  test('an unknown stored name falls back to the whole log', () {
    expect(historyRangeByName('week'), HistoryRange.week);
    // Written by a newer version, read by an older one: showing everything
    // is the harmless misreading, hiding everything is not.
    expect(historyRangeByName('quartal'), HistoryRange.all);
  });
}
