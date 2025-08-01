import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_type.dart';
import '../bloc/asset_bloc.dart';
import '../bloc/asset_event.dart';
import '../bloc/asset_state.dart';
import 'edit_asset_screen.dart';

class AssetDetailScreen extends StatefulWidget {
  final String assetId;

  const AssetDetailScreen({
    super.key,
    required this.assetId,
  });

  @override
  State<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends State<AssetDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AssetBloc>().add(
          AssetGetByIdRequested(assetId: widget.assetId),
        );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    return '${formatter.format(amount)} VNĐ';
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');
    return formatter.format(date);
  }

  void _navigateToEdit(Asset asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditAssetScreen(asset: asset),
      ),
    ).then((_) {
      // Reload asset detail after edit
      if (mounted) {
        context.read<AssetBloc>().add(
              AssetGetByIdRequested(assetId: widget.assetId),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết tài sản'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<AssetBloc, AssetState>(
        listener: (context, state) {
          if (state is AssetError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AssetDetailLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is AssetDetailLoaded) {
            return _buildAssetDetail(state.asset);
          } else if (state is AssetError) {
            return _buildErrorState(state.message);
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAssetDetail(Asset asset) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  _getAssetIcon(asset.type),
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                Text(
                  asset.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  asset.type.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatCurrency(asset.balance),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details Section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thông tin chi tiết',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Asset Type
                _buildDetailRow(
                  icon: Icons.category,
                  label: 'Loại tài sản',
                  value: asset.type.displayName,
                ),
                const SizedBox(height: 16),

                // Balance
                _buildDetailRow(
                  icon: Icons.account_balance_wallet,
                  label: 'Số dư hiện tại',
                  value: _formatCurrency(asset.balance),
                ),
                const SizedBox(height: 16),

                // Created Date
                _buildDetailRow(
                  icon: Icons.calendar_today,
                  label: 'Ngày tạo',
                  value: _formatDate(asset.createdAt),
                ),
                const SizedBox(height: 16),

                // Updated Date
                _buildDetailRow(
                  icon: Icons.update,
                  label: 'Cập nhật lần cuối',
                  value: _formatDate(asset.updatedAt),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToEdit(asset),
                        icon: const Icon(Icons.edit),
                        label: const Text('Chỉnh sửa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showDeleteConfirmation(asset),
                        icon: const Icon(Icons.delete),
                        label: const Text('Xóa'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AssetBloc>().add(
                    AssetGetByIdRequested(assetId: widget.assetId),
                  );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAssetIcon(AssetType type) {
    switch (type) {
      case AssetType.paymentAccount:
        return Icons.credit_card;
      case AssetType.savingsAccount:
        return Icons.savings;
      case AssetType.gold:
        return Icons.diamond;
      case AssetType.loan:
        return Icons.handshake;
      case AssetType.realEstate:
        return Icons.home;
      case AssetType.other:
        return Icons.account_balance_wallet;
    }
  }

  void _showDeleteConfirmation(Asset asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa tài sản "${asset.name}"? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
              context.read<AssetBloc>().add(
                    AssetDeleteRequested(assetId: asset.id),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}