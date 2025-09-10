import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartDataPoint {
  final double x;
  final double y;

  ChartDataPoint({required this.x, required this.y});
}

class LineChartWidget extends StatelessWidget {
  final List&lt;ChartDataPoint&gt; data;
  final String title;
  final Color color;
  final bool showGrid;
  final bool showDots;
  final double strokeWidth;

  const LineChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.color = Colors.blue,
    this.showGrid = true,
    this.showDots = true,
    this.strokeWidth = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(&apos;No data available&apos;),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: showGrid),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: _getBottomInterval(),
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    &apos;${date.day}/${date.month}&apos;,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: data.map((point) =&gt; FlSpot(point.x, point.y)).toList(),
            isCurved: true,
            color: color,
            barWidth: strokeWidth,
            dotData: FlDotData(show: showDots),
            belowBarData: BarAreaData(
              show: true,
              color: color.withOpacity(0.1),
            ),
          ),
        ],
        minX: data.first.x,
        maxX: data.last.x,
        minY: 0,
        maxY: _getMaxY() * 1.1,
      ),
    );
  }

  double _getMaxY() {
    if (data.isEmpty) return 100;
    return data.map((e) =&gt; e.y).reduce((a, b) =&gt; a &gt; b ? a : b);
  }

  double _getBottomInterval() {
    if (data.isEmpty) return 1;
    final range = data.last.x - data.first.x;
    return range / 5; // Show approximately 5 labels
  }
}