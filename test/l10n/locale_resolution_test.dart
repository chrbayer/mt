import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mathe_trainer/app.dart';
import 'package:mathe_trainer/l10n/l10n.dart';

/// The device's own language where the app has it, English for everything
/// else - a child who reads none of them is better served by English.
void main() {
  final supported = AppLocalizations.supportedLocales;

  test('a German device gets German, in every region', () {
    expect(resolveAppLocale(const Locale('de'), supported), const Locale('de'));
    expect(
      resolveAppLocale(const Locale('de', 'AT'), supported),
      const Locale('de'),
    );
  });

  test('French, Spanish and Italian devices get their own language', () {
    expect(resolveAppLocale(const Locale('fr'), supported), const Locale('fr'));
    expect(
      resolveAppLocale(const Locale('fr', 'CA'), supported),
      const Locale('fr'),
    );
    // The rule does not care how many ARB files exist: pass all five.
    const five = [
      Locale('de'),
      Locale('en'),
      Locale('fr'),
      Locale('es'),
      Locale('it'),
    ];
    expect(resolveAppLocale(const Locale('es', 'MX'), five), const Locale('es'));
    expect(resolveAppLocale(const Locale('it'), five), const Locale('it'));
    expect(resolveAppLocale(const Locale('pt', 'BR'), five), const Locale('en'));
  });

  test('English and every other language get English', () {
    expect(
      resolveAppLocale(const Locale('en', 'GB'), supported),
      const Locale('en'),
    );
    expect(resolveAppLocale(const Locale('tr'), supported), const Locale('en'));
    expect(resolveAppLocale(const Locale('pt'), supported), const Locale('en'));
    expect(resolveAppLocale(null, supported), const Locale('en'));
  });

  test('both resolved languages exist', () {
    expect(supported.map((l) => l.languageCode), containsAll(['de', 'en', 'fr']));
  });
}
