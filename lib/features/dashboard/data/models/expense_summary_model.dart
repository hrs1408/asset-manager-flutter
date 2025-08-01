import '../../domain/entities/expense_summary.dart';

class ExpenseSummaryModel extends ExpenseSummary {
  const ExpenseSummaryModel({
    required super.totalExpenses,
    required super.dailyExpenses,
    required super.expensesByCategory,
    required super.expensesByAsset,
    required super.startDate,
    required super.endDate,
    required super.totalTransactions,
  });

  factory ExpenseSummaryModel.fromJson(Map<String, dynamic> json) {
    // Parse dailyExpenses
    final dailyExpensesJson = json['dailyExpenses'] as Map<String, dynamic>? ?? {};
    final Map<DateTime, double> dailyExpenses = {};
    for (final entry in dailyExpensesJson.entries) {
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(entry.key));
      dailyExpenses[date] = (entry.value as num).toDouble();
    }

    // Parse expensesByCategory
    final expensesByCategoryJson = json['expensesByCategory'] as Map<String, dynamic>? ?? {};
    final Map<String, double> expensesByCategory = {};
    for (final entry in expensesByCategoryJson.entries) {
      expensesByCategory[entry.key] = (entry.value as num).toDouble();
    }

    // Parse expensesByAsset
    final expensesByAssetJson = json['expensesByAsset'] as Map<String, dynamic>? ?? {};
    final Map<String, double> expensesByAsset = {};
    for (final entry in expensesByAssetJson.entries) {
      expensesByAsset[entry.key] = (entry.value as num).toDouble();
    }

    return ExpenseSummaryModel(
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      dailyExpenses: dailyExpenses,
      expensesByCategory: expensesByCategory,
      expensesByAsset: expensesByAsset,
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate'] as int),
      endDate: DateTime.fromMillisecondsSinceEpoch(json['endDate'] as int),
      totalTransactions: json['totalTransactions'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    // Convert dailyExpenses to JSON
    final Map<String, double> dailyExpensesJson = {};
    for (final entry in dailyExpenses.entries) {
      dailyExpensesJson[entry.key.millisecondsSinceEpoch.toString()] = entry.value;
    }

    return {
      'totalExpenses': totalExpenses,
      'dailyExpenses': dailyExpensesJson,
      'expensesByCategory': expensesByCategory,
      'expensesByAsset': expensesByAsset,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'totalTransactions': totalTransactions,
    };
  }

  factory ExpenseSummaryModel.fromEntity(ExpenseSummary entity) {
    return ExpenseSummaryModel(
      totalExpenses: entity.totalExpenses,
      dailyExpenses: entity.dailyExpenses,
      expensesByCategory: entity.expensesByCategory,
      expensesByAsset: entity.expensesByAsset,
      startDate: entity.startDate,
      endDate: entity.endDate,
      totalTransactions: entity.totalTransactions,
    );
  }
}