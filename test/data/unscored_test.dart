import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/data/repositories/session_repository.dart';
import 'package:mathe_trainer/data/repositories/stats_repository.dart';
import 'package:mathe_trainer/data/repositories/user_repository.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';

void main() {
  test('the unscored SQL list is real ids, and the queries run', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final id = await UserRepository(db)
        .createUser(name: 'Mia', avatar: 'M', colorIndex: 0);
    final sessions = SessionRepository(db);
    final s = await sessions.startSession(
        userId: id, lessonId: 'count_pictures', taskCount: 10, seed: 1);
    await sessions.finishSession(
      sessionId: s,
      completed: true,
      results: [
        for (var i = 0; i < 10; i++)
          const TaskResult(
            task: Task(a: 3, b: 1, op: Operation.add, form: TaskForm.quantity),
            elapsedMs: 5000,
            wrongAttempts: 3,
          ),
      ],
    );

    final stats = StatsRepository(db);
    // Thirty wrong attempts over ten tasks: one star, exactly as anywhere
    // else. Not being timed says nothing about how carefully it was worked.
    expect(
        (await stats.watchLessonStats(id).first)['count_pictures']!.bestStars,
        1);
    expect((await stats.watchStarTotals().first)[id], 1);
    // And it never turns up in a ranking.
    expect(await stats.watchLeaderboard('count_pictures').first, isEmpty);
    expect(await stats.watchAllLeaderboards().first, isEmpty);
  });
}
