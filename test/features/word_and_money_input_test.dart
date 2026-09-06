import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/practice/practice_screen.dart';
import 'package:mathe_trainer/features/practice/widgets/big_keypad.dart';
import 'package:mathe_trainer/features/practice/widgets/choice_keypad.dart';
import 'package:mathe_trainer/features/practice/widgets/task_display.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// Two lessons answer with something other than digits: a spoken time is
/// tapped as words, an amount is laid out from coins. Both are driven here
/// the way a child drives them - only by tapping keys.
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

  Future<void> pump(WidgetTester tester, String lessonId,
      {int taskCount = 3}) async {
    tester.view.physicalSize = const Size(2400, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: PracticeScreen(
            lesson: lessonById(lessonId),
            taskCount: taskCount,
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Task currentTask(WidgetTester tester) =>
      tester.widget<TaskDisplay>(find.byType(TaskDisplay)).task;

  Future<void> tapKey(WidgetTester tester, Key key) async {
    await tester.tap(find.byKey(key));
    await tester.pump();
  }

  Future<void> typeNumber(WidgetTester tester, int number) async {
    for (final digit in '$number'.split('')) {
      await tapKey(tester, Key('digit-$digit'));
    }
  }

  group('saying the time', () {
    testWidgets('the pad shows words first and digits for the hour',
        (tester) async {
      await pump(tester, 'clock_words');

      // Every spoken form is on the pad, and no digit is.
      expect(find.byType(ChoiceKeypad), findsOneWidget);
      expect(find.byType(BigKeypad), findsNothing);
      for (final phrase in clockPhrases) {
        expect(find.text(phrase), findsOneWidget, reason: phrase);
      }

      final task = currentTask(tester);
      await tapKey(tester, Key('choice-${task.expected}'));

      // The box shows the words, not the number behind them.
      expect(
        tester.widget<TaskDisplay>(find.byType(TaskDisplay)).input,
        '${task.expected}',
      );
      expect(find.text(clockPhrases[task.expected]), findsWidgets);

      // Moving on to the hour swaps the pad back to digits.
      await tapKey(tester, const Key('submit'));
      expect(find.byType(BigKeypad), findsOneWidget);
      expect(find.byType(ChoiceKeypad), findsNothing);
    });

    testWidgets('a full run of spoken times can be answered', (tester) async {
      await pump(tester, 'clock_words');

      for (var i = 0; i < 3; i++) {
        final task = currentTask(tester);
        await tapKey(tester, Key('choice-${task.expected}'));
        await tapKey(tester, const Key('submit'));
        await typeNumber(tester, task.expectedSecond!);
        await tapKey(tester, const Key('submit'));
        await tester.pump(const Duration(milliseconds: 500));
      }
      await tester.pumpAndSettle();

      expect(find.text('Geschafft, Mia!'), findsOneWidget);
      final session = (await db.select(db.sessions).get()).single;
      expect(session.wrongAttempts, 0);
    });

    testWidgets('tapping another word replaces the first one', (tester) async {
      await pump(tester, 'clock_words');

      await tapKey(tester, const Key('choice-0'));
      await tapKey(tester, const Key('choice-5'));
      expect(
        tester.widget<TaskDisplay>(find.byType(TaskDisplay)).input,
        '5',
      );
    });
  });

  group('laying out an amount', () {
    testWidgets('coins add up and the pile is shown', (tester) async {
      await pump(tester, 'money_compose');

      // A coin for every piece, and no digits to type.
      expect(find.byType(BigKeypad), findsNothing);
      for (final piece in moneyPieces) {
        expect(find.text(formatPiece(piece)), findsWidgets, reason: '$piece');
      }

      // 1 € is at index 4, 50 ct at index 3.
      await tapKey(tester, const Key('choice-4'));
      await tapKey(tester, const Key('choice-3'));
      final display = tester.widget<TaskDisplay>(find.byType(TaskDisplay));
      expect(display.input, '150');
      expect(display.pieces, [100, 50]);
      // The running total is written as an amount, not as a count of cents.
      expect(find.text('1,50 €'), findsOneWidget);
    });

    testWidgets('backspace takes the pile apart piece by piece',
        (tester) async {
      await pump(tester, 'money_compose');

      await tapKey(tester, const Key('choice-4'));
      await tapKey(tester, const Key('choice-3'));
      await tapKey(tester, const Key('backspace'));

      final display = tester.widget<TaskDisplay>(find.byType(TaskDisplay));
      expect(display.pieces, [100]);
      expect(display.input, '100');
    });

    testWidgets('an amount laid out correctly is accepted', (tester) async {
      await pump(tester, 'money_compose', taskCount: 1);

      // Greedy from the biggest piece down - the generator guarantees this
      // always comes out even.
      var rest = currentTask(tester).expected;
      for (final piece in moneyPieces.reversed) {
        final index = moneyPieces.indexOf(piece);
        while (rest >= piece) {
          rest -= piece;
          await tapKey(tester, Key('choice-$index'));
        }
      }
      expect(rest, 0);

      await tapKey(tester, const Key('submit'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.text('Geschafft, Mia!'), findsOneWidget);
      final session = (await db.select(db.sessions).get()).single;
      expect(session.wrongAttempts, 0);
    });

    testWidgets('too little money is a wrong answer, and can be corrected',
        (tester) async {
      await pump(tester, 'money_compose', taskCount: 1);

      // Five cents is never enough: the smallest amount asked for is 10.
      await tapKey(tester, const Key('choice-0'));
      await tapKey(tester, const Key('submit'));

      final display = tester.widget<TaskDisplay>(find.byType(TaskDisplay));
      expect(display.pieces, isEmpty, reason: 'the pile is swept away');
      expect(display.input, isEmpty);

      var rest = currentTask(tester).expected;
      for (final piece in moneyPieces.reversed) {
        final index = moneyPieces.indexOf(piece);
        while (rest >= piece) {
          rest -= piece;
          await tapKey(tester, Key('choice-$index'));
        }
      }
      await tapKey(tester, const Key('submit'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      final session = (await db.select(db.sessions).get()).single;
      expect(session.wrongAttempts, 1);
      expect(session.completed, isTrue);
    });
  });
}
