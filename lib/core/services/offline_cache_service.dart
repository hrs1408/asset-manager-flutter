import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../features/assets/domain/entities/asset.dart';
import '../../features/expenses/domain/entities/expense_category.dart';
import '../../features/expenses/domain/entities/transaction.dart';
import '../../features/assets/data/models/asset_model.dart';
import '../../features/expenses/data/models/expense_category_model.dart';
import '../../features/expenses/data/models/transaction_model.dart';
import 'connectivity_service.dart';

/// Service để cache dữ liệu offline với Hive
class OfflineCacheService {
  static OfflineCacheService? _instance;
  static OfflineCacheService get instance => _instance ??= OfflineCacheService._();
  
  OfflineCacheService._();

  // Box names
  static const String _assetsBoxName = 'assets_cache';
  static const String _categoriesBoxName = 'categories_cache';
  static const String _transactionsBoxName = 'transactions_cache';
  static const String _metadataBoxName = 'metadata_cache';
  static const String _pendingSyncBoxName = 'pending_sync';

  // Boxes
  Box<String>? _assetsBox;
  Box<String>? _categoriesBox;
  Box<String>? _transactionsBox;
  Box<String>? _metadataBox;
  Box<String>? _pendingSyncBox;

  final ConnectivityService _connectivityService = ConnectivityService.instance;

  /// Khởi tạo Hive và các boxes
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      
      // Mở các boxes
      _assetsBox = await Hive.openBox<String>(_assetsBoxName);
      _categoriesBox = await Hive.openBox<String>(_categoriesBoxName);
      _transactionsBox = await Hive.openBox<String>(_transactionsBoxName);
      _metadataBox = await Hive.openBox<String>(_metadataBoxName);
      _pendingSyncBox = await Hive.openBox<String>(_pendingSyncBoxName);

      if (kDebugMode) {
        print('OfflineCacheService: Initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Đóng tất cả boxes
  Future<void> dispose() async {
    await _assetsBox?.close();
    await _categoriesBox?.close();
    await _transactionsBox?.close();
    await _metadataBox?.close();
    await _pendingSyncBox?.close();
  }

  // ===== ASSETS CACHING =====

  /// Cache danh sách assets
  Future<void> cacheAssets(String userId, List<Asset> assets) async {
    try {
      final assetsJson = assets.map((asset) => 
        AssetModel.fromEntity(asset).toJson()).toList();
      
      await _assetsBox?.put('${userId}_assets', jsonEncode(assetsJson));
      await _updateCacheMetadata('${userId}_assets');
      
      if (kDebugMode) {
        print('OfflineCacheService: Cached ${assets.length} assets for user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to cache assets: $e');
      }
    }
  }

  /// Lấy cached assets
  Future<List<Asset>?> getCachedAssets(String userId) async {
    try {
      final cachedData = _assetsBox?.get('${userId}_assets');
      if (cachedData == null) return null;

      final List<dynamic> assetsJson = jsonDecode(cachedData);
      final assets = assetsJson
          .map((json) => AssetModel.fromJson(json).toEntity())
          .toList();

      if (kDebugMode) {
        print('OfflineCacheService: Retrieved ${assets.length} cached assets for user $userId');
      }

      return assets;
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to get cached assets: $e');
      }
      return null;
    }
  }

  /// Cache single asset
  Future<void> cacheAsset(Asset asset) async {
    try {
      final assetJson = AssetModel.fromEntity(asset).toJson();
      await _assetsBox?.put('asset_${asset.id}', jsonEncode(assetJson));
      await _updateCacheMetadata('asset_${asset.id}');
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to cache asset: $e');
      }
    }
  }

