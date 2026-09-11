import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/data/repositories/session_repository.dart';
import 'package:mathe_trainer/data/repositories/user_repository.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';

/// The daily cap from #16 has to step aside for the one lesson an open
/// assignment is measured against, but only that one, and only until its
/// goal is met - see `SessionRepository.finishSession`'s `servesAssignment`.
void main() {
  late AppDatabase db;
  late SessionRepository sessions;
  late int mia;

  const lesson = 'add_100_plain';
  const otherLesson = 'add_100_carry';

  int dayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    sessions = SessionRepository(db);
    mia = await UserRepository(db)
        .createUser(name: 'Mia', avatar: 'M', colorIndex: 0);
  });
  tearDown(() => db.close());

  Future<int> run({
    required String lessonId,
    bool servesAssignment = false,
    int limit = 3,
  }) async {
    final id = await sessions.startSession(
      userId: mia,
      lessonId: lessonId,
      taskCount: 10,
      seed: 1,
    );
    await sessions.finishSession(
      sessionId: id,
      completed: true,
      scoredRunLimit: limit,
      dayStartMs: dayStart(),
      servesAssignment: servesAssignment,
      results: [
        for (var i = 0; i < 10; i++)
          const TaskResult(
            task: Task(a: 42, b: 35, op: Operation.add, form: TaskForm.result),
            elapsedMs: 5000,
            wrongAttempts: 0,
          ),
      ],
    );
    return id;
  }

  Future<bool> scored(int sessionId) async =>
      (await sessions.sessionById(sessionId))!.scored;

  test('the fourth run of the assigned lesson still counts while open',
      () async {
    for (var i = 0; i < 3; i++) {
      expect(await scored(await run(lessonId: lesson, servesAssignment: true)),
          isTrue);
    }
    // Without the assignment this fourth run would be past the cap.
    expect(
      await scored(await run(lessonId: lesson, servesAssignment: true)),
      isTrue,
      reason: 'the assignment suspends the cap for this lesson',
    );
  });

  test('a different lesson is not covered by the same assignment', () async {
    for (var i = 0; i < 3; i++) {
      await run(lessonId: otherLesson, servesAssignment: false);
    }
    expect(
      await scored(await run(lessonId: otherLesson, servesAssignment: false)),
      isFalse,
      reason: "the assignment only ever names one lesson",
    );
  });

  test('once the goal is met the ordinary cap applies again', () async {
    // The three runs the cap allows, with the assignment already met by
    // then - servesAssignment is what openAssignmentProvider would answer,
    // and once the goal is met that answer turns false.
    for (var i = 0; i < 3; i++) {
      await run(lessonId: lesson, servesAssignment: false);
    }
    expect(
      await scored(await run(lessonId: lesson, servesAssignment: false)),
      isFalse,
      reason: 'the fourth run is past the ordinary cap',
    );
  });
}
