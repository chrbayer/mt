import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/data/repositories/backup_repository.dart';
import 'package:mathe_trainer/data/repositories/session_repository.dart';
import 'package:mathe_trainer/data/repositories/settings_repository.dart';
import 'package:mathe_trainer/data/repositories/user_repository.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';

/// The whole point of a backup is the day the tablet is wiped, so these tests
/// go the full way round: export, throw everything away, import, compare.
void main() {
  late AppDatabase db;
  late UserRepository users;
  late SessionRepository sessions;
  late BackupRepository backup;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    users = UserRepository(db);
    sessions = SessionRepository(db);
    backup = BackupRepository(db);
  });

  tearDown(() => db.close());

  Future<int> seedData() async {
    final mia = await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
    await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);
    await users.setHiddenGroups(mia, {LessonGroup.upTo1000});
    await users.setReviewHardTasks(mia, false);
    await SettingsRepository(db).setAdminPin('4711');
    await SettingsRepository(db).setDefaultTaskCount(30);
    await users.setProfileTaskCount(mia, 20);
    await SettingsRepository(db).setLessonTaskCount(
      userId: mia,
      lessonId: 'times_7',
      count: 50,
    );

    final id = await sessions.startSession(
      userId: mia,
      lessonId: 'times_7',
      taskCount: 2,
      seed: 99,
    );
    await sessions.finishSession(
      sessionId: id,
      completed: true,
      results: const [
        TaskResult(
          task: Task(a: 7, b: 8, op: Operation.mul, form: TaskForm.result),
          elapsedMs: 4200,
          wrongAttempts: 1,
        ),
        TaskResult(
          task: Task(a: 7, b: 9, op: Operation.mul, form: TaskForm.result),
          elapsedMs: 3100,
          wrongAttempts: 0,
        ),
      ],
    );
    return mia;
  }

  test('everything comes back exactly as it went out', () async {
    final mia = await seedData();
    final json = await backup.export();

    // A wiped tablet.
    await db.delete(db.users).go();
    await db.delete(db.appSettings).go();
    expect(await users.allUsers(), isEmpty);

    final summary = await backup.import(json);
    expect(summary.users, 2);
    expect(summary.sessions, 1);
    expect(summary.attempts, 2);
    expect(summary.exportedAt, isNotNull);

    final restored = (await users.findUser(mia))!;
    expect(restored.name, 'Mia');
    expect(restored.avatar, '🦊');
    expect(restored.hidden, {LessonGroup.upTo1000});
    expect(restored.reviewHardTasks, isFalse);
    expect(restored.defaultTaskCount, 20);
    // The per-lesson choice travels too - it is the most specific level and
    // the easiest to lose without noticing.
    expect(
      await SettingsRepository(db)
          .watchLessonTaskCount(mia, 'times_7')
          .first,
      50,
    );

    final session = (await db.select(db.sessions).get()).single;
    expect(session.lessonId, 'times_7');
    expect(session.totalMs, 7300);
    expect(session.wrongAttempts, 1);
    expect(session.seed, 99);

    final attempts = await db.select(db.attempts).get();
    expect(attempts, hasLength(2));
    expect(attempts.first.operandA, 7);
    expect(attempts.first.op, 'mul');

    // The PIN travels with it, so a restore does not lock the parent out.
    expect(await SettingsRepository(db).checkAdminPin('4711'), isTrue);
    expect((await SettingsRepository(db).load()).defaultTaskCount, 30);
  });

  test('an import replaces, it does not merge', () async {
    await seedData();
    final json = await backup.export();

    await users.createUser(name: 'Fremd', avatar: '🐢', colorIndex: 3);
    await backup.import(json);

    // Ids from two tablets would collide, so a restore is a restore.
    expect((await users.allUsers()).map((u) => u.name), ['Mia', 'Tom']);
  });

  test('a foreign file is refused, not half-applied', () async {
    await seedData();
    final before = (await users.allUsers()).length;

    for (final bad in [
      'kein json',
      '{"format":"etwas anderes"}',
      jsonEncode({'format': 'mathe_trainer_backup', 'schemaVersion': 999}),
    ]) {
      expect(
        () => backup.import(bad),
        throwsA(isA<BackupFormatException>()),
        reason: bad,
      );
    }
    expect((await users.allUsers()).length, before);
  });

  test('a backup from an older version still restores', () async {
    // Written before the group and review columns existed.
    final old = jsonEncode({
      'format': 'mathe_trainer_backup',
      'schemaVersion': 1,
      'exportedAtMs': DateTime(2026, 1, 1).millisecondsSinceEpoch,
      'users': [
        {
          'id': 1,
          'name': 'Mia',
          'avatar': '🦊',
          'colorIndex': 0,
          'createdAtMs': 1,
        }
      ],
      'sessions': [],
      'attempts': [],
      'settings': [],
    });

    final summary = await backup.import(old);
    expect(summary.users, 1);
    final user = (await users.allUsers()).single;
    // The missing columns arrive at their defaults.
    expect(user.visibleGroups, LessonGroup.values);
    expect(user.reviewHardTasks, isTrue);
  });

  test('an empty database exports and restores without complaint', () async {
    final json = await backup.export();
    final summary = await backup.import(json);
    expect(summary.users, 0);
    expect(await users.allUsers(), isEmpty);
  });
}