  /// Lấy cached asset by ID
  Future<Asset?> getCachedAsset(String assetId) async {
    try {
      final cachedData = _assetsBox?.get('asset_$assetId');
      if (cachedData == null) return null;

      final assetJson = jsonDecode(cachedData);
      return AssetModel.fromJson(assetJson).toEntity();
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to get cached asset: $e');
      }
      return null;
    }
  }

  // ===== CATEGORIES CACHING =====

  /// Cache danh sách categories
  Future<void> cacheCategories(String userId, List<ExpenseCategory> categories) async {
    try {
      final categoriesJson = categories.map((category) => 
        ExpenseCategoryModel.fromEntity(category).toJson()).toList();
      
      await _categoriesBox?.put('${userId}_categories', jsonEncode(categoriesJson));
      await _updateCacheMetadata('${userId}_categories');
      
      if (kDebugMode) {
        print('OfflineCacheService: Cached ${categories.length} categories for user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to cache categories: $e');
      }
    }
  }

  /// Lấy cached categories
  Future<List<ExpenseCategory>?> getCachedCategories(String userId) async {
    try {
      final cachedData = _categoriesBox?.get('${userId}_categories');
      if (cachedData == null) return null;

      final List<dynamic> categoriesJson = jsonDecode(cachedData);
      final categories = categoriesJson
          .map((json) => ExpenseCategoryModel.fromJson(json).toEntity())
          .toList();

      if (kDebugMode) {
        print('OfflineCacheService: Retrieved ${categories.length} cached categories for user $userId');
      }

      return categories;
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to get cached categories: $e');
      }
      return null;
    }
  }

  // ===== TRANSACTIONS CACHING =====

  /// Cache danh sách transactions
  Future<void> cacheTransactions(String userId, List<Transaction> transactions) async {
    try {
      final transactionsJson = transactions.map((transaction) => 
        TransactionModel.fromEntity(transaction).toJson()).toList();
      
      await _transactionsBox?.put('${userId}_transactions', jsonEncode(transactionsJson));
      await _updateCacheMetadata('${userId}_transactions');
      
      if (kDebugMode) {
        print('OfflineCacheService: Cached ${transactions.length} transactions for user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to cache transactions: $e');
      }
    }
  }

  /// Lấy cached transactions
  Future<List<Transaction>?> getCachedTransactions(String userId) async {
    try {
      final cachedData = _transactionsBox?.get('${userId}_transactions');
      if (cachedData == null) return null;

      final List<dynamic> transactionsJson = jsonDecode(cachedData);
      final transactions = transactionsJson
          .map((json) => TransactionModel.fromJson(json).toEntity())
          .toList();

      if (kDebugMode) {
        print('OfflineCacheService: Retrieved ${transactions.length} cached transactions for user $userId');
      }

      return transactions;
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to get cached transactions: $e');
      }
      return null;
    }
  }

  // ===== PENDING SYNC OPERATIONS =====

  /// Thêm operation vào pending sync queue
  Future<void> addPendingSyncOperation(PendingSyncOperation operation) async {
    try {
      final operationJson = operation.toJson();
      final key = '${operation.type}_${operation.id}_${DateTime.now().millisecondsSinceEpoch}';
      
      await _pendingSyncBox?.put(key, jsonEncode(operationJson));
      
      if (kDebugMode) {
        print('OfflineCacheService: Added pending sync operation: ${operation.type}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to add pending sync operation: $e');
      }
    }
  }

  /// Lấy tất cả pending sync operations
  Future<List<PendingSyncOperation>> getPendingSyncOperations() async {
    try {
      final operations = <PendingSyncOperation>[];
      
      for (final key in _pendingSyncBox?.keys ?? <String>[]) {
        final operationData = _pendingSyncBox?.get(key);
        if (operationData != null) {
          final operationJson = jsonDecode(operationData);
          operations.add(PendingSyncOperation.fromJson(operationJson));
        }
      }
      
      if (kDebugMode) {
        print('OfflineCacheService: Retrieved ${operations.length} pending sync operations');
      }
      
      return operations;
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to get pending sync operations: $e');
      }
      return [];
    }
  }

  /// Xóa pending sync operation
  Future<void> removePendingSyncOperation(String operationKey) async {
    try {
      await _pendingSyncBox?.delete(operationKey);
      
      if (kDebugMode) {
        print('OfflineCacheService: Removed pending sync operation: $operationKey');
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to remove pending sync operation: $e');
      }
    }
  }

  /// Xóa tất cả pending sync operations
  Future<void> clearPendingSyncOperations() async {
    try {
      await _pendingSyncBox?.clear();
      
      if (kDebugMode) {
        print('OfflineCacheService: Cleared all pending sync operations');
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to clear pending sync operations: $e');
      }
    }
  }

  // ===== CACHE MANAGEMENT =====

  /// Cập nhật metadata của cache
  Future<void> _updateCacheMetadata(String key) async {
    try {
      final metadata = {
        'lastUpdated': DateTime.now().toIso8601String(),
        'version': '1.0',
      };
      
      await _metadataBox?.put('${key}_metadata', jsonEncode(metadata));
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to update cache metadata: $e');
      }
    }
  }

  /// Kiểm tra cache có hết hạn không
  Future<bool> isCacheExpired(String key, {Duration maxAge = const Duration(hours: 24)}) async {
    try {
      final metadataData = _metadataBox?.get('${key}_metadata');
      if (metadataData == null) return true;

      final metadata = jsonDecode(metadataData);
      final lastUpdated = DateTime.parse(metadata['lastUpdated']);
      
      return DateTime.now().difference(lastUpdated) > maxAge;
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to check cache expiration: $e');
      }
      return true;
    }
  }

  /// Xóa cache của user
  Future<void> clearUserCache(String userId) async {
    try {
      await _assetsBox?.delete('${userId}_assets');
      await _categoriesBox?.delete('${userId}_categories');
      await _transactionsBox?.delete('${userId}_transactions');
      
      // Xóa metadata
      await _metadataBox?.delete('${userId}_assets_metadata');
      await _metadataBox?.delete('${userId}_categories_metadata');
      await _metadataBox?.delete('${userId}_transactions_metadata');
      
      if (kDebugMode) {
        print('OfflineCacheService: Cleared cache for user $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to clear user cache: $e');
      }
    }
  }

  /// Xóa tất cả cache
  Future<void> clearAllCache() async {
    try {
      await _assetsBox?.clear();
      await _categoriesBox?.clear();
      await _transactionsBox?.clear();
      await _metadataBox?.clear();
      
      if (kDebugMode) {
        print('OfflineCacheService: Cleared all cache');
      }
    } catch (e) {
      if (kDebugMode) {
        print('OfflineCacheService: Failed to clear all cache: $e');
      }
    }
  }

  /// Lấy kích thước cache
  Future<Map<String, int>> getCacheSize() async {
    return {
      'assets': _assetsBox?.length ?? 0,
      'categories': _categoriesBox?.length ?? 0,
      'transactions': _transactionsBox?.length ?? 0,
      'metadata': _metadataBox?.length ?? 0,
      'pendingSync': _pendingSyncBox?.length ?? 0,
    };
  }
}

/// Model cho pending sync operations
class PendingSyncOperation {
  final String id;
  final String type; // 'create', 'update', 'delete'
  final String entityType; // 'asset', 'category', 'transaction'
  final Map<String, dynamic> data;
  final DateTime timestamp;

  PendingSyncOperation({
    required this.id,
    required this.type,
    required this.entityType,
    required this.data,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'entityType': entityType,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PendingSyncOperation.fromJson(Map<String, dynamic> json) {
    return PendingSyncOperation(
      id: json['id'],
      type: json['type'],
      entityType: json['entityType'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}