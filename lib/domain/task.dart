/// A single arithmetic task. No Flutter dependency.
library;

import 'clock_speech.dart';
import 'lesson.dart';

/// The concrete operation of a generated task ([ArithmeticOp.mixed] is
/// resolved to one of these when the task is created).
enum Operation { add, sub, mul, div }

/// U+2212 MINUS SIGN reads better than a hyphen at large font sizes. The
/// multiplication dot and the colon are what German primary schools write.
///
/// A free function rather than a [Task] getter: [TaskForm.chain] has two
/// operations, and its `prefix` needs the symbol for the second one too.
String symbolOf(Operation op) => switch (op) {
      Operation.add => '+',
      Operation.sub => '−',
      Operation.mul => '·',
      Operation.div => ':',
    };

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

/// Coins and notes a child actually handles, in cents. One and two cent
/// pieces are left out: every amount asked for lands on five cents, and two
/// more keys would only make the pad harder to aim at.
const moneyPieces = [5, 10, 20, 50, 100, 200, 500, 1000, 2000];

/// The part of the day, so a clock face can be read as a 24-hour time at
/// all: the hands look the same at 3 and at 15 o'clock. The word for it is
/// text and lives in the l10n layer.
enum DayPart { morning, noon, afternoon, evening }

/// Which part of the day an hour of a 24-hour clock falls in.
DayPart dayPartOf(int hour) => switch (hour) {
      < 12 => DayPart.morning,
      // Twelve is its own word, and it is the hour where the counting starts
      // to differ from the dial - the one worth naming exactly.
      12 => DayPart.noon,
      < 18 => DayPart.afternoon,
      _ => DayPart.evening,
    };

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

  /// The third operand of a [TaskForm.chain] task. Null for every other
  /// form: two operands were enough for them.
  final int? c;

  /// The second operation of a [TaskForm.chain] task - always the opposite
  /// kind from [op] (one of the two is multiplication or division, the other
  /// addition or subtraction). Null for every other form.
  final Operation? op2;

  const Task({
    required this.a,
    required this.b,
    required this.op,
    required this.form,
    this.c,
    this.op2,
  });

  /// Whether this form is an arithmetic task at all. Counting apples and
  /// reading a clock are not, and [op] carries no meaning for them.
  bool get _isCalculation => switch (form) {
        TaskForm.result ||
        TaskForm.gap ||
        TaskForm.remainder ||
        TaskForm.money ||
        TaskForm.change ||
        TaskForm.chain =>
          true,
        TaskForm.partner ||
        TaskForm.clock ||
        TaskForm.clockPhrase ||
        TaskForm.moneyCompose ||
        TaskForm.quantity ||
        TaskForm.dice ||
        TaskForm.compare ||
        TaskForm.sequence ||
        TaskForm.quantityAdd ||
        TaskForm.placeValue =>
          false,
      };

  /// The four place-value counts, smallest first: ones, tens, hundreds,
  /// thousands. Zero means the place is not named at all.
  ///
  /// Four counts in three fields, and they fit: a thousands count above nine
  /// would push the answer past 9999, so thousands and hundreds share `c` as
  /// `100 * Tausender + Hunderter`. That keeps the task inside `operandA`,
  /// `operandB` and `operandC`, which is what the database stores and what
  /// the review list rebuilds a task from.
  List<int> get places => [a, b, (c ?? 0) % 100, (c ?? 0) ~/ 100];

  /// Applies one operation to two numbers. Shared by [result] and
  /// [_chainResult] so the arithmetic itself is written down exactly once.
  int _apply(Operation op, int x, int y) => switch (op) {
        Operation.add => x + y,
        Operation.sub => x - y,
        Operation.mul => x * y,
        Operation.div => x ~/ y,
      };

  /// Punkt vor Strich: the multiplication or division is worked out first,
  /// whichever side of the term it sits on - `a` and `b` are always the
  /// operands shown first and second, so which one carries the point
  /// operation depends on whether [op] or [op2] is `mul`/`div`.
  int get _chainResult {
    final second = op2!;
    return op == Operation.mul || op == Operation.div
        ? _apply(second, _apply(op, a, b), c!) //  a · b + c
        : _apply(op, a, _apply(second, b, c!)); //  a + b · c
  }

  /// Result of the underlying calculation. For a division this is the whole
  /// part; see [remainder] for what is left over.
  ///
  /// Where there is no calculation this is simply the answer - otherwise a
  /// clock showing 9:45 would claim a "result" of 54.
  int get result {
    if (!_isCalculation) return expected;
    if (form == TaskForm.chain) return _chainResult;
    return _apply(op, a, b);
  }

  /// What a division leaves over. Zero for every other operation.
  int get remainder => op == Operation.div ? a % b : 0;

  /// The hour a spoken time names, in the way [speech] counts: German counts
  /// towards the coming hour from half past on (2:30 is "halb 3").
  int namedHourIn(ClockSpeech speech) => speech.namedHour(expected, a);

  /// Which part of the day a 24-hour clock task falls in.
  DayPart get dayPart => dayPartOf(a);

  /// The number the child has to type in - the first of two where a task
  /// asks for two.
  int get expected => switch (form) {
        TaskForm.result || TaskForm.remainder || TaskForm.chain => result,
        TaskForm.gap || TaskForm.partner => b,
        // Amounts are held in cents, so this is the euro part.
        TaskForm.money || TaskForm.change => result ~/ 100,
        // The whole amount in cents; there is nothing to split into two
        // boxes, because the pieces themselves are the answer.
        TaskForm.moneyCompose => a,
        // Which of the spoken forms fits - "viertel vor", "halb", …
        TaskForm.clockPhrase => b ~/ 5 - 1,
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
        // Ones, tens, hundreds, thousands - each count times what its place
        // is worth.
        TaskForm.placeValue => places[0] +
            10 * places[1] +
            100 * places[2] +
            1000 * places[3],
      };

  /// The second number to enter, for the forms that ask for two. Null for the
  /// ones that ask for one.
  ///
  /// Only a spoken time depends on the language - the hour it names is
  /// counted differently - so this answers for German; [expectedSecondIn]
  /// takes the language.
  int? get expectedSecond => expectedSecondIn(ClockSpeech.de);

  /// Same, for the language the time is spoken in.
  int? expectedSecondIn(ClockSpeech speech) => switch (form) {
        TaskForm.remainder => remainder,
        TaskForm.money || TaskForm.change => result % 100,
        TaskForm.clock => b,
        // "halb 3" names the hour that is coming, not the one gone by - in
        // German; the language decides.
        TaskForm.clockPhrase => namedHourIn(speech),
        TaskForm.moneyCompose => null,
        TaskForm.result ||
        TaskForm.gap ||
        TaskForm.partner ||
        TaskForm.quantity ||
        TaskForm.dice ||
        TaskForm.compare ||
        TaskForm.sequence ||
        TaskForm.quantityAdd ||
        TaskForm.placeValue ||
        TaskForm.chain =>
          null,
      };

  /// How many digits the answer can have.
  ///
  /// The box refuses one digit too many instead of swallowing it, and how
  /// many that is depends on the task rather than on the app: three up to a
  /// thousand, four for the lessons that work with thousands.
  int get maxAnswerDigits => expected > 999 ? 4 : 3;

  /// U+2212 MINUS SIGN reads better than a hyphen at large font sizes. The
  /// multiplication dot and the colon are what German primary schools write.
  String get opSymbol => symbolOf(op);

  /// Text shown left of the input box.
  String get prefix => switch (form) {
        TaskForm.result || TaskForm.remainder => '$a $opSymbol $b =',
        TaskForm.gap => '$a $opSymbol',
        // The heart between the two numbers replaces the operator.
        TaskForm.partner => '$a',
        // The row so far, and the box takes the place of the next number.
        // This one used to sit in the list below and showed nothing at all:
        // a question, an empty box and no numbers to continue.
        TaskForm.sequence => sequenceNumbers.join(' '),
        // Punkt vor Strich: the whole term, both operators included. Nothing
        // else says which one binds first, so the term has to stand there
        // and speak for itself.
        TaskForm.chain => '$a $opSymbol $b ${symbolOf(op2!)} $c =',
        // Amounts and place-value parts are written with words and a money
        // format, which belong to the language: see `taskPrefix` in l10n.
        // These all draw their own picture; there is nothing to write.
        TaskForm.money ||
        TaskForm.placeValue ||
        TaskForm.clock ||
        TaskForm.clockPhrase ||
        TaskForm.moneyCompose ||
        TaskForm.change ||
        TaskForm.quantity ||
        TaskForm.dice ||
        TaskForm.compare ||
        TaskForm.quantityAdd =>
          '',
      };

  /// Text shown right of the input box, empty when the box comes last. The
  /// remainder form has its own second box instead, drawn by the display.
  String get suffix => form == TaskForm.gap ? '= $result' : '';

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
    // Two tasks that name the same counts are the same task; c holds two of
    // the four, so it has to be part of the key.
    if (form == TaskForm.placeValue) return '$a:$b:$c:places';
    // Unlike `result`, the order here is exactly what is being drilled: `3 ·
    // 6 + 40` and `40 − 3 · 6` are different facts, not the same one shown
    // two ways.
    if (form == TaskForm.chain) return '$a:$b:$c:${op.name}:${op2!.name}';
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
      other.form == form &&
      other.c == c &&
      other.op2 == op2;

  @override
  int get hashCode => Object.hash(a, b, op, form, c, op2);

  @override
  String toString() => 'Task($form, $a, $b, $op)';
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
