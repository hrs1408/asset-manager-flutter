import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/transaction_repository.dart';

class GetDailyExpensesUseCase {
  final TransactionRepository _repository;

  GetDailyExpensesUseCase({
    required TransactionRepository repository,
  }) : _repository = repository;

  Future<Either<Failure, Map<DateTime, double>>> call(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _repository.getDailyExpenses(userId, startDate, endDate);
  }
}