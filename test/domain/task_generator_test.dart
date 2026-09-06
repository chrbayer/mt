import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/domain/task_generator.dart';

/// Seeds used to exercise every lesson many times over.
const seeds = [0, 1, 2, 7, 13, 42, 99, 256, 1234, 31337, 987654];

bool onesCarry(Task t) => t.a % 10 + t.b % 10 >= 10;
bool tensCarry(Task t) => (t.a ~/ 10) % 10 + (t.b ~/ 10) % 10 >= 10;
bool onesBorrow(Task t) => t.a % 10 < t.b % 10;
bool tensBorrow(Task t) => (t.a ~/ 10) % 10 < (t.b ~/ 10) % 10;

/// How many different calculations a lesson can actually produce.
///
/// Some pools are tiny by nature, and no amount of shuffling can space out
/// repeats in a run longer than the pool itself.
int poolSize(LessonSpec lesson) =>
    generateTasks(lesson: lesson, count: 80, seed: 12345)
        .map((t) => t.key)
        .toSet()
        .length;

void main() {
  group('generateTasks invariants', () {
    for (final lesson in lessonCatalog) {
      test('${lesson.id} respects range, operands and result', () {
        for (final seed in seeds) {
          for (final count in selectableTaskCounts) {
            final tasks = generateTasks(
              lesson: lesson,
              count: count,
              seed: seed,
            );
            expect(tasks, hasLength(count));

            final limit = switch (lesson.group) {
              // Counting pictures, dice pips and the number line all stay
              // inside one hand's worth - except the sequence, which walks
              // up to ten.
              LessonGroup.firstSteps => 10,
              LessonGroup.upTo10 => 10,
              LessonGroup.upTo20 => 20,
              LessonGroup.upTo100 => 100,
              LessonGroup.upTo1000 => 999,
              // The small times table tops out at 10 x 10, and every division
              // is built backwards from it.
              LessonGroup.timesTables => 100,
              // Every dividend is a product from the small table.
              LessonGroup.reverseTimesTables => 100,
              // Beyond the table: 25 x 9 and 96 : 6 both live here.
              LessonGroup.timesAndDivision => 999,
              // Money is held in cents, so the numbers are the biggest of all.
              LessonGroup.everyday => 2000,
            };
            // A pair lesson asks in both directions and a clock reads minute
            // zero, so those allow 0. Everywhere else 1 is the smallest.
            final smallest = lesson.fixedSum != null ||
                    lesson.form == TaskForm.clock ||
                    lesson.form == TaskForm.quantity ||
                    lesson.form == TaskForm.dice ||
                    lesson.form == TaskForm.sequence ||
                    // An amount to lay out has no second operand at all.
                    lesson.form == TaskForm.moneyCompose
                ? 0
                : 1;
            for (final task in tasks) {
              final where = '${lesson.id}/seed $seed: $task';
              expect(task.a, inInclusiveRange(smallest, limit), reason: where);
              expect(task.b, inInclusiveRange(smallest, limit), reason: where);
              expect(task.result, inInclusiveRange(0, limit), reason: where);
              expect(task.expected, greaterThanOrEqualTo(0), reason: where);
              expect(task.form, lesson.form, reason: where);
            }
          }
        }
      });

      test('${lesson.id} respects its carry rule', () {
        if (lesson.carry == CarryMode.any) return;
        final upTo1000 = lesson.group == LessonGroup.upTo1000;
        for (final seed in seeds) {
          final tasks = generateTasks(lesson: lesson, count: 50, seed: seed);
          for (final task in tasks) {
            final crosses = task.op == Operation.add
                ? onesCarry(task) || (upTo1000 && tensCarry(task))
                : onesBorrow(task) || (upTo1000 && tensBorrow(task));
            expect(
              crosses,
              lesson.carry == CarryMode.required,
              reason: '${lesson.id}/seed $seed: $task',
            );
          }
        }
      });

      test('${lesson.id} does not repeat a calculation in a short run', () {
        if (poolSize(lesson) < 12) return;
        for (final seed in seeds) {
          final tasks = generateTasks(lesson: lesson, count: 10, seed: seed);
          final keys = tasks.map((t) => t.key).toSet();
          expect(keys, hasLength(tasks.length), reason: '${lesson.id}/$seed');
        }
      });

      test('${lesson.id} spaces out repeats in a long run', () {
        // Pair lessons cycle through their whole pool by design, and some
        // pools are simply tiny - one die has five faces. Both are checked
        // separately below.
        if (lesson.fixedSum != null) return;
        if (poolSize(lesson) < 12) return;
        // Up to 20 there are fewer than 50 valid calculations for some
        // lessons, so a 50-task drill must repeat - just never close together.
        for (final seed in seeds) {
          final tasks = generateTasks(lesson: lesson, count: 50, seed: seed);
          for (var i = 0; i < tasks.length; i++) {
            final window = tasks
                .sublist(i, (i + 9).clamp(0, tasks.length))
                .map((t) => t.key)
                .toList();
            expect(
              window.toSet(),
              hasLength(window.length),
              reason: '${lesson.id}/seed $seed at $i: $window',
            );
          }
        }
      });

      test('${lesson.id} is deterministic for a seed', () {
        final first = generateTasks(lesson: lesson, count: 30, seed: 4711);
        final second = generateTasks(lesson: lesson, count: 30, seed: 4711);
        final other = generateTasks(lesson: lesson, count: 30, seed: 4712);
        expect(first, second);
        expect(first, isNot(other));
      });

      test('${lesson.id} keeps easy operands a garnish', () {
        // A pair lesson drills its complete pool, which contains 0, 1 and 10
        // by design - and up to 10 those are ordinary numbers rather than
        // shortcuts. The budget applies from 20 upwards.
        if (lesson.fixedSum != null) return;
        // Mirrors the production rule: the cap only fits the number ranges
        // from 20 upwards. In the 10er-Reihe every task contains a ten.
        if (lesson.group == LessonGroup.upTo10) return;
        if (lesson.group == LessonGroup.timesTables) return;
        if (lesson.group == LessonGroup.reverseTimesTables) return;
        if (lesson.group == LessonGroup.timesAndDivision) return;
        // Clock hands land on zero minutes and money on round euro amounts;
        // neither is a shortcut the way "47 + 1" is.
        if (lesson.group == LessonGroup.everyday) return;
        // The first steps deal in ones and fives by their very nature.
        if (lesson.group == LessonGroup.firstSteps) return;
        // Round tens and the operand 1 are allowed, but a fifth of the run at
        // most - otherwise a small number range turns into a plus-one drill.
        for (final seed in seeds) {
          final tasks = generateTasks(lesson: lesson, count: 20, seed: seed);
          final easy = tasks
              .where((t) =>
                  t.a % 10 == 0 || t.b % 10 == 0 || t.a == 1 || t.b == 1)
              .length;
          expect(easy, lessThanOrEqualTo(4), reason: '${lesson.id}/$seed');
        }
      });
    }

    test('the correct operation is used per lesson', () {
      for (final lesson in lessonCatalog) {
        final tasks = generateTasks(lesson: lesson, count: 40, seed: 5);
        final ops = tasks.map((t) => t.op).toSet();
        switch (lesson.op) {
          case ArithmeticOp.add:
            expect(ops, {Operation.add}, reason: lesson.id);
          case ArithmeticOp.sub:
            expect(ops, {Operation.sub}, reason: lesson.id);
          case ArithmeticOp.mul:
            expect(ops, {Operation.mul}, reason: lesson.id);
          case ArithmeticOp.div:
            expect(ops, {Operation.div}, reason: lesson.id);
          case ArithmeticOp.mixed:
            expect(ops, {Operation.add, Operation.sub}, reason: lesson.id);
          case ArithmeticOp.mulDiv:
            expect(ops, {Operation.mul, Operation.div}, reason: lesson.id);
        }
      }
    });

    test('mixed lessons stay roughly balanced', () {
      for (final lesson
          in lessonCatalog.where((l) => l.op == ArithmeticOp.mixed)) {
        for (final seed in seeds) {
          final tasks = generateTasks(lesson: lesson, count: 50, seed: seed);
          final adds = tasks.where((t) => t.op == Operation.add).length;
          expect(adds, inInclusiveRange(24, 26), reason: '${lesson.id}/$seed');
        }
      }
    });

    test('verliebte Zahlen asks every pair in both directions', () {
      final lesson = lessonById('partners_of_ten');
      final tasks = generateTasks(lesson: lesson, count: 11, seed: 1);

      // 0 with 10, 1 with 9, ... 10 with 0 - eleven prompts covering every
      // pair from both sides.
      expect(tasks.map((t) => t.a).toSet(), {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10});
      for (final task in tasks) {
        expect(task.a + task.b, 10, reason: '$task');
        expect(task.expected, task.b, reason: '$task');
        expect(task.form, TaskForm.partner);
      }
    });

    test('verliebte Zahlen is a drill, not a lottery', () {
      for (final seed in seeds) {
        final tasks = generateTasks(
          lesson: lessonById('partners_of_ten'),
          count: 44,
          seed: seed,
        );
        // Never the same prompt twice in a row.
        for (var i = 1; i < tasks.length; i++) {
          expect(tasks[i], isNot(tasks[i - 1]), reason: 'seed $seed at $i');
        }
        // Four full rounds, so every pair comes up exactly four times.
        final counts = <int, int>{};
        for (final task in tasks) {
          counts[task.a] = (counts[task.a] ?? 0) + 1;
        }
        expect(counts.values.toSet(), {4}, reason: 'seed $seed: $counts');
      }
    });

    test('verliebte Zahlen reads as a heart, not as a sum', () {
      final task = generateTasks(
        lesson: lessonById('partners_of_ten'),
        count: 11,
        seed: 1,
      ).firstWhere((t) => t.a == 3);
      expect(task.question, 'Welche Zahl ist mit 3 verliebt?');
      expect(task.render('7'), '3 \u2665 7');
      expect(task.suffix, isEmpty);
    });

    test('a row of the times table drills exactly that row, both ways', () {
      for (final lesson in lessonsInGroup(LessonGroup.timesTables)
          .where((l) => l.timesTable != null)) {
        final table = lesson.timesTable!;
        var tableFirst = 0;
        final others = <int>{};
        for (var seed = 0; seed < 40; seed++) {
          for (final task
              in generateTasks(lesson: lesson, count: 20, seed: seed)) {
            expect(task.op, Operation.mul, reason: '$task');
            expect(
              task.a == table || task.b == table,
              isTrue,
              reason: '${lesson.id}: $task',
            );
            expect(task.result, task.a * task.b, reason: '$task');
            if (task.a == table) tableFirst++;
            others.add(task.a == table ? task.b : task.a);
          }
        }
        // Every partner from 1 to 10 comes up, and neither order dominates.
        expect(others, containsAll(List.generate(10, (i) => i + 1)));
        expect(tableFirst / 800, closeTo(0.5, 0.15), reason: lesson.id);
      }
    });

    test('the bigger products stay whole and reachable', () {
      for (final id in ['mul_tens', 'mul_two_digit']) {
        final lesson = lessonById(id);
        var firstIsBigger = 0;
        var total = 0;
        for (var seed = 0; seed < 40; seed++) {
          for (final task
              in generateTasks(lesson: lesson, count: 20, seed: seed)) {
            total++;
            if (task.a > task.b) firstIsBigger++;
            expect(task.op, Operation.mul);
            expect(task.result, task.a * task.b);
            expect(task.result, lessThanOrEqualTo(810), reason: '$task');
            final big = max(task.a, task.b);
            final small = min(task.a, task.b);
            expect(small, inInclusiveRange(2, 9), reason: '$task');
            if (id == 'mul_tens') {
              expect(big % 10, 0, reason: '$task');
            } else {
              expect(big, inInclusiveRange(11, 25), reason: '$task');
            }
          }
        }
        // Both orders again, so it never reads as one fixed shape.
        expect(firstIsBigger / total, closeTo(0.5, 0.1), reason: id);
      }
    });

    test('dividing beyond the table gives a two-digit answer', () {
      final lesson = lessonById('div_two_digit');
      for (var seed = 0; seed < 40; seed++) {
        for (final task
            in generateTasks(lesson: lesson, count: 20, seed: seed)) {
          expect(task.remainder, 0, reason: '$task');
          expect(task.b, inInclusiveRange(2, 10), reason: '$task');
          expect(task.result, inInclusiveRange(11, 25), reason: '$task');
          expect(task.a, task.b * task.result, reason: '$task');
        }
      }
    });

    test('divisions are built backwards from the times table', () {
      for (final id in ['div_plain', 'div_gap', 'mul_div_mixed']) {
        for (var seed = 0; seed < 40; seed++) {
          for (final task
              in generateTasks(lesson: lessonById(id), count: 20, seed: seed)) {
            if (task.op != Operation.div) continue;
            expect(task.remainder, 0, reason: '$task');
            expect(task.b, inInclusiveRange(2, 10), reason: '$task');
            expect(task.result, inInclusiveRange(1, 10), reason: '$task');
            expect(task.a, task.b * task.result, reason: '$task');
          }
        }
      }
    });

    test('geteilt mit Rest always leaves something over', () {
      final lesson = lessonById('div_remainder');
      for (var seed = 0; seed < 60; seed++) {
        for (final task
            in generateTasks(lesson: lesson, count: 20, seed: seed)) {
          expect(task.form, TaskForm.remainder);
          expect(task.remainder, greaterThanOrEqualTo(1), reason: '$task');
          expect(task.remainder, lessThan(task.b), reason: '$task');
          expect(task.a, inInclusiveRange(3, 100), reason: '$task');
          // Both numbers are asked for, and they reconstruct the dividend.
          expect(task.expected, task.a ~/ task.b);
          expect(task.expectedSecond, task.a % task.b);
          expect(task.b * task.expected + task.expectedSecond!, task.a);
        }
      }
    });

    test('multiplication and division read the way school writes them', () {
      const product =
          Task(a: 3, b: 7, op: Operation.mul, form: TaskForm.result);
      expect(product.render('21'), '3 · 7 = 21');
      expect(product.expectedSecond, isNull);

      const quotient =
          Task(a: 17, b: 5, op: Operation.div, form: TaskForm.remainder);
      expect(quotient.render('3', '2'), '17 : 5 = 3 Rest 2');
      expect(quotient.expected, 3);
      expect(quotient.expectedSecond, 2);

      const gap = Task(a: 24, b: 4, op: Operation.div, form: TaskForm.gap);
      expect(gap.render('4'), '24 : 4 = 6');
      expect(gap.expected, 4);
    });

    test('commutative pairs count as one calculation', () {
      const a = Task(a: 3, b: 7, op: Operation.mul, form: TaskForm.result);
      const b = Task(a: 7, b: 3, op: Operation.mul, form: TaskForm.result);
      expect(a.key, b.key);

      // Division is not commutative, and neither is the gap form.
      const c = Task(a: 21, b: 3, op: Operation.div, form: TaskForm.result);
      const d = Task(a: 3, b: 21, op: Operation.div, form: TaskForm.result);
      expect(c.key, isNot(d.key));
    });

    group('review of difficult tasks', () {
      const hard = [
        Task(a: 47, b: 38, op: Operation.add, form: TaskForm.result),
        Task(a: 59, b: 26, op: Operation.add, form: TaskForm.result),
        Task(a: 68, b: 17, op: Operation.add, form: TaskForm.result),
      ];

      test('about a quarter of a run comes from the review pool', () {
        for (final seed in seeds) {
          final tasks = generateTasks(
            lesson: lessonById('add_100_carry'),
            count: 20,
            seed: seed,
            review: hard,
          );
          final reviewed = tasks.where(hard.contains).length;
          // Three available, five wanted - so all three, each exactly once.
          expect(reviewed, 3, reason: 'seed $seed');
          for (final task in hard) {
            expect(tasks.where((t) => t == task), hasLength(1));
          }
        }
      });

      test('review tasks are scattered, not bunched at the start', () {
        final positions = <int>{};
        for (var seed = 0; seed < 40; seed++) {
          final tasks = generateTasks(
            lesson: lessonById('add_100_carry'),
            count: 20,
            seed: seed,
            review: hard,
          );
          for (var i = 0; i < tasks.length; i++) {
            if (hard.contains(tasks[i])) positions.add(i);
          }
        }
        expect(positions.length, greaterThan(10));
      });

      test('a review task is never doubled by the ordinary sampling', () {
        for (final seed in seeds) {
          final tasks = generateTasks(
            lesson: lessonById('add_100_carry'),
            count: 30,
            seed: seed,
            review: hard,
          );
          for (final task in hard) {
            expect(
              tasks.where((t) => t.key == task.key),
              hasLength(1),
              reason: 'seed $seed: $task',
            );
          }
        }
      });

      test('without a pool nothing changes', () {
        for (final seed in seeds) {
          expect(
            generateTasks(
                lesson: lessonById('add_100_carry'), count: 20, seed: seed),
            generateTasks(
              lesson: lessonById('add_100_carry'),
              count: 20,
              seed: seed,
              review: const [],
            ),
          );
        }
      });

      test('a big pool still leaves most of the run fresh', () {
        final many = [
          for (var a = 20; a < 60; a++)
            Task(a: a, b: 38, op: Operation.add, form: TaskForm.result),
        ];
        final tasks = generateTasks(
          lesson: lessonById('add_100_carry'),
          count: 20,
          seed: 3,
          review: many,
        );
        expect(tasks.where(many.contains).length, 5);
      });
    });

    test('subtraction may come out at zero, but not at a near miss', () {
      // "8 - 8 = 0" is a fact worth drilling; "74 - 73" is just fiddly.
      final results = <int>[];
      for (var seed = 0; seed < 60; seed++) {
        results.addAll(
          generateTasks(
            lesson: lessonById('sub_100_plain'),
            count: 50,
            seed: seed,
          ).map((t) => t.result),
        );
      }
      expect(results, contains(0));
      expect(results.where((r) => r >= 1 && r < 5), isEmpty);
    });

    group('everyday maths', () {
      test('a clock only ever shows a readable time', () {
        for (final lesson in lessonsInGroup(LessonGroup.everyday)
            .where((l) => l.form == TaskForm.clock)) {
          for (var seed = 0; seed < 30; seed++) {
            for (final task
                in generateTasks(lesson: lesson, count: 20, seed: seed)) {
              // Hours as they are spoken: 1 to 12, never 0. A 24-hour lesson
              // counts on past noon, and starts at six so that every hour it
              // shows is one a child has a name for.
              expect(
                task.a,
                lesson.clock24
                    ? inInclusiveRange(6, 23)
                    : inInclusiveRange(1, 12),
                reason: '$task',
              );
              expect(task.b, inInclusiveRange(0, 59), reason: '$task');
              expect(task.b % lesson.minuteStep, 0, reason: '$task');
              expect(task.expected, task.a);
              expect(task.expectedSecond, task.b);
              expect(task.question, 'Wie spät ist es?');
            }
          }
        }
      });

      test('the clock lessons get finer, step by step', () {
        expect(lessonById('clock_half').minuteStep, 30);
        expect(lessonById('clock_quarter').minuteStep, 15);
        expect(lessonById('clock_five').minuteStep, 5);
        // Half hours are a subset of quarters, quarters of five-minute steps.
        for (final lesson in ['clock_half', 'clock_quarter']) {
          final minutes = generateTasks(
            lesson: lessonById(lesson),
            count: 40,
            seed: 1,
          ).map((t) => t.b).toSet();
          expect(minutes.every((m) => m % 5 == 0), isTrue);
        }
      });

      test('money is asked in euro and cent, and always adds up', () {
        for (final id in ['money_add', 'money_sub']) {
          final lesson = lessonById(id);
          for (var seed = 0; seed < 30; seed++) {
            for (final task
                in generateTasks(lesson: lesson, count: 20, seed: seed)) {
              expect(task.result, greaterThanOrEqualTo(0), reason: '$task');
              expect(task.result, lessThanOrEqualTo(2000), reason: '$task');
              // Both halves together are the amount.
              expect(
                task.expected * 100 + task.expectedSecond!,
                task.result,
                reason: '$task',
              );
              expect(task.expectedSecond, inInclusiveRange(0, 99));
              // Prices land on five cents, not on stray single cents.
              expect(task.a % 5, 0, reason: '$task');
              expect(task.b % 5, 0, reason: '$task');
            }
          }
        }
      });

      test('the spoken hour is the one that is coming, not the one gone by',
          () {
        // The whole point of the lesson: at half past, German names the next
        // hour. Getting that wrong is the classic mistake.
        Task at(int hour, int minute) =>
            Task(a: hour, b: minute, op: Operation.add, form: TaskForm.clockPhrase);
        expect(at(2, 15).spokenTime, 'viertel nach 2');
        expect(at(2, 20).spokenTime, '20 nach 2');
        expect(at(2, 25).spokenTime, '5 vor halb 3');
        expect(at(2, 30).spokenTime, 'halb 3');
        expect(at(2, 35).spokenTime, '5 nach halb 3');
        expect(at(2, 45).spokenTime, 'viertel vor 3');
        expect(at(2, 55).spokenTime, '5 vor 3');
        // After twelve it starts over at one, not at thirteen.
        expect(at(12, 30).spokenTime, 'halb 1');
        expect(at(12, 45).spokenTime, 'viertel vor 1');
        expect(at(12, 15).spokenTime, 'viertel nach 12');
      });

      test('every spoken time asks for a phrase and the hour it names', () {
        final lesson = lessonById('clock_words');
        for (var seed = 0; seed < 30; seed++) {
          for (final task
              in generateTasks(lesson: lesson, count: 20, seed: seed)) {
            // The full hour has no key on the pad, so it must never come up.
            expect(task.b, inInclusiveRange(5, 55), reason: '$task');
            expect(task.b % 5, 0, reason: '$task');
            expect(task.expected, inInclusiveRange(0, clockPhrases.length - 1),
                reason: '$task');
            // The two answers together are exactly what is said out loud.
            expect(
              task.spokenTime,
              '${clockPhrases[task.expected]} ${task.expectedSecond}',
              reason: '$task',
            );
            expect(task.expectedSecond, inInclusiveRange(1, 12),
                reason: '$task');
            expect(task.question, 'Wie sagt man das?');
          }
        }
      });

      test('a 24-hour clock says which part of the day it is', () {
        final lesson = lessonById('clock_24');
        expect(lesson.clock24, isTrue);
        for (var seed = 0; seed < 30; seed++) {
          for (final task
              in generateTasks(lesson: lesson, count: 20, seed: seed)) {
            expect(task.a, inInclusiveRange(6, 23), reason: '$task');
            expect(task.expected, task.a, reason: '$task');
            expect(task.dayPart, isNotEmpty, reason: '$task');
          }
        }
        expect(dayPartOf(9), 'vormittags');
        expect(dayPartOf(12), 'mittags');
        expect(dayPartOf(13), 'nachmittags');
        expect(dayPartOf(17), 'nachmittags');
        expect(dayPartOf(18), 'abends');
        expect(dayPartOf(23), 'abends');
      });

      test('an amount to lay out can always be laid from the pieces', () {
        final lesson = lessonById('money_compose');
        for (var seed = 0; seed < 30; seed++) {
          for (final task
              in generateTasks(lesson: lesson, count: 20, seed: seed)) {
            expect(task.expected, task.a, reason: '$task');
            expect(task.expectedSecond, isNull, reason: '$task');
            expect(task.a % 5, 0, reason: '$task');
            expect(task.a, greaterThanOrEqualTo(10), reason: '$task');
            // Greedy from the largest piece down: if that clears the amount,
            // it can be laid at all.
            var rest = task.a;
            for (final piece in moneyPieces.reversed) {
              rest %= piece;
            }
            expect(rest, 0, reason: '$task');
          }
        }
      });

      test('change is given on a round amount that really covers the price',
          () {
        final lesson = lessonById('money_change');
        for (var seed = 0; seed < 30; seed++) {
          for (final task
              in generateTasks(lesson: lesson, count: 20, seed: seed)) {
            // a is what is handed over, b what it costs.
            expect(const [100, 200, 500, 1000, 2000], contains(task.a),
                reason: '$task');
            expect(task.b, lessThan(task.a), reason: '$task');
            expect(task.b % 5, 0, reason: '$task');
            expect(task.result, greaterThanOrEqualTo(10), reason: '$task');
            expect(task.expected * 100 + task.expectedSecond!, task.result,
                reason: '$task');
            expect(task.question, contains('zurück'), reason: '$task');
          }
        }
      });

      test('a coin is written the way it is stamped', () {
        expect(formatPiece(5), '5 ct');
        expect(formatPiece(50), '50 ct');
        expect(formatPiece(100), '1 €');
        expect(formatPiece(2000), '20 €');
      });

      test('money is written the way a price tag is', () {
        const task =
            Task(a: 350, b: 120, op: Operation.add, form: TaskForm.money);
        expect(task.prefix, '3,50 € + 1,20 € =');
        expect(task.expected, 4);
        expect(task.expectedSecond, 70);
        expect(task.secondLabel, '€');
        expect(task.secondUnit, 'ct');
        expect(formatEuro(5), '0,05 €');
        expect(formatEuro(2000), '20,00 €');
      });

      test('a clock task reads as a time, not as a sum', () {
        const task =
            Task(a: 9, b: 45, op: Operation.add, form: TaskForm.clock);
        expect(task.toString(), '9:45 Uhr');
        expect(task.prefix, isEmpty);
        expect(task.secondLabel, 'Uhr');
      });
    });

    test('a tiny pool still comes round evenly and never twice in a row', () {
      // One die: six faces, and a twenty-task run has to reuse them.
      final lesson = lessonById('count_dice');
      for (var seed = 0; seed < 30; seed++) {
        final tasks = generateTasks(lesson: lesson, count: 20, seed: seed);
        expect(tasks.map((t) => t.a).toSet(), {1, 2, 3, 4, 5, 6});
        for (var i = 1; i < tasks.length; i++) {
          expect(tasks[i], isNot(tasks[i - 1]), reason: 'seed $seed at $i');
        }
      }
    });

    group('first steps', () {
      test('counting tasks stay within one hand', () {
        for (final lesson in lessonsInGroup(LessonGroup.firstSteps)) {
          for (var seed = 0; seed < 30; seed++) {
            for (final task
                in generateTasks(lesson: lesson, count: 20, seed: seed)) {
              expect(task.expected, inInclusiveRange(0, 10), reason: '$task');
            }
          }
        }
      });

      test('none of them is timed or ranked', () {
        for (final lesson in lessonsInGroup(LessonGroup.firstSteps)) {
          expect(lesson.scored, isFalse, reason: lesson.id);
        }
        // And every other lesson is.
        for (final lesson in lessonCatalog
            .where((l) => l.group != LessonGroup.firstSteps)) {
          expect(lesson.scored, isTrue, reason: lesson.id);
        }
        expect(unscoredLessonIds, hasLength(12));
      });

      test('counting asks for the number of pictures', () {
        final lesson = lessonById('count_pictures');
        for (var seed = 0; seed < 20; seed++) {
          for (final task
              in generateTasks(lesson: lesson, count: 20, seed: seed)) {
            expect(task.a, inInclusiveRange(1, 5));
            expect(task.expected, task.a);
            expect(task.question, 'Wie viele?');
            expect(countingPictures, contains(task.picture));
            // The rendering is the pictures themselves, one per unit.
            expect(task.toString(), task.picture * task.a);
          }
        }
      });

      test('a single die shows all six faces, a pair stays at five', () {
        // Reading uses the whole die; adding two keeps the sum inside ten.
        for (final task in generateTasks(
            lesson: lessonById('dice_add'), count: 40, seed: 4)) {
          expect(task.a, inInclusiveRange(1, 5));
          expect(task.b, inInclusiveRange(1, 5));
          expect(task.expected, task.a + task.b);
          expect(task.expected, lessThanOrEqualTo(10));
          expect(task.question, 'Wie viele Punkte sind es zusammen?');
        }

        final faces = <int>{};
        for (var seed = 0; seed < 20; seed++) {
          for (final task in generateTasks(
              lesson: lessonById('count_dice'), count: 20, seed: seed)) {
            expect(task.b, 0);
            expect(task.expected, task.a);
            expect(task.question, 'Wie viele Punkte?');
            faces.add(task.a);
          }
        }
        expect(faces, {1, 2, 3, 4, 5, 6});
      });

      test('a task never comes twice in a row, however small the pool', () {
        // Six faces in a twenty-task run must repeat - but not back to back.
        for (final lesson in lessonCatalog) {
          for (var seed = 0; seed < 8; seed++) {
            final tasks = generateTasks(lesson: lesson, count: 30, seed: seed);
            for (var i = 1; i < tasks.length; i++) {
              expect(
                tasks[i].key,
                isNot(tasks[i - 1].key),
                reason: '${lesson.id}/seed $seed at $i',
              );
            }
          }
        }
      });

      test('comparing never shows two equal heaps', () {
        final lesson = lessonById('compare_more');
        for (var seed = 0; seed < 30; seed++) {
          for (final task
              in generateTasks(lesson: lesson, count: 20, seed: seed)) {
            expect(task.a, isNot(task.b), reason: '$task');
            expect(task.expected, task.a > task.b ? task.a : task.b);
          }
        }
      });

      test('the number line runs both ways', () {
        final lesson = lessonById('count_next');
        final directions = <int>{};
        for (var seed = 0; seed < 30; seed++) {
          for (final task
              in generateTasks(lesson: lesson, count: 20, seed: seed)) {
            directions.add(task.b);
            expect(task.sequenceNumbers, hasLength(3));
            if (task.b == 0) {
              expect(task.sequenceNumbers, [task.a, task.a + 1, task.a + 2]);
              expect(task.expected, task.a + 3);
            } else {
              expect(task.sequenceNumbers, [task.a, task.a - 1, task.a - 2]);
              expect(task.expected, task.a - 3);
            }
            expect(task.expected, greaterThanOrEqualTo(1));
          }
        }
        expect(directions, {0, 1});
      });

      test('calculating stops at six, in all three flavours', () {
        for (final id in ['add_to_six', 'sub_to_six', 'calc_to_six']) {
          final lesson = lessonById(id);
          final ops = <Operation>{};
          for (var seed = 0; seed < 30; seed++) {
            for (final task
                in generateTasks(lesson: lesson, count: 20, seed: seed)) {
              ops.add(task.op);
              expect(task.a, inInclusiveRange(1, 6), reason: '$task');
              expect(task.b, inInclusiveRange(1, 6), reason: '$task');
              expect(task.result, inInclusiveRange(1, 6), reason: '$task');
            }
          }
          expect(
            ops,
            switch (id) {
              'add_to_six' => {Operation.add},
              'sub_to_six' => {Operation.sub},
              _ => {Operation.add, Operation.sub},
            },
            reason: id,
          );
        }
      });

      test('the mixed lesson keeps its old id', () {
        // Runs recorded before the split still belong to a lesson.
        expect(lessonByIdOrNull('calc_to_six'), isNotNull);
        expect(lessonById('calc_to_six').op, ArithmeticOp.mixed);
        // And an id the catalogue never had comes back empty instead of
        // throwing.
        expect(lessonByIdOrNull('bruchrechnen'), isNull);
        expect(() => lessonById('bruchrechnen'), throwsStateError);
      });

      test('the row comes before the cloud, and both ask the same thing', () {
        // Counting a line and counting a scattered heap are different
        // skills, so they are different lessons - but the tasks behind them
        // are identical.
        for (final pair in [
          ('count_pictures', 'count_pictures_cloud'),
          ('bees_add', 'bees_add_cloud'),
        ]) {
          final row = lessonById(pair.$1);
          final cloud = lessonById(pair.$2);
          expect(row.arrangement, PictureArrangement.row);
          expect(cloud.arrangement, PictureArrangement.scattered);
          expect(cloud.form, row.form);
          // The row version is offered first.
          expect(
            lessonCatalog.indexOf(row),
            lessThan(lessonCatalog.indexOf(cloud)),
          );
          // Same seed, same tasks: only the layout differs.
          expect(
            generateTasks(lesson: cloud, count: 20, seed: 7),
            generateTasks(lesson: row, count: 20, seed: 7),
          );
        }
      });

      test('bees are added up, never past ten, and always bees', () {
        final lesson = lessonById('bees_add');
        for (var seed = 0; seed < 30; seed++) {
          for (final task
              in generateTasks(lesson: lesson, count: 20, seed: seed)) {
            expect(task.a, inInclusiveRange(1, 5), reason: '$task');
            expect(task.b, greaterThanOrEqualTo(1), reason: '$task');
            expect(task.expected, task.a + task.b);
            expect(task.expected, lessThanOrEqualTo(10), reason: '$task');
            expect(task.picture, '🐝');
            expect(task.question, 'Wie viele sind es zusammen?');
          }
        }
      });

      test('dice read as pips, not as "Würfel 2"', () {
        const one = Task(a: 2, b: 0, op: Operation.add, form: TaskForm.dice);
        const two = Task(a: 4, b: 3, op: Operation.add, form: TaskForm.dice);
        expect(one.toString(), '2 Punkte');
        expect(two.toString(), '4 + 3 Punkte');
      });
    });

    test('up-to-10 lessons stay inside the first number range', () {
      for (final lesson in lessonsInGroup(LessonGroup.upTo10)) {
        for (var seed = 0; seed < 30; seed++) {
          final tasks = generateTasks(lesson: lesson, count: 20, seed: seed);
          for (final task in tasks) {
            expect(task.a, inInclusiveRange(0, 10), reason: '$task');
            expect(task.b, inInclusiveRange(0, 10), reason: '$task');
            expect(task.result, inInclusiveRange(0, 10), reason: '$task');
            expect(task.expected, inInclusiveRange(0, 10), reason: '$task');
          }
        }
      }
    });

    test('up-to-20 lessons stay in first-grade territory', () {
      for (final lesson in lessonsInGroup(LessonGroup.upTo20)) {
        final tasks = generateTasks(lesson: lesson, count: 40, seed: 3);
        for (final task in tasks) {
          expect(task.a, lessThanOrEqualTo(20), reason: '$task');
          expect(task.b, lessThanOrEqualTo(20), reason: '$task');
          expect(task.result, inInclusiveRange(0, 20), reason: '$task');
        }
      }
    });

    test('up-to-1000 lessons work with three-digit numbers', () {
      for (final lesson in lessonsInGroup(LessonGroup.upTo1000)) {
        final tasks = generateTasks(lesson: lesson, count: 40, seed: 8);
        for (final task in tasks) {
          // Either operand may be the small one - additions are shown in both
          // orders - but the task always involves a three-digit number.
          expect(
            task.a >= 100 || task.b >= 100,
            isTrue,
            reason: '$task',
          );
        }
      }
    });

    test('additions are shown in both orders', () {
      // The ranges draw the bigger operand first; without the deliberate flip
      // every addition would read "68 + 13" and never "13 + 68".
      for (final id in ['add_20_plain', 'add_100_carry', 'add_1000_plain']) {
        var firstIsBigger = 0;
        var total = 0;
        for (var seed = 0; seed < 60; seed++) {
          for (final task
              in generateTasks(lesson: lessonById(id), count: 20, seed: seed)) {
            total++;
            if (task.a > task.b) firstIsBigger++;
          }
        }
        expect(firstIsBigger / total, closeTo(0.5, 0.1), reason: id);
      }
    });

    test('the operand 1 appears, but stays rare', () {
      for (final id in ['add_20_plain', 'sub_20_plain', 'add_100_carry']) {
        var withOne = 0;
        var total = 0;
        for (var seed = 0; seed < 60; seed++) {
          for (final task
              in generateTasks(lesson: lessonById(id), count: 20, seed: seed)) {
            total++;
            if (task.a == 1 || task.b == 1) withOne++;
          }
        }
        expect(withOne, greaterThan(0), reason: id);
        expect(withOne / total, lessThan(0.2), reason: id);
      }
    });
  });

  group('Task presentation', () {
    test('result form asks for the result', () {
      const task = Task(a: 47, b: 38, op: Operation.add, form: TaskForm.result);
      expect(task.result, 85);
      expect(task.expected, 85);
      expect(task.prefix, '47 + 38 =');
      expect(task.suffix, '');
      expect(task.render('85'), '47 + 38 = 85');
    });

    test('gap form asks for the second operand', () {
      const task = Task(a: 34, b: 37, op: Operation.add, form: TaskForm.gap);
      expect(task.expected, 37);
      expect(task.prefix, '34 +');
      expect(task.suffix, '= 71');
      expect(task.render('37'), '34 + 37 = 71');
    });

    test('subtraction uses a real minus sign', () {
      const task = Task(a: 72, b: 38, op: Operation.sub, form: TaskForm.result);
      expect(task.result, 34);
      expect(task.opSymbol, '−');
    });
  });

  group('lesson catalog', () {
    test('has 75 lessons in nine groups with unique ids', () {
      expect(lessonCatalog, hasLength(75));
      expect(lessonsInGroup(LessonGroup.firstSteps), hasLength(12));
      expect(lessonsInGroup(LessonGroup.everyday), hasLength(9));
      // Nine rows of the times table plus a mixed one.
      expect(lessonsInGroup(LessonGroup.timesTables), hasLength(10));
      expect(lessonsInGroup(LessonGroup.timesAndDivision), hasLength(7));
      // Nine rows read backwards plus all of them mixed.
      expect(lessonsInGroup(LessonGroup.reverseTimesTables), hasLength(10));
      // Up to 10 nothing can cross the ten, so that group is shorter: the
      // pairs that make ten plus five lessons, instead of the usual seven.
      expect(lessonsInGroup(LessonGroup.upTo10), hasLength(6));
      expect(lessonsInGroup(LessonGroup.upTo20), hasLength(7));
      expect(lessonsInGroup(LessonGroup.upTo100), hasLength(7));
      expect(lessonsInGroup(LessonGroup.upTo1000), hasLength(7));
      expect(lessonCatalog.first.id, 'count_pictures');
      expect(lessonCatalog.map((l) => l.id).toSet(), hasLength(75));
    });

    // The rule the numerals follow: a number belongs where an amount is meant
    // to be tied to it, and not where the point of the exercise is to count.
    test('numerals are shown next to an amount, never where counting is the '
        'exercise', () {
      for (final id in [
        'compare_more',
        'compare_more_cloud',
        'bees_add',
        'bees_add_cloud',
        'dice_add',
      ]) {
        expect(lessonById(id).showCounts, isTrue, reason: id);
      }
      for (final id in [
        'count_pictures',
        'count_pictures_cloud',
        'count_dice',
      ]) {
        expect(lessonById(id).showCounts, isFalse, reason: id);
      }
      // Nothing outside the first steps draws pictures at all, so a numeral
      // there would have nothing to sit under.
      for (final lesson in lessonCatalog
          .where((l) => l.group != LessonGroup.firstSteps)) {
        expect(lesson.showCounts, isFalse, reason: lesson.id);
      }
    });

    test('the two comparison lessons differ only in their arrangement', () {
      final row = lessonById('compare_more');
      final cloud = lessonById('compare_more_cloud');
      expect(row.arrangement, PictureArrangement.row);
      expect(cloud.arrangement, PictureArrangement.scattered);
      expect(cloud.form, row.form);
      expect(cloud.scored, row.scored);
    });

    test('a reverse row divides by that row and nothing else', () {
      for (final n in [2, 5, 10, 3, 4, 6, 7, 8, 9]) {
        final lesson = lessonById('div_by_$n');
        expect(lesson.timesTable, n);
        for (var seed = 0; seed < 20; seed++) {
          for (final task
              in generateTasks(lesson: lesson, count: 20, seed: seed)) {
            expect(task.op, Operation.div, reason: '$task');
            expect(task.b, n, reason: 'divided by the row: $task');
            // It goes out evenly, and the quotient stays in the table.
            expect(task.a % n, 0, reason: '$task');
            expect(task.result, inInclusiveRange(1, 10), reason: '$task');
            expect(task.a, lessThanOrEqualTo(100), reason: '$task');
          }
        }
      }
    });

    test('the reverse group mirrors the tables, and closes the same way', () {
      final forwards = lessonsInGroup(LessonGroup.timesTables);
      final backwards = lessonsInGroup(LessonGroup.reverseTimesTables);
      expect(backwards, hasLength(forwards.length));
      // Same rows, in the same order - the row just drilled forwards is the
      // one to try backwards.
      expect(
        backwards.map((l) => l.timesTable).toList(),
        forwards.map((l) => l.timesTable).toList(),
      );
      // The mixed lesson at the end kept its id, because leaderboards point
      // at it.
      expect(backwards.last.id, 'div_plain');
      expect(backwards.last.timesTable, isNull);
      expect(lessonById('div_plain').group, LessonGroup.reverseTimesTables);
    });

    test('the reverse group sits between the tables and mixed division', () {
      const order = LessonGroup.values;
      expect(
        order.indexOf(LessonGroup.reverseTimesTables),
        order.indexOf(LessonGroup.timesTables) + 1,
      );
      expect(
        order.indexOf(LessonGroup.timesAndDivision),
        order.indexOf(LessonGroup.reverseTimesTables) + 1,
      );
    });

    test('the times tables are ordered easiest first', () {
      final rows = lessonsInGroup(LessonGroup.timesTables)
          .where((l) => l.timesTable != null)
          .map((l) => l.timesTable)
          .toList();
      expect(rows, [2, 5, 10, 3, 4, 6, 7, 8, 9]);
      expect(lessonsInGroup(LessonGroup.timesTables).last.id, 'times_all');
    });

    test('the up-to-10 group does not pretend there is a Zehnerübergang', () {
      for (final lesson in lessonsInGroup(LessonGroup.upTo10)) {
        expect(lesson.carry, CarryMode.any, reason: lesson.id);
        expect(lesson.title, isNot(contains('Übergang')), reason: lesson.id);
      }
    });

    test('the small ranges name the Zehnerübergang, the big one does not', () {
      expect(lessonById('add_20_carry').title, 'Plus mit Zehnerübergang');
      expect(lessonById('sub_100_plain').title, 'Minus ohne Zehnerübergang');
      // Up to 1000 a task may cross the ten or the hundred.
      expect(lessonById('add_1000_carry').title, 'Plus mit Übergang');
    });

    test('every lesson explains itself in one sentence', () {
      for (final lesson in lessonCatalog) {
        expect(lesson.description, isNotEmpty, reason: lesson.id);
        expect(
          ['.', '?', '!'].any(lesson.description.endsWith),
          isTrue,
          reason: lesson.id,
        );
      }
    });

    test('lessonById finds every lesson and rejects unknown ids', () {
      for (final lesson in lessonCatalog) {
        expect(lessonById(lesson.id), same(lesson));
      }
      expect(() => lessonById('nope'), throwsStateError);
    });
  });
}
