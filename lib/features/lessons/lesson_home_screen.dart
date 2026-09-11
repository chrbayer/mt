import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/stats_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/assignment.dart';
import '../../domain/lesson.dart';
import '../../domain/lesson_filter.dart';
import '../../domain/practice_limit.dart';
import '../../domain/scoring.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/star_row.dart';
import '../practice/practice_screen.dart';
import '../profiles/profile_badge.dart';
import '../settings/settings_screen.dart';
import '../stats/stats_screen.dart';
import 'assignment_tile.dart';
import 'lesson_example.dart';
import 'pause_notice.dart';
import 'recommendation.dart';
import 'start_lesson_sheet.dart';

class LessonHomeScreen extends ConsumerWidget {
  const LessonHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(activeUserProvider);
    if (user == null) return const Scaffold();

    // Keep the cached profile fresh after a rename.
    ref.listen(usersProvider, (_, next) {
      final users = next.value;
      if (users != null) ref.read(activeUserProvider.notifier).refresh(users);
    });

    final stats = ref.watch(lessonStatsProvider(user.id)).value ?? const {};
    final allowance = ref.watch(practiceAllowanceProvider).value ??
        PracticeAllowance.unlimited;
    final assignments =
        ref.watch(openAssignmentsProvider(user.id)).value ?? const [];
    // Lessons already carrying a card above: suggesting one of them a line
    // further down would be a contradiction, whether its card is still open
    // or already ticked off.
    final assignedLessonIds = {for (final a in assignments) a.lessonId};

    /// The lessons of a group after the child's filter has had its say.
    List<LessonSpec> offered(LessonGroup group) => [
          for (final lesson in lessonsInGroup(group))
            if (!hiddenByFilter(
              user.filter,
              lesson: lesson,
              stars: stats[lesson.id]?.bestStars ?? 0,
              bolts: stats[lesson.id]?.bestBolts ?? 0,
            ))
              lesson,
        ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ProfileBadge(user: user, size: 28),
            const SizedBox(width: 24),
            // The running totals, right where the child looks anyway.
            //
            // Asymmetric on purpose: the stars carry the maximum, the bolts
            // only their count. That says which of the two is the goal -
            // care has a target to reach, speed is the extra on top. It also
            // happens to be what fits on a 10" tablet.
            StarTotal(
              earned: _earnedStars(user.visibleGroups, stats),
              possible: _possibleStars(user.visibleGroups),
              size: 24,
            ),
            const SizedBox(width: 18),
            StarTotal(
              earned: _earnedBolts(user.visibleGroups, stats),
              size: 24,
              bolts: true,
            ),
          ],
        ),
        actions: [
          // The filter belongs here rather than in the settings: it changes
          // what is on this screen, and a child should be able to put the
          // catalogue back without going looking for a switch.
          PopupMenuButton<LessonFilter>(
            tooltip: 'Fertige Lektionen ausblenden',
            icon: Icon(
              user.filter == LessonFilter.all
                  ? Icons.filter_list_off
                  : Icons.filter_list,
              size: 28,
              color: user.filter == LessonFilter.all
                  ? AppColors.textMuted
                  : AppColors.primary,
            ),
            onSelected: (filter) =>
                ref.read(userRepositoryProvider).setLessonFilter(
                      user.id,
                      filter,
                    ),
            itemBuilder: (context) => [
              for (final filter in LessonFilter.values)
                PopupMenuItem<LessonFilter>(
                  value: filter,
                  child: Row(
                    children: [
                      Icon(
                        filter == user.filter
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 22,
                        color: filter == user.filter
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 12),
                      // Wraps rather than overflows: the longest label is a
                      // whole sentence, and the menu is only as wide as the
                      // button it hangs under.
                      Flexible(
                        child: Text(lessonFilterTitle(filter),
                            style: const TextStyle(fontSize: 19)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            icon: const Icon(Icons.insights_outlined, size: 28),
            label: const Text('Statistik', style: TextStyle(fontSize: 20)),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const StatsScreen()),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Einstellungen',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            icon: const Icon(Icons.logout, size: 26),
            label: const Text('Wechseln', style: TextStyle(fontSize: 20)),
            onPressed: () {
              ref.read(activeUserProvider.notifier).logout();
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: user.visibleGroups.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'Für dieses Profil ist noch kein Bereich freigeschaltet.\n'
                  'Das lässt sich im Elternbereich ändern.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: AppColors.textMuted),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
              children: [
                // Above the recommendation and above the break notice: an
                // assignment answers "what now?" better than either, and a
                // finished card is the reward for finishing it.
                if (assignments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: _AssignmentGroup(assignments: assignments),
                  ),
                if (!allowance.allowed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PauseNotice(allowance: allowance, compact: true),
                  ),
                _RecommendationCard(
                  // A lesson the child has filtered away, or that already
                  // has a card above, must not be suggested a line later.
                  recommendation: recommendLesson(
                    candidates: [
                      for (final group in user.visibleGroups)
                        for (final lesson in offered(group))
                          if (!assignedLessonIds.contains(lesson.id)) lesson,
                    ],
                    stats: stats,
                  ),
                  userId: user.id,
                ),
                for (final group in user.visibleGroups)
                  if (offered(group).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: _LessonGroup(
                        title: groupTitle(group),
                        lessons: offered(group),
                        stats: stats,
                      ),
                    ),
                if (user.visibleGroups.every((g) => offered(g).isEmpty))
                  const _NothingLeft(),
              ],
            ),
    );
  }
}

/// What is left when the filter has taken everything away.
///
/// Not an empty screen: a child who has just finished the last lesson should
/// read that they finished it, and find the way back in the same breath.
class _NothingLeft extends StatelessWidget {
  const _NothingLeft();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.correctSoft,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.correct, width: 2),
        ),
        child: Column(
          children: [
            const Icon(Icons.emoji_events_outlined,
                size: 64, color: AppColors.correct),
            const SizedBox(height: 12),
            Text(
              'Alles geschafft!',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: AppColors.correct),
            ),
            const SizedBox(height: 6),
            const Text(
              'Was du kannst, ist gerade ausgeblendet. Über den Filter oben '
              'kommt der ganze Katalog zurück.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, color: AppColors.text),
            ),
          ],
        ),
      );
}

