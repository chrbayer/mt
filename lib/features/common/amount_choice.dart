import 'package:flutter/material.dart';
import '../../l10n/l10n.dart';

/// Picks one number out of a few, with an optional "same as everyone".
///
/// Used for the app-wide limits and for a single child's, so the two always
/// look and behave the same - the twin of [TaskCountChoice]. It started out
/// as a minute picker and stayed generic when the daily cap on scored runs
/// needed exactly the same two levels with a different unit.
class AmountChoice extends StatelessWidget {
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

  /// Whether zero reads as "no limit" when [zeroLabel] is not given.
  final bool zeroIsNoLimit;

  /// How a value reads. Minutes by default, because that is what most of
  /// these rows are.
  final String Function(int)? labelFor;

  const AmountChoice({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.inherited,
    this.allowInherit = false,
    this.zeroLabel,
    this.zeroIsNoLimit = true,
    this.labelFor,
  });

  String _label(BuildContext context, int value) => value == 0
      ? (zeroLabel ??
          (zeroIsNoLimit
              ? context.l10n.amountNoLimit
              : (labelFor?.call(0) ?? context.l10n.commonMinutesShort(0))))
      : (labelFor?.call(value) ?? context.l10n.commonMinutesShort(value));

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
                  ? context.l10n.amountSameAsAll
                  : context.l10n
                      .amountSameAsAllWith(_label(context, inherited!)),
              style: const TextStyle(fontSize: 18),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            selected: value == null,
            onSelected: onChanged == null ? null : (_) => onChanged!(null),
          ),
        for (final minutes in options)
          ChoiceChip(
            label: Text(_label(context, minutes), style: const TextStyle(fontSize: 18)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            selected: value == minutes,
            onSelected:
                onChanged == null ? null : (_) => onChanged!(minutes),
          ),
      ],
    );
  }
}
