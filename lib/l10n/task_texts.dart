/// The words of a task: its question, the labels between the answer boxes,
/// the parts of a place-value task and the spoken time. The domain
/// (`domain/task.dart`) keeps the numbers and the symbols (`+ − · :`); where a
/// word or a money format is needed, it is added here.
library;

import '../domain/clock_speech.dart';
import '../domain/lesson.dart';
import '../domain/task.dart';
import 'formatters.dart';
import 'l10n.dart';

/// Spoken form of the task, shown above it for the forms that are not
/// written as an equation. Null when the task speaks for itself.
String? taskQuestion(AppLocalizations l10n, Task task) => switch (task.form) {
      TaskForm.partner => l10n.taskQuestionPartner(task.a),
      TaskForm.clock => l10n.taskQuestionClock,
      TaskForm.clockPhrase => l10n.taskQuestionClockPhrase,
      TaskForm.moneyCompose =>
        l10n.taskQuestionMoneyCompose(formatEuro(l10n, task.a)),
      // The price and what is handed over are both in the question, so
      // nothing is written as an equation: at the till nobody writes one.
      TaskForm.change => l10n.taskQuestionChange(
          formatEuro(l10n, task.b), formatEuro(l10n, task.a)),
      TaskForm.quantity => l10n.taskQuestionQuantity,
      TaskForm.dice => task.b == 0
          ? l10n.taskQuestionDiceOne
          : l10n.taskQuestionDiceTwo,
      // With a keypad the answer is a number, so the question has to say
      // which number - "wo sind mehr" alone would ask for a pointing finger.
      TaskForm.compare => l10n.taskQuestionCompare,
      TaskForm.sequence => l10n.taskQuestionSequence,
      TaskForm.quantityAdd => l10n.taskQuestionQuantityAdd,
      TaskForm.placeValue => l10n.taskQuestionPlaceValue,
      _ => null,
    };

/// Label between the two boxes, for the forms that have two.
String taskSecondLabel(AppLocalizations l10n, Task task) => switch (task.form) {
      TaskForm.remainder => l10n.taskLabelRemainder,
      TaskForm.money || TaskForm.change => l10n.taskLabelEuro,
      TaskForm.clock => l10n.taskLabelClock,
      _ => '',
    };

/// Unit after the second box, where there is one.
String taskSecondUnit(AppLocalizations l10n, Task task) =>
    task.form == TaskForm.money || task.form == TaskForm.change
        ? l10n.taskUnitCents
        : '';

/// The named places as text, smallest first: "5 Einer", "12 Zehner", …
///
/// One per line on screen. Written as a single line they run off the edge
/// at the size the practice screen uses.
List<String> placeParts(AppLocalizations l10n, Task task) {
  final names = [
    l10n.placeOnes,
    l10n.placeTens,
    l10n.placeHundreds,
    l10n.placeThousands,
  ];
  return [
    for (final (index, count) in task.places.indexed)
      if (count > 0) names[index](count)
  ];
}

/// Text shown left of the input box. The domain's [Task.prefix] for every
/// form that is only numbers and symbols; the two that carry words or a
/// price are written here.
String taskPrefix(AppLocalizations l10n, Task task) => switch (task.form) {
      TaskForm.money =>
        '${formatEuro(l10n, task.a)} ${task.opSymbol} '
            '${formatEuro(l10n, task.b)} =',
      // The parts themselves, smallest first, as they were dictated.
      TaskForm.placeValue => placeParts(l10n, task).join(', '),
      _ => task.prefix,
    };

/// The word for the part of the day under a 24-hour clock.
String dayPartName(AppLocalizations l10n, DayPart part) => switch (part) {
      DayPart.morning => l10n.dayPartMorning,
      DayPart.noon => l10n.dayPartNoon,
      DayPart.afternoon => l10n.dayPartAfternoon,
      DayPart.evening => l10n.dayPartEvening,
    };

/// The eleven spoken forms of a time, in five-minute steps, in the order of
/// their index (index 0 is `:05`).
///
/// The full hour is deliberately missing. "3 Uhr" puts the hour first and
/// every other reading puts it last in German, and a box that swaps places
/// with its neighbour depending on the answer would be a puzzle of its own.
/// Full hours are practised in the three lessons that ask for the digits.
List<String> clockPhraseLabels(AppLocalizations l10n) => [
      l10n.clockPhrase05,
      l10n.clockPhrase10,
      l10n.clockPhrase15,
      l10n.clockPhrase20,
      l10n.clockPhrase25,
      l10n.clockPhrase30,
      l10n.clockPhrase35,
      l10n.clockPhrase40,
      l10n.clockPhrase45,
      l10n.clockPhrase50,
      l10n.clockPhrase55,
    ];

/// The whole spoken form, for the review list and the lesson tile.
String spokenTime(AppLocalizations l10n, Task task,
        {ClockSpeech speech = ClockSpeech.de}) =>
    l10n.clockSpokenTime(
      clockPhraseLabels(l10n)[task.expected],
      task.namedHourIn(speech),
    );

/// One-line rendering of [task] with [answer] placed in the box, and
/// [secondAnswer] in the second one where there is one.
String renderTask(AppLocalizations l10n, Task task, String answer,
    [String secondAnswer = '?', ClockSpeech speech = ClockSpeech.de]) {
  final prefix = taskPrefix(l10n, task);
  final suffix = task.suffix;
  final (a, b) = (task.a, task.b);
  return switch (task.form) {
    TaskForm.result => '$prefix $answer',
    TaskForm.placeValue => '$prefix = $answer',
    TaskForm.gap => '$prefix $answer $suffix',
    TaskForm.partner => '$a ♥ $answer',
    TaskForm.remainder =>
      l10n.taskRenderRemainder(prefix, answer, secondAnswer),
    TaskForm.money => '$prefix $answer',
    // A sample time says more about the lesson than a placeholder.
    TaskForm.clock =>
      l10n.taskRenderClock(a, b.toString().padLeft(2, '0')),
    TaskForm.clockPhrase => spokenTime(l10n, task, speech: speech),
    TaskForm.moneyCompose => formatEuro(l10n, a),
    TaskForm.change => l10n.taskRenderChange(
        formatEuro(l10n, b), formatEuro(l10n, a)),
    TaskForm.quantity => pictureFor(a, b) * a,
    // "Würfel 2" told nobody anything; the pips are what is on screen.
    TaskForm.dice =>
      b == 0 ? l10n.taskRenderDiceOne(a) : l10n.taskRenderDiceTwo(a, b),
    TaskForm.compare => '${pictureFor(a, b) * a}  ·  ${pictureFor(a, b) * b}',
    TaskForm.sequence => '${task.sequenceNumbers.join(' ')} ?',
    TaskForm.quantityAdd => '${task.picture * a} + ${task.picture * b}',
    TaskForm.chain => '$prefix $answer',
  };
}

/// What a task looks like with nothing entered yet - the way a lesson tile
/// and the start dialog show an example.
String taskExample(AppLocalizations l10n, Task task) =>
    renderTask(l10n, task, '?');
