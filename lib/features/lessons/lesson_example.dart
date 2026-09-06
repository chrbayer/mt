import 'package:flutter/material.dart';

import '../../domain/lesson.dart';
import '../../domain/task.dart';
import '../../domain/task_generator.dart';
import '../../theme/app_theme.dart';
import '../practice/widgets/dice_face.dart';
import '../practice/widgets/picture_group.dart';

/// One sample task per lesson, cached because the catalogue never changes.
final _examples = <String, Task>{};

/// A representative task for a lesson: `47 + 38 = ?` says far more than
/// `50 + 50`, `1 + 18` or `253 - 253`. Those all occur in the lesson itself,
/// they just make a poor advertisement for it.
Task exampleTaskFor(LessonSpec lesson) => _examples.putIfAbsent(lesson.id, () {
      // A seed derived from the lesson id. With one shared seed every row of
      // the times table drew the same partner factor and the whole group
      // advertised itself with "9 x something".
      final seed = lesson.id.codeUnits
              .fold<int>(20260905, (value, unit) => value * 31 + unit) &
          0x7FFFFFFF;
      final candidates = generateTasks(lesson: lesson, count: 8, seed: seed);

      bool representative(Task task) {
        // A clock, a price or a heap of pictures is whatever it is - there is
        // no trivial version to avoid.
        if (task.form != TaskForm.result &&
            task.form != TaskForm.gap &&
            task.form != TaskForm.partner) {
          return true;
        }
        if (task.a == 1 || task.b == 1) return false;
        if (task.result == 0) return false;
        // For a division the answer is the quotient, so "4 : 4" is the
        // division version of "times one" - it says nothing about the row.
        // A round dividend is fine: that is what dividing by ten looks like.
        if (task.op == Operation.div) return task.result != 1;
        // A ten belongs in the example only when it is the row being drilled.
        final table = lesson.timesTable;
        if (table != null) {
          final partner = task.a == table ? task.b : task.a;
          return partner % 10 != 0;
        }
        return task.a % 10 != 0 && task.b % 10 != 0;
      }

      return candidates.firstWhere(representative,
          orElse: () => candidates.first);
    });

String exampleFor(LessonSpec lesson) => exampleTaskFor(lesson).toString();

/// The sample task as it should look on a tile.
///
/// Dice get drawn rather than written: "2 Punkte" is no help to a child who
/// cannot read yet, and "Würfel 2" was no help to anyone.
class LessonExample extends StatelessWidget {
  final LessonSpec lesson;
  final double fontSize;

  const LessonExample({
    super.key,
    required this.lesson,
    this.fontSize = 27,
  });

  @override
  Widget build(BuildContext context) {
    final task = exampleTaskFor(lesson);

    // The two picture variants differ only in their layout, so the tile has
    // to show it - otherwise "Reihe" and "Wolke" look like the same lesson.
    if (task.form == TaskForm.quantity) {
      return PictureGroup(
        count: task.a,
        picture: task.picture,
        arrangement: lesson.arrangement,
        seed: task.a * 31 + task.b,
        size: fontSize,
        showCount: lesson.showCounts,
      );
    }
    if (task.form == TaskForm.quantityAdd) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PictureGroup(
            count: task.a,
            picture: task.picture,
            arrangement: lesson.arrangement,
            seed: task.a * 31 + task.b,
            size: fontSize,
            showCount: lesson.showCounts,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: fontSize * 0.3),
            child: Text(
              '+',
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          PictureGroup(
            count: task.b,
            picture: task.picture,
            arrangement: lesson.arrangement,
            seed: task.b * 31 + task.a,
            size: fontSize,
            showCount: lesson.showCounts,
          ),
        ],
      );
    }
    if (task.form == TaskForm.dice) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DiceFace(
            pips: task.a,
            size: fontSize * 1.7,
            showNumber: lesson.showCounts,
          ),
          if (task.b > 0) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: fontSize * 0.35),
              child: Text(
                '+',
                style: TextStyle(
                  fontSize: fontSize,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            DiceFace(
              pips: task.b,
              size: fontSize * 1.7,
              showNumber: lesson.showCounts,
            ),
          ],
        ],
      );
    }

    return Text(
      task.toString(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize,
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
