import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/practice_limit.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/admin/today_summary.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// Who has practised how much today - the question the parent area is opened
/// with.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late User mia;
  late User tom;
  late DateTime clock;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    clock = DateTime(2026, 9, 7, 15, 0);
    container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        clockProvider.overrideWithValue(() => clock),
      ],
    );
    final users = container.read(userRepositoryProvider);
    mia = (await users.findUser(
        await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0)))!;
    tom = (await users.findUser(
        await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1)))!;
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  /// A run of [minutes] that ended [minutesAgo] before the test clock.
  Future<void> practise(
    User user, {
    required int minutes,
    int minutesAgo = 10,
    bool completed = true,
  }) async {
    final sessions = container.read(sessionRepositoryProvider);
    final id = await sessions.startSession(
      userId: user.id,
      lessonId: 'add_100_carry',
      taskCount: 10,
      seed: 1,
    );
    await sessions.finishSession(
      sessionId: id,
      completed: completed,
      results: [
        for (var i = 0; i < 10; i++)
          TaskResult(
            task: Task(a: 47, b: 38, op: Operation.add, form: TaskForm.result),
            elapsedMs: minutes * 60000 ~/ 10,
            wrongAttempts: 0,
          ),
      ],
    );
    final ended =
        clock.subtract(Duration(minutes: minutesAgo)).millisecondsSinceEpoch;
    await (db.update(db.sessions)..where((s) => s.id.equals(id))).write(
      SessionsCompanion(
        startedAtMs: Value(ended - minutes * 60000),
        finishedAtMs: Value(ended),
      ),
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
          home: const Scaffold(body: TodaySummary()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> setGlobalDaily(int minutes) =>
      container.read(settingsRepositoryProvider).setPracticeLimits(
            PracticeLimits(
              stretchMinutes: 0,
              breakMinutes: 15,
              dailyMinutes: minutes,
            ),
          );

  testWidgets('every profile is listed, with what it did today',
      (tester) async {
    await setGlobalDaily(0);
    await practise(mia, minutes: 25);
    await pump(tester);

    expect(find.text('Mia'), findsOneWidget);
    expect(find.text('Tom'), findsOneWidget);
    expect(find.text('25 min'), findsOneWidget);
    // Nothing yet is said in words, not as a zero.
    expect(find.text('noch nichts'), findsOneWidget);
  });

  testWidgets('yesterday does not count towards today', (tester) async {
    await setGlobalDaily(0);
    await practise(mia, minutes: 40, minutesAgo: 20 * 60);
    await pump(tester);

    expect(find.text('noch nichts'), findsNWidgets(2));
  });

  testWidgets('the daily cap is named next to the time', (tester) async {
    await setGlobalDaily(120);
    await practise(mia, minutes: 45);
    await pump(tester);

    expect(find.text('45 min von 120 min'), findsOneWidget);
    expect(find.text('noch nichts von 120 min'), findsOneWidget);
  });

  testWidgets("a child's own cap wins over the one for everyone",
      (tester) async {
    await setGlobalDaily(120);
    await container.read(userRepositoryProvider).setPracticeLimit(
          tom.id,
          limitMinutes: null,
          breakMinutes: null,
          dailyLimitMinutes: 30,
        );
    await pump(tester);

    expect(find.text('noch nichts von 120 min'), findsOneWidget);
    expect(find.text('noch nichts von 30 min'), findsOneWidget);
  });

  testWidgets('an abandoned run counts, exactly as the cap counts it',
      (tester) async {
    // The whole point of matching the cap's accounting: this line must never
    // say twelve minutes while the app tells the child the twenty are up.
    await setGlobalDaily(120);
    await practise(mia, minutes: 20, completed: false);
    await pump(tester);

    expect(find.text('20 min von 120 min'), findsOneWidget);
  });

  testWidgets('two stretches on one day are added up', (tester) async {
    await setGlobalDaily(60);
    await practise(mia, minutes: 30, minutesAgo: 200);
    await practise(mia, minutes: 30, minutesAgo: 5);
    await pump(tester);

    expect(find.text('1 h 0 min von 60 min'), findsOneWidget);
  });

  // Plain test, not a widget one: a blocked child leaves an alarm waiting for
  // midnight, and the widget harness rejects any pending timer.
  test('and the cap sees exactly the same time', () async {
    await setGlobalDaily(60);
    await practise(mia, minutes: 30, minutesAgo: 200);
    await practise(mia, minutes: 30, minutesAgo: 5);

    // Subscriptions held over the awaits: without a listener a provider is
    // disposed on read and its future never completes.
    final shownSub = container.listen(practisedTodayProvider, (_, _) {});
    final shown = (await container.read(practisedTodayProvider.future))[mia.id];
    expect(shown, 60 * 60000);
    shownSub.close();

    final sub =
        container.listen(practiceAllowanceForProvider(mia.id), (_, _) {});
    final allowance =
        await container.read(practiceAllowanceForProvider(mia.id).future);
    expect(allowance.practisedTodayMinutes, 60);
    expect(allowance.allowed, isFalse);
    expect(allowance.dayIsDone, isTrue);
    sub.close();
  });
}
