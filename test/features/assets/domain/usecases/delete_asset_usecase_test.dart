import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/core/error/failures.dart';
import 'package:quan_ly_tai_san/features/assets/domain/repositories/asset_repository.dart';
import 'package:quan_ly_tai_san/features/assets/domain/usecases/delete_asset_usecase.dart';

class MockAssetRepository extends Mock implements AssetRepository {}

void main() {
  late DeleteAssetUseCase usecase;
  late MockAssetRepository mockAssetRepository;

  setUp(() {
    mockAssetRepository = MockAssetRepository();
    usecase = DeleteAssetUseCase(mockAssetRepository);
  });

  const tAssetId = 'test-asset-id';

  group('DeleteAssetUseCase', () {
    test('should delete asset successfully', () async {
      // arrange
      when(() => mockAssetRepository.deleteAsset(any()))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(const DeleteAssetParams(assetId: tAssetId));

      // assert
      expect(result, const Right(null));
      verify(() => mockAssetRepository.deleteAsset(tAssetId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return NotFoundFailure when asset does not exist', () async {
      // arrange
      const tFailure = NotFoundFailure('Asset not found');
      when(() => mockAssetRepository.deleteAsset(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const DeleteAssetParams(assetId: tAssetId));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.deleteAsset(tAssetId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return ValidationFailure when asset is being used in transactions', () async {
      // arrange
      const tFailure = ValidationFailure('Cannot delete asset that has transactions');
      when(() => mockAssetRepository.deleteAsset(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const DeleteAssetParams(assetId: tAssetId));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.deleteAsset(tAssetId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const tFailure = ServerFailure('Failed to delete asset');
      when(() => mockAssetRepository.deleteAsset(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const DeleteAssetParams(assetId: tAssetId));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.deleteAsset(tAssetId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockAssetRepository.deleteAsset(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const DeleteAssetParams(assetId: tAssetId));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.deleteAsset(tAssetId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return AuthFailure when user is not authenticated', () async {
      // arrange
      const tFailure = AuthFailure('User not authenticated');
      when(() => mockAssetRepository.deleteAsset(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const DeleteAssetParams(assetId: tAssetId));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.deleteAsset(tAssetId));
      verifyNoMoreInteractions(mockAssetRepository);
    });
  });
}