import 'package:flutter/material.dart';

import '../../domain/lesson.dart';
import '../../theme/app_theme.dart';

/// Picks how long a run should be, with an optional "same as everyone".
///
/// Used for the app-wide default and for a single child's, so the two always
/// look and behave the same.
class TaskCountChoice extends StatelessWidget {
  /// The chosen count, or null when this level inherits.
  final int? value;

  /// What inheriting would currently mean, shown on the inherit chip.
  final int? inherited;

  /// Whether "same as everyone" is an option at all.
  final bool allowInherit;

  /// Null while the stored value is still being read, which disables the row
  /// rather than showing a guess that would then jump.
  final ValueChanged<int?>? onChanged;

  const TaskCountChoice({
    super.key,
    required this.value,
    required this.onChanged,
    this.inherited,
    this.allowInherit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (allowInherit)
          ChoiceChip(
            label: Text(
              inherited == null ? 'wie überall' : 'wie überall ($inherited)',
              style: const TextStyle(fontSize: 20),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            selected: value == null,
            onSelected: onChanged == null ? null : (_) => onChanged!(null),
          ),
        for (final option in selectableTaskCounts)
          ChoiceChip(
            label: Text('$option', style: const TextStyle(fontSize: 20)),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            selected: value == option,
            onSelected: onChanged == null ? null : (_) => onChanged!(option),
          ),
      ],
    );
  }
}

/// Explains the four levels, worded for the level it is shown at.
///
/// "Sonst diese hier" has to point at the right dial, and which dial that is
/// depends on the screen - the app-wide default or one child's. A running
/// assignment always wins over all of it - there the length is not a choice,
/// it is the goal (#24).
class TaskCountExplanation extends StatelessWidget {
  /// True where a single profile's default is being set.
  final bool forProfile;

  const TaskCountExplanation({super.key, this.forProfile = false});

  @override
  Widget build(BuildContext context) => Text(
        forProfile
            ? 'Es gilt jeweils das Genaueste: eine offene Aufgabe zuerst, '
                'sonst was zuletzt bei einer Lektion gewählt wurde, sonst '
                'diese hier, sonst die Vorgabe für alle.'
            : 'Es gilt jeweils das Genaueste: eine offene Aufgabe zuerst, '
                'sonst was zuletzt bei einer Lektion gewählt wurde, sonst '
                'die Vorgabe des Profils, sonst diese hier.',
        style: const TextStyle(fontSize: 17, color: AppColors.textMuted),
      );
}
