/// Local SQLite storage. The app is fully offline; this database is the only
/// place where profiles and results live.
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

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

@DriftDatabase(
    tables: [Users, Sessions, Attempts, AppSettings, LessonPreferences])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'mathe_trainer'));

  @override
  int get schemaVersion => 6;

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
            await m.alterTable(TableMigration(users));
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
        },
        beforeOpen: (details) async {
          // Needed for the ON DELETE CASCADE above to actually fire.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
