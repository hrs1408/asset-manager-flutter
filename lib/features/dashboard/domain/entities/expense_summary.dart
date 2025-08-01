import 'package:equatable/equatable.dart';

class ExpenseSummary extends Equatable {
  final double totalExpenses;
  final Map<DateTime, double> dailyExpenses;
  final Map<String, double> expensesByCategory;
  final Map<String, double> expensesByAsset;
  final DateTime startDate;
  final DateTime endDate;
  final int totalTransactions;

  const ExpenseSummary({
    required this.totalExpenses,
    required this.dailyExpenses,
    required this.expensesByCategory,
    required this.expensesByAsset,
    required this.startDate,
    required this.endDate,
    required this.totalTransactions,
  });

  @override
  List<Object?> get props => [
        totalExpenses,
        dailyExpenses,
        expensesByCategory,
        expensesByAsset,
        startDate,
        endDate,
        totalTransactions,
      ];
}