import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/features/duel/duel_screen.dart';
import 'package:mathe_trainer/features/practice/practice_screen.dart';
import 'package:mathe_trainer/features/practice/widgets/task_display.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// A duel is only fair if both children get the identical run - same tasks,
/// same order. These tests play one through and compare what was shown.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int mia;
  late int tom;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    final users = container.read(userRepositoryProvider);
    mia = await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
    tom = await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpSetup(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const DuelSetupScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  /// The lesson chips sit in a scrolling list; with eleven first-steps
  /// lessons above it, the one we want is not built until we get there.
  Future<void> pickLesson(WidgetTester tester) async {
    final chip = find.textContaining('Plus mit Zehnerübergang');
    for (var i = 0; i < 15 && chip.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(chip.first);
    await tester.pumpAndSettle();
    await tester.tap(chip.first);
    await tester.pumpAndSettle();
  }

  /// Solves the run currently on screen, remembering what was asked.
  Future<List<String>> playRun(WidgetTester tester) async {
    final asked = <String>[];
    for (var i = 0; i < 10; i++) {
      final task = tester.widget<TaskDisplay>(find.byType(TaskDisplay)).task;
      asked.add(task.toString());
      for (final digit in '${task.expected}'.split('')) {
        await tester.tap(find.byKey(Key('digit-$digit')));
        await tester.pump();
      }
      await tester.tap(find.byKey(const Key('submit')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }
    await tester.pumpAndSettle();
    return asked;
  }

  testWidgets('both children solve exactly the same tasks', (tester) async {
    await pumpSetup(tester);

    await tester.tap(find.textContaining('Mia'));
    await tester.tap(find.textContaining('Tom'));
    await tester.pumpAndSettle();
    await pickLesson(tester);
    await tester.tap(find.text('Duell starten'));
    await tester.pumpAndSettle();

    // First leg: the tablet is handed over before the clock starts.
    expect(find.text('Mia ist dran'), findsOneWidget);
    expect(find.text('1 von 2'), findsOneWidget);
    await tester.tap(find.text('Bereit'));
    await tester.pumpAndSettle();
    final first = await playRun(tester);

    expect(find.text('Tom ist dran'), findsOneWidget);
    await tester.tap(find.text('Bereit'));
    await tester.pumpAndSettle();
    final second = await playRun(tester);

    expect(second, first);
    expect(first, hasLength(10));

    // And the ranking is there, with both runs stored as normal sessions.
    expect(find.byType(DuelResultScreen), findsOneWidget);
    expect(find.text('Alle hatten dieselben Aufgaben.'), findsOneWidget);
    expect(find.text('Sieg!'), findsOneWidget);

    final stored = await db.select(db.sessions).get();
    expect(stored, hasLength(2));
    expect(stored.map((s) => s.userId).toSet(), {mia, tom});
    expect(stored.map((s) => s.seed).toSet(), hasLength(1));
    expect(stored.every((s) => s.completed), isTrue);
  });

  testWidgets('a duel needs at least two children', (tester) async {
    await pumpSetup(tester);

    expect(find.text('Wähle mindestens zwei Kinder aus.'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Duell starten'))
          .onPressed,
      isNull,
    );

    await tester.tap(find.textContaining('Mia'));
    await tester.pumpAndSettle();
    // One is still not a duel.
    expect(find.text('Wähle mindestens zwei Kinder aus.'), findsOneWidget);
  });

  testWidgets('only lessons every participant may see are offered',
      (tester) async {
    // Tom is still on the small numbers, so "Bis 1000" is out for both.
    await container
        .read(userRepositoryProvider)
        .setHiddenGroups(tom, {LessonGroup.upTo1000, LessonGroup.timesTables});
    await pumpSetup(tester);

    await tester.tap(find.textContaining('Mia'));
    await tester.tap(find.textContaining('Tom'));
    await tester.pumpAndSettle();

    expect(find.text('Bis 10'), findsOneWidget);
    expect(find.text('Bis 1000'), findsNothing);
    expect(find.text('Einmaleins'), findsNothing);
  });

  testWidgets('backing out of the hand-over ends the duel', (tester) async {
    await pumpSetup(tester);
    await tester.tap(find.textContaining('Mia'));
    await tester.tap(find.textContaining('Tom'));
    await tester.pumpAndSettle();
    await pickLesson(tester);
    await tester.tap(find.text('Duell starten'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Duell abbrechen'));
    await tester.pumpAndSettle();

    expect(find.byType(PracticeScreen), findsNothing);
    expect(find.byType(DuelSetupScreen), findsOneWidget);
    expect(await db.select(db.sessions).get(), isEmpty);
  });
}
