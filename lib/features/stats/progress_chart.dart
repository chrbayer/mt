import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../data/repositories/stats_repository.dart';
import '../../domain/scoring.dart';
import '../../theme/app_theme.dart';

/// The learning curve: average seconds per task over the last runs of one
/// lesson. Downwards means faster, which is the whole point of the app.
class ProgressChart extends StatelessWidget {
  final List<ProgressPoint> points;

  const ProgressChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return const Center(
        child: Text(
          'Ab dem zweiten Durchgang siehst du hier deine Lernkurve.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: AppColors.textMuted),
        ),
      );
    }

    final seconds = [for (final p in points) p.msPerTask / 1000];
    // Whole-second bounds and step, otherwise fl_chart rounds two neighbouring
    // labels to the same text near the top of the axis.
    final slowest = seconds.reduce((a, b) => a > b ? a : b);
    final maxY = (slowest * 1.25).ceilToDouble();
    final step = (maxY / 5).ceilToDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (points.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: step,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: AppColors.divider, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${value.toInt() + 1}',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 52,
              interval: step,
              getTitlesWidget: (value, meta) => Text(
                '${value.toStringAsFixed(0)} s',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) => [
              for (final spot in spots)
                LineTooltipItem(
                  formatPerTask(spot.y * 1000),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < seconds.length; i++)
                FlSpot(i.toDouble(), seconds[i]),
            ],
            isCurved: true,
            curveSmoothness: 0.2,
            color: AppColors.primary,
            barWidth: 4,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
