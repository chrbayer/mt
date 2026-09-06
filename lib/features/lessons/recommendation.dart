import '../../data/repositories/stats_repository.dart';
import '../../domain/lesson.dart';

/// Why a lesson is being suggested.
enum RecommendationReason {
  /// Practised, but with too many mistakes last time round.
  shaky,

  /// Never practised at all.
  fresh,

  /// Practised once, then left alone for a while.
  stale,
}

class Recommendation {
  final LessonSpec lesson;
  final RecommendationReason reason;

  const Recommendation({required this.lesson, required this.reason});

  String get headline => switch (reason) {
        RecommendationReason.shaky => 'Da war es zuletzt wackelig',
        RecommendationReason.fresh => 'Das hast du noch nie geübt',
        RecommendationReason.stale => 'Lange nicht mehr geübt',
      };
}

/// An error rate above this counts as shaky - roughly every seventh task
/// needing a second go.
const double _shakyErrorRate = 0.15;

/// Days after which a lesson is treated as gone cold.
const int _staleDays = 7;

/// Picks the one lesson worth suggesting next, or null when there is nothing
/// sensible to say.
///
/// Weak spots come before new material: a child who keeps stumbling over the
/// 7er-Reihe is not helped by being pointed at the 8er. Only [candidates] are
/// considered, so a hidden group is never suggested.
Recommendation? recommendLesson({
  required List<LessonSpec> candidates,
  required Map<String, LessonStat> stats,
  DateTime? now,
}) {
  if (candidates.isEmpty) return null;

  LessonSpec? shakiest;
  var worstRate = _shakyErrorRate;
  for (final lesson in candidates) {
    final stat = stats[lesson.id];
    if (stat != null && stat.errorRate > worstRate) {
      worstRate = stat.errorRate;
      shakiest = lesson;
    }
  }
  if (shakiest != null) {
    return Recommendation(
      lesson: shakiest,
      reason: RecommendationReason.shaky,
    );
  }

  for (final lesson in candidates) {
    if (!stats.containsKey(lesson.id)) {
      return Recommendation(
        lesson: lesson,
        reason: RecommendationReason.fresh,
      );
    }
  }

  final today = now ?? DateTime.now();
  LessonSpec? coldest;
  DateTime? oldest;
  for (final lesson in candidates) {
    final stat = stats[lesson.id];
    if (stat == null) continue;
    if (today.difference(stat.lastPlayed).inDays < _staleDays) continue;
    if (oldest == null || stat.lastPlayed.isBefore(oldest)) {
      oldest = stat.lastPlayed;
      coldest = lesson;
    }
  }
  return coldest == null
      ? null
      : Recommendation(lesson: coldest, reason: RecommendationReason.stale);
}
