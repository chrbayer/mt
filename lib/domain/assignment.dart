/// A parent-set goal for one child and one lesson: practise it on a
/// rhythm, to a minimum length, stars and bolts. No Flutter dependency.
library;

import 'lesson.dart';
import 'scoring.dart';

/// How often the goal renews. Daily runs to a time of day, weekly to a
/// weekday and a time of day.
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

  /// Minutes since midnight the goal is due by.
  final int dueMinute;

  /// [DateTime.monday]..[DateTime.sunday]. Only meaningful for
  /// [AssignmentRhythm.weekly].
  final int dueWeekday;

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
    required this.dueMinute,
    required this.dueWeekday,
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
      other.dueMinute == dueMinute &&
      other.dueWeekday == dueWeekday &&
      other.runs == runs &&
      other.taskCount == taskCount &&
      other.minStars == minStars &&
      other.minBolts == minBolts &&
      other.createdAtMs == createdAtMs &&
      other.endedAtMs == endedAtMs;

  @override
  int get hashCode => Object.hash(id, userId, lessonId, rhythm, dueMinute,
      dueWeekday, runs, taskCount, minStars, minBolts, createdAtMs, endedAtMs);
}

/// One rhythm period with its own deadline: one calendar day for
/// [AssignmentRhythm.daily], one calendar week (Monday to Sunday) for
/// [AssignmentRhythm.weekly].
class AssignmentPeriod {
  final int startMs;
  final int dueMs;

  const AssignmentPeriod({required this.startMs, required this.dueMs});
}

/// The period [now] falls into, and the deadline within it.
///
/// Daily: the calendar day, due at [Assignment.dueMinute] on that same day.
/// Weekly: the calendar week starting Monday 00:00, due at
/// [Assignment.dueMinute] on [Assignment.dueWeekday] of that week.
AssignmentPeriod periodAt(Assignment a, DateTime now) {
  switch (a.rhythm) {
    case AssignmentRhythm.daily:
      final day = DateTime(now.year, now.month, now.day);
      return AssignmentPeriod(
        startMs: day.millisecondsSinceEpoch,
        dueMs:
            day.add(Duration(minutes: a.dueMinute)).millisecondsSinceEpoch,
      );
    case AssignmentRhythm.weekly:
      final today = DateTime(now.year, now.month, now.day);
      // DateTime.weekday is 1 (Monday) .. 7 (Sunday), so this always lands
      // on this week's Monday, even when today already is one.
      final monday = today.subtract(Duration(days: today.weekday - 1));
      final due = monday
          .add(Duration(days: a.dueWeekday - 1))
          .add(Duration(minutes: a.dueMinute));
      return AssignmentPeriod(
        startMs: monday.millisecondsSinceEpoch,
        dueMs: due.millisecondsSinceEpoch,
      );
  }
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

/// Every period whose deadline has already passed and that fell within this
/// assignment's lifetime: created before its due time, and - if the
/// assignment has since ended - due before it ended.
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

const List<String> _weekdayShortNames = [
  'Mo',
  'Di',
  'Mi',
  'Do',
  'Fr',
  'Sa',
  'So',
];

/// "bis 18:00" for a daily assignment, "bis So" for a weekly one - short
/// enough for a card's footer, and closer to how a child reads a deadline
/// than a full date would be. Shared by the child's card and the parent
/// tab, so the two never say it two different ways.
String formatDueTime(Assignment a) {
  final hour = (a.dueMinute ~/ 60).toString().padLeft(2, '0');
  final minute = (a.dueMinute % 60).toString().padLeft(2, '0');
  if (a.rhythm == AssignmentRhythm.daily) return 'bis $hour:$minute';
  return 'bis ${_weekdayShortNames[a.dueWeekday - 1]}';
}
