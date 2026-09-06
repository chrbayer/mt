import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/practice_limit.dart';

void main() {
  final now = DateTime(2026, 9, 6, 15, 0);

  PracticeAllowance check({
    int limit = 30,
    int pause = 15,
    int practisedMinutes = 0,
    Duration sinceLastRun = const Duration(minutes: 1),
  }) =>
      practiceAllowance(
        limitMinutes: limit,
        breakMinutes: pause,
        practisedMs: practisedMinutes * 60000,
        lastFinishedAt: now.subtract(sinceLastRun),
        now: now,
      );

  test('without a cap nothing is ever blocked', () {
    final allowance = check(limit: 0, practisedMinutes: 600);
    expect(allowance.allowed, isTrue);
    expect(allowance.limitMinutes, 0);
    expect(allowance.breakUntil, isNull);
  });

  test('a child who has never practised may start', () {
    final allowance = practiceAllowance(
      limitMinutes: 30,
      breakMinutes: 15,
      practisedMs: 0,
      lastFinishedAt: null,
      now: now,
    );
    expect(allowance.allowed, isTrue);
  });

  test('below the cap practice goes on', () {
    expect(check(practisedMinutes: 29).allowed, isTrue);
  });

  test('at the cap the break starts, and it ends when it is over', () {
    final blocked = check(practisedMinutes: 30, sinceLastRun: const Duration(minutes: 2));
    expect(blocked.allowed, isFalse);
    expect(blocked.practisedMinutes, 30);
    // Fifteen minutes after the last run ended, which was two minutes ago.
    expect(blocked.breakUntil, DateTime(2026, 9, 6, 15, 13));
  });

  test('a break that has been taken wipes the stretch, however long it was',
      () {
    // Two hours of practice, but the break afterwards was long enough.
    final after = check(
      practisedMinutes: 120,
      sinceLastRun: const Duration(minutes: 15),
    );
    expect(after.allowed, isTrue);
    expect(after.practisedMinutes, 0, reason: 'a new stretch starts at zero');
  });

  test('a break one minute short is still a break not taken', () {
    expect(
      check(practisedMinutes: 40, sinceLastRun: const Duration(minutes: 14))
          .allowed,
      isFalse,
    );
  });

  test('the wait is spoken in whole minutes, rounded up', () {
    expect(formatRemaining(const Duration(seconds: 0)), 'gleich');
    expect(formatRemaining(const Duration(seconds: -5)), 'gleich');
    expect(formatRemaining(const Duration(seconds: 1)), 'noch eine Minute');
    expect(formatRemaining(const Duration(seconds: 60)), 'noch eine Minute');
    expect(formatRemaining(const Duration(seconds: 61)), 'noch 2 Minuten');
    expect(formatRemaining(const Duration(minutes: 14)), 'noch 14 Minuten');
  });

  group('the daily total', () {
    PracticeAllowance today({
      int daily = 60,
      int minutesToday = 0,
      int stretchMinutes = 0,
    }) =>
        practiceAllowance(
          limitMinutes: 30,
          breakMinutes: 15,
          practisedMs: stretchMinutes * 60000,
          lastFinishedAt: now.subtract(const Duration(minutes: 1)),
          now: now,
          dailyLimitMinutes: daily,
          practisedTodayMs: minutesToday * 60000,
        );

    test('below it the day carries on', () {
      expect(today(minutesToday: 59).allowed, isTrue);
    });

    test('once used up no break helps - the day is simply over', () {
      final done = today(minutesToday: 60);
      expect(done.allowed, isFalse);
      expect(done.dayIsDone, isTrue);
      expect(done.practisedTodayMinutes, 60);
      // Tomorrow, not in fifteen minutes.
      expect(done.breakUntil, DateTime(2026, 9, 7));
    });

    test('it outranks the stretch: no hour is promised', () {
      // Both caps reached at once. The daily one has to win, because a
      // break would not lift it.
      final done = today(minutesToday: 90, stretchMinutes: 40);
      expect(done.dayIsDone, isTrue);
      expect(done.breakUntil, DateTime(2026, 9, 7));
    });

    test('it works on its own, without a stretch cap', () {
      final done = practiceAllowance(
        limitMinutes: 0,
        breakMinutes: 15,
        practisedMs: 0,
        lastFinishedAt: now.subtract(const Duration(minutes: 1)),
        now: now,
        dailyLimitMinutes: 30,
        practisedTodayMs: 30 * 60000,
      );
      expect(done.allowed, isFalse);
      expect(done.dayIsDone, isTrue);
    });

    test('without either cap nothing is blocked', () {
      final free = practiceAllowance(
        limitMinutes: 0,
        breakMinutes: 15,
        practisedMs: 600 * 60000,
        lastFinishedAt: now,
        now: now,
        dailyLimitMinutes: 0,
        practisedTodayMs: 600 * 60000,
      );
      expect(free.allowed, isTrue);
    });
  });

  test('the offered lengths start with switching it off', () {
    expect(practiceLimitOptions.first, 0);
    expect(practiceLimitOptions, isNot(contains(5)),
        reason: 'a five minute cap would end a run before it starts');
    expect(breakMinuteOptions, isNot(contains(0)));
    expect(dailyLimitOptions.first, 0);
  });

  group('two levels', () {
    test('the defaults are two hours a day and twenty minutes at a stretch',
        () {
      const global = PracticeLimits();
      expect(global.stretchMinutes, 20);
      expect(global.dailyMinutes, 120);
      expect(global.breakMinutes, 15);
      // Both are among the offered values, so a parent can see which one is
      // in force rather than facing an unselected row.
      expect(practiceLimitOptions, contains(global.stretchMinutes));
      expect(dailyLimitOptions, contains(global.dailyMinutes));
      expect(breakMinuteOptions, contains(global.breakMinutes));
    });

    test('null takes the app-wide value, a number overrides it', () {
      const global =
          PracticeLimits(stretchMinutes: 20, breakMinutes: 15, dailyMinutes: 120);

      final inherited = resolvePracticeLimits(global: global);
      expect(inherited.stretchMinutes, 20);
      expect(inherited.dailyMinutes, 120);

      final own = resolvePracticeLimits(
        global: global,
        stretchMinutes: 45,
        dailyMinutes: 60,
      );
      expect(own.stretchMinutes, 45);
      expect(own.dailyMinutes, 60);
      expect(own.breakMinutes, 15, reason: 'not set, so inherited');
    });

    test('zero is a decision, not an absent one', () {
      // The whole reason the columns are nullable: "no limit for this child"
      // and "whatever everyone else has" must not collapse into one value.
      const global = PracticeLimits(stretchMinutes: 20, dailyMinutes: 120);
      final off = resolvePracticeLimits(global: global, stretchMinutes: 0);
      expect(off.stretchMinutes, 0);
      expect(off.dailyMinutes, 120, reason: 'the day is still capped');
    });
  });
}
