import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/stats_repository.dart';
import '../../domain/lesson.dart';
import '../../domain/scoring.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../../data/repositories/user_repository.dart';
import '../common/star_row.dart';
import '../profiles/profile_editor.dart';
import 'backup_actions.dart';
import 'profile_settings_dialog.dart';
import 'pin_gate.dart';

/// The parent area behind the PIN: what was practised when and how well, plus
/// the operations a child should not be able to trigger - renaming, deleting
/// and wiping results.
class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  /// Opens the parent area, asking for the PIN first.
  static Future<void> open(BuildContext context) async {
    final navigator = Navigator.of(context);
    if (!await requireAdminPin(context)) return;
    await navigator.push(
      MaterialPageRoute<void>(builder: (_) => const AdminScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Elternbereich'),
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            tabs: [
              Tab(height: 58, text: 'Übungsverlauf'),
              Tab(height: 58, text: 'Verwaltung'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_HistoryTab(), _ManagementTab()],
        ),
      ),
    );
  }
}

class _HistoryTab extends ConsumerStatefulWidget {
  const _HistoryTab();

  @override
  ConsumerState<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends ConsumerState<_HistoryTab> {
  int? _filter;

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider).value ?? const <User>[];
    final history = ref.watch(historyProvider(_filter));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Alle', style: TextStyle(fontSize: 19)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                selected: _filter == null,
                onSelected: (_) => setState(() => _filter = null),
              ),
              for (final user in users)
                ChoiceChip(
                  label: Text(
                    '${user.avatar}  ${user.name}',
                    style: const TextStyle(fontSize: 19),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  selected: _filter == user.id,
                  onSelected: (_) => setState(() => _filter = user.id),
                ),
            ],
          ),
        ),
        Expanded(
          child: history.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Fehler: $error')),
            data: (entries) => entries.isEmpty
                ? const Center(
                    child: Text(
                      'Noch keine Durchgänge.',
                      style:
                          TextStyle(fontSize: 22, color: AppColors.textMuted),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) => _HistoryRow(
                      entry: entries[index],
                      onDelete: () => _confirmDelete(entries[index]),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(HistoryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Diesen Durchgang löschen?'),
        content: Text(
          '${entry.userName} · '
          '${lessonByIdOrNull(entry.lessonId)?.title ?? entry.lessonId} · '
          '${formatDayAndTime(entry.playedAt)}',
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.wrong),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ref.read(statsRepositoryProvider).deleteSession(entry.sessionId);
    }
  }
}

class _HistoryRow extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onDelete;

  const _HistoryRow({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.profileColor(entry.colorIndex);
    // A run can outlive its lesson - an older backup, a dropped lesson. The
    // log has to survive that rather than take the parent area down.
    final lesson = lessonByIdOrNull(entry.lessonId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              formatDayAndTime(entry.playedAt),
              style: const TextStyle(fontSize: 17, color: AppColors.textMuted),
            ),
          ),
          Text(entry.avatar, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              entry.userName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          Expanded(
            child: Text(
              lesson == null
                  ? entry.lessonId
                  : '${lesson.title}  ·  '
                      '${groupTitle(lesson.group).toLowerCase()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 19),
            ),
          ),
          if (entry.completed) ...[
            _Cell('${entry.taskCount}', 'Aufgaben'),
            _Cell(formatPerTask(entry.msPerTask), 'pro Aufgabe'),
            _Cell('${entry.wrongAttempts}', 'Fehler'),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: StarRow(
                earned: starsFor(entry.wrongAttempts, entry.taskCount,
                    scored: true),
                size: 20,
              ),
            ),
          ] else
            SizedBox(
              width: 330,
              child: Text(
                'abgebrochen nach ${entry.taskCount} '
                '${entry.taskCount == 1 ? 'Aufgabe' : 'Aufgaben'}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          IconButton(
            tooltip: 'Durchgang löschen',
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String value;
  final String label;

  const _Cell(this.value, this.label);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
            ),
          ],
        ),
      );
}

