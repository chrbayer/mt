import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/profiles/profile_select_screen.dart';
import 'providers.dart';
import 'theme/app_theme.dart';

class MatheTrainerApp extends ConsumerWidget {
  const MatheTrainerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Held from the root for the whole session. Otherwise every screen that
    // needs a preference is the first to ask for it, waits a frame, and shows
    // something else in the meantime.
    ref.watch(preferencesProvider);

    return MaterialApp(
      title: 'Mathe-Trainer',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const ProfileSelectScreen(),
    );
  }
}
