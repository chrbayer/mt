import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/domain/task.dart';
import 'package:mathe_trainer/features/admin/admin_screen.dart';
import 'package:mathe_trainer/features/admin/global_settings_tab.dart';
import 'package:mathe_trainer/features/admin/profile_settings_dialog.dart';
import 'package:mathe_trainer/features/admin/reset_stars_dialog.dart';
import 'package:mathe_trainer/features/leaderboard/leaderboard_screen.dart';
import 'package:mathe_trainer/features/lessons/lesson_home_screen.dart';
import 'package:mathe_trainer/features/practice/practice_screen.dart';
import 'package:mathe_trainer/features/profiles/profile_select_screen.dart';
import 'package:mathe_trainer/features/result/result_screen.dart';
import 'package:mathe_trainer/features/settings/settings_screen.dart';
import 'package:mathe_trainer/features/stats/global_stats_screen.dart';
import 'package:mathe_trainer/features/stats/stats_screen.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// Every screen is rendered at real tablet sizes. A `RenderFlex overflowed`
/// error fails the test, which is the cheap way to catch a layout that breaks
/// on a smaller 10" tablet.
const tabletSizes = <String, Size>{
  '10zoll': Size(1280, 800),
  'gross': Size(1600, 1000),
};

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late User mia;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );

    final users = container.read(userRepositoryProvider);
    final miaId =
        await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
    await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);
    await users.createUser(name: 'Jonas', avatar: '🦖', colorIndex: 2);
    mia = (await users.findUser(miaId))!;
    container.read(activeUserProvider.notifier).select(mia);

    // Some history so statistics and leaderboards have something to show.
    final sessions = container.read(sessionRepositoryProvider);
    for (final (index, ms) in [7200, 6100, 5400, 4800].indexed) {
      final id = await sessions.startSession(
        userId: mia.id,
        lessonId: 'add_100_carry',
        taskCount: 10,
        seed: index,
      );
      await sessions.finishSession(
        sessionId: id,
        completed: true,
        results: [
          for (var i = 0; i < 10; i++)
            TaskResult(
              task: Task(
                a: 47 + i,
                b: 38,
                op: Operation.add,
                form: TaskForm.result,
              ),
              elapsedMs: ms + i * 120,
              wrongAttempts: i == 3 ? 1 : 0,
            ),
        ],
      );
    }
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen,
    Size size,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: screen,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  final screens = <String, Widget Function()>{
    '01-profile-auswahl': () => const ProfileSelectScreen(),
    '02-lektionen': () => const LessonHomeScreen(),
    '03-uebung': () => PracticeScreen(
          lesson: lessonById('add_100_carry'),
          taskCount: 10,
        ),
    // Not written as an equation, so it lays out differently: a question line
    // above, and a heart where the operator would be.
    '03b-verliebte-zahlen': () => PracticeScreen(
          lesson: lessonById('partners_of_ten'),
          taskCount: 10,
        ),
    // The widest task there is: two answer boxes plus the word "Rest".
    '03c-geteilt-mit-rest': () => PracticeScreen(
          lesson: lessonById('div_remainder'),
          taskCount: 10,
        ),
    // Pictures to count, dice to read, two heaps to compare, a number line.
    '02a-zaehlen': () => PracticeScreen(
          lesson: lessonById('count_pictures'),
          taskCount: 5,
        ),
    '02b-wuerfel': () => PracticeScreen(
          lesson: lessonById('dice_add'),
          taskCount: 5,
        ),
    '02a2-zaehlen-wolke': () => PracticeScreen(
          lesson: lessonById('count_pictures_cloud'),
          taskCount: 5,
        ),
    '02b3-bienchen-wolke': () => PracticeScreen(
          lesson: lessonById('bees_add_cloud'),
          taskCount: 5,
        ),
    '02b2-bienchen': () => PracticeScreen(
          lesson: lessonById('bees_add'),
          taskCount: 5,
        ),
    '02c-vergleichen': () => PracticeScreen(
          lesson: lessonById('compare_more'),
          taskCount: 5,
        ),
    '02c2-vergleichen-wolke': () => PracticeScreen(
          lesson: lessonById('compare_more_cloud'),
          taskCount: 5,
        ),
    '03e-uhrzeit-sagen': () => PracticeScreen(
          lesson: lessonById('clock_words'),
          taskCount: 5,
        ),
    '03f-uhrzeit-24': () => PracticeScreen(
          lesson: lessonById('clock_24'),
          taskCount: 5,
        ),
    '03g-geld-legen': () => PracticeScreen(
          lesson: lessonById('money_compose'),
          taskCount: 5,
        ),
    '03h-rueckgeld': () => PracticeScreen(
          lesson: lessonById('money_change'),
          taskCount: 5,
        ),
    '02d-zahlenreihe': () => PracticeScreen(
          lesson: lessonById('count_next'),
          taskCount: 5,
        ),
    // A drawn clock next to two boxes.
    '03d-uhrzeit': () => PracticeScreen(
          lesson: lessonById('clock_five'),
          taskCount: 10,
        ),
    // Two amounts, two boxes and two units.
    '03e-geld': () => PracticeScreen(
          lesson: lessonById('money_add'),
          taskCount: 10,
        ),
    '04-ergebnis': () => ResultScreen(
          lesson: lessonById('add_100_carry'),
          sessionId: null,
          taskCount: 10,
          totalMs: 48000,
          wrongAttempts: 1,
        ),
    '05-bestenliste': () =>
        LeaderboardScreen(lesson: lessonById('add_100_carry')),
    '06-statistik': () => const StatsScreen(),
    '07-einstellungen': () => const SettingsScreen(),
    '09-alle-ergebnisse': () => const GlobalStatsScreen(),
    '10-elternbereich': () => const AdminScreen(),
  };

  for (final size in tabletSizes.entries) {
    for (final screen in screens.entries) {
      testWidgets('${screen.key} passt auf ${size.key}', (tester) async {
        await pumpScreen(tester, screen.value(), size.value);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('10b-elternbereich-verwaltung passt auf ${size.key}',
        (tester) async {
      await pumpScreen(tester, const AdminScreen(), size.value);
      await tester.tap(find.text('Verwaltung'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('09b-bestenlisten passt auf ${size.key}', (tester) async {
      await pumpScreen(tester, const GlobalStatsScreen(), size.value);
      await tester.tap(find.text('Bestenlisten'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('13-einstellungen-mit-profil passt auf ${size.key}',
        (tester) async {
      // A child's own settings, reached from inside their own screen: the
      // run length is theirs, and nothing here says whose it is.
      final users = container.read(userRepositoryProvider);
      container
          .read(activeUserProvider.notifier)
          .select((await users.findUser(mia.id))!);
      await pumpScreen(tester, const SettingsScreen(), size.value);
      expect(tester.takeException(), isNull);
      expect(find.text('Aufgaben pro Durchgang'), findsOneWidget);
      expect(find.text('Für Mia'), findsNothing);
      expect(find.text('Für alle'), findsNothing);
      // What holds for everyone is behind the PIN now.
      expect(find.byType(SwitchListTile), findsNothing);
    });

    testWidgets('13b-profileinstellungen passt auf ${size.key}',
        (tester) async {
      // Grown section by section - Aufgabenzahl, Übungszeit, Tagesgrenze,
      // Filter, Bereiche - and each one was added without a test here.
      await pumpScreen(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => ProfileSettingsDialog.show(context, mia),
            child: const Text('auf'),
          ),
        ),
        size.value,
      );
      await tester.tap(find.text('auf'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Scrolled to the bottom it must still not overflow.
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Speichern'), findsOneWidget);
    });

    testWidgets('13c-sterne-zuruecksetzen passt auf ${size.key}',
        (tester) async {
      // One row per group, nine of them, each with a button - the tallest
      // dialog in the app.
      await pumpScreen(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => ResetStarsDialog.show(context, mia),
            child: const Text('auf'),
          ),
        ),
        size.value,
      );
      await tester.tap(find.text('auf'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Fertig'), findsOneWidget);
    });

    testWidgets('14-elternbereich-einstellungen passt auf ${size.key}',
        (tester) async {
      await pumpScreen(
          tester, const Scaffold(body: GlobalSettingsTab()), size.value);
      expect(tester.takeException(), isNull);
      expect(find.text('Uhr während der Übung zeigen'), findsOneWidget);
      expect(find.text('Aufgaben pro Durchgang für alle'), findsOneWidget);
    });

    testWidgets('12-bereiche-dialog passt auf ${size.key}', (tester) async {
      await pumpScreen(tester, const AdminScreen(), size.value);
      await tester.tap(find.text('Verwaltung'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Einstellungen').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Every group must be reachable, and so must the save button.
      for (final group in LessonGroup.values) {
        expect(find.text(groupTitle(group)), findsOneWidget);
      }
      expect(find.text('Speichern'), findsOneWidget);
    });

    testWidgets('11-pin-dialog passt auf ${size.key}', (tester) async {
      await pumpScreen(tester, const ProfileSelectScreen(), size.value);
      await tester.tap(find.text('Eltern'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // The keypad is tall; on a short tablet the dialog has to scroll
      // instead of clipping the cancel button.
      expect(find.text('Abbrechen'), findsOneWidget);
      expect(find.byKey(const Key('digit-5')), findsOneWidget);
    });

    // The start sheet is only ~640 dp wide no matter how big the tablet is,
    // and it grows with the lesson title and the help text - so it gets its
    // own check instead of riding along with the screen behind it.
    testWidgets('08-startdialog passt auf ${size.key}', (tester) async {
      await pumpScreen(tester, const LessonHomeScreen(), size.value);
      // Two groups and a recommendation card sit above it, and off-screen
      // slivers are not built - so it has to be scrolled into existence.
      final all = find.text('Plus mit Zehnerübergang');
      for (var i = 0; i < 15 && all.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -400));
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(all.first);
      await tester.pumpAndSettle();
      await tester.tap(all.first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip('Was heißt das?'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Both actions must be reachable, not clipped off the sheet.
      expect(find.text("Los geht's"), findsOneWidget);
      expect(find.text('Bestenliste'), findsOneWidget);
      for (final label in ["Los geht's", 'Bestenliste']) {
        final box = tester.getRect(find.text(label));
        expect(box.right, lessThanOrEqualTo(size.value.width), reason: label);
        expect(box.bottom, lessThanOrEqualTo(size.value.height), reason: label);
      }
    });
  }
}
