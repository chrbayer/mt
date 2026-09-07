// Drives the real practice screen with real taps on the real Linux device,
// so the audio it produces can be recorded and measured. Run it headless:
//   wlheadless-run -c weston -- flutter test integration_test/... -d linux
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mathe_trainer/data/db/app_database.dart';
import 'package:mathe_trainer/domain/lesson.dart';
import 'package:mathe_trainer/features/practice/practice_screen.dart';
import 'package:mathe_trainer/providers.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('tapping digits makes a click every time', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final container =
        ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    final users = container.read(userRepositoryProvider);
    final id = await users.createUser(name: 'Mia', avatar: 'M', colorIndex: 0);
    container
        .read(activeUserProvider.notifier)
        .select((await users.findUser(id))!);

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildAppTheme(),
        home: PracticeScreen(
          lesson: lessonById('add_100_plain'),
          taskCount: 20,
          seed: 1,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    // Twenty presses in the rhythm of a real run: two digits, a pause.
    for (var i = 0; i < 10; i++) {
      for (final digit in ['4', '2']) {
        await tester.tap(find.byKey(Key('digit-$digit')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
      }
      await tester.tap(find.byKey(const Key('backspace')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('backspace')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }
    await tester.pump(const Duration(seconds: 1));
  });
}
