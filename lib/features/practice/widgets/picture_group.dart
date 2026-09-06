import 'dart:math';

import 'package:flutter/material.dart';

import '../../../domain/lesson.dart';
import '../../../theme/app_theme.dart';

/// A handful of identical pictures, either lined up or scattered.
///
/// The two are different exercises. A row can be counted by running a finger
/// along it; a cloud cannot, and the child has to keep track of what is
/// already counted. Which one a lesson uses is part of the lesson, not a
/// decoration.
class PictureGroup extends StatelessWidget {
  final int count;
  final String picture;
  final PictureArrangement arrangement;

  /// Varies the scatter between tasks that would otherwise look identical.
  final int seed;

  final double size;

  /// Prints the count under the group.
  ///
  /// On where it belongs: a number helps where the point is to tie it to an
  /// amount - comparing two heaps, adding two of them. It gives the game away
  /// where the point is to count, so the counting lessons show none.
  final bool showCount;

  const PictureGroup({
    super.key,
    required this.count,
    required this.picture,
    required this.arrangement,
    this.seed = 0,
    this.size = 76,
    this.showCount = false,
  });

  @override
  Widget build(BuildContext context) {
    // A Row, not a Wrap: a row that breaks into two lines is no longer the
    // exercise it claims to be, and the display around it scales down rather
    // than clipping. Wrap also reports its height as if every picture sat on
    // its own line, which threw off anything measuring the group.
    final pictures = arrangement == PictureArrangement.row
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < count; i++)
                Padding(
                  padding: EdgeInsets.only(right: i == count - 1 ? 0 : 12),
                  child: Text(picture, style: TextStyle(fontSize: size)),
                ),
            ],
          )
        : _Cloud(count: count, picture: picture, seed: seed, size: size);

    if (!showCount) return pictures;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        pictures,
        SizedBox(height: size * 0.12),
        Text(
          '$count',
          style: TextStyle(
            fontSize: size * 0.62,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }
}

/// Pictures on a jittered grid: never overlapping, never in a line.
///
/// The positions come from a seeded generator so they hold still across
/// rebuilds - pictures that jump around while a child counts them would be
/// unusable.
class _Cloud extends StatelessWidget {
  final int count;
  final String picture;
  final int seed;
  final double size;

  const _Cloud({
    required this.count,
    required this.picture,
    required this.seed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    // The grid grows with the heap: a lone picture in a three-by-three box
    // would sit in a lot of empty space and stop reading as a group.
    final columns = count <= 1
        ? 1
        : count <= 4
            ? 2
            : 3;
    final rows = (count / columns).ceil() + (count > 1 ? 1 : 0);

    // A glyph is taller than its font size - emoji noticeably so. Sizing the
    // cells by the font size alone let the bottom row poke out of the Stack,
    // which clips, so the last pictures were cut off.
    final extent = size * 1.4;
    final jitter = size * 0.35;
    final cell = extent + jitter;

    final random = Random(seed * 7919 + count);
    final cells = [for (var i = 0; i < columns * rows; i++) i]..shuffle(random);

    return SizedBox(
      width: cell * columns,
      height: cell * rows,
      child: Stack(
        children: [
          for (final index in cells.take(count))
            Positioned(
              left: (index % columns) * cell + random.nextDouble() * jitter,
              top: (index ~/ columns) * cell + random.nextDouble() * jitter,
              width: extent,
              height: extent,
              child: Center(
                child: Text(picture, style: TextStyle(fontSize: size)),
              ),
            ),
        ],
      ),
    );
  }
}
