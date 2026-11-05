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
