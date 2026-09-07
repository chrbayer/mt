import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/lessons/lesson_example.dart';
import 'package:mathe_trainer/features/practice/practice_controller.dart';
import 'package:mathe_trainer/features/practice/widgets/dice_face.dart';
import 'package:mathe_trainer/features/practice/widgets/picture_group.dart';
import 'package:mathe_trainer/features/practice/widgets/task_display.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// Two heaps and their two numbers: the numbers belong on one line, with the
/// same sign between them that stands between the heaps.
void main() {
  Future<void> pumpTask(
      WidgetTester tester, Task task, LessonSpec lesson) async {
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
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Rect rectOf(WidgetTester tester, String text) =>
      tester.getRect(find.text(text));

  /// The signs top to bottom: the first stands between the heaps, the last
  /// between their numbers.
  List<Rect> plusRects(WidgetTester tester) {
    final rects = <Rect>[];
    for (var i = 0; i < tester.widgetList(find.text('+')).length; i++) {
      rects.add(tester.getRect(find.text('+').at(i)));
    }
    rects.sort((a, b) => a.top.compareTo(b.top));
    return rects;
  }

  group('adding two heaps', () {
    testWidgets('the two counts sit on one line, even as a cloud',
        (tester) async {
      // The cloud is the case that broke it: four bees are taller than two,
      // so counts hung under each heap ended up at different heights.
      final lesson = lessonById('bees_add_cloud');
      await pumpTask(
        tester,
        const Task(a: 2, b: 4, op: Operation.add, form: TaskForm.quantityAdd),
        lesson,
      );

      expect(rectOf(tester, '2').top, rectOf(tester, '4').top);
    });

    testWidgets('and a plus stands between them', (tester) async {
      await pumpTask(
        tester,
        const Task(a: 3, b: 5, op: Operation.add, form: TaskForm.quantityAdd),
        lessonById('bees_add'),
      );

      // One above the heaps, one between the numbers.
      final signs = plusRects(tester);
      expect(signs, hasLength(2));

      final left = rectOf(tester, '3');
      final right = rectOf(tester, '5');
      expect(signs.last.center.dy, greaterThan(left.top));
      expect(signs.last.center.dy, lessThan(left.bottom));
      expect(signs.last.left, greaterThan(left.right));
      expect(signs.last.right, lessThan(right.left));
    });

    testWidgets('two dice do the same', (tester) async {
      await pumpTask(
        tester,
        const Task(a: 2, b: 5, op: Operation.add, form: TaskForm.dice),
        lessonById('dice_add'),
      );

      expect(rectOf(tester, '2').top, rectOf(tester, '5').top);
      expect(plusRects(tester), hasLength(2));
    });
  });

  group('comparing two heaps', () {
    testWidgets('the counts line up, but nothing is added', (tester) async {
      await pumpTask(
        tester,
        const Task(a: 1, b: 4, op: Operation.add, form: TaskForm.compare),
        lessonById('compare_more_cloud'),
      );

      expect(rectOf(tester, '1').top, rectOf(tester, '4').top);
      expect(find.text('+'), findsNothing,
          reason: 'the heaps are compared, not added');
    });

    testWidgets('the divider grows to the height of the clouds',
        (tester) async {
      // A stub of a line between two tall clouds separates nothing, and
      // separating them is its whole job.
      await pumpTask(
        tester,
        const Task(a: 6, b: 3, op: Operation.add, form: TaskForm.compare),
        lessonById('compare_more_cloud'),
      );

      final divider = tester.getRect(find.byWidgetPredicate((w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color == AppColors.textMuted));
      final heaps = tester.getRect(find.byType(PictureGroup).first);
      expect(divider.height, greaterThanOrEqualTo(heaps.height));
    });
  });

  group('counting one heap', () {
    testWidgets('shows no number at all - that is the question',
        (tester) async {
      await pumpTask(
        tester,
        const Task(a: 4, b: 0, op: Operation.add, form: TaskForm.quantity),
        lessonById('count_pictures'),
      );

      expect(find.text('4'), findsNothing);
    });

    testWidgets('nor does a single die', (tester) async {
      await pumpTask(
        tester,
        const Task(a: 5, b: 0, op: Operation.add, form: TaskForm.dice),
        lessonById('count_dice'),
      );

      expect(find.text('5'), findsNothing);
      expect(find.byType(DiceFace), findsOneWidget);
    });
  });

  group('on a lesson tile', () {
    Future<void> pumpTile(WidgetTester tester, String lessonId) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: Center(child: LessonExample(lesson: lessonById(lessonId))),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('the dice are blue, like every other example', (tester) async {
      // They used to be drawn in near-black while every other tile spoke in
      // blue, so the first steps read as a different kind of thing.
      await pumpTile(tester, 'dice_add');

      final dice = tester.widgetList<DiceFace>(find.byType(DiceFace));
      expect(dice, isNotEmpty);
      for (final die in dice) {
        expect(die.color, AppColors.primary);
      }
    });

    testWidgets('and so are the numbers under the heaps', (tester) async {
      await pumpTile(tester, 'bees_add');

      final numbers = tester
          .widgetList<Text>(find.byType(Text))
          .where((t) => int.tryParse(t.data ?? '') != null);
      expect(numbers, isNotEmpty);
      for (final number in numbers) {
        expect(number.style?.color, AppColors.primary);
      }
    });

    testWidgets('the tile lines its numbers up too', (tester) async {
      await pumpTile(tester, 'bees_add_cloud');

      // By index, not by text: the example may well be "2 + 2".
      final task = exampleTaskFor(lessonById('bees_add_cloud'));
      final tops = <double>[
        for (var i = 0; i < 2; i++)
          tester.getRect(find.text('${task.a}').at(i)).top,
      ];
      expect(task.a, task.b,
          reason: 'otherwise pick each number by its own text');
      expect(tops.first, tops.last);
    });
  });
}
