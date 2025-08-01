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

  /// Nộp tiền vào tài sản
  Future<Either<Failure, Asset>> depositToAsset(String assetId, double amount);

  /// Nộp tiền vào tài sản với nguồn và ghi chú
  Future<Either<Failure, Asset>> depositToAssetWithDetails({
    required String assetId,
    required double amount,
    required String depositSource,
    String? notes,
  });

  /// Chuyển tiền giữa các tài sản
  Future<Either<Failure, Map<String, Asset>>> transferBetweenAssets({
    required String fromAssetId,
    required String toAssetId,
    required double amount,
    String? notes,
  });

  /// Lấy tổng giá trị tài sản theo loại
  Future<Either<Failure, Map<String, double>>> getAssetSummaryByType(String userId);
}