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
    required String lessonId,
    required AssignmentRhythm rhythm,
    required int runs,
    required int taskCount,
    required int minStars,
    required int minBolts,
  }) =>
      _db.into(_db.assignments).insert(
            AssignmentsCompanion.insert(
              userId: userId,
              lessonId: lessonId,
              rhythm: rhythm.name,
              runs: runs,
              taskCount: taskCount,
              minStars: minStars,
              minBolts: minBolts,
              createdAtMs: DateTime.now().millisecondsSinceEpoch,
            ),
          );

  /// Closes an assignment. Its statistics stay exactly as they are - only a
  /// new assignment can change the target from here on.
  Future<void> endAssignment(int id, int nowMs) =>
      (_db.update(_db.assignments)..where((a) => a.id.equals(id)))
          .write(AssignmentsCompanion(endedAtMs: Value(nowMs)));

  Future<void> deleteAssignment(int id) =>
      (_db.delete(_db.assignments)..where((a) => a.id.equals(id))).go();

  /// Completed, non-deleted runs of [a]'s child and lesson, finished at or
  /// after [sinceMs]. No upper bound - `qualifies` and `progressIn` already
  /// know a period's deadline, and asking once for the whole stretch beats
  /// asking once per period.
  Stream<List<AssignmentRun>> watchRunsFor(
    Assignment a, {
    required int sinceMs,
  }) {
    return (_db.select(_db.sessions)
          ..where((s) =>
              s.userId.equals(a.userId) &
              s.lessonId.equals(a.lessonId) &
              s.completed.equals(true) &
              s.deleted.equals(false) &
              s.finishedAtMs.isBiggerOrEqualValue(sinceMs)))
        .watch()
        .map((rows) => [
              for (final row in rows)
                AssignmentRun(
                  // completed = true always carries a finish time.
                  finishedAtMs: row.finishedAtMs!,
                  taskCount: row.taskCount,
                  totalMs: row.totalMs,
                  wrongAttempts: row.wrongAttempts,
                ),
            ]);
  }

  Assignment _fromRow(AssignmentRow row) => Assignment(
        id: row.id,
        userId: row.userId,
        lessonId: row.lessonId,
        rhythm: rhythmByName(row.rhythm),
        runs: row.runs,
        taskCount: row.taskCount,
        minStars: row.minStars,
        minBolts: row.minBolts,
        createdAtMs: row.createdAtMs,
        endedAtMs: row.endedAtMs,
      );
}
