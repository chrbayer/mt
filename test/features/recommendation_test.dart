import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/repositories/stats_repository.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/features/lessons/recommendation.dart';

LessonStat stat({
  required String id,
  double errorRate = 0,
  DateTime? lastPlayed,
}) =>
    LessonStat(
      lessonId: id,
      runs: 1,
      bestScoreMs: 5000,
      averageMs: 5000,
      errorRate: errorRate,
      bestStars: 3,
      lastPlayed: lastPlayed ?? DateTime(2026, 9, 6),
    );

void main() {
  final now = DateTime(2026, 9, 6);
  final candidates = [
    lessonById('add_20_plain'),
    lessonById('add_20_carry'),
    lessonById('times_7'),
  ];

  test('a weak spot beats new material', () {
    // Pointing a child who keeps stumbling over one lesson at the next new
    // one does not help them.
    final result = recommendLesson(
      candidates: candidates,
      stats: {
        'add_20_plain': stat(id: 'add_20_plain'),
        'add_20_carry': stat(id: 'add_20_carry', errorRate: 0.3),
      },
      now: now,
    );

    expect(result!.lesson.id, 'add_20_carry');
    expect(result.reason, RecommendationReason.shaky);
    expect(result.headline, 'Da war es zuletzt wackelig');
  });

  test('the shakiest of several is chosen', () {
    final result = recommendLesson(
      candidates: candidates,
      stats: {
        'add_20_plain': stat(id: 'add_20_plain', errorRate: 0.2),
        'add_20_carry': stat(id: 'add_20_carry', errorRate: 0.4),
        'times_7': stat(id: 'times_7', errorRate: 0.18),
      },
      now: now,
    );
    expect(result!.lesson.id, 'add_20_carry');
  });

  test('a few slips are not a weak spot', () {
    // Below the threshold nothing is called shaky, and the untouched lesson
    // wins instead.
    final result = recommendLesson(
      candidates: candidates,
      stats: {
        'add_20_plain': stat(id: 'add_20_plain', errorRate: 0.1),
        'add_20_carry': stat(id: 'add_20_carry', errorRate: 0.05),
      },
      now: now,
    );
    expect(result!.lesson.id, 'times_7');
    expect(result.reason, RecommendationReason.fresh);
  });

  test('with nothing practised yet the first lesson is offered', () {
    final result =
        recommendLesson(candidates: candidates, stats: const {}, now: now);
    expect(result!.lesson.id, 'add_20_plain');
    expect(result.reason, RecommendationReason.fresh);
  });

  test('when everything is done and clean, the coldest comes up', () {
    final result = recommendLesson(
      candidates: candidates,
      stats: {
        'add_20_plain':
            stat(id: 'add_20_plain', lastPlayed: DateTime(2026, 8, 20)),
        'add_20_carry':
            stat(id: 'add_20_carry', lastPlayed: DateTime(2026, 8, 28)),
        'times_7': stat(id: 'times_7', lastPlayed: DateTime(2026, 9, 5)),
      },
      now: now,
    );
    expect(result!.lesson.id, 'add_20_plain');
    expect(result.reason, RecommendationReason.stale);
  });

  test('nothing is suggested when everything is fresh and clean', () {
    final result = recommendLesson(
      candidates: candidates,
      stats: {
        for (final lesson in candidates)
          lesson.id: stat(id: lesson.id, lastPlayed: DateTime(2026, 9, 5)),
      },
      now: now,
    );
    expect(result, isNull);
  });

  test('a hidden group is never suggested', () {
    // Only what the child can actually reach is offered.
    final result = recommendLesson(
      candidates: [lessonById('add_20_plain')],
      stats: {'times_7': stat(id: 'times_7', errorRate: 0.9)},
      now: now,
    );
    expect(result!.lesson.id, 'add_20_plain');
  });

  test('without candidates there is nothing to say', () {
    expect(
      recommendLesson(candidates: const [], stats: const {}, now: now),
      isNull,
    );
  });
}
