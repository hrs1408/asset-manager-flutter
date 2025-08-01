import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/core/error/failures.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset_type.dart';
import 'package:quan_ly_tai_san/features/assets/domain/repositories/asset_repository.dart';
import 'package:quan_ly_tai_san/features/assets/domain/usecases/update_asset_usecase.dart';
import '../../../../helpers/test_helper.dart';

class MockAssetRepository extends Mock implements AssetRepository {}

void main() {
  setUpAll(() {
    registerFallbackValues();
  });
  late UpdateAssetUseCase usecase;
  late MockAssetRepository mockAssetRepository;

  setUp(() {
    mockAssetRepository = MockAssetRepository();
    usecase = UpdateAssetUseCase(mockAssetRepository);
  });

  final tDateTime = DateTime(2024, 1, 1);
  final tAsset = Asset(
    id: 'test-id',
    userId: 'test-user-id',
    name: 'Tài khoản thanh toán',
    type: AssetType.paymentAccount,
    balance: 1000000,
    createdAt: tDateTime,
    updatedAt: tDateTime,
  );

  final tUpdatedAsset = tAsset.copyWith(
    name: 'Tài khoản thanh toán cập nhật',
    balance: 2000000,
    updatedAt: tDateTime.add(const Duration(hours: 1)),
  );

  group('UpdateAssetUseCase', () {
    test('should update asset successfully', () async {
      // arrange
      when(() => mockAssetRepository.updateAsset(any()))
          .thenAnswer((_) async => Right(tUpdatedAsset));

      // act
      final result = await usecase(UpdateAssetParams(asset: tUpdatedAsset));

      // assert
      expect(result, Right(tUpdatedAsset));
      verify(() => mockAssetRepository.updateAsset(tUpdatedAsset));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return ValidationFailure when asset data is invalid', () async {
      // arrange
      const tFailure = ValidationFailure('Asset name cannot be empty');
      final tInvalidAsset = tAsset.copyWith(name: '');
      when(() => mockAssetRepository.updateAsset(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(UpdateAssetParams(asset: tInvalidAsset));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.updateAsset(tInvalidAsset));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return NotFoundFailure when asset does not exist', () async {
      // arrange
      const tFailure = NotFoundFailure('Asset not found');
      when(() => mockAssetRepository.updateAsset(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(UpdateAssetParams(asset: tUpdatedAsset));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.updateAsset(tUpdatedAsset));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const tFailure = ServerFailure('Failed to update asset');
      when(() => mockAssetRepository.updateAsset(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(UpdateAssetParams(asset: tUpdatedAsset));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.updateAsset(tUpdatedAsset));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockAssetRepository.updateAsset(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(UpdateAssetParams(asset: tUpdatedAsset));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.updateAsset(tUpdatedAsset));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return AuthFailure when user is not authenticated', () async {
      // arrange
      const tFailure = AuthFailure('User not authenticated');
      when(() => mockAssetRepository.updateAsset(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(UpdateAssetParams(asset: tUpdatedAsset));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.updateAsset(tUpdatedAsset));
      verifyNoMoreInteractions(mockAssetRepository);
    });
  });
}