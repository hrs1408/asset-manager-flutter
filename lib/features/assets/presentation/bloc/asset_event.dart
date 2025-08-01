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

class AssetDepositRequested extends AssetEvent {
  final String assetId;
  final double amount;

  const AssetDepositRequested({
    required this.assetId,
    required this.amount,
  });

  @override
  List<Object> get props => [assetId, amount];
}

class AssetDepositWithDetailsRequested extends AssetEvent {
  final String assetId;
  final double amount;
  final String depositSource;
  final String? notes;

  const AssetDepositWithDetailsRequested({
    required this.assetId,
    required this.amount,
    required this.depositSource,
    this.notes,
  });

  @override
  List<Object?> get props => [assetId, amount, depositSource, notes];
}

class AssetTransferRequested extends AssetEvent {
  final String fromAssetId;
  final String toAssetId;
  final double amount;
  final String? notes;

  const AssetTransferRequested({
    required this.fromAssetId,
    required this.toAssetId,
    required this.amount,
    this.notes,
  });

  @override
  List<Object?> get props => [fromAssetId, toAssetId, amount, notes];
}