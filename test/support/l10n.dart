import 'package:flutter/widgets.dart';
import 'package:mathe_trainer/l10n/l10n.dart';

/// Tests run in German, the language of the template.
const testLocale = Locale('de');

/// Pass to every `MaterialApp` in a test, together with [testLocale].
const testLocalizationsDelegates = AppLocalizations.localizationsDelegates;

/// Without this the explicit [testLocale] is resolved against `en_US`, the
/// framework's default, and falls back to it.
const testSupportedLocales = [testLocale];
