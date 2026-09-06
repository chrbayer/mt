import 'package:drift/drift.dart';

import '../../domain/lesson.dart';
import '../../domain/scoring.dart';
import '../db/app_database.dart';

/// Aggregated results of one child in one lesson.
class LessonStat {
  final String lessonId;
  final int runs;

  /// Best (lowest) scored time per task in ms.
  final double bestScoreMs;

  /// Average scored time per task across all runs - the same metric as
  /// [bestScoreMs], so the two are comparable.
  final double averageMs;

  /// Wrong attempts per task.
  final double errorRate;

  /// Most stars earned in any single run of this lesson - what the tile
  /// wears, and what counts once towards the total.
  final int bestStars;

  final DateTime lastPlayed;

  const LessonStat({
    required this.lessonId,
    required this.runs,
    required this.bestScoreMs,
    required this.averageMs,
    required this.errorRate,
    required this.bestStars,
    required this.lastPlayed,
  });
}

/// One row of a lesson leaderboard: a child's personal best.
class LeaderboardEntry {
  final int userId;
  final String name;
  final String avatar;
  final int colorIndex;
  final double scoreMs;
  final double errorRate;
  final int taskCount;
  final DateTime playedAt;

  const LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.colorIndex,
    required this.scoreMs,
    required this.errorRate,
    required this.taskCount,
    required this.playedAt,
  });
}

/// One completed run, plotted as a point on the learning curve.
class ProgressPoint {
  final DateTime at;
  final double msPerTask;

  const ProgressPoint({required this.at, required this.msPerTask});
}

/// One finished (or abandoned) run, as the parent area lists it.
class HistoryEntry {
  final int sessionId;
  final int userId;
  final String userName;
  final String avatar;
  final int colorIndex;
  final String lessonId;
  final int taskCount;
  final int totalMs;
  final int wrongAttempts;
  final bool completed;
  final DateTime playedAt;

  const HistoryEntry({
    required this.sessionId,
    required this.userId,
    required this.userName,
    required this.avatar,
    required this.colorIndex,
    required this.lessonId,
    required this.taskCount,
    required this.totalMs,
    required this.wrongAttempts,
    required this.completed,
    required this.playedAt,
  });

  /// The scored time - the same metric the leaderboards rank by, so a parent
  /// reading the log sees the number the child saw.
  double get msPerTask => scoreMsPerTask(totalMs, wrongAttempts, taskCount);

  double get errors => errorRate(wrongAttempts, taskCount);
}

/// Everything one child has done so far, across all lessons.
class UserSummary {
  final int userId;
  final String name;
  final String avatar;
  final int colorIndex;
  final int runs;
  final int tasks;
  final int totalMs;
  final int wrongAttempts;
  final DateTime? lastPlayed;

  const UserSummary({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.colorIndex,
    required this.runs,
    required this.tasks,
    required this.totalMs,
    required this.wrongAttempts,
    required this.lastPlayed,
  });

  double get errors => errorRate(wrongAttempts, tasks);
}

/// One lesson's ranking, for the overview across all lessons.
class LessonLeaderboard {
  final String lessonId;

  /// When this lesson was last practised by anyone - the overview puts the
  /// freshest first.
  final DateTime lastPlayed;

  /// Best run per child, fastest first.
  final List<LeaderboardEntry> entries;

  const LessonLeaderboard({
    required this.lessonId,
    required this.lastPlayed,
    required this.entries,
  });
}

/// How much one child practised on one calendar day.
class ActivityPoint {
  final DateTime day;
  final int userId;
  final int runs;
  final int totalMs;

  const ActivityPoint({
    required this.day,
    required this.userId,
    required this.runs,
    required this.totalMs,
  });
}

/// A calculation the child repeatedly struggles with.
class HardTask {
  final int a;
  final int b;
  final String op;
  final String form;
  final double averageMs;
  final int occurrences;

