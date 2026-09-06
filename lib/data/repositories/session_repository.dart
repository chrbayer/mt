import 'package:drift/drift.dart';

import '../../domain/task.dart';
import '../db/app_database.dart';

/// Writes practice runs. A session row is created up front so an aborted run
/// can be recorded too (with `completed = false`, which excludes it from all
/// statistics); attempts are written in one transaction at the end so nothing
/// touches the disk while the stopwatch is running.
class SessionRepository {
  final AppDatabase _db;

  SessionRepository(this._db);

  Future<int> startSession({
    required int userId,
    required String lessonId,
    required int taskCount,
    required int seed,
  }) =>
      _db.into(_db.sessions).insert(
            SessionsCompanion.insert(
              userId: userId,
              lessonId: lessonId,
              taskCount: taskCount,
              seed: seed,
              startedAtMs: DateTime.now().millisecondsSinceEpoch,
            ),
          );

  Future<void> finishSession({
    required int sessionId,
    required List<TaskResult> results,
    required bool completed,
  }) async {
    final totalMs = results.fold<int>(0, (sum, r) => sum + r.elapsedMs);
    final wrong = results.fold<int>(0, (sum, r) => sum + r.wrongAttempts);

    await _db.transaction(() async {
      await _db.batch((batch) {
        batch.insertAll(_db.attempts, [
          for (var i = 0; i < results.length; i++)
            AttemptsCompanion.insert(
              sessionId: sessionId,
              position: i,
              operandA: results[i].task.a,
              operandB: results[i].task.b,
              op: results[i].task.op.name,
              form: results[i].task.form.name,
              expected: results[i].task.expected,
              elapsedMs: results[i].elapsedMs,
              wrongAttempts: results[i].wrongAttempts,
            ),
        ]);
      });

      await (_db.update(_db.sessions)..where((s) => s.id.equals(sessionId)))
          .write(
        SessionsCompanion(
          finishedAtMs: Value(DateTime.now().millisecondsSinceEpoch),
          totalMs: Value(totalMs),
          wrongAttempts: Value(wrong),
          completed: Value(completed),
          // An abandoned run is stored with the number of tasks actually done,
          // otherwise its per-task averages would be meaningless.
          taskCount: completed ? const Value.absent() : Value(results.length),
        ),
      );
    });
  }

  /// The previous completed run of the same lesson, used on the result screen
  /// for "4 seconds faster than last time".
  Future<Session?> previousCompletedSession({
    required int userId,
    required String lessonId,
    required int excludingSessionId,
  }) =>
      (_db.select(_db.sessions)
            ..where((s) =>
                s.userId.equals(userId) &
                s.lessonId.equals(lessonId) &
                s.completed.equals(true) &
                s.id.equals(excludingSessionId).not())
            ..orderBy([
              (s) => OrderingTerm(
                    expression: s.finishedAtMs,
                    mode: OrderingMode.desc,
                  )
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<Session?> sessionById(int id) =>
      (_db.select(_db.sessions)..where((s) => s.id.equals(id)))
          .getSingleOrNull();
}
