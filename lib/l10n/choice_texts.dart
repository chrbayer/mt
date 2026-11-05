/// Names of the small enums of the domain: the finished-lessons filter and
/// the time range of the run log. The enums themselves carry no words.
library;

import '../domain/history_range.dart';
import '../domain/lesson_filter.dart';
import 'l10n.dart';

/// Label for the choice, for the catalogue and for the parent area.
String lessonFilterTitle(AppLocalizations l10n, LessonFilter filter) =>
    switch (filter) {
      LessonFilter.all => l10n.filterAllTitle,
      LessonFilter.mastered => l10n.filterMasteredTitle,
      LessonFilter.perfected => l10n.filterPerfectedTitle,
    };

/// One sentence on what the choice does.
String lessonFilterExplanation(AppLocalizations l10n, LessonFilter filter) =>
    switch (filter) {
      LessonFilter.all => l10n.filterAllText,
      LessonFilter.mastered => l10n.filterMasteredText,
      LessonFilter.perfected => l10n.filterPerfectedText,
    };

String historyRangeTitle(AppLocalizations l10n, HistoryRange range) =>
    switch (range) {
      HistoryRange.all => l10n.rangeAll,
      HistoryRange.today => l10n.rangeToday,
      HistoryRange.week => l10n.rangeWeek,
      HistoryRange.month => l10n.rangeMonth,
    };

/// The same, in the middle of a sentence - for the question asked before
/// anything is tidied away.
String historyRangePhrase(AppLocalizations l10n, HistoryRange range) =>
    switch (range) {
      HistoryRange.all => l10n.rangeAllPhrase,
      HistoryRange.today => l10n.rangeTodayPhrase,
      HistoryRange.week => l10n.rangeWeekPhrase,
      HistoryRange.month => l10n.rangeMonthPhrase,
    };
