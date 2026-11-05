/// The words of the lesson catalogue. The domain knows lessons only by their
/// stable id (`LessonSpec.id`); what they are called and how they are
/// explained is text, and text belongs to the language.
///
/// One `switch` over the id, here, and nowhere else. A lesson added to the
/// catalogue needs entries in every `app_<lang>.arb` and a case below -
/// `test/l10n/lesson_texts_test.dart` runs over the whole catalogue and
/// fails for the one that is missing, instead of showing its id to a child.
library;

import '../domain/lesson.dart';
import 'l10n.dart';

/// Heading of a group on the lesson screen.
String groupTitle(AppLocalizations l10n, LessonGroup group) =>
    switch (group) {
      LessonGroup.firstSteps => l10n.groupFirstSteps,
      LessonGroup.upTo10 => l10n.groupUpTo10,
      LessonGroup.upTo20 => l10n.groupUpTo20,
      LessonGroup.upTo100 => l10n.groupUpTo100,
      LessonGroup.upTo1000 => l10n.groupUpTo1000,
      LessonGroup.withThousands => l10n.groupWithThousands,
      LessonGroup.timesTables => l10n.groupTimesTables,
      LessonGroup.reverseTimesTables => l10n.groupReverseTimesTables,
      LessonGroup.timesAndDivision => l10n.groupTimesAndDivision,
      LessonGroup.everyday => l10n.groupEveryday,
    };

/// The name of a lesson.
///
/// The rows of the times table are one message with the row as a parameter
/// instead of nine of them. A lesson without a text falls back to its id:
/// ugly, but a screen that shows it is better than one that throws, and the
/// catalogue test catches it long before a child does.
String lessonTitle(AppLocalizations l10n, LessonSpec lesson) {
  final row = lesson.timesTable;
  if (row != null) {
    return lesson.group == LessonGroup.reverseTimesTables
        ? l10n.lessonReverseTableTitle(row)
        : l10n.lessonTimesTableTitle(row);
  }
  return switch (lesson.id) {
    'add_20_plain' || 'add_100_plain' => l10n.lessonAddPlainTitle,
    'add_1000_plain' => l10n.lessonAddPlainBigTitle,
    'add_20_carry' || 'add_100_carry' => l10n.lessonAddCarryTitle,
    'add_1000_carry' => l10n.lessonAddCarryBigTitle,
    'sub_20_plain' || 'sub_100_plain' => l10n.lessonSubPlainTitle,
    'sub_1000_plain' => l10n.lessonSubPlainBigTitle,
    'sub_20_borrow' || 'sub_100_borrow' => l10n.lessonSubBorrowTitle,
    'sub_1000_borrow' => l10n.lessonSubBorrowBigTitle,
    'add_10_gap' || 'add_20_gap' || 'add_100_gap' || 'add_1000_gap' => l10n.lessonPlusGapTitle,
    'sub_10_gap' || 'sub_20_gap' || 'sub_100_gap' || 'sub_1000_gap' => l10n.lessonMinusGapTitle,
    'mix_20' || 'mix_100' || 'mix_1000' => l10n.lessonMixedTitle,
    'mix_10' => l10n.lessonMixedTitle,
    'partners_of_ten' => l10n.lessonPartnersOfTenTitle,
    'add_10' => l10n.lessonAdd10Title,
    'sub_10' => l10n.lessonSub10Title,
    'times_all' => l10n.lessonTimesAllTitle,
    'div_plain' => l10n.lessonDivPlainTitle,
    'div_remainder' => l10n.lessonDivRemainderTitle,
    'times_gap' => l10n.lessonTimesGapTitle,
    'div_gap' => l10n.lessonDivGapTitle,
    'mul_tens' => l10n.lessonMulTensTitle,
    'mul_two_digit' => l10n.lessonMulTwoDigitTitle,
    'div_two_digit' => l10n.lessonDivTwoDigitTitle,
    'mul_div_mixed' => l10n.lessonMulDivMixedTitle,
    'punkt_vor_strich' => l10n.lessonPunktVorStrichTitle,
    'count_pictures' => l10n.lessonCountPicturesTitle,
    'count_pictures_cloud' => l10n.lessonCountPicturesCloudTitle,
    'count_dice' => l10n.lessonCountDiceTitle,
    'compare_more' => l10n.lessonCompareMoreTitle,
    'compare_more_cloud' => l10n.lessonCompareMoreCloudTitle,
    'count_next' => l10n.lessonCountNextTitle,
    'bees_add' => l10n.lessonBeesAddTitle,
    'bees_add_cloud' => l10n.lessonBeesAddCloudTitle,
    'dice_add' => l10n.lessonDiceAddTitle,
    'add_to_six' => l10n.lessonAddToSixTitle,
    'sub_to_six' => l10n.lessonSubToSixTitle,
    'calc_to_six' => l10n.lessonCalcToSixTitle,
    'clock_half' => l10n.lessonClockHalfTitle,
    'clock_quarter' => l10n.lessonClockQuarterTitle,
    'clock_five' => l10n.lessonClockFiveTitle,
    'clock_24' => l10n.lessonClock24Title,
    'clock_words' => l10n.lessonClockWordsTitle,
    'money_add' => l10n.lessonMoneyAddTitle,
    'money_sub' => l10n.lessonMoneySubTitle,
    'money_compose' => l10n.lessonMoneyComposeTitle,
    'money_change' => l10n.lessonMoneyChangeTitle,
    'place_value_100' => l10n.lessonPlaceValue100Title,
    'place_value_1000' => l10n.lessonPlaceValue1000Title,
    'round_thousands' => l10n.lessonRoundThousandsTitle,
    'round_hundreds' => l10n.lessonRoundHundredsTitle,
    'round_gap' => l10n.lessonRoundGapTitle,
    'place_value_10000' => l10n.lessonPlaceValue10000Title,
    'add_sub_10000_plain' => l10n.lessonAddSub10000PlainTitle,
    _ => lesson.id,
  };
}

