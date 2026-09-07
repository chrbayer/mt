import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/scoring.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/admin/reset_stars_dialog.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// Stars are stored rather than worked out from the runs, so that a parent
/// can hand a group back without touching the times behind it.
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
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> run(
    String lessonId, {
    int wrong = 0,
    int msPerTask = 4000,
    int taskCount = 10,
    bool completed = true,
  }) async {
    final sessions = container.read(sessionRepositoryProvider);
    final id = await sessions.startSession(
      userId: mia.id,
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
            task: Task(a: 47, b: 38, op: Operation.add, form: TaskForm.result),
            elapsedMs: msPerTask,
            wrongAttempts: i == 0 ? wrong : 0,
          ),
      ],
    );
  }

  Future<int> starsOf(String lessonId) async {
    final stats =
        await container.read(statsRepositoryProvider).watchLessonStats(mia.id).first;
    return stats[lessonId]?.bestStars ?? 0;
  }

  Future<int> total() async =>
      (await container.read(statsRepositoryProvider).watchStarTotals().first)[
          mia.id] ??
      0;

  group('earning', () {
    test('a run writes down what it was worth', () async {
      await run('add_100_carry');
      expect(await starsOf('add_100_carry'), maxStars);
      expect(await total(), maxStars);
    });

    test('only ever upwards - a bad run takes nothing away', () async {
      await run('add_100_carry');
      await run('add_100_carry', wrong: 9);
      expect(await starsOf('add_100_carry'), maxStars);
    });

    test('but a better run does raise it', () async {
      await run('add_100_carry', wrong: 9);
      expect(await starsOf('add_100_carry'), 1);
      await run('add_100_carry', wrong: 2);
      expect(await starsOf('add_100_carry'), 2);
      await run('add_100_carry');
      expect(await starsOf('add_100_carry'), maxStars);
    });

    test('an abandoned run earns nothing', () async {
      await run('add_100_carry', completed: false);
      expect(await starsOf('add_100_carry'), 0);
    });

    test('a run too short to count earns nothing', () async {
      await run('add_100_carry', taskCount: 5);
      expect(await starsOf('add_100_carry'), 0);
    });

    test('the first steps earn theirs for finishing', () async {
      await run('count_pictures', wrong: 10);
      expect(await starsOf('count_pictures'), maxStars);
    });
  });

  group('resetting one group', () {
    test('takes the stars and leaves everything else', () async {
      await run('add_100_carry', msPerTask: 3000);
      await run('times_7', msPerTask: 3000);

      final stats = container.read(statsRepositoryProvider);
      final before = await stats.watchLessonStats(mia.id).first;
      expect(before['add_100_carry']!.bestStars, maxStars);

      await stats.resetStarsInGroup(mia.id, LessonGroup.upTo100);
      final after = await stats.watchLessonStats(mia.id).first;

      expect(after['add_100_carry']!.bestStars, 0);
      // Everything that comes from the times is untouched.
      expect(after['add_100_carry']!.bestScoreMs,
          before['add_100_carry']!.bestScoreMs);
      expect(after['add_100_carry']!.bestBolts,
          before['add_100_carry']!.bestBolts);
      expect(after['add_100_carry']!.runs, before['add_100_carry']!.runs);
      expect(after['add_100_carry']!.errorRate,
          before['add_100_carry']!.errorRate);
      // And the leaderboard still knows the run.
      expect(await stats.watchLeaderboard('add_100_carry').first, hasLength(1));
    });

    test('leaves the other groups alone', () async {
      await run('add_100_carry');
      await run('times_7');
      expect(await total(), 2 * maxStars);

      await container
          .read(statsRepositoryProvider)
          .resetStarsInGroup(mia.id, LessonGroup.upTo100);

      expect(await starsOf('times_7'), maxStars);
      expect(await total(), maxStars);
    });

    test('they can be earned again afterwards', () async {
      await run('add_100_carry');
      await container
          .read(statsRepositoryProvider)
          .resetStarsInGroup(mia.id, LessonGroup.upTo100);
      expect(await starsOf('add_100_carry'), 0);

      await run('add_100_carry');
      expect(await starsOf('add_100_carry'), maxStars);
    });

    test('a group nobody has touched simply stays at zero', () async {
      await container
          .read(statsRepositoryProvider)
          .resetStarsInGroup(mia.id, LessonGroup.upTo1000);
      expect(await total(), 0);
    });
  });

  group('the dialog', () {
    Future<void> pump(WidgetTester tester) async {
      tester.view.physicalSize = const Size(2400, 1500);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(),
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => ResetStarsDialog.show(context, mia),
                child: const Text('auf'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('auf'));
      await tester.pumpAndSettle();
    }

    /// The row of one group. Several groups hold 21 stars, so the count
    /// alone is not enough to point at one of them.
    Finder rowOf(LessonGroup group) => find
        .ancestor(
          of: find.text(groupTitle(group)),
          matching: find.byType(Row),
        )
        .first;

    Finder resetButtonOf(LessonGroup group) => find.descendant(
          of: rowOf(group),
          matching: find.widgetWithText(OutlinedButton, 'Zurücksetzen'),
        );

    testWidgets('shows what is standing and hands it back', (tester) async {
      await run('add_100_carry');
      await pump(tester);

      expect(
        find.descendant(
          of: rowOf(LessonGroup.upTo100),
          matching: find.text('3 von 21 Sternen'),
        ),
        findsOneWidget,
      );

      await tester.tap(resetButtonOf(LessonGroup.upTo100));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Zurücksetzen'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: rowOf(LessonGroup.upTo100),
          matching: find.text('0 von 21 Sternen'),
        ),
        findsOneWidget,
      );
      expect(await starsOf('add_100_carry'), 0);
    });

    testWidgets('an empty group cannot be reset', (tester) async {
      await run('add_100_carry');
      await pump(tester);

      // Nothing standing in the times tables, so nothing to hand back.
      expect(
        tester.widget<OutlinedButton>(resetButtonOf(LessonGroup.timesTables))
            .onPressed,
        isNull,
      );
      expect(
        tester.widget<OutlinedButton>(resetButtonOf(LessonGroup.upTo100))
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('cancelling changes nothing', (tester) async {
      await run('add_100_carry');
      await pump(tester);

      await tester.tap(resetButtonOf(LessonGroup.upTo100));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(OutlinedButton, 'Abbrechen'));
      await tester.pumpAndSettle();

      expect(await starsOf('add_100_carry'), maxStars);
    });
  });
}
