import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CoreUsage extends StatelessWidget {
  final int index;
  final BigInt frequency;
  final List<FlSpot> spots;
  static const TextStyle _textStyle = TextStyle(fontWeight: FontWeight.bold);
  static const FlDotData _dotData = FlDotData(show: false);
  static final BarAreaData _barAreaData = BarAreaData(
    show: true,
    color: Colors.cyanAccent,
  );
  const CoreUsage({
    required this.index,
    required this.spots,
    required this.frequency,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Core $index", style: _textStyle),
        Text("$frequency MHz"),
        AspectRatio(
          aspectRatio: 1.4,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              maxY: 100.0,
              minY: 0.0,
              minX: spots.isNotEmpty ? spots.first.x : 0,
              maxX: spots.isNotEmpty ? spots.last.x : 100,
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  spots: spots,
                  dotData: _dotData,
                  belowBarData: _barAreaData,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
