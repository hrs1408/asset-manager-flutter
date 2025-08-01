import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../assets/domain/entities/asset.dart';
import '../../../assets/domain/entities/asset_type.dart';
import '../../../assets/presentation/bloc/asset_bloc.dart';
import '../../../assets/presentation/bloc/asset_state.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/entities/deposit_source.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_state.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Transaction icon
              _buildTransactionIcon(),
              const SizedBox(width: 16),
              
              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Transaction title and asset name
                    Row(
                      children: [
                        Expanded(
                          child: _buildTransactionTitle(),
                        ),
                        _buildAssetName(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Transaction subtitle
                    _buildTransactionSubtitle(),
                    
                    const SizedBox(height: 4),
                    
                    // Date
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(transaction.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildAmountText(),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionIcon() {
    IconData iconData;
    Color backgroundColor;
    Color iconColor;
    
    switch (transaction.type) {
      case TransactionType.expense:
        iconData = Icons.remove_circle_outline;
        backgroundColor = Colors.red.withOpacity(0.1);
        iconColor = Colors.red;
        break;
      case TransactionType.deposit:
        iconData = Icons.add_circle_outline;
        backgroundColor = Colors.green.withOpacity(0.1);
        iconColor = Colors.green;
        break;
      case TransactionType.transfer:
        iconData = Icons.swap_horiz;
        backgroundColor = Colors.blue.withOpacity(0.1);
        iconColor = Colors.blue;
        break;
    }
    
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildTransactionTitle() {
    switch (transaction.type) {
      case TransactionType.expense:
        return _buildCategoryName();
      case TransactionType.deposit:
        return Text(
          transaction.type.displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      case TransactionType.transfer:
        return Text(
          transaction.type.displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
    }
  }

  Widget _buildTransactionSubtitle() {
    switch (transaction.type) {
      case TransactionType.expense:
        // Hiển thị description cho chi tiêu
        if (transaction.description.isNotEmpty && 
            transaction.description != 'Không có ghi chú') {
          return Text(
            transaction.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }
        return const SizedBox.shrink();
        
      case TransactionType.deposit:
        // Hiển thị nguồn nộp tiền
        if (transaction.depositSource != null) {
          return Text(
            'Từ ${transaction.depositSource!.displayName}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }
        return const SizedBox.shrink();
        
      case TransactionType.transfer:
        // Hiển thị thông tin chuyển tiền
        if (transaction.toAssetId != null) {
          return BlocBuilder<AssetBloc, AssetState>(
            builder: (context, state) {
              if (state is AssetLoaded) {
                final toAsset = state.assets.firstWhere(
                  (ast) => ast.id == transaction.toAssetId,
                  orElse: () => Asset(
                    id: '',
                    userId: '',
                    name: 'Không xác định',
                    type: AssetType.other,
                    balance: 0,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  ),
                );
                
                if (transaction.amount > 0) {
                  // Giao dịch nhận tiền
                  return Text(
                    'Nhận từ ${toAsset.name}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                } else {
                  // Giao dịch chuyển tiền đi
                  return Text(
                    'Chuyển đến ${toAsset.name}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }
              }
              return const SizedBox.shrink();
            },
          );
        }
        return const SizedBox.shrink();
    }
  }

  Widget _buildAmountText() {
    String prefix;
    Color color;
    
    switch (transaction.type) {
      case TransactionType.expense:
        prefix = '-';
        color = Colors.red;
        break;
      case TransactionType.deposit:
        prefix = '+';
        color = Colors.green;
        break;
      case TransactionType.transfer:
        if (transaction.amount > 0) {
          prefix = '+';
          color = Colors.green;
        } else {
          prefix = '';
          color = Colors.red;
        }
        break;
    }
    
    return Text(
      '$prefix${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.amount.abs())}',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  Widget _buildCategoryName() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoaded) {
          final category = state.categories.firstWhere(
            (cat) => cat.id == transaction.categoryId,
            orElse: () => ExpenseCategory(
              id: '',
              userId: '',
              name: 'Không xác định',
              description: '',
              icon: '❓',
              isDefault: false,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          
          return Text(
            category.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }
        
        return const Text(
          'Đang tải...',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        );
      },
    );
  }

  Widget _buildAssetName() {
    return BlocBuilder<AssetBloc, AssetState>(
      builder: (context, state) {
        if (state is AssetLoaded) {
          final asset = state.assets.firstWhere(
            (ast) => ast.id == transaction.assetId,
            orElse: () => Asset(
              id: '',
              userId: '',
              name: 'Không xác định',
              type: AssetType.other,
              balance: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );
          
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              asset.name,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Đang tải...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}