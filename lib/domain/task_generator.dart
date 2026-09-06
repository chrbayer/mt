/// Deterministic task generation for a lesson. No Flutter dependency.
library;

import 'dart:math';

import 'lesson.dart';
import 'task.dart';

/// Maximum share of tasks that may contain an "easy" operand - a multiple of
/// ten, or a 1. Neither is excluded: `40 + 30` and `7 + 1` are real tasks, and
/// adding or taking away one is a fact worth knowing. But in a small number
/// range they crowd out everything else if left unchecked, and a lesson turns
/// into a plus-one drill.
const double _maxEasyShare = 0.2;

bool _isEasy(LessonSpec lesson, Task task) {
  // The rule only fits the number ranges from 20 upwards, where "47 + 1" is a
  // freebie next to "47 + 38". Up to 10, 1 and 10 are two of eleven numbers.
  // In the 10er-Reihe every single task contains a ten, and a division by ten
  // is simply one of the divisors - capping those would gut the lessons.
  switch (lesson.group) {
    case LessonGroup.upTo10:
    case LessonGroup.timesTables:
    case LessonGroup.timesAndDivision:
    case LessonGroup.everyday:
    case LessonGroup.firstSteps:
      return false;
    case LessonGroup.upTo20:
    case LessonGroup.upTo100:
    case LessonGroup.upTo1000:
      return task.a % 10 == 0 ||
          task.b % 10 == 0 ||
          task.a == 1 ||
          task.b == 1;
  }
}

/// Attempts spent per task before constraints are relaxed. Relaxing keeps the
/// generator from looping forever when a lesson has few valid combinations.
const int _attemptsBeforeRelaxingEasyCap = 150;
const int _attemptsBeforeRelaxingRepeats = 250;
const int _attemptsBeforeRelaxingWindow = 350;
const int _maxAttempts = 400;

/// Share of a run made up of calculations the child struggled with before.
/// A quarter is enough to make a difference without turning practice into a
/// wall of the hardest things they know.
const double _reviewShare = 0.25;

/// How many tasks must pass before a calculation may come round again.
///
/// Up to 20 there simply are not 50 different tasks with a Zehnerübergang, so
/// demanding global uniqueness would be a promise the number range cannot
/// keep. Spacing repeats out is the honest rule, and it is the better one for
/// drilling anyway.
const int _repeatWindow = 8;

/// Generates [count] tasks for [lesson], reproducibly from [seed].
///
/// The same (lesson, count, seed) triple always yields the same list, which is
/// what makes a finished session replayable and comparable.
/// [review] holds calculations this child was slow or wrong on before. A
/// quarter of the run is drawn from it, scattered over the whole run rather
/// than bunched at the start.
List<Task> generateTasks({
  required LessonSpec lesson,
  required int count,
  required int seed,
  List<Task> review = const [],
}) {
  assert(count > 0);
  final random = Random(seed);

  if (lesson.fixedSum != null) {
    return _generateFixedSumTasks(lesson, count, random);
  }

  final operations = _operationSequence(lesson, count, random);

  // Pick the review tasks and their slots up front. Their keys go into `seen`
  // straight away so the ordinary sampling never draws the same calculation
  // just before one of them comes round.
  final reviewPool = [...review]..shuffle(random);
  final reviewCount =
      min(reviewPool.length, max(1, (count * _reviewShare).round()));
  final reviewTasks = reviewPool.take(reviewCount).toList();
  final reviewSlots = <int, Task>{};
  for (final task in reviewTasks) {
    var slot = random.nextInt(count);
    while (reviewSlots.containsKey(slot)) {
      slot = (slot + 1) % count;
    }
    reviewSlots[slot] = task;
  }

  final tasks = <Task>[];
  final seen = {for (final task in reviewTasks) task.key};
  final recent = <String>[];
  final easyBudget = max(1, (count * _maxEasyShare).floor());
  var easyUsed = 0;

  for (var i = 0; i < count; i++) {
    final review = reviewSlots[i];
    if (review != null) {
      recent.add(review.key);
      if (recent.length > _repeatWindow) recent.removeAt(0);
      tasks.add(review);
      continue;
    }

    final op = operations[i];
    Task? picked;

    for (var attempt = 0; attempt < _maxAttempts; attempt++) {
      final candidate = _sample(lesson, op, random);
      if (candidate == null) continue;

      // Never the same task twice in a row - whatever else gets relaxed.
      // With a pool of six faces the spacing rules have to give way, but an
      // immediate repeat reads as a glitch rather than as practice.
      if (tasks.isNotEmpty && candidate.key == tasks.last.key) continue;

      // Preferred: a calculation that has not come up at all. Once the range
      // is exhausted, at least keep it out of the last few tasks.
      if (attempt < _attemptsBeforeRelaxingRepeats &&
          seen.contains(candidate.key)) {
        continue;
      }
      if (attempt < _attemptsBeforeRelaxingWindow &&
          recent.contains(candidate.key)) {
        continue;
      }

      final easy = _isEasy(lesson, candidate);
      final capLifted = attempt >= _attemptsBeforeRelaxingEasyCap;
      if (easy && !capLifted && easyUsed >= easyBudget) continue;

      picked = candidate;
      if (easy) easyUsed++;
      break;
    }

    // Last resort: accept any valid task. Only reachable if even the relaxed
    // rules found nothing in 400 draws.
    picked ??= _sampleUntilValid(
      lesson,
      op,
      random,
      avoid: tasks.isEmpty ? null : tasks.last.key,
    );

    seen.add(picked.key);
    recent.add(picked.key);
    if (recent.length > _repeatWindow) recent.removeAt(0);
    tasks.add(picked);
  }

  return List.unmodifiable(tasks);
}