  const HardTask({
    required this.a,
    required this.b,
    required this.op,
    required this.form,
    required this.averageMs,
    required this.occurrences,
  });
}

/// Read-only statistics. All aggregation happens in SQL, not in Dart.
class StatsRepository {
  final AppDatabase _db;

  StatsRepository(this._db);

  /// Score expression shared by every query, so the ranking rule lives in
  /// exactly one place next to [wrongAttemptPenaltyMs].
  static const String _score =
      '(s.total_ms + $wrongAttemptPenaltyMs * s.wrong_attempts) * 1.0 '
      '/ s.task_count';

  /// The lessons that are neither timed nor ranked, as a SQL list. Built from
  /// the catalogue, which SQL cannot read for itself. The ids are code
  /// constants, never user input.
  static final String _unscored =
      unscoredLessonIds.map((id) => "'$id'").join(', ');

  /// The same rule as [starsFor], expressed in SQL.
  ///
  /// A lesson that is not scored earns its stars for being finished: in the
  /// first steps the achievement is getting through, not getting through
  /// cleanly.
  static final String _stars = '''
      CASE
        WHEN s.lesson_id IN ($_unscored) THEN $maxStars
        WHEN s.wrong_attempts * 1.0 / s.task_count <= $threeStarErrorRate
          THEN $maxStars
        WHEN s.wrong_attempts * 1.0 / s.task_count <= $twoStarErrorRate
          THEN 2
        ELSE 1
      END''';

  /// Per-lesson summary for one child. Streams so screens refresh themselves
  /// after a run.
  Stream<Map<String, LessonStat>> watchLessonStats(int userId) {
    return _db
        .customSelect(
          '''
          SELECT s.lesson_id                       AS lesson_id,
                 COUNT(*)                          AS runs,
                 MIN($_score)                      AS best_score,
                 AVG($_score)                      AS average_ms,
                 SUM(s.wrong_attempts) * 1.0 / SUM(s.task_count) AS error_rate,
                 MAX($_stars)                      AS best_stars,
                 MAX(s.finished_at_ms)             AS last_played
          FROM sessions s
          WHERE s.user_id = ?1 AND s.completed = 1
          GROUP BY s.lesson_id
          ''',
          variables: [Variable.withInt(userId)],
          readsFrom: {_db.sessions},
        )
        .watch()
        .map((rows) => {
              for (final row in rows)
                row.read<String>('lesson_id'): LessonStat(
                  lessonId: row.read<String>('lesson_id'),
                  runs: row.read<int>('runs'),
                  bestScoreMs: row.read<double>('best_score'),
                  averageMs: row.read<double>('average_ms'),
                  errorRate: row.read<double>('error_rate'),
                  bestStars: row.read<int>('best_stars'),
                  lastPlayed: DateTime.fromMillisecondsSinceEpoch(
                    row.read<int>('last_played'),
                  ),
                )
            });
  }

  /// Ranking of all profiles in one lesson, best personal run per child.
  ///
  /// Relies on SQLite's documented behaviour that with a single bare `MIN()`
  /// the other selected columns come from the matching row.
  Stream<List<LeaderboardEntry>> watchLeaderboard(String lessonId) {
    return _db
        .customSelect(
          '''
          SELECT u.id                AS user_id,
                 u.name              AS name,
                 u.avatar            AS avatar,
                 u.color_index       AS color_index,
                 MIN($_score)        AS score,
                 s.wrong_attempts    AS wrong_attempts,
                 s.task_count        AS task_count,
                 s.finished_at_ms    AS finished_at_ms
          FROM sessions s
          JOIN users u ON u.id = s.user_id
          WHERE s.lesson_id = ?1
            AND s.completed = 1
            AND s.task_count >= ?2
            AND s.lesson_id NOT IN ($_unscored)
          GROUP BY u.id
          ORDER BY score ASC
          ''',
          variables: [
            Variable.withString(lessonId),
            Variable.withInt(minTasksForLeaderboard),
          ],
          readsFrom: {_db.sessions, _db.users},
        )
        .watch()
        .map((rows) => [
              for (final row in rows)
                LeaderboardEntry(
                  userId: row.read<int>('user_id'),
                  name: row.read<String>('name'),
                  avatar: row.read<String>('avatar'),
                  colorIndex: row.read<int>('color_index'),
                  scoreMs: row.read<double>('score'),
                  errorRate: errorRate(
                    row.read<int>('wrong_attempts'),
                    row.read<int>('task_count'),
                  ),
                  taskCount: row.read<int>('task_count'),
                  playedAt: DateTime.fromMillisecondsSinceEpoch(
                    row.read<int>('finished_at_ms'),
                  ),
                )
            ]);
  }

