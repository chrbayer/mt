import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/lesson.dart';
import '../../domain/lesson_filter.dart';
import '../../domain/practice_limit.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/amount_choice.dart';
import '../common/task_count_choice.dart';
import '../lessons/lesson_example.dart';
import '../profiles/profile_editor.dart';
import 'confirm_dialog.dart';
import 'reset_stars_dialog.dart';

/// Below this width the two columns fall back to one. A 10" tablet in
/// landscape is far wider than this; a phone held sideways is not.
const double _twoColumnWidth = 900;

/// Everything a parent decides about one child, and everything they can do to
/// the profile itself.
///
/// A screen rather than a dialog, and that is the whole point of it: a dialog
/// put "Speichern" underneath nine sections of scrolling, so the usual way
/// out was the back gesture - which threw the changes away without a word.
/// An app bar keeps the tick and the cross in sight however far down one has
/// scrolled, and [PopScope] catches the back gesture.
class ProfileSettingsScreen extends ConsumerStatefulWidget {
  final User user;

  const ProfileSettingsScreen({super.key, required this.user});

  static Future<void> show(BuildContext context, User user) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProfileSettingsScreen(user: user),
        ),
      );

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState
    extends ConsumerState<ProfileSettingsScreen> {
  late final Set<LessonGroup> _visible =
      widget.user.visibleGroups.toSet();
  late bool _review = widget.user.reviewHardTasks;
  late int? _taskCount = widget.user.defaultTaskCount;
  late int? _limitMinutes = widget.user.practiceLimitMinutes;
  late int? _breakMinutes = widget.user.breakMinutes;
  late int? _dailyMinutes = widget.user.dailyLimitMinutes;
  late int? _scoredRuns = widget.user.scoredRunsPerLesson;
  late bool _locked = widget.user.locked;
  late LessonFilter _filter = widget.user.filter;

  /// Set once the profile is gone, so leaving does not ask to save settings
  /// for a child who no longer exists.
  bool _deleted = false;

  /// Whether anything on this screen differs from what is stored.
  ///
  /// The back gesture only interrupts when there is something to lose. A
  /// dialog that appears after every look at the settings teaches people to
  /// dismiss it without reading, which is how the changes get lost in the
  /// first place.
  bool get _dirty =>
      !_deleted &&
      (!_setEquals(_visible, widget.user.visibleGroups.toSet()) ||
          _review != widget.user.reviewHardTasks ||
          _taskCount != widget.user.defaultTaskCount ||
          _limitMinutes != widget.user.practiceLimitMinutes ||
          _breakMinutes != widget.user.breakMinutes ||
          _dailyMinutes != widget.user.dailyLimitMinutes ||
          _scoredRuns != widget.user.scoredRunsPerLesson ||
          _locked != widget.user.locked ||
          _filter != widget.user.filter);

  static bool _setEquals(Set<LessonGroup> a, Set<LessonGroup> b) =>
      a.length == b.length && a.containsAll(b);

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    final repository = ref.read(userRepositoryProvider);
    final id = widget.user.id;
    await repository.setHiddenGroups(
      id,
      LessonGroup.values.where((g) => !_visible.contains(g)).toSet(),
    );
    await repository.setReviewHardTasks(id, _review);
    await repository.setProfileTaskCount(id, _taskCount);
    await repository.setLessonFilter(id, _filter);
    await repository.setPracticeLimit(
      id,
      limitMinutes: _limitMinutes,
      breakMinutes: _breakMinutes,
      dailyLimitMinutes: _dailyMinutes,
    );
    await repository.setScoredRunsPerLesson(id, _scoredRuns);
    await repository.setLocked(id, _locked);
    navigator.pop();
  }

  /// Leaving without saving. Silent when nothing was touched.
  Future<void> _close() async {
    final navigator = Navigator.of(context);
    if (!_dirty) {
      navigator.pop();
      return;
    }
    final discard = await confirmDestructive(
      context,
      title: 'Änderungen verwerfen?',
      message: 'Die Einstellungen für ${widget.user.name} wurden geändert, '
          'aber noch nicht gespeichert.',
      confirmLabel: 'Verwerfen',
    );
    if (discard) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.profileColor(widget.user.colorIndex);
    // Null while the app-wide limits are still being read; the inherit chips
    // then say "wie für alle" without a number rather than a guessed one.
    final preferences = ref.watch(preferencesProvider).value;
    final global = preferences?.limits;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Verwerfen',
            icon: const Icon(Icons.close, size: 30),
            onPressed: _close,
          ),
          title: Row(
            children: [
              Text(widget.user.avatar, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  widget.user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color),
                ),
              ),
            ],
          ),
          actions: [
            // The one control this screen exists for. Labelled as well as
            // ticked: a bare tick in a corner is a convention, and a parent
            // who has just changed a time limit should not have to know it.
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: FilledButton.icon(
                icon: const Icon(Icons.check, size: 28),
                label: const Text('Speichern'),
                onPressed: _save,
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns = constraints.maxWidth >= _twoColumnWidth;
            return ListView(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
              children: [
                _LockBlock(
                  locked: _locked,
                  onChanged: (on) => setState(() => _locked = on),
                ),
                const Divider(height: 36),
                if (twoColumns)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _practiceColumn(global)),
                      const SizedBox(width: 40),
                      Expanded(child: _timeColumn(global, preferences)),
                    ],
                  )
                else ...[
                  _practiceColumn(global),
                  const SizedBox(height: 28),
                  _timeColumn(global, preferences),
                ],
                const Divider(height: 36),
                _tidyUpBlock(),
              ],
            );
          },
        ),
      ),
    );
  }

  /// What the child is offered and how a run is put together.
  Widget _practiceColumn(PracticeLimits? global) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Üben'),
          Text('Bereiche', style: Theme.of(context).textTheme.titleLarge),
          const Text(
            'Abgeschaltete Bereiche erscheinen nicht mehr auf dem '
            'Übungsbildschirm. Bereits erzielte Ergebnisse bleiben erhalten.',
            style: TextStyle(fontSize: 17, color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          for (final group in LessonGroup.values)
            SwitchTile(
              title: groupTitle(group),
              subtitle: _summary(group),
              value: _visible.contains(group),
              onChanged: (on) => setState(
                () => on ? _visible.add(group) : _visible.remove(group),
              ),
            ),
          if (_visible.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Ohne einen einzigen Bereich kann das Kind nicht üben.',
                style: TextStyle(fontSize: 17, color: AppColors.wrong),
              ),
            ),
          const SizedBox(height: 24),
          Text('Fertige Lektionen ausblenden',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          const Text(
            'Kürzt den Katalog um das, was schon sitzt. Das Kind kann es auf '
            'dem Übungsbildschirm selbst umstellen - hier steht es, damit man '
            'es einmal einrichten kann. Die Ersten Schritte bleiben immer '
            'stehen: dort gibt es die Sterne fürs Durchhalten, nicht fürs '
            'Richtigsein.',
            style: TextStyle(fontSize: 17, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          RadioGroup<LessonFilter>(
            groupValue: _filter,
            onChanged: (chosen) => setState(() => _filter = chosen ?? _filter),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final filter in LessonFilter.values)
                  RadioListTile<LessonFilter>(
                    value: filter,
                    contentPadding: EdgeInsets.zero,
                    title: Text(lessonFilterTitle(filter),
                        style: const TextStyle(fontSize: 20)),
                    subtitle: Text(
                      lessonFilterExplanation(filter).replaceAll('**', ''),
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.textMuted),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Aufgaben pro Durchgang',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          const TaskCountExplanation(forProfile: true),
          const SizedBox(height: 10),
          TaskCountChoice(
            value: _taskCount,
            inherited: ref.watch(preferencesProvider).value?.defaultTaskCount,
            allowInherit: true,
            onChanged: (count) => setState(() => _taskCount = count),
          ),
          const SizedBox(height: 16),
          SwitchTile(
            title: 'Schwere Aufgaben wiederholen',
            subtitle: 'Ein Viertel jedes Durchgangs besteht aus dem, was '
                'zuletzt lange gedauert hat oder falsch war.',
            value: _review,
            onChanged: (on) => setState(() => _review = on),
          ),
        ],
      );

  /// How long, how often, and how much of it counts.
  Widget _timeColumn(
    PracticeLimits? global, AppPreferences? preferences) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Zeit und Wertung'),
          Text('Übungszeit am Stück',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          const Text(
            'Nach dieser Zeit gibt es eine Pause. Ein laufender Durchgang '
            'wird nie abgebrochen - erst der nächste Start ist gesperrt. Die '
            'Zeit zählt weiter, solange die Pause nicht vollständig '
            'eingehalten wurde.',
            style: TextStyle(fontSize: 17, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          AmountChoice(
            value: _limitMinutes,
            options: practiceLimitOptions,
            inherited: global?.stretchMinutes,
            allowInherit: true,
            onChanged: (minutes) => setState(() => _limitMinutes = minutes),
          ),
          // Only worth asking once there is a limit for it to end.
          if ((_limitMinutes ?? global?.stretchMinutes ?? 0) > 0) ...[
            const SizedBox(height: 16),
            Text('Wie lange dauert die Pause?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            AmountChoice(
              value: _breakMinutes,
              options: breakMinuteOptions,
              inherited: global?.breakMinutes,
              allowInherit: true,
              zeroLabel: null,
              onChanged: (minutes) => setState(() => _breakMinutes = minutes),
            ),
          ],
          const SizedBox(height: 24),
          Text('Und pro Tag insgesamt',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          const Text(
            'Zählt alle Durchgänge des Tages zusammen, Pausen hin oder her. '
            'Ist die Zeit aufgebraucht, geht es erst am nächsten Tag weiter.',
            style: TextStyle(fontSize: 17, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          AmountChoice(
            value: _dailyMinutes,
            options: dailyLimitOptions,
            inherited: global?.dailyMinutes,
            allowInherit: true,
            onChanged: (minutes) => setState(() => _dailyMinutes = minutes),
          ),
          const SizedBox(height: 24),
          Text('Gewertete Durchgänge je Übung und Tag',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          const Text(
            'Danach darf dieselbe Übung weiter gemacht werden, sie bringt nur '
            'keine Bestzeit, keine Sterne und keine Blitze mehr. Geübte Zeit '
            'und Verlauf zählen weiter mit.',
            style: TextStyle(fontSize: 17, color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),
          AmountChoice(
            value: _scoredRuns,
            options: scoredRunOptions,
            inherited: preferences?.scoredRunsPerLesson,
            allowInherit: true,
            labelFor: (runs) => '$runs×',
            onChanged: (runs) => setState(() => _scoredRuns = runs),
          ),
        ],
      );

  /// Everything that is done to the profile rather than set on it.
  ///
  /// These used to sit as four labelled buttons on the row in the list, where
  /// they were six pixels from overflowing on a 10" tablet. Here they have
  /// room, and "Löschen" is no longer one slip of the thumb away from
  /// "Einstellungen".
  Widget _tidyUpBlock() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('Aufräumen'),
          const Text(
            'Diese Knöpfe wirken sofort - sie warten nicht auf "Speichern".',
            style: TextStyle(fontSize: 17, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 24),
                label: const Text('Umbenennen'),
                onPressed: () =>
                    ProfileEditorDialog.show(context, user: widget.user),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.star_outline, size: 24),
                label: const Text('Sterne zurückgeben …'),
                onPressed: () => ResetStarsDialog.show(context, widget.user),
              ),
              OutlinedButton.icon(
                style:
                    OutlinedButton.styleFrom(foregroundColor: AppColors.wrong),
                icon: const Icon(Icons.restart_alt, size: 24),
                label: const Text('Ergebnisse löschen'),
                onPressed: _confirmReset,
              ),
              OutlinedButton.icon(
                style:
                    OutlinedButton.styleFrom(foregroundColor: AppColors.wrong),
                icon: const Icon(Icons.delete_outline, size: 24),
                label: const Text('Profil löschen'),
                onPressed: _confirmDelete,
              ),
            ],
          ),
        ],
      );

  Future<void> _confirmReset() async {
    final confirmed = await confirmDestructive(
      context,
      title: 'Ergebnisse von ${widget.user.name} löschen?',
      message: 'Bestzeiten, Lernkurve und Verlauf gehen verloren. Das Profil '
          'selbst bleibt bestehen.',
    );
    if (!confirmed) return;
    await ref.read(userRepositoryProvider).resetStatistics(widget.user.id);
  }

  Future<void> _confirmDelete() async {
    final navigator = Navigator.of(context);
    final confirmed = await confirmDestructive(
      context,
      title: '${widget.user.name} löschen?',
      message: 'Profil und alle Ergebnisse werden entfernt.',
    );
    if (!confirmed) return;
    await ref.read(userRepositoryProvider).deleteUser(widget.user.id);
    // Nothing left to settle: leaving must not ask about unsaved changes for
    // a profile that no longer exists.
    _deleted = true;
    navigator.pop();
  }

  /// What a group actually asks of a child. A sample calculation says that
  /// far better than a list of lesson titles, which only gets truncated.
  String _summary(LessonGroup group) {
    final lessons = lessonsInGroup(group);
    return '${lessons.length} Lektionen · z. B. ${exampleFor(lessons.first)}';
  }
}

/// The lock, on its own and above everything else.
///
/// It is the one thing a parent reaches for in a hurry, and it used to sit in
/// the middle of a long scroll between the daily cap and the stars.
class _LockBlock extends StatelessWidget {
  final bool locked;
  final ValueChanged<bool> onChanged;

  const _LockBlock({required this.locked, required this.onChanged});

  @override
  Widget build(BuildContext context) => Material(
        // The colour belongs on the Material, not on a box around the tile:
        // a ListTile paints its own ink on the nearest Material, and a
        // coloured box in between would swallow both colour and splash.
        color: locked ? AppColors.wrongSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(
              color: locked ? AppColors.wrong : AppColors.divider,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: SwitchListTile(
            value: locked,
            onChanged: onChanged,
            contentPadding: EdgeInsets.zero,
            secondary: Icon(
              locked ? Icons.lock : Icons.lock_open,
              size: 32,
              color: locked ? AppColors.wrong : AppColors.textMuted,
            ),
            title: Text('Profil vorübergehend sperren',
                style: Theme.of(context).textTheme.titleLarge),
            subtitle: const Text(
              'Das Profil lässt sich dann nicht öffnen und nicht zum Duell '
              'einladen. Nichts geht verloren: Sterne, Blitze und Bestzeiten '
              'sind nach dem Freigeben unverändert da.',
              style: TextStyle(fontSize: 17, color: AppColors.textMuted),
            ),
          ),
        ),
      );
}

/// The heading of one of the screen's blocks - smaller than a section title,
/// so the two levels stay apart at a glance.
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.primary,
          ),
        ),
      );
}

/// A switch row sized for a tablet - the Material default is too small here.
class SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SwitchListTile(
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
        title: Text(title, style: const TextStyle(fontSize: 22)),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16),
        ),
      );
}
