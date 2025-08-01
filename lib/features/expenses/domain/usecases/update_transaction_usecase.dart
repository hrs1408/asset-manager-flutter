import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../assets/domain/repositories/asset_repository.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransactionUseCase {
  final TransactionRepository _transactionRepository;
  final AssetRepository _assetRepository;

  UpdateTransactionUseCase({
    required TransactionRepository transactionRepository,
    required AssetRepository assetRepository,
  })  : _transactionRepository = transactionRepository,
        _assetRepository = assetRepository;

  Future<Either<Failure, Transaction>> call(Transaction updatedTransaction) async {
    try {
      // 1. Get the original transaction to calculate balance difference
      final originalTransactionResult = await _transactionRepository.getTransactionById(updatedTransaction.id);
      
      if (originalTransactionResult.isLeft()) {
        return originalTransactionResult.fold(
          (failure) => Left(failure),
          (_) => const Left(ValidationFailure('Original transaction not found')),
        );
      }

      final originalTransaction = originalTransactionResult.getOrElse(() => throw Exception('Original transaction not found'));

      // 2. Check if asset changed or amount changed
      final bool assetChanged = originalTransaction.assetId != updatedTransaction.assetId;
      final bool amountChanged = originalTransaction.amount != updatedTransaction.amount;

      if (assetChanged || amountChanged) {
        // Handle balance updates
        if (assetChanged) {
          // Restore balance to original asset
          final originalAssetResult = await _assetRepository.getAssetById(originalTransaction.assetId);
          if (originalAssetResult.isRight()) {
            final originalAsset = originalAssetResult.getOrElse(() => throw Exception('Original asset not found'));
            final restoredBalance = originalAsset.balance + originalTransaction.amount;
            await _assetRepository.updateAssetBalance(originalTransaction.assetId, restoredBalance);
          }

          // Deduct from new asset
          final newAssetResult = await _assetRepository.getAssetById(updatedTransaction.assetId);
          if (newAssetResult.isLeft()) {
            return newAssetResult.fold(
              (failure) => Left(failure),
              (_) => const Left(ValidationFailure('New asset not found')),
            );
          }

          final newAsset = newAssetResult.getOrElse(() => throw Exception('New asset not found'));
          
          // Check if new asset has sufficient balance
          if (newAsset.balance < updatedTransaction.amount) {
            return const Left(ValidationFailure(
              'Số dư tài sản mới không đủ để thực hiện giao dịch này'
            ));
          }

          final newBalance = newAsset.balance - updatedTransaction.amount;
          final updateNewBalanceResult = await _assetRepository.updateAssetBalance(
            updatedTransaction.assetId,
            newBalance,
          );

          if (updateNewBalanceResult.isLeft()) {
            return updateNewBalanceResult.fold(
              (failure) => Left(ServerFailure('Không thể cập nhật số dư tài sản mới: ${failure.message}')),
              (_) => Right(updatedTransaction),
            );
          }
        } else if (amountChanged) {
          // Same asset, different amount
          final assetResult = await _assetRepository.getAssetById(updatedTransaction.assetId);
          if (assetResult.isLeft()) {
            return assetResult.fold(
              (failure) => Left(failure),
              (_) => const Left(ValidationFailure('Asset not found')),
            );
          }

          final asset = assetResult.getOrElse(() => throw Exception('Asset not found'));
          
          // Calculate the difference and check if asset has sufficient balance
          final amountDifference = updatedTransaction.amount - originalTransaction.amount;
          final newBalance = asset.balance - amountDifference;

          if (newBalance < 0) {
            return const Left(ValidationFailure(
              'Số dư tài sản không đủ để thực hiện cập nhật này'
            ));
          }

          final updateBalanceResult = await _assetRepository.updateAssetBalance(
            updatedTransaction.assetId,
            newBalance,
          );

          if (updateBalanceResult.isLeft()) {
            return updateBalanceResult.fold(
              (failure) => Left(ServerFailure('Không thể cập nhật số dư tài sản: ${failure.message}')),
              (_) => Right(updatedTransaction),
            );
          }
        }
      }

      // 3. Update the transaction
      final transactionResult = await _transactionRepository.updateTransaction(updatedTransaction);
      
      return transactionResult;
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định khi cập nhật giao dịch: $e'));
    }
  }
}