import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/scoring.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/practice/practice_screen.dart';
import 'package:mathe_trainer/features/result/result_screen.dart';
import 'package:mathe_trainer/features/practice/widgets/task_display.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// Drives the real practice screen through a whole run, the way a child does:
/// only by tapping keys on the app's own keypad.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    final id = await container
        .read(userRepositoryProvider)
        .createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
    container
        .read(activeUserProvider.notifier)
        .select((await container.read(userRepositoryProvider).findUser(id))!);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpPractice(WidgetTester tester, {int taskCount = 10}) async {
    tester.view.physicalSize = const Size(2400, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: PracticeScreen(
            lesson: lessonById('add_100_carry'),
            taskCount: taskCount,
          ),
        ),
      ),
    );
    // Two frames: the run is only generated once the practice cap has
    // answered, and the review pool after that.
    await tester.pump();
    await tester.pump();
  }

  Task currentTask(WidgetTester tester) =>
      tester.widget<TaskDisplay>(find.byType(TaskDisplay)).task;

  Future<void> typeNumber(WidgetTester tester, int number) async {
    for (final digit in '$number'.split('')) {
      await tester.tap(find.byKey(Key('digit-$digit')));
      await tester.pump();
    }
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pump();
  }

  testWidgets('a full run is stored and leads to the result screen',
      (tester) async {
    await pumpPractice(tester);

    for (var i = 0; i < 10; i++) {
      await typeNumber(tester, currentTask(tester).expected);
      await submit(tester);
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pumpAndSettle();

    expect(find.text('Geschafft, Mia!'), findsOneWidget);

    final session = (await db.select(db.sessions).get()).single;
    expect(session.completed, isTrue);
    expect(session.taskCount, 10);
    expect(session.wrongAttempts, 0);
    expect(await db.select(db.attempts).get(), hasLength(10));
  });

  testWidgets('a wrong answer is shown, counted, and lets the child retry',
      (tester) async {
    await pumpPractice(tester, taskCount: 10);

    final wrongAnswer = currentTask(tester).expected == 99 ? 98 : 99;
    await typeNumber(tester, wrongAnswer);
    await submit(tester);

    // The box is cleared and marked red; the run does not move on.
    expect(find.byType(TaskDisplay), findsOneWidget);
    final display = tester.widget<TaskDisplay>(find.byType(TaskDisplay));
    expect(display.input, isEmpty);

    for (var i = 0; i < 10; i++) {
      await typeNumber(tester, currentTask(tester).expected);
      await submit(tester);
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pumpAndSettle();

    final session = (await db.select(db.sessions).get()).single;
    expect(session.wrongAttempts, 1);
    expect(find.text('Geschafft, Mia!'), findsOneWidget);
    // Two stars: one mistake in ten tasks is a 10 % error rate.
    expect(starsFor(session.wrongAttempts, session.taskCount, scored: true), 2);
  });

  testWidgets('the active profile stays visible while practising',
      (tester) async {
    await pumpPractice(tester);

    // Whose run this is must be readable at any moment - on a shared tablet
    // it is the difference between a personal best and a ruined leaderboard.
    expect(find.text('Mia'), findsOneWidget);
    expect(find.text('🦊'), findsOneWidget);

    await typeNumber(tester, currentTask(tester).expected);
    await submit(tester);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Mia'), findsOneWidget);
  });

  testWidgets('the result screen shows one time, penalty included',
      (tester) async {
    // There used to be two: a penalty-free average here and a scored one in
    // the leaderboard. They disagreed, and no wording fixed that.
    tester.view.physicalSize = const Size(2400, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    Future<void> pumpResult(int wrongAttempts) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(),
            home: ResultScreen(
              lesson: lessonById('add_100_carry'),
              sessionId: null,
              taskCount: 10,
              totalMs: 48000,
              wrongAttempts: wrongAttempts,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // 48 s of calculating plus 2 x 3 s penalty is 54 s, or 5,4 s per task -
    // and that is the number the leaderboard will rank.
    await pumpResult(2);
    expect(find.text('54,0 s'), findsOneWidget);
    expect(find.text('5,4 s'), findsOneWidget);
    expect(find.text('4,8 s'), findsNothing);
    expect(
      find.textContaining('6,0 s Zeitstrafe für 2 Fehlversuche'),
      findsOneWidget,
    );

    // A clean run needs no explanation: the total is simply the elapsed time.
    await pumpResult(0);
    expect(find.text('48,0 s'), findsOneWidget);
    expect(find.text('4,8 s'), findsOneWidget);
    expect(find.textContaining('Zeitstrafe'), findsNothing);
  });

  testWidgets('the result screen has its own way back', (tester) async {
    // It is the only screen without an app bar, so the arrow has to be part
    // of the layout - and it has to actually pop, not just look like it.
    tester.view.physicalSize = const Size(2400, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ResultScreen(
                      lesson: lessonById('add_100_carry'),
                      sessionId: null,
                      taskCount: 10,
                      totalMs: 48000,
                      wrongAttempts: 1,
                    ),
                  ),
                ),
                child: const Text('Lektionen'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Lektionen'));
    await tester.pumpAndSettle();
    expect(find.text('Geschafft, Mia!'), findsOneWidget);

    await tester.tap(find.byTooltip('Zurück zu den Lektionen'));
    await tester.pumpAndSettle();

    expect(find.byType(ResultScreen), findsNothing);
    expect(find.text('Lektionen'), findsOneWidget);
  });

  testWidgets('backspace deletes a digit before submitting', (tester) async {
    await pumpPractice(tester);

    await typeNumber(tester, 12);
    await tester.tap(find.byKey(const Key('backspace')));
    await tester.pump();
    expect(tester.widget<TaskDisplay>(find.byType(TaskDisplay)).input, '1');
  });

  testWidgets('leaving asks first and marks the run as not counting',
      (tester) async {
    await pumpPractice(tester);

    await typeNumber(tester, currentTask(tester).expected);
    await submit(tester);
    await tester.pump(const Duration(milliseconds: 500));

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Übung beenden?'), findsOneWidget);

    await tester.tap(find.text('Beenden'));
    await tester.pumpAndSettle();

    final session = (await db.select(db.sessions).get()).single;
    expect(session.completed, isFalse);
    expect(session.taskCount, 1);
  });

  testWidgets('cancelling the leave dialog continues the run', (tester) async {
    await pumpPractice(tester);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weiter rechnen'));
    await tester.pumpAndSettle();

    expect(find.byType(TaskDisplay), findsOneWidget);
    await typeNumber(tester, 7);
    expect(tester.widget<TaskDisplay>(find.byType(TaskDisplay)).input, '7');
  });

  testWidgets('leaving never shows the pause screen on the way out',
      (tester) async {
    // The dialog stops the clock, which used to raise the pause overlay -
    // it stood behind the dialog and then flashed up full screen for a frame
    // between "Beenden" and the lesson list.
    await pumpPractice(tester);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Übung beenden?'), findsOneWidget);
    expect(find.text('Pause'), findsNothing,
        reason: 'the dialog stops the clock, it does not pause the child');

    await tester.tap(find.text('Beenden'));
    // Frame by frame rather than pumpAndSettle: the flash lasted one frame.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(find.text('Pause'), findsNothing);
    }
    await tester.pumpAndSettle();
    expect(find.text('Pause'), findsNothing);
  });

  testWidgets('a deliberate pause still shows it', (tester) async {
    // The overlay is not gone, only kept out of the abort path: it carries
    // the "Weiter" button a child needs after the app was in the background.
    await pumpPractice(tester);

    // The binding only accepts legal transitions, so the app goes away the
    // way it really does: resumed -> inactive.
    tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();

    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Die Zeit läuft nicht weiter.'), findsOneWidget);

    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    expect(find.text('Pause'), findsNothing);
  });
}
