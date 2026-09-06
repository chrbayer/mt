import 'package:flutter_test/flutter_test.dart';
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
    expect(starsFor(0, 10), 3);
    expect(starsFor(2, 10), 2);
    expect(starsFor(9, 10), 1);
    expect(starsFor(100, 10), 1);
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
}
