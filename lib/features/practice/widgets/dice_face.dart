import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// A die with its pips, and the numeral underneath.
///
/// Both at once on purpose: the pattern is what a child recognises first, the
/// numeral is what they are learning to attach to it. Seeing them together is
/// the whole lesson.
class DiceFace extends StatelessWidget {
  /// Edge length of the die itself, without the numeral underneath.
  static const double defaultSize = 190;

  final int pips;
  final double size;

  /// The numeral under the die. Dropped where the die is only a thumbnail.
  final bool showNumber;

  const DiceFace({
    super.key,
    required this.pips,
    this.size = defaultSize,
    this.showNumber = true,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.text, width: 5),
            borderRadius: BorderRadius.circular(size * 0.18),
          ),
          child: CustomPaint(painter: _PipPainter(pips: pips)),
        ),
        if (showNumber) ...[
          SizedBox(height: size * 0.09),
          Text(
            '$pips',
            style: TextStyle(
              fontSize: size * 0.36,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ],
      ],
    );
  }
}

class _PipPainter extends CustomPainter {
  final int pips;

  _PipPainter({required this.pips});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.text;
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
  bool shouldRepaint(_PipPainter old) => old.pips != pips;
}
