import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';

import 'package:crypto/crypto.dart';

import '../../domain/practice_limit.dart';
import '../../domain/task_count.dart';
import '../db/app_database.dart';

/// App-wide preferences, stored as strings in a small key/value table.
class AppPreferences {
  /// Show a running clock during practice. Off by default - visible time
  /// pressure makes children slower, while the measurement happens anyway.
  final bool showClock;
  final bool haptics;

  /// Task count preselected when a lesson is opened.
  final int defaultTaskCount;

  /// The time limits that hold for every child without their own.
  final PracticeLimits limits;

  const AppPreferences({
    this.showClock = false,
    this.haptics = true,
    this.defaultTaskCount = fallbackTaskCount,
    this.limits = const PracticeLimits(),
  });

  AppPreferences copyWith({
    bool? showClock,
    bool? haptics,
    int? defaultTaskCount,
    PracticeLimits? limits,
  }) =>
      AppPreferences(
        showClock: showClock ?? this.showClock,
        haptics: haptics ?? this.haptics,
        defaultTaskCount: defaultTaskCount ?? this.defaultTaskCount,
        limits: limits ?? this.limits,
      );
}

/// Length of the parent-area PIN. Four digits, entered on the app's own
/// keypad - long enough to keep a sibling out, short enough to remember.
const int adminPinLength = 4;

class SettingsRepository {
  static const _showClock = 'show_clock';
  static const _haptics = 'haptics';
  static const _defaultTaskCount = 'default_task_count';
  static const _stretchMinutes = 'practice_limit_minutes';
  static const _breakMinutes = 'break_minutes';
  static const _dailyMinutes = 'daily_limit_minutes';
  static const _pinSalt = 'admin_pin_salt';
  static const _pinHash = 'admin_pin_hash';

  final AppDatabase _db;

  SettingsRepository(this._db);

  Stream<AppPreferences> watch() =>
      _db.select(_db.appSettings).watch().map(_fromRows);

  Future<AppPreferences> load() async =>
      _fromRows(await _db.select(_db.appSettings).get());

  AppPreferences _fromRows(List<AppSetting> rows) {
    final map = {for (final row in rows) row.settingKey: row.settingValue};
    const defaults = AppPreferences();
    return AppPreferences(
      showClock: map[_showClock] == '1' ? true : defaults.showClock,
      haptics: map[_haptics] == null ? defaults.haptics : map[_haptics] == '1',
      defaultTaskCount:
          int.tryParse(map[_defaultTaskCount] ?? '') ?? defaults.defaultTaskCount,
      limits: PracticeLimits(
        stretchMinutes: int.tryParse(map[_stretchMinutes] ?? '') ??
            defaults.limits.stretchMinutes,
        breakMinutes: int.tryParse(map[_breakMinutes] ?? '') ??
            defaults.limits.breakMinutes,
        dailyMinutes: int.tryParse(map[_dailyMinutes] ?? '') ??
            defaults.limits.dailyMinutes,
      ),
    );
  }

  Future<void> setShowClock(bool value) => _put(_showClock, value ? '1' : '0');

  Future<void> setHaptics(bool value) => _put(_haptics, value ? '1' : '0');

  Future<void> setDefaultTaskCount(int value) =>
      _put(_defaultTaskCount, '$value');

  /// The time limits for every child who has none of their own.
  Future<void> setPracticeLimits(PracticeLimits limits) async {
    await _put(_stretchMinutes, '${limits.stretchMinutes}');
    await _put(_breakMinutes, '${limits.breakMinutes}');
    await _put(_dailyMinutes, '${limits.dailyMinutes}');
  }

  /// What this child last chose for this lesson, if anything.
  Stream<int?> watchLessonTaskCount(int userId, String lessonId) =>
      (_db.select(_db.lessonPreferences)
            ..where((p) => p.userId.equals(userId) & p.lessonId.equals(lessonId)))
          .watchSingleOrNull()
          .map((row) => row?.taskCount);

  Future<void> setLessonTaskCount({
    required int userId,
    required String lessonId,
    required int count,
  }) =>
      _db.into(_db.lessonPreferences).insertOnConflictUpdate(
            LessonPreferencesCompanion.insert(
              userId: userId,
              lessonId: lessonId,
              taskCount: count,
            ),
          );

  // --- Parent area -----------------------------------------------------
  //
  // The PIN keeps a curious sibling out of the history and the reset button;
  // it is not protecting secrets. It is still stored salted and hashed rather
  // than in the clear, so a glance at the database never reveals it.

  /// Whether a PIN has been chosen yet. On first use the parent area asks for
  /// a new one instead of an existing one.
  Future<bool> hasAdminPin() async => (await _get(_pinHash)) != null;

  Future<void> setAdminPin(String pin) async {
    final salt = _randomSalt();
    await _put(_pinSalt, salt);
    await _put(_pinHash, _hashPin(pin, salt));
  }

  Future<bool> checkAdminPin(String pin) async {
    final salt = await _get(_pinSalt);
    final hash = await _get(_pinHash);
    if (salt == null || hash == null) return false;
    return _hashPin(pin, salt) == hash;
  }

  /// Forgets the PIN, so the next visit to the parent area sets a new one.
  /// This is how "change PIN" works - there is nothing to gain from asking
  /// for the old one first, the parent just got past it.
  Future<void> clearAdminPin() async {
    await (_db.delete(_db.appSettings)
          ..where((s) => s.settingKey.isIn([_pinSalt, _pinHash])))
        .go();
  }

  static String _hashPin(String pin, String salt) =>
      sha256.convert(utf8.encode('$salt:$pin')).toString();

  static String _randomSalt() {
    final random = Random.secure();
    return base64Url.encode(List.generate(16, (_) => random.nextInt(256)));
  }

  Future<String?> _get(String key) async {
    final row = await (_db.select(_db.appSettings)
          ..where((s) => s.settingKey.equals(key)))
        .getSingleOrNull();
    return row?.settingValue;
  }

  Future<void> _put(String key, String value) =>
      _db.into(_db.appSettings).insertOnConflictUpdate(
            AppSettingsCompanion.insert(settingKey: key, settingValue: value),
          );
}
