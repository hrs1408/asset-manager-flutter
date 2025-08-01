import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/chart_widgets.dart';
import '../widgets/dashboard_insights.dart';
import '../widgets/mobile_chart_widgets.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../../core/widgets/responsive_grid.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/widgets/data_mode_indicator.dart';

class MobileDashboardScreen extends StatefulWidget {
  const MobileDashboardScreen({super.key});

  @override
  State<MobileDashboardScreen> createState() => _MobileDashboardScreenState();
}

class _MobileDashboardScreenState extends State<MobileDashboardScreen>
    with TickerProviderStateMixin {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final PageController _pageController = PageController();
  int _currentChartPage = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadDashboard();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
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
      backgroundColor: Colors.grey[50],
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardLoaded) {
            _animationController.forward();
          }
        },
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildMobileSliverAppBar(),
              if (state is DashboardLoading) _buildMobileLoadingSliver(),
              if (state is DashboardError) _buildMobileErrorSliver(state),
              if (state is DashboardLoaded) _buildMobileContentSliver(state),
              if (state is DashboardInitial) _buildMobileInitialSliver(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
          onPressed: () => DataModeDialog.show(context),
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
          onPressed: _refreshDashboard,
        ),
      ],
    );
  }

  Widget _buildMobileInitialSliver() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.dashboard,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Chào mừng đến với Dashboard',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Theo dõi tài sản và chi tiêu của bạn',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadDashboard,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Bắt đầu'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLoadingSliver() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          ShimmerLoading(
            isLoading: true,
            child: Column(
              children: [
                _buildShimmerCard(height: 80),
                const SizedBox(height: 16),
                _buildShimmerCard(height: 120),
                const SizedBox(height: 16),
                _buildShimmerCard(height: 120),
                const SizedBox(height: 16),
                _buildShimmerCard(height: 200),
                const SizedBox(height: 16),
                _buildShimmerCard(height: 150),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildShimmerCard({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildMobileErrorSliver(DashboardError state) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Có lỗi xảy ra',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadDashboard,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _navigateToAddAsset,
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm dữ liệu'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const DataModeIndicator(showAlways: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileContentSliver(DashboardLoaded state) {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMobileWelcomeHeader(),
                const SizedBox(height: 16),
                _buildMobileQuickActions(),
                const SizedBox(height: 20),
                _buildMobileDateRangeSelector(state),
                const SizedBox(height: 16),
                _buildMobileOverviewCards(state),
                const SizedBox(height: 20),
                _buildMobileChartsSection(state),
                const SizedBox(height: 20),
                _buildMobileInsights(state),
                const SizedBox(height: 20),
                _buildMobileRecentTransactions(state),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildMobileWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue[400]!,
            Colors.blue[600]!,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    final greeting = authState is AuthAuthenticated
                        ? 'Chào ${authState.user.email.split('@')[0]}!'
                        : 'Chào mừng!';
                    return Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                Text(
                  _dateFormat.format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.dashboard,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thao tác nhanh',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMobileQuickActionCard(
                icon: Icons.add_circle,
                title: 'Thêm\ntài sản',
                color: Colors.green,
                onTap: _navigateToAddAsset,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMobileQuickActionCard(
                icon: Icons.remove_circle,
                title: 'Thêm\nchi tiêu',
                color: Colors.red,
                onTap: _navigateToAddExpense,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMobileQuickActionCard(
                icon: Icons.analytics,
                title: 'Xem\nbáo cáo',
                color: Colors.purple,
                onTap: _navigateToReports,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileDateRangeSelector(DashboardLoaded state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.date_range,
              color: Colors.blue,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Khoảng thời gian',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${_dateFormat.format(state.startDate)} - ${_dateFormat.format(state.endDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _selectDateRange(state),
            child: const Text(
              'Đổi',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileOverviewCards(DashboardLoaded state) {
    return Column(
      children: [
        _buildMobileAssetOverviewCard(state),
        const SizedBox(height: 12),
        _buildMobileExpenseOverviewCard(state),
      ],
    );
  }

  Widget _buildMobileAssetOverviewCard(DashboardLoaded state) {
    return GestureDetector(
      onTap: _navigateToAssets,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[400]!,
              Colors.green[600]!,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng tài sản',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedCounter(
                    value: state.assetSummary.totalBalance,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    suffix: ' VNĐ',
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${state.assetSummary.totalAssets} tài sản',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileExpenseOverviewCard(DashboardLoaded state) {
    return GestureDetector(
      onTap: _navigateToTransactions,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.red[400]!,
              Colors.red[600]!,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.money_off,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng chi tiêu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedCounter(
                    value: state.expenseSummary.totalExpenses,
                    textStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    suffix: ' VNĐ',
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${state.expenseSummary.totalTransactions} giao dịch',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileChartsSection(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Phân tích',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Row(
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.only(left: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentChartPage == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 280,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentChartPage = index;
              });
            },
            children: [
              _buildMobileAssetDistributionChart(state),
              _buildMobileExpenseByCategoryChart(state),
              _buildMobileExpenseTrendChart(state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileAssetDistributionChart(DashboardLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: Colors.purple,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Phân bổ tài sản',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.assetSummary.totalBalance > 0)
            Expanded(
              child: Row(
                children: [
                  AssetDistributionPieChart(
                    assetSummary: state.assetSummary,
                    size: 100,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AssetDistributionLegend(
                      assetSummary: state.assetSummary,
                    ),
                  ),
                ],
              ),
            )
          else
            _buildMobileEmptyState('Chưa có dữ liệu tài sản', Icons.account_balance_wallet),
        ],
      ),
    );
  }

  Widget _buildMobileExpenseByCategoryChart(DashboardLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: Colors.orange,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Chi tiêu theo danh mục',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.categoryExpenses.isNotEmpty)
            Expanded(
              child: ExpenseByCategoryBarChart(
                categoryExpenses: state.categoryExpenses,
                height: 200,
              ),
            )
          else
            _buildMobileEmptyState('Chưa có dữ liệu chi tiêu', Icons.receipt_long),
        ],
      ),
    );
  }

  Widget _buildMobileExpenseTrendChart(DashboardLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.blue,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Xu hướng chi tiêu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ExpenseTrendLineChart(
              expenseSummary: state.expenseSummary,
              height: 200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileInsights(DashboardLoaded state) {
    return DashboardInsights(
      assetSummary: state.assetSummary,
      expenseSummary: state.expenseSummary,
    );
  }

  Widget _buildMobileRecentTransactions(DashboardLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.history,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Giao dịch gần đây',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _navigateToTransactions,
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.recentTransactions.isEmpty)
            _buildMobileEmptyState('Chưa có giao dịch nào', Icons.receipt_long)
          else
            ...state.recentTransactions.take(3).map((transaction) =>
                _buildMobileTransactionItem(transaction)),
        ],
      ),
    );
  }

  Widget _buildMobileEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileTransactionItem(transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.receipt,
              color: Colors.red,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? 'Giao dịch',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _dateFormat.format(transaction.date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-${transaction.amount.toStringAsFixed(0)} VNĐ',
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToAddAsset() {
    Navigator.pushNamed(context, '/add-asset');
  }

  void _navigateToAddExpense() {
    Navigator.pushNamed(context, '/add-expense');
  }

  void _navigateToReports() {
    Navigator.pushNamed(context, '/reports');
  }

  void _navigateToAssets() {
    if (mounted) {
      DefaultTabController.of(context)?.animateTo(1);
    }
  }

  void _navigateToTransactions() {
    if (mounted) {
      DefaultTabController.of(context)?.animateTo(2);
    }
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.blue,
                ),
          ),
          child: child!,
        );
      },
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