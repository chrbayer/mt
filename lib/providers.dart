/// Central Riverpod wiring: one database, repositories on top of it, and the
/// small amount of app-wide state (which child is currently logged in).
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/app_database.dart';
import 'data/repositories/assignment_repository.dart';
import 'data/repositories/backup_repository.dart';
import 'data/repositories/session_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/stats_repository.dart';
import 'data/repositories/user_repository.dart';
import 'domain/assignment.dart';
import 'domain/lesson.dart';
import 'domain/practice_limit.dart';
import 'domain/task.dart';
import 'domain/task_count.dart';
import 'features/practice/feedback_sounds.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final userRepositoryProvider =
    Provider((ref) => UserRepository(ref.watch(databaseProvider)));

final sessionRepositoryProvider =
    Provider((ref) => SessionRepository(ref.watch(databaseProvider)));

final backupRepositoryProvider =
    Provider((ref) => BackupRepository(ref.watch(databaseProvider)));

final statsRepositoryProvider =
    Provider((ref) => StatsRepository(ref.watch(databaseProvider)));

final settingsRepositoryProvider =
    Provider((ref) => SettingsRepository(ref.watch(databaseProvider)));

final assignmentRepositoryProvider =
    Provider((ref) => AssignmentRepository(ref.watch(databaseProvider)));

/// Key for the per-lesson run length: one child, one lesson.
typedef LessonKey = ({int userId, String lessonId});

final lessonTaskCountProvider = StreamProvider.family<int?, LessonKey>(
  (ref, key) => ref
      .watch(settingsRepositoryProvider)
      .watchLessonTaskCount(key.userId, key.lessonId),
);

/// How long the next run of this lesson should be, with all four levels
/// resolved: an open assignment for this lesson, then this lesson, then this
/// child, then everyone.
///
/// Loading until every level has answered - a made-up value would show one
/// number and then jump to another.
final resolvedTaskCountProvider =
    Provider.family<AsyncValue<int>, LessonKey>((ref, key) {
  final global = ref.watch(preferencesProvider);
  final perLesson = ref.watch(lessonTaskCountProvider(key));
  final assignment = ref.watch(assignmentForLessonProvider(key));
  final user = ref.watch(activeUserProvider);

  if (!global.hasValue || !perLesson.hasValue || !assignment.hasValue) {
    return const AsyncLoading();
  }
  return AsyncData(
    resolveTaskCount(
      forAssignment: assignment.value?.taskCount,
      forLesson: perLesson.value,
      forProfile: user?.defaultTaskCount,
      global: global.value!.defaultTaskCount,
    ),
  );
});

/// Every assignment still open for one child - the child screen's "Deine
/// Aufgaben" and the profile tile's badge both read this.
final openAssignmentsProvider = StreamProvider.family<List<Assignment>, int>(
  (ref, userId) => ref
      .watch(assignmentRepositoryProvider)
      .watchAssignments(userId: userId, openOnly: true),
);

/// The one open assignment for this child and this lesson, or null. At most
/// one is expected to matter at a time - an assignment is never edited, only
/// ended and replaced.
///
/// Built on [openAssignmentsProvider]'s `.future` rather than awaiting the
/// repository's stream directly: awaiting a drift stream's `.first` inside a
/// widget test deadlocks, because nothing pumps it (the same trap
/// `task_count_priority_test.dart` already works around). Going through a
/// `StreamProvider` and its Riverpod-managed `.future` does not have that
/// problem - `usersProvider.future` and `preferencesProvider.future` are read
/// the same way elsewhere in this file.
final assignmentForLessonProvider =
    FutureProvider.family<Assignment?, LessonKey>((ref, key) async {
  final assignments =
      await ref.watch(openAssignmentsProvider(key.userId).future);
  for (final a in assignments) {
    if (a.lessonId == key.lessonId) return a;
  }
  return null;
});

