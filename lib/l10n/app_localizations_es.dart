// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Mathe-Trainer';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Borrar';

  @override
  String commonMinutesShort(int n) {
    return '$n min';
  }

  @override
  String versionLabel(String version) {
    return 'Versión $version';
  }

  @override
  String get loadFailureMessage => 'No se pudo cargar ahora mismo.';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsTaskCountHeading => 'Operaciones por ronda';

  @override
  String get settingsParentAreaNote =>
      'Reloj y vibración, el valor para todos, borrar resultados, gestionar perfiles y ver el historial de práctica: todo eso está en la zona de padres de la pantalla de inicio, protegida con el PIN.';

  @override
  String get amountNoLimit => 'sin límite';

  @override
  String get amountSameAsAll => 'como para todos';

  @override
  String amountSameAsAllWith(String value) {
    return 'como para todos ($value)';
  }

  @override
  String get taskCountSameEverywhere => 'como en todas partes';

  @override
  String taskCountSameEverywhereWith(int count) {
    return 'como en todas partes ($count)';
  }

  @override
  String get taskCountExplanationProfile =>
      'Vale siempre lo más concreto: primero una tarea abierta, si no, lo último elegido en una lección, si no, este ajuste, si no, el valor para todos.';

  @override
  String get taskCountExplanationGlobal =>
      'Vale siempre lo más concreto: primero una tarea abierta, si no, lo último elegido en una lección, si no, el valor del perfil, si no, este ajuste.';

  @override
  String get soundTestRunning => 'Sonando …';

  @override
  String get soundTestButton => 'Probar sonido (10 clics)';

  @override
  String soundTestAllPlayed(int played, int expected) {
    return 'Se reprodujeron $played de $expected clics. Si no oíste nada, revisa el volumen del dispositivo.';
  }

  @override
  String soundTestSomePlayed(int played, int expected) {
    return 'Solo se reprodujeron $played de $expected clics: el sonido se corta en este dispositivo.';
  }

  @override
  String soundTestUnavailable(String error) {
    return 'El sonido no está disponible en este dispositivo:\n$error';
  }

  @override
  String get recommendShaky => 'La última vez salió flojo';

  @override
  String get recommendFresh => 'Esto todavía no lo has practicado';

  @override
  String get recommendStale => 'Hace mucho que no lo practicas';

  @override
  String get pauseDayDoneTitle => '¡Por hoy es suficiente!';

  @override
  String pauseDayDoneText(int minutes) {
    return 'Hoy has calculado $minutes minutos. Mañana seguimos.';
  }

  @override
  String get pauseBreakTitle => '¡Descanso!';

  @override
  String pauseBreakText(int minutes, String clock, String left) {
    return 'Has practicado $minutes minutos seguidos. Seguimos a las $clock - $left.';
  }

  @override
  String pauseClock(String time) {
    return '$time';
  }

  @override
  String get runHintTooShort =>
      'No cuenta: sin estrellas, sin rayos, sin clasificación.';

  @override
  String runHintUsedUpToday(int count) {
    return 'Hoy ya contaron $count× - puedes seguir practicando, pero ya no cuenta.';
  }

  @override
  String runHintRemaining(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos más y toca descanso.',
      one: 'Un minuto más y toca descanso.',
      zero: 'Enseguida toca descanso.',
    );
    return '$_temp0';
  }

  @override
  String get assignmentGoalDone => '¡Tarea conseguida!';

  @override
  String assignmentGoalCounts(int done, int runs) {
    return 'Cuenta para tu tarea: $done de $runs';
  }

  @override
  String get assignmentGoalNotEnough => 'Para tu tarea todavía no basta:';

  @override
  String get assignmentTileDone => 'hecha';

  @override
  String get todayHeading => 'Practicado hoy';

  @override
  String get todayNothingYet => 'todavía nada';

  @override
  String todayNothingOfLimit(int limit) {
    return 'todavía nada de $limit min';
  }

  @override
  String todayTimeOfLimit(String time, int limit) {
    return '$time de $limit min';
  }

  @override
  String get progressChartEmpty =>
      'A partir de la segunda ronda verás aquí tu curva de aprendizaje.';

  @override
  String starRowEarnedOf(int earned, int possible) {
    return '$earned de $possible';
  }

  @override
  String get adminSessionClosed => 'Zona de padres cerrada.';

  @override
  String get taskClock24Question => '¿Qué hora es? Dila con 24 horas.';

  @override
  String get backupShareSubject => 'Copia de seguridad de Mathe-Trainer';

  @override
  String backupExportFailed(String error) {
    return 'Falló la copia de seguridad: $error';
  }

  @override
  String get backupImportConfirmTitle => '¿Restaurar la copia?';

  @override
  String get backupImportConfirmText =>
      'Todos los perfiles y resultados de este dispositivo se sustituirán por los de la copia. Lo que hay ahora desaparecerá.';

  @override
  String get backupReplace => 'Sustituir';

  @override
  String get backupFileTypeLabel => 'Copia de seguridad';

  @override
  String backupImported(int users, int sessions) {
    return 'Se restauraron $users perfiles y $sessions rondas.';
  }

  @override
  String backupImportFailed(String error) {
    return 'Falló la restauración: $error';
  }

  @override
  String get backupHeading => 'Datos';

  @override
  String get backupIntro =>
      'Todos los perfiles, resultados y ajustes en un archivo. Guárdalo fuera de la tableta: si se restablece el dispositivo, se pierde todo.';

  @override
  String get backupCreate => 'Crear copia';

  @override
  String get backupRestore => 'Restaurar copia';

  @override
  String get backupNever => 'Nunca se ha hecho una copia.';

  @override
  String backupLast(String when) {
    return 'Última copia: $when.';
  }

  @override
  String backupLastOverdue(String when) {
    return 'Última copia: $when. Hace ya bastante tiempo.';
  }

  @override
  String get pinTitleVerify => 'Zona de padres';

  @override
  String get pinTitleSetup => 'Configurar la zona de padres';

  @override
  String get pinHintEnter => 'Introduce el PIN';

  @override
  String pinHintChoose(int length) {
    return 'Elige un PIN de $length cifras';
  }

  @override
  String get pinHintRepeat => 'Repite el PIN';

  @override
  String get pinWrong => 'PIN incorrecto.';

  @override
  String get pinMismatch => 'Las dos entradas no coinciden.';

  @override
  String get startWhatDoesItMean => '¿Qué significa?';

  @override
  String startExample(String example) {
    return 'Por ejemplo:  $example';
  }

  @override
  String startAssignmentGoal(int count) {
    return 'Para tu tarea: $count operaciones';
  }

  @override
  String get startHowMany => '¿Cuántas operaciones?';

  @override
  String startBoltsFrom(String time) {
    return 'desde $time por operación';
  }

  @override
  String get startGo => '¡Vamos!';

  @override
  String get startLeaderboard => 'Clasificación';

  @override
  String get commonPerTask => 'por operación';

  @override
  String get commonErrors => 'Errores';

  @override
  String get commonTasks => 'Operaciones';

  @override
  String leaderboardTitle(String lesson) {
    return 'Clasificación · $lesson';
  }

  @override
  String leaderboardEmpty(int min) {
    return 'Todavía no hay resultados.\nPara la clasificación cuentan al menos $min operaciones.';
  }

  @override
  String leaderboardScoreExplanation(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds segundos',
      one: '1 segundo',
    );
    return 'Se puntúa el tiempo por operación, más $_temp0 por cada intento fallido. Así no compensa adivinar, y las rondas con distinto número de operaciones siguen siendo comparables.';
  }

  @override
  String statsTitle(String name) {
    return 'Estadísticas · $name';
  }

  @override
  String get statsEmpty => 'Todavía no hay rondas terminadas.';

  @override
  String statsLearningCurve(String lesson) {
    return 'Curva de aprendizaje · $lesson';
  }

  @override
  String get statsLearningCurveSub => 'Segundos por operación, ronda a ronda';

  @override
  String get statsHardest => 'Estas operaciones son las que más tardan';

  @override
  String get statsHeadStars => 'Estrellas';

  @override
  String get statsHeadBest => 'Mejor tiempo';

  @override
  String get statsHeadAverage => 'Ø tiempo';

  @override
  String get statsHeadRuns => 'Rondas';

  @override
  String get statsTooFewData => 'Todavía hay pocos datos.';

  @override
  String get globalStatsTitle => 'Todos los resultados';

  @override
  String get globalStatsTabOverview => 'Resumen';

  @override
  String get globalStatsTabLeaderboards => 'Clasificaciones';

  @override
  String get globalStatsNoProfiles => 'Todavía no hay perfiles.';

  @override
  String globalStatsActivityHeading(int days) {
    return 'Practicado en los últimos $days días';
  }

  @override
  String get globalStatsActivitySub =>
      'Minutos por día, cada niño con su color';

  @override
  String globalStatsNoLeaderboards(int min) {
    return 'Todavía no hay clasificaciones.\nUna ronda cuenta a partir de $min operaciones.';
  }

  @override
  String get globalStatsNotPlayed => 'Todavía sin practicar.';

  @override
  String globalStatsRounds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'rondas',
      one: 'ronda',
    );
    return '$_temp0';
  }

  @override
  String get globalStatsPractised => 'practicado';

  @override
  String globalStatsStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '$_temp0 seguidos';
  }

  @override
  String globalStatsLastPlayed(String when) {
    return 'último: $when';
  }

  @override
  String get globalStatsNoActivity =>
      'En las últimas semanas no se ha practicado.';

  @override
  String get profilesTitle => '¿Quién calcula?';

  @override
  String get profilesAllResults => 'Todos los resultados';

  @override
  String get profilesDuel => 'Duelo';

  @override
  String get profilesParents => 'Padres';

  @override
  String get profilesNone =>
      'Todavía no hay perfil. Toca “Nuevo” para empezar.';

  @override
  String profilesLockedTitle(String name) {
    return '$name está descansando';
  }

  @override
  String get profilesLockedText =>
      'Este perfil está bloqueado por ahora. Todas las estrellas, rayos y mejores tiempos se conservan: vuelven en cuanto los padres lo desbloqueen.';

  @override
  String get profilesLockedOk => 'Entendido';

  @override
  String get profilesAllDone => 'todo hecho';

  @override
  String profilesTodo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tareas',
      one: '1 tarea',
    );
    return '$_temp0';
  }

  @override
  String get profilesEditLook => 'Cambiar imagen y color';

  @override
  String get profilesNew => 'Nuevo';

  @override
  String get profileEditorNew => 'Perfil nuevo';

  @override
  String get profileEditorChangeName => 'Cambiar nombre';

  @override
  String get profileEditorNameLabel => 'Nombre';

  @override
  String get profileEditorNext => 'Siguiente';

  @override
  String get profileEditorLookTitle => 'Imagen y color';

  @override
  String get profileEditorPicture => 'Imagen';

  @override
  String get profileEditorColor => 'Color';

  @override
  String get profileEditorSave => 'Guardar';

  @override
  String get duelTitle => 'Duelo';

  @override
  String get duelNeedTwoProfiles =>
      'Para un duelo hacen falta al menos dos perfiles.';

  @override
  String get duelWhoPlays => '¿Quién participa?';

  @override
  String duelPlayerLocked(String avatar, String name) {
    return '$avatar  $name · bloqueado';
  }

  @override
  String duelPlayerOnBreak(String avatar, String name) {
    return '$avatar  $name · descanso';
  }

  @override
  String duelPlayer(String avatar, String name) {
    return '$avatar  $name';
  }

  @override
  String get duelWhichTasks => '¿Qué operaciones?';

  @override
  String get duelPickTwo => 'Elige al menos dos niños.';

  @override
  String duelLessonChip(String title, String example) {
    return '$title  ·  $example';
  }

  @override
  String get duelStart => 'Empezar duelo';

  @override
  String duelPosition(int position, int total) {
    return '$position de $total';
  }

  @override
  String duelYourTurn(String name) {
    return 'Turno de $name';
  }

  @override
  String duelLessonAndGroup(String lesson, String group) {
    return '$lesson · $group';
  }

  @override
  String get duelReady => 'Listo';

  @override
  String get duelAbort => 'Cancelar duelo';

  @override
  String duelResultTitle(String lesson) {
    return 'Duelo · $lesson';
  }

  @override
  String get duelSameTasks => 'Todos tuvieron las mismas operaciones.';

  @override
  String get duelDone => 'Terminado';

  @override
  String get duelWin => '¡Gana!';

  @override
  String get commonBackToLessons => 'Volver a las lecciones';

  @override
  String get resultDone => '¡Muy bien!';

  @override
  String resultDoneName(String name) {
    return '¡Muy bien, $name!';
  }

  @override
  String resultNextBolt(int n, String time) {
    return 'Rayo $n desde $time por operación';
  }

  @override
  String get resultForThisLesson => 'en esta lección';

  @override
  String get resultInTotal => 'en total';

  @override
  String get resultMetricTasks => 'Operaciones';

  @override
  String get resultMetricTotalTime => 'Tiempo total';

  @override
  String get resultMetricPerTask => 'Por operación';

  @override
  String get resultMetricErrors => 'Errores';

  @override
  String resultPenalty(String penalty, int count, int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count intentos fallidos',
      one: '1 intento fallido',
    );
    String _temp1 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds segundos',
      one: '1 segundo',
    );
    return 'Incluye una penalización de $penalty por $_temp0: $_temp1 por cada uno.';
  }

  @override
  String resultStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días',
      one: '1 día',
    );
    return '¡$_temp0 practicando seguidos!';
  }

  @override
  String get resultAgain => 'Otra vez';

  @override
  String get resultLeaderboard => 'Clasificación';

  @override
  String get resultOtherLesson => 'Otra lección';

  @override
  String get resultFirstRun =>
      'Esta fue tu primera ronda aquí:\ndesde ahora este tiempo es tu récord.';

  @override
  String get resultSameSpeed => 'Igual de rápido que la última vez.';

  @override
  String resultFaster(String delta) {
    return '¡$delta más rápido por operación que la última vez!';
  }

  @override
  String resultSlower(String delta) {
    return '$delta más lento por operación que la última vez.';
  }

  @override
  String get practiceAbortTitle => '¿Terminar la práctica?';

  @override
  String get practiceAbortText =>
      'Esta ronda no contará para la clasificación.';

  @override
  String get practiceKeepGoing => 'Seguir';

  @override
  String get practiceAbortConfirm => 'Terminar';

  @override
  String get practiceAbortTooltip => 'Terminar la práctica';

  @override
  String get practicePause => 'Pausa';

  @override
  String get practicePauseNote => 'El reloj está parado.';

  @override
  String get practiceResume => 'Continuar';

  @override
  String get lessonsFilterTooltip => 'Ocultar lecciones terminadas';

  @override
  String get lessonsHideDoneAssignments => 'Ocultar tareas hechas';

  @override
  String get lessonsStatsLabel => 'Estadísticas';

  @override
  String get lessonsSettingsTooltip => 'Ajustes';

  @override
  String get lessonsSwitchLabel => 'Cambiar';

  @override
  String get lessonsNoGroup =>
      'Todavía no hay ninguna zona desbloqueada para este perfil.\nSe puede cambiar en la zona de padres.';

  @override
  String get lessonsNothingLeftTitle => '¡Todo hecho!';

  @override
  String get lessonsNothingLeftText =>
      'Lo que puedes practicar está oculto ahora mismo. El filtro de arriba vuelve a mostrar todo el catálogo.';

  @override
  String get lessonsRecommendGo => 'Ir';

  @override
  String lessonsRecommendTitle(String lesson, String group) {
    return '$lesson · $group';
  }

  @override
  String get lessonsAssignmentsHeading => 'Tus tareas';

  @override
  String get lessonsAssignmentsAllDone =>
      '¡Todo hecho! Las tareas terminadas están ocultas.';

  @override
  String get lessonsNotPractised => 'todavía sin practicar';

  @override
  String lessonsPractisedTimes(int count) {
    return 'practicada $count×';
  }

  @override
  String get adminTitle => 'Zona de padres';

  @override
  String get adminTabHistory => 'Historial';

  @override
  String get adminTabManagement => 'Gestión';

  @override
  String get adminTabAssignments => 'Tareas';

  @override
  String get adminTabSettings => 'Ajustes';

  @override
  String get adminFilterAll => 'Todos';

  @override
  String get adminShowDeleted => 'Borradas';

  @override
  String adminHistoryTruncated(int limit) {
    return 'Se muestran las últimas $limit rondas. Un periodo más corto muestra el resto.';
  }

  @override
  String adminCleanupAll(int count) {
    return 'Limpiar rondas abandonadas ($count)';
  }

  @override
  String adminCleanupOne(String name, int count) {
    return 'Limpiar rondas abandonadas de $name ($count)';
  }

  @override
  String get adminHistoryEmpty => 'Todavía no hay rondas.';

  @override
  String get adminDeleteRunTitle => '¿Borrar esta ronda?';

  @override
  String adminDeleteRunText(String user, String lesson, String when) {
    return '$user · $lesson · $when';
  }

  @override
  String get adminRunDeleted => 'Ronda borrada.';

  @override
  String get adminUndo => 'Deshacer';

  @override
  String get adminThisChild => 'este niño';

  @override
  String get adminWhoAll => 'de todos los niños';

  @override
  String adminWhoOne(String name) {
    return 'de $name';
  }

  @override
  String adminCleanupTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Limpiar $count rondas abandonadas?',
      one: '¿Limpiar una ronda abandonada?',
    );
    return '$_temp0';
  }

  @override
  String adminCleanupText(String whose, String range) {
    return 'Las rondas abandonadas $whose $range desaparecerán. Nunca contaron para estrellas, rayos ni clasificación; el tiempo de práctica se sigue contando.';
  }

  @override
  String get adminCleanupConfirm => 'Limpiar';

  @override
  String adminCleanedUp(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rondas abandonadas limpiadas.',
      one: 'Una ronda abandonada limpiada.',
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
      other: '$count operaciones',
      one: '1 operación',
    );
    return 'abandonada tras $_temp0';
  }

  @override
  String get adminRestore => 'Recuperar';

  @override
  String get adminDeleteRun => 'Borrar ronda';

  @override
  String get adminProfiles => 'Perfiles';

  @override
  String get adminNewProfile => 'Perfil nuevo';

  @override
  String get adminProfilesNote =>
      'Al tocar a un niño se abre todo lo que le pertenece: zonas, tiempos, bloqueo, cambiar el nombre y borrar. Cada niño puede cambiar él mismo su imagen y su color en la pantalla de inicio.';

  @override
  String get adminPinHeading => 'PIN';

  @override
  String get adminPinNote =>
      'Protege esta zona. ¿Lo has olvidado? Entonces la única salida es borrar los datos de la app en los ajustes de Android, y con eso se borran también todos los resultados.';

  @override
  String get adminChangePin => 'Cambiar PIN';

  @override
  String get adminGroupsNone => 'Ninguna zona desbloqueada';

  @override
  String get adminGroupsAll => 'Todas las zonas';

  @override
  String adminGroupsSome(int n, int total) {
    return '$n de $total zonas';
  }

  @override
  String get adminLocked => 'Bloqueado';

  @override
  String get adminNoReview => 'sin repaso';

  @override
  String get profileSettingsDiscardTitle => '¿Descartar los cambios?';

  @override
  String profileSettingsDiscardText(String name) {
    return 'Los ajustes de $name se han cambiado, pero todavía no se han guardado.';
  }

  @override
  String get profileSettingsDiscard => 'Descartar';

  @override
  String get profileSettingsSave => 'Guardar';

  @override
  String get profileSettingsSectionPractice => 'Práctica';

  @override
  String get profileSettingsGroups => 'Zonas';

  @override
  String get profileSettingsGroupsNote =>
      'Las zonas desactivadas ya no aparecen en la pantalla de práctica. Los resultados ya conseguidos se conservan.';

  @override
  String get profileSettingsNoGroup =>
      'Sin ninguna zona, el niño no puede practicar.';

  @override
  String get profileSettingsHideDoneHeading => 'Ocultar lecciones terminadas';

  @override
  String get profileSettingsHideDoneNote =>
      'Recorta el catálogo con lo que ya está firme. El niño también puede cambiarlo en la pantalla de práctica; aquí se puede dejar preparado de una vez. El nivel más estricto deja los Primeros pasos donde están: allí no se mide el tiempo, así que no hay rayos que conseguir.';

  @override
  String get profileSettingsHideDoneAssignments => 'Ocultar tareas hechas';

  @override
  String get profileSettingsHideDoneAssignmentsNote =>
      'Las tarjetas terminadas desaparecen antes de que acabe el día o la semana. Si no, se quedan ahí, marcadas como hechas.';

  @override
  String get profileSettingsTaskCount => 'Operaciones por ronda';

  @override
  String get profileSettingsReview => 'Repetir operaciones difíciles';

  @override
  String get profileSettingsReviewNote =>
      'Una cuarta parte de cada ronda se compone de lo que tardó mucho o salió mal la última vez.';

  @override
  String get profileSettingsSectionTime => 'Tiempo y puntuación';

  @override
  String get profileSettingsStretch => 'Tiempo de práctica seguido';

  @override
  String get profileSettingsStretchNote =>
      'Pasado este tiempo hay un descanso. Una ronda en marcha nunca se interrumpe: solo se bloquea el siguiente comienzo. El tiempo sigue contando mientras el descanso no se haya cumplido entero.';

  @override
  String get profileSettingsBreakLength => '¿Cuánto dura el descanso?';

  @override
  String get profileSettingsDaily => 'Y en total por día';

  @override
  String get profileSettingsDailyNote =>
      'Suma todas las rondas del día, con descansos o sin ellos. Cuando se agota el tiempo, se continúa al día siguiente.';

  @override
  String get profileSettingsScoredRuns => 'Rondas puntuadas por lección y día';

  @override
  String get profileSettingsScoredRunsNote =>
      'Después se puede seguir practicando la misma lección, pero ya no da mejor tiempo, estrellas ni rayos. El tiempo de práctica y el historial siguen contando.';

  @override
  String get profileSettingsSectionTidy => 'Ordenar';

  @override
  String get profileSettingsTidyNote =>
      'Estos botones actúan al instante: no esperan a “Guardar”.';

  @override
  String get profileSettingsRename => 'Cambiar nombre';

  @override
  String get profileSettingsGiveBackStars => 'Devolver estrellas …';

  @override
  String get profileSettingsResetResults => 'Borrar resultados';

  @override
  String get profileSettingsDeleteProfile => 'Borrar perfil';

  @override
  String profileSettingsResetTitle(String name) {
    return '¿Borrar los resultados de $name?';
  }

  @override
  String get profileSettingsResetText =>
      'Se pierden los mejores tiempos, la curva de aprendizaje y el historial. El perfil se queda.';

  @override
  String profileSettingsDeleteTitle(String name) {
    return '¿Borrar a $name?';
  }

  @override
  String get profileSettingsDeleteText =>
      'Se eliminan el perfil y todos los resultados.';

  @override
  String profileSettingsGroupSummary(int count, String example) {
    return '$count lecciones · p. ej. $example';
  }

  @override
  String get profileSettingsLockTitle => 'Bloquear el perfil por ahora';

  @override
  String get profileSettingsLockNote =>
      'Entonces el perfil no se puede abrir ni invitar a un duelo. No se pierde nada: las estrellas, los rayos y los mejores tiempos vuelven intactos al desbloquear.';

  @override
  String get globalSettingsClock => 'Mostrar el reloj al practicar';

  @override
  String get globalSettingsClockNote =>
      'El tiempo se mide siempre. Pero verlo pone nerviosos a algunos niños, por eso viene desactivado.';

  @override
  String get globalSettingsHaptics => 'Vibrar al pulsar una tecla';

  @override
  String get globalSettingsHapticsNote =>
      'Una vibración corta en cada pulsación.';

  @override
  String get globalSettingsSounds => 'Reproducir sonidos';

  @override
  String get globalSettingsSoundsNote =>
      'Un sonido corto para lo correcto, otro distinto para lo incorrecto y un clic suave bajo cada tecla. En una tableta apoyada en la mesa apenas se nota la vibración.';

  @override
  String get globalSettingsTaskCount => 'Operaciones por ronda para todos';

  @override
  String get globalSettingsTaskCountNote =>
      'Para un solo niño, el valor está en “Gestión”, en su perfil, y el propio niño puede cambiarlo en sus ajustes.';

  @override
  String get globalSettingsLimits => 'Tiempo de práctica para todos';

  @override
  String get globalSettingsLimitsNote =>
      'Vale para cada niño que no tenga un valor propio. Una ronda en marcha nunca se interrumpe: solo se bloquea el siguiente comienzo.';

  @override
  String get globalSettingsStretch => 'Seguido, luego descanso';

  @override
  String get globalSettingsBreakLength => '¿Cuánto dura el descanso?';

  @override
  String get globalSettingsDaily => 'Y en total por día';

  @override
  String get globalSettingsScoredRuns => 'Rondas puntuadas por lección y día';

  @override
  String get globalSettingsScoredRunsNote =>
      'Después se puede seguir practicando la misma lección, pero ya no da mejor tiempo, estrellas ni rayos. Así se quita el motivo para repetir la lección más fácil hasta que el tiempo salga bien. El tiempo de práctica y el historial siguen contando.';

  @override
  String resetStarsTitle(String group) {
    return '¿Reiniciar las estrellas de “$group”?';
  }

  @override
  String resetStarsText(String name) {
    return 'Después $name puede volver a ganarlas. Los mejores tiempos, los rayos, la curva de aprendizaje y las clasificaciones no cambian: solo se ven afectadas las estrellas de esta zona.';
  }

  @override
  String get resetStarsConfirm => 'Reiniciar';

  @override
  String resetStarsHeading(String name) {
    return 'Estrellas de $name';
  }

  @override
  String get resetStarsNote =>
      'Solo se reinician las estrellas. Los tiempos se quedan: mejores tiempos, rayos, curva de aprendizaje y clasificaciones siguen exactamente igual.';

  @override
  String get resetStarsDone => 'Hecho';

  @override
  String resetStarsGroupLine(int earned, int possible) {
    return '$earned de $possible estrellas';
  }

  @override
  String get assignmentsAll => 'Todas';

  @override
  String get assignmentsNew => 'Tarea nueva';

  @override
  String get assignmentsHideFinished => 'Ocultar hechas';

  @override
  String assignmentsHiddenCount(int count) {
    return '$count ocultas';
  }

  @override
  String get assignmentsEmpty => 'Todavía no hay tareas.';

  @override
  String get assignmentsNoneOpen =>
      'No hay tareas abiertas. Las terminadas están ocultas.';

  @override
  String get assignmentsDaily => 'diaria';

  @override
  String get assignmentsWeekly => 'semanal';

  @override
  String get assignmentsCarriesOver => 'se arrastra';

  @override
  String assignmentsLessonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lecciones',
      one: '1 lección',
    );
    return '$_temp0';
  }

  @override
  String get assignmentsEdit => 'Editar';

  @override
  String get assignmentsEnd => 'Terminar';

  @override
  String get assignmentsRepeat => 'Poner otra vez';

  @override
  String get assignmentsDelete => 'Borrar tarea';

  @override
  String assignmentsRunsOfTasks(int runs, int tasks) {
    return '$runs× $tasks operaciones';
  }

  @override
  String assignmentsMinStars(int count) {
    return 'mín. $count ★';
  }

  @override
  String assignmentsMinBolts(int count) {
    return 'mín. $count ⚡';
  }

  @override
  String get assignmentsNoClosedPeriod =>
      'Todavía no hay ningún periodo terminado';

  @override
  String assignmentsMetOf(int met, int total, String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'daily': 'días',
      'weekly': 'semanas',
      'other': 'semanas',
    });
    return 'Cumplida en $met de $total $_temp0';
  }

  @override
  String assignmentsBefore(int met, int total, String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'daily': 'días',
      'weekly': 'semanas',
      'other': 'semanas',
    });
    return 'antes, $met de $total $_temp0';
  }

  @override
  String get assignmentsVerdictMet => 'Cumplida';

  @override
  String get assignmentsVerdictPending => 'Aún abierta';

  @override
  String get assignmentsVerdictLate => 'Perdida, recuperada después';

  @override
  String get assignmentsVerdictMissed => 'Perdida';

  @override
  String get editorTitleEdit => 'Editar tarea';

  @override
  String get editorTitleAgain => 'Poner otra vez';

  @override
  String get editorTitleNew => 'Tarea nueva';

  @override
  String get editorChild => 'Niño';

  @override
  String get editorUnknownChild => 'Niño desconocido';

  @override
  String get editorLessons => 'Lecciones';

  @override
  String get editorLessonsNote =>
      'Se pueden elegir varias. Hay que completar cada una para que la tarea esté hecha.';

  @override
  String get editorNoLesson => 'Sin ninguna lección no hay nada que poner.';

  @override
  String get editorPeriod => 'Periodo';

  @override
  String get editorOneDay => 'un día';

  @override
  String get editorOneWeek => 'una semana';

  @override
  String get editorRepetition => 'Repetir';

  @override
  String get editorEveryTime => 'siempre';

  @override
  String get editorOnce => 'una vez';

  @override
  String get editorDailyNote => 'Nueva cada día, vence al final del día.';

  @override
  String get editorWeeklyNote =>
      'Nueva cada semana, vence el domingo por la tarde.';

  @override
  String editorOnDay(String day) {
    return 'El $day';
  }

  @override
  String editorInWeek(String day) {
    return 'En la semana del $day';
  }

  @override
  String get editorPickDay => 'Elegir un día …';

  @override
  String get editorCarryOver => 'Arrastrar si no se hace';

  @override
  String get editorCarryOverNote =>
      'Entonces la tarea se queda hasta que se haga. El día en sí cuenta igualmente como perdido: las estadísticas dicen cuándo se practicó, no lo que se pretendía.';

  @override
  String get editorRuns => 'Rondas';

  @override
  String get editorTasksPerRun => 'Operaciones por ronda';

  @override
  String get editorMinStars => 'Mínimo de estrellas';

  @override
  String get editorMinBolts => 'Mínimo de rayos';

  @override
  String get editorNoRequirement => 'sin requisito';

  @override
  String get editorSave => 'Guardar';

  @override
  String get editorCreate => 'Crear';

  @override
  String get groupFirstSteps => 'Primeros pasos';

  @override
  String get groupUpTo10 => 'Hasta 10';

  @override
  String get groupUpTo20 => 'Hasta 20';

  @override
  String get groupUpTo100 => 'Hasta 100';

  @override
  String get groupUpTo1000 => 'Hasta 1000';

  @override
  String get groupWithThousands => 'Con millares';

  @override
  String get groupTimesTables => 'Tablas de multiplicar';

  @override
  String get groupReverseTimesTables => 'Tablas al revés';

  @override
  String get groupTimesAndDivision => 'Multiplicar y dividir';

  @override
  String get groupEveryday => 'Hora y dinero';

  @override
  String get lessonAddPlainTitle => 'Suma sin pasar la decena';

  @override
  String get lessonAddPlainBigTitle => 'Suma sin llevadas';

  @override
  String get lessonAddPlainDesc =>
      'Las unidades juntas se quedan por debajo de 10: no hay que llevar nada.';

  @override
  String get lessonAddPlainBigDesc =>
      'Ninguna posición se desborda, ni las unidades ni las decenas.';

  @override
  String get lessonAddCarryTitle => 'Suma pasando la decena';

  @override
  String get lessonAddCarryBigTitle => 'Suma con llevadas';

  @override
  String get lessonAddCarryDesc =>
      'Las unidades suman 10 o más: una decena pasa a la siguiente posición.';

  @override
  String get lessonAddCarryBigDesc =>
      'Se desbordan las unidades o las decenas: hay que llevar algo.';

  @override
  String get lessonSubPlainTitle => 'Resta sin pasar la decena';

  @override
  String get lessonSubPlainBigTitle => 'Resta sin llevadas';

  @override
  String get lessonSubPlainDesc =>
      'Cada cifra de arriba es suficientemente grande: no hay que romper ninguna decena.';

  @override
  String get lessonSubPlainBigDesc =>
      'Cada cifra de arriba es suficientemente grande: no hay que romper nada.';

  @override
  String get lessonSubBorrowTitle => 'Resta pasando la decena';

  @override
  String get lessonSubBorrowBigTitle => 'Resta con llevadas';

  @override
  String get lessonSubBorrowDesc =>
      'Las unidades de arriba no alcanzan: hay que romper una decena.';

  @override
  String get lessonSubBorrowBigDesc =>
      'Una posición de arriba no alcanza: hay que romper una decena o una centena.';

  @override
  String get lessonPlusGapTitle => 'Suma con número que falta';

  @override
  String get lessonMinusGapTitle => 'Resta con número que falta';

  @override
  String get lessonGapDesc =>
      'Busca el número que falta para que la operación sea cierta.';

  @override
  String get lessonMixedTitle => 'Sumas y restas mezcladas';

  @override
  String get lessonMixedDesc =>
      'Sumas y restas se alternan al azar, con y sin pasar la decena.';

  @override
  String lessonTimesTableTitle(int n) {
    return 'Tabla del $n';
  }

  @override
  String lessonTimesTableDesc(int n) {
    return 'Todas las operaciones de la tabla del $n, en los dos sentidos: $n · 4 y también 4 · $n.';
  }

  @override
  String lessonReverseTableTitle(int n) {
    return 'Tabla del $n al revés';
  }

  @override
  String lessonReverseTableDesc(int n, int product) {
    return 'Dividido entre $n. Cada operación es la inversa de una de la tabla del $n: $n · 4 = $product se convierte en $product : $n = 4.';
  }

  @override
  String get lessonPartnersOfTenTitle => 'Los amigos del 10';

  @override
  String get lessonPartnersOfTenDesc =>
      'Dos números son amigos cuando juntos suman justo 10: 1 y 9, 2 y 8, 3 y 7. Se pregunta en los dos sentidos: de 3 a 7 y también de 7 a 3.';

  @override
  String get lessonAdd10Title => 'Sumas hasta 10';

  @override
  String get lessonAdd10Desc => 'Sumar sin pasar de 10.';

  @override
  String get lessonSub10Title => 'Restas hasta 10';

  @override
  String get lessonSub10Desc => 'Quitar dentro del 10.';

  @override
  String get lessonMix10Desc => 'Sumas y restas se alternan al azar.';

  @override
  String get lessonTimesAllTitle => 'Todas las tablas mezcladas';

  @override
  String get lessonTimesAllDesc =>
      'Toda la tabla de multiplicar pequeña, bien mezclada.';

  @override
  String get lessonDivPlainTitle => 'Todas las tablas al revés';

  @override
  String get lessonDivPlainDesc =>
      'Divisiones entre todos los números, mezcladas. Todas dan exacto: son la inversa de una operación de las tablas de multiplicar.';

  @override
  String get lessonDivRemainderTitle => 'División con resto';

  @override
  String get lessonDivRemainderDesc =>
      'Siempre sobra algo. Escribe primero el resultado y luego el resto.';

  @override
  String get lessonTimesGapTitle => 'Multiplicar con número que falta';

  @override
  String get lessonTimesGapDesc =>
      '¿Por qué número hay que multiplicar para que sea cierto?';

  @override
  String get lessonDivGapTitle => 'Dividir con número que falta';

  @override
  String get lessonDivGapDesc =>
      '¿Entre qué número hay que dividir para que sea cierto?';

  @override
  String get lessonMulTensTitle => 'Multiplicar con decenas';

  @override
  String get lessonMulTensDesc =>
      'La tabla de multiplicar con un cero detrás: 3 · 4 = 12, así que 30 · 4 = 120.';

  @override
  String get lessonMulTwoDigitTitle => 'Multiplicar más allá de las tablas';

  @override
  String get lessonMulTwoDigitDesc =>
      'Multiplica un número de dos cifras, por ejemplo 14 · 6.';

  @override
  String get lessonDivTwoDigitTitle => 'Dividir más allá de las tablas';

  @override
  String get lessonDivTwoDigitDesc =>
      'El resultado es mayor que diez, por ejemplo 96 : 6.';

  @override
  String get lessonMulDivMixedTitle => 'Multiplicar y dividir mezclado';

  @override
  String get lessonMulDivMixedDesc =>
      'Multiplicar y dividir se alternan al azar.';

  @override
  String get lessonPunktVorStrichTitle => 'Prioridad de las operaciones';

  @override
  String get lessonPunktVorStrichDesc =>
      'Multiplicar y dividir van antes que sumar y restar, aunque estén al final: en 40 − 3 · 6 primero se calcula 3 · 6.';

  @override
  String get lessonCountPicturesTitle => '¿Cuántos hay? (en fila)';

  @override
  String get lessonCountPicturesDesc =>
      'Cuenta los dibujos, de uno a cinco, bien colocados en fila.';

  @override
  String get lessonCountPicturesCloudTitle => '¿Cuántos hay? (desordenados)';

  @override
  String get lessonCountPicturesCloudDesc =>
      'Los mismos dibujos, pero revueltos: hay que acordarse de lo que ya se ha contado.';

  @override
  String get lessonCountDiceTitle => '¿Cuántos puntos?';

  @override
  String get lessonCountDiceDesc =>
      'Un dado. Pronto verás el número sin contar.';

  @override
  String get lessonCompareMoreTitle => '¿Dónde hay más? (en fila)';

  @override
  String get lessonCompareMoreDesc =>
      'Compara dos grupos y escribe el número mayor.';

  @override
  String get lessonCompareMoreCloudTitle => '¿Dónde hay más? (desordenados)';

  @override
  String get lessonCompareMoreCloudDesc =>
      'Lo mismo, pero con los dibujos revueltos.';

  @override
  String get lessonCountNextTitle => '¿Qué número viene después?';

  @override
  String get lessonCountNextDesc =>
      'La serie de números hacia delante y hacia atrás.';

  @override
  String get lessonBeesAddTitle => 'Abejitas (en fila)';

  @override
  String get lessonBeesAddDesc =>
      'Suma dos grupos pequeños de abejas; en total nunca más de diez.';

  @override
  String get lessonBeesAddCloudTitle => 'Abejitas (desordenadas)';

  @override
  String get lessonBeesAddCloudDesc =>
      'La misma operación, pero con las abejas zumbando por todas partes.';

  @override
  String get lessonDiceAddTitle => 'Sumar dos dados';

  @override
  String get lessonDiceAddDesc =>
      'Los dos dados muestran hasta cinco puntos: ¿cuántos hay en total?';

  @override
  String get lessonAddToSixTitle => 'Sumas hasta 6';

  @override
  String get lessonAddToSixDesc => 'Sumar sin pasar de seis.';

  @override
  String get lessonSubToSixTitle => 'Restas hasta 6';

  @override
  String get lessonSubToSixDesc => 'Quitar dentro del seis.';

  @override
  String get lessonCalcToSixTitle => 'Sumas y restas hasta 6';

  @override
  String get lessonCalcToSixDesc => 'Las dos mezcladas, sin pasar de seis.';

  @override
  String get lessonClockHalfTitle => 'Horas en punto y y media';

  @override
  String get lessonClockHalfDesc =>
      '¿Qué hora es? La aguja grande señala el 12 o el 6.';

  @override
  String get lessonClockQuarterTitle => 'Cuartos de hora';

  @override
  String get lessonClockQuarterDesc =>
      'Y cuarto, y media, menos cuarto: la aguja grande señala el 12, el 3, el 6 o el 9.';

  @override
  String get lessonClockFiveTitle => 'Hora de cinco en cinco minutos';

  @override
  String get lessonClockFiveDesc =>
      'La aguja grande señala uno de los doce números.';

  @override
  String get lessonClock24Title => 'Hora con 24 horas';

  @override
  String get lessonClock24Desc =>
      'Por la tarde se sigue contando: las 3 se convierten en las 15:00. Debajo del reloj pone qué parte del día es.';

  @override
  String get lessonClockWordsTitle => 'Decir la hora';

  @override
  String get lessonClockWordsDesc =>
      '¿Cómo se dice la hora? Primero escribe la hora y luego toca la expresión: en “las 3 y media” es el 3.';

  @override
  String get lessonMoneyAddTitle => 'Sumar dinero';

  @override
  String get lessonMoneyAddDesc =>
      'Suma dos cantidades. Escribe primero los euros y luego los céntimos.';

  @override
  String get lessonMoneySubTitle => 'Quitar dinero';

  @override
  String get lessonMoneySubDesc => '¿Cuánto queda, o cuánto te devuelven?';

  @override
  String get lessonMoneyComposeTitle => 'Formar una cantidad';

  @override
  String get lessonMoneyComposeDesc =>
      'Forma la cantidad con monedas y billetes. Hay muchas formas correctas: al final la cantidad tiene que ser exacta.';

  @override
  String get lessonMoneyChangeTitle => '¿Cuánto me devuelven?';

  @override
  String get lessonMoneyChangeDesc =>
      'Algo cuesta una cantidad rara y pagas con un billete o una moneda redondos. Tienes que averiguar el cambio.';

  @override
  String get lessonPlaceValue100Title => 'Unidades y decenas';

  @override
  String get lessonPlaceValue100Desc =>
      '¿Cuántas unidades y decenas hay? ¿Qué número es todo junto? Puede haber más de nueve unidades.';

  @override
  String get lessonPlaceValue1000Title => 'Unidades, decenas, centenas';

  @override
  String get lessonPlaceValue1000Desc =>
      '¿Cuántas unidades, decenas y centenas hay? ¿Qué número es todo junto? Puede haber más de nueve de una clase.';

  @override
  String get lessonRoundThousandsTitle => 'Millares enteros';

  @override
  String get lessonRoundThousandsDesc =>
      '3000 + 4000, 8000 − 5000: calcula con millares enteros. Si sabes 3 + 4, esto también.';

  @override
  String get lessonRoundHundredsTitle => 'Centenas enteras';

  @override
  String get lessonRoundHundredsDesc =>
      '2300 + 400, 5600 − 200: calcula con centenas enteras. Aquí también se puede pasar de mil.';

  @override
  String get lessonRoundGapTitle => 'Millares y centenas: número que falta';

  @override
  String get lessonRoundGapDesc =>
      '3000 + ? = 7000. ¿Cuánto falta hasta el número? Piensa hacia atrás.';

  @override
  String get lessonPlaceValue10000Title =>
      'Unidades, decenas, centenas, millares';

  @override
  String get lessonPlaceValue10000Desc =>
      '¿Cuántas unidades, decenas, centenas y millares hay? ¿Qué número es todo junto? Puede haber más de nueve de una clase.';

  @override
  String get lessonAddSub10000PlainTitle => 'Sumas y restas sin llevadas';

  @override
  String get lessonAddSub10000PlainDesc =>
      '4200 + 350, 6870 − 40: números de cuatro cifras, pero sin llevadas. Una posición cada vez.';

  @override
  String taskQuestionPartner(int a) {
    return '¿Qué número va con $a para llegar a 10?';
  }

  @override
  String get taskQuestionClock => '¿Qué hora es?';

  @override
  String get taskQuestionClockPhrase => '¿Cómo se dice?';

  @override
  String taskQuestionMoneyCompose(String amount) {
    return 'Forma $amount: toca las monedas y los billetes.';
  }

  @override
  String taskQuestionChange(String price, String paid) {
    return 'Cuesta $price. Pagas con $paid. ¿Cuánto te devuelven?';
  }

  @override
  String get taskQuestionQuantity => '¿Cuántos hay?';

  @override
  String get taskQuestionDiceOne => '¿Cuántos puntos?';

  @override
  String get taskQuestionDiceTwo => '¿Cuántos puntos en total?';

  @override
  String get taskQuestionCompare => '¿Dónde hay más? Toca el número mayor.';

  @override
  String get taskQuestionSequence => '¿Qué número viene después?';

  @override
  String get taskQuestionQuantityAdd => '¿Cuántos hay en total?';

  @override
  String get taskQuestionPlaceValue => '¿Qué número es?';

  @override
  String get taskLabelRemainder => 'Resto';

  @override
  String get taskLabelEuro => '€';

  @override
  String get taskLabelClock => ':';

  @override
  String get taskUnitCents => 'cts';

  @override
  String placeOnes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n unidades',
      one: '1 unidad',
    );
    return '$_temp0';
  }

  @override
  String placeTens(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n decenas',
      one: '1 decena',
    );
    return '$_temp0';
  }

  @override
  String placeHundreds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n centenas',
      one: '1 centena',
    );
    return '$_temp0';
  }

  @override
  String placeThousands(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n millares',
      one: '1 millar',
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
    return '$price, pagado con $paid';
  }

  @override
  String taskRenderDiceOne(int a) {
    String _temp0 = intl.Intl.pluralLogic(
      a,
      locale: localeName,
      other: '$a puntos',
      one: '1 punto',
    );
    return '$_temp0';
  }

  @override
  String taskRenderDiceTwo(int a, int b) {
    return '$a + $b puntos';
  }

  @override
  String get dayPartMorning => 'de la mañana';

  @override
  String get dayPartNoon => 'al mediodía';

  @override
  String get dayPartAfternoon => 'de la tarde';

  @override
  String get dayPartEvening => 'de la noche';

  @override
  String get clockPhrase05 => 'y cinco';

  @override
  String get clockPhrase10 => 'y diez';

  @override
  String get clockPhrase15 => 'y cuarto';

  @override
  String get clockPhrase20 => 'y veinte';

  @override
  String get clockPhrase25 => 'y veinticinco';

  @override
  String get clockPhrase30 => 'y media';

  @override
  String get clockPhrase35 => 'menos veinticinco';

  @override
  String get clockPhrase40 => 'menos veinte';

  @override
  String get clockPhrase45 => 'menos cuarto';

  @override
  String get clockPhrase50 => 'menos diez';

  @override
  String get clockPhrase55 => 'menos cinco';

  @override
  String clockSpokenTime(String phrase, int hour) {
    return '$hour $phrase';
  }

  @override
  String get filterAllTitle => 'Mostrar todo';

  @override
  String get filterAllText => 'Todo el catálogo, nada oculto.';

  @override
  String get filterMasteredTitle => 'Ocultar con 3 estrellas';

  @override
  String get filterMasteredText =>
      'Lo que ya está firme desaparece de la lista. Lo que aún falla se queda.';

  @override
  String get filterPerfectedTitle => 'Solo con 3 estrellas y 3 rayos';

  @override
  String get filterPerfectedText =>
      'Solo desaparece lo que está firme **y** es rápido. Lo que no tiene errores pero aún es lento se queda para practicar.';

  @override
  String get rangeAll => 'Todo';

  @override
  String get rangeToday => 'Hoy';

  @override
  String get rangeWeek => '7 días';

  @override
  String get rangeMonth => '30 días';

  @override
  String get rangeAllPhrase => 'de todo el historial';

  @override
  String get rangeTodayPhrase => 'de hoy';

  @override
  String get rangeWeekPhrase => 'de los últimos 7 días';

  @override
  String get rangeMonthPhrase => 'de los últimos 30 días';

  @override
  String get backupErrorNotABackup =>
      'El archivo no es una copia de seguridad válida.';

  @override
  String get backupErrorWrongApp => 'Este archivo no procede de Mathe-Trainer.';

  @override
  String get backupErrorTooNew =>
      'La copia procede de una versión más nueva de la app.';

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
  String get relativeToday => 'hoy';

  @override
  String get relativeYesterday => 'ayer';

  @override
  String relativeDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'hace $days días',
      one: 'hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String remainingMinutes(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos más',
      one: '1 minuto más',
      zero: 'enseguida',
    );
    return '$_temp0';
  }

  @override
  String moneyAmount(String amount) {
    return '$amount €';
  }

  @override
  String moneyCoinCents(int n) {
    return '$n cts';
  }

  @override
  String moneyCoinEuros(int n) {
    return '$n €';
  }

  @override
  String get deadlineToday => 'hoy';

  @override
  String get deadlineUntilSunday => 'hasta el domingo';

  @override
  String get deadlineStillOpen => 'aún abierta';

  @override
  String deadlineWas(String day) {
    return 'era $day';
  }

  @override
  String get deadlineThisWeek => 'esta semana';

  @override
  String deadlineFrom(String day) {
    return 'desde $day';
  }

  @override
  String deadlineOn(String day) {
    return 'el $day';
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
