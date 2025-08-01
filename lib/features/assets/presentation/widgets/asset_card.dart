import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/format_utils.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_type.dart';
import '../bloc/asset_bloc.dart';
import '../bloc/asset_state.dart';
import 'deposit_dialog.dart';
import 'transfer_dialog.dart';

class AssetCard extends StatelessWidget {
  final Asset asset;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AssetCard({
    super.key,
    required this.asset,
    required this.onTap,
    required this.onDelete,
  });

  String _formatCurrency(double amount) {
    return FormatUtils.formatCurrency(amount);
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

  Color _getAssetColor(AssetType type) {
    switch (type) {
      case AssetType.paymentAccount:
        return Colors.blue;
      case AssetType.savingsAccount:
        return Colors.green;
      case AssetType.gold:
        return Colors.amber;
      case AssetType.loan:
        return Colors.orange;
      case AssetType.realEstate:
        return Colors.brown;
      case AssetType.other:
        return Colors.grey;
    }
  }

  void _showQuickDepositDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DepositDialog(asset: asset),
    );
  }

  void _showQuickTransferDialog(BuildContext context) {
    final currentState = context.read<AssetBloc>().state;
    if (currentState is AssetLoaded) {
      showDialog(
        context: context,
        builder: (context) => TransferDialog(
          fromAsset: asset,
          availableAssets: currentState.assets,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể tải danh sách tài sản'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetColor = _getAssetColor(asset.type);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Asset Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: assetColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getAssetIcon(asset.type),
                  color: assetColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              
              // Asset Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      asset.type.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(asset.balance),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: asset.balance >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Quick deposit button
                  IconButton(
                    onPressed: () => _showQuickDepositDialog(context),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.green,
                    ),
                    tooltip: 'Nộp tiền',
                  ),
                  // Quick transfer button
                  IconButton(
                    onPressed: () => _showQuickTransferDialog(context),
                    icon: const Icon(
                      Icons.swap_horiz,
                      color: Colors.blue,
                    ),
                    tooltip: 'Chuyển tiền',
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa'),
                          ],
                        ),
                      ),
                    ],
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}