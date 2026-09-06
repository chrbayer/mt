import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/scoring.dart';

void main() {
  test('wrong attempts cost three seconds each', () {
    expect(penalizedTimeMs(60000, 0), 60000);
    expect(penalizedTimeMs(60000, 4), 72000);
  });

  test('score normalises per task so run lengths are comparable', () {
    // 10 tasks in 50 s and 50 tasks in 250 s are equally fast.
    expect(scoreMsPerTask(50000, 0, 10), scoreMsPerTask(250000, 0, 50));
    expect(scoreMsPerTask(50000, 0, 10), 5000);
  });

  test('guessing is punished in the ranking', () {
    final careful = scoreMsPerTask(60000, 0, 10);
    final guesser = scoreMsPerTask(45000, 6, 10);
    expect(guesser, greaterThan(careful));
  });

  test('a clean run scores exactly its elapsed time', () {
    // No mistakes, no penalty: the scored number is the real one.
    expect(scoreMsPerTask(60000, 0, 10), 6000);
    expect(penalizedTimeMs(60000, 0), 60000);
    expect(errorRate(3, 10), closeTo(0.3, 1e-9));
  });

  test('stars range from one to three', () {
    expect(starsFor(0, 10, scored: true), 3);
    expect(starsFor(2, 10, scored: true), 2);
    expect(starsFor(9, 10, scored: true), 1);
    expect(starsFor(100, 10, scored: true), 1);
  });

  test('zero task counts do not divide by zero', () {
    expect(scoreMsPerTask(1000, 1, 0), 0);
    expect(errorRate(1, 0), 0);
  });

  test('total practice time is formatted in hours and minutes', () {
    expect(formatTotalTime(0), '0 min');
    expect(formatTotalTime(42 * 60000), '42 min');
    expect(formatTotalTime(60 * 60000), '1 h 0 min');
    expect(formatTotalTime((3 * 60 + 12) * 60000), '3 h 12 min');
  });

  test('history timestamps are short', () {
    expect(formatDayAndTime(DateTime(2026, 9, 5, 14, 32)), '5.9. · 14:32');
    expect(formatDayAndTime(DateTime(2026, 12, 24, 9, 5)), '24.12. · 09:05');
  });

  test('last activity is expressed relative to today', () {
    final now = DateTime(2026, 9, 5, 18);
    expect(formatRelativeDay(DateTime(2026, 9, 5, 7), now: now), 'heute');
    expect(formatRelativeDay(DateTime(2026, 9, 4, 23), now: now), 'gestern');
    expect(formatRelativeDay(DateTime(2026, 9, 2), now: now), 'vor 3 Tagen');
    expect(formatRelativeDay(DateTime(2026, 8, 20), now: now), '20.8.2026');
  });

  test('durations are formatted for children', () {
    expect(formatDuration(4300), '4,3 s');
    expect(formatDuration(59900), '59,9 s');
    expect(formatDuration(65000), '1:05 min');
    expect(formatPerTask(4321), '4,3 s');
  });

  group('lightning bolts', () {
    test('three at the target, then one fewer per step', () {
      const target = 6000;
      // On the line counts as inside it - a target you cannot actually hit
      // is not a target.
      expect(boltsFor(target, 6000, 10), 3);
      expect(boltsFor(target, 5999, 10), 3);
      expect(boltsFor(target, 6001, 10), 2);
      expect(boltsFor(target, target * twoBoltFactor, 10), 2);
      expect(boltsFor(target, target * twoBoltFactor + 1, 10), 1);
      expect(boltsFor(target, target * oneBoltFactor, 10), 1);
      expect(boltsFor(target, target * oneBoltFactor + 1, 10), 0);
    });

    test('an untimed lesson gives none, however fast the run', () {
      expect(boltsFor(0, 1, 10), 0);
      expect(boltsFor(0, 0, 10), 0);
    });

    test('the next bolt names the time it takes', () {
      const target = 6000;
      expect(nextBoltTargetMs(target, 0), target * oneBoltFactor);
      expect(nextBoltTargetMs(target, 1), target * twoBoltFactor);
      expect(nextBoltTargetMs(target, 2), 6000);
      // All three in: there is nothing left to ask for.
      expect(nextBoltTargetMs(target, 3), isNull);
      expect(nextBoltTargetMs(0, 0), isNull);
    });

    test('every timed lesson has a target, and the first steps have none', () {
      for (final lesson in lessonCatalog) {
        expect(
          lesson.targetMsPerTask > 0,
          lesson.scored,
          reason: lesson.id,
        );
      }
    });

    test('the targets grow with the difficulty of the lesson', () {
      int target(String id) => lessonById(id).targetMsPerTask;

      // Bigger numbers, more time.
      expect(target('add_20_plain'), lessThan(target('add_100_plain')));
      expect(target('add_100_plain'), lessThan(target('add_1000_plain')));
      // Crossing the ten costs a moment, and so does working backwards.
      expect(target('add_100_carry'), greaterThan(target('add_100_plain')));
      expect(target('add_100_gap'), greaterThan(target('add_100_carry')));
      // Pairs learnt by heart are the fastest thing in the app.
      expect(target('partners_of_ten'), lessThan(target('add_10')));
      // The rows that are learnt first are expected to come back faster.
      expect(target('times_2'), lessThan(target('times_7')));
      expect(target('times_10'), lessThan(target('times_7')));
      expect(target('times_all'), greaterThan(target('times_7')));
      // Two answers take longer than one.
      expect(target('div_remainder'), greaterThan(target('div_plain')));
      // Several taps per task: nothing else is slower.
      expect(
        target('money_compose'),
        greaterThan(target('money_add')),
      );
      // Every target is a round tenth of a second, because children read it.
      for (final lesson in lessonCatalog) {
        expect(lesson.targetMsPerTask % 100, 0, reason: lesson.id);
      }
    });
  });
}
