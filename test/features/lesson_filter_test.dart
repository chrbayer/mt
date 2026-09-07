import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/lesson_filter.dart';
import 'package:mathe_trainer/domain/practice_limit.dart';
import 'package:mathe_trainer/data/repositories/user_repository.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/lessons/lesson_home_screen.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// Hiding what is done turns a catalogue of seventy-five into a to-do list.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late User mia;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    final users = container.read(userRepositoryProvider);
    final id = await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
    mia = (await users.findUser(id))!;
    container.read(activeUserProvider.notifier).select(mia);
    // This file is about the catalogue, not about time: the fabricated
    // practice below runs into the default caps otherwise.
    await container.read(settingsRepositoryProvider).setPracticeLimits(
          const PracticeLimits(
            stretchMinutes: 0,
            breakMinutes: 15,
            dailyMinutes: 0,
          ),
        );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// A clean run of [lessonId] at [msPerTask] - fast enough for three bolts
  /// when it is well under the lesson's target.
  Future<void> run(String lessonId, {required int msPerTask}) async {
    final sessions = container.read(sessionRepositoryProvider);
    final id = await sessions.startSession(
      userId: mia.id,
      lessonId: lessonId,
      taskCount: 10,
      seed: 1,
    );
    await sessions.finishSession(
      sessionId: id,
      completed: true,
      results: [
        for (var i = 0; i < 10; i++)
          TaskResult(
            task: Task(a: 47, b: 38, op: Operation.add, form: TaskForm.result),
            elapsedMs: msPerTask,
            wrongAttempts: 0,
          ),
      ],
    );
  }

  Future<void> setFilter(LessonFilter filter) async {
    await container.read(userRepositoryProvider).setLessonFilter(mia.id, filter);
    container.read(activeUserProvider.notifier).select(
          (await container.read(userRepositoryProvider).findUser(mia.id))!,
        );
  }

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(2400, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const LessonHomeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  /// Group headings are unique; lesson titles are not - "Plus mit
  /// Zehnerübergang" exists in three number ranges. So the screen is checked
  /// by what a whole group does, and the per-lesson rule by its own test.
  Future<bool> showsGroup(WidgetTester tester, LessonGroup group) async {
    final heading = find.text(groupTitle(group));
    for (var i = 0; i < 30; i++) {
      if (heading.evaluate().isNotEmpty) return true;
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pump();
    }
    return heading.evaluate().isNotEmpty;
  }

  /// Every lesson of "Uhrzeit und Geld", done at the given pace.
  Future<void> finishEveryday({required int msPerTask}) async {
    for (final lesson in lessonsInGroup(LessonGroup.everyday)) {
      await run(lesson.id, msPerTask: msPerTask);
    }
  }

  testWidgets('nothing is hidden until the filter is set', (tester) async {
    await finishEveryday(msPerTask: 1000);
    await pump(tester);

    expect(await showsGroup(tester, LessonGroup.everyday), isTrue);
  });

  testWidgets('three stars are enough to drop out of the list',
      (tester) async {
    // Clean but slow: three stars, no bolts.
    await finishEveryday(msPerTask: 60000);
    await setFilter(LessonFilter.mastered);
    await pump(tester);

    expect(await showsGroup(tester, LessonGroup.everyday), isFalse);
  });

  testWidgets('the finer setting keeps what is right but still slow',
      (tester) async {
    await finishEveryday(msPerTask: 60000);
    await setFilter(LessonFilter.perfected);
    await pump(tester);

    expect(await showsGroup(tester, LessonGroup.everyday), isTrue,
        reason: 'three stars, but no bolts - there is still something to do');
  });

  testWidgets('and drops it once it is quick as well', (tester) async {
    await finishEveryday(msPerTask: 1000);
    await setFilter(LessonFilter.perfected);
    await pump(tester);

    expect(await showsGroup(tester, LessonGroup.everyday), isFalse);
  });

  testWidgets('an untouched group always stays', (tester) async {
    await setFilter(LessonFilter.mastered);
    await pump(tester);

    expect(await showsGroup(tester, LessonGroup.upTo1000), isTrue);
  });

  testWidgets('the first steps are never filtered away', (tester) async {
    // Ten wrong out of ten and still three stars there - the whole group
    // would vanish after a single run.
    for (final lesson in lessonsInGroup(LessonGroup.firstSteps)) {
      final sessions = container.read(sessionRepositoryProvider);
      final id = await sessions.startSession(
        userId: mia.id,
        lessonId: lesson.id,
        taskCount: 10,
        seed: 1,
      );
      await sessions.finishSession(
        sessionId: id,
        completed: true,
        results: [
          for (var i = 0; i < 10; i++)
            TaskResult(
              task:
                  Task(a: 3, b: 1, op: Operation.add, form: TaskForm.quantity),
              elapsedMs: 1000,
              wrongAttempts: 1,
            ),
        ],
      );
    }
    await setFilter(LessonFilter.mastered);
    await pump(tester);

    expect(await showsGroup(tester, LessonGroup.firstSteps), isTrue);
  });

  testWidgets('the filter can be changed from the catalogue itself',
      (tester) async {
    await finishEveryday(msPerTask: 60000);
    await pump(tester);

    await tester.tap(find.byIcon(Icons.filter_list_off));
    await tester.pumpAndSettle();
    await tester.tap(find.text(lessonFilterTitle(LessonFilter.mastered)));
    await tester.pumpAndSettle();

    expect(
      (await container.read(userRepositoryProvider).findUser(mia.id))!.filter,
      LessonFilter.mastered,
    );
    expect(await showsGroup(tester, LessonGroup.everyday), isFalse);
  });

  testWidgets('with everything hidden the screen says so', (tester) async {
    // One group left, and every lesson of it filtered away.
    await container.read(userRepositoryProvider).setHiddenGroups(
          mia.id,
          LessonGroup.values.where((g) => g != LessonGroup.everyday).toSet(),
        );
    await finishEveryday(msPerTask: 1000);
    await setFilter(LessonFilter.mastered);
    await pump(tester);

    expect(find.text('Alles geschafft!'), findsOneWidget);
  });
}
