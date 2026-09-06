import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/db/app_database.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/lesson.dart';
import '../../domain/scoring.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../lessons/lesson_example.dart';
import '../practice/practice_screen.dart';

/// Set up a duel: who is playing, which lesson, how many tasks.
///
/// Everyone gets the identical run - same seed, same tasks, same order - so
/// the comparison is about the children, not about who drew the easier set.
class DuelSetupScreen extends ConsumerStatefulWidget {
  const DuelSetupScreen({super.key});

  @override
  ConsumerState<DuelSetupScreen> createState() => _DuelSetupScreenState();
}

class _DuelSetupScreenState extends ConsumerState<DuelSetupScreen> {
  final _players = <int>{};
  String? _lessonId;
  int _taskCount = 10;

  /// Only lessons every participant is allowed to see - a duel must not put a
  /// first-grader in front of "Bis 1000".
  List<LessonGroup> _sharedGroups(List<User> users) {
    final chosen = users.where((u) => _players.contains(u.id));
    if (chosen.isEmpty) return const [];
    return LessonGroup.values
        .where((group) => chosen.every((user) => user.shows(group)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final users = ref.watch(usersProvider).value ?? const <User>[];
    final groups = _sharedGroups(users);
    final lessons = [for (final group in groups) ...lessonsInGroup(group)];
    if (_lessonId != null && !lessons.any((l) => l.id == _lessonId)) {
      _lessonId = null;
    }
    final ready = _players.length >= 2 && _lessonId != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Duell')),
      body: users.length < 2
          ? const Center(
              child: Text(
                'Für ein Duell braucht es mindestens zwei Profile.',
                style: TextStyle(fontSize: 24, color: AppColors.textMuted),
              ),
            )
          : Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wer tritt an?',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final user in users)
                        ChoiceChip(
                          selected: _players.contains(user.id),
                          onSelected: (on) => setState(() =>
                              on ? _players.add(user.id) : _players.remove(user.id)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          label: Text(
                            '${user.avatar}  ${user.name}',
                            style: const TextStyle(fontSize: 21),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text('Welche Aufgaben?',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(width: 20),
                      for (final option in selectableTaskCounts)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: ChoiceChip(
                            selected: _taskCount == option,
                            onSelected: (_) =>
                                setState(() => _taskCount = option),
                            label: Text('$option',
                                style: const TextStyle(fontSize: 19)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _players.length < 2
                        ? const Center(
                            child: Text(
                              'Wähle mindestens zwei Kinder aus.',
                              style: TextStyle(
                                  fontSize: 22, color: AppColors.textMuted),
                            ),
                          )
                        : ListView(
                            children: [
                              for (final group in groups) ...[
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(4, 12, 4, 8),
                                  child: Text(
                                    groupTitle(group),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                ),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    for (final lesson in lessonsInGroup(group))
                                      ChoiceChip(
                                        selected: _lessonId == lesson.id,
                                        onSelected: (_) => setState(
                                            () => _lessonId = lesson.id),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 10),
                                        label: Text(
                                          '${lesson.title}  ·  '
                                          '${exampleFor(lesson)}',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.sports_score, size: 32),
                      label: const Text('Duell starten'),
                      onPressed: ready
                          ? () => _start(
                                users
                                    .where((u) => _players.contains(u.id))
                                    .toList(),
                                lessonById(_lessonId!),
                              )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _start(List<User> players, LessonSpec lesson) async {
    final navigator = Navigator.of(context);
    // One seed for the whole duel: everyone solves the same tasks.
    final seed = Random().nextInt(0x7FFFFFFF);
    final outcomes = <int, RunOutcome>{};

    for (final player in players) {
      ref.read(activeUserProvider.notifier).select(player);
      final go = await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => _HandOverScreen(
            player: player,
            lesson: lesson,
            position: players.indexOf(player) + 1,
            total: players.length,
          ),
        ),
      );
      if (go != true) return;

      final outcome = await navigator.push<RunOutcome>(
        MaterialPageRoute<RunOutcome>(
          builder: (_) => PracticeScreen(
            lesson: lesson,
            taskCount: _taskCount,
            seed: seed,
            returnOutcome: true,
          ),
        ),
      );
      if (outcome == null || !outcome.completed) return;
      outcomes[player.id] = outcome;
    }

    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => DuelResultScreen(
          lesson: lesson,
          players: players,
          outcomes: outcomes,
        ),
      ),
    );
    if (mounted) navigator.pop();
  }
}

/// A deliberate pause between two legs, so the tablet changes hands before the
/// clock starts rather than after.
class _HandOverScreen extends StatelessWidget {
  final User player;
  final LessonSpec lesson;
  final int position;
  final int total;

  const _HandOverScreen({
    required this.player,
    required this.lesson,
    required this.position,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.profileColor(player.colorIndex);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$position von $total',
                style: const TextStyle(
                    fontSize: 22, color: AppColors.textMuted)),
            const SizedBox(height: 12),
            Text(player.avatar, style: const TextStyle(fontSize: 90)),
            const SizedBox(height: 8),
            Text(
              '${player.name} ist dran',
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${lesson.title} · ${groupTitle(lesson.group)}',
              style: const TextStyle(fontSize: 22, color: AppColors.textMuted),
            ),
            const SizedBox(height: 36),
            FilledButton.icon(
              icon: const Icon(Icons.play_arrow_rounded, size: 34),
              label: const Text('Bereit'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Duell abbrechen',
                  style: TextStyle(fontSize: 19)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Who won, and by how much.
class DuelResultScreen extends StatelessWidget {
  final LessonSpec lesson;
  final List<User> players;
  final Map<int, RunOutcome> outcomes;

  const DuelResultScreen({
    super.key,
    required this.lesson,
    required this.players,
    required this.outcomes,
  });

  @override
  Widget build(BuildContext context) {
    final ranked = [...players]..sort((a, b) => _score(a).compareTo(_score(b)));
    final best = _score(ranked.first);

    return Scaffold(
      appBar: AppBar(title: Text('Duell · ${lesson.title}')),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 12, 40, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Alle hatten dieselben Aufgaben.',
              style: TextStyle(fontSize: 20, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: ranked.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _DuelRow(
                  rank: index + 1,
                  player: ranked[index],
                  outcome: outcomes[ranked[index].id]!,
                  behind: _score(ranked[index]) - best,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fertig'),
            ),
          ],
        ),
      ),
    );
  }

  double _score(User player) {
    final outcome = outcomes[player.id]!;
    return scoreMsPerTask(
      outcome.totalMs,
      outcome.wrongAttempts,
      outcome.taskCount,
    );
  }
}

class _DuelRow extends StatelessWidget {
  final int rank;
  final User player;
  final RunOutcome outcome;
  final double behind;

  const _DuelRow({
    required this.rank,
    required this.player,
    required this.outcome,
    required this.behind,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.profileColor(player.colorIndex);
    final winner = rank == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: winner ? color.withValues(alpha: 0.12) : AppColors.surface,
        border: Border.all(
          color: winner ? color : AppColors.divider,
          width: winner ? 3 : 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$rank.',
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            ),
          ),
          Text(player.avatar, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          _Cell(
            value: formatPerTask(scoreMsPerTask(
              outcome.totalMs,
              outcome.wrongAttempts,
              outcome.taskCount,
            )),
            label: 'pro Aufgabe',
            strong: true,
          ),
          _Cell(value: '${outcome.wrongAttempts}', label: 'Fehler'),
          SizedBox(
            width: 130,
            child: Text(
              winner ? 'Sieg!' : '+${formatPerTask(behind)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: winner ? color : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String value;
  final String label;
  final bool strong;

  const _Cell({required this.value, required this.label, this.strong = false});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: strong ? 28 : 24,
                fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
                color: strong ? AppColors.primary : AppColors.text,
              ),
            ),
            Text(label,
                style: const TextStyle(
                    fontSize: 15, color: AppColors.textMuted)),
          ],
        ),
      );
}
