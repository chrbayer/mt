import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/features/lessons/lesson_home_screen.dart';
import 'package:mathe_trainer/features/profiles/profile_select_screen.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// A locked profile is a pause, not a deletion: it cannot be opened, and
/// everything it collected is untouched when it comes back.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late int mia;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    mia = await container
        .read(userRepositoryProvider)
        .createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
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

  testWidgets('an open profile still opens', (tester) async {
    await pumpProfiles(tester);
    await tester.tap(find.text('Mia'));
    await tester.pumpAndSettle();

    expect(find.byType(LessonHomeScreen), findsOneWidget);
  });

  testWidgets('a locked one says so instead of opening', (tester) async {
    await container.read(userRepositoryProvider).setLocked(mia, true);
    await pumpProfiles(tester);

    await tester.tap(find.text('Mia'));
    await tester.pumpAndSettle();

    expect(find.byType(LessonHomeScreen), findsNothing);
    // Silence would read as a broken app, and a child needs to hear that
    // nothing of theirs is gone.
    expect(find.text('Mia macht gerade Pause'), findsOneWidget);
    expect(find.textContaining('bleiben erhalten'), findsOneWidget);
  });

  testWidgets('and wears a lock instead of the palette', (tester) async {
    // The "Eltern" button in the app bar wears a padlock too, so the tile's
    // own is counted as the second one.
    await pumpProfiles(tester);
    expect(find.byIcon(Icons.palette_outlined), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);

    await container.read(userRepositoryProvider).setLocked(mia, true);
    await tester.pumpAndSettle();

    // Choosing a colour for a tile that will not open is a door to nowhere.
    expect(find.byIcon(Icons.palette_outlined), findsNothing);
    expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
  });

  testWidgets('unlocking opens it again, unchanged', (tester) async {
    final users = container.read(userRepositoryProvider);
    await users.setLocked(mia, true);
    await users.setLocked(mia, false);
    await pumpProfiles(tester);

    await tester.tap(find.text('Mia'));
    await tester.pumpAndSettle();
    expect(find.byType(LessonHomeScreen), findsOneWidget);
  });

  test('locking touches nothing but the lock', () async {
    final users = container.read(userRepositoryProvider);
    final before = await users.findUser(mia);
    await users.setLocked(mia, true);
    final after = await users.findUser(mia);

    expect(after!.locked, isTrue);
    expect(after.name, before!.name);
    expect(after.avatar, before.avatar);
    expect(after.colorIndex, before.colorIndex);
    expect(after.hiddenGroups, before.hiddenGroups);
    expect(after.defaultTaskCount, before.defaultTaskCount);
    expect(after.dailyLimitMinutes, before.dailyLimitMinutes);
  });
}