  /// Every lesson that has a ranking at all, freshest first.
  ///
  /// One query rather than one per lesson: there are over forty of them, and
  /// most are empty on any given tablet.
  Stream<List<LessonLeaderboard>> watchAllLeaderboards() {
    return _db
        .customSelect(
          '''
          SELECT s.lesson_id       AS lesson_id,
                 u.id              AS user_id,
                 u.name            AS name,
                 u.avatar          AS avatar,
                 u.color_index     AS color_index,
                 MIN($_score)      AS score,
                 s.wrong_attempts  AS wrong_attempts,
                 s.task_count      AS task_count,
                 s.finished_at_ms  AS finished_at_ms,
                 (SELECT MAX(l.finished_at_ms)
                    FROM sessions l
                   WHERE l.lesson_id = s.lesson_id
                     AND l.completed = 1) AS last_played_ms
          FROM sessions s
          JOIN users u ON u.id = s.user_id
          WHERE s.completed = 1
            AND s.task_count >= ?1
            AND s.lesson_id NOT IN ($_unscored)
          GROUP BY s.lesson_id, u.id
          ORDER BY last_played_ms DESC, s.lesson_id, score ASC
          ''',
          variables: [Variable.withInt(minTasksForLeaderboard)],
          readsFrom: {_db.sessions, _db.users},
        )
        .watch()
        .map((rows) {
      // The rows arrive grouped by lesson and sorted within it, so a single
      // pass keeps both orders.
      final byLesson = <String, List<LeaderboardEntry>>{};
      final lastPlayed = <String, DateTime>{};
      final order = <String>[];

      for (final row in rows) {
        final lessonId = row.read<String>('lesson_id');
        if (byLesson.putIfAbsent(lessonId, () => []).isEmpty) {
          order.add(lessonId);
          lastPlayed[lessonId] = DateTime.fromMillisecondsSinceEpoch(
            row.read<int>('last_played_ms'),
          );
        }
        byLesson[lessonId]!.add(
          LeaderboardEntry(
            userId: row.read<int>('user_id'),
            name: row.read<String>('name'),
            avatar: row.read<String>('avatar'),
            colorIndex: row.read<int>('color_index'),
            scoreMs: row.read<double>('score'),
            errorRate: errorRate(
              row.read<int>('wrong_attempts'),
              row.read<int>('task_count'),
            ),
            taskCount: row.read<int>('task_count'),
            playedAt: DateTime.fromMillisecondsSinceEpoch(
              row.read<int>('finished_at_ms'),
            ),
          ),
        );
      }

      return [
        for (final lessonId in order)
          LessonLeaderboard(
            lessonId: lessonId,
            lastPlayed: lastPlayed[lessonId]!,
            entries: byLesson[lessonId]!,
          )
      ];
    });
  }

