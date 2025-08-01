import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../assets/domain/repositories/asset_repository.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  final TransactionRepository _transactionRepository;
  final AssetRepository _assetRepository;

  DeleteTransactionUseCase({
    required TransactionRepository transactionRepository,
    required AssetRepository assetRepository,
  })  : _transactionRepository = transactionRepository,
        _assetRepository = assetRepository;

  Future<Either<Failure, void>> call(String transactionId) async {
    try {
      // 1. Get the transaction to restore the balance
      final transactionResult = await _transactionRepository.getTransactionById(transactionId);
      
      if (transactionResult.isLeft()) {
        return transactionResult.fold(
          (failure) => Left(failure),
          (_) => const Left(ValidationFailure('Transaction not found')),
        );
      }

      final transaction = transactionResult.getOrElse(() => throw Exception('Transaction not found'));

      // 2. Get the asset to restore balance
      final assetResult = await _assetRepository.getAssetById(transaction.assetId);
      
      if (assetResult.isLeft()) {
        return assetResult.fold(
          (failure) => Left(failure),
          (_) => const Left(ValidationFailure('Asset not found')),
        );
      }

      final asset = assetResult.getOrElse(() => throw Exception('Asset not found'));

      // 3. Delete the transaction first
      final deleteResult = await _transactionRepository.deleteTransaction(transactionId);
      
      if (deleteResult.isLeft()) {
        return deleteResult;
      }

      // 4. Restore the balance (add back the transaction amount)
      final restoredBalance = asset.balance + transaction.amount;
      final updateBalanceResult = await _assetRepository.updateAssetBalance(
        transaction.assetId,
        restoredBalance,
      );

      if (updateBalanceResult.isLeft()) {
        return updateBalanceResult.fold(
          (failure) => Left(ServerFailure('Giao dịch đã được xóa nhưng không thể khôi phục số dư tài sản: ${failure.message}')),
          (_) => const Right(null),
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định khi xóa giao dịch: $e'));
    }
  }
}