import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// A die with its pips.
///
/// The numeral that belongs with it is drawn by whoever places the die, so
/// that two dice can share one line of numbers - see [CountedPair].
class DiceFace extends StatelessWidget {
  /// Edge length of the die itself, without the numeral underneath.
  static const double defaultSize = 190;

  final int pips;
  final double size;

  /// Outline and pips. Blue on a lesson tile, where every other example is
  /// blue too and a black die stood out as if it were something else.
  final Color color;

  const DiceFace({
    super.key,
    required this.pips,
    this.size = defaultSize,
    this.color = AppColors.text,
  });

  /// Pip positions in a unit square, in the arrangement every die uses.
  static const _layouts = <int, List<Offset>>{
    1: [Offset(0.5, 0.5)],
    2: [Offset(0.28, 0.28), Offset(0.72, 0.72)],
    3: [Offset(0.28, 0.28), Offset(0.5, 0.5), Offset(0.72, 0.72)],
    4: [
      Offset(0.28, 0.28),
      Offset(0.72, 0.28),
      Offset(0.28, 0.72),
      Offset(0.72, 0.72),
    ],
    5: [
      Offset(0.28, 0.28),
      Offset(0.72, 0.28),
      Offset(0.5, 0.5),
      Offset(0.28, 0.72),
      Offset(0.72, 0.72),
    ],
    6: [
      Offset(0.28, 0.24),
      Offset(0.72, 0.24),
      Offset(0.28, 0.5),
      Offset(0.72, 0.5),
      Offset(0.28, 0.76),
      Offset(0.72, 0.76),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: color, width: size * 0.026),
        borderRadius: BorderRadius.circular(size * 0.18),
      ),
      child: CustomPaint(painter: _PipPainter(pips: pips, color: color)),
    );
  }
}

class _PipPainter extends CustomPainter {
  final int pips;
  final Color color;

  _PipPainter({required this.pips, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final radius = size.width * 0.085;
    for (final spot in DiceFace._layouts[pips] ?? const <Offset>[]) {
      canvas.drawCircle(
        Offset(spot.dx * size.width, spot.dy * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_PipPainter old) =>
      old.pips != pips || old.color != color;
}
