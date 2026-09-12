import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/stats_repository.dart';
import '../../domain/history_range.dart';
import '../../domain/lesson.dart';
import '../../domain/scoring.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/load_failure.dart';
import '../../data/repositories/user_repository.dart';
import '../common/star_row.dart';
import '../profiles/profile_editor.dart';
import 'assignments_tab.dart';
import 'backup_actions.dart';
import 'global_settings_tab.dart';
import 'pin_gate.dart';
import 'profile_settings_screen.dart';
import 'today_summary.dart';

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
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Elternbereich'),
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            tabs: [
              Tab(height: 58, text: 'Übungsverlauf'),
              Tab(height: 58, text: 'Verwaltung'),
              Tab(height: 58, text: 'Aufgaben'),
              Tab(height: 58, text: 'Einstellungen'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _HistoryTab(),
            _ManagementTab(),
            AssignmentsTab(),
            GlobalSettingsTab(),
          ],
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
  HistoryRange _range = HistoryRange.all;

  /// Whether runs a parent has taken out of the record are shown as well.
  /// They were only ever marked, so this is a matter of looking rather than
  /// of digging anything up.
  bool _showDeleted = false;

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider).value ?? const <User>[];
    final key = (userId: _filter, range: _range, deleted: _showDeleted);
    final history = ref.watch(historyProvider(key));

    // Its own query, not a count of the rows on screen: the list stops at
    // two hundred, and a button that removes more than it promises is the
    // very thing these filters exist to prevent.
    final abandoned = ref.watch(abandonedCountProvider(key)).value ?? 0;
    // A long history is cut off. Saying so beats letting a parent believe
    // they have seen all of it.
    final truncated = (history.value?.length ?? 0) >= historyLimit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Above the filter and the list: "who has done how much today" is
        // the question this area is opened with, and reading the whole
        // history to answer it was the wrong way round.
        const Padding(
          padding: EdgeInsets.fromLTRB(32, 16, 32, 4),
          child: TodaySummary(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 12, 32, 8),
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
        // A second row rather than one long one: who and when are two
        // different questions, and mixed into a single row of chips it would
        // not be clear that they narrow the list independently.
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 8),
          child: Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (final range in HistoryRange.values)
                ChoiceChip(
                  label: Text(historyRangeTitle(range),
                      style: const TextStyle(fontSize: 19)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  selected: _range == range,
                  onSelected: (_) => setState(() => _range = range),
                ),
              const SizedBox(width: 12),
              // Nothing is ever erased, so a deleted run is only out of
              // sight - and getting it back should not depend on still
              // having the moment it went on screen.
              FilterChip(
                avatar: Icon(
                  _showDeleted ? Icons.visibility : Icons.visibility_off,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                label:
                    const Text('Gelöschte', style: TextStyle(fontSize: 19)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                selected: _showDeleted,
                onSelected: (on) => setState(() => _showDeleted = on),
              ),
            ],
          ),
        ),
        if (truncated)
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 8),
            child: Text(
              'Es werden die letzten $historyLimit Durchgänge angezeigt. '
              'Ein kürzerer Zeitraum zeigt den Rest.',
              style: TextStyle(fontSize: 16, color: AppColors.textMuted),
            ),
          ),
        // Only ever what the filter above shows. Tidying up the list one is
        // looking at is a different act from tidying up every child's list
        // at once, and a button that silently did the second would be a trap.
        if (abandoned > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 0, 32, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.cleaning_services_outlined, size: 22),
                // The count comes from the list on screen, so the button
                // and what it removes are the same rows. What exactly that
                // covers is spelled out in the question, not squeezed into
                // the label.
                label: Text(
                  _filter == null
                      ? 'Abgebrochene Durchgänge aufräumen ($abandoned)'
                      : 'Abgebrochene von ${_filterName(users)} aufräumen '
                          '($abandoned)',
                  style: const TextStyle(fontSize: 18),
                ),
                onPressed: () => _confirmCleanup(abandoned, users),
              ),
            ),
          ),
        Expanded(
          child: history.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => LoadFailure(detail: error),
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
                      onRestore: () => ref
                          .read(statsRepositoryProvider)
                          .restoreSessions([entries[index].sessionId]),
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
      _offerUndo('Durchgang gelöscht.', [entry.sessionId]);
    }
  }

  /// Nothing is ever erased - `deleted` is a mark - so undoing it costs one
  /// line. Without a way back a slip in here was final, and the row that
  /// went was somebody's afternoon.
  void _offerUndo(String what, List<int> ids) {
    if (!mounted || ids.isEmpty) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(what, style: const TextStyle(fontSize: 18)),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: 'Rückgängig',
            onPressed: () =>
                ref.read(statsRepositoryProvider).restoreSessions(ids),
          ),
        ),
      );
  }

  String _filterName(List<User> users) =>
      users.where((u) => u.id == _filter).firstOrNull?.name ?? 'diesem Kind';

  Future<void> _confirmCleanup(int count, List<User> users) async {
    // Says exactly what is about to go: whose runs, and from which stretch
    // of time. The list is filtered two ways now, and a question that named
    // neither would be asking about something else than the button removes.
    final whose =
        _filter == null ? 'von allen Kindern' : 'von ${_filterName(users)}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          count == 1
              ? 'Einen abgebrochenen Durchgang aufräumen?'
              : '$count abgebrochene Durchgänge aufräumen?',
        ),
        content: Text(
          'Es verschwinden die abgebrochenen Durchgänge $whose '
          '${historyRangePhrase(_range)}. Sie zählten nie für Sterne, Blitze '
          'oder eine Bestenliste - die geübte Zeit bleibt gezählt.',
          style: const TextStyle(fontSize: 20),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Aufräumen'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      // Both filters, so this removes exactly the rows that were on screen.
      final removed =
          await ref.read(statsRepositoryProvider).deleteIncompleteSessions(
                userId: _filter,
                sinceMs: historySince(_range, ref.read(clockProvider)()),
              );
      _offerUndo(
        removed.length == 1
            ? 'Ein abgebrochener Durchgang aufgeräumt.'
            : '${removed.length} abgebrochene Durchgänge aufgeräumt.',
        removed,
      );
    }
  }
}

