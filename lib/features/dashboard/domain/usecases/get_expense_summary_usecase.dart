import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../expenses/domain/repositories/transaction_repository.dart';
import '../entities/expense_summary.dart';

class GetExpenseSummaryUseCase implements UseCase<ExpenseSummary, GetExpenseSummaryParams> {
  final TransactionRepository transactionRepository;

  GetExpenseSummaryUseCase({required this.transactionRepository});

  @override
  Future<Either<Failure, ExpenseSummary>> call(GetExpenseSummaryParams params) async {
    try {
      // Get transactions in date range
      final transactionsResult = await transactionRepository.getTransactionsByDateRange(
        params.userId,
        params.startDate,
        params.endDate,
      );

      if (transactionsResult.isLeft()) {
        return Left(transactionsResult.fold((l) => l, (r) => ServerFailure('Unexpected error')));
      }

      final transactions = transactionsResult.getOrElse(() => []);

      // Get expenses by category
      final expensesByCategoryResult = await transactionRepository.getExpensesByCategory(
        params.userId,
        params.startDate,
        params.endDate,
      );

      // Get expenses by asset
      final expensesByAssetResult = await transactionRepository.getExpensesByAsset(
        params.userId,
        params.startDate,
        params.endDate,
      );

      // Get daily expenses
      final dailyExpensesResult = await transactionRepository.getDailyExpenses(
        params.userId,
        params.startDate,
        params.endDate,
      );

      // Calculate total expenses
      double totalExpenses = 0;
      for (final transaction in transactions) {
        totalExpenses += transaction.amount;
      }

      final summary = ExpenseSummary(
        totalExpenses: totalExpenses,
        dailyExpenses: dailyExpensesResult.getOrElse(() => {}),
        expensesByCategory: expensesByCategoryResult.getOrElse(() => {}),
        expensesByAsset: expensesByAssetResult.getOrElse(() => {}),
        startDate: params.startDate,
        endDate: params.endDate,
        totalTransactions: transactions.length,
      );

      return Right(summary);
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định khi lấy tổng quan chi tiêu: $e'));
    }
  }
}

class GetExpenseSummaryParams extends Equatable {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  const GetExpenseSummaryParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}