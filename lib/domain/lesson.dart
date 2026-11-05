/// Lesson catalog for the math trainer.
///
/// This file has NO Flutter dependency. Lessons are plain constants with a
/// stable [LessonSpec.id] so that leaderboard entries stay valid across app
/// updates even if the catalog order changes.
library;

/// The section a lesson belongs to on the lesson screen.
///
/// The first four are number ranges. The last two group by operation instead:
/// the times tables are learned table by table rather than by how big the
/// numbers get, and dividing belongs next to multiplying, not next to plus.
enum LessonGroup {
  firstSteps,
  upTo10,
  upTo20,
  upTo100,
  upTo1000,

  /// Working with thousands, but not with arbitrary four-digit numbers: whole
  /// thousands and whole hundreds, a placeholder among them, the places by
  /// name, and adding without crossing. Everything stays below 10000.
  withThousands,
  timesTables,
  reverseTimesTables,
  timesAndDivision,
  everyday,
}

/// The arithmetic operation of a lesson. [mixed] means each generated task
/// randomly picks [add] or [sub], [mulDiv] the same for [mul] and [div].
enum ArithmeticOp { add, sub, mixed, mul, div, mulDiv }

/// Whether a task must cross a place-value boundary ("Zehnerübergang").
enum CarryMode {
  /// No carry/borrow is allowed (e.g. 42 + 35, 78 - 35).
  none,

  /// A carry/borrow is required (e.g. 47 + 38, 72 - 38).
  required,

  /// No constraint - either is fine.
  any,
}

/// How the pictures of a counting task are laid out.
///
/// A row can be counted by running a finger along it. A scattered cloud
/// cannot: the child has to keep track of what is already counted. That is a
/// different skill, and it belongs in its own lesson rather than mixed in.
enum PictureArrangement { row, scattered }

/// How big the numbers in a product or quotient get.
enum FactorScale {
  /// Both factors between 1 and 10 - the small times table.
  table,

  /// One factor is a whole ten: 30 · 4. The step out of the table that costs
  /// nothing but a zero.
  tens,

  /// One factor is two-digit: 14 · 6.
  twoDigit,
}

/// The presentation form of a task.
enum TaskForm {
  /// `a op b = ?` - the result is asked for.
  result,

  /// `a op ? = r` - the second operand is asked for.
  gap,

  /// Not written as a calculation at all: "which number goes with 3?".
  /// For children who are still learning the pairs by heart, before they
  /// read equations.
  partner,

  /// `a : b = ? Rest ?` - two numbers to enter, the quotient and what is
  /// left over.
  remainder,

  /// Amounts of money: `3,50 € + 1,20 € = ? € ? ct`. Two boxes rather than a
  /// comma key, so the keypad stays the same everywhere.
  money,

  /// A clock face to read: `? Uhr ?`.
  clock,

  /// A clock face to say out loud: the spoken form ("viertel vor") and the
  /// hour it names. Two answers, and the first one is a word.
  clockPhrase,

  /// An amount to lay out from coins and notes. The answer is not typed at
  /// all - it is the pieces that were tapped.
  moneyCompose,

  /// A price, a round amount handed over, and the change as the answer.
  change,

  /// A handful of pictures to count.
  quantity,

  /// One or two dice, showing pips and the numeral underneath.
  dice,

  /// Two groups of pictures side by side; the larger count is the answer.
  compare,

  /// A row of numbers with the next one missing: `1 2 3 ?`.
  sequence,

  /// Two groups of pictures to add up: three bees and four bees.
  quantityAdd,

  /// `a · b + c` - two operations in one term, and the point one (`·` or
  /// `:`) is worked out first, whichever side of the term it sits on.
  chain,

  /// "5 Einer, 12 Zehner, 3 Hunderter" - what number is that? Place value
  /// read forwards, and the counts go past nine on purpose: twelve tens are
  /// a hundred and twenty, and that is the whole point of the exercise.
  placeValue,
}

