import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/chart_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/shimmer_loading.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
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
        title: const Text('Tổng quan'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshDashboard,
          ),
        ],
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
                    onPressed: _loadDashboard,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async => _refreshDashboard(),
              child: _buildDashboardContent(state),
            );
          }

          return const Center(child: Text('Chưa có dữ liệu'));
        },
      ),
    );
  }  Widget 
_buildDashboardContent(DashboardLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Selector
          _buildDateRangeSelector(state),
          const SizedBox(height: 16),

          // Asset Overview
          _buildAssetOverview(state),
          const SizedBox(height: 24),

          // Expense Overview
          _buildExpenseOverview(state),
          const SizedBox(height: 24),

          // Asset Distribution Chart
          _buildAssetDistributionSection(state),
          const SizedBox(height: 24),

          // Expense by Category Chart
          _buildExpenseByCategorySection(state),
          const SizedBox(height: 24),

          // Expense Trend Chart
          _buildExpenseTrendSection(state),
          const SizedBox(height: 24),

          // Recent Transactions
          _buildRecentTransactionsSection(state),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.date_range),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Từ ${_dateFormat.format(state.startDate)} đến ${_dateFormat.format(state.endDate)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () => _selectDateRange(state),
              child: const Text('Thay đổi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetOverview(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng quan tài sản',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Tổng tài sản',
                  '${state.assetSummary.totalBalance.toStringAsFixed(0)} VNĐ',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
                _buildStatCard(
                  'Số lượng',
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
 Widget _buildExpenseOverview(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tổng quan chi tiêu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Tổng chi tiêu',
                  '${state.expenseSummary.totalExpenses.toStringAsFixed(0)} VNĐ',
                  Icons.money_off,
                  Colors.red,
                ),
                _buildStatCard(
                  'Giao dịch',
                  '${state.expenseSummary.totalTransactions}',
                  Icons.receipt,
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
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

  Widget _buildAssetDistributionSection(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phân bổ tài sản',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                AssetDistributionPieChart(
                  assetSummary: state.assetSummary,
                  size: 150,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AssetDistributionLegend(
                    assetSummary: state.assetSummary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  } 
 Widget _buildExpenseByCategorySection(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiêu theo danh mục',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ExpenseByCategoryBarChart(
              categoryExpenses: state.categoryExpenses,
              height: 250,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTrendSection(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xu hướng chi tiêu',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ExpenseTrendLineChart(
              expenseSummary: state.expenseSummary,
              height: 250,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsSection(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Giao dịch gần đây',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full transaction list
                  },
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.recentTransactions.isEmpty)
              const Center(
                child: Text(
                  'Chưa có giao dịch nào',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...state.recentTransactions.take(5).map((transaction) =>
                  _buildTransactionItem(transaction)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(transaction) {
    return ListTile(
      leading: const CircleAvatar(
        child: Icon(Icons.receipt),
      ),
      title: Text(transaction.description),
      subtitle: Text(_dateFormat.format(transaction.date)),
      trailing: Text(
        '-${transaction.amount.toStringAsFixed(0)} VNĐ',
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _refreshDashboard() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<DashboardBloc>().add(
            RefreshDashboardData(userId: authState.user.id),
          );
    }
  }

  Future<void> _selectDateRange(DashboardLoaded state) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: state.startDate,
        end: state.endDate,
      ),
    );

    if (picked != null) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<DashboardBloc>().add(
              UpdateDateRange(
                userId: authState.user.id,
                startDate: picked.start,
                endDate: picked.end,
              ),
            );
      }
    }
  }
}