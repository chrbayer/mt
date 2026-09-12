import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../domain/assignment.dart';
import '../../domain/lesson.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import 'assignment_editor.dart';

/// What a parent set up for each child: which lesson, on what rhythm, to
/// what minimum - and, underneath, how often the goal was actually held.
///
/// Filtered by child the same way the run log is, because the question here
/// is the same one: "what has this child been asked to do, and how is it
/// going".
///
/// An open assignment can be changed, and changing it re-judges what is
/// behind it: nothing about an assignment is frozen, it is all worked out
/// from the runs each time it is read. Raising the bar can therefore take
/// today's tick away again, which is exactly what raising a bar means.
/// Child and lesson stay put - see [AssignmentEditor].
class AssignmentsTab extends ConsumerStatefulWidget {
  const AssignmentsTab({super.key});

  @override
  ConsumerState<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends ConsumerState<AssignmentsTab> {
  int? _filter;

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider).value ?? const <User>[];
    final assignments = ref.watch(assignmentsProvider(_filter)).value ??
        const <Assignment>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
          child: Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Alle', style: TextStyle(fontSize: 19)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      selected: _filter == null,
                      onSelected: (_) => setState(() => _filter = null),
                    ),
                    for (final user in users)
                      ChoiceChip(
                        label: Text(
                          '${user.avatar}  ${user.name}',
                          style: const TextStyle(fontSize: 19),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        selected: _filter == user.id,
                        onSelected: (_) => setState(() => _filter = user.id),
                      ),
                  ],
                ),
              ),
              FilledButton.icon(
                icon: const Icon(Icons.add_task, size: 26),
                label: const Text('Neue Aufgabe'),
                onPressed: () => AssignmentEditor.show(context),
              ),
            ],
          ),
        ),
        Expanded(
          child: assignments.isEmpty
              ? const Center(
                  child: Text(
                    'Noch keine Aufgaben.',
                    style: TextStyle(fontSize: 22, color: AppColors.textMuted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                  itemCount: assignments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _AssignmentRow(
                    assignment: assignments[index],
                    user: users.where((u) => u.id == assignments[index].userId)
                        .firstOrNull,
                  ),
                ),
        ),
      ],
    );
  }
}

class _AssignmentRow extends ConsumerWidget {
  final Assignment assignment;
  final User? user;

  const _AssignmentRow({required this.assignment, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(assignmentStatsProvider(assignment)).value;
    final lessons = [
      for (final id in assignment.lessonIds) ?lessonByIdOrNull(id),
    ];
    final ended = !assignment.isOpen;
    // The rhythm shows up twice in this row, once as its own word and once
    // as the unit the statistic counts in.
    final daily = assignment.rhythm == AssignmentRhythm.daily;
    final rhythmWord = daily ? 'täglich' : 'wöchentlich';
    final periodWord = daily ? 'Tagen' : 'Wochen';

    return Opacity(
      opacity: ended ? 0.6 : 1,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.divider, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (user != null) ...[
                  Text(user!.avatar, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    user!.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.profileColor(user!.colorIndex),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Text(
                    lessons.isEmpty
                        ? assignment.lessonIds.join(', ')
                        : lessons.length == 1
                            ? '${lessons.single.title} · '
                                '${groupTitle(lessons.single.group)}'
                            : '${lessons.length} Übungen',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                ),
                if (!ended)
                  TextButton.icon(
                    icon: const Icon(Icons.edit_outlined, size: 22),
                    label: const Text('Ändern'),
                    onPressed: () =>
                        AssignmentEditor.show(context, existing: assignment),
                  ),
                if (!ended)
                  TextButton.icon(
                    icon: const Icon(Icons.stop_circle_outlined, size: 22),
                    label: const Text('Beenden'),
                    onPressed: () => ref
                        .read(assignmentRepositoryProvider)
                        .endAssignment(
                          assignment.id,
                          DateTime.now().millisecondsSinceEpoch,
                        ),
                  ),
                IconButton(
                  tooltip: 'Aufgabe löschen',
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.textMuted),
                  onPressed: () => ref
                      .read(assignmentRepositoryProvider)
                      .deleteAssignment(assignment.id),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$rhythmWord '
              '· ${assignment.runs}× ${assignment.taskCount} Rechnungen'
              '${assignment.minStars > 0 ? " · mind. ${assignment.minStars} ★" : ""}'
              '${assignment.minBolts > 0 ? " · mind. ${assignment.minBolts} ⚡" : ""}',
              style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
            if (stats != null) ...[
              const SizedBox(height: 8),
              // One line per lesson, each with its own count: every lesson
              // of an assignment is measured on its own, and the assignment
              // is done when all of them are.
              if (!ended)
                for (final lesson in lessons)
                  _LessonLine(
                    lesson: lesson,
                    progress: stats.progressOf(lesson.id),
                    runs: assignment.runs,
                    showTitle: lessons.length > 1,
                    closedMet: stats.closedMetByLesson[lesson.id] ?? 0,
                    closedTotal: stats.closed.length,
                    periodWord: periodWord,
                  ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    stats.closed.isEmpty
                        ? 'Noch kein abgeschlossener Zeitraum'
                        : 'Geschafft an ${stats.closedMet} von '
                            '${stats.closed.length} $periodWord',
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 10),
                  // The last fourteen closed periods as a strip of dots -
                  // "how often" at a glance, without a table to read.
                  for (final met in _lastFourteen(stats.closed))
                    Padding(
                      padding: const EdgeInsets.only(right: 3),
                      child: Icon(
                        Icons.circle,
                        size: 10,
                        color: met ? AppColors.correct : AppColors.divider,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<bool> _lastFourteen(List<bool> closed) =>
      closed.length <= 14 ? closed : closed.sublist(closed.length - 14);
}

/// Where one lesson of an assignment stands in the period running now.
class _LessonLine extends StatelessWidget {
  final LessonSpec lesson;
  final AssignmentProgress? progress;
  final int runs;

  /// With a single lesson the heading above already names it, so repeating
  /// it here would only take the room the numbers need.
  final bool showTitle;

  /// How many of the closed periods this lesson met, and how many there
  /// were. The dot strip below says a period was missed; this says by which
  /// lesson, which is the only half a parent can act on.
  final int closedMet;
  final int closedTotal;
  final String periodWord;

  const _LessonLine({
    required this.lesson,
    required this.progress,
    required this.runs,
    required this.showTitle,
    required this.closedMet,
    required this.closedTotal,
    required this.periodWord,
  });

  @override
  Widget build(BuildContext context) {
    final done = progress?.met ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 18,
            color: done ? AppColors.correct : AppColors.divider,
          ),
          const SizedBox(width: 8),
          if (showTitle) ...[
            Flexible(
              child: Text(
                lesson.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            '${progress?.qualifyingRuns ?? 0}/$runs',
            style: const TextStyle(fontSize: 16, color: AppColors.textMuted),
          ),
          if (closedTotal > 0) ...[
            const SizedBox(width: 10),
            Text(
              '· davor $closedMet von $closedTotal $periodWord',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                // The one that keeps falling short is the one to talk about,
                // so it does not read like the others.
                color: closedMet < closedTotal
                    ? AppColors.profile1
                    : AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
