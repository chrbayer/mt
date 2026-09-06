/// A single arithmetic task. No Flutter dependency.
library;

import 'lesson.dart';

/// The concrete operation of a generated task ([ArithmeticOp.mixed] is
/// resolved to one of these when the task is created).
enum Operation { add, sub, mul, div }

/// Pictures for the counting lessons. Emoji rather than assets: instantly
/// recognisable, nothing to ship, and every one of them is a thing a child
/// can name out loud.
const countingPictures = ['🍎', '🐟', '⭐', '🚗', '🐝', '🎈'];

/// Which picture a counting task uses.
///
/// Derived from the operands rather than stored, because the picture is
/// decoration: counting three apples and counting three fish is the same
/// exercise, and the review pool should treat them as one.
String pictureFor(int a, int b) =>
    countingPictures[(a * 5 + b) % countingPictures.length];

/// Cents as they are written on a price tag: `350` becomes `3,50 €`.
String formatEuro(int cents) =>
    '${cents ~/ 100},${(cents % 100).toString().padLeft(2, '0')} €';

/// One generated exercise.
///
/// [a] and [b] are always the operands of the underlying calculation
/// `a op b = result`, independent of how the task is presented. For
/// [TaskForm.gap] the child sees `a op ? = result` and has to supply [b].
class Task {
  final int a;
  final int b;
  final Operation op;
  final TaskForm form;

  const Task({
    required this.a,
    required this.b,
    required this.op,
    required this.form,
  });

  /// Whether this form is an arithmetic task at all. Counting apples and
  /// reading a clock are not, and [op] carries no meaning for them.
  bool get _isCalculation => switch (form) {
        TaskForm.result ||
        TaskForm.gap ||
        TaskForm.remainder ||
        TaskForm.money =>
          true,
        TaskForm.partner ||
        TaskForm.clock ||
        TaskForm.quantity ||
        TaskForm.dice ||
        TaskForm.compare ||
        TaskForm.sequence ||
        TaskForm.quantityAdd =>
          false,
      };

  /// Result of the underlying calculation. For a division this is the whole
  /// part; see [remainder] for what is left over.
  ///
  /// Where there is no calculation this is simply the answer - otherwise a
  /// clock showing 9:45 would claim a "result" of 54.
  int get result {
    if (!_isCalculation) return expected;
    return switch (op) {
      Operation.add => a + b,
      Operation.sub => a - b,
      Operation.mul => a * b,
      Operation.div => a ~/ b,
    };
  }

  /// What a division leaves over. Zero for every other operation.
  int get remainder => op == Operation.div ? a % b : 0;

  /// The number the child has to type in - the first of two where a task
  /// asks for two.
  int get expected => switch (form) {
        TaskForm.result || TaskForm.remainder => result,
        TaskForm.gap || TaskForm.partner => b,
        // Amounts are held in cents, so this is the euro part.
        TaskForm.money => result ~/ 100,
        // A clock task holds the time itself: hours in a, minutes in b.
        TaskForm.clock => a,
        // How many pictures there are; b only picks which picture.
        TaskForm.quantity => a,
        // One die (b == 0) or the two together.
        TaskForm.dice => a + b,
        // The bigger of the two heaps.
        TaskForm.compare => a > b ? a : b,
        // b == 0 counts up from a, b == 1 counts down.
        TaskForm.sequence => b == 0 ? a + 3 : a - 3,
        TaskForm.quantityAdd => a + b,
      };

  /// The second number to enter, for the forms that ask for two. Null for the
  /// ones that ask for one.
  int? get expectedSecond => switch (form) {
        TaskForm.remainder => remainder,
        TaskForm.money => result % 100,
        TaskForm.clock => b,
        TaskForm.result ||
        TaskForm.gap ||
        TaskForm.partner ||
        TaskForm.quantity ||
        TaskForm.dice ||
        TaskForm.compare ||
        TaskForm.sequence ||
        TaskForm.quantityAdd =>
          null,
      };

  /// Label between the two boxes, for the forms that have two.
  String get secondLabel => switch (form) {
        TaskForm.remainder => 'Rest',
        TaskForm.money => '€',
        TaskForm.clock => 'Uhr',
        _ => '',
      };

  /// Unit after the second box, where there is one.
  String get secondUnit => form == TaskForm.money ? 'ct' : '';

