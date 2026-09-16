import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/domain/task_generator.dart';

/// Draws a good number of tasks from the place-value lesson.
List<Task> _draw({int runs = 60, int count = 20}) => [
      for (var seed = 0; seed < runs; seed++)
        ...generateTasks(
          lesson: lessonById('place_value_1000'),
          count: count,
          seed: seed,
        )
    ];

void main() {
  final tasks = _draw();

  test('the answer is what the named places add up to', () {
    for (final task in tasks) {
      final [ones, tens, hundreds, thousands] = task.places;
      expect(
        task.expected,
        ones + 10 * tens + 100 * hundreds + 1000 * thousands,
        reason: task.prefix,
      );
    }
  });

  test('every task stays inside four digits', () {
    for (final task in tasks) {
      expect(task.expected, lessThanOrEqualTo(9999), reason: task.prefix);
      expect(task.maxAnswerDigits, 4);
    }
  });

  test('at least two places are named, or there is nothing to put together',
      () {
    for (final task in tasks) {
      expect(task.places.where((count) => count > 0).length,
          greaterThanOrEqualTo(2),
          reason: task.prefix);
    }
  });

  test('counts above nine happen - that is the point of the lesson', () {
    final withCarry =
        tasks.where((t) => t.places.any((count) => count > 9)).length;
    expect(withCarry, greaterThan(tasks.length ~/ 10));
  });

  test('but large counts stay the exception', () {
    final counts = [
      for (final task in tasks)
        for (final count in task.places)
          if (count > 0) count
    ];
    final small = counts.where((count) => count <= 9).length;
    expect(small / counts.length, greaterThan(0.5));
  });

  test('the higher the place, the rarer it is named', () {
    int named(int place) =>
        tasks.where((task) => task.places[place] > 0).length;
    expect(named(0), greaterThan(named(2)));
    expect(named(1), greaterThan(named(2)));
    expect(named(2), greaterThan(named(3)));
  });

  test('thousands never push the answer out of range', () {
    for (final task in tasks) {
      expect(task.places[3], lessThanOrEqualTo(9), reason: task.prefix);
    }
  });

  test('the text names the parts from the ones upwards', () {
    final task = Task(a: 5, b: 12, c: 3, op: Operation.add, form: TaskForm.placeValue);
    expect(task.prefix, '5 Einer, 12 Zehner, 3 Hunderter');
    expect(task.expected, 5 + 120 + 300);
    expect(task.question, 'Welche Zahl ist das?');
  });

  test('a place that is not named is left out of the text', () {
    final task = Task(a: 0, b: 4, c: 200, op: Operation.add, form: TaskForm.placeValue);
    expect(task.prefix, '4 Zehner, 2 Tausender');
    expect(task.expected, 2040);
  });

  test('two tasks with different hundreds are different tasks', () {
    const first = Task(a: 1, b: 2, c: 3, op: Operation.add, form: TaskForm.placeValue);
    const second = Task(a: 1, b: 2, c: 4, op: Operation.add, form: TaskForm.placeValue);
    expect(first.key, isNot(second.key));
  });
}
