// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Mathe-Trainer';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonDelete => 'Löschen';

  @override
  String commonMinutesShort(int n) {
    return '$n min';
  }

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get loadFailureMessage => 'Das konnte gerade nicht geladen werden.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsTaskCountHeading => 'Aufgaben pro Durchgang';

  @override
  String get settingsParentAreaNote =>
      'Uhr und Vibration, die Vorgabe für alle, Ergebnisse löschen, Profile verwalten und den Übungsverlauf ansehen: das steht im Elternbereich auf dem Startbildschirm, geschützt durch die PIN.';

  @override
  String get amountNoLimit => 'ohne Grenze';

  @override
  String get amountSameAsAll => 'wie für alle';

  @override
  String amountSameAsAllWith(String value) {
    return 'wie für alle ($value)';
  }

  @override
  String get taskCountSameEverywhere => 'wie überall';

  @override
  String taskCountSameEverywhereWith(int count) {
    return 'wie überall ($count)';
  }

  @override
  String get taskCountExplanationProfile =>
      'Es gilt jeweils das Genaueste: eine offene Aufgabe zuerst, sonst was zuletzt bei einer Lektion gewählt wurde, sonst diese hier, sonst die Vorgabe für alle.';

  @override
  String get taskCountExplanationGlobal =>
      'Es gilt jeweils das Genaueste: eine offene Aufgabe zuerst, sonst was zuletzt bei einer Lektion gewählt wurde, sonst die Vorgabe des Profils, sonst diese hier.';

  @override
  String get soundTestRunning => 'Spielt …';

  @override
  String get soundTestButton => 'Ton testen (10 Klicks)';

  @override
  String soundTestAllPlayed(int played, int expected) {
    return '$played von $expected Klicks haben gespielt. War nichts zu hören, liegt es an der Lautstärke des Geräts.';
  }

  @override
  String soundTestSomePlayed(int played, int expected) {
    return 'Nur $played von $expected Klicks haben gespielt - der Ton bricht auf diesem Gerät ab.';
  }

  @override
  String soundTestUnavailable(String error) {
    return 'Der Ton ist auf diesem Gerät nicht verfügbar:\n$error';
  }

  @override
  String get recommendShaky => 'Da war es zuletzt wackelig';

  @override
  String get recommendFresh => 'Das hast du noch nie geübt';

  @override
  String get recommendStale => 'Lange nicht mehr geübt';

  @override
  String get pauseDayDoneTitle => 'Für heute reicht es!';

  @override
  String pauseDayDoneText(int minutes) {
    return 'Du hast heute $minutes Minuten gerechnet. Morgen geht es weiter.';
  }

  @override
  String get pauseBreakTitle => 'Pause!';

  @override
  String pauseBreakText(int minutes, String clock, String left) {
    return 'Du hast $minutes Minuten am Stück geübt. Weiter geht es um $clock - $left.';
  }

  @override
  String pauseClock(String time) {
    return '$time Uhr';
  }

  @override
  String get runHintTooShort =>
      'Zählt nicht: keine Sterne, keine Blitze, keine Bestenliste.';

  @override
  String runHintUsedUpToday(int count) {
    return 'Heute schon $count× gewertet - üben geht weiter, zählen nicht mehr.';
  }

  @override
  String runHintRemaining(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Noch $minutes Minuten, dann ist Pause.',
      one: 'Noch eine Minute, dann ist Pause.',
      zero: 'Gleich ist Pause.',
    );
    return '$_temp0';
  }

  @override
  String get assignmentGoalDone => 'Aufgabe geschafft!';

  @override
  String assignmentGoalCounts(int done, int runs) {
    return 'Zählt für deine Aufgabe: $done von $runs';
  }

  @override
  String get assignmentGoalNotEnough =>
      'Das reicht für deine Aufgabe noch nicht:';

  @override
  String get assignmentTileDone => 'geschafft';

  @override
  String get todayHeading => 'Heute geübt';

  @override
  String get todayNothingYet => 'noch nichts';

  @override
  String todayNothingOfLimit(int limit) {
    return 'noch nichts von $limit min';
  }

  @override
  String todayTimeOfLimit(String time, int limit) {
    return '$time von $limit min';
  }

  @override
  String get progressChartEmpty =>
      'Ab dem zweiten Durchgang siehst du hier deine Lernkurve.';

  @override
  String starRowEarnedOf(int earned, int possible) {
    return '$earned von $possible';
  }

  @override
  String get adminSessionClosed => 'Elternbereich geschlossen.';

  @override
  String get taskClock24Question => 'Wie spät ist es? Sage es mit 24 Stunden.';

  @override
  String get backupShareSubject => 'Mathe-Trainer Sicherung';

  @override
  String backupExportFailed(String error) {
    return 'Sicherung fehlgeschlagen: $error';
  }

  @override
  String get backupImportConfirmTitle => 'Sicherung einspielen?';

  @override
  String get backupImportConfirmText =>
      'Alle Profile und Ergebnisse auf diesem Gerät werden durch die Sicherung ersetzt. Was jetzt hier steht, ist danach weg.';

  @override
  String get backupReplace => 'Ersetzen';

  @override
  String get backupFileTypeLabel => 'Sicherung';

  @override
  String backupImported(int users, int sessions) {
    return '$users Profile und $sessions Durchgänge eingespielt.';
  }

  @override
  String backupImportFailed(String error) {
    return 'Einspielen fehlgeschlagen: $error';
  }

  @override
  String get backupHeading => 'Daten';

  @override
  String get backupIntro =>
      'Alle Profile, Ergebnisse und Einstellungen als Datei. Bewahre sie außerhalb des Tablets auf - ein zurückgesetztes Gerät nimmt sonst alles mit.';

  @override
  String get backupCreate => 'Sicherung erstellen';

  @override
  String get backupRestore => 'Sicherung einspielen';

  @override
  String get backupNever => 'Noch nie gesichert.';

  @override
  String backupLast(String when) {
    return 'Zuletzt gesichert: $when.';
  }

  @override
  String backupLastOverdue(String when) {
    return 'Zuletzt gesichert: $when. Das ist eine Weile her.';
  }

  @override
  String get pinTitleVerify => 'Elternbereich';

  @override
  String get pinTitleSetup => 'Elternbereich einrichten';

  @override
  String get pinHintEnter => 'PIN eingeben';

  @override
  String pinHintChoose(int length) {
    return 'Wähle eine PIN aus $length Ziffern';
  }

  @override
  String get pinHintRepeat => 'PIN wiederholen';

  @override
  String get pinWrong => 'Falsche PIN.';

  @override
  String get pinMismatch => 'Die beiden Eingaben waren verschieden.';

  @override
  String get startWhatDoesItMean => 'Was heißt das?';

  @override
  String startExample(String example) {
    return 'Zum Beispiel:  $example';
  }

  @override
  String startAssignmentGoal(int count) {
    return 'Für deine Aufgabe: $count Rechnungen';
  }

  @override
  String get startHowMany => 'Wie viele Aufgaben?';

  @override
  String startBoltsFrom(String time) {
    return 'ab $time pro Aufgabe';
  }

  @override
  String get startGo => 'Los geht\'s';

  @override
  String get startLeaderboard => 'Bestenliste';

  @override
  String get commonPerTask => 'pro Aufgabe';

  @override
  String get commonErrors => 'Fehler';

  @override
  String get commonTasks => 'Aufgaben';

  @override
  String leaderboardTitle(String lesson) {
    return 'Bestenliste · $lesson';
  }

  @override
  String leaderboardEmpty(int min) {
    return 'Noch keine Ergebnisse.\nMindestens $min Aufgaben zählen für die Bestenliste.';
  }

  @override
  String get leaderboardScoreExplanation =>
      'Gewertet wird die Zeit pro Aufgabe, plus 3 Sekunden für jeden Fehlversuch. Deshalb lohnt sich Raten nicht, und Durchgänge mit unterschiedlich vielen Aufgaben bleiben vergleichbar.';

  @override
  String statsTitle(String name) {
    return 'Statistik · $name';
  }

  @override
  String get statsEmpty => 'Noch keine abgeschlossenen Durchgänge.';

  @override
  String statsLearningCurve(String lesson) {
    return 'Lernkurve · $lesson';
  }

  @override
  String get statsLearningCurveSub =>
      'Sekunden pro Aufgabe, Durchgang für Durchgang';

  @override
  String get statsHardest => 'Diese Aufgaben dauern am längsten';

  @override
  String get statsHeadStars => 'Sterne';

  @override
  String get statsHeadBest => 'Bestzeit';

  @override
  String get statsHeadAverage => 'Ø Zeit';

  @override
  String get statsHeadRuns => 'Runden';

  @override
  String get statsTooFewData => 'Noch zu wenige Daten.';

  @override
  String get globalStatsTitle => 'Alle Ergebnisse';

  @override
  String get globalStatsTabOverview => 'Übersicht';

  @override
  String get globalStatsTabLeaderboards => 'Bestenlisten';

  @override
  String get globalStatsNoProfiles => 'Noch keine Profile.';

  @override
  String globalStatsActivityHeading(int days) {
    return 'Geübt in den letzten $days Tagen';
  }

  @override
  String get globalStatsActivitySub =>
      'Minuten pro Tag, je Kind in seiner Farbe';

  @override
  String globalStatsNoLeaderboards(int min) {
    return 'Noch keine Bestenlisten.\nEin Durchgang zählt ab $min Aufgaben.';
  }

  @override
  String get globalStatsNotPlayed => 'Noch nicht geübt.';

  @override
  String globalStatsRounds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Runden',
      one: 'Runde',
    );
    return '$_temp0';
  }

  @override
  String get globalStatsPractised => 'geübt';

  @override
  String globalStatsStreak(int days) {
    return '$days Tage in Folge';
  }

  @override
  String globalStatsLastPlayed(String when) {
    return 'zuletzt $when';
  }

  @override
  String get globalStatsNoActivity =>
      'In den letzten Wochen wurde noch nicht geübt.';

  @override
  String get profilesTitle => 'Wer rechnet?';

  @override
  String get profilesAllResults => 'Alle Ergebnisse';

  @override
  String get profilesDuel => 'Duell';

  @override
  String get profilesParents => 'Eltern';

  @override
  String get profilesNone =>
      'Noch kein Profil. Tippe auf „Neu\", um anzufangen.';

  @override
  String profilesLockedTitle(String name) {
    return '$name macht gerade Pause';
  }

  @override
  String get profilesLockedText =>
      'Dieses Profil ist vorübergehend gesperrt. Alle Sterne, Blitze und Bestzeiten bleiben erhalten - sie sind wieder da, sobald die Eltern es freigeben.';

  @override
  String get profilesLockedOk => 'Alles klar';

  @override
  String get profilesAllDone => 'alles geschafft';

  @override
  String profilesTodo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben',
      one: '1 Aufgabe',
    );
    return '$_temp0';
  }

  @override
  String get profilesEditLook => 'Bild und Farbe ändern';

  @override
  String get profilesNew => 'Neu';

  @override
  String get profileEditorNew => 'Neues Profil';

  @override
  String get profileEditorChangeName => 'Name ändern';

  @override
  String get profileEditorNameLabel => 'Name';

  @override
  String get profileEditorNext => 'Weiter';

  @override
  String get profileEditorLookTitle => 'Bild und Farbe';

  @override
  String get profileEditorPicture => 'Bild';

  @override
  String get profileEditorColor => 'Farbe';

  @override
  String get profileEditorSave => 'Speichern';

  @override
  String get duelTitle => 'Duell';

  @override
  String get duelNeedTwoProfiles =>
      'Für ein Duell braucht es mindestens zwei Profile.';

  @override
  String get duelWhoPlays => 'Wer tritt an?';

  @override
  String duelPlayerLocked(String avatar, String name) {
    return '$avatar  $name · gesperrt';
  }

  @override
  String duelPlayerOnBreak(String avatar, String name) {
    return '$avatar  $name · Pause';
  }

  @override
  String duelPlayer(String avatar, String name) {
    return '$avatar  $name';
  }

  @override
  String get duelWhichTasks => 'Welche Aufgaben?';

  @override
  String get duelPickTwo => 'Wähle mindestens zwei Kinder aus.';

  @override
  String duelLessonChip(String title, String example) {
    return '$title  ·  $example';
  }

  @override
  String get duelStart => 'Duell starten';

  @override
  String duelPosition(int position, int total) {
    return '$position von $total';
  }

  @override
  String duelYourTurn(String name) {
    return '$name ist dran';
  }

  @override
  String duelLessonAndGroup(String lesson, String group) {
    return '$lesson · $group';
  }

  @override
  String get duelReady => 'Bereit';

  @override
  String get duelAbort => 'Duell abbrechen';

  @override
  String duelResultTitle(String lesson) {
    return 'Duell · $lesson';
  }

  @override
  String get duelSameTasks => 'Alle hatten dieselben Aufgaben.';

  @override
  String get duelDone => 'Fertig';

  @override
  String get duelWin => 'Sieg!';

  @override
  String get commonBackToLessons => 'Zurück zu den Lektionen';

  @override
  String get resultDone => 'Geschafft!';

  @override
  String resultDoneName(String name) {
    return 'Geschafft, $name!';
  }

  @override
  String resultNextBolt(int n, String time) {
    return '$n. Blitz ab $time pro Aufgabe';
  }

  @override
  String get resultForThisLesson => 'für diese Lektion';

  @override
  String get resultInTotal => 'insgesamt';

  @override
  String get resultMetricTasks => 'Aufgaben';

  @override
  String get resultMetricTotalTime => 'Gesamtzeit';

  @override
  String get resultMetricPerTask => 'Pro Aufgabe';

  @override
  String get resultMetricErrors => 'Fehler';

  @override
  String resultPenalty(String penalty, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fehlversuche',
      one: '1 Fehlversuch',
    );
    return 'Darin sind $penalty Zeitstrafe für $_temp0 enthalten - 3 Sekunden für jeden.';
  }

  @override
  String resultStreak(int days) {
    return '$days Tage in Folge geübt!';
  }

  @override
  String get resultAgain => 'Nochmal';

  @override
  String get resultLeaderboard => 'Bestenliste';

  @override
  String get resultOtherLesson => 'Andere Lektion';

  @override
  String get resultFirstRun =>
      'Das war dein erster Durchgang hier -\ndie Zeit ist ab jetzt dein Rekord.';

  @override
  String get resultSameSpeed => 'Genau so schnell wie beim letzten Mal.';

  @override
  String resultFaster(String delta) {
    return '$delta schneller pro Aufgabe als beim letzten Mal!';
  }

  @override
  String resultSlower(String delta) {
    return '$delta langsamer pro Aufgabe als beim letzten Mal.';
  }

  @override
  String get practiceAbortTitle => 'Übung beenden?';

  @override
  String get practiceAbortText =>
      'Dieser Durchgang zählt dann nicht für die Bestenliste.';

  @override
  String get practiceKeepGoing => 'Weiter rechnen';

  @override
  String get practiceAbortConfirm => 'Beenden';

  @override
  String get practiceAbortTooltip => 'Übung beenden';

  @override
  String get practicePause => 'Pause';

  @override
  String get practicePauseNote => 'Die Zeit läuft nicht weiter.';

  @override
  String get practiceResume => 'Weiter';

  @override
  String get lessonsFilterTooltip => 'Fertiges ausblenden';

  @override
  String get lessonsHideDoneAssignments => 'Erledigte Aufgaben ausblenden';

  @override
  String get lessonsStatsLabel => 'Statistik';

  @override
  String get lessonsSettingsTooltip => 'Einstellungen';

  @override
  String get lessonsSwitchLabel => 'Wechseln';

  @override
  String get lessonsNoGroup =>
      'Für dieses Profil ist noch kein Bereich freigeschaltet.\nDas lässt sich im Elternbereich ändern.';

  @override
  String get lessonsNothingLeftTitle => 'Alles geschafft!';

  @override
  String get lessonsNothingLeftText =>
      'Was du kannst, ist gerade ausgeblendet. Über den Filter oben kommt der ganze Katalog zurück.';

  @override
  String get lessonsRecommendGo => 'Los';

  @override
  String lessonsRecommendTitle(String lesson, String group) {
    return '$lesson · $group';
  }

  @override
  String get lessonsAssignmentsHeading => 'Deine Aufgaben';

  @override
  String get lessonsAssignmentsAllDone =>
      'Alles erledigt! Die fertigen Aufgaben sind ausgeblendet.';

  @override
  String get lessonsNotPractised => 'noch nicht geübt';

  @override
  String lessonsPractisedTimes(int count) {
    return '$count× geübt';
  }

  @override
  String get adminTitle => 'Elternbereich';

  @override
  String get adminTabHistory => 'Übungsverlauf';

  @override
  String get adminTabManagement => 'Verwaltung';

  @override
  String get adminTabAssignments => 'Aufgaben';

  @override
  String get adminTabSettings => 'Einstellungen';

  @override
  String get adminFilterAll => 'Alle';

  @override
  String get adminShowDeleted => 'Gelöschte';

  @override
  String adminHistoryTruncated(int limit) {
    return 'Es werden die letzten $limit Durchgänge angezeigt. Ein kürzerer Zeitraum zeigt den Rest.';
  }

  @override
  String adminCleanupAll(int count) {
    return 'Abgebrochene Durchgänge aufräumen ($count)';
  }

  @override
  String adminCleanupOne(String name, int count) {
    return 'Abgebrochene von $name aufräumen ($count)';
  }

  @override
  String get adminHistoryEmpty => 'Noch keine Durchgänge.';

  @override
  String get adminDeleteRunTitle => 'Diesen Durchgang löschen?';

  @override
  String adminDeleteRunText(String user, String lesson, String when) {
    return '$user · $lesson · $when';
  }

  @override
  String get adminRunDeleted => 'Durchgang gelöscht.';

  @override
  String get adminUndo => 'Rückgängig';

  @override
  String get adminThisChild => 'diesem Kind';

  @override
  String get adminWhoAll => 'von allen Kindern';

  @override
  String adminWhoOne(String name) {
    return 'von $name';
  }

  @override
  String adminCleanupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abgebrochene Durchgänge aufräumen?',
      one: 'Einen abgebrochenen Durchgang aufräumen?',
    );
    return '$_temp0';
  }

  @override
  String adminCleanupText(String whose, String range) {
    return 'Es verschwinden die abgebrochenen Durchgänge $whose $range. Sie zählten nie für Sterne, Blitze oder eine Bestenliste - die geübte Zeit bleibt gezählt.';
  }

  @override
  String get adminCleanupConfirm => 'Aufräumen';

  @override
  String adminCleanedUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abgebrochene Durchgänge aufgeräumt.',
      one: 'Ein abgebrochener Durchgang aufgeräumt.',
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
      other: '$count Aufgaben',
      one: '1 Aufgabe',
    );
    return 'abgebrochen nach $_temp0';
  }

  @override
  String get adminRestore => 'Wiederherstellen';

  @override
  String get adminDeleteRun => 'Durchgang löschen';

  @override
  String get adminProfiles => 'Profile';

  @override
  String get adminNewProfile => 'Neues Profil';

  @override
  String get adminProfilesNote =>
      'Ein Tipp auf ein Kind öffnet alles, was zu ihm gehört: Bereiche, Zeiten, Sperre, Umbenennen und Löschen. Bild und Farbe darf jedes Kind selbst auf dem Startbildschirm ändern.';

  @override
  String get adminPinHeading => 'PIN';

  @override
  String get adminPinNote =>
      'Schützt diesen Bereich. Vergessen? Dann hilft nur, die App-Daten in den Android-Einstellungen zu löschen - damit sind aber auch alle Ergebnisse weg.';

  @override
  String get adminChangePin => 'PIN ändern';

  @override
  String get adminGroupsNone => 'Kein Bereich freigeschaltet';

  @override
  String get adminGroupsAll => 'Alle Bereiche';

  @override
  String adminGroupsSome(int n, int total) {
    return '$n von $total Bereichen';
  }

  @override
  String get adminLocked => 'Gesperrt';

  @override
  String get adminNoReview => 'ohne Wiederholung';

  @override
  String get profileSettingsDiscardTitle => 'Änderungen verwerfen?';

  @override
  String profileSettingsDiscardText(String name) {
    return 'Die Einstellungen für $name wurden geändert, aber noch nicht gespeichert.';
  }

  @override
  String get profileSettingsDiscard => 'Verwerfen';

  @override
  String get profileSettingsSave => 'Speichern';

  @override
  String get profileSettingsSectionPractice => 'Üben';

  @override
  String get profileSettingsGroups => 'Bereiche';

  @override
  String get profileSettingsGroupsNote =>
      'Abgeschaltete Bereiche erscheinen nicht mehr auf dem Übungsbildschirm. Bereits erzielte Ergebnisse bleiben erhalten.';

  @override
  String get profileSettingsNoGroup =>
      'Ohne einen einzigen Bereich kann das Kind nicht üben.';

  @override
  String get profileSettingsHideDoneHeading => 'Fertige Lektionen ausblenden';

  @override
  String get profileSettingsHideDoneNote =>
      'Kürzt den Katalog um das, was schon sitzt. Das Kind kann es auf dem Übungsbildschirm selbst umstellen - hier steht es, damit man es einmal einrichten kann. Die strengere Stufe lässt die Ersten Schritte stehen: dort wird nicht auf Zeit gerechnet, also gibt es keine Blitze zu holen.';

  @override
  String get profileSettingsHideDoneAssignments =>
      'Erledigte Aufgaben ausblenden';

  @override
  String get profileSettingsHideDoneAssignmentsNote =>
      'Fertige Karten verschwinden schon vor Ende des Tages bzw. der Woche. Sonst bleiben sie abgehakt stehen.';

  @override
  String get profileSettingsTaskCount => 'Aufgaben pro Durchgang';

  @override
  String get profileSettingsReview => 'Schwere Aufgaben wiederholen';

  @override
  String get profileSettingsReviewNote =>
      'Ein Viertel jedes Durchgangs besteht aus dem, was zuletzt lange gedauert hat oder falsch war.';

  @override
  String get profileSettingsSectionTime => 'Zeit und Wertung';

  @override
  String get profileSettingsStretch => 'Übungszeit am Stück';

  @override
  String get profileSettingsStretchNote =>
      'Nach dieser Zeit gibt es eine Pause. Ein laufender Durchgang wird nie abgebrochen - erst der nächste Start ist gesperrt. Die Zeit zählt weiter, solange die Pause nicht vollständig eingehalten wurde.';

  @override
  String get profileSettingsBreakLength => 'Wie lange dauert die Pause?';

  @override
  String get profileSettingsDaily => 'Und pro Tag insgesamt';

  @override
  String get profileSettingsDailyNote =>
      'Zählt alle Durchgänge des Tages zusammen, Pausen hin oder her. Ist die Zeit aufgebraucht, geht es erst am nächsten Tag weiter.';

  @override
  String get profileSettingsScoredRuns =>
      'Gewertete Durchgänge je Übung und Tag';

  @override
  String get profileSettingsScoredRunsNote =>
      'Danach darf dieselbe Übung weiter gemacht werden, sie bringt nur keine Bestzeit, keine Sterne und keine Blitze mehr. Geübte Zeit und Verlauf zählen weiter mit.';

  @override
  String get profileSettingsSectionTidy => 'Aufräumen';

  @override
  String get profileSettingsTidyNote =>
      'Diese Knöpfe wirken sofort - sie warten nicht auf \"Speichern\".';

  @override
  String get profileSettingsRename => 'Umbenennen';

  @override
  String get profileSettingsGiveBackStars => 'Sterne zurückgeben …';

  @override
  String get profileSettingsResetResults => 'Ergebnisse löschen';

  @override
  String get profileSettingsDeleteProfile => 'Profil löschen';

  @override
  String profileSettingsResetTitle(String name) {
    return 'Ergebnisse von $name löschen?';
  }

  @override
  String get profileSettingsResetText =>
      'Bestzeiten, Lernkurve und Verlauf gehen verloren. Das Profil selbst bleibt bestehen.';

  @override
  String profileSettingsDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get profileSettingsDeleteText =>
      'Profil und alle Ergebnisse werden entfernt.';

  @override
  String profileSettingsGroupSummary(int count, String example) {
    return '$count Lektionen · z. B. $example';
  }

  @override
  String get profileSettingsLockTitle => 'Profil vorübergehend sperren';

  @override
  String get profileSettingsLockNote =>
      'Das Profil lässt sich dann nicht öffnen und nicht zum Duell einladen. Nichts geht verloren: Sterne, Blitze und Bestzeiten sind nach dem Freigeben unverändert da.';

  @override
  String get globalSettingsClock => 'Uhr während der Übung zeigen';

  @override
  String get globalSettingsClockNote =>
      'Die Zeit wird immer gemessen. Sichtbar macht sie manche Kinder aber nervös - deshalb ist sie standardmäßig aus.';

  @override
  String get globalSettingsHaptics => 'Tasten vibrieren lassen';

  @override
  String get globalSettingsHapticsNote =>
      'Kurzes Feedback bei jedem Tastendruck.';

  @override
  String get globalSettingsSounds => 'Töne abspielen';

  @override
  String get globalSettingsSoundsNote =>
      'Ein kurzer Klang bei richtig, ein anderer bei falsch und ein leiser Klick unter jeder Taste. Auf einem flach liegenden Tablet spürt man die Vibration kaum.';

  @override
  String get globalSettingsTaskCount => 'Aufgaben pro Durchgang für alle';

  @override
  String get globalSettingsTaskCountNote =>
      'Für ein einzelnes Kind steht die Vorgabe unter „Verwaltung\" bei seinem Profil - und das Kind selbst kann sie in seinen eigenen Einstellungen ändern.';

  @override
  String get globalSettingsLimits => 'Übungszeit für alle';

  @override
  String get globalSettingsLimitsNote =>
      'Gilt für jedes Kind, das keine eigene Vorgabe hat. Ein laufender Durchgang wird nie abgebrochen - erst der nächste Start ist gesperrt.';

  @override
  String get globalSettingsStretch => 'Am Stück, dann Pause';

  @override
  String get globalSettingsBreakLength => 'Wie lange dauert die Pause?';

  @override
  String get globalSettingsDaily => 'Und pro Tag insgesamt';

  @override
  String get globalSettingsScoredRuns =>
      'Gewertete Durchgänge je Übung und Tag';

  @override
  String get globalSettingsScoredRunsNote =>
      'Danach darf dieselbe Übung weiter gemacht werden, sie bringt nur keine Bestzeit, keine Sterne und keine Blitze mehr. Das nimmt den Anreiz, die leichteste Übung so lange zu wiederholen, bis die Zeit stimmt. Geübte Zeit und Verlauf zählen weiter mit.';

  @override
  String resetStarsTitle(String group) {
    return 'Sterne in „$group\" zurücksetzen?';
  }

  @override
  String resetStarsText(String name) {
    return '$name kann sie danach neu verdienen. Bestzeiten, Blitze, Lernkurve und Bestenlisten bleiben unverändert - es geht nur um die Sterne dieser Gruppe.';
  }

  @override
  String get resetStarsConfirm => 'Zurücksetzen';

  @override
  String resetStarsHeading(String name) {
    return 'Sterne von $name';
  }

  @override
  String get resetStarsNote =>
      'Zurückgesetzt werden nur die Sterne. Die Zeiten bleiben - Bestzeiten, Blitze, Lernkurve und Bestenlisten sind danach genau wie vorher.';

  @override
  String get resetStarsDone => 'Fertig';

  @override
  String resetStarsGroupLine(int earned, int possible) {
    return '$earned von $possible Sternen';
  }

  @override
  String get assignmentsAll => 'Alle';

  @override
  String get assignmentsNew => 'Neue Aufgabe';

  @override
  String get assignmentsHideFinished => 'Erledigte ausblenden';

  @override
  String assignmentsHiddenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgeblendet',
      one: '1 ausgeblendet',
    );
    return '$_temp0';
  }

  @override
  String get assignmentsEmpty => 'Noch keine Aufgaben.';

  @override
  String get assignmentsNoneOpen =>
      'Keine offenen Aufgaben. Erledigte sind ausgeblendet.';

  @override
  String get assignmentsPeriodDays => 'Tagen';

  @override
  String get assignmentsPeriodWeeks => 'Wochen';

  @override
  String get assignmentsDaily => 'täglich';

  @override
  String get assignmentsWeekly => 'wöchentlich';

  @override
  String get assignmentsCarriesOver => ' · zieht nach';

  @override
  String assignmentsLessonCount(int count) {
    return '$count Übungen';
  }

  @override
  String get assignmentsEdit => 'Ändern';

  @override
  String get assignmentsEnd => 'Beenden';

  @override
  String get assignmentsRepeat => 'Erneut stellen';

  @override
  String get assignmentsDelete => 'Aufgabe löschen';

  @override
  String assignmentsRunsOfTasks(int runs, int tasks) {
    return '$runs× $tasks Rechnungen';
  }

  @override
  String assignmentsMinStars(int count) {
    return 'mind. $count ★';
  }

  @override
  String assignmentsMinBolts(int count) {
    return 'mind. $count ⚡';
  }

  @override
  String get assignmentsNoClosedPeriod => 'Noch kein abgeschlossener Zeitraum';

  @override
  String assignmentsMetOf(int met, int total, String period) {
    return 'Geschafft an $met von $total $period';
  }

  @override
  String assignmentsBefore(int met, int total, String period) {
    return '· davor $met von $total $period';
  }

  @override
  String get assignmentsVerdictMet => 'Geschafft';

  @override
  String get assignmentsVerdictPending => 'Steht noch aus';

  @override
  String get assignmentsVerdictLate => 'Verpasst, später nachgeholt';

  @override
  String get assignmentsVerdictMissed => 'Verpasst';

  @override
  String get editorTitleEdit => 'Aufgabe ändern';

  @override
  String get editorTitleAgain => 'Aufgabe erneut stellen';

  @override
  String get editorTitleNew => 'Neue Aufgabe';

  @override
  String get editorChild => 'Kind';

  @override
  String get editorUnknownChild => 'Unbekanntes Kind';

  @override
  String get editorLessons => 'Übungen';

  @override
  String get editorLessonsNote =>
      'Mehrere sind möglich. Jede davon muss erfüllt werden, damit die Aufgabe erledigt ist.';

  @override
  String get editorNoLesson =>
      'Ohne eine einzige Übung gibt es nichts aufzugeben.';

  @override
  String get editorPeriod => 'Zeitraum';

  @override
  String get editorOneDay => 'ein Tag';

  @override
  String get editorOneWeek => 'eine Woche';

  @override
  String get editorRepetition => 'Wiederholung';

  @override
  String get editorEveryTime => 'jedes Mal';

  @override
  String get editorOnce => 'einmalig';

  @override
  String get editorDailyNote => 'Jeden Tag neu, fällig am Ende des Tages.';

  @override
  String get editorWeeklyNote => 'Jede Woche neu, fällig Sonntagabend.';

  @override
  String editorOnDay(String day) {
    return 'Am $day';
  }

  @override
  String editorInWeek(String day) {
    return 'In der Woche ab $day';
  }

  @override
  String get editorPickDay => 'Tag wählen …';

  @override
  String get editorCarryOver => 'Nachziehen, wenn nicht geschafft';

  @override
  String get editorCarryOverNote =>
      'Die Aufgabe bleibt danach stehen, bis sie erledigt ist. Der Tag selbst gilt trotzdem als verpasst - die Statistik sagt, wann geübt wurde, nicht was gemeint war.';

  @override
  String get editorRuns => 'Durchgänge';

  @override
  String get editorTasksPerRun => 'Rechnungen je Durchgang';

  @override
  String get editorMinStars => 'Mindeststerne';

  @override
  String get editorMinBolts => 'Mindestblitze';

  @override
  String get editorNoRequirement => 'keine Vorgabe';

  @override
  String get editorSave => 'Speichern';

  @override
  String get editorCreate => 'Anlegen';

  @override
  String editorDayLabel(String weekday, int day, int month) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      '1': 'Mo',
      '2': 'Di',
      '3': 'Mi',
      '4': 'Do',
      '5': 'Fr',
      '6': 'Sa',
      '7': 'So',
      'other': '',
    });
    return '$_temp0, $day.$month.';
  }
}
