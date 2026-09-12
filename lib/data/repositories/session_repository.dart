import 'package:drift/drift.dart';

import '../../domain/lesson.dart';
import '../../domain/practice_limit.dart';
import '../../domain/scoring.dart';
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

  /// Stores the finished run.
  ///
  /// [scoredRunLimit] is how many runs of this lesson may still earn
  /// something today; zero means no cap. [dayStartMs] says when that day
  /// began - handed in rather than taken from SQL's `now` for the same reason
  /// the practice caps do it: the app has one clock, and a rule that turns
  /// over at midnight has to be testable at any time of day.
  ///
  /// [servesAssignment] suspends that cap - but only for this one run. It is
  /// true exactly when this lesson has an open assignment whose current
  /// period has not met its goal yet (#24): without this, three failed
  /// attempts at the daily cap could use up the day's scoring slots before
  /// the assignment itself was ever met, locking a child out of their own
  /// goal until tomorrow. It does **not** reopen the cap in general - only
  /// this lesson, and only until the assignment's period is satisfied; the
  /// moment it is, `openAssignmentProvider` turns false again and #16's cap
  /// applies exactly as before.
  Future<void> finishSession({
    required int sessionId,
    required List<TaskResult> results,
    required bool completed,
    int scoredRunLimit = 0,
    int dayStartMs = 0,
    bool servesAssignment = false,
  }) async {
    final totalMs = results.fold<int>(0, (sum, r) => sum + r.elapsedMs);
    final wrong = results.fold<int>(0, (sum, r) => sum + r.wrongAttempts);

    // A lesson this version no longer knows is treated as measured: the cap
    // is the cautious answer when the catalogue cannot say.
    final session = await sessionById(sessionId);
    final lessonIsScored =
        lessonByIdOrNull(session?.lessonId ?? '')?.scored ?? true;

    // An abandoned run never counted anyway, so it neither earns nor uses up
    // one of the day's scoring slots. The first steps are exempt from the
    // cap altogether - see runStillCounts.
    final scored = completed &&
        (servesAssignment ||
            !lessonIsScored ||
            runStillCounts(
              limit: scoredRunLimit,
              scoredToday: await _scoredToday(sessionId, dayStartMs),
              lessonIsScored: lessonIsScored,
            ));

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
              operandC: Value(results[i].task.c),
              op2: Value(results[i].task.op2?.name),
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
          scored: Value(scored),
          // An abandoned run is stored with the number of tasks actually done,
          // otherwise its per-task averages would be meaningless.
          taskCount: completed ? const Value.absent() : Value(results.length),
        ),
      );

      if (scored) await _awardStars(sessionId, wrong, results.length);
    });
  }

  /// How many runs of this session's lesson already counted today, for this
  /// child. The session being finished is excluded - it has not been marked
  /// yet, and counting itself would make the cap one too small.
  Future<int> _scoredToday(int sessionId, int dayStartMs) async {
    final session = await sessionById(sessionId);
    if (session == null) return 0;
    final rows = await (_db.select(_db.sessions)
          ..where((s) =>
              s.userId.equals(session.userId) &
              s.lessonId.equals(session.lessonId) &
              s.completed.equals(true) &
              s.scored.equals(true) &
              s.deleted.equals(false) &
              s.id.equals(sessionId).not() &
              s.finishedAtMs.isBiggerOrEqualValue(dayStartMs)))
        .get();
    return rows.length;
  }

  /// Writes down what this run was worth, keeping the best.
  ///
  /// The stars used to be worked out from the runs whenever they were needed.
  /// Since a parent can hand them back without touching the times, the two
  /// can differ, and only a stored value can say what was actually earned.
  ///
  /// Only ever upwards: a bad run after a good one takes nothing away.
  Future<void> _awardStars(int sessionId, int wrong, int taskCount) async {
    final session = await sessionById(sessionId);
    if (session == null) return;
    final lesson = lessonByIdOrNull(session.lessonId);
    // A run of a lesson this version does not know cannot be scored, and
    // guessing would be worse than leaving it alone.
    if (lesson == null) return;

    final earned = starsFor(wrong, taskCount, scored: lesson.scored);
    if (earned <= 0) return;

    // Through drift's own API rather than raw SQL: a customStatement does not
    // tell drift which table it touched, so every watching stream would keep
    // showing the old total until something else happened to invalidate it.
    final held = await (_db.select(_db.lessonStars)
          ..where((row) =>
              row.userId.equals(session.userId) &
              row.lessonId.equals(session.lessonId)))
        .getSingleOrNull();
    if (held != null && held.stars >= earned) return;

    await _db.into(_db.lessonStars).insertOnConflictUpdate(
          LessonStarsCompanion.insert(
            userId: session.userId,
            lessonId: session.lessonId,
            stars: earned,
          ),
        );
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
