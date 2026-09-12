import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/stats_repository.dart';
import '../../domain/lesson.dart';
import '../../domain/scoring.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/load_failure.dart';
import '../common/star_row.dart';
import '../leaderboard/leaderboard_screen.dart';

/// Everyone at a glance: who practised how much, and how that spread over the
/// last weeks. Reachable from the profile screen without logging in, because
/// comparing is exactly what happens there anyway.
class GlobalStatsScreen extends ConsumerWidget {
  const GlobalStatsScreen({super.key});

  static const activityDays = 30;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alle Ergebnisse'),
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            tabs: [
              Tab(height: 58, text: 'Übersicht'),
              Tab(height: 58, text: 'Bestenlisten'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_OverviewTab(), _LeaderboardsTab()],
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(userSummariesProvider);

    return summaries.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => LoadFailure(detail: error),
      data: (list) => list.isEmpty
          ? const Center(
              child: Text(
                'Noch keine Profile.',
                style: TextStyle(fontSize: 24, color: AppColors.textMuted),
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(32, 12, 32, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 306,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 16),
                      itemBuilder: (context, index) =>
                          _SummaryCard(summary: list[index]),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Geübt in den letzten '
                    '${GlobalStatsScreen.activityDays} Tagen',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Minuten pro Tag, je Kind in seiner Farbe',
                    style: TextStyle(fontSize: 17, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _ActivityChart(users: list)),
                ],
              ),
            ),
    );
  }
}

/// Every lesson that has a ranking, most recently practised first.
///
/// Only lessons anyone has actually played: there are over forty, and a list
/// of empty ones would bury the handful that matter.
class _LeaderboardsTab extends ConsumerWidget {
  const _LeaderboardsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boards = ref.watch(allLeaderboardsProvider);
    final activeUserId = ref.watch(activeUserProvider)?.id;

    return boards.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => LoadFailure(detail: error),
      data: (list) => list.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text(
                  'Noch keine Bestenlisten.\n'
                  'Ein Durchgang zählt ab $minTasksForAward Aufgaben.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: AppColors.textMuted),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _LeaderboardRow(
                board: list[index],
                activeUserId: activeUserId,
              ),
            ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LessonLeaderboard board;
  final int? activeUserId;

  const _LeaderboardRow({required this.board, required this.activeUserId});

