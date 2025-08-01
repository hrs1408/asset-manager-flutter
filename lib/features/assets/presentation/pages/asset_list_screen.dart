import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/asset_type.dart';
import '../../domain/usecases/get_assets_usecase.dart';
import '../bloc/asset_bloc.dart';
import '../bloc/asset_event.dart';
import '../bloc/asset_state.dart';
import '../widgets/asset_card.dart';
import '../widgets/asset_filter_bottom_sheet.dart';
import 'add_asset_screen.dart';
import 'asset_detail_screen.dart';

class AssetListScreen extends StatefulWidget {
  final String userId;

  const AssetListScreen({
    super.key,
    required this.userId,
  });

  @override
  State<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends State<AssetListScreen> {
  final TextEditingController _searchController = TextEditingController();
  AssetType? _selectedType;
  AssetSortBy _sortBy = AssetSortBy.updatedAt;
  SortOrder _sortOrder = SortOrder.descending;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAssets() {
    context.read<AssetBloc>().add(
          AssetLoadRequested(
            userId: widget.userId,
            filterByType: _selectedType,
            searchQuery: _searchController.text.trim().isEmpty
                ? null
                : _searchController.text.trim(),
            sortBy: _sortBy,
            sortOrder: _sortOrder,
          ),
        );
  }

  void _onRefresh() {
    context.read<AssetBloc>().add(
          AssetRefreshRequested(userId: widget.userId),
        );
  }

  void _onSearch(String query) {
    context.read<AssetBloc>().add(
          AssetLoadRequested(
            userId: widget.userId,
            filterByType: _selectedType,
            searchQuery: query.trim().isEmpty ? null : query.trim(),
            sortBy: _sortBy,
            sortOrder: _sortOrder,
          ),
        );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AssetFilterBottomSheet(
        selectedType: _selectedType,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
        onApplyFilter: (type, sortBy, sortOrder) {
          setState(() {
            _selectedType = type;
            _sortBy = sortBy;
            _sortOrder = sortOrder;
          });
          _loadAssets();
        },
      ),
    );
  }

  void _navigateToAddAsset() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAssetScreen(userId: widget.userId),
      ),
    ).then((_) => _loadAssets());
  }

  void _navigateToAssetDetail(String assetId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetDetailScreen(assetId: assetId),
      ),
    ).then((_) => _loadAssets());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài sản của tôi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm tài sản...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Asset List
          Expanded(
            child: BlocConsumer<AssetBloc, AssetState>(
              listener: (context, state) {
                if (state is AssetError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is AssetOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AssetLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is AssetEmpty) {
                  return _buildEmptyState();
                } else if (state is AssetLoaded ||
                    state is AssetRefreshing ||
                    state is AssetOperationLoading) {
                  final assets = state is AssetLoaded
                      ? state.assets
                      : state is AssetRefreshing
                          ? state.assets
                          : (state as AssetOperationLoading).assets;

                  return RefreshIndicator(
                    onRefresh: () async => _onRefresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: assets.length,
                      itemBuilder: (context, index) {
                        final asset = assets[index];
                        return AssetCard(
                          asset: asset,
                          onTap: () => _navigateToAssetDetail(asset.id),
                          onDelete: () => _showDeleteConfirmation(asset.id),
                        );
                      },
                    ),
                  );
                } else if (state is AssetError) {
                  return _buildErrorState(state.message);
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAsset,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có tài sản nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm tài sản đầu tiên của bạn',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddAsset,
            icon: const Icon(Icons.add),
            label: const Text('Thêm tài sản'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
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
            onPressed: _loadAssets,
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

  void _showDeleteConfirmation(String assetId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tài sản này? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AssetBloc>().add(
                    AssetDeleteRequested(assetId: assetId),
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