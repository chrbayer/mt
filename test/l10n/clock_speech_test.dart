import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/clock_speech.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/practice/practice_controller.dart';
import 'package:mathe_trainer/l10n/task_texts.dart';

import '../support/l10n.dart';

/// How a time is said. The stored answer is the index of the phrase and the
/// minute; only the hour that is named depends on the language.
void main() {
  Task at(int hour, int minute) =>
      Task(a: hour, b: minute, op: Operation.add, form: TaskForm.clockPhrase);

  group('German', () {
    const speech = ClockSpeech.de;

    test('says the hour behind the phrase, and from 25 past the next one', () {
      expect(speech.hourFirst, isFalse);
      expect(spokenTime(deL10n, at(3, 15), speech: speech), 'viertel nach 3');
      expect(spokenTime(deL10n, at(3, 25), speech: speech), '5 vor halb 4');
      expect(spokenTime(deL10n, at(3, 30), speech: speech), 'halb 4');
      expect(spokenTime(deL10n, at(3, 45), speech: speech), 'viertel vor 4');
    });

    test('the hour after twelve is one', () {
      expect(speech.namedHour(5, 12), 1);
      expect(speech.namedHour(2, 12), 12);
    });

    test('the phrase index does not depend on the language', () {
      expect(at(3, 5).expected, 0);
      expect(at(3, 55).expected, clockPhraseCount - 1);
      expect(at(3, 25).expectedSecondIn(speech), 4);
      expect(at(3, 25).expectedSecond, 4);
    });

    test('is what an unknown language falls back to', () {
      expect(identical(ClockSpeech.forLanguage('de'), ClockSpeech.de), isTrue);
      expect(identical(ClockSpeech.forLanguage('xx'), ClockSpeech.de), isTrue);
    });
  });

  group('a language that says the hour first', () {
    // French "3 heures et quart": nothing in the app is French yet, but the
    // controller must already be able to follow the order.
    const french = ClockSpeech(nextHourFromIndex: 6, hourFirst: true);
    final lesson = lessonById('clock_words');

    test('names the next hour from :35 on', () {
      expect(at(3, 30).expectedSecondIn(french), 3);
      expect(at(3, 35).expectedSecondIn(french), 4);
    });

    test('is entered hour first, then the phrase', () {
      final controller = PracticeController(
        lesson: lesson,
        tasks: [at(3, 35), at(7, 15)],
        speech: french,
      );
      expect(controller.activeField, AnswerField.second);
      controller.pressDigit(4);
      expect(controller.submit(), AnswerFeedback.none);
      expect(controller.activeField, AnswerField.primary);
      // Backing out of the empty word box returns to the hour.
      expect(controller.backspace(), isTrue);
      expect(controller.activeField, AnswerField.second);
      controller.submit();
      controller.pressPhrase(at(3, 35).expected);
      expect(controller.submit(), AnswerFeedback.correct);
      controller.advance();
      expect(controller.activeField, AnswerField.second);
    });

    test('German order is unchanged', () {
      final controller =
          PracticeController(lesson: lesson, tasks: [at(3, 30)]);
      expect(controller.activeField, AnswerField.primary);
      controller.pressPhrase(at(3, 30).expected);
      controller.submit();
      expect(controller.activeField, AnswerField.second);
      controller.pressDigit(4);
      expect(controller.submit(), AnswerFeedback.correct);
    });
  });
}
