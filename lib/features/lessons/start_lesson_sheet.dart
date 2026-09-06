import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/lesson.dart';
import '../../domain/scoring.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../../domain/practice_limit.dart';
import '../common/run_hints.dart';
import '../common/star_row.dart';
import 'pause_notice.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../practice/practice_screen.dart';
import 'lesson_example.dart';

/// Asks how many tasks this run should have. The app is meant for drilling as
/// much as for testing, so longer runs are a first-class choice - the
/// leaderboard normalises per task and stays comparable.
class StartLessonSheet extends ConsumerStatefulWidget {
  final LessonSpec lesson;

  const StartLessonSheet({super.key, required this.lesson});

  static Future<void> show(BuildContext context, LessonSpec lesson) =>
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        showDragHandle: true,
        // A tablet in landscape is short: without this the default 9/16 cap
        // clips the buttons at the bottom.
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (_) => StartLessonSheet(lesson: lesson),
      );

  @override
  ConsumerState<StartLessonSheet> createState() => _StartLessonSheetState();
}

class _StartLessonSheetState extends ConsumerState<StartLessonSheet> {
  int? _selected;

  /// The explanation stays folded away. A child does not need it, and a term
  /// like "Zehnerübergang" is exactly what a parent looks up once.
  bool _showHelp = false;

  @override
  Widget build(BuildContext context) {
    // Deliberately nullable: inventing a default here made the highlight
    // jump from the made-up 10 to the stored value a frame later.
    final user = ref.watch(activeUserProvider);
    // Without a profile there is no per-child or per-lesson level to consult,
    // so the app-wide default is all there is. Not reachable from the lesson
    // screen, but the sheet should not be stuck if it ever is.
    final stored = user == null
        ? ref.watch(preferencesProvider).value?.defaultTaskCount
        : ref
            .watch(resolvedTaskCountProvider(
                (userId: user.id, lessonId: widget.lesson.id)))
            .value;
    final count = _selected ?? stored;

    // Checked here rather than on the tile: a child should still be able to
    // look at a lesson and its ranking during the break. The binding check
    // sits in the practice screen; this one only greys the button out.
    final gate = ref.watch(practiceGateProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(40, 8, 40, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  widget.lesson.title,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Was heißt das?',
                iconSize: 32,
                color: _showHelp ? AppColors.primary : AppColors.textMuted,
                icon: Icon(
                  _showHelp ? Icons.help : Icons.help_outline,
                ),
                onPressed: () => setState(() => _showHelp = !_showHelp),
              ),
            ],
          ),
          Text(
            'Zum Beispiel:  ${exampleFor(widget.lesson)}',
            style: const TextStyle(
              fontSize: 24,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Built only when open: AnimatedCrossFade would keep the text in
          // the tree, and it should be genuinely absent when folded away.
          if (_showHelp)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                widget.lesson.description,
                style:
                    const TextStyle(fontSize: 19, color: AppColors.textMuted),
              ),
            ),
          // The target, before the run rather than after it: a child who
          // knows what three bolts take can go for them.
          if (widget.lesson.targetMsPerTask > 0)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Row(
                children: [
                  const BoltRow(earned: maxBolts, size: 26),
                  const SizedBox(width: 10),
                  Text(
                    'ab ${formatPerTask(
                      widget.lesson.targetMsPerTask.toDouble(),
                    )} pro Aufgabe',
                    style: const TextStyle(
                      fontSize: 19,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 26),
          const Text('Wie viele Aufgaben?', style: TextStyle(fontSize: 22)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            children: [
              for (final option in selectableTaskCounts)
                Padding(
                  padding: EdgeInsets.zero,
                  child: _CountChip(
                    value: option,
                    selected: count != null && option == count,
                    onTap: () => setState(() => _selected = option),
                  ),
                ),
            ],
          ),
          // Both hints sit under the choice they are about: how long the run
          // is, and how much time is left for it.
          if (count != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: ShortRunHint(
                taskCount: count,
                scored: widget.lesson.scored,
              ),
            ),
          if (gate.pause == null && widget.lesson.scored)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: RemainingTimeHint(
                allowance: ref.watch(practiceAllowanceProvider).value ??
                    PracticeAllowance.unlimited,
              ),
            ),
          const SizedBox(height: 30),
          // Stacked, not side by side: a bottom sheet is only ~640 dp wide,
          // and two labelled buttons in a row clip the second one.
          if (gate.pause != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: PauseNotice(allowance: gate.pause!, compact: true),
            ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.play_arrow_rounded, size: 34),
              label: const Text("Los geht's"),
              // Disabled for the one frame before the stored count arrives.
              onPressed: !gate.mayStart || count == null
                  ? null
                  : () async {
                      // The navigator has to be captured before the sheet is
                      // popped: afterwards this context is defunct and a
                      // second Navigator.of(context) goes nowhere.
                      final navigator = Navigator.of(context);
                      // Remembered for this lesson only. Changing the length
                      // here is a decision about this lesson, not about every
                      // lesson and every child.
                      if (user != null) {
                        await ref
                            .read(settingsRepositoryProvider)
                            .setLessonTaskCount(
                              userId: user.id,
                              lessonId: widget.lesson.id,
                              count: count,
                            );
                      }
                      navigator.pop();
                      await navigator.push(
                        MaterialPageRoute<void>(
                          builder: (_) => PracticeScreen(
                            lesson: widget.lesson,
                            taskCount: count,
                          ),
                        ),
                      );
                    },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.leaderboard_outlined, size: 28),
              label: const Text('Bestenliste'),
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.pop();
                navigator.push(
                  MaterialPageRoute<void>(
                    builder: (_) => LeaderboardScreen(lesson: widget.lesson),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final int value;
  final bool selected;
  final VoidCallback onTap;

  const _CountChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.background,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 96,
          height: 76,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.divider,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
