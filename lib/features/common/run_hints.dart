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
    // Nothing is being withheld in the first steps, so nothing to say.
    if (!scored || taskCount >= minTasksForAward) {
      return const SizedBox.shrink();
    }

    // The warm accent, the same one the chip wears: choosing five is a
    // legitimate way to practise, not a mistake, so not the red one.
    return Row(
      children: [
        Icon(Icons.info_outline,
            size: fontSize * 1.2, color: AppColors.profile1),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Zählt nicht: keine Sterne, keine Blitze, keine Bestenliste.',
            style: TextStyle(fontSize: fontSize, color: AppColors.profile1),
          ),
        ),
      ],
    );
  }
}

/// Says that this lesson has used up its scoring for today.
///
/// The lesson can still be practised - that is the point, and the button
/// stays live. What it no longer does is set a best time or hand out stars
/// and bolts, and a rule that quietly stops counting is exactly the kind of
/// thing that has to be said out loud.
class UsedUpTodayHint extends StatelessWidget {
  /// How often this lesson counted today. Named rather than implied: "schon
  /// 3-mal" is a different sentence from "du darfst nicht mehr".
  final int scoredToday;

  final double fontSize;

  const UsedUpTodayHint({
    super.key,
    required this.scoredToday,
    this.fontSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline,
            size: fontSize * 1.2, color: AppColors.profile1),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Heute schon $scoredToday× gewertet - üben geht weiter, '
            'zählen nicht mehr.',
            style: TextStyle(fontSize: fontSize, color: AppColors.profile1),
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