/// Immutable description of one lesson. Lessons are defined as compile-time
/// constants in [lessonCatalog] and never stored in the database - only
/// their [id] is persisted (in sessions/leaderboard rows).
class LessonSpec {
  final String id;
  final LessonGroup group;
  final ArithmeticOp op;
  final CarryMode carry;
  final TaskForm form;

  /// When set, every task of this lesson adds up to exactly this number
  /// ("verliebte Zahlen": 3 + ? = 10). The pool is then a handful of pairs
  /// rather than a range, and the generator drills them instead of sampling.
  final int? fixedSum;

  /// When set, one of the two factors is always this number - the lesson
  /// drills a single row of the times table.
  final int? timesTable;

  /// How big multiplication and division get. Ignored by the other
  /// operations.
  final FactorScale scale;

  /// How a counting task arranges its pictures.
  final PictureArrangement arrangement;

  /// Whether each group also shows how many it holds.
  ///
  /// A number belongs where an amount is meant to be tied to it - comparing
  /// two heaps, adding two of them. Where the exercise *is* the counting, it
  /// gives the answer away.
  final bool showCounts;

  /// For clock lessons: the minutes hand only ever lands on multiples of
  /// this. Half hours first, then quarters, then five-minute steps.
  final int minuteStep;

  /// Whether the clock is read as a 24-hour time. The hands look the same at
  /// 3 and at 15 o'clock, so these tasks also name the part of the day.
  final bool clock24;

  /// When set, both operands are multiples of this - 1000 for whole
  /// thousands, 100 for whole hundreds.
  ///
  /// A property of the numbers, not a form of its own: "3000 + 4000 = ?" is
  /// still written, answered and stored like any other addition. Zero means
  /// the lesson draws freely.
  final int roundTo;

  /// Whether this lesson is measured and ranked.
  ///
  /// The first steps are not: no clock, no leaderboard, and the stars are for
  /// finishing rather than for being fast. Counting five apples is an
  /// achievement in itself, and racing a sibling would turn it into a
  /// humiliation.
  final bool scored;

  const LessonSpec({
    required this.id,
    required this.group,
    required this.op,
    required this.carry,
    required this.form,
    this.fixedSum,
    this.roundTo = 0,
    this.timesTable,
    this.scale = FactorScale.table,
    this.minuteStep = 0,
    this.clock24 = false,
    this.scored = true,
    this.arrangement = PictureArrangement.row,
    this.showCounts = false,
  });