  /// Spoken form of the task, shown above it for the forms that are not
  /// written as an equation. Null when the task speaks for itself.
  String? get question => switch (form) {
        TaskForm.partner => 'Welche Zahl ist mit $a verliebt?',
        TaskForm.clock => 'Wie spät ist es?',
        TaskForm.quantity => 'Wie viele?',
        TaskForm.dice =>
          b == 0 ? 'Wie viele Punkte?' : 'Wie viele Punkte sind es zusammen?',
        // With a keypad the answer is a number, so the question has to say
        // which number - "wo sind mehr" alone would ask for a pointing finger.
        TaskForm.compare => 'Wo sind mehr? Tippe die größere Anzahl.',
        TaskForm.sequence => 'Welche Zahl kommt danach?',
        TaskForm.quantityAdd => 'Wie viele sind es zusammen?',
        _ => null,
      };

  /// U+2212 MINUS SIGN reads better than a hyphen at large font sizes. The
  /// multiplication dot and the colon are what German primary schools write.
  String get opSymbol => switch (op) {
        Operation.add => '+',
        Operation.sub => '−',
        Operation.mul => '·',
        Operation.div => ':',
      };

  /// Text shown left of the input box.
  String get prefix => switch (form) {
        TaskForm.result || TaskForm.remainder => '$a $opSymbol $b =',
        TaskForm.gap => '$a $opSymbol',
        // The heart between the two numbers replaces the operator.
        TaskForm.partner => '$a',
        TaskForm.money => '${formatEuro(a)} $opSymbol ${formatEuro(b)} =',
        // These all draw their own picture; there is nothing to write.
        TaskForm.clock ||
        TaskForm.quantity ||
        TaskForm.dice ||
        TaskForm.compare ||
        TaskForm.sequence ||
        TaskForm.quantityAdd =>
          '',
      };

  /// Text shown right of the input box, empty when the box comes last. The
  /// remainder form has its own second box instead, drawn by the display.
  String get suffix => form == TaskForm.gap ? '= $result' : '';

  /// One-line rendering with [answer] placed in the box, and
  /// [remainderAnswer] in the second one where there is one.
  String render(String answer, [String secondAnswer = '?']) => switch (form) {
        TaskForm.result => '$prefix $answer',
        TaskForm.gap => '$prefix $answer $suffix',
        TaskForm.partner => '$a \u2665 $answer',
        TaskForm.remainder => '$prefix $answer Rest $secondAnswer',
        TaskForm.money => '$prefix $answer',
        // A sample time says more about the lesson than a placeholder.
        TaskForm.clock => '$a:${b.toString().padLeft(2, '0')} Uhr',
        TaskForm.quantity => pictureFor(a, b) * a,
        // "Würfel 2" told nobody anything; the pips are what is on screen.
        TaskForm.dice => b == 0 ? '$a Punkte' : '$a + $b Punkte',
        TaskForm.compare =>
          '${pictureFor(a, b) * a}  ·  ${pictureFor(a, b) * b}',
        TaskForm.sequence => '${sequenceNumbers.join(' ')} ?',
        TaskForm.quantityAdd =>
          '${picture * a} + ${picture * b}',
      };

  /// The picture a counting or comparing task shows.
  ///
  /// The bee lesson always shows bees - it is named after them, and one
  /// picture that never changes is one thing less to take in.
  String get picture =>
      form == TaskForm.quantityAdd ? '🐝' : pictureFor(a, b);

  /// The numbers shown before the gap in a [TaskForm.sequence] task.
  List<int> get sequenceNumbers =>
      b == 0 ? [a, a + 1, a + 2] : [a, a - 1, a - 2];

  /// Stable key used to avoid repeating the same calculation in a session.
  ///
  /// Addition and multiplication are commutative, so `13 + 68` and `68 + 13`
  /// - or `3 · 7` and `7 · 3` - are the same fact and should not meet within
  /// a few tasks. For the other forms the order does matter: `13 + ? = 81`
  /// and `68 + ? = 81` ask for different numbers.
  String get key {
    if ((op == Operation.add || op == Operation.mul) &&
        form == TaskForm.result) {
      final (low, high) = a <= b ? (a, b) : (b, a);
      return '$low:$high:${op.name}';
    }
    return '$a:$b:${op.name}';
  }

  @override
  bool operator ==(Object other) =>
      other is Task &&
      other.a == a &&
      other.b == b &&
      other.op == op &&
      other.form == form;

  @override
  int get hashCode => Object.hash(a, b, op, form);

  @override
  String toString() => render('?');
}

/// A finished task together with how it went. Collected in memory during a
/// run and written to the database when the session ends.
class TaskResult {
  final Task task;

  /// Time from showing the task until the first correct answer, excluding
  /// time the app spent in the background.
  final int elapsedMs;

  /// How often a wrong answer was submitted before the correct one.
  final int wrongAttempts;

  const TaskResult({
    required this.task,
    required this.elapsedMs,
    required this.wrongAttempts,
  });
}
