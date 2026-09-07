import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/lesson.dart';
import '../../domain/scoring.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/star_row.dart';

/// Hands the stars of one group back so a child can earn them again.
///
/// Separate from the other profile settings because it is the only thing in
/// there that takes something away, and because it needs room: one line per
/// group, with what is standing there right now.
class ResetStarsDialog extends ConsumerWidget {
  final User user;

  const ResetStarsDialog({super.key, required this.user});

  static Future<void> show(BuildContext context, User user) => showDialog<void>(
        context: context,
        builder: (_) => ResetStarsDialog(user: user),
      );

  Future<void> _reset(
    BuildContext context,
    WidgetRef ref,
    LessonGroup group,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Sterne in „${groupTitle(group)}" zurücksetzen?'),
        content: Text(
          '${user.name} kann sie danach neu verdienen. Bestzeiten, Blitze, '
          'Lernkurve und Bestenlisten bleiben unverändert - es geht nur um '
          'die Sterne dieser Gruppe.',
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(statsRepositoryProvider).resetStarsInGroup(user.id, group);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(lessonStatsProvider(user.id)).value ?? const {};
    final color = AppColors.profileColor(user.colorIndex);

    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(user.avatar, style: const TextStyle(fontSize: 34)),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Sterne von ${user.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Zurückgesetzt werden nur die Sterne. Die Zeiten bleiben - '
                'Bestzeiten, Blitze, Lernkurve und Bestenlisten sind danach '
                'genau wie vorher.',
                style: TextStyle(fontSize: 17, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              // Only the groups this child is offered: resetting something
              // they cannot even see would be a puzzle later.
              for (final group in user.visibleGroups)
                _GroupRow(
                  group: group,
                  earned: _starsIn(group, stats),
                  onReset: () => _reset(context, ref, group),
                ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fertig'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stars standing in one group, counted the way the catalogue counts them.
int _starsIn(LessonGroup group, Map<String, dynamic> stats) {
  var total = 0;
  for (final lesson in lessonsInGroup(group)) {
    total += (stats[lesson.id]?.bestStars ?? 0) as int;
  }
  return total;
}

class _GroupRow extends StatelessWidget {
  final LessonGroup group;
  final int earned;
  final VoidCallback onReset;

  const _GroupRow({
    required this.group,
    required this.earned,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final possible = lessonsInGroup(group).length * maxStars;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(groupTitle(group), style: const TextStyle(fontSize: 20)),
                Text(
                  '$earned von $possible Sternen',
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          StarTotal(earned: earned, size: 20),
          const SizedBox(width: 12),
          // Nothing to hand back when there is nothing there.
          OutlinedButton(
            onPressed: earned == 0 ? null : onReset,
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );
  }
}
