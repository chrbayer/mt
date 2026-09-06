import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/practice_limit.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/minutes_choice.dart';
import '../common/task_count_choice.dart';

/// Everything that holds for the whole app rather than for one child.
///
/// Lives behind the PIN because it is a parent's decision: a child who can
/// switch the clock off, or set every run to five tasks, has been handed the
/// wrong dial.
class GlobalSettingsTab extends ConsumerWidget {
  const GlobalSettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Nullable on purpose: a made-up default would show one option as
    // selected and then jump to the stored one.
    final preferences = ref.watch(preferencesProvider).value;
    final repository = ref.read(settingsRepositoryProvider);
    final limits = preferences?.limits;

    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 32),
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
        const Text('Aufgaben pro Durchgang für alle',
            style: TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        const TaskCountExplanation(),
        const SizedBox(height: 14),
        TaskCountChoice(
          value: preferences?.defaultTaskCount,
          onChanged: preferences == null
              ? null
              : (count) => repository.setDefaultTaskCount(count!),
        ),
        const SizedBox(height: 24),
        const Text(
          'Für ein einzelnes Kind steht die Vorgabe unter „Verwaltung" bei '
          'seinem Profil - und das Kind selbst kann sie in seinen eigenen '
          'Einstellungen ändern.',
          style: TextStyle(fontSize: 17, color: AppColors.textMuted),
        ),
        const Divider(height: 40),
        const Text('Übungszeit für alle', style: TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        const Text(
          'Gilt für jedes Kind, das keine eigene Vorgabe hat. Ein laufender '
          'Durchgang wird nie abgebrochen - erst der nächste Start ist '
          'gesperrt.',
          style: TextStyle(fontSize: 17, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        const Text('Am Stück, dann Pause',
            style: TextStyle(fontSize: 20, color: AppColors.text)),
        const SizedBox(height: 8),
        MinutesChoice(
          value: limits?.stretchMinutes,
          options: practiceLimitOptions,
          onChanged: limits == null
              ? null
              : (minutes) => repository.setPracticeLimits(
                    PracticeLimits(
                      stretchMinutes: minutes!,
                      breakMinutes: limits.breakMinutes,
                      dailyMinutes: limits.dailyMinutes,
                    ),
                  ),
        ),
        if ((limits?.stretchMinutes ?? 0) > 0) ...[
          const SizedBox(height: 16),
          const Text('Wie lange dauert die Pause?',
              style: TextStyle(fontSize: 20, color: AppColors.text)),
          const SizedBox(height: 8),
          MinutesChoice(
            value: limits?.breakMinutes,
            options: breakMinuteOptions,
            zeroLabel: null,
            onChanged: limits == null
                ? null
                : (minutes) => repository.setPracticeLimits(
                      PracticeLimits(
                        stretchMinutes: limits.stretchMinutes,
                        breakMinutes: minutes!,
                        dailyMinutes: limits.dailyMinutes,
                      ),
                    ),
          ),
        ],
        const SizedBox(height: 16),
        const Text('Und pro Tag insgesamt',
            style: TextStyle(fontSize: 20, color: AppColors.text)),
        const SizedBox(height: 8),
        MinutesChoice(
          value: limits?.dailyMinutes,
          options: dailyLimitOptions,
          onChanged: limits == null
              ? null
              : (minutes) => repository.setPracticeLimits(
                    PracticeLimits(
                      stretchMinutes: limits.stretchMinutes,
                      breakMinutes: limits.breakMinutes,
                      dailyMinutes: minutes!,
                    ),
                  ),
        ),
      ],
    );
  }
}
