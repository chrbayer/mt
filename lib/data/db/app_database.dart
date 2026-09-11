/// Local SQLite storage. The app is fully offline; this database is the only
/// place where profiles and results live.
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/lesson.dart';
import '../../domain/scoring.dart';

part 'app_database.g.dart';

/// A child's profile. No password - a tap on the tile is the login.
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 20)();

  /// A single emoji, picked from a fixed list in the UI.
  TextColumn get avatar => text()();

  /// Index into the app's profile colour palette.
  IntColumn get colorIndex => integer()();
  IntColumn get createdAtMs => integer()();

  /// Lesson groups this child does not see, as a comma-separated list of
  /// [LessonGroup] names. Storing what is *hidden* rather than what is shown
  /// means a group added in a later version appears for everyone instead of
  /// silently staying invisible.
  TextColumn get hiddenGroups => text().withDefault(const Constant(''))();

  /// Whether runs mix in calculations this child was slow or wrong on last
  /// time. On by default: practising what already works is the least useful
  /// thing an exercise app can do.
  BoolColumn get reviewHardTasks =>
      boolean().withDefault(const Constant(true))();

  /// How many tasks a run starts with for this child. Null means "whatever is
  /// set for everyone".
  IntColumn get defaultTaskCount => integer().nullable()();

  /// Longest stretch of practice this child may do before a break, in
  /// minutes. Null takes the app-wide setting; zero is a decision - this
  /// child has no stretch limit.
  IntColumn get practiceLimitMinutes => integer().nullable()();

  /// How long the break has to be before a new stretch may start. Also what
  /// separates one stretch from the next when the time is added up. Null
  /// takes the app-wide setting.
  IntColumn get breakMinutes => integer().nullable()();

  /// Total practice this child may do in one day, in minutes. Null takes the
  /// app-wide setting, zero means this child has no daily limit. Independent
  /// of the stretch cap: enough breaks would otherwise add up to an
  /// afternoon.
  IntColumn get dailyLimitMinutes => integer().nullable()();

  /// Which finished lessons the catalogue leaves out, as a [LessonFilter]
  /// name. Stored as a name rather than an index so a reordered enum cannot
  /// silently turn one setting into another.
  TextColumn get lessonFilter =>
      text().withDefault(const Constant('all'))();

  /// How many runs of one lesson may earn something on one day. Null takes
  /// the app-wide setting, zero means this child has no cap.
  IntColumn get scoredRunsPerLesson => integer().nullable()();

  /// Whether a parent has put this profile aside for now.
  ///
  /// A pause, not a deletion: everything the child collected stays exactly
  /// where it is and comes back untouched when the lock is lifted. That is
  /// the point - a parent who wants to stop the tablet for a while should not
  /// have to choose between nagging and destroying a year of best times.
  BoolColumn get locked => boolean().withDefault(const Constant(false))();
}

/// What one child last chose for one lesson.
///
/// Changing the length while starting a lesson is a decision about *that*
/// lesson - ten counting tasks and fifty times-table drills are both right.
/// It must not silently become everyone's default.
class LessonPreferences extends Table {
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get lessonId => text()();
  IntColumn get taskCount => integer()();

  @override
  Set<Column> get primaryKey => {userId, lessonId};
}

/// Stars a child has earned per lesson.
///
/// Stored rather than derived from the runs, because a parent can hand the
/// stars of a whole group back without touching the times behind them. Once
/// the two can differ, only a stored value can say what was actually earned.
class LessonStars extends Table {
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get lessonId => text()();

  /// The best a single run of this lesson was ever worth. Never goes down on
  /// its own - only a parent's reset takes it away.
  IntColumn get stars => integer()();

  @override
  Set<Column> get primaryKey => {userId, lessonId};
}

