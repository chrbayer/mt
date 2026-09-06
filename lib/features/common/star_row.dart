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

/// The lightning bolts of a run, filled up to [earned].
///
/// The twin of [StarRow] for the other axis: stars say how carefully a run
/// went, bolts how fast. Unlike stars these do start at zero - speed is the
/// thing still to be had, and a row of three outlines says exactly that.
class BoltRow extends StatelessWidget {
  final int earned;
  final double size;

  /// Dim the whole row - for a lesson that has not been practised at all.
  final bool faded;

  const BoltRow({
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
        for (var i = 0; i < maxBolts; i++)
          Icon(
            i < earned ? Icons.bolt : Icons.bolt_outlined,
            size: size,
            color: i < earned
                ? AppColors.bolt
                : (faded ? AppColors.divider : AppColors.boltEmpty),
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

  /// Show the badge as lightning bolts instead of stars. Same shape, same
  /// place, other axis.
  final bool bolts;

  const StarTotal({
    super.key,
    required this.earned,
    this.possible,
    this.size = 22,
    this.bolts = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          bolts ? Icons.bolt : Icons.star_rounded,
          size: size * 1.3,
          color: bolts ? AppColors.bolt : AppColors.star,
        ),
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
