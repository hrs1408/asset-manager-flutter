import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/asset_summary.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/category_expense.dart';
import '../../../assets/domain/entities/asset_type.dart';

class MobileAssetDistributionChart extends StatefulWidget {
  final AssetSummary assetSummary;

  const MobileAssetDistributionChart({
    super.key,
    required this.assetSummary,
  });

  @override
  State<MobileAssetDistributionChart> createState() => _MobileAssetDistributionChartState();
}

class _MobileAssetDistributionChartState extends State<MobileAssetDistributionChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 120,
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
              sectionsSpace: 1,
              centerSpaceRadius: 25,
              sections: _buildPieChartSections(),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildMobileLegend(),
      ],
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final List<PieChartSectionData> sections = [];
    int index = 0;

    for (final entry in widget.assetSummary.balanceByType.entries) {
      if (entry.value > 0) {
        final isTouched = index == touchedIndex;
        final fontSize = isTouched ? 12.0 : 10.0;
        final radius = isTouched ? 35.0 : 30.0;
        final percentage = (entry.value / widget.assetSummary.totalBalance) * 100;

        sections.add(
          PieChartSectionData(
            color: _getAssetTypeColor(entry.key),
            value: entry.value,
            title: '${percentage.toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        index++;
      }
    }

    return sections;
  }

  Widget _buildMobileLegend() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: widget.assetSummary.balanceByType.entries
          .where((entry) => entry.value > 0)
          .map((entry) => _buildMobileLegendItem(entry.key, entry.value))
          .toList(),
    );
  }

  Widget _buildMobileLegendItem(AssetType assetType, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getAssetTypeColor(assetType).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getAssetTypeColor(assetType).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getAssetTypeColor(assetType),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            assetType.displayName,
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Color _getAssetTypeColor(AssetType assetType) {
    switch (assetType) {
      case AssetType.paymentAccount:
        return Colors.blue;
      case AssetType.savingsAccount:
        return Colors.green;
      case AssetType.gold:
        return Colors.amber;
      case AssetType.loan:
        return Colors.orange;
      case AssetType.realEstate:
        return Colors.purple;
      case AssetType.other:
        return Colors.grey;
    }
  }
}

class MobileExpenseByCategoryChart extends StatefulWidget {
  final List<CategoryExpense> categoryExpenses;

  const MobileExpenseByCategoryChart({
    super.key,
    required this.categoryExpenses,
  });

  @override
  State<MobileExpenseByCategoryChart> createState() => _MobileExpenseByCategoryChartState();
}

class _MobileExpenseByCategoryChartState extends State<MobileExpenseByCategoryChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.categoryExpenses.isEmpty) {
      return const Center(
        child: Text(
          'Không có dữ liệu chi tiêu',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 140,
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
                    reservedSize: 32,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: _getMaxY() / 3,
                    getTitlesWidget: _getLeftTitles,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: _buildBarGroups(),
              gridData: const FlGridData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildMobileCategoryLegend(),
      ],
    );
  }

  double _getMaxY() {
    if (widget.categoryExpenses.isEmpty) return 100;
    final maxAmount = widget.categoryExpenses
        .map((e) => e.totalAmount)
        .reduce((a, b) => a > b ? a : b);
    return maxAmount * 1.2;
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    if (value.toInt() >= 0 && value.toInt() < widget.categoryExpenses.length) {
      final category = widget.categoryExpenses[value.toInt()];
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8,
        child: Text(
          category.category.icon,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }
    return const Text('');
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );

    String text;
    if (value >= 1000000) {
      text = '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(0)}K';
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
            width: isTouched ? 16 : 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(2),
              topRight: Radius.circular(2),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildMobileCategoryLegend() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: widget.categoryExpenses.take(3).map((categoryExpense) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                categoryExpense.category.icon,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(width: 4),
              Text(
                categoryExpense.category.name,
                style: const TextStyle(fontSize: 9),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class MobileExpenseTrendChart extends StatelessWidget {
  final ExpenseSummary expenseSummary;

  const MobileExpenseTrendChart({
    super.key,
    required this.expenseSummary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _getMaxY() / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
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
                reservedSize: 22,
                interval: 7,
                getTitlesWidget: _getBottomTitles,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
                interval: _getMaxY() / 3,
                getTitlesWidget: _getLeftTitles,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: expenseSummary.dailyExpenses.length.toDouble() - 1,
          minY: 0,
          maxY: _getMaxY(),
          lineBarsData: [
            LineChartBarData(
              spots: _buildSpots(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    if (expenseSummary.dailyExpenses.isEmpty) return 100;
    final maxAmount = expenseSummary.dailyExpenses.values
        .reduce((a, b) => a > b ? a : b);
    return maxAmount * 1.2;
  }

  List<FlSpot> _buildSpots() {
    final sortedEntries = expenseSummary.dailyExpenses.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );

    final sortedEntries = expenseSummary.dailyExpenses.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (value.toInt() >= 0 && value.toInt() < sortedEntries.length) {
      final date = sortedEntries[value.toInt()].key;
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 4,
        child: Text(
          '${date.day}/${date.month}',
          style: style,
        ),
      );
    }

    return const Text('');
  }

  Widget _getLeftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );

    String text;
    if (value >= 1000000) {
      text = '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      text = '${(value / 1000).toStringAsFixed(0)}K';
    } else {
      text = value.toInt().toString();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 0,
      child: Text(text, style: style),
    );
  }
}