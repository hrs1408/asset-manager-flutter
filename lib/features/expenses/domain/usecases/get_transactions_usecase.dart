import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class TransactionFilter {
  final String? assetId;
  final String? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;
  final int? offset;

  const TransactionFilter({
    this.assetId,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.limit,
    this.offset,
  });
}

class GetTransactionsUseCase {
  final TransactionRepository _repository;

  GetTransactionsUseCase({
    required TransactionRepository repository,
  }) : _repository = repository;

  Future<Either<Failure, List<Transaction>>> call(
    String userId, {
    TransactionFilter? filter,
  }) async {
    try {
      // If no filter is provided, get all transactions
      if (filter == null) {
        return await _repository.getTransactions(userId);
      }

      List<Transaction> transactions = [];

      // Apply filters based on what's provided
      if (filter.startDate != null && filter.endDate != null) {
        // Get transactions by date range
        final result = await _repository.getTransactionsByDateRange(
          userId,
          filter.startDate!,
          filter.endDate!,
        );
        
        if (result.isLeft()) {
          return result;
        }
        
        transactions = result.getOrElse(() => []);
      } else if (filter.assetId != null) {
        // Get transactions by asset
        final result = await _repository.getTransactionsByAsset(filter.assetId!);
        
        if (result.isLeft()) {
          return result;
        }
        
        transactions = result.getOrElse(() => []);
      } else if (filter.categoryId != null) {
        // Get transactions by category
        final result = await _repository.getTransactionsByCategory(filter.categoryId!);
        
        if (result.isLeft()) {
          return result;
        }
        
        transactions = result.getOrElse(() => []);
      } else {
        // Get all transactions
        final result = await _repository.getTransactions(userId);
        
        if (result.isLeft()) {
          return result;
        }
        
        transactions = result.getOrElse(() => []);
      }

      // Apply additional filters in memory
      List<Transaction> filteredTransactions = transactions;

      // Filter by asset if not already filtered
      if (filter.assetId != null && filter.startDate == null) {
        filteredTransactions = filteredTransactions
            .where((transaction) => transaction.assetId == filter.assetId)
            .toList();
      }

      // Filter by category if not already filtered
      if (filter.categoryId != null && filter.assetId == null && filter.startDate == null) {
        filteredTransactions = filteredTransactions
            .where((transaction) => transaction.categoryId == filter.categoryId)
            .toList();
      }

      // Filter by date range if not already filtered
      if (filter.startDate != null && filter.endDate != null && filter.assetId != null) {
        filteredTransactions = filteredTransactions
            .where((transaction) =>
                transaction.date.isAfter(filter.startDate!.subtract(const Duration(days: 1))) &&
                transaction.date.isBefore(filter.endDate!.add(const Duration(days: 1))))
            .toList();
      }

      // Apply pagination
      if (filter.offset != null) {
        final startIndex = filter.offset!;
        if (startIndex < filteredTransactions.length) {
          filteredTransactions = filteredTransactions.sublist(startIndex);
        } else {
          filteredTransactions = [];
        }
      }

      if (filter.limit != null && filteredTransactions.length > filter.limit!) {
        filteredTransactions = filteredTransactions.take(filter.limit!).toList();
      }

      return Right(filteredTransactions);
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định khi lấy danh sách giao dịch: $e'));
    }
  }
}