/// Drill for a lesson with a [LessonSpec.fixedSum]: the pool is just ten
/// pairs, so the tasks are shuffled blocks of the complete pool instead of
/// independent random draws. Every pair then comes up equally often, in a
/// different order each round, and never twice in a row.
///
/// The first operand runs 0..sum, so every pair is asked in both directions:
/// from 3 to 7 just as much as from 7 to 3, and 0 and 10 are included.
List<Task> _generateFixedSumTasks(LessonSpec lesson, int count, Random random) {
  final sum = lesson.fixedSum!;
  final pool = [
    for (var a = 0; a <= sum; a++)
      Task(a: a, b: sum - a, op: Operation.add, form: lesson.form),
  ];

  final tasks = <Task>[];
  while (tasks.length < count) {
    final block = [...pool]..shuffle(random);
    // Avoid a repeat across the seam between two blocks.
    if (tasks.isNotEmpty && block.first == tasks.last && block.length > 1) {
      final other = 1 + random.nextInt(block.length - 1);
      final first = block[0];
      block[0] = block[other];
      block[other] = first;
    }
    tasks.addAll(block);
  }

  return List.unmodifiable(tasks.sublist(0, count));
}

/// For a mixed lesson: a balanced, shuffled sequence of the two operations,
/// so a run never degenerates into ten additions in a row.
List<Operation> _operationSequence(
  LessonSpec lesson,
  int count,
  Random random,
) {
  final (first, second) = switch (lesson.op) {
    ArithmeticOp.add => (Operation.add, null),
    ArithmeticOp.sub => (Operation.sub, null),
    ArithmeticOp.mul => (Operation.mul, null),
    ArithmeticOp.div => (Operation.div, null),
    ArithmeticOp.mixed => (Operation.add, Operation.sub),
    ArithmeticOp.mulDiv => (Operation.mul, Operation.div),
  };
  if (second == null) return List.filled(count, first);

  final firstCount = count ~/ 2 + (count.isOdd && random.nextBool() ? 1 : 0);
  final sequence = <Operation>[
    ...List.filled(firstCount, first),
    ...List.filled(count - firstCount, second),
  ];
  sequence.shuffle(random);
  return sequence;
}

Task _sampleUntilValid(
  LessonSpec lesson,
  Operation op,
  Random random, {
  String? avoid,
}) {
  Task? fallback;
  for (var i = 0; i < 10000; i++) {
    final candidate = _sample(lesson, op, random);
    if (candidate == null) continue;
    if (candidate.key != avoid) return candidate;
    fallback ??= candidate;
  }
  // Only when the lesson has literally one possible task.
  if (fallback != null) return fallback;
  throw StateError('No valid task for lesson ${lesson.id}');
}

