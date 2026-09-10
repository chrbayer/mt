/// A single arithmetic task. No Flutter dependency.
library;

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

/// How a time is said out loud, in five-minute steps. The index is the
/// answer to a [TaskForm.clockPhrase] task: minute 5 is index 0.
///
/// The full hour is deliberately missing. "3 Uhr" puts the hour first and
/// every other reading puts it last, and a box that swaps places with its
/// neighbour depending on the answer would be a puzzle of its own. Full hours
/// are practised in the three lessons that ask for the digits.
const clockPhrases = [
  '5 nach', // :05
  '10 nach', // :10
  'viertel nach', // :15
  '20 nach', // :20
  '5 vor halb', // :25
  'halb', // :30
  '5 nach halb', // :35
  '20 vor', // :40
  'viertel vor', // :45
  '10 vor', // :50
  '5 vor', // :55
];

/// Coins and notes a child actually handles, in cents. One and two cent
/// pieces are left out: every amount asked for lands on five cents, and two
/// more keys would only make the pad harder to aim at.
const moneyPieces = [5, 10, 20, 50, 100, 200, 500, 1000, 2000];

/// The word for the part of the day, so a clock face can be read as a
/// 24-hour time at all: the hands look the same at 3 and at 15 o'clock.
String dayPartOf(int hour) => switch (hour) {
      < 12 => 'vormittags',
      // Twelve is its own word, and it is the hour where the counting starts
      // to differ from the dial - the one worth naming exactly.
      12 => 'mittags',
      < 18 => 'nachmittags',
      _ => 'abends',
    };

/// A single coin or note, the way it is stamped on it: `50 ct`, `2 €`.
String formatPiece(int cents) =>
    cents < 100 ? '$cents ct' : '${cents ~/ 100} €';

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
        TaskForm.quantityAdd =>
          false,
      };

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

  /// The hour a spoken time names. From half past onwards German counts
  /// towards the coming hour: 2:30 is "halb 3", 2:45 is "viertel vor 3".
  int get namedHour => b >= 25 ? a % 12 + 1 : a;

  /// The whole spoken form, for the review list and the lesson tile.
  String get spokenTime => '${clockPhrases[expected]} $namedHour';

  /// Which part of the day a 24-hour clock task falls in.
  String get dayPart => dayPartOf(a);

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
      };

  /// The second number to enter, for the forms that ask for two. Null for the
  /// ones that ask for one.
  int? get expectedSecond => switch (form) {
        TaskForm.remainder => remainder,
        TaskForm.money || TaskForm.change => result % 100,
        TaskForm.clock => b,
        // "halb 3" names the hour that is coming, not the one gone by.
        TaskForm.clockPhrase => namedHour,
        TaskForm.moneyCompose => null,
        TaskForm.result ||
        TaskForm.gap ||
        TaskForm.partner ||
        TaskForm.quantity ||
        TaskForm.dice ||
        TaskForm.compare ||
        TaskForm.sequence ||
        TaskForm.quantityAdd ||
        TaskForm.chain =>
          null,
      };

  /// Label between the two boxes, for the forms that have two.
  String get secondLabel => switch (form) {
        TaskForm.remainder => 'Rest',
        TaskForm.money || TaskForm.change => '€',
        TaskForm.clock => 'Uhr',
        _ => '',
      };

  /// Unit after the second box, where there is one.
  String get secondUnit =>
      form == TaskForm.money || form == TaskForm.change ? 'ct' : '';

  /// Spoken form of the task, shown above it for the forms that are not
  /// written as an equation. Null when the task speaks for itself.
  String? get question => switch (form) {
        TaskForm.partner => 'Welche Zahl ist mit $a verliebt?',
        TaskForm.clock => 'Wie spät ist es?',
        TaskForm.clockPhrase => 'Wie sagt man das?',
        TaskForm.moneyCompose =>
          'Lege ${formatEuro(a)} - tippe die Münzen und Scheine an.',
        // The price and what is handed over are both in the question, so
        // nothing is written as an equation: at the till nobody writes one.
        TaskForm.change => 'Es kostet ${formatEuro(b)}. '
            'Du gibst ${formatEuro(a)}. Wie viel bekommst du zurück?',
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
  String get opSymbol => symbolOf(op);

  /// Text shown left of the input box.
  String get prefix => switch (form) {
        TaskForm.result || TaskForm.remainder => '$a $opSymbol $b =',
        TaskForm.gap => '$a $opSymbol',
        // The heart between the two numbers replaces the operator.
        TaskForm.partner => '$a',
        TaskForm.money => '${formatEuro(a)} $opSymbol ${formatEuro(b)} =',
        // The row so far, and the box takes the place of the next number.
        // This one used to sit in the list below and showed nothing at all:
        // a question, an empty box and no numbers to continue.
        TaskForm.sequence => sequenceNumbers.join(' '),
        // Punkt vor Strich: the whole term, both operators included. Nothing
        // else says which one binds first, so the term has to stand there
        // and speak for itself.
        TaskForm.chain => '$a $opSymbol $b ${symbolOf(op2!)} $c =',
        // These all draw their own picture; there is nothing to write.
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
        TaskForm.clockPhrase => spokenTime,
        TaskForm.moneyCompose => formatEuro(a),
        TaskForm.change => '${formatEuro(b)}, bezahlt mit ${formatEuro(a)}',
        TaskForm.quantity => pictureFor(a, b) * a,
        // "Würfel 2" told nobody anything; the pips are what is on screen.
        TaskForm.dice => b == 0 ? '$a Punkte' : '$a + $b Punkte',
        TaskForm.compare =>
          '${pictureFor(a, b) * a}  ·  ${pictureFor(a, b) * b}',
        TaskForm.sequence => '${sequenceNumbers.join(' ')} ?',
        TaskForm.quantityAdd =>
          '${picture * a} + ${picture * b}',
        TaskForm.chain => '$prefix $answer',
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
