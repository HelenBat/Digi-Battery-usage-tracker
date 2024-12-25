import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SocialMediaPieChart extends StatelessWidget {
  final List<Map<String, dynamic>> usageData;

  const SocialMediaPieChart({Key? key, required this.usageData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate total CO2
    double totalCO2 = 0;
    for (var data in usageData) {
      totalCO2 += (data['co2'] as double);
    }

    // Generate sections
    final sections = usageData.map((data) {
      final co2 = data['co2'] as double;
      final percentage = totalCO2 == 0 ? 0 : (co2 / totalCO2) * 100;
      return PieChartSectionData(
        value: co2,
        title: "${percentage.toStringAsFixed(1)}%",
        color: _randomColorForApp(data['package']),
        radius: 80,
        titleStyle: const TextStyle(color: Colors.white, fontSize: 12),
      );
    }).toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 2,
      ),
    );
  }

  /// Simple function to get a color based on package name.
  Color _randomColorForApp(String packageName) {
    // You might want a more consistent approach or a mapping
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.brown,
      Colors.cyan,
      Colors.pink,
      Colors.yellow,
      Colors.grey,
    ];
    return colors[packageName.hashCode % colors.length];
  }
}

class SocialMediaLineChart extends StatelessWidget {
  final List<Map<String, dynamic>> usageData;

  const SocialMediaLineChart({Key? key, required this.usageData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // For demonstration, we’ll plot each app’s CO2 in a single line
    // or an aggregated line over time. Real usage would require data points at intervals.
    // Here, we show a simplistic approach with usage index on X-axis and CO2 on Y-axis.

    // Sort usageData by CO2 ascending for a simple line
    final sortedUsage = List<Map<String, dynamic>>.from(usageData)
      ..sort((a, b) => (a['co2'] as double).compareTo(b['co2'] as double));

    List<FlSpot> spots = [];
    for (int i = 0; i < sortedUsage.length; i++) {
      final co2Val = sortedUsage[i]['co2'] as double;
      spots.add(FlSpot(i.toDouble(), co2Val));
    }

    final lineBarData = LineChartBarData(
      spots: spots,
      isCurved: true,
      color: Colors.blueAccent,
      barWidth: 2,
      dotData: FlDotData(show: true),
    );

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (spots.isEmpty ? 1 : spots.length - 1).toDouble(),
        minY: 0,
        maxY: _maxCO2(spots),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                'App ${(value + 1).toInt()}',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
        ),
        lineBarsData: [lineBarData],
      ),
    );
  }

  double _maxCO2(List<FlSpot> spots) {
    double maxVal = 0;
    for (var spot in spots) {
      if (spot.y > maxVal) {
        maxVal = spot.y;
      }
    }
    if (maxVal < 1) return 1.0; // just to avoid a zero or too low scale
    return maxVal;
  }
}
