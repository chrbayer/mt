// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Mathe-Trainer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String commonMinutesShort(int n) {
    return '$n min';
  }

  @override
  String versionLabel(String version) {
    return 'Version $version';
  }

  @override
  String get loadFailureMessage => 'Impossible de charger pour le moment.';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsTaskCountHeading => 'Calculs par série';

  @override
  String get settingsParentAreaNote =>
      'Horloge et vibration, réglage pour tous, suppression des résultats, gestion des profils et journal d’entraînement : tout cela se trouve dans l’espace parents de l’écran d’accueil, protégé par le code PIN.';

  @override
  String get amountNoLimit => 'sans limite';

  @override
  String get amountSameAsAll => 'comme pour tous';

  @override
  String amountSameAsAllWith(String value) {
    return 'comme pour tous ($value)';
  }

  @override
  String get taskCountSameEverywhere => 'partout pareil';

  @override
  String taskCountSameEverywhereWith(int count) {
    return 'partout pareil ($count)';
  }

  @override
  String get taskCountExplanationProfile =>
      'Le plus précis l’emporte : d’abord une mission en cours, puis le dernier choix pour une leçon, puis ce réglage, puis le réglage pour tous.';

  @override
  String get taskCountExplanationGlobal =>
      'Le plus précis l’emporte : d’abord une mission en cours, puis le dernier choix pour une leçon, puis le réglage du profil, puis ce réglage.';

  @override
  String get soundTestRunning => 'Lecture en cours …';

  @override
  String get soundTestButton => 'Tester le son (10 clics)';

  @override
  String soundTestAllPlayed(int played, int expected) {
    return '$played clics sur $expected joués. Si tu n’as rien entendu, vérifie le volume de l’appareil.';
  }

  @override
  String soundTestSomePlayed(int played, int expected) {
    return 'Seulement $played clics sur $expected joués – le son se coupe sur cet appareil.';
  }

  @override
  String soundTestUnavailable(String error) {
    return 'Le son n’est pas disponible sur cet appareil :\n$error';
  }

  @override
  String get recommendShaky => 'C’était fragile la dernière fois';

  @override
  String get recommendFresh => 'Tu n’as encore jamais fait ça';

  @override
  String get recommendStale => 'Pas fait depuis longtemps';

  @override
  String get pauseDayDoneTitle => 'C’est assez pour aujourd’hui !';

  @override
  String pauseDayDoneText(int minutes) {
    return 'Tu as fait $minutes minutes de maths aujourd’hui. On continue demain.';
  }

  @override
  String get pauseBreakTitle => 'C’est l’heure de la pause !';

  @override
  String pauseBreakText(int minutes, String clock, String left) {
    return 'Tu as calculé $minutes minutes d’affilée. On reprend à $clock – $left.';
  }

  @override
  String pauseClock(String time) {
    return '$time';
  }

  @override
  String get runHintTooShort =>
      'Ne compte pas : ni étoiles, ni éclairs, ni classement.';

  @override
  String runHintUsedUpToday(int count) {
    return 'Déjà compté $count fois aujourd’hui – tu peux continuer, mais ça ne comptera plus.';
  }

  @override
  String runHintRemaining(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Encore $minutes minutes, puis une pause.',
      one: 'Encore une minute, puis une pause.',
      zero: 'Une pause arrive.',
    );
    return '$_temp0';
  }

  @override
  String get assignmentGoalDone => 'Mission accomplie !';

  @override
  String assignmentGoalCounts(int done, int runs) {
    return 'Compte pour ta mission : $done sur $runs';
  }

  @override
  String get assignmentGoalNotEnough =>
      'Ça ne suffit pas encore pour ta mission :';

  @override
  String get assignmentTileDone => 'fait';

  @override
  String get todayHeading => 'Entraînement du jour';

  @override
  String get todayNothingYet => 'encore rien';

  @override
  String todayNothingOfLimit(int limit) {
    return 'encore rien sur $limit min';
  }

  @override
  String todayTimeOfLimit(String time, int limit) {
    return '$time sur $limit min';
  }

  @override
  String get progressChartEmpty =>
      'À partir de ta deuxième série, ta courbe de progrès apparaît ici.';

  @override
  String starRowEarnedOf(int earned, int possible) {
    return '$earned sur $possible';
  }

  @override
  String get adminSessionClosed => 'Espace parents fermé.';

  @override
  String get taskClock24Question =>
      'Quelle heure est-il ? Utilise l’horloge de 24 heures.';

  @override
  String get backupShareSubject => 'Sauvegarde Mathe-Trainer';

  @override
  String backupExportFailed(String error) {
    return 'Échec de la sauvegarde : $error';
  }

  @override
  String get backupImportConfirmTitle => 'Restaurer la sauvegarde ?';

  @override
  String get backupImportConfirmText =>
      'Tous les profils et résultats de cet appareil seront remplacés par la sauvegarde. Ce qui s’y trouve maintenant sera perdu.';

  @override
  String get backupReplace => 'Remplacer';

  @override
  String get backupFileTypeLabel => 'Sauvegarde';

  @override
  String backupImported(int users, int sessions) {
    return '$users profils et $sessions séries restaurés.';
  }

  @override
  String backupImportFailed(String error) {
    return 'Échec de la restauration : $error';
  }

  @override
  String get backupHeading => 'Données';

  @override
  String get backupIntro =>
      'Tous les profils, résultats et réglages dans un fichier. Garde-le ailleurs que sur la tablette – un appareil réinitialisé emporte tout avec lui.';

  @override
  String get backupCreate => 'Créer une sauvegarde';

  @override
  String get backupRestore => 'Restaurer une sauvegarde';

  @override
  String get backupNever => 'Jamais sauvegardé.';

  @override
  String backupLast(String when) {
    return 'Dernière sauvegarde : $when.';
  }

  @override
  String backupLastOverdue(String when) {
    return 'Dernière sauvegarde : $when. C’était il y a un moment.';
  }

  @override
  String get pinTitleVerify => 'Espace parents';

  @override
  String get pinTitleSetup => 'Configurer l’espace parents';

  @override
  String get pinHintEnter => 'Saisir le code PIN';

  @override
  String pinHintChoose(int length) {
    return 'Choisir un code PIN de $length chiffres';
  }

  @override
  String get pinHintRepeat => 'Répéter le code PIN';

  @override
  String get pinWrong => 'Code PIN incorrect.';

  @override
  String get pinMismatch => 'Les deux saisies étaient différentes.';

  @override
  String get startWhatDoesItMean => 'Qu’est-ce que ça veut dire ?';

  @override
  String startExample(String example) {
    return 'Par exemple :  $example';
  }

  @override
  String startAssignmentGoal(int count) {
    return 'Pour ta mission : $count calculs';
  }

  @override
  String get startHowMany => 'Combien de calculs ?';

  @override
  String startBoltsFrom(String time) {
    return 'dès $time par calcul';
  }

  @override
  String get startGo => 'C’est parti';

  @override
  String get startLeaderboard => 'Classement';

  @override
  String get commonPerTask => 'par calcul';

  @override
  String get commonErrors => 'Erreurs';

  @override
  String get commonTasks => 'Calculs';

  @override
  String leaderboardTitle(String lesson) {
    return 'Classement · $lesson';
  }

  @override
  String leaderboardEmpty(int min) {
    return 'Pas encore de résultat.\nAu moins $min calculs comptent pour le classement.';
  }

  @override
  String leaderboardScoreExplanation(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds secondes',
      one: '1 seconde',
    );
    return 'Le score est le temps par calcul, plus $_temp0 par mauvaise réponse. Deviner ne rapporte donc rien, et les séries de longueurs différentes restent comparables.';
  }

  @override
  String statsTitle(String name) {
    return 'Statistiques · $name';
  }

  @override
  String get statsEmpty => 'Pas encore de série terminée.';

  @override
  String statsLearningCurve(String lesson) {
    return 'Courbe de progrès · $lesson';
  }

  @override
  String get statsLearningCurveSub => 'Secondes par calcul, série après série';

  @override
  String get statsHardest => 'Ces calculs prennent le plus de temps';

  @override
  String get statsHeadStars => 'Étoiles';

  @override
  String get statsHeadBest => 'Record';

  @override
  String get statsHeadAverage => 'Ø temps';

  @override
  String get statsHeadRuns => 'Séries';

  @override
  String get statsTooFewData => 'Pas encore assez de données.';

  @override
  String get globalStatsTitle => 'Tous les résultats';

  @override
  String get globalStatsTabOverview => 'Aperçu';

  @override
  String get globalStatsTabLeaderboards => 'Classements';

  @override
  String get globalStatsNoProfiles => 'Pas encore de profil.';

  @override
  String globalStatsActivityHeading(int days) {
    return 'Entraînement des $days derniers jours';
  }

  @override
  String get globalStatsActivitySub =>
      'Minutes par jour, chaque enfant dans sa couleur';

  @override
  String globalStatsNoLeaderboards(int min) {
    return 'Pas encore de classement.\nUne série compte à partir de $min calculs.';
  }

  @override
  String get globalStatsNotPlayed => 'Pas encore entraîné.';

  @override
  String globalStatsRounds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'séries',
      one: 'série',
    );
    return '$_temp0';
  }

  @override
  String get globalStatsPractised => 'd’entraînement';

  @override
  String globalStatsStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return '$_temp0 de suite';
  }

  @override
  String globalStatsLastPlayed(String when) {
    return 'dernier : $when';
  }

  @override
  String get globalStatsNoActivity =>
      'Personne ne s’est entraîné ces dernières semaines.';

  @override
  String get profilesTitle => 'Qui joue ?';

  @override
  String get profilesAllResults => 'Tous les résultats';

  @override
  String get profilesDuel => 'Duel';

  @override
  String get profilesParents => 'Parents';

  @override
  String get profilesNone =>
      'Pas encore de profil. Appuie sur « Nouveau » pour commencer.';

  @override
  String profilesLockedTitle(String name) {
    return '$name fait une pause';
  }

  @override
  String get profilesLockedText =>
      'Ce profil est bloqué pour le moment. Toutes les étoiles, tous les éclairs et tous les records sont conservés – ils reviennent dès que les parents le débloquent.';

  @override
  String get profilesLockedOk => 'Compris';

  @override
  String get profilesAllDone => 'tout est fait';

  @override
  String profilesTodo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count missions',
      one: '1 mission',
    );
    return '$_temp0';
  }

  @override
  String get profilesEditLook => 'Changer l’image et la couleur';

  @override
  String get profilesNew => 'Nouveau';

  @override
  String get profileEditorNew => 'Nouveau profil';

  @override
  String get profileEditorChangeName => 'Changer le prénom';

  @override
  String get profileEditorNameLabel => 'Prénom';

  @override
  String get profileEditorNext => 'Suivant';

  @override
  String get profileEditorLookTitle => 'Image et couleur';

  @override
  String get profileEditorPicture => 'Image';

  @override
  String get profileEditorColor => 'Couleur';

  @override
  String get profileEditorSave => 'Enregistrer';

  @override
  String get duelTitle => 'Duel';

  @override
  String get duelNeedTwoProfiles => 'Un duel demande au moins deux profils.';

  @override
  String get duelWhoPlays => 'Qui joue ?';

  @override
  String duelPlayerLocked(String avatar, String name) {
    return '$avatar  $name · bloqué';
  }

  @override
  String duelPlayerOnBreak(String avatar, String name) {
    return '$avatar  $name · pause';
  }

  @override
  String duelPlayer(String avatar, String name) {
    return '$avatar  $name';
  }

  @override
  String get duelWhichTasks => 'Quels calculs ?';

  @override
  String get duelPickTwo => 'Choisis au moins deux enfants.';

  @override
  String duelLessonChip(String title, String example) {
    return '$title  ·  $example';
  }

  @override
  String get duelStart => 'Lancer le duel';

  @override
  String duelPosition(int position, int total) {
    return '$position sur $total';
  }

  @override
  String duelYourTurn(String name) {
    return 'Au tour de $name';
  }

  @override
  String duelLessonAndGroup(String lesson, String group) {
    return '$lesson · $group';
  }

  @override
  String get duelReady => 'Prêt';

  @override
  String get duelAbort => 'Arrêter le duel';

  @override
  String duelResultTitle(String lesson) {
    return 'Duel · $lesson';
  }

  @override
  String get duelSameTasks => 'Tout le monde a eu les mêmes calculs.';

  @override
  String get duelDone => 'Terminé';

  @override
  String get duelWin => 'Gagné !';

  @override
  String get commonBackToLessons => 'Retour aux leçons';

  @override
  String get resultDone => 'Bravo !';

  @override
  String resultDoneName(String name) {
    return 'Bravo, $name !';
  }

  @override
  String resultNextBolt(int n, String time) {
    return 'Éclair $n dès $time par calcul';
  }

  @override
  String get resultForThisLesson => 'pour cette leçon';

  @override
  String get resultInTotal => 'au total';

  @override
  String get resultMetricTasks => 'Calculs';

  @override
  String get resultMetricTotalTime => 'Temps total';

  @override
  String get resultMetricPerTask => 'Par calcul';

  @override
  String get resultMetricErrors => 'Erreurs';

  @override
  String resultPenalty(String penalty, int count, int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mauvaises réponses',
      one: '1 mauvaise réponse',
    );
    String _temp1 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds secondes',
      one: '1 seconde',
    );
    return 'Cela comprend une pénalité de $penalty pour $_temp0 – $_temp1 chacune.';
  }

  @override
  String resultStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '1 jour',
    );
    return '$_temp0 d’entraînement de suite !';
  }

  @override
  String get resultAgain => 'Encore';

  @override
  String get resultLeaderboard => 'Classement';

  @override
  String get resultOtherLesson => 'Autre leçon';

  @override
  String get resultFirstRun =>
      'C’était ta première série ici –\nce temps est ton record à partir de maintenant.';

  @override
  String get resultSameSpeed => 'Exactement aussi vite que la dernière fois.';

  @override
  String resultFaster(String delta) {
    return '$delta plus vite par calcul que la dernière fois !';
  }

  @override
  String resultSlower(String delta) {
    return '$delta plus lent par calcul que la dernière fois.';
  }

  @override
  String get practiceAbortTitle => 'Arrêter l’entraînement ?';

  @override
  String get practiceAbortText =>
      'Cette série ne comptera pas pour le classement.';

  @override
  String get practiceKeepGoing => 'Continuer';

  @override
  String get practiceAbortConfirm => 'Arrêter';

  @override
  String get practiceAbortTooltip => 'Arrêter l’entraînement';

  @override
  String get practicePause => 'Pause';

  @override
  String get practicePauseNote => 'Le chrono est arrêté.';

  @override
  String get practiceResume => 'Continuer';

  @override
  String get lessonsFilterTooltip => 'Masquer les leçons terminées';

  @override
  String get lessonsHideDoneAssignments => 'Masquer les missions accomplies';

  @override
  String get lessonsStatsLabel => 'Stats';

  @override
  String get lessonsSettingsTooltip => 'Réglages';

  @override
  String get lessonsSwitchLabel => 'Changer';

  @override
  String get lessonsNoGroup =>
      'Aucun domaine n’est débloqué pour ce profil.\nCela se change dans l’espace parents.';

  @override
  String get lessonsNothingLeftTitle => 'Tout est fait !';

  @override
  String get lessonsNothingLeftText =>
      'Ce que tu sais faire est masqué pour l’instant. Le filtre en haut ramène tout le catalogue.';

  @override
  String get lessonsRecommendGo => 'Go';

  @override
  String lessonsRecommendTitle(String lesson, String group) {
    return '$lesson · $group';
  }

  @override
  String get lessonsAssignmentsHeading => 'Tes missions';

  @override
  String get lessonsAssignmentsAllDone =>
      'Tout est fait ! Les missions accomplies sont masquées.';

  @override
  String get lessonsNotPractised => 'pas encore fait';

  @override
  String lessonsPractisedTimes(int count) {
    return 'fait $count fois';
  }

  @override
  String get adminTitle => 'Espace parents';

  @override
  String get adminTabHistory => 'Journal';

  @override
  String get adminTabManagement => 'Gérer';

  @override
  String get adminTabAssignments => 'Missions';

  @override
  String get adminTabSettings => 'Réglages';

  @override
  String get adminFilterAll => 'Tous';

  @override
  String get adminShowDeleted => 'Supprimées';

  @override
  String adminHistoryTruncated(int limit) {
    return 'Les $limit dernières séries sont affichées. Une période plus courte montre le reste.';
  }

  @override
  String adminCleanupAll(int count) {
    return 'Nettoyer les séries abandonnées ($count)';
  }

  @override
  String adminCleanupOne(String name, int count) {
    return 'Nettoyer les séries abandonnées de $name ($count)';
  }

  @override
  String get adminHistoryEmpty => 'Pas encore de série.';

  @override
  String get adminDeleteRunTitle => 'Supprimer cette série ?';

  @override
  String adminDeleteRunText(String user, String lesson, String when) {
    return '$user · $lesson · $when';
  }

  @override
  String get adminRunDeleted => 'Série supprimée.';

  @override
  String get adminUndo => 'Annuler';

  @override
  String get adminThisChild => 'de cet enfant';

  @override
  String get adminWhoAll => 'de tous les enfants';

  @override
  String adminWhoOne(String name) {
    return 'de $name';
  }

  @override
  String adminCleanupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nettoyer $count séries abandonnées ?',
      one: 'Nettoyer une série abandonnée ?',
    );
    return '$_temp0';
  }

  @override
  String adminCleanupText(String whose, String range) {
    return 'Les séries abandonnées $whose $range vont disparaître. Elles n’ont jamais compté pour les étoiles, les éclairs ni un classement – le temps d’entraînement reste compté.';
  }

  @override
  String get adminCleanupConfirm => 'Nettoyer';

  @override
  String adminCleanedUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séries abandonnées nettoyées.',
      one: 'Une série abandonnée nettoyée.',
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
      other: '$count calculs',
      one: '1 calcul',
    );
    return 'abandonnée après $_temp0';
  }

  @override
  String get adminRestore => 'Rétablir';

  @override
  String get adminDeleteRun => 'Supprimer la série';

  @override
  String get adminProfiles => 'Profils';

  @override
  String get adminNewProfile => 'Nouveau profil';

  @override
  String get adminProfilesNote =>
      'Un appui sur un enfant ouvre tout ce qui le concerne : domaines, durées, blocage, renommer et supprimer. Chaque enfant peut changer lui-même son image et sa couleur sur l’écran d’accueil.';

  @override
  String get adminPinHeading => 'Code PIN';

  @override
  String get adminPinNote =>
      'Protège cet espace. Oublié ? Alors la seule issue est d’effacer les données de l’application dans les réglages Android – ce qui supprime aussi tous les résultats.';

  @override
  String get adminChangePin => 'Changer le code PIN';

  @override
  String get adminGroupsNone => 'Aucun domaine débloqué';

  @override
  String get adminGroupsAll => 'Tous les domaines';

  @override
  String adminGroupsSome(int n, int total) {
    return '$n domaines sur $total';
  }

  @override
  String get adminLocked => 'Bloqué';

  @override
  String get adminNoReview => 'sans révision';

  @override
  String get profileSettingsDiscardTitle => 'Abandonner les modifications ?';

  @override
  String profileSettingsDiscardText(String name) {
    return 'Les réglages de $name ont été modifiés mais pas encore enregistrés.';
  }

  @override
  String get profileSettingsDiscard => 'Abandonner';

  @override
  String get profileSettingsSave => 'Enregistrer';

  @override
  String get profileSettingsSectionPractice => 'Entraînement';

  @override
  String get profileSettingsGroups => 'Domaines';

  @override
  String get profileSettingsGroupsNote =>
      'Les domaines désactivés n’apparaissent plus dans l’écran d’entraînement. Les résultats déjà obtenus sont conservés.';

  @override
  String get profileSettingsNoGroup =>
      'Sans aucun domaine, l’enfant ne peut pas s’entraîner.';

  @override
  String get profileSettingsHideDoneHeading => 'Masquer les leçons terminées';

  @override
  String get profileSettingsHideDoneNote =>
      'Allège le catalogue de ce qui est déjà acquis. L’enfant peut aussi le changer sur l’écran d’entraînement – c’est ici pour le régler une fois pour toutes. Le niveau le plus strict laisse les Premiers pas en place : rien n’y est chronométré, il n’y a donc pas d’éclairs à gagner.';

  @override
  String get profileSettingsHideDoneAssignments =>
      'Masquer les missions accomplies';

  @override
  String get profileSettingsHideDoneAssignmentsNote =>
      'Les cartes terminées disparaissent avant la fin du jour ou de la semaine. Sinon elles restent là, cochées.';

  @override
  String get profileSettingsTaskCount => 'Calculs par série';

  @override
  String get profileSettingsReview => 'Répéter les calculs difficiles';

  @override
  String get profileSettingsReviewNote =>
      'Un quart de chaque série est composé de ce qui a pris du temps ou raté la dernière fois.';

  @override
  String get profileSettingsSectionTime => 'Temps et score';

  @override
  String get profileSettingsStretch => 'Temps d’entraînement d’affilée';

  @override
  String get profileSettingsStretchNote =>
      'Après ce temps, il y a une pause. Une série en cours n’est jamais interrompue – seul le prochain départ est bloqué. Le temps continue de compter tant que la pause n’a pas été prise en entier.';

  @override
  String get profileSettingsBreakLength => 'Durée de la pause';

  @override
  String get profileSettingsDaily => 'Et par jour au total';

  @override
  String get profileSettingsDailyNote =>
      'Additionne toutes les séries du jour, pauses ou non. Une fois le temps épuisé, on reprend le lendemain.';

  @override
  String get profileSettingsScoredRuns =>
      'Séries comptées par leçon et par jour';

  @override
  String get profileSettingsScoredRunsNote =>
      'Ensuite, la même leçon peut encore être travaillée, mais elle ne rapporte plus ni record, ni étoiles, ni éclairs. Le temps d’entraînement et le journal continuent de compter.';

  @override
  String get profileSettingsSectionTidy => 'Ranger';

  @override
  String get profileSettingsTidyNote =>
      'Ces boutons agissent tout de suite – ils n’attendent pas « Enregistrer ».';

  @override
  String get profileSettingsRename => 'Renommer';

  @override
  String get profileSettingsGiveBackStars => 'Rendre des étoiles …';

  @override
  String get profileSettingsResetResults => 'Supprimer les résultats';

  @override
  String get profileSettingsDeleteProfile => 'Supprimer le profil';

  @override
  String profileSettingsResetTitle(String name) {
    return 'Supprimer les résultats de $name ?';
  }

  @override
  String get profileSettingsResetText =>
      'Les records, la courbe de progrès et le journal sont perdus. Le profil reste.';

  @override
  String profileSettingsDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get profileSettingsDeleteText =>
      'Le profil et tous les résultats sont supprimés.';

  @override
  String profileSettingsGroupSummary(int count, String example) {
    return '$count leçons · p. ex. $example';
  }

  @override
  String get profileSettingsLockTitle => 'Bloquer le profil pour l’instant';

  @override
  String get profileSettingsLockNote =>
      'Le profil ne peut alors plus être ouvert ni invité à un duel. Rien n’est perdu : étoiles, éclairs et records reviennent inchangés après le déblocage.';

  @override
  String get globalSettingsClock => 'Afficher le chrono pendant l’entraînement';

  @override
  String get globalSettingsClockNote =>
      'Le temps est toujours mesuré. Mais le voir rend certains enfants nerveux – c’est pourquoi il est désactivé par défaut.';

  @override
  String get globalSettingsHaptics => 'Vibrer à chaque touche';

  @override
  String get globalSettingsHapticsNote =>
      'Une courte vibration à chaque appui sur une touche.';

  @override
  String get globalSettingsSounds => 'Jouer des sons';

  @override
  String get globalSettingsSoundsNote =>
      'Un court son pour juste, un autre pour faux, et un léger clic sous chaque touche. Sur une tablette posée à plat, on sent à peine la vibration.';

  @override
  String get globalSettingsTaskCount => 'Calculs par série pour tous';

  @override
  String get globalSettingsTaskCountNote =>
      'Pour un seul enfant, le réglage se trouve sous « Gérer », dans son profil – et l’enfant peut le changer dans ses propres réglages.';

  @override
  String get globalSettingsLimits => 'Temps d’entraînement pour tous';

  @override
  String get globalSettingsLimitsNote =>
      'S’applique à chaque enfant sans réglage propre. Une série en cours n’est jamais interrompue – seul le prochain départ est bloqué.';

  @override
  String get globalSettingsStretch => 'D’affilée, puis une pause';

  @override
  String get globalSettingsBreakLength => 'Durée de la pause';

  @override
  String get globalSettingsDaily => 'Et par jour au total';

  @override
  String get globalSettingsScoredRuns =>
      'Séries comptées par leçon et par jour';

  @override
  String get globalSettingsScoredRunsNote =>
      'Ensuite, la même leçon peut encore être travaillée, mais elle ne rapporte plus ni record, ni étoiles, ni éclairs. Cela ôte l’intérêt de répéter la leçon la plus facile jusqu’à ce que le temps soit bon. Le temps d’entraînement et le journal continuent de compter.';

  @override
  String resetStarsTitle(String group) {
    return 'Remettre à zéro les étoiles de « $group » ?';
  }

  @override
  String resetStarsText(String name) {
    return '$name pourra les regagner ensuite. Records, éclairs, courbe de progrès et classements restent inchangés – seules les étoiles de ce domaine sont concernées.';
  }

  @override
  String get resetStarsConfirm => 'Remettre à zéro';

  @override
  String resetStarsHeading(String name) {
    return 'Étoiles de $name';
  }

  @override
  String get resetStarsNote =>
      'Seules les étoiles sont remises à zéro. Les temps restent – records, éclairs, courbe de progrès et classements sont exactement comme avant.';

  @override
  String get resetStarsDone => 'Terminé';

  @override
  String resetStarsGroupLine(int earned, int possible) {
    return '$earned étoiles sur $possible';
  }

  @override
  String get assignmentsAll => 'Toutes';

  @override
  String get assignmentsNew => 'Nouvelle mission';

  @override
  String get assignmentsHideFinished => 'Masquer les accomplies';

  @override
  String assignmentsHiddenCount(int count) {
    return '$count masquées';
  }

  @override
  String get assignmentsEmpty => 'Pas encore de mission.';

  @override
  String get assignmentsNoneOpen =>
      'Aucune mission en cours. Les accomplies sont masquées.';

  @override
  String get assignmentsDaily => 'quotidienne';

  @override
  String get assignmentsWeekly => 'hebdomadaire';

  @override
  String get assignmentsCarriesOver => 'reportée';

  @override
  String assignmentsLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count leçons',
      one: '1 leçon',
    );
    return '$_temp0';
  }

  @override
  String get assignmentsEdit => 'Modifier';

  @override
  String get assignmentsEnd => 'Terminer';

  @override
  String get assignmentsRepeat => 'Redonner';

  @override
  String get assignmentsDelete => 'Supprimer la mission';

  @override
  String assignmentsRunsOfTasks(int runs, int tasks) {
    return '$runs× $tasks calculs';
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
  String get assignmentsNoClosedPeriod => 'Pas encore de période terminée';

  @override
  String assignmentsMetOf(int met, int total, String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'daily': 'jours',
      'weekly': 'semaines',
      'other': 'semaines',
    });
    return 'Réussi $met fois sur $total $_temp0';
  }

  @override
  String assignmentsBefore(int met, int total, String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'daily': 'jours',
      'weekly': 'semaines',
      'other': 'semaines',
    });
    return 'avant : $met sur $total $_temp0';
  }

  @override
  String get assignmentsVerdictMet => 'Réussi';

  @override
  String get assignmentsVerdictPending => 'En cours';

  @override
  String get assignmentsVerdictLate => 'Manqué, rattrapé plus tard';

  @override
  String get assignmentsVerdictMissed => 'Manqué';

  @override
  String get editorTitleEdit => 'Modifier la mission';

  @override
  String get editorTitleAgain => 'Redonner la mission';

  @override
  String get editorTitleNew => 'Nouvelle mission';

  @override
  String get editorChild => 'Enfant';

  @override
  String get editorUnknownChild => 'Enfant inconnu';

  @override
  String get editorLessons => 'Leçons';

  @override
  String get editorLessonsNote =>
      'Plusieurs sont possibles. Chacune doit être réussie pour que la mission soit accomplie.';

  @override
  String get editorNoLesson => 'Sans aucune leçon, il n’y a rien à donner.';

  @override
  String get editorPeriod => 'Période';

  @override
  String get editorOneDay => 'un jour';

  @override
  String get editorOneWeek => 'une semaine';

  @override
  String get editorRepetition => 'Répéter';

  @override
  String get editorEveryTime => 'à chaque fois';

  @override
  String get editorOnce => 'une fois';

  @override
  String get editorDailyNote => 'Nouvelle chaque jour, à rendre le soir.';

  @override
  String get editorWeeklyNote =>
      'Nouvelle chaque semaine, à rendre le dimanche soir.';

  @override
  String editorOnDay(String day) {
    return 'Le $day';
  }

  @override
  String editorInWeek(String day) {
    return 'Semaine du $day';
  }

  @override
  String get editorPickDay => 'Choisir un jour …';

  @override
  String get editorCarryOver => 'Reporter si non faite';

  @override
  String get editorCarryOverNote =>
      'La mission reste alors jusqu’à ce qu’elle soit faite. Le jour compte quand même comme manqué – les statistiques disent quand on s’est entraîné, pas ce qui était prévu.';

  @override
  String get editorRuns => 'Séries';

  @override
  String get editorTasksPerRun => 'Calculs par série';

  @override
  String get editorMinStars => 'Étoiles minimum';

  @override
  String get editorMinBolts => 'Éclairs minimum';

  @override
  String get editorNoRequirement => 'aucune exigence';

  @override
  String get editorSave => 'Enregistrer';

  @override
  String get editorCreate => 'Créer';

  @override
  String get groupFirstSteps => 'Premiers pas';

  @override
  String get groupUpTo10 => 'Jusqu’à 10';

  @override
  String get groupUpTo20 => 'Jusqu’à 20';

  @override
  String get groupUpTo100 => 'Jusqu’à 100';

  @override
  String get groupUpTo1000 => 'Jusqu’à 1000';

  @override
  String get groupWithThousands => 'Avec les milliers';

  @override
  String get groupTimesTables => 'Tables de multiplication';

  @override
  String get groupReverseTimesTables => 'Tables à l’envers';

  @override
  String get groupTimesAndDivision => 'Multiplier et diviser';

  @override
  String get groupEveryday => 'Heure et argent';

  @override
  String get lessonAddPlainTitle => 'Plus sans passer la dizaine';

  @override
  String get lessonAddPlainBigTitle => 'Plus sans retenue';

  @override
  String get lessonAddPlainDesc =>
      'Les unités restent sous 10 ensemble – rien à retenir.';

  @override
  String get lessonAddPlainBigDesc =>
      'Aucune colonne ne déborde – ni les unités, ni les dizaines.';

  @override
  String get lessonAddCarryTitle => 'Plus en passant la dizaine';

  @override
  String get lessonAddCarryBigTitle => 'Plus avec retenue';

  @override
  String get lessonAddCarryDesc =>
      'Les unités font 10 ou plus – une dizaine passe à la colonne suivante.';

  @override
  String get lessonAddCarryBigDesc =>
      'Les unités ou les dizaines débordent – il faut retenir quelque chose.';

  @override
  String get lessonSubPlainTitle => 'Moins sans passer la dizaine';

  @override
  String get lessonSubPlainBigTitle => 'Moins sans retenue';

  @override
  String get lessonSubPlainDesc =>
      'Chaque chiffre du haut est assez grand – aucune dizaine à casser.';

  @override
  String get lessonSubPlainBigDesc =>
      'Chaque chiffre du haut est assez grand – rien à casser.';

  @override
  String get lessonSubBorrowTitle => 'Moins en passant la dizaine';

  @override
  String get lessonSubBorrowBigTitle => 'Moins avec retenue';

  @override
  String get lessonSubBorrowDesc =>
      'Les unités du haut ne suffisent pas – il faut casser une dizaine.';

  @override
  String get lessonSubBorrowBigDesc =>
      'Une colonne du haut ne suffit pas – il faut casser une dizaine ou une centaine.';

  @override
  String get lessonPlusGapTitle => 'Plus avec un nombre manquant';

  @override
  String get lessonMinusGapTitle => 'Moins avec un nombre manquant';

  @override
  String get lessonGapDesc =>
      'Trouve le nombre qui manque pour que le calcul soit juste.';

  @override
  String get lessonMixedTitle => 'Plus et moins mélangés';

  @override
  String get lessonMixedDesc =>
      'Plus et moins se suivent au hasard, avec et sans passage de dizaine.';

  @override
  String lessonTimesTableTitle(int n) {
    return 'Table de $n';
  }

  @override
  String lessonTimesTableDesc(int n) {
    return 'Tous les calculs de la table de $n, dans les deux sens : $n · 4 comme 4 · $n.';
  }

  @override
  String lessonReverseTableTitle(int n) {
    return 'Table de $n à l’envers';
  }

  @override
  String lessonReverseTableDesc(int n, int product) {
    return 'Divisé par $n. Chaque calcul est l’inverse d’un calcul de la table de $n : $n · 4 = $product devient $product : $n = 4.';
  }

  @override
  String get lessonPartnersOfTenTitle => 'Les compléments à 10';

  @override
  String get lessonPartnersOfTenDesc =>
      'Deux nombres sont complémentaires quand ils font exactement 10 ensemble : 1 et 9, 2 et 8, 3 et 7. On te le demande dans les deux sens – de 3 à 7 comme de 7 à 3.';

  @override
  String get lessonAdd10Title => 'Plus jusqu’à 10';

  @override
  String get lessonAdd10Desc => 'Additionner sans dépasser 10.';

  @override
  String get lessonSub10Title => 'Moins jusqu’à 10';

  @override
  String get lessonSub10Desc => 'Enlever dans les limites de 10.';

  @override
  String get lessonMix10Desc => 'Plus et moins se suivent au hasard.';

  @override
  String get lessonTimesAllTitle => 'Toutes les tables mélangées';

  @override
  String get lessonTimesAllDesc =>
      'Toute la petite table de multiplication, dans le désordre.';

  @override
  String get lessonDivPlainTitle => 'Toutes les tables à l’envers';

  @override
  String get lessonDivPlainDesc =>
      'Divisé par tout, dans le désordre. Chaque calcul tombe juste – c’est l’inverse d’un calcul de table de multiplication.';

  @override
  String get lessonDivRemainderTitle => 'Division avec reste';

  @override
  String get lessonDivRemainderDesc =>
      'Il reste toujours quelque chose. Entre d’abord le résultat, puis le reste.';

  @override
  String get lessonTimesGapTitle => 'Fois avec un nombre manquant';

  @override
  String get lessonTimesGapDesc =>
      'Par quel nombre faut-il multiplier pour que ce soit juste ?';

  @override
  String get lessonDivGapTitle => 'Diviser avec un nombre manquant';

  @override
  String get lessonDivGapDesc =>
      'Par quel nombre faut-il diviser pour que ce soit juste ?';

  @override
  String get lessonMulTensTitle => 'Fois avec des dizaines';

  @override
  String get lessonMulTensDesc =>
      'La table avec un zéro derrière : 3 · 4 = 12, donc 30 · 4 = 120.';

  @override
  String get lessonMulTwoDigitTitle => 'Fois au-delà des tables';

  @override
  String get lessonMulTwoDigitDesc =>
      'Multiplie un nombre à deux chiffres, par exemple 14 · 6.';

  @override
  String get lessonDivTwoDigitTitle => 'Diviser au-delà des tables';

  @override
  String get lessonDivTwoDigitDesc =>
      'Le résultat est plus grand que dix, par exemple 96 : 6.';

  @override
  String get lessonMulDivMixedTitle => 'Fois et divisé mélangés';

  @override
  String get lessonMulDivMixedDesc =>
      'Multiplier et diviser se suivent au hasard.';

  @override
  String get lessonPunktVorStrichTitle => 'Priorité des opérations';

  @override
  String get lessonPunktVorStrichDesc =>
      'Fois et divisé passent avant plus et moins – même quand ils viennent en dernier : dans 40 − 3 · 6, on calcule d’abord 3 · 6.';

  @override
  String get lessonCountPicturesTitle => 'Combien ? (en ligne)';

  @override
  String get lessonCountPicturesDesc =>
      'Compte les images, de un à cinq, bien alignées.';

  @override
  String get lessonCountPicturesCloudTitle => 'Combien ? (en désordre)';

  @override
  String get lessonCountPicturesCloudDesc =>
      'Les mêmes images, mais dans le désordre – il faut se souvenir de ce qu’on a déjà compté.';

  @override
  String get lessonCountDiceTitle => 'Combien de points ?';

  @override
  String get lessonCountDiceDesc =>
      'Un dé. Bientôt tu verras le nombre sans compter.';

  @override
  String get lessonCompareMoreTitle => 'Où y en a-t-il plus ? (en ligne)';

  @override
  String get lessonCompareMoreDesc =>
      'Compare deux groupes et entre le plus grand nombre.';

  @override
  String get lessonCompareMoreCloudTitle =>
      'Où y en a-t-il plus ? (en désordre)';

  @override
  String get lessonCompareMoreCloudDesc =>
      'Pareil, mais les images sont dans le désordre.';

  @override
  String get lessonCountNextTitle => 'Quel nombre vient ensuite ?';

  @override
  String get lessonCountNextDesc =>
      'La file des nombres, en avant et en arrière.';

  @override
  String get lessonBeesAddTitle => 'Petites abeilles (en ligne)';

  @override
  String get lessonBeesAddDesc =>
      'Additionne deux petits groupes d’abeilles ; jamais plus de dix en tout.';

  @override
  String get lessonBeesAddCloudTitle => 'Petites abeilles (en désordre)';

  @override
  String get lessonBeesAddCloudDesc =>
      'Le même calcul, mais les abeilles bourdonnent dans tous les sens.';

  @override
  String get lessonDiceAddTitle => 'Additionner deux dés';

  @override
  String get lessonDiceAddDesc =>
      'Les deux dés montrent jusqu’à cinq points – combien y en a-t-il en tout ?';

  @override
  String get lessonAddToSixTitle => 'Plus jusqu’à 6';

  @override
  String get lessonAddToSixDesc => 'Additionner sans jamais dépasser six.';

  @override
  String get lessonSubToSixTitle => 'Moins jusqu’à 6';

  @override
  String get lessonSubToSixDesc => 'Enlever dans les limites de six.';

  @override
  String get lessonCalcToSixTitle => 'Plus et moins jusqu’à 6';

  @override
  String get lessonCalcToSixDesc =>
      'Les deux mélangés, sans jamais dépasser six.';

  @override
  String get lessonClockHalfTitle => 'Heures pleines et demi-heures';

  @override
  String get lessonClockHalfDesc =>
      'Quelle heure est-il ? La grande aiguille montre le 12 ou le 6.';

  @override
  String get lessonClockQuarterTitle => 'Quarts d’heure';

  @override
  String get lessonClockQuarterDesc =>
      'Et quart, et demie, moins le quart – la grande aiguille montre le 12, le 3, le 6 ou le 9.';

  @override
  String get lessonClockFiveTitle => 'L’heure à cinq minutes près';

  @override
  String get lessonClockFiveDesc =>
      'La grande aiguille montre l’un des douze nombres.';

  @override
  String get lessonClock24Title => 'L’heure sur 24 heures';

  @override
  String get lessonClock24Desc =>
      'L’après-midi, on continue à compter : 3 heures devient 15 h 00. Sous l’horloge, il est écrit quel moment de la journée c’est.';

  @override
  String get lessonClockWordsTitle => 'Dire l’heure';

  @override
  String get lessonClockWordsDesc =>
      'Comment dit-on l’heure ? Écris d’abord l’heure, puis touche l’expression – pour « 3 h et demie », c’est le 3.';

  @override
  String get lessonMoneyAddTitle => 'Additionner de l’argent';

  @override
  String get lessonMoneyAddDesc =>
      'Additionne deux montants. Entre d’abord les euros, puis les centimes.';

  @override
  String get lessonMoneySubTitle => 'Enlever de l’argent';

  @override
  String get lessonMoneySubDesc =>
      'Combien reste-t-il, ou combien te rend-on ?';

  @override
  String get lessonMoneyComposeTitle => 'Faire un montant';

  @override
  String get lessonMoneyComposeDesc =>
      'Fais le montant avec des pièces et des billets. Il y a beaucoup de bonnes façons – à la fin, le montant doit être exact.';

  @override
  String get lessonMoneyChangeTitle => 'Combien me rend-on ?';

  @override
  String get lessonMoneyChangeDesc =>
      'Quelque chose coûte un montant avec des centimes et tu paies avec un billet ou une pièce ronde. Tu dois trouver la monnaie.';

  @override
  String get lessonPlaceValue100Title => 'Unités et dizaines';

  @override
  String get lessonPlaceValue100Desc =>
      'Combien d’unités et de dizaines y a-t-il ? Quel nombre cela fait-il en tout ? Il peut y avoir plus de neuf unités.';

  @override
  String get lessonPlaceValue1000Title => 'Unités, dizaines, centaines';

  @override
  String get lessonPlaceValue1000Desc =>
      'Combien d’unités, de dizaines et de centaines y a-t-il ? Quel nombre cela fait-il en tout ? Il peut y en avoir plus de neuf d’une sorte.';

  @override
  String get lessonRoundThousandsTitle => 'Milliers entiers';

  @override
  String get lessonRoundThousandsDesc =>
      '3000 + 4000, 8000 − 5000 : calcule avec des milliers entiers. Si tu sais faire 3 + 4, tu sais faire ça aussi.';

  @override
  String get lessonRoundHundredsTitle => 'Centaines entières';

  @override
  String get lessonRoundHundredsDesc =>
      '2300 + 400, 5600 − 200 : calcule avec des centaines entières. Ici, on peut aussi dépasser mille.';

  @override
  String get lessonRoundGapTitle => 'Milliers et centaines : nombre manquant';

  @override
  String get lessonRoundGapDesc =>
      '3000 + ? = 7000. Que manque-t-il pour arriver au nombre ? Réfléchis à l’envers.';

  @override
  String get lessonPlaceValue10000Title =>
      'Unités, dizaines, centaines, milliers';

  @override
  String get lessonPlaceValue10000Desc =>
      'Combien d’unités, de dizaines, de centaines et de milliers y a-t-il ? Quel nombre cela fait-il en tout ? Il peut y en avoir plus de neuf d’une sorte.';

  @override
  String get lessonAddSub10000PlainTitle => 'Plus et moins sans retenue';

  @override
  String get lessonAddSub10000PlainDesc =>
      '4200 + 350, 6870 − 40 : des nombres à quatre chiffres, mais sans retenue. Une colonne après l’autre.';

  @override
  String taskQuestionPartner(int a) {
    return 'Quel nombre va avec $a pour faire 10 ?';
  }

  @override
  String get taskQuestionClock => 'Quelle heure est-il ?';

  @override
  String get taskQuestionClockPhrase => 'Comment dit-on ça ?';

  @override
  String taskQuestionMoneyCompose(String amount) {
    return 'Fais $amount – appuie sur les pièces et les billets.';
  }

  @override
  String taskQuestionChange(String price, String paid) {
    return 'Ça coûte $price. Tu paies $paid. Combien te rend-on ?';
  }

  @override
  String get taskQuestionQuantity => 'Combien ?';

  @override
  String get taskQuestionDiceOne => 'Combien de points ?';

  @override
  String get taskQuestionDiceTwo => 'Combien de points en tout ?';

  @override
  String get taskQuestionCompare =>
      'Où y en a-t-il plus ? Appuie sur le plus grand nombre.';

  @override
  String get taskQuestionSequence => 'Quel nombre vient ensuite ?';

  @override
  String get taskQuestionQuantityAdd => 'Combien en tout ?';

  @override
  String get taskQuestionPlaceValue => 'Quel est ce nombre ?';

  @override
  String get taskLabelRemainder => 'Reste';

  @override
  String get taskLabelEuro => '€';

  @override
  String get taskLabelClock => 'h';

  @override
  String get taskUnitCents => 'c';

  @override
  String placeOnes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n unités',
      one: '1 unité',
    );
    return '$_temp0';
  }

  @override
  String placeTens(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n dizaines',
      one: '1 dizaine',
    );
    return '$_temp0';
  }

  @override
  String placeHundreds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n centaines',
      one: '1 centaine',
    );
    return '$_temp0';
  }

  @override
  String placeThousands(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n milliers',
      one: '1 millier',
    );
    return '$_temp0';
  }

  @override
  String taskRenderRemainder(String prefix, String answer, String second) {
    return '$prefix $answer reste $second';
  }

  @override
  String taskRenderClock(int hour, String minute) {
    return '$hour h $minute';
  }

  @override
  String taskRenderChange(String price, String paid) {
    return '$price, payé avec $paid';
  }

  @override
  String taskRenderDiceOne(int a) {
    String _temp0 = intl.Intl.pluralLogic(
      a,
      locale: localeName,
      other: '$a points',
      one: '1 point',
    );
    return '$_temp0';
  }

  @override
  String taskRenderDiceTwo(int a, int b) {
    return '$a + $b points';
  }

  @override
  String get dayPartMorning => 'du matin';

  @override
  String get dayPartNoon => 'à midi';

  @override
  String get dayPartAfternoon => 'de l’après-midi';

  @override
  String get dayPartEvening => 'du soir';

  @override
  String get clockPhrase05 => 'h cinq';

  @override
  String get clockPhrase10 => 'h dix';

  @override
  String get clockPhrase15 => 'h et quart';

  @override
  String get clockPhrase20 => 'h vingt';

  @override
  String get clockPhrase25 => 'h vingt-cinq';

  @override
  String get clockPhrase30 => 'h et demie';

  @override
  String get clockPhrase35 => 'h moins vingt-cinq';

  @override
  String get clockPhrase40 => 'h moins vingt';

  @override
  String get clockPhrase45 => 'h moins le quart';

  @override
  String get clockPhrase50 => 'h moins dix';

  @override
  String get clockPhrase55 => 'h moins cinq';

  @override
  String clockSpokenTime(String phrase, int hour) {
    return '$hour $phrase';
  }

  @override
  String get filterAllTitle => 'Tout afficher';

  @override
  String get filterAllText => 'Tout le catalogue, rien n’est masqué.';

  @override
  String get filterMasteredTitle => 'Masquer à 3 étoiles';

  @override
  String get filterMasteredText =>
      'Ce qui est acquis disparaît de la liste. Ce qui pose encore problème reste.';

  @override
  String get filterPerfectedTitle => 'Seulement avec 3 étoiles et 3 éclairs';

  @override
  String get filterPerfectedText =>
      'Seul ce qui est acquis **et** rapide disparaît. Ce qui est sans erreur mais encore lent reste pour s’entraîner.';

  @override
  String get rangeAll => 'Tout';

  @override
  String get rangeToday => 'Aujourd’hui';

  @override
  String get rangeWeek => '7 jours';

  @override
  String get rangeMonth => '30 jours';

  @override
  String get rangeAllPhrase => 'de tout le journal';

  @override
  String get rangeTodayPhrase => 'd’aujourd’hui';

  @override
  String get rangeWeekPhrase => 'des 7 derniers jours';

  @override
  String get rangeMonthPhrase => 'des 30 derniers jours';

  @override
  String get backupErrorNotABackup =>
      'Ce fichier n’est pas une sauvegarde valide.';

  @override
  String get backupErrorWrongApp => 'Ce fichier ne vient pas de Mathe-Trainer.';

  @override
  String get backupErrorTooNew =>
      'La sauvegarde vient d’une version plus récente de l’application.';

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
  String get relativeToday => 'aujourd’hui';

  @override
  String get relativeYesterday => 'hier';

  @override
  String relativeDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'il y a $days jours',
      one: 'il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String remainingMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'encore $minutes minutes',
      one: 'encore 1 minute',
      zero: 'bientôt',
    );
    return '$_temp0';
  }

  @override
  String moneyAmount(String amount) {
    return '$amount €';
  }

  @override
  String moneyCoinCents(int n) {
    return '$n c';
  }

  @override
  String moneyCoinEuros(int n) {
    return '$n €';
  }

  @override
  String get deadlineToday => 'aujourd’hui';

  @override
  String get deadlineUntilSunday => 'jusqu’à dimanche';

  @override
  String get deadlineStillOpen => 'encore en cours';

  @override
  String deadlineWas(String day) {
    return 'c’était $day';
  }

  @override
  String get deadlineThisWeek => 'cette semaine';

  @override
  String deadlineFrom(String day) {
    return 'à partir de $day';
  }

  @override
  String deadlineOn(String day) {
    return 'le $day';
  }

  @override
  String commonSecondsShort(int n) {
    return '$n s';
  }

  @override
  String commonPercent(int n) {
    return '$n %';
  }

  @override
  String get formatClockPattern => 'H:mm';

  @override
  String get formatLogTimePattern => 'HH:mm';
}
