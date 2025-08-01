import 'package:flutter/material.dart';
import '../../domain/entities/asset_summary.dart';
import '../../domain/entities/expense_summary.dart';

class DashboardInsights extends StatelessWidget {
  final AssetSummary assetSummary;
  final ExpenseSummary expenseSummary;

  const DashboardInsights({
    super.key,
    required this.assetSummary,
    required this.expenseSummary,
  });

  @override
  Widget build(BuildContext context) {
    final insights = _generateInsights();
    
    if (insights.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thông tin hữu ích',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...insights.map((insight) => _buildInsightItem(insight)),
        ],
      ),
    );
  }

  Widget _buildInsightItem(DashboardInsight insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: insight.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insight.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            insight.icon,
            color: insight.color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: insight.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  insight.description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DashboardInsight> _generateInsights() {
    final List<DashboardInsight> insights = [];

    // Asset insights
    if (assetSummary.totalBalance > 0) {
      // Check asset diversification
      final assetTypes = assetSummary.balanceByType.keys.length;
      if (assetTypes < 3) {
        insights.add(
          DashboardInsight(
            title: 'Đa dạng hóa tài sản',
            description: 'Bạn nên đầu tư vào nhiều loại tài sản khác nhau để giảm rủi ro.',
            icon: Icons.diversity_3,
            color: Colors.blue,
          ),
        );
      }

      // Check emergency fund
      final monthlyExpense = expenseSummary.totalExpenses / 30;
      final emergencyFundMonths = assetSummary.totalBalance / monthlyExpense;
      if (emergencyFundMonths < 3) {
        insights.add(
          DashboardInsight(
            title: 'Quỹ khẩn cấp',
            description: 'Nên duy trì quỹ khẩn cấp ít nhất 3-6 tháng chi tiêu.',
            icon: Icons.security,
            color: Colors.orange,
          ),
        );
      }
    }

    // Expense insights
    if (expenseSummary.totalExpenses > 0) {
      // Check spending trend
      final dailyAverage = expenseSummary.totalExpenses / 30;
      if (dailyAverage > assetSummary.totalBalance * 0.1) {
        insights.add(
          DashboardInsight(
            title: 'Kiểm soát chi tiêu',
            description: 'Chi tiêu hàng ngày của bạn khá cao so với tổng tài sản.',
            icon: Icons.trending_down,
            color: Colors.red,
          ),
        );
      }

      // Positive insight
      if (assetSummary.totalBalance > expenseSummary.totalExpenses * 10) {
        insights.add(
          DashboardInsight(
            title: 'Tài chính ổn định',
            description: 'Tuyệt vời! Bạn đang quản lý tài chính rất tốt.',
            icon: Icons.thumb_up,
            color: Colors.green,
          ),
        );
      }
    }

    return insights;
  }
}

class DashboardInsight {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  DashboardInsight({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}