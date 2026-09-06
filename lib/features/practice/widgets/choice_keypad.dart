import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';
import 'big_keypad.dart';

/// A keypad whose keys are words instead of digits.
///
/// Some answers are not numbers. "Viertel vor" is a thing a child says, not
/// something to spell on a number pad, and a coin is a thing to hand over.
/// Both keep the layout of [BigKeypad] - three columns, four rows, the green
/// key bottom right - so the pad still feels like the same keyboard.
class ChoiceKeypad extends StatelessWidget {
  final List<String> labels;

  /// Which label is currently chosen, if any. Marked so a child can see what
  /// they tapped without hunting for it in the answer box.
  final int? selected;

  final ValueChanged<int> onChoice;

  /// Only the money pad has one: a pile is taken apart piece by piece. The
  /// word pad has nothing to delete, because tapping again replaces.
  final VoidCallback? onBackspace;

  final VoidCallback onSubmit;
  final bool enabled;
  final bool haptics;

  static const int columns = 3;

  const ChoiceKeypad({
    super.key,
    required this.labels,
    required this.onChoice,
    required this.onSubmit,
    this.selected,
    this.onBackspace,
    this.enabled = true,
    this.haptics = true,
  });

  void _tap(VoidCallback action, {bool strong = false}) {
    if (!enabled) return;
    if (haptics) {
      strong ? HapticFeedback.mediumImpact() : HapticFeedback.selectionClick();
    }
    action();
  }

  @override
  Widget build(BuildContext context) {
    final cells = <Widget?>[
      for (final (index, label) in labels.indexed)
        KeypadKey(
          key: Key('choice-$index'),
          onTap: () => _tap(() => onChoice(index)),
          enabled: enabled,
          background:
              index == selected ? AppColors.primary : AppColors.surface,
          // Long words get small rather than clipped: "5 nach halb" has to
          // fit the same key as "halb".
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: index == selected ? Colors.white : AppColors.text,
                ),
              ),
            ),
          ),
        ),
      if (onBackspace != null) ...[
        KeypadKey(
          key: const Key('backspace'),
          onTap: () => _tap(onBackspace!),
          enabled: enabled,
          background: AppColors.background,
          child: const Icon(
            Icons.backspace_outlined,
            size: 38,
            color: AppColors.textMuted,
          ),
        ),
        null,
      ],
      KeypadKey(
        key: const Key('submit'),
        onTap: () => _tap(onSubmit, strong: true),
        enabled: enabled,
        background: AppColors.correct,
        child: const Icon(Icons.check, size: 52, color: Colors.white),
      ),
    ];

    // Pad out to whole rows so the last row lines up with the ones above it
    // instead of stretching two keys across the width.
    while (cells.length % columns != 0) {
      cells.insert(cells.length - 1, null);
    }

    return Column(
      children: [
        for (var start = 0; start < cells.length; start += columns)
          Expanded(
            child: Row(
              children: [
                for (final cell in cells.sublist(start, start + columns))
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: cell ?? const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
