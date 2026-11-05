import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/assignment.dart';
import 'package:mathe_trainer/domain/history_range.dart';
import 'package:mathe_trainer/domain/lesson_filter.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/l10n/choice_texts.dart';
import 'package:mathe_trainer/l10n/formatters.dart';
import 'package:mathe_trainer/l10n/task_texts.dart';

import '../support/l10n.dart';

/// The same formatters as `formatters_test`, in English: the decimal point,
/// the euro sign in front, the twelve-hour clock, month before day.
void main() {
  setUpAll(initEnglishDateSymbols);

  final l10n = enL10n;

  test('durations use a decimal point', () {
    expect(formatDuration(l10n, 4300), '4.3 s');
    expect(formatDuration(l10n, 59900), '59.9 s');
    expect(formatDuration(l10n, 65000), '1:05 min');
    expect(formatPerTask(l10n, 4321), '4.3 s');
  });

  test('total practice time', () {
    expect(formatTotalTime(l10n, 42 * 60000), '42 min');
    expect(formatTotalTime(l10n, (3 * 60 + 12) * 60000), '3 h 12 min');
  });

  test('money has the euro sign in front and a decimal point', () {
    expect(formatEuro(l10n, 350), '€3.50');
    expect(formatEuro(l10n, 5), '€0.05');
    expect(formatEuro(l10n, 2000), '€20.00');
    expect(formatPiece(l10n, 50), '50c');
    expect(formatPiece(l10n, 200), '€2');
  });

  test('times of day are on a twelve-hour clock', () {
    expect(formatClockTime(l10n, DateTime(2026, 9, 5, 9, 5)), '9:05 AM');
    expect(formatClockTime(l10n, DateTime(2026, 9, 5, 14, 32)), '2:32 PM');
    expect(
      formatDayAndTime(l10n, DateTime(2026, 9, 5, 14, 32)),
      '9/5 · 2:32 PM',
    );
  });

  test('a short day carries its weekday, month first', () {
    expect(formatShortDay(l10n, DateTime(2026, 9, 16)), 'Wed, 9/16');
    expect(formatShortDate(l10n, DateTime(2026, 9, 5)), '9/5');
  });

  test('last activity is expressed relative to today', () {
    final now = DateTime(2026, 9, 5, 18);
    expect(formatRelativeDay(l10n, DateTime(2026, 9, 5, 7), now: now), 'today');
    expect(
      formatRelativeDay(l10n, DateTime(2026, 9, 4, 23), now: now),
      'yesterday',
    );
    expect(
      formatRelativeDay(l10n, DateTime(2026, 9, 2), now: now),
      '3 days ago',
    );
    expect(
      formatRelativeDay(l10n, DateTime(2026, 8, 20), now: now),
      '8/20/2026',
    );
  });

  test('the wait is spoken in whole minutes, rounded up', () {
    expect(formatRemaining(l10n, const Duration(seconds: 0)), 'soon');
    expect(formatRemaining(l10n, const Duration(seconds: 1)), '1 more minute');
    expect(
      formatRemaining(l10n, const Duration(seconds: 61)),
      '2 more minutes',
    );
  });

  test('deadlines', () {
    Assignment make({bool repeats = true, int? onDayMs}) => Assignment(
      id: 1,
      userId: 1,
      lessonIds: const ['add_100_plain'],
      rhythm: repeats ? AssignmentRhythm.weekly : AssignmentRhythm.daily,
      runs: 1,
      taskCount: 10,
      minStars: 0,
      minBolts: 0,
      createdAtMs: DateTime(2026, 9, 1).millisecondsSinceEpoch,
      repeats: repeats,
      carryOver: false,
      onDayMs: onDayMs,
    );
    expect(formatDeadline(l10n, make()), 'until Sunday');
    final once = make(
      repeats: false,
      onDayMs: DateTime(2026, 9, 16, 10).millisecondsSinceEpoch,
    );
    expect(
      formatDeadline(l10n, once, now: DateTime(2026, 9, 14)),
      'on Wed, 9/16',
    );
  });

  test('small words come in the right number', () {
    expect(l10n.placeOnes(1), '1 one');
    expect(l10n.placeTens(12), '12 tens');
    expect(l10n.taskRenderDiceOne(1), '1 dot');
    expect(l10n.taskRenderDiceOne(4), '4 dots');
    expect(l10n.profilesTodo(1), '1 assignment');
    expect(l10n.profilesTodo(3), '3 assignments');
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
    expect(dayPartName(l10n, DayPart.afternoon), 'in the afternoon');
  });
}
