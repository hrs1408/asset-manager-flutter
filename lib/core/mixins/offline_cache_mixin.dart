import 'package:flutter/foundation.dart';

import '../services/offline_cache_service.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../../features/assets/domain/entities/asset.dart';
import '../../features/expenses/domain/entities/expense_category.dart';
import '../../features/expenses/domain/entities/transaction.dart';

/// Mixin để thêm offline caching cho repositories
mixin OfflineCacheMixin {
  final OfflineCacheService _cacheService = OfflineCacheService.instance;
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  final SyncService _syncService = SyncService.instance;

  /// Kiểm tra xem có nên sử dụng cache không
  bool get shouldUseCache => !_connectivityService.isConnected;

  /// Lấy user ID hiện tại (cần implement trong repository)
  String? getCurrentUserId();

  // ===== ASSETS CACHING =====

  /// Lấy assets với offline support
  Future<List<Asset>?> getAssetsWithCache({
    required Future<List<Asset>> Function() fetchFromServer,
    Duration cacheMaxAge = const Duration(hours: 24),
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) return null;

    try {
      // Nếu có kết nối mạng, lấy từ server
      if (_connectivityService.isConnected) {
        try {
          final assets = await fetchFromServer();
          
          // Cache dữ liệu mới
          await _cacheService.cacheAssets(userId, assets);
          
          if (kDebugMode) {
            print('OfflineCacheMixin: Fetched ${assets.length} assets from server');
          }
          
          return assets;
        } catch (e) {
          if (kDebugMode) {
            print('OfflineCacheMixin: Failed to fetch assets from server, trying cache: $e');
          }
          
          // Nếu lỗi server, thử lấy từ cache
          return await _getCachedAssetsIfValid(userId, cacheMaxAge);
        }
      } else {
        // Không có kết nối, lấy từ cache
        if (kDebugMode) {
          print('OfflineCacheMixin: No connection, using cached assets');
        }
        
        return await _getCachedAssetsIfValid(userId, cacheMaxAge);
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheMixin: Error in getAssetsWithCache: $e');
      }
      return null;
    }
  }

  /// Lấy cached assets nếu còn hợp lệ
  Future<List<Asset>?> _getCachedAssetsIfValid(String userId, Duration maxAge) async {
    final cacheKey = '${userId}_assets';
    final isExpired = await _cacheService.isCacheExpired(cacheKey, maxAge: maxAge);
    
    if (!isExpired) {
      return await _cacheService.getCachedAssets(userId);
    }
    
    return null;
  }

  /// Tạo asset với offline support
  Future<void> createAssetWithCache({
    required Asset asset,
    required Future<void> Function(Asset) createOnServer,
  }) async {
    try {
      if (_connectivityService.isConnected) {
        // Có kết nối, tạo trực tiếp trên server
        await createOnServer(asset);
        
        // Cache asset mới
        await _cacheService.cacheAsset(asset);
        
        if (kDebugMode) {
          print('OfflineCacheMixin: Created asset on server: ${asset.id}');
        }
      } else {
        // Không có kết nối, cache và queue để sync sau
        await _cacheService.cacheAsset(asset);
        
        await _syncService.queueOperation(
          id: asset.id,
          type: 'create',
          entityType: 'asset',
          data: {
            'id': asset.id,
            'userId': asset.userId,
            'name': asset.name,
            'type': asset.type.toString(),
            'balance': asset.balance,
            'createdAt': asset.createdAt.toIso8601String(),
            'updatedAt': asset.updatedAt.toIso8601String(),
          },
        );
        
        if (kDebugMode) {
          print('OfflineCacheMixin: Queued asset creation for sync: ${asset.id}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheMixin: Error in createAssetWithCache: $e');
      }
      rethrow;
    }
  }

  /// Cập nhật asset với offline support
  Future<void> updateAssetWithCache({
    required Asset asset,
    required Future<void> Function(Asset) updateOnServer,
  }) async {
    try {
      if (_connectivityService.isConnected) {
        // Có kết nối, cập nhật trực tiếp trên server
        await updateOnServer(asset);
        
        // Cache asset đã cập nhật
        await _cacheService.cacheAsset(asset);
        
        if (kDebugMode) {
          print('OfflineCacheMixin: Updated asset on server: ${asset.id}');
        }
      } else {
        // Không có kết nối, cache và queue để sync sau
        await _cacheService.cacheAsset(asset);
        
        await _syncService.queueOperation(
          id: asset.id,
          type: 'update',
          entityType: 'asset',
          data: {
            'id': asset.id,
            'userId': asset.userId,
            'name': asset.name,
            'type': asset.type.toString(),
            'balance': asset.balance,
            'createdAt': asset.createdAt.toIso8601String(),
            'updatedAt': asset.updatedAt.toIso8601String(),
          },
        );
        
        if (kDebugMode) {
          print('OfflineCacheMixin: Queued asset update for sync: ${asset.id}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheMixin: Error in updateAssetWithCache: $e');
      }
      rethrow;
    }
  }

  // ===== CATEGORIES CACHING =====

  /// Lấy categories với offline support
  Future<List<ExpenseCategory>?> getCategoriesWithCache({
    required Future<List<ExpenseCategory>> Function() fetchFromServer,
    Duration cacheMaxAge = const Duration(hours: 24),
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) return null;

    try {
      if (_connectivityService.isConnected) {
        try {
          final categories = await fetchFromServer();
          await _cacheService.cacheCategories(userId, categories);
          
          if (kDebugMode) {
            print('OfflineCacheMixin: Fetched ${categories.length} categories from server');
          }
          
          return categories;
        } catch (e) {
          if (kDebugMode) {
            print('OfflineCacheMixin: Failed to fetch categories from server, trying cache: $e');
          }
          
          return await _getCachedCategoriesIfValid(userId, cacheMaxAge);
        }
      } else {
        if (kDebugMode) {
          print('OfflineCacheMixin: No connection, using cached categories');
        }
        
        return await _getCachedCategoriesIfValid(userId, cacheMaxAge);
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheMixin: Error in getCategoriesWithCache: $e');
      }
      return null;
    }
  }

  /// Lấy cached categories nếu còn hợp lệ
  Future<List<ExpenseCategory>?> _getCachedCategoriesIfValid(String userId, Duration maxAge) async {
    final cacheKey = '${userId}_categories';
    final isExpired = await _cacheService.isCacheExpired(cacheKey, maxAge: maxAge);
    
    if (!isExpired) {
      return await _cacheService.getCachedCategories(userId);
    }
    
    return null;
  }

  // ===== TRANSACTIONS CACHING =====

  /// Lấy transactions với offline support
  Future<List<Transaction>?> getTransactionsWithCache({
    required Future<List<Transaction>> Function() fetchFromServer,
    Duration cacheMaxAge = const Duration(hours: 1),
  }) async {
    final userId = getCurrentUserId();
    if (userId == null) return null;

    try {
      if (_connectivityService.isConnected) {
        try {
          final transactions = await fetchFromServer();
          await _cacheService.cacheTransactions(userId, transactions);
          
          if (kDebugMode) {
            print('OfflineCacheMixin: Fetched ${transactions.length} transactions from server');
          }
          
          return transactions;
        } catch (e) {
          if (kDebugMode) {
            print('OfflineCacheMixin: Failed to fetch transactions from server, trying cache: $e');
          }
          
          return await _getCachedTransactionsIfValid(userId, cacheMaxAge);
        }
      } else {
        if (kDebugMode) {
          print('OfflineCacheMixin: No connection, using cached transactions');
        }
        
        return await _getCachedTransactionsIfValid(userId, cacheMaxAge);
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheMixin: Error in getTransactionsWithCache: $e');
      }
      return null;
    }
  }

  /// Lấy cached transactions nếu còn hợp lệ
  Future<List<Transaction>?> _getCachedTransactionsIfValid(String userId, Duration maxAge) async {
    final cacheKey = '${userId}_transactions';
    final isExpired = await _cacheService.isCacheExpired(cacheKey, maxAge: maxAge);
    
    if (!isExpired) {
      return await _cacheService.getCachedTransactions(userId);
    }
    
    return null;
  }

  /// Tạo transaction với offline support
  Future<void> createTransactionWithCache({
    required Transaction transaction,
    required Future<void> Function(Transaction) createOnServer,
  }) async {
    try {
      if (_connectivityService.isConnected) {
        await createOnServer(transaction);
        
        if (kDebugMode) {
          print('OfflineCacheMixin: Created transaction on server: ${transaction.id}');
        }
      } else {
        await _syncService.queueOperation(
          id: transaction.id,
          type: 'create',
          entityType: 'transaction',
          data: {
            'id': transaction.id,
            'userId': transaction.userId,
            'assetId': transaction.assetId,
            'categoryId': transaction.categoryId,
            'amount': transaction.amount,
            'description': transaction.description,
            'date': transaction.date.toIso8601String(),
            'createdAt': transaction.createdAt.toIso8601String(),
          },
        );
        
        if (kDebugMode) {
          print('OfflineCacheMixin: Queued transaction creation for sync: ${transaction.id}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheMixin: Error in createTransactionWithCache: $e');
      }
      rethrow;
    }
  }

  /// Xóa cache khi user logout
  Future<void> clearUserCache() async {
    final userId = getCurrentUserId();
    if (userId != null) {
      await _cacheService.clearUserCache(userId);
      
      if (kDebugMode) {
        print('OfflineCacheMixin: Cleared cache for user $userId');
      }
    }
  }
}