import 'package:flutter/foundation.dart';

import '../../domain/lesson.dart';
import '../../domain/task.dart';

/// Visual state of the answer box after a submission.
enum AnswerFeedback { none, correct, wrong }

/// Which box the keypad writes into. Only a division with remainder has two.
enum AnswerField { primary, second }

/// Drives one practice run: current task, typed digits, timing and results.
///
/// Deliberately free of any widget code so the rules - especially "the clock
/// keeps running through wrong answers" - can be tested directly.
class PracticeController extends ChangeNotifier {
  /// Answers never exceed three digits (100 in the small range, 999 in the
  /// large one), so the box refuses a fourth digit instead of silently
  /// swallowing it.
  static const int maxInputDigits = 3;

  final LessonSpec lesson;
  final List<Task> tasks;
  final Stopwatch _stopwatch;

  int _index = 0;
  String _input = '';
  String _secondInput = '';
  AnswerField _field = AnswerField.primary;
  /// The coins and notes tapped so far, newest last. Only a
  /// [TaskForm.moneyCompose] task collects any.
  final List<int> _pieces = [];

  int _wrongForCurrentTask = 0;
  AnswerFeedback _feedback = AnswerFeedback.none;
  bool _paused = false;
  bool _finished = false;
  final List<TaskResult> _results = [];

  PracticeController({
    required this.lesson,
    required this.tasks,
    Stopwatch? stopwatch,
  })  : assert(tasks.isNotEmpty, 'a run needs at least one task'),
        _stopwatch = stopwatch ?? Stopwatch() {
    _stopwatch.start();
  }

  Task get currentTask => tasks[_index];
  int get index => _index;
  int get taskCount => tasks.length;
  String get input => _input;

  /// Content of the second box - the remainder, the cents, the minutes.
  String get secondInput => _secondInput;

  /// Which box the keypad currently fills.
  AnswerField get activeField => _field;

  /// The coins and notes laid out so far, in the order they were tapped.
  List<int> get pieces => List.unmodifiable(_pieces);

  /// Whether this task asks for two numbers.
  bool get hasSecondField => currentTask.expectedSecond != null;

  AnswerFeedback get feedback => _feedback;
  bool get isPaused => _paused;
  bool get isFinished => _finished;
  List<TaskResult> get results => List.unmodifiable(_results);

  /// Wrong attempts across the whole run, including the current task.
  int get wrongAttempts =>
      _results.fold<int>(0, (sum, r) => sum + r.wrongAttempts) +
      _wrongForCurrentTask;

  /// Summed time of finished tasks plus the one currently on screen.
  ///
  /// As soon as an answer is correct its time is already in [_results], so the
  /// still-running stopwatch must not be counted a second time.
  int get elapsedMs {
    final done = _results.fold<int>(0, (sum, r) => sum + r.elapsedMs);
    final currentTaskRecorded =
        _finished || _feedback == AnswerFeedback.correct;
    return done + (currentTaskRecorded ? 0 : _stopwatch.elapsedMilliseconds);
  }

  /// While [AnswerFeedback.correct] is shown the box is locked so a fast
  /// tapper cannot type into the next task before it appears.
  bool get _acceptsInput =>
      !_finished && !_paused && _feedback != AnswerFeedback.correct;

  String get _active =>
      _field == AnswerField.primary ? _input : _secondInput;

  void _setActive(String value) {
    if (_field == AnswerField.primary) {
      _input = value;
    } else {
      _secondInput = value;
    }
  }

  void pressDigit(int digit) {
    if (!_acceptsInput) return;
    // Typing right after a mistake is allowed and clears the red state - the
    // child should not have to wait out an animation.
    if (_feedback == AnswerFeedback.wrong) _feedback = AnswerFeedback.none;
    // A bare 0 is a legitimate answer - "8 - 8", "17 : 4 Rest 1" - so it can
    // be typed. A following digit replaces it instead of producing "07".
    if (_active == '0') {
      _setActive('$digit');
    } else {
      if (_active.length >= maxInputDigits) return;
      _setActive('$_active$digit');
    }
    notifyListeners();
  }

  /// Taps one of the spoken forms. It replaces whatever was chosen before -
  /// there is nothing to append to, so there is nothing to delete either.
  void pressPhrase(int index) {
    if (!_acceptsInput) return;
    if (_feedback == AnswerFeedback.wrong) _feedback = AnswerFeedback.none;
    _field = AnswerField.primary;
    _input = '$index';
    notifyListeners();
  }

