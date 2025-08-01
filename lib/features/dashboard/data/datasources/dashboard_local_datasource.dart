import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/asset_summary.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/category_expense.dart';
import '../models/asset_summary_model.dart';
import '../models/expense_summary_model.dart';
import '../models/category_expense_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class DashboardLocalDataSource {
  Future<AssetSummary?> getCachedAssetSummary(String userId);
  Future<void> cacheAssetSummary(AssetSummary assetSummary);
  
  Future<ExpenseSummary?> getCachedExpenseSummary(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<void> cacheExpenseSummary(ExpenseSummary expenseSummary);
  
  Future<List<CategoryExpense>?> getCachedCategoryExpenses(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<void> cacheCategoryExpenses(List<CategoryExpense> categoryExpenses);
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final SharedPreferences sharedPreferences;

  DashboardLocalDataSourceImpl({required this.sharedPreferences});

  static const String _assetSummaryKey = 'CACHED_ASSET_SUMMARY';
  static const String _expenseSummaryKey = 'CACHED_EXPENSE_SUMMARY';
  static const String _categoryExpensesKey = 'CACHED_CATEGORY_EXPENSES';
  static const String _cacheTimestampKey = 'CACHE_TIMESTAMP';

  @override
  Future<AssetSummary?> getCachedAssetSummary(String userId) async {
    try {
      final jsonString = sharedPreferences.getString('${_assetSummaryKey}_$userId');
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        return AssetSummaryModel.fromJson(json);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached asset summary: $e');
    }
  }

  @override
  Future<void> cacheAssetSummary(AssetSummary assetSummary) async {
    try {
      final model = AssetSummaryModel.fromEntity(assetSummary);
      final jsonString = jsonEncode(model.toJson());
      await sharedPreferences.setString(
        '${_assetSummaryKey}_${assetSummary.hashCode}',
        jsonString,
      );
      await _updateCacheTimestamp();
    } catch (e) {
      throw CacheException('Failed to cache asset summary: $e');
    }
  }

  @override
  Future<ExpenseSummary?> getCachedExpenseSummary(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final key = _generateExpenseSummaryKey(userId, startDate, endDate);
      final jsonString = sharedPreferences.getString(key);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        return ExpenseSummaryModel.fromJson(json);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached expense summary: $e');
    }
  }

  @override
  Future<void> cacheExpenseSummary(ExpenseSummary expenseSummary) async {
    try {
      final model = ExpenseSummaryModel.fromEntity(expenseSummary);
      final jsonString = jsonEncode(model.toJson());
      final key = _generateExpenseSummaryKey(
        'user', // We'll need to pass userId properly
        expenseSummary.startDate,
        expenseSummary.endDate,
      );
      await sharedPreferences.setString(key, jsonString);
      await _updateCacheTimestamp();
    } catch (e) {
      throw CacheException('Failed to cache expense summary: $e');
    }
  }

  @override
  Future<List<CategoryExpense>?> getCachedCategoryExpenses(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final key = _generateCategoryExpensesKey(userId, startDate, endDate);
      final jsonString = sharedPreferences.getString(key);
      if (jsonString != null) {
        final jsonList = jsonDecode(jsonString) as List;
        return jsonList
            .map((json) => CategoryExpenseModel.fromJson(json))
            .toList();
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached category expenses: $e');
    }
  }

  @override
  Future<void> cacheCategoryExpenses(List<CategoryExpense> categoryExpenses) async {
    try {
      final models = categoryExpenses
          .map((expense) => CategoryExpenseModel.fromEntity(expense))
          .toList();
      final jsonList = models.map((model) => model.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      
      // Generate a key - we'll need proper userId, startDate, endDate
      final key = '${_categoryExpensesKey}_${categoryExpenses.hashCode}';
      await sharedPreferences.setString(key, jsonString);
      await _updateCacheTimestamp();
    } catch (e) {
      throw CacheException('Failed to cache category expenses: $e');
    }
  }

  String _generateExpenseSummaryKey(String userId, DateTime startDate, DateTime endDate) {
    return '${_expenseSummaryKey}_${userId}_${startDate.millisecondsSinceEpoch}_${endDate.millisecondsSinceEpoch}';
  }

  String _generateCategoryExpensesKey(String userId, DateTime startDate, DateTime endDate) {
    return '${_categoryExpensesKey}_${userId}_${startDate.millisecondsSinceEpoch}_${endDate.millisecondsSinceEpoch}';
  }

  Future<void> _updateCacheTimestamp() async {
    await sharedPreferences.setInt(
      _cacheTimestampKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<bool> isCacheValid({Duration maxAge = const Duration(hours: 1)}) async {
    final timestamp = sharedPreferences.getInt(_cacheTimestampKey);
    if (timestamp == null) return false;
    
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    
    return now.difference(cacheTime) < maxAge;
  }

  Future<void> clearCache() async {
    final keys = sharedPreferences.getKeys();
    final dashboardKeys = keys.where((key) => 
        key.startsWith(_assetSummaryKey) ||
        key.startsWith(_expenseSummaryKey) ||
        key.startsWith(_categoryExpensesKey));
    
    for (final key in dashboardKeys) {
      await sharedPreferences.remove(key);
    }
    
    await sharedPreferences.remove(_cacheTimestampKey);
  }
}