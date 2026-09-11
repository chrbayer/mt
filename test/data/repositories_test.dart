import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/data/repositories/session_repository.dart';
import 'package:mathe_trainer/data/repositories/settings_repository.dart';
import 'package:mathe_trainer/data/repositories/stats_repository.dart';
import 'package:mathe_trainer/data/repositories/user_repository.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mathe_trainer/domain/group_visibility.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/lesson_filter.dart';
import 'package:mathe_trainer/domain/scoring.dart';
import 'package:mathe_trainer/domain/task.dart';

/// Records a completed run of [taskCount] tasks taking [msPerTask] each.
Future<int> recordRun(
  SessionRepository sessions, {
  required int userId,
  required String lessonId,
  int taskCount = 10,
  int msPerTask = 5000,
  int wrongAttempts = 0,
  bool completed = true,
}) async {
  final id = await sessions.startSession(
    userId: userId,
    lessonId: lessonId,
    taskCount: taskCount,
    seed: 1,
  );
  await sessions.finishSession(
    sessionId: id,
    completed: completed,
    results: [
      for (var i = 0; i < taskCount; i++)
        TaskResult(
          task: Task(
            a: 40 + i,
            b: 30,
            op: Operation.add,
            form: TaskForm.result,
          ),
          elapsedMs: msPerTask,
          wrongAttempts: i == 0 ? wrongAttempts : 0,
        ),
    ],
  );
  return id;
}

