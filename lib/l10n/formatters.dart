/// Times, amounts and dates as text, in the language of the app.
///
/// The domain hands over numbers (`int` milliseconds, cents, `DateTime`); how
/// they are written - the decimal separator, the position of the euro sign,
/// "heute" or "today" - is a matter of language and lives here, in one place.
/// The calling convention is the same everywhere: the [AppLocalizations] first,
/// so the active locale decides.
///
/// Dates and times use `DateFormat`, which needs the locale's symbols loaded.
/// In the app `GlobalMaterialLocalizations` does that; a plain unit test has
/// to call `initializeDateFormatting` itself.
library;

import 'package:intl/intl.dart';

import '../domain/assignment.dart';
import '../domain/practice_limit.dart';
import 'l10n.dart';

/// The decimal separator of the language: `,` in German, `.` in English.
String _decimalSeparator(AppLocalizations l10n) =>
    NumberFormat.decimalPattern(l10n.localeName).symbols.DECIMAL_SEP;

/// A number with one decimal place. Rounded by `toStringAsFixed` as it always
/// was, then only the separator is swapped - the formatting must not change a
/// time that has been shown for years by rounding it differently.
String _oneDecimal(AppLocalizations l10n, double value) =>
    value.toStringAsFixed(1).replaceAll('.', _decimalSeparator(l10n));

/// `m:ss min` for a minute or more, otherwise `s,d s` - short and readable
/// for children.
String formatDuration(AppLocalizations l10n, int milliseconds) {
  final totalSeconds = milliseconds / 1000;
  if (totalSeconds < 60) {
    return l10n.formatSeconds(_oneDecimal(l10n, totalSeconds));
  }
  final minutes = milliseconds ~/ 60000;
  final seconds = (milliseconds % 60000) ~/ 1000;
  return l10n.formatMinutesSeconds(
      minutes, seconds.toString().padLeft(2, '0'));
}

/// Compact per-task time, always in seconds with one decimal.
String formatPerTask(AppLocalizations l10n, double milliseconds) =>
    l10n.formatSeconds(_oneDecimal(l10n, milliseconds / 1000));

/// Summed practice time over many runs: `3 h 12 min`, `42 min`, `0 min`.
String formatTotalTime(AppLocalizations l10n, int milliseconds) {
  final minutes = milliseconds ~/ 60000;
  if (minutes < 60) return l10n.commonMinutesShort(minutes);
  return l10n.formatHoursMinutes(minutes ~/ 60, minutes % 60);
}

/// `5.9.` / `9/5` - the day and month, in the order the language writes them.
String formatShortDate(AppLocalizations l10n, DateTime at) =>
    DateFormat.Md(l10n.localeName).format(at);

/// `Mi, 16.9.` / `Wed, 9/16` - short enough for a card's footer or a button.
String formatShortDay(AppLocalizations l10n, DateTime at) =>
    '${DateFormat.E(l10n.localeName).format(at)}, ${formatShortDate(l10n, at)}';

/// `14:32` or `2:32 PM` - the pattern is the language's (`formatClockPattern`).
String formatClockTime(AppLocalizations l10n, DateTime at) =>
    DateFormat(l10n.formatClockPattern, l10n.localeName).format(at);

/// `5.9. · 14:32` - short enough for a list, unambiguous within a school
/// year.
String formatDayAndTime(AppLocalizations l10n, DateTime at) =>
    l10n.formatDayAndTime(
      formatShortDate(l10n, at),
      DateFormat(l10n.formatLogTimePattern, l10n.localeName).format(at),
    );

/// `heute`, `gestern`, `vor 3 Tagen`, otherwise the date. Used for "last
/// active", where the exact minute does not matter.
String formatRelativeDay(AppLocalizations l10n, DateTime at, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final days = DateTime(today.year, today.month, today.day)
      .difference(DateTime(at.year, at.month, at.day))
      .inDays;
  return switch (days) {
    0 => l10n.relativeToday,
    1 => l10n.relativeYesterday,
    < 7 => l10n.relativeDaysAgo(days),
    _ => DateFormat.yMd(l10n.localeName).format(at),
  };
}

/// `noch 7 Minuten`, `noch eine Minute`, `gleich` - for the pause notice.
String formatRemaining(AppLocalizations l10n, Duration left) =>
    l10n.remainingMinutes(remainingMinutes(left));

/// Cents as they are written on a price tag: `350` becomes `3,50 €`.
String formatEuro(AppLocalizations l10n, int cents) => l10n.moneyAmount(
    '${cents ~/ 100}${_decimalSeparator(l10n)}'
    '${(cents % 100).toString().padLeft(2, '0')}');

/// A single coin or note, the way it is stamped on it: `50 ct`, `2 €`.
String formatPiece(AppLocalizations l10n, int cents) => cents < 100
    ? l10n.moneyCoinCents(cents)
    : l10n.moneyCoinEuros(cents ~/ 100);

/// The deadline of an assignment as a child reads it. The decision what it
/// says is the domain's ([deadlineOf]); the words are the language's, and
/// the card and the parent tab must never say it two different ways.
String formatDeadline(AppLocalizations l10n, Assignment a, {DateTime? now}) {
  final deadline = deadlineOf(a, now: now);
  String day() => formatShortDay(l10n, deadline.day!);
  return switch (deadline.kind) {
    DeadlineKind.today => l10n.deadlineToday,
    DeadlineKind.untilSunday => l10n.deadlineUntilSunday,
    DeadlineKind.stillOpen => l10n.deadlineStillOpen,
    DeadlineKind.wasOn => l10n.deadlineWas(day()),
    DeadlineKind.thisWeek => l10n.deadlineThisWeek,
    DeadlineKind.fromDay => l10n.deadlineFrom(day()),
    DeadlineKind.onDay => l10n.deadlineOn(day()),
  };
}
