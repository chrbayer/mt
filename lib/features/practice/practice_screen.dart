import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/lesson.dart';
import '../../domain/practice_limit.dart';
import '../../domain/scoring.dart';
import '../../domain/task.dart';
import '../../domain/task_generator.dart';
import '../../data/repositories/settings_repository.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../profiles/profile_badge.dart';
import '../result/result_screen.dart';
import 'feedback_sounds.dart';
import 'practice_controller.dart';
import '../lessons/pause_notice.dart';
import 'widgets/big_keypad.dart';
import 'widgets/choice_keypad.dart';
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

  final FeedbackSounds _sounds = FeedbackSounds();

  /// Set when the practice cap was already reached as this screen opened.
  /// Then no run is generated at all and the break is shown instead.
  PracticeAllowance? _blocked;

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
    unawaited(_sounds.warmUp());
  }

  Future<void> _prepare() async {
    final user = ref.read(activeUserProvider);

    // The one place every run goes through, whichever button led here. The
    // buttons themselves are the polite half - they grey out - but a third
    // door slipped past them once, so the guarantee lives here.
    //
    // Awaited rather than read: while the limits are still loading the answer
    // is not yet "yes", and assuming it would open a door about to close.
    //
    // Asked exactly once. A run under way is never cut short - being thrown
    // out mid-task would lose the round and teach a child that the app is not
    // to be trusted.
    if (user != null) {
      final provider = practiceAllowanceForProvider(user.id);
      // Held open across the await: without a listener the provider is
      // disposed the moment it is read, and its future never completes.
      final subscription = ref.listenManual(provider, (_, _) {});
      final PracticeAllowance allowance;
      try {
        allowance = await ref.read(provider.future);
      } finally {
        subscription.close();
      }
      if (!mounted) return;
      if (!allowance.allowed) {
        setState(() => _blocked = allowance);
        return;
      }
    }

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
    unawaited(_sounds.dispose());
    super.dispose();
  }

  /// Which pad this task needs. Words for a spoken time, coins for an amount
  /// to lay out, digits for everything else - including the hour that follows
  /// a spoken form, which is a number again.
  Widget _keypadFor(
    PracticeController controller, {
    required bool enabled,
    required bool haptics,
  }) {
    final form = controller.currentTask.form;
    if (form == TaskForm.moneyCompose) {
      return ChoiceKeypad(
        labels: [for (final cents in moneyPieces) formatPiece(cents)],
        enabled: enabled,
        haptics: haptics,
        onChoice: (index) => _key(() => controller.pressPiece(moneyPieces[index])),
        onBackspace: () => _key(controller.backspace),
        onClear: () => _key(controller.clearPieces),
        onSubmit: _submit,
      );
    }
    if (form == TaskForm.clockPhrase &&
        controller.activeField == AnswerField.primary) {
      return ChoiceKeypad(
        labels: clockPhrases,
        selected:
            controller.input.isEmpty ? null : int.parse(controller.input),
        enabled: enabled,
        haptics: haptics,
        onChoice: (index) => _key(() => controller.pressPhrase(index)),
        onSubmit: _submit,
      );
    }
    return BigKeypad(
      enabled: enabled,
      haptics: haptics,
      onDigit: (digit) => _key(() => controller.pressDigit(digit)),
      onBackspace: () => _key(controller.backspace),
      onSubmit: _submit,
    );
  }

  /// Runs one key action and clicks if it actually did something.
  ///
  /// Not every press is an input: the tenth digit, a backspace on an empty
  /// box, anything tapped while the green flash is still up. A click there
  /// would tell the child the tap arrived when it did not - the silence is
  /// the answer. The green key is excluded from this entirely; it has its
  /// own two sounds and says far more than "angekommen".
  void _key(bool Function() action) {
    if (!action()) return;
    if (ref.read(preferencesProvider).value?.sounds ?? true) {
      _sounds.playKey();
    }
  }

  void _submit() {
    final controller = _controller!;
    final outcome = controller.submit();
    // Sound, shake and colour say the same thing three ways. A child looking
    // at the keypad rather than at the answer box gets only one of them.
    final sounds = ref.read(preferencesProvider).value?.sounds ?? true;
    if (outcome == AnswerFeedback.wrong) {
      if (sounds) _sounds.playWrong();
      _shake.forward(from: 0);
      return;
    }
    if (outcome == AnswerFeedback.correct) {
      if (sounds) _sounds.playCorrect();
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
    // Reached the cap before this run even began: no tasks were generated,
    // and the break is all there is to say.
    final blocked = _blocked;
    if (blocked != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.lesson.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PauseNotice(allowance: blocked),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    icon: const Icon(Icons.grid_view_rounded, size: 30),
                    label: const Text('Zurück zu den Lektionen'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

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
                                  showCounts: widget.lesson.showCounts,
                                  clock24: widget.lesson.clock24,
                                  pieces: controller.pieces,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 2,
                            child: _keypadFor(
                              controller,
                              enabled: !locked,
                              haptics: preferences.haptics,
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
