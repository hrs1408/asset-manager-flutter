import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/asset_summary.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/category_expense.dart';
import '../../../assets/domain/entities/asset_type.dart';
import '../../../expenses/domain/entities/expense_category.dart';
import '../../../../core/error/exceptions.dart';

abstract class DashboardRemoteDataSource {
  Future<AssetSummary> getAssetSummary(String userId);
  Future<ExpenseSummary> getExpenseSummary(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
  Future<List<CategoryExpense>> getExpensesByCategory(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    bool includeZeroExpenses = false,
    int? limit,
  });
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final FirebaseFirestore firestore;

  DashboardRemoteDataSourceImpl({required this.firestore});

  @override
  Future<AssetSummary> getAssetSummary(String userId) async {
    try {
      // Get all assets for user
      final assetsSnapshot = await firestore
          .collection('assets')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      if (assetsSnapshot.docs.isEmpty) {
        return AssetSummary(
          totalBalance: 0,
          totalAssets: 0,
          balanceByType: {},
          countByType: {},
        );
      }

      double totalBalance = 0;
      final Map<AssetType, double> balanceByType = {};
      final Map<AssetType, int> countByType = {};

      for (final doc in assetsSnapshot.docs) {
        final data = doc.data();
        final balance = (data['balance'] as num?)?.toDouble() ?? 0;
        final assetTypeString = data['type'] as String? ?? 'other';
        final assetType = _parseAssetType(assetTypeString);

        totalBalance += balance;
        balanceByType[assetType] = (balanceByType[assetType] ?? 0) + balance;
        countByType[assetType] = (countByType[assetType] ?? 0) + 1;
      }

      return AssetSummary(
        totalBalance: totalBalance,
        totalAssets: assetsSnapshot.docs.length,
        balanceByType: balanceByType,
        countByType: countByType,
      );
    } catch (e) {
      throw ServerException('Failed to get asset summary: $e');
    }
  }

  @override
  Future<ExpenseSummary> getExpenseSummary(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Get all transactions in date range
      final transactionsSnapshot = await firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .where('type', isEqualTo: 'expense')
          .get();

      if (transactionsSnapshot.docs.isEmpty) {
        return ExpenseSummary(
          totalExpenses: 0,
          totalTransactions: 0,
          dailyExpenses: {},
          expensesByCategory: {},
          expensesByAsset: {},
          startDate: startDate,
          endDate: endDate,
        );
      }

      double totalExpenses = 0;
      final Map<DateTime, double> dailyExpenses = {};
      final Map<String, double> expensesByCategory = {};
      final Map<String, double> expensesByAsset = {};

      for (final doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final amount = (data['amount'] as num?)?.toDouble() ?? 0;
        final date = (data['date'] as Timestamp).toDate();
        final categoryId = data['categoryId'] as String? ?? 'unknown';
        final assetId = data['assetId'] as String? ?? 'unknown';

        totalExpenses += amount;

        // Group by day
        final dayKey = DateTime(date.year, date.month, date.day);
        dailyExpenses[dayKey] = (dailyExpenses[dayKey] ?? 0) + amount;

        // Group by category
        expensesByCategory[categoryId] = (expensesByCategory[categoryId] ?? 0) + amount;

        // Group by asset
        expensesByAsset[assetId] = (expensesByAsset[assetId] ?? 0) + amount;
      }

      return ExpenseSummary(
        totalExpenses: totalExpenses,
        totalTransactions: transactionsSnapshot.docs.length,
        dailyExpenses: dailyExpenses,
        expensesByCategory: expensesByCategory,
        expensesByAsset: expensesByAsset,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      throw ServerException('Failed to get expense summary: $e');
    }
  }

  @override
  Future<List<CategoryExpense>> getExpensesByCategory(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    bool includeZeroExpenses = false,
    int? limit,
  }) async {
    try {
      // Get expense summary first
      final expenseSummary = await getExpenseSummary(userId, startDate, endDate);
      
      // Get all categories for user
      final categoriesSnapshot = await firestore
          .collection('expense_categories')
          .where('userId', isEqualTo: userId)
          .get();

      final List<CategoryExpense> categoryExpenses = [];

      for (final categoryDoc in categoriesSnapshot.docs) {
        final categoryData = categoryDoc.data();
        final category = ExpenseCategory(
          id: categoryDoc.id,
          userId: categoryData['userId'] as String,
          name: categoryData['name'] as String,
          description: categoryData['description'] as String? ?? '',
          icon: categoryData['icon'] as String? ?? '📦',
          isDefault: categoryData['isDefault'] as bool? ?? false,
          createdAt: (categoryData['createdAt'] as Timestamp).toDate(),
          updatedAt: (categoryData['updatedAt'] as Timestamp).toDate(),
        );

        final totalAmount = expenseSummary.expensesByCategory[categoryDoc.id] ?? 0;
        
        if (!includeZeroExpenses && totalAmount == 0) continue;

        // Count transactions for this category
        final transactionCount = await _getTransactionCountForCategory(
          userId,
          categoryDoc.id,
          startDate,
          endDate,
        );

        final percentage = expenseSummary.totalExpenses > 0 
            ? (totalAmount / expenseSummary.totalExpenses) * 100 
            : 0;

        categoryExpenses.add(CategoryExpense(
          category: category,
          totalAmount: totalAmount,
          transactionCount: transactionCount,
          percentage: percentage,
        ));
      }

      // Sort by amount descending
      categoryExpenses.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

      // Apply limit if specified
      if (limit != null && categoryExpenses.length > limit) {
        return categoryExpenses.take(limit).toList();
      }

      return categoryExpenses;
    } catch (e) {
      throw ServerException('Failed to get expenses by category: $e');
    }
  }

  Future<int> _getTransactionCountForCategory(
    String userId,
    String categoryId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final snapshot = await firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .where('categoryId', isEqualTo: categoryId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .where('type', isEqualTo: 'expense')
        .get();

    return snapshot.docs.length;
  }

  AssetType _parseAssetType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'payment_account':
      case 'paymentaccount':
        return AssetType.paymentAccount;
      case 'savings_account':
      case 'savingsaccount':
        return AssetType.savingsAccount;
      case 'gold':
        return AssetType.gold;
      case 'loan':
        return AssetType.loan;
      case 'real_estate':
      case 'realestate':
        return AssetType.realEstate;
      default:
        return AssetType.other;
    }
  }
}