/// One practice run. Timestamps are epoch milliseconds so the raw SQL in the
/// statistics repositories stays unambiguous.
class Sessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();

  /// Stable [LessonSpec.id], never a foreign key - lessons live in code.
  TextColumn get lessonId => text()();
  IntColumn get taskCount => integer()();
  IntColumn get seed => integer()();
  IntColumn get startedAtMs => integer()();
  IntColumn get finishedAtMs => integer().nullable()();

  /// Summed time of all tasks, excluding paused time.
  IntColumn get totalMs => integer().withDefault(const Constant(0))();
  IntColumn get wrongAttempts => integer().withDefault(const Constant(0))();

  /// Only completed runs count for statistics and leaderboards.
  BoolColumn get completed => boolean().withDefault(const Constant(false))();

  /// Whether this run was allowed to earn anything: a best time, stars,
  /// bolts, a place in the ranking. Runs past the daily cap for their lesson
  /// are stored with this false - they are practice, and they count towards
  /// the day's time, but they set no records.
  ///
  /// Decided once, when the run finishes, and stored: working it out again
  /// later would need the cap as it stood that day, and a parent may change
  /// it tomorrow.
  BoolColumn get scored => boolean().withDefault(const Constant(true))();

  /// Whether a parent has removed this run from the record.
  ///
  /// Removed, not erased: the row stays so the **practised time** stays.
  /// Deleting a run may cost stars, bolts and a place in the ranking - that
  /// is what a parent tidying up is asking for - but it must not hand back
  /// an afternoon of screen time. Otherwise the daily limit would have a
  /// delete button next to it.
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
}

/// One task within a session - the basis for "which calculations are slow?".
class Attempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId =>
      integer().references(Sessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  IntColumn get operandA => integer()();
  IntColumn get operandB => integer()();
  TextColumn get op => text()();
  TextColumn get form => text()();

  /// The third operand and second operation of a Punkt-vor-Strich task
  /// ([TaskForm.chain]). Null for every other form - two operands were the
  /// whole task before this one, and null is the true reading of that, not
  /// a missing value.
  IntColumn get operandC => integer().nullable()();
  TextColumn get op2 => text().nullable()();
  IntColumn get expected => integer()();
  IntColumn get elapsedMs => integer()();
  IntColumn get wrongAttempts => integer()();
}

/// Simple key/value store for app-wide preferences.
class AppSettings extends Table {
  TextColumn get settingKey => text()();
  TextColumn get settingValue => text()();

  @override
  Set<Column> get primaryKey => {settingKey};
}

/// A parent-set goal: one lesson, one rhythm, a minimum length and quality,
/// for one child. Never updated in place - see `domain/assignment.dart` for
/// why - only its [endedAtMs] is ever written after creation.
///
/// Named `AssignmentRow` rather than the default `Assignment`: that name
/// already belongs to the domain class this row is read into, and the two
/// must not collide.
@DataClassName('AssignmentRow')
class Assignments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId =>
      integer().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get lessonId => text()();

  /// [AssignmentRhythm] name, not index - the same caution as
  /// `hidden_groups` and `lesson_filter`: a reordered enum must not
  /// silently turn one rhythm into another.
  /// The rhythm is the whole deadline - a day, or a week ending Sunday
  /// night. v13 also held an hour and a weekday here; see the migration to
  /// v14 for why they went.
  TextColumn get rhythm => text()();
  IntColumn get runs => integer()();
  IntColumn get taskCount => integer()();
  IntColumn get minStars => integer()();
  IntColumn get minBolts => integer()();
  IntColumn get createdAtMs => integer()();
  IntColumn get endedAtMs => integer().nullable()();
}

