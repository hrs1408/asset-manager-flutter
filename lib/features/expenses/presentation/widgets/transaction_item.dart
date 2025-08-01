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
              // Category icon
              _buildCategoryIcon(),
              const SizedBox(width: 16),
              
              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category name and asset name
                    Row(
                      children: [
                        Expanded(
                          child: _buildCategoryName(),
                        ),
                        _buildAssetName(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    
                    // Description
                    if (transaction.description.isNotEmpty && 
                        transaction.description != 'Không có ghi chú')
                      Text(
                        transaction.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
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
                  Text(
                    '-${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.amount)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
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

  Widget _buildCategoryIcon() {
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
          
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                category.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          );
        }
        
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Icon(
              Icons.category,
              color: Colors.grey,
              size: 24,
            ),
          ),
        );
      },
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