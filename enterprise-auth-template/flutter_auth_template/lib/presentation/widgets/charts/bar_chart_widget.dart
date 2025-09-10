import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class BarChartData {
  final String label;
  final double value;
  final Color? color;

  BarChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

class BarChartWidget extends StatefulWidget {
  final List&lt;BarChartData&gt; data;
  final String title;
  final Color color;
  final bool showGrid;
  final bool showValues;

  const BarChartWidget({
    super.key,
    required this.data,
    required this.title,
    this.color = Colors.blue,
    this.showGrid = true,
    this.showValues = true,
  });

  @override
  State&lt;BarChartWidget&gt; createState() =&gt; _BarChartWidgetState();
}

class _BarChartWidgetState extends State&lt;BarChartWidget&gt; {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text(&apos;No data available&apos;),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY() * 1.2,
        barTouchData: BarTouchData(
          touchCallback: (FlTouchEvent event, barTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  barTouchResponse == null ||
                  barTouchResponse.spot == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
            });
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index &gt;= 0 &amp;&amp; index &lt; widget.data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      widget.data[index].label,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return const Text(&apos;&apos;);
              },
              reservedSize: 38,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: _getLeftInterval(),
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        barGroups: _buildBarGroups(),
        gridData: FlGridData(show: widget.showGrid),
      ),
    );
  }

  List&lt;BarChartGroupData&gt; _buildBarGroups() {
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == touchedIndex;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.value,
            color: data.color ?? widget.color,
            width: isTouched ? 25 : 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: Colors.grey.shade200,
            ),
          ),
        ],
        showingTooltipIndicators: widget.showValues &amp;&amp; isTouched ? [0] : [],
      );
    }).toList();
  }

  double _getMaxY() {
    if (widget.data.isEmpty) return 100;
    return widget.data.map((e) =&gt; e.value).reduce((a, b) =&gt; a &gt; b ? a : b);
  }

  double _getLeftInterval() {
    final maxY = _getMaxY();
    if (maxY &lt;= 10) return 1;
    if (maxY &lt;= 50) return 5;
    if (maxY &lt;= 100) return 10;
    if (maxY &lt;= 500) return 50;
    return 100;
  }
}