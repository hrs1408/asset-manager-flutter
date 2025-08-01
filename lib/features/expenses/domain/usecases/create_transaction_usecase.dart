import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../assets/domain/repositories/asset_repository.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class CreateTransactionUseCase {
  final TransactionRepository _transactionRepository;
  final AssetRepository _assetRepository;

  CreateTransactionUseCase({
    required TransactionRepository transactionRepository,
    required AssetRepository assetRepository,
  })  : _transactionRepository = transactionRepository,
        _assetRepository = assetRepository;

  Future<Either<Failure, Transaction>> call(Transaction transaction) async {
    try {
      // 1. Validate that the asset exists and has sufficient balance
      final assetResult = await _assetRepository.getAssetById(transaction.assetId);
      
      if (assetResult.isLeft()) {
        return assetResult.fold(
          (failure) => Left(failure),
          (_) => const Left(ValidationFailure('Asset not found')),
        );
      }

      final asset = assetResult.getOrElse(() => throw Exception('Asset not found'));

      // 2. Check if asset has sufficient balance
      if (asset.balance < transaction.amount) {
        return const Left(ValidationFailure(
          'Số dư tài sản không đủ để thực hiện giao dịch này'
        ));
      }

      // 3. Create the transaction
      final transactionResult = await _transactionRepository.createTransaction(transaction);
      
      if (transactionResult.isLeft()) {
        return transactionResult;
      }

      final createdTransaction = transactionResult.getOrElse(() => throw Exception('Transaction creation failed'));

      // 4. Update asset balance (subtract the transaction amount)
      final newBalance = asset.balance - transaction.amount;
      final updateBalanceResult = await _assetRepository.updateAssetBalance(
        transaction.assetId,
        newBalance,
      );

      if (updateBalanceResult.isLeft()) {
        // If balance update fails, we should ideally rollback the transaction
        // For now, we'll return the failure
        return updateBalanceResult.fold(
          (failure) => Left(ServerFailure('Giao dịch đã được tạo nhưng không thể cập nhật số dư tài sản: ${failure.message}')),
          (_) => Right(createdTransaction),
        );
      }

      return Right(createdTransaction);
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định khi tạo giao dịch: $e'));
    }
  }
}