/// Every assignment for one child, open or already ended, or for every child
/// when [userId] is null - what the parent tab lists.
final assignmentsProvider = StreamProvider.family<List<Assignment>, int?>(
  (ref, userId) =>
      ref.watch(assignmentRepositoryProvider).watchAssignments(userId: userId),
);

/// One assignment's progress: whether the period running right now has met
/// its goal, and - for the parent tab - the same question for every closed
/// period since it started.
///
/// Computed once from the whole run history of this child and this lesson,
/// not once per period: the row set is already bounded to one child and one
/// lesson (see [AssignmentRepository]), so asking the database once beats
/// asking it once per period.
class AssignmentStats {
  final Assignment assignment;
  final LessonSpec lesson;
  final AssignmentPeriod currentPeriod;
  final AssignmentProgress current;

  /// Every closed period, oldest first, true where it was met.
  final List<bool> closed;

  const AssignmentStats({
    required this.assignment,
    required this.lesson,
    required this.currentPeriod,
    required this.current,
    required this.closed,
  });

  int get closedMet => closed.where((met) => met).length;
}

/// Null when the assigned lesson is one this version no longer knows - an
/// older backup, a dropped lesson - the same reason `lessonByIdOrNull`
/// exists: nothing here can be measured against a lesson that is not there.
final assignmentStatsProvider =
    StreamProvider.family<AssignmentStats?, Assignment>((ref, a) {
  final lesson = lessonByIdOrNull(a.lessonId);
  if (lesson == null) return Stream.value(null);

  final repo = ref.watch(assignmentRepositoryProvider);
  final now = ref.watch(clockProvider)();
  final currentPeriod = periodAt(a, now);

  return repo.watchRunsFor(a, sinceMs: a.createdAtMs).map((rows) {
    final runs = [for (final row in rows) row.facts];
    final current = progressIn(
      a: a,
      lesson: lesson,
      period: currentPeriod,
      runs: runs,
    );
    final closed = [
      for (final period in closedPeriods(a, now))
        progressIn(a: a, lesson: lesson, period: period, runs: runs).met,
    ];
    return AssignmentStats(
      assignment: a,
      lesson: lesson,
      currentPeriod: currentPeriod,
      current: current,
      closed: closed,
    );
  });
});

/// Whether the daily cap from #16 must step aside for this child and this
/// lesson right now: there is an open assignment for it, and the period
/// running now has not met its goal yet.
///
/// A future, not a stream, for the same reason [scoredRunLimitProvider] is:
/// `PracticeScreen._prepare()` reads it once before a run starts and never
/// re-judges it while the run is under way.
final openAssignmentProvider =
    FutureProvider.family<bool, LessonKey>((ref, key) async {
  final a = await ref.watch(assignmentForLessonProvider(key).future);
  if (a == null) return false;
  final stats = await ref.watch(assignmentStatsProvider(a).future);
  return stats != null && !stats.current.met;
});

final usersProvider = StreamProvider<List<User>>(
  (ref) => ref.watch(userRepositoryProvider).watchUsers(),
);

final preferencesProvider = StreamProvider<AppPreferences>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// The child currently practising. Intentionally not persisted: the app
/// always starts at the profile picker so the next child taps their own tile.
class ActiveUser extends Notifier<User?> {
  @override
  User? build() => null;

  void select(User user) => state = user;

  void logout() => state = null;

  /// Keeps the cached profile in sync after a rename or avatar change.
  void refresh(List<User> users) {
    final current = state;
    if (current == null) return;
    final match = users.where((u) => u.id == current.id).firstOrNull;
    if (match == null) {
      state = null;
    } else if (match != current) {
      state = match;
    }
  }
}

final activeUserProvider = NotifierProvider<ActiveUser, User?>(ActiveUser.new);

final lessonStatsProvider = StreamProvider.family<Map<String, LessonStat>, int>(
  (ref, userId) => ref.watch(statsRepositoryProvider).watchLessonStats(userId),
);

