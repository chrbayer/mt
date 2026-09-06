import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

/// The app's own number pad. The system keyboard is never used during
/// practice: it is small, it hides half the screen, and it offers a child
/// plenty of ways to leave the app by accident.
class BigKeypad extends StatelessWidget {
  final ValueChanged<int> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final bool enabled;
  final bool haptics;

  /// Minimum edge length of a key. Keys grow to fill the available space.
  static const double minKeySize = 96;

  const BigKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onSubmit,
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
    Widget digit(int value) => KeypadKey(
          key: Key('digit-$value'),
          onTap: () => _tap(() => onDigit(value)),
          enabled: enabled,
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        );

    return Column(
      children: [
        for (final row in const [
          [1, 2, 3],
          [4, 5, 6],
          [7, 8, 9],
        ])
          Expanded(
            child: Row(
              children: [
                for (final value in row)
                  Expanded(child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: digit(value),
                  )),
              ],
            ),
          ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: KeypadKey(
                    key: const Key('backspace'),
                    onTap: () => _tap(onBackspace),
                    enabled: enabled,
                    background: AppColors.background,
                    child: const Icon(
                      Icons.backspace_outlined,
                      size: 38,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: digit(0),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: KeypadKey(
                    key: const Key('submit'),
                    onTap: () => _tap(onSubmit, strong: true),
                    enabled: enabled,
                    background: AppColors.correct,
                    child: const Icon(Icons.check, size: 52, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One key of a practice keypad. Shared with the word and money pads so all
/// three feel like the same keyboard.
class KeypadKey extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final bool enabled;
  final Color background;

  const KeypadKey({
    super.key,
    required this.onTap,
    required this.child,
    required this.enabled,
    this.background = AppColors.surface,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: BigKeypad.minKeySize,
          minHeight: BigKeypad.minKeySize,
        ),
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(20),
          elevation: 0,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.divider, width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
