import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/data/repositories/session_repository.dart';
import 'package:mathe_trainer/data/repositories/stats_repository.dart';
import 'package:mathe_trainer/data/repositories/user_repository.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/practice_limit.dart';
import 'package:mathe_trainer/domain/task.dart';

/// The daily cap on scored runs: repeating the easiest lesson must stop
/// paying, without stopping the child from practising it.
void main() {
  late AppDatabase db;
  late SessionRepository sessions;
  late StatsRepository stats;
  late int mia;

  const lesson = 'add_100_plain';

  /// Midnight today, the same boundary the app uses.
  int dayStart([DateTime? at]) {
    final now = at ?? DateTime.now();
    return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    sessions = SessionRepository(db);
    stats = StatsRepository(db);
    mia = await UserRepository(db)
        .createUser(name: 'Mia', avatar: 'M', colorIndex: 0);
  });
  tearDown(() => db.close());

  /// One run of [lesson] at [msPerTask], stored under a cap of [limit].
  Future<int> run({
    required int msPerTask,
    int limit = 3,
    int wrong = 0,
    int taskCount = 10,
    String lessonId = lesson,
  }) async {
    final id = await sessions.startSession(
      userId: mia,
      lessonId: lessonId,
      taskCount: taskCount,
      seed: 1,
    );
    await sessions.finishSession(
      sessionId: id,
      completed: true,
      scoredRunLimit: limit,
      dayStartMs: dayStart(),
      results: [
        for (var i = 0; i < taskCount; i++)
          TaskResult(
            task: const Task(a: 42, b: 35, op: Operation.add, form: TaskForm.result),
            elapsedMs: msPerTask,
            wrongAttempts: wrong,
          ),
      ],
    );
    return id;
  }

  Future<bool> scored(int sessionId) async =>
      (await sessions.sessionById(sessionId))!.scored;

  test('the first runs count, the ones past the cap do not', () async {
    expect(await scored(await run(msPerTask: 9000)), isTrue);
    expect(await scored(await run(msPerTask: 9000)), isTrue);
    expect(await scored(await run(msPerTask: 9000)), isTrue);
    expect(await scored(await run(msPerTask: 9000)), isFalse);
    expect(await scored(await run(msPerTask: 9000)), isFalse);
  });

  test('a faster fourth run does not become the best time', () async {
    for (var i = 0; i < 3; i++) {
      await run(msPerTask: 9000);
    }
    final before =
        (await stats.watchLessonStats(mia).first)[lesson]!.bestScoreMs;

    await run(msPerTask: 1000);
    final after = await stats.watchLessonStats(mia).first;

    expect(after[lesson]!.bestScoreMs, before,
        reason: 'that is the whole point of the cap');
    // The practice itself is not denied, and the tile keeps counting it.
    expect(after[lesson]!.runs, 4);
  });

  test('and it stays out of the leaderboard and the bolt total', () async {
    for (var i = 0; i < 3; i++) {
      await run(msPerTask: 9000);
    }
    final slowBolts = (await stats.watchBoltTotals().first)[mia];

    await run(msPerTask: 500);

    final board = await stats.watchLeaderboard(lesson).first;
    expect(board.single.scoreMs, 9000);
    expect((await stats.watchBoltTotals().first)[mia], slowBolts);
  });

  test('nor does it force stars out of a lesson by repetition', () async {
    // Three sloppy runs first: they count, and they are worth fewer stars.
    for (var i = 0; i < 3; i++) {
      await run(msPerTask: 9000, wrong: 5);
    }
    final earned = (await stats.watchStarTotals().first)[mia] ?? 0;

    // A flawless fourth would have been worth three, and changes nothing.
    await run(msPerTask: 9000);
    expect((await stats.watchStarTotals().first)[mia] ?? 0, earned);
  });

  test('an abandoned run neither counts nor uses up a slot', () async {
    final id = await sessions.startSession(
        userId: mia, lessonId: lesson, taskCount: 10, seed: 1);
    await sessions.finishSession(
      sessionId: id,
      completed: false,
      scoredRunLimit: 1,
      dayStartMs: dayStart(),
      results: const [
        TaskResult(
          task: Task(a: 42, b: 35, op: Operation.add, form: TaskForm.result),
          elapsedMs: 3000,
          wrongAttempts: 0,
        ),
      ],
    );
    expect(await scored(id), isFalse);

    // The slot was never used, so the next real run still counts.
    expect(await scored(await run(msPerTask: 9000, limit: 1)), isTrue);
  });

  test('the cap is per lesson, not per child', () async {
    await run(msPerTask: 9000, limit: 1);
    expect(await scored(await run(msPerTask: 9000, limit: 1)), isFalse);
    expect(
      await scored(await run(msPerTask: 9000, limit: 1, lessonId: 'add_100_carry')),
      isTrue,
      reason: 'a different lesson has its own slots',
    );
  });

  test('a cap of zero is no cap at all', () async {
    for (var i = 0; i < 6; i++) {
      expect(await scored(await run(msPerTask: 9000, limit: 0)), isTrue);
    }
  });

  test('yesterday does not use up today', () async {
    for (var i = 0; i < 3; i++) {
      await run(msPerTask: 9000);
    }
    // Push everything back a day, then ask again with today's boundary.
    await db.customStatement(
      'UPDATE sessions SET finished_at_ms = finished_at_ms - 86400000',
    );
    expect(await scored(await run(msPerTask: 9000)), isTrue);
  });

  group('the rule itself', () {
    test('counts up to the limit and no further', () {
      expect(runStillCounts(limit: 3, scoredToday: 0), isTrue);
      expect(runStillCounts(limit: 3, scoredToday: 2), isTrue);
      expect(runStillCounts(limit: 3, scoredToday: 3), isFalse);
      expect(runStillCounts(limit: 0, scoredToday: 99), isTrue);
    });

    test('a profile without its own follows the app-wide one', () {
      expect(resolveScoredRuns(global: 3, scoredRuns: null), 3);
      expect(resolveScoredRuns(global: 3, scoredRuns: 1), 1);
      // Zero is a decision, not "unset": this child has no cap.
      expect(resolveScoredRuns(global: 3, scoredRuns: 0), 0);
    });
  });

  test('how many runs are left today', () async {
    Future<int> left() => stats
        .watchScoredRunsToday(
          userId: mia,
          lessonId: lesson,
          dayStartMs: dayStart(),
        )
        .first;

    expect(await left(), 0);
    await run(msPerTask: 9000);
    expect(await left(), 1);
    await run(msPerTask: 9000);
    await run(msPerTask: 9000);
    expect(await left(), 3);
    // The fourth did not count, so it does not show up here either.
    await run(msPerTask: 9000);
    expect(await left(), 3);
  });
}
