/// A parent-set goal for one child and one lesson: practise it on a
/// rhythm, to a minimum length, stars and bolts. No Flutter dependency.
library;

import 'lesson.dart';
import 'scoring.dart';

/// What one period of an assignment is: a day, or a week ending Sunday
/// night. **The unit, not the repetition** - whether it renews at all is
/// [Assignment.repeats].
///
/// The two were one field until a parent wanted "heute das, morgen jenes":
/// a plan is a row of single assignments, and squeezing that into a list of
/// rhythms would have grown a value for every new idea.
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

  /// The lessons this assignment covers, in catalogue order.
  ///
  /// Every one of them has to be practised to the bar, [runs] times, inside
  /// a period - the assignment is done when all of them are. For the child
  /// that changes nothing: each lesson is its own card, exactly as it was
  /// when an assignment could only name one.
  final List<String> lessonIds;

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

  /// Whether the goal renews every period, or is a single one.
  ///
  /// A repeating assignment is a standing rule ("jeden Tag Einmaleins"); a
  /// single one belongs to one named day or week, and several of them side
  /// by side are a plan.
  final bool repeats;

  /// For a single assignment: any instant inside the day or week it belongs
  /// to. Null for a repeating one, where the period is always the current.
  final int? onDayMs;

  /// Whether an unfinished single assignment stays on the child's screen
  /// after its day is over.
  ///
  /// Only ever offered for single ones. A repeating assignment brings a
  /// fresh one tomorrow anyway, and carrying those over would turn two
  /// weeks of holiday into fourteen cards and a debt nobody catches up on.
  final bool carryOver;

  /// When a parent ended this assignment. Null while it is still running.
  final int? endedAtMs;

  const Assignment({
    required this.id,
    required this.userId,
    required this.lessonIds,
    required this.rhythm,
    required this.runs,
    required this.taskCount,
    required this.minStars,
    required this.minBolts,
    required this.createdAtMs,
    this.repeats = true,
    this.onDayMs,
    this.carryOver = false,
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
      _sameLessons(other.lessonIds, lessonIds) &&
      other.rhythm == rhythm &&
      other.runs == runs &&
      other.taskCount == taskCount &&
      other.minStars == minStars &&
      other.minBolts == minBolts &&
      other.createdAtMs == createdAtMs &&
      other.repeats == repeats &&
      other.onDayMs == onDayMs &&
      other.carryOver == carryOver &&
      other.endedAtMs == endedAtMs;

  @override
  int get hashCode => Object.hash(id, userId, Object.hashAll(lessonIds),
      rhythm, runs, taskCount, minStars, minBolts, createdAtMs, repeats,
      onDayMs, carryOver, endedAtMs);

  static bool _sameLessons(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Reads the stored list of lesson ids. Ids the catalogue no longer has are
/// skipped, the same caution every stored name gets - a backup from a newer
/// version must not take the whole assignment down with it.
List<String> lessonIdsByName(String stored) => [
      for (final lesson in lessonCatalog)
        if (stored.split(',').contains(lesson.id)) lesson.id,
    ];

/// Writes them back, always in catalogue order so two equal assignments
/// compare equal and the stored string is stable.
String lessonIdsToStored(Iterable<String> ids) {
  final wanted = ids.toSet();
  return [
    for (final lesson in lessonCatalog)
      if (wanted.contains(lesson.id)) lesson.id,
  ].join(',');
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
  // A single assignment always names the same period, whatever day it is
  // looked at on. That is the whole difference between a plan and a rule.
  final at = a.repeats
      ? now
      : DateTime.fromMillisecondsSinceEpoch(a.onDayMs ?? a.createdAtMs);
  final today = DateTime(at.year, at.month, at.day);
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

/// Whether [now] still falls inside the assignment's own period.
///
/// Always true for a repeating one - its period is wherever now is.
bool withinPeriod(Assignment a, DateTime now) {
  if (a.repeats) return true;
  final period = periodAt(a, now);
  final ms = now.millisecondsSinceEpoch;
  return ms >= period.startMs && ms <= period.dueMs;
}

/// Whether the child should still be shown this assignment.
///
/// A repeating one, always. A single one while its day or week is running -
/// and past it only when it is carried over and still unfinished. [met] is
/// handed in rather than worked out here: the domain layer never reaches for
/// the runs on its own.
bool stillShown(Assignment a, DateTime now, {required bool met}) {
  if (a.repeats) return true;
  if (withinPeriod(a, now)) return true;
  return a.carryOver && !met;
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
  // A single assignment has exactly one period, and it counts once it is
  // over. Making it up afterwards finishes the assignment but does not
  // change what happened on the day - the record is about days, not
  // intentions.
  if (!a.repeats) {
    final period = periodAt(a, now);
    final overdue = now.millisecondsSinceEpoch > period.dueMs;
    return overdue && period.dueMs >= a.createdAtMs ? [period] : const [];
  }

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
/// [Assignment.runs]. Held per lesson: an assignment is done when every
/// lesson it names is.
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

/// The same for every lesson the assignment names, keyed by lesson id.
///
/// [runsByLesson] holds only the runs of that lesson; a lesson the catalogue
/// no longer knows is left out rather than guessed at.
Map<String, AssignmentProgress> progressByLesson({
  required Assignment a,
  required AssignmentPeriod period,
  required Map<String, List<RunFacts>> runsByLesson,
}) =>
    {
      for (final id in a.lessonIds)
        if (lessonByIdOrNull(id) case final lesson?)
          id: progressIn(
            a: a,
            lesson: lesson,
            period: period,
            runs: runsByLesson[id] ?? const [],
          ),
    };

/// Whether every lesson of the assignment has had its say.
///
/// Empty counts as not done: an assignment without a single lesson left in
/// the catalogue has nothing to show for itself, and calling that "geschafft"
/// would be a green tick for nothing.
bool allLessonsMet(Map<String, AssignmentProgress> byLesson) =>
    byLesson.isNotEmpty && byLesson.values.every((p) => p.met);

/// The deadline as a child reads it.
///
/// A repeating one says "heute" or "bis Sonntag". A single one says which
/// day or week it belongs to, and says so plainly when that is behind us -
/// a card that still claimed "heute" the morning after would be a lie.
///
/// This is also what tells the two rhythms apart on a card, so it is the one
/// place the wording lives - the card and the parent tab must never say it
/// two different ways.
String formatDeadline(Assignment a, {DateTime? now}) {
  if (a.repeats) {
    return a.rhythm == AssignmentRhythm.daily ? 'heute' : 'bis Sonntag';
  }
  final today = now ?? DateTime.now();
  final period = periodAt(a, today);
  final day = DateTime.fromMillisecondsSinceEpoch(period.startMs);
  if (today.millisecondsSinceEpoch > period.dueMs) {
    // "Noch offen" only where it really is: a carried-over one is still to
    // be done, one without is simply over, and saying otherwise would ask a
    // parent to act on something that cannot be acted on any more.
    return a.carryOver ? 'noch offen' : 'war ${_short(day)}';
  }
  if (a.rhythm == AssignmentRhythm.weekly) {
    return withinPeriod(a, today) ? 'diese Woche' : 'ab ${_short(day)}';
  }
  final sameDay = DateTime(today.year, today.month, today.day) == day;
  return sameDay ? 'heute' : 'am ${_short(day)}';
}

/// `Do, 18.9.` - short enough for a card's footer.
String _short(DateTime day) {
  const names = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
  return '${names[day.weekday - 1]}, ${day.day}.${day.month}.';
}
