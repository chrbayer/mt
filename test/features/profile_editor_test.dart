import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/features/profiles/profile_editor.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// Naming a profile is the only place the system keyboard appears, and in the
/// app's forced landscape it eats most of the screen. These tests pin down
/// that the name step still works with a keyboard up - on a tablet and on a
/// phone.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpEditor(
    WidgetTester tester, {
    Size size = const Size(1600, 1000),
    double keyboard = 0,
    User? user,
    bool allowRename = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    tester.view.viewInsets = FakeViewPadding(bottom: keyboard);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: buildAppTheme(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => ProfileEditorDialog.show(
                  context,
                  user: user,
                  allowRename: allowRename,
                ),
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

  testWidgets('the name comes first, alone', (tester) async {
    await pumpEditor(tester);

    expect(find.text('Neues Profil'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    // No avatars competing with the keyboard for space.
    expect(find.text('Bild'), findsNothing);
    expect(find.text('Farbe'), findsNothing);
  });

  testWidgets('"Weiter" stays out of reach until there is a name',
      (tester) async {
    await pumpEditor(tester);

    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Weiter'),
    );
    expect(button.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Mia');
    await tester.pump();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Weiter'))
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('picture and colour come second, without a keyboard',
      (tester) async {
    await pumpEditor(tester);

    await tester.enterText(find.byType(TextField), 'Mia');
    await tester.pump();
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Bild'), findsOneWidget);
    expect(find.text('Farbe'), findsOneWidget);
    // The name is carried over and shown as a heading.
    expect(find.text('Mia'), findsOneWidget);
  });

  testWidgets('the keyboard key alone gets through both steps',
      (tester) async {
    await pumpEditor(tester);

    await tester.enterText(find.byType(TextField), 'Mia');
    // "Done" on the keyboard, without touching the button.
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('Bild'), findsOneWidget);
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    final users = await container.read(userRepositoryProvider).allUsers();
    expect(users.single.name, 'Mia');
  });

  testWidgets('the name can be corrected from the second step',
      (tester) async {
    await pumpEditor(tester);

    await tester.enterText(find.byType(TextField), 'Mia');
    await tester.pump();
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Name ändern'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Mia B.');
    await tester.pump();
    await tester.tap(find.text('Weiter'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Speichern'));
    await tester.pumpAndSettle();

    final users = await container.read(userRepositoryProvider).allUsers();
    expect(users.single.name, 'Mia B.');
  });

  testWidgets('a child editing their look never sees the name step',
      (tester) async {
    final id = await container
        .read(userRepositoryProvider)
        .createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
    final user = await container.read(userRepositoryProvider).findUser(id);

    await pumpEditor(tester, user: user, allowRename: false);

    expect(find.byType(TextField), findsNothing);
    expect(find.text('Bild'), findsOneWidget);
    expect(find.text('Name ändern'), findsNothing);
    expect(find.text('Abbrechen'), findsOneWidget);
  });

  group('with the keyboard up', () {
    // Roughly what is left on a 10" tablet and on a phone in landscape once
    // the system keyboard is showing.
    const cases = {
      'tablet': (Size(1600, 1000), 420.0),
      'handy': (Size(880, 420), 230.0),
    };

    for (final entry in cases.entries) {
      testWidgets('the name step fits on a ${entry.key}', (tester) async {
        final (size, keyboard) = entry.value;
        await pumpEditor(tester, size: size, keyboard: keyboard);
        expect(tester.takeException(), isNull);

        await tester.enterText(find.byType(TextField), 'Mia');
        await tester.pump();

        // Both the field and the way onwards have to sit above the keyboard.
        final free = size.height - keyboard;
        for (final finder in [
          find.byType(TextField),
          find.widgetWithText(FilledButton, 'Weiter'),
          find.byTooltip('Abbrechen'),
        ]) {
          final box = tester.getRect(finder);
          expect(box.bottom, lessThanOrEqualTo(free), reason: entry.key);
          expect(box.top, greaterThanOrEqualTo(0), reason: entry.key);
        }

        // And nothing may be cut off: if the step had to scroll, something is
        // hidden above or below the fold.
        final scroll =
            tester.state<ScrollableState>(find.byType(Scrollable).first);
        expect(
          scroll.position.maxScrollExtent,
          0,
          reason: '${entry.key}: the name step must fit above the keyboard',
        );
      });
    }
  });
}
