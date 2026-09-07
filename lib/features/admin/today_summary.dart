import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../domain/practice_limit.dart';
import '../../domain/scoring.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';

/// Who has practised how much today, at a glance.
///
/// The first question a parent opens this area with, and until now it took
/// reading the whole history to answer it.
///
/// Counted the way the daily cap counts - abandoned runs included - so that
/// this line and the child's own "noch 5 Minuten" can never disagree.
class TodaySummary extends ConsumerWidget {
  const TodaySummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider).value ?? const <User>[];
    if (users.isEmpty) return const SizedBox.shrink();

    final today = ref.watch(practisedTodayProvider).value;
    final global = ref.watch(preferencesProvider).value?.limits;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
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
              const Icon(Icons.today_outlined,
                  size: 24, color: AppColors.textMuted),
              const SizedBox(width: 10),
              Text('Heute geübt',
                  style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 24,
            runSpacing: 10,
            children: [
              for (final user in users)
                _Entry(
                  user: user,
                  // Null while it loads: a made-up zero would read as "has
                  // not practised", which is a statement, not a placeholder.
                  milliseconds: today?[user.id] ?? (today == null ? null : 0),
                  dailyLimitMinutes: global == null
                      ? null
                      : resolvePracticeLimits(
                          global: global,
                          dailyMinutes: user.dailyLimitMinutes,
                        ).dailyMinutes,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  final User user;
  final int? milliseconds;

  /// The cap in force for this child, or zero when there is none.
  final int? dailyLimitMinutes;

  const _Entry({
    required this.user,
    required this.milliseconds,
    required this.dailyLimitMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.profileColor(user.colorIndex);
    final ms = milliseconds;
    final minutes = ms == null ? null : ms ~/ 60000;
    final limit = dailyLimitMinutes ?? 0;
    // Used up means the child is locked out for the day; a parent looking at
    // this list should see that without doing the arithmetic.
    final done = minutes != null && limit > 0 && minutes >= limit;

    return SizedBox(
      width: 220,
      child: Row(
        children: [
          Text(user.avatar, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  switch ((ms, limit)) {
                    (null, _) => '…',
                    (final value?, 0) when value < 60000 => 'noch nichts',
                    (final value?, 0) => formatTotalTime(value),
                    (final value?, _) when value < 60000 =>
                      'noch nichts von $limit min',
                    (final value?, _) =>
                      '${formatTotalTime(value)} von $limit min',
                  },
                  style: TextStyle(
                    fontSize: 17,
                    color: done ? AppColors.profile1 : AppColors.textMuted,
                    fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
