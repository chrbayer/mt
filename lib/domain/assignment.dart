/// A parent-set goal for one child and one lesson: practise it on a
/// rhythm, to a minimum length, stars and bolts. No Flutter dependency.
library;

import 'lesson.dart';
import 'scoring.dart';

/// How often the goal renews, and that is the whole deadline: a day, or a
/// week that ends on Sunday night.
///
/// Deliberately no time of day. A child does not watch the clock, and "noch
/// bis 18:00" on a card is pressure without a purpose - what a parent
/// actually means is "heute" or "diese Woche". It also makes the deadline
/// and the end of the period the same instant, so a period is closed exactly
/// when it is over.
enum AssignmentRhythm { daily, weekly }

/// Reads a stored rhythm name back. An unknown name - a downgrade, or a
/// corrupted row - falls back to daily: the closer deadline is the safer
/// misreading, since it can never let a whole week go by unnoticed.
AssignmentRhythm rhythmByName(String name) {
  for (final rhythm in AssignmentRhythm.values) {
    if (rhythm.name == name) return rhythm;
  }
  return AssignmentRhythm.daily;
}

/// What a parent has set up. Mirrors the database row; only [id] is ever
/// looked up again, the rest is read straight off this class.
///
/// Never changed once created - only ended and replaced. "Geschafft an 12
/// von 15 Tagen" is only true as long as the target itself never moved, so
/// changing a requirement means ending this assignment and creating a new
/// one, each with its own statistics.
class Assignment {
  final int id;
  final int userId;
  final String lessonId;
  final AssignmentRhythm rhythm;

  /// How many qualifying runs the period needs.
  final int runs;

  /// How many tasks a run needs at least to qualify. A longer run is more
  /// work, not less, so this is a floor, not an exact count.
  final int taskCount;

  /// Minimum stars a run needs to qualify. Zero means no requirement.
  final int minStars;

  /// Minimum bolts a run needs to qualify. Zero means no requirement.
  final int minBolts;

  final int createdAtMs;

  /// When a parent ended this assignment. Null while it is still running.
  final int? endedAtMs;

  const Assignment({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.rhythm,
    required this.runs,
    required this.taskCount,
    required this.minStars,
    required this.minBolts,
    required this.createdAtMs,
    this.endedAtMs,
  });

  bool get isOpen => endedAtMs == null;

  /// Value equality, because this class is used as a Riverpod family key.
  /// Without it, every re-emission of the assignment list would hand out
  /// fresh objects, every one of them a *new* key - and a family provider
  /// keyed anew opens another database subscription while the old one is
  /// kept alive. Two rows with the same contents are the same assignment.
  @override
  bool operator ==(Object other) =>
      other is Assignment &&
      other.id == id &&
      other.userId == userId &&
      other.lessonId == lessonId &&
      other.rhythm == rhythm &&
      other.runs == runs &&
      other.taskCount == taskCount &&
      other.minStars == minStars &&
      other.minBolts == minBolts &&
      other.createdAtMs == createdAtMs &&
      other.endedAtMs == endedAtMs;

  @override
  int get hashCode => Object.hash(id, userId, lessonId, rhythm, runs,
      taskCount, minStars, minBolts, createdAtMs, endedAtMs);
}

/// One rhythm period with its own deadline: one calendar day for
/// [AssignmentRhythm.daily], one calendar week (Monday to Sunday) for
/// [AssignmentRhythm.weekly].
class AssignmentPeriod {
  final int startMs;
  final int dueMs;

  const AssignmentPeriod({required this.startMs, required this.dueMs});
}

/// The period [now] falls into. Its deadline is its own last instant: the
/// calendar day for [AssignmentRhythm.daily], the calendar week from Monday
/// to Sunday night for [AssignmentRhythm.weekly].
///
/// Built with `DateTime(year, month, day)` rather than by adding
/// milliseconds, so the boundaries stay on real local midnights across a
/// daylight-saving change.
AssignmentPeriod periodAt(Assignment a, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final (start, nextStart) = switch (a.rhythm) {
    AssignmentRhythm.daily => (
        today,
        DateTime(today.year, today.month, today.day + 1),
      ),
    // DateTime.weekday runs 1 (Monday) .. 7 (Sunday), so this always lands
    // on this week's Monday, even when today already is one.
    AssignmentRhythm.weekly => () {
        final monday =
            DateTime(today.year, today.month, today.day - (today.weekday - 1));
        return (
          monday,
          DateTime(monday.year, monday.month, monday.day + 7),
        );
      }(),
  };
  return AssignmentPeriod(
    startMs: start.millisecondsSinceEpoch,
    // The last millisecond that still belongs to this period: a run finished
    // at the stroke of midnight belongs to the next one, not this one.
    dueMs: nextStart.millisecondsSinceEpoch - 1,
  );
}

