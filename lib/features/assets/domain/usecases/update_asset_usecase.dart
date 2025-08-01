import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/asset.dart';
import '../repositories/asset_repository.dart';

class UpdateAssetUseCase implements UseCase<Asset, UpdateAssetParams> {
  final AssetRepository repository;

  UpdateAssetUseCase(this.repository);

  @override
  Future<Either<Failure, Asset>> call(UpdateAssetParams params) async {
    return await repository.updateAsset(params.asset);
  }
}

class UpdateAssetParams extends Equatable {
  final Asset asset;

  const UpdateAssetParams({
    required this.asset,
  });

  @override
  List<Object> get props => [asset];
}