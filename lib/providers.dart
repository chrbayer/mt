/// Central Riverpod wiring: one database, repositories on top of it, and the
/// small amount of app-wide state (which child is currently logged in).
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/app_database.dart';
import 'data/repositories/backup_repository.dart';
import 'data/repositories/session_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/stats_repository.dart';
import 'data/repositories/user_repository.dart';
import 'domain/lesson.dart';
import 'domain/practice_limit.dart';
import 'domain/task.dart';
import 'domain/task_count.dart';

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

/// Key for the per-lesson run length: one child, one lesson.
typedef LessonKey = ({int userId, String lessonId});

final lessonTaskCountProvider = StreamProvider.family<int?, LessonKey>(
  (ref, key) => ref
      .watch(settingsRepositoryProvider)
      .watchLessonTaskCount(key.userId, key.lessonId),
);

/// How long the next run of this lesson should be, with the three levels
/// resolved: this lesson, then this child, then everyone.
///
/// Loading until every level has answered - a made-up value would show one
/// number and then jump to another.
final resolvedTaskCountProvider =
    Provider.family<AsyncValue<int>, LessonKey>((ref, key) {
  final global = ref.watch(preferencesProvider);
  final perLesson = ref.watch(lessonTaskCountProvider(key));
  final user = ref.watch(activeUserProvider);

  if (!global.hasValue || !perLesson.hasValue) return const AsyncLoading();
  return AsyncData(
    resolveTaskCount(
      forLesson: perLesson.value,
      forProfile: user?.defaultTaskCount,
      global: global.value!.defaultTaskCount,
    ),
  );
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
  final today = now();
  final stretches = ref.watch(statsRepositoryProvider).watchPracticeStretch(
        userId: user.id,
        breakMinutes: limits.breakMinutes,
        dayStartMs:
            DateTime(today.year, today.month, today.day).millisecondsSinceEpoch,
      );

  // Waking up at the end of a break rebuilds the whole provider rather than
  // re-judging the old numbers: when the wake-up is midnight, the day itself
  // has changed and the query has to be asked again.
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
        ref.invalidateSelf,
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
        )
    ];
  },
);

final hardestTasksProvider = FutureProvider.family<List<HardTask>, int>(
  (ref, userId) => ref.watch(statsRepositoryProvider).hardestTasks(userId: userId),
);
