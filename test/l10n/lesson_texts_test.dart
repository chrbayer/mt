import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/l10n/l10n.dart';
import 'package:mathe_trainer/l10n/lesson_texts.dart';

/// The catalogue knows lessons only by id; their words come from the ARB
/// files through one `switch`. A lesson added without texts would show its id
/// to a child - this fails first.
void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    group('texts in ${locale.languageCode}', () {
      final l10n = lookupAppLocalizations(locale);

      test('every lesson has a title and a description of its own', () {
        for (final lesson in lessonCatalog) {
          final title = lessonTitle(l10n, lesson);
          final description = lessonDescription(l10n, lesson);
          expect(title, isNotEmpty, reason: lesson.id);
          expect(description, isNotEmpty, reason: lesson.id);
          // The fallback is the id itself.
          expect(title, isNot(lesson.id), reason: lesson.id);
          expect(description, isNot(lesson.id), reason: lesson.id);
        }
      });

      test('every group has a heading', () {
        for (final group in LessonGroup.values) {
          expect(groupTitle(l10n, group), isNotEmpty, reason: '$group');
        }
      });

      test('the rows of the times table carry their number', () {
        final row = lessonById('times_7');
        expect(lessonTitle(l10n, row), contains('7'));
        expect(lessonDescription(l10n, lessonById('div_by_6')), contains('24'));
      });
    });
  }

  test('English is not German with an English accent', () {
    final de = lookupAppLocalizations(const Locale('de'));
    final en = lookupAppLocalizations(const Locale('en'));
    // The texts most easily left untranslated by a copy and paste.
    for (final id in [
      'add_10',
      'partners_of_ten',
      'times_7',
      'div_remainder',
      'clock_words',
      'money_change',
    ]) {
      final lesson = lessonById(id);
      expect(lessonTitle(en, lesson), isNot(lessonTitle(de, lesson)),
          reason: id);
      expect(lessonDescription(en, lesson),
          isNot(lessonDescription(de, lesson)),
          reason: id);
    }
    expect(lessonTitle(en, lessonById('add_10')), 'Plus up to 10');
    expect(
        lessonTitle(en, lessonById('partners_of_ten')), 'Number bonds to 10');
    expect(lessonTitle(en, lessonById('times_7')), '7 times table');
    expect(groupTitle(en, LessonGroup.timesTables), 'Times Tables');
  });

  test('an unknown stored id is shown as it is', () {
    final l10n = lookupAppLocalizations(const Locale('de'));
    expect(lessonTitleById(l10n, 'from_the_future'), 'from_the_future');
    expect(lessonTitleById(l10n, 'add_10'), 'Plus bis 10');
  });
}