  /// Time per task that earns all three lightning bolts, in milliseconds.
  /// Zero for a lesson that is not timed at all.
  ///
  /// Derived rather than written down 54 times: what makes a lesson slow is
  /// the size of its numbers, whether the answer has to be worked backwards,
  /// and how many taps it takes. Writing a triple of seconds under every
  /// lesson by hand would be 54 invented numbers that nobody could keep
  /// consistent with each other.
  ///
  /// The measured value is the penalised time per task, so these targets
  /// already include what a mistake costs.
  int get targetMsPerTask {
    if (!scored) return 0;

    final base = switch (group) {
      // Not timed; handled by the guard above, listed for completeness.
      LessonGroup.firstSteps => 0,
      LessonGroup.upTo10 => 3000,
      LessonGroup.upTo20 => 4000,
      LessonGroup.upTo100 => 6000,
      LessonGroup.upTo1000 => 9000,
      // Four-digit numbers, but the lessons here lean on whole thousands and
      // hundreds rather than on hard column arithmetic.
      LessonGroup.withThousands => 11000,
      // A row of the times table is learnt by heart, so it is quick once it
      // sits - quicker than adding two-digit numbers.
      LessonGroup.timesTables => 4000,
      // Dividing takes a moment longer than the multiplication it undoes:
      // the row has to be searched from the other end.
      LessonGroup.reverseTimesTables => 5000,
      LessonGroup.timesAndDivision => 7000,
      // Reading a dial or a price tag takes longer than reading two numbers.
      LessonGroup.everyday => 8000,
    };

    final byForm = switch (form) {
      // Working backwards from the result takes longer than working forwards.
      TaskForm.gap => 1.3,
      // Two answers, and the second one has to be worked out separately.
      TaskForm.remainder => 1.4,
      // Eleven pairs learnt by heart - these should come out fast.
      TaskForm.partner => 0.7,
      TaskForm.money || TaskForm.change => 1.2,
      TaskForm.clockPhrase => 1.3,
      // Several taps per task, not one: laying out an amount is slower than
      // any other answer in the app.
      TaskForm.moneyCompose => 2.0,
      // Two calculations instead of one, plus deciding which comes first.
      TaskForm.chain => 1.5,
      // Up to four parts to put together, and the ones above nine have to be
      // carried over into the next place.
      TaskForm.placeValue => 1.2,
      _ => 1.0,
    };

    // Whole thousands are the small table with three noughts behind it, and
    // whole hundreds are barely harder. Without this they would be measured
    // as if every one of them were real four-digit arithmetic.
    final byRound = switch (roundTo) {
      >= 1000 => 0.6,
      >= 100 => 0.8,
      _ => 1.0,
    };

    final byCarry = carry == CarryMode.required ? 1.15 : 1.0;
    final byOp = op == ArithmeticOp.mixed ? 1.1 : 1.0;

    // The rows the catalogue puts first are the ones that sit first: doubling,
    // fives and tens come back faster than the seven times table ever does.
    final byTable = switch (timesTable) {
      2 || 5 || 10 => 0.85,
      // All rows at once: every task starts by working out which row it is.
      null when group == LessonGroup.timesTables ||
          group == LessonGroup.reverseTimesTables =>
        1.1,
      _ => 1.0,
    };

    // To a tenth of a second: the targets are shown to children, and
    // "6,9 s" is a number to aim at while "6,873 s" is noise.
    return ((base * byForm * byRound * byCarry * byOp * byTable) / 100)
            .round() *
        100;
  }

  @override
  String toString() => 'LessonSpec($id)';
}

/// Builds the seven lessons every number range offers, so the three groups
/// stay in step with each other.
///
/// Up to 100 the only boundary is the ten and the texts name it; up to 1000
/// a task may cross the ten or the hundred and they stay general. That is
/// the one difference between the groups, and it lives in the texts
/// (`lesson_texts.dart`), not here.
List<LessonSpec> _rangeGroup(LessonGroup group, String suffix) {
  return [
    LessonSpec(
      id: 'add_${suffix}_plain',
      group: group,
      op: ArithmeticOp.add,
      carry: CarryMode.none,
      form: TaskForm.result,
    ),
    LessonSpec(
      id: 'add_${suffix}_carry',
      group: group,
      op: ArithmeticOp.add,
      carry: CarryMode.required,
      form: TaskForm.result,
    ),
    LessonSpec(
      id: 'sub_${suffix}_plain',
      group: group,
      op: ArithmeticOp.sub,
      carry: CarryMode.none,
      form: TaskForm.result,
    ),
    LessonSpec(
      id: 'sub_${suffix}_borrow',
      group: group,
      op: ArithmeticOp.sub,
      carry: CarryMode.required,
      form: TaskForm.result,
    ),
    LessonSpec(
      id: 'add_${suffix}_gap',
      group: group,
      op: ArithmeticOp.add,
      carry: CarryMode.any,
      form: TaskForm.gap,
    ),
    LessonSpec(
      id: 'sub_${suffix}_gap',
      group: group,
      op: ArithmeticOp.sub,
      carry: CarryMode.any,
      form: TaskForm.gap,
    ),
    LessonSpec(
      id: 'mix_$suffix',
      group: group,
      op: ArithmeticOp.mixed,
      carry: CarryMode.any,
      form: TaskForm.result,
    ),
  ];
}

/// The very first exercise of all: the pairs that make ten. Everything that
/// follows - especially the Zehnerübergang - builds on knowing these by heart.
const _partnersOfTen = LessonSpec(
  id: 'partners_of_ten',
  group: LessonGroup.upTo10,
  op: ArithmeticOp.add,
  carry: CarryMode.any,
  form: TaskForm.partner,
  fixedSum: 10,
);

