import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/asset.dart';
import '../repositories/asset_repository.dart';

class GetAssetByIdUseCase implements UseCase<Asset, GetAssetByIdParams> {
  final AssetRepository repository;

  GetAssetByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Asset>> call(GetAssetByIdParams params) async {
    return await repository.getAssetById(params.assetId);
  }
}

class GetAssetByIdParams extends Equatable {
  final String assetId;

  const GetAssetByIdParams({
    required this.assetId,
  });

  @override
  List<Object> get props => [assetId];
}