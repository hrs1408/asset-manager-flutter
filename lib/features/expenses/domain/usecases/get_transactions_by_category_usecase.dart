import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsByCategoryUseCase {
  final TransactionRepository _repository;

  GetTransactionsByCategoryUseCase({
    required TransactionRepository repository,
  }) : _repository = repository;

  Future<Either<Failure, List<Transaction>>> call(String categoryId) async {
    return await _repository.getTransactionsByCategory(categoryId);
  }
}