/// The range up to ten gets its own, shorter set: nothing here can cross the
/// ten, so splitting the lessons into "mit" and "ohne Zehnerübergang" would be
/// a distinction without a difference.
const _upTo10Lessons = [
  LessonSpec(
    id: 'add_10',
    group: LessonGroup.upTo10,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.result,
  ),
  LessonSpec(
    id: 'sub_10',
    group: LessonGroup.upTo10,
    op: ArithmeticOp.sub,
    carry: CarryMode.any,
    form: TaskForm.result,
  ),
  LessonSpec(
    id: 'add_10_gap',
    group: LessonGroup.upTo10,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.gap,
  ),
  LessonSpec(
    id: 'sub_10_gap',
    group: LessonGroup.upTo10,
    op: ArithmeticOp.sub,
    carry: CarryMode.any,
    form: TaskForm.gap,
  ),
  LessonSpec(
    id: 'mix_10',
    group: LessonGroup.upTo10,
    op: ArithmeticOp.mixed,
    carry: CarryMode.any,
    form: TaskForm.result,
  ),
];

/// Rows of the small times table, in the order they are usually taught: the
/// ones with an obvious pattern first, the awkward ones last.
const _tableOrder = [2, 5, 10, 3, 4, 6, 7, 8, 9];

List<LessonSpec> _timesTableLessons() => [
      for (final n in _tableOrder)
        LessonSpec(
          id: 'times_$n',
          group: LessonGroup.timesTables,
          op: ArithmeticOp.mul,
          carry: CarryMode.any,
          form: TaskForm.result,
          timesTable: n,
        ),
      const LessonSpec(
        id: 'times_all',
        group: LessonGroup.timesTables,
        op: ArithmeticOp.mul,
        carry: CarryMode.any,
        form: TaskForm.result,
      ),
    ];

/// The times tables read backwards: one lesson per row, dividing by it.
///
/// Its own group rather than a corner of "Mal und Geteilt", because it is
/// learnt the same way the tables are - row by row, until each one sits. The
/// row that has just been drilled forwards is the one to try backwards.
List<LessonSpec> _reverseTimesTableLessons() => [
      for (final n in _tableOrder)
        LessonSpec(
          id: 'div_by_$n',
          group: LessonGroup.reverseTimesTables,
          op: ArithmeticOp.div,
          carry: CarryMode.any,
          form: TaskForm.result,
          timesTable: n,
        ),
      // Closes the group the way "Alle Reihen gemischt" closes the tables.
      // Keeps its old id: it has leaderboards behind it.
      const LessonSpec(
        id: 'div_plain',
        group: LessonGroup.reverseTimesTables,
        op: ArithmeticOp.div,
        carry: CarryMode.any,
        form: TaskForm.result,
      ),
    ];

const _timesAndDivisionLessons = [
  LessonSpec(
    id: 'div_remainder',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.div,
    carry: CarryMode.any,
    form: TaskForm.remainder,
  ),
  LessonSpec(
    id: 'times_gap',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.mul,
    carry: CarryMode.any,
    form: TaskForm.gap,
  ),
  LessonSpec(
    id: 'div_gap',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.div,
    carry: CarryMode.any,
    form: TaskForm.gap,
  ),
  LessonSpec(
    id: 'mul_tens',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.mul,
    carry: CarryMode.any,
    form: TaskForm.result,
    scale: FactorScale.tens,
  ),
  LessonSpec(
    id: 'mul_two_digit',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.mul,
    carry: CarryMode.any,
    form: TaskForm.result,
    scale: FactorScale.twoDigit,
  ),
  LessonSpec(
    id: 'div_two_digit',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.div,
    carry: CarryMode.any,
    form: TaskForm.result,
    scale: FactorScale.twoDigit,
  ),
  LessonSpec(
    id: 'mul_div_mixed',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.mulDiv,
    carry: CarryMode.any,
    form: TaskForm.result,
  ),
  LessonSpec(
    id: 'punkt_vor_strich',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.mulDiv,
    carry: CarryMode.any,
    form: TaskForm.chain,
  ),
];

