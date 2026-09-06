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
  timesTables,
  timesAndDivision,
  everyday,
}

/// Heading of a group on the lesson screen.
String groupTitle(LessonGroup group) => switch (group) {
      LessonGroup.firstSteps => 'Erste Schritte',
      LessonGroup.upTo10 => 'Bis 10',
      LessonGroup.upTo20 => 'Bis 20',
      LessonGroup.upTo100 => 'Bis 100',
      LessonGroup.upTo1000 => 'Bis 1000',
      LessonGroup.timesTables => 'Einmaleins',
      LessonGroup.timesAndDivision => 'Mal und Geteilt',
      LessonGroup.everyday => 'Uhrzeit und Geld',
    };

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
}

/// Immutable description of one lesson. Lessons are defined as compile-time
/// constants in [lessonCatalog] and never stored in the database - only
/// their [id] is persisted (in sessions/leaderboard rows).
class LessonSpec {
  final String id;
  final String title;

  /// One sentence explaining what the lesson drills, shown when a child (or a
  /// parent) opens it. "Übergang" is not self-explanatory.
  final String description;
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

  /// Whether this lesson is measured and ranked.
  ///
  /// The first steps are not: no clock, no leaderboard, and the stars are for
  /// finishing rather than for being fast. Counting five apples is an
  /// achievement in itself, and racing a sibling would turn it into a
  /// humiliation.
  final bool scored;

  const LessonSpec({
    required this.id,
    required this.title,
    required this.description,
    required this.group,
    required this.op,
    required this.carry,
    required this.form,
    this.fixedSum,
    this.timesTable,
    this.scale = FactorScale.table,
    this.minuteStep = 0,
    this.scored = true,
    this.arrangement = PictureArrangement.row,
    this.showCounts = false,
  });

  @override
  String toString() => 'LessonSpec($id)';
}

// Shared wording. Up to 100 the only boundary is the ten, so the lessons name
// it; up to 1000 a task may cross the ten or the hundred, so they stay general.
const _addPlain = 'Die Einer bleiben zusammen unter 10 - '
    'es muss nichts übertragen werden.';
const _addCarry = 'Die Einer ergeben zusammen 10 oder mehr - '
    'ein Zehner wandert weiter.';
const _subPlain = 'Jede Ziffer oben ist groß genug - '
    'es muss kein Zehner aufgelöst werden.';
const _subBorrow = 'Die Einer oben reichen nicht - '
    'ein Zehner muss aufgelöst werden.';
const _gap = 'Gesucht ist die Zahl, die fehlt, damit die Rechnung stimmt.';
const _mixed = 'Plus und Minus wechseln sich zufällig ab, '
    'mit und ohne Übergang.';

const _addPlainBig = 'Keine Stelle läuft über - weder die Einer noch die Zehner.';
const _addCarryBig = 'Einer oder Zehner laufen über - es muss übertragen werden.';
const _subPlainBig = 'Jede Ziffer oben ist groß genug - '
    'es muss nichts aufgelöst werden.';
const _subBorrowBig = 'Eine Stelle oben reicht nicht - '
    'Zehner oder Hunderter müssen aufgelöst werden.';

