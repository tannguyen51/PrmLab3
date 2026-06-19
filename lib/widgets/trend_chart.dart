import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/trend_point.dart';

class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.points});

  final List<TrendPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const _EmptyChart();
    }

    final maxY = points
        .map((point) => point.count)
        .reduce((left, right) => left > right ? left : right)
        .toDouble();

    if (maxY == 0) return const _EmptyChart();

    final interval = maxY <= 5 ? 1.0 : (maxY / 5).ceilToDouble();

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          maxY: maxY + 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: AppColors.borderGlass,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: interval,
                getTitlesWidget: (value, meta) => Text(
                  meta.formattedValue,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${points[index].year}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: points
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final point = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: point.count.toDouble(),
                      width: 18,
                      gradient: const LinearGradient(
                        colors: [AppColors.neonCyan, AppColors.neonLime],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ],
                );
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: const Text(
        'Not enough publication year data\nto draw a trend chart.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}
