import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Asks before something that cannot be taken back.
///
/// One implementation rather than one per caller: the parent area asks this
/// question about half a dozen different things, and they should all look
/// and read the same. [confirmLabel] names the deed rather than saying "OK" -
/// "Löschen" on the button is the last chance to notice what is about to
/// happen.
Future<bool> confirmDestructive(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Löschen',
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message, style: const TextStyle(fontSize: 20)),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.wrong),
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
