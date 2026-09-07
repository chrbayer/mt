import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/lesson_filter.dart';
import 'package:mathe_trainer/domain/scoring.dart';

void main() {
  final scored = lessonById('add_100_carry');
  final firstSteps = lessonById('count_pictures');

  bool hidden(LessonFilter filter, LessonSpec lesson, int stars, int bolts) =>
      hiddenByFilter(filter, lesson: lesson, stars: stars, bolts: bolts);

  test('off, nothing is hidden - not even a perfect run', () {
    expect(hidden(LessonFilter.all, scored, maxStars, maxBolts), isFalse);
  });

  test('three stars are the first bar', () {
    expect(hidden(LessonFilter.mastered, scored, maxStars, 0), isTrue);
    expect(hidden(LessonFilter.mastered, scored, 2, maxBolts), isFalse);
  });

  test('the finer setting wants both, so it hides less', () {
    // Right but slow stays: there is still something to practise.
    expect(hidden(LessonFilter.perfected, scored, maxStars, 0), isFalse);
    expect(hidden(LessonFilter.perfected, scored, maxStars, 2), isFalse);
    expect(hidden(LessonFilter.perfected, scored, maxStars, maxBolts), isTrue);
    // Fast but not clean is not done either.
    expect(hidden(LessonFilter.perfected, scored, 2, maxBolts), isFalse);
  });

  test('an untouched lesson is never hidden', () {
    for (final filter in LessonFilter.values) {
      expect(hidden(filter, scored, 0, 0), isFalse, reason: filter.name);
    }
  });

  test('the first steps go too, once they are finished', () {
    // They used to be exempt, because their stars come for finishing rather
    // than for being right. That held while hiding was a one-way door; since
    // a parent can hand the stars back, it is just tidying up.
    expect(hidden(LessonFilter.all, firstSteps, maxStars, 0), isFalse);
    expect(hidden(LessonFilter.mastered, firstSteps, maxStars, 0), isTrue);
  });

  test('but the stricter setting keeps them, without a special case', () {
    // Nothing is timed there, so there are no bolts to earn and the second
    // condition can never be met.
    expect(firstSteps.targetMsPerTask, 0);
    expect(hidden(LessonFilter.perfected, firstSteps, maxStars, 0), isFalse);
  });

  test('an unknown stored name shows everything rather than hiding blindly',
      () {
    expect(lessonFilterByName('mastered'), LessonFilter.mastered);
    expect(lessonFilterByName('perfected'), LessonFilter.perfected);
    expect(lessonFilterByName(''), LessonFilter.all);
    expect(lessonFilterByName('was-auch-immer'), LessonFilter.all);
  });

  test('every setting can be named and explained', () {
    for (final filter in LessonFilter.values) {
      expect(lessonFilterTitle(filter), isNotEmpty);
      expect(lessonFilterExplanation(filter), isNotEmpty);
    }
  });
}
