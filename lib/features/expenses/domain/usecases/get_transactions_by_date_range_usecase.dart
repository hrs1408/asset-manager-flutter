import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsByDateRangeUseCase {
  final TransactionRepository _repository;

  GetTransactionsByDateRangeUseCase({
    required TransactionRepository repository,
  }) : _repository = repository;

  Future<Either<Failure, List<Transaction>>> call(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _repository.getTransactionsByDateRange(userId, startDate, endDate);
  }
}