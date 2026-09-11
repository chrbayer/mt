import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/assignment.dart';
import 'package:mathe_trainer/domain/lesson.dart';

/// Periods, closed periods, and what counts as a qualifying run - none of it
/// needs a database, which is the whole point of keeping this in
/// domain/assignment.dart.
void main() {
  final lesson = lessonById('add_100_plain');

  Assignment daily({
    int dueMinute = 18 * 60,
    int runs = 1,
    int taskCount = 10,
    int minStars = 0,
    int minBolts = 0,
    required int createdAtMs,
    int? endedAtMs,
  }) =>
      Assignment(
        id: 1,
        userId: 1,
        lessonId: lesson.id,
        rhythm: AssignmentRhythm.daily,
        dueMinute: dueMinute,
        dueWeekday: 7,
        runs: runs,
        taskCount: taskCount,
        minStars: minStars,
        minBolts: minBolts,
        createdAtMs: createdAtMs,
        endedAtMs: endedAtMs,
      );

  Assignment weekly({
    int dueMinute = 18 * 60,
    int dueWeekday = DateTime.friday,
    required int createdAtMs,
    int? endedAtMs,
  }) =>
      Assignment(
        id: 2,
        userId: 1,
        lessonId: lesson.id,
        rhythm: AssignmentRhythm.weekly,
        dueMinute: dueMinute,
        dueWeekday: dueWeekday,
        runs: 1,
        taskCount: 10,
        minStars: 0,
        minBolts: 0,
        createdAtMs: createdAtMs,
        endedAtMs: endedAtMs,
      );

  group('periodAt', () {
    test('a daily period is the calendar day, due at its own minute', () {
      final a = daily(dueMinute: 18 * 60, createdAtMs: 0);
      final now = DateTime(2026, 3, 10, 9, 30);
      final period = periodAt(a, now);
      expect(period.startMs, DateTime(2026, 3, 10).millisecondsSinceEpoch);
      expect(
        period.dueMs,
        DateTime(2026, 3, 10, 18).millisecondsSinceEpoch,
      );
    });

    test('a weekly period starts Monday and is due on its weekday', () {
      final a = weekly(dueWeekday: DateTime.friday, createdAtMs: 0);
      // Wednesday, 2026-03-11.
      final now = DateTime(2026, 3, 11);
      final period = periodAt(a, now);
      // Monday of that week is 2026-03-09.
      expect(period.startMs, DateTime(2026, 3, 9).millisecondsSinceEpoch);
      expect(
        period.dueMs,
        DateTime(2026, 3, 13, 18).millisecondsSinceEpoch,
      );
    });

    test('a Monday itself still starts its own week', () {
      final a = weekly(dueWeekday: DateTime.friday, createdAtMs: 0);
      final now = DateTime(2026, 3, 9, 7);
      expect(
        periodAt(a, now).startMs,
        DateTime(2026, 3, 9).millisecondsSinceEpoch,
      );
    });
  });

  group('closedPeriods', () {
    test('the first period is missing when created after its due time', () {
      // Created at 19:00 on the 10th - today's 18:00 deadline had already
      // passed, so today never belonged to this assignment.
      final a = daily(
        dueMinute: 18 * 60,
        createdAtMs: DateTime(2026, 3, 10, 19).millisecondsSinceEpoch,
      );
      final now = DateTime(2026, 3, 13, 9);
      final closed = closedPeriods(a, now);
      expect(
        closed.every((p) => p.dueMs >= a.createdAtMs),
        isTrue,
      );
      expect(
        closed.any((p) =>
            p.dueMs == DateTime(2026, 3, 10, 18).millisecondsSinceEpoch),
        isFalse,
      );
      // The 11th and 12th did fall inside its lifetime.
      expect(closed.length, 2);
    });

    test('nothing after ended counts any more', () {
      final a = daily(
        dueMinute: 18 * 60,
        createdAtMs: DateTime(2026, 3, 1).millisecondsSinceEpoch,
        endedAtMs: DateTime(2026, 3, 5, 18).millisecondsSinceEpoch,
      );
      // Asked long after the end - only the days up to and including the 5th
      // may show up.
      final now = DateTime(2026, 3, 20);
      final closed = closedPeriods(a, now);
      expect(closed.every((p) => p.dueMs <= a.endedAtMs!), isTrue);
      expect(
        closed.any((p) =>
            p.dueMs == DateTime(2026, 3, 5, 18).millisecondsSinceEpoch),
        isTrue,
      );
    });

    test('closed periods come oldest first', () {
      final a = daily(
        dueMinute: 12 * 60,
        createdAtMs: DateTime(2026, 3, 1).millisecondsSinceEpoch,
      );
      final now = DateTime(2026, 3, 5);
      final closed = closedPeriods(a, now);
      for (var i = 1; i < closed.length; i++) {
        expect(closed[i].dueMs, greaterThan(closed[i - 1].dueMs));
      }
    });
  });

  group('qualifies', () {
    const dueMs = 1000000;

    RunFacts run({
      int finishedAtMs = dueMs - 1,
      int taskCount = 10,
      int totalMs = 40000,
      int wrongAttempts = 0,
    }) =>
        (
          finishedAtMs: finishedAtMs,
          taskCount: taskCount,
          totalMs: totalMs,
          wrongAttempts: wrongAttempts,
        );

    test('a run finished after the deadline does not qualify', () {
      final a = daily(createdAtMs: 0);
      expect(
        qualifies(
          a: a,
          lesson: lesson,
          run: run(finishedAtMs: dueMs + 1),
          dueMs: dueMs,
        ),
        isFalse,
      );
    });

    test('too few tasks does not qualify, even at good quality', () {
      final a = daily(taskCount: 20, createdAtMs: 0);
      expect(
        qualifies(
          a: a,
          lesson: lesson,
          run: run(taskCount: 10),
          dueMs: dueMs,
        ),
        isFalse,
      );
    });

    test('a longer run than asked for still qualifies', () {
      final a = daily(taskCount: 10, createdAtMs: 0);
      expect(
        qualifies(
          a: a,
          lesson: lesson,
          run: run(taskCount: 50),
          dueMs: dueMs,
        ),
        isTrue,
      );
    });

    test('too few stars does not qualify', () {
      final a = daily(minStars: 3, createdAtMs: 0);
      expect(
        qualifies(
          a: a,
          lesson: lesson,
          // Sloppy enough for only one star.
          run: run(wrongAttempts: 9),
          dueMs: dueMs,
        ),
        isFalse,
      );
    });

    test('too few bolts does not qualify', () {
      final a = daily(minBolts: 3, createdAtMs: 0);
      expect(
        qualifies(
          a: a,
          lesson: lesson,
          // Far slower than the lesson's target.
          run: run(totalMs: 999999),
          dueMs: dueMs,
        ),
        isFalse,
      );
    });

    test('meeting every minimum qualifies', () {
      final a = daily(taskCount: 10, minStars: 3, minBolts: 3, createdAtMs: 0);
      expect(
        qualifies(
          a: a,
          lesson: lesson,
          run: run(totalMs: 10 * lesson.targetMsPerTask, wrongAttempts: 0),
          dueMs: dueMs,
        ),
        isTrue,
      );
    });
  });

  group('progressIn', () {
    test('counts qualifying runs and says whether the goal is met', () {
      final a = daily(runs: 2, taskCount: 10, createdAtMs: 0);
      final period = periodAt(a, DateTime(2026, 3, 10, 20));
      final good = (
        finishedAtMs: period.startMs + 1000,
        taskCount: 10,
        totalMs: 10 * lesson.targetMsPerTask,
        wrongAttempts: 0,
      );
      final tooFew = (
        finishedAtMs: period.startMs + 2000,
        taskCount: 5,
        totalMs: 5000,
        wrongAttempts: 0,
      );

      final one = progressIn(
        a: a,
        lesson: lesson,
        period: period,
        runs: [good, tooFew],
      );
      expect(one.qualifyingRuns, 1);
      expect(one.met, isFalse);

      final two = progressIn(
        a: a,
        lesson: lesson,
        period: period,
        runs: [good, good, tooFew],
      );
      expect(two.qualifyingRuns, 2);
      expect(two.met, isTrue);
    });

    test('a run from before the period started does not count', () {
      final a = daily(runs: 1, taskCount: 10, createdAtMs: 0);
      final period = periodAt(a, DateTime(2026, 3, 10, 20));
      final yesterday = (
        finishedAtMs: period.startMs - 1000,
        taskCount: 10,
        totalMs: 10 * lesson.targetMsPerTask,
        wrongAttempts: 0,
      );
      final progress = progressIn(
        a: a,
        lesson: lesson,
        period: period,
        runs: [yesterday],
      );
      expect(progress.qualifyingRuns, 0);
      expect(progress.met, isFalse);
    });
  });

  group('formatDueTime', () {
    test('a daily assignment names the time', () {
      final a = daily(dueMinute: 9 * 60 + 5, createdAtMs: 0);
      expect(formatDueTime(a), 'bis 09:05');
    });

    test('a weekly assignment names the weekday', () {
      final a = weekly(dueWeekday: DateTime.sunday, createdAtMs: 0);
      expect(formatDueTime(a), 'bis So');
    });
  });

  group('rhythmByName', () {
    test('reads a stored name back', () {
      expect(rhythmByName('weekly'), AssignmentRhythm.weekly);
      expect(rhythmByName('daily'), AssignmentRhythm.daily);
    });

    test('an unknown name falls back to daily', () {
      expect(rhythmByName('monthly'), AssignmentRhythm.daily);
    });
  });
}
