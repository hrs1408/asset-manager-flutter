import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../assets/domain/entities/asset_type.dart';
import '../../domain/entities/asset_summary.dart';

class AssetDistributionPieChart extends StatefulWidget {
  final AssetSummary assetSummary;
  final double size;

  const AssetDistributionPieChart({
    super.key,
    required this.assetSummary,
    this.size = 200,
  });

  @override
  State<AssetDistributionPieChart> createState() => _AssetDistributionPieChartState();
}

class _AssetDistributionPieChartState extends State<AssetDistributionPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
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
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: _buildPieChartSections(),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final List<PieChartSectionData> sections = [];
    int index = 0;

    for (final entry in widget.assetSummary.balanceByType.entries) {
      if (entry.value > 0) {
        final isTouched = index == touchedIndex;
        final fontSize = isTouched ? 16.0 : 12.0;
        final radius = isTouched ? 60.0 : 50.0;
        final percentage = (entry.value / widget.assetSummary.totalBalance) * 100;

        sections.add(
          PieChartSectionData(
            color: _getAssetTypeColor(entry.key),
            value: entry.value,
            title: '${percentage.toStringAsFixed(1)}%',
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

class AssetDistributionLegend extends StatelessWidget {
  final AssetSummary assetSummary;

  const AssetDistributionLegend({
    super.key,
    required this.assetSummary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: assetSummary.balanceByType.entries
          .where((entry) => entry.value > 0)
          .map((entry) => _buildLegendItem(entry.key, entry.value))
          .toList(),
    );
  }

  Widget _buildLegendItem(AssetType assetType, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _getAssetTypeColor(assetType),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              assetType.displayName,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            '${value.toStringAsFixed(0)} VNĐ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
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