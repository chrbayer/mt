import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../domain/assignment.dart';
import '../../domain/lesson.dart';
import '../../domain/scoring.dart';
import '../../domain/task_count.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/amount_choice.dart';

const List<String> _weekdayLabels = [
  'Montag',
  'Dienstag',
  'Mittwoch',
  'Donnerstag',
  'Freitag',
  'Samstag',
  'Sonntag',
];

/// How many qualifying runs an assignment may ask for. A handful of options,
/// not a free number - one clean run is already a real goal, and asking for
/// more than ten in one period is asking for a different kind of app.
const List<int> _runOptions = [1, 2, 3, 5, 7, 10];

/// New assignment: pick a child, a lesson, a rhythm and the four
/// requirements. There is no "edit" - only "Neue Aufgabe", because an
/// assignment is never changed once created (see domain/assignment.dart);
/// this dialog only ever inserts a row.
class AssignmentEditor extends ConsumerStatefulWidget {
  const AssignmentEditor({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => const AssignmentEditor(),
      );

  @override
  ConsumerState<AssignmentEditor> createState() => _AssignmentEditorState();
}

class _AssignmentEditorState extends ConsumerState<AssignmentEditor> {
  int? _userId;
  String? _lessonId;
  AssignmentRhythm _rhythm = AssignmentRhythm.daily;
  TimeOfDay _dueTime = const TimeOfDay(hour: 18, minute: 0);
  int _dueWeekday = DateTime.sunday;
  int _runs = 1;
  int _taskCount = fallbackTaskCount;
  int _minStars = 0;
  int _minBolts = 0;

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider).value ?? const <User>[];
    final lesson = _lessonId == null ? null : lessonByIdOrNull(_lessonId!);
    // Options start at minTasksForAward: below it a run earns no stars and
    // no bolts at all, so "mindestens 2 Sterne" would be a goal nobody could
    // ever reach.
    final taskCountOptions =
        selectableTaskCounts.where((c) => c >= minTasksForAward).toList();

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
              Text('Neue Aufgabe',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const Text('Kind', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final user in users)
                    ChoiceChip(
                      label: Text('${user.avatar}  ${user.name}',
                          style: const TextStyle(fontSize: 18)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      selected: _userId == user.id,
                      onSelected: (_) => setState(() => _userId = user.id),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Lektion', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _lessonId,
                isExpanded: true,
                hint: const Text('auswählen'),
                items: [
                  for (final group in LessonGroup.values)
                    if (lessonsInGroup(group).isNotEmpty) ...[
                      DropdownMenuItem<String>(
                        enabled: false,
                        value: '_group_${group.name}',
                        child: Text(
                          groupTitle(group),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      for (final option in lessonsInGroup(group))
                        DropdownMenuItem<String>(
                          value: option.id,
                          child: Text('   ${option.title}'),
                        ),
                    ],
                ],
                onChanged: (id) {
                  if (id == null || id.startsWith('_group_')) return;
                  setState(() {
                    _lessonId = id;
                    // A first-steps lesson (scored == false) has no bolts to
                    // earn, and its stars are awarded for finishing
                    // regardless of how it went - starsFor(..., scored:
                    // false) always returns full marks. Both requirements
                    // would be a wish nobody can fail to grant, so drop them
                    // rather than leave a dead control in the form.
                    if (lessonByIdOrNull(id)?.scored == false) {
                      _minBolts = 0;
                      _minStars = 0;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text('Rhythmus', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              SegmentedButton<AssignmentRhythm>(
                segments: const [
                  ButtonSegment(
                    value: AssignmentRhythm.daily,
                    label: Text('täglich'),
                  ),
                  ButtonSegment(
                    value: AssignmentRhythm.weekly,
                    label: Text('wöchentlich'),
                  ),
                ],
                selected: {_rhythm},
                onSelectionChanged: (selection) =>
                    setState(() => _rhythm = selection.first),
              ),
              const SizedBox(height: 12),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  const Text('fällig bis', style: TextStyle(fontSize: 18)),
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _dueTime,
                      );
                      if (picked != null) setState(() => _dueTime = picked);
                    },
                    child: Text(_dueTime.format(context)),
                  ),
                  if (_rhythm == AssignmentRhythm.weekly)
                    DropdownButton<int>(
                      value: _dueWeekday,
                      items: [
                        for (var day = DateTime.monday;
                            day <= DateTime.sunday;
                            day++)
                          DropdownMenuItem(
                            value: day,
                            child: Text(_weekdayLabels[day - 1]),
                          ),
                      ],
                      onChanged: (day) =>
                          setState(() => _dueWeekday = day ?? _dueWeekday),
                    ),
                ],
              ),
              const Divider(height: 32),
              const Text('Durchgänge', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              AmountChoice(
                value: _runs,
                options: _runOptions,
                zeroLabel: null,
                labelFor: (v) => '$v×',
                onChanged: (v) => setState(() => _runs = v ?? _runs),
              ),
              const SizedBox(height: 16),
              const Text('Rechnungen je Durchgang',
                  style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              AmountChoice(
                value: _taskCount,
                options: taskCountOptions,
                zeroLabel: null,
                labelFor: (v) => '$v',
                onChanged: (v) => setState(() => _taskCount = v ?? _taskCount),
              ),
              // Both rows are hidden for the first steps (scored == false):
              // nothing is timed there, so there are no bolts to ask for
              // (LessonSpec.targetMsPerTask), and its stars are awarded for
              // finishing regardless of how it went, so a star requirement
              // would never actually require anything.
              if (lesson == null || lesson.scored) ...[
                const SizedBox(height: 16),
                const Text('Mindestens Sterne',
                    style: TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                AmountChoice(
                  value: _minStars,
                  options: const [0, 1, 2, 3],
                  zeroLabel: 'keine Vorgabe',
                  labelFor: (v) => '$v ★',
                  onChanged: (v) =>
                      setState(() => _minStars = v ?? _minStars),
                ),
                const SizedBox(height: 16),
                const Text('Mindestens Blitze',
                    style: TextStyle(fontSize: 20)),
                const SizedBox(height: 8),
                AmountChoice(
                  value: _minBolts,
                  options: const [0, 1, 2, 3],
                  zeroLabel: 'keine Vorgabe',
                  labelFor: (v) => '$v ⚡',
                  onChanged: (v) =>
                      setState(() => _minBolts = v ?? _minBolts),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Abbrechen'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton(
                    onPressed: _userId == null || _lessonId == null
                        ? null
                        : () async {
                            final navigator = Navigator.of(context);
                            await ref
                                .read(assignmentRepositoryProvider)
                                .createAssignment(
                                  userId: _userId!,
                                  lessonId: _lessonId!,
                                  rhythm: _rhythm,
                                  dueMinute:
                                      _dueTime.hour * 60 + _dueTime.minute,
                                  dueWeekday: _dueWeekday,
                                  runs: _runs,
                                  taskCount: _taskCount,
                                  minStars: _minStars,
                                  minBolts: _minBolts,
                                );
                            navigator.pop();
                          },
                    child: const Text('Anlegen'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
