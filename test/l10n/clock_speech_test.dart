import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/clock_speech.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/practice/practice_controller.dart';
import 'package:mathe_trainer/l10n/l10n.dart';
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

    test('is chosen by its language code', () {
      expect(identical(ClockSpeech.forLanguage('de'), ClockSpeech.de), isTrue);
    });
  });

  group('English', () {
    const speech = ClockSpeech.en;
    final en = enL10n;

    test('says the hour behind the phrase, and from :35 the next one', () {
      expect(speech.hourFirst, isFalse);
      expect(speech.nextHourFromIndex, 6);
      expect(spokenTime(en, at(3, 15), speech: speech), 'quarter past 3');
      expect(spokenTime(en, at(3, 25), speech: speech), 'twenty-five past 3');
      expect(spokenTime(en, at(3, 30), speech: speech), 'half past 3');
      expect(spokenTime(en, at(3, 35), speech: speech), 'twenty-five to 4');
      expect(spokenTime(en, at(3, 45), speech: speech), 'quarter to 4');
      expect(spokenTime(en, at(3, 55), speech: speech), 'five to 4');
    });

    test('differs from German exactly at :25', () {
      expect(at(3, 25).expectedSecondIn(ClockSpeech.de), 4);
      expect(at(3, 25).expectedSecondIn(speech), 3);
      expect(at(3, 30).expectedSecondIn(speech), 3);
      expect(at(3, 35).expectedSecondIn(speech), 4);
    });

    test('a tile sample follows the language of the texts', () {
      expect(spokenTime(en, at(3, 25)), 'twenty-five past 3');
      expect(spokenTime(deL10n, at(3, 25)), '5 vor halb 4');
    });

    test('the hour after twelve is one', () {
      expect(at(12, 45).expectedSecondIn(speech), 1);
      expect(at(12, 15).expectedSecondIn(speech), 12);
    });

    test('is graded with the English hour', () {
      final controller = PracticeController(
        lesson: lessonById('clock_words'),
        tasks: [at(3, 25)],
        speech: speech,
      );
      controller.pressPhrase(at(3, 25).expected);
      controller.submit();
      controller.pressDigit(3);
      expect(controller.submit(), AnswerFeedback.correct);
    });

    test('is what the language code en and every unknown one resolves to', () {
      expect(identical(ClockSpeech.forLanguage('en'), ClockSpeech.en), isTrue);
      expect(identical(ClockSpeech.forLanguage('xx'), ClockSpeech.en), isTrue);
    });
  });

  group('French, Spanish and Italian', () {
    // All three say the hour first and name the coming hour from :35 on.
    for (final entry in {
      'fr': ClockSpeech.fr,
      'es': ClockSpeech.es,
      'it': ClockSpeech.it,
    }.entries) {
      group(entry.key, () {
        final speech = entry.value;

        test('is chosen by its language code', () {
          expect(identical(ClockSpeech.forLanguage(entry.key), speech), isTrue);
          expect(speech.hourFirst, isTrue);
          expect(speech.nextHourFromIndex, 6);
        });

        test('names the hour that has begun up to :30, the next from :35', () {
          expect(at(3, 15).expectedSecondIn(speech), 3);
          expect(at(3, 25).expectedSecondIn(speech), 3);
          expect(at(3, 30).expectedSecondIn(speech), 3);
          expect(at(3, 35).expectedSecondIn(speech), 4);
          expect(at(3, 45).expectedSecondIn(speech), 4);
          expect(at(3, 55).expectedSecondIn(speech), 4);
        });

        test('the hour after twelve is one', () {
          expect(at(12, 45).expectedSecondIn(speech), 1);
          expect(at(12, 15).expectedSecondIn(speech), 12);
        });
      });
    }

    test('French puts the hour in front of the phrase', () {
      final fr = lookupAppLocalizations(const Locale('fr'));
      expect(spokenTime(fr, at(3, 15), speech: ClockSpeech.fr), '3 h et quart');
      expect(
        spokenTime(fr, at(3, 30), speech: ClockSpeech.fr),
        '3 h et demie',
      );
      expect(
        spokenTime(fr, at(3, 35), speech: ClockSpeech.fr),
        '4 h moins vingt-cinq',
      );
      expect(
        spokenTime(fr, at(3, 45), speech: ClockSpeech.fr),
        '4 h moins le quart',
      );
      expect(
        spokenTime(fr, at(12, 45), speech: ClockSpeech.fr),
        '1 h moins le quart',
      );
      // Without an explicit speech it follows the language of the texts.
      expect(spokenTime(fr, at(3, 45)), '4 h moins le quart');
    });

    test('Spanish and Italian put the hour in front of the phrase', () {
      final es = lookupAppLocalizations(const Locale('es'));
      final it = lookupAppLocalizations(const Locale('it'));
      expect(spokenTime(es, at(3, 15)), '3 y cuarto');
      expect(spokenTime(es, at(3, 30)), '3 y media');
      expect(spokenTime(es, at(3, 35)), '4 menos veinticinco');
      expect(spokenTime(es, at(12, 45)), '1 menos cuarto');
      expect(spokenTime(it, at(3, 15)), '3 e un quarto');
      expect(spokenTime(it, at(3, 30)), '3 e mezza');
      expect(spokenTime(it, at(3, 35)), '4 meno venticinque');
      expect(spokenTime(it, at(12, 45)), '1 meno un quarto');
    });

    for (final code in ['fr', 'es', 'it']) {
      test('$code: the word at the hour box never names the answer', () {
        // No article or plural that depends on the hour ("la una" / "las
        // tres", "l'una" / "le tre"): the phrases of two different hours
        // differ only in the hour box.
        final l10n = lookupAppLocalizations(Locale(code));
        for (final minute in [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]) {
          final one = spokenTime(l10n, at(1, minute));
          final three = spokenTime(l10n, at(3, minute));
          expect(one.substring(one.indexOf(' ')),
              three.substring(three.indexOf(' ')),
              reason: '$code :$minute');
        }
      });
    }
  });

  group('a language that says the hour first', () {
    // French "3 h et quart": any speech that sets hourFirst is followed by
    // the controller; the French one is checked on the real screen too.
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
