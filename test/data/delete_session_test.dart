import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/data/repositories/session_repository.dart';
import 'package:mathe_trainer/data/repositories/stats_repository.dart';
import 'package:mathe_trainer/data/repositories/user_repository.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/scoring.dart';
import 'package:mathe_trainer/domain/task.dart';

/// Deleting a run may cost stars, bolts and a ranking - that is what a parent
/// is asking for. It must not hand back practice time, or the daily limit
/// would come with a delete button next to it.
void main() {
  late AppDatabase db;
  late SessionRepository sessions;
  late StatsRepository stats;
  late int mia;

  const lesson = 'add_100_plain';

  int dayStart() {
    final now = DateTime.now();
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

  Future<int> run({
    int msPerTask = 5000,
    int wrong = 0,
    bool completed = true,
    String lessonId = lesson,
  }) async {
    final id = await sessions.startSession(
      userId: mia,
      lessonId: lessonId,
      taskCount: 10,
      seed: 1,
    );
    await sessions.finishSession(
      sessionId: id,
      completed: completed,
      dayStartMs: dayStart(),
      results: [
        for (var i = 0; i < 10; i++)
          TaskResult(
            task:
                const Task(a: 42, b: 35, op: Operation.add, form: TaskForm.result),
            elapsedMs: msPerTask,
            wrongAttempts: i < wrong ? 1 : 0,
          ),
      ],
    );
    return id;
  }

  Future<int> practisedToday() async =>
      (await stats.watchPractisedToday(dayStart()).first)[mia] ?? 0;

  test('the practised time survives a deletion', () async {
    await run();
    final drop = await run();
    final before = await practisedToday();
    expect(before, 100000);

    await stats.deleteSession(drop);
    expect(await practisedToday(), before,
        reason: 'otherwise the daily limit has a delete button next to it');
  });

  test('but the record does not', () async {
    await run(msPerTask: 9000);
    final fast = await run(msPerTask: 1000);

    expect((await stats.watchLessonStats(mia).first)[lesson]!.bestScoreMs,
        1000);
    await stats.deleteSession(fast);

    final after = await stats.watchLessonStats(mia).first;
    expect(after[lesson]!.bestScoreMs, 9000);
    expect(after[lesson]!.runs, 1);
    expect((await stats.watchLeaderboard(lesson).first).single.scoreMs, 9000);
    expect(await stats.watchHistory().first, hasLength(1));
  });

  test('the stars are worked out again from what is left', () async {
    // A sloppy run first, then a clean one worth three.
    await run(wrong: 5);
    final clean = await run();
    expect((await stats.watchStarTotals().first)[mia], maxStars);

    await stats.deleteSession(clean);
    final left = (await stats.watchStarTotals().first)[mia] ?? 0;
    expect(left, lessThan(maxStars));
    expect(left, starsFor(5, 10, scored: true));
  });

  test('and go altogether when the last run of a lesson goes', () async {
    final only = await run();
    expect((await stats.watchStarTotals().first)[mia], maxStars);

    await stats.deleteSession(only);
    expect((await stats.watchStarTotals().first)[mia] ?? 0, 0);
    expect(await db.select(db.lessonStars).get(), isEmpty);
  });

  test('a deleted run frees its slot under the daily cap', () async {
    final first = await run();
    await stats.deleteSession(first);

    final id = await sessions.startSession(
        userId: mia, lessonId: lesson, taskCount: 10, seed: 1);
    await sessions.finishSession(
      sessionId: id,
      completed: true,
      scoredRunLimit: 1,
      dayStartMs: dayStart(),
      results: [
        for (var i = 0; i < 10; i++)
          const TaskResult(
            task: Task(a: 42, b: 35, op: Operation.add, form: TaskForm.result),
            elapsedMs: 5000,
            wrongAttempts: 0,
          ),
      ],
    );
    expect((await sessions.sessionById(id))!.scored, isTrue);
  });

  group('tidying up abandoned runs', () {
    test('removes the abandoned ones and leaves the rest', () async {
      final kept = await run();
      await run(completed: false);
      await run(completed: false);

      expect(await stats.deleteIncompleteSessions(), 2);
      expect((await stats.watchHistory().first).map((h) => h.sessionId),
          [kept]);
    });

    test('for one child only, when one is picked', () async {
      final tom = await UserRepository(db)
          .createUser(name: 'Tom', avatar: 'T', colorIndex: 1);
      await run(completed: false);
      final tomsRun = await sessions.startSession(
          userId: tom, lessonId: lesson, taskCount: 10, seed: 1);
      await sessions.finishSession(
        sessionId: tomsRun,
        completed: false,
        results: const [],
      );

      expect(await stats.deleteIncompleteSessions(userId: mia), 1);
      expect((await stats.watchHistory().first).map((h) => h.sessionId),
          [tomsRun]);
    });

    test('and the time they took stays counted', () async {
      await run(completed: false);
      final before = await practisedToday();
      expect(before, greaterThan(0));

      await stats.deleteIncompleteSessions();
      expect(await practisedToday(), before);
    });

    test('tidying twice tidies nothing the second time', () async {
      await run(completed: false);
      expect(await stats.deleteIncompleteSessions(), 1);
      expect(await stats.deleteIncompleteSessions(), 0);
    });
  });
}
