import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/asset_repository.dart';

class DeleteAssetUseCase implements UseCase<void, DeleteAssetParams> {
  final AssetRepository repository;

  DeleteAssetUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteAssetParams params) async {
    return await repository.deleteAsset(params.assetId);
  }
}

class DeleteAssetParams extends Equatable {
  final String assetId;

  const DeleteAssetParams({
    required this.assetId,
  });

  @override
  List<Object> get props => [assetId];
}