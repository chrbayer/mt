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

  /// No description provided for @commonMinutesShort.
  ///
  /// In de, this message translates to:
  /// **'{n} min'**
  String commonMinutesShort(int n);

  /// No description provided for @versionLabel.
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

  /// No description provided for @amountNoLimit.
  ///
  /// In de, this message translates to:
  /// **'ohne Grenze'**
  String get amountNoLimit;

  /// No description provided for @amountSameAsAll.
  ///
  /// In de, this message translates to:
  /// **'wie für alle'**
  String get amountSameAsAll;

  /// No description provided for @amountSameAsAllWith.
  ///
  /// In de, this message translates to:
  /// **'wie für alle ({value})'**
  String amountSameAsAllWith(String value);

  /// No description provided for @taskCountSameEverywhere.
  ///
  /// In de, this message translates to:
  /// **'wie überall'**
  String get taskCountSameEverywhere;

  /// No description provided for @taskCountSameEverywhereWith.
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

  /// No description provided for @soundTestAllPlayed.
  ///
  /// In de, this message translates to:
  /// **'{played} von {expected} Klicks haben gespielt. War nichts zu hören, liegt es an der Lautstärke des Geräts.'**
  String soundTestAllPlayed(int played, int expected);

  /// No description provided for @soundTestSomePlayed.
  ///
  /// In de, this message translates to:
  /// **'Nur {played} von {expected} Klicks haben gespielt - der Ton bricht auf diesem Gerät ab.'**
  String soundTestSomePlayed(int played, int expected);

  /// No description provided for @soundTestUnavailable.
  ///
  /// In de, this message translates to:
  /// **'Der Ton ist auf diesem Gerät nicht verfügbar:\n{error}'**
  String soundTestUnavailable(String error);

  /// No description provided for @recommendShaky.
  ///
  /// In de, this message translates to:
  /// **'Da war es zuletzt wackelig'**
  String get recommendShaky;

  /// No description provided for @recommendFresh.
  ///
  /// In de, this message translates to:
  /// **'Das hast du noch nie geübt'**
  String get recommendFresh;

  /// No description provided for @recommendStale.
  ///
  /// In de, this message translates to:
  /// **'Lange nicht mehr geübt'**
  String get recommendStale;

  /// No description provided for @pauseDayDoneTitle.
  ///
  /// In de, this message translates to:
  /// **'Für heute reicht es!'**
  String get pauseDayDoneTitle;

  /// No description provided for @pauseDayDoneText.
  ///
  /// In de, this message translates to:
  /// **'Du hast heute {minutes} Minuten gerechnet. Morgen geht es weiter.'**
  String pauseDayDoneText(int minutes);

  /// No description provided for @pauseBreakTitle.
  ///
  /// In de, this message translates to:
  /// **'Pause!'**
  String get pauseBreakTitle;

  /// No description provided for @pauseBreakText.
  ///
  /// In de, this message translates to:
  /// **'Du hast {minutes} Minuten am Stück geübt. Weiter geht es um {clock} - {left}.'**
  String pauseBreakText(int minutes, String clock, String left);

  /// No description provided for @pauseClock.
  ///
  /// In de, this message translates to:
  /// **'{time} Uhr'**
  String pauseClock(String time);

  /// No description provided for @runHintTooShort.
  ///
  /// In de, this message translates to:
  /// **'Zählt nicht: keine Sterne, keine Blitze, keine Bestenliste.'**
  String get runHintTooShort;

  /// No description provided for @runHintUsedUpToday.
  ///
  /// In de, this message translates to:
  /// **'Heute schon {count}× gewertet - üben geht weiter, zählen nicht mehr.'**
  String runHintUsedUpToday(int count);

  /// No description provided for @runHintRemaining.
  ///
  /// In de, this message translates to:
  /// **'{minutes, plural, =0{Gleich ist Pause.} =1{Noch eine Minute, dann ist Pause.} other{Noch {minutes} Minuten, dann ist Pause.}}'**
  String runHintRemaining(int minutes);

  /// No description provided for @assignmentGoalDone.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe geschafft!'**
  String get assignmentGoalDone;

  /// No description provided for @assignmentGoalCounts.
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

  /// No description provided for @todayNothingOfLimit.
  ///
  /// In de, this message translates to:
  /// **'noch nichts von {limit} min'**
  String todayNothingOfLimit(int limit);

  /// No description provided for @todayTimeOfLimit.
  ///
  /// In de, this message translates to:
  /// **'{time} von {limit} min'**
  String todayTimeOfLimit(String time, int limit);

  /// No description provided for @progressChartEmpty.
  ///
  /// In de, this message translates to:
  /// **'Ab dem zweiten Durchgang siehst du hier deine Lernkurve.'**
  String get progressChartEmpty;

  /// No description provided for @starRowEarnedOf.
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

  /// No description provided for @backupExportFailed.
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

  /// No description provided for @backupImported.
  ///
  /// In de, this message translates to:
  /// **'{users} Profile und {sessions} Durchgänge eingespielt.'**
  String backupImported(int users, int sessions);

  /// No description provided for @backupImportFailed.
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

  /// No description provided for @backupLast.
  ///
  /// In de, this message translates to:
  /// **'Zuletzt gesichert: {when}.'**
  String backupLast(String when);

  /// No description provided for @backupLastOverdue.
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

  /// No description provided for @pinHintChoose.
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

  /// No description provided for @startExample.
  ///
  /// In de, this message translates to:
  /// **'Zum Beispiel:  {example}'**
  String startExample(String example);

  /// No description provided for @startAssignmentGoal.
  ///
  /// In de, this message translates to:
  /// **'Für deine Aufgabe: {count} Rechnungen'**
  String startAssignmentGoal(int count);

  /// No description provided for @startHowMany.
  ///
  /// In de, this message translates to:
  /// **'Wie viele Aufgaben?'**
  String get startHowMany;

  /// No description provided for @startBoltsFrom.
  ///
  /// In de, this message translates to:
  /// **'ab {time} pro Aufgabe'**
  String startBoltsFrom(String time);

  /// No description provided for @startGo.
  ///
  /// In de, this message translates to:
  /// **'Los geht\'s'**
  String get startGo;

  /// No description provided for @startLeaderboard.
  ///
  /// In de, this message translates to:
  /// **'Bestenliste'**
  String get startLeaderboard;

  /// No description provided for @commonPerTask.
  ///
  /// In de, this message translates to:
  /// **'pro Aufgabe'**
  String get commonPerTask;

  /// No description provided for @commonErrors.
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get commonErrors;

  /// No description provided for @commonTasks.
  ///
  /// In de, this message translates to:
  /// **'Aufgaben'**
  String get commonTasks;

  /// No description provided for @leaderboardTitle.
  ///
  /// In de, this message translates to:
  /// **'Bestenliste · {lesson}'**
  String leaderboardTitle(String lesson);

  /// No description provided for @leaderboardEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Ergebnisse.\nMindestens {min} Aufgaben zählen für die Bestenliste.'**
  String leaderboardEmpty(int min);

  /// No description provided for @leaderboardScoreExplanation.
  ///
  /// In de, this message translates to:
  /// **'Gewertet wird die Zeit pro Aufgabe, plus 3 Sekunden für jeden Fehlversuch. Deshalb lohnt sich Raten nicht, und Durchgänge mit unterschiedlich vielen Aufgaben bleiben vergleichbar.'**
  String get leaderboardScoreExplanation;

  /// No description provided for @statsTitle.
  ///
  /// In de, this message translates to:
  /// **'Statistik · {name}'**
  String statsTitle(String name);

  /// No description provided for @statsEmpty.
  ///
  /// In de, this message translates to:
  /// **'Noch keine abgeschlossenen Durchgänge.'**
  String get statsEmpty;

  /// No description provided for @statsLearningCurve.
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

  /// No description provided for @statsHeadBest.
  ///
  /// In de, this message translates to:
  /// **'Bestzeit'**
  String get statsHeadBest;

  /// No description provided for @statsHeadAverage.
  ///
  /// In de, this message translates to:
  /// **'Ø Zeit'**
  String get statsHeadAverage;

  /// No description provided for @statsHeadRuns.
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

  /// No description provided for @globalStatsActivityHeading.
  ///
  /// In de, this message translates to:
  /// **'Geübt in den letzten {days} Tagen'**
  String globalStatsActivityHeading(int days);

  /// No description provided for @globalStatsActivitySub.
  ///
  /// In de, this message translates to:
  /// **'Minuten pro Tag, je Kind in seiner Farbe'**
  String get globalStatsActivitySub;

  /// No description provided for @globalStatsNoLeaderboards.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Bestenlisten.\nEin Durchgang zählt ab {min} Aufgaben.'**
  String globalStatsNoLeaderboards(int min);

  /// No description provided for @globalStatsNotPlayed.
  ///
  /// In de, this message translates to:
  /// **'Noch nicht geübt.'**
  String get globalStatsNotPlayed;

  /// No description provided for @globalStatsRounds.
  ///
  /// In de, this message translates to:
  /// **'{n, plural, =1{Runde} other{Runden}}'**
  String globalStatsRounds(int n);

  /// No description provided for @globalStatsPractised.
  ///
  /// In de, this message translates to:
  /// **'geübt'**
  String get globalStatsPractised;

  /// No description provided for @globalStatsStreak.
  ///
  /// In de, this message translates to:
  /// **'{days} Tage in Folge'**
  String globalStatsStreak(int days);

  /// No description provided for @globalStatsLastPlayed.
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

  /// No description provided for @profilesDuel.
  ///
  /// In de, this message translates to:
  /// **'Duell'**
  String get profilesDuel;

  /// No description provided for @profilesParents.
  ///
  /// In de, this message translates to:
  /// **'Eltern'**
  String get profilesParents;

  /// No description provided for @profilesNone.
  ///
  /// In de, this message translates to:
  /// **'Noch kein Profil. Tippe auf „Neu\", um anzufangen.'**
  String get profilesNone;

  /// No description provided for @profilesLockedTitle.
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

  /// No description provided for @profilesTodo.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{1 Aufgabe} other{{count} Aufgaben}}'**
  String profilesTodo(int count);

  /// No description provided for @profilesEditLook.
  ///
  /// In de, this message translates to:
  /// **'Bild und Farbe ändern'**
  String get profilesEditLook;

  /// No description provided for @profilesNew.
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

  /// No description provided for @profileEditorNext.
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

  /// No description provided for @duelPlayerLocked.
  ///
  /// In de, this message translates to:
  /// **'{avatar}  {name} · gesperrt'**
  String duelPlayerLocked(String avatar, String name);

  /// No description provided for @duelPlayerOnBreak.
  ///
  /// In de, this message translates to:
  /// **'{avatar}  {name} · Pause'**
  String duelPlayerOnBreak(String avatar, String name);

  /// No description provided for @duelPlayer.
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

  /// No description provided for @duelLessonChip.
  ///
  /// In de, this message translates to:
  /// **'{title}  ·  {example}'**
  String duelLessonChip(String title, String example);

  /// No description provided for @duelStart.
  ///
  /// In de, this message translates to:
  /// **'Duell starten'**
  String get duelStart;

  /// No description provided for @duelPosition.
  ///
  /// In de, this message translates to:
  /// **'{position} von {total}'**
  String duelPosition(int position, int total);

  /// No description provided for @duelYourTurn.
  ///
  /// In de, this message translates to:
  /// **'{name} ist dran'**
  String duelYourTurn(String name);

  /// No description provided for @duelLessonAndGroup.
  ///
  /// In de, this message translates to:
  /// **'{lesson} · {group}'**
  String duelLessonAndGroup(String lesson, String group);

  /// No description provided for @duelReady.
  ///
  /// In de, this message translates to:
  /// **'Bereit'**
  String get duelReady;

  /// No description provided for @duelAbort.
  ///
  /// In de, this message translates to:
  /// **'Duell abbrechen'**
  String get duelAbort;

  /// No description provided for @duelResultTitle.
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

  /// No description provided for @duelWin.
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

  /// No description provided for @resultDoneName.
  ///
  /// In de, this message translates to:
  /// **'Geschafft, {name}!'**
  String resultDoneName(String name);

  /// No description provided for @resultNextBolt.
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

  /// No description provided for @resultMetricPerTask.
  ///
  /// In de, this message translates to:
  /// **'Pro Aufgabe'**
  String get resultMetricPerTask;

  /// No description provided for @resultMetricErrors.
  ///
  /// In de, this message translates to:
  /// **'Fehler'**
  String get resultMetricErrors;

  /// No description provided for @resultPenalty.
  ///
  /// In de, this message translates to:
  /// **'Darin sind {penalty} Zeitstrafe für {count, plural, =1{1 Fehlversuch} other{{count} Fehlversuche}} enthalten - 3 Sekunden für jeden.'**
  String resultPenalty(String penalty, int count);

  /// No description provided for @resultStreak.
  ///
  /// In de, this message translates to:
  /// **'{days} Tage in Folge geübt!'**
  String resultStreak(int days);

  /// No description provided for @resultAgain.
  ///
  /// In de, this message translates to:
  /// **'Nochmal'**
  String get resultAgain;

  /// No description provided for @resultLeaderboard.
  ///
  /// In de, this message translates to:
  /// **'Bestenliste'**
  String get resultLeaderboard;

  /// No description provided for @resultOtherLesson.
  ///
  /// In de, this message translates to:
  /// **'Andere Lektion'**
  String get resultOtherLesson;

  /// No description provided for @resultFirstRun.
  ///
  /// In de, this message translates to:
  /// **'Das war dein erster Durchgang hier -\ndie Zeit ist ab jetzt dein Rekord.'**
  String get resultFirstRun;

  /// No description provided for @resultSameSpeed.
  ///
  /// In de, this message translates to:
  /// **'Genau so schnell wie beim letzten Mal.'**
  String get resultSameSpeed;

  /// No description provided for @resultFaster.
  ///
  /// In de, this message translates to:
  /// **'{delta} schneller pro Aufgabe als beim letzten Mal!'**
  String resultFaster(String delta);

  /// No description provided for @resultSlower.
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

  /// No description provided for @practiceKeepGoing.
  ///
  /// In de, this message translates to:
  /// **'Weiter rechnen'**
  String get practiceKeepGoing;

  /// No description provided for @practiceAbortConfirm.
  ///
  /// In de, this message translates to:
  /// **'Beenden'**
  String get practiceAbortConfirm;

  /// No description provided for @practiceAbortTooltip.
  ///
  /// In de, this message translates to:
  /// **'Übung beenden'**
  String get practiceAbortTooltip;

  /// No description provided for @practicePause.
  ///
  /// In de, this message translates to:
  /// **'Pause'**
  String get practicePause;

  /// No description provided for @practicePauseNote.
  ///
  /// In de, this message translates to:
  /// **'Die Zeit läuft nicht weiter.'**
  String get practicePauseNote;

  /// No description provided for @practiceResume.
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

  /// No description provided for @lessonsStatsLabel.
  ///
  /// In de, this message translates to:
  /// **'Statistik'**
  String get lessonsStatsLabel;

  /// No description provided for @lessonsSettingsTooltip.
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get lessonsSettingsTooltip;

  /// No description provided for @lessonsSwitchLabel.
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

  /// No description provided for @lessonsRecommendGo.
  ///
  /// In de, this message translates to:
  /// **'Los'**
  String get lessonsRecommendGo;

  /// No description provided for @lessonsRecommendTitle.
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

  /// No description provided for @lessonsPractisedTimes.
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

  /// No description provided for @adminFilterAll.
  ///
  /// In de, this message translates to:
  /// **'Alle'**
  String get adminFilterAll;

  /// No description provided for @adminShowDeleted.
  ///
  /// In de, this message translates to:
  /// **'Gelöschte'**
  String get adminShowDeleted;

  /// No description provided for @adminHistoryTruncated.
  ///
  /// In de, this message translates to:
  /// **'Es werden die letzten {limit} Durchgänge angezeigt. Ein kürzerer Zeitraum zeigt den Rest.'**
  String adminHistoryTruncated(int limit);

  /// No description provided for @adminCleanupAll.
  ///
  /// In de, this message translates to:
  /// **'Abgebrochene Durchgänge aufräumen ({count})'**
  String adminCleanupAll(int count);

  /// No description provided for @adminCleanupOne.
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

  /// No description provided for @adminDeleteRunText.
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

  /// No description provided for @adminWhoOne.
  ///
  /// In de, this message translates to:
  /// **'von {name}'**
  String adminWhoOne(String name);

  /// No description provided for @adminCleanupTitle.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Einen abgebrochenen Durchgang aufräumen?} other{{count} abgebrochene Durchgänge aufräumen?}}'**
  String adminCleanupTitle(int count);

  /// No description provided for @adminCleanupText.
  ///
  /// In de, this message translates to:
  /// **'Es verschwinden die abgebrochenen Durchgänge {whose} {range}. Sie zählten nie für Sterne, Blitze oder eine Bestenliste - die geübte Zeit bleibt gezählt.'**
  String adminCleanupText(String whose, String range);

  /// No description provided for @adminCleanupConfirm.
  ///
  /// In de, this message translates to:
  /// **'Aufräumen'**
  String get adminCleanupConfirm;

  /// No description provided for @adminCleanedUp.
  ///
  /// In de, this message translates to:
  /// **'{count, plural, =1{Ein abgebrochener Durchgang aufgeräumt.} other{{count} abgebrochene Durchgänge aufgeräumt.}}'**
  String adminCleanedUp(int count);

  /// No description provided for @adminHistoryLessonLine.
  ///
  /// In de, this message translates to:
  /// **'{lesson}  ·  {group}'**
  String adminHistoryLessonLine(String lesson, String group);

  /// No description provided for @adminAbortedAfter.
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

  /// No description provided for @adminGroupsSome.
  ///
  /// In de, this message translates to:
  /// **'{n} von {total} Bereichen'**
  String adminGroupsSome(int n, int total);

  /// No description provided for @adminLocked.
  ///
  /// In de, this message translates to:
  /// **'Gesperrt'**
  String get adminLocked;

  /// No description provided for @adminNoReview.
  ///
  /// In de, this message translates to:
  /// **'ohne Wiederholung'**
  String get adminNoReview;

  /// No description provided for @profileSettingsDiscardTitle.
  ///
  /// In de, this message translates to:
  /// **'Änderungen verwerfen?'**
  String get profileSettingsDiscardTitle;

  /// No description provided for @profileSettingsDiscardText.
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

  /// No description provided for @profileSettingsResetTitle.
  ///
  /// In de, this message translates to:
  /// **'Ergebnisse von {name} löschen?'**
  String profileSettingsResetTitle(String name);

  /// No description provided for @profileSettingsResetText.
  ///
  /// In de, this message translates to:
  /// **'Bestzeiten, Lernkurve und Verlauf gehen verloren. Das Profil selbst bleibt bestehen.'**
  String get profileSettingsResetText;

  /// No description provided for @profileSettingsDeleteTitle.
  ///
  /// In de, this message translates to:
  /// **'{name} löschen?'**
  String profileSettingsDeleteTitle(String name);

  /// No description provided for @profileSettingsDeleteText.
  ///
  /// In de, this message translates to:
  /// **'Profil und alle Ergebnisse werden entfernt.'**
  String get profileSettingsDeleteText;

  /// No description provided for @profileSettingsGroupSummary.
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

  /// No description provided for @resetStarsTitle.
  ///
  /// In de, this message translates to:
  /// **'Sterne in „{group}\" zurücksetzen?'**
  String resetStarsTitle(String group);

  /// No description provided for @resetStarsText.
  ///
  /// In de, this message translates to:
  /// **'{name} kann sie danach neu verdienen. Bestzeiten, Blitze, Lernkurve und Bestenlisten bleiben unverändert - es geht nur um die Sterne dieser Gruppe.'**
  String resetStarsText(String name);

  /// No description provided for @resetStarsConfirm.
  ///
  /// In de, this message translates to:
  /// **'Zurücksetzen'**
  String get resetStarsConfirm;

  /// No description provided for @resetStarsHeading.
  ///
  /// In de, this message translates to:
  /// **'Sterne von {name}'**
  String resetStarsHeading(String name);

  /// No description provided for @resetStarsNote.
  ///
  /// In de, this message translates to:
  /// **'Zurückgesetzt werden nur die Sterne. Die Zeiten bleiben - Bestzeiten, Blitze, Lernkurve und Bestenlisten sind danach genau wie vorher.'**
  String get resetStarsNote;

  /// No description provided for @resetStarsDone.
  ///
  /// In de, this message translates to:
  /// **'Fertig'**
  String get resetStarsDone;

  /// No description provided for @resetStarsGroupLine.
  ///
  /// In de, this message translates to:
  /// **'{earned} von {possible} Sternen'**
  String resetStarsGroupLine(int earned, int possible);

  /// No description provided for @assignmentsAll.
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

  /// No description provided for @assignmentsHiddenCount.
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

  /// No description provided for @assignmentsPeriodDays.
  ///
  /// In de, this message translates to:
  /// **'Tagen'**
  String get assignmentsPeriodDays;

  /// No description provided for @assignmentsPeriodWeeks.
  ///
  /// In de, this message translates to:
  /// **'Wochen'**
  String get assignmentsPeriodWeeks;

  /// No description provided for @assignmentsDaily.
  ///
  /// In de, this message translates to:
  /// **'täglich'**
  String get assignmentsDaily;

  /// No description provided for @assignmentsWeekly.
  ///
  /// In de, this message translates to:
  /// **'wöchentlich'**
  String get assignmentsWeekly;

  /// No description provided for @assignmentsCarriesOver.
  ///
  /// In de, this message translates to:
  /// **' · zieht nach'**
  String get assignmentsCarriesOver;

  /// No description provided for @assignmentsLessonCount.
  ///
  /// In de, this message translates to:
  /// **'{count} Übungen'**
  String assignmentsLessonCount(int count);

  /// No description provided for @assignmentsEdit.
  ///
  /// In de, this message translates to:
  /// **'Ändern'**
  String get assignmentsEdit;

  /// No description provided for @assignmentsEnd.
  ///
  /// In de, this message translates to:
  /// **'Beenden'**
  String get assignmentsEnd;

  /// No description provided for @assignmentsRepeat.
  ///
  /// In de, this message translates to:
  /// **'Erneut stellen'**
  String get assignmentsRepeat;

  /// No description provided for @assignmentsDelete.
  ///
  /// In de, this message translates to:
  /// **'Aufgabe löschen'**
  String get assignmentsDelete;

  /// No description provided for @assignmentsRunsOfTasks.
  ///
  /// In de, this message translates to:
  /// **'{runs}× {tasks} Rechnungen'**
  String assignmentsRunsOfTasks(int runs, int tasks);

  /// No description provided for @assignmentsMinStars.
  ///
  /// In de, this message translates to:
  /// **'mind. {count} ★'**
  String assignmentsMinStars(int count);

  /// No description provided for @assignmentsMinBolts.
  ///
  /// In de, this message translates to:
  /// **'mind. {count} ⚡'**
  String assignmentsMinBolts(int count);

  /// No description provided for @assignmentsNoClosedPeriod.
  ///
  /// In de, this message translates to:
  /// **'Noch kein abgeschlossener Zeitraum'**
  String get assignmentsNoClosedPeriod;

  /// No description provided for @assignmentsMetOf.
  ///
  /// In de, this message translates to:
  /// **'Geschafft an {met} von {total} {period}'**
  String assignmentsMetOf(int met, int total, String period);

  /// No description provided for @assignmentsBefore.
  ///
  /// In de, this message translates to:
  /// **'· davor {met} von {total} {period}'**
  String assignmentsBefore(int met, int total, String period);

  /// No description provided for @assignmentsVerdictMet.
  ///
  /// In de, this message translates to:
  /// **'Geschafft'**
  String get assignmentsVerdictMet;

  /// No description provided for @assignmentsVerdictPending.
  ///
  /// In de, this message translates to:
  /// **'Steht noch aus'**
  String get assignmentsVerdictPending;

  /// No description provided for @assignmentsVerdictLate.
  ///
  /// In de, this message translates to:
  /// **'Verpasst, später nachgeholt'**
  String get assignmentsVerdictLate;

  /// No description provided for @assignmentsVerdictMissed.
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

  /// No description provided for @editorLessons.
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

  /// No description provided for @editorPeriod.
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

  /// No description provided for @editorEveryTime.
  ///
  /// In de, this message translates to:
  /// **'jedes Mal'**
  String get editorEveryTime;

  /// No description provided for @editorOnce.
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

  /// No description provided for @editorOnDay.
  ///
  /// In de, this message translates to:
  /// **'Am {day}'**
  String editorOnDay(String day);

  /// No description provided for @editorInWeek.
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

  /// No description provided for @editorCreate.
  ///
  /// In de, this message translates to:
  /// **'Anlegen'**
  String get editorCreate;

  /// No description provided for @editorDayLabel.
  ///
  /// In de, this message translates to:
  /// **'{weekday, select, 1{Mo} 2{Di} 3{Mi} 4{Do} 5{Fr} 6{Sa} 7{So} other{}}, {day}.{month}.'**
  String editorDayLabel(String weekday, int day, int month);
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
