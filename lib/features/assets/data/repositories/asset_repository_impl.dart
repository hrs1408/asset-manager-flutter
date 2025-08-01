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
  Future<Either<Failure, Asset>> depositToAsset(
    String assetId,
    double amount,
  ) async {
    try {
      if (amount <= 0) {
        return const Left(ValidationFailure('Số tiền nộp phải lớn hơn 0'));
      }

      // Lấy thông tin tài sản hiện tại
      final assetResult = await getAssetById(assetId);
      if (assetResult.isLeft()) {
        return assetResult;
      }

      final currentAsset = assetResult.getOrElse(() => throw Exception());
      final newBalance = currentAsset.balance + amount;

      // Cập nhật số dư mới
      return await updateAssetBalance(assetId, newBalance);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Asset>> depositToAssetWithDetails({
    required String assetId,
    required double amount,
    required String depositSource,
    String? notes,
  }) async {
    try {
      if (amount <= 0) {
        return const Left(ValidationFailure('Số tiền nộp phải lớn hơn 0'));
      }

      // Lấy thông tin tài sản hiện tại
      final assetResult = await getAssetById(assetId);
      if (assetResult.isLeft()) {
        return assetResult;
      }

      final currentAsset = assetResult.getOrElse(() => throw Exception());
      final newBalance = currentAsset.balance + amount;

      // Tạo transaction record cho việc nộp tiền
      await _createDepositTransaction(
        assetId: assetId,
        amount: amount,
        depositSource: depositSource,
        notes: notes,
      );

      // Cập nhật số dư mới
      return await updateAssetBalance(assetId, newBalance);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, Asset>>> transferBetweenAssets({
    required String fromAssetId,
    required String toAssetId,
    required double amount,
    String? notes,
  }) async {
    try {
      if (amount <= 0) {
        return const Left(ValidationFailure('Số tiền chuyển phải lớn hơn 0'));
      }

      if (fromAssetId == toAssetId) {
        return const Left(ValidationFailure('Không thể chuyển tiền cho cùng một tài sản'));
      }

      // Lấy thông tin cả hai tài sản
      final fromAssetResult = await getAssetById(fromAssetId);
      final toAssetResult = await getAssetById(toAssetId);

      if (fromAssetResult.isLeft()) {
        return Left(fromAssetResult.fold((l) => l, (r) => throw Exception()));
      }
      if (toAssetResult.isLeft()) {
        return Left(toAssetResult.fold((l) => l, (r) => throw Exception()));
      }

      final fromAsset = fromAssetResult.getOrElse(() => throw Exception());
      final toAsset = toAssetResult.getOrElse(() => throw Exception());

      // Kiểm tra số dư đủ để chuyển
      if (fromAsset.balance < amount) {
        return const Left(ValidationFailure('Số dư không đủ để thực hiện chuyển tiền'));
      }

      // Tạo transaction record cho việc chuyển tiền
      await _createTransferTransaction(
        fromAssetId: fromAssetId,
        toAssetId: toAssetId,
        amount: amount,
        notes: notes,
      );

      // Cập nhật số dư cho cả hai tài sản
      final newFromBalance = fromAsset.balance - amount;
      final newToBalance = toAsset.balance + amount;

      final updatedFromAssetResult = await updateAssetBalance(fromAssetId, newFromBalance);
      final updatedToAssetResult = await updateAssetBalance(toAssetId, newToBalance);

      if (updatedFromAssetResult.isLeft()) {
        return Left(updatedFromAssetResult.fold((l) => l, (r) => throw Exception()));
      }
      if (updatedToAssetResult.isLeft()) {
        return Left(updatedToAssetResult.fold((l) => l, (r) => throw Exception()));
      }

      final updatedFromAsset = updatedFromAssetResult.getOrElse(() => throw Exception());
      final updatedToAsset = updatedToAssetResult.getOrElse(() => throw Exception());

      return Right({
        'from': updatedFromAsset,
        'to': updatedToAsset,
      });
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

  /// Tạo transaction record cho việc nộp tiền
  Future<void> _createDepositTransaction({
    required String assetId,
    required double amount,
    required String depositSource,
    String? notes,
  }) async {
    final transactionData = {
      'userId': _firestoreService.currentUserId,
      'assetId': assetId,
      'categoryId': 'deposit', // Special category for deposits
      'amount': amount,
      'description': 'Nộp tiền từ $depositSource',
      'date': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'deposit',
      'depositSource': depositSource,
      'notes': notes,
    };

    await _firestoreService.createDocument(
      AppConstants.transactionsCollection,
      transactionData,
    );
  }

  /// Tạo transaction record cho việc chuyển tiền
  Future<void> _createTransferTransaction({
    required String fromAssetId,
    required String toAssetId,
    required double amount,
    String? notes,
  }) async {
    // Tạo transaction cho tài sản nguồn (trừ tiền)
    final fromTransactionData = {
      'userId': _firestoreService.currentUserId,
      'assetId': fromAssetId,
      'categoryId': 'transfer', // Special category for transfers
      'amount': -amount, // Negative amount for outgoing transfer
      'description': 'Chuyển tiền đi',
      'date': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'transfer',
      'toAssetId': toAssetId,
      'notes': notes,
    };

    // Tạo transaction cho tài sản đích (cộng tiền)
    final toTransactionData = {
      'userId': _firestoreService.currentUserId,
      'assetId': toAssetId,
      'categoryId': 'transfer', // Special category for transfers
      'amount': amount, // Positive amount for incoming transfer
      'description': 'Nhận tiền chuyển',
      'date': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'transfer',
      'toAssetId': fromAssetId, // Reference to source asset
      'notes': notes,
    };

    // Tạo cả hai transaction
    await Future.wait([
      _firestoreService.createDocument(
        AppConstants.transactionsCollection,
        fromTransactionData,
      ),
      _firestoreService.createDocument(
        AppConstants.transactionsCollection,
        toTransactionData,
      ),
    ]);
  }
}