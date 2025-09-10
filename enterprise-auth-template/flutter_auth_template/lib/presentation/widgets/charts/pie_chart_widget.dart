import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartData {
  final String label;
  final double value;
  final Color? color;

  PieChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

class PieChartWidget extends StatefulWidget {
  final List&lt;PieChartData&gt; data;
  final bool showPercentages;
  final bool showLegend;
  final double radius;

  const PieChartWidget({
    super.key,
    required this.data,
    this.showPercentages = true,
    this.showLegend = true,
    this.radius = 80,
  });

  @override
  State&lt;PieChartWidget&gt; createState() =&gt; _PieChartWidgetState();
}

class _PieChartWidgetState extends State&lt;PieChartWidget&gt; {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.data.isEmpty) {
      return const Center(
        child: Text(&apos;No data available&apos;),
      );
    }

    final total = widget.data.fold&lt;double&gt;(0, (sum, item) =&gt; sum + item.value);

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 0,
                sections: _buildSections(total),
              ),
            ),
          ),
        ),
        if (widget.showLegend) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildLegend(total),
          ),
        ],
      ],
    );
  }

  List&lt;PieChartSectionData&gt; _buildSections(double total) {
    final colors = _generateColors(widget.data.length);
    
    return widget.data.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? widget.radius + 10 : widget.radius;
      final percentage = (data.value / total * 100);

      return PieChartSectionData(
        color: data.color ?? colors[index],
        value: data.value,
        title: widget.showPercentages ? &apos;${percentage.toStringAsFixed(1)}%&apos; : &apos;&apos;,
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(double total) {
    final colors = _generateColors(widget.data.length);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.data.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        final percentage = (data.value / total * 100);
        final color = data.color ?? colors[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      &apos;${data.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)&apos;,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List&lt;Color&gt; _generateColors(int count) {
    return List.generate(count, (index) {
      final hue = (index * 360 / count) % 360;
      return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
    });
  }
}