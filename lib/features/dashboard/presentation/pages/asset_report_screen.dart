import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/chart_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../assets/domain/entities/asset_type.dart';

class AssetReportScreen extends StatefulWidget {
  const AssetReportScreen({super.key});

  @override
  State<AssetReportScreen> createState() => _AssetReportScreenState();
}

class _AssetReportScreenState extends State<AssetReportScreen> {
  @override
  void initState() {
    super.initState();
    _loadAssetReport();
  }

  void _loadAssetReport() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<DashboardBloc>().add(
            LoadDashboardData(userId: authState.user.id),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo tài sản'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lỗi: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAssetReport,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            return _buildAssetReportContent(state);
          }

          return const Center(child: Text('Chưa có dữ liệu'));
        },
      ),
    );
  }  Widget 
_buildAssetReportContent(DashboardLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Assets Summary
          _buildTotalAssetsSummary(state),
          const SizedBox(height: 24),

          // Asset Distribution Chart
          _buildAssetDistributionChart(state),
          const SizedBox(height: 24),

          // Asset Details by Type
          _buildAssetDetailsByType(state),
        ],
      ),
    );
  }

  Widget _buildTotalAssetsSummary(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng quan tài sản',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(
                  'Tổng giá trị',
                  '${state.assetSummary.totalBalance.toStringAsFixed(0)} VNĐ',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
                _buildSummaryItem(
                  'Số lượng tài sản',
                  '${state.assetSummary.totalAssets}',
                  Icons.list,
                  Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetDistributionChart(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phân bổ tài sản theo loại',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: AssetDistributionPieChart(
                assetSummary: state.assetSummary,
                size: 250,
              ),
            ),
            const SizedBox(height: 16),
            AssetDistributionLegend(
              assetSummary: state.assetSummary,
            ),
          ],
        ),
      ),
    );
  }  Widget
 _buildAssetDetailsByType(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết theo loại tài sản',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...AssetType.values.map((assetType) {
              final balance = state.assetSummary.balanceByType[assetType] ?? 0;
              final count = state.assetSummary.countByType[assetType] ?? 0;
              
              if (balance == 0 && count == 0) {
                return const SizedBox.shrink();
              }

              final percentage = state.assetSummary.totalBalance > 0
                  ? (balance / state.assetSummary.totalBalance) * 100
                  : 0;

              return _buildAssetTypeItem(
                assetType,
                balance,
                count,
                percentage,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetTypeItem(
    AssetType assetType,
    double balance,
    int count,
    double percentage,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getAssetTypeColor(assetType).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getAssetTypeIcon(assetType),
              color: _getAssetTypeColor(assetType),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  assetType.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count tài sản • ${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${balance.toStringAsFixed(0)} VNĐ',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getAssetTypeColor(assetType),
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

  IconData _getAssetTypeIcon(AssetType assetType) {
    switch (assetType) {
      case AssetType.paymentAccount:
        return Icons.account_balance;
      case AssetType.savingsAccount:
        return Icons.savings;
      case AssetType.gold:
        return Icons.star;
      case AssetType.loan:
        return Icons.handshake;
      case AssetType.realEstate:
        return Icons.home;
      case AssetType.other:
        return Icons.category;
    }
  }
}