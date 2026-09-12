import 'package:drift/drift.dart';

import '../../domain/assignment.dart';
import '../db/app_database.dart';

/// The raw columns of one finished run, for one assignment's own lesson and
/// child. Kept separate from [Session]: only the four numbers
/// `domain/assignment.dart` actually scores with, nothing else leaks out of
/// this repository.
class AssignmentRun {
  final int finishedAtMs;
  final int taskCount;
  final int totalMs;
  final int wrongAttempts;

  const AssignmentRun({
    required this.finishedAtMs,
    required this.taskCount,
    required this.totalMs,
    required this.wrongAttempts,
  });

  /// The shape `qualifies` and `progressIn` actually want.
  RunFacts get facts => (
        finishedAtMs: finishedAtMs,
        taskCount: taskCount,
        totalMs: totalMs,
        wrongAttempts: wrongAttempts,
      );
}

/// Assignments: create, end, delete, and read what a child has done towards
/// one.
///
/// Deliberately no scoring in SQL: the row set is bounded to one child and
/// one lesson, small enough that `starsFor`/`boltsFor` can run in Dart
/// without a second copy of what counts as three stars. Everything goes
/// through drift's own query API rather than `customStatement`, so every
/// stream watching it re-runs after a write - the same lesson the stored
/// stars learned the hard way.
class AssignmentRepository {
  final AppDatabase _db;

  AssignmentRepository(this._db);

  /// Assignments for one child, or for everyone when [userId] is null - the
  /// parent tab wants every child's row in one list. [openOnly] leaves out
  /// assignments a parent has already ended.
  Stream<List<Assignment>> watchAssignments({
    int? userId,
    bool openOnly = false,
  }) {
    final query = _db.select(_db.assignments)
      ..where((a) =>
          (userId == null ? const Constant(true) : a.userId.equals(userId)) &
          (openOnly ? a.endedAtMs.isNull() : const Constant(true)))
      ..orderBy([
        (a) => OrderingTerm(expression: a.createdAtMs, mode: OrderingMode.desc)
      ]);
    return query.watch().map(
          (rows) => [for (final row in rows) _fromRow(row)],
        );
  }

  Future<int> createAssignment({
    required int userId,
    required List<String> lessonIds,
    required AssignmentRhythm rhythm,
    required int runs,
    required int taskCount,
    required int minStars,
    required int minBolts,
    bool repeats = true,
    int? onDayMs,
    bool carryOver = false,
  }) =>
      _db.into(_db.assignments).insert(
            AssignmentsCompanion.insert(
              userId: userId,
              lessonIds: lessonIdsToStored(lessonIds),
              rhythm: rhythm.name,
              repeats: Value(repeats),
              onDayMs: Value(onDayMs),
              carryOver: Value(carryOver),
              runs: runs,
              taskCount: taskCount,
              minStars: minStars,
              minBolts: minBolts,
              createdAtMs: DateTime.now().millisecondsSinceEpoch,
            ),
          );

  /// Changes what an assignment asks for. Child and lesson are not among
  /// the arguments on purpose: those two make it a different assignment, and
  /// its statistics would suddenly be about runs that were never assigned.
  ///
  /// Everything here is worked out fresh from the runs whenever it is read,
  /// so raising the bar re-judges the periods already behind it - including
  /// the one running now, whose tick can disappear again. That is what a
  /// parent means by changing the requirement; freezing the old verdict
  /// would leave two different answers standing side by side.
  Future<void> updateAssignment(
    int id, {
    required List<String> lessonIds,
    required AssignmentRhythm rhythm,
    required int runs,
    required int taskCount,
    required int minStars,
    required int minBolts,
    bool repeats = true,
    int? onDayMs,
    bool carryOver = false,
  }) =>
      (_db.update(_db.assignments)..where((a) => a.id.equals(id))).write(
        AssignmentsCompanion(
          lessonIds: Value(lessonIdsToStored(lessonIds)),
          rhythm: Value(rhythm.name),
          repeats: Value(repeats),
          onDayMs: Value(onDayMs),
          carryOver: Value(carryOver),
          runs: Value(runs),
          taskCount: Value(taskCount),
          minStars: Value(minStars),
          minBolts: Value(minBolts),
        ),
      );

  /// Closes an assignment. Its statistics stay exactly as they are - only a
  /// new assignment can change the target from here on.
  Future<void> endAssignment(int id, int nowMs) =>
      (_db.update(_db.assignments)..where((a) => a.id.equals(id)))
          .write(AssignmentsCompanion(endedAtMs: Value(nowMs)));

  Future<void> deleteAssignment(int id) =>
      (_db.delete(_db.assignments)..where((a) => a.id.equals(id))).go();

  /// Completed, non-deleted runs of [a]'s child, for every lesson it names,
  /// finished at or after [sinceMs] - grouped by lesson, because each lesson
  /// of an assignment is measured on its own.
  ///
  /// One query for all of them rather than one per lesson: the row set is
  /// already small, and asking N times would multiply the subscriptions for
  /// nothing. No upper bound either - `qualifies` and `progressIn` know a
  /// period's deadline, and asking once for the whole stretch beats asking
  /// once per period.
  Stream<Map<String, List<AssignmentRun>>> watchRunsFor(
    Assignment a, {
    required int sinceMs,
  }) {
    return (_db.select(_db.sessions)
          ..where((s) =>
              s.userId.equals(a.userId) &
              s.lessonId.isIn(a.lessonIds) &
              s.completed.equals(true) &
              s.deleted.equals(false) &
              s.finishedAtMs.isBiggerOrEqualValue(sinceMs)))
        .watch()
        .map((rows) {
      final byLesson = <String, List<AssignmentRun>>{
        for (final id in a.lessonIds) id: <AssignmentRun>[],
      };
      for (final row in rows) {
        byLesson[row.lessonId]?.add(AssignmentRun(
          // completed = true always carries a finish time.
          finishedAtMs: row.finishedAtMs!,
          taskCount: row.taskCount,
          totalMs: row.totalMs,
          wrongAttempts: row.wrongAttempts,
        ));
      }
      return byLesson;
    });
  }

  Assignment _fromRow(AssignmentRow row) => Assignment(
        id: row.id,
        userId: row.userId,
        lessonIds: lessonIdsByName(row.lessonIds),
        rhythm: rhythmByName(row.rhythm),
        repeats: row.repeats,
        onDayMs: row.onDayMs,
        carryOver: row.carryOver,
        runs: row.runs,
        taskCount: row.taskCount,
        minStars: row.minStars,
        minBolts: row.minBolts,
        createdAtMs: row.createdAtMs,
        endedAtMs: row.endedAtMs,
      );
}
