import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/data/repositories/user_repository.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/admin/admin_screen.dart';
import 'package:mathe_trainer/features/leaderboard/leaderboard_screen.dart';
import 'package:mathe_trainer/features/profiles/profile_select_screen.dart';
import 'package:mathe_trainer/features/stats/global_stats_screen.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// The parent area and the overview across all children, driven the way a
/// parent drives them: from the profile screen, through the PIN pad.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int mia;
  late int tom;

  Future<void> run(
    int userId,
    String lessonId, {
    bool completed = true,
    int msPerTask = 5000,
    int taskCount = 10,
  }) async {
    final sessions = container.read(sessionRepositoryProvider);
    final id = await sessions.startSession(
      userId: userId,
      lessonId: lessonId,
      taskCount: taskCount,
      seed: 1,
    );
    await sessions.finishSession(
      sessionId: id,
      completed: completed,
      results: [
        for (var i = 0; i < taskCount; i++)
          TaskResult(
            task: Task(a: 40 + i, b: 30, op: Operation.add, form: TaskForm.result),
            elapsedMs: msPerTask,
            wrongAttempts: i == 0 ? 2 : 0,
          ),
      ],
    );
  }

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    final users = container.read(userRepositoryProvider);
    mia = await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
    tom = await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpProfiles(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const ProfileSelectScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> enterPin(WidgetTester tester, String pin) async {
    for (final digit in pin.split('')) {
      await tester.tap(find.byKey(Key('digit-$digit')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  group('PIN gate', () {
    testWidgets('the first visit sets a PIN up, entered twice', (tester) async {
      await pumpProfiles(tester);
      await tester.tap(find.text('Eltern'));
      await tester.pumpAndSettle();

      expect(find.text('Elternbereich einrichten'), findsOneWidget);
      expect(find.text('Wähle eine PIN aus 4 Ziffern'), findsOneWidget);

      await enterPin(tester, '4711');
      expect(find.text('PIN wiederholen'), findsOneWidget);
      await enterPin(tester, '4711');

      expect(find.byType(AdminScreen), findsOneWidget);
      expect(await container.read(settingsRepositoryProvider).hasAdminPin(),
          isTrue);
    });

    testWidgets('a mismatch during setup starts over', (tester) async {
      await pumpProfiles(tester);
      await tester.tap(find.text('Eltern'));
      await tester.pumpAndSettle();

      await enterPin(tester, '4711');
      await enterPin(tester, '1234');

      expect(find.text('Die beiden Eingaben waren verschieden.'),
          findsOneWidget);
      expect(find.byType(AdminScreen), findsNothing);
      expect(await container.read(settingsRepositoryProvider).hasAdminPin(),
          isFalse);
    });

    testWidgets('afterwards the PIN is asked for, and a wrong one refused',
        (tester) async {
      await container.read(settingsRepositoryProvider).setAdminPin('4711');
      await pumpProfiles(tester);

      await tester.tap(find.text('Eltern'));
      await tester.pumpAndSettle();
      expect(find.text('PIN eingeben'), findsOneWidget);

      await enterPin(tester, '1234');
      expect(find.text('Falsche PIN.'), findsOneWidget);
      expect(find.byType(AdminScreen), findsNothing);

      await enterPin(tester, '4711');
      expect(find.byType(AdminScreen), findsOneWidget);
    });

    testWidgets('creating a profile is behind the PIN, the look is not',
        (tester) async {
      await container.read(settingsRepositoryProvider).setAdminPin('4711');
      await pumpProfiles(tester);

      await tester.tap(find.text('Neu'));
      await tester.pumpAndSettle();
      expect(find.text('PIN eingeben'), findsOneWidget);
      expect(find.text('Neues Profil'), findsNothing);

      await enterPin(tester, '4711');
      expect(find.text('Neues Profil'), findsOneWidget);
      // Past the PIN the name may be typed - that is the point of the gate.
      // It is asked on its own first, so the keyboard has room.
      expect(find.widgetWithText(TextField, 'Name'), findsOneWidget);
      expect(find.text('Bild'), findsNothing);
    });

    testWidgets('a child may change picture and colour without the PIN',
        (tester) async {
      await container.read(settingsRepositoryProvider).setAdminPin('4711');
      await pumpProfiles(tester);

      await tester.tap(find.byTooltip('Bild und Farbe ändern').first);
      await tester.pumpAndSettle();

      // Straight to picture and colour, with their own name as the heading.
      expect(find.text('Mia'), findsWidgets);
      expect(find.text('Bild'), findsOneWidget);
      expect(find.text('Farbe'), findsOneWidget);
      // No name field, and no way to reach one: renaming is a parent job.
      expect(find.byType(TextField), findsNothing);
      expect(find.text('Name ändern'), findsNothing);
    });
  });

  group('parent area', () {
    Future<void> openAdmin(WidgetTester tester) async {
      await container.read(settingsRepositoryProvider).setAdminPin('4711');
      await pumpProfiles(tester);
      await tester.tap(find.text('Eltern'));
      await tester.pumpAndSettle();
      await enterPin(tester, '4711');
    }

    /// The Android back button, as the platform actually sends it - the way
    /// out a parent takes without thinking, and the one that used to throw
    /// away everything they had just set.
    Future<void> simulateBack(WidgetTester tester) async {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    }

    testWidgets('the history lists runs and marks the abandoned ones',
        (tester) async {
      await run(mia, 'add_20_plain');
      await run(tom, 'mix_100', completed: false);
      await openAdmin(tester);

      expect(find.text('Plus ohne Zehnerübergang  ·  Bis 20'), findsOneWidget);
      expect(find.textContaining('abgebrochen nach'), findsOneWidget);
      expect(find.text('Mia'), findsWidgets);
      expect(find.text('Tom'), findsWidgets);
    });

    testWidgets('the history can be filtered to one child', (tester) async {
      await run(mia, 'add_20_plain');
      await run(tom, 'mix_100');
      await openAdmin(tester);

      await tester.tap(find.text('🦊  Mia'));
      await tester.pumpAndSettle();

      expect(find.text('Plus ohne Zehnerübergang  ·  Bis 20'), findsOneWidget);
      expect(find.text('Plus und Minus gemischt  ·  Bis 100'), findsNothing);
    });

    testWidgets('the history can be narrowed to the last seven days',
        (tester) async {
      await run(mia, 'add_20_plain');
      await run(tom, 'mix_100');
      // Push Mia's run ten days back, so only Tom's is left inside a week.
      final rows = await db.select(db.sessions).get();
      final old = rows.firstWhere((s) => s.userId == mia);
      await (db.update(db.sessions)..where((s) => s.id.equals(old.id))).write(
        SessionsCompanion(
          finishedAtMs: Value(DateTime.now()
              .subtract(const Duration(days: 10))
              .millisecondsSinceEpoch),
        ),
      );
      await openAdmin(tester);

      // Both are there until the log is narrowed.
      expect(find.text('Plus ohne Zehnerübergang  ·  Bis 20'), findsOneWidget);

      await tester.tap(find.text('7 Tage'));
      await tester.pumpAndSettle();
      expect(find.text('Plus ohne Zehnerübergang  ·  Bis 20'), findsNothing);
      expect(find.text('Plus und Minus gemischt  ·  Bis 100'), findsOneWidget);

      // And the two filters narrow independently.
      await tester.tap(find.text('🐧  Tom'));
      await tester.pumpAndSettle();
      expect(find.text('Plus und Minus gemischt  ·  Bis 100'), findsOneWidget);
      await tester.tap(find.text('🦊  Mia'));
      await tester.pumpAndSettle();
      expect(find.text('Plus und Minus gemischt  ·  Bis 100'), findsNothing);
    });

    testWidgets('tidying up says whose runs and from when', (tester) async {
      await run(mia, 'add_20_plain', completed: false);
      await openAdmin(tester);

      await tester.tap(find.text('Heute'));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('aufräumen'));
      await tester.pumpAndSettle();

      // The question has to cover exactly what the button removes, now that
      // the list is filtered two ways.
      expect(find.textContaining('von allen Kindern von heute'),
          findsOneWidget);
    });

    testWidgets('a deletion can be taken back right away', (tester) async {
      await run(mia, 'add_20_plain');
      await openAdmin(tester);

      await tester.tap(find.byTooltip('Durchgang löschen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();
      expect(find.text('Plus ohne Zehnerübergang  ·  Bis 20'), findsNothing);

      // Nothing was ever erased, so the way back is one tap.
      expect(find.text('Rückgängig'), findsOneWidget);
      await tester.tap(find.text('Rückgängig'));
      await tester.pumpAndSettle();
      expect(find.text('Plus ohne Zehnerübergang  ·  Bis 20'), findsOneWidget);
    });

    testWidgets('and so can tidying up the abandoned ones', (tester) async {
      await run(mia, 'add_20_plain', completed: false);
      await openAdmin(tester);

      await tester.tap(find.textContaining('aufräumen'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Aufräumen'));
      await tester.pumpAndSettle();
      expect(find.textContaining('abgebrochen nach'), findsNothing);

      await tester.tap(find.text('Rückgängig'));
      await tester.pumpAndSettle();
      expect(find.textContaining('abgebrochen nach'), findsOneWidget);
    });

    testWidgets('a single run can be deleted from the log', (tester) async {
      await run(mia, 'add_20_plain');
      await openAdmin(tester);

      await tester.tap(find.byTooltip('Durchgang löschen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();

      expect(find.text('Noch keine Durchgänge.'), findsOneWidget);
      // Gone from the log, still on disk: the row carries the practised time,
      // and deleting a run must not hand that back.
      expect((await db.select(db.sessions).get()).single.deleted, isTrue);
    });

    testWidgets('abandoned runs can be tidied away in one go', (tester) async {
      await run(mia, 'add_20_plain');
      await run(mia, 'mix_100', completed: false);
      await openAdmin(tester);

      await tester.tap(find.textContaining('aufräumen (1)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aufräumen'));
      await tester.pumpAndSettle();

      // The finished run stays, the abandoned one is gone from the list, and
      // the button with it - there is nothing left to tidy.
      expect(find.text('Plus ohne Zehnerübergang  ·  Bis 20'), findsOneWidget);
      expect(find.textContaining('aufräumen'), findsNothing);
    });

    testWidgets('the PIN pad has no green key', (tester) async {
      // A PIN is exactly four digits, and the fourth submits it - so the
      // green key could only ever be pressed on an incomplete entry, where
      // it does nothing. That would teach the wrong thing about the green
      // key everywhere else.
      await pumpProfiles(tester);
      await tester.tap(find.text('Eltern'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('digit-1')), findsOneWidget);
      expect(find.byKey(const Key('backspace')), findsOneWidget);
      expect(find.byKey(const Key('submit')), findsNothing);
    });

    testWidgets('the fourth digit opens the parent area by itself',
        (tester) async {
      await pumpProfiles(tester);
      await tester.tap(find.text('Eltern'));
      await tester.pumpAndSettle();
      await enterPin(tester, '1234');
      await enterPin(tester, '1234');

      expect(find.text('Übungsverlauf'), findsOneWidget);
    });

    /// Opens Mia's settings. The whole row is the way in - it carries no
    /// buttons of its own any more.
    Future<void> openSettings(WidgetTester tester) async {
      await tester.tap(find.text('Verwaltung'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mia'));
      await tester.pumpAndSettle();
    }

    testWidgets('a profile can be locked and unlocked again', (tester) async {
      await openAdmin(tester);
      await openSettings(tester);
      // The lock sits in the first block, above everything else: it is what
      // a parent reaches for in a hurry.
      final lock = find.widgetWithText(
          SwitchListTile, 'Profil vorübergehend sperren');
      expect(lock, findsOneWidget);

      await tester.tap(lock);
      await tester.pump();
      // No scrolling to reach it: the app bar keeps it in sight.
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      final locked = await container.read(userRepositoryProvider).findUser(mia);
      expect(locked!.locked, isTrue);
      // Nothing else moved - a lock is a pause, not a reset.
      expect(locked.name, 'Mia');
      expect(locked.avatar, '🦊');
    });

    testWidgets('statistics can be reset per profile', (tester) async {
      await run(mia, 'add_20_plain');
      await run(tom, 'mix_100');
      await openAdmin(tester);

      await openSettings(tester);
      // "Aufräumen" sits at the foot of the screen, deliberately far from
      // the settings above it.
      await tester.dragUntilVisible(
        find.text('Ergebnisse löschen'),
        find.byType(ListView).first,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ergebnisse löschen'));
      await tester.pumpAndSettle();
      expect(find.text('Ergebnisse von Mia löschen?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Löschen'));
      await tester.pumpAndSettle();

      final left = await db.select(db.sessions).get();
      expect(left.map((s) => s.userId), [tom]);
      // The profile itself survives.
      expect(await container.read(userRepositoryProvider).findUser(mia),
          isNotNull);
    });

    testWidgets('groups can be switched off for one child', (tester) async {
      await openAdmin(tester);
      await tester.tap(find.text('Verwaltung'));
      await tester.pumpAndSettle();

      expect(find.text('Alle Bereiche'), findsNWidgets(2));

      await tester.tap(find.text('Mia'));
      await tester.pumpAndSettle();

      // The screen scrolls, so each switch has to be brought into view first.
      for (final group in ['Bis 1000', 'Einmaleins']) {
        final tile = find.widgetWithText(SwitchListTile, group);
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        await tester.tap(tile);
        await tester.pump();
      }
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      final users = container.read(userRepositoryProvider);
      expect((await users.findUser(mia))!.hidden,
          {LessonGroup.upTo1000, LessonGroup.timesTables});
      // Tom is untouched, and the summary says so.
      expect((await users.findUser(tom))!.hidden, isEmpty);
      expect(find.text('Alle Bereiche'), findsOneWidget);
    });

    testWidgets('the review of hard tasks can be switched off per child',
        (tester) async {
      await openAdmin(tester);
      await tester.tap(find.text('Verwaltung'));
      await tester.pumpAndSettle();

      // On by default - practising what already works is the least useful
      // thing this app could do.
      expect((await container.read(userRepositoryProvider).findUser(mia))!
          .reviewHardTasks, isTrue);

      await tester.tap(find.text('Mia'));
      await tester.pumpAndSettle();
      final review =
          find.widgetWithText(SwitchListTile, 'Schwere Aufgaben wiederholen');
      await tester.ensureVisible(review);
      await tester.pumpAndSettle();
      await tester.tap(review);
      await tester.pump();
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      final users = container.read(userRepositoryProvider);
      expect((await users.findUser(mia))!.reviewHardTasks, isFalse);
      // Only for this child.
      expect((await users.findUser(tom))!.reviewHardTasks, isTrue);
      expect(find.textContaining('ohne Wiederholung'), findsOneWidget);
    });

    testWidgets('leaving by the cross asks before throwing changes away',
        (tester) async {
      await openAdmin(tester);
      await openSettings(tester);

      final tile = find.widgetWithText(SwitchListTile, 'Bis 1000');
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.text('Änderungen verwerfen?'), findsOneWidget);

      // Thinking better of it leaves the screen open and the change intact.
      await tester.tap(find.widgetWithText(OutlinedButton, 'Abbrechen'));
      await tester.pumpAndSettle();
      expect(tile, findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Verwerfen'));
      await tester.pumpAndSettle();

      expect((await container.read(userRepositoryProvider).findUser(mia))!
          .hidden, isEmpty);
    });

    testWidgets('the back gesture asks too, and only when something changed',
        (tester) async {
      await openAdmin(tester);
      await openSettings(tester);

      // Nothing touched yet: going back must not interrupt with a question
      // nobody needs to answer.
      await simulateBack(tester);
      expect(find.text('Änderungen verwerfen?'), findsNothing);
      expect(find.text('Verwaltung'), findsOneWidget);

      await openSettings(tester);
      await tester.tap(
          find.widgetWithText(SwitchListTile, 'Profil vorübergehend sperren'));
      await tester.pump();
      // This is the way out that used to lose the changes without a word.
      await simulateBack(tester);
      expect(find.text('Änderungen verwerfen?'), findsOneWidget);
    });

    testWidgets('switching everything off is flagged in the dialog',
        (tester) async {
      await openAdmin(tester);
      await tester.tap(find.text('Verwaltung'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mia'));
      await tester.pumpAndSettle();

      for (final group in LessonGroup.values) {
        final tile = find.widgetWithText(SwitchListTile, groupTitle(group));
        await tester.ensureVisible(tile);
        await tester.pumpAndSettle();
        await tester.tap(tile);
        await tester.pump();
      }
      expect(find.textContaining('kann das Kind nicht üben'), findsOneWidget);
    });

    testWidgets('deleted runs can be brought back without the snack bar',
        (tester) async {
      // The snack bar right after the deed only helps whoever is still
      // looking at it. This is the other way, and it does not depend on it.
      await run(mia, 'add_20_plain');
      await openAdmin(tester);

      await tester.tap(find.byTooltip('Durchgang löschen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();
      expect(find.text('Plus ohne Zehnerübergang  ·  Bis 20'), findsNothing);

      // Nothing was ever erased, so looking is all it takes.
      await tester.tap(find.text('Gelöschte'));
      await tester.pumpAndSettle();
      expect(find.text('Plus ohne Zehnerübergang  ·  Bis 20'), findsOneWidget);

      await tester.tap(find.byTooltip('Wiederherstellen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gelöschte'));
      await tester.pumpAndSettle();
      expect(find.text('Plus ohne Zehnerübergang  ·  Bis 20'), findsOneWidget);
    });

    testWidgets('the tidy-up button counts past the end of the list',
        (tester) async {
      // More abandoned runs than the log shows at once. The count used to
      // come off the list on screen, so the button promised too few.
      for (var i = 0; i < 205; i++) {
        await run(mia, 'add_20_plain', completed: false);
      }
      await openAdmin(tester);

      expect(find.textContaining('aufräumen (205)'), findsOneWidget);
      expect(find.textContaining('letzten 200 Durchgänge'), findsOneWidget);
    });

    testWidgets('the parent area says when the last backup was',
        (tester) async {
      await openAdmin(tester);
      await tester.tap(find.text('Verwaltung'));
      await tester.pumpAndSettle();

      // Never backed up: everything this app knows lives on one tablet, and
      // nothing used to mention that.
      await tester.dragUntilVisible(
        find.text('Noch nie gesichert.'),
        find.byType(ListView).first,
        const Offset(0, -300),
      );
      expect(find.text('Noch nie gesichert.'), findsOneWidget);

      await container
          .read(settingsRepositoryProvider)
          .setLastBackup(DateTime.now().millisecondsSinceEpoch);
      await tester.pumpAndSettle();
      expect(find.textContaining('Zuletzt gesichert: heute'), findsOneWidget);
      expect(find.textContaining('eine Weile her'), findsNothing);
    });

    testWidgets('changing the PIN asks for a new one right away',
        (tester) async {
      await openAdmin(tester);
      await tester.tap(find.text('Verwaltung'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('PIN ändern'));
      await tester.pumpAndSettle();
      expect(find.text('Elternbereich einrichten'), findsOneWidget);

      await enterPin(tester, '0000');
      await enterPin(tester, '0000');

      final settings = container.read(settingsRepositoryProvider);
      expect(await settings.checkAdminPin('0000'), isTrue);
      expect(await settings.checkAdminPin('4711'), isFalse);
    });
  });

  group('overview across all children', () {
    testWidgets('shows a card per profile, including untouched ones',
        (tester) async {
      await run(mia, 'add_20_plain', msPerTask: 6000);
      await pumpProfiles(tester);

      await tester.tap(find.text('Alle Ergebnisse').last);
      await tester.pumpAndSettle();

      expect(find.byType(GlobalStatsScreen), findsOneWidget);
      expect(find.text('Mia'), findsOneWidget);
      expect(find.text('Tom'), findsOneWidget);
      // Mia: one run of 10 tasks at 6 s = 1 minute, 2 wrong out of 10.
      expect(find.text('1 min'), findsOneWidget);
      expect(find.text('20 %'), findsOneWidget);
      expect(find.text('zuletzt heute'), findsOneWidget);
      expect(find.text('Runde'), findsOneWidget);
      // Tom has not practised yet.
      expect(find.text('Noch nicht geübt.'), findsOneWidget);
    });

    testWidgets('every leaderboard is reachable from the second tab',
        (tester) async {
      await run(mia, 'times_7', msPerTask: 3000);
      await run(tom, 'times_7', msPerTask: 2000);
      await run(mia, 'add_20_plain', msPerTask: 6000);
      await pumpProfiles(tester);

      await tester.tap(find.text('Alle Ergebnisse').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bestenlisten'));
      await tester.pumpAndSettle();

      // Both played lessons are listed, with the podium visible at a glance.
      expect(find.text('7er-Reihe'), findsOneWidget);
      expect(find.text('Plus ohne Zehnerübergang'), findsOneWidget);
      expect(find.text('Einmaleins'), findsOneWidget);
      // Tom is faster in the 7er-Reihe, so his time leads. The listed value
      // is the scored one: 2 s per task plus 2 wrong attempts over 10 tasks.
      expect(find.text('2,6 s'), findsOneWidget);
      expect(find.text('3,6 s'), findsOneWidget);

      await tester.tap(find.text('7er-Reihe'));
      await tester.pumpAndSettle();
      expect(find.byType(LeaderboardScreen), findsOneWidget);
      expect(find.text('Bestenliste · 7er-Reihe'), findsOneWidget);
    });

    testWidgets('lessons without a ranking stay out of the list',
        (tester) async {
      // Too short to count, so there is nothing to rank yet.
      await run(mia, 'times_7', taskCount: 5, msPerTask: 1000);
      await pumpProfiles(tester);

      await tester.tap(find.text('Alle Ergebnisse').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bestenlisten'));
      await tester.pumpAndSettle();

      expect(find.text('7er-Reihe'), findsNothing);
      expect(find.textContaining('Noch keine Bestenlisten'), findsOneWidget);
    });
  });
}
