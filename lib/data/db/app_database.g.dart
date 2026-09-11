// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 20,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
    'avatar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorIndexMeta = const VerificationMeta(
    'colorIndex',
  );
  @override
  late final GeneratedColumn<int> colorIndex = GeneratedColumn<int>(
    'color_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hiddenGroupsMeta = const VerificationMeta(
    'hiddenGroups',
  );
  @override
  late final GeneratedColumn<String> hiddenGroups = GeneratedColumn<String>(
    'hidden_groups',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _knownGroupsMeta = const VerificationMeta(
    'knownGroups',
  );
  @override
  late final GeneratedColumn<String> knownGroups = GeneratedColumn<String>(
    'known_groups',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _reviewHardTasksMeta = const VerificationMeta(
    'reviewHardTasks',
  );
  @override
  late final GeneratedColumn<bool> reviewHardTasks = GeneratedColumn<bool>(
    'review_hard_tasks',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("review_hard_tasks" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _defaultTaskCountMeta = const VerificationMeta(
    'defaultTaskCount',
  );
  @override
  late final GeneratedColumn<int> defaultTaskCount = GeneratedColumn<int>(
    'default_task_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _practiceLimitMinutesMeta =
      const VerificationMeta('practiceLimitMinutes');
  @override
  late final GeneratedColumn<int> practiceLimitMinutes = GeneratedColumn<int>(
    'practice_limit_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _breakMinutesMeta = const VerificationMeta(
    'breakMinutes',
  );
  @override
  late final GeneratedColumn<int> breakMinutes = GeneratedColumn<int>(
    'break_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyLimitMinutesMeta = const VerificationMeta(
    'dailyLimitMinutes',
  );
  @override
  late final GeneratedColumn<int> dailyLimitMinutes = GeneratedColumn<int>(
    'daily_limit_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lessonFilterMeta = const VerificationMeta(
    'lessonFilter',
  );
  @override
  late final GeneratedColumn<String> lessonFilter = GeneratedColumn<String>(
    'lesson_filter',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('all'),
  );
  static const VerificationMeta _scoredRunsPerLessonMeta =
      const VerificationMeta('scoredRunsPerLesson');
  @override
  late final GeneratedColumn<int> scoredRunsPerLesson = GeneratedColumn<int>(
    'scored_runs_per_lesson',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    avatar,
    colorIndex,
    createdAtMs,
    hiddenGroups,
    knownGroups,
    reviewHardTasks,
    defaultTaskCount,
    practiceLimitMinutes,
    breakMinutes,
    dailyLimitMinutes,
    lessonFilter,
    scoredRunsPerLesson,
    locked,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('avatar')) {
      context.handle(
        _avatarMeta,
        avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta),
      );
    } else if (isInserting) {
      context.missing(_avatarMeta);
    }
    if (data.containsKey('color_index')) {
      context.handle(
        _colorIndexMeta,
        colorIndex.isAcceptableOrUnknown(data['color_index']!, _colorIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_colorIndexMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('hidden_groups')) {
      context.handle(
        _hiddenGroupsMeta,
        hiddenGroups.isAcceptableOrUnknown(
          data['hidden_groups']!,
          _hiddenGroupsMeta,
        ),
      );
    }
    if (data.containsKey('known_groups')) {
      context.handle(
        _knownGroupsMeta,
        knownGroups.isAcceptableOrUnknown(
          data['known_groups']!,
          _knownGroupsMeta,
        ),
      );
    }
    if (data.containsKey('review_hard_tasks')) {
      context.handle(
        _reviewHardTasksMeta,
        reviewHardTasks.isAcceptableOrUnknown(
          data['review_hard_tasks']!,
          _reviewHardTasksMeta,
        ),
      );
    }
    if (data.containsKey('default_task_count')) {
      context.handle(
        _defaultTaskCountMeta,
        defaultTaskCount.isAcceptableOrUnknown(
          data['default_task_count']!,
          _defaultTaskCountMeta,
        ),
      );
    }
    if (data.containsKey('practice_limit_minutes')) {
      context.handle(
        _practiceLimitMinutesMeta,
        practiceLimitMinutes.isAcceptableOrUnknown(
          data['practice_limit_minutes']!,
          _practiceLimitMinutesMeta,
        ),
      );
    }
    if (data.containsKey('break_minutes')) {
      context.handle(
        _breakMinutesMeta,
        breakMinutes.isAcceptableOrUnknown(
          data['break_minutes']!,
          _breakMinutesMeta,
        ),
      );
    }
    if (data.containsKey('daily_limit_minutes')) {
      context.handle(
        _dailyLimitMinutesMeta,
        dailyLimitMinutes.isAcceptableOrUnknown(
          data['daily_limit_minutes']!,
          _dailyLimitMinutesMeta,
        ),
      );
    }
    if (data.containsKey('lesson_filter')) {
      context.handle(
        _lessonFilterMeta,
        lessonFilter.isAcceptableOrUnknown(
          data['lesson_filter']!,
          _lessonFilterMeta,
        ),
      );
    }
    if (data.containsKey('scored_runs_per_lesson')) {
      context.handle(
        _scoredRunsPerLessonMeta,
        scoredRunsPerLesson.isAcceptableOrUnknown(
          data['scored_runs_per_lesson']!,
          _scoredRunsPerLessonMeta,
        ),
      );
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatar: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar'],
      )!,
      colorIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_index'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      hiddenGroups: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hidden_groups'],
      )!,
      knownGroups: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}known_groups'],
      )!,
      reviewHardTasks: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}review_hard_tasks'],
      )!,
      defaultTaskCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_task_count'],
      ),
      practiceLimitMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}practice_limit_minutes'],
      ),
      breakMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}break_minutes'],
      ),
      dailyLimitMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_limit_minutes'],
      ),
      lessonFilter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_filter'],
      )!,
      scoredRunsPerLesson: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scored_runs_per_lesson'],
      ),
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String name;

  /// A single emoji, picked from a fixed list in the UI.
  final String avatar;

  /// Index into the app's profile colour palette.
  final int colorIndex;
  final int createdAtMs;

  /// Lesson groups this child does not see, as a comma-separated list of
  /// [LessonGroup] names. Storing what is *hidden* rather than what is shown
  /// keeps a group added in a later version from silently staying invisible.
  final String hiddenGroups;

  /// The groups [hiddenGroups] was last decided against, same format.
  ///
  /// Without it "not hidden" covers two different things: a group a parent
  /// left switched on, and a group that did not exist when they looked. The
  /// second kind is new, and `domain/group_visibility.dart` only switches it
  /// on where it borders something this child already has.
  ///
  /// Empty means every group is known - what a profile written before this
  /// column says, and the only safe reading of it.
  final String knownGroups;

  /// Whether runs mix in calculations this child was slow or wrong on last
  /// time. On by default: practising what already works is the least useful
  /// thing an exercise app can do.
  final bool reviewHardTasks;

  /// How many tasks a run starts with for this child. Null means "whatever is
  /// set for everyone".
  final int? defaultTaskCount;

  /// Longest stretch of practice this child may do before a break, in
  /// minutes. Null takes the app-wide setting; zero is a decision - this
  /// child has no stretch limit.
  final int? practiceLimitMinutes;

  /// How long the break has to be before a new stretch may start. Also what
  /// separates one stretch from the next when the time is added up. Null
  /// takes the app-wide setting.
  final int? breakMinutes;

  /// Total practice this child may do in one day, in minutes. Null takes the
  /// app-wide setting, zero means this child has no daily limit. Independent
  /// of the stretch cap: enough breaks would otherwise add up to an
  /// afternoon.
  final int? dailyLimitMinutes;

  /// Which finished lessons the catalogue leaves out, as a [LessonFilter]
  /// name. Stored as a name rather than an index so a reordered enum cannot
  /// silently turn one setting into another.
  final String lessonFilter;

  /// How many runs of one lesson may earn something on one day. Null takes
  /// the app-wide setting, zero means this child has no cap.
  final int? scoredRunsPerLesson;

  /// Whether a parent has put this profile aside for now.
  ///
  /// A pause, not a deletion: everything the child collected stays exactly
  /// where it is and comes back untouched when the lock is lifted. That is
  /// the point - a parent who wants to stop the tablet for a while should not
  /// have to choose between nagging and destroying a year of best times.
  final bool locked;
  const User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.colorIndex,
    required this.createdAtMs,
    required this.hiddenGroups,
    required this.knownGroups,
    required this.reviewHardTasks,
    this.defaultTaskCount,
    this.practiceLimitMinutes,
    this.breakMinutes,
    this.dailyLimitMinutes,
    required this.lessonFilter,
    this.scoredRunsPerLesson,
    required this.locked,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['avatar'] = Variable<String>(avatar);
    map['color_index'] = Variable<int>(colorIndex);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['hidden_groups'] = Variable<String>(hiddenGroups);
    map['known_groups'] = Variable<String>(knownGroups);
    map['review_hard_tasks'] = Variable<bool>(reviewHardTasks);
    if (!nullToAbsent || defaultTaskCount != null) {
      map['default_task_count'] = Variable<int>(defaultTaskCount);
    }
    if (!nullToAbsent || practiceLimitMinutes != null) {
      map['practice_limit_minutes'] = Variable<int>(practiceLimitMinutes);
    }
    if (!nullToAbsent || breakMinutes != null) {
      map['break_minutes'] = Variable<int>(breakMinutes);
    }
    if (!nullToAbsent || dailyLimitMinutes != null) {
      map['daily_limit_minutes'] = Variable<int>(dailyLimitMinutes);
    }
    map['lesson_filter'] = Variable<String>(lessonFilter);
    if (!nullToAbsent || scoredRunsPerLesson != null) {
      map['scored_runs_per_lesson'] = Variable<int>(scoredRunsPerLesson);
    }
    map['locked'] = Variable<bool>(locked);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      avatar: Value(avatar),
      colorIndex: Value(colorIndex),
      createdAtMs: Value(createdAtMs),
      hiddenGroups: Value(hiddenGroups),
      knownGroups: Value(knownGroups),
      reviewHardTasks: Value(reviewHardTasks),
      defaultTaskCount: defaultTaskCount == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultTaskCount),
      practiceLimitMinutes: practiceLimitMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(practiceLimitMinutes),
      breakMinutes: breakMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(breakMinutes),
      dailyLimitMinutes: dailyLimitMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyLimitMinutes),
      lessonFilter: Value(lessonFilter),
      scoredRunsPerLesson: scoredRunsPerLesson == null && nullToAbsent
          ? const Value.absent()
          : Value(scoredRunsPerLesson),
      locked: Value(locked),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatar: serializer.fromJson<String>(json['avatar']),
      colorIndex: serializer.fromJson<int>(json['colorIndex']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      hiddenGroups: serializer.fromJson<String>(json['hiddenGroups']),
      knownGroups: serializer.fromJson<String>(json['knownGroups']),
      reviewHardTasks: serializer.fromJson<bool>(json['reviewHardTasks']),
      defaultTaskCount: serializer.fromJson<int?>(json['defaultTaskCount']),
      practiceLimitMinutes: serializer.fromJson<int?>(
        json['practiceLimitMinutes'],
      ),
      breakMinutes: serializer.fromJson<int?>(json['breakMinutes']),
      dailyLimitMinutes: serializer.fromJson<int?>(json['dailyLimitMinutes']),
      lessonFilter: serializer.fromJson<String>(json['lessonFilter']),
      scoredRunsPerLesson: serializer.fromJson<int?>(
        json['scoredRunsPerLesson'],
      ),
      locked: serializer.fromJson<bool>(json['locked']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'avatar': serializer.toJson<String>(avatar),
      'colorIndex': serializer.toJson<int>(colorIndex),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'hiddenGroups': serializer.toJson<String>(hiddenGroups),
      'knownGroups': serializer.toJson<String>(knownGroups),
      'reviewHardTasks': serializer.toJson<bool>(reviewHardTasks),
      'defaultTaskCount': serializer.toJson<int?>(defaultTaskCount),
      'practiceLimitMinutes': serializer.toJson<int?>(practiceLimitMinutes),
      'breakMinutes': serializer.toJson<int?>(breakMinutes),
      'dailyLimitMinutes': serializer.toJson<int?>(dailyLimitMinutes),
      'lessonFilter': serializer.toJson<String>(lessonFilter),
      'scoredRunsPerLesson': serializer.toJson<int?>(scoredRunsPerLesson),
      'locked': serializer.toJson<bool>(locked),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? avatar,
    int? colorIndex,
    int? createdAtMs,
    String? hiddenGroups,
    String? knownGroups,
    bool? reviewHardTasks,
    Value<int?> defaultTaskCount = const Value.absent(),
    Value<int?> practiceLimitMinutes = const Value.absent(),
    Value<int?> breakMinutes = const Value.absent(),
    Value<int?> dailyLimitMinutes = const Value.absent(),
    String? lessonFilter,
    Value<int?> scoredRunsPerLesson = const Value.absent(),
    bool? locked,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    avatar: avatar ?? this.avatar,
    colorIndex: colorIndex ?? this.colorIndex,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    hiddenGroups: hiddenGroups ?? this.hiddenGroups,
    knownGroups: knownGroups ?? this.knownGroups,
    reviewHardTasks: reviewHardTasks ?? this.reviewHardTasks,
    defaultTaskCount: defaultTaskCount.present
        ? defaultTaskCount.value
        : this.defaultTaskCount,
    practiceLimitMinutes: practiceLimitMinutes.present
        ? practiceLimitMinutes.value
        : this.practiceLimitMinutes,
    breakMinutes: breakMinutes.present ? breakMinutes.value : this.breakMinutes,
    dailyLimitMinutes: dailyLimitMinutes.present
        ? dailyLimitMinutes.value
        : this.dailyLimitMinutes,
    lessonFilter: lessonFilter ?? this.lessonFilter,
    scoredRunsPerLesson: scoredRunsPerLesson.present
        ? scoredRunsPerLesson.value
        : this.scoredRunsPerLesson,
    locked: locked ?? this.locked,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      colorIndex: data.colorIndex.present
          ? data.colorIndex.value
          : this.colorIndex,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      hiddenGroups: data.hiddenGroups.present
          ? data.hiddenGroups.value
          : this.hiddenGroups,
      knownGroups: data.knownGroups.present
          ? data.knownGroups.value
          : this.knownGroups,
      reviewHardTasks: data.reviewHardTasks.present
          ? data.reviewHardTasks.value
          : this.reviewHardTasks,
      defaultTaskCount: data.defaultTaskCount.present
          ? data.defaultTaskCount.value
          : this.defaultTaskCount,
      practiceLimitMinutes: data.practiceLimitMinutes.present
          ? data.practiceLimitMinutes.value
          : this.practiceLimitMinutes,
      breakMinutes: data.breakMinutes.present
          ? data.breakMinutes.value
          : this.breakMinutes,
      dailyLimitMinutes: data.dailyLimitMinutes.present
          ? data.dailyLimitMinutes.value
          : this.dailyLimitMinutes,
      lessonFilter: data.lessonFilter.present
          ? data.lessonFilter.value
          : this.lessonFilter,
      scoredRunsPerLesson: data.scoredRunsPerLesson.present
          ? data.scoredRunsPerLesson.value
          : this.scoredRunsPerLesson,
      locked: data.locked.present ? data.locked.value : this.locked,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('colorIndex: $colorIndex, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('hiddenGroups: $hiddenGroups, ')
          ..write('knownGroups: $knownGroups, ')
          ..write('reviewHardTasks: $reviewHardTasks, ')
          ..write('defaultTaskCount: $defaultTaskCount, ')
          ..write('practiceLimitMinutes: $practiceLimitMinutes, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('dailyLimitMinutes: $dailyLimitMinutes, ')
          ..write('lessonFilter: $lessonFilter, ')
          ..write('scoredRunsPerLesson: $scoredRunsPerLesson, ')
          ..write('locked: $locked')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    avatar,
    colorIndex,
    createdAtMs,
    hiddenGroups,
    knownGroups,
    reviewHardTasks,
    defaultTaskCount,
    practiceLimitMinutes,
    breakMinutes,
    dailyLimitMinutes,
    lessonFilter,
    scoredRunsPerLesson,
    locked,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatar == this.avatar &&
          other.colorIndex == this.colorIndex &&
          other.createdAtMs == this.createdAtMs &&
          other.hiddenGroups == this.hiddenGroups &&
          other.knownGroups == this.knownGroups &&
          other.reviewHardTasks == this.reviewHardTasks &&
          other.defaultTaskCount == this.defaultTaskCount &&
          other.practiceLimitMinutes == this.practiceLimitMinutes &&
          other.breakMinutes == this.breakMinutes &&
          other.dailyLimitMinutes == this.dailyLimitMinutes &&
          other.lessonFilter == this.lessonFilter &&
          other.scoredRunsPerLesson == this.scoredRunsPerLesson &&
          other.locked == this.locked);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> avatar;
  final Value<int> colorIndex;
  final Value<int> createdAtMs;
  final Value<String> hiddenGroups;
  final Value<String> knownGroups;
  final Value<bool> reviewHardTasks;
  final Value<int?> defaultTaskCount;
  final Value<int?> practiceLimitMinutes;
  final Value<int?> breakMinutes;
  final Value<int?> dailyLimitMinutes;
  final Value<String> lessonFilter;
  final Value<int?> scoredRunsPerLesson;
  final Value<bool> locked;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatar = const Value.absent(),
    this.colorIndex = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.hiddenGroups = const Value.absent(),
    this.knownGroups = const Value.absent(),
    this.reviewHardTasks = const Value.absent(),
    this.defaultTaskCount = const Value.absent(),
    this.practiceLimitMinutes = const Value.absent(),
    this.breakMinutes = const Value.absent(),
    this.dailyLimitMinutes = const Value.absent(),
    this.lessonFilter = const Value.absent(),
    this.scoredRunsPerLesson = const Value.absent(),
    this.locked = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String avatar,
    required int colorIndex,
    required int createdAtMs,
    this.hiddenGroups = const Value.absent(),
    this.knownGroups = const Value.absent(),
    this.reviewHardTasks = const Value.absent(),
    this.defaultTaskCount = const Value.absent(),
    this.practiceLimitMinutes = const Value.absent(),
    this.breakMinutes = const Value.absent(),
    this.dailyLimitMinutes = const Value.absent(),
    this.lessonFilter = const Value.absent(),
    this.scoredRunsPerLesson = const Value.absent(),
    this.locked = const Value.absent(),
  }) : name = Value(name),
       avatar = Value(avatar),
       colorIndex = Value(colorIndex),
       createdAtMs = Value(createdAtMs);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? avatar,
    Expression<int>? colorIndex,
    Expression<int>? createdAtMs,
    Expression<String>? hiddenGroups,
    Expression<String>? knownGroups,
    Expression<bool>? reviewHardTasks,
    Expression<int>? defaultTaskCount,
    Expression<int>? practiceLimitMinutes,
    Expression<int>? breakMinutes,
    Expression<int>? dailyLimitMinutes,
    Expression<String>? lessonFilter,
    Expression<int>? scoredRunsPerLesson,
    Expression<bool>? locked,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatar != null) 'avatar': avatar,
      if (colorIndex != null) 'color_index': colorIndex,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (hiddenGroups != null) 'hidden_groups': hiddenGroups,
      if (knownGroups != null) 'known_groups': knownGroups,
      if (reviewHardTasks != null) 'review_hard_tasks': reviewHardTasks,
      if (defaultTaskCount != null) 'default_task_count': defaultTaskCount,
      if (practiceLimitMinutes != null)
        'practice_limit_minutes': practiceLimitMinutes,
      if (breakMinutes != null) 'break_minutes': breakMinutes,
      if (dailyLimitMinutes != null) 'daily_limit_minutes': dailyLimitMinutes,
      if (lessonFilter != null) 'lesson_filter': lessonFilter,
      if (scoredRunsPerLesson != null)
        'scored_runs_per_lesson': scoredRunsPerLesson,
      if (locked != null) 'locked': locked,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? avatar,
    Value<int>? colorIndex,
    Value<int>? createdAtMs,
    Value<String>? hiddenGroups,
    Value<String>? knownGroups,
    Value<bool>? reviewHardTasks,
    Value<int?>? defaultTaskCount,
    Value<int?>? practiceLimitMinutes,
    Value<int?>? breakMinutes,
    Value<int?>? dailyLimitMinutes,
    Value<String>? lessonFilter,
    Value<int?>? scoredRunsPerLesson,
    Value<bool>? locked,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      colorIndex: colorIndex ?? this.colorIndex,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      hiddenGroups: hiddenGroups ?? this.hiddenGroups,
      knownGroups: knownGroups ?? this.knownGroups,
      reviewHardTasks: reviewHardTasks ?? this.reviewHardTasks,
      defaultTaskCount: defaultTaskCount ?? this.defaultTaskCount,
      practiceLimitMinutes: practiceLimitMinutes ?? this.practiceLimitMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      lessonFilter: lessonFilter ?? this.lessonFilter,
      scoredRunsPerLesson: scoredRunsPerLesson ?? this.scoredRunsPerLesson,
      locked: locked ?? this.locked,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (colorIndex.present) {
      map['color_index'] = Variable<int>(colorIndex.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (hiddenGroups.present) {
      map['hidden_groups'] = Variable<String>(hiddenGroups.value);
    }
    if (knownGroups.present) {
      map['known_groups'] = Variable<String>(knownGroups.value);
    }
    if (reviewHardTasks.present) {
      map['review_hard_tasks'] = Variable<bool>(reviewHardTasks.value);
    }
    if (defaultTaskCount.present) {
      map['default_task_count'] = Variable<int>(defaultTaskCount.value);
    }
    if (practiceLimitMinutes.present) {
      map['practice_limit_minutes'] = Variable<int>(practiceLimitMinutes.value);
    }
    if (breakMinutes.present) {
      map['break_minutes'] = Variable<int>(breakMinutes.value);
    }
    if (dailyLimitMinutes.present) {
      map['daily_limit_minutes'] = Variable<int>(dailyLimitMinutes.value);
    }
    if (lessonFilter.present) {
      map['lesson_filter'] = Variable<String>(lessonFilter.value);
    }
    if (scoredRunsPerLesson.present) {
      map['scored_runs_per_lesson'] = Variable<int>(scoredRunsPerLesson.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatar: $avatar, ')
          ..write('colorIndex: $colorIndex, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('hiddenGroups: $hiddenGroups, ')
          ..write('knownGroups: $knownGroups, ')
          ..write('reviewHardTasks: $reviewHardTasks, ')
          ..write('defaultTaskCount: $defaultTaskCount, ')
          ..write('practiceLimitMinutes: $practiceLimitMinutes, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('dailyLimitMinutes: $dailyLimitMinutes, ')
          ..write('lessonFilter: $lessonFilter, ')
          ..write('scoredRunsPerLesson: $scoredRunsPerLesson, ')
          ..write('locked: $locked')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskCountMeta = const VerificationMeta(
    'taskCount',
  );
  @override
  late final GeneratedColumn<int> taskCount = GeneratedColumn<int>(
    'task_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<int> seed = GeneratedColumn<int>(
    'seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMsMeta = const VerificationMeta(
    'startedAtMs',
  );
  @override
  late final GeneratedColumn<int> startedAtMs = GeneratedColumn<int>(
    'started_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMsMeta = const VerificationMeta(
    'finishedAtMs',
  );
  @override
  late final GeneratedColumn<int> finishedAtMs = GeneratedColumn<int>(
    'finished_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMsMeta = const VerificationMeta(
    'totalMs',
  );
  @override
  late final GeneratedColumn<int> totalMs = GeneratedColumn<int>(
    'total_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _wrongAttemptsMeta = const VerificationMeta(
    'wrongAttempts',
  );
  @override
  late final GeneratedColumn<int> wrongAttempts = GeneratedColumn<int>(
    'wrong_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _scoredMeta = const VerificationMeta('scored');
  @override
  late final GeneratedColumn<bool> scored = GeneratedColumn<bool>(
    'scored',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("scored" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    lessonId,
    taskCount,
    seed,
    startedAtMs,
    finishedAtMs,
    totalMs,
    wrongAttempts,
    completed,
    scored,
    deleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Session> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('task_count')) {
      context.handle(
        _taskCountMeta,
        taskCount.isAcceptableOrUnknown(data['task_count']!, _taskCountMeta),
      );
    } else if (isInserting) {
      context.missing(_taskCountMeta);
    }
    if (data.containsKey('seed')) {
      context.handle(
        _seedMeta,
        seed.isAcceptableOrUnknown(data['seed']!, _seedMeta),
      );
    } else if (isInserting) {
      context.missing(_seedMeta);
    }
    if (data.containsKey('started_at_ms')) {
      context.handle(
        _startedAtMsMeta,
        startedAtMs.isAcceptableOrUnknown(
          data['started_at_ms']!,
          _startedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startedAtMsMeta);
    }
    if (data.containsKey('finished_at_ms')) {
      context.handle(
        _finishedAtMsMeta,
        finishedAtMs.isAcceptableOrUnknown(
          data['finished_at_ms']!,
          _finishedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('total_ms')) {
      context.handle(
        _totalMsMeta,
        totalMs.isAcceptableOrUnknown(data['total_ms']!, _totalMsMeta),
      );
    }
    if (data.containsKey('wrong_attempts')) {
      context.handle(
        _wrongAttemptsMeta,
        wrongAttempts.isAcceptableOrUnknown(
          data['wrong_attempts']!,
          _wrongAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('scored')) {
      context.handle(
        _scoredMeta,
        scored.isAcceptableOrUnknown(data['scored']!, _scoredMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      taskCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_count'],
      )!,
      seed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed'],
      )!,
      startedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at_ms'],
      )!,
      finishedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}finished_at_ms'],
      ),
      totalMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_ms'],
      )!,
      wrongAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong_attempts'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      scored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}scored'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final int id;
  final int userId;

  /// Stable [LessonSpec.id], never a foreign key - lessons live in code.
  final String lessonId;
  final int taskCount;
  final int seed;
  final int startedAtMs;
  final int? finishedAtMs;

  /// Summed time of all tasks, excluding paused time.
  final int totalMs;
  final int wrongAttempts;

  /// Only completed runs count for statistics and leaderboards.
  final bool completed;

  /// Whether this run was allowed to earn anything: a best time, stars,
  /// bolts, a place in the ranking. Runs past the daily cap for their lesson
  /// are stored with this false - they are practice, and they count towards
  /// the day's time, but they set no records.
  ///
  /// Decided once, when the run finishes, and stored: working it out again
  /// later would need the cap as it stood that day, and a parent may change
  /// it tomorrow.
  final bool scored;

  /// Whether a parent has removed this run from the record.
  ///
  /// Removed, not erased: the row stays so the **practised time** stays.
  /// Deleting a run may cost stars, bolts and a place in the ranking - that
  /// is what a parent tidying up is asking for - but it must not hand back
  /// an afternoon of screen time. Otherwise the daily limit would have a
  /// delete button next to it.
  final bool deleted;
  const Session({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.taskCount,
    required this.seed,
    required this.startedAtMs,
    this.finishedAtMs,
    required this.totalMs,
    required this.wrongAttempts,
    required this.completed,
    required this.scored,
    required this.deleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['lesson_id'] = Variable<String>(lessonId);
    map['task_count'] = Variable<int>(taskCount);
    map['seed'] = Variable<int>(seed);
    map['started_at_ms'] = Variable<int>(startedAtMs);
    if (!nullToAbsent || finishedAtMs != null) {
      map['finished_at_ms'] = Variable<int>(finishedAtMs);
    }
    map['total_ms'] = Variable<int>(totalMs);
    map['wrong_attempts'] = Variable<int>(wrongAttempts);
    map['completed'] = Variable<bool>(completed);
    map['scored'] = Variable<bool>(scored);
    map['deleted'] = Variable<bool>(deleted);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      lessonId: Value(lessonId),
      taskCount: Value(taskCount),
      seed: Value(seed),
      startedAtMs: Value(startedAtMs),
      finishedAtMs: finishedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAtMs),
      totalMs: Value(totalMs),
      wrongAttempts: Value(wrongAttempts),
      completed: Value(completed),
      scored: Value(scored),
      deleted: Value(deleted),
    );
  }

  factory Session.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      taskCount: serializer.fromJson<int>(json['taskCount']),
      seed: serializer.fromJson<int>(json['seed']),
      startedAtMs: serializer.fromJson<int>(json['startedAtMs']),
      finishedAtMs: serializer.fromJson<int?>(json['finishedAtMs']),
      totalMs: serializer.fromJson<int>(json['totalMs']),
      wrongAttempts: serializer.fromJson<int>(json['wrongAttempts']),
      completed: serializer.fromJson<bool>(json['completed']),
      scored: serializer.fromJson<bool>(json['scored']),
      deleted: serializer.fromJson<bool>(json['deleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'lessonId': serializer.toJson<String>(lessonId),
      'taskCount': serializer.toJson<int>(taskCount),
      'seed': serializer.toJson<int>(seed),
      'startedAtMs': serializer.toJson<int>(startedAtMs),
      'finishedAtMs': serializer.toJson<int?>(finishedAtMs),
      'totalMs': serializer.toJson<int>(totalMs),
      'wrongAttempts': serializer.toJson<int>(wrongAttempts),
      'completed': serializer.toJson<bool>(completed),
      'scored': serializer.toJson<bool>(scored),
      'deleted': serializer.toJson<bool>(deleted),
    };
  }

  Session copyWith({
    int? id,
    int? userId,
    String? lessonId,
    int? taskCount,
    int? seed,
    int? startedAtMs,
    Value<int?> finishedAtMs = const Value.absent(),
    int? totalMs,
    int? wrongAttempts,
    bool? completed,
    bool? scored,
    bool? deleted,
  }) => Session(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    lessonId: lessonId ?? this.lessonId,
    taskCount: taskCount ?? this.taskCount,
    seed: seed ?? this.seed,
    startedAtMs: startedAtMs ?? this.startedAtMs,
    finishedAtMs: finishedAtMs.present ? finishedAtMs.value : this.finishedAtMs,
    totalMs: totalMs ?? this.totalMs,
    wrongAttempts: wrongAttempts ?? this.wrongAttempts,
    completed: completed ?? this.completed,
    scored: scored ?? this.scored,
    deleted: deleted ?? this.deleted,
  );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      taskCount: data.taskCount.present ? data.taskCount.value : this.taskCount,
      seed: data.seed.present ? data.seed.value : this.seed,
      startedAtMs: data.startedAtMs.present
          ? data.startedAtMs.value
          : this.startedAtMs,
      finishedAtMs: data.finishedAtMs.present
          ? data.finishedAtMs.value
          : this.finishedAtMs,
      totalMs: data.totalMs.present ? data.totalMs.value : this.totalMs,
      wrongAttempts: data.wrongAttempts.present
          ? data.wrongAttempts.value
          : this.wrongAttempts,
      completed: data.completed.present ? data.completed.value : this.completed,
      scored: data.scored.present ? data.scored.value : this.scored,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('lessonId: $lessonId, ')
          ..write('taskCount: $taskCount, ')
          ..write('seed: $seed, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('finishedAtMs: $finishedAtMs, ')
          ..write('totalMs: $totalMs, ')
          ..write('wrongAttempts: $wrongAttempts, ')
          ..write('completed: $completed, ')
          ..write('scored: $scored, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    lessonId,
    taskCount,
    seed,
    startedAtMs,
    finishedAtMs,
    totalMs,
    wrongAttempts,
    completed,
    scored,
    deleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.lessonId == this.lessonId &&
          other.taskCount == this.taskCount &&
          other.seed == this.seed &&
          other.startedAtMs == this.startedAtMs &&
          other.finishedAtMs == this.finishedAtMs &&
          other.totalMs == this.totalMs &&
          other.wrongAttempts == this.wrongAttempts &&
          other.completed == this.completed &&
          other.scored == this.scored &&
          other.deleted == this.deleted);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> lessonId;
  final Value<int> taskCount;
  final Value<int> seed;
  final Value<int> startedAtMs;
  final Value<int?> finishedAtMs;
  final Value<int> totalMs;
  final Value<int> wrongAttempts;
  final Value<bool> completed;
  final Value<bool> scored;
  final Value<bool> deleted;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.taskCount = const Value.absent(),
    this.seed = const Value.absent(),
    this.startedAtMs = const Value.absent(),
    this.finishedAtMs = const Value.absent(),
    this.totalMs = const Value.absent(),
    this.wrongAttempts = const Value.absent(),
    this.completed = const Value.absent(),
    this.scored = const Value.absent(),
    this.deleted = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String lessonId,
    required int taskCount,
    required int seed,
    required int startedAtMs,
    this.finishedAtMs = const Value.absent(),
    this.totalMs = const Value.absent(),
    this.wrongAttempts = const Value.absent(),
    this.completed = const Value.absent(),
    this.scored = const Value.absent(),
    this.deleted = const Value.absent(),
  }) : userId = Value(userId),
       lessonId = Value(lessonId),
       taskCount = Value(taskCount),
       seed = Value(seed),
       startedAtMs = Value(startedAtMs);
  static Insertable<Session> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? lessonId,
    Expression<int>? taskCount,
    Expression<int>? seed,
    Expression<int>? startedAtMs,
    Expression<int>? finishedAtMs,
    Expression<int>? totalMs,
    Expression<int>? wrongAttempts,
    Expression<bool>? completed,
    Expression<bool>? scored,
    Expression<bool>? deleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (taskCount != null) 'task_count': taskCount,
      if (seed != null) 'seed': seed,
      if (startedAtMs != null) 'started_at_ms': startedAtMs,
      if (finishedAtMs != null) 'finished_at_ms': finishedAtMs,
      if (totalMs != null) 'total_ms': totalMs,
      if (wrongAttempts != null) 'wrong_attempts': wrongAttempts,
      if (completed != null) 'completed': completed,
      if (scored != null) 'scored': scored,
      if (deleted != null) 'deleted': deleted,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? lessonId,
    Value<int>? taskCount,
    Value<int>? seed,
    Value<int>? startedAtMs,
    Value<int?>? finishedAtMs,
    Value<int>? totalMs,
    Value<int>? wrongAttempts,
    Value<bool>? completed,
    Value<bool>? scored,
    Value<bool>? deleted,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      taskCount: taskCount ?? this.taskCount,
      seed: seed ?? this.seed,
      startedAtMs: startedAtMs ?? this.startedAtMs,
      finishedAtMs: finishedAtMs ?? this.finishedAtMs,
      totalMs: totalMs ?? this.totalMs,
      wrongAttempts: wrongAttempts ?? this.wrongAttempts,
      completed: completed ?? this.completed,
      scored: scored ?? this.scored,
      deleted: deleted ?? this.deleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (taskCount.present) {
      map['task_count'] = Variable<int>(taskCount.value);
    }
    if (seed.present) {
      map['seed'] = Variable<int>(seed.value);
    }
    if (startedAtMs.present) {
      map['started_at_ms'] = Variable<int>(startedAtMs.value);
    }
    if (finishedAtMs.present) {
      map['finished_at_ms'] = Variable<int>(finishedAtMs.value);
    }
    if (totalMs.present) {
      map['total_ms'] = Variable<int>(totalMs.value);
    }
    if (wrongAttempts.present) {
      map['wrong_attempts'] = Variable<int>(wrongAttempts.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (scored.present) {
      map['scored'] = Variable<bool>(scored.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('lessonId: $lessonId, ')
          ..write('taskCount: $taskCount, ')
          ..write('seed: $seed, ')
          ..write('startedAtMs: $startedAtMs, ')
          ..write('finishedAtMs: $finishedAtMs, ')
          ..write('totalMs: $totalMs, ')
          ..write('wrongAttempts: $wrongAttempts, ')
          ..write('completed: $completed, ')
          ..write('scored: $scored, ')
          ..write('deleted: $deleted')
          ..write(')'))
        .toString();
  }
}

class $AttemptsTable extends Attempts with TableInfo<$AttemptsTable, Attempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operandAMeta = const VerificationMeta(
    'operandA',
  );
  @override
  late final GeneratedColumn<int> operandA = GeneratedColumn<int>(
    'operand_a',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operandBMeta = const VerificationMeta(
    'operandB',
  );
  @override
  late final GeneratedColumn<int> operandB = GeneratedColumn<int>(
    'operand_b',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formMeta = const VerificationMeta('form');
  @override
  late final GeneratedColumn<String> form = GeneratedColumn<String>(
    'form',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operandCMeta = const VerificationMeta(
    'operandC',
  );
  @override
  late final GeneratedColumn<int> operandC = GeneratedColumn<int>(
    'operand_c',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _op2Meta = const VerificationMeta('op2');
  @override
  late final GeneratedColumn<String> op2 = GeneratedColumn<String>(
    'op2',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expectedMeta = const VerificationMeta(
    'expected',
  );
  @override
  late final GeneratedColumn<int> expected = GeneratedColumn<int>(
    'expected',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elapsedMsMeta = const VerificationMeta(
    'elapsedMs',
  );
  @override
  late final GeneratedColumn<int> elapsedMs = GeneratedColumn<int>(
    'elapsed_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wrongAttemptsMeta = const VerificationMeta(
    'wrongAttempts',
  );
  @override
  late final GeneratedColumn<int> wrongAttempts = GeneratedColumn<int>(
    'wrong_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    position,
    operandA,
    operandB,
    op,
    form,
    operandC,
    op2,
    expected,
    elapsedMs,
    wrongAttempts,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('operand_a')) {
      context.handle(
        _operandAMeta,
        operandA.isAcceptableOrUnknown(data['operand_a']!, _operandAMeta),
      );
    } else if (isInserting) {
      context.missing(_operandAMeta);
    }
    if (data.containsKey('operand_b')) {
      context.handle(
        _operandBMeta,
        operandB.isAcceptableOrUnknown(data['operand_b']!, _operandBMeta),
      );
    } else if (isInserting) {
      context.missing(_operandBMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('form')) {
      context.handle(
        _formMeta,
        form.isAcceptableOrUnknown(data['form']!, _formMeta),
      );
    } else if (isInserting) {
      context.missing(_formMeta);
    }
    if (data.containsKey('operand_c')) {
      context.handle(
        _operandCMeta,
        operandC.isAcceptableOrUnknown(data['operand_c']!, _operandCMeta),
      );
    }
    if (data.containsKey('op2')) {
      context.handle(
        _op2Meta,
        op2.isAcceptableOrUnknown(data['op2']!, _op2Meta),
      );
    }
    if (data.containsKey('expected')) {
      context.handle(
        _expectedMeta,
        expected.isAcceptableOrUnknown(data['expected']!, _expectedMeta),
      );
    } else if (isInserting) {
      context.missing(_expectedMeta);
    }
    if (data.containsKey('elapsed_ms')) {
      context.handle(
        _elapsedMsMeta,
        elapsedMs.isAcceptableOrUnknown(data['elapsed_ms']!, _elapsedMsMeta),
      );
    } else if (isInserting) {
      context.missing(_elapsedMsMeta);
    }
    if (data.containsKey('wrong_attempts')) {
      context.handle(
        _wrongAttemptsMeta,
        wrongAttempts.isAcceptableOrUnknown(
          data['wrong_attempts']!,
          _wrongAttemptsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wrongAttemptsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      operandA: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}operand_a'],
      )!,
      operandB: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}operand_b'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      form: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}form'],
      )!,
      operandC: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}operand_c'],
      ),
      op2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op2'],
      ),
      expected: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected'],
      )!,
      elapsedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_ms'],
      )!,
      wrongAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong_attempts'],
      )!,
    );
  }

  @override
  $AttemptsTable createAlias(String alias) {
    return $AttemptsTable(attachedDatabase, alias);
  }
}

class Attempt extends DataClass implements Insertable<Attempt> {
  final int id;
  final int sessionId;
  final int position;
  final int operandA;
  final int operandB;
  final String op;
  final String form;

  /// The third operand and second operation of a Punkt-vor-Strich task
  /// ([TaskForm.chain]). Null for every other form - two operands were the
  /// whole task before this one, and null is the true reading of that, not
  /// a missing value.
  final int? operandC;
  final String? op2;
  final int expected;
  final int elapsedMs;
  final int wrongAttempts;
  const Attempt({
    required this.id,
    required this.sessionId,
    required this.position,
    required this.operandA,
    required this.operandB,
    required this.op,
    required this.form,
    this.operandC,
    this.op2,
    required this.expected,
    required this.elapsedMs,
    required this.wrongAttempts,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['position'] = Variable<int>(position);
    map['operand_a'] = Variable<int>(operandA);
    map['operand_b'] = Variable<int>(operandB);
    map['op'] = Variable<String>(op);
    map['form'] = Variable<String>(form);
    if (!nullToAbsent || operandC != null) {
      map['operand_c'] = Variable<int>(operandC);
    }
    if (!nullToAbsent || op2 != null) {
      map['op2'] = Variable<String>(op2);
    }
    map['expected'] = Variable<int>(expected);
    map['elapsed_ms'] = Variable<int>(elapsedMs);
    map['wrong_attempts'] = Variable<int>(wrongAttempts);
    return map;
  }

  AttemptsCompanion toCompanion(bool nullToAbsent) {
    return AttemptsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      position: Value(position),
      operandA: Value(operandA),
      operandB: Value(operandB),
      op: Value(op),
      form: Value(form),
      operandC: operandC == null && nullToAbsent
          ? const Value.absent()
          : Value(operandC),
      op2: op2 == null && nullToAbsent ? const Value.absent() : Value(op2),
      expected: Value(expected),
      elapsedMs: Value(elapsedMs),
      wrongAttempts: Value(wrongAttempts),
    );
  }

  factory Attempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attempt(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      position: serializer.fromJson<int>(json['position']),
      operandA: serializer.fromJson<int>(json['operandA']),
      operandB: serializer.fromJson<int>(json['operandB']),
      op: serializer.fromJson<String>(json['op']),
      form: serializer.fromJson<String>(json['form']),
      operandC: serializer.fromJson<int?>(json['operandC']),
      op2: serializer.fromJson<String?>(json['op2']),
      expected: serializer.fromJson<int>(json['expected']),
      elapsedMs: serializer.fromJson<int>(json['elapsedMs']),
      wrongAttempts: serializer.fromJson<int>(json['wrongAttempts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'position': serializer.toJson<int>(position),
      'operandA': serializer.toJson<int>(operandA),
      'operandB': serializer.toJson<int>(operandB),
      'op': serializer.toJson<String>(op),
      'form': serializer.toJson<String>(form),
      'operandC': serializer.toJson<int?>(operandC),
      'op2': serializer.toJson<String?>(op2),
      'expected': serializer.toJson<int>(expected),
      'elapsedMs': serializer.toJson<int>(elapsedMs),
      'wrongAttempts': serializer.toJson<int>(wrongAttempts),
    };
  }

  Attempt copyWith({
    int? id,
    int? sessionId,
    int? position,
    int? operandA,
    int? operandB,
    String? op,
    String? form,
    Value<int?> operandC = const Value.absent(),
    Value<String?> op2 = const Value.absent(),
    int? expected,
    int? elapsedMs,
    int? wrongAttempts,
  }) => Attempt(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    position: position ?? this.position,
    operandA: operandA ?? this.operandA,
    operandB: operandB ?? this.operandB,
    op: op ?? this.op,
    form: form ?? this.form,
    operandC: operandC.present ? operandC.value : this.operandC,
    op2: op2.present ? op2.value : this.op2,
    expected: expected ?? this.expected,
    elapsedMs: elapsedMs ?? this.elapsedMs,
    wrongAttempts: wrongAttempts ?? this.wrongAttempts,
  );
  Attempt copyWithCompanion(AttemptsCompanion data) {
    return Attempt(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      position: data.position.present ? data.position.value : this.position,
      operandA: data.operandA.present ? data.operandA.value : this.operandA,
      operandB: data.operandB.present ? data.operandB.value : this.operandB,
      op: data.op.present ? data.op.value : this.op,
      form: data.form.present ? data.form.value : this.form,
      operandC: data.operandC.present ? data.operandC.value : this.operandC,
      op2: data.op2.present ? data.op2.value : this.op2,
      expected: data.expected.present ? data.expected.value : this.expected,
      elapsedMs: data.elapsedMs.present ? data.elapsedMs.value : this.elapsedMs,
      wrongAttempts: data.wrongAttempts.present
          ? data.wrongAttempts.value
          : this.wrongAttempts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attempt(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('position: $position, ')
          ..write('operandA: $operandA, ')
          ..write('operandB: $operandB, ')
          ..write('op: $op, ')
          ..write('form: $form, ')
          ..write('operandC: $operandC, ')
          ..write('op2: $op2, ')
          ..write('expected: $expected, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('wrongAttempts: $wrongAttempts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    position,
    operandA,
    operandB,
    op,
    form,
    operandC,
    op2,
    expected,
    elapsedMs,
    wrongAttempts,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attempt &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.position == this.position &&
          other.operandA == this.operandA &&
          other.operandB == this.operandB &&
          other.op == this.op &&
          other.form == this.form &&
          other.operandC == this.operandC &&
          other.op2 == this.op2 &&
          other.expected == this.expected &&
          other.elapsedMs == this.elapsedMs &&
          other.wrongAttempts == this.wrongAttempts);
}

class AttemptsCompanion extends UpdateCompanion<Attempt> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> position;
  final Value<int> operandA;
  final Value<int> operandB;
  final Value<String> op;
  final Value<String> form;
  final Value<int?> operandC;
  final Value<String?> op2;
  final Value<int> expected;
  final Value<int> elapsedMs;
  final Value<int> wrongAttempts;
  const AttemptsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.position = const Value.absent(),
    this.operandA = const Value.absent(),
    this.operandB = const Value.absent(),
    this.op = const Value.absent(),
    this.form = const Value.absent(),
    this.operandC = const Value.absent(),
    this.op2 = const Value.absent(),
    this.expected = const Value.absent(),
    this.elapsedMs = const Value.absent(),
    this.wrongAttempts = const Value.absent(),
  });
  AttemptsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int position,
    required int operandA,
    required int operandB,
    required String op,
    required String form,
    this.operandC = const Value.absent(),
    this.op2 = const Value.absent(),
    required int expected,
    required int elapsedMs,
    required int wrongAttempts,
  }) : sessionId = Value(sessionId),
       position = Value(position),
       operandA = Value(operandA),
       operandB = Value(operandB),
       op = Value(op),
       form = Value(form),
       expected = Value(expected),
       elapsedMs = Value(elapsedMs),
       wrongAttempts = Value(wrongAttempts);
  static Insertable<Attempt> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? position,
    Expression<int>? operandA,
    Expression<int>? operandB,
    Expression<String>? op,
    Expression<String>? form,
    Expression<int>? operandC,
    Expression<String>? op2,
    Expression<int>? expected,
    Expression<int>? elapsedMs,
    Expression<int>? wrongAttempts,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (position != null) 'position': position,
      if (operandA != null) 'operand_a': operandA,
      if (operandB != null) 'operand_b': operandB,
      if (op != null) 'op': op,
      if (form != null) 'form': form,
      if (operandC != null) 'operand_c': operandC,
      if (op2 != null) 'op2': op2,
      if (expected != null) 'expected': expected,
      if (elapsedMs != null) 'elapsed_ms': elapsedMs,
      if (wrongAttempts != null) 'wrong_attempts': wrongAttempts,
    });
  }

  AttemptsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? position,
    Value<int>? operandA,
    Value<int>? operandB,
    Value<String>? op,
    Value<String>? form,
    Value<int?>? operandC,
    Value<String?>? op2,
    Value<int>? expected,
    Value<int>? elapsedMs,
    Value<int>? wrongAttempts,
  }) {
    return AttemptsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      position: position ?? this.position,
      operandA: operandA ?? this.operandA,
      operandB: operandB ?? this.operandB,
      op: op ?? this.op,
      form: form ?? this.form,
      operandC: operandC ?? this.operandC,
      op2: op2 ?? this.op2,
      expected: expected ?? this.expected,
      elapsedMs: elapsedMs ?? this.elapsedMs,
      wrongAttempts: wrongAttempts ?? this.wrongAttempts,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (operandA.present) {
      map['operand_a'] = Variable<int>(operandA.value);
    }
    if (operandB.present) {
      map['operand_b'] = Variable<int>(operandB.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (form.present) {
      map['form'] = Variable<String>(form.value);
    }
    if (operandC.present) {
      map['operand_c'] = Variable<int>(operandC.value);
    }
    if (op2.present) {
      map['op2'] = Variable<String>(op2.value);
    }
    if (expected.present) {
      map['expected'] = Variable<int>(expected.value);
    }
    if (elapsedMs.present) {
      map['elapsed_ms'] = Variable<int>(elapsedMs.value);
    }
    if (wrongAttempts.present) {
      map['wrong_attempts'] = Variable<int>(wrongAttempts.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('position: $position, ')
          ..write('operandA: $operandA, ')
          ..write('operandB: $operandB, ')
          ..write('op: $op, ')
          ..write('form: $form, ')
          ..write('operandC: $operandC, ')
          ..write('op2: $op2, ')
          ..write('expected: $expected, ')
          ..write('elapsedMs: $elapsedMs, ')
          ..write('wrongAttempts: $wrongAttempts')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _settingKeyMeta = const VerificationMeta(
    'settingKey',
  );
  @override
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
    'setting_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settingValueMeta = const VerificationMeta(
    'settingValue',
  );
  @override
  late final GeneratedColumn<String> settingValue = GeneratedColumn<String>(
    'setting_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [settingKey, settingValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('setting_key')) {
      context.handle(
        _settingKeyMeta,
        settingKey.isAcceptableOrUnknown(data['setting_key']!, _settingKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('setting_value')) {
      context.handle(
        _settingValueMeta,
        settingValue.isAcceptableOrUnknown(
          data['setting_value']!,
          _settingValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_settingValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {settingKey};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      settingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_key'],
      )!,
      settingValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String settingKey;
  final String settingValue;
  const AppSetting({required this.settingKey, required this.settingValue});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['setting_key'] = Variable<String>(settingKey);
    map['setting_value'] = Variable<String>(settingValue);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      settingKey: Value(settingKey),
      settingValue: Value(settingValue),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      settingKey: serializer.fromJson<String>(json['settingKey']),
      settingValue: serializer.fromJson<String>(json['settingValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'settingKey': serializer.toJson<String>(settingKey),
      'settingValue': serializer.toJson<String>(settingValue),
    };
  }

  AppSetting copyWith({String? settingKey, String? settingValue}) => AppSetting(
    settingKey: settingKey ?? this.settingKey,
    settingValue: settingValue ?? this.settingValue,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      settingKey: data.settingKey.present
          ? data.settingKey.value
          : this.settingKey,
      settingValue: data.settingValue.present
          ? data.settingValue.value
          : this.settingValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(settingKey, settingValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.settingKey == this.settingKey &&
          other.settingValue == this.settingValue);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> settingKey;
  final Value<String> settingValue;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.settingKey = const Value.absent(),
    this.settingValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String settingKey,
    required String settingValue,
    this.rowid = const Value.absent(),
  }) : settingKey = Value(settingKey),
       settingValue = Value(settingValue);
  static Insertable<AppSetting> custom({
    Expression<String>? settingKey,
    Expression<String>? settingValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (settingKey != null) 'setting_key': settingKey,
      if (settingValue != null) 'setting_value': settingValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? settingKey,
    Value<String>? settingValue,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      settingKey: settingKey ?? this.settingKey,
      settingValue: settingValue ?? this.settingValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (settingValue.present) {
      map['setting_value'] = Variable<String>(settingValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('settingKey: $settingKey, ')
          ..write('settingValue: $settingValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LessonPreferencesTable extends LessonPreferences
    with TableInfo<$LessonPreferencesTable, LessonPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskCountMeta = const VerificationMeta(
    'taskCount',
  );
  @override
  late final GeneratedColumn<int> taskCount = GeneratedColumn<int>(
    'task_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, lessonId, taskCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<LessonPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('task_count')) {
      context.handle(
        _taskCountMeta,
        taskCount.isAcceptableOrUnknown(data['task_count']!, _taskCountMeta),
      );
    } else if (isInserting) {
      context.missing(_taskCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, lessonId};
  @override
  LessonPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonPreference(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      taskCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_count'],
      )!,
    );
  }

  @override
  $LessonPreferencesTable createAlias(String alias) {
    return $LessonPreferencesTable(attachedDatabase, alias);
  }
}

class LessonPreference extends DataClass
    implements Insertable<LessonPreference> {
  final int userId;
  final String lessonId;
  final int taskCount;
  const LessonPreference({
    required this.userId,
    required this.lessonId,
    required this.taskCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['lesson_id'] = Variable<String>(lessonId);
    map['task_count'] = Variable<int>(taskCount);
    return map;
  }

  LessonPreferencesCompanion toCompanion(bool nullToAbsent) {
    return LessonPreferencesCompanion(
      userId: Value(userId),
      lessonId: Value(lessonId),
      taskCount: Value(taskCount),
    );
  }

  factory LessonPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonPreference(
      userId: serializer.fromJson<int>(json['userId']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      taskCount: serializer.fromJson<int>(json['taskCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'lessonId': serializer.toJson<String>(lessonId),
      'taskCount': serializer.toJson<int>(taskCount),
    };
  }

  LessonPreference copyWith({int? userId, String? lessonId, int? taskCount}) =>
      LessonPreference(
        userId: userId ?? this.userId,
        lessonId: lessonId ?? this.lessonId,
        taskCount: taskCount ?? this.taskCount,
      );
  LessonPreference copyWithCompanion(LessonPreferencesCompanion data) {
    return LessonPreference(
      userId: data.userId.present ? data.userId.value : this.userId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      taskCount: data.taskCount.present ? data.taskCount.value : this.taskCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonPreference(')
          ..write('userId: $userId, ')
          ..write('lessonId: $lessonId, ')
          ..write('taskCount: $taskCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, lessonId, taskCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonPreference &&
          other.userId == this.userId &&
          other.lessonId == this.lessonId &&
          other.taskCount == this.taskCount);
}

class LessonPreferencesCompanion extends UpdateCompanion<LessonPreference> {
  final Value<int> userId;
  final Value<String> lessonId;
  final Value<int> taskCount;
  final Value<int> rowid;
  const LessonPreferencesCompanion({
    this.userId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.taskCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonPreferencesCompanion.insert({
    required int userId,
    required String lessonId,
    required int taskCount,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       lessonId = Value(lessonId),
       taskCount = Value(taskCount);
  static Insertable<LessonPreference> custom({
    Expression<int>? userId,
    Expression<String>? lessonId,
    Expression<int>? taskCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (taskCount != null) 'task_count': taskCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonPreferencesCompanion copyWith({
    Value<int>? userId,
    Value<String>? lessonId,
    Value<int>? taskCount,
    Value<int>? rowid,
  }) {
    return LessonPreferencesCompanion(
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      taskCount: taskCount ?? this.taskCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (taskCount.present) {
      map['task_count'] = Variable<int>(taskCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonPreferencesCompanion(')
          ..write('userId: $userId, ')
          ..write('lessonId: $lessonId, ')
          ..write('taskCount: $taskCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LessonStarsTable extends LessonStars
    with TableInfo<$LessonStarsTable, LessonStar> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LessonStarsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starsMeta = const VerificationMeta('stars');
  @override
  late final GeneratedColumn<int> stars = GeneratedColumn<int>(
    'stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userId, lessonId, stars];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_stars';
  @override
  VerificationContext validateIntegrity(
    Insertable<LessonStar> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('stars')) {
      context.handle(
        _starsMeta,
        stars.isAcceptableOrUnknown(data['stars']!, _starsMeta),
      );
    } else if (isInserting) {
      context.missing(_starsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId, lessonId};
  @override
  LessonStar map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonStar(
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      stars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stars'],
      )!,
    );
  }

  @override
  $LessonStarsTable createAlias(String alias) {
    return $LessonStarsTable(attachedDatabase, alias);
  }
}

class LessonStar extends DataClass implements Insertable<LessonStar> {
  final int userId;
  final String lessonId;

  /// The best a single run of this lesson was ever worth. Never goes down on
  /// its own - only a parent's reset takes it away.
  final int stars;
  const LessonStar({
    required this.userId,
    required this.lessonId,
    required this.stars,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<int>(userId);
    map['lesson_id'] = Variable<String>(lessonId);
    map['stars'] = Variable<int>(stars);
    return map;
  }

  LessonStarsCompanion toCompanion(bool nullToAbsent) {
    return LessonStarsCompanion(
      userId: Value(userId),
      lessonId: Value(lessonId),
      stars: Value(stars),
    );
  }

  factory LessonStar.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonStar(
      userId: serializer.fromJson<int>(json['userId']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      stars: serializer.fromJson<int>(json['stars']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<int>(userId),
      'lessonId': serializer.toJson<String>(lessonId),
      'stars': serializer.toJson<int>(stars),
    };
  }

  LessonStar copyWith({int? userId, String? lessonId, int? stars}) =>
      LessonStar(
        userId: userId ?? this.userId,
        lessonId: lessonId ?? this.lessonId,
        stars: stars ?? this.stars,
      );
  LessonStar copyWithCompanion(LessonStarsCompanion data) {
    return LessonStar(
      userId: data.userId.present ? data.userId.value : this.userId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      stars: data.stars.present ? data.stars.value : this.stars,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonStar(')
          ..write('userId: $userId, ')
          ..write('lessonId: $lessonId, ')
          ..write('stars: $stars')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, lessonId, stars);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonStar &&
          other.userId == this.userId &&
          other.lessonId == this.lessonId &&
          other.stars == this.stars);
}

class LessonStarsCompanion extends UpdateCompanion<LessonStar> {
  final Value<int> userId;
  final Value<String> lessonId;
  final Value<int> stars;
  final Value<int> rowid;
  const LessonStarsCompanion({
    this.userId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.stars = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonStarsCompanion.insert({
    required int userId,
    required String lessonId,
    required int stars,
    this.rowid = const Value.absent(),
  }) : userId = Value(userId),
       lessonId = Value(lessonId),
       stars = Value(stars);
  static Insertable<LessonStar> custom({
    Expression<int>? userId,
    Expression<String>? lessonId,
    Expression<int>? stars,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (stars != null) 'stars': stars,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonStarsCompanion copyWith({
    Value<int>? userId,
    Value<String>? lessonId,
    Value<int>? stars,
    Value<int>? rowid,
  }) {
    return LessonStarsCompanion(
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      stars: stars ?? this.stars,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (stars.present) {
      map['stars'] = Variable<int>(stars.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonStarsCompanion(')
          ..write('userId: $userId, ')
          ..write('lessonId: $lessonId, ')
          ..write('stars: $stars, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssignmentsTable extends Assignments
    with TableInfo<$AssignmentsTable, AssignmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _lessonIdMeta = const VerificationMeta(
    'lessonId',
  );
  @override
  late final GeneratedColumn<String> lessonId = GeneratedColumn<String>(
    'lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rhythmMeta = const VerificationMeta('rhythm');
  @override
  late final GeneratedColumn<String> rhythm = GeneratedColumn<String>(
    'rhythm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _runsMeta = const VerificationMeta('runs');
  @override
  late final GeneratedColumn<int> runs = GeneratedColumn<int>(
    'runs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskCountMeta = const VerificationMeta(
    'taskCount',
  );
  @override
  late final GeneratedColumn<int> taskCount = GeneratedColumn<int>(
    'task_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minStarsMeta = const VerificationMeta(
    'minStars',
  );
  @override
  late final GeneratedColumn<int> minStars = GeneratedColumn<int>(
    'min_stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minBoltsMeta = const VerificationMeta(
    'minBolts',
  );
  @override
  late final GeneratedColumn<int> minBolts = GeneratedColumn<int>(
    'min_bolts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMsMeta = const VerificationMeta(
    'endedAtMs',
  );
  @override
  late final GeneratedColumn<int> endedAtMs = GeneratedColumn<int>(
    'ended_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    lessonId,
    rhythm,
    runs,
    taskCount,
    minStars,
    minBolts,
    createdAtMs,
    endedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssignmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('lesson_id')) {
      context.handle(
        _lessonIdMeta,
        lessonId.isAcceptableOrUnknown(data['lesson_id']!, _lessonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonIdMeta);
    }
    if (data.containsKey('rhythm')) {
      context.handle(
        _rhythmMeta,
        rhythm.isAcceptableOrUnknown(data['rhythm']!, _rhythmMeta),
      );
    } else if (isInserting) {
      context.missing(_rhythmMeta);
    }
    if (data.containsKey('runs')) {
      context.handle(
        _runsMeta,
        runs.isAcceptableOrUnknown(data['runs']!, _runsMeta),
      );
    } else if (isInserting) {
      context.missing(_runsMeta);
    }
    if (data.containsKey('task_count')) {
      context.handle(
        _taskCountMeta,
        taskCount.isAcceptableOrUnknown(data['task_count']!, _taskCountMeta),
      );
    } else if (isInserting) {
      context.missing(_taskCountMeta);
    }
    if (data.containsKey('min_stars')) {
      context.handle(
        _minStarsMeta,
        minStars.isAcceptableOrUnknown(data['min_stars']!, _minStarsMeta),
      );
    } else if (isInserting) {
      context.missing(_minStarsMeta);
    }
    if (data.containsKey('min_bolts')) {
      context.handle(
        _minBoltsMeta,
        minBolts.isAcceptableOrUnknown(data['min_bolts']!, _minBoltsMeta),
      );
    } else if (isInserting) {
      context.missing(_minBoltsMeta);
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('ended_at_ms')) {
      context.handle(
        _endedAtMsMeta,
        endedAtMs.isAcceptableOrUnknown(data['ended_at_ms']!, _endedAtMsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssignmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssignmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      )!,
      lessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_id'],
      )!,
      rhythm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rhythm'],
      )!,
      runs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runs'],
      )!,
      taskCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_count'],
      )!,
      minStars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_stars'],
      )!,
      minBolts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_bolts'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      endedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ended_at_ms'],
      ),
    );
  }

  @override
  $AssignmentsTable createAlias(String alias) {
    return $AssignmentsTable(attachedDatabase, alias);
  }
}

class AssignmentRow extends DataClass implements Insertable<AssignmentRow> {
  final int id;
  final int userId;
  final String lessonId;

  /// [AssignmentRhythm] name, not index - the same caution as
  /// `hidden_groups` and `lesson_filter`: a reordered enum must not
  /// silently turn one rhythm into another.
  /// The rhythm is the whole deadline - a day, or a week ending Sunday
  /// night. v13 also held an hour and a weekday here; see the migration to
  /// v14 for why they went.
  final String rhythm;
  final int runs;
  final int taskCount;
  final int minStars;
  final int minBolts;
  final int createdAtMs;
  final int? endedAtMs;
  const AssignmentRow({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.rhythm,
    required this.runs,
    required this.taskCount,
    required this.minStars,
    required this.minBolts,
    required this.createdAtMs,
    this.endedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_id'] = Variable<int>(userId);
    map['lesson_id'] = Variable<String>(lessonId);
    map['rhythm'] = Variable<String>(rhythm);
    map['runs'] = Variable<int>(runs);
    map['task_count'] = Variable<int>(taskCount);
    map['min_stars'] = Variable<int>(minStars);
    map['min_bolts'] = Variable<int>(minBolts);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    if (!nullToAbsent || endedAtMs != null) {
      map['ended_at_ms'] = Variable<int>(endedAtMs);
    }
    return map;
  }

  AssignmentsCompanion toCompanion(bool nullToAbsent) {
    return AssignmentsCompanion(
      id: Value(id),
      userId: Value(userId),
      lessonId: Value(lessonId),
      rhythm: Value(rhythm),
      runs: Value(runs),
      taskCount: Value(taskCount),
      minStars: Value(minStars),
      minBolts: Value(minBolts),
      createdAtMs: Value(createdAtMs),
      endedAtMs: endedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAtMs),
    );
  }

  factory AssignmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssignmentRow(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int>(json['userId']),
      lessonId: serializer.fromJson<String>(json['lessonId']),
      rhythm: serializer.fromJson<String>(json['rhythm']),
      runs: serializer.fromJson<int>(json['runs']),
      taskCount: serializer.fromJson<int>(json['taskCount']),
      minStars: serializer.fromJson<int>(json['minStars']),
      minBolts: serializer.fromJson<int>(json['minBolts']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      endedAtMs: serializer.fromJson<int?>(json['endedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int>(userId),
      'lessonId': serializer.toJson<String>(lessonId),
      'rhythm': serializer.toJson<String>(rhythm),
      'runs': serializer.toJson<int>(runs),
      'taskCount': serializer.toJson<int>(taskCount),
      'minStars': serializer.toJson<int>(minStars),
      'minBolts': serializer.toJson<int>(minBolts),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'endedAtMs': serializer.toJson<int?>(endedAtMs),
    };
  }

  AssignmentRow copyWith({
    int? id,
    int? userId,
    String? lessonId,
    String? rhythm,
    int? runs,
    int? taskCount,
    int? minStars,
    int? minBolts,
    int? createdAtMs,
    Value<int?> endedAtMs = const Value.absent(),
  }) => AssignmentRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    lessonId: lessonId ?? this.lessonId,
    rhythm: rhythm ?? this.rhythm,
    runs: runs ?? this.runs,
    taskCount: taskCount ?? this.taskCount,
    minStars: minStars ?? this.minStars,
    minBolts: minBolts ?? this.minBolts,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    endedAtMs: endedAtMs.present ? endedAtMs.value : this.endedAtMs,
  );
  AssignmentRow copyWithCompanion(AssignmentsCompanion data) {
    return AssignmentRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      lessonId: data.lessonId.present ? data.lessonId.value : this.lessonId,
      rhythm: data.rhythm.present ? data.rhythm.value : this.rhythm,
      runs: data.runs.present ? data.runs.value : this.runs,
      taskCount: data.taskCount.present ? data.taskCount.value : this.taskCount,
      minStars: data.minStars.present ? data.minStars.value : this.minStars,
      minBolts: data.minBolts.present ? data.minBolts.value : this.minBolts,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      endedAtMs: data.endedAtMs.present ? data.endedAtMs.value : this.endedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('lessonId: $lessonId, ')
          ..write('rhythm: $rhythm, ')
          ..write('runs: $runs, ')
          ..write('taskCount: $taskCount, ')
          ..write('minStars: $minStars, ')
          ..write('minBolts: $minBolts, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('endedAtMs: $endedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    lessonId,
    rhythm,
    runs,
    taskCount,
    minStars,
    minBolts,
    createdAtMs,
    endedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssignmentRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.lessonId == this.lessonId &&
          other.rhythm == this.rhythm &&
          other.runs == this.runs &&
          other.taskCount == this.taskCount &&
          other.minStars == this.minStars &&
          other.minBolts == this.minBolts &&
          other.createdAtMs == this.createdAtMs &&
          other.endedAtMs == this.endedAtMs);
}

class AssignmentsCompanion extends UpdateCompanion<AssignmentRow> {
  final Value<int> id;
  final Value<int> userId;
  final Value<String> lessonId;
  final Value<String> rhythm;
  final Value<int> runs;
  final Value<int> taskCount;
  final Value<int> minStars;
  final Value<int> minBolts;
  final Value<int> createdAtMs;
  final Value<int?> endedAtMs;
  const AssignmentsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.lessonId = const Value.absent(),
    this.rhythm = const Value.absent(),
    this.runs = const Value.absent(),
    this.taskCount = const Value.absent(),
    this.minStars = const Value.absent(),
    this.minBolts = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.endedAtMs = const Value.absent(),
  });
  AssignmentsCompanion.insert({
    this.id = const Value.absent(),
    required int userId,
    required String lessonId,
    required String rhythm,
    required int runs,
    required int taskCount,
    required int minStars,
    required int minBolts,
    required int createdAtMs,
    this.endedAtMs = const Value.absent(),
  }) : userId = Value(userId),
       lessonId = Value(lessonId),
       rhythm = Value(rhythm),
       runs = Value(runs),
       taskCount = Value(taskCount),
       minStars = Value(minStars),
       minBolts = Value(minBolts),
       createdAtMs = Value(createdAtMs);
  static Insertable<AssignmentRow> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? lessonId,
    Expression<String>? rhythm,
    Expression<int>? runs,
    Expression<int>? taskCount,
    Expression<int>? minStars,
    Expression<int>? minBolts,
    Expression<int>? createdAtMs,
    Expression<int>? endedAtMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (lessonId != null) 'lesson_id': lessonId,
      if (rhythm != null) 'rhythm': rhythm,
      if (runs != null) 'runs': runs,
      if (taskCount != null) 'task_count': taskCount,
      if (minStars != null) 'min_stars': minStars,
      if (minBolts != null) 'min_bolts': minBolts,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (endedAtMs != null) 'ended_at_ms': endedAtMs,
    });
  }

  AssignmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? userId,
    Value<String>? lessonId,
    Value<String>? rhythm,
    Value<int>? runs,
    Value<int>? taskCount,
    Value<int>? minStars,
    Value<int>? minBolts,
    Value<int>? createdAtMs,
    Value<int?>? endedAtMs,
  }) {
    return AssignmentsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lessonId: lessonId ?? this.lessonId,
      rhythm: rhythm ?? this.rhythm,
      runs: runs ?? this.runs,
      taskCount: taskCount ?? this.taskCount,
      minStars: minStars ?? this.minStars,
      minBolts: minBolts ?? this.minBolts,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      endedAtMs: endedAtMs ?? this.endedAtMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (lessonId.present) {
      map['lesson_id'] = Variable<String>(lessonId.value);
    }
    if (rhythm.present) {
      map['rhythm'] = Variable<String>(rhythm.value);
    }
    if (runs.present) {
      map['runs'] = Variable<int>(runs.value);
    }
    if (taskCount.present) {
      map['task_count'] = Variable<int>(taskCount.value);
    }
    if (minStars.present) {
      map['min_stars'] = Variable<int>(minStars.value);
    }
    if (minBolts.present) {
      map['min_bolts'] = Variable<int>(minBolts.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (endedAtMs.present) {
      map['ended_at_ms'] = Variable<int>(endedAtMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('lessonId: $lessonId, ')
          ..write('rhythm: $rhythm, ')
          ..write('runs: $runs, ')
          ..write('taskCount: $taskCount, ')
          ..write('minStars: $minStars, ')
          ..write('minBolts: $minBolts, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('endedAtMs: $endedAtMs')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $AttemptsTable attempts = $AttemptsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $LessonPreferencesTable lessonPreferences =
      $LessonPreferencesTable(this);
  late final $LessonStarsTable lessonStars = $LessonStarsTable(this);
  late final $AssignmentsTable assignments = $AssignmentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    sessions,
    attempts,
    appSettings,
    lessonPreferences,
    lessonStars,
    assignments,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'users',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('sessions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('attempts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'users',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lesson_preferences', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'users',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lesson_stars', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'users',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('assignments', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  required String name,
  required String avatar,
  required int colorIndex,
  required int createdAtMs,
  Value<String> hiddenGroups,
  Value<String> knownGroups,
  Value<bool> reviewHardTasks,
  Value<int?> defaultTaskCount,
  Value<int?> practiceLimitMinutes,
  Value<int?> breakMinutes,
  Value<int?> dailyLimitMinutes,
  Value<String> lessonFilter,
  Value<int?> scoredRunsPerLesson,
  Value<bool> locked,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> avatar,
  Value<int> colorIndex,
  Value<int> createdAtMs,
  Value<String> hiddenGroups,
  Value<String> knownGroups,
  Value<bool> reviewHardTasks,
  Value<int?> defaultTaskCount,
  Value<int?> practiceLimitMinutes,
  Value<int?> breakMinutes,
  Value<int?> dailyLimitMinutes,
  Value<String> lessonFilter,
  Value<int?> scoredRunsPerLesson,
  Value<bool> locked,
});

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionsTable, List<Session>> _sessionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sessions,
    aliasName: 'users__id__sessions__user_id',
  );

  $$SessionsTableProcessedTableManager get sessionsRefs {
    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sessionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LessonPreferencesTable, List<LessonPreference>>
  _lessonPreferencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.lessonPreferences,
        aliasName: 'users__id__lesson_preferences__user_id',
      );

  $$LessonPreferencesTableProcessedTableManager get lessonPreferencesRefs {
    final manager = $$LessonPreferencesTableTableManager(
      $_db,
      $_db.lessonPreferences,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lessonPreferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LessonStarsTable, List<LessonStar>>
  _lessonStarsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lessonStars,
    aliasName: 'users__id__lesson_stars__user_id',
  );

  $$LessonStarsTableProcessedTableManager get lessonStarsRefs {
    final manager = $$LessonStarsTableTableManager(
      $_db,
      $_db.lessonStars,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lessonStarsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AssignmentsTable, List<AssignmentRow>>
  _assignmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assignments,
    aliasName: 'users__id__assignments__user_id',
  );

  $$AssignmentsTableProcessedTableManager get assignmentsRefs {
    final manager = $$AssignmentsTableTableManager(
      $_db,
      $_db.assignments,
    ).filter((f) => f.userId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_assignmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorIndex => $composableBuilder(
    column: $table.colorIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hiddenGroups => $composableBuilder(
    column: $table.hiddenGroups,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get knownGroups => $composableBuilder(
    column: $table.knownGroups,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reviewHardTasks => $composableBuilder(
    column: $table.reviewHardTasks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultTaskCount => $composableBuilder(
    column: $table.defaultTaskCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get practiceLimitMinutes => $composableBuilder(
    column: $table.practiceLimitMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dailyLimitMinutes => $composableBuilder(
    column: $table.dailyLimitMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonFilter => $composableBuilder(
    column: $table.lessonFilter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoredRunsPerLesson => $composableBuilder(
    column: $table.scoredRunsPerLesson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionsRefs(
    Expression<bool> Function($$SessionsTableFilterComposer f) f,
  ) {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lessonPreferencesRefs(
    Expression<bool> Function($$LessonPreferencesTableFilterComposer f) f,
  ) {
    final $$LessonPreferencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lessonPreferences,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonPreferencesTableFilterComposer(
            $db: $db,
            $table: $db.lessonPreferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lessonStarsRefs(
    Expression<bool> Function($$LessonStarsTableFilterComposer f) f,
  ) {
    final $$LessonStarsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lessonStars,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonStarsTableFilterComposer(
            $db: $db,
            $table: $db.lessonStars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> assignmentsRefs(
    Expression<bool> Function($$AssignmentsTableFilterComposer f) f,
  ) {
    final $$AssignmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assignments,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssignmentsTableFilterComposer(
            $db: $db,
            $table: $db.assignments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatar => $composableBuilder(
    column: $table.avatar,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorIndex => $composableBuilder(
    column: $table.colorIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hiddenGroups => $composableBuilder(
    column: $table.hiddenGroups,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get knownGroups => $composableBuilder(
    column: $table.knownGroups,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reviewHardTasks => $composableBuilder(
    column: $table.reviewHardTasks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultTaskCount => $composableBuilder(
    column: $table.defaultTaskCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get practiceLimitMinutes => $composableBuilder(
    column: $table.practiceLimitMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyLimitMinutes => $composableBuilder(
    column: $table.dailyLimitMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonFilter => $composableBuilder(
    column: $table.lessonFilter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoredRunsPerLesson => $composableBuilder(
    column: $table.scoredRunsPerLesson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<int> get colorIndex => $composableBuilder(
    column: $table.colorIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hiddenGroups => $composableBuilder(
    column: $table.hiddenGroups,
    builder: (column) => column,
  );

  GeneratedColumn<String> get knownGroups => $composableBuilder(
    column: $table.knownGroups,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reviewHardTasks => $composableBuilder(
    column: $table.reviewHardTasks,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultTaskCount => $composableBuilder(
    column: $table.defaultTaskCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get practiceLimitMinutes => $composableBuilder(
    column: $table.practiceLimitMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get breakMinutes => $composableBuilder(
    column: $table.breakMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dailyLimitMinutes => $composableBuilder(
    column: $table.dailyLimitMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lessonFilter => $composableBuilder(
    column: $table.lessonFilter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scoredRunsPerLesson => $composableBuilder(
    column: $table.scoredRunsPerLesson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  Expression<T> sessionsRefs<T extends Object>(
    Expression<T> Function($$SessionsTableAnnotationComposer a) f,
  ) {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lessonPreferencesRefs<T extends Object>(
    Expression<T> Function($$LessonPreferencesTableAnnotationComposer a) f,
  ) {
    final $$LessonPreferencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.lessonPreferences,
          getReferencedColumn: (t) => t.userId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$LessonPreferencesTableAnnotationComposer(
                $db: $db,
                $table: $db.lessonPreferences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> lessonStarsRefs<T extends Object>(
    Expression<T> Function($$LessonStarsTableAnnotationComposer a) f,
  ) {
    final $$LessonStarsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lessonStars,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LessonStarsTableAnnotationComposer(
            $db: $db,
            $table: $db.lessonStars,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> assignmentsRefs<T extends Object>(
    Expression<T> Function($$AssignmentsTableAnnotationComposer a) f,
  ) {
    final $$AssignmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assignments,
      getReferencedColumn: (t) => t.userId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssignmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.assignments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({
            bool sessionsRefs,
            bool lessonPreferencesRefs,
            bool lessonStarsRefs,
            bool assignmentsRefs,
          })
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> avatar = const Value.absent(),
                Value<int> colorIndex = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<String> hiddenGroups = const Value.absent(),
                Value<String> knownGroups = const Value.absent(),
                Value<bool> reviewHardTasks = const Value.absent(),
                Value<int?> defaultTaskCount = const Value.absent(),
                Value<int?> practiceLimitMinutes = const Value.absent(),
                Value<int?> breakMinutes = const Value.absent(),
                Value<int?> dailyLimitMinutes = const Value.absent(),
                Value<String> lessonFilter = const Value.absent(),
                Value<int?> scoredRunsPerLesson = const Value.absent(),
                Value<bool> locked = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                name: name,
                avatar: avatar,
                colorIndex: colorIndex,
                createdAtMs: createdAtMs,
                hiddenGroups: hiddenGroups,
                knownGroups: knownGroups,
                reviewHardTasks: reviewHardTasks,
                defaultTaskCount: defaultTaskCount,
                practiceLimitMinutes: practiceLimitMinutes,
                breakMinutes: breakMinutes,
                dailyLimitMinutes: dailyLimitMinutes,
                lessonFilter: lessonFilter,
                scoredRunsPerLesson: scoredRunsPerLesson,
                locked: locked,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String avatar,
                required int colorIndex,
                required int createdAtMs,
                Value<String> hiddenGroups = const Value.absent(),
                Value<String> knownGroups = const Value.absent(),
                Value<bool> reviewHardTasks = const Value.absent(),
                Value<int?> defaultTaskCount = const Value.absent(),
                Value<int?> practiceLimitMinutes = const Value.absent(),
                Value<int?> breakMinutes = const Value.absent(),
                Value<int?> dailyLimitMinutes = const Value.absent(),
                Value<String> lessonFilter = const Value.absent(),
                Value<int?> scoredRunsPerLesson = const Value.absent(),
                Value<bool> locked = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                name: name,
                avatar: avatar,
                colorIndex: colorIndex,
                createdAtMs: createdAtMs,
                hiddenGroups: hiddenGroups,
                knownGroups: knownGroups,
                reviewHardTasks: reviewHardTasks,
                defaultTaskCount: defaultTaskCount,
                practiceLimitMinutes: practiceLimitMinutes,
                breakMinutes: breakMinutes,
                dailyLimitMinutes: dailyLimitMinutes,
                lessonFilter: lessonFilter,
                scoredRunsPerLesson: scoredRunsPerLesson,
                locked: locked,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsersTable, User>(table),
                  $$UsersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sessionsRefs = false,
                lessonPreferencesRefs = false,
                lessonStarsRefs = false,
                assignmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionsRefs) db.sessions,
                    if (lessonPreferencesRefs) db.lessonPreferences,
                    if (lessonStarsRefs) db.lessonStars,
                    if (assignmentsRefs) db.assignments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionsRefs)
                        await $_getPrefetchedData<User, $UsersTable, Session>(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._sessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lessonPreferencesRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          LessonPreference
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._lessonPreferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).lessonPreferencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lessonStarsRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          LessonStar
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._lessonStarsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).lessonStarsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (assignmentsRefs)
                        await $_getPrefetchedData<
                          User,
                          $UsersTable,
                          AssignmentRow
                        >(
                          currentTable: table,
                          referencedTable: $$UsersTableReferences
                              ._assignmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).assignmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.userId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({
        bool sessionsRefs,
        bool lessonPreferencesRefs,
        bool lessonStarsRefs,
        bool assignmentsRefs,
      })
    >;
typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  required int userId,
  required String lessonId,
  required int taskCount,
  required int seed,
  required int startedAtMs,
  Value<int?> finishedAtMs,
  Value<int> totalMs,
  Value<int> wrongAttempts,
  Value<bool> completed,
  Value<bool> scored,
  Value<bool> deleted,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<int> id,
  Value<int> userId,
  Value<String> lessonId,
  Value<int> taskCount,
  Value<int> seed,
  Value<int> startedAtMs,
  Value<int?> finishedAtMs,
  Value<int> totalMs,
  Value<int> wrongAttempts,
  Value<bool> completed,
  Value<bool> scored,
  Value<bool> deleted,
});

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, Session> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('sessions__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AttemptsTable, List<Attempt>> _attemptsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.attempts,
    aliasName: 'sessions__id__attempts__session_id',
  );

  $$AttemptsTableProcessedTableManager get attemptsRefs {
    final manager = $$AttemptsTableTableManager(
      $_db,
      $_db.attempts,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskCount => $composableBuilder(
    column: $table.taskCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finishedAtMs => $composableBuilder(
    column: $table.finishedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMs => $composableBuilder(
    column: $table.totalMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrongAttempts => $composableBuilder(
    column: $table.wrongAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get scored => $composableBuilder(
    column: $table.scored,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> attemptsRefs(
    Expression<bool> Function($$AttemptsTableFilterComposer f) f,
  ) {
    final $$AttemptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableFilterComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskCount => $composableBuilder(
    column: $table.taskCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finishedAtMs => $composableBuilder(
    column: $table.finishedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMs => $composableBuilder(
    column: $table.totalMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrongAttempts => $composableBuilder(
    column: $table.wrongAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get scored => $composableBuilder(
    column: $table.scored,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<int> get taskCount =>
      $composableBuilder(column: $table.taskCount, builder: (column) => column);

  GeneratedColumn<int> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

  GeneratedColumn<int> get startedAtMs => $composableBuilder(
    column: $table.startedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get finishedAtMs => $composableBuilder(
    column: $table.finishedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalMs =>
      $composableBuilder(column: $table.totalMs, builder: (column) => column);

  GeneratedColumn<int> get wrongAttempts => $composableBuilder(
    column: $table.wrongAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get scored =>
      $composableBuilder(column: $table.scored, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> attemptsRefs<T extends Object>(
    Expression<T> Function($$AttemptsTableAnnotationComposer a) f,
  ) {
    final $$AttemptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attempts,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttemptsTableAnnotationComposer(
            $db: $db,
            $table: $db.attempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          Session,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (Session, $$SessionsTableReferences),
          Session,
          PrefetchHooks Function({bool userId, bool attemptsRefs})
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<int> taskCount = const Value.absent(),
                Value<int> seed = const Value.absent(),
                Value<int> startedAtMs = const Value.absent(),
                Value<int?> finishedAtMs = const Value.absent(),
                Value<int> totalMs = const Value.absent(),
                Value<int> wrongAttempts = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> scored = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                userId: userId,
                lessonId: lessonId,
                taskCount: taskCount,
                seed: seed,
                startedAtMs: startedAtMs,
                finishedAtMs: finishedAtMs,
                totalMs: totalMs,
                wrongAttempts: wrongAttempts,
                completed: completed,
                scored: scored,
                deleted: deleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required String lessonId,
                required int taskCount,
                required int seed,
                required int startedAtMs,
                Value<int?> finishedAtMs = const Value.absent(),
                Value<int> totalMs = const Value.absent(),
                Value<int> wrongAttempts = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> scored = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
              }) => SessionsCompanion.insert(
                id: id,
                userId: userId,
                lessonId: lessonId,
                taskCount: taskCount,
                seed: seed,
                startedAtMs: startedAtMs,
                finishedAtMs: finishedAtMs,
                totalMs: totalMs,
                wrongAttempts: wrongAttempts,
                completed: completed,
                scored: scored,
                deleted: deleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, Session>(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false, attemptsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (attemptsRefs) db.attempts],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.userId,
                        referencedTable: $$SessionsTableReferences._userIdTable(
                          db,
                        ),
                        referencedColumn: $$SessionsTableReferences
                            ._userIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (attemptsRefs)
                    await $_getPrefetchedData<Session, $SessionsTable, Attempt>(
                      currentTable: table,
                      referencedTable: $$SessionsTableReferences
                          ._attemptsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SessionsTableReferences(db, table, p0).attemptsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      Session,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (Session, $$SessionsTableReferences),
      Session,
      PrefetchHooks Function({bool userId, bool attemptsRefs})
    >;
typedef $$AttemptsTableCreateCompanionBuilder = AttemptsCompanion Function({
  Value<int> id,
  required int sessionId,
  required int position,
  required int operandA,
  required int operandB,
  required String op,
  required String form,
  Value<int?> operandC,
  Value<String?> op2,
  required int expected,
  required int elapsedMs,
  required int wrongAttempts,
});
typedef $$AttemptsTableUpdateCompanionBuilder = AttemptsCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<int> position,
  Value<int> operandA,
  Value<int> operandB,
  Value<String> op,
  Value<String> form,
  Value<int?> operandC,
  Value<String?> op2,
  Value<int> expected,
  Value<int> elapsedMs,
  Value<int> wrongAttempts,
});

final class $$AttemptsTableReferences
    extends BaseReferences<_$AppDatabase, $AttemptsTable, Attempt> {
  $$AttemptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('attempts__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttemptsTableFilterComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get operandA => $composableBuilder(
    column: $table.operandA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get operandB => $composableBuilder(
    column: $table.operandB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get operandC => $composableBuilder(
    column: $table.operandC,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op2 => $composableBuilder(
    column: $table.op2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expected => $composableBuilder(
    column: $table.expected,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrongAttempts => $composableBuilder(
    column: $table.wrongAttempts,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get operandA => $composableBuilder(
    column: $table.operandA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get operandB => $composableBuilder(
    column: $table.operandB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get form => $composableBuilder(
    column: $table.form,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get operandC => $composableBuilder(
    column: $table.operandC,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op2 => $composableBuilder(
    column: $table.op2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expected => $composableBuilder(
    column: $table.expected,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedMs => $composableBuilder(
    column: $table.elapsedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrongAttempts => $composableBuilder(
    column: $table.wrongAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttemptsTable> {
  $$AttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get operandA =>
      $composableBuilder(column: $table.operandA, builder: (column) => column);

  GeneratedColumn<int> get operandB =>
      $composableBuilder(column: $table.operandB, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get form =>
      $composableBuilder(column: $table.form, builder: (column) => column);

  GeneratedColumn<int> get operandC =>
      $composableBuilder(column: $table.operandC, builder: (column) => column);

  GeneratedColumn<String> get op2 =>
      $composableBuilder(column: $table.op2, builder: (column) => column);

  GeneratedColumn<int> get expected =>
      $composableBuilder(column: $table.expected, builder: (column) => column);

  GeneratedColumn<int> get elapsedMs =>
      $composableBuilder(column: $table.elapsedMs, builder: (column) => column);

  GeneratedColumn<int> get wrongAttempts => $composableBuilder(
    column: $table.wrongAttempts,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttemptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttemptsTable,
          Attempt,
          $$AttemptsTableFilterComposer,
          $$AttemptsTableOrderingComposer,
          $$AttemptsTableAnnotationComposer,
          $$AttemptsTableCreateCompanionBuilder,
          $$AttemptsTableUpdateCompanionBuilder,
          (Attempt, $$AttemptsTableReferences),
          Attempt,
          PrefetchHooks Function({bool sessionId})
        > {
  $$AttemptsTableTableManager(_$AppDatabase db, $AttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> operandA = const Value.absent(),
                Value<int> operandB = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> form = const Value.absent(),
                Value<int?> operandC = const Value.absent(),
                Value<String?> op2 = const Value.absent(),
                Value<int> expected = const Value.absent(),
                Value<int> elapsedMs = const Value.absent(),
                Value<int> wrongAttempts = const Value.absent(),
              }) => AttemptsCompanion(
                id: id,
                sessionId: sessionId,
                position: position,
                operandA: operandA,
                operandB: operandB,
                op: op,
                form: form,
                operandC: operandC,
                op2: op2,
                expected: expected,
                elapsedMs: elapsedMs,
                wrongAttempts: wrongAttempts,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int position,
                required int operandA,
                required int operandB,
                required String op,
                required String form,
                Value<int?> operandC = const Value.absent(),
                Value<String?> op2 = const Value.absent(),
                required int expected,
                required int elapsedMs,
                required int wrongAttempts,
              }) => AttemptsCompanion.insert(
                id: id,
                sessionId: sessionId,
                position: position,
                operandA: operandA,
                operandB: operandB,
                op: op,
                form: form,
                operandC: operandC,
                op2: op2,
                expected: expected,
                elapsedMs: elapsedMs,
                wrongAttempts: wrongAttempts,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AttemptsTable, Attempt>(table),
                  $$AttemptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$AttemptsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$AttemptsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttemptsTable,
      Attempt,
      $$AttemptsTableFilterComposer,
      $$AttemptsTableOrderingComposer,
      $$AttemptsTableAnnotationComposer,
      $$AttemptsTableCreateCompanionBuilder,
      $$AttemptsTableUpdateCompanionBuilder,
      (Attempt, $$AttemptsTableReferences),
      Attempt,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String settingKey,
      required String settingValue,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> settingKey,
      Value<String> settingValue,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingValue => $composableBuilder(
    column: $table.settingValue,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> settingKey = const Value.absent(),
                Value<String> settingValue = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                settingKey: settingKey,
                settingValue: settingValue,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String settingKey,
                required String settingValue,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                settingKey: settingKey,
                settingValue: settingValue,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$LessonPreferencesTableCreateCompanionBuilder =
    LessonPreferencesCompanion Function({
      required int userId,
      required String lessonId,
      required int taskCount,
      Value<int> rowid,
    });
typedef $$LessonPreferencesTableUpdateCompanionBuilder =
    LessonPreferencesCompanion Function({
      Value<int> userId,
      Value<String> lessonId,
      Value<int> taskCount,
      Value<int> rowid,
    });

final class $$LessonPreferencesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $LessonPreferencesTable,
          LessonPreference
        > {
  $$LessonPreferencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('lesson_preferences__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LessonPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $LessonPreferencesTable> {
  $$LessonPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskCount => $composableBuilder(
    column: $table.taskCount,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonPreferencesTable> {
  $$LessonPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskCount => $composableBuilder(
    column: $table.taskCount,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonPreferencesTable> {
  $$LessonPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<int> get taskCount =>
      $composableBuilder(column: $table.taskCount, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonPreferencesTable,
          LessonPreference,
          $$LessonPreferencesTableFilterComposer,
          $$LessonPreferencesTableOrderingComposer,
          $$LessonPreferencesTableAnnotationComposer,
          $$LessonPreferencesTableCreateCompanionBuilder,
          $$LessonPreferencesTableUpdateCompanionBuilder,
          (LessonPreference, $$LessonPreferencesTableReferences),
          LessonPreference,
          PrefetchHooks Function({bool userId})
        > {
  $$LessonPreferencesTableTableManager(
    _$AppDatabase db,
    $LessonPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonPreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<int> taskCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonPreferencesCompanion(
                userId: userId,
                lessonId: lessonId,
                taskCount: taskCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int userId,
                required String lessonId,
                required int taskCount,
                Value<int> rowid = const Value.absent(),
              }) => LessonPreferencesCompanion.insert(
                userId: userId,
                lessonId: lessonId,
                taskCount: taskCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LessonPreferencesTable, LessonPreference>(table),
                  $$LessonPreferencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.userId,
                        referencedTable: $$LessonPreferencesTableReferences
                            ._userIdTable(db),
                        referencedColumn: $$LessonPreferencesTableReferences
                            ._userIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LessonPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonPreferencesTable,
      LessonPreference,
      $$LessonPreferencesTableFilterComposer,
      $$LessonPreferencesTableOrderingComposer,
      $$LessonPreferencesTableAnnotationComposer,
      $$LessonPreferencesTableCreateCompanionBuilder,
      $$LessonPreferencesTableUpdateCompanionBuilder,
      (LessonPreference, $$LessonPreferencesTableReferences),
      LessonPreference,
      PrefetchHooks Function({bool userId})
    >;
typedef $$LessonStarsTableCreateCompanionBuilder =
    LessonStarsCompanion Function({
      required int userId,
      required String lessonId,
      required int stars,
      Value<int> rowid,
    });
typedef $$LessonStarsTableUpdateCompanionBuilder =
    LessonStarsCompanion Function({
      Value<int> userId,
      Value<String> lessonId,
      Value<int> stars,
      Value<int> rowid,
    });

final class $$LessonStarsTableReferences
    extends BaseReferences<_$AppDatabase, $LessonStarsTable, LessonStar> {
  $$LessonStarsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('lesson_stars__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LessonStarsTableFilterComposer
    extends Composer<_$AppDatabase, $LessonStarsTable> {
  $$LessonStarsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonStarsTableOrderingComposer
    extends Composer<_$AppDatabase, $LessonStarsTable> {
  $$LessonStarsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonStarsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LessonStarsTable> {
  $$LessonStarsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<int> get stars =>
      $composableBuilder(column: $table.stars, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LessonStarsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LessonStarsTable,
          LessonStar,
          $$LessonStarsTableFilterComposer,
          $$LessonStarsTableOrderingComposer,
          $$LessonStarsTableAnnotationComposer,
          $$LessonStarsTableCreateCompanionBuilder,
          $$LessonStarsTableUpdateCompanionBuilder,
          (LessonStar, $$LessonStarsTableReferences),
          LessonStar,
          PrefetchHooks Function({bool userId})
        > {
  $$LessonStarsTableTableManager(_$AppDatabase db, $LessonStarsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LessonStarsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LessonStarsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LessonStarsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> userId = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonStarsCompanion(
                userId: userId,
                lessonId: lessonId,
                stars: stars,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int userId,
                required String lessonId,
                required int stars,
                Value<int> rowid = const Value.absent(),
              }) => LessonStarsCompanion.insert(
                userId: userId,
                lessonId: lessonId,
                stars: stars,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LessonStarsTable, LessonStar>(table),
                  $$LessonStarsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.userId,
                        referencedTable: $$LessonStarsTableReferences
                            ._userIdTable(db),
                        referencedColumn: $$LessonStarsTableReferences
                            ._userIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LessonStarsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LessonStarsTable,
      LessonStar,
      $$LessonStarsTableFilterComposer,
      $$LessonStarsTableOrderingComposer,
      $$LessonStarsTableAnnotationComposer,
      $$LessonStarsTableCreateCompanionBuilder,
      $$LessonStarsTableUpdateCompanionBuilder,
      (LessonStar, $$LessonStarsTableReferences),
      LessonStar,
      PrefetchHooks Function({bool userId})
    >;
typedef $$AssignmentsTableCreateCompanionBuilder =
    AssignmentsCompanion Function({
      Value<int> id,
      required int userId,
      required String lessonId,
      required String rhythm,
      required int runs,
      required int taskCount,
      required int minStars,
      required int minBolts,
      required int createdAtMs,
      Value<int?> endedAtMs,
    });
typedef $$AssignmentsTableUpdateCompanionBuilder =
    AssignmentsCompanion Function({
      Value<int> id,
      Value<int> userId,
      Value<String> lessonId,
      Value<String> rhythm,
      Value<int> runs,
      Value<int> taskCount,
      Value<int> minStars,
      Value<int> minBolts,
      Value<int> createdAtMs,
      Value<int?> endedAtMs,
    });

final class $$AssignmentsTableReferences
    extends BaseReferences<_$AppDatabase, $AssignmentsTable, AssignmentRow> {
  $$AssignmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _userIdTable(_$AppDatabase db) =>
      db.users.createAlias('assignments__user_id__users__id');

  $$UsersTableProcessedTableManager get userId {
    final $_column = $_itemColumn<int>('user_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_userIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rhythm => $composableBuilder(
    column: $table.rhythm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runs => $composableBuilder(
    column: $table.runs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taskCount => $composableBuilder(
    column: $table.taskCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minStars => $composableBuilder(
    column: $table.minStars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minBolts => $composableBuilder(
    column: $table.minBolts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endedAtMs => $composableBuilder(
    column: $table.endedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get userId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lessonId => $composableBuilder(
    column: $table.lessonId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rhythm => $composableBuilder(
    column: $table.rhythm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runs => $composableBuilder(
    column: $table.runs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taskCount => $composableBuilder(
    column: $table.taskCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minStars => $composableBuilder(
    column: $table.minStars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minBolts => $composableBuilder(
    column: $table.minBolts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endedAtMs => $composableBuilder(
    column: $table.endedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get userId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssignmentsTable> {
  $$AssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lessonId =>
      $composableBuilder(column: $table.lessonId, builder: (column) => column);

  GeneratedColumn<String> get rhythm =>
      $composableBuilder(column: $table.rhythm, builder: (column) => column);

  GeneratedColumn<int> get runs =>
      $composableBuilder(column: $table.runs, builder: (column) => column);

  GeneratedColumn<int> get taskCount =>
      $composableBuilder(column: $table.taskCount, builder: (column) => column);

  GeneratedColumn<int> get minStars =>
      $composableBuilder(column: $table.minStars, builder: (column) => column);

  GeneratedColumn<int> get minBolts =>
      $composableBuilder(column: $table.minBolts, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endedAtMs =>
      $composableBuilder(column: $table.endedAtMs, builder: (column) => column);

  $$UsersTableAnnotationComposer get userId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.userId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssignmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssignmentsTable,
          AssignmentRow,
          $$AssignmentsTableFilterComposer,
          $$AssignmentsTableOrderingComposer,
          $$AssignmentsTableAnnotationComposer,
          $$AssignmentsTableCreateCompanionBuilder,
          $$AssignmentsTableUpdateCompanionBuilder,
          (AssignmentRow, $$AssignmentsTableReferences),
          AssignmentRow,
          PrefetchHooks Function({bool userId})
        > {
  $$AssignmentsTableTableManager(_$AppDatabase db, $AssignmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssignmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userId = const Value.absent(),
                Value<String> lessonId = const Value.absent(),
                Value<String> rhythm = const Value.absent(),
                Value<int> runs = const Value.absent(),
                Value<int> taskCount = const Value.absent(),
                Value<int> minStars = const Value.absent(),
                Value<int> minBolts = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int?> endedAtMs = const Value.absent(),
              }) => AssignmentsCompanion(
                id: id,
                userId: userId,
                lessonId: lessonId,
                rhythm: rhythm,
                runs: runs,
                taskCount: taskCount,
                minStars: minStars,
                minBolts: minBolts,
                createdAtMs: createdAtMs,
                endedAtMs: endedAtMs,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userId,
                required String lessonId,
                required String rhythm,
                required int runs,
                required int taskCount,
                required int minStars,
                required int minBolts,
                required int createdAtMs,
                Value<int?> endedAtMs = const Value.absent(),
              }) => AssignmentsCompanion.insert(
                id: id,
                userId: userId,
                lessonId: lessonId,
                rhythm: rhythm,
                runs: runs,
                taskCount: taskCount,
                minStars: minStars,
                minBolts: minBolts,
                createdAtMs: createdAtMs,
                endedAtMs: endedAtMs,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssignmentsTable, AssignmentRow>(table),
                  $$AssignmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (userId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.userId,
                        referencedTable: $$AssignmentsTableReferences
                            ._userIdTable(db),
                        referencedColumn: $$AssignmentsTableReferences
                            ._userIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AssignmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssignmentsTable,
      AssignmentRow,
      $$AssignmentsTableFilterComposer,
      $$AssignmentsTableOrderingComposer,
      $$AssignmentsTableAnnotationComposer,
      $$AssignmentsTableCreateCompanionBuilder,
      $$AssignmentsTableUpdateCompanionBuilder,
      (AssignmentRow, $$AssignmentsTableReferences),
      AssignmentRow,
      PrefetchHooks Function({bool userId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$AttemptsTableTableManager get attempts =>
      $$AttemptsTableTableManager(_db, _db.attempts);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$LessonPreferencesTableTableManager get lessonPreferences =>
      $$LessonPreferencesTableTableManager(_db, _db.lessonPreferences);
  $$LessonStarsTableTableManager get lessonStars =>
      $$LessonStarsTableTableManager(_db, _db.lessonStars);
  $$AssignmentsTableTableManager get assignments =>
      $$AssignmentsTableTableManager(_db, _db.assignments);
}
