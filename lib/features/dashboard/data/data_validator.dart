import 'demo_dashboard_data.dart';

class DataValidator {
  static void validateDashboardData() {
    print('🔍 Validating Dashboard Data...');
    
    // Get all data
    final assetSummary = DemoDashboardData.getAssetSummary();
    final expenseSummary = DemoDashboardData.getExpenseSummary();
    final categoryExpenses = DemoDashboardData.getCategoryExpenses();
    final recentTransactions = DemoDashboardData.getRecentTransactions();
    
    // Validate Asset Summary
    print('\n📊 Asset Summary:');
    final calculatedAssetTotal = assetSummary.balanceByType.values.reduce((a, b) => a + b);
    print('  Total Balance: ${_formatCurrency(assetSummary.totalBalance)}');
    print('  Calculated Total: ${_formatCurrency(calculatedAssetTotal)}');
    print('  ✅ Asset totals match: ${assetSummary.totalBalance == calculatedAssetTotal}');
    
    final calculatedAssetCount = assetSummary.countByType.values.reduce((a, b) => a + b);
    print('  Total Assets: ${assetSummary.totalAssets}');
    print('  Calculated Count: $calculatedAssetCount');
    print('  ✅ Asset counts match: ${assetSummary.totalAssets == calculatedAssetCount}');
    
    // Validate Expense Summary
    print('\n💰 Expense Summary:');
    final calculatedExpenseTotal = expenseSummary.expensesByCategory.values.reduce((a, b) => a + b);
    print('  Total Expenses: ${_formatCurrency(expenseSummary.totalExpenses)}');
    print('  Calculated Total: ${_formatCurrency(calculatedExpenseTotal)}');
    print('  ✅ Expense totals match: ${expenseSummary.totalExpenses == calculatedExpenseTotal}');
    
    // Validate Category Expenses
    print('\n📈 Category Expenses:');
    final categoryTotal = categoryExpenses.map((e) => e.totalAmount).reduce((a, b) => a + b);
    final categoryTransactionCount = categoryExpenses.map((e) => e.transactionCount).reduce((a, b) => a + b);
    final categoryPercentageSum = categoryExpenses.map((e) => e.percentage).reduce((a, b) => a + b);
    
    print('  Category Total: ${_formatCurrency(categoryTotal)}');
    print('  Expense Total: ${_formatCurrency(expenseSummary.totalExpenses)}');
    print('  ✅ Category totals match: ${(categoryTotal - expenseSummary.totalExpenses).abs() < 1}');
    
    print('  Category Transactions: $categoryTransactionCount');
    print('  Expense Transactions: ${expenseSummary.totalTransactions}');
    print('  ✅ Transaction counts match: ${categoryTransactionCount == expenseSummary.totalTransactions}');
    
    print('  Percentage Sum: ${categoryPercentageSum.toStringAsFixed(1)}%');
    print('  ✅ Percentages sum to ~100%: ${(categoryPercentageSum - 100).abs() < 1}');
    
    // Validate Daily Expenses
    print('\n📅 Daily Expenses:');
    final dailyTotal = expenseSummary.dailyExpenses.values.reduce((a, b) => a + b);
    print('  Daily Total: ${_formatCurrency(dailyTotal)}');
    print('  Expense Total: ${_formatCurrency(expenseSummary.totalExpenses)}');
    print('  ✅ Daily totals match: ${(dailyTotal - expenseSummary.totalExpenses).abs() < 1000}'); // Allow 1k variance
    
    // Recent Transactions
    print('\n🕒 Recent Transactions:');
    print('  Transaction Count: ${recentTransactions.length}');
    final transactionTotal = recentTransactions.map((e) => e.amount).reduce((a, b) => a + b);
    print('  Recent Total: ${_formatCurrency(transactionTotal)}');
    
    // Category breakdown
    print('\n📊 Category Breakdown:');
    for (final category in categoryExpenses) {
      print('  ${category.category.icon} ${category.category.name}: '
            '${_formatCurrency(category.totalAmount)} '
            '(${category.percentage.toStringAsFixed(1)}%) '
            '- ${category.transactionCount} transactions');
    }
    
    // Asset breakdown
    print('\n🏦 Asset Breakdown:');
    for (final entry in assetSummary.balanceByType.entries) {
      final percentage = (entry.value / assetSummary.totalBalance) * 100;
      print('  ${_getAssetIcon(entry.key)} ${_getAssetName(entry.key)}: '
            '${_formatCurrency(entry.value)} '
            '(${percentage.toStringAsFixed(1)}%) '
            '- ${assetSummary.countByType[entry.key]} assets');
    }
    
    print('\n✅ Data validation completed!');
  }
  
  static String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M VNĐ';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K VNĐ';
    } else {
      return '${amount.toStringAsFixed(0)} VNĐ';
    }
  }
  
  static String _getAssetIcon(assetType) {
    switch (assetType.toString()) {
      case 'AssetType.paymentAccount': return '💳';
      case 'AssetType.savingsAccount': return '🏦';
      case 'AssetType.gold': return '🥇';
      case 'AssetType.realEstate': return '🏠';
      default: return '📦';
    }
  }
  
  static String _getAssetName(assetType) {
    switch (assetType.toString()) {
      case 'AssetType.paymentAccount': return 'Tài khoản thanh toán';
      case 'AssetType.savingsAccount': return 'Tài khoản tiết kiệm';
      case 'AssetType.gold': return 'Vàng';
      case 'AssetType.realEstate': return 'Bất động sản';
      default: return 'Khác';
    }
  }
}