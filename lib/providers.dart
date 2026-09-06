/// Central Riverpod wiring: one database, repositories on top of it, and the
/// small amount of app-wide state (which child is currently logged in).
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/db/app_database.dart';
import 'data/repositories/backup_repository.dart';
import 'data/repositories/session_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/stats_repository.dart';
import 'data/repositories/user_repository.dart';
import 'domain/lesson.dart';
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
