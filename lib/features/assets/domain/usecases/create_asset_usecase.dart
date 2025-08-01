import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/asset.dart';
import '../repositories/asset_repository.dart';

class CreateAssetUseCase implements UseCase<Asset, CreateAssetParams> {
  final AssetRepository repository;

  CreateAssetUseCase(this.repository);

  @override
  Future<Either<Failure, Asset>> call(CreateAssetParams params) async {
    return await repository.createAsset(params.asset);
  }
}

class CreateAssetParams extends Equatable {
  final Asset asset;

  const CreateAssetParams({
    required this.asset,
  });

  @override
  List<Object> get props => [asset];
}