void main() {
  // The migration test deliberately opens the same file twice.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late UserRepository users;
  late SessionRepository sessions;
  late StatsRepository stats;
  late SettingsRepository settings;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    users = UserRepository(db);
    sessions = SessionRepository(db);
    stats = StatsRepository(db);
    settings = SettingsRepository(db);
  });

  tearDown(() => db.close());

  group('profiles', () {
    test('create, update and list', () async {
      final id =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 2);
      expect((await users.allUsers()).single.name, 'Mia');

      await users.updateUser(
          id: id, name: 'Mia B.', avatar: '🐼', colorIndex: 3);
      final updated = await users.findUser(id);
      expect(updated!.name, 'Mia B.');
      expect(updated.avatar, '🐼');
    });

    test('deleting a profile removes its runs and attempts', () async {
      final id =
          await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 0);
      await recordRun(sessions, userId: id, lessonId: 'add_100_plain');

      await users.deleteUser(id);
      expect(await db.select(db.sessions).get(), isEmpty);
      expect(await db.select(db.attempts).get(), isEmpty);
    });

    test('every group is visible until one is switched off', () async {
      final id =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final fresh = (await users.findUser(id))!;
      expect(fresh.visibleGroups, LessonGroup.values);
      expect(fresh.hidden, isEmpty);
      expect(fresh.shows(LessonGroup.upTo1000), isTrue);
    });

    test('hidden groups are stored per child and survive a reload', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final tom =
          await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);

      await users.setHiddenGroups(mia, {
        LessonGroup.upTo1000,
        LessonGroup.timesTables,
        LessonGroup.timesAndDivision,
        LessonGroup.everyday,
      });

      final reloaded = (await users.findUser(mia))!;
      // Everything not switched off, in catalogue order.
      expect(reloaded.visibleGroups, [
        LessonGroup.firstSteps,
        LessonGroup.upTo10,
        LessonGroup.upTo20,
        LessonGroup.upTo100,
        LessonGroup.reverseTimesTables,
      ]);
      expect(reloaded.shows(LessonGroup.timesTables), isFalse);
      // The setting belongs to one child only.
      expect((await users.findUser(tom))!.visibleGroups, LessonGroup.values);
    });

    test('a group can be switched back on', () async {
      final id =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      await users.setHiddenGroups(id, {LessonGroup.upTo1000});
      await users.setHiddenGroups(id, {});
      expect((await users.findUser(id))!.visibleGroups, LessonGroup.values);
    });

    test('a group added later only comes along next to one the child has',
        () async {
      final id =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      // A setting written by a version that did not have the times tables
      // yet, with both of the neighbouring groups switched off.
      await (db.update(db.users)..where((u) => u.id.equals(id))).write(
        UsersCompanion(
          hiddenGroups: const Value('upTo1000,reverseTimesTables'),
          knownGroups: Value(groupNames(
              LessonGroup.values.toSet()..remove(LessonGroup.timesTables))),
        ),
      );

      // Nothing beside it is on, so it stays out rather than turning up on
      // a first-grader's screen.
      expect((await users.findUser(id))!.shows(LessonGroup.timesTables),
          isFalse);

      // Once a parent has looked at the list, the group is no longer new:
      // leaving it on is now a decision like any other.
      await users.setHiddenGroups(id, {LessonGroup.upTo1000});
      final decided = (await users.findUser(id))!;
      expect(decided.shows(LessonGroup.timesTables), isTrue);
      expect(decided.known, LessonGroup.values.toSet());
    });

    test('a new group next to one that is on comes along by itself', () async {
      final id =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      await (db.update(db.users)..where((u) => u.id.equals(id))).write(
        UsersCompanion(
          knownGroups: Value(groupNames(
              LessonGroup.values.toSet()..remove(LessonGroup.timesTables))),
        ),
      );
      expect((await users.findUser(id))!.shows(LessonGroup.timesTables),
          isTrue);
    });

    test('a profile from before the rule sees the whole catalogue', () async {
      final id =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      // Empty is what such a profile carries. Read as "knows nothing" it
      // would leave the child with an empty screen.
      await (db.update(db.users)..where((u) => u.id.equals(id)))
          .write(const UsersCompanion(knownGroups: Value('')));
      expect((await users.findUser(id))!.visibleGroups, LessonGroup.values);
    });

    test('an unknown stored group name is ignored, not crashed on', () async {
      // A profile written by a newer version, opened by an older one.
      final id =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      await (db.update(db.users)..where((u) => u.id.equals(id)))
          .write(const UsersCompanion(
              hiddenGroups: Value('upTo20,bruchrechnen')));

      final user = (await users.findUser(id))!;
      expect(user.hidden, {LessonGroup.upTo20});
      expect(user.shows(LessonGroup.upTo10), isTrue);
    });

    test('resetting statistics keeps the profile', () async {
      final id =
          await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 0);
      await recordRun(sessions, userId: id, lessonId: 'add_100_plain');

      await users.resetStatistics(id);
      expect(await users.findUser(id), isNotNull);
      expect(await db.select(db.sessions).get(), isEmpty);
    });
  });

  group('migration', () {
    /// Builds a database at [version] by taking the current schema back to
    /// it, then hands the file over for reopening.
    Future<File> databaseAtVersion(int version) async {
      final dir = Directory.systemTemp.createTempSync('mt_migration');
      addTearDown(() => dir.deleteSync(recursive: true));
      final file = File('${dir.path}/app.sqlite');

      final before = AppDatabase(NativeDatabase(file));
      final id = await UserRepository(before)
          .createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      await recordRun(SessionRepository(before),
          userId: id, lessonId: 'add_20_plain');

      if (version < 15) {
        await before
            .customStatement('ALTER TABLE users DROP COLUMN known_groups');
      }
      if (version < 14) {
        // v13 hung an hour of day and a weekday on every assignment.
        await before.customStatement('ALTER TABLE assignments '
            'ADD COLUMN due_minute INTEGER NOT NULL DEFAULT 1080');
        await before.customStatement('ALTER TABLE assignments '
            'ADD COLUMN due_weekday INTEGER NOT NULL DEFAULT 7');
      }
      if (version < 13) {
        await before.customStatement('DROP TABLE assignments');
      } else {
        // An assignment to carry across, in whatever shape its version had:
        // up to v13 with the hour and weekday the deadline used to name,
        // from v14 without them.
        final oldShape = version < 14;
        await before.customStatement(
          'INSERT INTO assignments (user_id, lesson_id, rhythm, '
          '${oldShape ? 'due_minute, due_weekday, ' : ''}'
          'runs, task_count, min_stars, min_bolts, '
          'created_at_ms, ended_at_ms) '
          "VALUES ($id, 'times_7', 'weekly', "
          '${oldShape ? '1080, 5, ' : ''}'
          '3, 20, 2, 1, 1000, NULL)',
        );
      }
      if (version < 12) {
        await before
            .customStatement('ALTER TABLE attempts DROP COLUMN operand_c');
        await before.customStatement('ALTER TABLE attempts DROP COLUMN op2');
      }
      if (version < 11) {
        await before.customStatement('ALTER TABLE users DROP COLUMN locked');
      }
      if (version < 10) {
        await before.customStatement('ALTER TABLE sessions DROP COLUMN deleted');
      }
      if (version < 9) {
        await before
            .customStatement('ALTER TABLE users DROP COLUMN scored_runs_per_lesson');
        await before.customStatement('ALTER TABLE sessions DROP COLUMN scored');
      }
      if (version < 8) {
        await before.customStatement('DROP TABLE lesson_stars');
      }
      if (version < 7) {
        await before
            .customStatement('ALTER TABLE users DROP COLUMN lesson_filter');
      }
      if (version < 5) {
        await before.customStatement(
            'ALTER TABLE users DROP COLUMN practice_limit_minutes');
        await before.customStatement(
            'ALTER TABLE users DROP COLUMN break_minutes');
        await before.customStatement(
            'ALTER TABLE users DROP COLUMN daily_limit_minutes');
      } else if (version < 6) {
        // v5 had no "as for everyone": every profile carried the values it
        // was created with.
        await before.customStatement(
          'UPDATE users SET practice_limit_minutes = 0, break_minutes = 15, '
          'daily_limit_minutes = 0',
        );
      }
      if (version < 4) {
        await before.customStatement('DROP TABLE lesson_preferences');
        await before.customStatement(
            'ALTER TABLE users DROP COLUMN default_task_count');
      }
      if (version < 3) {
        await before
            .customStatement('ALTER TABLE users DROP COLUMN review_hard_tasks');
      }
      if (version < 2) {
        await before
            .customStatement('ALTER TABLE users DROP COLUMN hidden_groups');
      }
      await before.customStatement('PRAGMA user_version = $version');
      await before.close();
      return file;
    }

    for (final from in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]) {
      test('a database from schema v$from keeps its data', () async {
        final file = await databaseAtVersion(from);

        // Reopening runs the migration.
        final after = AppDatabase(NativeDatabase(file));
        addTearDown(after.close);
        final user = (await UserRepository(after).allUsers()).single;

        expect(user.name, 'Mia');
        expect(user.avatar, '🦊');
        // New columns arrive at their defaults, so nothing changes behind the
        // child's back: every group visible, review switched on.
        expect(user.visibleGroups, LessonGroup.values);
        expect(user.reviewHardTasks, isTrue);
        expect(user.defaultTaskCount, isNull);
        // Nobody ever decided about the time limits for this profile, so it
        // follows the app-wide setting - that is what null means here.
        expect(user.practiceLimitMinutes, isNull);
        expect(user.breakMinutes, isNull);
        expect(user.dailyLimitMinutes, isNull);
        // Nothing was ever filtered away, so nothing is.
        expect(user.filter, LessonFilter.all);
        // Every group this version has was decided against the catalogue as
        // it stands, so none of it counts as new - a migration must not
        // change what a child is offered.
        expect(user.known, LessonGroup.values.toSet());
        // The daily cap on scored runs is new too: nobody decided about it,
        // so this profile follows the app-wide setting.
        expect(user.scoredRunsPerLesson, isNull);
        // And everything already in the database was earned under no cap at
        // all. A rule made afterwards must not take a best time away.
        expect((await after.select(after.sessions).get()).single.scored,
            isTrue);
        // Nothing was ever deleted before v10 either.
        expect((await after.select(after.sessions).get()).single.deleted,
            isFalse);
        // And nobody was locked out by an update.
        expect(user.locked, isFalse);
        // The stars were worked out from the runs before v8 and are carried
        // over once: a clean run of ten is worth three, and nobody loses
        // what they collected because the app changed how it keeps score.
        final stars = await StatsRepository(after).watchLessonStats(1).first;
        expect(stars['add_20_plain']!.bestStars, maxStars);
        expect((await StatsRepository(after).watchStarTotals().first)[1],
            maxStars);
        expect(await after.select(after.lessonPreferences).get(), isEmpty);
        expect(await after.select(after.sessions).get(), hasLength(1));
        final attempts = await after.select(after.attempts).get();
        expect(attempts, hasLength(10));
        // Every task recorded before v12 had two operands, and that is
        // still the truth about it - not a value nobody filled in.
        expect(attempts.first.operandC, isNull);
        expect(attempts.first.op2, isNull);
        final assignments = await after.select(after.assignments).get();
        if (from < 13) {
          // There were no assignments before v13 - the empty table is the
          // whole migration.
          expect(assignments, isEmpty);
        } else {
          // v14 drops the hour and the weekday and keeps everything else.
          // Nobody loses an assignment because the deadline got coarser.
          expect(assignments.single.lessonId, 'times_7');
          expect(assignments.single.rhythm, 'weekly');
          expect(assignments.single.runs, 3);
          expect(assignments.single.taskCount, 20);
          expect(assignments.single.minStars, 2);
          expect(assignments.single.minBolts, 1);
          expect(assignments.single.endedAtMs, isNull);
        }
      });
    }
  });

  group('sessions', () {
    test('finishing sums up time and wrong attempts', () async {
      final user =
          await users.createUser(name: 'Ida', avatar: '🐨', colorIndex: 1);
      final id = await recordRun(
        sessions,
        userId: user,
        lessonId: 'add_100_carry',
        taskCount: 10,
        msPerTask: 4000,
        wrongAttempts: 3,
      );

      final row = await sessions.sessionById(id);
      expect(row!.totalMs, 40000);
      expect(row.wrongAttempts, 3);
      expect(row.completed, isTrue);
      expect(row.finishedAtMs, isNotNull);
      expect(await db.select(db.attempts).get(), hasLength(10));
    });

    test('an aborted run stores the tasks actually done', () async {
      final user =
          await users.createUser(name: 'Ida', avatar: '🐨', colorIndex: 1);
      final id = await sessions.startSession(
        userId: user,
        lessonId: 'add_100_carry',
        taskCount: 20,
        seed: 7,
      );
      await sessions.finishSession(
        sessionId: id,
        completed: false,
        results: const [
          TaskResult(
            task: Task(a: 47, b: 38, op: Operation.add, form: TaskForm.result),
            elapsedMs: 3000,
            wrongAttempts: 1,
          ),
        ],
      );

      final row = await sessions.sessionById(id);
      expect(row!.completed, isFalse);
      expect(row.taskCount, 1);
    });

    test('previousCompletedSession skips the current and aborted runs',
        () async {
      final user =
          await users.createUser(name: 'Ida', avatar: '🐨', colorIndex: 1);
      final older = await recordRun(
          sessions, userId: user, lessonId: 'mix_100', msPerTask: 9000);
      await recordRun(
          sessions, userId: user, lessonId: 'mix_100', completed: false);
      final current = await recordRun(
          sessions, userId: user, lessonId: 'mix_100', msPerTask: 4000);

      final previous = await sessions.previousCompletedSession(
        userId: user,
        lessonId: 'mix_100',
        excludingSessionId: current,
      );
      expect(previous!.id, older);
    });
  });

  group('statistics', () {
    test('lesson stats aggregate runs of one child', () async {
      final user =
          await users.createUser(name: 'Ida', avatar: '🐨', colorIndex: 1);
      await recordRun(
          sessions, userId: user, lessonId: 'add_100_plain', msPerTask: 6000);
      await recordRun(
        sessions,
        userId: user,
        lessonId: 'add_100_plain',
        msPerTask: 4000,
        wrongAttempts: 2,
      );
      // Not counted: incomplete.
      await recordRun(
        sessions,
        userId: user,
        lessonId: 'add_100_plain',
        msPerTask: 100,
        completed: false,
      );

      final byLesson = await stats.watchLessonStats(user).first;
      final stat = byLesson['add_100_plain']!;
      expect(stat.runs, 2);
      // Both figures are the scored time, so they are comparable: the clean
      // 6 s run, and the 4 s run plus 2 x 3 s penalty over 10 tasks = 4.6 s.
      expect(stat.bestScoreMs, closeTo(4600, 0.01));
      expect(stat.averageMs, closeTo(5300, 0.01));
      expect(stat.errorRate, closeTo(0.1, 1e-9));
      // The clean run is worth three stars, and the best one is what counts.
      expect(stat.bestStars, 3);
    });

    test('leaderboard ranks each child by their personal best', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final tom =
          await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);
      await recordRun(
          sessions, userId: mia, lessonId: 'mix_100', msPerTask: 9000);
      await recordRun(
          sessions, userId: mia, lessonId: 'mix_100', msPerTask: 5000);
      await recordRun(
          sessions, userId: tom, lessonId: 'mix_100', msPerTask: 7000);

      final board = await stats.watchLeaderboard('mix_100').first;
      expect(board.map((e) => e.name), ['Mia', 'Tom']);
      expect(board.first.scoreMs, 5000);
      expect(board.first.avatar, '🦊');
    });

    test('leaderboard compares runs of different lengths fairly', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final tom =
          await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);
      // Tom did five times as many tasks at the same pace, and still wins on
      // pace because Mia is slower per task.
      await recordRun(
        sessions,
        userId: mia,
        lessonId: 'mix_1000',
        taskCount: 10,
        msPerTask: 8000,
      );
      await recordRun(
        sessions,
        userId: tom,
        lessonId: 'mix_1000',
        taskCount: 50,
        msPerTask: 6000,
      );

      final board = await stats.watchLeaderboard('mix_1000').first;
      expect(board.map((e) => e.name), ['Tom', 'Mia']);
    });

    test('short runs stay out of the leaderboard', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      await recordRun(
        sessions,
        userId: mia,
        lessonId: 'sub_100_borrow',
        taskCount: minTasksForAward - 1,
        msPerTask: 1000,
      );

      expect(await stats.watchLeaderboard('sub_100_borrow').first, isEmpty);
    });

    test('all leaderboards come back in one go, freshest lesson first',
        () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final tom =
          await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);

      await recordRun(sessions,
          userId: mia, lessonId: 'times_7', msPerTask: 3000);
      await recordRun(sessions,
          userId: tom, lessonId: 'times_7', msPerTask: 2000);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await recordRun(sessions,
          userId: mia, lessonId: 'add_20_plain', msPerTask: 4000);
      // Too short to be ranked at all.
      await recordRun(
        sessions,
        userId: tom,
        lessonId: 'div_plain',
        taskCount: 5,
        msPerTask: 500,
      );

      final boards = await stats.watchAllLeaderboards().first;

      // The lesson practised last comes first; empty and too-short lessons
      // do not appear.
      expect(boards.map((b) => b.lessonId), ['add_20_plain', 'times_7']);

      final sevens = boards.last;
      expect(sevens.entries.map((e) => e.name), ['Tom', 'Mia']);
      expect(sevens.entries.first.scoreMs, 2000);
      expect(sevens.entries.first.avatar, '🐧');

      final twenties = boards.first;
      expect(twenties.entries.single.name, 'Mia');
    });

    test('each child appears once per leaderboard, with their best run',
        () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      await recordRun(sessions,
          userId: mia, lessonId: 'times_7', msPerTask: 9000);
      await recordRun(sessions,
          userId: mia, lessonId: 'times_7', msPerTask: 4000);
      await recordRun(sessions,
          userId: mia, lessonId: 'times_7', msPerTask: 6000);

      final board = (await stats.watchAllLeaderboards().first).single;
      expect(board.entries, hasLength(1));
      expect(board.entries.single.scoreMs, 4000);
    });

    test('progress is returned oldest first', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      await recordRun(
          sessions, userId: mia, lessonId: 'add_1000_gap', msPerTask: 9000);
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await recordRun(
          sessions, userId: mia, lessonId: 'add_1000_gap', msPerTask: 5000);

      final points = await stats
          .watchProgress(userId: mia, lessonId: 'add_1000_gap')
          .first;
      expect(points.map((p) => p.msPerTask), [9000, 5000]);
    });

    test('the review pool holds the slow and the wrong ones', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final id = await sessions.startSession(
        userId: mia,
        lessonId: 'add_100_carry',
        taskCount: 4,
        seed: 1,
      );
      await sessions.finishSession(
        sessionId: id,
        completed: true,
        results: const [
          // Fast and right - nothing to practise here.
          TaskResult(
            task: Task(a: 11, b: 12, op: Operation.add, form: TaskForm.result),
            elapsedMs: 2000,
            wrongAttempts: 0,
          ),
          TaskResult(
            task: Task(a: 13, b: 14, op: Operation.add, form: TaskForm.result),
            elapsedMs: 2000,
            wrongAttempts: 0,
          ),
          // Right, but far slower than the rest.
          TaskResult(
            task: Task(a: 47, b: 38, op: Operation.add, form: TaskForm.result),
            elapsedMs: 9000,
            wrongAttempts: 0,
          ),
          // Quick, but got it wrong first.
          TaskResult(
            task: Task(a: 59, b: 26, op: Operation.add, form: TaskForm.result),
            elapsedMs: 2500,
            wrongAttempts: 2,
          ),
        ],
      );

      final pool = await stats.hardTasksInLesson(
        userId: mia,
        lessonId: 'add_100_carry',
      );
      expect(pool.map((t) => '${t.a}+${t.b}'), containsAll(['47+38', '59+26']));
      expect(pool.map((t) => '${t.a}+${t.b}'), isNot(contains('11+12')));
    });

    test('the review pool stays within one lesson', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      await recordRun(sessions,
          userId: mia, lessonId: 'add_20_plain', wrongAttempts: 3);

      expect(
        await stats.hardTasksInLesson(userId: mia, lessonId: 'mix_100'),
        isEmpty,
      );
      expect(
        await stats.hardTasksInLesson(userId: mia, lessonId: 'add_20_plain'),
        isNotEmpty,
      );
    });

    test('hardest tasks are ranked by time plus penalty', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final id = await sessions.startSession(
        userId: mia,
        lessonId: 'add_100_carry',
        taskCount: 2,
        seed: 1,
      );
      await sessions.finishSession(
        sessionId: id,
        completed: true,
        results: const [
          TaskResult(
            task: Task(a: 12, b: 13, op: Operation.add, form: TaskForm.result),
            elapsedMs: 2000,
            wrongAttempts: 0,
          ),
          TaskResult(
            task: Task(a: 47, b: 38, op: Operation.add, form: TaskForm.result),
            elapsedMs: 3000,
            wrongAttempts: 4,
          ),
        ],
      );

      final hard = await stats.hardestTasks(userId: mia);
      expect(hard.first.a, 47);
      expect(hard.first.b, 38);
      expect(hard.last.a, 12);
    });
  });

  group('parent area', () {
    test('history lists every run, newest first, aborted ones included',
        () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final tom =
          await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);

      await recordRun(sessions, userId: mia, lessonId: 'add_20_plain');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await recordRun(
        sessions,
        userId: tom,
        lessonId: 'mix_100',
        completed: false,
        wrongAttempts: 2,
      );

      final history = await stats.watchHistory().first;
      expect(history, hasLength(2));
      expect(history.first.userName, 'Tom');
      expect(history.first.completed, isFalse);
      expect(history.first.lessonId, 'mix_100');
      expect(history.last.userName, 'Mia');
      expect(history.last.completed, isTrue);
      expect(history.last.avatar, '🦊');
    });

    test('history can be narrowed to one child', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final tom =
          await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);
      await recordRun(sessions, userId: mia, lessonId: 'add_20_plain');
      await recordRun(sessions, userId: tom, lessonId: 'add_20_plain');

      final onlyMia = await stats.watchHistory(userId: mia).first;
      expect(onlyMia, hasLength(1));
      expect(onlyMia.single.userName, 'Mia');
    });

    test('a single run can be deleted', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final keep =
          await recordRun(sessions, userId: mia, lessonId: 'add_20_plain');
      final drop =
          await recordRun(sessions, userId: mia, lessonId: 'mix_100');

      await stats.deleteSession(drop);
      final history = await stats.watchHistory().first;
      expect(history.map((h) => h.sessionId), [keep]);
      // Marked, not erased: the row and its attempts stay so the practised
      // time stays. Deleting a run must not hand back an afternoon.
      expect(await db.select(db.sessions).get(), hasLength(2));
      expect(await db.select(db.attempts).get(), hasLength(20));
    });

    test('summaries cover every profile, also the ones without a run',
        () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      await users.createUser(name: 'Neu', avatar: '🐢', colorIndex: 2);
      await recordRun(
        sessions,
        userId: mia,
        lessonId: 'add_20_plain',
        msPerTask: 5000,
        wrongAttempts: 4,
      );
      await recordRun(
          sessions, userId: mia, lessonId: 'mix_100', msPerTask: 3000);
      // Aborted runs do not count towards the totals.
      await recordRun(
        sessions,
        userId: mia,
        lessonId: 'mix_100',
        msPerTask: 60000,
        completed: false,
      );

      final summaries = await stats.watchUserSummaries().first;
      expect(summaries.map((s) => s.name), ['Mia', 'Neu']);

      final first = summaries.first;
      expect(first.runs, 2);
      expect(first.tasks, 20);
      expect(first.totalMs, 80000);
      expect(first.wrongAttempts, 4);
      expect(first.errors, closeTo(0.2, 1e-9));
      expect(first.lastPlayed, isNotNull);

      final untouched = summaries.last;
      expect(untouched.runs, 0);
      expect(untouched.totalMs, 0);
      expect(untouched.lastPlayed, isNull);
    });

    test('stars follow the error rate, best run per lesson', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);

      // Nine wrong out of ten: one star.
      await recordRun(sessions,
          userId: mia, lessonId: 'times_7', wrongAttempts: 9);
      var stats2 = await stats.watchLessonStats(mia).first;
      expect(stats2['times_7']!.bestStars, 1);

      // Two wrong out of ten is 20 %: two stars, and it is the better run.
      await recordRun(sessions,
          userId: mia, lessonId: 'times_7', wrongAttempts: 2);
      stats2 = await stats.watchLessonStats(mia).first;
      expect(stats2['times_7']!.bestStars, 2);

      // A clean run tops it off. A later worse run must not take it away.
      await recordRun(sessions, userId: mia, lessonId: 'times_7');
      await recordRun(sessions,
          userId: mia, lessonId: 'times_7', wrongAttempts: 8);
      stats2 = await stats.watchLessonStats(mia).first;
      expect(stats2['times_7']!.bestStars, 3);
    });

    test('the star total counts each lesson once, at its best', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final tom =
          await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);

      // Four clean runs of the same lesson are still three stars - otherwise
      // repeating the easiest lesson would beat trying a new one.
      for (var i = 0; i < 4; i++) {
        await recordRun(sessions, userId: mia, lessonId: 'times_7');
      }
      expect((await stats.watchStarTotals().first)[mia], 3);

      // A second lesson adds its own.
      await recordRun(sessions,
          userId: mia, lessonId: 'add_20_plain', wrongAttempts: 2);
      expect((await stats.watchStarTotals().first)[mia], 5);

      // An abandoned run earns nothing.
      await recordRun(sessions,
          userId: mia, lessonId: 'mix_100', completed: false);
      expect((await stats.watchStarTotals().first)[mia], 5);

      // And it is per child.
      await recordRun(sessions, userId: tom, lessonId: 'times_7');
      final totals = await stats.watchStarTotals().first;
      expect(totals[mia], 5);
      expect(totals[tom], 3);
    });

    test('the stored stars agree with the Dart rule', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      // Since v8 the stars are written by starsFor and read straight back,
      // so this walks the whole way: run, store, read.
      //
      // Scored lessons only: the first steps earn their stars for finishing,
      // which is exactly what the next test checks.
      final scored =
          lessonCatalog.where((l) => l.scored).take(6).toList();
      for (final (index, wrong) in [0, 1, 2, 3, 5, 10].indexed) {
        await recordRun(
          sessions,
          userId: mia,
          lessonId: scored[index].id,
          wrongAttempts: wrong,
        );
      }

      final byLesson = await stats.watchLessonStats(mia).first;
      for (final (index, wrong) in [0, 1, 2, 3, 5, 10].indexed) {
        expect(
          byLesson[scored[index].id]!.bestStars,
          starsFor(wrong, 10, scored: true),
          reason: '$wrong Fehler',
        );
      }
    });

    test('the SQL bolts agree with the Dart ones', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      // One lesson per group that is timed, so the generated CASE is
      // exercised with genuinely different targets.
      final lessons = [
        lessonById('add_100_carry'),
        lessonById('times_7'),
        lessonById('div_remainder'),
        lessonById('money_compose'),
        lessonById('partners_of_ten'),
      ];
      for (final lesson in lessons) {
        // Around the three-bolt line, well past it, and hopeless.
        for (final factor in [0.5, 1.0, 1.4, 2.0, 3.0]) {
          final ms = (lesson.targetMsPerTask * factor).round();
          await recordRun(
            sessions,
            userId: mia,
            lessonId: lesson.id,
            msPerTask: ms,
          );
        }
      }

      // The best (fastest) run of each lesson is what the totals count.
      var expectedTotal = 0;
      for (final lesson in lessons) {
        final best = (lesson.targetMsPerTask * 0.5).round().toDouble();
        expectedTotal += boltsFor(lesson.targetMsPerTask, best, 10);
      }
      expect((await stats.watchBoltTotals().first)[mia], expectedTotal);
    });

    test('bolts are earned per run, and the fastest one counts', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final lesson = lessonById('add_100_carry');
      final target = lesson.targetMsPerTask;

      // Far too slow for any bolt at all.
      await recordRun(sessions,
          userId: mia, lessonId: lesson.id, msPerTask: target * 3);
      expect((await stats.watchBoltTotals().first)[mia], 0);

      // Just inside the one-bolt line.
      await recordRun(sessions,
          userId: mia,
          lessonId: lesson.id,
          msPerTask: (target * oneBoltFactor).round());
      expect((await stats.watchBoltTotals().first)[mia], 1);

      // Bang on the target: all three, and a later slow run cannot take
      // them away again.
      await recordRun(sessions,
          userId: mia, lessonId: lesson.id, msPerTask: target);
      await recordRun(sessions,
          userId: mia, lessonId: lesson.id, msPerTask: target * 5);
      expect((await stats.watchBoltTotals().first)[mia], maxBolts);
    });

    test('a run under ten tasks is worth no stars and no bolts', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      // Flawless and fast - but only five tasks long.
      await recordRun(sessions,
          userId: mia,
          lessonId: 'add_100_carry',
          taskCount: 5,
          msPerTask: 1000);

      final byLesson = await stats.watchLessonStats(mia).first;
      expect(byLesson['add_100_carry']!.bestStars, 0);
      expect(byLesson['add_100_carry']!.bestBolts, 0);
      // No row at all rather than a zero: nothing was earned, so there is
      // nothing to store.
      expect((await stats.watchStarTotals().first)[mia] ?? 0, 0);
      expect((await stats.watchBoltTotals().first)[mia] ?? 0, 0);

      // Ten tasks of the same quality do count, and the short run neither
      // adds to nor takes away from that.
      await recordRun(sessions,
          userId: mia,
          lessonId: 'add_100_carry',
          taskCount: 10,
          msPerTask: 1000);
      final after = await stats.watchLessonStats(mia).first;
      expect(after['add_100_carry']!.bestStars, maxStars);
      expect(after['add_100_carry']!.bestBolts, maxBolts);
    });

    test('the first steps keep their stars however short the run', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      // Five apples counted is a result there, and the minimum must not
      // quietly take it away.
      await recordRun(sessions,
          userId: mia, lessonId: 'count_pictures', taskCount: 5);

      final byLesson = await stats.watchLessonStats(mia).first;
      expect(byLesson['count_pictures']!.bestStars, maxStars);
      expect((await stats.watchStarTotals().first)[mia], maxStars);
      // And the Dart side says the same thing.
      expect(starsFor(0, 5, scored: false), maxStars);
      expect(starsFor(0, 5, scored: true), 0);
    });

    test('a lesson that is not timed has no bolts to give', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      // As fast as anyone could ever be - and still no bolts, because
      // counting apples is not a race.
      await recordRun(sessions,
          userId: mia, lessonId: 'count_pictures', msPerTask: 100);

      expect(lessonById('count_pictures').targetMsPerTask, 0);
      expect((await stats.watchBoltTotals().first)[mia] ?? 0, 0);
      // The stars are untouched by any of this.
      expect((await stats.watchStarTotals().first)[mia], maxStars);
    });

    test('an unscored lesson earns its stars for being finished', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      // Ten tasks, ten wrong attempts - and still three stars, because in the
      // first steps getting through is the achievement.
      await recordRun(sessions,
          userId: mia, lessonId: 'count_pictures', wrongAttempts: 10);

      final byLesson = await stats.watchLessonStats(mia).first;
      expect(byLesson['count_pictures']!.bestStars, maxStars);
      expect((await stats.watchStarTotals().first)[mia], maxStars);
      // And it stays out of every ranking.
      expect(await stats.watchLeaderboard('count_pictures').first, isEmpty);
      expect(await stats.watchAllLeaderboards().first, isEmpty);
    });

    final now = DateTime.now();
    final todayStartMs =
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;

    test('the current stretch adds up until a real break', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      // Three runs back to back, five minutes of practice each.
      for (var i = 0; i < 3; i++) {
        await recordRun(sessions,
            userId: mia, lessonId: 'add_100_carry', msPerTask: 30000);
      }

      final stretch = await stats
          .watchPracticeStretch(
            userId: mia,
            breakMinutes: 15,
            dayStartMs: todayStartMs,
          )
          .first;
      expect(stretch.practisedMs, 3 * 10 * 30000);
      expect(stretch.lastFinishedAt, isNotNull);
    });

    test('an old run is a stretch of its own', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      await recordRun(sessions,
          userId: mia, lessonId: 'add_100_carry', msPerTask: 30000);

      // Backdate it by an hour: with a fifteen minute break in between, the
      // run that follows opens a new stretch.
      final old = (await db.select(db.sessions).get()).single;
      final anHourAgo =
          DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch;
      await (db.update(db.sessions)..where((s) => s.id.equals(old.id))).write(
        SessionsCompanion(
          startedAtMs: Value(anHourAgo),
          finishedAtMs: Value(anHourAgo + 1000),
        ),
      );
      await recordRun(sessions,
          userId: mia, lessonId: 'add_100_carry', msPerTask: 6000);

      final stretch = await stats
          .watchPracticeStretch(
            userId: mia,
            breakMinutes: 15,
            dayStartMs: todayStartMs,
          )
          .first;
      expect(stretch.practisedMs, 10 * 6000,
          reason: 'only the fresh run is in the current stretch');
    });

    test('an abandoned run still counts as time at the tablet', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      await recordRun(sessions,
          userId: mia,
          lessonId: 'add_100_carry',
          msPerTask: 30000,
          completed: false);

      final stretch = await stats
          .watchPracticeStretch(
            userId: mia,
            breakMinutes: 15,
            dayStartMs: todayStartMs,
          )
          .first;
      expect(stretch.practisedMs, 10 * 30000);
    });

    test('a child with no history has an empty stretch', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final stretch = await stats
          .watchPracticeStretch(
            userId: mia,
            breakMinutes: 15,
            dayStartMs: todayStartMs,
          )
          .first;
      expect(stretch.practisedMs, 0);
      expect(stretch.lastFinishedAt, isNull);
    });

    test('a streak counts practice days in a row', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final tom =
          await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);

      /// Backdates a finished run to a given day.
      Future<void> runOn(int userId, int daysAgo) async {
        final id = await recordRun(sessions,
            userId: userId, lessonId: 'add_20_plain');
        final when = DateTime.now().subtract(Duration(days: daysAgo));
        await (db.update(db.sessions)..where((s) => s.id.equals(id))).write(
          SessionsCompanion(
            finishedAtMs: Value(when.millisecondsSinceEpoch),
          ),
        );
      }

      // Mia: today, yesterday, the day before - three in a row.
      await runOn(mia, 0);
      await runOn(mia, 1);
      await runOn(mia, 2);
      // And once more further back, with a gap in between.
      await runOn(mia, 5);
      // Tom last practised three days ago, so his streak is over.
      await runOn(tom, 3);

      final streaks = await stats.watchStreaks().first;
      expect(streaks[mia], 3);
      expect(streaks[tom], 0);
    });

    test('a streak survives a day that is not over yet', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final id =
          await recordRun(sessions, userId: mia, lessonId: 'add_20_plain');
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await (db.update(db.sessions)..where((s) => s.id.equals(id))).write(
        SessionsCompanion(
          finishedAtMs: Value(yesterday.millisecondsSinceEpoch),
        ),
      );

      // Nothing done today yet - the streak still stands until midnight.
      expect((await stats.watchStreaks().first)[mia], 1);
    });

    test('activity is grouped per child and calendar day', () async {
      final mia =
          await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
      final tom =
          await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);
      await recordRun(sessions, userId: mia, lessonId: 'add_20_plain');
      await recordRun(sessions, userId: mia, lessonId: 'mix_100');
      await recordRun(sessions, userId: tom, lessonId: 'mix_100');

      final activity = await stats.watchActivity().first;
      // All three runs happened just now, so one bucket per child.
      expect(activity, hasLength(2));

      final mine = activity.firstWhere((a) => a.userId == mia);
      expect(mine.runs, 2);
      expect(mine.totalMs, 100000);

      final today = DateTime.now();
      expect(mine.day.year, today.year);
      expect(mine.day.month, today.month);
      expect(mine.day.day, today.day);
    });

    test('the PIN is set once and then checked', () async {
      expect(await settings.hasAdminPin(), isFalse);
      expect(await settings.checkAdminPin('1234'), isFalse);

      await settings.setAdminPin('4711');
      expect(await settings.hasAdminPin(), isTrue);
      expect(await settings.checkAdminPin('4711'), isTrue);
      expect(await settings.checkAdminPin('4712'), isFalse);

      await settings.setAdminPin('0000');
      expect(await settings.checkAdminPin('4711'), isFalse);
      expect(await settings.checkAdminPin('0000'), isTrue);
    });

    test('the PIN is never stored in the clear', () async {
      await settings.setAdminPin('4711');
      final rows = await db.select(db.appSettings).get();
      expect(rows.map((r) => r.settingValue), isNot(contains('4711')));
      expect(rows.any((r) => r.settingKey == 'admin_pin_hash'), isTrue);
    });

    test('the same PIN hashes differently every time it is set', () async {
      Future<String> currentHash() async => (await db.select(db.appSettings).get())
          .firstWhere((r) => r.settingKey == 'admin_pin_hash')
          .settingValue;

      await settings.setAdminPin('4711');
      final first = await currentHash();
      await settings.setAdminPin('4711');

      // A fresh salt each time, so the stored hash is never a lookup-able
      // fingerprint of a four-digit number.
      expect(await currentHash(), isNot(first));
      expect(await settings.checkAdminPin('4711'), isTrue);
    });
  });

  group('preferences', () {
    test('defaults, then persisted changes', () async {
      final initial = await settings.load();
      expect(initial.showClock, isFalse);
      expect(initial.haptics, isTrue);
      expect(initial.defaultTaskCount, 10);

      await settings.setShowClock(true);
      await settings.setHaptics(false);
      await settings.setDefaultTaskCount(30);

      final updated = await settings.load();
      expect(updated.showClock, isTrue);
      expect(updated.haptics, isFalse);
      expect(updated.defaultTaskCount, 30);
    });
  });
}
