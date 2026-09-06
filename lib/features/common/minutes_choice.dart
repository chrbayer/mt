import 'package:flutter/material.dart';

/// Picks a number of minutes, with an optional "same as everyone".
///
/// Used for the app-wide limits and for a single child's, so the two always
/// look and behave the same - the twin of [TaskCountChoice] for times.
class MinutesChoice extends StatelessWidget {
  /// The chosen value, or null when this level inherits.
  final int? value;

  final List<int> options;

  /// What inheriting would currently mean, shown on the inherit chip.
  final int? inherited;

  /// Whether "same as everyone" is an option at all.
  final bool allowInherit;

  /// Null while the stored value is still being read, which disables the row
  /// rather than showing a guess that would then jump.
  final ValueChanged<int?>? onChanged;

  /// Whether zero is offered, and as what. A break of zero makes no sense;
  /// a limit of zero means there is none.
  final String? zeroLabel;

  const MinutesChoice({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.inherited,
    this.allowInherit = false,
    this.zeroLabel = 'ohne Grenze',
  });

  String _label(int minutes) =>
      minutes == 0 ? (zeroLabel ?? '0 min') : '$minutes min';

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (allowInherit)
          ChoiceChip(
            label: Text(
              inherited == null
                  ? 'wie für alle'
                  : 'wie für alle (${_label(inherited!)})',
              style: const TextStyle(fontSize: 18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            selected: value == null,
            onSelected: onChanged == null ? null : (_) => onChanged!(null),
          ),
        for (final minutes in options)
          ChoiceChip(
            label: Text(_label(minutes), style: const TextStyle(fontSize: 18)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            selected: value == minutes,
            onSelected:
                onChanged == null ? null : (_) => onChanged!(minutes),
          ),
      ],
    );
  }
}