/// Draws one candidate for the given operation, or null when the draw missed
/// the lesson's constraints (rejection sampling).
Task? _sample(LessonSpec lesson, Operation op, Random random) {
  // Several forms are told apart by their form, not by their operation:
  // counting apples is not an addition at all.
  switch (lesson.form) {
    case TaskForm.clock:
      return _sampleClock(lesson, random);
    case TaskForm.money:
      return _sampleMoney(lesson, op, random);
    case TaskForm.quantity:
      // a is how many, b only picks the picture.
      return Task(
        a: _between(random, 1, 5),
        b: random.nextInt(countingPictures.length),
        op: Operation.add,
        form: TaskForm.quantity,
      );
    case TaskForm.dice:
      // Reading a single die uses the whole die, all six faces. Adding two
      // stays at five each, so the sum never leaves the first ten.
      final single = lesson.id == 'count_dice';
      return Task(
        a: _between(random, 1, single ? 6 : 5),
        b: single ? 0 : _between(random, 1, 5),
        op: Operation.add,
        form: TaskForm.dice,
      );
    case TaskForm.compare:
      final a = _between(random, 1, 5);
      final b = _between(random, 1, 5);
      // Equal heaps have no answer to "where are there more".
      if (a == b) return null;
      return Task(a: a, b: b, op: Operation.add, form: TaskForm.compare);
    case TaskForm.sequence:
      final backwards = random.nextBool();
      return Task(
        a: backwards ? _between(random, 4, 10) : _between(random, 1, 7),
        b: backwards ? 1 : 0,
        op: Operation.add,
        form: TaskForm.sequence,
      );
    case TaskForm.quantityAdd:
      // Two little heaps, together never more than ten.
      final left = _between(random, 1, 5);
      return Task(
        a: left,
        b: _between(random, 1, 10 - left),
        op: Operation.add,
        form: TaskForm.quantityAdd,
      );
    case TaskForm.result:
    case TaskForm.gap:
    case TaskForm.partner:
    case TaskForm.remainder:
      break;
  }

  return switch (op) {
    Operation.mul => _sampleProduct(lesson, random),
    Operation.div => _sampleQuotient(lesson, random),
    Operation.add || Operation.sub => _sampleSum(lesson, op, random),
  };
}

/// A time on the clock face. Hours run 1..12 as they are read aloud, minutes
/// in the steps this lesson practises.
Task _sampleClock(LessonSpec lesson, Random random) {
  final steps = 60 ~/ lesson.minuteStep;
  return Task(
    a: _between(random, 1, 12),
    b: random.nextInt(steps) * lesson.minuteStep,
    op: Operation.add,
    form: TaskForm.clock,
  );
}

/// Two amounts of money, held in cents. Both land on five cents, the way
/// prices and pocket money do.
Task? _sampleMoney(LessonSpec lesson, Operation op, Random random) {
  int amount(int maxCents) => _between(random, 1, maxCents ~/ 5) * 5;

  if (op == Operation.add) {
    final a = amount(1500);
    final b = amount(2000 - a);
    if (b < 5) return null;
    return Task(a: a, b: b, op: op, form: TaskForm.money);
  }

  final a = _between(random, 4, 400) * 5;
  final b = amount(a - 5);
  if (b < 5) return null;
  return Task(a: a, b: b, op: op, form: TaskForm.money);
}

/// A product from the small times table. When the lesson drills one row, that
/// factor is fixed and the other runs 1..10; both orders come up equally
/// often, because `3 · 7` and `7 · 3` are both worth recognising.
Task _sampleProduct(LessonSpec lesson, Random random) {
  final table = lesson.timesTable;
  final int a;
  final int b;

  if (table != null) {
    final other = _between(random, 1, 10);
    (a, b) = random.nextBool() ? (table, other) : (other, table);
  } else {
    final (big, small) = switch (lesson.scale) {
      FactorScale.table => (_between(random, 1, 10), _between(random, 1, 10)),
      // A whole ten: the same table fact with a zero appended.
      FactorScale.tens => (_between(random, 2, 9) * 10, _between(random, 2, 9)),
      FactorScale.twoDigit => (
          _between(random, 11, 25),
          _between(random, 2, 9)
        ),
    };
    (a, b) = random.nextBool() ? (big, small) : (small, big);
  }
  return Task(a: a, b: b, op: Operation.mul, form: lesson.form);
}

/// A division built backwards from its answer, so it always stays inside the
/// small times table. Lessons in [TaskForm.remainder] always leave something
/// over - that is what they are called after.
Task? _sampleQuotient(LessonSpec lesson, Random random) {
  final divisor = _between(random, 2, 10);
  final quotient = switch (lesson.scale) {
    FactorScale.table => _between(random, 1, 10),
    FactorScale.tens => _between(random, 2, 9) * 10,
    FactorScale.twoDigit => _between(random, 11, 25),
  };
  final remainder = lesson.form == TaskForm.remainder
      ? _between(random, 1, divisor - 1)
      : 0;

  final dividend = divisor * quotient + remainder;
  final limit = lesson.scale == FactorScale.table ? 100 : 999;
  if (dividend > limit) return null;
  return Task(a: dividend, b: divisor, op: Operation.div, form: lesson.form);
}

