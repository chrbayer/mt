import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/leaderboard/leaderboard_screen.dart';
import 'package:mathe_trainer/features/lessons/lesson_home_screen.dart';
import 'package:mathe_trainer/features/common/star_row.dart';
import 'package:mathe_trainer/features/practice/practice_screen.dart';
import 'package:mathe_trainer/features/practice/widgets/task_display.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// The path from the lesson tile through the start sheet into a run. This was
/// broken once: the sheet looked up its Navigator *after* popping itself, so
/// both buttons did nothing at all.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    final users = container.read(userRepositoryProvider);
    final id = await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
    container.read(activeUserProvider.notifier).select((await users.findUser(id))!);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
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
    await tester.pumpAndSettle();
  }

  /// Off-screen slivers are not built at all, so a tile further down has to
  /// be scrolled into existence before it can be found, let alone tapped.
  ///
  /// The check runs on the unfiltered finder: `.first` on an empty one throws
  /// rather than reporting emptiness.
  Future<Finder> scrollToText(WidgetTester tester, String text) async {
    final all = find.text(text);
    for (var i = 0; i < 15 && all.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();
    }
    final target = all.first;
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    return target;
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.tap(await scrollToText(tester, 'Plus mit Zehnerübergang'));
    await tester.pumpAndSettle();
    expect(find.text('Wie viele Aufgaben?'), findsOneWidget);
  }

  testWidgets('the explanation is hidden until the help icon is tapped',
      (tester) async {
    await pumpHome(tester);
    await openSheet(tester);

    const explanation = 'Die Einer ergeben zusammen 10 oder mehr - '
        'ein Zehner wandert weiter.';
    expect(find.text(explanation), findsNothing);

    await tester.tap(find.byTooltip('Was heißt das?'));
    await tester.pumpAndSettle();
    expect(find.text(explanation), findsOneWidget);

    await tester.tap(find.byTooltip('Was heißt das?'));
    await tester.pumpAndSettle();
    expect(find.text(explanation), findsNothing);
  });

  testWidgets("\"Los geht's\" actually starts the run", (tester) async {
    await pumpHome(tester);
    await openSheet(tester);

    await tester.tap(find.text("Los geht's"));
    await tester.pumpAndSettle();

    expect(find.byType(PracticeScreen), findsOneWidget);
    expect(find.byType(TaskDisplay), findsOneWidget);
  });

  testWidgets('the chosen task count is used and remembered', (tester) async {
    await pumpHome(tester);
    await openSheet(tester);

    await tester.tap(find.text('30'));
    await tester.pump();
    await tester.tap(find.text("Los geht's"));
    await tester.pumpAndSettle();

    expect(
      tester.widget<PracticeScreen>(find.byType(PracticeScreen)).taskCount,
      30,
    );
    // Remembered for this lesson, not as everyone's default.
    final prefs = await db.select(db.lessonPreferences).get();
    expect(prefs.single.lessonId, 'add_20_carry');
    expect(prefs.single.taskCount, 30);
    expect((await container.read(settingsRepositoryProvider).load())
        .defaultTaskCount, 10);
  });

  testWidgets('"Bestenliste" actually opens the leaderboard', (tester) async {
    await pumpHome(tester);
    await openSheet(tester);

    await tester.tap(find.text('Bestenliste'));
    await tester.pumpAndSettle();

    expect(find.byType(LeaderboardScreen), findsOneWidget);
  });

  testWidgets('all four number ranges are offered, smallest first',
      (tester) async {
    await pumpHome(tester);

    // Off-screen slivers are not built, so each heading only exists once it
    // has been scrolled to.
    expect(find.text('Erste Schritte'), findsOneWidget);
    for (final heading in [
      'Bis 10',
      'Bis 20',
      'Bis 100',
      'Bis 1000',
      'Einmaleins',
      'Mal und Geteilt',
      'Uhrzeit und Geld',
    ]) {
      for (var i = 0; i < 12 && find.text(heading).evaluate().isEmpty; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -400));
        await tester.pumpAndSettle();
      }
      expect(find.text(heading), findsOneWidget, reason: heading);
    }
  });

  testWidgets('a switched-off group is not offered to that child',
      (tester) async {
    final users = container.read(userRepositoryProvider);
    final id = container.read(activeUserProvider)!.id;
    await users.setHiddenGroups(id, {
      LessonGroup.upTo100,
      LessonGroup.upTo1000,
      LessonGroup.timesTables,
      LessonGroup.timesAndDivision,
    });
    container.read(activeUserProvider.notifier).select((await users.findUser(id))!);

    await pumpHome(tester);

    expect(find.text('Erste Schritte'), findsOneWidget);
    await scrollToText(tester, 'Bis 10');
    expect(find.text('Bis 10'), findsOneWidget);
    // Scrolling to the bottom must not turn up the hidden ones.
    for (var i = 0; i < 6; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();
    }
    expect(find.text('Bis 100'), findsNothing);
    expect(find.text('Einmaleins'), findsNothing);
  });

  testWidgets('a child with no group at all is told what is wrong',
      (tester) async {
    final users = container.read(userRepositoryProvider);
    final id = container.read(activeUserProvider)!.id;
    await users.setHiddenGroups(id, LessonGroup.values.toSet());
    container.read(activeUserProvider.notifier).select((await users.findUser(id))!);

    await pumpHome(tester);

    expect(find.textContaining('kein Bereich freigeschaltet'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('every tile wears its stars, empty ones included',
      (tester) async {
    await pumpHome(tester);
    await scrollToText(tester, 'Wie viele? (Reihe)');

    // Nothing practised yet: every tile shows three outlines, which is what
    // says "still open" without a word. Scoped to StarRow, because the total
    // badge carries a star of its own.
    expect(
      find.descendant(
        of: find.byType(StarRow),
        matching: find.byIcon(Icons.star_rounded),
      ),
      findsNothing,
    );
    expect(find.byIcon(Icons.star_outline_rounded), findsWidgets);
    expect(find.text('noch nicht geübt'), findsWidgets);
    expect(find.textContaining('0 von '), findsOneWidget);
  });

  testWidgets('the total counts a lesson once, however often it is played',
      (tester) async {
    final user = container.read(activeUserProvider)!;
    final sessions = container.read(sessionRepositoryProvider);

    Future<void> run(String lessonId, int wrong) async {
      final id = await sessions.startSession(
        userId: user.id,
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
              task: const Task(
                  a: 4, b: 3, op: Operation.add, form: TaskForm.result),
              elapsedMs: 3000,
              wrongAttempts: i < wrong ? 1 : 0,
            ),
        ],
      );
    }

    // Three clean runs of one lesson are still three stars.
    await run('partners_of_ten', 0);
    await run('partners_of_ten', 0);
    await run('partners_of_ten', 0);
    await pumpHome(tester);
    expect(find.textContaining('3 von '), findsOneWidget);

    // A second lesson, two stars: 20 % wrong.
    await run('add_10', 2);
    await pumpHome(tester);
    expect(find.textContaining('5 von '), findsOneWidget);

    // Both lessons live in "Bis 10", which starts below the fold.
    await scrollToText(tester, 'Verliebte Zahlen');
    expect(
      find.descendant(
        of: find.byType(StarRow),
        matching: find.byIcon(Icons.star_rounded),
      ),
      findsNWidgets(5),
    );
  });

  testWidgets('the very first lesson is the gentlest one', (tester) async {
    await pumpHome(tester);

    final heading = tester.getRect(find.text('Erste Schritte'));
    final first = tester.getRect(find.text('Wie viele? (Reihe)'));
    expect(first.top, greaterThan(heading.top));
    expect(first.left, lessThan(400));
  });
}
