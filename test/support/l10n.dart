import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mathe_trainer/l10n/l10n.dart';

/// Tests run in German, the language of the template.
const testLocale = Locale('de');

/// Pass to every `MaterialApp` in a test, together with [testLocale].
const testLocalizationsDelegates = AppLocalizations.localizationsDelegates;

/// Without this the explicit [testLocale] is resolved against `en_US`, the
/// framework's default, and falls back to it.
const testSupportedLocales = [testLocale];

/// German texts without a widget tree - for tests of the formatters and of
/// everything that turns domain data into words. The same lookup the app's
/// delegate performs.
final AppLocalizations deL10n = lookupAppLocalizations(testLocale);

/// `DateFormat` needs the locale's symbols. In the app the Material
/// delegate loads them; a plain unit test has to ask (`setUpAll`).
Future<void> initDateSymbols() => initializeDateFormatting('de');

/// English, for the tests that check a second language.
const enLocale = Locale('en');

/// English texts without a widget tree.
final AppLocalizations enL10n = lookupAppLocalizations(enLocale);

/// Date symbols for English, next to [initDateSymbols].
Future<void> initEnglishDateSymbols() => initializeDateFormatting('en');

/// French, for the tests that check a language with the hour in front.
const frLocale = Locale('fr');

/// French texts without a widget tree.
final AppLocalizations frL10n = lookupAppLocalizations(frLocale);

/// Date symbols for French.
Future<void> initFrenchDateSymbols() => initializeDateFormatting('fr');
