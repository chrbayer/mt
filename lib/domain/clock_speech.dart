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
  /// that sets it (French, Spanish and Italian do) needs no further code: the two boxes swap
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

  /// English: "half past 2" is 2:30 as well, but the coming hour is named
  /// only from "twenty-five to" (index 6, `:35`) on: 2:35 is "twenty-five to
  /// 3". Where German already says "5 vor halb 3" at `:25`, English still
  /// says "twenty-five past 2".
  static const ClockSpeech en = ClockSpeech(
    nextHourFromIndex: 6,
    hourFirst: false,
  );

  /// French "4 h moins le quart" (3:45), Spanish "4 menos cuarto" and
  /// Italian "4 meno un quarto": the hour comes first, and from `:35` on the
  /// coming hour is named - `:30` is still "3 h et demie", `:35` already
  /// "4 h moins vingt-cinq".
  ///
  /// The texts next to the hour box must not give the answer away, so they
  /// carry no article or plural that depends on the hour ("3 h", not
  /// "trois heures"/"las tres").
  static const ClockSpeech fr = ClockSpeech(
    nextHourFromIndex: 6,
    hourFirst: true,
  );

  /// Spanish: see [fr].
  static const ClockSpeech es = ClockSpeech(
    nextHourFromIndex: 6,
    hourFirst: true,
  );

  /// Italian: see [fr].
  static const ClockSpeech it = ClockSpeech(
    nextHourFromIndex: 6,
    hourFirst: true,
  );

  /// The rules for a language code. Pass the language of the **resolved**
  /// locale (`Localizations.localeOf`), not of the device: the words on the
  /// screen are in that language, and the right answer must match them.
  /// A code the app does not know falls back to English, like the texts do.
  static ClockSpeech forLanguage(String code) => switch (code) {
        'de' => de,
        'fr' => fr,
        'es' => es,
        'it' => it,
        _ => en,
      };

  /// The hour a spoken form names for a clock showing [hour] o'clock and
  /// some minutes. From [nextHourFromIndex] on it is the coming hour:
  /// 2:30 is "halb 3", 12:45 is "viertel vor 1".
  int namedHour(int phraseIndex, int hour) =>
      phraseIndex >= nextHourFromIndex ? hour % 12 + 1 : hour;
}
