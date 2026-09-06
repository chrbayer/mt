import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/lesson.dart';
import '../../domain/scoring.dart';
import '../../domain/task.dart';
import '../../domain/task_generator.dart';
import '../../data/repositories/settings_repository.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../profiles/profile_badge.dart';
import '../result/result_screen.dart';
import 'practice_controller.dart';
import 'widgets/big_keypad.dart';
import 'widgets/progress_dots.dart';
import 'widgets/task_display.dart';

/// How long the green flash stays before the next task appears.
const _correctFlash = Duration(milliseconds: 400);

/// What a finished run came to. Returned instead of shown when the run is
/// one leg of a duel.
class RunOutcome {
  final int taskCount;
  final int totalMs;
  final int wrongAttempts;
  final bool completed;

  const RunOutcome({
    required this.taskCount,
    required this.totalMs,
    required this.wrongAttempts,
    required this.completed,
  });
}

class PracticeScreen extends ConsumerStatefulWidget {
  final LessonSpec lesson;
  final int taskCount;

  /// Fixed seed, so both sides of a duel get exactly the same tasks. Null
  /// means a fresh one - and then, and only then, previously difficult tasks
  /// are folded in: a duel has to be the same for everyone.
  final int? seed;

  /// Pop with a [RunOutcome] instead of moving on to the result screen.
  final bool returnOutcome;

  const PracticeScreen({
    super.key,
    required this.lesson,
    required this.taskCount,
    this.seed,
    this.returnOutcome = false,
  });

