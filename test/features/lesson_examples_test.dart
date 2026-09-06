import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/features/lessons/lesson_example.dart';

/// The sample calculation on each lesson tile is the whole advertisement for
/// that lesson, so it must not be a freak of the seed.
void main() {
  test('every lesson shows a sample task', () {
    for (final lesson in lessonCatalog) {
      expect(exampleFor(lesson), isNotEmpty, reason: lesson.id);
    }
  });

  test('the rows of the times table do not all show the same partner', () {
    // They once all advertised "9 x something", because every lesson drew its
    // example from the same seed.
    final partners = <int>{};
    for (final lesson in lessonsInGroup(LessonGroup.timesTables)
        .where((l) => l.timesTable != null)) {
      final numbers = RegExp(r'\d+')
          .allMatches(exampleFor(lesson))
          .map((m) => int.parse(m.group(0)!))
          .toList();
      partners.add(numbers.firstWhere((n) => n != lesson.timesTable,
          orElse: () => lesson.timesTable!));
    }
    expect(partners.length, greaterThanOrEqualTo(4));
  });

  test('samples avoid the trivial members of a lesson', () {
    for (final lesson in lessonCatalog) {
      final example = exampleFor(lesson);
      if (lesson.form == TaskForm.partner) continue;
      // "10 x 1" or "253 - 253" say nothing about what a lesson practises.
      expect(example, isNot(matches(r'(^|\D)1(\D|$).*=')), reason: lesson.id);
    }
  });

  test('a division never advertises itself with an answer of one', () {
    // "4 : 4" is the division version of "times one": it says nothing about
    // the row the lesson is named after.
    for (final lesson in lessonCatalog.where(
      (l) => l.op == ArithmeticOp.div && l.form == TaskForm.result,
    )) {
      final task = exampleTaskFor(lesson);
      expect(task.result, isNot(1), reason: '${lesson.id}: $task');
      expect(task.a, isNot(task.b), reason: '${lesson.id}: $task');
    }
  });
}
