import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/assignment.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/admin/assignments_tab.dart';
import 'package:mathe_trainer/features/common/run_hints.dart';
import 'package:mathe_trainer/features/common/star_row.dart';
import 'package:mathe_trainer/features/result/result_screen.dart';
import 'package:mathe_trainer/features/lessons/assignment_tile.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/features/lessons/lesson_home_screen.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// A parent's assignment, as the child sees it: a card in "Deine Aufgaben",
/// a green tick once a run qualifies, sorted by deadline, and left out of
/// the recommendation right below it.
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
    mia = (await users.findUser(
        await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0)))!;
    container.read(activeUserProvider.notifier).select(mia);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<int> assign(
    String lessonId, {
    List<String>? lessonIds,
    AssignmentRhythm rhythm = AssignmentRhythm.daily,
    int runs = 1,
    int taskCount = 10,
    int minStars = 0,
    int minBolts = 0,
  }) =>
      container.read(assignmentRepositoryProvider).createAssignment(
            userId: mia.id,
            lessonIds: lessonIds ?? [lessonId],
            rhythm: rhythm,
            runs: runs,
            taskCount: taskCount,
            minStars: minStars,
            minBolts: minBolts,
          );

  Future<void> finishRun(
    String lessonId, {
    int taskCount = 10,
    int wrongAttempts = 0,
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
      completed: true,
      results: [
        for (var i = 0; i < taskCount; i++)
          TaskResult(
            task: const Task(
                a: 42, b: 35, op: Operation.add, form: TaskForm.result),
            elapsedMs: 5000,
            wrongAttempts: i == 0 ? wrongAttempts : 0,
          ),
      ],
    );
  }

  Future<void> pump(WidgetTester tester) async {
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

  /// The result screen for a run of [lessonId] that took [wrong] retries.
  Future<void> pumpResult(
    WidgetTester tester,
    String lessonId, {
    int wrong = 0,
    int taskCount = 10,
    int msPerTask = 3000,
  }) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: ResultScreen(
            lesson: lessonById(lessonId),
            sessionId: null,
            taskCount: taskCount,
            totalMs: taskCount * msPerTask,
            wrongAttempts: wrong,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('what the result screen says about the assignment', () {
    testWidgets('a run that misses the bar shows what the bar was',
        (tester) async {
      await assign('add_100_plain', minStars: 3, minBolts: 2);
      // Six retries over ten tasks is worth one star, not three.
      await pumpResult(tester, 'add_100_plain', wrong: 6);

      expect(find.textContaining('reicht für deine Aufgabe noch nicht'),
          findsOneWidget);
      // The bar itself, drawn in the symbols it is measured in: three stars
      // wanted next to the one that was earned.
      final rows = tester.widgetList<StarRow>(find.byType(StarRow));
      expect(rows.any((r) => r.earned == 3), isTrue);
      expect(tester.widgetList<BoltRow>(find.byType(BoltRow))
          .any((r) => r.earned == 2), isTrue);
    });

    testWidgets('a run that clears it says how far along it is',
        (tester) async {
      await assign('add_100_plain', runs: 3, minStars: 2);
      await finishRun('add_100_plain');
      await pumpResult(tester, 'add_100_plain');

      expect(find.textContaining('Zählt für deine Aufgabe: 1 von 3'),
          findsOneWidget);
    });

    testWidgets('and the last one says it is done', (tester) async {
      await assign('add_100_plain', minStars: 2);
      await finishRun('add_100_plain');
      await pumpResult(tester, 'add_100_plain');

      expect(find.text('Aufgabe geschafft!'), findsOneWidget);
    });

    testWidgets('and the line fits on a 10" tablet', (tester) async {
      // The column on that screen cannot grow: the hint takes the space the
      // gap below it would have had, and nothing more.
      await assign('add_100_plain', runs: 3, minStars: 3, minBolts: 3);
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(),
            home: ResultScreen(
              lesson: lessonById('add_100_plain'),
              sessionId: null,
              taskCount: 10,
              totalMs: 30000,
              wrongAttempts: 6,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(AssignmentGoalHint), findsOneWidget);
    });

    testWidgets('a lesson without an assignment says nothing about one',
        (tester) async {
      await pumpResult(tester, 'add_100_plain');

      expect(find.byType(AssignmentGoalHint), findsNothing);
    });
  });

  group('an assignment over several lessons', () {
    testWidgets('gives the child one card per lesson', (tester) async {
      await assign('add_100_plain',
          lessonIds: ['add_100_plain', 'money_add']);
      await pump(tester);

      final tiles = tester
          .widgetList<AssignmentTile>(find.byType(AssignmentTile))
          .toList();
      expect(tiles.map((t) => t.lesson.id),
          ['add_100_plain', 'money_add']);
      // Nothing about the card changed: each one is its own, with its own
      // count, exactly as when an assignment could only name one lesson.
      expect(find.textContaining('0/1'), findsNWidgets(2));
    });

    testWidgets('is only done when every lesson is', (tester) async {
      await assign('add_100_plain',
          lessonIds: ['add_100_plain', 'money_add']);
      await finishRun('add_100_plain');
      await pump(tester);

      // One ticked off, one still open.
      expect(find.text('geschafft'), findsOneWidget);
      expect(find.textContaining('0/1'), findsOneWidget);

      await finishRun('money_add');
      await pump(tester);
      expect(find.text('geschafft'), findsNWidgets(2));
    });

    test('the stored list keeps catalogue order, whatever went in', () {
      expect(lessonIdsToStored(['money_add', 'add_100_plain']),
          'add_100_plain,money_add');
      // An id this version no longer has is skipped rather than kept.
      expect(lessonIdsByName('add_100_plain,bruchrechnen'),
          ['add_100_plain']);
    });
  });

  testWidgets('the parent list says which lesson kept falling short',
      (tester) async {
    // Two lessons, one of them done yesterday and the other not. The dot
    // strip says a period was missed; only this says by which lesson.
    final id = await assign('add_100_plain',
        lessonIds: ['add_100_plain', 'money_add']);
    await container.read(assignmentRepositoryProvider).updateAssignment(
          id,
          lessonIds: const ['add_100_plain', 'money_add'],
          rhythm: AssignmentRhythm.daily,
          runs: 1,
          taskCount: 10,
          minStars: 0,
          minBolts: 0,
        );
    await finishRun('add_100_plain');
    // Move both the assignment and the run back a day, so today's period is
    // fresh and yesterday's is closed.
    final yesterday =
        DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;
    await db.customStatement(
        'UPDATE assignments SET created_at_ms = $yesterday');
    await db.customStatement(
        'UPDATE sessions SET finished_at_ms = $yesterday');

    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const Scaffold(body: AssignmentsTab()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // One lesson held yesterday, the other did not.
    expect(find.textContaining('davor 1 von 1 Tagen'), findsOneWidget);
    expect(find.textContaining('davor 0 von 1 Tagen'), findsOneWidget);
  });

  group('a plan of single assignments', () {
    Future<int> assignOnce(
      String lessonId, {
      required DateTime on,
      bool carryOver = false,
    }) =>
        container.read(assignmentRepositoryProvider).createAssignment(
              userId: mia.id,
              lessonIds: [lessonId],
              rhythm: AssignmentRhythm.daily,
              repeats: false,
              onDayMs: on.millisecondsSinceEpoch,
              carryOver: carryOver,
              runs: 1,
              taskCount: 10,
              minStars: 0,
              minBolts: 0,
            );

    testWidgets('today shows today, not tomorrow', (tester) async {
      final today = DateTime.now();
      await assignOnce('add_100_plain', on: today);
      await assignOnce('money_add',
          on: today.add(const Duration(days: 1)));
      await pump(tester);

      final tiles = tester
          .widgetList<AssignmentTile>(find.byType(AssignmentTile))
          .toList();
      expect(tiles.map((t) => t.lesson.id), ['add_100_plain']);
    });

    testWidgets('yesterday is gone unless it is carried over',
        (tester) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await assignOnce('add_100_plain', on: yesterday);
      await pump(tester);
      expect(find.byType(AssignmentTile), findsNothing);

      await assignOnce('money_add', on: yesterday, carryOver: true);
      await pump(tester);
      final tiles = tester
          .widgetList<AssignmentTile>(find.byType(AssignmentTile))
          .toList();
      expect(tiles.map((t) => t.lesson.id), ['money_add']);
      expect(find.textContaining('noch offen'), findsOneWidget);
    });

    testWidgets('making up a carried-over one takes the card away',
        (tester) async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await assignOnce('add_100_plain', on: yesterday, carryOver: true);
      await pump(tester);
      expect(find.byType(AssignmentTile), findsOneWidget);

      await finishRun('add_100_plain');
      await pump(tester);
      expect(find.byType(AssignmentTile), findsNothing);
    });
  });

  // A plain test, not a widget one: awaiting a drift stream's `.first`
  // inside testWidgets deadlocks because nothing pumps it - the same trap
  // assignmentForLessonProvider works around in providers.dart.
  test('the parent list reads as a plan, by day', () async {
    // Created in the wrong order on purpose: what orders the list is the
    // day an assignment belongs to, not the moment it was typed in.
    final today = DateTime.now();
    await container.read(assignmentRepositoryProvider).createAssignment(
          userId: mia.id,
          lessonIds: const ['money_add'],
          rhythm: AssignmentRhythm.daily,
          repeats: false,
          onDayMs: today.millisecondsSinceEpoch,
          runs: 1,
          taskCount: 10,
          minStars: 0,
          minBolts: 0,
        );
    await container.read(assignmentRepositoryProvider).createAssignment(
          userId: mia.id,
          lessonIds: const ['add_100_plain'],
          rhythm: AssignmentRhythm.daily,
          repeats: false,
          onDayMs:
              today.add(const Duration(days: 3)).millisecondsSinceEpoch,
          runs: 1,
          taskCount: 10,
          minStars: 0,
          minBolts: 0,
        );

    final list = await container
        .read(assignmentRepositoryProvider)
        .watchAssignments(userId: mia.id)
        .first;
    expect(list.map((a) => a.lessonIds.single),
        ['add_100_plain', 'money_add']);
  });

  testWidgets('a single assignment gets a verdict, not a tally',
      (tester) async {
    // "Geschafft an 0 von 1 Tagen" plus one dot is a repetition statistic
    // for something that happened once.
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await container.read(assignmentRepositoryProvider).createAssignment(
          userId: mia.id,
          lessonIds: const ['add_100_plain'],
          rhythm: AssignmentRhythm.daily,
          repeats: false,
          onDayMs: yesterday.millisecondsSinceEpoch,
          runs: 1,
          taskCount: 10,
          minStars: 0,
          minBolts: 0,
        );

    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const Scaffold(body: AssignmentsTab()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Verpasst'), findsOneWidget);
    expect(find.textContaining('von 1 Tagen'), findsNothing);
  });

  group('changing an assignment', () {
    Future<void> pumpTab(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1600, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(),
            home: const Scaffold(body: AssignmentsTab()),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('raising the bar takes the tick away again', (tester) async {
      // Two stars asked for, two stars delivered: done.
      final id = await assign('add_100_plain', minStars: 2);
      await finishRun('add_100_plain', wrongAttempts: 2);
      await pump(tester);
      expect(find.text('geschafft'), findsOneWidget);

      // The parent raises it to three. Nothing about an assignment is
      // frozen, so the same run is judged again - and no longer clears it.
      await container.read(assignmentRepositoryProvider).updateAssignment(
            id,
            lessonIds: const ['add_100_plain'],
            rhythm: AssignmentRhythm.daily,
            runs: 1,
            taskCount: 10,
            minStars: 3,
            minBolts: 0,
          );
      await pump(tester);
      expect(find.text('geschafft'), findsNothing);
      expect(find.textContaining('0/1'), findsOneWidget);
    });

    testWidgets('and lowering it hands the tick back', (tester) async {
      final id = await assign('add_100_plain', minStars: 3);
      await finishRun('add_100_plain', wrongAttempts: 2);
      await pump(tester);
      expect(find.text('geschafft'), findsNothing);

      await container.read(assignmentRepositoryProvider).updateAssignment(
            id,
            lessonIds: const ['add_100_plain'],
            rhythm: AssignmentRhythm.daily,
            runs: 1,
            taskCount: 10,
            minStars: 2,
            minBolts: 0,
          );
      await pump(tester);
      expect(find.text('geschafft'), findsOneWidget);
    });

    testWidgets('the dialog opens on the values that are stored',
        (tester) async {
      await assign('money_add', runs: 3, taskCount: 20, minStars: 2);
      await pumpTab(tester);

      await tester.tap(find.text('Ändern'));
      await tester.pumpAndSettle();

      expect(find.text('Aufgabe ändern'), findsOneWidget);
      // Child and lesson are shown but not offered: those two are what the
      // assignment is.
      expect(find.text('Geld zusammenzählen · ${groupTitle(
          LessonGroup.everyday)}'), findsWidgets);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      expect(find.text('Speichern'), findsOneWidget);
    });

    testWidgets('an ended assignment cannot be changed any more',
        (tester) async {
      final id = await assign('add_100_plain');
      await container
          .read(assignmentRepositoryProvider)
          .endAssignment(id, DateTime.now().millisecondsSinceEpoch);
      await pumpTab(tester);

      expect(find.text('Ändern'), findsNothing);
    });
  });

  testWidgets('the parent list writes the group the way the catalogue does',
      (tester) async {
    // German capitalises its nouns, and a group title is a name. The three
    // places that print one beside a lesson title used to lowercase it, so
    // "Uhrzeit und Geld" arrived as "uhrzeit und geld".
    await assign('money_add');

    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const Scaffold(body: AssignmentsTab()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Geld zusammenzählen · ${groupTitle(LessonGroup.everyday)}'),
      findsOneWidget,
    );
  });

  testWidgets('an assignment shows up as a card in "Deine Aufgaben"',
      (tester) async {
    await assign('add_100_plain');
    await pump(tester);

    expect(find.text('Deine Aufgaben'), findsOneWidget);
    expect(find.text('Plus ohne Zehnerübergang'), findsWidgets);
  });

  testWidgets('a qualifying run ticks the card off', (tester) async {
    await assign('add_100_plain', runs: 1, taskCount: 10, minStars: 2);
    await finishRun('add_100_plain');
    await pump(tester);

    expect(find.text('geschafft'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('a run under the star requirement leaves it open',
      (tester) async {
    await assign('add_100_plain', runs: 1, taskCount: 10, minStars: 3);
    // Six wrong out of ten: an error rate that is only worth one star.
    await finishRun('add_100_plain', wrongAttempts: 6);
    await pump(tester);

    expect(find.text('geschafft'), findsNothing);
    expect(find.textContaining('0/1'), findsOneWidget);
  });

  testWidgets('the daily card comes before the weekly one', (tester) async {
    await assign('add_100_plain', rhythm: AssignmentRhythm.weekly);
    await assign('add_100_carry');
    await pump(tester);

    final tiles = tester
        .widgetList<AssignmentTile>(find.byType(AssignmentTile))
        .toList();
    expect(tiles.map((t) => t.lesson.id).toList(),
        ['add_100_carry', 'add_100_plain']);
  });

  testWidgets('two cards due the same day keep the older one in front',
      (tester) async {
    // Both are due at the end of today, so the deadline cannot separate
    // them. The one that has been standing longer goes first.
    final first = await assign('add_100_plain');
    final second = await assign('add_100_carry');
    expect(first, lessThan(second));
    await pump(tester);

    final tiles = tester
        .widgetList<AssignmentTile>(find.byType(AssignmentTile))
        .toList();
    expect(tiles.map((t) => t.lesson.id).toList(),
        ['add_100_plain', 'add_100_carry']);
  });

  testWidgets('a met card sinks below an open one, whatever its own deadline',
      (tester) async {
    // Due sooner, but already met - it must still fall behind the open one.
    await assign('add_100_carry');
    await finishRun('add_100_carry');
    await assign('add_100_plain', rhythm: AssignmentRhythm.weekly);
    await pump(tester);

    final tiles = tester
        .widgetList<AssignmentTile>(find.byType(AssignmentTile))
        .toList();
    expect(tiles.map((t) => t.lesson.id).toList(),
        ['add_100_plain', 'add_100_carry']);
  });

  testWidgets(
      'a lesson with an open assignment is not suggested a second time',
      (tester) async {
    // The very lesson a fresh profile would otherwise recommend first.
    await assign('count_pictures');
    await pump(tester);

    // The recommendation card names its lesson together with its group -
    // a combination only the card itself writes, so this is unambiguous.
    expect(
      find.text('Wie viele? (Reihe) · Erste Schritte'),
      findsNothing,
      reason: 'already has a card of its own above',
    );
    expect(find.text('Wie viele? (Wolke) · Erste Schritte'), findsOneWidget);
  });
}