/// The gentlest group: counting, recognising dice patterns, comparing
/// amounts, the number line, and sums that stay within one hand.
///
/// None of it is timed or ranked - see [LessonSpec.scored].
const _firstStepsLessons = [
  LessonSpec(
    id: 'count_pictures',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.quantity,
    scored: false,
  ),
  LessonSpec(
    id: 'count_pictures_cloud',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.quantity,
    scored: false,
    arrangement: PictureArrangement.scattered,
  ),
  LessonSpec(
    id: 'count_dice',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.dice,
    scored: false,
  ),
  LessonSpec(
    id: 'compare_more',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.compare,
    scored: false,
    showCounts: true,
  ),
  LessonSpec(
    id: 'compare_more_cloud',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.compare,
    scored: false,
    arrangement: PictureArrangement.scattered,
    showCounts: true,
  ),
  LessonSpec(
    id: 'count_next',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.sequence,
    scored: false,
  ),
  LessonSpec(
    id: 'bees_add',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.quantityAdd,
    scored: false,
    showCounts: true,
  ),
  LessonSpec(
    id: 'bees_add_cloud',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.quantityAdd,
    scored: false,
    arrangement: PictureArrangement.scattered,
    showCounts: true,
  ),
  LessonSpec(
    id: 'dice_add',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.dice,
    scored: false,
    showCounts: true,
  ),
  LessonSpec(
    id: 'add_to_six',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.result,
    scored: false,
  ),
  LessonSpec(
    id: 'sub_to_six',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.sub,
    carry: CarryMode.any,
    form: TaskForm.result,
    scored: false,
  ),
  // The id stays as it was: renaming it would cut every run already recorded
  // under it loose from its lesson.
  LessonSpec(
    id: 'calc_to_six',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.mixed,
    carry: CarryMode.any,
    form: TaskForm.result,
    scored: false,
  ),
];

/// Reading a clock and handling money: the two places where school maths
/// walks out of the exercise book. Both ask for two numbers, which the app
/// already knows how to take from the division with remainder.
const _everydayLessons = [
  LessonSpec(
    id: 'clock_half',
    group: LessonGroup.everyday,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.clock,
    minuteStep: 30,
  ),
  LessonSpec(
    id: 'clock_quarter',
    group: LessonGroup.everyday,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.clock,
    minuteStep: 15,
  ),
  LessonSpec(
    id: 'clock_five',
    group: LessonGroup.everyday,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.clock,
    minuteStep: 5,
  ),
  LessonSpec(
    id: 'clock_24',
    group: LessonGroup.everyday,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.clock,
    minuteStep: 5,
    clock24: true,
  ),
  LessonSpec(
    id: 'clock_words',
    group: LessonGroup.everyday,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.clockPhrase,
    minuteStep: 5,
  ),
  LessonSpec(
    id: 'money_add',
    group: LessonGroup.everyday,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.money,
  ),
  LessonSpec(
    id: 'money_sub',
    group: LessonGroup.everyday,
    op: ArithmeticOp.sub,
    carry: CarryMode.any,
    form: TaskForm.money,
  ),
  LessonSpec(
    id: 'money_compose',
    group: LessonGroup.everyday,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.moneyCompose,
  ),
  LessonSpec(
    id: 'money_change',
    group: LessonGroup.everyday,
    op: ArithmeticOp.sub,
    carry: CarryMode.any,
    form: TaskForm.change,
  ),
];

/// Place value as a question, the small version: ones and tens only.
///
/// Same idea as [_placeValueTo1000] one range further up, and the same twist:
/// "13 Einer, 4 Zehner" is 53, so the ones have to be carried over into the
/// tens. Below a hundred there are only two places to name, which is what
/// makes this the one to start with.
const _placeValueTo100 = LessonSpec(
  id: 'place_value_100',
  group: LessonGroup.upTo100,
  op: ArithmeticOp.add,
  carry: CarryMode.any,
  form: TaskForm.placeValue,
);

