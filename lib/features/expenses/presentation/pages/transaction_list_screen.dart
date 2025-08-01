import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../../assets/presentation/bloc/asset_bloc.dart';
import '../../../assets/presentation/bloc/asset_event.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/transaction_filter_bottom_sheet.dart';
import '../widgets/transaction_item.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TransactionBloc>().add(LoadTransactions(userId: authState.user.id));
      context.read<AssetBloc>().add(AssetLoadRequested(userId: authState.user.id));
      context.read<CategoryBloc>().add(LoadCategories(authState.user.id));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSearching ? _buildSearchAppBar() : _buildNormalAppBar(),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTransaction,
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar() {
    return AppBar(
      title: const Text('Lịch sử Giao dịch'),
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterBottomSheet,
        ),
      ],
    );
  }

  PreferredSizeWidget _buildSearchAppBar() {
    return AppBar(
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
          });
          context.read<TransactionBloc>().add(const SearchTransactions(query: ''));
        },
      ),
      title: TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Tìm kiếm giao dịch...',
          hintStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        onChanged: (query) {
          context.read<TransactionBloc>().add(SearchTransactions(query: query));
        },
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              context.read<TransactionBloc>().add(const SearchTransactions(query: ''));
            },
          ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is! TransactionLoaded) {
          return const SizedBox.shrink();
        }

        final hasFilters = state.isFiltered || 
                          (state.searchQuery != null && state.searchQuery!.isNotEmpty);

        if (!hasFilters) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (state.currentFilter?.assetId != null)
                _buildFilterChip(
                  'Tài sản',
                  () => _clearAssetFilter(),
                ),
              if (state.currentFilter?.categoryId != null)
                _buildFilterChip(
                  'Danh mục',
                  () => _clearCategoryFilter(),
                ),
              if (state.currentFilter?.startDate != null && state.currentFilter?.endDate != null)
                _buildFilterChip(
                  'Thời gian',
                  () => _clearDateFilter(),
                ),
              if (state.searchQuery != null && state.searchQuery!.isNotEmpty)
                _buildFilterChip(
                  'Tìm kiếm: "${state.searchQuery}"',
                  () => _clearSearch(),
                ),
              const Spacer(),
              if (hasFilters)
                TextButton(
                  onPressed: () {
                    context.read<TransactionBloc>().add(const ClearTransactionFilters());
                    _searchController.clear();
                    setState(() {
                      _isSearching = false;
                    });
                  },
                  child: const Text('Xóa tất cả'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
        backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
        deleteIconColor: AppConstants.primaryColor,
      ),
    );
  }

  Widget _buildTransactionList() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is TransactionError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${state.message}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final authState = context.read<AuthBloc>().state;
                    if (authState is AuthAuthenticated) {
                      context.read<TransactionBloc>().add(
                        RefreshTransactions(userId: authState.user.id),
                      );
                    }
                  },
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state is TransactionLoaded) {
          final transactions = state.filteredTransactions;

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.isFiltered || (state.searchQuery?.isNotEmpty ?? false)
                        ? 'Không tìm thấy giao dịch nào'
                        : 'Chưa có giao dịch nào',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.isFiltered || (state.searchQuery?.isNotEmpty ?? false)
                        ? 'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm'
                        : 'Nhấn nút + để thêm giao dịch đầu tiên',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthBloc>().state;
              if (authState is AuthAuthenticated) {
                context.read<TransactionBloc>().add(
                  RefreshTransactions(userId: authState.user.id),
                );
              }
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return TransactionItem(
                  transaction: transaction,
                  onTap: () => _showTransactionDetails(transaction),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TransactionFilterBottomSheet(
        onFilterApplied: (filter) {
          context.read<TransactionBloc>().add(FilterTransactions(filter: filter));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _navigateToAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => sl<TransactionBloc>(),
          child: const AddTransactionScreen(),
        ),
      ),
    );

    if (result == true) {
      // Refresh the transaction list
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<TransactionBloc>().add(
          RefreshTransactions(userId: authState.user.id),
        );
      }
    }
  }

  void _showTransactionDetails(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildTransactionDetailsBottomSheet(transaction),
    );
  }

  Widget _buildTransactionDetailsBottomSheet(Transaction transaction) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const Text(
            'Chi tiết Giao dịch',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Transaction details
          _buildDetailRow('Số tiền', 
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(transaction.amount),
            isAmount: true,
          ),
          _buildDetailRow('Ngày giao dịch', 
            DateFormat('dd/MM/yyyy').format(transaction.date),
          ),
          _buildDetailRow('Ghi chú', transaction.description),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to edit transaction screen
                  },
                  child: const Text('Chỉnh sửa'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(transaction);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Xóa'),
                ),
              ),
            ],
          ),
          
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isAmount ? FontWeight.w600 : FontWeight.normal,
                color: isAmount ? Colors.red : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TransactionBloc>().add(
                DeleteTransaction(transactionId: transaction.id),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _clearAssetFilter() {
    final state = context.read<TransactionBloc>().state;
    if (state is TransactionLoaded && state.currentFilter != null) {
      final newFilter = TransactionFilter(
        categoryId: state.currentFilter!.categoryId,
        startDate: state.currentFilter!.startDate,
        endDate: state.currentFilter!.endDate,
        limit: state.currentFilter!.limit,
        offset: state.currentFilter!.offset,
      );
      context.read<TransactionBloc>().add(FilterTransactions(filter: newFilter));
    }
  }

  void _clearCategoryFilter() {
    final state = context.read<TransactionBloc>().state;
    if (state is TransactionLoaded && state.currentFilter != null) {
      final newFilter = TransactionFilter(
        assetId: state.currentFilter!.assetId,
        startDate: state.currentFilter!.startDate,
        endDate: state.currentFilter!.endDate,
        limit: state.currentFilter!.limit,
        offset: state.currentFilter!.offset,
      );
      context.read<TransactionBloc>().add(FilterTransactions(filter: newFilter));
    }
  }

  void _clearDateFilter() {
    final state = context.read<TransactionBloc>().state;
    if (state is TransactionLoaded && state.currentFilter != null) {
      final newFilter = TransactionFilter(
        assetId: state.currentFilter!.assetId,
        categoryId: state.currentFilter!.categoryId,
        limit: state.currentFilter!.limit,
        offset: state.currentFilter!.offset,
      );
      context.read<TransactionBloc>().add(FilterTransactions(filter: newFilter));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<TransactionBloc>().add(const SearchTransactions(query: ''));
  }
}