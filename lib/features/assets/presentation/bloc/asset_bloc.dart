import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/asset.dart';
import '../../domain/usecases/usecases.dart';
import 'asset_event.dart';
import 'asset_state.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  final GetAssetsUseCase getAssetsUseCase;
  final CreateAssetUseCase createAssetUseCase;
  final UpdateAssetUseCase updateAssetUseCase;
  final DeleteAssetUseCase deleteAssetUseCase;
  final GetAssetByIdUseCase getAssetByIdUseCase;
  final DepositToAssetUsecase depositToAssetUsecase;
  final DepositToAssetWithDetailsUsecase depositToAssetWithDetailsUsecase;
  final TransferBetweenAssetsUsecase transferBetweenAssetsUsecase;

  AssetBloc({
    required this.getAssetsUseCase,
    required this.createAssetUseCase,
    required this.updateAssetUseCase,
    required this.deleteAssetUseCase,
    required this.getAssetByIdUseCase,
    required this.depositToAssetUsecase,
    required this.depositToAssetWithDetailsUsecase,
    required this.transferBetweenAssetsUsecase,
  }) : super(const AssetInitial()) {
    on<AssetLoadRequested>(_onAssetLoadRequested);
    on<AssetCreateRequested>(_onAssetCreateRequested);
    on<AssetUpdateRequested>(_onAssetUpdateRequested);
    on<AssetDeleteRequested>(_onAssetDeleteRequested);
    on<AssetGetByIdRequested>(_onAssetGetByIdRequested);
    on<AssetRefreshRequested>(_onAssetRefreshRequested);
    on<AssetDepositRequested>(_onAssetDepositRequested);
    on<AssetDepositWithDetailsRequested>(_onAssetDepositWithDetailsRequested);
    on<AssetTransferRequested>(_onAssetTransferRequested);
  }

  Future<void> _onAssetLoadRequested(
    AssetLoadRequested event,
    Emitter<AssetState> emit,
  ) async {
    emit(const AssetLoading());

    final result = await getAssetsUseCase(
      GetAssetsParams(
        userId: event.userId,
        assetType: event.filterByType,
        searchQuery: event.searchQuery,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      ),
    );

    result.fold(
      (failure) => emit(AssetError(message: failure.message)),
      (assets) {
        if (assets.isEmpty) {
          emit(const AssetEmpty());
        } else {
          emit(AssetLoaded(assets: assets));
        }
      },
    );
  }

  Future<void> _onAssetCreateRequested(
    AssetCreateRequested event,
    Emitter<AssetState> emit,
  ) async {
    final currentState = state;
    final currentAssets = _getCurrentAssets(currentState);
    
    emit(AssetOperationLoading(
      assets: currentAssets,
      operation: 'Đang tạo tài sản...',
    ));

    final result = await createAssetUseCase(
      CreateAssetParams(asset: event.asset),
    );

    result.fold(
      (failure) => emit(AssetError(message: failure.message)),
      (newAsset) {
        final updatedAssets = [...currentAssets, newAsset];
        emit(AssetOperationSuccess(
          assets: updatedAssets,
          message: 'Tạo tài sản thành công',
        ));
        // Automatically transition to loaded state
        emit(AssetLoaded(assets: updatedAssets));
      },
    );
  }

  Future<void> _onAssetUpdateRequested(
    AssetUpdateRequested event,
    Emitter<AssetState> emit,
  ) async {
    final currentState = state;
    final currentAssets = _getCurrentAssets(currentState);
    
    emit(AssetOperationLoading(
      assets: currentAssets,
      operation: 'Đang cập nhật tài sản...',
    ));

    final result = await updateAssetUseCase(
      UpdateAssetParams(asset: event.asset),
    );

    result.fold(
      (failure) => emit(AssetError(message: failure.message)),
      (updatedAsset) {
        final updatedAssets = currentAssets
            .map((asset) => asset.id == updatedAsset.id ? updatedAsset : asset)
            .toList();
        emit(AssetOperationSuccess(
          assets: updatedAssets,
          message: 'Cập nhật tài sản thành công',
        ));
        // Automatically transition to loaded state
        emit(AssetLoaded(assets: updatedAssets));
      },
    );
  }

  Future<void> _onAssetDeleteRequested(
    AssetDeleteRequested event,
    Emitter<AssetState> emit,
  ) async {
    final currentState = state;
    final currentAssets = _getCurrentAssets(currentState);
    
    emit(AssetOperationLoading(
      assets: currentAssets,
      operation: 'Đang xóa tài sản...',
    ));

    final result = await deleteAssetUseCase(
      DeleteAssetParams(assetId: event.assetId),
    );

    result.fold(
      (failure) => emit(AssetError(message: failure.message)),
      (_) {
        final updatedAssets = currentAssets
            .where((asset) => asset.id != event.assetId)
            .toList();
        emit(AssetOperationSuccess(
          assets: updatedAssets,
          message: 'Xóa tài sản thành công',
        ));
        // Check if list is empty after deletion
        if (updatedAssets.isEmpty) {
          emit(const AssetEmpty());
        } else {
          emit(AssetLoaded(assets: updatedAssets));
        }
      },
    );
  }

  Future<void> _onAssetGetByIdRequested(
    AssetGetByIdRequested event,
    Emitter<AssetState> emit,
  ) async {
    emit(const AssetDetailLoading());

    final result = await getAssetByIdUseCase(
      GetAssetByIdParams(assetId: event.assetId),
    );

    result.fold(
      (failure) => emit(AssetError(message: failure.message)),
      (asset) => emit(AssetDetailLoaded(asset: asset)),
    );
  }

  Future<void> _onAssetRefreshRequested(
    AssetRefreshRequested event,
    Emitter<AssetState> emit,
  ) async {
    final currentState = state;
    final currentAssets = _getCurrentAssets(currentState);
    
    emit(AssetRefreshing(assets: currentAssets));

    final result = await getAssetsUseCase(
      GetAssetsParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(AssetError(message: failure.message)),
      (assets) {
        if (assets.isEmpty) {
          emit(const AssetEmpty());
        } else {
          emit(AssetLoaded(assets: assets));
        }
      },
    );
  }

  Future<void> _onAssetDepositRequested(
    AssetDepositRequested event,
    Emitter<AssetState> emit,
  ) async {
    final currentState = state;
    final currentAssets = _getCurrentAssets(currentState);
    
    emit(AssetOperationLoading(
      assets: currentAssets,
      operation: 'Đang nộp tiền vào tài sản...',
    ));

    final result = await depositToAssetUsecase(
      DepositToAssetParams(
        assetId: event.assetId,
        amount: event.amount,
      ),
    );

    result.fold(
      (failure) => emit(AssetError(message: failure.message)),
      (updatedAsset) {
        final updatedAssets = currentAssets
            .map((asset) => asset.id == updatedAsset.id ? updatedAsset : asset)
            .toList();
        emit(AssetOperationSuccess(
          assets: updatedAssets,
          message: 'Nộp tiền thành công',
        ));
        // Automatically transition to loaded state
        emit(AssetLoaded(assets: updatedAssets));
      },
    );
  }

  Future<void> _onAssetDepositWithDetailsRequested(
    AssetDepositWithDetailsRequested event,
    Emitter<AssetState> emit,
  ) async {
    final currentState = state;
    final currentAssets = _getCurrentAssets(currentState);
    
    emit(AssetOperationLoading(
      assets: currentAssets,
      operation: 'Đang nộp tiền vào tài sản...',
    ));

    final result = await depositToAssetWithDetailsUsecase(
      DepositToAssetWithDetailsParams(
        assetId: event.assetId,
        amount: event.amount,
        depositSource: event.depositSource,
        notes: event.notes,
      ),
    );

    result.fold(
      (failure) => emit(AssetError(message: failure.message)),
      (updatedAsset) {
        final updatedAssets = currentAssets
            .map((asset) => asset.id == updatedAsset.id ? updatedAsset : asset)
            .toList();
        emit(AssetOperationSuccess(
          assets: updatedAssets,
          message: 'Nộp tiền thành công',
        ));
        // Automatically transition to loaded state
        emit(AssetLoaded(assets: updatedAssets));
      },
    );
  }

  Future<void> _onAssetTransferRequested(
    AssetTransferRequested event,
    Emitter<AssetState> emit,
  ) async {
    final currentState = state;
    final currentAssets = _getCurrentAssets(currentState);
    
    emit(AssetOperationLoading(
      assets: currentAssets,
      operation: 'Đang chuyển tiền giữa tài sản...',
    ));

    final result = await transferBetweenAssetsUsecase(
      TransferBetweenAssetsParams(
        fromAssetId: event.fromAssetId,
        toAssetId: event.toAssetId,
        amount: event.amount,
        notes: event.notes,
      ),
    );

    result.fold(
      (failure) => emit(AssetError(message: failure.message)),
      (transferResult) {
        final fromAsset = transferResult['from']!;
        final toAsset = transferResult['to']!;
        
        final updatedAssets = currentAssets.map((asset) {
          if (asset.id == fromAsset.id) return fromAsset;
          if (asset.id == toAsset.id) return toAsset;
          return asset;
        }).toList();
        
        emit(AssetOperationSuccess(
          assets: updatedAssets,
          message: 'Chuyển tiền thành công',
        ));
        // Automatically transition to loaded state
        emit(AssetLoaded(assets: updatedAssets));
      },
    );
  }

  List<Asset> _getCurrentAssets(AssetState state) {
    if (state is AssetLoaded) {
      return state.assets;
    } else if (state is AssetRefreshing) {
      return state.assets;
    } else if (state is AssetOperationLoading) {
      return state.assets;
    } else if (state is AssetOperationSuccess) {
      return state.assets;
    }
    return <Asset>[];
  }
}