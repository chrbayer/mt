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
  late final Set<String> _lessonIds = {...?widget.existing?.lessonIds};
  late AssignmentRhythm _rhythm =
      widget.existing?.rhythm ?? AssignmentRhythm.daily;
  late bool _repeats = widget.existing?.repeats ?? true;
  late DateTime _onDay = DateTime.fromMillisecondsSinceEpoch(
      widget.existing?.onDayMs ?? DateTime.now().millisecondsSinceEpoch);
  late bool _carryOver = widget.existing?.carryOver ?? false;
  late int _runs = widget.existing?.runs ?? 1;
  late int _taskCount = widget.existing?.taskCount ?? fallbackTaskCount;
  late int _minStars = widget.existing?.minStars ?? 0;
  late int _minBolts = widget.existing?.minBolts ?? 0;

  bool get _editing => widget.existing != null;

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider).value ?? const <User>[];
    // Which of the chosen lessons the child has already finished in the
    // period running now - shown ticked and dimmed in the picker, so a
    // parent adding a lesson can see what is already behind them.
    final done = widget.existing == null
        ? const <String>{}
        : {
            for (final entry in (ref
                        .watch(assignmentStatsProvider(widget.existing!))
                        .value
                        ?.current ??
                    const <String, AssignmentProgress>{})
                .entries)
              if (entry.value.met) entry.key,
          };
    // No bolts are earned where nothing is timed, so a bolt requirement
    // would be a wish nobody can fail to grant. One unscored lesson among
    // them is enough to take the row away - the bar has to be reachable for
    // every lesson the assignment names.
    final anyUnscored = _lessonIds
        .any((id) => lessonByIdOrNull(id)?.scored == false);
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
              const Text('Übungen', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              const Text(
                'Mehrere sind möglich. Jede davon muss erfüllt werden, '
                'damit die Aufgabe erledigt ist.',
                style: TextStyle(fontSize: 17, color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              // Its own scroller with a fixed height: seventy-odd lessons do
              // not belong in a dialog that already scrolls, and a dropdown
              // cannot hold a multiple choice.
              Container(
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.divider, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  children: [
                    for (final group in LessonGroup.values)
                      if (lessonsInGroup(group).isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
                          child: Text(
                            groupTitle(group),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        for (final option in lessonsInGroup(group))
                          _LessonChoice(
                            lesson: option,
                            selected: _lessonIds.contains(option.id),
                            done: done.contains(option.id),
                            onChanged: (on) => setState(() {
                              if (on) {
                                _lessonIds.add(option.id);
                              } else {
                                _lessonIds.remove(option.id);
                              }
                            }),
                          ),
                      ],
                  ],
                ),
              ),
              if (_lessonIds.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Ohne eine einzige Übung gibt es nichts aufzugeben.',
                    style: TextStyle(fontSize: 17, color: AppColors.wrong),
                  ),
                ),
              const SizedBox(height: 20),
              // Two questions, not one: what a period is, and whether it
              // comes round again. Squeezed into a single list of rhythms it
              // would have grown a value for every new idea.
              const Text('Zeitraum', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              SegmentedButton<AssignmentRhythm>(
                segments: const [
                  ButtonSegment(
                    value: AssignmentRhythm.daily,
                    label: Text('ein Tag'),
                  ),
                  ButtonSegment(
                    value: AssignmentRhythm.weekly,
                    label: Text('eine Woche'),
                  ),
                ],
                selected: {_rhythm},
                onSelectionChanged: (selection) =>
                    setState(() => _rhythm = selection.first),
              ),
              const SizedBox(height: 16),
              const Text('Wiederholung', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('jedes Mal')),
                  ButtonSegment(value: false, label: Text('einmalig')),
                ],
                selected: {_repeats},
                onSelectionChanged: (selection) => setState(() {
                  _repeats = selection.first;
                  // A repeating one brings a fresh one tomorrow anyway, so
                  // carrying it over would only pile up a debt.
                  if (_repeats) _carryOver = false;
                }),
              ),
              const SizedBox(height: 8),
              // No hour to pick: the period is the whole deadline. A finer
              // setting was precision nobody acted on, and a child does not
              // watch the clock.
              if (_repeats)
                Text(
                  _rhythm == AssignmentRhythm.daily
                      ? 'Jeden Tag neu, fällig am Ende des Tages.'
                      : 'Jede Woche neu, fällig Sonntagabend.',
                  style: const TextStyle(
                      fontSize: 17, color: AppColors.textMuted),
                )
              else ...[
                Row(
                  children: [
                    Text(
                      _rhythm == AssignmentRhythm.daily
                          ? 'Am ${_dayLabel(_onDay)}'
                          : 'In der Woche ab ${_dayLabel(_monday(_onDay))}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _pickDay,
                      child: const Text('Tag wählen …'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SwitchListTile(
                  value: _carryOver,
                  onChanged: (on) => setState(() => _carryOver = on),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Nachziehen, wenn nicht geschafft',
                      style: TextStyle(fontSize: 19)),
                  subtitle: const Text(
                    'Die Aufgabe bleibt danach stehen, bis sie erledigt ist. '
                    'Der Tag selbst gilt trotzdem als verpasst - die '
                    'Statistik sagt, wann geübt wurde, nicht was gemeint '
                    'war.',
                    style:
                        TextStyle(fontSize: 16, color: AppColors.textMuted),
                  ),
                ),
              ],
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
              // Stars mean something everywhere, so that row always stands.
              // Bolts do not: nothing is timed in the first steps, so a bolt
              // requirement there would be a wish nobody can fail to grant -
              // and one such lesson among several is enough, because the bar
              // has to be reachable for every lesson the assignment names.
              ...[
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
                if (!anyUnscored) ...[
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
                    // At least one lesson has to be left standing, whichever
                    // way one got here.
                    onPressed: _userId == null || _lessonIds.isEmpty
                        ? null
                        : () async {
                            final navigator = Navigator.of(context);
                            final repository =
                                ref.read(assignmentRepositoryProvider);
                            final chosen = _lessonIds.toList();
                            final bolts = anyUnscored ? 0 : _minBolts;
                            if (_editing) {
                              await repository.updateAssignment(
                                widget.existing!.id,
                                lessonIds: chosen,
                                rhythm: _rhythm,
                                repeats: _repeats,
                                onDayMs: _repeats
                                    ? null
                                    : _onDay.millisecondsSinceEpoch,
                                carryOver: _carryOver,
                                runs: _runs,
                                taskCount: _taskCount,
                                minStars: _minStars,
                                minBolts: bolts,
                              );
                            } else {
                              await repository.createAssignment(
                                userId: _userId!,
                                lessonIds: chosen,
                                rhythm: _rhythm,
                                repeats: _repeats,
                                onDayMs: _repeats
                                    ? null
                                    : _onDay.millisecondsSinceEpoch,
                                carryOver: _carryOver,
                                runs: _runs,
                                taskCount: _taskCount,
                                minStars: _minStars,
                                minBolts: bolts,
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

  static DateTime _monday(DateTime day) =>
      DateTime(day.year, day.month, day.day - (day.weekday - 1));

  static String _dayLabel(DateTime day) {
    const names = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
    return '${names[day.weekday - 1]}, ${day.day}.${day.month}.';
  }

  Future<void> _pickDay() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _onDay,
      // A little way back, because a plan is sometimes written down after
      // the fact, and far enough forward for a school term.
      firstDate: DateTime(today.year, today.month, today.day - 7),
      lastDate: DateTime(today.year, today.month, today.day + 180),
    );
    if (picked != null) setState(() => _onDay = picked);
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

/// One lesson in the picker: a checkbox, and a tick where the child has
/// already finished it in the period running now.
///
/// Done means dimmed and ticked, not disabled: a parent may well want to
/// take a finished lesson back out, and a row that refuses to be touched
/// would not say why.
class _LessonChoice extends StatelessWidget {
  final LessonSpec lesson;
  final bool selected;
  final bool done;
  final ValueChanged<bool> onChanged;

  const _LessonChoice({
    required this.lesson,
    required this.selected,
    required this.done,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => CheckboxListTile(
        value: selected,
        onChanged: (on) => onChanged(on ?? false),
        dense: true,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Opacity(
          opacity: done ? 0.5 : 1,
          child: Row(
            children: [
              Flexible(
                child: Text(
                  lesson.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 17),
                ),
              ),
              if (done) ...[
                const SizedBox(width: 8),
                const Icon(Icons.check_circle,
                    size: 18, color: AppColors.correct),
              ],
            ],
          ),
        ),
      );
}
