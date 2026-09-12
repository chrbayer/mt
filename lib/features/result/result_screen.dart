import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../domain/assignment.dart';
import '../../domain/lesson.dart';
import '../../domain/scoring.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/star_row.dart';
import '../common/run_hints.dart';
import '../leaderboard/leaderboard_screen.dart';
import '../lessons/pause_notice.dart';
import '../practice/practice_screen.dart';

/// Shown after a completed run: what was achieved, and whether it was faster
/// than last time.
class ResultScreen extends ConsumerWidget {
  final LessonSpec lesson;
  final int? sessionId;
  final int taskCount;
  final int totalMs;
  final int wrongAttempts;

  const ResultScreen({
    super.key,
    required this.lesson,
    required this.sessionId,
    required this.taskCount,
    required this.totalMs,
    required this.wrongAttempts,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Whether this run was allowed to earn anything. Read from the stored
    // session rather than worked out again: the decision was made when the
    // run finished, against the cap as it stood then.
    final counted = sessionId == null ||
        (ref.watch(sessionScoredProvider(sessionId!)).value ?? true);

    // Shown as nothing when it counted for nothing. The same line a run
    // under ten tasks already follows: three golden stars beside "zählt
    // nicht" would be two answers to the same question.
    final stars =
        counted ? starsFor(wrongAttempts, taskCount, scored: lesson.scored) : 0;
    // One time, everywhere: what is shown here is what the leaderboard ranks
    // and what the learning curve plots. A second, penalty-free number would
    // only read as a contradiction.
    final scoredTotal = penalizedTimeMs(totalMs, wrongAttempts);
    final perTask = scoreMsPerTask(totalMs, wrongAttempts, taskCount);
    final penalty = scoredTotal - totalMs;
    // Two axes, deliberately: stars say how carefully this run went, bolts
    // how fast. A child who is careful but slow still gets three stars.
    final bolts =
        counted ? boltsFor(lesson.targetMsPerTask, perTask, taskCount) : 0;
    // No next bolt to chase either: this run cannot earn one however fast it
    // was, and naming a target would be an invitation to run it again.
    final nextBolt =
        counted ? nextBoltTargetMs(lesson.targetMsPerTask, bolts) : null;
    final user = ref.watch(activeUserProvider);
    final gate = ref.watch(practiceGateProvider);
    final streak = user == null
        ? 0
        : ref.watch(streaksProvider).value?[user.id] ?? 0;

    final capToday = user == null || counted
        ? null
        : ref
            .watch(scoredRunsTodayProvider(
              (userId: user.id, lessonId: lesson.id),
            ))
            .value;
    // Only when the cap is what stopped it - an abandoned run is not scored
    // either, and it does not reach this screen with something to explain.
    final usedUpToday = capToday?.used;

    // What the assignment behind this run asked for, if there is one. The
    // screen shows what was earned in letters the size of a hand; without
    // this it never showed what was wanted, so two stars left a child
    // guessing whether that finished the assignment or missed it by one.
    final assignment = user == null
        ? null
        : ref
            .watch(assignmentForLessonProvider(
              (userId: user.id, lessonId: lesson.id),
            ))
            .value;
    final assignmentStats = assignment == null
        ? null
        : ref.watch(assignmentStatsProvider(assignment)).value;
    final goal = assignmentStats == null
        ? null
        : (
            assignment: assignment!,
            // Judged by the domain rule, never re-derived here.
            qualified: qualifies(
              a: assignment,
              lesson: lesson,
              run: (
                finishedAtMs:
                    ref.watch(clockProvider)().millisecondsSinceEpoch,
                taskCount: taskCount,
                totalMs: totalMs,
                wrongAttempts: wrongAttempts,
              ),
              dueMs: assignmentStats.currentPeriod.dueMs,
            ),
            // This lesson's own share of the assignment: an assignment can
            // name several, and the child has just finished one of them.
            done: assignmentStats.progressOf(lesson.id)?.qualifyingRuns ?? 0,
            met: assignmentStats.progressOf(lesson.id)?.met ?? false,
          );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 40, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // This screen has no app bar, so it needs its own way back -
                  // otherwise the only exit is a button further down, and the
                  // system gesture nobody sees in immersive mode.
                  IconButton(
                    tooltip: 'Zurück zu den Lektionen',
                    iconSize: 34,
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // The name in the headline: praise reads better with
                        // it, and it makes plain which profile just earned
                        // this result.
                        Row(
                          children: [
                            if (user != null) ...[
                              Text(user.avatar,
                                  style: const TextStyle(fontSize: 44)),
                              const SizedBox(width: 14),
                            ],
                            Flexible(
                              child: Text(
                                user == null
                                    ? 'Geschafft!'
                                    : 'Geschafft, ${user.name}!',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style:
                                    Theme.of(context).textTheme.headlineLarge,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lesson.title,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StarRow(earned: stars, size: 76),
                    if (lesson.targetMsPerTask > 0) ...[
                      const SizedBox(width: 28),
                      BoltRow(earned: bolts, size: 76),
                    ],
                  ],
                ),
              ),
              // The bolt that is still missing, and what it would take. A
              // target nobody can name is not a target.
              if (nextBolt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${bolts + 1}. Blitz ab ${formatPerTask(nextBolt)} '
                    'pro Aufgabe',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              if (user != null)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StarRow(
                        earned: ref
                                .watch(lessonStatsProvider(user.id))
                                .value?[lesson.id]
                                ?.bestStars ??
                            stars,
                        size: 22,
                      ),
                      if (lesson.targetMsPerTask > 0) ...[
                        const SizedBox(width: 6),
                        BoltRow(
                          earned: ref
                                  .watch(lessonStatsProvider(user.id))
                                  .value?[lesson.id]
                                  ?.bestBolts ??
                              bolts,
                          size: 22,
                        ),
                      ],
                      const SizedBox(width: 8),
                      const Text(
                        'für diese Lektion',
                        style: TextStyle(
                            fontSize: 18, color: AppColors.textMuted),
                      ),
                      const SizedBox(width: 24),
                      StarTotal(
                        earned:
                            ref.watch(starTotalsProvider).value?[user.id] ?? 0,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'insgesamt',
                        style: TextStyle(
                            fontSize: 18, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              // The extra line takes the space the gap below would have had:
              // this column has no room to grow, and the explanation is
              // worth more than the air. One line at most, so the two share
              // the slot - and "did not count today" outranks "too short",
              // because it is the one the child could not have foreseen.
              // The assignment comes first of the three: it is the only one
              // the child was working towards, and the other two cannot
              // apply while one is open anyway - the cap is suspended, and
              // an assignment never asks for fewer than ten tasks.
              if (goal != null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: AssignmentGoalHint(
                    assignment: goal.assignment,
                    qualified: goal.qualified,
                    done: goal.done,
                    met: goal.met,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
              ] else if (usedUpToday != null) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: UsedUpTodayHint(
                    scoredToday: usedUpToday,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
              ] else if (taskCount < minTasksForAward && lesson.scored) ...[
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ShortRunHint(
                    taskCount: taskCount,
                    scored: lesson.scored,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 6),
              ] else
                const SizedBox(height: 16),
              Row(
                children: [
                  _Metric(label: 'Aufgaben', value: '$taskCount'),
                  // A lesson that is not scored shows no times at all - not
                  // even a quiet one. Counting apples is not a race.
                  if (lesson.scored) ...[
                    _Metric(
                      label: 'Gesamtzeit',
                      value: formatDuration(scoredTotal),
                    ),
                    _Metric(
                      label: 'Pro Aufgabe',
                      value: formatPerTask(perTask),
                      highlight: true,
                    ),
                  ],
                  _Metric(label: 'Fehler', value: '$wrongAttempts'),
                ],
              ),
              // Where the extra seconds came from. Without this the total
              // would not match a stopwatch, and the rule would stay a
              // mystery until it cost a place in the ranking.
              if (wrongAttempts > 0 && lesson.scored)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    'Darin sind ${formatDuration(penalty)} Zeitstrafe für '
                    '$wrongAttempts ${wrongAttempts == 1 ? 'Fehlversuch' : 'Fehlversuche'} '
                    'enthalten - 3 Sekunden für jeden.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              if (streak >= 2)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_fire_department_outlined,
                          size: 30, color: AppColors.profile1),
                      const SizedBox(width: 10),
                      Text(
                        '$streak Tage in Folge geübt!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.profile1,
                        ),
                      ),
                    ],
                  ),
                ),
              if (user != null && sessionId != null && lesson.scored)
                Expanded(
                  child: _ComparisonToLastRun(
                    userId: user.id,
                    lesson: lesson,
                    sessionId: sessionId!,
                    msPerTask: perTask,
                  ),
                )
              else
                const Spacer(),
              // The run just finished may well have been the one that used up
              // the time. "Nochmal" starts a new one, so it has to ask the
              // same question the start dialog asks.
              if (gate.pause != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: PauseNotice(allowance: gate.pause!, compact: true),
                ),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.refresh, size: 30),
                      label: const Text('Nochmal'),
                      onPressed: !gate.mayStart
                          ? null
                          : () => Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => PracticeScreen(
                                    lesson: lesson,
                                    taskCount: taskCount,
                                  ),
                                ),
                              ),
                    ),
                  ),
                  if (lesson.scored) const SizedBox(width: 16),
                  if (lesson.scored)
                    Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.leaderboard_outlined, size: 30),
                      label: const Text('Bestenliste'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => LeaderboardScreen(lesson: lesson),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.grid_view_rounded, size: 30),
                      label: const Text('Andere Lektion'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
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

/// "4 Sekunden schneller als beim letzten Mal" - the single most motivating
/// number on this screen, so it gets its own block.
class _ComparisonToLastRun extends ConsumerWidget {
  final int userId;
  final LessonSpec lesson;
  final int sessionId;
  final double msPerTask;

  const _ComparisonToLastRun({
    required this.userId,
    required this.lesson,
    required this.sessionId,
    required this.msPerTask,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Session?>(
      future: ref.read(sessionRepositoryProvider).previousCompletedSession(
            userId: userId,
            lessonId: lesson.id,
            excludingSessionId: sessionId,
          ),
      builder: (context, snapshot) {
        final previous = snapshot.data;
        if (previous == null) {
          return const Center(
            child: Text(
              'Das war dein erster Durchgang hier -\ndie Zeit ist ab jetzt dein Rekord.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, color: AppColors.textMuted),
            ),
          );
        }

        final before = scoreMsPerTask(
          previous.totalMs,
          previous.wrongAttempts,
          previous.taskCount,
        );
        final delta = before - msPerTask;
        final faster = delta > 0;
        final text = delta.abs() < 100
            ? 'Genau so schnell wie beim letzten Mal.'
            : faster
                ? '${formatPerTask(delta)} schneller pro Aufgabe als beim letzten Mal!'
                : '${formatPerTask(-delta)} langsamer pro Aufgabe als beim letzten Mal.';

        return Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                faster ? Icons.trending_up : Icons.trending_flat,
                size: 44,
                color: faster ? AppColors.correct : AppColors.textMuted,
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w600,
                    color: faster ? AppColors.correct : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _Metric({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: highlight ? AppColors.correctSoft : AppColors.surface,
          border: Border.all(
            color: highlight ? AppColors.correct : AppColors.divider,
            width: highlight ? 3 : 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w700,
                color: highlight ? AppColors.correct : AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 18, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
