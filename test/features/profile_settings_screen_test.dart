import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/features/admin/profile_settings_screen.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// The parents' side of `users.hide_done_assignments`: a switch next to
/// "Fertige Lektionen ausblenden", saved like everything else on this screen.
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
    mia = (await users.findUser(
        await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0)))!;
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          // A real route below it, as in the app: `ProfileSettingsScreen`
          // pops itself on save, and a screen with nothing under it to pop
          // to cannot be told apart from one that failed to.
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => ProfileSettingsScreen.show(context, mia),
                child: const Text('auf'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('auf'));
    await tester.pumpAndSettle();
  }

  testWidgets('off by default, and switching it on survives Speichern',
      (tester) async {
    await pumpScreen(tester);

    final tile = find.widgetWithText(
        SwitchListTile, 'Erledigte Aufgaben ausblenden');
    expect(tester.widget<SwitchListTile>(tile).value, isFalse);

    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pump();
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    final users = container.read(userRepositoryProvider);
    expect((await users.findUser(mia.id))!.hideDoneAssignments, isTrue);
  });

  testWidgets('leaving without saving does not touch it', (tester) async {
    await pumpScreen(tester);

    final tile = find.widgetWithText(
        SwitchListTile, 'Erledigte Aufgaben ausblenden');
    await tester.ensureVisible(tile);
    await tester.pumpAndSettle();
    await tester.tap(tile);
    await tester.pump();

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    // Discards the change: the same dialog every destructive action here
    // uses.
    await tester.tap(find.text('Verwerfen'));
    await tester.pumpAndSettle();

    final users = container.read(userRepositoryProvider);
    expect((await users.findUser(mia.id))!.hideDoneAssignments, isFalse);
  });
}
