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

/// How many qualifying runs an assignment may ask for. A handful of options,
/// not a free number - one clean run is already a real goal, and asking for
/// more than ten in one period is asking for a different kind of app.
const List<int> _runOptions = [1, 2, 3, 5, 7, 10];

/// Pick a child, a lesson, a rhythm and the four requirements - or change
/// the requirements of one that already exists.
///
/// In edit mode child and lesson are shown but not offered: those two are
/// what an assignment **is**, and swapping them would leave the statistics
/// describing runs that were never assigned. Everything else is fair game,
/// and because nothing is frozen, changing it re-judges the periods already
/// behind it. That is the point of changing a requirement.
class AssignmentEditor extends ConsumerStatefulWidget {
  /// The assignment being changed, or null when a new one is being made.
  final Assignment? existing;

  const AssignmentEditor({super.key, this.existing});

  static Future<void> show(BuildContext context, {Assignment? existing}) =>
      showDialog<void>(
        context: context,
        builder: (_) => AssignmentEditor(existing: existing),
      );

  @override
  ConsumerState<AssignmentEditor> createState() => _AssignmentEditorState();
}

class _AssignmentEditorState extends ConsumerState<AssignmentEditor> {
  late int? _userId = widget.existing?.userId;
  late String? _lessonId = widget.existing?.lessonId;
  late AssignmentRhythm _rhythm =
      widget.existing?.rhythm ?? AssignmentRhythm.daily;
  late int _runs = widget.existing?.runs ?? 1;
  late int _taskCount = widget.existing?.taskCount ?? fallbackTaskCount;
  late int _minStars = widget.existing?.minStars ?? 0;
  late int _minBolts = widget.existing?.minBolts ?? 0;

  bool get _editing => widget.existing != null;

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
              Text(_editing ? 'Aufgabe ändern' : 'Neue Aufgabe',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 16),
              const Text('Kind', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              // Fixed while editing, and shown rather than hidden: a parent
              // has to see whose assignment they are changing.
              if (_editing)
                _Fixed(
                  users
                          .where((u) => u.id == _userId)
                          .map((u) => '${u.avatar}  ${u.name}')
                          .firstOrNull ??
                      'Unbekanntes Kind',
                )
              else
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
              if (_editing)
                _Fixed(lesson == null
                    ? _lessonId!
                    : '${lesson.title} · ${groupTitle(lesson.group)}')
              else
              DropdownButtonFormField<String>(
                initialValue: _lessonId,
                isExpanded: true,
                hint: const Text('Bitte auswählen'),
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
                    // A first-steps lesson is not timed, so it has no bolts
                    // to earn and a bolt requirement would be a wish nobody
                    // can fail to grant. Its stars do mean something - they
                    // follow the error rate like everywhere else - so that
                    // requirement stays.
                    if (lessonByIdOrNull(id)?.scored == false) _minBolts = 0;
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
              const SizedBox(height: 8),
              // No hour to pick: the rhythm is the whole deadline. A finer
              // setting was precision nobody acted on, and a child does not
              // watch the clock.
              Text(
                _rhythm == AssignmentRhythm.daily
                    ? 'Fällig am Ende des Tages.'
                    : 'Fällig am Ende der Woche, also Sonntagabend.',
                style: const TextStyle(
                    fontSize: 17, color: AppColors.textMuted),
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
                const Text('Mindeststerne',
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
                const Text('Mindestblitze',
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
                            final repository =
                                ref.read(assignmentRepositoryProvider);
                            if (_editing) {
                              await repository.updateAssignment(
                                widget.existing!.id,
                                rhythm: _rhythm,
                                runs: _runs,
                                taskCount: _taskCount,
                                minStars: _minStars,
                                minBolts: _minBolts,
                              );
                            } else {
                              await repository.createAssignment(
                                userId: _userId!,
                                lessonId: _lessonId!,
                                rhythm: _rhythm,
                                runs: _runs,
                                taskCount: _taskCount,
                                minStars: _minStars,
                                minBolts: _minBolts,
                              );
                            }
                            navigator.pop();
                          },
                    child: Text(_editing ? 'Speichern' : 'Anlegen'),
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

/// A value that is part of what this assignment is, and therefore not up for
/// changing here: shown plainly, so it is clear which one is being edited.
class _Fixed extends StatelessWidget {
  final String text;

  const _Fixed(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
      );
}
