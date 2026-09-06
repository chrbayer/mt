import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/features/lessons/start_lesson_sheet.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// The preselected run length has three levels. Changing it while starting a
/// lesson must stay with that lesson - it used to overwrite the app-wide
/// default for everyone.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int mia;
  late int tom;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    final users = container.read(userRepositoryProvider);
    mia = await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
    tom = await users.createUser(name: 'Tom', avatar: '🐧', colorIndex: 1);
    container
        .read(activeUserProvider.notifier)
        .select((await users.findUser(mia))!);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> openSheet(WidgetTester tester, String lessonId) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () =>
                    StartLessonSheet.show(context, lessonById(lessonId)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  int? preselected(WidgetTester tester) {
    for (final option in selectableTaskCounts) {
      final label = find.descendant(
        of: find.byType(StartLessonSheet),
        matching: find.text('$option'),
      );
      if (label.evaluate().isEmpty) continue;
      if (tester.widget<Text>(label).style?.color == Colors.white) {
        return option;
      }
    }
    return null;
  }

  testWidgets('with nothing set, ten is preselected', (tester) async {
    await openSheet(tester, 'times_7');
    expect(preselected(tester), 10);
  });

  testWidgets('the app-wide default applies to every lesson', (tester) async {
    await container.read(settingsRepositoryProvider).setDefaultTaskCount(30);
    await openSheet(tester, 'times_7');
    expect(preselected(tester), 30);
  });

  testWidgets('a profile setting beats the app-wide one', (tester) async {
    await container.read(settingsRepositoryProvider).setDefaultTaskCount(30);
    final users = container.read(userRepositoryProvider);
    await users.setProfileTaskCount(mia, 20);
    container
        .read(activeUserProvider.notifier)
        .select((await users.findUser(mia))!);

    await openSheet(tester, 'times_7');
    expect(preselected(tester), 20);
  });

  testWidgets('what was chosen for a lesson beats both', (tester) async {
    await container.read(settingsRepositoryProvider).setDefaultTaskCount(30);
    await container
        .read(userRepositoryProvider)
        .setProfileTaskCount(mia, 20);
    await container.read(settingsRepositoryProvider).setLessonTaskCount(
        userId: mia, lessonId: 'times_7', count: 50);

    await openSheet(tester, 'times_7');
    expect(preselected(tester), 50);
  });

  testWidgets('changing it at the start sticks to that lesson only',
      (tester) async {
    await openSheet(tester, 'times_7');
    expect(preselected(tester), 10);

    await tester.tap(find.descendant(
      of: find.byType(StartLessonSheet),
      matching: find.text('30'),
    ));
    await tester.pump();
    await tester.tap(find.text("Los geht's"));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Take the practice screen down again before asking the database
    // anything - its own writes are still in flight otherwise.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));

    // Read the table directly: awaiting a drift *stream* inside a widget
    // test deadlocks, because nothing pumps it.
    final prefs = await db.select(db.lessonPreferences).get();
    // Remembered for this lesson, and for nothing else - not another lesson,
    // not another child.
    expect(prefs, hasLength(1));
    expect(prefs.single.userId, mia);
    expect(prefs.single.lessonId, 'times_7');
    expect(prefs.single.taskCount, 30);

    // And above all not for the profile or for everyone.
    expect(
      (await container.read(userRepositoryProvider).findUser(mia))!
          .defaultTaskCount,
      isNull,
    );
    expect(
      (await container.read(settingsRepositoryProvider).load())
          .defaultTaskCount,
      10,
    );
    expect(tom, isNotNull);
  });

  testWidgets('another lesson keeps following the profile', (tester) async {
    final users = container.read(userRepositoryProvider);
    await users.setProfileTaskCount(mia, 20);
    await container.read(settingsRepositoryProvider).setLessonTaskCount(
        userId: mia, lessonId: 'times_7', count: 50);
    container
        .read(activeUserProvider.notifier)
        .select((await users.findUser(mia))!);

    await openSheet(tester, 'add_20_carry');
    expect(preselected(tester), 20);
  });
}
