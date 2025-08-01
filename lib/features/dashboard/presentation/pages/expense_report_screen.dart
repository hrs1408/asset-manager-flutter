import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/chart_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ExpenseReportScreen extends StatefulWidget {
  const ExpenseReportScreen({super.key});

  @override
  State<ExpenseReportScreen> createState() => _ExpenseReportScreenState();
}

class _ExpenseReportScreenState extends State<ExpenseReportScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadExpenseReport();
  }

  void _loadExpenseReport() {
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
        title: const Text('Báo cáo chi tiêu'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
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
                    onPressed: _loadExpenseReport,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is DashboardLoaded) {
            return _buildExpenseReportContent(state);
          }

          return const Center(child: Text('Chưa có dữ liệu'));
        },
      ),
    );
  }  
Widget _buildExpenseReportContent(DashboardLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Range Display
          _buildDateRangeCard(state),
          const SizedBox(height: 16),

          // Expense Summary
          _buildExpenseSummary(state),
          const SizedBox(height: 24),

          // Expense Trend Chart
          _buildExpenseTrendChart(state),
          const SizedBox(height: 24),

          // Expense by Category Chart
          _buildExpenseByCategoryChart(state),
          const SizedBox(height: 24),

          // Category Details
          _buildCategoryDetails(state),
        ],
      ),
    );
  }

  Widget _buildDateRangeCard(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.date_range, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Khoảng thời gian',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Từ ${_dateFormat.format(state.startDate)} đến ${_dateFormat.format(state.endDate)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _selectDateRange,
              child: const Text('Thay đổi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseSummary(DashboardLoaded state) {
    final avgDaily = state.expenseSummary.dailyExpenses.isNotEmpty
        ? state.expenseSummary.totalExpenses / state.expenseSummary.dailyExpenses.length
        : 0;

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
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Tổng chi tiêu',
                    '${state.expenseSummary.totalExpenses.toStringAsFixed(0)} VNĐ',
                    Icons.money_off,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Trung bình/ngày',
                    '${avgDaily.toStringAsFixed(0)} VNĐ',
                    Icons.trending_up,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Số giao dịch',
                    '${state.expenseSummary.totalTransactions}',
                    Icons.receipt,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Số danh mục',
                    '${state.categoryExpenses.length}',
                    Icons.category,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }  Widget
 _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Container(
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
    );
  }

  Widget _buildExpenseTrendChart(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Xu hướng chi tiêu theo ngày',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ExpenseTrendLineChart(
              expenseSummary: state.expenseSummary,
              height: 300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseByCategoryChart(DashboardLoaded state) {
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
              height: 300,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDetails(DashboardLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết theo danh mục',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (state.categoryExpenses.isEmpty)
              const Center(
                child: Text(
                  'Không có dữ liệu chi tiêu',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...state.categoryExpenses.map((categoryExpense) =>
                  _buildCategoryItem(categoryExpense)),
          ],
        ),
      ),
    );
  }  Widget 
_buildCategoryItem(categoryExpense) {
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
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                categoryExpense.category.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryExpense.category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${categoryExpense.transactionCount} giao dịch • ${categoryExpense.percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${categoryExpense.totalAmount.toStringAsFixed(0)} VNĐ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDateRange() async {
    final currentState = context.read<DashboardBloc>().state;
    if (currentState is! DashboardLoaded) return;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: currentState.startDate,
        end: currentState.endDate,
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