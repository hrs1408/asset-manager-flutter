import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/asset.dart';

abstract class AssetRepository {
  /// Tạo tài sản mới
  Future<Either<Failure, Asset>> createAsset(Asset asset);

  /// Lấy danh sách tài sản của người dùng
  Future<Either<Failure, List<Asset>>> getAssets(String userId);

  /// Lấy tài sản theo ID
  Future<Either<Failure, Asset>> getAssetById(String assetId);

  /// Cập nhật thông tin tài sản
  Future<Either<Failure, Asset>> updateAsset(Asset asset);

  /// Xóa tài sản
  Future<Either<Failure, void>> deleteAsset(String assetId);

  /// Cập nhật số dư tài sản
  Future<Either<Failure, Asset>> updateAssetBalance(String assetId, double newBalance);

  /// Lấy tổng giá trị tài sản theo loại
  Future<Either<Failure, Map<String, double>>> getAssetSummaryByType(String userId);
}