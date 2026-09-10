import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';

void main() {
  group('Punkt vor Strich', () {
    test('the point operation is worked out first, wherever it sits', () {
      // Point term at the back.
      const a = Task(
        a: 4,
        b: 3,
        op: Operation.add,
        c: 5,
        op2: Operation.mul,
        form: TaskForm.chain,
      );
      expect(a.result, 19); // 4 + 3 · 5, not (4 + 3) · 5.
      expect(a.prefix, '4 + 3 · 5 =');

      // Point term at the back, minus this time.
      const b = Task(
        a: 40,
        b: 3,
        op: Operation.sub,
        c: 6,
        op2: Operation.mul,
        form: TaskForm.chain,
      );
      expect(b.result, 22); // 40 − 3 · 6, not (40 − 3) · 6.
      expect(b.prefix, '40 − 3 · 6 =');

      // Point term at the front, a division.
      const c = Task(
        a: 72,
        b: 8,
        op: Operation.div,
        c: 14,
        op2: Operation.add,
        form: TaskForm.chain,
      );
      expect(c.result, 23); // 72 : 8 + 14.
      expect(c.prefix, '72 : 8 + 14 =');

      // Point term at the back, a division.
      const d = Task(
        a: 25,
        b: 54,
        op: Operation.add,
        c: 6,
        op2: Operation.div,
        form: TaskForm.chain,
      );
      expect(d.result, 34); // 25 + 54 : 6.
      expect(d.prefix, '25 + 54 : 6 =');
    });

    test('expected is the whole term, and there is no second field', () {
      const task = Task(
        a: 40,
        b: 3,
        op: Operation.sub,
        c: 6,
        op2: Operation.mul,
        form: TaskForm.chain,
      );
      expect(task.expected, 22);
      expect(task.expectedSecond, isNull);
      expect(task.question, isNull);
      expect(task.render('22'), '40 − 3 · 6 = 22');
    });

    test('key tells the two orders of the same numbers apart', () {
      // `3 · 6 + 40` and `40 − 3 · 6` share every number, but they are
      // different facts and must not count as one for the review pool.
      const pointFirst = Task(
        a: 3,
        b: 6,
        op: Operation.mul,
        c: 40,
        op2: Operation.add,
        form: TaskForm.chain,
      );
      const pointLast = Task(
        a: 40,
        b: 3,
        op: Operation.sub,
        c: 6,
        op2: Operation.mul,
        form: TaskForm.chain,
      );
      expect(pointFirst.key, isNot(pointLast.key));

      // And unlike a plain result task, the key does not swap operands
      // around: the order is exactly what is being practised here.
      const swapped = Task(
        a: 6,
        b: 3,
        op: Operation.mul,
        c: 40,
        op2: Operation.add,
        form: TaskForm.chain,
      );
      expect(pointFirst.key, isNot(swapped.key));
    });

    test('equality and hashCode take c and op2 into account', () {
      const task = Task(
        a: 40,
        b: 3,
        op: Operation.sub,
        c: 6,
        op2: Operation.mul,
        form: TaskForm.chain,
      );
      const same = Task(
        a: 40,
        b: 3,
        op: Operation.sub,
        c: 6,
        op2: Operation.mul,
        form: TaskForm.chain,
      );
      const differentC = Task(
        a: 40,
        b: 3,
        op: Operation.sub,
        c: 7,
        op2: Operation.mul,
        form: TaskForm.chain,
      );
      const differentOp2 = Task(
        a: 40,
        b: 3,
        op: Operation.sub,
        c: 6,
        op2: Operation.div,
        form: TaskForm.chain,
      );

      expect(task, same);
      expect(task.hashCode, same.hashCode);
      expect(task, isNot(differentC));
      expect(task, isNot(differentOp2));
    });
  });
}
