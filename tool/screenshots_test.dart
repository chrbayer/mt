import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/assignment.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/practice_limit.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/domain/task_generator.dart';
import 'package:mathe_trainer/features/admin/admin_screen.dart';
import 'package:mathe_trainer/features/lessons/lesson_home_screen.dart';
import 'package:mathe_trainer/features/practice/practice_screen.dart';
import 'package:mathe_trainer/features/profiles/profile_select_screen.dart';
import 'package:mathe_trainer/features/result/result_screen.dart';
import 'package:mathe_trainer/features/stats/stats_screen.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// Writes the store screenshots straight out of the app.
///
/// Not a test and deliberately not under `test/`, so `flutter test` leaves it
/// alone - a golden that has to be renewed after every change to a colour
/// would be a tax on every future change for no gain in correctness.
///
/// ```bash
/// flutter test tool/screenshots_test.dart --update-goldens
/// ```
///
/// The pictures land in `fastlane/metadata/android/de-DE/images/`, where
/// F-Droid picks them up without any further step.
///
/// **The run ends with one reported failure and that is expected.** Each
/// sound player opens an event channel whose name carries its own uuid, so
/// those cannot be mocked away by name, and the complaint arrives long after
/// the picture is written. Every one of the eight files is renewed
/// regardless - check the folder, not the exit code.
const _out = '../fastlane/metadata/android/de-DE/images/tenInchScreenshots';

/// Loads the three fonts a widget test does not bring along by itself.
///
/// Without them the pictures are full of empty boxes: the text font is
/// square, the Material icon font is not in the test bundle at all, and no
/// emoji font is either - so every star, every bolt and every bee comes out
/// as a placeholder.
///
/// The emoji font gets a family of its own and is hung into the theme as a
/// fallback. Putting it in the same family as the text font looked tidier
/// and did nothing: within one family the engine picks a variant, it does
/// not go looking for a missing glyph in another file.
const _emojiFamily = 'ScreenshotEmoji';

/// A second fallback, for the characters that are neither letters nor emoji.
///
/// The app writes a minimum as `mind. 2 ★` (U+2605). Roboto has no such
/// glyph and neither does the colour emoji font, so with those two alone the
/// parent screen printed `mind. 2 ▯`. DejaVu has it.
const _symbolFamily = 'ScreenshotSymbols';

