import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/expense_summary.dart';

class ExpenseTrendLineChart extends StatefulWidget {
  final ExpenseSummary expenseSummary;
  final double height;

  const ExpenseTrendLineChart({
    super.key,
    required this.expenseSummary,
    this.height = 300,
  });

  @override
  State<ExpenseTrendLineChart> createState() => _ExpenseTrendLineChartState();
}

class _ExpenseTrendLineChartState extends State<ExpenseTrendLineChart> {
  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.expenseSummary.dailyExpenses.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text(
            'Không có dữ liệu chi tiêu theo ngày',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: _getMaxY() / 5,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Colors.grey,
                strokeWidth: 0.5,
              );
            },
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: Colors.grey,
                strokeWidth: 0.5,
              );
            },
          ),     
     titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: _getBottomInterval(),
                getTitlesWidget: _getBottomTitles,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _getMaxY() / 5,
                getTitlesWidget: _getLeftTitles,
                reservedSize: 60,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d)),
          ),
          minX: 0,
          maxX: _getMaxX(),
          minY: 0,
          maxY: _getMaxY(),
          lineBarsData: [
            LineChartBarData(
              spots: _buildSpots(),
              isCurved: true,
              gradient: LinearGradient(
                colors: gradientColors,
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(
                show: false,
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: gradientColors
                      .map((color) => color.withOpacity(0.3))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }  List
<FlSpot> _buildSpots() {
    final sortedEntries = widget.expenseSummary.dailyExpenses.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final amount = entry.value.value;
      return FlSpot(index.toDouble(), amount);
    }).toList();
  }

  double _getMaxX() {
    return widget.expenseSummary.dailyExpenses.length.toDouble() - 1;
  }

  double _getMaxY() {
    if (widget.expenseSummary.dailyExpenses.isEmpty) return 100;
    final maxAmount = widget.expenseSummary.dailyExpenses.values
        .reduce((a, b) => a > b ? a : b);
    return maxAmount * 1.2; // Add 20% padding
  }

  double _getBottomInterval() {
    final length = widget.expenseSummary.dailyExpenses.length;
    if (length <= 7) return 1;
    if (length <= 14) return 2;
    if (length <= 30) return 5;
    return 7;
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    final sortedEntries = widget.expenseSummary.dailyExpenses.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (value.toInt() >= 0 && value.toInt() < sortedEntries.length) {
      final date = sortedEntries[value.toInt()].key;
      final formatter = DateFormat('dd/MM');
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(formatter.format(date), style: style),
      );
    }

    return const Text('');
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    String text;
    if (value >= 1000000) {
      text = '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      text = value.toInt().toString();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }
}