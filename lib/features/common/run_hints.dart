import 'package:flutter/material.dart';

import '../../domain/practice_limit.dart';
import '../../domain/scoring.dart';
import '../../theme/app_theme.dart';

/// Says that a run this short earns nothing.
///
/// Five is the leftmost option, so it is the easy one to tap - and since the
/// minimum came in, a flawless run of five hands back three empty stars with
/// no word of explanation. The rule is fine; being silent about it is not.
class ShortRunHint extends StatelessWidget {
  final int taskCount;

  /// The first steps are not counted at all, so nothing is being withheld
  /// there and there is nothing to explain.
  final bool scored;

  final double fontSize;

  const ShortRunHint({
    super.key,
    required this.taskCount,
    required this.scored,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    if (!scored || taskCount >= minTasksForAward) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Icon(Icons.info_outline, size: fontSize * 1.2,
            color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Unter $minTasksForAward Aufgaben gibt es keine Sterne, keine '
            'Blitze und keinen Eintrag in der Bestenliste - zum Üben ist es '
            'trotzdem gut.',
            style: TextStyle(fontSize: fontSize, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

/// Says how much practice time is left before the next break.
///
/// Shown where the run is chosen, because that is where it changes a
/// decision: fifty tasks with four minutes left is a different plan from
/// fifty tasks with an hour.
class RemainingTimeHint extends StatelessWidget {
  final PracticeAllowance allowance;
  final double fontSize;

  const RemainingTimeHint({
    super.key,
    required this.allowance,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final left = allowance.remainingMinutes;
    if (left == null || !allowance.allowed) return const SizedBox.shrink();

    // Under five minutes the tone changes: that is when it is worth knowing
    // before starting a long run rather than after.
    final soon = left <= 5;
    final color = soon ? AppColors.profile1 : AppColors.textMuted;
    return Row(
      children: [
        Icon(soon ? Icons.hourglass_bottom : Icons.schedule,
            size: fontSize * 1.2, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            switch (left) {
              0 => 'Gleich ist Pause.',
              1 => 'Noch eine Minute, dann ist Pause.',
              _ => 'Noch $left Minuten, dann ist Pause.',
            },
            style: TextStyle(
              fontSize: fontSize,
              color: color,
              fontWeight: soon ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
