import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsByAssetUseCase {
  final TransactionRepository _repository;

  GetTransactionsByAssetUseCase({
    required TransactionRepository repository,
  }) : _repository = repository;

  Future<Either<Failure, List<Transaction>>> call(String assetId) async {
    return await _repository.getTransactionsByAsset(assetId);
  }
}