final leaderboardProvider =
    StreamProvider.family<List<LeaderboardEntry>, String>(
  (ref, lessonId) =>
      ref.watch(statsRepositoryProvider).watchLeaderboard(lessonId),
);

/// Key for [progressProvider]: one child's curve in one lesson.
typedef ProgressKey = ({int userId, String lessonId});

final progressProvider =
    StreamProvider.family<List<ProgressPoint>, ProgressKey>(
  (ref, key) => ref.watch(statsRepositoryProvider).watchProgress(
        userId: key.userId,
        lessonId: key.lessonId,
      ),
);

/// The parent area's run log. A null key means "all children".
final historyProvider = StreamProvider.family<List<HistoryEntry>, int?>(
  (ref, userId) =>
      ref.watch(statsRepositoryProvider).watchHistory(userId: userId),
);

/// One row per profile for the overview across all children.
final userSummariesProvider = StreamProvider<List<UserSummary>>(
  (ref) => ref.watch(statsRepositoryProvider).watchUserSummaries(),
);

/// Every lesson that has a ranking, freshest first.
final allLeaderboardsProvider = StreamProvider<List<LessonLeaderboard>>(
  (ref) => ref.watch(statsRepositoryProvider).watchAllLeaderboards(),
);

/// Stars per child, counting each lesson's best run once.
final starTotalsProvider = StreamProvider<Map<int, int>>(
  (ref) => ref.watch(statsRepositoryProvider).watchStarTotals(),
);

/// Bolts per child, counting each lesson's best run once.
final boltTotalsProvider = StreamProvider<Map<int, int>>(
  (ref) => ref.watch(statsRepositoryProvider).watchBoltTotals(),
);

/// Whether the active child may start another run right now.
///
/// Re-emits when a run is stored, and once more exactly when the break is
/// over - a screen that says "Pause bis 15:20" has to unlock itself at 15:20
/// without anyone tapping anything. It ticks only while blocked; while
/// practice is allowed nothing changes on its own.
/// The wall clock, so a test can decide what time it is.
///
/// Only the practice cap needs this: it is the one rule that changes with the
/// passing of time alone, without anybody touching the app.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Start of the current day in epoch milliseconds: the one boundary every
/// rule that counts "today" reads.
///
/// Cached until something invalidates it, and [refreshDay] is what does -
/// from the app coming back to the foreground, and from the one binding
/// check in `PracticeScreen._prepare()`.
///
/// It used to be worked out inside each of those rules, once, from
/// [clockProvider]. That froze it on whatever day the provider was first
/// built. On a tablet the app lives for days, so practice from Monday kept
/// counting towards Tuesday's total and the daily cap locked a child out
/// over time they had not spent that day. What hid it was that the only
/// wake-up in the app fired while a child was **already blocked** - so the
/// day rolled over exactly when it was least needed, and never otherwise.
///
/// Deliberately no timer of its own. A pending alarm keeps the app and every
/// widget test awake, which is why the break alarm below is only ever set
/// when there is something to wake up for.
final dayStartProvider = Provider<int>((ref) {
  final now = ref.watch(clockProvider)();
  return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
});

/// Re-reads the day boundary, and with it everything counted against it.
///
/// Called from the one place that reliably marks the passing of a night:
/// the app coming back to the foreground. Invalidating it from inside a run
/// being prepared looked tempting and was worse than the bug - the screen
/// under it watches the allowance, so the rebuild it set off never settled.
void refreshDay(WidgetRef ref) => ref.invalidate(dayStartProvider);