  /// The learning curve: scored time per task over the last [limit] runs of a
  /// lesson, oldest first. Scored rather than raw, so the curve reflects
  /// getting things right as well as getting faster - and so it cannot
  /// disagree with the number the child was shown.
  Stream<List<ProgressPoint>> watchProgress({
    required int userId,
    required String lessonId,
    int limit = 20,
  }) {
    return _db
        .customSelect(
          '''
          SELECT s.finished_at_ms AS finished_at_ms,
                 $_score AS ms_per_task
          FROM sessions s
          WHERE s.user_id = ?1 AND s.lesson_id = ?2 AND s.completed = 1
          ORDER BY s.finished_at_ms DESC
          LIMIT ?3
          ''',
          variables: [
            Variable.withInt(userId),
            Variable.withString(lessonId),
            Variable.withInt(limit),
          ],
          readsFrom: {_db.sessions},
        )
        .watch()
        .map((rows) => [
              for (final row in rows.reversed)
                ProgressPoint(
                  at: DateTime.fromMillisecondsSinceEpoch(
                    row.read<int>('finished_at_ms'),
                  ),
                  msPerTask: row.read<double>('ms_per_task'),
                )
            ]);
  }

  /// The parent area's log: every run, newest first, optionally for one child.
  ///
  /// Abandoned runs are included on purpose - "started and gave up" is exactly
  /// the kind of thing a parent wants to see.
  Stream<List<HistoryEntry>> watchHistory({int? userId, int limit = 200}) {
    return _db
        .customSelect(
          '''
          SELECT s.id             AS session_id,
                 s.user_id        AS user_id,
                 u.name           AS name,
                 u.avatar         AS avatar,
                 u.color_index    AS color_index,
                 s.lesson_id      AS lesson_id,
                 s.task_count     AS task_count,
                 s.total_ms       AS total_ms,
                 s.wrong_attempts AS wrong_attempts,
                 s.completed      AS completed,
                 COALESCE(s.finished_at_ms, s.started_at_ms) AS played_at_ms
          FROM sessions s
          JOIN users u ON u.id = s.user_id
          WHERE (?1 IS NULL OR s.user_id = ?1)
          ORDER BY played_at_ms DESC
          LIMIT ?2
          ''',
          variables: [
            if (userId == null) const Variable<int>(null) else Variable.withInt(userId),
            Variable.withInt(limit),
          ],
          readsFrom: {_db.sessions, _db.users},
        )
        .watch()
        .map((rows) => [
              for (final row in rows)
                HistoryEntry(
                  sessionId: row.read<int>('session_id'),
                  userId: row.read<int>('user_id'),
                  userName: row.read<String>('name'),
                  avatar: row.read<String>('avatar'),
                  colorIndex: row.read<int>('color_index'),
                  lessonId: row.read<String>('lesson_id'),
                  taskCount: row.read<int>('task_count'),
                  totalMs: row.read<int>('total_ms'),
                  wrongAttempts: row.read<int>('wrong_attempts'),
                  completed: row.read<bool>('completed'),
                  playedAt: DateTime.fromMillisecondsSinceEpoch(
                    row.read<int>('played_at_ms'),
                  ),
                )
            ]);
  }

  /// One row per profile for the overview screen. Profiles without a single
  /// finished run are included with zeroes, so nobody is missing from the
  /// comparison.
  Stream<List<UserSummary>> watchUserSummaries() {
    return _db
        .customSelect(
          '''
          SELECT u.id                      AS user_id,
                 u.name                    AS name,
                 u.avatar                  AS avatar,
                 u.color_index             AS color_index,
                 COUNT(s.id)               AS runs,
                 COALESCE(SUM(s.task_count), 0)     AS tasks,
                 COALESCE(SUM(s.total_ms), 0)       AS total_ms,
                 COALESCE(SUM(s.wrong_attempts), 0) AS wrong_attempts,
                 MAX(s.finished_at_ms)     AS last_played_ms
          FROM users u
          LEFT JOIN sessions s ON s.user_id = u.id AND s.completed = 1
          GROUP BY u.id
          ORDER BY total_ms DESC, u.id
          ''',
          readsFrom: {_db.sessions, _db.users},
        )
        .watch()
        .map((rows) => [
              for (final row in rows)
                UserSummary(
                  userId: row.read<int>('user_id'),
                  name: row.read<String>('name'),
                  avatar: row.read<String>('avatar'),
                  colorIndex: row.read<int>('color_index'),
                  runs: row.read<int>('runs'),
                  tasks: row.read<int>('tasks'),
                  totalMs: row.read<int>('total_ms'),
                  wrongAttempts: row.read<int>('wrong_attempts'),
                  lastPlayed: row.read<int?>('last_played_ms') == null
                      ? null
                      : DateTime.fromMillisecondsSinceEpoch(
                          row.read<int>('last_played_ms'),
                        ),
                )
            ]);
  }

