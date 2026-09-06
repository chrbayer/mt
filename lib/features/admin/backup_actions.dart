import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories/backup_repository.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';

/// Save and restore the whole database.
///
/// Everything lives in one file on one tablet; a factory reset would take
/// months of results with it. Export goes through the Android share sheet
/// rather than a save dialog - that way the backup can land in Drive or an
/// e-mail, off the device, which is the only place a backup helps.
class BackupActions extends ConsumerStatefulWidget {
  const BackupActions({super.key});

  @override
  ConsumerState<BackupActions> createState() => _BackupActionsState();
}

class _BackupActionsState extends ConsumerState<BackupActions> {
  bool _busy = false;

  String get _fileName {
    final now = DateTime.now();
    String two(int value) => value.toString().padLeft(2, '0');
    return 'mathe-trainer-${now.year}-${two(now.month)}-${two(now.day)}.json';
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final json = await ref.read(backupRepositoryProvider).export();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$_fileName');
      await file.writeAsString(json);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/json')],
          fileNameOverrides: [_fileName],
          subject: 'Mathe-Trainer Sicherung',
        ),
      );
    } catch (error) {
      _tell('Sicherung fehlgeschlagen: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sicherung einspielen?'),
        content: const Text(
          'Alle Profile und Ergebnisse auf diesem Gerät werden durch die '
          'Sicherung ersetzt. Was jetzt hier steht, ist danach weg.',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.wrong),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ersetzen'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;

    setState(() => _busy = true);
    try {
      const typeGroup = XTypeGroup(
        label: 'Sicherung',
        extensions: ['json'],
        mimeTypes: ['application/json'],
      );
      final file = await openFile(acceptedTypeGroups: const [typeGroup]);
      if (file == null) return;

      final summary =
          await ref.read(backupRepositoryProvider).import(await file.readAsString());
      _tell(
        '${summary.users} Profile und ${summary.sessions} Durchgänge '
        'eingespielt.',
      );
    } on BackupFormatException catch (error) {
      _tell(error.message);
    } catch (error) {
      _tell('Einspielen fehlgeschlagen: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _tell(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 19)),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daten', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        const Text(
          'Alle Profile, Ergebnisse und Einstellungen als Datei. Bewahre sie '
          'außerhalb des Tablets auf - ein zurückgesetztes Gerät nimmt sonst '
          'alles mit.',
          style: TextStyle(fontSize: 17, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.save_alt, size: 26),
              label: const Text('Sicherung erstellen'),
              onPressed: _busy ? null : _export,
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.settings_backup_restore, size: 26),
              label: const Text('Sicherung einspielen'),
              onPressed: _busy ? null : _import,
            ),
          ],
        ),
      ],
    );
  }
}
