import '../domain/entities/asset_summary.dart';
import '../domain/entities/expense_summary.dart';
import '../domain/entities/category_expense.dart';
import '../../assets/domain/entities/asset_type.dart';
import '../../expenses/domain/entities/expense_category.dart';

class DemoDashboardData {
  static AssetSummary getAssetSummary() {
    return AssetSummary(
      totalBalance: 150000000, // 150 triệu VNĐ
      totalAssets: 8,
      balanceByType: {
        AssetType.paymentAccount: 25000000, // 25 triệu
        AssetType.savingsAccount: 80000000, // 80 triệu
        AssetType.gold: 30000000, // 30 triệu
        AssetType.realEstate: 15000000, // 15 triệu
      },
      countByType: {
        AssetType.paymentAccount: 2,
        AssetType.savingsAccount: 3,
        AssetType.gold: 2,
        AssetType.realEstate: 1,
      },
    );
  }

  static ExpenseSummary getExpenseSummary() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 1, now.day);
    
    return ExpenseSummary(
      totalExpenses: 12000000, // 12 triệu VNĐ
      totalTransactions: 45,
      dailyExpenses: _generateDailyExpenses(),
      expensesByCategory: {
        'Ăn uống': 4500000,
        'Di chuyển': 2800000,
        'Mua sắm': 2200000,
        'Giải trí': 1500000,
        'Khác': 1000000,
      },
      expensesByAsset: {
        'Tài khoản thanh toán': 8000000,
        'Tiền mặt': 4000000,
      },
      startDate: startDate,
      endDate: now,
    );
  }

  static List<CategoryExpense> getCategoryExpenses() {
    final now = DateTime.now();
    final categories = [
      ExpenseCategory(
        id: '1',
        userId: 'demo_user',
        name: 'Ăn uống',
        description: 'Chi phí ăn uống',
        icon: '🍽️',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: '2',
        userId: 'demo_user',
        name: 'Di chuyển',
        description: 'Chi phí di chuyển',
        icon: '🚗',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: '3',
        userId: 'demo_user',
        name: 'Mua sắm',
        description: 'Chi phí mua sắm',
        icon: '🛍️',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: '4',
        userId: 'demo_user',
        name: 'Giải trí',
        description: 'Chi phí giải trí',
        icon: '🎮',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
      ExpenseCategory(
        id: '5',
        userId: 'demo_user',
        name: 'Khác',
        description: 'Chi phí khác',
        icon: '📦',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    return [
      CategoryExpense(
        category: categories[0],
        totalAmount: 4500000, // 4.5 triệu
        transactionCount: 18,
        percentage: 37.5,
      ),
      CategoryExpense(
        category: categories[1],
        totalAmount: 2800000, // 2.8 triệu
        transactionCount: 12,
        percentage: 23.3,
      ),
      CategoryExpense(
        category: categories[2],
        totalAmount: 2200000, // 2.2 triệu
        transactionCount: 8,
        percentage: 18.3,
      ),
      CategoryExpense(
        category: categories[3],
        totalAmount: 1500000, // 1.5 triệu
        transactionCount: 5,
        percentage: 12.5,
      ),
      CategoryExpense(
        category: categories[4],
        totalAmount: 1000000, // 1 triệu
        transactionCount: 2,
        percentage: 8.3,
      ),
    ];
  }

  static List<DemoTransaction> getRecentTransactions() {
    return [
      DemoTransaction(
        id: '1',
        description: 'Cà phê Highlands',
        amount: 85000,
        date: DateTime.now().subtract(const Duration(hours: 2)),
        category: 'Ăn uống',
      ),
      DemoTransaction(
        id: '2',
        description: 'Grab đi làm',
        amount: 45000,
        date: DateTime.now().subtract(const Duration(hours: 8)),
        category: 'Di chuyển',
      ),
      DemoTransaction(
        id: '3',
        description: 'Mua đồ ăn trưa',
        amount: 120000,
        date: DateTime.now().subtract(const Duration(days: 1)),
        category: 'Ăn uống',
      ),
      DemoTransaction(
        id: '4',
        description: 'Xem phim CGV',
        amount: 180000,
        date: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        category: 'Giải trí',
      ),
      DemoTransaction(
        id: '5',
        description: 'Mua áo thun',
        amount: 350000,
        date: DateTime.now().subtract(const Duration(days: 2)),
        category: 'Mua sắm',
      ),
    ];
  }

  static Map<DateTime, double> _generateDailyExpenses() {
    final Map<DateTime, double> expenses = {};
    final now = DateTime.now();
    
    for (int i = 29; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      // Generate random expenses between 200k - 800k
      final amount = 200000 + (600000 * (0.5 + 0.5 * (i % 7) / 7));
      expenses[date] = amount;
    }
    
    return expenses;
  }
}

class DemoTransaction {
  final String id;
  final String description;
  final double amount;
  final DateTime date;
  final String category;

  DemoTransaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.category,
  });
}