import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/features/common/version_label.dart';
import 'package:mathe_trainer/theme/app_theme.dart';

/// The version comes in as a compile-time constant from the build scripts.
///
/// The test adapts to how it is run: plain `flutter test` has no
/// `--dart-define`, so it checks that nothing is shown at all; run with
/// `--dart-define=MT_VERSION=…` it checks that the number arrives. Both paths
/// matter - a stale or blank "Version" line would be worse than none.
void main() {
  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: const Scaffold(body: Center(child: VersionLabel())),
        ),
      );

  testWidgets('the label follows the constant it was built with',
      (tester) async {
    await pump(tester);
    expect(tester.takeException(), isNull);

    if (appVersion.isEmpty) {
      expect(find.textContaining('Version'), findsNothing,
          reason: 'no number, so no line');
      return;
    }

    expect(find.text('Version $appVersion'), findsOneWidget);
    // Quiet on purpose: the smallest and palest thing on the screen, because
    // a child has no use for it.
    final text = tester.widget<Text>(find.text('Version $appVersion'));
    expect(text.style?.fontSize, 13);
    expect(text.style?.color, AppColors.starEmpty);
  });
}
