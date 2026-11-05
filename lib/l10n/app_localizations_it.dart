// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Mathe-Trainer';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonDelete => 'Elimina';

  @override
  String commonMinutesShort(int n) {
    return '$n min';
  }

  @override
  String versionLabel(String version) {
    return 'Versione $version';
  }

  @override
  String get loadFailureMessage => 'Impossibile caricare in questo momento.';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsTaskCountHeading => 'Calcoli per giro';

  @override
  String get settingsParentAreaNote =>
      'Orologio e vibrazione, l’impostazione per tutti, eliminare i risultati, gestire i profili e vedere il registro degli esercizi: tutto questo si trova nell’area genitori nella schermata iniziale, protetta dal PIN.';

  @override
  String get amountNoLimit => 'nessun limite';

  @override
  String get amountSameAsAll => 'come per tutti';

  @override
  String amountSameAsAllWith(String value) {
    return 'come per tutti ($value)';
  }

  @override
  String get taskCountSameEverywhere => 'uguale ovunque';

  @override
  String taskCountSameEverywhereWith(int count) {
    return 'uguale ovunque ($count)';
  }

  @override
  String get taskCountExplanationProfile =>
      'Vale la più specifica: prima un compito aperto, poi l’ultima scelta per una lezione, poi questa impostazione, poi quella per tutti.';

  @override
  String get taskCountExplanationGlobal =>
      'Vale la più specifica: prima un compito aperto, poi l’ultima scelta per una lezione, poi quella del profilo, poi questa impostazione.';

  @override
  String get soundTestRunning => 'Riproduzione …';

  @override
  String get soundTestButton => 'Prova il suono (10 clic)';

  @override
  String soundTestAllPlayed(int played, int expected) {
    return '$played clic su $expected riprodotti. Se non hai sentito nulla, controlla il volume del dispositivo.';
  }

  @override
  String soundTestSomePlayed(int played, int expected) {
    return 'Solo $played clic su $expected riprodotti - su questo dispositivo il suono si interrompe.';
  }

  @override
  String soundTestUnavailable(String error) {
    return 'Il suono non è disponibile su questo dispositivo:\n$error';
  }

  @override
  String get recommendShaky => 'L’ultima volta era incerto';

  @override
  String get recommendFresh => 'Non l’hai mai fatto';

  @override
  String get recommendStale => 'Da molto tempo non lo fai';

  @override
  String get pauseDayDoneTitle => 'Per oggi basta!';

  @override
  String pauseDayDoneText(int minutes) {
    return 'Oggi hai fatto $minutes minuti di matematica. Domani si continua.';
  }

  @override
  String get pauseBreakTitle => 'È ora di fare una pausa!';

  @override
  String pauseBreakText(int minutes, String clock, String left) {
    return 'Ti sei esercitato per $minutes minuti di fila. Si riprende alle $clock - $left.';
  }

  @override
  String pauseClock(String time) {
    return '$time';
  }

  @override
  String get runHintTooShort =>
      'Non conta: niente stelle, niente fulmini, niente classifica.';

  @override
  String runHintUsedUpToday(int count) {
    return 'Oggi ha già contato $count× - puoi continuare a esercitarti, ma non conterà più.';
  }

  @override
  String runHintRemaining(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Ancora $minutes minuti, poi una pausa.',
      one: 'Ancora un minuto, poi una pausa.',
      zero: 'Sta per arrivare una pausa.',
    );
    return '$_temp0';
  }

  @override
  String get assignmentGoalDone => 'Compito svolto!';

  @override
  String assignmentGoalCounts(int done, int runs) {
    return 'Conta per il tuo compito: $done su $runs';
  }

  @override
  String get assignmentGoalNotEnough => 'Per il tuo compito non basta ancora:';

  @override
  String get assignmentTileDone => 'fatto';

  @override
  String get todayHeading => 'Esercizio di oggi';

  @override
  String get todayNothingYet => 'ancora niente';

  @override
  String todayNothingOfLimit(int limit) {
    return 'ancora niente su $limit min';
  }

  @override
  String todayTimeOfLimit(String time, int limit) {
    return '$time su $limit min';
  }

  @override
  String get progressChartEmpty =>
      'Dal secondo giro in poi qui compare la tua curva di apprendimento.';

  @override
  String starRowEarnedOf(int earned, int possible) {
    return '$earned su $possible';
  }

  @override
  String get adminSessionClosed => 'Area genitori chiusa.';

  @override
  String get taskClock24Question => 'Che ore sono? Usa l’orologio a 24 ore.';

  @override
  String get backupShareSubject => 'Copia di sicurezza Mathe-Trainer';

  @override
  String backupExportFailed(String error) {
    return 'Copia di sicurezza non riuscita: $error';
  }

  @override
  String get backupImportConfirmTitle => 'Ripristinare la copia?';

  @override
  String get backupImportConfirmText =>
      'Tutti i profili e i risultati su questo dispositivo verranno sostituiti dalla copia di sicurezza. Quello che c’è adesso andrà perso.';

  @override
  String get backupReplace => 'Sostituisci';

  @override
  String get backupFileTypeLabel => 'Copia di sicurezza';

  @override
  String backupImported(int users, int sessions) {
    return '$users profili e $sessions giri ripristinati.';
  }

  @override
  String backupImportFailed(String error) {
    return 'Ripristino non riuscito: $error';
  }

  @override
  String get backupHeading => 'Dati';

  @override
  String get backupIntro =>
      'Tutti i profili, i risultati e le impostazioni in un file. Conservalo in un posto diverso dal tablet - se il dispositivo viene ripristinato, perde tutto.';

  @override
  String get backupCreate => 'Crea copia di sicurezza';

  @override
  String get backupRestore => 'Ripristina copia';

  @override
  String get backupNever => 'Nessuna copia di sicurezza finora.';

  @override
  String backupLast(String when) {
    return 'Ultima copia: $when.';
  }

  @override
  String backupLastOverdue(String when) {
    return 'Ultima copia: $when. È passato un po’ di tempo.';
  }

  @override
  String get pinTitleVerify => 'Area genitori';

  @override
  String get pinTitleSetup => 'Imposta l’area genitori';

  @override
  String get pinHintEnter => 'Inserisci il PIN';

  @override
  String pinHintChoose(int length) {
    return 'Scegli un PIN di $length cifre';
  }

  @override
  String get pinHintRepeat => 'Ripeti il PIN';

  @override
  String get pinWrong => 'PIN errato.';

  @override
  String get pinMismatch => 'Le due immissioni erano diverse.';

  @override
  String get startWhatDoesItMean => 'Cosa significa?';

  @override
  String startExample(String example) {
    return 'Ad esempio:  $example';
  }

  @override
  String startAssignmentGoal(int count) {
    return 'Per il tuo compito: $count calcoli';
  }

  @override
  String get startHowMany => 'Quanti calcoli?';

  @override
  String startBoltsFrom(String time) {
    return 'da $time per calcolo';
  }

  @override
  String get startGo => 'Via!';

  @override
  String get startLeaderboard => 'Classifica';

  @override
  String get commonPerTask => 'per calcolo';

  @override
  String get commonErrors => 'Errori';

  @override
  String get commonTasks => 'Calcoli';

  @override
  String leaderboardTitle(String lesson) {
    return 'Classifica · $lesson';
  }

  @override
  String leaderboardEmpty(int min) {
    return 'Ancora nessun risultato.\nPer la classifica contano almeno $min calcoli.';
  }

  @override
  String leaderboardScoreExplanation(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds secondi',
      one: '1 secondo',
    );
    return 'Il punteggio è il tempo per calcolo, più $_temp0 per ogni tentativo sbagliato. Così tirare a indovinare non conviene, e i giri con un numero diverso di calcoli restano confrontabili.';
  }

  @override
  String statsTitle(String name) {
    return 'Statistiche · $name';
  }

  @override
  String get statsEmpty => 'Ancora nessun giro concluso.';

  @override
  String statsLearningCurve(String lesson) {
    return 'Curva di apprendimento · $lesson';
  }

  @override
  String get statsLearningCurveSub => 'Secondi per calcolo, giro dopo giro';

  @override
  String get statsHardest => 'Questi calcoli richiedono più tempo';

  @override
  String get statsHeadStars => 'Stelle';

  @override
  String get statsHeadBest => 'Migliore';

  @override
  String get statsHeadAverage => 'Ø tempo';

  @override
  String get statsHeadRuns => 'Giri';

  @override
  String get statsTooFewData => 'Ancora pochi dati.';

  @override
  String get globalStatsTitle => 'Tutti i risultati';

  @override
  String get globalStatsTabOverview => 'Panoramica';

  @override
  String get globalStatsTabLeaderboards => 'Classifiche';

  @override
  String get globalStatsNoProfiles => 'Ancora nessun profilo.';

  @override
  String globalStatsActivityHeading(int days) {
    return 'Esercizio degli ultimi $days giorni';
  }

  @override
  String get globalStatsActivitySub =>
      'Minuti al giorno, ogni bambino con il suo colore';

  @override
  String globalStatsNoLeaderboards(int min) {
    return 'Ancora nessuna classifica.\nUn giro conta da $min calcoli.';
  }

  @override
  String get globalStatsNotPlayed => 'Ancora nessun esercizio.';

  @override
  String globalStatsRounds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'giri',
      one: 'giro',
    );
    return '$_temp0';
  }

  @override
  String get globalStatsPractised => 'di esercizio';

  @override
  String globalStatsStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: '1 giorno',
    );
    return '$_temp0 di fila';
  }

  @override
  String globalStatsLastPlayed(String when) {
    return 'ultimo: $when';
  }

  @override
  String get globalStatsNoActivity =>
      'Nelle ultime settimane nessuno si è esercitato.';

  @override
  String get profilesTitle => 'Chi tocca a te?';

  @override
  String get profilesAllResults => 'Tutti i risultati';

  @override
  String get profilesDuel => 'Sfida';

  @override
  String get profilesParents => 'Genitori';

  @override
  String get profilesNone =>
      'Ancora nessun profilo. Tocca “Nuovo” per cominciare.';

  @override
  String profilesLockedTitle(String name) {
    return '$name fa una pausa';
  }

  @override
  String get profilesLockedText =>
      'Questo profilo è bloccato per ora. Tutte le stelle, i fulmini e i tempi migliori restano - ritornano appena i genitori lo sbloccano.';

  @override
  String get profilesLockedOk => 'Capito';

  @override
  String get profilesAllDone => 'tutto fatto';

  @override
  String profilesTodo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count compiti',
      one: '1 compito',
    );
    return '$_temp0';
  }

  @override
  String get profilesEditLook => 'Cambia immagine e colore';

  @override
  String get profilesNew => 'Nuovo';

  @override
  String get profileEditorNew => 'Nuovo profilo';

  @override
  String get profileEditorChangeName => 'Cambia nome';

  @override
  String get profileEditorNameLabel => 'Nome';

  @override
  String get profileEditorNext => 'Avanti';

  @override
  String get profileEditorLookTitle => 'Immagine e colore';

  @override
  String get profileEditorPicture => 'Immagine';

  @override
  String get profileEditorColor => 'Colore';

  @override
  String get profileEditorSave => 'Salva';

  @override
  String get duelTitle => 'Sfida';

  @override
  String get duelNeedTwoProfiles => 'Per una sfida servono almeno due profili.';

  @override
  String get duelWhoPlays => 'Chi gioca?';

  @override
  String duelPlayerLocked(String avatar, String name) {
    return '$avatar  $name · bloccato';
  }

  @override
  String duelPlayerOnBreak(String avatar, String name) {
    return '$avatar  $name · pausa';
  }

  @override
  String duelPlayer(String avatar, String name) {
    return '$avatar  $name';
  }

  @override
  String get duelWhichTasks => 'Quali calcoli?';

  @override
  String get duelPickTwo => 'Scegli almeno due bambini.';

  @override
  String duelLessonChip(String title, String example) {
    return '$title  ·  $example';
  }

  @override
  String get duelStart => 'Inizia la sfida';

  @override
  String duelPosition(int position, int total) {
    return '$position su $total';
  }

  @override
  String duelYourTurn(String name) {
    return 'Tocca a $name';
  }

  @override
  String duelLessonAndGroup(String lesson, String group) {
    return '$lesson · $group';
  }

  @override
  String get duelReady => 'Pronto';

  @override
  String get duelAbort => 'Annulla la sfida';

  @override
  String duelResultTitle(String lesson) {
    return 'Sfida · $lesson';
  }

  @override
  String get duelSameTasks => 'Tutti hanno avuto gli stessi calcoli.';

  @override
  String get duelDone => 'Fatto';

  @override
  String get duelWin => 'Vince!';

  @override
  String get commonBackToLessons => 'Torna alle lezioni';

  @override
  String get resultDone => 'Bravo!';

  @override
  String resultDoneName(String name) {
    return 'Bravo, $name!';
  }

  @override
  String resultNextBolt(int n, String time) {
    return 'Fulmine $n da $time per calcolo';
  }

  @override
  String get resultForThisLesson => 'per questa lezione';

  @override
  String get resultInTotal => 'in tutto';

  @override
  String get resultMetricTasks => 'Calcoli';

  @override
  String get resultMetricTotalTime => 'Tempo totale';

  @override
  String get resultMetricPerTask => 'Per calcolo';

  @override
  String get resultMetricErrors => 'Errori';

  @override
  String resultPenalty(String penalty, int count, int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tentativi sbagliati',
      one: '1 tentativo sbagliato',
    );
    String _temp1 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds secondi',
      one: '1 secondo',
    );
    return 'Include una penalità di $penalty per $_temp0 - $_temp1 ciascuno.';
  }

  @override
  String resultStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: '1 giorno',
    );
    return '$_temp0 di esercizio di fila!';
  }

  @override
  String get resultAgain => 'Ancora';

  @override
  String get resultLeaderboard => 'Classifica';

  @override
  String get resultOtherLesson => 'Altra lezione';

  @override
  String get resultFirstRun =>
      'Questo era il tuo primo giro qui -\nda adesso questo tempo è il tuo record.';

  @override
  String get resultSameSpeed => 'Veloce esattamente come l’ultima volta.';

  @override
  String resultFaster(String delta) {
    return '$delta più veloce per calcolo dell’ultima volta!';
  }

  @override
  String resultSlower(String delta) {
    return '$delta più lento per calcolo dell’ultima volta.';
  }

  @override
  String get practiceAbortTitle => 'Finire l’esercizio?';

  @override
  String get practiceAbortText => 'Questo giro non conterà per la classifica.';

  @override
  String get practiceKeepGoing => 'Continua';

  @override
  String get practiceAbortConfirm => 'Finisci';

  @override
  String get practiceAbortTooltip => 'Finisci l’esercizio';

  @override
  String get practicePause => 'Pausa';

  @override
  String get practicePauseNote => 'L’orologio è fermo.';

  @override
  String get practiceResume => 'Riprendi';

  @override
  String get lessonsFilterTooltip => 'Nascondi le lezioni finite';

  @override
  String get lessonsHideDoneAssignments => 'Nascondi i compiti svolti';

  @override
  String get lessonsStatsLabel => 'Statistiche';

  @override
  String get lessonsSettingsTooltip => 'Impostazioni';

  @override
  String get lessonsSwitchLabel => 'Cambia';

  @override
  String get lessonsNoGroup =>
      'Per questo profilo non è ancora sbloccata nessuna area.\nSi può cambiare nell’area genitori.';

  @override
  String get lessonsNothingLeftTitle => 'Tutto fatto!';

  @override
  String get lessonsNothingLeftText =>
      'Quello che puoi fare adesso è nascosto. Il filtro in alto riporta tutto il catalogo.';

  @override
  String get lessonsRecommendGo => 'Via';

  @override
  String lessonsRecommendTitle(String lesson, String group) {
    return '$lesson · $group';
  }

  @override
  String get lessonsAssignmentsHeading => 'I tuoi compiti';

  @override
  String get lessonsAssignmentsAllDone =>
      'Tutto fatto! I compiti svolti sono nascosti.';

  @override
  String get lessonsNotPractised => 'non ancora fatto';

  @override
  String lessonsPractisedTimes(int count) {
    return 'fatto $count×';
  }

  @override
  String get adminTitle => 'Area genitori';

  @override
  String get adminTabHistory => 'Registro';

  @override
  String get adminTabManagement => 'Gestione';

  @override
  String get adminTabAssignments => 'Compiti';

  @override
  String get adminTabSettings => 'Impostazioni';

  @override
  String get adminFilterAll => 'Tutti';

  @override
  String get adminShowDeleted => 'Eliminati';

  @override
  String adminHistoryTruncated(int limit) {
    return 'Sono mostrati gli ultimi $limit giri. Un periodo più breve mostra il resto.';
  }

  @override
  String adminCleanupAll(int count) {
    return 'Pulisci i giri interrotti ($count)';
  }

  @override
  String adminCleanupOne(String name, int count) {
    return 'Pulisci i giri interrotti di $name ($count)';
  }

  @override
  String get adminHistoryEmpty => 'Ancora nessun giro.';

  @override
  String get adminDeleteRunTitle => 'Eliminare questo giro?';

  @override
  String adminDeleteRunText(String user, String lesson, String when) {
    return '$user · $lesson · $when';
  }

  @override
  String get adminRunDeleted => 'Giro eliminato.';

  @override
  String get adminUndo => 'Annulla';

  @override
  String get adminThisChild => 'questo bambino';

  @override
  String get adminWhoAll => 'di tutti i bambini';

  @override
  String adminWhoOne(String name) {
    return 'di $name';
  }

  @override
  String adminCleanupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pulire $count giri interrotti?',
      one: 'Pulire un giro interrotto?',
    );
    return '$_temp0';
  }

  @override
  String adminCleanupText(String whose, String range) {
    return 'I giri interrotti $whose $range spariranno. Non hanno mai contato per stelle, fulmini o classifica - il tempo di esercizio resta conteggiato.';
  }

  @override
  String get adminCleanupConfirm => 'Pulisci';

  @override
  String adminCleanedUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giri interrotti eliminati.',
      one: 'Un giro interrotto eliminato.',
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
      other: '$count calcoli',
      one: '1 calcolo',
    );
    return 'interrotto dopo $_temp0';
  }

  @override
  String get adminRestore => 'Ripristina';

  @override
  String get adminDeleteRun => 'Elimina giro';

  @override
  String get adminProfiles => 'Profili';

  @override
  String get adminNewProfile => 'Nuovo profilo';

  @override
  String get adminProfilesNote =>
      'Toccando un bambino si apre tutto ciò che lo riguarda: aree, tempi, blocco, rinomina ed eliminazione. Ogni bambino può cambiare da solo immagine e colore nella schermata iniziale.';

  @override
  String get adminPinHeading => 'PIN';

  @override
  String get adminPinNote =>
      'Protegge quest’area. Dimenticato? Allora l’unica via d’uscita è cancellare i dati dell’app nelle impostazioni di Android - e così si cancellano anche tutti i risultati.';

  @override
  String get adminChangePin => 'Cambia PIN';

  @override
  String get adminGroupsNone => 'Nessuna area sbloccata';

  @override
  String get adminGroupsAll => 'Tutte le aree';

  @override
  String adminGroupsSome(int n, int total) {
    return '$n aree su $total';
  }

  @override
  String get adminLocked => 'Bloccato';

  @override
  String get adminNoReview => 'senza ripasso';

  @override
  String get profileSettingsDiscardTitle => 'Scartare le modifiche?';

  @override
  String profileSettingsDiscardText(String name) {
    return 'Le impostazioni di $name sono state modificate ma non ancora salvate.';
  }

  @override
  String get profileSettingsDiscard => 'Scarta';

  @override
  String get profileSettingsSave => 'Salva';

  @override
  String get profileSettingsSectionPractice => 'Esercizio';

  @override
  String get profileSettingsGroups => 'Aree';

  @override
  String get profileSettingsGroupsNote =>
      'Le aree disattivate non compaiono più nella schermata di esercizio. I risultati già ottenuti restano.';

  @override
  String get profileSettingsNoGroup =>
      'Senza nemmeno un’area il bambino non può esercitarsi.';

  @override
  String get profileSettingsHideDoneHeading => 'Nascondi le lezioni finite';

  @override
  String get profileSettingsHideDoneNote =>
      'Riduce il catalogo a ciò che non è ancora sicuro. Il bambino può cambiarlo anche nella schermata di esercizio - qui serve per impostarlo una volta per tutte. Il livello più severo lascia i Primi passi dove sono: lì non si misura il tempo, quindi non ci sono fulmini da conquistare.';

  @override
  String get profileSettingsHideDoneAssignments => 'Nascondi i compiti svolti';

  @override
  String get profileSettingsHideDoneAssignmentsNote =>
      'Le schede finite spariscono prima della fine del giorno o della settimana. Altrimenti restano lì, spuntate.';

  @override
  String get profileSettingsTaskCount => 'Calcoli per giro';

  @override
  String get profileSettingsReview => 'Ripassa i calcoli difficili';

  @override
  String get profileSettingsReviewNote =>
      'Un quarto di ogni giro è fatto di ciò che ha richiesto molto tempo o è andato male l’ultima volta.';

  @override
  String get profileSettingsSectionTime => 'Tempo e punteggio';

  @override
  String get profileSettingsStretch => 'Tempo di esercizio di fila';

  @override
  String get profileSettingsStretchNote =>
      'Dopo questo tempo c’è una pausa. Un giro in corso non viene mai interrotto - si blocca solo l’avvio successivo. Il tempo continua a contare finché la pausa non è stata fatta per intero.';

  @override
  String get profileSettingsBreakLength => 'Quanto dura la pausa?';

  @override
  String get profileSettingsDaily => 'E al giorno in tutto';

  @override
  String get profileSettingsDailyNote =>
      'Somma tutti i giri del giorno, con o senza pause. Quando il tempo è finito, si riprende il giorno dopo.';

  @override
  String get profileSettingsScoredRuns => 'Giri valutati per lezione e giorno';

  @override
  String get profileSettingsScoredRunsNote =>
      'Dopo, la stessa lezione si può ancora fare, ma non porta più un tempo migliore, stelle o fulmini. Il tempo di esercizio e il registro continuano a contare.';

  @override
  String get profileSettingsSectionTidy => 'Riordina';

  @override
  String get profileSettingsTidyNote =>
      'Questi pulsanti agiscono subito - non aspettano “Salva”.';

  @override
  String get profileSettingsRename => 'Rinomina';

  @override
  String get profileSettingsGiveBackStars => 'Restituisci le stelle …';

  @override
  String get profileSettingsResetResults => 'Elimina i risultati';

  @override
  String get profileSettingsDeleteProfile => 'Elimina il profilo';

  @override
  String profileSettingsResetTitle(String name) {
    return 'Eliminare i risultati di $name?';
  }

  @override
  String get profileSettingsResetText =>
      'Tempi migliori, curva di apprendimento e registro andranno persi. Il profilo resta.';

  @override
  String profileSettingsDeleteTitle(String name) {
    return 'Eliminare $name?';
  }

  @override
  String get profileSettingsDeleteText =>
      'Il profilo e tutti i risultati vengono rimossi.';

  @override
  String profileSettingsGroupSummary(int count, String example) {
    return '$count lezioni · es. $example';
  }

  @override
  String get profileSettingsLockTitle => 'Blocca il profilo per ora';

  @override
  String get profileSettingsLockNote =>
      'Il profilo allora non si può aprire né invitare a una sfida. Non si perde nulla: stelle, fulmini e tempi migliori tornano invariati dopo lo sblocco.';

  @override
  String get globalSettingsClock => 'Mostra l’orologio durante l’esercizio';

  @override
  String get globalSettingsClockNote =>
      'Il tempo viene sempre misurato. Ma vederlo rende nervosi alcuni bambini - per questo è disattivato in partenza.';

  @override
  String get globalSettingsHaptics => 'Vibra alla pressione dei tasti';

  @override
  String get globalSettingsHapticsNote =>
      'Una breve vibrazione a ogni tasto premuto.';

  @override
  String get globalSettingsSounds => 'Riproduci i suoni';

  @override
  String get globalSettingsSoundsNote =>
      'Un breve suono per giusto, uno diverso per sbagliato e un lieve clic sotto ogni tasto. Su un tablet appoggiato sul tavolo la vibrazione si sente appena.';

  @override
  String get globalSettingsTaskCount => 'Calcoli per giro per tutti';

  @override
  String get globalSettingsTaskCountNote =>
      'Per un singolo bambino l’impostazione è sotto “Gestione”, nel suo profilo - e il bambino può cambiarla nelle sue impostazioni.';

  @override
  String get globalSettingsLimits => 'Tempo di esercizio per tutti';

  @override
  String get globalSettingsLimitsNote =>
      'Vale per ogni bambino senza un’impostazione propria. Un giro in corso non viene mai interrotto - si blocca solo l’avvio successivo.';

  @override
  String get globalSettingsStretch => 'Di fila, poi una pausa';

  @override
  String get globalSettingsBreakLength => 'Quanto dura la pausa?';

  @override
  String get globalSettingsDaily => 'E al giorno in tutto';

  @override
  String get globalSettingsScoredRuns => 'Giri valutati per lezione e giorno';

  @override
  String get globalSettingsScoredRunsNote =>
      'Dopo, la stessa lezione si può ancora fare, ma non porta più un tempo migliore, stelle o fulmini. Così non conviene più ripetere la lezione più facile finché il tempo non è quello giusto. Il tempo di esercizio e il registro continuano a contare.';

  @override
  String resetStarsTitle(String group) {
    return 'Azzerare le stelle in “$group”?';
  }

  @override
  String resetStarsText(String name) {
    return 'Dopo, $name può guadagnarle di nuovo. Tempi migliori, fulmini, curva di apprendimento e classifiche restano invariati - riguarda solo le stelle di quest’area.';
  }

  @override
  String get resetStarsConfirm => 'Azzera';

  @override
  String resetStarsHeading(String name) {
    return 'Le stelle di $name';
  }

  @override
  String get resetStarsNote =>
      'Si azzerano solo le stelle. I tempi restano - tempi migliori, fulmini, curva di apprendimento e classifiche sono esattamente come prima.';

  @override
  String get resetStarsDone => 'Fatto';

  @override
  String resetStarsGroupLine(int earned, int possible) {
    return '$earned stelle su $possible';
  }

  @override
  String get assignmentsAll => 'Tutti';

  @override
  String get assignmentsNew => 'Nuovo compito';

  @override
  String get assignmentsHideFinished => 'Nascondi i completati';

  @override
  String assignmentsHiddenCount(int count) {
    return '$count nascosti';
  }

  @override
  String get assignmentsEmpty => 'Ancora nessun compito.';

  @override
  String get assignmentsNoneOpen =>
      'Nessun compito aperto. Quelli svolti sono nascosti.';

  @override
  String get assignmentsDaily => 'ogni giorno';

  @override
  String get assignmentsWeekly => 'ogni settimana';

  @override
  String get assignmentsCarriesOver => 'si riporta';

  @override
  String assignmentsLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lezioni',
      one: '1 lezione',
    );
    return '$_temp0';
  }

  @override
  String get assignmentsEdit => 'Modifica';

  @override
  String get assignmentsEnd => 'Termina';

  @override
  String get assignmentsRepeat => 'Assegna di nuovo';

  @override
  String get assignmentsDelete => 'Elimina il compito';

  @override
  String assignmentsRunsOfTasks(int runs, int tasks) {
    return '$runs× $tasks calcoli';
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
  String get assignmentsNoClosedPeriod => 'Ancora nessun periodo concluso';

  @override
  String assignmentsMetOf(int met, int total, String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'daily': 'giorni',
      'weekly': 'settimane',
      'other': 'settimane',
    });
    return 'Riuscito in $met su $total $_temp0';
  }

  @override
  String assignmentsBefore(int met, int total, String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'daily': 'giorni',
      'weekly': 'settimane',
      'other': 'settimane',
    });
    return 'prima $met su $total $_temp0';
  }

  @override
  String get assignmentsVerdictMet => 'Fatto';

  @override
  String get assignmentsVerdictPending => 'Ancora aperto';

  @override
  String get assignmentsVerdictLate => 'Mancato, recuperato dopo';

  @override
  String get assignmentsVerdictMissed => 'Mancato';

  @override
  String get editorTitleEdit => 'Modifica il compito';

  @override
  String get editorTitleAgain => 'Assegna di nuovo';

  @override
  String get editorTitleNew => 'Nuovo compito';

  @override
  String get editorChild => 'Bambino';

  @override
  String get editorUnknownChild => 'Bambino sconosciuto';

  @override
  String get editorLessons => 'Lezioni';

  @override
  String get editorLessonsNote =>
      'Se ne possono scegliere più d’una. Ognuna deve essere completata perché il compito sia svolto.';

  @override
  String get editorNoLesson =>
      'Senza nemmeno una lezione non c’è nulla da assegnare.';

  @override
  String get editorPeriod => 'Periodo';

  @override
  String get editorOneDay => 'un giorno';

  @override
  String get editorOneWeek => 'una settimana';

  @override
  String get editorRepetition => 'Ripetizione';

  @override
  String get editorEveryTime => 'ogni volta';

  @override
  String get editorOnce => 'una volta';

  @override
  String get editorDailyNote =>
      'Nuovo ogni giorno, da svolgere entro fine giornata.';

  @override
  String get editorWeeklyNote =>
      'Nuovo ogni settimana, da svolgere entro domenica sera.';

  @override
  String editorOnDay(String day) {
    return 'Il $day';
  }

  @override
  String editorInWeek(String day) {
    return 'Nella settimana da $day';
  }

  @override
  String get editorPickDay => 'Scegli un giorno …';

  @override
  String get editorCarryOver => 'Riporta se non svolto';

  @override
  String get editorCarryOverNote =>
      'Il compito allora resta finché non è svolto. Il giorno stesso conta comunque come mancato - le statistiche dicono quando si è esercitato, non cosa era previsto.';

  @override
  String get editorRuns => 'Giri';

  @override
  String get editorTasksPerRun => 'Calcoli per giro';

  @override
  String get editorMinStars => 'Stelle minime';

  @override
  String get editorMinBolts => 'Fulmini minimi';

  @override
  String get editorNoRequirement => 'nessun requisito';

  @override
  String get editorSave => 'Salva';

  @override
  String get editorCreate => 'Crea';

  @override
  String get groupFirstSteps => 'Primi passi';

  @override
  String get groupUpTo10 => 'Fino a 10';

  @override
  String get groupUpTo20 => 'Fino a 20';

  @override
  String get groupUpTo100 => 'Fino a 100';

  @override
  String get groupUpTo1000 => 'Fino a 1000';

  @override
  String get groupWithThousands => 'Con le migliaia';

  @override
  String get groupTimesTables => 'Tabelline';

  @override
  String get groupReverseTimesTables => 'Tabelline al contrario';

  @override
  String get groupTimesAndDivision => 'Per e diviso';

  @override
  String get groupEveryday => 'Ora e denaro';

  @override
  String get lessonAddPlainTitle => 'Più senza passare la decina';

  @override
  String get lessonAddPlainBigTitle => 'Più senza cambio';

  @override
  String get lessonAddPlainDesc =>
      'Le unità restano sotto 10 insieme - non c’è nessun riporto.';

  @override
  String get lessonAddPlainBigDesc =>
      'Nessun posto va oltre - né le unità né le decine.';

  @override
  String get lessonAddCarryTitle => 'Più passando la decina';

  @override
  String get lessonAddCarryBigTitle => 'Più con il cambio';

  @override
  String get lessonAddCarryDesc =>
      'Le unità fanno 10 o più - una decina passa avanti.';

  @override
  String get lessonAddCarryBigDesc =>
      'Le unità o le decine vanno oltre - c’è un riporto da fare.';

  @override
  String get lessonSubPlainTitle => 'Meno senza passare la decina';

  @override
  String get lessonSubPlainBigTitle => 'Meno senza cambio';

  @override
  String get lessonSubPlainDesc =>
      'Ogni cifra di sopra è abbastanza grande - non si deve rompere nessuna decina.';

  @override
  String get lessonSubPlainBigDesc =>
      'Ogni cifra di sopra è abbastanza grande - non si deve rompere niente.';

  @override
  String get lessonSubBorrowTitle => 'Meno passando la decina';

  @override
  String get lessonSubBorrowBigTitle => 'Meno con il cambio';

  @override
  String get lessonSubBorrowDesc =>
      'Le unità di sopra non bastano - si deve rompere una decina.';

  @override
  String get lessonSubBorrowBigDesc =>
      'Un posto di sopra non basta - si deve rompere una decina o un centinaio.';

  @override
  String get lessonPlusGapTitle => 'Più con un numero mancante';

  @override
  String get lessonMinusGapTitle => 'Meno con un numero mancante';

  @override
  String get lessonGapDesc =>
      'Trova il numero che manca perché il calcolo sia giusto.';

  @override
  String get lessonMixedTitle => 'Più e meno mescolati';

  @override
  String get lessonMixedDesc =>
      'Più e meno si alternano a caso, con e senza passaggio della decina.';

  @override
  String lessonTimesTableTitle(int n) {
    return 'Tabellina $n';
  }

  @override
  String lessonTimesTableDesc(int n) {
    return 'Tutti i calcoli della tabellina $n, nei due sensi: $n · 4 e anche 4 · $n.';
  }

  @override
  String lessonReverseTableTitle(int n) {
    return 'Tabellina $n al contrario';
  }

  @override
  String lessonReverseTableDesc(int n, int product) {
    return 'Diviso per $n. Ogni calcolo è l’inverso di uno della tabellina $n: $n · 4 = $product diventa $product : $n = 4.';
  }

  @override
  String get lessonPartnersOfTenTitle => 'Gli amici del 10';

  @override
  String get lessonPartnersOfTenDesc =>
      'Due numeri sono amici quando insieme fanno esattamente 10: 1 e 9, 2 e 8, 3 e 7. Te lo chiedo nei due sensi - da 3 a 7 e anche da 7 a 3.';

  @override
  String get lessonAdd10Title => 'Più fino a 10';

  @override
  String get lessonAdd10Desc => 'Sommare senza superare il 10.';

  @override
  String get lessonSub10Title => 'Meno fino a 10';

  @override
  String get lessonSub10Desc => 'Togliere entro il 10.';

  @override
  String get lessonMix10Desc => 'Più e meno si alternano a caso.';

  @override
  String get lessonTimesAllTitle => 'Tutte le tabelline mescolate';

  @override
  String get lessonTimesAllDesc => 'Tutte le tabelline, tutte mescolate.';

  @override
  String get lessonDivPlainTitle => 'Tutte le tabelline al contrario';

  @override
  String get lessonDivPlainDesc =>
      'Diviso per tutto, tutto mescolato. Ogni calcolo torna esatto - è l’inverso di un calcolo di tabellina.';

  @override
  String get lessonDivRemainderTitle => 'Divisione con resto';

  @override
  String get lessonDivRemainderDesc =>
      'Avanza sempre qualcosa. Scrivi prima il risultato, poi il resto.';

  @override
  String get lessonTimesGapTitle => 'Per con un numero mancante';

  @override
  String get lessonTimesGapDesc =>
      'Per quale numero devi moltiplicare perché sia giusto?';

  @override
  String get lessonDivGapTitle => 'Diviso con un numero mancante';

  @override
  String get lessonDivGapDesc =>
      'Per quale numero devi dividere perché sia giusto?';

  @override
  String get lessonMulTensTitle => 'Per con le decine';

  @override
  String get lessonMulTensDesc =>
      'La tabellina con uno zero dietro: 3 · 4 = 12, quindi 30 · 4 = 120.';

  @override
  String get lessonMulTwoDigitTitle => 'Per oltre la tabellina';

  @override
  String get lessonMulTwoDigitDesc =>
      'Moltiplica un numero di due cifre, per esempio 14 · 6.';

  @override
  String get lessonDivTwoDigitTitle => 'Diviso oltre la tabellina';

  @override
  String get lessonDivTwoDigitDesc =>
      'Il risultato è maggiore di dieci, per esempio 96 : 6.';

  @override
  String get lessonMulDivMixedTitle => 'Per e diviso mescolati';

  @override
  String get lessonMulDivMixedDesc =>
      'Moltiplicazioni e divisioni si alternano a caso.';

  @override
  String get lessonPunktVorStrichTitle => 'Prima per e diviso';

  @override
  String get lessonPunktVorStrichDesc =>
      'Per e diviso vengono prima di più e meno - anche quando stanno alla fine: in 40 − 3 · 6 si calcola prima 3 · 6.';

  @override
  String get lessonCountPicturesTitle => 'Quanti? (in fila)';

  @override
  String get lessonCountPicturesDesc =>
      'Conta le figure, da uno a cinque, ben in fila.';

  @override
  String get lessonCountPicturesCloudTitle => 'Quanti? (sparsi)';

  @override
  String get lessonCountPicturesCloudDesc =>
      'Le stesse figure, ma sparse - devi ricordare cosa hai già contato.';

  @override
  String get lessonCountDiceTitle => 'Quanti puntini?';

  @override
  String get lessonCountDiceDesc =>
      'Un dado. Presto vedrai il numero senza contare.';

  @override
  String get lessonCompareMoreTitle => 'Dove ce ne sono di più? (in fila)';

  @override
  String get lessonCompareMoreDesc =>
      'Confronta due gruppi e scrivi il numero più grande.';

  @override
  String get lessonCompareMoreCloudTitle => 'Dove ce ne sono di più? (sparsi)';

  @override
  String get lessonCompareMoreCloudDesc =>
      'Lo stesso, ma le figure sono sparse.';

  @override
  String get lessonCountNextTitle => 'Quale numero viene dopo?';

  @override
  String get lessonCountNextDesc => 'La linea dei numeri avanti e indietro.';

  @override
  String get lessonBeesAddTitle => 'Le apine (in fila)';

  @override
  String get lessonBeesAddDesc =>
      'Somma due piccoli gruppi di api; mai più di dieci in tutto.';

  @override
  String get lessonBeesAddCloudTitle => 'Le apine (sparse)';

  @override
  String get lessonBeesAddCloudDesc =>
      'Lo stesso calcolo, ma le api volano dappertutto.';

  @override
  String get lessonDiceAddTitle => 'Somma di due dadi';

  @override
  String get lessonDiceAddDesc =>
      'Entrambi i dadi mostrano fino a cinque puntini - quanti sono in tutto?';

  @override
  String get lessonAddToSixTitle => 'Più fino a 6';

  @override
  String get lessonAddToSixDesc => 'Sommare, senza mai superare il sei.';

  @override
  String get lessonSubToSixTitle => 'Meno fino a 6';

  @override
  String get lessonSubToSixDesc => 'Togliere entro il sei.';

  @override
  String get lessonCalcToSixTitle => 'Più e meno fino a 6';

  @override
  String get lessonCalcToSixDesc =>
      'Tutti e due mescolati, senza mai superare il sei.';

  @override
  String get lessonClockHalfTitle => 'Ore intere e mezze';

  @override
  String get lessonClockHalfDesc =>
      'Che ore sono? La lancetta grande punta sul 12 o sul 6.';

  @override
  String get lessonClockQuarterTitle => 'Quarti d’ora';

  @override
  String get lessonClockQuarterDesc =>
      'E un quarto, e mezza, meno un quarto - la lancetta grande punta sul 12, sul 3, sul 6 o sul 9.';

  @override
  String get lessonClockFiveTitle => 'Ora ai cinque minuti';

  @override
  String get lessonClockFiveDesc =>
      'La lancetta grande punta su uno dei dodici numeri.';

  @override
  String get lessonClock24Title => 'Ora a 24 ore';

  @override
  String get lessonClock24Desc =>
      'Il pomeriggio si continua a contare: le 3 diventano le 15:00. Sotto l’orologio c’è scritto che momento della giornata è.';

  @override
  String get lessonClockWordsTitle => 'Dire l’ora';

  @override
  String get lessonClockWordsDesc =>
      'Come si dice l’ora? Prima scrivi l’ora, poi tocca l’espressione - per “le tre e mezza” è il 3.';

  @override
  String get lessonMoneyAddTitle => 'Sommare i soldi';

  @override
  String get lessonMoneyAddDesc =>
      'Somma due importi. Scrivi prima gli euro, poi i centesimi.';

  @override
  String get lessonMoneySubTitle => 'Togliere i soldi';

  @override
  String get lessonMoneySubDesc => 'Quanto resta, o quanto ti danno di resto?';

  @override
  String get lessonMoneyComposeTitle => 'Comporre un importo';

  @override
  String get lessonMoneyComposeDesc =>
      'Componi l’importo con monete e banconote. Ci sono molti modi giusti - alla fine l’importo deve essere esatto.';

  @override
  String get lessonMoneyChangeTitle => 'Quanto resto ricevo?';

  @override
  String get lessonMoneyChangeDesc =>
      'Una cosa costa un importo strano e paghi con una banconota o una moneta tonda. Devi trovare il resto.';

  @override
  String get lessonPlaceValue100Title => 'Unità e decine';

  @override
  String get lessonPlaceValue100Desc =>
      'Quante unità e decine ci sono? Che numero è tutto insieme? Possono esserci più di nove unità.';

  @override
  String get lessonPlaceValue1000Title => 'Unità, decine, centinaia';

  @override
  String get lessonPlaceValue1000Desc =>
      'Quante unità, decine e centinaia ci sono? Che numero è tutto insieme? Di una specie ce ne possono essere più di nove.';

  @override
  String get lessonRoundThousandsTitle => 'Migliaia intere';

  @override
  String get lessonRoundThousandsDesc =>
      '3000 + 4000, 8000 − 5000: calcola con migliaia intere. Se sai fare 3 + 4, sai fare anche questo.';

  @override
  String get lessonRoundHundredsTitle => 'Centinaia intere';

  @override
  String get lessonRoundHundredsDesc =>
      '2300 + 400, 5600 − 200: calcola con centinaia intere. Qui si può anche superare il mille.';

  @override
  String get lessonRoundGapTitle => 'Migliaia e centinaia: numero mancante';

  @override
  String get lessonRoundGapDesc =>
      '3000 + ? = 7000. Cosa manca per arrivare al numero? Pensa al contrario.';

  @override
  String get lessonPlaceValue10000Title => 'Unità, decine, centinaia, migliaia';

  @override
  String get lessonPlaceValue10000Desc =>
      'Quante unità, decine, centinaia e migliaia ci sono? Che numero è tutto insieme? Di una specie ce ne possono essere più di nove.';

  @override
  String get lessonAddSub10000PlainTitle => 'Più e meno senza cambio';

  @override
  String get lessonAddSub10000PlainDesc =>
      '4200 + 350, 6870 − 40: numeri di quattro cifre, ma senza cambio. Un posto alla volta.';

  @override
  String taskQuestionPartner(int a) {
    return 'Cosa sta con $a per fare 10?';
  }

  @override
  String get taskQuestionClock => 'Che ore sono?';

  @override
  String get taskQuestionClockPhrase => 'Come si dice?';

  @override
  String taskQuestionMoneyCompose(String amount) {
    return 'Componi $amount - tocca monete e banconote.';
  }

  @override
  String taskQuestionChange(String price, String paid) {
    return 'Costa $price. Paghi $paid. Quanto resto ricevi?';
  }

  @override
  String get taskQuestionQuantity => 'Quanti?';

  @override
  String get taskQuestionDiceOne => 'Quanti puntini?';

  @override
  String get taskQuestionDiceTwo => 'Quanti puntini in tutto?';

  @override
  String get taskQuestionCompare =>
      'Dove ce ne sono di più? Tocca il numero più grande.';

  @override
  String get taskQuestionSequence => 'Quale numero viene dopo?';

  @override
  String get taskQuestionQuantityAdd => 'Quanti in tutto?';

  @override
  String get taskQuestionPlaceValue => 'Che numero è?';

  @override
  String get taskLabelRemainder => 'Resto';

  @override
  String get taskLabelEuro => '€';

  @override
  String get taskLabelClock => ':';

  @override
  String get taskUnitCents => 'cent';

  @override
  String placeOnes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n unità',
      one: '1 unità',
    );
    return '$_temp0';
  }

  @override
  String placeTens(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n decine',
      one: '1 decina',
    );
    return '$_temp0';
  }

  @override
  String placeHundreds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n centinaia',
      one: '1 centinaio',
    );
    return '$_temp0';
  }

  @override
  String placeThousands(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n migliaia',
      one: '1 migliaio',
    );
    return '$_temp0';
  }

  @override
  String taskRenderRemainder(String prefix, String answer, String second) {
    return '$prefix $answer resto $second';
  }

  @override
  String taskRenderClock(int hour, String minute) {
    return '$hour:$minute';
  }

  @override
  String taskRenderChange(String price, String paid) {
    return '$price, pagato con $paid';
  }

  @override
  String taskRenderDiceOne(int a) {
    String _temp0 = intl.Intl.pluralLogic(
      a,
      locale: localeName,
      other: '$a puntini',
      one: '1 puntino',
    );
    return '$_temp0';
  }

  @override
  String taskRenderDiceTwo(int a, int b) {
    return '$a + $b puntini';
  }

  @override
  String get dayPartMorning => 'di mattina';

  @override
  String get dayPartNoon => 'a mezzogiorno';

  @override
  String get dayPartAfternoon => 'del pomeriggio';

  @override
  String get dayPartEvening => 'di sera';

  @override
  String get clockPhrase05 => 'e cinque';

  @override
  String get clockPhrase10 => 'e dieci';

  @override
  String get clockPhrase15 => 'e un quarto';

  @override
  String get clockPhrase20 => 'e venti';

  @override
  String get clockPhrase25 => 'e venticinque';

  @override
  String get clockPhrase30 => 'e mezza';

  @override
  String get clockPhrase35 => 'meno venticinque';

  @override
  String get clockPhrase40 => 'meno venti';

  @override
  String get clockPhrase45 => 'meno un quarto';

  @override
  String get clockPhrase50 => 'meno dieci';

  @override
  String get clockPhrase55 => 'meno cinque';

  @override
  String clockSpokenTime(String phrase, int hour) {
    return '$hour $phrase';
  }

  @override
  String get filterAllTitle => 'Mostra tutto';

  @override
  String get filterAllText => 'Tutto il catalogo, niente è nascosto.';

  @override
  String get filterMasteredTitle => 'Nascondi con 3 stelle';

  @override
  String get filterMasteredText =>
      'Quello che è sicuro sparisce dalla lista. Quello che va ancora storto resta.';

  @override
  String get filterPerfectedTitle => 'Solo con 3 stelle e 3 fulmini';

  @override
  String get filterPerfectedText =>
      'Sparisce solo ciò che è sicuro **e** veloce. Quello senza errori ma ancora lento resta da esercitare.';

  @override
  String get rangeAll => 'Tutto';

  @override
  String get rangeToday => 'Oggi';

  @override
  String get rangeWeek => '7 giorni';

  @override
  String get rangeMonth => '30 giorni';

  @override
  String get rangeAllPhrase => 'dell’intero registro';

  @override
  String get rangeTodayPhrase => 'di oggi';

  @override
  String get rangeWeekPhrase => 'degli ultimi 7 giorni';

  @override
  String get rangeMonthPhrase => 'degli ultimi 30 giorni';

  @override
  String get backupErrorNotABackup =>
      'Il file non è una copia di sicurezza valida.';

  @override
  String get backupErrorWrongApp =>
      'Questo file non proviene da Mathe-Trainer.';

  @override
  String get backupErrorTooNew =>
      'La copia di sicurezza proviene da una versione più recente dell’app.';

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
  String get relativeToday => 'oggi';

  @override
  String get relativeYesterday => 'ieri';

  @override
  String relativeDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni fa',
      one: '1 giorno fa',
    );
    return '$_temp0';
  }

  @override
  String remainingMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'ancora $minutes minuti',
      one: 'ancora 1 minuto',
      zero: 'tra poco',
    );
    return '$_temp0';
  }

  @override
  String moneyAmount(String amount) {
    return '$amount €';
  }

  @override
  String moneyCoinCents(int n) {
    return '$n cent';
  }

  @override
  String moneyCoinEuros(int n) {
    return '$n €';
  }

  @override
  String get deadlineToday => 'oggi';

  @override
  String get deadlineUntilSunday => 'fino a domenica';

  @override
  String get deadlineStillOpen => 'ancora aperto';

  @override
  String deadlineWas(String day) {
    return 'era $day';
  }

  @override
  String get deadlineThisWeek => 'questa settimana';

  @override
  String deadlineFrom(String day) {
    return 'da $day';
  }

  @override
  String deadlineOn(String day) {
    return 'il $day';
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
  String get formatClockPattern => 'H:mm';

  @override
  String get formatLogTimePattern => 'HH:mm';
}
