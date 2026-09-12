/// How far back the parent area's run log reaches. No Flutter dependency.
library;

/// The stretches of time the log can be narrowed to.
///
/// Calendar days, not rolling hours: a parent asking "what did they do this
/// week" means the last seven days as they appear on a calendar, not the
/// last 168 hours. "7 Tage" therefore includes today and the six days before
/// it, whole days each.
enum HistoryRange { all, today, week, month }

String historyRangeTitle(HistoryRange range) => switch (range) {
      HistoryRange.all => 'Alle',
      HistoryRange.today => 'Heute',
      HistoryRange.week => '7 Tage',
      HistoryRange.month => '30 Tage',
    };

/// The same, in the middle of a sentence - for the question asked before
/// anything is tidied away.
String historyRangePhrase(HistoryRange range) => switch (range) {
      HistoryRange.all => 'aus dem ganzen Verlauf',
      HistoryRange.today => 'von heute',
      HistoryRange.week => 'aus den letzten 7 Tagen',
      HistoryRange.month => 'aus den letzten 30 Tagen',
    };

/// The earliest moment [range] still shows, or null for no limit.
///
/// Built by counting days on a [DateTime] rather than subtracting
/// milliseconds: an hour goes missing twice a year, and a boundary that
/// lands at 23:00 instead of midnight would quietly take a day in or leave
/// one out.
int? historySince(HistoryRange range, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  int msOf(int daysBack) =>
      DateTime(today.year, today.month, today.day - daysBack)
          .millisecondsSinceEpoch;
  return switch (range) {
    HistoryRange.all => null,
    HistoryRange.today => msOf(0),
    HistoryRange.week => msOf(6),
    HistoryRange.month => msOf(29),
  };
}

/// Reads a stored name back, unknown ones falling to [HistoryRange.all].
///
/// Not persisted today - the log is a view, not a setting - but the same
/// caution the other enums get, so it can be stored later without a trap.
HistoryRange historyRangeByName(String name) {
  for (final range in HistoryRange.values) {
    if (range.name == name) return range;
  }
  return HistoryRange.all;
}
