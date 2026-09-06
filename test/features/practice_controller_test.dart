import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/practice/practice_controller.dart';

/// Stopwatch whose elapsed time is advanced by the test, not by the clock.
class FakeStopwatch implements Stopwatch {
  Duration _elapsed = Duration.zero;
  bool _running = false;

  void advance(Duration by) {
    if (_running) _elapsed += by;
  }

  @override
  void start() => _running = true;

  @override
  void stop() => _running = false;

  @override
  void reset() => _elapsed = Duration.zero;

  @override
  bool get isRunning => _running;

  @override
  Duration get elapsed => _elapsed;

  @override
  int get elapsedMilliseconds => _elapsed.inMilliseconds;

  @override
  int get elapsedMicroseconds => _elapsed.inMicroseconds;

  @override
  int get elapsedTicks => _elapsed.inMicroseconds;

  @override
  int get frequency => 1000000;
}

const tasks = [
  Task(a: 47, b: 38, op: Operation.add, form: TaskForm.result), // 85
  Task(a: 12, b: 13, op: Operation.add, form: TaskForm.result), // 25
];

void main() {
  late FakeStopwatch clock;
  late PracticeController controller;

  setUp(() {
    clock = FakeStopwatch();
    controller = PracticeController(
      lesson: lessonById('add_100_carry'),
      tasks: tasks,
      stopwatch: clock,
    );
  });

  void type(String digits) {
    for (final digit in digits.split('')) {
      controller.pressDigit(int.parse(digit));
    }
  }

  test('a correct answer stores the elapsed time and advances', () {
    clock.advance(const Duration(milliseconds: 4200));
    type('85');
    expect(controller.submit(), AnswerFeedback.correct);
    expect(controller.results.single.elapsedMs, 4200);
    expect(controller.results.single.wrongAttempts, 0);

    controller.advance();
    expect(controller.index, 1);
    expect(controller.input, isEmpty);
    expect(controller.isFinished, isFalse);
  });

  test('a wrong answer clears the box but not the clock', () {
    clock.advance(const Duration(milliseconds: 3000));
    type('84');
    expect(controller.submit(), AnswerFeedback.wrong);
    expect(controller.input, isEmpty);
    expect(controller.wrongAttempts, 1);

    clock.advance(const Duration(milliseconds: 2500));
    type('85');
    controller.submit();

    // 3000 ms before the mistake plus 2500 ms after it.
    expect(controller.results.single.elapsedMs, 5500);
    expect(controller.results.single.wrongAttempts, 1);
  });

  test('typing after a mistake clears the red state immediately', () {
    type('84');
    controller.submit();
    expect(controller.feedback, AnswerFeedback.wrong);

    controller.pressDigit(8);
    expect(controller.feedback, AnswerFeedback.none);
    expect(controller.input, '8');
  });

  test('input is locked while the green flash is shown', () {
    type('85');
    controller.submit();
    controller.pressDigit(1);
    controller.backspace();
    expect(controller.input, '85');
  });

  test('the box takes at most three digits', () {
    type('1234');
    expect(controller.input, '123');
  });

  test('zero can be answered, and does not become a leading zero', () {
    type('0');
    expect(controller.input, '0');
    // A following digit replaces the 0 instead of making it "07".
    type('7');
    expect(controller.input, '7');
    type('0');
    expect(controller.input, '70');
  });

  test('an empty submission is ignored', () {
    expect(controller.submit(), AnswerFeedback.none);
    expect(controller.wrongAttempts, 0);
  });

  test('backspace removes the last digit', () {
    type('85');
    controller.backspace();
    expect(controller.input, '8');
  });

  test('pausing stops the clock, resuming continues it', () {
    clock.advance(const Duration(seconds: 2));
    controller.pause();
    clock.advance(const Duration(minutes: 30));
    expect(controller.isPaused, isTrue);

    controller.resume();
    clock.advance(const Duration(seconds: 3));
    type('85');
    controller.submit();
    expect(controller.results.single.elapsedMs, 5000);
  });

  test('input is refused while paused', () {
    controller.pause();
    type('85');
    expect(controller.input, isEmpty);
  });

  test('the run finishes after the last task', () {
    clock.advance(const Duration(seconds: 4));
    type('85');
    controller.submit();
    controller.advance();

    clock.advance(const Duration(seconds: 6));
    type('25');
    controller.submit();
    controller.advance();

    expect(controller.isFinished, isTrue);
    expect(controller.results, hasLength(2));
    expect(controller.elapsedMs, 10000);
    expect(clock.isRunning, isFalse);
  });

  test('the live clock never counts a solved task twice', () {
    clock.advance(const Duration(seconds: 4));
    type('85');
    controller.submit();
    // Still in the green flash: the 4 s belong to the result, not on top.
    expect(controller.elapsedMs, 4000);
    controller.advance();
    expect(controller.elapsedMs, 4000);
  });

  test('the clock restarts per task', () {
    clock.advance(const Duration(seconds: 4));
    type('85');
    controller.submit();
    controller.advance();

    clock.advance(const Duration(seconds: 6));
    type('25');
    controller.submit();
    expect(controller.results.last.elapsedMs, 6000);
  });

  group('division with remainder', () {
    late FakeStopwatch clock;
    late PracticeController division;

    setUp(() {
      clock = FakeStopwatch();
      division = PracticeController(
        lesson: lessonById('div_remainder'),
        tasks: const [
          Task(a: 17, b: 5, op: Operation.div, form: TaskForm.remainder),
        ],
        stopwatch: clock,
      );
    });

    void type(String digits) {
      for (final digit in digits.split('')) {
        division.pressDigit(int.parse(digit));
      }
    }

    test('the quotient is entered first, then the remainder', () {
      expect(division.hasSecondField, isTrue);
      expect(division.activeField, AnswerField.primary);

      type('3');
      // Confirming the first box only moves on - judging it now would give
      // away half the answer.
      expect(division.submit(), AnswerFeedback.none);
      expect(division.activeField, AnswerField.second);
      expect(division.input, '3');

      type('2');
      expect(division.secondInput, '2');
      expect(division.submit(), AnswerFeedback.correct);
      expect(division.results.single.wrongAttempts, 0);
    });

    test('a wrong remainder fails the whole task and starts over', () {
      type('3');
      division.submit();
      type('1');
      expect(division.submit(), AnswerFeedback.wrong);

      expect(division.input, isEmpty);
      expect(division.secondInput, isEmpty);
      expect(division.activeField, AnswerField.primary);
      expect(division.wrongAttempts, 1);
    });

    test('a wrong quotient fails too, even with the right remainder', () {
      type('4');
      division.submit();
      type('2');
      expect(division.submit(), AnswerFeedback.wrong);
      expect(division.wrongAttempts, 1);
    });

    test('backspace out of the empty remainder returns to the quotient', () {
      type('3');
      division.submit();
      expect(division.activeField, AnswerField.second);

      division.backspace();
      expect(division.activeField, AnswerField.primary);
      expect(division.input, '3');

      division.backspace();
      expect(division.input, isEmpty);
    });

    test('digits go into whichever box is active', () {
      type('3');
      division.submit();
      type('2');
      expect(division.input, '3');
      expect(division.secondInput, '2');
    });

    test('a remainder of zero can be entered', () {
      final exact = PracticeController(
        lesson: lessonById('div_remainder'),
        tasks: const [
          Task(a: 20, b: 5, op: Operation.div, form: TaskForm.remainder),
        ],
        stopwatch: FakeStopwatch(),
      );
      exact.pressDigit(4);
      exact.submit();
      exact.pressDigit(0);
      expect(exact.secondInput, '0');
      expect(exact.submit(), AnswerFeedback.correct);
    });

    test('the clock runs across both entries and the retry', () {
      clock.advance(const Duration(seconds: 3));
      type('3');
      division.submit();
      clock.advance(const Duration(seconds: 2));
      type('1');
      division.submit(); // wrong

      clock.advance(const Duration(seconds: 4));
      type('3');
      division.submit();
      type('2');
      division.submit();

      expect(division.results.single.elapsedMs, 9000);
      expect(division.results.single.wrongAttempts, 1);
    });
  });

  test('gap tasks are checked against the missing operand', () {
    final gap = PracticeController(
      lesson: lessonById('add_100_gap'),
      tasks: const [Task(a: 34, b: 37, op: Operation.add, form: TaskForm.gap)],
      stopwatch: FakeStopwatch(),
    );
    gap.pressDigit(7);
    gap.pressDigit(1);
    expect(gap.submit(), AnswerFeedback.wrong); // 71 is the result, not the gap
    gap.pressDigit(3);
    gap.pressDigit(7);
    expect(gap.submit(), AnswerFeedback.correct);
  });
}
