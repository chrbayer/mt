// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mathe-Trainer';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String commonMinutesShort(int n) {
    return '$n min';
  }

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get loadFailureMessage => 'That couldn\'t be loaded just now.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTaskCountHeading => 'Problems per round';

  @override
  String get settingsParentAreaNote =>
      'Clock and vibration, the default for everyone, deleting results, managing profiles and viewing the practice log: all of this is in the parent area on the start screen, protected by the PIN.';

  @override
  String get amountNoLimit => 'no limit';

  @override
  String get amountSameAsAll => 'same as for everyone';

  @override
  String amountSameAsAllWith(String value) {
    return 'same as for everyone ($value)';
  }

  @override
  String get taskCountSameEverywhere => 'same everywhere';

  @override
  String taskCountSameEverywhereWith(int count) {
    return 'same everywhere ($count)';
  }

  @override
  String get taskCountExplanationProfile =>
      'The most specific one wins: an open assignment first, then what was last chosen for a lesson, then this setting, then the default for everyone.';

  @override
  String get taskCountExplanationGlobal =>
      'The most specific one wins: an open assignment first, then what was last chosen for a lesson, then the profile\'s default, then this setting.';

  @override
  String get soundTestRunning => 'Playing …';

  @override
  String get soundTestButton => 'Test sound (10 clicks)';

  @override
  String soundTestAllPlayed(int played, int expected) {
    return '$played of $expected clicks played. If you heard nothing, check the volume of the device.';
  }

  @override
  String soundTestSomePlayed(int played, int expected) {
    return 'Only $played of $expected clicks played - the sound cuts out on this device.';
  }

  @override
  String soundTestUnavailable(String error) {
    return 'Sound is not available on this device:\n$error';
  }

  @override
  String get recommendShaky => 'It was shaky last time';

  @override
  String get recommendFresh => 'You have never practiced this';

  @override
  String get recommendStale => 'Not practiced for a long time';

  @override
  String get pauseDayDoneTitle => 'That\'s enough for today!';

  @override
  String pauseDayDoneText(int minutes) {
    return 'You did $minutes minutes of math today. We\'ll go on tomorrow.';
  }

  @override
  String get pauseBreakTitle => 'Break time!';

  @override
  String pauseBreakText(int minutes, String clock, String left) {
    return 'You practiced for $minutes minutes in a row. Back at $clock - $left.';
  }

  @override
  String pauseClock(String time) {
    return '$time';
  }

  @override
  String get runHintTooShort =>
      'Doesn\'t count: no stars, no bolts, no leaderboard.';

  @override
  String runHintUsedUpToday(int count) {
    return 'Already counted $count× today - you can keep practicing, but it won\'t count anymore.';
  }

  @override
  String runHintRemaining(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes more minutes, then a break.',
      one: 'One more minute, then a break.',
      zero: 'A break is coming up.',
    );
    return '$_temp0';
  }

  @override
  String get assignmentGoalDone => 'Assignment complete!';

  @override
  String assignmentGoalCounts(int done, int runs) {
    return 'Counts for your assignment: $done of $runs';
  }

  @override
  String get assignmentGoalNotEnough =>
      'That\'s not enough for your assignment yet:';

  @override
  String get assignmentTileDone => 'done';

  @override
  String get todayHeading => 'Practiced today';

  @override
  String get todayNothingYet => 'nothing yet';

  @override
  String todayNothingOfLimit(int limit) {
    return 'nothing yet of $limit min';
  }

  @override
  String todayTimeOfLimit(String time, int limit) {
    return '$time of $limit min';
  }

  @override
  String get progressChartEmpty =>
      'From your second round on, your learning curve appears here.';

  @override
  String starRowEarnedOf(int earned, int possible) {
    return '$earned of $possible';
  }

  @override
  String get adminSessionClosed => 'Parent area closed.';

  @override
  String get taskClock24Question => 'What time is it? Use the 24-hour clock.';

  @override
  String get backupShareSubject => 'Mathe-Trainer backup';

  @override
  String backupExportFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get backupImportConfirmTitle => 'Restore backup?';

  @override
  String get backupImportConfirmText =>
      'All profiles and results on this device will be replaced by the backup. What is here now will be gone.';

  @override
  String get backupReplace => 'Replace';

  @override
  String get backupFileTypeLabel => 'Backup';

  @override
  String backupImported(int users, int sessions) {
    return '$users profiles and $sessions rounds restored.';
  }

  @override
  String backupImportFailed(String error) {
    return 'Restoring failed: $error';
  }

  @override
  String get backupHeading => 'Data';

  @override
  String get backupIntro =>
      'All profiles, results and settings as a file. Keep it somewhere other than the tablet - a reset device takes everything with it.';

  @override
  String get backupCreate => 'Create backup';

  @override
  String get backupRestore => 'Restore backup';

  @override
  String get backupNever => 'Never backed up.';

  @override
  String backupLast(String when) {
    return 'Last backup: $when.';
  }

  @override
  String backupLastOverdue(String when) {
    return 'Last backup: $when. That was a while ago.';
  }

  @override
  String get pinTitleVerify => 'Parent area';

  @override
  String get pinTitleSetup => 'Set up parent area';

  @override
  String get pinHintEnter => 'Enter PIN';

  @override
  String pinHintChoose(int length) {
    return 'Choose a PIN of $length digits';
  }

  @override
  String get pinHintRepeat => 'Repeat PIN';

  @override
  String get pinWrong => 'Wrong PIN.';

  @override
  String get pinMismatch => 'The two entries were different.';

  @override
  String get startWhatDoesItMean => 'What does that mean?';

  @override
  String startExample(String example) {
    return 'For example:  $example';
  }

  @override
  String startAssignmentGoal(int count) {
    return 'For your assignment: $count problems';
  }

  @override
  String get startHowMany => 'How many problems?';

  @override
  String startBoltsFrom(String time) {
    return 'from $time per problem';
  }

  @override
  String get startGo => 'Let\'s go';

  @override
  String get startLeaderboard => 'Leaderboard';

  @override
  String get commonPerTask => 'per problem';

  @override
  String get commonErrors => 'Mistakes';

  @override
  String get commonTasks => 'Problems';

  @override
  String leaderboardTitle(String lesson) {
    return 'Leaderboard · $lesson';
  }

  @override
  String leaderboardEmpty(int min) {
    return 'No results yet.\nAt least $min problems count for the leaderboard.';
  }

  @override
  String leaderboardScoreExplanation(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds',
      one: '1 second',
    );
    return 'The score is the time per problem, plus $_temp0 for every wrong attempt. So guessing doesn\'t pay, and rounds with different numbers of problems stay comparable.';
  }

  @override
  String statsTitle(String name) {
    return 'Stats · $name';
  }

  @override
  String get statsEmpty => 'No finished rounds yet.';

  @override
  String statsLearningCurve(String lesson) {
    return 'Learning curve · $lesson';
  }

  @override
  String get statsLearningCurveSub => 'Seconds per problem, round by round';

  @override
  String get statsHardest => 'These problems take the longest';

  @override
  String get statsHeadStars => 'Stars';

  @override
  String get statsHeadBest => 'Best';

  @override
  String get statsHeadAverage => 'Ø time';

  @override
  String get statsHeadRuns => 'Rounds';

  @override
  String get statsTooFewData => 'Not enough data yet.';

  @override
  String get globalStatsTitle => 'All results';

  @override
  String get globalStatsTabOverview => 'Overview';

  @override
  String get globalStatsTabLeaderboards => 'Leaderboards';

  @override
  String get globalStatsNoProfiles => 'No profiles yet.';

  @override
  String globalStatsActivityHeading(int days) {
    return 'Practiced in the last $days days';
  }

  @override
  String get globalStatsActivitySub =>
      'Minutes per day, each child in their color';

  @override
  String globalStatsNoLeaderboards(int min) {
    return 'No leaderboards yet.\nA round counts from $min problems.';
  }

  @override
  String get globalStatsNotPlayed => 'Not practiced yet.';

  @override
  String globalStatsRounds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'rounds',
      one: 'round',
    );
    return '$_temp0';
  }

  @override
  String get globalStatsPractised => 'practiced';

  @override
  String globalStatsStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0 in a row';
  }

  @override
  String globalStatsLastPlayed(String when) {
    return 'last $when';
  }

  @override
  String get globalStatsNoActivity =>
      'Nobody has practiced in the last few weeks.';

  @override
  String get profilesTitle => 'Who\'s up?';

  @override
  String get profilesAllResults => 'All results';

  @override
  String get profilesDuel => 'Duel';

  @override
  String get profilesParents => 'Parents';

  @override
  String get profilesNone => 'No profile yet. Tap “New” to get started.';

  @override
  String profilesLockedTitle(String name) {
    return '$name is taking a break';
  }

  @override
  String get profilesLockedText =>
      'This profile is locked for now. All stars, bolts and best times are kept - they are back as soon as the parents unlock it.';

  @override
  String get profilesLockedOk => 'Got it';

  @override
  String get profilesAllDone => 'all done';

  @override
  String profilesTodo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count assignments',
      one: '1 assignment',
    );
    return '$_temp0';
  }

  @override
  String get profilesEditLook => 'Change picture and color';

  @override
  String get profilesNew => 'New';

  @override
  String get profileEditorNew => 'New profile';

  @override
  String get profileEditorChangeName => 'Change name';

  @override
  String get profileEditorNameLabel => 'Name';

  @override
  String get profileEditorNext => 'Next';

  @override
  String get profileEditorLookTitle => 'Picture and color';

  @override
  String get profileEditorPicture => 'Picture';

  @override
  String get profileEditorColor => 'Color';

  @override
  String get profileEditorSave => 'Save';

  @override
  String get duelTitle => 'Duel';

  @override
  String get duelNeedTwoProfiles => 'A duel needs at least two profiles.';

  @override
  String get duelWhoPlays => 'Who\'s playing?';

  @override
  String duelPlayerLocked(String avatar, String name) {
    return '$avatar  $name · locked';
  }

  @override
  String duelPlayerOnBreak(String avatar, String name) {
    return '$avatar  $name · break';
  }

  @override
  String duelPlayer(String avatar, String name) {
    return '$avatar  $name';
  }

  @override
  String get duelWhichTasks => 'Which problems?';

  @override
  String get duelPickTwo => 'Pick at least two children.';

  @override
  String duelLessonChip(String title, String example) {
    return '$title  ·  $example';
  }

  @override
  String get duelStart => 'Start duel';

  @override
  String duelPosition(int position, int total) {
    return '$position of $total';
  }

  @override
  String duelYourTurn(String name) {
    return '$name\'s turn';
  }

  @override
  String duelLessonAndGroup(String lesson, String group) {
    return '$lesson · $group';
  }

  @override
  String get duelReady => 'Ready';

  @override
  String get duelAbort => 'Cancel duel';

  @override
  String duelResultTitle(String lesson) {
    return 'Duel · $lesson';
  }

  @override
  String get duelSameTasks => 'Everyone had the same problems.';

  @override
  String get duelDone => 'Done';

  @override
  String get duelWin => 'Win!';

  @override
  String get commonBackToLessons => 'Back to the lessons';

  @override
  String get resultDone => 'Well done!';

  @override
  String resultDoneName(String name) {
    return 'Well done, $name!';
  }

  @override
  String resultNextBolt(int n, String time) {
    return 'Bolt $n from $time per problem';
  }

  @override
  String get resultForThisLesson => 'for this lesson';

  @override
  String get resultInTotal => 'in total';

  @override
  String get resultMetricTasks => 'Problems';

  @override
  String get resultMetricTotalTime => 'Total time';

  @override
  String get resultMetricPerTask => 'Per problem';

  @override
  String get resultMetricErrors => 'Mistakes';

  @override
  String resultPenalty(String penalty, int count, int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wrong attempts',
      one: '1 wrong attempt',
    );
    String _temp1 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds seconds',
      one: '1 second',
    );
    return 'This includes a time penalty of $penalty for $_temp0 - $_temp1 for each.';
  }

  @override
  String resultStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0 of practice in a row!';
  }

  @override
  String get resultAgain => 'Again';

  @override
  String get resultLeaderboard => 'Leaderboard';

  @override
  String get resultOtherLesson => 'Other lesson';

  @override
  String get resultFirstRun =>
      'That was your first round here -\nthis time is your record from now on.';

  @override
  String get resultSameSpeed => 'Exactly as fast as last time.';

  @override
  String resultFaster(String delta) {
    return '$delta faster per problem than last time!';
  }

  @override
  String resultSlower(String delta) {
    return '$delta slower per problem than last time.';
  }

  @override
  String get practiceAbortTitle => 'End practice?';

  @override
  String get practiceAbortText =>
      'This round will not count for the leaderboard.';

  @override
  String get practiceKeepGoing => 'Keep going';

  @override
  String get practiceAbortConfirm => 'End';

  @override
  String get practiceAbortTooltip => 'End practice';

  @override
  String get practicePause => 'Pause';

  @override
  String get practicePauseNote => 'The clock has stopped.';

  @override
  String get practiceResume => 'Continue';

  @override
  String get lessonsFilterTooltip => 'Hide finished lessons';

  @override
  String get lessonsHideDoneAssignments => 'Hide completed assignments';

  @override
  String get lessonsStatsLabel => 'Stats';

  @override
  String get lessonsSettingsTooltip => 'Settings';

  @override
  String get lessonsSwitchLabel => 'Switch';

  @override
  String get lessonsNoGroup =>
      'No area is unlocked for this profile yet.\nThat can be changed in the parent area.';

  @override
  String get lessonsNothingLeftTitle => 'All done!';

  @override
  String get lessonsNothingLeftText =>
      'What you can do is hidden right now. The filter at the top brings back the whole catalog.';

  @override
  String get lessonsRecommendGo => 'Go';

  @override
  String lessonsRecommendTitle(String lesson, String group) {
    return '$lesson · $group';
  }

  @override
  String get lessonsAssignmentsHeading => 'Your assignments';

  @override
  String get lessonsAssignmentsAllDone =>
      'All done! Completed assignments are hidden.';

  @override
  String get lessonsNotPractised => 'not practiced yet';

  @override
  String lessonsPractisedTimes(int count) {
    return 'practiced $count×';
  }

  @override
  String get adminTitle => 'Parent area';

  @override
  String get adminTabHistory => 'Practice log';

  @override
  String get adminTabManagement => 'Manage';

  @override
  String get adminTabAssignments => 'Assignments';

  @override
  String get adminTabSettings => 'Settings';

  @override
  String get adminFilterAll => 'All';

  @override
  String get adminShowDeleted => 'Deleted';

  @override
  String adminHistoryTruncated(int limit) {
    return 'The last $limit rounds are shown. A shorter period shows the rest.';
  }

  @override
  String adminCleanupAll(int count) {
    return 'Clean up aborted rounds ($count)';
  }

  @override
  String adminCleanupOne(String name, int count) {
    return 'Clean up $name\'s aborted rounds ($count)';
  }

  @override
  String get adminHistoryEmpty => 'No rounds yet.';

  @override
  String get adminDeleteRunTitle => 'Delete this round?';

  @override
  String adminDeleteRunText(String user, String lesson, String when) {
    return '$user · $lesson · $when';
  }

  @override
  String get adminRunDeleted => 'Round deleted.';

  @override
  String get adminUndo => 'Undo';

  @override
  String get adminThisChild => 'this child';

  @override
  String get adminWhoAll => 'of all children';

  @override
  String adminWhoOne(String name) {
    return 'of $name';
  }

  @override
  String adminCleanupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Clean up $count aborted rounds?',
      one: 'Clean up one aborted round?',
    );
    return '$_temp0';
  }

  @override
  String adminCleanupText(String whose, String range) {
    return 'The aborted rounds $whose $range will disappear. They never counted for stars, bolts or a leaderboard - the practice time stays counted.';
  }

  @override
  String get adminCleanupConfirm => 'Clean up';

  @override
  String adminCleanedUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count aborted rounds cleaned up.',
      one: 'One aborted round cleaned up.',
    );
    return '$_temp0';
  }

  @override
  String adminHistoryLessonLine(String lesson, String group) {
    return '$lesson  ·  $group';
  }

  @override
  String adminAbortedAfter(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count problems',
      one: '1 problem',
    );
    return 'aborted after $_temp0';
  }

  @override
  String get adminRestore => 'Restore';

  @override
  String get adminDeleteRun => 'Delete round';

  @override
  String get adminProfiles => 'Profiles';

  @override
  String get adminNewProfile => 'New profile';

  @override
  String get adminProfilesNote =>
      'Tapping a child opens everything that belongs to them: areas, times, lock, renaming and deleting. Every child can change their picture and color themselves on the start screen.';

  @override
  String get adminPinHeading => 'PIN';

  @override
  String get adminPinNote =>
      'Protects this area. Forgotten it? Then the only way out is to delete the app data in the Android settings - which also deletes all results.';

  @override
  String get adminChangePin => 'Change PIN';

  @override
  String get adminGroupsNone => 'No area unlocked';

  @override
  String get adminGroupsAll => 'All areas';

  @override
  String adminGroupsSome(int n, int total) {
    return '$n of $total areas';
  }

  @override
  String get adminLocked => 'Locked';

  @override
  String get adminNoReview => 'no review';

  @override
  String get profileSettingsDiscardTitle => 'Discard changes?';

  @override
  String profileSettingsDiscardText(String name) {
    return 'The settings for $name were changed but not saved yet.';
  }

  @override
  String get profileSettingsDiscard => 'Discard';

  @override
  String get profileSettingsSave => 'Save';

  @override
  String get profileSettingsSectionPractice => 'Practice';

  @override
  String get profileSettingsGroups => 'Areas';

  @override
  String get profileSettingsGroupsNote =>
      'Areas that are turned off no longer appear on the practice screen. Results already earned are kept.';

  @override
  String get profileSettingsNoGroup =>
      'Without a single area the child cannot practice.';

  @override
  String get profileSettingsHideDoneHeading => 'Hide finished lessons';

  @override
  String get profileSettingsHideDoneNote =>
      'Trims the catalog by what is already solid. The child can change this on the practice screen too - it is here so it can be set up once. The stricter level leaves the First Steps in place: nothing is timed there, so there are no bolts to earn.';

  @override
  String get profileSettingsHideDoneAssignments => 'Hide completed assignments';

  @override
  String get profileSettingsHideDoneAssignmentsNote =>
      'Finished cards disappear before the end of the day or week. Otherwise they stay there, ticked off.';

  @override
  String get profileSettingsTaskCount => 'Problems per round';

  @override
  String get profileSettingsReview => 'Repeat hard problems';

  @override
  String get profileSettingsReviewNote =>
      'A quarter of every round is made up of what took a long time or went wrong last time.';

  @override
  String get profileSettingsSectionTime => 'Time and scoring';

  @override
  String get profileSettingsStretch => 'Practice time in a row';

  @override
  String get profileSettingsStretchNote =>
      'After this time there is a break. A running round is never interrupted - only the next start is blocked. The time keeps counting as long as the break has not been fully taken.';

  @override
  String get profileSettingsBreakLength => 'How long is the break?';

  @override
  String get profileSettingsDaily => 'And per day in total';

  @override
  String get profileSettingsDailyNote =>
      'Adds up all rounds of the day, breaks or not. Once the time is used up, it continues the next day.';

  @override
  String get profileSettingsScoredRuns => 'Scored rounds per lesson and day';

  @override
  String get profileSettingsScoredRunsNote =>
      'After that the same lesson can still be practiced, it just no longer brings a best time, stars or bolts. Practice time and the log keep counting.';

  @override
  String get profileSettingsSectionTidy => 'Tidy up';

  @override
  String get profileSettingsTidyNote =>
      'These buttons take effect immediately - they don\'t wait for “Save”.';

  @override
  String get profileSettingsRename => 'Rename';

  @override
  String get profileSettingsGiveBackStars => 'Give back stars …';

  @override
  String get profileSettingsResetResults => 'Delete results';

  @override
  String get profileSettingsDeleteProfile => 'Delete profile';

  @override
  String profileSettingsResetTitle(String name) {
    return 'Delete $name\'s results?';
  }

  @override
  String get profileSettingsResetText =>
      'Best times, learning curve and log are lost. The profile itself stays.';

  @override
  String profileSettingsDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get profileSettingsDeleteText =>
      'The profile and all results are removed.';

  @override
  String profileSettingsGroupSummary(int count, String example) {
    return '$count lessons · e.g. $example';
  }

  @override
  String get profileSettingsLockTitle => 'Lock profile for now';

  @override
  String get profileSettingsLockNote =>
      'The profile can then not be opened or invited to a duel. Nothing is lost: stars, bolts and best times are back unchanged after unlocking.';

  @override
  String get globalSettingsClock => 'Show clock during practice';

  @override
  String get globalSettingsClockNote =>
      'The time is always measured. But seeing it makes some children nervous - so it is off by default.';

  @override
  String get globalSettingsHaptics => 'Vibrate on key press';

  @override
  String get globalSettingsHapticsNote => 'A short buzz on every key press.';

  @override
  String get globalSettingsSounds => 'Play sounds';

  @override
  String get globalSettingsSoundsNote =>
      'A short sound for right, a different one for wrong, and a soft click under every key. On a tablet lying flat you hardly feel the vibration.';

  @override
  String get globalSettingsTaskCount => 'Problems per round for everyone';

  @override
  String get globalSettingsTaskCountNote =>
      'For a single child the default is under “Manage”, in their profile - and the child can change it in their own settings.';

  @override
  String get globalSettingsLimits => 'Practice time for everyone';

  @override
  String get globalSettingsLimitsNote =>
      'Applies to every child without a default of their own. A running round is never interrupted - only the next start is blocked.';

  @override
  String get globalSettingsStretch => 'In a row, then a break';

  @override
  String get globalSettingsBreakLength => 'How long is the break?';

  @override
  String get globalSettingsDaily => 'And per day in total';

  @override
  String get globalSettingsScoredRuns => 'Scored rounds per lesson and day';

  @override
  String get globalSettingsScoredRunsNote =>
      'After that the same lesson can still be practiced, it just no longer brings a best time, stars or bolts. That takes away the reason to repeat the easiest lesson until the time is right. Practice time and the log keep counting.';

  @override
  String resetStarsTitle(String group) {
    return 'Reset stars in “$group”?';
  }

  @override
  String resetStarsText(String name) {
    return '$name can earn them again afterwards. Best times, bolts, learning curve and leaderboards stay unchanged - only the stars of this area are affected.';
  }

  @override
  String get resetStarsConfirm => 'Reset';

  @override
  String resetStarsHeading(String name) {
    return '$name\'s stars';
  }

  @override
  String get resetStarsNote =>
      'Only the stars are reset. The times stay - best times, bolts, learning curve and leaderboards are exactly as before.';

  @override
  String get resetStarsDone => 'Done';

  @override
  String resetStarsGroupLine(int earned, int possible) {
    return '$earned of $possible stars';
  }

  @override
  String get assignmentsAll => 'All';

  @override
  String get assignmentsNew => 'New assignment';

  @override
  String get assignmentsHideFinished => 'Hide completed';

  @override
  String assignmentsHiddenCount(int count) {
    return '$count hidden';
  }

  @override
  String get assignmentsEmpty => 'No assignments yet.';

  @override
  String get assignmentsNoneOpen =>
      'No open assignments. Completed ones are hidden.';

  @override
  String get assignmentsDaily => 'daily';

  @override
  String get assignmentsWeekly => 'weekly';

  @override
  String get assignmentsCarriesOver => 'carries over';

  @override
  String assignmentsLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lessons',
      one: '1 lesson',
    );
    return '$_temp0';
  }

  @override
  String get assignmentsEdit => 'Edit';

  @override
  String get assignmentsEnd => 'End';

  @override
  String get assignmentsRepeat => 'Assign again';

  @override
  String get assignmentsDelete => 'Delete assignment';

  @override
  String assignmentsRunsOfTasks(int runs, int tasks) {
    return '$runs× $tasks problems';
  }

  @override
  String assignmentsMinStars(int count) {
    return 'min. $count ★';
  }

  @override
  String assignmentsMinBolts(int count) {
    return 'min. $count ⚡';
  }

  @override
  String get assignmentsNoClosedPeriod => 'No finished period yet';

  @override
  String assignmentsMetOf(int met, int total, String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'daily': 'days',
      'weekly': 'weeks',
      'other': 'weeks',
    });
    return 'Done on $met of $total $_temp0';
  }

  @override
  String assignmentsBefore(int met, int total, String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'daily': 'days',
      'weekly': 'weeks',
      'other': 'weeks',
    });
    return 'before that $met of $total $_temp0';
  }

  @override
  String get assignmentsVerdictMet => 'Done';

  @override
  String get assignmentsVerdictPending => 'Still open';

  @override
  String get assignmentsVerdictLate => 'Missed, made up later';

  @override
  String get assignmentsVerdictMissed => 'Missed';

  @override
  String get editorTitleEdit => 'Edit assignment';

  @override
  String get editorTitleAgain => 'Assign again';

  @override
  String get editorTitleNew => 'New assignment';

  @override
  String get editorChild => 'Child';

  @override
  String get editorUnknownChild => 'Unknown child';

  @override
  String get editorLessons => 'Lessons';

  @override
  String get editorLessonsNote =>
      'Several are possible. Each of them must be completed for the assignment to be done.';

  @override
  String get editorNoLesson =>
      'Without a single lesson there is nothing to assign.';

  @override
  String get editorPeriod => 'Period';

  @override
  String get editorOneDay => 'one day';

  @override
  String get editorOneWeek => 'one week';

  @override
  String get editorRepetition => 'Repeat';

  @override
  String get editorEveryTime => 'every time';

  @override
  String get editorOnce => 'once';

  @override
  String get editorDailyNote => 'New every day, due at the end of the day.';

  @override
  String get editorWeeklyNote => 'New every week, due on Sunday evening.';

  @override
  String editorOnDay(String day) {
    return 'On $day';
  }

  @override
  String editorInWeek(String day) {
    return 'In the week from $day';
  }

  @override
  String get editorPickDay => 'Pick a day …';

  @override
  String get editorCarryOver => 'Carry over if not done';

  @override
  String get editorCarryOverNote =>
      'The assignment then stays until it is done. The day itself still counts as missed - the stats show when practice happened, not what was meant.';

  @override
  String get editorRuns => 'Rounds';

  @override
  String get editorTasksPerRun => 'Problems per round';

  @override
  String get editorMinStars => 'Minimum stars';

  @override
  String get editorMinBolts => 'Minimum bolts';

  @override
  String get editorNoRequirement => 'no requirement';

  @override
  String get editorSave => 'Save';

  @override
  String get editorCreate => 'Create';

  @override
  String get groupFirstSteps => 'First Steps';

  @override
  String get groupUpTo10 => 'Up to 10';

  @override
  String get groupUpTo20 => 'Up to 20';

  @override
  String get groupUpTo100 => 'Up to 100';

  @override
  String get groupUpTo1000 => 'Up to 1000';

  @override
  String get groupWithThousands => 'With Thousands';

  @override
  String get groupTimesTables => 'Times Tables';

  @override
  String get groupReverseTimesTables => 'Times Tables Backwards';

  @override
  String get groupTimesAndDivision => 'Multiply and Divide';

  @override
  String get groupEveryday => 'Time and Money';

  @override
  String get lessonAddPlainTitle => 'Plus without crossing ten';

  @override
  String get lessonAddPlainBigTitle => 'Plus without regrouping';

  @override
  String get lessonAddPlainDesc =>
      'The ones stay under 10 together - nothing has to be carried.';

  @override
  String get lessonAddPlainBigDesc =>
      'No place overflows - neither the ones nor the tens.';

  @override
  String get lessonAddCarryTitle => 'Plus crossing ten';

  @override
  String get lessonAddCarryBigTitle => 'Plus with regrouping';

  @override
  String get lessonAddCarryDesc =>
      'The ones add up to 10 or more - a ten moves on.';

  @override
  String get lessonAddCarryBigDesc =>
      'The ones or the tens overflow - something has to be carried.';

  @override
  String get lessonSubPlainTitle => 'Minus without crossing ten';

  @override
  String get lessonSubPlainBigTitle => 'Minus without regrouping';

  @override
  String get lessonSubPlainDesc =>
      'Every digit on top is big enough - no ten has to be broken up.';

  @override
  String get lessonSubPlainBigDesc =>
      'Every digit on top is big enough - nothing has to be broken up.';

  @override
  String get lessonSubBorrowTitle => 'Minus crossing ten';

  @override
  String get lessonSubBorrowBigTitle => 'Minus with regrouping';

  @override
  String get lessonSubBorrowDesc =>
      'The ones on top are not enough - a ten has to be broken up.';

  @override
  String get lessonSubBorrowBigDesc =>
      'A place on top is not enough - a ten or a hundred has to be broken up.';

  @override
  String get lessonPlusGapTitle => 'Plus with a missing number';

  @override
  String get lessonMinusGapTitle => 'Minus with a missing number';

  @override
  String get lessonGapDesc =>
      'Find the number that is missing to make the problem true.';

  @override
  String get lessonMixedTitle => 'Plus and minus mixed';

  @override
  String get lessonMixedDesc =>
      'Plus and minus alternate at random, with and without crossing ten.';

  @override
  String lessonTimesTableTitle(int n) {
    return '$n times table';
  }

  @override
  String lessonTimesTableDesc(int n) {
    return 'Every problem from the $n times table, both ways: $n · 4 as well as 4 · $n.';
  }

  @override
  String lessonReverseTableTitle(int n) {
    return '$n times table backwards';
  }

  @override
  String lessonReverseTableDesc(int n, int product) {
    return 'Divided by $n. Every problem is the reverse of one from the $n times table: $n · 4 = $product becomes $product : $n = 4.';
  }

  @override
  String get lessonPartnersOfTenTitle => 'Number bonds to 10';

  @override
  String get lessonPartnersOfTenDesc =>
      'Two numbers are partners when they make exactly 10 together: 1 and 9, 2 and 8, 3 and 7. You are asked both ways - from 3 to 7 as well as from 7 to 3.';

  @override
  String get lessonAdd10Title => 'Plus up to 10';

  @override
  String get lessonAdd10Desc => 'Adding up without going past 10.';

  @override
  String get lessonSub10Title => 'Minus up to 10';

  @override
  String get lessonSub10Desc => 'Taking away within 10.';

  @override
  String get lessonMix10Desc => 'Plus and minus alternate at random.';

  @override
  String get lessonTimesAllTitle => 'All tables mixed';

  @override
  String get lessonTimesAllDesc => 'The whole small times table, all mixed up.';

  @override
  String get lessonDivPlainTitle => 'All tables backwards';

  @override
  String get lessonDivPlainDesc =>
      'Divided by everything, all mixed up. Every problem works out evenly - it is the reverse of a times table problem.';

  @override
  String get lessonDivRemainderTitle => 'Division with remainder';

  @override
  String get lessonDivRemainderDesc =>
      'There is always something left over. Enter the result first, then the remainder.';

  @override
  String get lessonTimesGapTitle => 'Times with a missing number';

  @override
  String get lessonTimesGapDesc =>
      'Which number do you multiply by to make it true?';

  @override
  String get lessonDivGapTitle => 'Divide with a missing number';

  @override
  String get lessonDivGapDesc =>
      'Which number do you divide by to make it true?';

  @override
  String get lessonMulTensTitle => 'Times with tens';

  @override
  String get lessonMulTensDesc =>
      'The times table with a zero behind it: 3 · 4 = 12, so 30 · 4 = 120.';

  @override
  String get lessonMulTwoDigitTitle => 'Times beyond the times table';

  @override
  String get lessonMulTwoDigitDesc =>
      'Multiply a two-digit number, for example 14 · 6.';

  @override
  String get lessonDivTwoDigitTitle => 'Divide beyond the times table';

  @override
  String get lessonDivTwoDigitDesc =>
      'The result is bigger than ten, for example 96 : 6.';

  @override
  String get lessonMulDivMixedTitle => 'Times and divide mixed';

  @override
  String get lessonMulDivMixedDesc =>
      'Multiplying and dividing alternate at random.';

  @override
  String get lessonPunktVorStrichTitle => 'Order of operations';

  @override
  String get lessonPunktVorStrichDesc =>
      'Times and divide come before plus and minus - even when they come last: in 40 − 3 · 6, the 3 · 6 is worked out first.';

  @override
  String get lessonCountPicturesTitle => 'How many? (row)';

  @override
  String get lessonCountPicturesDesc =>
      'Count the pictures, one to five, neatly lined up.';

  @override
  String get lessonCountPicturesCloudTitle => 'How many? (scattered)';

  @override
  String get lessonCountPicturesCloudDesc =>
      'The same pictures, but jumbled - you have to remember what you have already counted.';

  @override
  String get lessonCountDiceTitle => 'How many dots?';

  @override
  String get lessonCountDiceDesc =>
      'One die. Soon you see the number without counting.';

  @override
  String get lessonCompareMoreTitle => 'Where are there more? (row)';

  @override
  String get lessonCompareMoreDesc =>
      'Compare two groups and enter the bigger number.';

  @override
  String get lessonCompareMoreCloudTitle => 'Where are there more? (scattered)';

  @override
  String get lessonCompareMoreCloudDesc =>
      'The same, but the pictures are jumbled.';

  @override
  String get lessonCountNextTitle => 'Which number comes next?';

  @override
  String get lessonCountNextDesc => 'The number line forwards and backwards.';

  @override
  String get lessonBeesAddTitle => 'Little bees (row)';

  @override
  String get lessonBeesAddDesc =>
      'Add two small groups of bees; never more than ten altogether.';

  @override
  String get lessonBeesAddCloudTitle => 'Little bees (scattered)';

  @override
  String get lessonBeesAddCloudDesc =>
      'The same problem, but the bees are buzzing all over the place.';

  @override
  String get lessonDiceAddTitle => 'Add two dice';

  @override
  String get lessonDiceAddDesc =>
      'Both dice show up to five dots - how many are there altogether?';

  @override
  String get lessonAddToSixTitle => 'Plus up to 6';

  @override
  String get lessonAddToSixDesc => 'Adding up, never going past six.';

  @override
  String get lessonSubToSixTitle => 'Minus up to 6';

  @override
  String get lessonSubToSixDesc => 'Taking away within six.';

  @override
  String get lessonCalcToSixTitle => 'Plus and minus up to 6';

  @override
  String get lessonCalcToSixDesc => 'Both mixed, never going past six.';

  @override
  String get lessonClockHalfTitle => 'Full and half hours';

  @override
  String get lessonClockHalfDesc =>
      'What time is it? The big hand points to the 12 or to the 6.';

  @override
  String get lessonClockQuarterTitle => 'Quarter hours';

  @override
  String get lessonClockQuarterDesc =>
      'Quarter past, half past, quarter to - the big hand points to 12, 3, 6 or 9.';

  @override
  String get lessonClockFiveTitle => 'Time to five minutes';

  @override
  String get lessonClockFiveDesc =>
      'The big hand points to one of the twelve numbers.';

  @override
  String get lessonClock24Title => 'Time with 24 hours';

  @override
  String get lessonClock24Desc =>
      'In the afternoon you keep counting: 3 o\'clock becomes 15:00. Under the clock it says what time of day it is.';

  @override
  String get lessonClockWordsTitle => 'Telling the time';

  @override
  String get lessonClockWordsDesc =>
      'How do you say the time? First tap the phrase, then the hour that is named - for \"half past 3\" that is the 3.';

  @override
  String get lessonMoneyAddTitle => 'Adding money';

  @override
  String get lessonMoneyAddDesc =>
      'Add two amounts. Enter the euros first, then the cents.';

  @override
  String get lessonMoneySubTitle => 'Taking away money';

  @override
  String get lessonMoneySubDesc => 'What is left, or what do you get back?';

  @override
  String get lessonMoneyComposeTitle => 'Make an amount';

  @override
  String get lessonMoneyComposeDesc =>
      'Make the amount from coins and notes. There are many right ways - the amount has to be exactly right in the end.';

  @override
  String get lessonMoneyChangeTitle => 'What change do I get?';

  @override
  String get lessonMoneyChangeDesc =>
      'Something costs an odd amount and you pay with a round note or coin. You need to find the change.';

  @override
  String get lessonPlaceValue100Title => 'Ones and tens';

  @override
  String get lessonPlaceValue100Desc =>
      'How many ones and tens are there? Which number is that all together? There can be more than nine ones.';

  @override
  String get lessonPlaceValue1000Title => 'Ones, tens, hundreds';

  @override
  String get lessonPlaceValue1000Desc =>
      'How many ones, tens and hundreds are there? Which number is that all together? There can be more than nine of one kind.';

  @override
  String get lessonRoundThousandsTitle => 'Full thousands';

  @override
  String get lessonRoundThousandsDesc =>
      '3000 + 4000, 8000 − 5000: calculate with whole thousands. If you can do 3 + 4, you can do this too.';

  @override
  String get lessonRoundHundredsTitle => 'Full hundreds';

  @override
  String get lessonRoundHundredsDesc =>
      '2300 + 400, 5600 − 200: calculate with whole hundreds. Here it can also go past a thousand.';

  @override
  String get lessonRoundGapTitle => 'Thousands and hundreds: missing number';

  @override
  String get lessonRoundGapDesc =>
      '3000 + ? = 7000. What is missing up to the number? Think backwards.';

  @override
  String get lessonPlaceValue10000Title => 'Ones, tens, hundreds, thousands';

  @override
  String get lessonPlaceValue10000Desc =>
      'How many ones, tens, hundreds and thousands are there? Which number is that all together? There can be more than nine of one kind.';

  @override
  String get lessonAddSub10000PlainTitle => 'Plus and minus without regrouping';

  @override
  String get lessonAddSub10000PlainDesc =>
      '4200 + 350, 6870 − 40: four-digit numbers, but without regrouping. One place at a time.';

  @override
  String taskQuestionPartner(int a) {
    return 'What goes with $a to make 10?';
  }

  @override
  String get taskQuestionClock => 'What time is it?';

  @override
  String get taskQuestionClockPhrase => 'How do you say that?';

  @override
  String taskQuestionMoneyCompose(String amount) {
    return 'Make $amount - tap the coins and notes.';
  }

  @override
  String taskQuestionChange(String price, String paid) {
    return 'It costs $price. You pay $paid. How much change do you get?';
  }

  @override
  String get taskQuestionQuantity => 'How many?';

  @override
  String get taskQuestionDiceOne => 'How many dots?';

  @override
  String get taskQuestionDiceTwo => 'How many dots altogether?';

  @override
  String get taskQuestionCompare =>
      'Where are there more? Tap the bigger number.';

  @override
  String get taskQuestionSequence => 'Which number comes next?';

  @override
  String get taskQuestionQuantityAdd => 'How many altogether?';

  @override
  String get taskQuestionPlaceValue => 'Which number is that?';

  @override
  String get taskLabelRemainder => 'Remainder';

  @override
  String get taskLabelEuro => '€';

  @override
  String get taskLabelClock => ':';

  @override
  String get taskUnitCents => 'c';

  @override
  String placeOnes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ones',
      one: '1 one',
    );
    return '$_temp0';
  }

  @override
  String placeTens(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n tens',
      one: '1 ten',
    );
    return '$_temp0';
  }

  @override
  String placeHundreds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n hundreds',
      one: '1 hundred',
    );
    return '$_temp0';
  }

  @override
  String placeThousands(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n thousands',
      one: '1 thousand',
    );
    return '$_temp0';
  }

  @override
  String taskRenderRemainder(String prefix, String answer, String second) {
    return '$prefix $answer remainder $second';
  }

  @override
  String taskRenderClock(int hour, String minute) {
    return '$hour:$minute';
  }

  @override
  String taskRenderChange(String price, String paid) {
    return '$price, paid with $paid';
  }

  @override
  String taskRenderDiceOne(int a) {
    String _temp0 = intl.Intl.pluralLogic(
      a,
      locale: localeName,
      other: '$a dots',
      one: '1 dot',
    );
    return '$_temp0';
  }

  @override
  String taskRenderDiceTwo(int a, int b) {
    return '$a + $b dots';
  }

  @override
  String get dayPartMorning => 'in the morning';

  @override
  String get dayPartNoon => 'at noon';

  @override
  String get dayPartAfternoon => 'in the afternoon';

  @override
  String get dayPartEvening => 'in the evening';

  @override
  String get clockPhrase05 => 'five past';

  @override
  String get clockPhrase10 => 'ten past';

  @override
  String get clockPhrase15 => 'quarter past';

  @override
  String get clockPhrase20 => 'twenty past';

  @override
  String get clockPhrase25 => 'twenty-five past';

  @override
  String get clockPhrase30 => 'half past';

  @override
  String get clockPhrase35 => 'twenty-five to';

  @override
  String get clockPhrase40 => 'twenty to';

  @override
  String get clockPhrase45 => 'quarter to';

  @override
  String get clockPhrase50 => 'ten to';

  @override
  String get clockPhrase55 => 'five to';

  @override
  String clockSpokenTime(String phrase, int hour) {
    return '$phrase $hour';
  }

  @override
  String get filterAllTitle => 'Show all';

  @override
  String get filterAllText => 'The whole catalog, nothing is hidden.';

  @override
  String get filterMasteredTitle => 'Hide at 3 stars';

  @override
  String get filterMasteredText =>
      'What is solid disappears from the list. What still goes wrong stays.';

  @override
  String get filterPerfectedTitle => 'Only with 3 stars and 3 bolts';

  @override
  String get filterPerfectedText =>
      'Only what is solid **and** fast disappears. What has no mistakes but is still slow stays for practice.';

  @override
  String get rangeAll => 'All';

  @override
  String get rangeToday => 'Today';

  @override
  String get rangeWeek => '7 days';

  @override
  String get rangeMonth => '30 days';

  @override
  String get rangeAllPhrase => 'from the whole log';

  @override
  String get rangeTodayPhrase => 'from today';

  @override
  String get rangeWeekPhrase => 'from the last 7 days';

  @override
  String get rangeMonthPhrase => 'from the last 30 days';

  @override
  String get backupErrorNotABackup => 'The file is not a valid backup.';

  @override
  String get backupErrorWrongApp =>
      'This file does not come from Mathe-Trainer.';

  @override
  String get backupErrorTooNew =>
      'The backup comes from a newer version of the app.';

  @override
  String formatSeconds(String value) {
    return '$value s';
  }

  @override
  String formatMinutesSeconds(int minutes, String seconds) {
    return '$minutes:$seconds min';
  }

  @override
  String formatHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String formatDayAndTime(String day, String time) {
    return '$day · $time';
  }

  @override
  String get relativeToday => 'today';

  @override
  String get relativeYesterday => 'yesterday';

  @override
  String relativeDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String remainingMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes more minutes',
      one: '1 more minute',
      zero: 'soon',
    );
    return '$_temp0';
  }

  @override
  String moneyAmount(String amount) {
    return '€$amount';
  }

  @override
  String moneyCoinCents(int n) {
    return '${n}c';
  }

  @override
  String moneyCoinEuros(int n) {
    return '€$n';
  }

  @override
  String get deadlineToday => 'today';

  @override
  String get deadlineUntilSunday => 'until Sunday';

  @override
  String get deadlineStillOpen => 'still open';

  @override
  String deadlineWas(String day) {
    return 'was $day';
  }

  @override
  String get deadlineThisWeek => 'this week';

  @override
  String deadlineFrom(String day) {
    return 'from $day';
  }

  @override
  String deadlineOn(String day) {
    return 'on $day';
  }

  @override
  String commonSecondsShort(int n) {
    return '$n s';
  }

  @override
  String commonPercent(int n) {
    return '$n%';
  }

  @override
  String get formatClockPattern => 'h:mm a';

  @override
  String get formatLogTimePattern => 'h:mm a';
}
