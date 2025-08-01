import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../expenses/domain/repositories/category_repository.dart';
import '../../../expenses/domain/repositories/transaction_repository.dart';
import '../entities/category_expense.dart';

class GetExpensesByCategoryUseCase implements UseCase<List<CategoryExpense>, GetExpensesByCategoryParams> {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;

  GetExpensesByCategoryUseCase({
    required this.transactionRepository,
    required this.categoryRepository,
  });

  @override
  Future<Either<Failure, List<CategoryExpense>>> call(GetExpensesByCategoryParams params) async {
    try {
      // Get expenses by category
      final expensesByCategoryResult = await transactionRepository.getExpensesByCategory(
        params.userId,
        params.startDate,
        params.endDate,
      );

      if (expensesByCategoryResult.isLeft()) {
        return Left(expensesByCategoryResult.fold((l) => l, (r) => ServerFailure('Unexpected error')));
      }

      final expensesByCategory = expensesByCategoryResult.getOrElse(() => {});

      // Get all categories
      final categoriesResult = await categoryRepository.getCategories(params.userId);
      
      if (categoriesResult.isLeft()) {
        return Left(categoriesResult.fold((l) => l, (r) => ServerFailure('Unexpected error')));
      }

      final categories = categoriesResult.getOrElse(() => []);

      // Get transactions to count them by category
      final transactionsResult = await transactionRepository.getTransactionsByDateRange(
        params.userId,
        params.startDate,
        params.endDate,
      );

      final transactions = transactionsResult.getOrElse(() => []);

      // Calculate total expenses for percentage calculation
      double totalExpenses = expensesByCategory.values.fold(0, (sum, amount) => sum + amount);

      // Create CategoryExpense objects
      List<CategoryExpense> categoryExpenses = [];

      for (final category in categories) {
        final amount = expensesByCategory[category.id] ?? 0;
        final transactionCount = transactions
            .where((transaction) => transaction.categoryId == category.id)
            .length;
        final percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0;

        // Only include categories with expenses if filterZero is true
        if (!params.includeZeroExpenses && amount == 0) {
          continue;
        }

        categoryExpenses.add(CategoryExpense(
          category: category,
          totalAmount: amount,
          transactionCount: transactionCount,
          percentage: percentage.toDouble(),
        ));
      }

      // Sort by amount descending
      categoryExpenses.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

      // Apply limit if specified
      if (params.limit != null && params.limit! > 0) {
        categoryExpenses = categoryExpenses.take(params.limit!).toList();
      }

      return Right(categoryExpenses);
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định khi lấy chi tiêu theo danh mục: $e'));
    }
  }
}

class GetExpensesByCategoryParams extends Equatable {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final bool includeZeroExpenses;
  final int? limit;

  const GetExpensesByCategoryParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
    this.includeZeroExpenses = false,
    this.limit,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate, includeZeroExpenses, limit];
}