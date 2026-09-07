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

  /// The daily cap in force, or zero when there is none.
  final int dailyLimitMinutes;

  const PracticeAllowance({
    required this.allowed,
    required this.practisedMinutes,
    required this.limitMinutes,
    this.breakUntil,
    this.dayIsDone = false,
    this.practisedTodayMinutes = 0,
    this.dailyLimitMinutes = 0,
  });

  /// Minutes of practice left before the next break, or null when nothing
  /// caps this child.
  ///
  /// Whichever runs out first: a stretch may have twenty minutes left while
  /// the day has five. Naming the more generous of the two would be a
  /// promise that breaks five minutes later.
  int? get remainingMinutes {
    final left = <int>[
      if (limitMinutes > 0) limitMinutes - practisedMinutes,
      if (dailyLimitMinutes > 0) dailyLimitMinutes - practisedTodayMinutes,
    ];
    if (left.isEmpty) return null;
    final least = left.reduce((a, b) => a < b ? a : b);
    return least < 0 ? 0 : least;
  }

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
      dailyLimitMinutes: dailyLimitMinutes,
    );
  }

  if (limitMinutes <= 0) {
    return PracticeAllowance(
      allowed: true,
      practisedMinutes: practisedMs ~/ 60000,
      practisedTodayMinutes: todayMinutes,
      limitMinutes: 0,
      dailyLimitMinutes: dailyLimitMinutes,
    );
  }

  final practisedMinutes = practisedMs ~/ 60000;
  if (lastFinishedAt == null) {
    return PracticeAllowance(
      allowed: true,
      practisedMinutes: practisedMinutes,
      practisedTodayMinutes: todayMinutes,
      limitMinutes: limitMinutes,
      dailyLimitMinutes: dailyLimitMinutes,
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
      dailyLimitMinutes: dailyLimitMinutes,
    );
  }

  if (practisedMinutes >= limitMinutes) {
    return PracticeAllowance(
      allowed: false,
      breakUntil: breakOver,
      practisedMinutes: practisedMinutes,
      practisedTodayMinutes: todayMinutes,
      limitMinutes: limitMinutes,
      dailyLimitMinutes: dailyLimitMinutes,
    );
  }

  return PracticeAllowance(
    allowed: true,
    practisedMinutes: practisedMinutes,
    practisedTodayMinutes: todayMinutes,
    limitMinutes: limitMinutes,
    dailyLimitMinutes: dailyLimitMinutes,
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

/// How many runs of one lesson may count for awards on one day.
///
/// The point is not to stop a child practising - repetition is the whole
/// idea - but to take away the reason for grinding the easiest lesson over
/// and over: a better time, or three stars forced out of a lesson by sheer
/// repetition. Beyond the cap a run is still practice, still logged, still
/// counted against the day's time; it just does not set a record.
///
/// Zero means no cap.
const scoredRunOptions = [0, 1, 2, 3, 5, 10];

/// What holds when nobody has decided otherwise. Three is enough to have a
/// bad round and try again, and few enough that a fourth attempt is clearly
/// about the leaderboard rather than about the maths.
const defaultScoredRunsPerLesson = 3;

/// A child's own cap where they have one, the app-wide one where not - the
/// same two levels as the times, and the same reason for nullability.
int resolveScoredRuns({required int global, int? scoredRuns}) =>
    scoredRuns ?? global;

/// Whether a run that is finishing now still counts, given how many scored
/// runs of the same lesson the child already has today.
///
/// [limit] of zero means no cap at all.
bool runStillCounts({required int limit, required int scoredToday}) =>
    limit <= 0 || scoredToday < limit;
