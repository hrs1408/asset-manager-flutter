import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/asset.dart';
import '../repositories/asset_repository.dart';

class DepositToAssetWithDetailsUsecase implements UseCase<Asset, DepositToAssetWithDetailsParams> {
  final AssetRepository repository;

  DepositToAssetWithDetailsUsecase(this.repository);

  @override
  Future<Either<Failure, Asset>> call(DepositToAssetWithDetailsParams params) async {
    return await repository.depositToAssetWithDetails(
      assetId: params.assetId,
      amount: params.amount,
      depositSource: params.depositSource,
      notes: params.notes,
    );
  }
}

class DepositToAssetWithDetailsParams {
  final String assetId;
  final double amount;
  final String depositSource;
  final String? notes;

  DepositToAssetWithDetailsParams({
    required this.assetId,
    required this.amount,
    required this.depositSource,
    this.notes,
  });
}