/// How many runs of one lesson may still earn something today, for one
/// child: their own cap where they have one, the app-wide one where not.
///
/// Zero means no cap. Awaited rather than guessed for the same reason the
/// time limits are: while the profile is loading, nobody knows.
final scoredRunLimitProvider =
    FutureProvider.family<int, int>((ref, userId) async {
  final users = await ref.watch(usersProvider.future);
  final preferences = await ref.watch(preferencesProvider.future);
  final user = users.where((u) => u.id == userId).firstOrNull;
  return resolveScoredRuns(
    global: preferences.scoredRunsPerLesson,
    scoredRuns: user?.scoredRunsPerLesson,
  );
});

/// How often one lesson counted for one child today, and how often it still
/// may. Null when there is no cap at all - then there is nothing to say.
final scoredRunsTodayProvider = StreamProvider.family<({int used, int left})?,
    ({int userId, String lessonId})>((ref, key) async* {
  final limit = await ref.watch(scoredRunLimitProvider(key.userId).future);
  if (limit <= 0) {
    yield null;
    return;
  }
  final dayStartMs = ref.watch(dayStartProvider);
  yield* ref
      .watch(statsRepositoryProvider)
      .watchScoredRunsToday(
        userId: key.userId,
        lessonId: key.lessonId,
        dayStartMs: dayStartMs,
      )
      .map((used) => (used: used, left: limit - used < 0 ? 0 : limit - used));
});

/// The app's sounds, created once and kept.
///
/// One instance for the whole app rather than one per practice screen: three
/// audio pipelines were being built and torn down on every run, for sounds
/// that are 35 to 300 ms long. It is also the safer shape - the screen can no
/// longer throw its players away while the next screen is building new ones.
final feedbackSoundsProvider = Provider<FeedbackSounds>((ref) {
  final sounds = FeedbackSounds();
  ref.onDispose(sounds.dispose);
  return sounds;
});

/// Whether one stored run was allowed to earn anything. Read on the result
/// screen, which otherwise has no way of knowing that this run was the
/// fourth of the day.
final sessionScoredProvider =
    FutureProvider.family<bool, int>((ref, sessionId) async {
  final session =
      await ref.watch(sessionRepositoryProvider).sessionById(sessionId);
  return session?.scored ?? true;
});

final practiceAllowanceForProvider =
    StreamProvider.family<PracticeAllowance, int>((ref, userId) async* {
  // Awaited, not read off an AsyncValue: while the profile or the app-wide
  // limits are still loading there is no telling whether this child is
  // capped, and answering "not capped" opens a door about to close. The
  // screens wait; they do not guess.
  final users = await ref.watch(usersProvider.future);
  final preferences = await ref.watch(preferencesProvider.future);

  final user = users.where((u) => u.id == userId).firstOrNull;
  if (user == null) {
    yield PracticeAllowance.unlimited;
    return;
  }

  final limits = resolvePracticeLimits(
    global: preferences.limits,
    stretchMinutes: user.practiceLimitMinutes,
    breakMinutes: user.breakMinutes,
    dailyMinutes: user.dailyLimitMinutes,
  );
  if (limits.stretchMinutes <= 0 && limits.dailyMinutes <= 0) {
    yield PracticeAllowance.unlimited;
    return;
  }

  final now = ref.watch(clockProvider);
  final stretches = ref.watch(statsRepositoryProvider).watchPracticeStretch(
        userId: user.id,
        breakMinutes: limits.breakMinutes,
        // From dayStartProvider, which moves on by itself: worked out here
        // it stayed frozen on the day this provider was first built.
        dayStartMs: ref.watch(dayStartProvider),
      );

  // Waking up at the end of a break rebuilds the whole provider rather than
  // re-judging the old numbers. Midnight is not this alarm's job - that is
  // what dayStartProvider is for, and it wakes up whether or not anybody is
  // currently blocked.
  //
  // An explicit Timer, not an await inside the generator - only this one
  // really stops once nobody is listening, and a pending alarm keeps both the
  // app and every widget test awake.
  Timer? alarm;
  ref.onDispose(() => alarm?.cancel());

  yield* stretches.map((stretch) {
    final allowance = practiceAllowance(
      limitMinutes: limits.stretchMinutes,
      breakMinutes: limits.breakMinutes,
      practisedMs: stretch.practisedMs,
      lastFinishedAt: stretch.lastFinishedAt,
      now: now(),
      dailyLimitMinutes: limits.dailyMinutes,
      practisedTodayMs: stretch.todayMs,
    );

    alarm?.cancel();
    final until = allowance.breakUntil;
    if (until != null) {
      final left = until.difference(now());
      alarm = Timer(
        left.isNegative ? Duration.zero : left + const Duration(seconds: 1),
        () {
          // The day boundary first: when this alarm is midnight, the day
          // itself has changed, and re-running only this provider would ask
          // the same question against yesterday's boundary.
          ref.invalidate(dayStartProvider);
          ref.invalidateSelf();
        },
      );
    }
    return allowance;
  });
});

