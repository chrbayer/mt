import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Marker so an unrelated JSON file cannot be fed in by accident.
const _backupMarker = 'mathe_trainer_backup';

/// What an import brought in, for the confirmation afterwards.
class BackupSummary {
  final int users;
  final int sessions;
  final int attempts;
  final DateTime? exportedAt;

  const BackupSummary({
    required this.users,
    required this.sessions,
    required this.attempts,
    required this.exportedAt,
  });
}

/// Thrown when a file is not a backup of this app, or is damaged.
class BackupFormatException implements Exception {
  final String message;

  const BackupFormatException(this.message);

  @override
  String toString() => message;
}

/// Reads and writes the whole database as one JSON document.
///
/// Everything lives in a single SQLite file on a single tablet - a reset
/// device would take months of results with it. JSON rather than a copy of
/// the database file because it survives a schema change: an export from an
/// older version can still be read back.
class BackupRepository {
  final AppDatabase _db;

  BackupRepository(this._db);

  Future<String> export() async {
    final users = await _db.select(_db.users).get();
    final sessions = await _db.select(_db.sessions).get();
    final attempts = await _db.select(_db.attempts).get();
    final settings = await _db.select(_db.appSettings).get();
    final lessonPrefs = await _db.select(_db.lessonPreferences).get();

    return const JsonEncoder.withIndent('  ').convert({
      'format': _backupMarker,
      'schemaVersion': _db.schemaVersion,
      'exportedAtMs': DateTime.now().millisecondsSinceEpoch,
      'users': [
        for (final user in users)
          {
            'id': user.id,
            'name': user.name,
            'avatar': user.avatar,
            'colorIndex': user.colorIndex,
            'createdAtMs': user.createdAtMs,
            'hiddenGroups': user.hiddenGroups,
            'reviewHardTasks': user.reviewHardTasks,
            'defaultTaskCount': user.defaultTaskCount,
            'practiceLimitMinutes': user.practiceLimitMinutes,
            'breakMinutes': user.breakMinutes,
            'dailyLimitMinutes': user.dailyLimitMinutes,
          }
      ],
      'sessions': [
        for (final session in sessions)
          {
            'id': session.id,
            'userId': session.userId,
            'lessonId': session.lessonId,
            'taskCount': session.taskCount,
            'seed': session.seed,
            'startedAtMs': session.startedAtMs,
            'finishedAtMs': session.finishedAtMs,
            'totalMs': session.totalMs,
            'wrongAttempts': session.wrongAttempts,
            'completed': session.completed,
          }
      ],
      'attempts': [
        for (final attempt in attempts)
          {
            'id': attempt.id,
            'sessionId': attempt.sessionId,
            'position': attempt.position,
            'operandA': attempt.operandA,
            'operandB': attempt.operandB,
            'op': attempt.op,
            'form': attempt.form,
            'expected': attempt.expected,
            'elapsedMs': attempt.elapsedMs,
            'wrongAttempts': attempt.wrongAttempts,
          }
      ],
      'settings': [
        for (final setting in settings)
          {'key': setting.settingKey, 'value': setting.settingValue}
      ],
      'lessonPreferences': [
        for (final pref in lessonPrefs)
          {
            'userId': pref.userId,
            'lessonId': pref.lessonId,
            'taskCount': pref.taskCount,
          }
      ],
    });
  }

  /// Replaces everything with the contents of [json].
  ///
  /// A restore, not a merge: ids from two tablets would collide, and silently
  /// half-merged results are worse than a clear "this is now that backup".
  /// The PIN is part of it - a backup should not lock a parent out.
  Future<BackupSummary> import(String json) async {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(json) as Map<String, dynamic>;
    } on FormatException {
      throw const BackupFormatException('Die Datei ist keine gültige Sicherung.');
    }

    if (data['format'] != _backupMarker) {
      throw const BackupFormatException(
        'Diese Datei stammt nicht aus dem Mathe-Trainer.',
      );
    }
    final version = data['schemaVersion'];
    if (version is! int || version > _db.schemaVersion) {
      throw const BackupFormatException(
        'Die Sicherung stammt aus einer neueren Version der App.',
      );
    }

