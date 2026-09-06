/// How long a child may practise in one stretch. No Flutter dependency.
library;

/// Break lengths a parent can pick, in minutes.
const breakMinuteOptions = [5, 10, 15, 20, 30, 60];

/// Stretch lengths a parent can pick, in minutes. Zero switches the cap off.
const practiceLimitOptions = [0, 10, 15, 20, 30, 45, 60];

/// Daily totals a parent can pick, in minutes. Zero switches the cap off.
const dailyLimitOptions = [0, 15, 30, 45, 60, 90, 120];

/// What holds when nobody has decided otherwise.
///
/// Deliberately not "no limit": two hours of maths in a day and twenty
/// minutes without getting up are already generous, and a parent who never
/// opens the settings should still get a sensible bedtime for the tablet.
const defaultStretchMinutes = 20;
const defaultBreakMinutes = 15;
const defaultDailyMinutes = 120;

/// The three time limits, as they apply to one child.
class PracticeLimits {
  /// Longest stretch without a break. Zero means no stretch limit.
  final int stretchMinutes;

  /// How long the break has to be, and what separates two stretches.
  final int breakMinutes;

  /// Total for one day. Zero means no daily limit.
  final int dailyMinutes;

  const PracticeLimits({
    this.stretchMinutes = defaultStretchMinutes,
    this.breakMinutes = defaultBreakMinutes,
    this.dailyMinutes = defaultDailyMinutes,
  });
}

/// A child's own limits where they have any, the app-wide ones where not.
///
/// Two levels, like the run length has three: null means "wie für alle",
/// while a stored **zero** is a decision - "this child has no limit". The two
/// have to stay apart, which is why the columns are nullable rather than
/// using zero for both.
PracticeLimits resolvePracticeLimits({
  required PracticeLimits global,
  int? stretchMinutes,
  int? breakMinutes,
  int? dailyMinutes,
}) =>
    PracticeLimits(
      stretchMinutes: stretchMinutes ?? global.stretchMinutes,
      breakMinutes: breakMinutes ?? global.breakMinutes,
      dailyMinutes: dailyMinutes ?? global.dailyMinutes,
    );

/// Whether practice may start right now, and if not, until when.
class PracticeAllowance {
  final bool allowed;

  /// When the break is over. Null whenever practice is allowed.
  final DateTime? breakUntil;

  /// Minutes already practised in the current stretch.
  final int practisedMinutes;

  /// The stretch cap in force, or zero when there is none.
  final int limitMinutes;

  /// Whether it is the daily total that has run out rather than the stretch.
  /// A different message: no break will help, the day is simply over.
  final bool dayIsDone;

  /// Minutes practised today, across all stretches.
  final int practisedTodayMinutes;

  const PracticeAllowance({
    required this.allowed,
    required this.practisedMinutes,
    required this.limitMinutes,
    this.breakUntil,
    this.dayIsDone = false,
    this.practisedTodayMinutes = 0,
  });

  /// No cap set, so nothing to work out.
  static const unlimited = PracticeAllowance(
    allowed: true,
    practisedMinutes: 0,
    limitMinutes: 0,
  );
}

/// Decides whether a new run may start.
///
/// A stretch is the practice since the last real break: [practisedMs] is what
/// the repository already added up for it. Once the break has actually been
/// taken the stretch is over and the count starts again - which is why an
/// elapsed break unlocks practice no matter how long the stretch was.
///
/// A run already under way is never cut short. The cap is a doorway, not a
/// stopwatch: being thrown out mid-task would lose the run and teach a child
/// that the app is not to be trusted.
PracticeAllowance practiceAllowance({
  required int limitMinutes,
  required int breakMinutes,
  required int practisedMs,
  required DateTime? lastFinishedAt,
  required DateTime now,
  int dailyLimitMinutes = 0,
  int practisedTodayMs = 0,
}) {
  final todayMinutes = practisedTodayMs ~/ 60000;

  // The day's total comes first: when it is used up no break will help, and
  // saying "back at 15:20" would be a promise the app cannot keep.
  if (dailyLimitMinutes > 0 && todayMinutes >= dailyLimitMinutes) {
    return PracticeAllowance(
      allowed: false,
      dayIsDone: true,
      breakUntil: DateTime(now.year, now.month, now.day + 1),
      practisedMinutes: practisedMs ~/ 60000,
      practisedTodayMinutes: todayMinutes,
      limitMinutes: limitMinutes,
    );
  }

  if (limitMinutes <= 0) {
    return PracticeAllowance(
      allowed: true,
      practisedMinutes: practisedMs ~/ 60000,
      practisedTodayMinutes: todayMinutes,
      limitMinutes: 0,
    );
  }

  final practisedMinutes = practisedMs ~/ 60000;
  if (lastFinishedAt == null) {
    return PracticeAllowance(
      allowed: true,
      practisedMinutes: practisedMinutes,
      practisedTodayMinutes: todayMinutes,
      limitMinutes: limitMinutes,
    );
  }

  final breakOver = lastFinishedAt.add(Duration(minutes: breakMinutes));
  // The break has been taken - whatever came before it is a closed stretch.
  if (!now.isBefore(breakOver)) {
    return PracticeAllowance(
      allowed: true,
      practisedMinutes: 0,
      practisedTodayMinutes: todayMinutes,
      limitMinutes: limitMinutes,
    );
  }

  if (practisedMinutes >= limitMinutes) {
    return PracticeAllowance(
      allowed: false,
      breakUntil: breakOver,
      practisedMinutes: practisedMinutes,
      practisedTodayMinutes: todayMinutes,
      limitMinutes: limitMinutes,
    );
  }

  return PracticeAllowance(
    allowed: true,
    practisedMinutes: practisedMinutes,
    practisedTodayMinutes: todayMinutes,
    limitMinutes: limitMinutes,
  );
}

/// `noch 7 Minuten`, `noch eine Minute`, `gleich` - for the pause notice.
String formatRemaining(Duration left) {
  final minutes = left.inSeconds <= 0 ? 0 : (left.inSeconds / 60).ceil();
  return switch (minutes) {
    0 => 'gleich',
    1 => 'noch eine Minute',
    _ => 'noch $minutes Minuten',
  };
}
