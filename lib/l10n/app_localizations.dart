import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('de')];

  /// No description provided for @appTitle.
  ///
  /// In de, this message translates to:
  /// **'Mathe-Trainer'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get commonDelete;

  /// Minutes, short, e.g. "15 min".
  ///
  /// In de, this message translates to:
  /// **'{n} min'**
  String commonMinutesShort(int n);

  /// App version in a corner of the profile screen, e.g. "Version 2.16.0".
  ///
  /// In de, this message translates to:
  /// **'Version {version}'**
  String versionLabel(String version);

  /// No description provided for @loadFailureMessage.
  ///
  /// In de, this message translates to:
  /// **'Das konnte gerade nicht geladen werden.'**
  String get loadFailureMessage;

  /// No description provided for @settingsTitle.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settingsTitle;

  /// No description provided for @settingsTaskCountHeading.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben pro Durchgang'**
  String get settingsTaskCountHeading;

  /// No description provided for @settingsParentAreaNote.
  ///
  /// In de, this message translates to:
  /// **'Uhr und Vibration, die Vorgabe für alle, Ergebnisse löschen, Profile verwalten und den Übungsverlauf ansehen: das steht im Elternbereich auf dem Startbildschirm, geschützt durch die PIN.'**
  String get settingsParentAreaNote;

  /// Value of a time limit setting: no limit.
  ///
  /// In de, this message translates to:
  /// **'ohne Grenze'**
  String get amountNoLimit;

  /// Value of a setting: same as the default for all children.
  ///
  /// In de, this message translates to:
  /// **'wie für alle'**
  String get amountSameAsAll;

  /// A setting that follows the default for all children; value is the default, e.g. "20 min".
  ///
  /// In de, this message translates to:
  /// **'wie für alle ({value})'**
  String amountSameAsAllWith(String value);

  /// Value of a setting: same as everywhere else.
  ///
  /// In de, this message translates to:
  /// **'wie überall'**
  String get taskCountSameEverywhere;

  /// Number of tasks per run when no special value is set; count is the value that applies.
  ///
  /// In de, this message translates to:
  /// **'wie überall ({count})'**
  String taskCountSameEverywhereWith(int count);

  /// No description provided for @taskCountExplanationProfile.
  ///
  /// In de, this message translates to:
  /// **'Es gilt jeweils das Genaueste: eine offene Aufgabe zuerst, sonst was zuletzt bei einer Lektion gewählt wurde, sonst diese hier, sonst die Vorgabe für alle.'**
  String get taskCountExplanationProfile;

  /// No description provided for @taskCountExplanationGlobal.
  ///
  /// In de, this message translates to:
  /// **'Es gilt jeweils das Genaueste: eine offene Aufgabe zuerst, sonst was zuletzt bei einer Lektion gewählt wurde, sonst die Vorgabe des Profils, sonst diese hier.'**
  String get taskCountExplanationGlobal;

  /// No description provided for @soundTestRunning.
  ///
  /// In de, this message translates to:
  /// **'Spielt …'**
  String get soundTestRunning;

  /// No description provided for @soundTestButton.
  ///
  /// In de, this message translates to:
  /// **'Ton testen (10 Klicks)'**
  String get soundTestButton;

  /// Result of the sound test in the parent area: played of expected click sounds ran.
  ///
  /// In de, this message translates to:
  /// **'{played} von {expected} Klicks haben gespielt. War nichts zu hören, liegt es an der Lautstärke des Geräts.'**
  String soundTestAllPlayed(int played, int expected);

  /// Result of the sound test when some clicks did not play.
  ///
  /// In de, this message translates to:
  /// **'Nur {played} von {expected} Klicks haben gespielt - der Ton bricht auf diesem Gerät ab.'**
  String soundTestSomePlayed(int played, int expected);

  /// Sound test failed; error is a technical message from the device.
  ///
  /// In de, this message translates to:
  /// **'Der Ton ist auf diesem Gerät nicht verfügbar:\n{error}'**
  String soundTestUnavailable(String error);

  /// Reason given for a recommended lesson: it went badly last time.
  ///
  /// In de, this message translates to:
  /// **'Da war es zuletzt wackelig'**
  String get recommendShaky;

  /// Reason given for a recommended lesson: never practised.
  ///
  /// In de, this message translates to:
  /// **'Das hast du noch nie geübt'**
  String get recommendFresh;

  /// Reason given for a recommended lesson: not practised for a long time.
  ///
  /// In de, this message translates to:
  /// **'Lange nicht mehr geübt'**
  String get recommendStale;

  /// No description provided for @pauseDayDoneTitle.
  ///
  /// In de, this message translates to:
  /// **'Für heute reicht es!'**
  String get pauseDayDoneTitle;

  /// Shown to a child whose daily practice time is used up; minutes is the time practised today.
  ///
  /// In de, this message translates to:
  /// **'Du hast heute {minutes} Minuten gerechnet. Morgen geht es weiter.'**
  String pauseDayDoneText(int minutes);

  /// Title when a child has practised long enough and must take a break.
  ///
  /// In de, this message translates to:
  /// **'Pause!'**
  String get pauseBreakTitle;

  /// Shown to a child who has to take a break; minutes practised in a row, clock is the time the break ends (see pauseClock), left says how long is left (see remainingMinutes).
  ///
  /// In de, this message translates to:
  /// **'Du hast {minutes} Minuten am Stück geübt. Weiter geht es um {clock} - {left}.'**
  String pauseBreakText(int minutes, String clock, String left);

  /// Time of day, e.g. "11:15 Uhr"; time is already formatted.
  ///
  /// In de, this message translates to:
  /// **'{time} Uhr'**
  String pauseClock(String time);

  /// No description provided for @runHintTooShort.
  ///
  /// In de, this message translates to:
  /// **'Zählt nicht: keine Sterne, keine Blitze, keine Bestenliste.'**
  String get runHintTooShort;

  /// The lesson has already counted for awards count times today, so another run does not count. Keep the "×".
  ///
  /// In de, this message translates to:
  /// **'Heute schon {count}× gewertet - üben geht weiter, zählen nicht mehr.'**
  String runHintUsedUpToday(int count);

  /// Hint under the task-count choice: practice time left until the break; 0 means the break is imminent.
  ///
  /// In de, this message translates to:
  /// **'{minutes, plural, =0{Gleich ist Pause.} =1{Noch eine Minute, dann ist Pause.} other{Noch {minutes} Minuten, dann ist Pause.}}'**
  String runHintRemaining(int minutes);

  /// No description provided for @assignmentGoalDone.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe geschafft!'**
  String get assignmentGoalDone;

  /// Result screen: how many of the runs an assignment asks for have been done.
  ///
  /// In de, this message translates to:
  /// **'Zählt für deine Aufgabe: {done} von {runs}'**
  String assignmentGoalCounts(int done, int runs);

  /// No description provided for @assignmentGoalNotEnough.
  ///
  /// In de, this message translates to:
  /// **'Das reicht für deine Aufgabe noch nicht:'**
  String get assignmentGoalNotEnough;

  /// No description provided for @assignmentTileDone.
  ///
  /// In de, this message translates to:
  /// **'geschafft'**
  String get assignmentTileDone;

  /// No description provided for @todayHeading.
  ///
  /// In de, this message translates to:
  /// **'Heute geübt'**
  String get todayHeading;

  /// No description provided for @todayNothingYet.
  ///
  /// In de, this message translates to:
  /// **'noch nichts'**
  String get todayNothingYet;

  /// Practised today: nothing yet, out of a daily limit given in minutes.
  ///
  /// In de, this message translates to:
  /// **'noch nichts von {limit} min'**
  String todayNothingOfLimit(int limit);

  /// Practised today: time (formatted) out of a daily limit in minutes.
  ///
  /// In de, this message translates to:
  /// **'{time} von {limit} min'**
  String todayTimeOfLimit(String time, int limit);

  /// No description provided for @progressChartEmpty.
  ///
  /// In de, this message translates to:
  /// **'Ab dem zweiten Durchgang siehst du hier deine Lernkurve.'**
  String get progressChartEmpty;

  /// Accessibility/summary of stars: earned out of possible.
  ///
  /// In de, this message translates to:
  /// **'{earned} von {possible}'**
  String starRowEarnedOf(int earned, int possible);

  /// No description provided for @adminSessionClosed.
  ///
  /// In de, this message translates to:
  /// **'Elternbereich geschlossen.'**
  String get adminSessionClosed;

  /// No description provided for @taskClock24Question.
  ///
  /// In de, this message translates to:
  /// **'Wie spät ist es? Sage es mit 24 Stunden.'**
  String get taskClock24Question;

  /// No description provided for @backupShareSubject.
  ///
  /// In de, this message translates to:
  /// **'Mathe-Trainer Sicherung'**
  String get backupShareSubject;

  /// Backup could not be created; error is a technical message.
  ///
  /// In de, this message translates to:
  /// **'Sicherung fehlgeschlagen: {error}'**
  String backupExportFailed(String error);

  /// No description provided for @backupImportConfirmTitle.
  ///
  /// In de, this message translates to:
  /// **'Sicherung einspielen?'**
  String get backupImportConfirmTitle;

  /// No description provided for @backupImportConfirmText.
  ///
  /// In de, this message translates to:
  /// **'Alle Profile und Ergebnisse auf diesem Gerät werden durch die Sicherung ersetzt. Was jetzt hier steht, ist danach weg.'**
  String get backupImportConfirmText;

  /// No description provided for @backupReplace.
  ///
  /// In de, this message translates to:
  /// **'Ersetzen'**
  String get backupReplace;

  /// No description provided for @backupFileTypeLabel.
  ///
  /// In de, this message translates to:
  /// **'Sicherung'**
  String get backupFileTypeLabel;

  /// Backup restored: number of child profiles and practice runs.
  ///
  /// In de, this message translates to:
  /// **'{users} Profile und {sessions} Durchgänge eingespielt.'**
  String backupImported(int users, int sessions);

  /// Backup could not be restored; error is a technical message.
  ///
  /// In de, this message translates to:
  /// **'Einspielen fehlgeschlagen: {error}'**
  String backupImportFailed(String error);

  /// No description provided for @backupHeading.
  ///
  /// In de, this message translates to:
  /// **'Daten'**
  String get backupHeading;

  /// No description provided for @backupIntro.
  ///
  /// In de, this message translates to:
  /// **'Alle Profile, Ergebnisse und Einstellungen als Datei. Bewahre sie außerhalb des Tablets auf - ein zurückgesetztes Gerät nimmt sonst alles mit.'**
  String get backupIntro;

  /// No description provided for @backupCreate.
  ///
  /// In de, this message translates to:
  /// **'Sicherung erstellen'**
  String get backupCreate;

  /// No description provided for @backupRestore.
  ///
  /// In de, this message translates to:
  /// **'Sicherung einspielen'**
  String get backupRestore;

  /// No description provided for @backupNever.
  ///
  /// In de, this message translates to:
  /// **'Noch nie gesichert.'**
  String get backupNever;

  /// When the last backup was made; when is a relative day such as "gestern".
  ///
  /// In de, this message translates to:
  /// **'Zuletzt gesichert: {when}.'**
  String backupLast(String when);

  /// Same, but the last backup is old, so a reminder follows.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt gesichert: {when}. Das ist eine Weile her.'**
  String backupLastOverdue(String when);

  /// No description provided for @pinTitleVerify.
  ///
  /// In de, this message translates to:
  /// **'Elternbereich'**
  String get pinTitleVerify;

  /// No description provided for @pinTitleSetup.
  ///
  /// In de, this message translates to:
  /// **'Elternbereich einrichten'**
  String get pinTitleSetup;

  /// No description provided for @pinHintEnter.
  ///
  /// In de, this message translates to:
  /// **'PIN eingeben'**
  String get pinHintEnter;

  /// Asks to choose a PIN; length is the number of digits.
  ///
  /// In de, this message translates to:
  /// **'Wähle eine PIN aus {length} Ziffern'**
  String pinHintChoose(int length);

  /// No description provided for @pinHintRepeat.
  ///
  /// In de, this message translates to:
  /// **'PIN wiederholen'**
  String get pinHintRepeat;

  /// No description provided for @pinWrong.
  ///
  /// In de, this message translates to:
  /// **'Falsche PIN.'**
  String get pinWrong;

  /// No description provided for @pinMismatch.
  ///
  /// In de, this message translates to:
  /// **'Die beiden Eingaben waren verschieden.'**
  String get pinMismatch;

  /// No description provided for @startWhatDoesItMean.
  ///
  /// In de, this message translates to:
  /// **'Was heißt das?'**
  String get startWhatDoesItMean;

  /// Example task shown in the start dialog of a lesson.
  ///
  /// In de, this message translates to:
  /// **'Zum Beispiel:  {example}'**
  String startExample(String example);

  /// The start dialog shows the number of tasks an assignment asks for in one run.
  ///
  /// In de, this message translates to:
  /// **'Für deine Aufgabe: {count} Rechnungen'**
  String startAssignmentGoal(int count);

  /// No description provided for @startHowMany.
  ///
  /// In de, this message translates to:
  /// **'Wie viele Aufgaben?'**
  String get startHowMany;

  /// Time per task that earns the next lightning bolt; time is formatted, e.g. "6,9 s".
  ///
  /// In de, this message translates to:
  /// **'ab {time} pro Aufgabe'**
  String startBoltsFrom(String time);

  /// Button that starts the lesson. Means "let's go".
  ///
  /// In de, this message translates to:
  /// **'Los geht\'s'**
  String get startGo;

  /// No description provided for @startLeaderboard.
  ///
  /// In de, this message translates to:
  /// **'Bestenliste'**
  String get startLeaderboard;

  /// Unit label: per task.
  ///
  /// In de, this message translates to:
  /// **'pro Aufgabe'**
  String get commonPerTask;

  /// Label: number of mistakes.
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get commonErrors;

  /// Label: number of tasks.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben'**
  String get commonTasks;

  /// Title of a leaderboard; lesson is the lesson title.
  ///
  /// In de, this message translates to:
  /// **'Bestenliste · {lesson}'**
  String leaderboardTitle(String lesson);

  /// Empty leaderboard; min is the minimum number of tasks a run needs to count.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Ergebnisse.\nMindestens {min} Aufgaben zählen für die Bestenliste.'**
  String leaderboardEmpty(int min);

  /// seconds is the time added to the score for every wrong attempt (a number from the code).
  ///
  /// In de, this message translates to:
  /// **'Gewertet wird die Zeit pro Aufgabe, plus {seconds, plural, =1{1 Sekunde} other{{seconds} Sekunden}} für jeden Fehlversuch. Deshalb lohnt sich Raten nicht, und Durchgänge mit unterschiedlich vielen Aufgaben bleiben vergleichbar.'**
  String leaderboardScoreExplanation(int seconds);

  /// Title of the statistics screen; name is the child's name.
  ///
  /// In de, this message translates to:
  /// **'Statistik · {name}'**
  String statsTitle(String name);

  /// No description provided for @statsEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine abgeschlossenen Durchgänge.'**
  String get statsEmpty;

  /// Heading of the learning-curve chart; lesson is the lesson title.
  ///
  /// In de, this message translates to:
  /// **'Lernkurve · {lesson}'**
  String statsLearningCurve(String lesson);

  /// No description provided for @statsLearningCurveSub.
  ///
  /// In de, this message translates to:
  /// **'Sekunden pro Aufgabe, Durchgang für Durchgang'**
  String get statsLearningCurveSub;

  /// No description provided for @statsHardest.
  ///
  /// In de, this message translates to:
  /// **'Diese Aufgaben dauern am längsten'**
  String get statsHardest;

  /// No description provided for @statsHeadStars.
  ///
  /// In de, this message translates to:
  /// **'Sterne'**
  String get statsHeadStars;

  /// Table header: best time.
  ///
  /// In de, this message translates to:
  /// **'Bestzeit'**
  String get statsHeadBest;

  /// Table header: average time ("Ø" means average).
  ///
  /// In de, this message translates to:
  /// **'Ø Zeit'**
  String get statsHeadAverage;

  /// Table header: number of runs.
  ///
  /// In de, this message translates to:
  /// **'Runden'**
  String get statsHeadRuns;

  /// No description provided for @statsTooFewData.
  ///
  /// In de, this message translates to:
  /// **'Noch zu wenige Daten.'**
  String get statsTooFewData;

  /// No description provided for @globalStatsTitle.
  ///
  /// In de, this message translates to:
  /// **'Alle Ergebnisse'**
  String get globalStatsTitle;

  /// No description provided for @globalStatsTabOverview.
  ///
  /// In de, this message translates to:
  /// **'Übersicht'**
  String get globalStatsTabOverview;

  /// No description provided for @globalStatsTabLeaderboards.
  ///
  /// In de, this message translates to:
  /// **'Bestenlisten'**
  String get globalStatsTabLeaderboards;

  /// No description provided for @globalStatsNoProfiles.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Profile.'**
  String get globalStatsNoProfiles;

  /// Heading of the activity chart; days is the number of days shown.
  ///
  /// In de, this message translates to:
  /// **'Geübt in den letzten {days} Tagen'**
  String globalStatsActivityHeading(int days);

  /// No description provided for @globalStatsActivitySub.
  ///
  /// In de, this message translates to:
  /// **'Minuten pro Tag, je Kind in seiner Farbe'**
  String get globalStatsActivitySub;

  /// No leaderboards yet; min is the minimum number of tasks for a run to count.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Bestenlisten.\nEin Durchgang zählt ab {min} Aufgaben.'**
  String globalStatsNoLeaderboards(int min);

  /// No description provided for @globalStatsNotPlayed.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht geübt.'**
  String get globalStatsNotPlayed;

  /// Unit "runs" next to a count; n picks singular or plural.
  ///
  /// In de, this message translates to:
  /// **'{n, plural, =1{Runde} other{Runden}}'**
  String globalStatsRounds(int n);

  /// Unit text next to a practice time, e.g. "3 h 12 min geübt".
  ///
  /// In de, this message translates to:
  /// **'geübt'**
  String get globalStatsPractised;

  /// Number of days in a row with practice.
  ///
  /// In de, this message translates to:
  /// **'{days} Tage in Folge'**
  String globalStatsStreak(int days);

  /// When a child last practised; when is a relative day such as "heute".
  ///
  /// In de, this message translates to:
  /// **'zuletzt {when}'**
  String globalStatsLastPlayed(String when);

  /// No description provided for @globalStatsNoActivity.
  ///
  /// In de, this message translates to:
  /// **'In den letzten Wochen wurde noch nicht geübt.'**
  String get globalStatsNoActivity;

  /// No description provided for @profilesTitle.
  ///
  /// In de, this message translates to:
  /// **'Wer rechnet?'**
  String get profilesTitle;

  /// No description provided for @profilesAllResults.
  ///
  /// In de, this message translates to:
  /// **'Alle Ergebnisse'**
  String get profilesAllResults;

  /// Button to the duel mode (two or more children play the same tasks).
  ///
  /// In de, this message translates to:
  /// **'Duell'**
  String get profilesDuel;

  /// Button to the parent area.
  ///
  /// In de, this message translates to:
  /// **'Eltern'**
  String get profilesParents;

  /// No description provided for @profilesNone.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Profil. Tippe auf „Neu\", um anzufangen.'**
  String get profilesNone;

  /// Dialog title when a locked profile is tapped; name is the child's name.
  ///
  /// In de, this message translates to:
  /// **'{name} macht gerade Pause'**
  String profilesLockedTitle(String name);

  /// No description provided for @profilesLockedText.
  ///
  /// In de, this message translates to:
  /// **'Dieses Profil ist vorübergehend gesperrt. Alle Sterne, Blitze und Bestzeiten bleiben erhalten - sie sind wieder da, sobald die Eltern es freigeben.'**
  String get profilesLockedText;

  /// No description provided for @profilesLockedOk.
  ///
  /// In de, this message translates to:
  /// **'Alles klar'**
  String get profilesLockedOk;

  /// No description provided for @profilesAllDone.
  ///
  /// In de, this message translates to:
  /// **'alles geschafft'**
  String get profilesAllDone;

  /// Number of open assignments shown on a profile tile.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Aufgabe} other{{count} Aufgaben}}'**
  String profilesTodo(int count);

  /// No description provided for @profilesEditLook.
  ///
  /// In de, this message translates to:
  /// **'Bild und Farbe ändern'**
  String get profilesEditLook;

  /// Button to create a new profile.
  ///
  /// In de, this message translates to:
  /// **'Neu'**
  String get profilesNew;

  /// No description provided for @profileEditorNew.
  ///
  /// In de, this message translates to:
  /// **'Neues Profil'**
  String get profileEditorNew;

  /// No description provided for @profileEditorChangeName.
  ///
  /// In de, this message translates to:
  /// **'Name ändern'**
  String get profileEditorChangeName;

  /// No description provided for @profileEditorNameLabel.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get profileEditorNameLabel;

  /// Button to continue to the next step.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get profileEditorNext;

  /// No description provided for @profileEditorLookTitle.
  ///
  /// In de, this message translates to:
  /// **'Bild und Farbe'**
  String get profileEditorLookTitle;

  /// No description provided for @profileEditorPicture.
  ///
  /// In de, this message translates to:
  /// **'Bild'**
  String get profileEditorPicture;

  /// No description provided for @profileEditorColor.
  ///
  /// In de, this message translates to:
  /// **'Farbe'**
  String get profileEditorColor;

  /// No description provided for @profileEditorSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get profileEditorSave;

  /// No description provided for @duelTitle.
  ///
  /// In de, this message translates to:
  /// **'Duell'**
  String get duelTitle;

  /// No description provided for @duelNeedTwoProfiles.
  ///
  /// In de, this message translates to:
  /// **'Für ein Duell braucht es mindestens zwei Profile.'**
  String get duelNeedTwoProfiles;

  /// No description provided for @duelWhoPlays.
  ///
  /// In de, this message translates to:
  /// **'Wer tritt an?'**
  String get duelWhoPlays;

  /// Child in the duel list who is locked: avatar emoji, then name.
  ///
  /// In de, this message translates to:
  /// **'{avatar}  {name} · gesperrt'**
  String duelPlayerLocked(String avatar, String name);

  /// Child in the duel list who is on a practice break.
  ///
  /// In de, this message translates to:
  /// **'{avatar}  {name} · Pause'**
  String duelPlayerOnBreak(String avatar, String name);

  /// Child in the duel list: avatar emoji, then name.
  ///
  /// In de, this message translates to:
  /// **'{avatar}  {name}'**
  String duelPlayer(String avatar, String name);

  /// No description provided for @duelWhichTasks.
  ///
  /// In de, this message translates to:
  /// **'Welche Aufgaben?'**
  String get duelWhichTasks;

  /// No description provided for @duelPickTwo.
  ///
  /// In de, this message translates to:
  /// **'Wähle mindestens zwei Kinder aus.'**
  String get duelPickTwo;

  /// Chip to choose a lesson for the duel: title and an example task.
  ///
  /// In de, this message translates to:
  /// **'{title}  ·  {example}'**
  String duelLessonChip(String title, String example);

  /// No description provided for @duelStart.
  ///
  /// In de, this message translates to:
  /// **'Duell starten'**
  String get duelStart;

  /// Which player is up, e.g. "2 von 3".
  ///
  /// In de, this message translates to:
  /// **'{position} von {total}'**
  String duelPosition(int position, int total);

  /// Announces whose turn it is in the duel.
  ///
  /// In de, this message translates to:
  /// **'{name} ist dran'**
  String duelYourTurn(String name);

  /// Lesson title and the title of its group.
  ///
  /// In de, this message translates to:
  /// **'{lesson} · {group}'**
  String duelLessonAndGroup(String lesson, String group);

  /// Button: the player is ready.
  ///
  /// In de, this message translates to:
  /// **'Bereit'**
  String get duelReady;

  /// No description provided for @duelAbort.
  ///
  /// In de, this message translates to:
  /// **'Duell abbrechen'**
  String get duelAbort;

  /// Title of the duel result; lesson is the lesson title.
  ///
  /// In de, this message translates to:
  /// **'Duell · {lesson}'**
  String duelResultTitle(String lesson);

  /// No description provided for @duelSameTasks.
  ///
  /// In de, this message translates to:
  /// **'Alle hatten dieselben Aufgaben.'**
  String get duelSameTasks;

  /// No description provided for @duelDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get duelDone;

  /// Shown for the winner of a duel.
  ///
  /// In de, this message translates to:
  /// **'Sieg!'**
  String get duelWin;

  /// No description provided for @commonBackToLessons.
  ///
  /// In de, this message translates to:
  /// **'Zurück zu den Lektionen'**
  String get commonBackToLessons;

  /// No description provided for @resultDone.
  ///
  /// In de, this message translates to:
  /// **'Geschafft!'**
  String get resultDone;

  /// Congratulation on the result screen with the child's name.
  ///
  /// In de, this message translates to:
  /// **'Geschafft, {name}!'**
  String resultDoneName(String name);

  /// What the next lightning bolt needs: n is the bolt number (1 to 3), time the time per task.
  ///
  /// In de, this message translates to:
  /// **'{n}. Blitz ab {time} pro Aufgabe'**
  String resultNextBolt(int n, String time);

  /// No description provided for @resultForThisLesson.
  ///
  /// In de, this message translates to:
  /// **'für diese Lektion'**
  String get resultForThisLesson;

  /// No description provided for @resultInTotal.
  ///
  /// In de, this message translates to:
  /// **'insgesamt'**
  String get resultInTotal;

  /// No description provided for @resultMetricTasks.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben'**
  String get resultMetricTasks;

  /// No description provided for @resultMetricTotalTime.
  ///
  /// In de, this message translates to:
  /// **'Gesamtzeit'**
  String get resultMetricTotalTime;

  /// Metric label: time per task.
  ///
  /// In de, this message translates to:
  /// **'Pro Aufgabe'**
  String get resultMetricPerTask;

  /// No description provided for @resultMetricErrors.
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get resultMetricErrors;

  /// penalty is a formatted duration, count the number of wrong attempts, seconds the penalty per wrong attempt.
  ///
  /// In de, this message translates to:
  /// **'Darin sind {penalty} Zeitstrafe für {count, plural, =1{1 Fehlversuch} other{{count} Fehlversuche}} enthalten - {seconds, plural, =1{1 Sekunde} other{{seconds} Sekunden}} für jeden.'**
  String resultPenalty(String penalty, int count, int seconds);

  /// Number of days in a row with practice.
  ///
  /// In de, this message translates to:
  /// **'{days} Tage in Folge geübt!'**
  String resultStreak(int days);

  /// Button: do the same lesson again.
  ///
  /// In de, this message translates to:
  /// **'Nochmal'**
  String get resultAgain;

  /// Button that opens the leaderboard.
  ///
  /// In de, this message translates to:
  /// **'Bestenliste'**
  String get resultLeaderboard;

  /// No description provided for @resultOtherLesson.
  ///
  /// In de, this message translates to:
  /// **'Andere Lektion'**
  String get resultOtherLesson;

  /// Shown after the first run of a lesson.
  ///
  /// In de, this message translates to:
  /// **'Das war dein erster Durchgang hier -\ndie Zeit ist ab jetzt dein Rekord.'**
  String get resultFirstRun;

  /// No description provided for @resultSameSpeed.
  ///
  /// In de, this message translates to:
  /// **'Genau so schnell wie beim letzten Mal.'**
  String get resultSameSpeed;

  /// delta is the formatted time difference per task, e.g. "0,4 s".
  ///
  /// In de, this message translates to:
  /// **'{delta} schneller pro Aufgabe als beim letzten Mal!'**
  String resultFaster(String delta);

  /// delta is the formatted time difference per task.
  ///
  /// In de, this message translates to:
  /// **'{delta} langsamer pro Aufgabe als beim letzten Mal.'**
  String resultSlower(String delta);

  /// No description provided for @practiceAbortTitle.
  ///
  /// In de, this message translates to:
  /// **'Übung beenden?'**
  String get practiceAbortTitle;

  /// No description provided for @practiceAbortText.
  ///
  /// In de, this message translates to:
  /// **'Dieser Durchgang zählt dann nicht für die Bestenliste.'**
  String get practiceAbortText;

  /// Button that continues the run instead of aborting.
  ///
  /// In de, this message translates to:
  /// **'Weiter rechnen'**
  String get practiceKeepGoing;

  /// Button that ends the run.
  ///
  /// In de, this message translates to:
  /// **'Beenden'**
  String get practiceAbortConfirm;

  /// No description provided for @practiceAbortTooltip.
  ///
  /// In de, this message translates to:
  /// **'Übung beenden'**
  String get practiceAbortTooltip;

  /// Title of the screen shown while the practice run is paused.
  ///
  /// In de, this message translates to:
  /// **'Pause'**
  String get practicePause;

  /// No description provided for @practicePauseNote.
  ///
  /// In de, this message translates to:
  /// **'Die Zeit läuft nicht weiter.'**
  String get practicePauseNote;

  /// Button that continues a paused run.
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get practiceResume;

  /// No description provided for @lessonsFilterTooltip.
  ///
  /// In de, this message translates to:
  /// **'Fertiges ausblenden'**
  String get lessonsFilterTooltip;

  /// No description provided for @lessonsHideDoneAssignments.
  ///
  /// In de, this message translates to:
  /// **'Erledigte Aufgaben ausblenden'**
  String get lessonsHideDoneAssignments;

  /// Button label in the app bar: statistics.
  ///
  /// In de, this message translates to:
  /// **'Statistik'**
  String get lessonsStatsLabel;

  /// No description provided for @lessonsSettingsTooltip.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get lessonsSettingsTooltip;

  /// Button label in the app bar: switch to another child.
  ///
  /// In de, this message translates to:
  /// **'Wechseln'**
  String get lessonsSwitchLabel;

  /// No description provided for @lessonsNoGroup.
  ///
  /// In de, this message translates to:
  /// **'Für dieses Profil ist noch kein Bereich freigeschaltet.\nDas lässt sich im Elternbereich ändern.'**
  String get lessonsNoGroup;

  /// No description provided for @lessonsNothingLeftTitle.
  ///
  /// In de, this message translates to:
  /// **'Alles geschafft!'**
  String get lessonsNothingLeftTitle;

  /// No description provided for @lessonsNothingLeftText.
  ///
  /// In de, this message translates to:
  /// **'Was du kannst, ist gerade ausgeblendet. Über den Filter oben kommt der ganze Katalog zurück.'**
  String get lessonsNothingLeftText;

  /// Button on the recommended lesson: start it.
  ///
  /// In de, this message translates to:
  /// **'Los'**
  String get lessonsRecommendGo;

  /// Recommended lesson with its group.
  ///
  /// In de, this message translates to:
  /// **'{lesson} · {group}'**
  String lessonsRecommendTitle(String lesson, String group);

  /// No description provided for @lessonsAssignmentsHeading.
  ///
  /// In de, this message translates to:
  /// **'Deine Aufgaben'**
  String get lessonsAssignmentsHeading;

  /// No description provided for @lessonsAssignmentsAllDone.
  ///
  /// In de, this message translates to:
  /// **'Alles erledigt! Die fertigen Aufgaben sind ausgeblendet.'**
  String get lessonsAssignmentsAllDone;

  /// No description provided for @lessonsNotPractised.
  ///
  /// In de, this message translates to:
  /// **'noch nicht geübt'**
  String get lessonsNotPractised;

  /// How often a lesson was practised, on a tile. Keep the "×".
  ///
  /// In de, this message translates to:
  /// **'{count}× geübt'**
  String lessonsPractisedTimes(int count);

  /// No description provided for @adminTitle.
  ///
  /// In de, this message translates to:
  /// **'Elternbereich'**
  String get adminTitle;

  /// No description provided for @adminTabHistory.
  ///
  /// In de, this message translates to:
  /// **'Übungsverlauf'**
  String get adminTabHistory;

  /// No description provided for @adminTabManagement.
  ///
  /// In de, this message translates to:
  /// **'Verwaltung'**
  String get adminTabManagement;

  /// No description provided for @adminTabAssignments.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben'**
  String get adminTabAssignments;

  /// No description provided for @adminTabSettings.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get adminTabSettings;

  /// Chip: show runs of all children.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get adminFilterAll;

  /// Chip that shows deleted runs again so they can be restored.
  ///
  /// In de, this message translates to:
  /// **'Gelöschte'**
  String get adminShowDeleted;

  /// The log shows only the last limit runs.
  ///
  /// In de, this message translates to:
  /// **'Es werden die letzten {limit} Durchgänge angezeigt. Ein kürzerer Zeitraum zeigt den Rest.'**
  String adminHistoryTruncated(int limit);

  /// Button that removes aborted runs of all children; count is how many.
  ///
  /// In de, this message translates to:
  /// **'Abgebrochene Durchgänge aufräumen ({count})'**
  String adminCleanupAll(int count);

  /// Button that removes aborted runs of one child.
  ///
  /// In de, this message translates to:
  /// **'Abgebrochene von {name} aufräumen ({count})'**
  String adminCleanupOne(String name, int count);

  /// No description provided for @adminHistoryEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Durchgänge.'**
  String get adminHistoryEmpty;

  /// No description provided for @adminDeleteRunTitle.
  ///
  /// In de, this message translates to:
  /// **'Diesen Durchgang löschen?'**
  String get adminDeleteRunTitle;

  /// Confirmation text: child, lesson and date of the run to delete.
  ///
  /// In de, this message translates to:
  /// **'{user} · {lesson} · {when}'**
  String adminDeleteRunText(String user, String lesson, String when);

  /// No description provided for @adminRunDeleted.
  ///
  /// In de, this message translates to:
  /// **'Durchgang gelöscht.'**
  String get adminRunDeleted;

  /// No description provided for @adminUndo.
  ///
  /// In de, this message translates to:
  /// **'Rückgängig'**
  String get adminUndo;

  /// No description provided for @adminThisChild.
  ///
  /// In de, this message translates to:
  /// **'diesem Kind'**
  String get adminThisChild;

  /// No description provided for @adminWhoAll.
  ///
  /// In de, this message translates to:
  /// **'von allen Kindern'**
  String get adminWhoAll;

  /// "of" plus a child's name, used inside a sentence (see adminCleanupText).
  ///
  /// In de, this message translates to:
  /// **'von {name}'**
  String adminWhoOne(String name);

  /// Question before removing aborted runs; count is how many.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Einen abgebrochenen Durchgang aufräumen?} other{{count} abgebrochene Durchgänge aufräumen?}}'**
  String adminCleanupTitle(int count);

  /// whose is "von allen Kindern" or "von <name>", range is a phrase such as "aus den letzten 7 Tagen".
  ///
  /// In de, this message translates to:
  /// **'Es verschwinden die abgebrochenen Durchgänge {whose} {range}. Sie zählten nie für Sterne, Blitze oder eine Bestenliste - die geübte Zeit bleibt gezählt.'**
  String adminCleanupText(String whose, String range);

  /// No description provided for @adminCleanupConfirm.
  ///
  /// In de, this message translates to:
  /// **'Aufräumen'**
  String get adminCleanupConfirm;

  /// Confirmation after removing aborted runs.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Ein abgebrochener Durchgang aufgeräumt.} other{{count} abgebrochene Durchgänge aufgeräumt.}}'**
  String adminCleanedUp(int count);

  /// Lesson title and group in the run log.
  ///
  /// In de, this message translates to:
  /// **'{lesson}  ·  {group}'**
  String adminHistoryLessonLine(String lesson, String group);

  /// Label of an aborted run: after how many tasks it was aborted.
  ///
  /// In de, this message translates to:
  /// **'abgebrochen nach {count, plural, =1{1 Aufgabe} other{{count} Aufgaben}}'**
  String adminAbortedAfter(int count);

  /// No description provided for @adminRestore.
  ///
  /// In de, this message translates to:
  /// **'Wiederherstellen'**
  String get adminRestore;

  /// No description provided for @adminDeleteRun.
  ///
  /// In de, this message translates to:
  /// **'Durchgang löschen'**
  String get adminDeleteRun;

  /// No description provided for @adminProfiles.
  ///
  /// In de, this message translates to:
  /// **'Profile'**
  String get adminProfiles;

  /// No description provided for @adminNewProfile.
  ///
  /// In de, this message translates to:
  /// **'Neues Profil'**
  String get adminNewProfile;

  /// No description provided for @adminProfilesNote.
  ///
  /// In de, this message translates to:
  /// **'Ein Tipp auf ein Kind öffnet alles, was zu ihm gehört: Bereiche, Zeiten, Sperre, Umbenennen und Löschen. Bild und Farbe darf jedes Kind selbst auf dem Startbildschirm ändern.'**
  String get adminProfilesNote;

  /// No description provided for @adminPinHeading.
  ///
  /// In de, this message translates to:
  /// **'PIN'**
  String get adminPinHeading;

  /// No description provided for @adminPinNote.
  ///
  /// In de, this message translates to:
  /// **'Schützt diesen Bereich. Vergessen? Dann hilft nur, die App-Daten in den Android-Einstellungen zu löschen - damit sind aber auch alle Ergebnisse weg.'**
  String get adminPinNote;

  /// No description provided for @adminChangePin.
  ///
  /// In de, this message translates to:
  /// **'PIN ändern'**
  String get adminChangePin;

  /// No description provided for @adminGroupsNone.
  ///
  /// In de, this message translates to:
  /// **'Kein Bereich freigeschaltet'**
  String get adminGroupsNone;

  /// No description provided for @adminGroupsAll.
  ///
  /// In de, this message translates to:
  /// **'Alle Bereiche'**
  String get adminGroupsAll;

  /// How many of the areas (groups of lessons) are switched on for a child.
  ///
  /// In de, this message translates to:
  /// **'{n} von {total} Bereichen'**
  String adminGroupsSome(int n, int total);

  /// Label of a profile that is temporarily locked.
  ///
  /// In de, this message translates to:
  /// **'Gesperrt'**
  String get adminLocked;

  /// Label: this child does not repeat hard tasks.
  ///
  /// In de, this message translates to:
  /// **'ohne Wiederholung'**
  String get adminNoReview;

  /// No description provided for @profileSettingsDiscardTitle.
  ///
  /// In de, this message translates to:
  /// **'Änderungen verwerfen?'**
  String get profileSettingsDiscardTitle;

  /// Asks whether unsaved settings for the named child are to be discarded.
  ///
  /// In de, this message translates to:
  /// **'Die Einstellungen für {name} wurden geändert, aber noch nicht gespeichert.'**
  String profileSettingsDiscardText(String name);

  /// No description provided for @profileSettingsDiscard.
  ///
  /// In de, this message translates to:
  /// **'Verwerfen'**
  String get profileSettingsDiscard;

  /// No description provided for @profileSettingsSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get profileSettingsSave;

  /// No description provided for @profileSettingsSectionPractice.
  ///
  /// In de, this message translates to:
  /// **'Üben'**
  String get profileSettingsSectionPractice;

  /// No description provided for @profileSettingsGroups.
  ///
  /// In de, this message translates to:
  /// **'Bereiche'**
  String get profileSettingsGroups;

  /// No description provided for @profileSettingsGroupsNote.
  ///
  /// In de, this message translates to:
  /// **'Abgeschaltete Bereiche erscheinen nicht mehr auf dem Übungsbildschirm. Bereits erzielte Ergebnisse bleiben erhalten.'**
  String get profileSettingsGroupsNote;

  /// No description provided for @profileSettingsNoGroup.
  ///
  /// In de, this message translates to:
  /// **'Ohne einen einzigen Bereich kann das Kind nicht üben.'**
  String get profileSettingsNoGroup;

  /// No description provided for @profileSettingsHideDoneHeading.
  ///
  /// In de, this message translates to:
  /// **'Fertige Lektionen ausblenden'**
  String get profileSettingsHideDoneHeading;

  /// No description provided for @profileSettingsHideDoneNote.
  ///
  /// In de, this message translates to:
  /// **'Kürzt den Katalog um das, was schon sitzt. Das Kind kann es auf dem Übungsbildschirm selbst umstellen - hier steht es, damit man es einmal einrichten kann. Die strengere Stufe lässt die Ersten Schritte stehen: dort wird nicht auf Zeit gerechnet, also gibt es keine Blitze zu holen.'**
  String get profileSettingsHideDoneNote;

  /// No description provided for @profileSettingsHideDoneAssignments.
  ///
  /// In de, this message translates to:
  /// **'Erledigte Aufgaben ausblenden'**
  String get profileSettingsHideDoneAssignments;

  /// No description provided for @profileSettingsHideDoneAssignmentsNote.
  ///
  /// In de, this message translates to:
  /// **'Fertige Karten verschwinden schon vor Ende des Tages bzw. der Woche. Sonst bleiben sie abgehakt stehen.'**
  String get profileSettingsHideDoneAssignmentsNote;

  /// No description provided for @profileSettingsTaskCount.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben pro Durchgang'**
  String get profileSettingsTaskCount;

  /// No description provided for @profileSettingsReview.
  ///
  /// In de, this message translates to:
  /// **'Schwere Aufgaben wiederholen'**
  String get profileSettingsReview;

  /// No description provided for @profileSettingsReviewNote.
  ///
  /// In de, this message translates to:
  /// **'Ein Viertel jedes Durchgangs besteht aus dem, was zuletzt lange gedauert hat oder falsch war.'**
  String get profileSettingsReviewNote;

  /// No description provided for @profileSettingsSectionTime.
  ///
  /// In de, this message translates to:
  /// **'Zeit und Wertung'**
  String get profileSettingsSectionTime;

  /// No description provided for @profileSettingsStretch.
  ///
  /// In de, this message translates to:
  /// **'Übungszeit am Stück'**
  String get profileSettingsStretch;

  /// No description provided for @profileSettingsStretchNote.
  ///
  /// In de, this message translates to:
  /// **'Nach dieser Zeit gibt es eine Pause. Ein laufender Durchgang wird nie abgebrochen - erst der nächste Start ist gesperrt. Die Zeit zählt weiter, solange die Pause nicht vollständig eingehalten wurde.'**
  String get profileSettingsStretchNote;

  /// No description provided for @profileSettingsBreakLength.
  ///
  /// In de, this message translates to:
  /// **'Wie lange dauert die Pause?'**
  String get profileSettingsBreakLength;

  /// No description provided for @profileSettingsDaily.
  ///
  /// In de, this message translates to:
  /// **'Und pro Tag insgesamt'**
  String get profileSettingsDaily;

  /// No description provided for @profileSettingsDailyNote.
  ///
  /// In de, this message translates to:
  /// **'Zählt alle Durchgänge des Tages zusammen, Pausen hin oder her. Ist die Zeit aufgebraucht, geht es erst am nächsten Tag weiter.'**
  String get profileSettingsDailyNote;

  /// No description provided for @profileSettingsScoredRuns.
  ///
  /// In de, this message translates to:
  /// **'Gewertete Durchgänge je Übung und Tag'**
  String get profileSettingsScoredRuns;

  /// No description provided for @profileSettingsScoredRunsNote.
  ///
  /// In de, this message translates to:
  /// **'Danach darf dieselbe Übung weiter gemacht werden, sie bringt nur keine Bestzeit, keine Sterne und keine Blitze mehr. Geübte Zeit und Verlauf zählen weiter mit.'**
  String get profileSettingsScoredRunsNote;

  /// No description provided for @profileSettingsSectionTidy.
  ///
  /// In de, this message translates to:
  /// **'Aufräumen'**
  String get profileSettingsSectionTidy;

  /// No description provided for @profileSettingsTidyNote.
  ///
  /// In de, this message translates to:
  /// **'Diese Knöpfe wirken sofort - sie warten nicht auf \"Speichern\".'**
  String get profileSettingsTidyNote;

  /// No description provided for @profileSettingsRename.
  ///
  /// In de, this message translates to:
  /// **'Umbenennen'**
  String get profileSettingsRename;

  /// No description provided for @profileSettingsGiveBackStars.
  ///
  /// In de, this message translates to:
  /// **'Sterne zurückgeben …'**
  String get profileSettingsGiveBackStars;

  /// No description provided for @profileSettingsResetResults.
  ///
  /// In de, this message translates to:
  /// **'Ergebnisse löschen'**
  String get profileSettingsResetResults;

  /// No description provided for @profileSettingsDeleteProfile.
  ///
  /// In de, this message translates to:
  /// **'Profil löschen'**
  String get profileSettingsDeleteProfile;

  /// Question before deleting all results of the named child.
  ///
  /// In de, this message translates to:
  /// **'Ergebnisse von {name} löschen?'**
  String profileSettingsResetTitle(String name);

  /// No description provided for @profileSettingsResetText.
  ///
  /// In de, this message translates to:
  /// **'Bestzeiten, Lernkurve und Verlauf gehen verloren. Das Profil selbst bleibt bestehen.'**
  String get profileSettingsResetText;

  /// Question before deleting the named profile.
  ///
  /// In de, this message translates to:
  /// **'{name} löschen?'**
  String profileSettingsDeleteTitle(String name);

  /// No description provided for @profileSettingsDeleteText.
  ///
  /// In de, this message translates to:
  /// **'Profil und alle Ergebnisse werden entfernt.'**
  String get profileSettingsDeleteText;

  /// Number of lessons in a group and an example task. Keep "z. B." as the abbreviation for "for example".
  ///
  /// In de, this message translates to:
  /// **'{count} Lektionen · z. B. {example}'**
  String profileSettingsGroupSummary(int count, String example);

  /// No description provided for @profileSettingsLockTitle.
  ///
  /// In de, this message translates to:
  /// **'Profil vorübergehend sperren'**
  String get profileSettingsLockTitle;

  /// No description provided for @profileSettingsLockNote.
  ///
  /// In de, this message translates to:
  /// **'Das Profil lässt sich dann nicht öffnen und nicht zum Duell einladen. Nichts geht verloren: Sterne, Blitze und Bestzeiten sind nach dem Freigeben unverändert da.'**
  String get profileSettingsLockNote;

  /// No description provided for @globalSettingsClock.
  ///
  /// In de, this message translates to:
  /// **'Uhr während der Übung zeigen'**
  String get globalSettingsClock;

  /// No description provided for @globalSettingsClockNote.
  ///
  /// In de, this message translates to:
  /// **'Die Zeit wird immer gemessen. Sichtbar macht sie manche Kinder aber nervös - deshalb ist sie standardmäßig aus.'**
  String get globalSettingsClockNote;

  /// No description provided for @globalSettingsHaptics.
  ///
  /// In de, this message translates to:
  /// **'Tasten vibrieren lassen'**
  String get globalSettingsHaptics;

  /// No description provided for @globalSettingsHapticsNote.
  ///
  /// In de, this message translates to:
  /// **'Kurzes Feedback bei jedem Tastendruck.'**
  String get globalSettingsHapticsNote;

  /// No description provided for @globalSettingsSounds.
  ///
  /// In de, this message translates to:
  /// **'Töne abspielen'**
  String get globalSettingsSounds;

  /// No description provided for @globalSettingsSoundsNote.
  ///
  /// In de, this message translates to:
  /// **'Ein kurzer Klang bei richtig, ein anderer bei falsch und ein leiser Klick unter jeder Taste. Auf einem flach liegenden Tablet spürt man die Vibration kaum.'**
  String get globalSettingsSoundsNote;

  /// No description provided for @globalSettingsTaskCount.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben pro Durchgang für alle'**
  String get globalSettingsTaskCount;

  /// No description provided for @globalSettingsTaskCountNote.
  ///
  /// In de, this message translates to:
  /// **'Für ein einzelnes Kind steht die Vorgabe unter „Verwaltung\" bei seinem Profil - und das Kind selbst kann sie in seinen eigenen Einstellungen ändern.'**
  String get globalSettingsTaskCountNote;

  /// No description provided for @globalSettingsLimits.
  ///
  /// In de, this message translates to:
  /// **'Übungszeit für alle'**
  String get globalSettingsLimits;

  /// No description provided for @globalSettingsLimitsNote.
  ///
  /// In de, this message translates to:
  /// **'Gilt für jedes Kind, das keine eigene Vorgabe hat. Ein laufender Durchgang wird nie abgebrochen - erst der nächste Start ist gesperrt.'**
  String get globalSettingsLimitsNote;

  /// No description provided for @globalSettingsStretch.
  ///
  /// In de, this message translates to:
  /// **'Am Stück, dann Pause'**
  String get globalSettingsStretch;

  /// No description provided for @globalSettingsBreakLength.
  ///
  /// In de, this message translates to:
  /// **'Wie lange dauert die Pause?'**
  String get globalSettingsBreakLength;

  /// No description provided for @globalSettingsDaily.
  ///
  /// In de, this message translates to:
  /// **'Und pro Tag insgesamt'**
  String get globalSettingsDaily;

  /// No description provided for @globalSettingsScoredRuns.
  ///
  /// In de, this message translates to:
  /// **'Gewertete Durchgänge je Übung und Tag'**
  String get globalSettingsScoredRuns;

  /// No description provided for @globalSettingsScoredRunsNote.
  ///
  /// In de, this message translates to:
  /// **'Danach darf dieselbe Übung weiter gemacht werden, sie bringt nur keine Bestzeit, keine Sterne und keine Blitze mehr. Das nimmt den Anreiz, die leichteste Übung so lange zu wiederholen, bis die Zeit stimmt. Geübte Zeit und Verlauf zählen weiter mit.'**
  String get globalSettingsScoredRunsNote;

  /// Question before taking the stars of a group of lessons back.
  ///
  /// In de, this message translates to:
  /// **'Sterne in „{group}\" zurücksetzen?'**
  String resetStarsTitle(String group);

  /// name is the child's name; the stars can be earned again.
  ///
  /// In de, this message translates to:
  /// **'{name} kann sie danach neu verdienen. Bestzeiten, Blitze, Lernkurve und Bestenlisten bleiben unverändert - es geht nur um die Sterne dieser Gruppe.'**
  String resetStarsText(String name);

  /// Button that confirms taking the stars back.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get resetStarsConfirm;

  /// Heading of the dialog to give stars back.
  ///
  /// In de, this message translates to:
  /// **'Sterne von {name}'**
  String resetStarsHeading(String name);

  /// No description provided for @resetStarsNote.
  ///
  /// In de, this message translates to:
  /// **'Zurückgesetzt werden nur die Sterne. Die Zeiten bleiben - Bestzeiten, Blitze, Lernkurve und Bestenlisten sind danach genau wie vorher.'**
  String get resetStarsNote;

  /// Button that closes the dialog; means "done".
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get resetStarsDone;

  /// Stars earned out of possible in one group.
  ///
  /// In de, this message translates to:
  /// **'{earned} von {possible} Sternen'**
  String resetStarsGroupLine(int earned, int possible);

  /// Chip: assignments of all children.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get assignmentsAll;

  /// No description provided for @assignmentsNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Aufgabe'**
  String get assignmentsNew;

  /// No description provided for @assignmentsHideFinished.
  ///
  /// In de, this message translates to:
  /// **'Erledigte ausblenden'**
  String get assignmentsHideFinished;

  /// Number of hidden (finished) assignments.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 ausgeblendet} other{{count} ausgeblendet}}'**
  String assignmentsHiddenCount(int count);

  /// No description provided for @assignmentsEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Aufgaben.'**
  String get assignmentsEmpty;

  /// No description provided for @assignmentsNoneOpen.
  ///
  /// In de, this message translates to:
  /// **'Keine offenen Aufgaben. Erledigte sind ausgeblendet.'**
  String get assignmentsNoneOpen;

  /// Rhythm of an assignment: every day.
  ///
  /// In de, this message translates to:
  /// **'täglich'**
  String get assignmentsDaily;

  /// Rhythm of an assignment: every week.
  ///
  /// In de, this message translates to:
  /// **'wöchentlich'**
  String get assignmentsWeekly;

  /// Appended to the deadline of a task that stays open until it is done; the separator before it is added in code.
  ///
  /// In de, this message translates to:
  /// **'zieht nach'**
  String get assignmentsCarriesOver;

  /// Number of lessons ("Übungen") in an assignment.
  ///
  /// In de, this message translates to:
  /// **'{count} Übungen'**
  String assignmentsLessonCount(int count);

  /// No description provided for @assignmentsEdit.
  ///
  /// In de, this message translates to:
  /// **'Ändern'**
  String get assignmentsEdit;

  /// Button that ends an assignment by hand.
  ///
  /// In de, this message translates to:
  /// **'Beenden'**
  String get assignmentsEnd;

  /// Button that creates a new assignment from a finished one.
  ///
  /// In de, this message translates to:
  /// **'Erneut stellen'**
  String get assignmentsRepeat;

  /// No description provided for @assignmentsDelete.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe löschen'**
  String get assignmentsDelete;

  /// An assignment asks for runs runs of tasks tasks each. Keep the "×".
  ///
  /// In de, this message translates to:
  /// **'{runs}× {tasks} Rechnungen'**
  String assignmentsRunsOfTasks(int runs, int tasks);

  /// Minimum stars an assignment asks for ("mind." is short for "at least").
  ///
  /// In de, this message translates to:
  /// **'mind. {count} ★'**
  String assignmentsMinStars(int count);

  /// Minimum lightning bolts an assignment asks for.
  ///
  /// In de, this message translates to:
  /// **'mind. {count} ⚡'**
  String assignmentsMinBolts(int count);

  /// No description provided for @assignmentsNoClosedPeriod.
  ///
  /// In de, this message translates to:
  /// **'Noch kein abgeschlossener Zeitraum'**
  String get assignmentsNoClosedPeriod;

  /// Statistic of a repeating task. period is "daily" or "weekly" and picks the unit: days or weeks.
  ///
  /// In de, this message translates to:
  /// **'Geschafft an {met} von {total} {period, select, daily{Tagen} weekly{Wochen} other{Wochen}}'**
  String assignmentsMetOf(int met, int total, String period);

  /// Earlier statistic next to a lesson of a task; the leading separator is added in code. period is "daily" or "weekly".
  ///
  /// In de, this message translates to:
  /// **'davor {met} von {total} {period, select, daily{Tagen} weekly{Wochen} other{Wochen}}'**
  String assignmentsBefore(int met, int total, String period);

  /// Verdict for a past period: the assignment was met.
  ///
  /// In de, this message translates to:
  /// **'Geschafft'**
  String get assignmentsVerdictMet;

  /// Verdict: the period is still running.
  ///
  /// In de, this message translates to:
  /// **'Steht noch aus'**
  String get assignmentsVerdictPending;

  /// Verdict for a past period: missed on the day, caught up later.
  ///
  /// In de, this message translates to:
  /// **'Verpasst, später nachgeholt'**
  String get assignmentsVerdictLate;

  /// Verdict for a past period: missed.
  ///
  /// In de, this message translates to:
  /// **'Verpasst'**
  String get assignmentsVerdictMissed;

  /// No description provided for @editorTitleEdit.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe ändern'**
  String get editorTitleEdit;

  /// No description provided for @editorTitleAgain.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe erneut stellen'**
  String get editorTitleAgain;

  /// No description provided for @editorTitleNew.
  ///
  /// In de, this message translates to:
  /// **'Neue Aufgabe'**
  String get editorTitleNew;

  /// No description provided for @editorChild.
  ///
  /// In de, this message translates to:
  /// **'Kind'**
  String get editorChild;

  /// No description provided for @editorUnknownChild.
  ///
  /// In de, this message translates to:
  /// **'Unbekanntes Kind'**
  String get editorUnknownChild;

  /// Heading: the lessons (exercises) of an assignment.
  ///
  /// In de, this message translates to:
  /// **'Übungen'**
  String get editorLessons;

  /// No description provided for @editorLessonsNote.
  ///
  /// In de, this message translates to:
  /// **'Mehrere sind möglich. Jede davon muss erfüllt werden, damit die Aufgabe erledigt ist.'**
  String get editorLessonsNote;

  /// No description provided for @editorNoLesson.
  ///
  /// In de, this message translates to:
  /// **'Ohne eine einzige Übung gibt es nichts aufzugeben.'**
  String get editorNoLesson;

  /// Heading: one day or one week.
  ///
  /// In de, this message translates to:
  /// **'Zeitraum'**
  String get editorPeriod;

  /// No description provided for @editorOneDay.
  ///
  /// In de, this message translates to:
  /// **'ein Tag'**
  String get editorOneDay;

  /// No description provided for @editorOneWeek.
  ///
  /// In de, this message translates to:
  /// **'eine Woche'**
  String get editorOneWeek;

  /// No description provided for @editorRepetition.
  ///
  /// In de, this message translates to:
  /// **'Wiederholung'**
  String get editorRepetition;

  /// Choice: the assignment comes back every period.
  ///
  /// In de, this message translates to:
  /// **'jedes Mal'**
  String get editorEveryTime;

  /// Choice: the assignment is given only once.
  ///
  /// In de, this message translates to:
  /// **'einmalig'**
  String get editorOnce;

  /// No description provided for @editorDailyNote.
  ///
  /// In de, this message translates to:
  /// **'Jeden Tag neu, fällig am Ende des Tages.'**
  String get editorDailyNote;

  /// No description provided for @editorWeeklyNote.
  ///
  /// In de, this message translates to:
  /// **'Jede Woche neu, fällig Sonntagabend.'**
  String get editorWeeklyNote;

  /// A one-time assignment on a day; day is a short date with weekday.
  ///
  /// In de, this message translates to:
  /// **'Am {day}'**
  String editorOnDay(String day);

  /// A one-time assignment in the week starting on the given day.
  ///
  /// In de, this message translates to:
  /// **'In der Woche ab {day}'**
  String editorInWeek(String day);

  /// No description provided for @editorPickDay.
  ///
  /// In de, this message translates to:
  /// **'Tag wählen …'**
  String get editorPickDay;

  /// No description provided for @editorCarryOver.
  ///
  /// In de, this message translates to:
  /// **'Nachziehen, wenn nicht geschafft'**
  String get editorCarryOver;

  /// No description provided for @editorCarryOverNote.
  ///
  /// In de, this message translates to:
  /// **'Die Aufgabe bleibt danach stehen, bis sie erledigt ist. Der Tag selbst gilt trotzdem als verpasst - die Statistik sagt, wann geübt wurde, nicht was gemeint war.'**
  String get editorCarryOverNote;

  /// No description provided for @editorRuns.
  ///
  /// In de, this message translates to:
  /// **'Durchgänge'**
  String get editorRuns;

  /// No description provided for @editorTasksPerRun.
  ///
  /// In de, this message translates to:
  /// **'Rechnungen je Durchgang'**
  String get editorTasksPerRun;

  /// No description provided for @editorMinStars.
  ///
  /// In de, this message translates to:
  /// **'Mindeststerne'**
  String get editorMinStars;

  /// No description provided for @editorMinBolts.
  ///
  /// In de, this message translates to:
  /// **'Mindestblitze'**
  String get editorMinBolts;

  /// No description provided for @editorNoRequirement.
  ///
  /// In de, this message translates to:
  /// **'keine Vorgabe'**
  String get editorNoRequirement;

  /// No description provided for @editorSave.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get editorSave;

  /// Button that creates the assignment.
  ///
  /// In de, this message translates to:
  /// **'Anlegen'**
  String get editorCreate;

  /// Heading of a group of lessons on the lesson screen.
  ///
  /// In de, this message translates to:
  /// **'Erste Schritte'**
  String get groupFirstSteps;

  /// No description provided for @groupUpTo10.
  ///
  /// In de, this message translates to:
  /// **'Bis 10'**
  String get groupUpTo10;

  /// No description provided for @groupUpTo20.
  ///
  /// In de, this message translates to:
  /// **'Bis 20'**
  String get groupUpTo20;

  /// No description provided for @groupUpTo100.
  ///
  /// In de, this message translates to:
  /// **'Bis 100'**
  String get groupUpTo100;

  /// No description provided for @groupUpTo1000.
  ///
  /// In de, this message translates to:
  /// **'Bis 1000'**
  String get groupUpTo1000;

  /// No description provided for @groupWithThousands.
  ///
  /// In de, this message translates to:
  /// **'Mit Tausendern'**
  String get groupWithThousands;

  /// No description provided for @groupTimesTables.
  ///
  /// In de, this message translates to:
  /// **'Einmaleins'**
  String get groupTimesTables;

  /// No description provided for @groupReverseTimesTables.
  ///
  /// In de, this message translates to:
  /// **'Einmaleins rückwärts'**
  String get groupReverseTimesTables;

  /// No description provided for @groupTimesAndDivision.
  ///
  /// In de, this message translates to:
  /// **'Mal und Geteilt'**
  String get groupTimesAndDivision;

  /// No description provided for @groupEveryday.
  ///
  /// In de, this message translates to:
  /// **'Uhrzeit und Geld'**
  String get groupEveryday;

  /// Title of a lesson. "Zehnerübergang" is the German school term for crossing a multiple of ten when adding or subtracting (carrying / borrowing).
  ///
  /// In de, this message translates to:
  /// **'Plus ohne Zehnerübergang'**
  String get lessonAddPlainTitle;

  /// Same lesson in the number ranges up to 1000, where a task may cross the ten or the hundred, so the title does not name the ten.
  ///
  /// In de, this message translates to:
  /// **'Plus ohne Übergang'**
  String get lessonAddPlainBigTitle;

  /// No description provided for @lessonAddPlainDesc.
  ///
  /// In de, this message translates to:
  /// **'Die Einer bleiben zusammen unter 10 - es muss nichts übertragen werden.'**
  String get lessonAddPlainDesc;

  /// No description provided for @lessonAddPlainBigDesc.
  ///
  /// In de, this message translates to:
  /// **'Keine Stelle läuft über - weder die Einer noch die Zehner.'**
  String get lessonAddPlainBigDesc;

  /// No description provided for @lessonAddCarryTitle.
  ///
  /// In de, this message translates to:
  /// **'Plus mit Zehnerübergang'**
  String get lessonAddCarryTitle;

  /// No description provided for @lessonAddCarryBigTitle.
  ///
  /// In de, this message translates to:
  /// **'Plus mit Übergang'**
  String get lessonAddCarryBigTitle;

  /// No description provided for @lessonAddCarryDesc.
  ///
  /// In de, this message translates to:
  /// **'Die Einer ergeben zusammen 10 oder mehr - ein Zehner wandert weiter.'**
  String get lessonAddCarryDesc;

  /// No description provided for @lessonAddCarryBigDesc.
  ///
  /// In de, this message translates to:
  /// **'Einer oder Zehner laufen über - es muss übertragen werden.'**
  String get lessonAddCarryBigDesc;

  /// No description provided for @lessonSubPlainTitle.
  ///
  /// In de, this message translates to:
  /// **'Minus ohne Zehnerübergang'**
  String get lessonSubPlainTitle;

  /// No description provided for @lessonSubPlainBigTitle.
  ///
  /// In de, this message translates to:
  /// **'Minus ohne Übergang'**
  String get lessonSubPlainBigTitle;

  /// No description provided for @lessonSubPlainDesc.
  ///
  /// In de, this message translates to:
  /// **'Jede Ziffer oben ist groß genug - es muss kein Zehner aufgelöst werden.'**
  String get lessonSubPlainDesc;

  /// No description provided for @lessonSubPlainBigDesc.
  ///
  /// In de, this message translates to:
  /// **'Jede Ziffer oben ist groß genug - es muss nichts aufgelöst werden.'**
  String get lessonSubPlainBigDesc;

  /// No description provided for @lessonSubBorrowTitle.
  ///
  /// In de, this message translates to:
  /// **'Minus mit Zehnerübergang'**
  String get lessonSubBorrowTitle;

  /// No description provided for @lessonSubBorrowBigTitle.
  ///
  /// In de, this message translates to:
  /// **'Minus mit Übergang'**
  String get lessonSubBorrowBigTitle;

  /// No description provided for @lessonSubBorrowDesc.
  ///
  /// In de, this message translates to:
  /// **'Die Einer oben reichen nicht - ein Zehner muss aufgelöst werden.'**
  String get lessonSubBorrowDesc;

  /// No description provided for @lessonSubBorrowBigDesc.
  ///
  /// In de, this message translates to:
  /// **'Eine Stelle oben reicht nicht - Zehner oder Hunderter müssen aufgelöst werden.'**
  String get lessonSubBorrowBigDesc;

  /// "Platzhalter" is the empty box standing in for a missing number: 3 + ? = 10.
  ///
  /// In de, this message translates to:
  /// **'Plus mit Platzhalter'**
  String get lessonPlusGapTitle;

  /// No description provided for @lessonMinusGapTitle.
  ///
  /// In de, this message translates to:
  /// **'Minus mit Platzhalter'**
  String get lessonMinusGapTitle;

  /// No description provided for @lessonGapDesc.
  ///
  /// In de, this message translates to:
  /// **'Gesucht ist die Zahl, die fehlt, damit die Rechnung stimmt.'**
  String get lessonGapDesc;

  /// No description provided for @lessonMixedTitle.
  ///
  /// In de, this message translates to:
  /// **'Plus und Minus gemischt'**
  String get lessonMixedTitle;

  /// No description provided for @lessonMixedDesc.
  ///
  /// In de, this message translates to:
  /// **'Plus und Minus wechseln sich zufällig ab, mit und ohne Übergang.'**
  String get lessonMixedDesc;

  /// Title of the lesson for one row of the times table; n is the row, e.g. 7 for the seven times table.
  ///
  /// In de, this message translates to:
  /// **'{n}er-Reihe'**
  String lessonTimesTableTitle(int n);

  /// Both directions means n · 4 and 4 · n.
  ///
  /// In de, this message translates to:
  /// **'Alle Aufgaben der {n}er-Reihe, in beide Richtungen: {n} · 4 genauso wie 4 · {n}.'**
  String lessonTimesTableDesc(int n);

  /// Title of the lesson that divides by n, the reverse of one row of the times table.
  ///
  /// In de, this message translates to:
  /// **'{n}er-Reihe rückwärts'**
  String lessonReverseTableTitle(int n);

  /// product is n times 4.
  ///
  /// In de, this message translates to:
  /// **'Geteilt durch {n}. Jede Aufgabe ist die Umkehrung einer Aufgabe der {n}er-Reihe: aus {n} · 4 = {product} wird {product} : {n} = 4.'**
  String lessonReverseTableDesc(int n, int product);

  /// No description provided for @lessonPartnersOfTenTitle.
  ///
  /// In de, this message translates to:
  /// **'Verliebte Zahlen'**
  String get lessonPartnersOfTenTitle;

  /// No description provided for @lessonPartnersOfTenDesc.
  ///
  /// In de, this message translates to:
  /// **'Zwei Zahlen sind verliebt, wenn sie zusammen genau 10 ergeben: 1 und 9, 2 und 8, 3 und 7. Gefragt wird in beide Richtungen - von 3 nach 7 genauso wie von 7 nach 3.'**
  String get lessonPartnersOfTenDesc;

  /// No description provided for @lessonAdd10Title.
  ///
  /// In de, this message translates to:
  /// **'Plus bis 10'**
  String get lessonAdd10Title;

  /// No description provided for @lessonAdd10Desc.
  ///
  /// In de, this message translates to:
  /// **'Zusammenzählen, ohne über die 10 hinauszugehen.'**
  String get lessonAdd10Desc;

  /// No description provided for @lessonSub10Title.
  ///
  /// In de, this message translates to:
  /// **'Minus bis 10'**
  String get lessonSub10Title;

  /// No description provided for @lessonSub10Desc.
  ///
  /// In de, this message translates to:
  /// **'Wegnehmen im Zahlenraum bis 10.'**
  String get lessonSub10Desc;

  /// No description provided for @lessonMix10Desc.
  ///
  /// In de, this message translates to:
  /// **'Plus und Minus wechseln sich zufällig ab.'**
  String get lessonMix10Desc;

  /// No description provided for @lessonTimesAllTitle.
  ///
  /// In de, this message translates to:
  /// **'Alle Reihen gemischt'**
  String get lessonTimesAllTitle;

  /// No description provided for @lessonTimesAllDesc.
  ///
  /// In de, this message translates to:
  /// **'Das ganze kleine Einmaleins, bunt durcheinander.'**
  String get lessonTimesAllDesc;

  /// No description provided for @lessonDivPlainTitle.
  ///
  /// In de, this message translates to:
  /// **'Alle Reihen rückwärts'**
  String get lessonDivPlainTitle;

  /// No description provided for @lessonDivPlainDesc.
  ///
  /// In de, this message translates to:
  /// **'Geteilt durch alles, bunt durcheinander. Jede Aufgabe geht glatt auf - sie ist die Umkehrung einer Einmaleins-Aufgabe.'**
  String get lessonDivPlainDesc;

  /// No description provided for @lessonDivRemainderTitle.
  ///
  /// In de, this message translates to:
  /// **'Geteilt mit Rest'**
  String get lessonDivRemainderTitle;

  /// No description provided for @lessonDivRemainderDesc.
  ///
  /// In de, this message translates to:
  /// **'Es bleibt immer etwas übrig. Erst das Ergebnis eingeben, dann den Rest.'**
  String get lessonDivRemainderDesc;

  /// No description provided for @lessonTimesGapTitle.
  ///
  /// In de, this message translates to:
  /// **'Mal mit Platzhalter'**
  String get lessonTimesGapTitle;

  /// No description provided for @lessonTimesGapDesc.
  ///
  /// In de, this message translates to:
  /// **'Mit welcher Zahl muss man malnehmen, damit es stimmt?'**
  String get lessonTimesGapDesc;

  /// No description provided for @lessonDivGapTitle.
  ///
  /// In de, this message translates to:
  /// **'Geteilt mit Platzhalter'**
  String get lessonDivGapTitle;

  /// No description provided for @lessonDivGapDesc.
  ///
  /// In de, this message translates to:
  /// **'Durch welche Zahl muss man teilen, damit es stimmt?'**
  String get lessonDivGapDesc;

  /// No description provided for @lessonMulTensTitle.
  ///
  /// In de, this message translates to:
  /// **'Mal mit Zehnerzahlen'**
  String get lessonMulTensTitle;

  /// No description provided for @lessonMulTensDesc.
  ///
  /// In de, this message translates to:
  /// **'Das Einmaleins mit einer Null dahinter: 3 · 4 = 12, also 30 · 4 = 120.'**
  String get lessonMulTensDesc;

  /// No description provided for @lessonMulTwoDigitTitle.
  ///
  /// In de, this message translates to:
  /// **'Mal über das Einmaleins hinaus'**
  String get lessonMulTwoDigitTitle;

  /// No description provided for @lessonMulTwoDigitDesc.
  ///
  /// In de, this message translates to:
  /// **'Eine zweistellige Zahl malnehmen, zum Beispiel 14 · 6.'**
  String get lessonMulTwoDigitDesc;

  /// No description provided for @lessonDivTwoDigitTitle.
  ///
  /// In de, this message translates to:
  /// **'Geteilt über das Einmaleins hinaus'**
  String get lessonDivTwoDigitTitle;

  /// No description provided for @lessonDivTwoDigitDesc.
  ///
  /// In de, this message translates to:
  /// **'Das Ergebnis ist größer als zehn, zum Beispiel 96 : 6.'**
  String get lessonDivTwoDigitDesc;

  /// No description provided for @lessonMulDivMixedTitle.
  ///
  /// In de, this message translates to:
  /// **'Mal und Geteilt gemischt'**
  String get lessonMulDivMixedTitle;

  /// No description provided for @lessonMulDivMixedDesc.
  ///
  /// In de, this message translates to:
  /// **'Malnehmen und Teilen wechseln sich zufällig ab.'**
  String get lessonMulDivMixedDesc;

  /// No description provided for @lessonPunktVorStrichTitle.
  ///
  /// In de, this message translates to:
  /// **'Punkt vor Strich'**
  String get lessonPunktVorStrichTitle;

  /// No description provided for @lessonPunktVorStrichDesc.
  ///
  /// In de, this message translates to:
  /// **'Mal und Geteilt kommen vor Plus und Minus - auch wenn sie hinten stehen: bei 40 − 3 · 6 wird erst 3 · 6 gerechnet.'**
  String get lessonPunktVorStrichDesc;

  /// No description provided for @lessonCountPicturesTitle.
  ///
  /// In de, this message translates to:
  /// **'Wie viele? (Reihe)'**
  String get lessonCountPicturesTitle;

  /// No description provided for @lessonCountPicturesDesc.
  ///
  /// In de, this message translates to:
  /// **'Bilder zählen, eins bis fünf, ordentlich aufgereiht.'**
  String get lessonCountPicturesDesc;

  /// No description provided for @lessonCountPicturesCloudTitle.
  ///
  /// In de, this message translates to:
  /// **'Wie viele? (Wolke)'**
  String get lessonCountPicturesCloudTitle;

  /// No description provided for @lessonCountPicturesCloudDesc.
  ///
  /// In de, this message translates to:
  /// **'Dieselben Bilder, aber durcheinander - man muss sich merken, was schon gezählt ist.'**
  String get lessonCountPicturesCloudDesc;

  /// No description provided for @lessonCountDiceTitle.
  ///
  /// In de, this message translates to:
  /// **'Wie viele Punkte?'**
  String get lessonCountDiceTitle;

  /// No description provided for @lessonCountDiceDesc.
  ///
  /// In de, this message translates to:
  /// **'Ein Würfel. Irgendwann sieht man die Zahl, ohne zu zählen.'**
  String get lessonCountDiceDesc;

  /// No description provided for @lessonCompareMoreTitle.
  ///
  /// In de, this message translates to:
  /// **'Wo sind mehr? (Reihe)'**
  String get lessonCompareMoreTitle;

  /// No description provided for @lessonCompareMoreDesc.
  ///
  /// In de, this message translates to:
  /// **'Zwei Häufchen vergleichen und die größere Anzahl eingeben.'**
  String get lessonCompareMoreDesc;

  /// No description provided for @lessonCompareMoreCloudTitle.
  ///
  /// In de, this message translates to:
  /// **'Wo sind mehr? (Wolke)'**
  String get lessonCompareMoreCloudTitle;

  /// No description provided for @lessonCompareMoreCloudDesc.
  ///
  /// In de, this message translates to:
  /// **'Dasselbe, aber die Bilder liegen durcheinander.'**
  String get lessonCompareMoreCloudDesc;

  /// No description provided for @lessonCountNextTitle.
  ///
  /// In de, this message translates to:
  /// **'Welche Zahl kommt danach?'**
  String get lessonCountNextTitle;

  /// No description provided for @lessonCountNextDesc.
  ///
  /// In de, this message translates to:
  /// **'Die Zahlenreihe vorwärts und rückwärts.'**
  String get lessonCountNextDesc;

  /// No description provided for @lessonBeesAddTitle.
  ///
  /// In de, this message translates to:
  /// **'Bienchen (Reihe)'**
  String get lessonBeesAddTitle;

  /// No description provided for @lessonBeesAddDesc.
  ///
  /// In de, this message translates to:
  /// **'Zwei Grüppchen Bienen zusammenzählen, zusammen nie mehr als zehn.'**
  String get lessonBeesAddDesc;

  /// No description provided for @lessonBeesAddCloudTitle.
  ///
  /// In de, this message translates to:
  /// **'Bienchen (Wolke)'**
  String get lessonBeesAddCloudTitle;

  /// No description provided for @lessonBeesAddCloudDesc.
  ///
  /// In de, this message translates to:
  /// **'Dieselbe Aufgabe, aber die Bienen schwirren durcheinander.'**
  String get lessonBeesAddCloudDesc;

  /// No description provided for @lessonDiceAddTitle.
  ///
  /// In de, this message translates to:
  /// **'Zwei Würfel zusammenzählen'**
  String get lessonDiceAddTitle;

  /// No description provided for @lessonDiceAddDesc.
  ///
  /// In de, this message translates to:
  /// **'Beide Würfel zeigen bis zu fünf Punkte - wie viele sind es zusammen?'**
  String get lessonDiceAddDesc;

  /// No description provided for @lessonAddToSixTitle.
  ///
  /// In de, this message translates to:
  /// **'Plus bis 6'**
  String get lessonAddToSixTitle;

  /// No description provided for @lessonAddToSixDesc.
  ///
  /// In de, this message translates to:
  /// **'Zusammenzählen, nie über die Sechs hinaus.'**
  String get lessonAddToSixDesc;

  /// No description provided for @lessonSubToSixTitle.
  ///
  /// In de, this message translates to:
  /// **'Minus bis 6'**
  String get lessonSubToSixTitle;

  /// No description provided for @lessonSubToSixDesc.
  ///
  /// In de, this message translates to:
  /// **'Wegnehmen im Zahlenraum bis sechs.'**
  String get lessonSubToSixDesc;

  /// No description provided for @lessonCalcToSixTitle.
  ///
  /// In de, this message translates to:
  /// **'Plus und Minus bis 6'**
  String get lessonCalcToSixTitle;

  /// No description provided for @lessonCalcToSixDesc.
  ///
  /// In de, this message translates to:
  /// **'Beides gemischt, nie über die Sechs hinaus.'**
  String get lessonCalcToSixDesc;

  /// No description provided for @lessonClockHalfTitle.
  ///
  /// In de, this message translates to:
  /// **'Volle und halbe Stunden'**
  String get lessonClockHalfTitle;

  /// No description provided for @lessonClockHalfDesc.
  ///
  /// In de, this message translates to:
  /// **'Wie spät ist es? Der große Zeiger steht auf der 12 oder auf der 6.'**
  String get lessonClockHalfDesc;

  /// No description provided for @lessonClockQuarterTitle.
  ///
  /// In de, this message translates to:
  /// **'Viertelstunden'**
  String get lessonClockQuarterTitle;

  /// No description provided for @lessonClockQuarterDesc.
  ///
  /// In de, this message translates to:
  /// **'Viertel nach, halb, Viertel vor - der große Zeiger steht auf 12, 3, 6 oder 9.'**
  String get lessonClockQuarterDesc;

  /// No description provided for @lessonClockFiveTitle.
  ///
  /// In de, this message translates to:
  /// **'Uhrzeit auf fünf Minuten'**
  String get lessonClockFiveTitle;

  /// No description provided for @lessonClockFiveDesc.
  ///
  /// In de, this message translates to:
  /// **'Der große Zeiger steht auf einer der zwölf Zahlen.'**
  String get lessonClockFiveDesc;

  /// No description provided for @lessonClock24Title.
  ///
  /// In de, this message translates to:
  /// **'Uhrzeit mit 24 Stunden'**
  String get lessonClock24Title;

  /// No description provided for @lessonClock24Desc.
  ///
  /// In de, this message translates to:
  /// **'Nachmittags zählt man weiter: aus 3 Uhr wird 15 Uhr. Unter der Uhr steht, welche Tageszeit es ist.'**
  String get lessonClock24Desc;

  /// No description provided for @lessonClockWordsTitle.
  ///
  /// In de, this message translates to:
  /// **'Uhrzeit sagen'**
  String get lessonClockWordsTitle;

  /// No description provided for @lessonClockWordsDesc.
  ///
  /// In de, this message translates to:
  /// **'Wie sagt man die Uhrzeit? Erst die Sprechweise antippen, dann die Stunde, die dabei genannt wird - bei \"halb 3\" ist das die 3.'**
  String get lessonClockWordsDesc;

  /// No description provided for @lessonMoneyAddTitle.
  ///
  /// In de, this message translates to:
  /// **'Geld zusammenzählen'**
  String get lessonMoneyAddTitle;

  /// No description provided for @lessonMoneyAddDesc.
  ///
  /// In de, this message translates to:
  /// **'Zwei Beträge addieren. Erst die Euro eingeben, dann die Cent.'**
  String get lessonMoneyAddDesc;

  /// No description provided for @lessonMoneySubTitle.
  ///
  /// In de, this message translates to:
  /// **'Geld abziehen'**
  String get lessonMoneySubTitle;

  /// No description provided for @lessonMoneySubDesc.
  ///
  /// In de, this message translates to:
  /// **'Was bleibt übrig, oder was gibt es zurück?'**
  String get lessonMoneySubDesc;

  /// No description provided for @lessonMoneyComposeTitle.
  ///
  /// In de, this message translates to:
  /// **'Betrag zusammenlegen'**
  String get lessonMoneyComposeTitle;

  /// No description provided for @lessonMoneyComposeDesc.
  ///
  /// In de, this message translates to:
  /// **'Lege den Betrag aus Münzen und Scheinen. Es gibt viele richtige Wege - der Betrag muss am Ende genau stimmen.'**
  String get lessonMoneyComposeDesc;

  /// No description provided for @lessonMoneyChangeTitle.
  ///
  /// In de, this message translates to:
  /// **'Was bekomme ich zurück?'**
  String get lessonMoneyChangeTitle;

  /// No description provided for @lessonMoneyChangeDesc.
  ///
  /// In de, this message translates to:
  /// **'Etwas kostet einen krummen Betrag, bezahlt wird mit einem glatten Schein oder Stück. Gesucht ist das Rückgeld.'**
  String get lessonMoneyChangeDesc;

  /// No description provided for @lessonPlaceValue100Title.
  ///
  /// In de, this message translates to:
  /// **'Einer und Zehner'**
  String get lessonPlaceValue100Title;

  /// No description provided for @lessonPlaceValue100Desc.
  ///
  /// In de, this message translates to:
  /// **'Wie viele Einer und Zehner sind es? Welche Zahl ist das zusammen? Es können auch mehr als neun Einer sein.'**
  String get lessonPlaceValue100Desc;

  /// No description provided for @lessonPlaceValue1000Title.
  ///
  /// In de, this message translates to:
  /// **'Einer, Zehner, Hunderter'**
  String get lessonPlaceValue1000Title;

  /// No description provided for @lessonPlaceValue1000Desc.
  ///
  /// In de, this message translates to:
  /// **'Wie viele Einer, Zehner und Hunderter sind es? Welche Zahl ist das zusammen? Es können auch mehr als neun von einer Sorte sein.'**
  String get lessonPlaceValue1000Desc;

  /// No description provided for @lessonRoundThousandsTitle.
  ///
  /// In de, this message translates to:
  /// **'Glatte Tausender'**
  String get lessonRoundThousandsTitle;

  /// No description provided for @lessonRoundThousandsDesc.
  ///
  /// In de, this message translates to:
  /// **'3000 + 4000, 8000 − 5000: rechne mit ganzen Tausendern. Wer 3 + 4 kann, kann das auch.'**
  String get lessonRoundThousandsDesc;

  /// No description provided for @lessonRoundHundredsTitle.
  ///
  /// In de, this message translates to:
  /// **'Glatte Hunderter'**
  String get lessonRoundHundredsTitle;

  /// No description provided for @lessonRoundHundredsDesc.
  ///
  /// In de, this message translates to:
  /// **'2300 + 400, 5600 − 200: rechne mit ganzen Hundertern. Hier geht es auch über den Tausender.'**
  String get lessonRoundHundredsDesc;

  /// No description provided for @lessonRoundGapTitle.
  ///
  /// In de, this message translates to:
  /// **'Glatte Zahlen mit Platzhalter'**
  String get lessonRoundGapTitle;

  /// No description provided for @lessonRoundGapDesc.
  ///
  /// In de, this message translates to:
  /// **'3000 + ? = 7000. Was fehlt bis zur Zahl? Rückwärts gedacht.'**
  String get lessonRoundGapDesc;

  /// No description provided for @lessonPlaceValue10000Title.
  ///
  /// In de, this message translates to:
  /// **'Einer, Zehner, Hunderter, Tausender'**
  String get lessonPlaceValue10000Title;

  /// No description provided for @lessonPlaceValue10000Desc.
  ///
  /// In de, this message translates to:
  /// **'Wie viele Einer, Zehner, Hunderter und Tausender sind es? Welche Zahl ist das zusammen? Es können auch mehr als neun von einer Sorte sein.'**
  String get lessonPlaceValue10000Desc;

  /// No description provided for @lessonAddSub10000PlainTitle.
  ///
  /// In de, this message translates to:
  /// **'Plus und Minus ohne Übergang'**
  String get lessonAddSub10000PlainTitle;

  /// No description provided for @lessonAddSub10000PlainDesc.
  ///
  /// In de, this message translates to:
  /// **'4200 + 350, 6870 − 40: vierstellig rechnen, aber ohne Übergang. Jede Stelle für sich.'**
  String get lessonAddSub10000PlainDesc;

  /// Asked in the "number bonds to ten" lesson: which number together with a makes ten ("in love" is the children's name for such a pair).
  ///
  /// In de, this message translates to:
  /// **'Welche Zahl ist mit {a} verliebt?'**
  String taskQuestionPartner(int a);

  /// Asked under a clock face.
  ///
  /// In de, this message translates to:
  /// **'Wie spät ist es?'**
  String get taskQuestionClock;

  /// Asked under a clock face; the child picks the spoken form of the time.
  ///
  /// In de, this message translates to:
  /// **'Wie sagt man das?'**
  String get taskQuestionClockPhrase;

  /// amount is a formatted price such as 3,50 €.
  ///
  /// In de, this message translates to:
  /// **'Lege {amount} - tippe die Münzen und Scheine an.'**
  String taskQuestionMoneyCompose(String amount);

  /// price and paid are formatted amounts of money.
  ///
  /// In de, this message translates to:
  /// **'Es kostet {price}. Du gibst {paid}. Wie viel bekommst du zurück?'**
  String taskQuestionChange(String price, String paid);

  /// Asked under a heap of pictures to count.
  ///
  /// In de, this message translates to:
  /// **'Wie viele?'**
  String get taskQuestionQuantity;

  /// Asked under one die.
  ///
  /// In de, this message translates to:
  /// **'Wie viele Punkte?'**
  String get taskQuestionDiceOne;

  /// Asked under two dice.
  ///
  /// In de, this message translates to:
  /// **'Wie viele Punkte sind es zusammen?'**
  String get taskQuestionDiceTwo;

  /// Two heaps of pictures are shown; the child types the larger count.
  ///
  /// In de, this message translates to:
  /// **'Wo sind mehr? Tippe die größere Anzahl.'**
  String get taskQuestionCompare;

  /// Asked under a row of numbers with the next one missing.
  ///
  /// In de, this message translates to:
  /// **'Welche Zahl kommt danach?'**
  String get taskQuestionSequence;

  /// Asked under two small groups of bees.
  ///
  /// In de, this message translates to:
  /// **'Wie viele sind es zusammen?'**
  String get taskQuestionQuantityAdd;

  /// Asked under a list such as "5 Einer, 12 Zehner, 3 Hunderter".
  ///
  /// In de, this message translates to:
  /// **'Welche Zahl ist das?'**
  String get taskQuestionPlaceValue;

  /// Label of the second answer box in a division with remainder.
  ///
  /// In de, this message translates to:
  /// **'Rest'**
  String get taskLabelRemainder;

  /// Label between the euro box and the cent box.
  ///
  /// In de, this message translates to:
  /// **'€'**
  String get taskLabelEuro;

  /// Label between the hour box and the minute box (as in "3 Uhr 15").
  ///
  /// In de, this message translates to:
  /// **'Uhr'**
  String get taskLabelClock;

  /// Unit after the cent box. Short for cents.
  ///
  /// In de, this message translates to:
  /// **'ct'**
  String get taskUnitCents;

  /// A count of ones in a place-value task, e.g. "5 Einer".
  ///
  /// In de, this message translates to:
  /// **'{n} Einer'**
  String placeOnes(int n);

  /// A count of tens, e.g. "12 Zehner".
  ///
  /// In de, this message translates to:
  /// **'{n} Zehner'**
  String placeTens(int n);

  /// A count of hundreds.
  ///
  /// In de, this message translates to:
  /// **'{n} Hunderter'**
  String placeHundreds(int n);

  /// A count of thousands.
  ///
  /// In de, this message translates to:
  /// **'{n} Tausender'**
  String placeThousands(int n);

  /// One-line text of a division with remainder, e.g. "17 : 5 = 3 Rest 2".
  ///
  /// In de, this message translates to:
  /// **'{prefix} {answer} Rest {second}'**
  String taskRenderRemainder(String prefix, String answer, String second);

  /// A sample time on a lesson tile; minute is two digits.
  ///
  /// In de, this message translates to:
  /// **'{hour}:{minute} Uhr'**
  String taskRenderClock(int hour, String minute);

  /// Sample of a change task on a lesson tile; both are formatted amounts of money.
  ///
  /// In de, this message translates to:
  /// **'{price}, bezahlt mit {paid}'**
  String taskRenderChange(String price, String paid);

  /// Sample of a die task on a tile.
  ///
  /// In de, this message translates to:
  /// **'{a} Punkte'**
  String taskRenderDiceOne(int a);

  /// Sample of a two-dice task on a tile.
  ///
  /// In de, this message translates to:
  /// **'{a} + {b} Punkte'**
  String taskRenderDiceTwo(int a, int b);

  /// Part of the day shown under a 24-hour clock: before noon.
  ///
  /// In de, this message translates to:
  /// **'vormittags'**
  String get dayPartMorning;

  /// Part of the day: exactly twelve o'clock.
  ///
  /// In de, this message translates to:
  /// **'mittags'**
  String get dayPartNoon;

  /// Part of the day: from one to five in the afternoon.
  ///
  /// In de, this message translates to:
  /// **'nachmittags'**
  String get dayPartAfternoon;

  /// Part of the day: from six o'clock on.
  ///
  /// In de, this message translates to:
  /// **'abends'**
  String get dayPartEvening;

  /// How the time :05 is said out loud, without the hour. Eleven such forms (:05 to :55) are keys on the pad, so keep them short. The hour comes from clockSpokenTime.
  ///
  /// In de, this message translates to:
  /// **'5 nach'**
  String get clockPhrase05;

  /// No description provided for @clockPhrase10.
  ///
  /// In de, this message translates to:
  /// **'10 nach'**
  String get clockPhrase10;

  /// No description provided for @clockPhrase15.
  ///
  /// In de, this message translates to:
  /// **'viertel nach'**
  String get clockPhrase15;

  /// No description provided for @clockPhrase20.
  ///
  /// In de, this message translates to:
  /// **'20 nach'**
  String get clockPhrase20;

  /// No description provided for @clockPhrase25.
  ///
  /// In de, this message translates to:
  /// **'5 vor halb'**
  String get clockPhrase25;

  /// German "halb 3" means 2:30 (half way to three).
  ///
  /// In de, this message translates to:
  /// **'halb'**
  String get clockPhrase30;

  /// No description provided for @clockPhrase35.
  ///
  /// In de, this message translates to:
  /// **'5 nach halb'**
  String get clockPhrase35;

  /// No description provided for @clockPhrase40.
  ///
  /// In de, this message translates to:
  /// **'20 vor'**
  String get clockPhrase40;

  /// No description provided for @clockPhrase45.
  ///
  /// In de, this message translates to:
  /// **'viertel vor'**
  String get clockPhrase45;

  /// No description provided for @clockPhrase50.
  ///
  /// In de, this message translates to:
  /// **'10 vor'**
  String get clockPhrase50;

  /// No description provided for @clockPhrase55.
  ///
  /// In de, this message translates to:
  /// **'5 vor'**
  String get clockPhrase55;

  /// A spoken time: the phrase and the hour it names, e.g. "viertel vor 3". A language that says the hour first puts {hour} first here.
  ///
  /// In de, this message translates to:
  /// **'{phrase} {hour}'**
  String clockSpokenTime(String phrase, int hour);

  /// Choice for hiding finished lessons: show everything.
  ///
  /// In de, this message translates to:
  /// **'Alle zeigen'**
  String get filterAllTitle;

  /// No description provided for @filterAllText.
  ///
  /// In de, this message translates to:
  /// **'Der ganze Katalog, nichts wird versteckt.'**
  String get filterAllText;

  /// No description provided for @filterMasteredTitle.
  ///
  /// In de, this message translates to:
  /// **'Mit 3 Sternen ausblenden'**
  String get filterMasteredTitle;

  /// No description provided for @filterMasteredText.
  ///
  /// In de, this message translates to:
  /// **'Was sicher sitzt, verschwindet aus der Liste. Übrig bleibt, was noch Fehler macht.'**
  String get filterMasteredText;

  /// Stars stand for accuracy, lightning bolts for speed.
  ///
  /// In de, this message translates to:
  /// **'Erst mit 3 Sternen und 3 Blitzen'**
  String get filterPerfectedTitle;

  /// The ** marks are Markdown bold; they are removed before display where bold is not supported.
  ///
  /// In de, this message translates to:
  /// **'Nur was sicher **und** schnell ist, verschwindet. Was zwar fehlerfrei, aber noch langsam ist, bleibt zum Üben stehen.'**
  String get filterPerfectedText;

  /// Chip for the log of practice runs: all time.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get rangeAll;

  /// No description provided for @rangeToday.
  ///
  /// In de, this message translates to:
  /// **'Heute'**
  String get rangeToday;

  /// Last seven calendar days including today.
  ///
  /// In de, this message translates to:
  /// **'7 Tage'**
  String get rangeWeek;

  /// No description provided for @rangeMonth.
  ///
  /// In de, this message translates to:
  /// **'30 Tage'**
  String get rangeMonth;

  /// Used inside a sentence: "... aufräumen {range}".
  ///
  /// In de, this message translates to:
  /// **'aus dem ganzen Verlauf'**
  String get rangeAllPhrase;

  /// No description provided for @rangeTodayPhrase.
  ///
  /// In de, this message translates to:
  /// **'von heute'**
  String get rangeTodayPhrase;

  /// No description provided for @rangeWeekPhrase.
  ///
  /// In de, this message translates to:
  /// **'aus den letzten 7 Tagen'**
  String get rangeWeekPhrase;

  /// No description provided for @rangeMonthPhrase.
  ///
  /// In de, this message translates to:
  /// **'aus den letzten 30 Tagen'**
  String get rangeMonthPhrase;

  /// No description provided for @backupErrorNotABackup.
  ///
  /// In de, this message translates to:
  /// **'Die Datei ist keine gültige Sicherung.'**
  String get backupErrorNotABackup;

  /// No description provided for @backupErrorWrongApp.
  ///
  /// In de, this message translates to:
  /// **'Diese Datei stammt nicht aus dem Mathe-Trainer.'**
  String get backupErrorWrongApp;

  /// No description provided for @backupErrorTooNew.
  ///
  /// In de, this message translates to:
  /// **'Die Sicherung stammt aus einer neueren Version der App.'**
  String get backupErrorTooNew;

  /// A time in seconds with one decimal place, e.g. "12,5 s". value is already formatted with the decimal separator of the language.
  ///
  /// In de, this message translates to:
  /// **'{value} s'**
  String formatSeconds(String value);

  /// A time of a minute or more, e.g. "1:05 min"; seconds are two digits.
  ///
  /// In de, this message translates to:
  /// **'{minutes}:{seconds} min'**
  String formatMinutesSeconds(int minutes, String seconds);

  /// Summed practice time, e.g. "3 h 12 min".
  ///
  /// In de, this message translates to:
  /// **'{hours} h {minutes} min'**
  String formatHoursMinutes(int hours, int minutes);

  /// Short date and time for a list, e.g. "5.9. · 14:32".
  ///
  /// In de, this message translates to:
  /// **'{day} · {time}'**
  String formatDayAndTime(String day, String time);

  /// "Last active" wording: today.
  ///
  /// In de, this message translates to:
  /// **'heute'**
  String get relativeToday;

  /// No description provided for @relativeYesterday.
  ///
  /// In de, this message translates to:
  /// **'gestern'**
  String get relativeYesterday;

  /// Used for two to six days ago only.
  ///
  /// In de, this message translates to:
  /// **'vor {days} Tagen'**
  String relativeDaysAgo(int days);

  /// Time left until the break ends, in a sentence such as "Weiter geht es um 11:15 - gleich". 0 means "in a moment".
  ///
  /// In de, this message translates to:
  /// **'{minutes, plural, =0{gleich} =1{noch eine Minute} other{noch {minutes} Minuten}}'**
  String remainingMinutes(int minutes);

  /// A price; amount is already formatted with the decimal separator of the language, e.g. "3,50".
  ///
  /// In de, this message translates to:
  /// **'{amount} €'**
  String moneyAmount(String amount);

  /// A coin of less than one euro as stamped on it, e.g. "50 ct".
  ///
  /// In de, this message translates to:
  /// **'{n} ct'**
  String moneyCoinCents(int n);

  /// A coin or note of whole euros, e.g. "2 €".
  ///
  /// In de, this message translates to:
  /// **'{n} €'**
  String moneyCoinEuros(int n);

  /// Deadline of a task on a card: due today.
  ///
  /// In de, this message translates to:
  /// **'heute'**
  String get deadlineToday;

  /// Deadline of a weekly task: until the end of the week.
  ///
  /// In de, this message translates to:
  /// **'bis Sonntag'**
  String get deadlineUntilSunday;

  /// Deadline of a task from an earlier day that is still to be done.
  ///
  /// In de, this message translates to:
  /// **'noch offen'**
  String get deadlineStillOpen;

  /// A task whose day is over; day is a short date such as "Mi, 16.9.".
  ///
  /// In de, this message translates to:
  /// **'war {day}'**
  String deadlineWas(String day);

  /// No description provided for @deadlineThisWeek.
  ///
  /// In de, this message translates to:
  /// **'diese Woche'**
  String get deadlineThisWeek;

  /// A task that starts in a later week; day is a short date.
  ///
  /// In de, this message translates to:
  /// **'ab {day}'**
  String deadlineFrom(String day);

  /// A task for one day; day is a short date such as "Mi, 16.9.".
  ///
  /// In de, this message translates to:
  /// **'am {day}'**
  String deadlineOn(String day);

  /// Seconds, short.
  ///
  /// In de, this message translates to:
  /// **'{n} s'**
  String commonSecondsShort(int n);

  /// A percentage.
  ///
  /// In de, this message translates to:
  /// **'{n} %'**
  String commonPercent(int n);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
