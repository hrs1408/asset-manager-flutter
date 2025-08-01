import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/transaction_repository.dart';

class GetExpensesByCategoryUseCase {
  final TransactionRepository _repository;

  GetExpensesByCategoryUseCase({
    required TransactionRepository repository,
  }) : _repository = repository;

  Future<Either<Failure, Map<String, double>>> call(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _repository.getExpensesByCategory(userId, startDate, endDate);
  }
}