class _ManagementTab extends ConsumerWidget {
  const _ManagementTab();

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String message,
    required Future<void> Function() action,
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
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) await action();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(usersProvider).value ?? const <User>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 32),
      children: [
        Row(
          children: [
            Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.person_add_alt, size: 28),
              label: const Text('Neues Profil'),
              onPressed: () => ProfileEditorDialog.show(context),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Namen vergeben, Profile löschen und festlegen, welche Bereiche ein '
          'Kind überhaupt sieht. Bild und Farbe darf jedes Kind selbst auf '
          'dem Startbildschirm ändern.',
          style: TextStyle(fontSize: 17, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        for (final user in users)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ManagementRow(
              user: user,
              onGroups: () => ProfileSettingsDialog.show(context, user),
              onRename: () =>
                  ProfileEditorDialog.show(context, user: user),
              onReset: () => _confirm(
                context,
                ref,
                title: 'Ergebnisse von ${user.name} löschen?',
                message: 'Bestzeiten, Lernkurve und Verlauf gehen verloren. '
                    'Das Profil selbst bleibt bestehen.',
                action: () =>
                    ref.read(userRepositoryProvider).resetStatistics(user.id),
              ),
              onDelete: () => _confirm(
                context,
                ref,
                title: '${user.name} löschen?',
                message: 'Profil und alle Ergebnisse werden entfernt.',
                action: () =>
                    ref.read(userRepositoryProvider).deleteUser(user.id),
              ),
            ),
          ),
        const Divider(height: 48),
        const BackupActions(),
        const Divider(height: 48),
        Text('PIN', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 4),
        const Text(
          'Schützt diesen Bereich. Vergessen? Dann hilft nur, die App-Daten '
          'in den Android-Einstellungen zu löschen - damit sind aber auch '
          'alle Ergebnisse weg.',
          style: TextStyle(fontSize: 17, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          icon: const Icon(Icons.password, size: 26),
          label: const Text('PIN ändern'),
          onPressed: () async {
            await ref.read(settingsRepositoryProvider).clearAdminPin();
            if (context.mounted) await requireAdminPin(context);
          },
        ),
      ],
    );
  }
}

class _ManagementRow extends StatelessWidget {
  final User user;
  final VoidCallback onGroups;
  final VoidCallback onRename;
  final VoidCallback onReset;
  final VoidCallback onDelete;

  const _ManagementRow({
    required this.user,
    required this.onGroups,
    required this.onRename,
    required this.onReset,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.profileColor(user.colorIndex);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.divider, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(user.avatar, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  _groupSummary(user),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Wrapped, not a plain row: four labelled buttons are 6 px too wide
          // on a 10" tablet, and a fifth one would break it again.
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 4,
            children: [
              TextButton.icon(
                icon: const Icon(Icons.tune, size: 24),
                label: const Text('Einstellungen',
                    style: TextStyle(fontSize: 18)),
                onPressed: onGroups,
              ),
              TextButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 24),
                label:
                    const Text('Umbenennen', style: TextStyle(fontSize: 18)),
                onPressed: onRename,
              ),
              TextButton.icon(
                icon: const Icon(Icons.restart_alt, size: 24),
                label: const Text('Zurücksetzen',
                    style: TextStyle(fontSize: 18)),
                onPressed: onReset,
              ),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: AppColors.wrong),
                icon: const Icon(Icons.delete_outline, size: 24),
                label: const Text('Löschen', style: TextStyle(fontSize: 18)),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// What this child is offered, at a glance.
  static String _groupSummary(User user) {
    final visible = user.visibleGroups;
    final review = user.reviewHardTasks ? '' : ' · ohne Wiederholung';
    if (visible.isEmpty) return 'Kein Bereich freigeschaltet$review';
    if (visible.length == LessonGroup.values.length) {
      return 'Alle Bereiche$review';
    }
    return '${visible.map(groupTitle).join(', ')}$review';
  }
}
