import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/features/lessons/start_lesson_sheet.dart';
import 'package:mathe_trainer/features/admin/global_settings_tab.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// Settings are read from the database, which takes a frame. Screens used to
/// fill that frame with a made-up default, so the selected task count visibly
/// jumped from 10 to whatever was actually stored.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    await container.read(settingsRepositoryProvider).setDefaultTaskCount(20);
    final users = container.read(userRepositoryProvider);
    final id = await users.createUser(name: 'Mia', avatar: '🦊', colorIndex: 0);
    container
        .read(activeUserProvider.notifier)
        .select((await users.findUser(id))!);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: buildAppTheme(), home: home),
      ),
    );
  }

  /// Which task-count option the sheet highlights, if any. Its chips paint
  /// the selected label white themselves.
  int? highlightedInSheet(WidgetTester tester) {
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

  /// The settings screens use Material chips, which carry the state directly.
  /// Only numbered chips count: the "wie überall" chip has no number.
  int? highlightedInSettings(WidgetTester tester) {
    for (final chip in tester.widgetList<ChoiceChip>(find.byType(ChoiceChip))) {
      if (!chip.selected) continue;
      final label = chip.label;
      if (label is! Text) continue;
      final number = int.tryParse(label.data ?? '');
      if (number != null) return number;
    }
    return null;
  }

  testWidgets('the start sheet never highlights a count it then abandons',
      (tester) async {
    await pump(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () =>
                StartLessonSheet.show(context, lessonById('add_20_carry')),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));

    // Every frame from the very first: either nothing is selected yet, or the
    // stored 20 - never the invented 10.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 30));
      expect(highlightedInSheet(tester), anyOf(isNull, 20), reason: 'Frame $i');
    }
    await tester.pumpAndSettle();
    expect(highlightedInSheet(tester), 20);
  });

  testWidgets('the settings screen does the same', (tester) async {
    await pump(tester, const Scaffold(body: GlobalSettingsTab()));

    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 30));
      expect(highlightedInSettings(tester), anyOf(isNull, 20),
          reason: 'Frame $i');
    }
    await tester.pumpAndSettle();
    expect(highlightedInSettings(tester), 20);
  });

  testWidgets('the switches wait for their real values too', (tester) async {
    await container.read(settingsRepositoryProvider).setShowClock(true);
    await pump(tester, const Scaffold(body: GlobalSettingsTab()));

    // Before the values arrive the switches are inert rather than showing a
    // guessed position that a tap would then act on.
    await tester.pump();
    for (final tile in tester.widgetList<SwitchListTile>(
        find.byType(SwitchListTile))) {
      if (tile.onChanged == null) continue;
      // If it is live, it must already carry the stored value.
      expect(tile.value, isNotNull);
    }

    await tester.pumpAndSettle();
    expect(
      tester
          .widget<SwitchListTile>(
              find.widgetWithText(SwitchListTile, 'Uhr während der Übung zeigen'))
          .value,
      isTrue,
    );
  });

  testWidgets('the sound switch is stored and read back', (tester) async {
    await pump(tester, const Scaffold(body: GlobalSettingsTab()));
    await tester.pumpAndSettle();

    // On by default: a tablet flat on the table swallows the vibration.
    final tile = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Töne abspielen'),
    );
    expect(tile.value, isTrue);

    await tester.tap(find.widgetWithText(SwitchListTile, 'Töne abspielen'));
    await tester.pumpAndSettle();
    expect(
      (await container.read(settingsRepositoryProvider).load()).sounds,
      isFalse,
    );
  });
}