  /// Stars per child: the best run of every lesson, counted once.
  ///
  /// Once per lesson on purpose - otherwise the total would reward repeating
  /// the easiest lesson over trying a new one.
  Stream<Map<int, int>> watchStarTotals() {
    return _db
        .customSelect(
          '''
          SELECT best.user_id AS user_id, SUM(best.stars) AS stars
          FROM (
            SELECT s.user_id AS user_id, MAX($_stars) AS stars
            FROM sessions s
            WHERE s.completed = 1
            GROUP BY s.user_id, s.lesson_id
          ) AS best
          GROUP BY best.user_id
          ''',
          readsFrom: {_db.sessions},
        )
        .watch()
        .map((rows) => {
              for (final row in rows)
                row.read<int>('user_id'): row.read<int>('stars'),
            });
  }

  /// Days practised in a row, per child.
  ///
  /// Today only extends a streak once something has been practised; until
  /// then the run of days up to yesterday still counts, so a streak does not
  /// look broken all morning.
  Stream<Map<int, int>> watchStreaks() {
    return _db
        .customSelect(
          '''
          SELECT DISTINCT
                 s.user_id AS user_id,
                 date(s.finished_at_ms / 1000, 'unixepoch', 'localtime') AS day
          FROM sessions s
          WHERE s.completed = 1
          ORDER BY user_id, day DESC
          ''',
          readsFrom: {_db.sessions},
        )
        .watch()
        .map((rows) {
      final daysByUser = <int, List<DateTime>>{};
      for (final row in rows) {
        daysByUser
            .putIfAbsent(row.read<int>('user_id'), () => [])
            .add(DateTime.parse(row.read<String>('day')));
      }

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      return {
        for (final entry in daysByUser.entries)
          entry.key: _streakLength(entry.value, today),
      };
    });
  }