/// What a screen has to know before it offers to start a run: whether it may
/// start, and, when not, what to say about it.
///
/// One implementation for all three doors into a run - start dialog,
/// "Nochmal" and the recommendation - because three copies of the same
/// question drift apart, and the third one already had.
typedef PracticeGate = ({bool mayStart, PracticeAllowance? pause});

/// While the limits are still being read the answer is **no**, and there is
/// nothing to explain yet: the same rule as for the run length, where
/// inventing a value made the choice jump. Here inventing "allowed" would
/// open a door that is about to close.
final practiceGateProvider = Provider<PracticeGate>((ref) {
  final allowance = ref.watch(practiceAllowanceProvider).value;
  if (allowance == null) return (mayStart: false, pause: null);
  return (
    mayStart: allowance.allowed,
    pause: allowance.allowed ? null : allowance,
  );
});

/// The same, for the child currently practising.
final practiceAllowanceProvider = Provider<AsyncValue<PracticeAllowance>>((ref) {
  final user = ref.watch(activeUserProvider);
  if (user == null) return const AsyncData(PracticeAllowance.unlimited);
  return ref.watch(practiceAllowanceForProvider(user.id));
});

/// What each child has practised today, per the app's own clock.
final practisedTodayProvider = StreamProvider<Map<int, int>>((ref) {
  final now = ref.watch(clockProvider)();
  return ref.watch(statsRepositoryProvider).watchPractisedToday(
        DateTime(now.year, now.month, now.day).millisecondsSinceEpoch,
      );
});

/// Days practised in a row, per child.
final streaksProvider = StreamProvider<Map<int, int>>(
  (ref) => ref.watch(statsRepositoryProvider).watchStreaks(),
);

/// Practice per day and child over the last 30 days.
final activityProvider = StreamProvider<List<ActivityPoint>>(
  (ref) => ref.watch(statsRepositoryProvider).watchActivity(),
);

/// Key for [reviewTasksProvider]: what one child struggles with in one lesson.
typedef ReviewKey = ({int userId, String lessonId});

/// Calculations to weave back into the next run of a lesson. Empty when the
/// child has the review switched off, or has not practised the lesson yet.
final reviewTasksProvider = FutureProvider.family<List<Task>, ReviewKey>(
  (ref, key) async {
    final user = await ref.watch(userRepositoryProvider).findUser(key.userId);
    if (user == null || !user.reviewHardTasks) return const [];

    final hard = await ref.watch(statsRepositoryProvider).hardTasksInLesson(
          userId: key.userId,
          lessonId: key.lessonId,
        );
    return [
      for (final task in hard)
        Task(
          a: task.a,
          b: task.b,
          op: Operation.values.byName(task.op),
          form: TaskForm.values.byName(task.form),
          c: task.c,
          op2: task.op2 == null ? null : Operation.values.byName(task.op2!),
        )
    ];
  },
);

final hardestTasksProvider = FutureProvider.family<List<HardTask>, int>(
  (ref, userId) => ref.watch(statsRepositoryProvider).hardestTasks(userId: userId),
);
