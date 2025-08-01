import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/asset.dart';
import '../repositories/asset_repository.dart';

class DepositToAssetUsecase implements UseCase<Asset, DepositToAssetParams> {
  final AssetRepository repository;

  DepositToAssetUsecase(this.repository);

  @override
  Future<Either<Failure, Asset>> call(DepositToAssetParams params) async {
    return await repository.depositToAsset(params.assetId, params.amount);
  }
}

class DepositToAssetParams {
  final String assetId;
  final double amount;

  DepositToAssetParams({
    required this.assetId,
    required this.amount,
  });
}