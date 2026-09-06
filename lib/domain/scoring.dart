/// Scoring and formatting of finished sessions. No Flutter dependency.
library;

/// Time added to the score for every wrong attempt. Without a penalty a child
/// could win a leaderboard by hammering the check button and guessing.
const int wrongAttemptPenaltyMs = 3000;

/// Minimum number of tasks a run must have to be worth anything: no stars,
/// no bolts and no place in a leaderboard below this.
///
/// Five quick tasks are a warm-up, not a result, and without a floor the
/// shortest run would be the cheapest way to a full set of stars. The first
/// steps are exempt - there the achievement is getting through at all, and
/// five is a perfectly good length.
const int minTasksForAward = 10;

/// Total time plus the penalty for all wrong attempts.
int penalizedTimeMs(int totalMs, int wrongAttempts) =>
    totalMs + wrongAttemptPenaltyMs * wrongAttempts;

/// **The** time metric of the app: penalised time normalised per task, so runs
/// of 10 and 50 tasks are comparable.
///
/// There is deliberately no penalty-free counterpart. Showing a raw average
/// next to this one made the result screen and the leaderboard disagree, and
/// no amount of explaining fixed that. The raw time and the error count stay
/// in the database, so the parent area can still take them apart.
double scoreMsPerTask(int totalMs, int wrongAttempts, int taskCount) {
  if (taskCount <= 0) return 0;
  return penalizedTimeMs(totalMs, wrongAttempts) / taskCount;
}

/// Wrong attempts per task, e.g. 0.2 means every fifth task needed a retry.
double errorRate(int wrongAttempts, int taskCount) {
  if (taskCount <= 0) return 0;
  return wrongAttempts / taskCount;
}

/// Most stars a single run can earn.
const int maxStars = 3;

/// Error rate up to which a run is worth three stars, and two.
///
/// Kept here rather than inline because the statistics repository has to
/// express the same rule in SQL - two copies of "what counts as three stars"
/// would drift apart.
const double threeStarErrorRate = 0.05;
const double twoStarErrorRate = 0.25;

/// One to three stars. Deliberately never zero - the goal is encouragement.
///
/// [scored] false means one of the first steps: those earn their stars for
/// being finished, however long they were and however often the child had to
/// try again.
int starsFor(int wrongAttempts, int taskCount, {required bool scored}) {
  if (!scored) return maxStars;
  if (taskCount < minTasksForAward) return 0;
  final rate = errorRate(wrongAttempts, taskCount);
  if (rate <= threeStarErrorRate) return maxStars;
  if (rate <= twoStarErrorRate) return 2;
  return 1;
}

/// Most lightning bolts a single run can earn.
const int maxBolts = 3;

/// How much slower than the lesson's target still earns two bolts, and one.
///
/// Kept here next to the star thresholds because the statistics repository
/// expresses the same rule in SQL - two copies of "what counts as three
/// bolts" would drift apart.
const double twoBoltFactor = 1.5;
const double oneBoltFactor = 2.2;

/// Zero to three bolts for a run, from its scored time per task.
///
/// Stars are for care and never fall below one; bolts are for speed and do
/// start at zero. An empty row of bolts is not a rebuke, it is the thing
/// that is still to be had - and without a floor, "one bolt" would mean
/// nothing at all.
///
/// [targetMs] is the lesson's own three-bolt time; zero means the lesson is
/// not timed, and then there are no bolts to give. A run too short to count
/// earns none either - a sprint over five tasks is not a fast pace.
int boltsFor(int targetMs, double scoreMsPerTask, int taskCount) {
  if (targetMs <= 0 || taskCount < minTasksForAward) return 0;
  if (scoreMsPerTask <= targetMs) return maxBolts;
  if (scoreMsPerTask <= targetMs * twoBoltFactor) return 2;
  if (scoreMsPerTask <= targetMs * oneBoltFactor) return 1;
  return 0;
}

/// The time per task the next bolt needs, or null once all three are in.
double? nextBoltTargetMs(int targetMs, int bolts) {
  if (targetMs <= 0 || bolts >= maxBolts) return null;
  return switch (bolts) {
    2 => targetMs.toDouble(),
    1 => targetMs * twoBoltFactor,
    _ => targetMs * oneBoltFactor,
  };
}

/// `m:ss` for a minute or more, otherwise `s,d s` - short and readable for
/// children.
String formatDuration(int milliseconds) {
  final totalSeconds = milliseconds / 1000;
  if (totalSeconds < 60) {
    return '${totalSeconds.toStringAsFixed(1).replaceAll('.', ',')} s';
  }
  final minutes = milliseconds ~/ 60000;
  final seconds = (milliseconds % 60000) ~/ 1000;
  return '$minutes:${seconds.toString().padLeft(2, '0')} min';
}

/// Compact per-task time, always in seconds with one decimal.
String formatPerTask(double milliseconds) =>
    '${(milliseconds / 1000).toStringAsFixed(1).replaceAll('.', ',')} s';

/// Summed practice time over many runs: `3 h 12 min`, `42 min`, `0 min`.
String formatTotalTime(int milliseconds) {
  final minutes = milliseconds ~/ 60000;
  if (minutes < 60) return '$minutes min';
  return '${minutes ~/ 60} h ${minutes % 60} min';
}

/// `5.9. · 14:32` - short enough for a list, unambiguous within a school year.
String formatDayAndTime(DateTime at) {
  final hour = at.hour.toString().padLeft(2, '0');
  final minute = at.minute.toString().padLeft(2, '0');
  return '${at.day}.${at.month}. · $hour:$minute';
}

/// `heute`, `gestern`, `vor 3 Tagen`, otherwise the date. Used for "last
/// active", where the exact minute does not matter.
String formatRelativeDay(DateTime at, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final days = DateTime(today.year, today.month, today.day)
      .difference(DateTime(at.year, at.month, at.day))
      .inDays;
  return switch (days) {
    0 => 'heute',
    1 => 'gestern',
    < 7 => 'vor $days Tagen',
    _ => '${at.day}.${at.month}.${at.year}',
  };
}
