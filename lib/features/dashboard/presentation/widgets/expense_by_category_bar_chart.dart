import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/category_expense.dart';

class ExpenseByCategoryBarChart extends StatefulWidget {
  final List<CategoryExpense> categoryExpenses;
  final double height;

  const ExpenseByCategoryBarChart({
    super.key,
    required this.categoryExpenses,
    this.height = 300,
  });

  @override
  State<ExpenseByCategoryBarChart> createState() => _ExpenseByCategoryBarChartState();
}

class _ExpenseByCategoryBarChartState extends State<ExpenseByCategoryBarChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryExpenses.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: Text(
            'Không có dữ liệu chi tiêu',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
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
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final categoryExpense = widget.categoryExpenses[groupIndex];
                return BarTooltipItem(
                  '${categoryExpense.category.name}\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      text: '${categoryExpense.totalAmount.toStringAsFixed(0)} VNĐ',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
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
                getTitlesWidget: _getBottomTitles,
                reservedSize: 42,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                interval: _getMaxY() / 5,
                getTitlesWidget: _getLeftTitles,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: _buildBarGroups(),
          gridData: const FlGridData(show: false),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (widget.categoryExpenses.isEmpty) return 100;
    final maxAmount = widget.categoryExpenses
        .map((e) => e.totalAmount)
        .reduce((a, b) => a > b ? a : b);
    return maxAmount * 1.2; // Add 20% padding
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );

    if (value.toInt() >= 0 && value.toInt() < widget.categoryExpenses.length) {
      final category = widget.categoryExpenses[value.toInt()];
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 16,
        child: Column(
          children: [
            Text(
              category.category.icon,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              category.category.name.length > 8
                  ? '${category.category.name.substring(0, 8)}...'
                  : category.category.name,
              style: style,
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.categoryExpenses.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryExpense = entry.value;
      final isTouched = index == touchedIndex;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: categoryExpense.totalAmount,
            color: isTouched ? Colors.blue : Colors.lightBlue,
            width: isTouched ? 25 : 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: Colors.grey.withOpacity(0.1),
            ),
          ),
        ],
      );
    }).toList();
  }
}