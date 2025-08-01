import 'package:flutter/material.dart';
import '../../domain/entities/asset_type.dart';
import '../../domain/usecases/get_assets_usecase.dart';

class AssetFilterBottomSheet extends StatefulWidget {
  final AssetType? selectedType;
  final AssetSortBy sortBy;
  final SortOrder sortOrder;
  final Function(AssetType?, AssetSortBy, SortOrder) onApplyFilter;

  const AssetFilterBottomSheet({
    super.key,
    required this.selectedType,
    required this.sortBy,
    required this.sortOrder,
    required this.onApplyFilter,
  });

  @override
  State<AssetFilterBottomSheet> createState() => _AssetFilterBottomSheetState();
}

class _AssetFilterBottomSheetState extends State<AssetFilterBottomSheet> {
  late AssetType? _selectedType;
  late AssetSortBy _sortBy;
  late SortOrder _sortOrder;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _sortBy = widget.sortBy;
    _sortOrder = widget.sortOrder;
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

  String _getSortByDisplayName(AssetSortBy sortBy) {
    switch (sortBy) {
      case AssetSortBy.name:
        return 'Tên tài sản';
      case AssetSortBy.balance:
        return 'Số dư';
      case AssetSortBy.type:
        return 'Loại tài sản';
      case AssetSortBy.createdAt:
        return 'Ngày tạo';
      case AssetSortBy.updatedAt:
        return 'Cập nhật lần cuối';
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _sortBy = AssetSortBy.updatedAt;
      _sortOrder = SortOrder.descending;
    });
  }

  void _applyFilters() {
    widget.onApplyFilter(_selectedType, _sortBy, _sortOrder);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Lọc và sắp xếp',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filter by Type
          const Text(
            'Lọc theo loại tài sản',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // All Types Option
          RadioListTile<AssetType?>(
            title: const Row(
              children: [
                Icon(Icons.all_inclusive, size: 20),
                SizedBox(width: 12),
                Text('Tất cả'),
              ],
            ),
            value: null,
            groupValue: _selectedType,
            onChanged: (value) {
              setState(() {
                _selectedType = value;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),
          
          // Asset Type Options
          ...AssetType.values.map((type) => RadioListTile<AssetType?>(
                title: Row(
                  children: [
                    Icon(_getAssetIcon(type), size: 20),
                    const SizedBox(width: 12),
                    Text(type.displayName),
                  ],
                ),
                value: type,
                groupValue: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                contentPadding: EdgeInsets.zero,
              )),

          const SizedBox(height: 24),

          // Sort By
          const Text(
            'Sắp xếp theo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          DropdownButtonFormField<AssetSortBy>(
            value: _sortBy,
            onChanged: (AssetSortBy? newValue) {
              if (newValue != null) {
                setState(() {
                  _sortBy = newValue;
                });
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: AssetSortBy.values.map((AssetSortBy sortBy) {
              return DropdownMenuItem<AssetSortBy>(
                value: sortBy,
                child: Text(_getSortByDisplayName(sortBy)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Sort Order
          const Text(
            'Thứ tự',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: RadioListTile<SortOrder>(
                  title: const Text('Tăng dần'),
                  value: SortOrder.ascending,
                  groupValue: _sortOrder,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortOrder = value;
                      });
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<SortOrder>(
                  title: const Text('Giảm dần'),
                  value: SortOrder.descending,
                  groupValue: _sortOrder,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortOrder = value;
                      });
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Xóa bộ lọc'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Áp dụng'),
                ),
              ),
            ],
          ),
          
          // Add bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}