  @override
  ConsumerState<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends ConsumerState<PracticeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  /// Null until the review tasks have been read from the database - the run
  /// cannot be generated before we know what to fold back in.
  PracticeController? _controller;
  late final AnimationController _shake;
  late final int _seed;
  Timer? _advanceTimer;
  Timer? _clockTimer;
  int? _sessionId;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _seed = widget.seed ?? DateTime.now().microsecondsSinceEpoch & 0x7FFFFFFF;
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    unawaited(_prepare());
  }

  Future<void> _prepare() async {
    final user = ref.read(activeUserProvider);
    final review = user == null || widget.seed != null
        ? const <Task>[]
        : await ref.read(
            reviewTasksProvider(
              (userId: user.id, lessonId: widget.lesson.id),
            ).future,
          );
    if (!mounted) return;

    setState(() {
      _controller = PracticeController(
        lesson: widget.lesson,
        tasks: generateTasks(
          lesson: widget.lesson,
          count: widget.taskCount,
          seed: _seed,
          review: review,
        ),
      )..addListener(_onControllerChanged);
    });

    unawaited(_createSession());
  }

  Future<void> _createSession() async {
    final user = ref.read(activeUserProvider);
    if (user == null) return;
    final id = await ref.read(sessionRepositoryProvider).startSession(
          userId: user.id,
          lessonId: widget.lesson.id,
          taskCount: widget.taskCount,
          seed: _seed,
        );
    if (mounted) setState(() => _sessionId = id);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Any interruption stops the clock. Resuming is deliberate (a tap on
    // "Weiter") so the timer does not run while nobody is looking.
    if (state != AppLifecycleState.resumed) _controller?.pause();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _advanceTimer?.cancel();
    _clockTimer?.cancel();
    _shake.dispose();
    _controller
      ?..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _submit() {
    final controller = _controller!;
    final outcome = controller.submit();
    if (outcome == AnswerFeedback.wrong) {
      _shake.forward(from: 0);
      return;
    }
    if (outcome == AnswerFeedback.correct) {
      _advanceTimer?.cancel();
      _advanceTimer = Timer(_correctFlash, () {
        controller.advance();
        if (controller.isFinished) unawaited(_finish());
      });
    }
  }

  Future<void> _finish() async {
    if (_leaving) return;
    _leaving = true;
    final sessionId = _sessionId;
    if (sessionId != null) {
      await ref.read(sessionRepositoryProvider).finishSession(
            sessionId: sessionId,
            results: _controller!.results,
            completed: true,
          );
    }
    if (!mounted) return;
    if (widget.returnOutcome) {
      Navigator.of(context).pop(
        RunOutcome(
          taskCount: widget.taskCount,
          totalMs: _controller!.elapsedMs,
          wrongAttempts: _controller!.wrongAttempts,
          completed: true,
        ),
      );
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          lesson: widget.lesson,
          sessionId: sessionId,
          taskCount: widget.taskCount,
          totalMs: _controller!.elapsedMs,
          wrongAttempts: _controller!.wrongAttempts,
        ),
      ),
    );
  }

  Future<void> _confirmAbort() async {
    _controller?.pause();
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Übung beenden?'),
        content: const Text(
          'Dieser Durchgang zählt dann nicht für die Bestenliste.',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Weiter rechnen'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Beenden'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (leave ?? false) {
      _leaving = true;
      final sessionId = _sessionId;
      if (sessionId != null) {
        await ref.read(sessionRepositoryProvider).finishSession(
              sessionId: sessionId,
              results: _controller?.results ?? const [],
              completed: false,
            );
      }
      if (mounted) {
        Navigator.of(context).pop(
          widget.returnOutcome
              ? RunOutcome(
                  taskCount: widget.taskCount,
                  totalMs: _controller?.elapsedMs ?? 0,
                  wrongAttempts: _controller?.wrongAttempts ?? 0,
                  completed: false,
                )
              : null,
        );
      }
    } else {
      _controller?.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final preferences =
        ref.watch(preferencesProvider).value ?? const AppPreferences();
    final activeUser = ref.watch(activeUserProvider);

    // The first steps are never timed, so the clock stays away even when it
    // is switched on for everyone else.
    final showClock = preferences.showClock && widget.lesson.scored;
    if (showClock && _clockTimer == null) {
      _clockTimer = Timer.periodic(
        const Duration(milliseconds: 500),
        (_) => setState(() {}),
      );
    }

    final locked = controller.feedback == AnswerFeedback.correct ||
        controller.isPaused;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_leaving) unawaited(_confirmAbort());
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Übung beenden',
                          iconSize: 36,
                          icon: const Icon(Icons.close),
                          onPressed: _confirmAbort,
                        ),
                        const SizedBox(width: 8),
                        // Next to the close button rather than in the far
                        // corner: that corner is where Android puts its own
                        // gestures, and identity reads better up front.
                        if (activeUser != null) ...[
                          ProfileBadge(user: activeUser, size: 21),
                          const SizedBox(width: 28),
                        ],
                        Expanded(
                          child: ProgressDots(
                            total: controller.taskCount,
                            current: controller.index,
                          ),
                        ),
                        if (showClock)
                          Text(
                            formatDuration(controller.elapsedMs),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: AnimatedBuilder(
                              animation: _shake,
                              builder: (context, child) => Transform.translate(
                                offset: Offset(_shakeOffset(), 0),
                                child: child,
                              ),
                              child: Center(
                                child: TaskDisplay(
                                  task: controller.currentTask,
                                  input: controller.input,
                                  secondInput: controller.secondInput,
                                  activeField: controller.activeField,
                                  feedback: controller.feedback,
                                  arrangement: widget.lesson.arrangement,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: BigKeypad(
                              enabled: !locked,
                              haptics: preferences.haptics,
                              onDigit: controller.pressDigit,
                              onBackspace: controller.backspace,
                              onSubmit: _submit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.isPaused) _PauseOverlay(onResume: controller.resume),
            ],
          ),
        ),
      ),
    );
  }

  /// Three quick swings that die down - readable as "no" without being scary.
  double _shakeOffset() {
    if (!_shake.isAnimating) return 0;
    final t = _shake.value;
    return 16 * (1 - t) * math.sin(t * math.pi * 6);
  }
}

class _PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;

  const _PauseOverlay({required this.onResume});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: AppColors.background.withValues(alpha: 0.97),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Pause', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              const Text(
                'Die Zeit läuft nicht weiter.',
                style: TextStyle(fontSize: 24, color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onResume,
                icon: const Icon(Icons.play_arrow, size: 32),
                label: const Text('Weiter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