/// Bolts a child has collected, counted like the stars: over every lesson of
/// every group they can see, best run once.
int _earnedBolts(List<LessonGroup> groups, Map<String, LessonStat> stats) {
  var total = 0;
  for (final group in groups) {
    for (final lesson in lessonsInGroup(group)) {
      total += stats[lesson.id]?.bestBolts ?? 0;
    }
  }
  return total;
}

/// Stars a child has collected in the groups they can see - each lesson's
/// best run counted once.
///
/// Deliberately over `lessonsInGroup` rather than over what the filter leaves
/// standing: hiding a finished lesson is a way of tidying the list, not of
/// giving its stars back. Only a parent unlocking or locking a group changes
/// what there is to collect.
int _earnedStars(List<LessonGroup> groups, Map<String, LessonStat> stats) {
  var total = 0;
  for (final group in groups) {
    for (final lesson in lessonsInGroup(group)) {
      total += stats[lesson.id]?.bestStars ?? 0;
    }
  }
  return total;
}

int _possibleStars(List<LessonGroup> groups) {
  var lessons = 0;
  for (final group in groups) {
    lessons += lessonsInGroup(group).length;
  }
  return lessons * maxStars;
}

/// One suggestion above the catalogue: with forty lessons on offer, "what
/// now?" is a real question, and the app knows the answer better than a
/// seven-year-old scrolling.
class _RecommendationCard extends ConsumerWidget {
  final Recommendation? recommendation;
  final int userId;

