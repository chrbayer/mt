import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/lesson.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/task_count_choice.dart';
import '../lessons/lesson_example.dart';

/// Everything a parent decides about one child: which lesson groups they are
/// offered, and whether runs fold in what went badly last time.
///
/// A first-grader who only ever sees "Bis 10" and "Bis 20" does not have to
/// scroll past four ranges they cannot do yet - and cannot start a run that
/// ends in frustration.
class ProfileSettingsDialog extends ConsumerStatefulWidget {
  final User user;

  const ProfileSettingsDialog({super.key, required this.user});

  static Future<void> show(BuildContext context, User user) => showDialog<void>(
        context: context,
        builder: (_) => ProfileSettingsDialog(user: user),
      );

  @override
  ConsumerState<ProfileSettingsDialog> createState() =>
      _ProfileSettingsDialogState();
}

class _ProfileSettingsDialogState
    extends ConsumerState<ProfileSettingsDialog> {
  late final Set<LessonGroup> _visible = widget.user.visibleGroups.toSet();
  late bool _review = widget.user.reviewHardTasks;
  late int? _taskCount = widget.user.defaultTaskCount;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.profileColor(widget.user.colorIndex);

    return Dialog(
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(widget.user.avatar,
                      style: const TextStyle(fontSize: 34)),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      'Einstellungen für ${widget.user.name}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SwitchTile(
                title: 'Schwere Aufgaben wiederholen',
                subtitle: 'Ein Viertel jedes Durchgangs besteht aus dem, '
                    'was zuletzt lange gedauert hat oder falsch war.',
                value: _review,
                onChanged: (on) => setState(() => _review = on),
              ),
              const Divider(height: 32),
              Text('Aufgaben pro Durchgang',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              const TaskCountExplanation(),
              const SizedBox(height: 10),
              TaskCountChoice(
                value: _taskCount,
                inherited:
                    ref.watch(preferencesProvider).value?.defaultTaskCount,
                allowInherit: true,
                onChanged: (count) => setState(() => _taskCount = count),
              ),
              const Divider(height: 32),
              Text('Bereiche', style: Theme.of(context).textTheme.titleLarge),
              const Text(
                'Abgeschaltete Bereiche erscheinen nicht mehr auf dem '
                'Übungsbildschirm. Bereits erzielte Ergebnisse bleiben '
                'erhalten.',
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
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final repository = ref.read(userRepositoryProvider);
                      await repository.setHiddenGroups(
                        widget.user.id,
                        LessonGroup.values
                            .where((g) => !_visible.contains(g))
                            .toSet(),
                      );
                      await repository.setReviewHardTasks(
                        widget.user.id,
                        _review,
                      );
                      await repository.setProfileTaskCount(
                        widget.user.id,
                        _taskCount,
                      );
                      navigator.pop();
                    },
                    child: const Text('Speichern'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// What a group actually asks of a child. A sample calculation says that
  /// far better than a list of lesson titles, which only gets truncated.
  String _summary(LessonGroup group) {
    final lessons = lessonsInGroup(group);
    return '${lessons.length} Lektionen · z. B. ${exampleFor(lessons.first)}';
  }
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
