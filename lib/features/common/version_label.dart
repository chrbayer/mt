import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// The version this build was made from, or empty when it was not built by
/// one of the two build scripts.
///
/// A compile-time constant rather than a plugin reading the manifest: the
/// build scripts already know the number, and one label is not worth a
/// dependency. Both scripts pass `--dart-define=MT_VERSION`.
const appVersion = String.fromEnvironment('MT_VERSION');

/// The version, quietly, in a corner.
///
/// For the grown-ups: it answers "which one is on this tablet" without
/// anybody having to dig. Deliberately the smallest and palest thing on the
/// screen - a child has no use for it.
///
/// Shows nothing at all when the number is unknown. A blank corner is honest;
/// a made-up or stale number is worse than none.
class VersionLabel extends StatelessWidget {
  const VersionLabel({super.key});

  @override
  Widget build(BuildContext context) {
    if (appVersion.isEmpty) return const SizedBox.shrink();
    return Text(
      'Version $appVersion',
      style: const TextStyle(fontSize: 13, color: AppColors.starEmpty),
    );
  }
}
