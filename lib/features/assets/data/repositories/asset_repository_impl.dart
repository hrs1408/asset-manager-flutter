import 'package:dartz/dartz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/firestore_service.dart';
import '../../domain/entities/asset.dart';
import '../../domain/entities/asset_type.dart';
import '../../domain/repositories/asset_repository.dart';
import '../models/asset_model.dart';

class AssetRepositoryImpl implements AssetRepository {
  final FirestoreService _firestoreService;

  AssetRepositoryImpl({
    required FirestoreService firestoreService,
  }) : _firestoreService = firestoreService;

  @override
  Future<Either<Failure, Asset>> createAsset(Asset asset) async {
    try {
      final assetModel = AssetModel.fromEntity(asset);
      final docId = await _firestoreService.createDocument(
        AppConstants.assetsCollection,
        assetModel.toFirestore(),
      );

      // Lấy lại document để có timestamp chính xác
      final doc = await _firestoreService.getDocument(
        AppConstants.assetsCollection,
        docId,
      );

      final createdAsset = AssetModel.fromFirestore(doc);
      return Right(createdAsset.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Asset>>> getAssets(String userId) async {
    try {
      final querySnapshot = await _firestoreService.getCollection(
        AppConstants.assetsCollection,
      );

      final assets = querySnapshot.docs
          .map((doc) => AssetModel.fromFirestore(doc).toEntity())
          .toList();

      // Sắp xếp theo thời gian tạo mới nhất
      assets.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return Right(assets);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Asset>> getAssetById(String assetId) async {
    try {
      final doc = await _firestoreService.getDocument(
        AppConstants.assetsCollection,
        assetId,
      );

      if (!doc.exists) {
        return const Left(NotFoundFailure('Asset not found'));
      }

      final asset = AssetModel.fromFirestore(doc);
      return Right(asset.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Asset>> updateAsset(Asset asset) async {
    try {
      final assetModel = AssetModel.fromEntity(asset);
      await _firestoreService.updateDocument(
        AppConstants.assetsCollection,
        asset.id,
        assetModel.toFirestoreUpdate(),
      );

      // Lấy lại document để có timestamp chính xác
      final doc = await _firestoreService.getDocument(
        AppConstants.assetsCollection,
        asset.id,
      );

      final updatedAsset = AssetModel.fromFirestore(doc);
      return Right(updatedAsset.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAsset(String assetId) async {
    try {
      // Kiểm tra xem asset có đang được sử dụng trong transaction không
      final isInUse = await _isAssetInUse(assetId);
      if (isInUse) {
        return const Left(ValidationFailure(
          'Không thể xóa tài sản đang được sử dụng trong giao dịch'
        ));
      }

      await _firestoreService.deleteDocument(
        AppConstants.assetsCollection,
        assetId,
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Asset>> updateAssetBalance(
    String assetId,
    double newBalance,
  ) async {
    try {
      await _firestoreService.updateDocument(
        AppConstants.assetsCollection,
        assetId,
        {
          'balance': newBalance,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Lấy lại document để có timestamp chính xác
      final doc = await _firestoreService.getDocument(
        AppConstants.assetsCollection,
        assetId,
      );

      final updatedAsset = AssetModel.fromFirestore(doc);
      return Right(updatedAsset.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getAssetSummaryByType(
    String userId,
  ) async {
    try {
      final querySnapshot = await _firestoreService.getCollection(
        AppConstants.assetsCollection,
      );

      final Map<String, double> summary = {};

      // Khởi tạo tất cả các loại tài sản với giá trị 0
      for (final assetType in AssetType.values) {
        summary[assetType.displayName] = 0.0;
      }

      // Tính tổng theo từng loại
      for (final doc in querySnapshot.docs) {
        final asset = AssetModel.fromFirestore(doc);
        final typeName = asset.type.displayName;
        summary[typeName] = (summary[typeName] ?? 0.0) + asset.balance;
      }

      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  /// Kiểm tra asset có đang được sử dụng trong transaction không
  Future<bool> _isAssetInUse(String assetId) async {
    try {
      final querySnapshot = await _firestoreService.getDocumentsWhere(
        AppConstants.transactionsCollection,
        field: 'assetId',
        isEqualTo: assetId,
        limit: 1,
      );

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Nếu có lỗi, giả sử asset đang được sử dụng để an toàn
      return true;
    }
  }
}