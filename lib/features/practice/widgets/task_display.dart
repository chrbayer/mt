import 'package:flutter/material.dart';

import '../../../domain/lesson.dart';
import '../../../domain/task.dart';
import '../../../theme/app_theme.dart';
import '../practice_controller.dart';
import 'clock_face.dart';
import 'counted_pair.dart';
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

  /// Whether each group carries its own number. Also a lesson property.
  final bool showCounts;

  /// Whether the clock is read as a 24-hour time; then the part of the day
  /// is written under the face, because the hands alone cannot say it.
  final bool clock24;

  /// The coins and notes laid down so far, for [TaskForm.moneyCompose].
  final List<int> pieces;

  const TaskDisplay({
    super.key,
    required this.task,
    required this.input,
    required this.feedback,
    this.secondInput = '',
    this.activeField = AnswerField.primary,
    this.arrangement = PictureArrangement.row,
    this.showCounts = false,
    this.clock24 = false,
    this.pieces = const [],
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
      // A single heap to count: never a number, or the answer would be
      // standing right there.
      TaskForm.quantity => PictureGroup(
          count: task.a,
          picture: task.picture,
          arrangement: arrangement,
          seed: task.a * 31 + task.b,
        ),
      TaskForm.dice => task.b == 0
          ? DiceFace(pips: task.a)
          : CountedPair(
              left: DiceFace(pips: task.a),
              right: DiceFace(pips: task.b),
              separator: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                child: Text('+', style: style.copyWith(fontSize: 72)),
              ),
              countSeparator: const Text('+'),
              leftCount: showCounts ? task.a : null,
              rightCount: showCounts ? task.b : null,
              countSize: 68,
            ),
      TaskForm.quantityAdd => CountedPair(
          left: PictureGroup(
            count: task.a,
            picture: task.picture,
            arrangement: arrangement,
            seed: task.a * 31 + task.b,
          ),
          right: PictureGroup(
            count: task.b,
            picture: task.picture,
            arrangement: arrangement,
            seed: task.b * 31 + task.a,
          ),
          separator: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text('+', style: style.copyWith(fontSize: 72)),
          ),
          countSeparator: const Text('+'),
          leftCount: showCounts ? task.a : null,
          rightCount: showCounts ? task.b : null,
          countSize: 68,
        ),
      // The divider is what makes two heaps read as two heaps, so it grows
      // with them - a cloud is far taller than a row, and a stub of a line
      // between two tall clouds separates nothing.
      // No plus between these counts: the heaps are compared, not added, and
      // a plus underneath would teach the wrong sum.
      TaskForm.compare => CountedPair(
          left: PictureGroup(
            count: task.a,
            picture: task.picture,
            arrangement: arrangement,
            seed: task.a * 31 + task.b,
          ),
          right: PictureGroup(
            count: task.b,
            picture: task.picture,
            arrangement: arrangement,
            seed: task.b * 31 + task.a,
          ),
          stretchSeparator: true,
          separator: Container(
            width: 8,
            margin: const EdgeInsets.symmetric(horizontal: 36),
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          leftCount: showCounts ? task.a : null,
          rightCount: showCounts ? task.b : null,
          countSize: 68,
        ),
      // Two answers, and the first of them is a word. The pad swaps to
      // words while that box is active, so both are typed the same way.
      TaskForm.clockPhrase => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClockFace(hour: task.a, minute: task.b),
            const SizedBox(width: 44),
            _AnswerBox(
              input: input.isEmpty ? '' : clockPhrases[int.parse(input)],
              feedback: feedback,
              active: activeField == AnswerField.primary,
              width: 400,
            ),
            const SizedBox(width: 24),
            _AnswerBox(
              input: secondInput,
              feedback: feedback,
              active: activeField == AnswerField.second,
              width: 190,
            ),
          ],
        ),
      // The pile itself is the answer, so it is drawn: a running total alone
      // would not show which coins are already down.
      TaskForm.moneyCompose => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _AnswerBox(
              input: input.isEmpty ? '' : formatEuro(int.parse(input)),
              feedback: feedback,
              width: 400,
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 54,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final piece in pieces)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: _PieceChip(cents: piece),
                    ),
                ],
              ),
            ),
          ],
        ),
      _ => null,
    };

    if (illustration != null) {
      // These two bring their own answer boxes; everything else gets one
      // placed beside the picture.
      final bringsItsOwnBox = task.form == TaskForm.clockPhrase ||
          task.form == TaskForm.moneyCompose;
      return _WithQuestion(
        question: task.question,
        child: bringsItsOwnBox
            ? illustration
            : Row(
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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClockFace(hour: task.a, minute: task.b),
                    if (clock24) ...[
                      const SizedBox(height: 12),
                      Text(
                        task.dayPart,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
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

    // A 24-hour lesson has to say so: the hands look the same at 10 in the
    // morning and at 10 at night, and the word under the dial only tells
    // which of the two it is - not that the answer runs past twelve.
    final question = clock24 && task.form == TaskForm.clock
        ? 'Wie spät ist es? Sage es mit 24 Stunden.'
        : task.question;
    return _WithQuestion(question: question, child: row);
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

/// One coin or note in the pile a child has laid out.
class _PieceChip extends StatelessWidget {
  final int cents;

  const _PieceChip({required this.cents});

  @override
  Widget build(BuildContext context) {
    // Notes are drawn as notes and coins as coins: at the till they do not
    // feel alike either.
    final isNote = cents >= 500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isNote ? AppColors.correctSoft : AppColors.background,
        border: Border.all(color: AppColors.divider, width: 2),
        borderRadius: BorderRadius.circular(isNote ? 8 : 24),
      ),
      child: Text(
        formatPiece(cents),
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
      ),
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
      // Words go in this box too ("5 nach halb", "12,50 €"), and they have
      // to get smaller rather than run over the edge.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            input,
            style: Theme.of(context)
                .textTheme
                .displayLarge!
                .copyWith(color: text, height: 1),
          ),
        ),
      ),
    );
  }
}
