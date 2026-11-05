import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/practice_limit.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../common/amount_choice.dart';
import 'sound_test_button.dart';
import '../common/task_count_choice.dart';
import '../../l10n/l10n.dart';

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
          title: Text(context.l10n.globalSettingsClock,
              style: const TextStyle(fontSize: 24)),
          subtitle: Text(
            context.l10n.globalSettingsClockNote,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const Divider(height: 40),
        SwitchListTile(
          value: preferences?.haptics ?? true,
          onChanged: preferences == null ? null : repository.setHaptics,
          title: Text(context.l10n.globalSettingsHaptics,
              style: const TextStyle(fontSize: 24)),
          subtitle: Text(
            context.l10n.globalSettingsHapticsNote,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const Divider(height: 40),
        SwitchListTile(
          value: preferences?.sounds ?? true,
          onChanged: preferences == null ? null : repository.setSounds,
          title: Text(context.l10n.globalSettingsSounds,
              style: const TextStyle(fontSize: 24)),
          subtitle: Text(
            context.l10n.globalSettingsSoundsNote,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: SoundTestButton(),
        ),
        const Divider(height: 40),
        Text(context.l10n.globalSettingsTaskCount,
            style: const TextStyle(fontSize: 24)),
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
        Text(
          context.l10n.globalSettingsTaskCountNote,
          style: const TextStyle(fontSize: 17, color: AppColors.textMuted),
        ),
        const Divider(height: 40),
        Text(context.l10n.globalSettingsLimits,
            style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          context.l10n.globalSettingsLimitsNote,
          style: const TextStyle(fontSize: 17, color: AppColors.textMuted),
        ),
        const SizedBox(height: 16),
        Text(context.l10n.globalSettingsStretch,
            style: const TextStyle(fontSize: 20, color: AppColors.text)),
        const SizedBox(height: 8),
        AmountChoice(
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
          Text(context.l10n.globalSettingsBreakLength,
              style: const TextStyle(fontSize: 20, color: AppColors.text)),
          const SizedBox(height: 8),
          AmountChoice(
            value: limits?.breakMinutes,
            options: breakMinuteOptions,
            zeroIsNoLimit: false,
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
        Text(context.l10n.globalSettingsDaily,
            style: const TextStyle(fontSize: 20, color: AppColors.text)),
        const SizedBox(height: 8),
        AmountChoice(
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
        const Divider(height: 40),
        Text(context.l10n.globalSettingsScoredRuns,
            style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        Text(
          context.l10n.globalSettingsScoredRunsNote,
          style: const TextStyle(fontSize: 17, color: AppColors.textMuted),
        ),
        const SizedBox(height: 12),
        AmountChoice(
          value: preferences?.scoredRunsPerLesson,
          options: scoredRunOptions,
          labelFor: (runs) => '$runs×',
          onChanged: preferences == null
              ? null
              : (runs) => repository.setScoredRunsPerLesson(runs!),
        ),
      ],
    );
  }
}
