import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/task_count_choice.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Nullable on purpose: a made-up default would show one option as
    // selected and then jump to the stored one.
    final preferences = ref.watch(preferencesProvider).value;
    // Only when a child is logged in is there a profile to set it for.
    final user = ref.watch(activeUserProvider);
    final repository = ref.read(settingsRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(40, 8, 40, 32),
        children: [
          SwitchListTile(
            value: preferences?.showClock ?? false,
            onChanged: preferences == null ? null : repository.setShowClock,
            title: const Text('Uhr während der Übung zeigen',
                style: TextStyle(fontSize: 24)),
            subtitle: const Text(
              'Die Zeit wird immer gemessen. Sichtbar macht sie manche Kinder '
              'aber nervös - deshalb ist sie standardmäßig aus.',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const Divider(height: 40),
          SwitchListTile(
            value: preferences?.haptics ?? true,
            onChanged: preferences == null ? null : repository.setHaptics,
            title: const Text('Tasten vibrieren lassen',
                style: TextStyle(fontSize: 24)),
            subtitle: const Text(
              'Kurzes Feedback bei jedem Tastendruck.',
              style: TextStyle(fontSize: 18),
            ),
          ),
          const Divider(height: 40),
          const Text('Aufgaben pro Durchgang',
              style: TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          const TaskCountExplanation(),
          const SizedBox(height: 14),
          if (user != null) ...[
            Text('Für ${user.name}',
                style: const TextStyle(fontSize: 20, color: AppColors.text)),
            const SizedBox(height: 8),
            TaskCountChoice(
              value: user.defaultTaskCount,
              inherited: preferences?.defaultTaskCount,
              allowInherit: true,
              onChanged: (count) => ref
                  .read(userRepositoryProvider)
                  .setProfileTaskCount(user.id, count),
            ),
            const SizedBox(height: 18),
          ],
          const Text('Für alle',
              style: TextStyle(fontSize: 20, color: AppColors.text)),
          const SizedBox(height: 8),
          TaskCountChoice(
            value: preferences?.defaultTaskCount,
            onChanged: preferences == null
                ? null
                : (count) => repository.setDefaultTaskCount(count!),
          ),
          const Divider(height: 40),
          const Text(
            'Ergebnisse löschen, Profile verwalten und den Übungsverlauf '
            'ansehen: das steht im Elternbereich auf dem Startbildschirm, '
            'geschützt durch die PIN.',
            style: TextStyle(fontSize: 18, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
