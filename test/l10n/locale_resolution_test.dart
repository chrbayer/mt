import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/app.dart';
import 'package:mathe_trainer/l10n/l10n.dart';

/// German for a German device, English for everything else - a child who
/// reads neither German nor French is better served by English.
void main() {
  final supported = AppLocalizations.supportedLocales;

  test('a German device gets German, in every region', () {
    expect(resolveAppLocale(const Locale('de'), supported), const Locale('de'));
    expect(
      resolveAppLocale(const Locale('de', 'AT'), supported),
      const Locale('de'),
    );
  });

  test('English and every other language get English', () {
    expect(
      resolveAppLocale(const Locale('en', 'GB'), supported),
      const Locale('en'),
    );
    expect(resolveAppLocale(const Locale('tr'), supported), const Locale('en'));
    expect(resolveAppLocale(null, supported), const Locale('en'));
  });

  test('both resolved languages exist', () {
    expect(supported.map((l) => l.languageCode), containsAll(['de', 'en']));
  });
}