/// The raw facts of one completed run that [qualifies] and [progressIn]
/// need. Deliberately a record and not a database row: the domain layer
/// takes no Flutter or drift import, and four numbers are all this needs.
typedef RunFacts = ({
  int finishedAtMs,
  int taskCount,
  int totalMs,
  int wrongAttempts,
});

/// Every period that is over and that fell within this assignment's
/// lifetime: created before the period ended, and - if the assignment has
/// since ended - over before it ended.
///
/// Since the deadline *is* the end of the period, "closed" and "missed its
/// deadline" are now the same question. Under an hour-of-day deadline they
/// were not, and a day whose time had passed still counted as running.
///
/// Oldest first. Bounded by [Assignment.createdAtMs] on one end and by
/// walking backward from [now] on the other, with a generous but finite
/// safety valve: an assignment lives for weeks or months, never for an
/// unbroken decade.
List<AssignmentPeriod> closedPeriods(Assignment a, DateTime now) {
  final step = a.rhythm == AssignmentRhythm.daily
      ? const Duration(days: 1)
      : const Duration(days: 7);

  final periods = <AssignmentPeriod>[];
  var probe = now.subtract(step);
  for (var i = 0; i < 3650; i++) {
    final period = periodAt(a, probe);
    if (period.dueMs < a.createdAtMs) break;
    final endedAt = a.endedAtMs;
    // A period whose deadline falls after the assignment ended never
    // belonged to it - skip it, but keep walking further back: earlier
    // periods, from while it was still running, still count.
    if (endedAt == null || period.dueMs <= endedAt) {
      periods.add(period);
    }
    probe = probe.subtract(step);
  }
  return periods.reversed.toList();
}

/// Whether one already-finished run satisfies an assignment's requirements.
///
/// At least, never exactly: a longer run is more work, and a run that beats
/// every minimum comfortably still counts.
bool qualifies({
  required Assignment a,
  required LessonSpec lesson,
  required RunFacts run,
  required int dueMs,
}) {
  if (run.finishedAtMs > dueMs) return false;
  if (run.taskCount < a.taskCount) return false;

  final stars =
      starsFor(run.wrongAttempts, run.taskCount, scored: lesson.scored);
  if (stars < a.minStars) return false;

  final scoreMs =
      scoreMsPerTask(run.totalMs, run.wrongAttempts, run.taskCount);
  final bolts = boltsFor(lesson.targetMsPerTask, scoreMs, run.taskCount);
  if (bolts < a.minBolts) return false;

  return true;
}

/// How many of [runs] qualify within [period], and whether that reaches
/// [Assignment.runs].
class AssignmentProgress {
  final int qualifyingRuns;
  final bool met;

  const AssignmentProgress({required this.qualifyingRuns, required this.met});
}

AssignmentProgress progressIn({
  required Assignment a,
  required LessonSpec lesson,
  required AssignmentPeriod period,
  required List<RunFacts> runs,
}) {
  final qualifying = runs.where((run) {
    if (run.finishedAtMs < period.startMs) return false;
    return qualifies(a: a, lesson: lesson, run: run, dueMs: period.dueMs);
  }).length;
  return AssignmentProgress(
    qualifyingRuns: qualifying,
    met: qualifying >= a.runs,
  );
}

/// The deadline as a child reads it: "heute" or "bis Sonntag".
///
/// This is also what tells the two rhythms apart on a card, so it is the one
/// place the wording lives - the card and the parent tab must never say it
/// two different ways.
String formatDeadline(Assignment a) =>
    a.rhythm == AssignmentRhythm.daily ? 'heute' : 'bis Sonntag';
