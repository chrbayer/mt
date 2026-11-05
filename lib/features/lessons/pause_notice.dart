import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/practice_limit.dart';
import '../../providers.dart';
import '../../theme/app_theme.dart';
import '../../l10n/l10n.dart';

/// Says that the practice cap has been reached, and until when.
///
/// Friendly on purpose. A child who has just worked for half an hour has done
/// nothing wrong, and the notice should read like being sent out to play, not
/// like being locked out.
class PauseNotice extends ConsumerWidget {
  final PracticeAllowance allowance;

  /// Bigger, for a whole panel; smaller for a strip above the catalogue.
  final bool compact;

  const PauseNotice({
    super.key,
    required this.allowance,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The same clock the decision was made with. Counting down against a
    // second one would be the one place it is guaranteed to show.
    final now = ref.watch(clockProvider)();
    final until = allowance.breakUntil;
    final clock = until == null
        ? ''
        : context.l10n.pauseClock(
            '${until.hour}:${until.minute.toString().padLeft(2, '0')}');
    final left = until == null
        ? ''
        : formatRemaining(until.difference(now));

    // A break can be waited out; a day cannot. Naming an hour when the day's
    // time is used up would be a promise the app is not going to keep.
    final (title, text) = allowance.dayIsDone
        ? (
            context.l10n.pauseDayDoneTitle,
            context.l10n.pauseDayDoneText(allowance.practisedTodayMinutes),
          )
        : (
            context.l10n.pauseBreakTitle,
            context.l10n.pauseBreakText(
                allowance.practisedMinutes, clock, left),
          );

    return Container(
      padding: EdgeInsets.all(compact ? 16 : 28),
      decoration: BoxDecoration(
        color: AppColors.correctSoft,
        borderRadius: BorderRadius.circular(compact ? 16 : 24),
        border: Border.all(color: AppColors.correct, width: 2),
      ),
      child: Row(
        children: [
          Icon(
            allowance.dayIsDone ? Icons.bedtime_outlined : Icons.self_improvement,
            size: compact ? 38 : 64,
            color: AppColors.correct,
          ),
          SizedBox(width: compact ? 14 : 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: compact ? 22 : 34,
                    fontWeight: FontWeight.w700,
                    color: AppColors.correct,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: compact ? 17 : 22,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
