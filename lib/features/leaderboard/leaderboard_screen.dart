import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/stats_repository.dart';
import '../../domain/lesson.dart';
import '../../domain/scoring.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/load_failure.dart';

/// Ranking of all profiles in one lesson - this is how the children compete.
class LeaderboardScreen extends ConsumerWidget {
  final LessonSpec lesson;

  const LeaderboardScreen({super.key, required this.lesson});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(leaderboardProvider(lesson.id));
    final activeUserId = ref.watch(activeUserProvider)?.id;

    return Scaffold(
      appBar: AppBar(title: Text('Bestenliste · ${lesson.title}')),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const LoadFailure(),
        data: (list) => list.isEmpty
            ? const Center(
                child: Text(
                  'Noch keine Ergebnisse.\nMindestens '
                  '$minTasksForAward Aufgaben zählen für die Bestenliste.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: AppColors.textMuted),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(40, 16, 40, 32),
                itemCount: list.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == list.length) return const _ScoreExplanation();
                  return _Row(
                    rank: index + 1,
                    entry: list[index],
                    isActive: list[index].userId == activeUserId,
                  );
                },
              ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;
  final bool isActive;

  const _Row({
    required this.rank,
    required this.entry,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.profileColor(entry.colorIndex);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.10) : AppColors.surface,
        border: Border.all(
          color: isActive ? color : AppColors.divider,
          width: isActive ? 3 : 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              '$rank.',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            ),
          ),
          Text(entry.avatar, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              entry.name,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          _Cell(
            value: formatPerTask(entry.scoreMs),
            label: 'pro Aufgabe',
            strong: true,
          ),
          _Cell(
            value: '${(entry.errorRate * 100).round()} %',
            label: 'Fehler',
          ),
          _Cell(value: '${entry.taskCount}', label: 'Aufgaben'),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String value;
  final String label;
  final bool strong;

  const _Cell({required this.value, required this.label, this.strong = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: strong ? 30 : 24,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              color: strong ? AppColors.primary : AppColors.text,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 15, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ScoreExplanation extends StatelessWidget {
  const _ScoreExplanation();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 12),
      child: Text(
        'Gewertet wird die Zeit pro Aufgabe, plus 3 Sekunden für jeden '
        'Fehlversuch. Deshalb lohnt sich Raten nicht, und Durchgänge mit '
        'unterschiedlich vielen Aufgaben bleiben vergleichbar.',
        style: TextStyle(fontSize: 17, color: AppColors.textMuted),
      ),
    );
  }
}
