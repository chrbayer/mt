import 'dart:math';

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// An analogue clock to read off.
///
/// Drawn rather than shipped as an image: it has to show any time the lesson
/// asks for, and a painter costs nothing next to sixty assets.
class ClockFace extends StatelessWidget {
  final int hour;
  final int minute;
  final double size;

  const ClockFace({
    super.key,
    required this.hour,
    required this.minute,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _ClockPainter(
            hour: hour,
            minute: minute,
            // A painter has no ambient text style, so the app's own has to be
            // handed in - otherwise the dial falls back to whatever font the
            // platform happens to default to.
            numberStyle: DefaultTextStyle.of(context).style.copyWith(
                  fontSize: size * 0.095,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
          ),
        ),
      );
}

class _ClockPainter extends CustomPainter {
  final int hour;
  final int minute;
  final TextStyle numberStyle;

  _ClockPainter({
    required this.hour,
    required this.minute,
    required this.numberStyle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(
      centre,
      radius - 4,
      Paint()..color = AppColors.surface,
    );
    canvas.drawCircle(
      centre,
      radius - 4,
      Paint()
        ..color = AppColors.text
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    // Minute ticks, with the five-minute ones drawn longer.
    for (var i = 0; i < 60; i++) {
      final isHour = i % 5 == 0;
      final angle = i * pi / 30 - pi / 2;
      final outer = radius - 12;
      final inner = outer - (isHour ? 18 : 8);
      canvas.drawLine(
        centre + Offset(cos(angle) * inner, sin(angle) * inner),
        centre + Offset(cos(angle) * outer, sin(angle) * outer),
        Paint()
          ..color = isHour ? AppColors.text : AppColors.divider
          ..strokeWidth = isHour ? 4 : 2,
      );
    }

    for (var number = 1; number <= 12; number++) {
      final angle = number * pi / 6 - pi / 2;
      final painter = TextPainter(
        text: TextSpan(text: '$number', style: numberStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final position = centre +
          Offset(cos(angle), sin(angle)) * (radius - 44) -
          Offset(painter.width / 2, painter.height / 2);
      painter.paint(canvas, position);
    }

    // The hour hand creeps on with the minutes, the way a real one does -
    // otherwise "halb vier" would look like it points at the four.
    final hourAngle = ((hour % 12) + minute / 60) * pi / 6 - pi / 2;
    _hand(canvas, centre, hourAngle, radius * 0.5, 11, AppColors.text);

    final minuteAngle = minute * pi / 30 - pi / 2;
    _hand(canvas, centre, minuteAngle, radius * 0.76, 7, AppColors.primary);

    canvas.drawCircle(centre, 9, Paint()..color = AppColors.text);
  }

  void _hand(
    Canvas canvas,
    Offset centre,
    double angle,
    double length,
    double width,
    Color color,
  ) {
    canvas.drawLine(
      centre - Offset(cos(angle), sin(angle)) * (length * 0.14),
      centre + Offset(cos(angle), sin(angle)) * length,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ClockPainter old) =>
      old.hour != hour ||
      old.minute != minute ||
      old.numberStyle != numberStyle;
}
