import 'package:flutter/material.dart';

import '../../domain/scoring.dart';
import '../../theme/app_theme.dart';

/// The three stars of a lesson, filled up to [earned].
///
/// Always all three, never just the earned ones: the empty ones are the point
/// - they say what is still open. A lesson nobody has touched shows three
/// outlines, which reads as "not done yet" without a word of explanation.
class StarRow extends StatelessWidget {
  final int earned;
  final double size;

  /// Dim the whole row - for a lesson that has not been practised at all.
  final bool faded;

  const StarRow({
    super.key,
    required this.earned,
    this.size = 22,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < maxStars; i++)
          Icon(
            i < earned ? Icons.star_rounded : Icons.star_outline_rounded,
            size: size,
            color: i < earned
                ? AppColors.star
                : (faded ? AppColors.divider : AppColors.starEmpty),
          ),
      ],
    );
  }
}

/// The running total, as a badge: `★ 24 von 150`.
class StarTotal extends StatelessWidget {
  final int earned;

  /// Null when there is no meaningful maximum to show.
  final int? possible;
  final double size;

  const StarTotal({
    super.key,
    required this.earned,
    this.possible,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size * 1.3, color: AppColors.star),
        const SizedBox(width: 6),
        Text(
          possible == null ? '$earned' : '$earned von $possible',
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}
