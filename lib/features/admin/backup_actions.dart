import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/repositories/backup_repository.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import 'admin_session.dart';
import '../../l10n/l10n.dart';
import '../../l10n/formatters.dart';

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
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final json = await ref.read(backupRepositoryProvider).export();
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$_fileName');
      await file.writeAsString(json);

      // Held open: sharing sends the app to the background on purpose, and
      // the parent area closing itself for that would cut the share sheet
      // off mid-share.
      final result = await AdminSession.holdOpen(
        () => SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'application/json')],
            fileNameOverrides: [_fileName],
            subject: l10n.backupShareSubject,
          ),
        ),
      );
      // Only once it really went somewhere. A share sheet that was opened
      // and closed again has saved nothing, and a date that lied about it
      // would be worse than no date at all.
      if (result.status == ShareResultStatus.success) {
        await ref.read(settingsRepositoryProvider).setLastBackup(
              DateTime.now().millisecondsSinceEpoch,
            );
      }
    } catch (error) {
      _tell(l10n.backupExportFailed('$error'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.backupImportConfirmTitle),
        content: Text(
          l10n.backupImportConfirmText,
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.wrong),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.backupReplace),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false)) return;

    setState(() => _busy = true);
    try {
      final typeGroup = XTypeGroup(
        label: l10n.backupFileTypeLabel,
        extensions: ['json'],
        mimeTypes: ['application/json'],
      );
      // Held open for the same reason as in _export: picking a file also
      // sends the app to the background.
      final file = await AdminSession.holdOpen(
        () => openFile(acceptedTypeGroups: [typeGroup]),
      );
      if (file == null) return;

      final summary =
          await ref.read(backupRepositoryProvider).import(await file.readAsString());
_tell(l10n.backupImported(summary.users, summary.sessions));
    } on BackupFormatException catch (error) {
      _tell(switch (error.error) {
        BackupError.notABackup => l10n.backupErrorNotABackup,
        BackupError.wrongApp => l10n.backupErrorWrongApp,
        BackupError.tooNew => l10n.backupErrorTooNew,
      });
    } catch (error) {
      _tell(l10n.backupImportFailed('$error'));
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
        Text(context.l10n.backupHeading, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          context.l10n.backupIntro,
          style: const TextStyle(fontSize: 17, color: AppColors.textMuted),
        ),
        const SizedBox(height: 10),
        BackupAgeNotice(
          lastBackupMs: ref.watch(preferencesProvider).value?.lastBackupMs,
          now: ref.watch(clockProvider)(),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.save_alt, size: 26),
              label: Text(context.l10n.backupCreate),
              onPressed: _busy ? null : _export,
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.settings_backup_restore, size: 26),
              label: Text(context.l10n.backupRestore),
              onPressed: _busy ? null : _import,
            ),
          ],
        ),
      ],
    );
  }
}

/// When the last backup was made, and a nudge once it is a while ago.
///
/// Everything this app knows lives on one tablet: no cloud, no second copy.
/// The export has been there all along and nothing ever mentioned it, so the
/// only thing between a year of results and a broken device was a parent who
/// happened to think of it.
class BackupAgeNotice extends StatelessWidget {
  final int? lastBackupMs;
  final DateTime now;

  /// After this long the line turns into a nudge. Four weeks is about a
  /// month of practice - enough to be worth keeping, not so soon that the
  /// warning becomes wallpaper.
  static const int nudgeAfterDays = 28;

  const BackupAgeNotice({
    super.key,
    required this.lastBackupMs,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final last = lastBackupMs;
    final days = last == null
        ? null
        : DateTime(now.year, now.month, now.day)
            .difference(DateTime.fromMillisecondsSinceEpoch(last))
            .inDays;
    final overdue = days == null || days >= nudgeAfterDays;
    final when = last == null
        ? ''
        : formatRelativeDay(context.l10n, 
            DateTime.fromMillisecondsSinceEpoch(last),
            now: now,
          );

    return Row(
      children: [
        Icon(
          overdue ? Icons.warning_amber_rounded : Icons.check_circle_outline,
          size: 22,
          color: overdue ? AppColors.profile1 : AppColors.correct,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            last == null
                ? context.l10n.backupNever
                : overdue
                    ? context.l10n.backupLastOverdue(when)
                    : context.l10n.backupLast(when),
            style: TextStyle(
              fontSize: 17,
              color: overdue ? AppColors.profile1 : AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
