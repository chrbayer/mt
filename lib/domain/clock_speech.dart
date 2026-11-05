/// How a language says the time. No Flutter dependency.
library;

/// The number of spoken forms a [TaskForm.clockPhrase] task chooses from:
/// the minutes 5, 10, ... 55 in steps of five. The index of a form is the
/// answer that is stored and compared, and it is the same in every language -
/// index 0 is `:05`, index 11 is `:55`, whatever the words are called.
const int clockPhraseCount = 11;

/// The rules of telling the time out loud that differ between languages.
///
/// The **words** ("viertel nach", "halb") are text and live in the ARB files
/// (`clockPhrase05` ... `clockPhrase55`). What cannot be left to a translator
/// is the structure around them, because it decides which answer is right:
///
/// * from which phrase on the *coming* hour is named - German counts towards
///   the next hour from "5 vor halb" on, so 2:25 is "5 vor halb 3";
/// * whether the hour stands in front of the phrase or behind it.
///
/// Both are fixed per language. A box that swapped places with its
/// neighbour depending on the answer would be a puzzle of its own.
class ClockSpeech {
  /// The first phrase index (0 is `:05`) that names the coming hour instead
  /// of the one that has begun.
  final int nextHourFromIndex;

  /// Whether the hour is said before the phrase ("3 heures et quart") and
  /// therefore entered first. German and English put it last.
  ///
  /// The practice controller and the task display follow this, so a language
  /// that sets it (French will) needs no further code: the two boxes swap
  /// places, the word pad appears in the second step.
  final bool hourFirst;

  const ClockSpeech({
    required this.nextHourFromIndex,
    required this.hourFirst,
  });

  /// German: "halb 3" is 2:30, and everything from "5 vor halb" (index 4,
  /// `:25`) on counts towards the 3.
  static const ClockSpeech de = ClockSpeech(
    nextHourFromIndex: 4,
    hourFirst: false,
  );

  /// The rules for a language code. Every language the app does not know
  /// yet falls back to German, which is the only one there is for now.
  static ClockSpeech forLanguage(String code) => switch (code) {
        _ => de,
      };

  /// The hour a spoken form names for a clock showing [hour] o'clock and
  /// some minutes. From [nextHourFromIndex] on it is the coming hour:
  /// 2:30 is "halb 3", 12:45 is "viertel vor 1".
  int namedHour(int phraseIndex, int hour) =>
      phraseIndex >= nextHourFromIndex ? hour % 12 + 1 : hour;
}