  @override
  Widget build(BuildContext context) {
    final lesson = lessonByIdOrNull(board.lessonId);
    // Nothing to open, and nothing sensible to title it with.
    if (lesson == null) return const SizedBox.shrink();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => LeaderboardScreen(lesson: lesson),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider, width: 1.5),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      groupTitle(lesson.group),
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // The podium, enough to see who leads without opening anything.
              for (final entry in board.entries.take(3))
                _PodiumChip(
                  entry: entry,
                  leader: entry == board.entries.first,
                  isActive: entry.userId == activeUserId,
                ),
              if (board.entries.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '+${board.entries.length - 3}',
                    style: const TextStyle(
                      fontSize: 17,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _PodiumChip extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool leader;
  final bool isActive;

  const _PodiumChip({
    required this.entry,
    required this.leader,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.profileColor(entry.colorIndex);
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.12) : Colors.transparent,
        border: Border.all(
          color: isActive ? color : AppColors.divider,
          width: isActive ? 2.5 : 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(entry.avatar, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(
            formatPerTask(entry.scoreMs),
            style: TextStyle(
              fontSize: 19,
              fontWeight: leader ? FontWeight.w700 : FontWeight.w500,
              color: leader ? AppColors.primary : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends ConsumerWidget {
  final UserSummary summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streaksProvider).value?[summary.userId] ?? 0;
    final stars = ref.watch(starTotalsProvider).value?[summary.userId] ?? 0;
    final bolts = ref.watch(boltTotalsProvider).value?[summary.userId] ?? 0;
    final color = AppColors.profileColor(summary.colorIndex);
    final played = summary.runs > 0;

    return Container(
      width: 272,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color, width: 3),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(summary.avatar, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  summary.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!played)
            const Text(
              'Noch nicht geübt.',
              style: TextStyle(fontSize: 19, color: AppColors.textMuted),
            )
          else ...[
            _Line(
              value: '${summary.runs}',
              label: summary.runs == 1 ? 'Runde' : 'Runden',
            ),
            _Line(value: formatTotalTime(summary.totalMs), label: 'geübt'),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // The icons say what they are. Spelling either out as well
                  // does not fit a card that sits beside two others.
                  StarTotal(earned: stars, size: 23),
                  const SizedBox(width: 18),
                  StarTotal(earned: bolts, size: 23, bolts: true),
                ],
              ),
            ),
            _Line(
              value: '${(summary.errors * 100).round()} %',
              label: 'Fehler',
            ),
            const Spacer(),
            if (streak >= 2)
              Text(
                '$streak Tage in Folge',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.profile1,
                ),
              )
            else
              Text(
                'zuletzt ${formatRelativeDay(summary.lastPlayed!)}',
                style:
                    const TextStyle(fontSize: 17, color: AppColors.textMuted),
              ),
          ],
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  final String value;
  final String label;

  const _Line({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            // A long label ("Runden") next to a wide value must not push the
            // row past the card edge.
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 17, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      );
}

/// Stacked bars: one bar per day, one segment per child.
class _ActivityChart extends ConsumerWidget {
  final List<UserSummary> users;

  const _ActivityChart({required this.users});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(activityProvider).value ?? const [];
    if (activity.isEmpty) {
      return const Center(
        child: Text(
          'In den letzten Wochen wurde noch nicht geübt.',
          style: TextStyle(fontSize: 20, color: AppColors.textMuted),
        ),
      );
    }

    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: GlobalStatsScreen.activityDays - 1));

    // day index -> user id -> minutes
    final byDay = <int, Map<int, double>>{};
    for (final point in activity) {
      final index = point.day.difference(start).inDays;
      if (index < 0 || index >= GlobalStatsScreen.activityDays) continue;
      (byDay[index] ??= {})[point.userId] = point.totalMs / 60000;
    }

    var tallest = 0.0;
    for (final day in byDay.values) {
      final sum = day.values.fold<double>(0, (a, b) => a + b);
      if (sum > tallest) tallest = sum;
    }
    final maxY = (tallest * 1.2).ceilToDouble().clamp(5.0, double.infinity);
    // Whole-minute steps, otherwise fl_chart rounds neighbouring labels to the
    // same text and the axis reads "4, 4, 3, 3".
    final step = (maxY / 5).ceilToDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        // spaceAround, not spaceBetween: the latter puts the last bar half
        // outside the plot area.
        alignment: BarChartAlignment.spaceAround,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: step,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.divider, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: step,
              // Plain numbers: the subtitle above already says minutes, and
              // repeating the unit on every tick just adds noise.
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final day = start.add(Duration(days: value.toInt()));
                // Only label Mondays, otherwise 30 labels collide.
                if (day.weekday != DateTime.monday) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${day.day}.${day.month}.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final day = start.add(Duration(days: group.x));
              return BarTooltipItem(
                '${day.day}.${day.month}.\n'
                '${rod.toY.round()} min',
                const TextStyle(color: Colors.white, fontSize: 15),
              );
            },
          ),
        ),
        barGroups: [
          for (var index = 0;
              index < GlobalStatsScreen.activityDays;
              index++)
            BarChartGroupData(
              x: index,
              barRods: [_rodFor(byDay[index] ?? const {})],
            ),
        ],
      ),
    );
  }

  BarChartRodData _rodFor(Map<int, double> minutesByUser) {
    var from = 0.0;
    final stack = <BarChartRodStackItem>[];
    for (final user in users) {
      final minutes = minutesByUser[user.userId] ?? 0;
      if (minutes <= 0) continue;
      stack.add(
        BarChartRodStackItem(
          from,
          from + minutes,
          AppColors.profileColor(user.colorIndex),
        ),
      );
      from += minutes;
    }
    return BarChartRodData(
      toY: from,
      width: 14,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      color: Colors.transparent,
      rodStackItems: stack,
    );
  }
}