/// Place value as a question: how many ones, tens and hundreds make which
/// number.
///
/// The counts deliberately run past nine. "3 Zehner" is reading a digit off;
/// "12 Zehner" is the step that says what a place actually means. The answer
/// stays below 1000 - the range this group is named after.
const _placeValueTo1000 = LessonSpec(
  id: 'place_value_1000',
  group: LessonGroup.upTo1000,
  op: ArithmeticOp.add,
  carry: CarryMode.any,
  form: TaskForm.placeValue,
);

/// Working with thousands, below ten thousand throughout.
///
/// Whole thousands first - that is the small times table with three noughts
/// behind it - then whole hundreds, then the same backwards as a placeholder.
/// The place-value question gets its fourth place here, where thousands
/// belong, and the last lesson adds and subtracts for real, but without a
/// crossing.
const _withThousandsLessons = [
  LessonSpec(
    id: 'round_thousands',
    group: LessonGroup.withThousands,
    op: ArithmeticOp.mixed,
    carry: CarryMode.any,
    form: TaskForm.result,
    roundTo: 1000,
  ),
  LessonSpec(
    id: 'round_hundreds',
    group: LessonGroup.withThousands,
    op: ArithmeticOp.mixed,
    carry: CarryMode.any,
    form: TaskForm.result,
    roundTo: 100,
  ),
  LessonSpec(
    id: 'round_gap',
    group: LessonGroup.withThousands,
    op: ArithmeticOp.mixed,
    carry: CarryMode.any,
    form: TaskForm.gap,
    roundTo: 1000,
  ),
  LessonSpec(
    id: 'place_value_10000',
    group: LessonGroup.withThousands,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.placeValue,
  ),
  LessonSpec(
    id: 'add_sub_10000_plain',
    group: LessonGroup.withThousands,
    op: ArithmeticOp.mixed,
    carry: CarryMode.none,
    form: TaskForm.result,
  ),
];

/// The full, fixed lesson catalog, ordered from the first steps up to 1000.
/// It opens with the pairs that make ten.
final List<LessonSpec> lessonCatalog = List.unmodifiable([
  ..._firstStepsLessons,
  _partnersOfTen,
  ..._upTo10Lessons,
  ..._rangeGroup(LessonGroup.upTo20, '20'),
  ..._rangeGroup(LessonGroup.upTo100, '100'),
  _placeValueTo100,
  ..._rangeGroup(LessonGroup.upTo1000, '1000'),
  _placeValueTo1000,
  ..._withThousandsLessons,
  ..._timesTableLessons(),
  ..._reverseTimesTableLessons(),
  ..._timesAndDivisionLessons,
  ..._everydayLessons,
]);

/// Looks up a lesson by its stable id. Throws a [StateError] if unknown.
LessonSpec lessonById(String id) =>
    lessonByIdOrNull(id) ?? (throw StateError('Unknown lesson id: $id'));

/// Same, but null for an id the catalogue no longer has.
///
/// Stored runs outlive the catalogue: a backup from a newer version, or a
/// lesson dropped in an update, would otherwise take the parent area down
/// with it.
LessonSpec? lessonByIdOrNull(String id) {
  for (final lesson in lessonCatalog) {
    if (lesson.id == id) return lesson;
  }
  return null;
}

/// All lessons belonging to one [LessonGroup], in catalog order.
List<LessonSpec> lessonsInGroup(LessonGroup group) =>
    lessonCatalog.where((l) => l.group == group).toList(growable: false);

/// Ids of every lesson that is neither timed nor ranked. The statistics
/// queries need this as a plain list, because SQL cannot read the catalogue.
final List<String> unscoredLessonIds = List.unmodifiable([
  for (final lesson in lessonCatalog)
    if (!lesson.scored) lesson.id,
]);

/// Allowed task counts a user may pick before starting a session. The first
/// steps get a shorter option too - ten counting tasks is already a session.
const List<int> selectableTaskCounts = [5, 10, 20, 30, 50];