  const _RecommendationCard({
    required this.recommendation,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestion = recommendation;
    if (suggestion == null) return const SizedBox.shrink();

    // The same three levels the start sheet resolves. Deliberately nullable:
    // starting the run with an invented ten while the stored length is still
    // being read would hand out the wrong length.
    final taskCount = ref
        .watch(resolvedTaskCountProvider(
            (userId: userId, lessonId: suggestion.lesson.id)))
        .value;
    // The card is a third door into a run, so it asks the same question the
    // other two ask.
    final gate = ref.watch(practiceGateProvider);
    final ready = gate.mayStart && taskCount != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: !ready
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => PracticeScreen(
                        lesson: suggestion.lesson,
                        taskCount: taskCount,
                      ),
                    ),
                  ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    size: 34, color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.headline,
                        style: const TextStyle(
                          fontSize: 17,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Text(
                        '${suggestion.lesson.title} · '
                        '${groupTitle(suggestion.lesson.group)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                LessonExample(lesson: suggestion.lesson, fontSize: 24),
                const SizedBox(width: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 30),
                  label: const Text('Los'),
                  onPressed: !ready
                      ? null
                      : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => PracticeScreen(
                                lesson: suggestion.lesson,
                                taskCount: taskCount,
                              ),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Deine Aufgaben": the same grid the catalogue groups use, sorted by
/// deadline - the soonest first, and a met one sunk to the end regardless of
/// its own deadline, since "what's next?" is not what a finished card
/// answers any more.
class _AssignmentGroup extends ConsumerWidget {
  final List<Assignment> assignments;

  const _AssignmentGroup({required this.assignments});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();

    // Both watched here, once, so the sort and the tile below draw on the
    // same numbers - asking twice would risk the two disagreeing for a
    // frame.
    final entries = [
      for (final a in assignments)
        (
          assignment: a,
          met: ref.watch(assignmentStatsProvider(a)).value?.current.met ??
              false,
          dueMs: periodAt(a, now).dueMs,
        ),
    ]..sort((x, y) {
        if (x.met != y.met) return x.met ? 1 : -1;
        return x.dueMs.compareTo(y.dueMs);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Deine Aufgaben',
            style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            for (final entry in entries)
              AssignmentTile(assignment: entry.assignment),
          ],
        ),
      ],
    );
  }
}

class _LessonGroup extends StatelessWidget {
  final String title;
  final List<LessonSpec> lessons;
  final Map<String, LessonStat> stats;

  const _LessonGroup({
    required this.title,
    required this.lessons,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.4,
          children: [
            for (final lesson in lessons)
              _LessonTile(lesson: lesson, stat: stats[lesson.id]),
          ],
        ),
      ],
    );
  }
}

class _LessonTile extends StatelessWidget {
  final LessonSpec lesson;
  final LessonStat? stat;

  const _LessonTile({required this.lesson, required this.stat});

  @override
  Widget build(BuildContext context) {
    // Each group in its own pastel, so the catalogue falls into blocks and
    // the seam between two groups is visible before a heading is read.
    return Material(
      color: AppColors.groupTint(lesson.group.index),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => StartLessonSheet.show(context, lesson),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.groupEdge(lesson.group.index),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              // The example scales down on a 10" tablet rather than clipping;
              // three-digit tasks are noticeably wider than two-digit ones.
              Expanded(
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: LessonExample(lesson: lesson),
                  ),
                ),
              ),
              Row(
                children: [
                  // Three stars on every tile - the empty ones show at a
                  // glance what is still untouched.
                  StarRow(
                    earned: stat?.bestStars ?? 0,
                    faded: stat == null,
                    size: 24,
                  ),
                  // Bolts only where time is measured, and only once there
                  // is a time: on an untouched lesson three grey bolts say
                  // nothing the three grey stars have not already said, and
                  // six icons crowd out "noch nicht geübt".
                  if (stat != null && lesson.targetMsPerTask > 0) ...[
                    const SizedBox(width: 4),
                    BoltRow(earned: stat!.bestBolts, size: 24),
                  ],
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      stat == null
                          ? 'noch nicht geübt'
                          : lesson.scored
                              ? formatPerTask(stat!.bestScoreMs)
                              : '${stat!.runs}× geübt',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
