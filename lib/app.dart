import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/profiles/profile_select_screen.dart';
import 'l10n/l10n.dart';
import 'providers.dart';
import 'theme/app_theme.dart';

class MatheTrainerApp extends ConsumerStatefulWidget {
  const MatheTrainerApp({super.key});

  @override
  ConsumerState<MatheTrainerApp> createState() => _MatheTrainerAppState();
}

class _MatheTrainerAppState extends ConsumerState<MatheTrainerApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The app is not restarted between one day and the next: on a tablet the
  /// process survives being put down in the evening and picked up the next
  /// afternoon. Everything counted against "today" has to be asked again
  /// then, or yesterday's practice would still count towards today's cap.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refreshDay(ref);
  }

  @override
  Widget build(BuildContext context) {
    // Held from the root for the whole session. Otherwise every screen that
    // needs a preference is the first to ask for it, waits a frame, and shows
    // something else in the meantime.
    ref.watch(preferencesProvider);

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('de'), Locale('en')],
      // German for German, English for everything else: a child who reads
      // neither German nor French is better served by English.
      localeResolutionCallback: resolveAppLocale,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const ProfileSelectScreen(),
    );
  }
}

/// The language of the app for a device language: German if the device says
/// German, otherwise English - also for languages the app does not know.
Locale resolveAppLocale(Locale? device, Iterable<Locale> supported) =>
    device?.languageCode == 'de' ? const Locale('de') : const Locale('en');
