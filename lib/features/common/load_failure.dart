import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// What a screen shows when something it needed could not be read.
///
/// The exception itself used to stand there, on the profile screen and the
/// leaderboard among others - a stack of Dart at a seven-year-old. A child
/// can do nothing with it and should not have to look at it.
///
/// The parent area is the exception and passes [detail] on: there a grown-up
/// is looking, the same reason `FeedbackSounds` keeps its last error rather
/// than only logging it. On a tablet there is no console, and "es geht
/// nicht" cannot be worked with.
class LoadFailure extends StatelessWidget {
  /// The technical text, shown only where someone can act on it.
  final Object? detail;

  const LoadFailure({super.key, this.detail});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined,
                  size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              const Text(
                'Das konnte gerade nicht geladen werden.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, color: AppColors.textMuted),
              ),
              if (detail != null) ...[
                const SizedBox(height: 10),
                Text(
                  '$detail',
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ),
      );
}