@DriftDatabase(tables: [
  Users,
  Sessions,
  Attempts,
  AppSettings,
  LessonPreferences,
  LessonStars,
  Assignments,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'mathe_trainer'));

  @override
  int get schemaVersion => 14;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          // v2 lets a parent hide whole lesson groups per child.
          if (from < 2) await m.addColumn(users, users.hiddenGroups);
          // v3 weaves previously difficult tasks back into a run.
          if (from < 3) await m.addColumn(users, users.reviewHardTasks);
          // v4 remembers the run length per profile and per lesson.
          if (from < 4) {
            await m.addColumn(users, users.defaultTaskCount);
            await m.createTable(lessonPreferences);
          }
          // v5 can cap how long a child practises in one stretch.
          if (from < 5) {
            await m.addColumn(users, users.practiceLimitMinutes);
            await m.addColumn(users, users.breakMinutes);
            await m.addColumn(users, users.dailyLimitMinutes);
          }
          // v6 lets the caps be set once for everyone, so a profile may now
          // say "as for everyone" (null) as well as "none" (zero).
          if (from < 6) {
            // The rebuild takes the table as it looks *now*, so every column
            // added after v6 comes along for the ride and has to be declared
            // as new - otherwise the copy looks for it in the old table.
            await m.alterTable(
              TableMigration(users, newColumns: [
                users.lessonFilter,
                users.scoredRunsPerLesson,
                users.locked,
              ]),
            );
            // A profile still carrying what v5 handed it never had a decision
            // made about it, so it follows the app-wide setting from now on.
            // Anything a parent actually chose stays as chosen.
            await m.database.customStatement(
              'UPDATE users SET practice_limit_minutes = NULL '
              'WHERE practice_limit_minutes = 0',
            );
            await m.database.customStatement(
              'UPDATE users SET break_minutes = NULL WHERE break_minutes = 15',
            );
            await m.database.customStatement(
              'UPDATE users SET daily_limit_minutes = NULL '
              'WHERE daily_limit_minutes = 0',
            );
          }
          // v7 can leave finished lessons out of the catalogue. Only needed
          // when the rebuild above did not already run.
          if (from == 6) await m.addColumn(users, users.lessonFilter);
          // v8 keeps the stars instead of working them out from the runs, so
          // that a parent can hand them back without losing the times.
          if (from < 8) {
            await m.createTable(lessonStars);
            await _carryStarsOver(m.database);
          }
          // v9 caps how many runs of one lesson may earn something in a day.
          // Everything already in the database was earned under no cap and
          // keeps counting: the column's default of true is exactly right,
          // and nobody loses a best time to a rule made after the fact.
          if (from < 9) {
            // Only where the v6 rebuild above did not already bring it along.
            if (from >= 6) await m.addColumn(users, users.scoredRunsPerLesson);
            await m.addColumn(sessions, sessions.scored);
          }
          // v10 lets a parent take a run out of the record while its time
          // stays counted. Nothing was ever deleted before, so the column's
          // default of false is the whole migration.
          if (from < 10) await m.addColumn(sessions, sessions.deleted);
          // v11 lets a parent put a profile aside for a while. Nobody was
          // ever locked before, so the default of false is the migration -
          // and again only where the v6 rebuild did not already bring the
          // column along.
          if (from < 11 && from >= 6) {
            await m.addColumn(users, users.locked);
          }
          // v12 lets a task carry three operands (Punkt vor Strich). Every
          // task recorded before this had two - null is the truth there, not
          // a gap.
          if (from < 12) {
            await m.addColumn(attempts, attempts.operandC);
            await m.addColumn(attempts, attempts.op2);
          }
          // v13 lets a parent assign a lesson, a rhythm and a minimum length
          // and quality. Nothing to carry over - there were no assignments
          // before this.
          if (from < 13) await m.createTable(assignments);
          // v14 drops the hour-of-day and weekday an assignment used to be
          // due at. A day or a week is the whole deadline now: a child does
          // not watch the clock, and the finer setting was precision nobody
          // acted on. Rebuilding the table copies every column that is still
          // declared and leaves those two behind.
          //
          // Nothing is lost by it. The end of a day lies after any time that
          // could have been set, so no assignment already in the database
          // becomes missed in hindsight.
          if (from >= 13 && from < 14) {
            await m.alterTable(TableMigration(assignments));
          }
        },
        beforeOpen: (details) async {
          // Needed for the ON DELETE CASCADE above to actually fire.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// Fills the star table once, from the runs that are already there.
///
/// Nobody may lose what they collected because the app changed how it keeps
/// score. This is the same rule the statistics used to apply on the fly, run
/// exactly once: the best a single completed run of each lesson was worth.
///
/// Written out here rather than reusing the repository's expression: that one
/// stops existing after this migration, and a migration has to keep working
/// against the schema of its own moment.
Future<void> _carryStarsOver(DatabaseConnectionUser db) async {
  final unscored = unscoredLessonIds.map((id) => "'$id'").join(', ');
  await db.customStatement('''
    INSERT INTO lesson_stars (user_id, lesson_id, stars)
    SELECT s.user_id, s.lesson_id, MAX(
      CASE
        WHEN s.lesson_id IN ($unscored) THEN $maxStars
        WHEN s.task_count < $minTasksForAward THEN 0
        WHEN s.wrong_attempts * 1.0 / s.task_count <= $threeStarErrorRate
          THEN $maxStars
        WHEN s.wrong_attempts * 1.0 / s.task_count <= $twoStarErrorRate
          THEN 2
        ELSE 1
      END)
    FROM sessions s
    WHERE s.completed = 1
    GROUP BY s.user_id, s.lesson_id
  ''');
}
