import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/stats_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/lesson.dart';
import '../../domain/practice_limit.dart';
import '../../domain/scoring.dart';
import '../../domain/task_count.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/star_row.dart';
import '../practice/practice_screen.dart';
import '../profiles/profile_badge.dart';
import '../settings/settings_screen.dart';
import '../stats/stats_screen.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ProfileBadge(user: user, size: 28),
            const SizedBox(width: 24),
            // The running total, right where the child looks anyway.
            StarTotal(
              earned: _earnedStars(user.visibleGroups, stats),
              possible: _possibleStars(user.visibleGroups),
              size: 24,
            ),
          ],
        ),
        actions: [
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
                // Above the recommendation, so the break is the first thing
                // read - suggesting a lesson that cannot be started would be
                // a small cruelty.
                if (!allowance.allowed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PauseNotice(allowance: allowance, compact: true),
                  ),
                _RecommendationCard(
                  recommendation: recommendLesson(
                    candidates: [
                      for (final group in user.visibleGroups)
                        ...lessonsInGroup(group),
                    ],
                    stats: stats,
                  ),
                  userId: user.id,
                ),
                for (final group in user.visibleGroups)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: _LessonGroup(
                      title: groupTitle(group),
                      lessons: lessonsInGroup(group),
                      stats: stats,
                    ),
                  ),
              ],
            ),
    );
  }
}

/// Stars a child has collected in the groups they can see - each lesson's
/// best run counted once.
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

    // The same three levels the start sheet resolves.
    final taskCount = ref
            .watch(resolvedTaskCountProvider(
                (userId: userId, lessonId: suggestion.lesson.id)))
            .value ??
        fallbackTaskCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(
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
                  onPressed: () => Navigator.of(context).push(
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
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => StartLessonSheet.show(context, lesson),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider, width: 1.5),
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
