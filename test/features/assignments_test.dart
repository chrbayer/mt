import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/assignment.dart';
import 'package:mathe_trainer/domain/task.dart';
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

  /// Due comfortably later today, whatever time the test happens to run at -
  /// these tests are not about the deadline itself, only about what is done
  /// against it.
  int dueSoon({int inMinutes = 5}) {
    final now = DateTime.now();
    return now.hour * 60 + now.minute + inMinutes;
  }

  Future<int> assign(
    String lessonId, {
    int dueMinute = -1,
    int runs = 1,
    int taskCount = 10,
    int minStars = 0,
    int minBolts = 0,
  }) =>
      container.read(assignmentRepositoryProvider).createAssignment(
            userId: mia.id,
            lessonId: lessonId,
            rhythm: AssignmentRhythm.daily,
            dueMinute: dueMinute < 0 ? dueSoon() : dueMinute,
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

  testWidgets('cards sort by how soon they are due', (tester) async {
    await assign('add_100_plain', dueMinute: dueSoon(inMinutes: 120));
    await assign('add_100_carry', dueMinute: dueSoon(inMinutes: 10));
    await pump(tester);

    final tiles = tester
        .widgetList<AssignmentTile>(find.byType(AssignmentTile))
        .toList();
    expect(tiles.map((t) => t.assignment.lessonId).toList(),
        ['add_100_carry', 'add_100_plain']);
  });

  testWidgets('a met card sinks below an open one, whatever its own deadline',
      (tester) async {
    // Due sooner, but already met - it must still fall behind the open one.
    await assign('add_100_carry', dueMinute: dueSoon(inMinutes: 10));
    await finishRun('add_100_carry');
    await assign('add_100_plain', dueMinute: dueSoon(inMinutes: 120));
    await pump(tester);

    final tiles = tester
        .widgetList<AssignmentTile>(find.byType(AssignmentTile))
        .toList();
    expect(tiles.map((t) => t.assignment.lessonId).toList(),
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
