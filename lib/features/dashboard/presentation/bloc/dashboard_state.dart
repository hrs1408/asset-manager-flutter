import 'package:equatable/equatable.dart';
import '../../domain/entities/asset_summary.dart';
import '../../domain/entities/expense_summary.dart';
import '../../domain/entities/category_expense.dart';
import '../../../expenses/domain/entities/transaction.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final AssetSummary assetSummary;
  final ExpenseSummary expenseSummary;
  final List<CategoryExpense> categoryExpenses;
  final List<Transaction> recentTransactions;
  final DateTime startDate;
  final DateTime endDate;

  const DashboardLoaded({
    required this.assetSummary,
    required this.expenseSummary,
    required this.categoryExpenses,
    required this.recentTransactions,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [
        assetSummary,
        expenseSummary,
        categoryExpenses,
        recentTransactions,
        startDate,
        endDate,
      ];

  DashboardLoaded copyWith({
    AssetSummary? assetSummary,
    ExpenseSummary? expenseSummary,
    List<CategoryExpense>? categoryExpenses,
    List<Transaction>? recentTransactions,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return DashboardLoaded(
      assetSummary: assetSummary ?? this.assetSummary,
      expenseSummary: expenseSummary ?? this.expenseSummary,
      categoryExpenses: categoryExpenses ?? this.categoryExpenses,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object?> get props => [message];
}