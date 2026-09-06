import 'package:drift/drift.dart';

import '../../domain/lesson.dart';
import '../db/app_database.dart';

/// Reads the per-child group visibility out of its stored representation.
extension UserVisibleGroups on User {
  /// Groups this child does not see. Names that no longer exist are ignored,
  /// so a downgrade cannot corrupt the setting.
  Set<LessonGroup> get hidden => {
        for (final name in hiddenGroups.split(','))
          for (final group in LessonGroup.values)
            if (group.name == name) group,
      };

  bool shows(LessonGroup group) => !hidden.contains(group);

  /// The groups to offer this child, in catalog order.
  List<LessonGroup> get visibleGroups =>
      LessonGroup.values.where(shows).toList(growable: false);
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

  /// Turns the review of previously difficult tasks on or off for one child.
  Future<void> setReviewHardTasks(int id, bool value) =>
      (_db.update(_db.users)..where((u) => u.id.equals(id)))
          .write(UsersCompanion(reviewHardTasks: Value(value)));

  /// Hides or shows whole lesson groups for one child - a first-grader has no
  /// business being offered "Bis 1000".
  Future<void> setHiddenGroups(int id, Set<LessonGroup> hidden) {
    // Written in enum order so the stored string is stable and comparable.
    final names =
        LessonGroup.values.where(hidden.contains).map((g) => g.name).join(',');
    return (_db.update(_db.users)..where((u) => u.id.equals(id)))
        .write(UsersCompanion(hiddenGroups: Value(names)));
  }

  /// Keeps the profile but throws away all results.
  Future<void> resetStatistics(int userId) =>
      (_db.delete(_db.sessions)..where((s) => s.userId.equals(userId))).go();
}
