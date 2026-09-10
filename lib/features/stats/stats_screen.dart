import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/stats_repository.dart';
import '../../domain/lesson.dart';
import '../../domain/scoring.dart';
import '../../domain/task.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/star_row.dart';
import 'progress_chart.dart';

/// Personal statistics: where the child stands per lesson, how the times
/// developed, and which calculations still cost the most time.
class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  String? _selectedLessonId;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(activeUserProvider);
    if (user == null) return const Scaffold();

    final stats = ref.watch(lessonStatsProvider(user.id)).value ?? const {};
    final played = lessonCatalog.where((l) => stats.containsKey(l.id)).toList();
    final selected = _selectedLessonId ??
        (played.isNotEmpty ? played.first.id : null);

    return Scaffold(
      appBar: AppBar(title: Text('Statistik · ${user.name}')),
      body: played.isEmpty
          ? const Center(
              child: Text(
                'Noch keine abgeschlossenen Durchgänge.',
                style: TextStyle(fontSize: 24, color: AppColors.textMuted),
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _LessonTable(
                      lessons: played,
                      stats: stats,
                      selectedId: selected,
                      onSelect: (id) => setState(() => _selectedLessonId = id),
                    ),
                  ),
                  const SizedBox(width: 28),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lernkurve · ${lessonById(selected!).title}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sekunden pro Aufgabe, Durchgang für Durchgang',
                          style: TextStyle(
                              fontSize: 16, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          flex: 3,
                          child: ref
                              .watch(progressProvider(
                                  (userId: user.id, lessonId: selected)))
                              .when(
                                loading: () => const SizedBox.shrink(),
                                error: (e, _) => Text('$e'),
                                data: (points) =>
                                    ProgressChart(points: points),
                              ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Diese Aufgaben dauern am längsten',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          flex: 2,
                          child: ref.watch(hardestTasksProvider(user.id)).when(
                                loading: () => const SizedBox.shrink(),
                                error: (e, _) => Text('$e'),
                                data: (tasks) => _HardTasks(tasks: tasks),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _LessonTable extends StatelessWidget {
  final List<LessonSpec> lessons;
  final Map<String, LessonStat> stats;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const _LessonTable({
    required this.lessons,
    required this.stats,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: lessons.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(left: 20, right: 20, bottom: 4),
            child: Row(
              children: [
                Expanded(child: SizedBox()),
                _Head('Sterne'),
                _Head('Bestzeit'),
                _Head('Ø Zeit'),
                _Head('Fehler'),
                _Head('Runden'),
              ],
            ),
          );
        }
        final lesson = lessons[index - 1];
        final stat = stats[lesson.id]!;
        final selected = lesson.id == selectedId;

        return Material(
          color: selected ? AppColors.primary.withValues(alpha: 0.10)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () => onSelect(lesson.id),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.divider,
                  width: selected ? 2.5 : 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          groupTitle(lesson.group).toLowerCase(),
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Two rows of three, stacked: side by side they need 160 px
                  // of a 10" tablet's width, and the times next to them lose
                  // more than the icons gain.
                  SizedBox(
                    width: 92,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StarRow(earned: stat.bestStars, size: 20),
                        if (lesson.targetMsPerTask > 0)
                          BoltRow(earned: stat.bestBolts, size: 20),
                      ],
                    ),
                  ),
                  _Value(
                    lesson.scored ? formatPerTask(stat.bestScoreMs) : '–',
                    strong: true,
                  ),
                  _Value(lesson.scored ? formatPerTask(stat.averageMs) : '–'),
                  _Value('${(stat.errorRate * 100).round()} %'),
                  _Value('${stat.runs}'),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Head extends StatelessWidget {
  final String text;

  const _Head(this.text);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 92,
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
        ),
      );
}

class _Value extends StatelessWidget {
  final String text;
  final bool strong;

  const _Value(this.text, {this.strong = false});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 92,
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 20,
            fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
            color: strong ? AppColors.primary : AppColors.text,
          ),
        ),
      );
}

class _HardTasks extends StatelessWidget {
  final List<HardTask> tasks;

  const _HardTasks({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Text(
        'Noch zu wenige Daten.',
        style: TextStyle(fontSize: 18, color: AppColors.textMuted),
      );
    }
    return SingleChildScrollView(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final hard in tasks)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.divider, width: 1.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _render(hard),
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    formatPerTask(hard.averageMs),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Rebuilds the printed form from the stored operands.
  ///
  /// `byName` rather than the old add/sub guess: that guess printed every
  /// multiplication as a subtraction, since it never considered `mul` or
  /// `div` at all.
  String _render(HardTask hard) => Task(
        a: hard.a,
        b: hard.b,
        op: Operation.values.byName(hard.op),
        form: TaskForm.values.byName(hard.form),
        c: hard.c,
        op2: hard.op2 == null ? null : Operation.values.byName(hard.op2!),
      ).toString();
}
