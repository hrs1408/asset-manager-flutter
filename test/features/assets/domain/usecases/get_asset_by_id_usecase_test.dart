import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/core/error/failures.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset_type.dart';
import 'package:quan_ly_tai_san/features/assets/domain/repositories/asset_repository.dart';
import 'package:quan_ly_tai_san/features/assets/domain/usecases/get_asset_by_id_usecase.dart';

class MockAssetRepository extends Mock implements AssetRepository {}

void main() {
  late GetAssetByIdUseCase usecase;
  late MockAssetRepository mockAssetRepository;

  setUp(() {
    mockAssetRepository = MockAssetRepository();
    usecase = GetAssetByIdUseCase(mockAssetRepository);
  });

  const tAssetId = 'test-asset-id';
  final tDateTime = DateTime(2024, 1, 1);
  final tAsset = Asset(
    id: tAssetId,
    userId: 'test-user-id',
    name: 'Tài khoản thanh toán',
    type: AssetType.paymentAccount,
    balance: 1000000,
    createdAt: tDateTime,
    updatedAt: tDateTime,
  );

  group('GetAssetByIdUseCase', () {
    test('should get asset by id from the repository', () async {
      // arrange
      when(() => mockAssetRepository.getAssetById(any()))
          .thenAnswer((_) async => Right(tAsset));

      // act
      final result = await usecase(const GetAssetByIdParams(assetId: tAssetId));

      // assert
      expect(result, Right(tAsset));
      verify(() => mockAssetRepository.getAssetById(tAssetId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return NotFoundFailure when asset is not found', () async {
      // arrange
      const tFailure = NotFoundFailure('Asset not found');
      when(() => mockAssetRepository.getAssetById(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const GetAssetByIdParams(assetId: tAssetId));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.getAssetById(tAssetId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const tFailure = ServerFailure('Server error');
      when(() => mockAssetRepository.getAssetById(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const GetAssetByIdParams(assetId: tAssetId));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.getAssetById(tAssetId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockAssetRepository.getAssetById(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const GetAssetByIdParams(assetId: tAssetId));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.getAssetById(tAssetId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return AuthFailure when user is not authenticated', () async {
      // arrange
      const tFailure = AuthFailure('User not authenticated');
      when(() => mockAssetRepository.getAssetById(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const GetAssetByIdParams(assetId: tAssetId));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.getAssetById(tAssetId));
      verifyNoMoreInteractions(mockAssetRepository);
    });
  });
}