  /// Counts back from [today] - or from yesterday, if today is still empty.
  static int _streakLength(List<DateTime> daysDescending, DateTime today) {
    if (daysDescending.isEmpty) return 0;
    var expected = today;
    if (daysDescending.first != today) {
      expected = today.subtract(const Duration(days: 1));
      if (daysDescending.first != expected) return 0;
    }

    var streak = 0;
    for (final day in daysDescending) {
      if (day != expected) break;
      streak++;
      expected = expected.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Practice per calendar day and child, for the activity chart.
  ///
  /// Days are bucketed with SQLite's `localtime`, so an evening session counts
  /// for the day it felt like, not for the UTC day.
  Stream<List<ActivityPoint>> watchActivity({int days = 30}) {
    final since = DateTime.now()
        .subtract(Duration(days: days - 1))
        .millisecondsSinceEpoch;
    return _db
        .customSelect(
          '''
          SELECT s.user_id AS user_id,
                 date(s.finished_at_ms / 1000, 'unixepoch', 'localtime') AS day,
                 COUNT(*) AS runs,
                 SUM(s.total_ms) AS total_ms
          FROM sessions s
          WHERE s.completed = 1 AND s.finished_at_ms >= ?1
          GROUP BY s.user_id, day
          ''',
          variables: [Variable.withInt(since)],
          readsFrom: {_db.sessions},
        )
        .watch()
        .map((rows) => [
              for (final row in rows)
                ActivityPoint(
                  day: DateTime.parse(row.read<String>('day')),
                  userId: row.read<int>('user_id'),
                  runs: row.read<int>('runs'),
                  totalMs: row.read<int>('total_ms'),
                )
            ]);
  }

  /// The calculations from one lesson that cost this child the most, worst
  /// first - the pool a run draws its review tasks from.
  ///
  /// Averaged over every encounter, so a single unlucky moment does not brand
  /// a task as hard forever, and weighted with the same penalty the scoring
  /// uses: getting it wrong counts more than being slow.
  Future<List<HardTask>> hardTasksInLesson({
    required int userId,
    required String lessonId,
    int limit = 12,
  }) async {
    final rows = await _db.customSelect(
      '''
      SELECT a.operand_a           AS operand_a,
             a.operand_b           AS operand_b,
             a.op                  AS op,
             a.form                AS form,
             AVG(a.elapsed_ms)     AS average_ms,
             COUNT(*)              AS occurrences,
             AVG(a.wrong_attempts) AS average_wrong
      FROM attempts a
      JOIN sessions s ON s.id = a.session_id
      WHERE s.user_id = ?1 AND s.lesson_id = ?2 AND s.completed = 1
      GROUP BY a.operand_a, a.operand_b, a.op, a.form
      HAVING average_wrong > 0 OR average_ms > (
        SELECT AVG(a2.elapsed_ms) * 1.4
        FROM attempts a2
        JOIN sessions s2 ON s2.id = a2.session_id
        WHERE s2.user_id = ?1 AND s2.lesson_id = ?2 AND s2.completed = 1
      )
      ORDER BY average_ms + $wrongAttemptPenaltyMs * average_wrong DESC
      LIMIT ?3
      ''',
      variables: [
        Variable.withInt(userId),
        Variable.withString(lessonId),
        Variable.withInt(limit),
      ],
      readsFrom: {_db.attempts, _db.sessions},
    ).get();

    return [
      for (final row in rows)
        HardTask(
          a: row.read<int>('operand_a'),
          b: row.read<int>('operand_b'),
          op: row.read<String>('op'),
          form: row.read<String>('form'),
          averageMs: row.read<double>('average_ms'),
          occurrences: row.read<int>('occurrences'),
        )
    ];
  }

  /// Removes a single run, for when a sibling scribbled through someone's
  /// lesson.
  Future<void> deleteSession(int sessionId) =>
      (_db.delete(_db.sessions)..where((s) => s.id.equals(sessionId))).go();

  /// Calculations that cost the child the most time, penalty included.
  Future<List<HardTask>> hardestTasks({
    required int userId,
    int limit = 8,
  }) async {
    final rows = await _db.customSelect(
      '''
      SELECT a.operand_a          AS operand_a,
             a.operand_b          AS operand_b,
             a.op                 AS op,
             a.form               AS form,
             AVG(a.elapsed_ms)    AS average_ms,
             COUNT(*)             AS occurrences,
             AVG(a.wrong_attempts) AS average_wrong
      FROM attempts a
      JOIN sessions s ON s.id = a.session_id
      WHERE s.user_id = ?1 AND s.completed = 1
      GROUP BY a.operand_a, a.operand_b, a.op, a.form
      ORDER BY average_ms + $wrongAttemptPenaltyMs * average_wrong DESC
      LIMIT ?2
      ''',
      variables: [Variable.withInt(userId), Variable.withInt(limit)],
      readsFrom: {_db.attempts, _db.sessions},
    ).get();

    return [
      for (final row in rows)
        HardTask(
          a: row.read<int>('operand_a'),
          b: row.read<int>('operand_b'),
          op: row.read<String>('op'),
          form: row.read<String>('form'),
          averageMs: row.read<double>('average_ms'),
          occurrences: row.read<int>('occurrences'),
        )
    ];
  }
}