  /// Lays down one coin or note. The answer to such a task is not a typed
  /// number but the pile itself, so the box shows the running total.
  void pressPiece(int cents) {
    if (!_acceptsInput) return;
    if (_feedback == AnswerFeedback.wrong) _feedback = AnswerFeedback.none;
    _pieces.add(cents);
    _input = '${_pieces.fold<int>(0, (sum, c) => sum + c)}';
    notifyListeners();
  }

  /// Sweeps the whole pile away at once.
  ///
  /// Taking six coins off one at a time to start over is six taps of the same
  /// key, and a child who has lost count wants to start over, not to undo.
  void clearPieces() {
    if (!_acceptsInput || _pieces.isEmpty) return;
    if (_feedback == AnswerFeedback.wrong) _feedback = AnswerFeedback.none;
    _pieces.clear();
    _input = '';
    notifyListeners();
  }

  void backspace() {
    if (!_acceptsInput) return;
    if (_feedback == AnswerFeedback.wrong) _feedback = AnswerFeedback.none;
    // A pile is taken apart piece by piece, not digit by digit: deleting a
    // digit off the total would leave an amount nobody laid down.
    if (_pieces.isNotEmpty) {
      _pieces.removeLast();
      _input = _pieces.isEmpty
          ? ''
          : '${_pieces.fold<int>(0, (sum, c) => sum + c)}';
      notifyListeners();
      return;
    }
    if (_active.isEmpty) {
      // Backing out of the empty remainder box returns to the quotient, so a
      // mistyped first number can still be corrected.
      if (_field == AnswerField.second) _field = AnswerField.primary;
    } else {
      _setActive(_active.substring(0, _active.length - 1));
    }
    notifyListeners();
  }

  /// Checks the typed number. Returns the resulting feedback so the screen can
  /// trigger the matching sound/haptic and schedule the next task.
  AnswerFeedback submit() {
    if (!_acceptsInput || _active.isEmpty) return AnswerFeedback.none;

    // First of two boxes: move on rather than judge. The answer is only half
    // given, and saying now which half is wrong would hand over the other.
    if (hasSecondField && _field == AnswerField.primary) {
      _field = AnswerField.second;
      notifyListeners();
      return AnswerFeedback.none;
    }

    final answer = int.parse(_input);
    final secondMatches = !hasSecondField ||
        int.parse(_secondInput) == currentTask.expectedSecond;
    if (answer == currentTask.expected && secondMatches) {
      _results.add(
        TaskResult(
          task: currentTask,
          elapsedMs: _stopwatch.elapsedMilliseconds,
          wrongAttempts: _wrongForCurrentTask,
        ),
      );
      _feedback = AnswerFeedback.correct;
    } else {
      // The stopwatch is not touched: the measured time is the time until the
      // correct answer, retries included.
      _wrongForCurrentTask++;
      _input = '';
      _secondInput = '';
      _pieces.clear();
      _field = AnswerField.primary;
      _feedback = AnswerFeedback.wrong;
    }
    notifyListeners();
    return _feedback;
  }

  /// Moves on after a correct answer; called by the screen once the green
  /// flash has been shown.
  void advance() {
    if (_feedback != AnswerFeedback.correct) return;
    _feedback = AnswerFeedback.none;
    _input = '';
    _secondInput = '';
    _pieces.clear();
    _field = AnswerField.primary;
    _wrongForCurrentTask = 0;

    if (_index + 1 >= tasks.length) {
      _finished = true;
      _stopwatch.stop();
    } else {
      _index++;
      _stopwatch
        ..reset()
        ..start();
    }
    notifyListeners();
  }

  /// Called when the app goes to the background. Without this a run left open
  /// over lunch would look like a catastrophic time.
  void pause() {
    if (_paused || _finished) return;
    _paused = true;
    _stopwatch.stop();
    notifyListeners();
  }

  void resume() {
    if (!_paused || _finished) return;
    _paused = false;
    _stopwatch.start();
    notifyListeners();
  }

  /// Results of an aborted run, so the session can still be stored (marked
  /// incomplete and excluded from statistics).
  List<TaskResult> get partialResults => results;
}