Future<void> _loadFonts() async {
  final flutterRoot = File(Platform.resolvedExecutable).parent.parent.parent;
  final home = Platform.environment['HOME'];
  // Roboto first, and not out of tidiness: it is what Android actually uses,
  // so with it the picture has the line breaks a device has. DejaVu is a good
  // deal wider, and under it the statistics table broke "Zehnerübergang"
  // across two lines - a layout fault in the screenshot that does not exist
  // in the app.
  final text = [
    '$home/.fonts/Roboto-Regular.ttf',
    '/usr/share/fonts/google-roboto-fonts/Roboto-Regular.ttf',
    '/usr/share/fonts/truetype/roboto/Roboto-Regular.ttf',
    '/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf',
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
  ];
  final bold = [
    '$home/.fonts/Roboto-Medium.ttf',
    '/usr/share/fonts/google-roboto-fonts/Roboto-Medium.ttf',
  ];
  const emoji = [
    // Colour first: the app shows colour emoji on a device, and a store
    // picture of black-and-white apples would be a picture of a different
    // app.
    '/usr/share/fonts/google-noto-color-emoji-fonts/Noto-COLRv1.ttf',
    '/usr/share/fonts/truetype/noto/NotoColorEmoji.ttf',
    '/usr/share/fonts/google-noto-emoji-fonts/NotoEmoji-Regular.ttf',
  ];
  final icons = [
    '${flutterRoot.path}/bin/cache/artifacts/material_fonts/'
        'MaterialIcons-Regular.otf',
    '${Platform.environment['HOME']}/flutter/bin/cache/artifacts/'
        'material_fonts/MaterialIcons-Regular.otf',
  ];

  String? first(List<String> candidates) {
    for (final path in candidates) {
      if (File(path).existsSync()) return path;
    }
    return null;
  }

  Future<void> load(String family, List<String?> paths) async {
    final loader = FontLoader(family);
    var any = false;
    for (final path in paths) {
      if (path == null) continue;
      loader.addFont(
          Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
      any = true;
    }
    if (any) await loader.load();
  }

  final textFont = first(text);
  final emojiFont = first(emoji);
  final symbolFont = first(const [
    '/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf',
    '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
  ]);
  for (final family in ['Roboto', '.SF UI Text', '.SF UI Display']) {
    await load(family, [textFont, first(bold)]);
  }
  await load(_emojiFamily, [emojiFont]);
  await load(_symbolFamily, [symbolFont]);
  await load('MaterialIcons', [first(icons)]);

  if (textFont == null || emojiFont == null || first(icons) == null) {
    // Said out loud: a picture full of boxes is easy to miss in a folder and
    // embarrassing in a store listing.
    // ignore: avoid_print
    print('ACHTUNG: nicht alle Schriften gefunden - '
        'Text $textFont, Emoji $emojiFont, Symbole ${first(icons)}');
  }
}

void _silenceAudio() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  for (final name in ['xyz.luan/audioplayers', 'xyz.luan/audioplayers.global']) {
    messenger.setMockMethodCallHandler(
        MethodChannel(name), (call) async => null);
  }

  // Each player also opens an event channel whose name carries its own uuid,
  // so those cannot be mocked by name. They fail late, after the picture is
  // long written, and the only thing left to do is not to let that one kind
  // of failure colour the run red. Everything else still does.
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    if (details.exception is MissingPluginException) return;
    previous?.call(details);
  };
  addTearDown(() => FlutterError.onError = previous);
}

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late User mia;

  setUpAll(_loadFonts);
  setUp(_silenceAudio);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    final users = container.read(userRepositoryProvider);
    final miaId =
        await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
    await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);
    await users.createUser(name: 'Lea', avatar: '🦖', colorIndex: 3);
    mia = (await users.findUser(miaId))!;
    container.read(activeUserProvider.notifier).select(mia);
    // The caps would otherwise lock the fabricated practice out.
    await container.read(settingsRepositoryProvider).setPracticeLimits(
        const PracticeLimits(
            stretchMinutes: 0, breakMinutes: 15, dailyMinutes: 0));

    // Enough history that the screens have something to show. Every lesson
    // gets its **own** pace and its own slips: with one shared set of numbers
    // the statistics table repeated `4,7 s / 6,5 s / 3 % / 4` down every row,
    // which reads as a mock-up rather than as a child's record.
    final sessions = container.read(sessionRepositoryProvider);
    const practised = <String, (int, int)>{
      // lesson: starting time per task in ms, and how many tasks were missed
      // across the four runs.
      'add_20_plain': (7400, 1),
      'add_20_carry': (9100, 5),
      'sub_20_plain': (8600, 3),
      'times_2': (6900, 2),
      'times_5': (7700, 4),
      'add_100_plain': (10200, 6),
      'clock_half': (8800, 2),
    };
    // The first group is what the catalogue shot opens on, so most of it is
    // practised: a screen of grey stars and "noch nicht geübt" would sell an
    // app nobody has used.
    final history = <String, (int, int)>{
      for (final (index, lesson)
          in lessonsInGroup(LessonGroup.firstSteps).take(9).indexed)
        lesson.id: (4600 + index * 350, index % 3),
      ...practised,
    };
    // Each run gets a day of its own, oldest first. Left at `DateTime.now()`
    // they all land in the same millisecond, and the learning curve then
    // draws them in whatever order the query happens to return - the first
    // version of this picture showed a child getting slower.
    final today = DateTime.now();
    var lessonIndex = 0;
    for (final entry in history.entries) {
      final (start, slips) = entry.value;
      var left = slips;
      final lesson = lessonById(entry.key);
      for (final (index, share) in [1.0, 0.82, 0.68, 0.61].indexed) {
        // Real tasks from the real generator. Made-up ones showed sums under
        // a picture-counting lesson, and "Diese Aufgaben dauern am längsten"
        // is the one panel that puts them on screen verbatim.
        final tasks = generateTasks(lesson: lesson, count: 10, seed: index);
        final id = await sessions.startSession(
          userId: mia.id,
          lessonId: entry.key,
          taskCount: 10,
          seed: index,
        );
        // The early runs carry the mistakes: that is what the learning curve
        // is supposed to show.
        final wrongHere = index == 3 ? 0 : (left + 3 - index) ~/ (4 - index);
        left -= wrongHere;
        await sessions.finishSession(
          sessionId: id,
          completed: true,
          results: [
            for (var i = 0; i < 10; i++)
              TaskResult(
                task: tasks[i],
                elapsedMs: (start * share).round() + (i % 5) * 420 - 700,
                wrongAttempts: i < wrongHere ? 1 : 0,
              ),
          ],
        );
        // Spread over the last three weeks, four runs per lesson, so the
        // curve, the streak and "today" all have something to say.
        final day = DateTime(today.year, today.month,
            today.day - (18 - index * 5 - lessonIndex % 3));
        final finished = day.add(const Duration(hours: 16));
        await (db.update(db.sessions)..where((t) => t.id.equals(id))).write(
          SessionsCompanion(
            startedAtMs: Value(finished.millisecondsSinceEpoch - 60000),
            finishedAtMs: Value(finished.millisecondsSinceEpoch),
          ),
        );
      }
      lessonIndex++;
    }
  });

  /// Two assignments, so the newest feature is not the only one with no
  /// picture: one daily that Mia has already earned today, one weekly that is
  /// still open. Together they show both states of the card.
  Future<void> giveAssignments() async {
    final assignments = container.read(assignmentRepositoryProvider);
    await assignments.createAssignment(
      userId: mia.id,
      lessonIds: ['times_5'],
      rhythm: AssignmentRhythm.daily,
      runs: 1,
      taskCount: 20,
      minStars: 2,
      minBolts: 1,
    );
    await assignments.createAssignment(
      userId: mia.id,
      lessonIds: ['add_100_plain', 'sub_100_plain'],
      rhythm: AssignmentRhythm.weekly,
      runs: 3,
      taskCount: 20,
      minStars: 3,
      minBolts: 0,
      carryOver: true,
    );

    // And one run today that clears the daily one, so the card with the green
    // tick is in the picture too. Twenty tasks, two slips: enough for the two
    // stars and the one bolt the assignment asks for.
    final sessions = container.read(sessionRepositoryProvider);
    final lesson = lessonById('times_5');
    final tasks = generateTasks(lesson: lesson, count: 20, seed: 9);
    final id = await sessions.startSession(
        userId: mia.id, lessonId: lesson.id, taskCount: 20, seed: 9);
    await sessions.finishSession(
      sessionId: id,
      completed: true,
      results: [
        for (var i = 0; i < 20; i++)
          TaskResult(
            task: tasks[i],
            elapsedMs: 3600 + (i % 4) * 300,
            wrongAttempts: i < 2 ? 1 : 0,
          ),
      ],
    );
  }

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> shoot(
    WidgetTester tester,
    String name,
    Widget screen, {
    Future<void> Function(WidgetTester)? after,
  }) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: _screenshotTheme(),
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (after != null) await after(tester);

    await expectLater(
        find.byType(MaterialApp), matchesGoldenFile('$_out/$name'));
  }

  testWidgets('01 Katalog', (tester) async {
    await shoot(tester, '01-katalog.png', const LessonHomeScreen());
  });

  testWidgets('02 Übung', (tester) async {
    await shoot(
      tester,
      '02-uebung.png',
      PracticeScreen(lesson: lessonById('add_100_carry'), taskCount: 10),
    );
  });

  testWidgets('03 Ergebnis', (tester) async {
    await shoot(
      tester,
      '03-ergebnis.png',
      ResultScreen(
        lesson: lessonById('add_100_carry'),
        sessionId: null,
        taskCount: 10,
        totalMs: 41000,
        wrongAttempts: 0,
      ),
    );
  });

  testWidgets('04 Erste Schritte', (tester) async {
    await shoot(
      tester,
      '04-erste-schritte.png',
      PracticeScreen(lesson: lessonById('bees_add'), taskCount: 10),
    );
  });

  testWidgets('05 Uhrzeit', (tester) async {
    await shoot(
      tester,
      '05-uhrzeit.png',
      PracticeScreen(lesson: lessonById('clock_quarter'), taskCount: 10),
    );
  });

  testWidgets('06 Statistik', (tester) async {
    await shoot(tester, '06-statistik.png', const StatsScreen());
  });


  testWidgets('07 Profile', (tester) async {
    await giveAssignments();
    container.read(activeUserProvider.notifier).logout();
    await shoot(tester, '07-profile.png', const ProfileSelectScreen());
  });

  testWidgets('09 Aufgaben (Kind)', (tester) async {
    await giveAssignments();
    await shoot(tester, '09-aufgaben.png', const LessonHomeScreen());
  });

  testWidgets('10 Aufgaben (Eltern)', (tester) async {
    await giveAssignments();
    await shoot(
      tester,
      '10-aufgaben-eltern.png',
      const AdminScreen(),
      after: (t) async {
        // Not `find.text`: "Aufgaben" also labels the cards below.
        await t.tap(find.widgetWithText(Tab, 'Aufgaben'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('08 Elternbereich', (tester) async {
    await shoot(
      tester,
      '08-elternbereich.png',
      const AdminScreen(),
      after: (t) async {
        await t.tap(find.widgetWithText(Tab, 'Einstellungen'));
        await t.pumpAndSettle();
      },
    );
  });
}

/// The app's theme, with the fonts this environment needs spelled out.
///
/// Two things have to be said that the app never has to say: the text family
/// by name, and the emoji family as a fallback. On a device both come from
/// the platform for free - `appBarTheme.titleTextStyle`, for instance, names
/// no family at all and gets Roboto. Here that same style fell through to
/// the square test font, and the profile name in the app bar came out as a
/// row of black boxes.
ThemeData _screenshotTheme() {
  final base = buildAppTheme();
  const fallback = [_emojiFamily, _symbolFamily];
  TextStyle? named(TextStyle? style) =>
      style?.copyWith(fontFamily: 'Roboto', fontFamilyFallback: fallback);

  // Buttons carry their label style in a WidgetStateProperty of their own,
  // so they miss everything done to the text themes above.
  ButtonStyle? button(ButtonStyle? style) => style?.copyWith(
        textStyle: WidgetStateProperty.resolveWith(
          (states) => named(style.textStyle?.resolve(states) ??
              const TextStyle(fontSize: 20)),
        ),
      );

  return base.copyWith(
    textTheme:
        base.textTheme.apply(fontFamily: 'Roboto', fontFamilyFallback: fallback),
    primaryTextTheme: base.primaryTextTheme
        .apply(fontFamily: 'Roboto', fontFamilyFallback: fallback),
    appBarTheme: base.appBarTheme.copyWith(
      titleTextStyle: named(base.appBarTheme.titleTextStyle),
      toolbarTextStyle: named(base.appBarTheme.toolbarTextStyle),
    ),
    chipTheme: base.chipTheme.copyWith(
      labelStyle: named(base.chipTheme.labelStyle ??
          base.textTheme.labelLarge ??
          const TextStyle(fontSize: 14)),
      secondaryLabelStyle: named(base.chipTheme.secondaryLabelStyle ??
          base.textTheme.labelLarge ??
          const TextStyle(fontSize: 14)),
    ),
    filledButtonTheme:
        FilledButtonThemeData(style: button(base.filledButtonTheme.style)),
    textButtonTheme:
        TextButtonThemeData(style: button(base.textButtonTheme.style)),
    outlinedButtonTheme:
        OutlinedButtonThemeData(style: button(base.outlinedButtonTheme.style)),
  );
}

