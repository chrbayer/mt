import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/task_count_choice.dart';

/// The settings a child may change about their own practice.
///
/// Only reachable from inside a child's own lesson screen, so everything here
/// is theirs by definition - it does not have to say whose it is. What holds
/// for the whole app lives in the parent area, behind the PIN.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Nullable on purpose: a made-up default would show one option as
    // selected and then jump to the stored one.
    final preferences = ref.watch(preferencesProvider).value;
    final user = ref.watch(activeUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(40, 8, 40, 32),
        children: [
          const Text('Aufgaben pro Durchgang', style: TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          const TaskCountExplanation(forProfile: true),
          const SizedBox(height: 14),
          TaskCountChoice(
            value: user?.defaultTaskCount,
            inherited: preferences?.defaultTaskCount,
            allowInherit: true,
            onChanged: user == null
                ? null
                : (count) => ref
                    .read(userRepositoryProvider)
                    .setProfileTaskCount(user.id, count),
          ),
          const Divider(height: 48),
          const Text(
            'Uhr und Vibration, die Vorgabe für alle, Ergebnisse löschen, '
            'Profile verwalten und den Übungsverlauf ansehen: das steht im '
            'Elternbereich auf dem Startbildschirm, geschützt durch die PIN.',
            style: TextStyle(fontSize: 18, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
