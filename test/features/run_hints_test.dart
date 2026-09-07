import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/practice_limit.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/lessons/start_lesson_sheet.dart';
import 'package:mathe_trainer/features/result/result_screen.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// Two things the app used to keep to itself: that a short run is worth
/// nothing, and how much practice time is left.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late User mia;
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
    final id = await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
    mia = (await users.findUser(id))!;
    container.read(activeUserProvider.notifier).select(mia);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

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

  Future<void> openSheet(WidgetTester tester, String lessonId) async {
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
                onPressed: () =>
                    StartLessonSheet.show(context, lessonById(lessonId)),
                child: const Text('auf'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('auf'));
    await tester.pumpAndSettle();
  }

  group('a run too short to count', () {
    testWidgets('says so before it is started', (tester) async {
      await container
          .read(userRepositoryProvider)
          .setProfileTaskCount(mia.id, 5);
      container.read(activeUserProvider.notifier).select(
            (await container.read(userRepositoryProvider).findUser(mia.id))!,
          );
      await openSheet(tester, 'add_100_carry');

      expect(find.textContaining('keine Sterne'), findsOneWidget);

      // Ten makes it go away again.
      await tester.tap(find.widgetWithText(Material, '10').first);
      await tester.pumpAndSettle();
      expect(find.textContaining('keine Sterne'), findsNothing);
    });

    testWidgets('and the chip itself says it, in colour', (tester) async {
      await openSheet(tester, 'add_100_carry');

      // The warm accent, not the red one: five is a legitimate way to
      // practise, and not the same as an error.
      Color fillOf(String label) => tester
          .widget<Material>(find.widgetWithText(Material, label).first)
          .color!;

      // Ten is preselected, so it wears the ordinary blue.
      expect(fillOf('10'), AppColors.primary);
      // Five stands out before it is even chosen.
      final five = tester.widget<Text>(find.text('5'));
      expect(five.style?.color, AppColors.profile1);

      await tester.tap(find.widgetWithText(Material, '5').first);
      await tester.pumpAndSettle();
      expect(fillOf('5'), AppColors.profile1);
      expect(fillOf('10'), AppColors.background,
          reason: 'ten is no longer the chosen one');
    });

    testWidgets('says so again where the empty stars turn up', (tester) async {
      tester.view.physicalSize = const Size(2400, 1500);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: buildAppTheme(),
            home: ResultScreen(
              lesson: lessonById('add_100_carry'),
              sessionId: null,
              taskCount: 5,
              totalMs: 20000,
              wrongAttempts: 0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('keine Sterne'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stays quiet for the first steps, which are never counted',
        (tester) async {
      await container
          .read(userRepositoryProvider)
          .setProfileTaskCount(mia.id, 5);
      container.read(activeUserProvider.notifier).select(
            (await container.read(userRepositoryProvider).findUser(mia.id))!,
          );
      await openSheet(tester, 'count_pictures');

      expect(find.textContaining('keine Sterne'), findsNothing,
          reason: 'nothing is being withheld there');
    });
  });

  group('the time that is left', () {
    testWidgets('is named before a run is started', (tester) async {
      await container.read(settingsRepositoryProvider).setPracticeLimits(
            const PracticeLimits(
              stretchMinutes: 20,
              breakMinutes: 15,
              dailyMinutes: 0,
            ),
          );
      await practise(minutes: 13, endedMinutesAgo: 1);
      await openSheet(tester, 'add_100_carry');

      expect(find.text('Noch 7 Minuten, dann ist Pause.'), findsOneWidget);
    });

    testWidgets('names whichever runs out first', (tester) async {
      await container.read(settingsRepositoryProvider).setPracticeLimits(
            const PracticeLimits(
              stretchMinutes: 20,
              breakMinutes: 15,
              dailyMinutes: 120,
            ),
          );
      // Two minutes into a stretch, but nearly two hours done today.
      await practise(minutes: 114, endedMinutesAgo: 200);
      await practise(minutes: 2, endedMinutesAgo: 1);
      await openSheet(tester, 'add_100_carry');

      expect(find.text('Noch 4 Minuten, dann ist Pause.'), findsOneWidget);
    });

    testWidgets('stays away when nothing caps this child', (tester) async {
      await container.read(settingsRepositoryProvider).setPracticeLimits(
            const PracticeLimits(
              stretchMinutes: 0,
              breakMinutes: 15,
              dailyMinutes: 0,
            ),
          );
      await practise(minutes: 90, endedMinutesAgo: 1);
      await openSheet(tester, 'add_100_carry');

      expect(find.textContaining('dann ist Pause'), findsNothing);
    });
  });
}
