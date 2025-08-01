import 'package:equatable/equatable.dart';
import '../../domain/entities/asset.dart';

abstract class AssetState extends Equatable {
  const AssetState();

  @override
  List<Object?> get props => [];
}

class AssetInitial extends AssetState {
  const AssetInitial();
}

class AssetLoading extends AssetState {
  const AssetLoading();
}

class AssetRefreshing extends AssetState {
  final List<Asset> assets;

  const AssetRefreshing({required this.assets});

  @override
  List<Object> get props => [assets];
}

class AssetLoaded extends AssetState {
  final List<Asset> assets;

  const AssetLoaded({required this.assets});

  @override
  List<Object> get props => [assets];
}

class AssetEmpty extends AssetState {
  const AssetEmpty();
}

class AssetError extends AssetState {
  final String message;

  const AssetError({required this.message});

  @override
  List<Object> get props => [message];
}

class AssetOperationLoading extends AssetState {
  final List<Asset> assets;
  final String operation;

  const AssetOperationLoading({
    required this.assets,
    required this.operation,
  });

  @override
  List<Object> get props => [assets, operation];
}

class AssetOperationSuccess extends AssetState {
  final List<Asset> assets;
  final String message;

  const AssetOperationSuccess({
    required this.assets,
    required this.message,
  });

  @override
  List<Object> get props => [assets, message];
}

class AssetDetailLoading extends AssetState {
  const AssetDetailLoading();
}

class AssetDetailLoaded extends AssetState {
  final Asset asset;

  const AssetDetailLoaded({required this.asset});

  @override
  List<Object> get props => [asset];
}