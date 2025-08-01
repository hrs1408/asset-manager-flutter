import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionByIdUseCase {
  final TransactionRepository _repository;

  GetTransactionByIdUseCase({
    required TransactionRepository repository,
  }) : _repository = repository;

  Future<Either<Failure, Transaction>> call(String transactionId) async {
    return await _repository.getTransactionById(transactionId);
  }
}