    List<Map<String, dynamic>> rows(String key) => [
          for (final row in (data[key] as List? ?? const []))
            row as Map<String, dynamic>
        ];

    final users = rows('users');
    final sessions = rows('sessions');
    final attempts = rows('attempts');
    final settings = rows('settings');
    final lessonPrefs = rows('lessonPreferences');

    await _db.transaction(() async {
      // Order matters: attempts hang off sessions, sessions off users.
      await _db.delete(_db.lessonPreferences).go();
      await _db.delete(_db.attempts).go();
      await _db.delete(_db.sessions).go();
      await _db.delete(_db.users).go();
      await _db.delete(_db.appSettings).go();

      for (final user in users) {
        await _db.into(_db.users).insert(
              UsersCompanion.insert(
                id: Value(user['id'] as int),
                name: user['name'] as String,
                avatar: user['avatar'] as String,
                colorIndex: user['colorIndex'] as int,
                createdAtMs: user['createdAtMs'] as int,
                // Missing in backups from before these columns existed.
                hiddenGroups: Value(user['hiddenGroups'] as String? ?? ''),
                reviewHardTasks:
                    Value(user['reviewHardTasks'] as bool? ?? true),
                defaultTaskCount: Value(user['defaultTaskCount'] as int?),
                // An older backup knows of no cap, and no cap is the
                // default - a restore must not invent one.
                practiceLimitMinutes:
                    Value(user['practiceLimitMinutes'] as int? ?? 0),
                breakMinutes: Value(user['breakMinutes'] as int? ?? 15),
                dailyLimitMinutes:
                    Value(user['dailyLimitMinutes'] as int? ?? 0),
              ),
            );
      }
      for (final session in sessions) {
        await _db.into(_db.sessions).insert(
              SessionsCompanion.insert(
                id: Value(session['id'] as int),
                userId: session['userId'] as int,
                lessonId: session['lessonId'] as String,
                taskCount: session['taskCount'] as int,
                seed: session['seed'] as int,
                startedAtMs: session['startedAtMs'] as int,
                finishedAtMs: Value(session['finishedAtMs'] as int?),
                totalMs: Value(session['totalMs'] as int? ?? 0),
                wrongAttempts: Value(session['wrongAttempts'] as int? ?? 0),
                completed: Value(session['completed'] as bool? ?? false),
              ),
            );
      }
      for (final attempt in attempts) {
        await _db.into(_db.attempts).insert(
              AttemptsCompanion.insert(
                id: Value(attempt['id'] as int),
                sessionId: attempt['sessionId'] as int,
                position: attempt['position'] as int,
                operandA: attempt['operandA'] as int,
                operandB: attempt['operandB'] as int,
                op: attempt['op'] as String,
                form: attempt['form'] as String,
                expected: attempt['expected'] as int,
                elapsedMs: attempt['elapsedMs'] as int,
                wrongAttempts: attempt['wrongAttempts'] as int,
              ),
            );
      }
      for (final setting in settings) {
        await _db.into(_db.appSettings).insert(
              AppSettingsCompanion.insert(
                settingKey: setting['key'] as String,
                settingValue: setting['value'] as String,
              ),
            );
      }
      for (final pref in lessonPrefs) {
        await _db.into(_db.lessonPreferences).insert(
              LessonPreferencesCompanion.insert(
                userId: pref['userId'] as int,
                lessonId: pref['lessonId'] as String,
                taskCount: pref['taskCount'] as int,
              ),
            );
      }
    });

    final exportedAtMs = data['exportedAtMs'];
    return BackupSummary(
      users: users.length,
      sessions: sessions.length,
      attempts: attempts.length,
      exportedAt: exportedAtMs is int
          ? DateTime.fromMillisecondsSinceEpoch(exportedAtMs)
          : null,
    );
  }
}
