/// Resolves how long a run should be.
///
/// Four levels, most specific first: an open assignment for this lesson,
/// then what this child last chose for this lesson, then what is set for
/// this child, then the app-wide default. A choice made while starting one
/// lesson stays with that lesson - counting pictures and drilling the times
/// table want different lengths, and neither should quietly redefine the
/// other. An assignment outranks all of that: while one is open the length
/// is not a choice, it is the goal.
int resolveTaskCount({
  int? forAssignment,
  int? forLesson,
  int? forProfile,
  required int global,
}) =>
    forAssignment ?? forLesson ?? forProfile ?? global;

/// The app-wide fallback when nothing else is set.
const int fallbackTaskCount = 10;
