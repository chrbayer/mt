/// Resolves how long a run should be.
///
/// Three levels, most specific first: what this child last chose for this
/// lesson, then what is set for this child, then the app-wide default. A
/// choice made while starting one lesson stays with that lesson - counting
/// pictures and drilling the times table want different lengths, and neither
/// should quietly redefine the other.
int resolveTaskCount({
  int? forLesson,
  int? forProfile,
  required int global,
}) =>
    forLesson ?? forProfile ?? global;

/// The app-wide fallback when nothing else is set.
const int fallbackTaskCount = 10;
