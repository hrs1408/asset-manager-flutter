import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/asset_summary.dart';
import '../entities/expense_summary.dart';
import '../entities/category_expense.dart';

abstract class DashboardRepository {
  Future<Either<Failure, AssetSummary>> getAssetSummary(String userId);
  
  Future<Either<Failure, ExpenseSummary>> getExpenseSummary(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );
  
  Future<Either<Failure, List<CategoryExpense>>> getExpensesByCategory(
    String userId,
    DateTime startDate,
    DateTime endDate, {
    bool includeZeroExpenses = false,
    int? limit,
  });
}