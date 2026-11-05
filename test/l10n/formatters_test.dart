import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/assignment.dart';
import 'package:mathe_trainer/l10n/choice_texts.dart';
import 'package:mathe_trainer/domain/history_range.dart';
import 'package:mathe_trainer/domain/lesson_filter.dart';
import 'package:mathe_trainer/l10n/formatters.dart';

import '../support/l10n.dart';

/// Domain data in the German words of today. These used to be domain tests
/// of strings; the domain now hands over numbers, and the words are checked
/// where they are made.
void main() {
  setUpAll(initDateSymbols);

  final l10n = deL10n;

  test('total practice time is formatted in hours and minutes', () {
    expect(formatTotalTime(l10n, 0), '0 min');
    expect(formatTotalTime(l10n, 42 * 60000), '42 min');
    expect(formatTotalTime(l10n, 60 * 60000), '1 h 0 min');
    expect(formatTotalTime(l10n, (3 * 60 + 12) * 60000), '3 h 12 min');
  });

  test('history timestamps are short', () {
    expect(formatDayAndTime(l10n, DateTime(2026, 9, 5, 14, 32)),
        '5.9. · 14:32');
    expect(formatDayAndTime(l10n, DateTime(2026, 12, 24, 9, 5)),
        '24.12. · 09:05');
  });

  test('a clock time has no leading zero on the hour', () {
    expect(formatClockTime(l10n, DateTime(2026, 9, 5, 9, 5)), '9:05');
    expect(formatClockTime(l10n, DateTime(2026, 9, 5, 14, 32)), '14:32');
  });

  test('last activity is expressed relative to today', () {
    final now = DateTime(2026, 9, 5, 18);
    expect(formatRelativeDay(l10n, DateTime(2026, 9, 5, 7), now: now), 'heute');
    expect(formatRelativeDay(l10n, DateTime(2026, 9, 4, 23), now: now),
        'gestern');
    expect(formatRelativeDay(l10n, DateTime(2026, 9, 2), now: now),
        'vor 3 Tagen');
    expect(formatRelativeDay(l10n, DateTime(2026, 8, 20), now: now),
        '20.8.2026');
  });

  test('durations are formatted for children', () {
    expect(formatDuration(l10n, 4300), '4,3 s');
    expect(formatDuration(l10n, 59900), '59,9 s');
    expect(formatDuration(l10n, 65000), '1:05 min');
    expect(formatPerTask(l10n, 4321), '4,3 s');
  });

  test('the wait is spoken in whole minutes, rounded up', () {
    expect(formatRemaining(l10n, const Duration(seconds: 0)), 'gleich');
    expect(formatRemaining(l10n, const Duration(seconds: -5)), 'gleich');
    expect(formatRemaining(l10n, const Duration(seconds: 1)),
        'noch eine Minute');
    expect(formatRemaining(l10n, const Duration(seconds: 60)),
        'noch eine Minute');
    expect(formatRemaining(l10n, const Duration(seconds: 61)),
        'noch 2 Minuten');
    expect(formatRemaining(l10n, const Duration(minutes: 14)),
        'noch 14 Minuten');
  });

  test('money is written with the decimal comma and the euro sign', () {
    expect(formatEuro(l10n, 350), '3,50 €');
    expect(formatEuro(l10n, 5), '0,05 €');
    expect(formatEuro(l10n, 2000), '20,00 €');
  });

  test('a short day carries its weekday', () {
    expect(formatShortDay(l10n, DateTime(2026, 9, 16)), 'Mi, 16.9.');
    expect(formatShortDay(l10n, DateTime(2026, 9, 14)), 'Mo, 14.9.');
  });

  group('formatDeadline', () {
    Assignment make({
      required AssignmentRhythm rhythm,
      bool repeats = true,
      bool carryOver = false,
      int? onDayMs,
    }) =>
        Assignment(
          id: 1,
          userId: 1,
          lessonIds: const ['add_100_plain'],
          rhythm: rhythm,
          runs: 1,
          taskCount: 10,
          minStars: 0,
          minBolts: 0,
          createdAtMs: DateTime(2026, 9, 1).millisecondsSinceEpoch,
          repeats: repeats,
          carryOver: carryOver,
          onDayMs: onDayMs,
        );

    Assignment once({bool carryOver = false}) => make(
          rhythm: AssignmentRhythm.daily,
          repeats: false,
          carryOver: carryOver,
          onDayMs: DateTime(2026, 9, 16, 10).millisecondsSinceEpoch,
        );

    test('repeating ones name their rhythm', () {
      expect(formatDeadline(l10n, make(rhythm: AssignmentRhythm.daily)),
          'heute');
      expect(formatDeadline(l10n, make(rhythm: AssignmentRhythm.weekly)),
          'bis Sonntag');
    });

    test('a single one says which day it belongs to, and when it is over', () {
      expect(formatDeadline(l10n, once(), now: DateTime(2026, 9, 16, 9)),
          'heute');
      expect(formatDeadline(l10n, once(), now: DateTime(2026, 9, 14)),
          'am Mi, 16.9.');
      expect(formatDeadline(l10n, once(), now: DateTime(2026, 9, 18)),
          'war Mi, 16.9.');
      expect(
          formatDeadline(l10n, once(carryOver: true),
              now: DateTime(2026, 9, 18)),
          'noch offen');
    });
  });

  test('every filter and every range can be named', () {
    for (final filter in LessonFilter.values) {
      expect(lessonFilterTitle(l10n, filter), isNotEmpty);
      expect(lessonFilterExplanation(l10n, filter), isNotEmpty);
    }
    for (final range in HistoryRange.values) {
      expect(historyRangeTitle(l10n, range), isNotEmpty);
      expect(historyRangePhrase(l10n, range), isNotEmpty);
    }
  });
}
