import '../domain/entities/asset_summary.dart';
import '../domain/entities/expense_summary.dart';
import '../domain/entities/category_expense.dart';
import '../../assets/domain/entities/asset_type.dart';
import '../../expenses/domain/entities/expense_category.dart';

class DemoDashboardData {
  // Constants for consistent data
  static const double _totalExpenses = 12000000; // 12 triệu VNĐ
  static const int _totalTransactions = 45;
  
  static AssetSummary getAssetSummary() {
    const balanceByType = {
      AssetType.paymentAccount: 25000000.0, // 25 triệu
      AssetType.savingsAccount: 80000000.0, // 80 triệu
      AssetType.gold: 30000000.0, // 30 triệu
      AssetType.realEstate: 15000000.0, // 15 triệu
    };
    
    // Calculate total balance from individual balances
    final totalBalance = balanceByType.values.reduce((a, b) => a + b);
    
    return AssetSummary(
      totalBalance: totalBalance, // 150 triệu VNĐ
      totalAssets: 8,
      balanceByType: balanceByType,
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
    
    // Consistent category expenses
    const expensesByCategory = {
      'Ăn uống': 4500000.0,
      'Di chuyển': 2800000.0,
      'Mua sắm': 2200000.0,
      'Giải trí': 1500000.0,
      'Khác': 1000000.0,
    };
    
    // Verify total matches
    final calculatedTotal = expensesByCategory.values.reduce((a, b) => a + b);
    assert(calculatedTotal == _totalExpenses, 'Expense totals must match');
    
    return ExpenseSummary(
      totalExpenses: _totalExpenses,
      totalTransactions: _totalTransactions,
      dailyExpenses: _generateDailyExpenses(),
      expensesByCategory: expensesByCategory,
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

    // Consistent expense data with calculated percentages
    final expenseData = [
      {'amount': 4500000.0, 'transactions': 18}, // Ăn uống
      {'amount': 2800000.0, 'transactions': 12}, // Di chuyển  
      {'amount': 2200000.0, 'transactions': 8},  // Mua sắm
      {'amount': 1500000.0, 'transactions': 5},  // Giải trí
      {'amount': 1000000.0, 'transactions': 2},  // Khác
    ];
    
    // Verify transaction count matches
    final totalTransactionCount = expenseData.map((e) => e['transactions'] as int).reduce((a, b) => a + b);
    assert(totalTransactionCount == _totalTransactions, 'Transaction counts must match');

    return expenseData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final amount = data['amount'] as double;
      final transactions = data['transactions'] as int;
      final percentage = (amount / _totalExpenses) * 100;
      
      return CategoryExpense(
        category: categories[index],
        totalAmount: amount,
        transactionCount: transactions,
        percentage: percentage,
      );
    }).toList();
  }

  static List<DemoTransaction> getRecentTransactions() {
    final now = DateTime.now();
    
    return [
      DemoTransaction(
        id: '1',
        description: 'Cà phê Highlands Coffee',
        amount: 85000,
        date: now.subtract(const Duration(hours: 2)),
        category: 'Ăn uống',
      ),
      DemoTransaction(
        id: '2',
        description: 'Grab đi làm về',
        amount: 45000,
        date: now.subtract(const Duration(hours: 8)),
        category: 'Di chuyển',
      ),
      DemoTransaction(
        id: '3',
        description: 'Cơm trưa quán cơm',
        amount: 120000,
        date: now.subtract(const Duration(days: 1)),
        category: 'Ăn uống',
      ),
      DemoTransaction(
        id: '4',
        description: 'Xem phim CGV Vincom',
        amount: 180000,
        date: now.subtract(const Duration(days: 1, hours: 5)),
        category: 'Giải trí',
      ),
      DemoTransaction(
        id: '5',
        description: 'Áo thun Uniqlo',
        amount: 350000,
        date: now.subtract(const Duration(days: 2)),
        category: 'Mua sắm',
      ),
      DemoTransaction(
        id: '6',
        description: 'Xăng xe máy',
        amount: 120000,
        date: now.subtract(const Duration(days: 2, hours: 3)),
        category: 'Di chuyển',
      ),
      DemoTransaction(
        id: '7',
        description: 'Tạp hóa mua đồ ăn',
        amount: 250000,
        date: now.subtract(const Duration(days: 3)),
        category: 'Ăn uống',
      ),
      DemoTransaction(
        id: '8',
        description: 'Game Steam',
        amount: 300000,
        date: now.subtract(const Duration(days: 3, hours: 12)),
        category: 'Giải trí',
      ),
    ];
  }

  static Map<DateTime, double> _generateDailyExpenses() {
    final Map<DateTime, double> expenses = {};
    final now = DateTime.now();
    
    // Generate 30 days of expenses that sum to _totalExpenses
    final dailyAverage = _totalExpenses / 30;
    double runningTotal = 0;
    
    for (int i = 29; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      
      // Vary expenses by day of week (higher on weekends)
      final dayOfWeek = date.weekday;
      double multiplier = 1.0;
      
      if (dayOfWeek == DateTime.saturday || dayOfWeek == DateTime.sunday) {
        multiplier = 1.4; // 40% higher on weekends
      } else if (dayOfWeek == DateTime.friday) {
        multiplier = 1.2; // 20% higher on Friday
      } else if (dayOfWeek == DateTime.monday) {
        multiplier = 0.8; // 20% lower on Monday
      }
      
      // Add some randomness
      final randomFactor = 0.7 + (0.6 * (i % 7) / 7); // 0.7 to 1.3
      
      double amount = dailyAverage * multiplier * randomFactor;
      
      // Ensure we don't exceed total budget
      if (i == 0) {
        // Last day - use remaining budget
        amount = _totalExpenses - runningTotal;
        if (amount < 0) amount = 50000; // Minimum amount
      } else {
        // Adjust amount to stay within budget
        final remainingBudget = _totalExpenses - runningTotal;
        final remainingDays = i;
        final maxAllowedToday = remainingBudget - (remainingDays * 50000); // Reserve 50k for each remaining day
        
        if (amount > maxAllowedToday && maxAllowedToday > 50000) {
          amount = maxAllowedToday;
        }
        
        runningTotal += amount;
      }
      
      expenses[date] = amount.clamp(50000, 800000); // Min 50k, Max 800k per day
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