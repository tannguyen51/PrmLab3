import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

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

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          maxY: maxY + 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
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
                interval: 1,
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
                        color: Color(0xFF334155),
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
                      color: const Color(0xFF0F766E),
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
      height: 200,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Not enough publication year data to draw a trend chart.',
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
      ),
    );
  }
}
