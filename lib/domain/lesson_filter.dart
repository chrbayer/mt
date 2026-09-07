/// Which finished lessons the catalogue leaves out. No Flutter dependency.
library;

import 'lesson.dart';
import 'scoring.dart';

/// How much has to be done before a lesson disappears from the catalogue.
///
/// With seventy-five lessons the list is long, and most of what a child
/// scrolls past is already sitting. Hiding what is done turns the catalogue
/// back into a to-do list.
enum LessonFilter {
  /// Everything stays, whatever it is worth.
  all,

  /// Out with everything worth three stars - the lessons this child gets
  /// right.
  mastered,

  /// Stricter, not looser: three stars **and** three bolts. Right is not the
  /// same as ready, and a child who wants to get quick keeps the ones that
  /// are only accurate in view.
  perfected,
}

/// Label for the choice, for the catalogue and for the parent area.
String lessonFilterTitle(LessonFilter filter) => switch (filter) {
      LessonFilter.all => 'Alle zeigen',
      LessonFilter.mastered => 'Mit 3 Sternen ausblenden',
      LessonFilter.perfected => 'Erst mit 3 Sternen und 3 Blitzen',
    };

/// One sentence on what the choice does.
String lessonFilterExplanation(LessonFilter filter) => switch (filter) {
      LessonFilter.all => 'Der ganze Katalog, nichts wird versteckt.',
      LessonFilter.mastered =>
        'Was sicher sitzt, verschwindet aus der Liste. Übrig bleibt, was '
            'noch Fehler macht.',
      LessonFilter.perfected =>
        'Nur was sicher **und** schnell ist, verschwindet. Was zwar '
            'fehlerfrei, aber noch langsam ist, bleibt zum Üben stehen.',
    };

/// Whether this lesson drops out of the catalogue.
///
/// Never the first steps, whatever they are worth: there the stars come for
/// finishing rather than for being right, so they would all vanish after a
/// single run - and repetition is the whole point of that group.
///
/// A lesson nobody has touched has no stars and therefore always stays.
bool hiddenByFilter(
  LessonFilter filter, {
  required LessonSpec lesson,
  required int stars,
  required int bolts,
}) {
  if (!lesson.scored) return false;
  return switch (filter) {
    LessonFilter.all => false,
    LessonFilter.mastered => stars >= maxStars,
    LessonFilter.perfected => stars >= maxStars && bolts >= maxBolts,
  };
}

/// Reads a stored name back. Anything unknown counts as [LessonFilter.all]:
/// a downgrade must not hide lessons for reasons nobody can see.
LessonFilter lessonFilterByName(String name) {
  for (final filter in LessonFilter.values) {
    if (filter.name == name) return filter;
  }
  return LessonFilter.all;
}