/// Draws a sum or difference and returns it only if it satisfies the lesson's
/// carry rule.
Task? _sampleSum(LessonSpec lesson, Operation op, Random random) {
  final int a;
  final int b;

  // Operands of 1 are allowed: "+1" and "-1" are real facts about neighbouring
  // numbers. How often they show up is capped by the easy-operand budget in
  // generateTasks, not by a rule against them here.
  //
  // Subtractions keep a minimum difference, because near-identical operands
  // like 74 - 73 read as a trick rather than as practice. Up to 20 that margin
  // stays small: 12 - 9 is a textbook Zehnerübergang. Equal operands are the
  // deliberate exception - "8 - 8 = 0" is a fact worth knowing, so it is drawn
  // now and then instead of being designed away.
  final zeroResult = op == Operation.sub && random.nextInt(12) == 0;

  switch ((lesson.group, op)) {
    case (LessonGroup.firstSteps, Operation.add):
      // Never past six, and never a task that is only about zero.
      a = _between(random, 1, 5);
      b = _between(random, 1, 6 - a);
    case (LessonGroup.firstSteps, Operation.sub):
      a = _between(random, 2, 6);
      b = _between(random, 1, a - 1);
    case (LessonGroup.upTo10, Operation.add):
      a = _between(random, 1, 9);
      final maxB = 10 - a;
      b = _between(random, 1, maxB);
    case (LessonGroup.upTo10, Operation.sub):
      a = _between(random, 3, 10);
      b = zeroResult ? a : _between(random, 1, a - 1);
    case (LessonGroup.upTo20, Operation.add):
      a = _between(random, 2, 18);
      final maxB = 20 - a;
      if (maxB < 1) return null;
      b = _between(random, 1, maxB);
      if (a + b < 5) return null;
    case (LessonGroup.upTo20, Operation.sub):
      a = _between(random, 6, 20);
      final maxB = a - 2;
      if (maxB < 1) return null;
      b = zeroResult ? a : _between(random, 1, maxB);
    case (LessonGroup.upTo100, Operation.add):
      a = _between(random, 10, 89);
      final maxB = 100 - a;
      if (maxB < 1) return null;
      b = _between(random, 1, maxB);
    case (LessonGroup.upTo100, Operation.sub):
      a = _between(random, 21, 100);
      final maxB = a - 5;
      if (maxB < 1) return null;
      b = zeroResult ? a : _between(random, 1, maxB);
    case (LessonGroup.upTo1000, Operation.add):
      a = _between(random, 100, 979);
      final maxB = 999 - a;
      if (maxB < 1) return null;
      b = _between(random, 1, maxB);
    case (LessonGroup.upTo1000, Operation.sub):
      a = _between(random, 110, 999);
      final maxB = a - 10;
      if (maxB < 1) return null;
      b = zeroResult ? a : _between(random, 1, maxB);
    case (LessonGroup.timesTables, _):
    case (LessonGroup.timesAndDivision, _):
    case (LessonGroup.everyday, _):
      // Unreachable: those groups only ever ask for products and quotients,
      // and _sample dispatches those elsewhere.
      return null;
    case (_, Operation.mul):
    case (_, Operation.div):
      return null;
  }

  // Places that count as a "Übergang": only the ones digit up to 100, ones and
  // tens up to 1000. A carry out of the tens digit up to 100 would mean
  // crossing 100, which the ranges above already exclude. Up to 10 nothing can
  // cross at all, which is why those lessons all use CarryMode.any.
  final places = lesson.group == LessonGroup.upTo1000 ? 2 : 1;
  final crosses = op == Operation.add
      ? _hasCarry(a, b, places)
      : _hasBorrow(a, b, places);

  switch (lesson.carry) {
    case CarryMode.none:
      if (crosses) return null;
    case CarryMode.required:
      if (!crosses) return null;
    case CarryMode.any:
      break;
  }

  // The ranges above draw the first operand from the wide end and the second
  // from what is left, so without this every single addition would read
  // "68 + 13" and never "13 + 68". Both orders belong in practice.
  if (op == Operation.add && random.nextBool()) {
    return Task(a: b, b: a, op: op, form: lesson.form);
  }
  return Task(a: a, b: b, op: op, form: lesson.form);
}

/// True if adding [a] and [b] carries out of any of the lowest [places] digits.
bool _hasCarry(int a, int b, int places) {
  var divisor = 1;
  for (var i = 0; i < places; i++) {
    if ((a ~/ divisor) % 10 + (b ~/ divisor) % 10 >= 10) return true;
    divisor *= 10;
  }
  return false;
}

/// True if subtracting [b] from [a] needs to borrow at any of the lowest
/// [places] digits.
bool _hasBorrow(int a, int b, int places) {
  var divisor = 1;
  for (var i = 0; i < places; i++) {
    if ((a ~/ divisor) % 10 < (b ~/ divisor) % 10) return true;
    divisor *= 10;
  }
  return false;
}

int _between(Random random, int min, int max) =>
    min + random.nextInt(max - min + 1);
