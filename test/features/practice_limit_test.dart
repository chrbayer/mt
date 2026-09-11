import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/app.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/practice_limit.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/lessons/lesson_home_screen.dart';
import 'package:mathe_trainer/features/lessons/pause_notice.dart';
import 'package:mathe_trainer/features/lessons/start_lesson_sheet.dart';
import 'package:mathe_trainer/features/practice/practice_screen.dart';
import 'package:mathe_trainer/features/practice/widgets/task_display.dart';
import 'package:mathe_trainer/features/result/result_screen.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// The practice cap, driven through the real screens: a parent sets it, the
/// child runs into it, and the break lets them back in.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late User mia;

  /// The app's clock, under the test's control: the cap is the one rule that
  /// changes with time alone, so time has to be something the test can move.
  late DateTime clock;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 9, 6, 15, 0);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => clock),
      ],
    );
    final users = container.read(userRepositoryProvider);
    final id = await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
    mia = (await users.findUser(id))!;
    container.read(activeUserProvider.notifier).select(mia);
    // Most tests here are about one child's own limits, so the app-wide ones
    // start switched off - otherwise every profile would already be capped
    // by the defaults.
    await container
        .read(settingsRepositoryProvider)
        .setPracticeLimits(const PracticeLimits(
          stretchMinutes: 0,
          breakMinutes: 15,
          dailyMinutes: 0,
        ));
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// Practice that ended [endedMinutesAgo] ago and lasted [minutes].
  Future<void> practise({
    required int minutes,
    required int endedMinutesAgo,
  }) async {
    final sessions = container.read(sessionRepositoryProvider);
    final id = await sessions.startSession(
      userId: mia.id,
      lessonId: 'add_100_carry',
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
            elapsedMs: minutes * 60000 ~/ 10,
            wrongAttempts: 0,
          ),
      ],
    );
    final ended = clock
        .subtract(Duration(minutes: endedMinutesAgo))
        .millisecondsSinceEpoch;
    await (db.update(db.sessions)..where((s) => s.id.equals(id))).write(
      SessionsCompanion(
        startedAtMs: Value(ended - minutes * 60000),
        finishedAtMs: Value(ended),
      ),
    );
  }

  /// The app-wide limits. Most tests here are about one child's own, so they
  /// switch these off first - otherwise every profile would already be
  /// capped by the defaults.
  Future<void> setGlobalLimits({
    int stretch = 0,
    int pause = 15,
    int daily = 0,
  }) =>
      container.read(settingsRepositoryProvider).setPracticeLimits(
            PracticeLimits(
              stretchMinutes: stretch,
              breakMinutes: pause,
              dailyMinutes: daily,
            ),
          );

  Future<void> setLimit({
    int? limit = 0,
    int? pause = 15,
    int? daily = 0,
  }) async {
    await container.read(userRepositoryProvider).setPracticeLimit(
          mia.id,
          limitMinutes: limit,
          breakMinutes: pause,
          dailyLimitMinutes: daily,
        );
    // The screens read the cap off the active profile, which the home screen
    // keeps in step with the database.
    final fresh =
        (await container.read(userRepositoryProvider).findUser(mia.id))!;
    container.read(activeUserProvider.notifier).select(fresh);
  }

  /// Moves both clocks on: the app's, and the one the pending alarm sleeps
  /// on. Leaves no timer behind, which the test harness insists on.
  Future<void> waitOut(WidgetTester tester, Duration time) async {
    clock = clock.add(time);
    await tester.pump(time + const Duration(seconds: 2));
  }

  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(2400, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: buildAppTheme(), home: screen),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('without a cap nothing is said about pauses', (tester) async {
    await practise(minutes: 90, endedMinutesAgo: 1);
    await pump(tester, const LessonHomeScreen());

    expect(find.byType(PauseNotice), findsNothing);
  });

  testWidgets('past the cap the catalogue says to take a break',
      (tester) async {
    await setLimit(limit: 20, pause: 15);
    await practise(minutes: 25, endedMinutesAgo: 1);
    await pump(tester, const LessonHomeScreen());

    expect(find.byType(PauseNotice), findsOneWidget);
    expect(find.textContaining('Pause!'), findsOneWidget);
    expect(find.textContaining('25 Minuten am Stück'), findsOneWidget);

    // Nobody taps anything: the break simply runs out.
    await waitOut(tester, const Duration(minutes: 14));
    expect(find.byType(PauseNotice), findsNothing);
  });

  testWidgets('below the cap practice carries on', (tester) async {
    await setLimit(limit: 30, pause: 15);
    await practise(minutes: 25, endedMinutesAgo: 1);
    await pump(tester, const LessonHomeScreen());

    expect(find.byType(PauseNotice), findsNothing);
  });

  testWidgets('a break that has been taken opens the app again',
      (tester) async {
    await setLimit(limit: 20, pause: 15);
    // Half an hour of practice, but it finished twenty minutes ago.
    await practise(minutes: 30, endedMinutesAgo: 20);
    await pump(tester, const LessonHomeScreen());

    expect(find.byType(PauseNotice), findsNothing);
  });

  testWidgets('the start button is dead during the break', (tester) async {
    await setLimit(limit: 20, pause: 15);
    await practise(minutes: 25, endedMinutesAgo: 1);
    await pump(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                StartLessonSheet.show(context, lessonById('add_100_carry')),
            child: const Text('auf'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('auf'));
    await tester.pumpAndSettle();

    // The sheet still opens - a child may look at the lesson and its
    // ranking - but it cannot be started.
    expect(find.byType(PauseNotice), findsOneWidget);
    final start = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, "Los geht's"),
    );
    expect(start.onPressed, isNull);

    await waitOut(tester, const Duration(minutes: 14));
    final afterBreak = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, "Los geht's"),
    );
    expect(afterBreak.onPressed, isNotNull,
        reason: 'the sheet unlocks itself when the break is over');
  });

  testWidgets('the daily total closes the day, and no clock is promised',
      (tester) async {
    await setLimit(daily: 30);
    // Three quarters of an hour today, spread over two proper stretches -
    // the breaks were taken, but the day is used up all the same.
    await practise(minutes: 25, endedMinutesAgo: 200);
    await practise(minutes: 20, endedMinutesAgo: 60);
    await pump(tester, const LessonHomeScreen());

    expect(find.byType(PauseNotice), findsOneWidget);
    expect(find.textContaining('Für heute reicht es!'), findsOneWidget);
    expect(find.textContaining('45 Minuten'), findsOneWidget);
    expect(find.textContaining('Morgen geht es weiter'), findsOneWidget);
    // Waiting out a break must not help here.
    await waitOut(tester, const Duration(minutes: 30));
    expect(find.byType(PauseNotice), findsOneWidget);

    // Only the next day opens it again.
    await waitOut(tester, const Duration(hours: 9));
    expect(find.byType(PauseNotice), findsNothing);
  });

  testWidgets('yesterday does not count against today', (tester) async {
    await setLimit(daily: 30);
    // A full hour, but it was yesterday afternoon.
    await practise(minutes: 60, endedMinutesAgo: 20 * 60);
    await pump(tester, const LessonHomeScreen());

    expect(find.byType(PauseNotice), findsNothing);
  });

  testWidgets('a night passing while the app keeps running starts the '
      'daily total again', (tester) async {
    await setLimit(daily: 30);
    // Yesterday evening: most of the day gone, but not all of it, so the
    // screen builds its allowance while practice is still allowed. That is
    // the case the old code never re-examined - the only wake-up it had
    // fired while a child was already blocked.
    await practise(minutes: 25, endedMinutesAgo: 5);
    await pump(tester, const LessonHomeScreen());
    expect(find.byType(PauseNotice), findsNothing);

    // The tablet is put down and picked up the next afternoon. The app is
    // never restarted in between, which is the whole point of the bug: the
    // day boundary has to be asked again rather than remembered.
    clock = clock.add(const Duration(hours: 21));
    await practise(minutes: 10, endedMinutesAgo: 60);
    container.invalidate(dayStartProvider);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Yesterday's 25 and today's 10 would be over the cap together. Ten on
    // their own are not, and ten is all that was practised today.
    expect(find.byType(PauseNotice), findsNothing);
  });

  testWidgets('coming back to the foreground asks what day it is',
      (tester) async {
    tester.view.physicalSize = const Size(2400, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MatheTrainerApp(),
    ));
    await tester.pump();
    final before = container.read(dayStartProvider);

    clock = clock.add(const Duration(days: 1));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    // Without this the boundary would still be yesterday's, and everything
    // counted against "today" with it.
    expect(container.read(dayStartProvider), greaterThan(before));
  });

  testWidgets('with the cap lifted the same run may start', (tester) async {
    await setLimit(limit: 60, pause: 15);
    await practise(minutes: 25, endedMinutesAgo: 1);
    await pump(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                StartLessonSheet.show(context, lessonById('add_100_carry')),
            child: const Text('auf'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('auf'));
    await tester.pumpAndSettle();

    expect(find.byType(PauseNotice), findsNothing);
    final start = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, "Los geht's"),
    );
    expect(start.onPressed, isNotNull);
  });

  group('the app-wide limits', () {
    testWidgets('hold for a child without their own', (tester) async {
      await setGlobalLimits(stretch: 20, pause: 15, daily: 120);
      await practise(minutes: 25, endedMinutesAgo: 1);
      await pump(tester, const LessonHomeScreen());

      expect(find.byType(PauseNotice), findsOneWidget);
      expect(find.textContaining('25 Minuten am Stück'), findsOneWidget);
      await waitOut(tester, const Duration(minutes: 14));
      expect(find.byType(PauseNotice), findsNothing);
    });

    testWidgets('are overridden by a child who has their own', (tester) async {
      await setGlobalLimits(stretch: 20, pause: 15, daily: 120);
      // This child may go on for an hour.
      await setLimit(limit: 60, pause: 15, daily: null);
      await practise(minutes: 25, endedMinutesAgo: 1);
      await pump(tester, const LessonHomeScreen());

      expect(find.byType(PauseNotice), findsNothing);
    });

    testWidgets('can be switched off for one child while everyone else keeps '
        'them', (tester) async {
      await setGlobalLimits(stretch: 20, pause: 15, daily: 120);
      // Zero is a decision, not "unset": this child has no stretch limit.
      await setLimit(limit: 0, pause: null, daily: null);
      await practise(minutes: 45, endedMinutesAgo: 1);
      await pump(tester, const LessonHomeScreen());

      expect(find.byType(PauseNotice), findsNothing,
          reason: 'the stretch cap is off for this child');
    });

    testWidgets('still cap the day when only the stretch is lifted',
        (tester) async {
      await setGlobalLimits(stretch: 20, pause: 15, daily: 120);
      await setLimit(limit: 0, pause: null, daily: null);
      // Over two hours today, in stretches that each stayed short.
      await practise(minutes: 70, endedMinutesAgo: 200);
      await practise(minutes: 60, endedMinutesAgo: 60);
      await pump(tester, const LessonHomeScreen());

      expect(find.textContaining('Für heute reicht es!'), findsOneWidget,
          reason: 'the daily limit is still inherited');
      // The alarm waits for midnight; let it come so no timer is left.
      await waitOut(tester, const Duration(hours: 9));
    });
  });

  group('a run already under way', () {
    testWidgets('is never interrupted, even when the time runs out mid-run',
        (tester) async {
      // A real run is dated by the app's own clock, so the test clock has to
      // agree with it - otherwise the run it plays lands hours away from the
      // stretch this test builds.
      clock = DateTime.now();
      await setLimit(limit: 20, pause: 15);
      // Nineteen minutes done: still under the cap, so the run may start.
      await practise(minutes: 19, endedMinutesAgo: 1);

      await pump(
        tester,
        PracticeScreen(lesson: lessonById('add_100_carry'), taskCount: 3),
      );
      expect(find.byType(TaskDisplay), findsOneWidget);

      // The cap is reached while the child is working: another run is
      // recorded in the background, pushing the stretch over twenty minutes.
      await practise(minutes: 10, endedMinutesAgo: 0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // No overlay, no notice, no dead keypad - the run carries on.
      expect(find.byType(PauseNotice), findsNothing);
      expect(find.byType(TaskDisplay), findsOneWidget);

      // And it can be answered through to the end and is stored.
      for (var i = 0; i < 3; i++) {
        final task =
            tester.widget<TaskDisplay>(find.byType(TaskDisplay)).task;
        for (final digit in '${task.expected}'.split('')) {
          await tester.tap(find.byKey(Key('digit-$digit')));
          await tester.pump();
        }
        await tester.tap(find.byKey(const Key('submit')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      }
      await tester.pumpAndSettle();

      expect(find.text('Geschafft, Mia!'), findsOneWidget);
      final stored = await db.select(db.sessions).get();
      expect(stored.where((s) => s.taskCount == 3 && s.completed), hasLength(1),
          reason: 'the run finished and was counted');

      // Only now does the break bite: "Nochmal" is dead. The stretch is
      // re-read from the database, so give that a frame.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.byType(PauseNotice), findsOneWidget);
      final again = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Nochmal'),
      );
      expect(again.onPressed, isNull);
      // Comfortably past the break, so no alarm is left waiting.
      await waitOut(tester, const Duration(minutes: 16));
    });

    testWidgets('"Nochmal" works again once the break is over', (tester) async {
      await setLimit(limit: 20, pause: 15);
      await practise(minutes: 25, endedMinutesAgo: 20);
      await pump(
        tester,
        ResultScreen(
          lesson: lessonById('add_100_carry'),
          sessionId: null,
          taskCount: 10,
          totalMs: 60000,
          wrongAttempts: 0,
        ),
      );

      expect(find.byType(PauseNotice), findsNothing);
      final again = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Nochmal'),
      );
      expect(again.onPressed, isNotNull);
    });
  });

  group('every door into a run asks the same question', () {
    testWidgets('the practice screen refuses even when pushed directly',
        (tester) async {
      await setLimit(limit: 20, pause: 15);
      await practise(minutes: 25, endedMinutesAgo: 1);

      // Straight past every button - this is what the recommendation card
      // did, and what any future fourth door would do.
      await pump(
        tester,
        PracticeScreen(lesson: lessonById('add_100_carry'), taskCount: 10),
      );
      // The screen asks the cap before it generates anything.
      await tester.pumpAndSettle();

      expect(find.byType(PauseNotice), findsOneWidget);
      expect(find.byType(TaskDisplay), findsNothing,
          reason: 'no run is generated at all');
      await waitOut(tester, const Duration(minutes: 16));
    });

    testWidgets('the recommendation card is dead during the break',
        (tester) async {
      await setLimit(limit: 20, pause: 15);
      await practise(minutes: 25, endedMinutesAgo: 1);
      await pump(tester, const LessonHomeScreen());

      final card = tester.widget<InkWell>(
        find.ancestor(
          of: find.byIcon(Icons.lightbulb_outline),
          matching: find.byType(InkWell),
        ),
      );
      expect(card.onTap, isNull);
      final go = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Los'),
      );
      expect(go.onPressed, isNull);
      await waitOut(tester, const Duration(minutes: 16));
    });

    testWidgets('and works again once the break is over', (tester) async {
      await setLimit(limit: 20, pause: 15);
      await practise(minutes: 25, endedMinutesAgo: 20);
      await pump(tester, const LessonHomeScreen());

      final go = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Los'),
      );
      expect(go.onPressed, isNotNull);
    });

    test('while the limits are unknown, no run may start', () async {
      final fresh = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(db)],
      );
      addTearDown(fresh.dispose);
      fresh.read(activeUserProvider.notifier).select(mia);
      // Read before anything has had a chance to load: the honest answer is
      // "not yet", and it must not be "yes" - that was the open door.
      final gate = fresh.read(practiceGateProvider);
      expect(gate.mayStart, isFalse);
      expect(gate.pause, isNull, reason: 'nothing to explain yet either');

      // And once everything is known the door opens again - the gate is
      // shut while loading, not shut for good.
      final sub =
          fresh.listen(practiceAllowanceForProvider(mia.id), (_, _) {});
      await fresh.read(practiceAllowanceForProvider(mia.id).future);
      expect(fresh.read(practiceGateProvider).mayStart, isTrue);
      sub.close();
    });
  });

  testWidgets('the countdown runs against the app clock', (tester) async {
    await setLimit(limit: 20, pause: 15);
    // The break ends fourteen minutes after the test clock, which is hours
    // away from the real one - so the wrong clock would show wildly.
    await practise(minutes: 25, endedMinutesAgo: 1);
    await pump(tester, const LessonHomeScreen());

    expect(find.textContaining('noch 14 Minuten'), findsOneWidget);
    await waitOut(tester, const Duration(minutes: 16));
  });
}
