import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// One dot per task: filled = done, ringed = current, empty = still to come.
///
/// A dot row instead of "3 / 20" keeps the remaining work visible at a glance
/// without putting a number in front of a child who is already counting.
class ProgressDots extends StatelessWidget {
  final int total;
  final int current;

  const ProgressDots({super.key, required this.total, required this.current});

  @override
  Widget build(BuildContext context) {
    // Long runs would overflow as dots, so they fall back to a slim bar.
    if (total > 20) {
      return Row(
        children: [
          Text(
            '${current + 1} / $total',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: current / total,
                minHeight: 12,
                backgroundColor: AppColors.divider,
                valueColor:
                    const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < current ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: i <= current ? AppColors.primary : AppColors.divider,
                  width: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
