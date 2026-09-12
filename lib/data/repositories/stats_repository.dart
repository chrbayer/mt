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

  /// Most bolts earned in any single run. Computed here rather than from
  /// [bestScoreMs] in the widget: the fastest run may have been too short to
  /// be worth anything, and the rule for that lives in one place.
  final int bestBolts;

  final DateTime lastPlayed;

  const LessonStat({
    required this.lessonId,
    required this.runs,
    required this.bestScoreMs,
    required this.averageMs,
    required this.errorRate,
    required this.bestStars,
    required this.bestBolts,
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

  /// The third operand and second operation of a Punkt-vor-Strich task.
  /// Null for every other form.
  final int? c;
  final String? op2;
  final double averageMs;
  final int occurrences;

  const HardTask({
    required this.a,
    required this.b,
    required this.op,
    required this.form,
    this.c,
    this.op2,
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

  /// The three-bolt time of every timed lesson, as a SQL lookup. Generated
  /// from the catalogue for the same reason as [_unscored]: SQL cannot read
  /// it, and a second hand-written copy of 54 targets would drift.
  static final String _boltTarget = '''
      CASE s.lesson_id
        ${lessonCatalog.where((l) => l.targetMsPerTask > 0).map((l) => "WHEN '${l.id}' THEN ${l.targetMsPerTask}").join('\n        ')}
        ELSE 0
      END''';

  /// The same rule as [boltsFor], expressed in SQL.
  ///
  /// Unlike the stars this may be zero: speed is the thing still to be had,
  /// and a lesson that is not timed has no bolts to give at all.
  static final String _bolts = '''
      CASE
        WHEN ($_boltTarget) = 0 THEN 0
        WHEN s.task_count < $minTasksForAward THEN 0
        WHEN $_score <= ($_boltTarget) THEN $maxBolts
        WHEN $_score <= ($_boltTarget) * $twoBoltFactor THEN 2
        WHEN $_score <= ($_boltTarget) * $oneBoltFactor THEN 1
        ELSE 0
      END''';

  /// Per-lesson summary for one child. Streams so screens refresh themselves
  /// after a run.
  /// Only the **records** are capped, never the practice facts: "12x geübt",
  /// the average and the error rate cover every completed run, while the best
  /// time and the bolts see only the runs that were allowed to count. A run
  /// past the daily cap really did happen; it just did not set a record.
  Stream<Map<String, LessonStat>> watchLessonStats(int userId) {
    return _db
        .customSelect(
          '''
          SELECT s.lesson_id                       AS lesson_id,
                 COUNT(*)                          AS runs,
                 COALESCE(
                   MIN(CASE WHEN s.scored = 1 THEN $_score END),
                   MIN($_score))                   AS best_score,
                 AVG($_score)                      AS average_ms,
                 SUM(s.wrong_attempts) * 1.0 / SUM(s.task_count) AS error_rate,
                 COALESCE(
                   (SELECT ls.stars FROM lesson_stars ls
                     WHERE ls.user_id = s.user_id
                       AND ls.lesson_id = s.lesson_id), 0) AS best_stars,
                 COALESCE(
                   MAX(CASE WHEN s.scored = 1 THEN $_bolts END), 0)
                                                   AS best_bolts,
                 MAX(s.finished_at_ms)             AS last_played
          FROM sessions s
          WHERE s.user_id = ?1 AND s.completed = 1 AND s.deleted = 0
          GROUP BY s.lesson_id
          ''',
          variables: [Variable.withInt(userId)],
          readsFrom: {_db.sessions, _db.lessonStars},
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
                  bestBolts: row.read<int>('best_bolts'),
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
            AND s.scored = 1
            AND s.deleted = 0
            AND s.task_count >= ?2
            AND s.lesson_id NOT IN ($_unscored)
          GROUP BY u.id
          ORDER BY score ASC
          ''',
          variables: [
            Variable.withString(lessonId),
            Variable.withInt(minTasksForAward),
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
                     AND l.completed = 1
                     AND l.deleted = 0) AS last_played_ms
          FROM sessions s
          JOIN users u ON u.id = s.user_id
          WHERE s.completed = 1
            AND s.scored = 1
            AND s.deleted = 0
            AND s.task_count >= ?1
            AND s.lesson_id NOT IN ($_unscored)
          GROUP BY s.lesson_id, u.id
          ORDER BY last_played_ms DESC, s.lesson_id, score ASC
          ''',
          variables: [Variable.withInt(minTasksForAward)],
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
            AND s.deleted = 0
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

  /// The parent area's log: every run, newest first, optionally for one child
  /// and optionally only back to [sinceMs].
  ///
  /// Abandoned runs are included on purpose - "started and gave up" is exactly
  /// the kind of thing a parent wants to see.
  Stream<List<HistoryEntry>> watchHistory({
    int? userId,
    int? sinceMs,
    int limit = 200,
  }) {
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
            AND s.deleted = 0
            -- The alias cannot be used here, so the expression is repeated.
            AND (?2 IS NULL
                 OR COALESCE(s.finished_at_ms, s.started_at_ms) >= ?2)
          ORDER BY played_at_ms DESC
          LIMIT ?3
          ''',
          variables: [
            if (userId == null) const Variable<int>(null) else Variable.withInt(userId),
            if (sinceMs == null) const Variable<int>(null) else Variable.withInt(sinceMs),
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
  ///
  /// Deleted runs still count here. This row is about **effort** - how long
  /// somebody sat at the tablet - and that did happen, whatever a parent
  /// later tidied out of the record.
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

  /// Hands the stars of one group back, and only those.
  ///
  /// The runs stay untouched, so best times, the learning curve, the
  /// leaderboards and the bolts are all exactly as they were - a parent who
  /// wants a child to earn the stars again is not asking to erase the
  /// history.
  Future<void> resetStarsInGroup(int userId, LessonGroup group) async {
    final ids = lessonsInGroup(group).map((l) => l.id).toList();
    if (ids.isEmpty) return;
    // Drift's own API, so the screens watching the totals hear about it.
    await (_db.delete(_db.lessonStars)
          ..where((row) => row.userId.equals(userId) & row.lessonId.isIn(ids)))
        .go();
  }

  /// Stars per child: what every lesson is worth, added up.
  ///
  /// One row per lesson by construction, so repeating the easiest lesson can
  /// never beat trying a new one - and a group a parent has reset is simply
  /// gone from the sum.
  Stream<Map<int, int>> watchStarTotals() {
    return _db
        .customSelect(
          '''
          SELECT user_id AS user_id, SUM(stars) AS stars
          FROM lesson_stars
          GROUP BY user_id
          ''',
          readsFrom: {_db.lessonStars},
        )
        .watch()
        .map((rows) => {
              for (final row in rows)
                row.read<int>('user_id'): row.read<int>('stars'),
            });
  }

  /// Bolts per child, counted the same way the stars are: the best run of
  /// every lesson, once.
  Stream<Map<int, int>> watchBoltTotals() {
    return _db
        .customSelect(
          '''
          SELECT best.user_id AS user_id, SUM(best.bolts) AS bolts
          FROM (
            SELECT s.user_id AS user_id, MAX($_bolts) AS bolts
            FROM sessions s
            WHERE s.completed = 1 AND s.scored = 1 AND s.deleted = 0
            GROUP BY s.user_id, s.lesson_id
          ) AS best
          GROUP BY best.user_id
          ''',
          readsFrom: {_db.sessions},
        )
        .watch()
        .map((rows) => {
              for (final row in rows)
                row.read<int>('user_id'): row.read<int>('bolts'),
            });
  }

  /// How many runs of one lesson already counted for this child today.
  ///
  /// Only completed **and** scored runs: an abandoned run never counted, and
  /// one past the cap must not use up a second slot.
  Stream<int> watchScoredRunsToday({
    required int userId,
    required String lessonId,
    required int dayStartMs,
  }) =>
      _db
          .customSelect(
            '''
          SELECT COUNT(*) AS runs
          FROM sessions s
          WHERE s.user_id = ?1
            AND s.lesson_id = ?2
            AND s.completed = 1
            AND s.scored = 1
            AND s.deleted = 0
            AND s.finished_at_ms >= ?3
          ''',
            variables: [
              Variable.withInt(userId),
              Variable.withString(lessonId),
              Variable.withInt(dayStartMs),
            ],
            readsFrom: {_db.sessions},
          )
          .watch()
          .map((rows) => rows.single.read<int>('runs'));

  /// Practice in the current stretch: how many milliseconds, when it last
  /// ended, and what the day since [dayStartMs] adds up to.
  ///
  /// The day boundary is handed in rather than taken from SQL's `now`: the
  /// app has one clock, and a rule that changes at midnight has to be able to
  /// be tested at any time of day.
  ///
  /// A stretch is everything since the last gap of at least [breakMinutes]
  /// between one run ending and the next beginning. Walked out in SQL with a
  /// window function rather than in Dart - the boundary is a running sum, and
  /// pulling every session across to add them up would be the one thing this
  /// repository exists to avoid.
  ///
  /// Abandoned runs count too. A child who starts, gets bored and stops has
  /// still been sitting at the tablet.
  Stream<({int practisedMs, DateTime? lastFinishedAt, int todayMs})>
      watchPracticeStretch({
    required int userId,
    required int breakMinutes,
    required int dayStartMs,
  }) {
    return _db
        .customSelect(
          '''
          WITH ordered AS (
            SELECT s.started_at_ms                     AS started,
                   COALESCE(s.finished_at_ms, s.started_at_ms) AS ended,
                   s.total_ms                          AS ms,
                   LAG(COALESCE(s.finished_at_ms, s.started_at_ms))
                     OVER (ORDER BY s.started_at_ms)   AS prev_end
            FROM sessions s
            WHERE s.user_id = ?1
          ),
          marked AS (
            SELECT *,
                   CASE WHEN prev_end IS NULL OR started - prev_end >= ?2
                        THEN 1 ELSE 0 END AS starts_stretch
            FROM ordered
          ),
          grouped AS (
            SELECT *,
                   SUM(starts_stretch) OVER (ORDER BY started) AS stretch
            FROM marked
          )
          SELECT COALESCE(SUM(ms), 0) AS practised,
                 MAX(ended)          AS last_end,
                 (SELECT COALESCE(SUM(t.total_ms), 0)
                    FROM sessions t
                   WHERE t.user_id = ?1
                     AND t.started_at_ms >= ?3) AS today
          FROM grouped
          WHERE stretch = (SELECT MAX(stretch) FROM grouped)
          ''',
          variables: [
            Variable.withInt(userId),
            Variable.withInt(breakMinutes * 60000),
            Variable.withInt(dayStartMs),
          ],
          readsFrom: {_db.sessions},
        )
        .watch()
        .map((rows) {
          if (rows.isEmpty) {
            return (practisedMs: 0, lastFinishedAt: null, todayMs: 0);
          }
          final row = rows.single;
          final lastEnd = row.read<int?>('last_end');
          return (
            practisedMs: row.read<int>('practised'),
            lastFinishedAt: lastEnd == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(lastEnd),
            todayMs: row.read<int>('today'),
          );
        });
  }

  /// What each child has practised today, in milliseconds.
  ///
  /// Counted exactly the way the daily cap counts it: from [dayStartMs], and
  /// **including abandoned runs** - who starts and stops has still been
  /// sitting at the tablet. Anything else and the overview would say twelve
  /// minutes while the app told the child the twenty were up.
  Stream<Map<int, int>> watchPractisedToday(int dayStartMs) {
    return _db
        .customSelect(
          '''
          SELECT s.user_id AS user_id, SUM(s.total_ms) AS ms
          FROM sessions s
          WHERE s.started_at_ms >= ?1
          GROUP BY s.user_id
          ''',
          variables: [Variable.withInt(dayStartMs)],
          readsFrom: {_db.sessions},
        )
        .watch()
        .map((rows) => {
              for (final row in rows)
                row.read<int>('user_id'): row.read<int>('ms'),
            });
  }

  /// Days practised in a row, per child.
  ///
  /// Deleted runs still count: the child practised that day. A streak is not
  /// a record to be revised.
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
  /// Runs and time per day. Deleted runs count towards both - this is the
  /// practised-time side of the ledger, and deleting a run must not hand
  /// back an afternoon.
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
             a.operand_c           AS operand_c,
             a.op2                 AS op2,
             AVG(a.elapsed_ms)     AS average_ms,
             COUNT(*)              AS occurrences,
             AVG(a.wrong_attempts) AS average_wrong
      FROM attempts a
      JOIN sessions s ON s.id = a.session_id
      WHERE s.user_id = ?1 AND s.lesson_id = ?2 AND s.completed = 1
        AND s.deleted = 0
      GROUP BY a.operand_a, a.operand_b, a.op, a.form, a.operand_c, a.op2
      HAVING average_wrong > 0 OR average_ms > (
        SELECT AVG(a2.elapsed_ms) * 1.4
        FROM attempts a2
        JOIN sessions s2 ON s2.id = a2.session_id
        WHERE s2.user_id = ?1 AND s2.lesson_id = ?2 AND s2.completed = 1
          AND s2.deleted = 0
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
          c: row.read<int?>('operand_c'),
          op2: row.read<String?>('op2'),
          averageMs: row.read<double>('average_ms'),
          occurrences: row.read<int>('occurrences'),
        )
    ];
  }

  /// Removes a single run, for when a sibling scribbled through someone's
  /// lesson.
  /// Takes one run out of the record, keeping its time.
  ///
  /// Marked rather than erased. A parent tidying up may well cost a child a
  /// best time, a star or a place in the ranking - that is what deleting a
  /// run means - but the practised time has to stay, or the daily limit
  /// would come with a delete button next to it.
  ///
  /// The stars are stored, so they are worked out again from what is left.
  Future<void> deleteSession(int sessionId) async {
    final session = await (_db.select(_db.sessions)
          ..where((s) => s.id.equals(sessionId)))
        .getSingleOrNull();
    if (session == null) return;

    await (_db.update(_db.sessions)..where((s) => s.id.equals(sessionId)))
        .write(const SessionsCompanion(deleted: Value(true)));
    await _recountStars(session.userId, session.lessonId);
  }

  /// Puts marked runs back into the record.
  ///
  /// Nothing was ever erased - `deleted` is a mark, so undoing it is a
  /// matter of clearing the mark. The stars are worked out again afterwards
  /// for every child and lesson touched: a run coming back can raise them
  /// the same way losing it lowered them.
  Future<void> restoreSessions(List<int> ids) async {
    if (ids.isEmpty) return;
    final rows = await (_db.select(_db.sessions)..where((s) => s.id.isIn(ids)))
        .get();
    await (_db.update(_db.sessions)..where((s) => s.id.isIn(ids)))
        .write(const SessionsCompanion(deleted: Value(false)));
    for (final pair in {for (final row in rows) (row.userId, row.lessonId)}) {
      await _recountStars(pair.$1, pair.$2);
    }
  }

  /// Takes every abandoned run out of the record, for one child or for all,
  /// and only back to [sinceMs] where one is given.
  ///
  /// Abandoned runs are shown on purpose - "started and gave up" is worth
  /// seeing - but after a few weeks they are mostly noise between the runs a
  /// parent actually wants to read. They never earned anything, so nothing
  /// has to be worked out again. Returns how many were tidied away.
  ///
  /// Both filters are handed in so this removes **exactly what the list is
  /// showing**. Tidying the list one is looking at is a different act from
  /// silently tidying every child's whole history, and a button that did the
  /// second would be a trap.
  /// Returns the ids it marked, so the caller can offer to undo it - the
  /// rows are only marked, never erased.
  Future<List<int>> deleteIncompleteSessions({
    int? userId,
    int? sinceMs,
  }) async {
    Expression<bool> matching($SessionsTable s) =>
        s.completed.equals(false) &
        s.deleted.equals(false) &
        (userId == null ? const Constant(true) : s.userId.equals(userId)) &
        (sinceMs == null
            ? const Constant(true)
            : coalesce([s.finishedAtMs, s.startedAtMs])
                .isBiggerOrEqualValue(sinceMs));

    final rows = await (_db.select(_db.sessions)..where(matching)).get();
    await (_db.update(_db.sessions)..where(matching))
        .write(const SessionsCompanion(deleted: Value(true)));
    return [for (final row in rows) row.id];
  }

  /// Rebuilds the stored stars of one lesson from the runs that are left.
  ///
  /// In Dart and through [starsFor], not in SQL: since v8 that rule lives in
  /// exactly one place, and a second copy here would be the very thing the
  /// stored stars were meant to end.
  Future<void> _recountStars(int userId, String lessonId) async {
    final lesson = lessonByIdOrNull(lessonId);
    if (lesson == null) return;

    final left = await (_db.select(_db.sessions)
          ..where((s) =>
              s.userId.equals(userId) &
              s.lessonId.equals(lessonId) &
              s.completed.equals(true) &
              s.scored.equals(true) &
              s.deleted.equals(false)))
        .get();

    var best = 0;
    for (final run in left) {
      final stars = starsFor(run.wrongAttempts, run.taskCount,
          scored: lesson.scored);
      if (stars > best) best = stars;
    }

    final row = _db.lessonStars;
    if (best <= 0) {
      await (_db.delete(row)
            ..where((r) => r.userId.equals(userId) & r.lessonId.equals(lessonId)))
          .go();
      return;
    }
    await _db.into(row).insertOnConflictUpdate(
          LessonStarsCompanion.insert(
            userId: userId,
            lessonId: lessonId,
            stars: best,
          ),
        );
  }

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
             a.operand_c          AS operand_c,
             a.op2                AS op2,
             AVG(a.elapsed_ms)    AS average_ms,
             COUNT(*)             AS occurrences,
             AVG(a.wrong_attempts) AS average_wrong
      FROM attempts a
      JOIN sessions s ON s.id = a.session_id
      WHERE s.user_id = ?1 AND s.completed = 1 AND s.deleted = 0
      GROUP BY a.operand_a, a.operand_b, a.op, a.form, a.operand_c, a.op2
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
          c: row.read<int?>('operand_c'),
          op2: row.read<String?>('op2'),
          averageMs: row.read<double>('average_ms'),
          occurrences: row.read<int>('occurrences'),
        )
    ];
  }
}
