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
  String leaderboardScoreExplanation(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds Sekunden',
      one: '1 Sekunde',
    );
    return 'Gewertet wird die Zeit pro Aufgabe, plus $_temp0 für jeden Fehlversuch. Deshalb lohnt sich Raten nicht, und Durchgänge mit unterschiedlich vielen Aufgaben bleiben vergleichbar.';
  }

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
  String resultPenalty(String penalty, int count, int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Fehlversuche',
      one: '1 Fehlversuch',
    );
    String _temp1 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds Sekunden',
      one: '1 Sekunde',
    );
    return 'Darin sind $penalty Zeitstrafe für $_temp0 enthalten - $_temp1 für jeden.';
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
  String get assignmentsDaily => 'täglich';

  @override
  String get assignmentsWeekly => 'wöchentlich';

  @override
  String get assignmentsCarriesOver => 'zieht nach';

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
    String _temp0 = intl.Intl.selectLogic(period, {
      'daily': 'Tagen',
      'weekly': 'Wochen',
      'other': 'Wochen',
    });
    return 'Geschafft an $met von $total $_temp0';
  }

  @override
  String assignmentsBefore(int met, int total, String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'daily': 'Tagen',
      'weekly': 'Wochen',
      'other': 'Wochen',
    });
    return 'davor $met von $total $_temp0';
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
  String get groupFirstSteps => 'Erste Schritte';

  @override
  String get groupUpTo10 => 'Bis 10';

  @override
  String get groupUpTo20 => 'Bis 20';

  @override
  String get groupUpTo100 => 'Bis 100';

  @override
  String get groupUpTo1000 => 'Bis 1000';

  @override
  String get groupWithThousands => 'Mit Tausendern';

  @override
  String get groupTimesTables => 'Einmaleins';

  @override
  String get groupReverseTimesTables => 'Einmaleins rückwärts';

  @override
  String get groupTimesAndDivision => 'Mal und Geteilt';

  @override
  String get groupEveryday => 'Uhrzeit und Geld';

  @override
  String get lessonAddPlainTitle => 'Plus ohne Zehnerübergang';

  @override
  String get lessonAddPlainBigTitle => 'Plus ohne Übergang';

  @override
  String get lessonAddPlainDesc =>
      'Die Einer bleiben zusammen unter 10 - es muss nichts übertragen werden.';

  @override
  String get lessonAddPlainBigDesc =>
      'Keine Stelle läuft über - weder die Einer noch die Zehner.';

  @override
  String get lessonAddCarryTitle => 'Plus mit Zehnerübergang';

  @override
  String get lessonAddCarryBigTitle => 'Plus mit Übergang';

  @override
  String get lessonAddCarryDesc =>
      'Die Einer ergeben zusammen 10 oder mehr - ein Zehner wandert weiter.';

  @override
  String get lessonAddCarryBigDesc =>
      'Einer oder Zehner laufen über - es muss übertragen werden.';

  @override
  String get lessonSubPlainTitle => 'Minus ohne Zehnerübergang';

  @override
  String get lessonSubPlainBigTitle => 'Minus ohne Übergang';

  @override
  String get lessonSubPlainDesc =>
      'Jede Ziffer oben ist groß genug - es muss kein Zehner aufgelöst werden.';

  @override
  String get lessonSubPlainBigDesc =>
      'Jede Ziffer oben ist groß genug - es muss nichts aufgelöst werden.';

  @override
  String get lessonSubBorrowTitle => 'Minus mit Zehnerübergang';

  @override
  String get lessonSubBorrowBigTitle => 'Minus mit Übergang';

  @override
  String get lessonSubBorrowDesc =>
      'Die Einer oben reichen nicht - ein Zehner muss aufgelöst werden.';

  @override
  String get lessonSubBorrowBigDesc =>
      'Eine Stelle oben reicht nicht - Zehner oder Hunderter müssen aufgelöst werden.';

  @override
  String get lessonPlusGapTitle => 'Plus mit Platzhalter';

  @override
  String get lessonMinusGapTitle => 'Minus mit Platzhalter';

  @override
  String get lessonGapDesc =>
      'Gesucht ist die Zahl, die fehlt, damit die Rechnung stimmt.';

  @override
  String get lessonMixedTitle => 'Plus und Minus gemischt';

  @override
  String get lessonMixedDesc =>
      'Plus und Minus wechseln sich zufällig ab, mit und ohne Übergang.';

  @override
  String lessonTimesTableTitle(int n) {
    return '${n}er-Reihe';
  }

  @override
  String lessonTimesTableDesc(int n) {
    return 'Alle Aufgaben der ${n}er-Reihe, in beide Richtungen: $n · 4 genauso wie 4 · $n.';
  }

  @override
  String lessonReverseTableTitle(int n) {
    return '${n}er-Reihe rückwärts';
  }

  @override
  String lessonReverseTableDesc(int n, int product) {
    return 'Geteilt durch $n. Jede Aufgabe ist die Umkehrung einer Aufgabe der ${n}er-Reihe: aus $n · 4 = $product wird $product : $n = 4.';
  }

  @override
  String get lessonPartnersOfTenTitle => 'Verliebte Zahlen';

  @override
  String get lessonPartnersOfTenDesc =>
      'Zwei Zahlen sind verliebt, wenn sie zusammen genau 10 ergeben: 1 und 9, 2 und 8, 3 und 7. Gefragt wird in beide Richtungen - von 3 nach 7 genauso wie von 7 nach 3.';

  @override
  String get lessonAdd10Title => 'Plus bis 10';

  @override
  String get lessonAdd10Desc =>
      'Zusammenzählen, ohne über die 10 hinauszugehen.';

  @override
  String get lessonSub10Title => 'Minus bis 10';

  @override
  String get lessonSub10Desc => 'Wegnehmen im Zahlenraum bis 10.';

  @override
  String get lessonMix10Desc => 'Plus und Minus wechseln sich zufällig ab.';

  @override
  String get lessonTimesAllTitle => 'Alle Reihen gemischt';

  @override
  String get lessonTimesAllDesc =>
      'Das ganze kleine Einmaleins, bunt durcheinander.';

  @override
  String get lessonDivPlainTitle => 'Alle Reihen rückwärts';

  @override
  String get lessonDivPlainDesc =>
      'Geteilt durch alles, bunt durcheinander. Jede Aufgabe geht glatt auf - sie ist die Umkehrung einer Einmaleins-Aufgabe.';

  @override
  String get lessonDivRemainderTitle => 'Geteilt mit Rest';

  @override
  String get lessonDivRemainderDesc =>
      'Es bleibt immer etwas übrig. Erst das Ergebnis eingeben, dann den Rest.';

  @override
  String get lessonTimesGapTitle => 'Mal mit Platzhalter';

  @override
  String get lessonTimesGapDesc =>
      'Mit welcher Zahl muss man malnehmen, damit es stimmt?';

  @override
  String get lessonDivGapTitle => 'Geteilt mit Platzhalter';

  @override
  String get lessonDivGapDesc =>
      'Durch welche Zahl muss man teilen, damit es stimmt?';

  @override
  String get lessonMulTensTitle => 'Mal mit Zehnerzahlen';

  @override
  String get lessonMulTensDesc =>
      'Das Einmaleins mit einer Null dahinter: 3 · 4 = 12, also 30 · 4 = 120.';

  @override
  String get lessonMulTwoDigitTitle => 'Mal über das Einmaleins hinaus';

  @override
  String get lessonMulTwoDigitDesc =>
      'Eine zweistellige Zahl malnehmen, zum Beispiel 14 · 6.';

  @override
  String get lessonDivTwoDigitTitle => 'Geteilt über das Einmaleins hinaus';

  @override
  String get lessonDivTwoDigitDesc =>
      'Das Ergebnis ist größer als zehn, zum Beispiel 96 : 6.';

  @override
  String get lessonMulDivMixedTitle => 'Mal und Geteilt gemischt';

  @override
  String get lessonMulDivMixedDesc =>
      'Malnehmen und Teilen wechseln sich zufällig ab.';

  @override
  String get lessonPunktVorStrichTitle => 'Punkt vor Strich';

  @override
  String get lessonPunktVorStrichDesc =>
      'Mal und Geteilt kommen vor Plus und Minus - auch wenn sie hinten stehen: bei 40 − 3 · 6 wird erst 3 · 6 gerechnet.';

  @override
  String get lessonCountPicturesTitle => 'Wie viele? (Reihe)';

  @override
  String get lessonCountPicturesDesc =>
      'Bilder zählen, eins bis fünf, ordentlich aufgereiht.';

  @override
  String get lessonCountPicturesCloudTitle => 'Wie viele? (Wolke)';

  @override
  String get lessonCountPicturesCloudDesc =>
      'Dieselben Bilder, aber durcheinander - man muss sich merken, was schon gezählt ist.';

  @override
  String get lessonCountDiceTitle => 'Wie viele Punkte?';

  @override
  String get lessonCountDiceDesc =>
      'Ein Würfel. Irgendwann sieht man die Zahl, ohne zu zählen.';

  @override
  String get lessonCompareMoreTitle => 'Wo sind mehr? (Reihe)';

  @override
  String get lessonCompareMoreDesc =>
      'Zwei Häufchen vergleichen und die größere Anzahl eingeben.';

  @override
  String get lessonCompareMoreCloudTitle => 'Wo sind mehr? (Wolke)';

  @override
  String get lessonCompareMoreCloudDesc =>
      'Dasselbe, aber die Bilder liegen durcheinander.';

  @override
  String get lessonCountNextTitle => 'Welche Zahl kommt danach?';

  @override
  String get lessonCountNextDesc => 'Die Zahlenreihe vorwärts und rückwärts.';

  @override
  String get lessonBeesAddTitle => 'Bienchen (Reihe)';

  @override
  String get lessonBeesAddDesc =>
      'Zwei Grüppchen Bienen zusammenzählen, zusammen nie mehr als zehn.';

  @override
  String get lessonBeesAddCloudTitle => 'Bienchen (Wolke)';

  @override
  String get lessonBeesAddCloudDesc =>
      'Dieselbe Aufgabe, aber die Bienen schwirren durcheinander.';

  @override
  String get lessonDiceAddTitle => 'Zwei Würfel zusammenzählen';

  @override
  String get lessonDiceAddDesc =>
      'Beide Würfel zeigen bis zu fünf Punkte - wie viele sind es zusammen?';

  @override
  String get lessonAddToSixTitle => 'Plus bis 6';

  @override
  String get lessonAddToSixDesc => 'Zusammenzählen, nie über die Sechs hinaus.';

  @override
  String get lessonSubToSixTitle => 'Minus bis 6';

  @override
  String get lessonSubToSixDesc => 'Wegnehmen im Zahlenraum bis sechs.';

  @override
  String get lessonCalcToSixTitle => 'Plus und Minus bis 6';

  @override
  String get lessonCalcToSixDesc =>
      'Beides gemischt, nie über die Sechs hinaus.';

  @override
  String get lessonClockHalfTitle => 'Volle und halbe Stunden';

  @override
  String get lessonClockHalfDesc =>
      'Wie spät ist es? Der große Zeiger steht auf der 12 oder auf der 6.';

  @override
  String get lessonClockQuarterTitle => 'Viertelstunden';

  @override
  String get lessonClockQuarterDesc =>
      'Viertel nach, halb, Viertel vor - der große Zeiger steht auf 12, 3, 6 oder 9.';

  @override
  String get lessonClockFiveTitle => 'Uhrzeit auf fünf Minuten';

  @override
  String get lessonClockFiveDesc =>
      'Der große Zeiger steht auf einer der zwölf Zahlen.';

  @override
  String get lessonClock24Title => 'Uhrzeit mit 24 Stunden';

  @override
  String get lessonClock24Desc =>
      'Nachmittags zählt man weiter: aus 3 Uhr wird 15 Uhr. Unter der Uhr steht, welche Tageszeit es ist.';

  @override
  String get lessonClockWordsTitle => 'Uhrzeit sagen';

  @override
  String get lessonClockWordsDesc =>
      'Wie sagt man die Uhrzeit? Erst die Sprechweise antippen, dann die Stunde, die dabei genannt wird - bei \"halb 3\" ist das die 3.';

  @override
  String get lessonMoneyAddTitle => 'Geld zusammenzählen';

  @override
  String get lessonMoneyAddDesc =>
      'Zwei Beträge addieren. Erst die Euro eingeben, dann die Cent.';

  @override
  String get lessonMoneySubTitle => 'Geld abziehen';

  @override
  String get lessonMoneySubDesc => 'Was bleibt übrig, oder was gibt es zurück?';

  @override
  String get lessonMoneyComposeTitle => 'Betrag zusammenlegen';

  @override
  String get lessonMoneyComposeDesc =>
      'Lege den Betrag aus Münzen und Scheinen. Es gibt viele richtige Wege - der Betrag muss am Ende genau stimmen.';

  @override
  String get lessonMoneyChangeTitle => 'Was bekomme ich zurück?';

  @override
  String get lessonMoneyChangeDesc =>
      'Etwas kostet einen krummen Betrag, bezahlt wird mit einem glatten Schein oder Stück. Gesucht ist das Rückgeld.';

  @override
  String get lessonPlaceValue100Title => 'Einer und Zehner';

  @override
  String get lessonPlaceValue100Desc =>
      'Wie viele Einer und Zehner sind es? Welche Zahl ist das zusammen? Es können auch mehr als neun Einer sein.';

  @override
  String get lessonPlaceValue1000Title => 'Einer, Zehner, Hunderter';

  @override
  String get lessonPlaceValue1000Desc =>
      'Wie viele Einer, Zehner und Hunderter sind es? Welche Zahl ist das zusammen? Es können auch mehr als neun von einer Sorte sein.';

  @override
  String get lessonRoundThousandsTitle => 'Glatte Tausender';

  @override
  String get lessonRoundThousandsDesc =>
      '3000 + 4000, 8000 − 5000: rechne mit ganzen Tausendern. Wer 3 + 4 kann, kann das auch.';

  @override
  String get lessonRoundHundredsTitle => 'Glatte Hunderter';

  @override
  String get lessonRoundHundredsDesc =>
      '2300 + 400, 5600 − 200: rechne mit ganzen Hundertern. Hier geht es auch über den Tausender.';

  @override
  String get lessonRoundGapTitle => 'Glatte Zahlen mit Platzhalter';

  @override
  String get lessonRoundGapDesc =>
      '3000 + ? = 7000. Was fehlt bis zur Zahl? Rückwärts gedacht.';

  @override
  String get lessonPlaceValue10000Title =>
      'Einer, Zehner, Hunderter, Tausender';

  @override
  String get lessonPlaceValue10000Desc =>
      'Wie viele Einer, Zehner, Hunderter und Tausender sind es? Welche Zahl ist das zusammen? Es können auch mehr als neun von einer Sorte sein.';

  @override
  String get lessonAddSub10000PlainTitle => 'Plus und Minus ohne Übergang';

  @override
  String get lessonAddSub10000PlainDesc =>
      '4200 + 350, 6870 − 40: vierstellig rechnen, aber ohne Übergang. Jede Stelle für sich.';

  @override
  String taskQuestionPartner(int a) {
    return 'Welche Zahl ist mit $a verliebt?';
  }

  @override
  String get taskQuestionClock => 'Wie spät ist es?';

  @override
  String get taskQuestionClockPhrase => 'Wie sagt man das?';

  @override
  String taskQuestionMoneyCompose(String amount) {
    return 'Lege $amount - tippe die Münzen und Scheine an.';
  }

  @override
  String taskQuestionChange(String price, String paid) {
    return 'Es kostet $price. Du gibst $paid. Wie viel bekommst du zurück?';
  }

  @override
  String get taskQuestionQuantity => 'Wie viele?';

  @override
  String get taskQuestionDiceOne => 'Wie viele Punkte?';

  @override
  String get taskQuestionDiceTwo => 'Wie viele Punkte sind es zusammen?';

  @override
  String get taskQuestionCompare => 'Wo sind mehr? Tippe die größere Anzahl.';

  @override
  String get taskQuestionSequence => 'Welche Zahl kommt danach?';

  @override
  String get taskQuestionQuantityAdd => 'Wie viele sind es zusammen?';

  @override
  String get taskQuestionPlaceValue => 'Welche Zahl ist das?';

  @override
  String get taskLabelRemainder => 'Rest';

  @override
  String get taskLabelEuro => '€';

  @override
  String get taskLabelClock => 'Uhr';

  @override
  String get taskUnitCents => 'ct';

  @override
  String placeOnes(int n) {
    return '$n Einer';
  }

  @override
  String placeTens(int n) {
    return '$n Zehner';
  }

  @override
  String placeHundreds(int n) {
    return '$n Hunderter';
  }

  @override
  String placeThousands(int n) {
    return '$n Tausender';
  }

  @override
  String taskRenderRemainder(String prefix, String answer, String second) {
    return '$prefix $answer Rest $second';
  }

  @override
  String taskRenderClock(int hour, String minute) {
    return '$hour:$minute Uhr';
  }

  @override
  String taskRenderChange(String price, String paid) {
    return '$price, bezahlt mit $paid';
  }

  @override
  String taskRenderDiceOne(int a) {
    return '$a Punkte';
  }

  @override
  String taskRenderDiceTwo(int a, int b) {
    return '$a + $b Punkte';
  }

  @override
  String get dayPartMorning => 'vormittags';

  @override
  String get dayPartNoon => 'mittags';

  @override
  String get dayPartAfternoon => 'nachmittags';

  @override
  String get dayPartEvening => 'abends';

  @override
  String get clockPhrase05 => '5 nach';

  @override
  String get clockPhrase10 => '10 nach';

  @override
  String get clockPhrase15 => 'viertel nach';

  @override
  String get clockPhrase20 => '20 nach';

  @override
  String get clockPhrase25 => '5 vor halb';

  @override
  String get clockPhrase30 => 'halb';

  @override
  String get clockPhrase35 => '5 nach halb';

  @override
  String get clockPhrase40 => '20 vor';

  @override
  String get clockPhrase45 => 'viertel vor';

  @override
  String get clockPhrase50 => '10 vor';

  @override
  String get clockPhrase55 => '5 vor';

  @override
  String clockSpokenTime(String phrase, int hour) {
    return '$phrase $hour';
  }

  @override
  String get filterAllTitle => 'Alle zeigen';

  @override
  String get filterAllText => 'Der ganze Katalog, nichts wird versteckt.';

  @override
  String get filterMasteredTitle => 'Mit 3 Sternen ausblenden';

  @override
  String get filterMasteredText =>
      'Was sicher sitzt, verschwindet aus der Liste. Übrig bleibt, was noch Fehler macht.';

  @override
  String get filterPerfectedTitle => 'Erst mit 3 Sternen und 3 Blitzen';

  @override
  String get filterPerfectedText =>
      'Nur was sicher **und** schnell ist, verschwindet. Was zwar fehlerfrei, aber noch langsam ist, bleibt zum Üben stehen.';

  @override
  String get rangeAll => 'Alle';

  @override
  String get rangeToday => 'Heute';

  @override
  String get rangeWeek => '7 Tage';

  @override
  String get rangeMonth => '30 Tage';

  @override
  String get rangeAllPhrase => 'aus dem ganzen Verlauf';

  @override
  String get rangeTodayPhrase => 'von heute';

  @override
  String get rangeWeekPhrase => 'aus den letzten 7 Tagen';

  @override
  String get rangeMonthPhrase => 'aus den letzten 30 Tagen';

  @override
  String get backupErrorNotABackup => 'Die Datei ist keine gültige Sicherung.';

  @override
  String get backupErrorWrongApp =>
      'Diese Datei stammt nicht aus dem Mathe-Trainer.';

  @override
  String get backupErrorTooNew =>
      'Die Sicherung stammt aus einer neueren Version der App.';

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
  String get relativeToday => 'heute';

  @override
  String get relativeYesterday => 'gestern';

  @override
  String relativeDaysAgo(int days) {
    return 'vor $days Tagen';
  }

  @override
  String remainingMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'noch $minutes Minuten',
      one: 'noch eine Minute',
      zero: 'gleich',
    );
    return '$_temp0';
  }

  @override
  String moneyAmount(String amount) {
    return '$amount €';
  }

  @override
  String moneyCoinCents(int n) {
    return '$n ct';
  }

  @override
  String moneyCoinEuros(int n) {
    return '$n €';
  }

  @override
  String get deadlineToday => 'heute';

  @override
  String get deadlineUntilSunday => 'bis Sonntag';

  @override
  String get deadlineStillOpen => 'noch offen';

  @override
  String deadlineWas(String day) {
    return 'war $day';
  }

  @override
  String get deadlineThisWeek => 'diese Woche';

  @override
  String deadlineFrom(String day) {
    return 'ab $day';
  }

  @override
  String deadlineOn(String day) {
    return 'am $day';
  }

  @override
  String commonSecondsShort(int n) {
    return '$n s';
  }

  @override
  String commonPercent(int n) {
    return '$n %';
  }
}
