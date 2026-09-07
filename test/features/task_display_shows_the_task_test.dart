import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/domain/task_generator.dart';
import 'package:mathe_trainer/features/practice/practice_controller.dart';
import 'package:mathe_trainer/features/practice/widgets/clock_face.dart';
import 'package:mathe_trainer/features/practice/widgets/dice_face.dart';
import 'package:mathe_trainer/features/practice/widgets/picture_group.dart';
import 'package:mathe_trainer/features/practice/widgets/task_display.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// Every lesson has to put its task on the screen.
///
/// "Welche Zahl kommt danach?" once showed a question, an empty box and
/// nothing else: the numbers to continue were missing, because that form sat
/// in the list of forms that draw their own picture - and it draws none. The
/// task was unanswerable and no test noticed, so this one checks all of them.
void main() {
  /// What a task shows besides the empty answer box: the numbers it names,
  /// or a picture it draws.
  ({List<String> texts, bool draws}) shown(WidgetTester tester) {
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data ?? '')
        .where((t) => t.trim().isNotEmpty)
        .toList();
    final draws = find.byType(PictureGroup).evaluate().isNotEmpty ||
        find.byType(DiceFace).evaluate().isNotEmpty ||
        find.byType(ClockFace).evaluate().isNotEmpty;
    return (texts: texts, draws: draws);
  }

  for (final lesson in lessonCatalog) {
    testWidgets('${lesson.id} shows what it is asking', (tester) async {
      final task = generateTasks(lesson: lesson, count: 1, seed: 7).single;

      tester.view.physicalSize = const Size(2400, 1500);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: Center(
              child: TaskDisplay(
                task: task,
                input: '',
                feedback: AnswerFeedback.none,
                arrangement: lesson.arrangement,
                showCounts: lesson.showCounts,
                clock24: lesson.clock24,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final on = shown(tester);
      if (on.draws) return; // A picture is the task.

      // Otherwise the numbers have to be readable somewhere - beside the box
      // or inside the question. A question alone with no numbers in it leaves
      // nothing to answer.
      final everything = on.texts.join(' ');
      expect(
        RegExp(r'\d').hasMatch(everything),
        isTrue,
        reason: '${lesson.id} (${task.form.name}) zeigt nur "$everything"',
      );
    });
  }

  testWidgets('the sequence lesson shows the row so far', (tester) async {
    const task = Task(a: 10, b: 1, op: Operation.add, form: TaskForm.sequence);

    tester.view.physicalSize = const Size(2400, 1500);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: TaskDisplay(
              task: task,
              input: '',
              feedback: AnswerFeedback.none,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Counting backwards from ten: the box takes the place of the next one.
    expect(find.textContaining('10'), findsOneWidget);
    expect(find.textContaining('9'), findsOneWidget);
    expect(find.textContaining('8'), findsOneWidget);
  });
}