/// Builds the seven lessons every number range offers, so the three groups
/// stay in step with each other.
List<LessonSpec> _rangeGroup(
  LessonGroup group,
  String suffix, {
  required bool nameTheTen,
}) {
  final ueber = nameTheTen ? 'Zehnerübergang' : 'Übergang';
  return [
    LessonSpec(
      id: 'add_${suffix}_plain',
      title: 'Plus ohne $ueber',
      description: nameTheTen ? _addPlain : _addPlainBig,
      group: group,
      op: ArithmeticOp.add,
      carry: CarryMode.none,
      form: TaskForm.result,
    ),
    LessonSpec(
      id: 'add_${suffix}_carry',
      title: 'Plus mit $ueber',
      description: nameTheTen ? _addCarry : _addCarryBig,
      group: group,
      op: ArithmeticOp.add,
      carry: CarryMode.required,
      form: TaskForm.result,
    ),
    LessonSpec(
      id: 'sub_${suffix}_plain',
      title: 'Minus ohne $ueber',
      description: nameTheTen ? _subPlain : _subPlainBig,
      group: group,
      op: ArithmeticOp.sub,
      carry: CarryMode.none,
      form: TaskForm.result,
    ),
    LessonSpec(
      id: 'sub_${suffix}_borrow',
      title: 'Minus mit $ueber',
      description: nameTheTen ? _subBorrow : _subBorrowBig,
      group: group,
      op: ArithmeticOp.sub,
      carry: CarryMode.required,
      form: TaskForm.result,
    ),
    LessonSpec(
      id: 'add_${suffix}_gap',
      title: 'Plus mit Platzhalter',
      description: _gap,
      group: group,
      op: ArithmeticOp.add,
      carry: CarryMode.any,
      form: TaskForm.gap,
    ),
    LessonSpec(
      id: 'sub_${suffix}_gap',
      title: 'Minus mit Platzhalter',
      description: _gap,
      group: group,
      op: ArithmeticOp.sub,
      carry: CarryMode.any,
      form: TaskForm.gap,
    ),
    LessonSpec(
      id: 'mix_$suffix',
      title: 'Plus und Minus gemischt',
      description: _mixed,
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
  title: 'Verliebte Zahlen',
  description: 'Zwei Zahlen sind verliebt, wenn sie zusammen genau 10 '
      'ergeben: 1 und 9, 2 und 8, 3 und 7. Gefragt wird in beide '
      'Richtungen - von 3 nach 7 genauso wie von 7 nach 3.',
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
    title: 'Plus bis 10',
    description: 'Zusammenzählen, ohne über die 10 hinauszugehen.',
    group: LessonGroup.upTo10,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.result,
  ),
  LessonSpec(
    id: 'sub_10',
    title: 'Minus bis 10',
    description: 'Wegnehmen im Zahlenraum bis 10.',
    group: LessonGroup.upTo10,
    op: ArithmeticOp.sub,
    carry: CarryMode.any,
    form: TaskForm.result,
  ),
  LessonSpec(
    id: 'add_10_gap',
    title: 'Plus mit Platzhalter',
    description: _gap,
    group: LessonGroup.upTo10,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.gap,
  ),
  LessonSpec(
    id: 'sub_10_gap',
    title: 'Minus mit Platzhalter',
    description: _gap,
    group: LessonGroup.upTo10,
    op: ArithmeticOp.sub,
    carry: CarryMode.any,
    form: TaskForm.gap,
  ),
  LessonSpec(
    id: 'mix_10',
    title: 'Plus und Minus gemischt',
    description: 'Plus und Minus wechseln sich zufällig ab.',
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
          title: '${n}er-Reihe',
          description: 'Alle Aufgaben der ${n}er-Reihe, in beide Richtungen: '
              '$n · 4 genauso wie 4 · $n.',
          group: LessonGroup.timesTables,
          op: ArithmeticOp.mul,
          carry: CarryMode.any,
          form: TaskForm.result,
          timesTable: n,
        ),
      const LessonSpec(
        id: 'times_all',
        title: 'Alle Reihen gemischt',
        description: 'Das ganze kleine Einmaleins, bunt durcheinander.',
        group: LessonGroup.timesTables,
        op: ArithmeticOp.mul,
        carry: CarryMode.any,
        form: TaskForm.result,
      ),
    ];

const _timesAndDivisionLessons = [
  LessonSpec(
    id: 'div_plain',
    title: 'Geteilt ohne Rest',
    description: 'Die Aufgabe geht glatt auf - jede ist die Umkehrung '
        'einer Einmaleins-Aufgabe.',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.div,
    carry: CarryMode.any,
    form: TaskForm.result,
  ),
  LessonSpec(
    id: 'div_remainder',
    title: 'Geteilt mit Rest',
    description: 'Es bleibt immer etwas übrig. Erst das Ergebnis eingeben, '
        'dann den Rest.',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.div,
    carry: CarryMode.any,
    form: TaskForm.remainder,
  ),
  LessonSpec(
    id: 'times_gap',
    title: 'Mal mit Platzhalter',
    description: 'Mit welcher Zahl muss man malnehmen, damit es stimmt?',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.mul,
    carry: CarryMode.any,
    form: TaskForm.gap,
  ),
  LessonSpec(
    id: 'div_gap',
    title: 'Geteilt mit Platzhalter',
    description: 'Durch welche Zahl muss man teilen, damit es stimmt?',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.div,
    carry: CarryMode.any,
    form: TaskForm.gap,
  ),
  LessonSpec(
    id: 'mul_tens',
    title: 'Mal mit Zehnerzahlen',
    description: 'Das Einmaleins mit einer Null dahinter: 3 · 4 = 12, '
        'also 30 · 4 = 120.',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.mul,
    carry: CarryMode.any,
    form: TaskForm.result,
    scale: FactorScale.tens,
  ),
  LessonSpec(
    id: 'mul_two_digit',
    title: 'Mal über das Einmaleins hinaus',
    description: 'Eine zweistellige Zahl malnehmen, zum Beispiel 14 · 6.',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.mul,
    carry: CarryMode.any,
    form: TaskForm.result,
    scale: FactorScale.twoDigit,
  ),
  LessonSpec(
    id: 'div_two_digit',
    title: 'Geteilt über das Einmaleins hinaus',
    description: 'Das Ergebnis ist größer als zehn, zum Beispiel 96 : 6.',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.div,
    carry: CarryMode.any,
    form: TaskForm.result,
    scale: FactorScale.twoDigit,
  ),
  LessonSpec(
    id: 'mul_div_mixed',
    title: 'Mal und Geteilt gemischt',
    description: 'Malnehmen und Teilen wechseln sich zufällig ab.',
    group: LessonGroup.timesAndDivision,
    op: ArithmeticOp.mulDiv,
    carry: CarryMode.any,
    form: TaskForm.result,
  ),
];

/// The gentlest group: counting, recognising dice patterns, comparing
/// amounts, the number line, and sums that stay within one hand.
///
/// None of it is timed or ranked - see [LessonSpec.scored].
const _firstStepsLessons = [
  LessonSpec(
    id: 'count_pictures',
    title: 'Wie viele? (Reihe)',
    description: 'Bilder zählen, eins bis fünf, ordentlich aufgereiht.',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.quantity,
    scored: false,
  ),
  LessonSpec(
    id: 'count_pictures_cloud',
    title: 'Wie viele? (Wolke)',
    description: 'Dieselben Bilder, aber durcheinander - man muss sich '
        'merken, was schon gezählt ist.',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.quantity,
    scored: false,
    arrangement: PictureArrangement.scattered,
  ),
  LessonSpec(
    id: 'count_dice',
    title: 'Wie viele Punkte?',
    description: 'Ein Würfel. Irgendwann sieht man die Zahl, ohne zu zählen.',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.dice,
    scored: false,
  ),
  LessonSpec(
    id: 'compare_more',
    title: 'Wo sind mehr? (Reihe)',
    description: 'Zwei Häufchen vergleichen und die größere Anzahl eingeben.',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.compare,
    scored: false,
    showCounts: true,
  ),
  LessonSpec(
    id: 'compare_more_cloud',
    title: 'Wo sind mehr? (Wolke)',
    description: 'Dasselbe, aber die Bilder liegen durcheinander.',
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
    title: 'Welche Zahl kommt danach?',
    description: 'Die Zahlenreihe vorwärts und rückwärts.',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.sequence,
    scored: false,
  ),
  LessonSpec(
    id: 'bees_add',
    title: 'Bienchen (Reihe)',
    description: 'Zwei Grüppchen Bienen zusammenzählen, zusammen nie mehr '
        'als zehn.',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.quantityAdd,
    scored: false,
    showCounts: true,
  ),
  LessonSpec(
    id: 'bees_add_cloud',
    title: 'Bienchen (Wolke)',
    description: 'Dieselbe Aufgabe, aber die Bienen schwirren durcheinander.',
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
    title: 'Zwei Würfel zusammenzählen',
    description: 'Beide Würfel zeigen bis zu fünf Punkte - wie viele sind '
        'es zusammen?',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.dice,
    scored: false,
    showCounts: true,
  ),
  LessonSpec(
    id: 'add_to_six',
    title: 'Plus bis 6',
    description: 'Zusammenzählen, nie über die Sechs hinaus.',
    group: LessonGroup.firstSteps,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.result,
    scored: false,
  ),
  LessonSpec(
    id: 'sub_to_six',
    title: 'Minus bis 6',
    description: 'Wegnehmen im Zahlenraum bis sechs.',
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
    title: 'Plus und Minus bis 6',
    description: 'Beides gemischt, nie über die Sechs hinaus.',
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
    title: 'Volle und halbe Stunden',
    description: 'Wie spät ist es? Der große Zeiger steht auf der 12 '
        'oder auf der 6.',
    group: LessonGroup.everyday,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.clock,
    minuteStep: 30,
  ),
  LessonSpec(
    id: 'clock_quarter',
    title: 'Viertelstunden',
    description: 'Viertel nach, halb, Viertel vor - der große Zeiger steht '
        'auf 12, 3, 6 oder 9.',
    group: LessonGroup.everyday,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.clock,
    minuteStep: 15,
  ),
  LessonSpec(
    id: 'clock_five',
    title: 'Uhrzeit auf fünf Minuten',
    description: 'Der große Zeiger steht auf einer der zwölf Zahlen.',
    group: LessonGroup.everyday,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.clock,
    minuteStep: 5,
  ),
  LessonSpec(
    id: 'money_add',
    title: 'Geld zusammenzählen',
    description: 'Zwei Beträge addieren. Erst die Euro eingeben, dann die '
        'Cent.',
    group: LessonGroup.everyday,
    op: ArithmeticOp.add,
    carry: CarryMode.any,
    form: TaskForm.money,
  ),
  LessonSpec(
    id: 'money_sub',
    title: 'Geld abziehen',
    description: 'Was bleibt übrig, oder was gibt es zurück?',
    group: LessonGroup.everyday,
    op: ArithmeticOp.sub,
    carry: CarryMode.any,
    form: TaskForm.money,
  ),
];

/// The full, fixed lesson catalog, ordered from the first steps up to 1000.
/// It opens with the pairs that make ten.
final List<LessonSpec> lessonCatalog = List.unmodifiable([
  ..._firstStepsLessons,
  _partnersOfTen,
  ..._upTo10Lessons,
  ..._rangeGroup(LessonGroup.upTo20, '20', nameTheTen: true),
  ..._rangeGroup(LessonGroup.upTo100, '100', nameTheTen: true),
  ..._rangeGroup(LessonGroup.upTo1000, '1000', nameTheTen: false),
  ..._timesTableLessons(),
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
