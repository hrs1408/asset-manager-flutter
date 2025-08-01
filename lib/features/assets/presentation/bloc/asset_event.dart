import 'package:equatable/equatable.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_type.dart';
import '../../domain/usecases/get_assets_usecase.dart';

abstract class AssetEvent extends Equatable {
  const AssetEvent();

  @override
  List<Object?> get props => [];
}

class AssetLoadRequested extends AssetEvent {
  final String userId;
  final AssetType? filterByType;
  final String? searchQuery;
  final AssetSortBy sortBy;
  final SortOrder sortOrder;

  const AssetLoadRequested({
    required this.userId,
    this.filterByType,
    this.searchQuery,
    this.sortBy = AssetSortBy.updatedAt,
    this.sortOrder = SortOrder.descending,
  });

  @override
  List<Object?> get props => [
        userId,
        filterByType,
        searchQuery,
        sortBy,
        sortOrder,
      ];
}

class AssetCreateRequested extends AssetEvent {
  final Asset asset;

  const AssetCreateRequested({required this.asset});

  @override
  List<Object> get props => [asset];
}

class AssetUpdateRequested extends AssetEvent {
  final Asset asset;

  const AssetUpdateRequested({required this.asset});

  @override
  List<Object> get props => [asset];
}

class AssetDeleteRequested extends AssetEvent {
  final String assetId;

  const AssetDeleteRequested({required this.assetId});

  @override
  List<Object> get props => [assetId];
}

class AssetGetByIdRequested extends AssetEvent {
  final String assetId;

  const AssetGetByIdRequested({required this.assetId});

  @override
  List<Object> get props => [assetId];
}

class AssetRefreshRequested extends AssetEvent {
  final String userId;

  const AssetRefreshRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}