/// One sentence on what the lesson drills, shown when a child (or a parent)
/// opens it. "Übergang" is not self-explanatory.
String lessonDescription(AppLocalizations l10n, LessonSpec lesson) {
  final row = lesson.timesTable;
  if (row != null) {
    return lesson.group == LessonGroup.reverseTimesTables
        ? l10n.lessonReverseTableDesc(row, row * 4)
        : l10n.lessonTimesTableDesc(row);
  }
  return switch (lesson.id) {
    'add_20_plain' || 'add_100_plain' => l10n.lessonAddPlainDesc,
    'add_1000_plain' => l10n.lessonAddPlainBigDesc,
    'add_20_carry' || 'add_100_carry' => l10n.lessonAddCarryDesc,
    'add_1000_carry' => l10n.lessonAddCarryBigDesc,
    'sub_20_plain' || 'sub_100_plain' => l10n.lessonSubPlainDesc,
    'sub_1000_plain' => l10n.lessonSubPlainBigDesc,
    'sub_20_borrow' || 'sub_100_borrow' => l10n.lessonSubBorrowDesc,
    'sub_1000_borrow' => l10n.lessonSubBorrowBigDesc,
    'add_10_gap' || 'add_20_gap' || 'add_100_gap' || 'add_1000_gap' || 'sub_10_gap' || 'sub_20_gap' || 'sub_100_gap' || 'sub_1000_gap' => l10n.lessonGapDesc,
    'mix_20' || 'mix_100' || 'mix_1000' => l10n.lessonMixedDesc,
    'partners_of_ten' => l10n.lessonPartnersOfTenDesc,
    'add_10' => l10n.lessonAdd10Desc,
    'sub_10' => l10n.lessonSub10Desc,
    'mix_10' => l10n.lessonMix10Desc,
    'times_all' => l10n.lessonTimesAllDesc,
    'div_plain' => l10n.lessonDivPlainDesc,
    'div_remainder' => l10n.lessonDivRemainderDesc,
    'times_gap' => l10n.lessonTimesGapDesc,
    'div_gap' => l10n.lessonDivGapDesc,
    'mul_tens' => l10n.lessonMulTensDesc,
    'mul_two_digit' => l10n.lessonMulTwoDigitDesc,
    'div_two_digit' => l10n.lessonDivTwoDigitDesc,
    'mul_div_mixed' => l10n.lessonMulDivMixedDesc,
    'punkt_vor_strich' => l10n.lessonPunktVorStrichDesc,
    'count_pictures' => l10n.lessonCountPicturesDesc,
    'count_pictures_cloud' => l10n.lessonCountPicturesCloudDesc,
    'count_dice' => l10n.lessonCountDiceDesc,
    'compare_more' => l10n.lessonCompareMoreDesc,
    'compare_more_cloud' => l10n.lessonCompareMoreCloudDesc,
    'count_next' => l10n.lessonCountNextDesc,
    'bees_add' => l10n.lessonBeesAddDesc,
    'bees_add_cloud' => l10n.lessonBeesAddCloudDesc,
    'dice_add' => l10n.lessonDiceAddDesc,
    'add_to_six' => l10n.lessonAddToSixDesc,
    'sub_to_six' => l10n.lessonSubToSixDesc,
    'calc_to_six' => l10n.lessonCalcToSixDesc,
    'clock_half' => l10n.lessonClockHalfDesc,
    'clock_quarter' => l10n.lessonClockQuarterDesc,
    'clock_five' => l10n.lessonClockFiveDesc,
    'clock_24' => l10n.lessonClock24Desc,
    'clock_words' => l10n.lessonClockWordsDesc,
    'money_add' => l10n.lessonMoneyAddDesc,
    'money_sub' => l10n.lessonMoneySubDesc,
    'money_compose' => l10n.lessonMoneyComposeDesc,
    'money_change' => l10n.lessonMoneyChangeDesc,
    'place_value_100' => l10n.lessonPlaceValue100Desc,
    'place_value_1000' => l10n.lessonPlaceValue1000Desc,
    'round_thousands' => l10n.lessonRoundThousandsDesc,
    'round_hundreds' => l10n.lessonRoundHundredsDesc,
    'round_gap' => l10n.lessonRoundGapDesc,
    'place_value_10000' => l10n.lessonPlaceValue10000Desc,
    'add_sub_10000_plain' => l10n.lessonAddSub10000PlainDesc,
    _ => lesson.id,
  };
}

/// The title of a **stored** lesson id. A saved run outlives the catalogue (a
/// backup from a newer version, a lesson dropped in an update), so an id the
/// catalogue no longer has is shown as it is instead of taking the screen down.
String lessonTitleById(AppLocalizations l10n, String id) {
  final lesson = lessonByIdOrNull(id);
  return lesson == null ? id : lessonTitle(l10n, lesson);
}
