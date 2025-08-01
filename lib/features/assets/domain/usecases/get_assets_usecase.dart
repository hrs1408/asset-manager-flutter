import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/asset.dart';
import '../entities/asset_type.dart';
import '../repositories/asset_repository.dart';

class GetAssetsUseCase implements UseCase<List<Asset>, GetAssetsParams> {
  final AssetRepository repository;

  GetAssetsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Asset>>> call(GetAssetsParams params) async {
    final result = await repository.getAssets(params.userId);
    
    return result.map((assets) {
      var filteredAssets = assets;
      
      // Apply type filter if specified
      if (params.assetType != null) {
        filteredAssets = filteredAssets
            .where((asset) => asset.type == params.assetType)
            .toList();
      }
      
      // Apply name search filter if specified
      if (params.searchQuery != null && params.searchQuery!.isNotEmpty) {
        filteredAssets = filteredAssets
            .where((asset) => asset.name
                .toLowerCase()
                .contains(params.searchQuery!.toLowerCase()))
            .toList();
      }
      
      // Apply sorting
      switch (params.sortBy) {
        case AssetSortBy.name:
          filteredAssets.sort((a, b) => params.sortOrder == SortOrder.ascending
              ? a.name.compareTo(b.name)
              : b.name.compareTo(a.name));
          break;
        case AssetSortBy.balance:
          filteredAssets.sort((a, b) => params.sortOrder == SortOrder.ascending
              ? a.balance.compareTo(b.balance)
              : b.balance.compareTo(a.balance));
          break;
        case AssetSortBy.type:
          filteredAssets.sort((a, b) => params.sortOrder == SortOrder.ascending
              ? a.type.displayName.compareTo(b.type.displayName)
              : b.type.displayName.compareTo(a.type.displayName));
          break;
        case AssetSortBy.createdAt:
          filteredAssets.sort((a, b) => params.sortOrder == SortOrder.ascending
              ? a.createdAt.compareTo(b.createdAt)
              : b.createdAt.compareTo(a.createdAt));
          break;
        case AssetSortBy.updatedAt:
          filteredAssets.sort((a, b) => params.sortOrder == SortOrder.ascending
              ? a.updatedAt.compareTo(b.updatedAt)
              : b.updatedAt.compareTo(a.updatedAt));
          break;
      }
      
      return filteredAssets;
    });
  }
}

class GetAssetsParams extends Equatable {
  final String userId;
  final AssetType? assetType;
  final String? searchQuery;
  final AssetSortBy sortBy;
  final SortOrder sortOrder;

  const GetAssetsParams({
    required this.userId,
    this.assetType,
    this.searchQuery,
    this.sortBy = AssetSortBy.updatedAt,
    this.sortOrder = SortOrder.descending,
  });

  @override
  List<Object?> get props => [
        userId,
        assetType,
        searchQuery,
        sortBy,
        sortOrder,
      ];
}

enum AssetSortBy {
  name,
  balance,
  type,
  createdAt,
  updatedAt,
}

enum SortOrder {
  ascending,
  descending,
}