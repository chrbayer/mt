import 'package:drift/drift.dart';

import '../../domain/group_visibility.dart' as groups;
import '../../domain/lesson.dart';
import '../../domain/lesson_filter.dart';
import '../db/app_database.dart';

/// Reads the per-child group visibility out of its stored representation.
extension UserVisibleGroups on User {
  /// Groups this child does not see. Names that no longer exist are ignored,
  /// so a downgrade cannot corrupt the setting.
  Set<LessonGroup> get hidden => groups.groupsByName(hiddenGroups);

  /// The groups the stored decision was made against. Empty means all of
  /// them - see [knownGroups].
  Set<LessonGroup> get known => groups.groupsByName(knownGroups);

  /// The groups to offer this child, in catalog order. A group added since
  /// this profile was last looked at only comes along if it borders one the
  /// child already has.
  List<LessonGroup> get visibleGroups => List.unmodifiable(
        groups.visibleGroups(hidden: hidden, known: known),
      );

  bool shows(LessonGroup group) => visibleGroups.contains(group);

  /// Which finished lessons this child's catalogue leaves out.
  LessonFilter get filter => lessonFilterByName(lessonFilter);
}

/// Profiles: create, rename, delete, and wipe a child's results.
class UserRepository {
  final AppDatabase _db;

  UserRepository(this._db);

  Stream<List<User>> watchUsers() =>
      (_db.select(_db.users)..orderBy([(u) => OrderingTerm(expression: u.id)]))
          .watch();

  Future<List<User>> allUsers() =>
      (_db.select(_db.users)..orderBy([(u) => OrderingTerm(expression: u.id)]))
          .get();

  Future<User?> findUser(int id) =>
      (_db.select(_db.users)..where((u) => u.id.equals(id)))
          .getSingleOrNull();

  Future<int> createUser({
    required String name,
    required String avatar,
    required int colorIndex,
  }) =>
      _db.into(_db.users).insert(
            UsersCompanion.insert(
              name: name,
              avatar: avatar,
              colorIndex: colorIndex,
              createdAtMs: DateTime.now().millisecondsSinceEpoch,
              // A fresh profile sees the whole catalogue, and it has seen all
              // of it: nothing here is new to a decision made just now.
              knownGroups: Value(groups.allGroupNames),
            ),
          );

  Future<void> updateUser({
    required int id,
    required String name,
    required String avatar,
    required int colorIndex,
  }) =>
      (_db.update(_db.users)..where((u) => u.id.equals(id))).write(
        UsersCompanion(
          name: Value(name),
          avatar: Value(avatar),
          colorIndex: Value(colorIndex),
        ),
      );

  /// Removes the profile; sessions and attempts follow via ON DELETE CASCADE.
  Future<void> deleteUser(int id) =>
      (_db.delete(_db.users)..where((u) => u.id.equals(id))).go();

  /// Sets how long this child's runs start out. Null falls back to the
  /// app-wide default.
  Future<void> setProfileTaskCount(int id, int? count) =>
      (_db.update(_db.users)..where((u) => u.id.equals(id)))
          .write(UsersCompanion(defaultTaskCount: Value(count)));

  /// Sets how long this child may practise in one stretch, and how long the
  /// break has to be. A limit of zero switches the cap off.
  /// Null for any of them means "as for everyone" - a stored zero is a
  /// decision, so the two must not be collapsed into one.
  Future<void> setPracticeLimit(
    int id, {
    required int? limitMinutes,
    required int? breakMinutes,
    required int? dailyLimitMinutes,
  }) =>
      (_db.update(_db.users)..where((u) => u.id.equals(id))).write(
        UsersCompanion(
          practiceLimitMinutes: Value(limitMinutes),
          breakMinutes: Value(breakMinutes),
          dailyLimitMinutes: Value(dailyLimitMinutes),
        ),
      );

  /// Sets how many runs of one lesson may still earn something in a day for
  /// this child. Null means "as for everyone", zero means no cap.
  Future<void> setScoredRunsPerLesson(int id, int? runs) =>
      (_db.update(_db.users)..where((u) => u.id.equals(id)))
          .write(UsersCompanion(scoredRunsPerLesson: Value(runs)));

  /// Puts a profile aside, or brings it back.
  ///
  /// Nothing is removed: the runs, the stars and the best times stay exactly
  /// as they are and return the moment the lock is lifted.
  Future<void> setLocked(int id, bool locked) =>
      (_db.update(_db.users)..where((u) => u.id.equals(id)))
          .write(UsersCompanion(locked: Value(locked)));

  /// Turns the review of previously difficult tasks on or off for one child.
  Future<void> setReviewHardTasks(int id, bool value) =>
      (_db.update(_db.users)..where((u) => u.id.equals(id)))
          .write(UsersCompanion(reviewHardTasks: Value(value)));

  /// Sets how much of a finished lesson has to be done before it drops out
  /// of this child's catalogue.
  Future<void> setLessonFilter(int id, LessonFilter filter) =>
      (_db.update(_db.users)..where((u) => u.id.equals(id)))
          .write(UsersCompanion(lessonFilter: Value(filter.name)));

  /// Hides or shows whole lesson groups for one child - a first-grader has no
  /// business being offered "Bis 1000".
  Future<void> setHiddenGroups(int id, Set<LessonGroup> hidden) =>
      (_db.update(_db.users)..where((u) => u.id.equals(id))).write(
        UsersCompanion(
          hiddenGroups: Value(groups.groupNames(hidden)),
          // Whoever just decided this had the whole catalogue in front of
          // them, so from here on none of it is new to this profile.
          knownGroups: Value(groups.allGroupNames),
        ),
      );

  /// Keeps the profile but throws away all results.
  Future<void> resetStatistics(int userId) =>
      (_db.delete(_db.sessions)..where((s) => s.userId.equals(userId))).go();
}
