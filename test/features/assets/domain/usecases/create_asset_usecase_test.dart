import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/core/error/failures.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset_type.dart';
import 'package:quan_ly_tai_san/features/assets/domain/repositories/asset_repository.dart';
import 'package:quan_ly_tai_san/features/assets/domain/usecases/create_asset_usecase.dart';
import '../../../../helpers/test_helper.dart';

class MockAssetRepository extends Mock implements AssetRepository {}

void main() {
  setUpAll(() {
    registerFallbackValues();
  });
  late CreateAssetUseCase usecase;
  late MockAssetRepository mockAssetRepository;

  setUp(() {
    mockAssetRepository = MockAssetRepository();
    usecase = CreateAssetUseCase(mockAssetRepository);
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

  group('CreateAssetUseCase', () {
    test('should create asset successfully', () async {
      // arrange
      when(() => mockAssetRepository.createAsset(any()))
          .thenAnswer((_) async => Right(tAsset));

      // act
      final result = await usecase(CreateAssetParams(asset: tAsset));

      // assert
      expect(result, Right(tAsset));
      verify(() => mockAssetRepository.createAsset(tAsset));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return ValidationFailure when asset data is invalid', () async {
      // arrange
      const tFailure = ValidationFailure('Asset name cannot be empty');
      final tInvalidAsset = tAsset.copyWith(name: '');
      when(() => mockAssetRepository.createAsset(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(CreateAssetParams(asset: tInvalidAsset));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.createAsset(tInvalidAsset));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const tFailure = ServerFailure('Failed to create asset');
      when(() => mockAssetRepository.createAsset(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(CreateAssetParams(asset: tAsset));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.createAsset(tAsset));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockAssetRepository.createAsset(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(CreateAssetParams(asset: tAsset));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.createAsset(tAsset));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return AuthFailure when user is not authenticated', () async {
      // arrange
      const tFailure = AuthFailure('User not authenticated');
      when(() => mockAssetRepository.createAsset(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(CreateAssetParams(asset: tAsset));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.createAsset(tAsset));
      verifyNoMoreInteractions(mockAssetRepository);
    });
  });
}