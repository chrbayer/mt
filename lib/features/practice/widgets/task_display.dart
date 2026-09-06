import 'package:flutter/material.dart';

import '../../../domain/lesson.dart';
import '../../../domain/task.dart';
import '../../../theme/app_theme.dart';
import '../practice_controller.dart';
import 'clock_face.dart';
import 'dice_face.dart';
import 'picture_group.dart';

/// The task itself plus the answer box, scaled to fill the space it gets.
class TaskDisplay extends StatelessWidget {
  final Task task;
  final String input;
  final AnswerFeedback feedback;

  /// Content of the second box, for a division with remainder.
  final String secondInput;

  /// Which box the keypad is filling; the other one is drawn quietly.
  final AnswerField activeField;

  /// How a counting task lays out its pictures. A property of the lesson, so
  /// it is handed in rather than read off the task.
  final PictureArrangement arrangement;

  const TaskDisplay({
    super.key,
    required this.task,
    required this.input,
    required this.feedback,
    this.secondInput = '',
    this.activeField = AnswerField.primary,
    this.arrangement = PictureArrangement.row,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.displayLarge!;
    final twoBoxes = task.expectedSecond != null;
    final box = _AnswerBox(
      input: input,
      feedback: feedback,
      // With one box there is nothing to point at, so it is never singled out.
      active: twoBoxes && activeField == AnswerField.primary,
      width: task.form == TaskForm.money || task.form == TaskForm.clock
          ? 200
          : 300,
    );

    // The gentlest forms draw a picture and put the box beside it. Nothing is
    // written as an equation, because reading one is not the point yet.
    final Widget? illustration = switch (task.form) {
      TaskForm.quantity => PictureGroup(
          count: task.a,
          picture: task.picture,
          arrangement: arrangement,
          seed: task.a * 31 + task.b,
        ),
      TaskForm.dice => Row(
          mainAxisSize: MainAxisSize.min,
          // Top-aligned so the plus lines up with the dice themselves rather
          // than with the numerals printed underneath them.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DiceFace(pips: task.a),
            if (task.b > 0) ...[
              SizedBox(
                height: DiceFace.defaultSize,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Center(
                    child: Text('+', style: style.copyWith(fontSize: 72)),
                  ),
                ),
              ),
              DiceFace(pips: task.b),
            ],
          ],
        ),
      TaskForm.quantityAdd => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PictureGroup(
              count: task.a,
              picture: task.picture,
              arrangement: arrangement,
              seed: task.a * 31 + task.b,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Text('+', style: style.copyWith(fontSize: 72)),
            ),
            PictureGroup(
              count: task.b,
              picture: task.picture,
              arrangement: arrangement,
              seed: task.b * 31 + task.a,
            ),
          ],
        ),
      TaskForm.compare => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PictureGroup(
              count: task.a,
              picture: task.picture,
              arrangement: arrangement,
            ),
            Container(
              width: 3,
              height: 150,
              margin: const EdgeInsets.symmetric(horizontal: 28),
              color: AppColors.divider,
            ),
            PictureGroup(
              count: task.b,
              picture: task.picture,
              arrangement: arrangement,
            ),
          ],
        ),
      TaskForm.sequence => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final number in task.sequenceNumbers)
              Padding(
                padding: const EdgeInsets.only(right: 28),
                child: Text('$number', style: style),
              ),
          ],
        ),
      _ => null,
    };

    if (illustration != null) {
      return _WithQuestion(
        question: task.question,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            illustration,
            const SizedBox(width: 36),
            box,
          ],
        ),
      );
    }

    // "Verliebte Zahlen" is not written as a calculation: a heart between the
    // two numbers says "these belong together" without any reading.
    final row = task.form == TaskForm.partner
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${task.a}', style: style),
              const SizedBox(width: 32),
              const Icon(Icons.favorite, size: 84, color: AppColors.heart),
              const SizedBox(width: 32),
              box,
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (task.form == TaskForm.clock) ...[
                ClockFace(hour: task.a, minute: task.b),
                const SizedBox(width: 44),
              ] else
                Text(task.prefix, style: style),
              const SizedBox(width: 20),
              box,
              if (task.suffix.isNotEmpty) ...[
                const SizedBox(width: 20),
                Text(task.suffix, style: style),
              ],
              if (twoBoxes) ...[
                const SizedBox(width: 22),
                Text(task.secondLabel, style: style.copyWith(fontSize: 60)),
                const SizedBox(width: 22),
                _AnswerBox(
                  input: secondInput,
                  feedback: feedback,
                  active: activeField == AnswerField.second,
                  width: task.form == TaskForm.remainder ? 190 : 200,
                ),
                if (task.secondUnit.isNotEmpty) ...[
                  const SizedBox(width: 16),
                  Text(task.secondUnit,
                      style: style.copyWith(fontSize: 60)),
                ],
              ],
            ],
          );

    return _WithQuestion(question: task.question, child: row);
  }
}

/// Puts the spoken question above whatever the task shows, and scales the
/// whole thing down rather than letting it clip.
class _WithQuestion extends StatelessWidget {
  final String? question;
  final Widget child;

  const _WithQuestion({required this.question, required this.child});

  @override
  Widget build(BuildContext context) {
    if (question == null) {
      return FittedBox(fit: BoxFit.scaleDown, child: child);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          question!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 30, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: child)),
      ],
    );
  }
}

class _AnswerBox extends StatelessWidget {
  final String input;
  final AnswerFeedback feedback;

  /// Marks the box the keypad is writing into, when there is more than one.
  final bool active;
  final double width;

  const _AnswerBox({
    required this.input,
    required this.feedback,
    this.active = false,
    this.width = 300,
  });

  @override
  Widget build(BuildContext context) {
    final (border, fill, text) = switch (feedback) {
      AnswerFeedback.correct => (
          AppColors.correct,
          AppColors.correctSoft,
          AppColors.correct
        ),
      AnswerFeedback.wrong => (
          AppColors.wrong,
          AppColors.wrongSoft,
          AppColors.wrong
        ),
      AnswerFeedback.none => (
          active ? AppColors.primary : AppColors.divider,
          AppColors.surface,
          AppColors.text
        ),
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: width,
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border, width: active ? 7 : 5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        input,
        style: Theme.of(context)
            .textTheme
            .displayLarge!
            .copyWith(color: text, height: 1),
      ),
    );
  }
}
