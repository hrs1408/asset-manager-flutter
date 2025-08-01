import 'dart:async';
import 'package:flutter/foundation.dart';

import '../usecases/usecase.dart';
import '../../features/assets/domain/repositories/asset_repository.dart';
import '../../features/expenses/domain/repositories/category_repository.dart';
import '../../features/expenses/domain/repositories/transaction_repository.dart';
import '../../features/assets/domain/entities/asset.dart';
import '../../features/expenses/domain/entities/expense_category.dart';
import '../../features/expenses/domain/entities/transaction.dart';
import '../../features/assets/data/models/asset_model.dart';
import '../../features/expenses/data/models/expense_category_model.dart';
import '../../features/expenses/data/models/transaction_model.dart';
import 'connectivity_service.dart';
import 'offline_cache_service.dart';
import '../error/error_handler.dart';

/// Service để đồng bộ dữ liệu khi có kết nối mạng
class SyncService {
  static SyncService? _instance;
  static SyncService get instance => _instance ??= SyncService._();
  
  SyncService._();

  final ConnectivityService _connectivityService = ConnectivityService.instance;
  final OfflineCacheService _cacheService = OfflineCacheService.instance;
  final ErrorHandler _errorHandler = ErrorHandler.instance;

  // Repositories sẽ được inject từ bên ngoài
  AssetRepository? _assetRepository;
  CategoryRepository? _categoryRepository;
  TransactionRepository? _transactionRepository;

  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;
  String? _currentUserId;

