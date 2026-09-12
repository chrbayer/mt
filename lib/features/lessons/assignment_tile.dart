import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/assignment.dart';
import '../../domain/lesson.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/star_row.dart';
import 'lesson_example.dart';
import 'start_lesson_sheet.dart';

/// A card for one lesson of one open assignment - the same catalogue tile as
/// [LessonHomeScreen]'s `_LessonTile`, right down to the grid, the radius,
/// the border and the lesson group's own pastel: it is the same lesson,
/// after all, and only the footer says something different.
///
/// Deliberately not a list: "Deine Aufgaben" answers "what now?" the way the
/// catalogue does, and a checklist row would answer it in a different
/// language from the rest of the screen.
class AssignmentTile extends ConsumerWidget {
  final Assignment assignment;

  /// Which of the assignment's lessons this card is for. An assignment can
  /// name several, and each of them is its own card - for the child nothing
  /// changed when assignments learned to hold more than one.
  final LessonSpec lesson;

  const AssignmentTile({
    super.key,
    required this.assignment,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(assignmentStatsProvider(assignment)).value;
    final progress = stats?.progressOf(lesson.id);
    // The lesson vanished from the catalogue (an older backup, a dropped
    // lesson) - nothing to draw and nothing to measure against.
    if (progress == null) return const SizedBox.shrink();

    final met = progress.met;
    final tint = AppColors.groupTint(lesson.group.index);
    final edge = AppColors.groupEdge(lesson.group.index);

    return Material(
      color: tint,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => StartLessonSheet.show(context, lesson),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: edge, width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          // Dimmed, not disabled: "erledigt" reads as "fertig", never as
          // "zu" - the same pairing the locked profile tile keeps, only with
          // the opposite meaning. The tap target stays live throughout.
          child: Opacity(
            opacity: met ? 0.55 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        lesson.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                    Icon(
                      met ? Icons.check_circle : Icons.push_pin_rounded,
                      size: 20,
                      color: met ? AppColors.correct : AppColors.primary,
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: LessonExample(lesson: lesson),
                    ),
                  ),
                ),
                _AssignmentFooter(
                  assignment: assignment,
                  progress: progress,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AssignmentFooter extends StatelessWidget {
  final Assignment assignment;
  final AssignmentProgress progress;

  const _AssignmentFooter({required this.assignment, required this.progress});

  @override
  Widget build(BuildContext context) {
    // The card stays up for the rest of the period once its goal is met -
    // the tick is the reward, and a card that vanished would not be one. So
    // this is the only thing the footer says from then on.
    if (progress.met) {
      return const Text(
        'geschafft',
        style: TextStyle(fontSize: 17, color: AppColors.textMuted),
      );
    }

    final a = assignment;
    return Row(
      children: [
        // Requirements reuse the same star and bolt rows the rest of the app
        // wears for what was *earned* - here it is what each run has to
        // clear, which reads the same way: filled means it matters, an
        // empty requirement (0) is simply left out.
        if (a.minStars > 0) ...[
          StarRow(earned: a.minStars, size: 16),
          const SizedBox(width: 6),
        ],
        if (a.minBolts > 0) ...[
          BoltRow(earned: a.minBolts, size: 16),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            '${progress.qualifyingRuns}/${a.runs} · ${formatDeadline(a)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
