import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../assets/domain/entities/asset_type.dart';
import '../../../assets/domain/repositories/asset_repository.dart';
import '../entities/asset_summary.dart';

class GetAssetSummaryUseCase implements UseCase<AssetSummary, GetAssetSummaryParams> {
  final AssetRepository assetRepository;

  GetAssetSummaryUseCase({required this.assetRepository});

  @override
  Future<Either<Failure, AssetSummary>> call(GetAssetSummaryParams params) async {
    try {
      // Get all assets for the user
      final assetsResult = await assetRepository.getAssets(params.userId);
      
      return assetsResult.fold(
        (failure) => Left(failure),
        (assets) {
          // Calculate total balance
          double totalBalance = 0;
          Map<AssetType, double> balanceByType = {};
          Map<AssetType, int> countByType = {};

          // Initialize maps with all asset types
          for (AssetType type in AssetType.values) {
            balanceByType[type] = 0;
            countByType[type] = 0;
          }

          // Process each asset
          for (final asset in assets) {
            totalBalance += asset.balance;
            balanceByType[asset.type] = (balanceByType[asset.type] ?? 0) + asset.balance;
            countByType[asset.type] = (countByType[asset.type] ?? 0) + 1;
          }

          final summary = AssetSummary(
            totalBalance: totalBalance,
            balanceByType: balanceByType,
            countByType: countByType,
            totalAssets: assets.length,
          );

          return Right(summary);
        },
      );
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định khi lấy tổng quan tài sản: $e'));
    }
  }
}

class GetAssetSummaryParams extends Equatable {
  final String userId;

  const GetAssetSummaryParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}