  /// Khởi tạo sync service
  void initialize({
    required AssetRepository assetRepository,
    required CategoryRepository categoryRepository,
    required TransactionRepository transactionRepository,
    required String userId,
  }) {
    _assetRepository = assetRepository;
    _categoryRepository = categoryRepository;
    _transactionRepository = transactionRepository;
    _currentUserId = userId;

    // Lắng nghe thay đổi kết nối mạng
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isConnected) {
        if (isConnected && !_isSyncing) {
          _performSync();
        }
      },
    );

    if (kDebugMode) {
      print('SyncService: Initialized for user $userId');
    }
  }

  /// Dừng sync service
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Thực hiện đồng bộ dữ liệu
  Future<void> _performSync() async {
    if (_isSyncing || !_connectivityService.isConnected || _currentUserId == null) {
      return;
    }

    _isSyncing = true;

    try {
      if (kDebugMode) {
        print('SyncService: Starting sync for user $_currentUserId');
      }

      // 1. Sync pending operations trước
      await _syncPendingOperations();

      // 2. Sync dữ liệu mới từ server
      await _syncFromServer();

      if (kDebugMode) {
        print('SyncService: Sync completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('SyncService: Sync failed: $e');
      }
      _errorHandler.logError(e, context: {'operation': 'sync'});
    } finally {
      _isSyncing = false;
    }
  }

  /// Đồng bộ các operations đang chờ
  Future<void> _syncPendingOperations() async {
    try {
      final pendingOperations = await _cacheService.getPendingSyncOperations();
      
      if (pendingOperations.isEmpty) {
        if (kDebugMode) {
          print('SyncService: No pending operations to sync');
        }
        return;
      }

      if (kDebugMode) {
        print('SyncService: Syncing ${pendingOperations.length} pending operations');
      }

      for (final operation in pendingOperations) {
        try {
          await _executePendingOperation(operation);
          
          // Xóa operation đã sync thành công
          final operationKey = '${operation.type}_${operation.id}_${operation.timestamp.millisecondsSinceEpoch}';
          await _cacheService.removePendingSyncOperation(operationKey);
          
          if (kDebugMode) {
            print('SyncService: Successfully synced operation ${operation.type} for ${operation.entityType}');
          }
        } catch (e) {
          if (kDebugMode) {
            print('SyncService: Failed to sync operation ${operation.type}: $e');
          }
          // Giữ lại operation để thử lại sau
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('SyncService: Failed to sync pending operations: $e');
      }
    }
  }

  /// Thực hiện một pending operation
  Future<void> _executePendingOperation(PendingSyncOperation operation) async {
    switch (operation.entityType) {
      case 'asset':
        await _executePendingAssetOperation(operation);
        break;
      case 'category':
        await _executePendingCategoryOperation(operation);
        break;
      case 'transaction':
        await _executePendingTransactionOperation(operation);
        break;
      default:
        throw Exception('Unknown entity type: ${operation.entityType}');
    }
  }

  /// Thực hiện pending asset operation
  Future<void> _executePendingAssetOperation(PendingSyncOperation operation) async {
    final asset = AssetModel.fromJson(operation.data).toEntity();
    
    switch (operation.type) {
      case 'create':
        await _assetRepository?.createAsset(asset);
        break;
      case 'update':
        await _assetRepository?.updateAsset(asset);
        break;
      case 'delete':
        await _assetRepository?.deleteAsset(asset.id);
        break;
    }
  }

  /// Thực hiện pending category operation
  Future<void> _executePendingCategoryOperation(PendingSyncOperation operation) async {
    final category = ExpenseCategoryModel.fromJson(operation.data).toEntity();
    
    switch (operation.type) {
      case 'create':
        await _categoryRepository?.createCategory(category);
        break;
      case 'update':
        await _categoryRepository?.updateCategory(category);
        break;
      case 'delete':
        await _categoryRepository?.deleteCategory(category.id);
        break;
    }
  }

  /// Thực hiện pending transaction operation
  Future<void> _executePendingTransactionOperation(PendingSyncOperation operation) async {
    final transaction = TransactionModel.fromJson(operation.data).toEntity();
    
    switch (operation.type) {
      case 'create':
        await _transactionRepository?.createTransaction(transaction);
        break;
      case 'update':
        await _transactionRepository?.updateTransaction(transaction);
        break;
      case 'delete':
        await _transactionRepository?.deleteTransaction(transaction.id);
        break;
    }
  }

  /// Đồng bộ dữ liệu mới từ server
  Future<void> _syncFromServer() async {
    if (_currentUserId == null) return;

    try {
      // Sync assets
      await _syncAssetsFromServer();
      
      // Sync categories
      await _syncCategoriesFromServer();
      
      // Sync transactions
      await _syncTransactionsFromServer();
      
    } catch (e) {
      if (kDebugMode) {
        print('SyncService: Failed to sync from server: $e');
      }
      rethrow;
    }
  }

  /// Sync assets từ server
  Future<void> _syncAssetsFromServer() async {
    try {
      final assetsResult = await _assetRepository?.getAssets(_currentUserId!);
      assetsResult?.fold(
        (failure) => print('Failed to sync assets: ${failure.message}'),
        (assets) async {
          if (assets.isNotEmpty) {
            await _cacheService.cacheAssets(_currentUserId!, assets);
            
            if (kDebugMode) {
              print('SyncService: Synced ${assets.length} assets from server');
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('SyncService: Failed to sync assets from server: $e');
      }
    }
  }

  /// Sync categories từ server
  Future<void> _syncCategoriesFromServer() async {
    try {
      final categoriesResult = await _categoryRepository?.getCategories(_currentUserId!);
      categoriesResult?.fold(
        (failure) => print('Failed to sync categories: ${failure.message}'),
        (categories) async {
          if (categories.isNotEmpty) {
            await _cacheService.cacheCategories(_currentUserId!, categories);
            
            if (kDebugMode) {
              print('SyncService: Synced ${categories.length} categories from server');
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('SyncService: Failed to sync categories from server: $e');
      }
    }
  }

  /// Sync transactions từ server
  Future<void> _syncTransactionsFromServer() async {
    try {
      final transactionsResult = await _transactionRepository?.getTransactions(_currentUserId!);
      transactionsResult?.fold(
        (failure) => print('Failed to sync transactions: ${failure.message}'),
        (transactions) async {
          if (transactions.isNotEmpty) {
            await _cacheService.cacheTransactions(_currentUserId!, transactions);
            
            if (kDebugMode) {
              print('SyncService: Synced ${transactions.length} transactions from server');
            }
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('SyncService: Failed to sync transactions from server: $e');
      }
    }
  }

  /// Thực hiện sync thủ công
  Future<SyncResult> manualSync() async {
    if (!_connectivityService.isConnected) {
      return SyncResult(
        success: false,
        message: 'Không có kết nối mạng',
        syncedOperations: 0,
      );
    }

    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Đang thực hiện đồng bộ',
        syncedOperations: 0,
      );
    }

    try {
      final pendingOperations = await _cacheService.getPendingSyncOperations();
      final initialCount = pendingOperations.length;
      
      await _performSync();
      
      final remainingOperations = await _cacheService.getPendingSyncOperations();
      final syncedCount = initialCount - remainingOperations.length;
      
      return SyncResult(
        success: true,
        message: 'Đồng bộ thành công',
        syncedOperations: syncedCount,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: 'Lỗi đồng bộ: ${e.toString()}',
        syncedOperations: 0,
      );
    }
  }

  /// Lấy trạng thái sync
  SyncStatus getSyncStatus() {
    final pendingOperationsCount = _cacheService.getPendingSyncOperations().then((ops) => ops.length);
    
    return SyncStatus(
      isConnected: _connectivityService.isConnected,
      isSyncing: _isSyncing,
      pendingOperationsCount: 0, // Sẽ được cập nhật async
    );
  }

  /// Thêm operation vào queue để sync sau
  Future<void> queueOperation({
    required String id,
    required String type,
    required String entityType,
    required Map<String, dynamic> data,
  }) async {
    final operation = PendingSyncOperation(
      id: id,
      type: type,
      entityType: entityType,
      data: data,
      timestamp: DateTime.now(),
    );

    await _cacheService.addPendingSyncOperation(operation);

    // Thử sync ngay nếu có kết nối
    if (_connectivityService.isConnected && !_isSyncing) {
      _performSync();
    }
  }
}

/// Kết quả của quá trình sync
class SyncResult {
  final bool success;
  final String message;
  final int syncedOperations;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedOperations,
  });
}

/// Trạng thái sync hiện tại
class SyncStatus {
  final bool isConnected;
  final bool isSyncing;
  final int pendingOperationsCount;

  SyncStatus({
    required this.isConnected,
    required this.isSyncing,
    required this.pendingOperationsCount,
  });
}