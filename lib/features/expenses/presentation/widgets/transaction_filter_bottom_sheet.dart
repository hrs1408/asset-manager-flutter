import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../assets/domain/entities/asset.dart';
import '../../../assets/presentation/bloc/asset_bloc.dart';
import '../../../assets/presentation/bloc/asset_state.dart';
import '../../domain/entities/expense_category.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_state.dart';

class TransactionFilterBottomSheet extends StatefulWidget {
  final Function(TransactionFilter) onFilterApplied;

  const TransactionFilterBottomSheet({
    super.key,
    required this.onFilterApplied,
  });

  @override
  State<TransactionFilterBottomSheet> createState() => _TransactionFilterBottomSheetState();
}

class _TransactionFilterBottomSheetState extends State<TransactionFilterBottomSheet> {
  Asset? _selectedAsset;
  ExpenseCategory? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          Row(
            children: [
              const Text(
                'Lọc Giao dịch',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFilters,
                child: const Text('Xóa tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Filter options
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAssetFilter(),
                  const SizedBox(height: 16),
                  _buildCategoryFilter(),
                  const SizedBox(height: 16),
                  _buildDateRangeFilter(),
                ],
              ),
            ),
          ),
          
          // Apply button
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Áp dụng Bộ lọc',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lọc theo Tài sản',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: InkWell(
            onTap: _showAssetSelection,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: AppConstants.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedAsset?.name ?? 'Tất cả tài sản',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedAsset != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  if (_selectedAsset != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedAsset = null;
                        });
                      },
                    ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lọc theo Danh mục',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: InkWell(
            onTap: _showCategorySelection,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        _selectedCategory?.icon ?? '📝',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedCategory?.name ?? 'Tất cả danh mục',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedCategory != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  if (_selectedCategory != null)
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _selectedCategory = null;
                        });
                      },
                    ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lọc theo Thời gian',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: () => _selectStartDate(),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Từ ngày',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _startDate != null
                              ? DateFormat('dd/MM/yyyy').format(_startDate!)
                              : 'Chọn ngày',
                          style: TextStyle(
                            fontSize: 14,
                            color: _startDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                child: InkWell(
                  onTap: () => _selectEndDate(),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Đến ngày',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _endDate != null
                              ? DateFormat('dd/MM/yyyy').format(_endDate!)
                              : 'Chọn ngày',
                          style: TextStyle(
                            fontSize: 14,
                            color: _endDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_startDate != null || _endDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                  child: const Text('Xóa thời gian'),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showAssetSelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn Tài sản',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<AssetBloc, AssetState>(
                builder: (context, state) {
                  if (state is AssetLoaded) {
                    return ListView.builder(
                      itemCount: state.assets.length,
                      itemBuilder: (context, index) {
                        final asset = state.assets[index];
                        return ListTile(
                          leading: Icon(
                            _getAssetIcon(asset.type.value),
                            color: AppConstants.primaryColor,
                          ),
                          title: Text(asset.name),
                          subtitle: Text(asset.type.displayName),
                          onTap: () {
                            setState(() {
                              _selectedAsset = asset;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategorySelection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn Danh mục',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<CategoryBloc, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoaded) {
                    return ListView.builder(
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
                        return ListTile(
                          leading: Text(
                            category.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(category.name),
                          subtitle: Text(category.description),
                          onTap: () {
                            setState(() {
                              _selectedCategory = category;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _endDate ?? DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppConstants.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppConstants.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedAsset = null;
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });
  }

  void _applyFilters() {
    final filter = TransactionFilter(
      assetId: _selectedAsset?.id,
      categoryId: _selectedCategory?.id,
      startDate: _startDate,
      endDate: _endDate,
    );
    
    widget.onFilterApplied(filter);
  }

  IconData _getAssetIcon(String assetType) {
    switch (assetType) {
      case 'payment_account':
        return Icons.credit_card;
      case 'savings_account':
        return Icons.savings;
      case 'gold':
        return Icons.diamond;
      case 'loan':
        return Icons.handshake;
      case 'real_estate':
        return Icons.home;
      default:
        return Icons.account_balance_wallet;
    }
  }
}