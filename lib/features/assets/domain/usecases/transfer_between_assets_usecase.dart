import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/asset.dart';
import '../repositories/asset_repository.dart';

class TransferBetweenAssetsUsecase implements UseCase<Map<String, Asset>, TransferBetweenAssetsParams> {
  final AssetRepository repository;

  TransferBetweenAssetsUsecase(this.repository);

  @override
  Future<Either<Failure, Map<String, Asset>>> call(TransferBetweenAssetsParams params) async {
    return await repository.transferBetweenAssets(
      fromAssetId: params.fromAssetId,
      toAssetId: params.toAssetId,
      amount: params.amount,
      notes: params.notes,
    );
  }
}

class TransferBetweenAssetsParams {
  final String fromAssetId;
  final String toAssetId;
  final double amount;
  final String? notes;

  TransferBetweenAssetsParams({
    required this.fromAssetId,
    required this.toAssetId,
    required this.amount,
    this.notes,
  });
}