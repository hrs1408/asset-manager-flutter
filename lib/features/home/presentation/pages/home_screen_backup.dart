import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../assets/presentation/pages/asset_list_screen.dart';
import '../../../expenses/presentation/pages/category_management_screen.dart';
import '../../../expenses/presentation/pages/transaction_list_screen.dart';
import '../../../expenses/presentation/bloc/transaction_bloc.dart';
import '../../../backup/presentation/pages/backup_screen.dart';
import '../../../dashboard/presentation/pages/production_dashboard_screen.dart';
import '../../../dashboard/presentation/pages/mobile_dashboard_screen.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../../core/widgets/responsive_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTabWrapper(),
    const AssetListScreenWrapper(),
    const TransactionListScreenWrapper(),
    const CategoryManagementScreen(),
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: ResponsiveBreakpoints.isMobile(context)
          ? _buildMobileBottomNavigation()
          : _buildTabletBottomNavigation(),
    );
  }
}

class DashboardTabWrapper extends StatelessWidget {
  const DashboardTabWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DashboardBloc>(),
      child: ResponsiveBreakpoints.isMobile(context)
          ? const MobileDashboardScreen()
          : const ProductionDashboardScreen(),
    );
  }
}

class AssetListScreenWrapper extends StatelessWidget {
  const AssetListScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return AssetListScreen(userId: state.user.id);
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class TransactionListScreenWrapper extends StatelessWidget {
  const TransactionListScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TransactionBloc>(),
      child: const TransactionListScreen(),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Đăng xuất'),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.read<AuthBloc>().add(const AuthSignOutRequested());
                      },
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return Text(
                    state.user.email,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
                return const Text('Đang tải...');
              },
            ),
            const SizedBox(height: 40),
            _buildMenuCard(
              context,
              icon: Icons.backup,
              title: 'Sao lưu & Bảo mật',
              subtitle: 'Xuất dữ liệu và cài đặt bảo mật',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BackupScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context,
              icon: Icons.info_outline,
              title: 'Thông tin ứng dụng',
              subtitle: 'Phiên bản 1.0.0',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Quản lý Tài sản',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.account_balance_wallet),
                  children: [
                    const Text('Ứng dụng quản lý tài sản cá nhân'),
                    const Text('Phát triển bằng Flutter & Firebase'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cá nhân'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Đăng xuất'),
                  content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.read<AuthBloc>().add(const AuthSignOutRequested());
                      },
                      child: const Text('Đăng xuất'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                if (state is AuthAuthenticated) {
                  return Text(
                    state.user.email,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
                return const Text('Đang tải...');
              },
            ),
            const SizedBox(height: 40),
            _buildMenuCard(
              context,
              icon: Icons.backup,
              title: 'Sao lưu & Bảo mật',
              subtitle: 'Xuất dữ liệu và cài đặt bảo mật',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BackupScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context,
              icon: Icons.info_outline,
              title: 'Thông tin ứng dụng',
              subtitle: 'Phiên bản 1.0.0',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Quản lý Tài sản',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.account_balance_wallet),
                  children: [
                    const Text('Ứng dụng quản lý tài sản cá nhân'),
                    const Text('Phát triển bằng Flutter & Firebase'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

extension on _HomeScreenState {
  Widget _buildMobileBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMobileNavItem(0, Icons.dashboard, 'Tổng quan'),
              _buildMobileNavItem(1, Icons.account_balance_wallet, 'Tài sản'),
              _buildMobileNavItem(2, Icons.receipt_long, 'Giao dịch'),
              _buildMobileNavItem(3, Icons.category, 'Danh mục'),
              _buildMobileNavItem(4, Icons.person, 'Cá nhân'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Tổng quan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Tài sản',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Giao dịch',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Danh mục',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Cá nhân',
        ),
      ],
    );
  }

  Widget _buildMobileNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}