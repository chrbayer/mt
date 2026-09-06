import 'dart:math';

import 'package:flutter/material.dart';

import '../../../domain/lesson.dart';

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

  const PictureGroup({
    super.key,
    required this.count,
    required this.picture,
    required this.arrangement,
    this.seed = 0,
    this.size = 76,
  });

  @override
  Widget build(BuildContext context) {
    if (arrangement == PictureArrangement.row) {
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          for (var i = 0; i < count; i++)
            Text(picture, style: TextStyle(fontSize: size)),
        ],
      );
    }
    return _Cloud(
        count: count, picture: picture, seed: seed, size: size);
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

    final cell = size * 1.4;
    final random = Random(seed * 7919 + count);
    final cells = [for (var i = 0; i < columns * rows; i++) i]..shuffle(random);

    return SizedBox(
      width: cell * columns,
      height: cell * rows,
      child: Stack(
        children: [
          for (final index in cells.take(count))
            Positioned(
              left: (index % columns) * cell +
                  random.nextDouble() * (cell - size),
              top: (index ~/ columns) * cell +
                  random.nextDouble() * (cell - size),
              child: Text(picture, style: TextStyle(fontSize: size)),
            ),
        ],
      ),
    );
  }
}
