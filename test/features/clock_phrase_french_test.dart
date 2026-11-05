import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/domain/task_generator.dart';
import 'package:mathe_trainer/features/practice/practice_screen.dart';
import 'package:mathe_trainer/features/practice/widgets/big_keypad.dart';
import 'package:mathe_trainer/features/practice/widgets/choice_keypad.dart';
import 'package:mathe_trainer/features/practice/widgets/task_display.dart';
import 'package:mathe_trainer/l10n/l10n.dart';
import 'package:mathe_trainer/l10n/task_texts.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// French says the hour first: "4 h moins le quart" is 3:45. The first
/// language to take the `hourFirst` path in the real practice screen - the
/// hour is entered first on the digit pad, then the phrase is chosen on the
/// word pad.
void main() {
  const fr = Locale('fr');
  final lesson = lessonById('clock_words');

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

  /// A seed whose first task shows [minute].
  int seedStartingAt(int minute) {
    for (var seed = 0; seed < 2000; seed++) {
      final first = generateTasks(lesson: lesson, count: 3, seed: seed).first;
      if (first.b == minute) return seed;
    }
    throw StateError('no seed for :$minute');
  }

  Future<void> pump(WidgetTester tester, int seed) async {
    tester.view.physicalSize = const Size(2400, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: fr,
          supportedLocales: const [fr],
          theme: buildAppTheme(),
          home: PracticeScreen(lesson: lesson, taskCount: 3, seed: seed),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  Task currentTask(WidgetTester tester) =>
      tester.widget<TaskDisplay>(find.byType(TaskDisplay)).task;

  Future<void> tap(WidgetTester tester, Key key) async {
    await tester.tap(find.byKey(key));
    await tester.pump();
  }

  /// Enters [hour], moves on, taps the phrase of [task] and submits.
  Future<void> answer(WidgetTester tester, Task task, int hour) async {
    expect(find.byType(BigKeypad), findsOneWidget);
    expect(find.byType(ChoiceKeypad), findsNothing);
    await tap(tester, Key('digit-$hour'));
    await tap(tester, const Key('submit'));
    expect(find.byType(ChoiceKeypad), findsOneWidget);
    await tap(tester, Key('choice-${task.expected}'));
    await tap(tester, const Key('submit'));
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('quarter to is graded with the coming hour', (tester) async {
    await pump(tester, seedStartingAt(45));
    final task = currentTask(tester);
    expect(clockPhraseLabels(lookupAppLocalizations(fr))[task.expected],
        'h moins le quart');

    await answer(tester, task, task.a % 12 + 1);
    expect(currentTask(tester), isNot(same(task)));
  });

  testWidgets('quarter past is graded with the hour that has begun',
      (tester) async {
    await pump(tester, seedStartingAt(15));
    final task = currentTask(tester);
    expect(clockPhraseLabels(lookupAppLocalizations(fr))[task.expected],
        'h et quart');

    await answer(tester, task, task.a);
    expect(currentTask(tester), isNot(same(task)));
  });

  testWidgets('the hour that has begun is wrong at quarter to', (tester) async {
    await pump(tester, seedStartingAt(45));
    final task = currentTask(tester);

    await answer(tester, task, task.a);
    expect(currentTask(tester), same(task));
  });
}