class _HistoryRow extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onDelete;

  final VoidCallback onRestore;

  const _HistoryRow({
    required this.entry,
    required this.onDelete,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.profileColor(entry.colorIndex);
    // A run can outlive its lesson - an older backup, a dropped lesson. The
    // log has to survive that rather than take the parent area down.
    final lesson = lessonByIdOrNull(entry.lessonId);

    // Taken out of the record but not erased: dimmed, so it reads as gone
    // without pretending it is.
    return Opacity(
      opacity: entry.deleted ? 0.5 : 1,
      child: Container(
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
                  : '${lesson.title}  ·  ${groupTitle(lesson.group)}',
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
          if (entry.deleted)
            IconButton(
              tooltip: 'Wiederherstellen',
              icon: const Icon(Icons.restore_from_trash_outlined,
                  color: AppColors.correct),
              onPressed: onRestore,
            )
          else
            IconButton(
              tooltip: 'Durchgang löschen',
              icon:
                  const Icon(Icons.delete_outline, color: AppColors.textMuted),
              onPressed: onDelete,
            ),
        ],
        ),
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
          'Ein Tipp auf ein Kind öffnet alles, was zu ihm gehört: Bereiche, '
          'Zeiten, Sperre, Umbenennen und Löschen. Bild und Farbe darf jedes '
          'Kind selbst auf dem Startbildschirm ändern.',
          style: TextStyle(fontSize: 17, color: AppColors.textMuted),
        ),
        const SizedBox(height: 14),
        for (final user in users)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ManagementRow(
              user: user,
              onOpen: () => ProfileSettingsScreen.show(context, user),
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
  final VoidCallback onOpen;

  const _ManagementRow({required this.user, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.profileColor(user.colorIndex);
    // A card, not a row of buttons. Four labelled ones sat here and were six
    // pixels from overflowing on a 10" tablet - and "Löschen" was one slip of
    // the thumb from "Einstellungen". Everything about a child now lives one
    // tap away, in one place.
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.divider, width: 1.5),
            borderRadius: BorderRadius.circular(16),
          ),
          // Dimmed while locked, and the tile keeps its own colour underneath
          // - the same wording the child's profile tile uses. Muted says
          // "paused", grey would say "gone".
          child: Opacity(
            opacity: user.locked ? 0.55 : 1,
            child: Row(
              children: [
                Text(user.avatar, style: const TextStyle(fontSize: 34)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: color,
                              ),
                            ),
                          ),
                          if (user.locked) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.lock,
                                size: 22, color: AppColors.wrong),
                          ],
                        ],
                      ),
                      Text(
                        _summary(user),
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
                const Icon(Icons.chevron_right,
                    size: 32, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// What this child is offered, at a glance. Short on purpose: the full list
  /// of group names ran off the end of the row and told nobody anything.
  static String _summary(User user) {
    final groups = switch (user.visibleGroups.length) {
      0 => 'Kein Bereich freigeschaltet',
      final n when n == LessonGroup.values.length => 'Alle Bereiche',
      final n => '$n von ${LessonGroup.values.length} Bereichen',
    };
    return [
      if (user.locked) 'Gesperrt',
      groups,
      if (!user.reviewHardTasks) 'ohne Wiederholung',
    ].join(' · ');
  }
}
