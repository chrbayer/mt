import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/features/admin/admin_screen.dart';
import 'package:mathe_trainer/features/admin/global_settings_tab.dart';
import 'package:mathe_trainer/features/admin/profile_settings_screen.dart';
import 'package:mathe_trainer/features/admin/reset_stars_dialog.dart';
import 'package:mathe_trainer/features/common/star_row.dart';
import 'package:mathe_trainer/features/lessons/lesson_home_screen.dart';
import 'package:mathe_trainer/features/lessons/start_lesson_sheet.dart';
import 'package:mathe_trainer/features/profiles/profile_select_screen.dart';
import 'package:mathe_trainer/features/settings/settings_screen.dart';
import 'package:mathe_trainer/features/stats/global_stats_screen.dart';
import 'package:mathe_trainer/l10n/l10n.dart';
import 'package:mathe_trainer/l10n/lesson_texts.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

import '../support/layout_screens.dart';
import '../support/real_font.dart';
import 'screens_layout_test.dart' show tabletSizes;

/// The same screens as `screens_layout_test`, in every other language the
/// app has. English is usually shorter than German, French and the Romance
/// languages often longer, and an overflow in a translation would otherwise
/// only show on a child's tablet. When a text overflows here, the fix is a
/// shorter text, not a different layout. A new ARB file is picked up by
/// `AppLocalizations.supportedLocales` without a change here.
void main() {
  for (final locale in AppLocalizations.supportedLocales) {
    if (locale.languageCode == 'de') continue; // screens_layout_test
    group(locale.languageCode, () => _suite(locale));
  }
}

void _suite(Locale locale) {
  final l10n = lookupAppLocalizations(locale);

  setUpAll(loadRealFont);

  late AppDatabase db;
  late ProviderContainer container;
  late User mia;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    mia = await seedLayoutData(container);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpScreen(WidgetTester tester, Widget screen, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: locale,
          supportedLocales: [locale],
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: screen,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Widget opener(void Function(BuildContext) open) => Builder(
    builder: (context) =>
        TextButton(onPressed: () => open(context), child: const Text('open')),
  );

  final screens = layoutScreens();

  for (final size in tabletSizes.entries) {
    for (final screen in screens.entries) {
      testWidgets(
        '${screen.key} fits on ${size.key} in ${locale.languageCode}',
        (tester) async {
          await pumpScreen(tester, screen.value(), size.value);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('management tab fits on ${size.key}', (tester) async {
      await pumpScreen(tester, const AdminScreen(), size.value);
      await tester.tap(find.text(l10n.adminTabManagement));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // The whole row is the way in.
      await tester.tap(find.text('Mia'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final group in LessonGroup.values) {
        expect(find.text(groupTitle(l10n, group)), findsOneWidget);
      }
    });

    testWidgets('assignments tab and editor fit on ${size.key}', (
      tester,
    ) async {
      await pumpScreen(tester, const AdminScreen(), size.value);
      await tester.tap(
        find.descendant(
          of: find.byType(TabBar),
          matching: find.text(l10n.adminTabAssignments),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text(l10n.assignmentsNew));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(l10n.editorCreate), findsOneWidget);
    });

    testWidgets('leaderboards overview fits on ${size.key}', (tester) async {
      await pumpScreen(tester, const GlobalStatsScreen(), size.value);
      await tester.tap(find.text(l10n.globalStatsTabLeaderboards));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('own settings fit on ${size.key}', (tester) async {
      await pumpScreen(tester, const SettingsScreen(), size.value);
      expect(tester.takeException(), isNull);
      expect(find.text(l10n.settingsTaskCountHeading), findsOneWidget);
    });

    testWidgets('profile settings fit on ${size.key}', (tester) async {
      await pumpScreen(
        tester,
        opener((context) => ProfileSettingsScreen.show(context, mia)),
        size.value,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(find.byType(ListView).first, const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(l10n.profileSettingsSave), findsOneWidget);
    });

    testWidgets('give-back-stars dialog fits on ${size.key}', (tester) async {
      await pumpScreen(
        tester,
        opener((context) => ResetStarsDialog.show(context, mia)),
        size.value,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView).first,
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(l10n.resetStarsDone), findsOneWidget);
    });

    testWidgets('global settings fit on ${size.key}', (tester) async {
      await pumpScreen(
        tester,
        const Scaffold(body: GlobalSettingsTab()),
        size.value,
      );
      expect(tester.takeException(), isNull);
      expect(find.text(l10n.globalSettingsClock), findsOneWidget);
    });

    testWidgets('PIN dialog fits on ${size.key}', (tester) async {
      await pumpScreen(tester, const ProfileSelectScreen(), size.value);
      await tester.tap(find.text(l10n.profilesParents));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text(l10n.commonCancel), findsOneWidget);
    });

    testWidgets('start dialog fits on ${size.key}', (tester) async {
      await pumpScreen(tester, const LessonHomeScreen(), size.value);
      final lesson = find.text(lessonTitle(l10n, lessonById('add_20_carry')));
      for (var i = 0; i < 15 && lesson.evaluate().isEmpty; i++) {
        await tester.drag(find.byType(ListView), const Offset(0, -400));
        await tester.pumpAndSettle();
      }
      await tester.ensureVisible(lesson.first);
      await tester.pumpAndSettle();
      await tester.tap(lesson.first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.tap(find.byTooltip(l10n.startWhatDoesItMean));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final go = find.text(l10n.startGo);
      expect(go, findsOneWidget);
      final before = tester.getRect(go);
      expect(before.bottom, lessThanOrEqualTo(size.value.height));
      for (final count in ['5', '10', '50']) {
        await tester.tap(find.widgetWithText(Material, count).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: count);
        expect(
          tester.getRect(go),
          before,
          reason: 'the sheet must not move when the count changes',
        );
      }
    });
  }

  for (final size in const {
    'small phone': Size(640, 360),
    'phone': Size(800, 400),
  }.entries) {
    testWidgets('start dialog stays usable on a ${size.key}', (tester) async {
      await pumpScreen(
        tester,
        opener(
          (context) =>
              StartLessonSheet.show(context, lessonById('add_100_carry')),
        ),
        size.value,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final count in ['5', '10', '50']) {
        await tester.tap(find.widgetWithText(Material, count).first);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: count);
      }
      await tester.ensureVisible(find.text(l10n.startGo));
      await tester.pumpAndSettle();
      final box = tester.getRect(find.text(l10n.startGo));
      expect(box.right, lessThanOrEqualTo(size.value.width));
    });
  }

  testWidgets('the header gives up its words on a narrow device', (
    tester,
  ) async {
    await pumpScreen(tester, const LessonHomeScreen(), const Size(820, 420));
    expect(find.text(l10n.lessonsStatsLabel), findsNothing);
    expect(find.text(l10n.lessonsSwitchLabel), findsNothing);
    expect(find.byTooltip(l10n.lessonsStatsLabel), findsOneWidget);
    expect(find.byTooltip(l10n.lessonsSwitchLabel), findsOneWidget);
    expect(find.byType(StarTotal), findsNWidgets(2));
  });

  testWidgets('a wide device keeps the words', (tester) async {
    await pumpScreen(tester, const LessonHomeScreen(), const Size(1280, 800));
    expect(find.text(l10n.lessonsStatsLabel), findsOneWidget);
    expect(find.text(l10n.lessonsSwitchLabel), findsOneWidget);
  });
}
