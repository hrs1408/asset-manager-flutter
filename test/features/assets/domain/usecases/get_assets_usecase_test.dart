import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/core/error/failures.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset_type.dart';
import 'package:quan_ly_tai_san/features/assets/domain/repositories/asset_repository.dart';
import 'package:quan_ly_tai_san/features/assets/domain/usecases/get_assets_usecase.dart';

class MockAssetRepository extends Mock implements AssetRepository {}

void main() {
  late GetAssetsUseCase usecase;
  late MockAssetRepository mockAssetRepository;

  setUp(() {
    mockAssetRepository = MockAssetRepository();
    usecase = GetAssetsUseCase(mockAssetRepository);
  });

  const tUserId = 'test-user-id';
  final tDateTime = DateTime(2024, 1, 1);
  
  final tAssets = [
    Asset(
      id: '1',
      userId: tUserId,
      name: 'Tài khoản thanh toán',
      type: AssetType.paymentAccount,
      balance: 1000000,
      createdAt: tDateTime,
      updatedAt: tDateTime,
    ),
    Asset(
      id: '2',
      userId: tUserId,
      name: 'Tài khoản tiết kiệm',
      type: AssetType.savingsAccount,
      balance: 5000000,
      createdAt: tDateTime.add(const Duration(days: 1)),
      updatedAt: tDateTime.add(const Duration(days: 1)),
    ),
    Asset(
      id: '3',
      userId: tUserId,
      name: 'Vàng SJC',
      type: AssetType.gold,
      balance: 2000000,
      createdAt: tDateTime.add(const Duration(days: 2)),
      updatedAt: tDateTime.add(const Duration(days: 2)),
    ),
  ];

  group('GetAssetsUseCase', () {
    test('should get assets from the repository', () async {
      // arrange
      when(() => mockAssetRepository.getAssets(any()))
          .thenAnswer((_) async => Right(tAssets));

      // act
      final result = await usecase(const GetAssetsParams(userId: tUserId));

      // assert
      expect(result, Right(tAssets));
      verify(() => mockAssetRepository.getAssets(tUserId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should filter assets by type when assetType is specified', () async {
      // arrange
      when(() => mockAssetRepository.getAssets(any()))
          .thenAnswer((_) async => Right(tAssets));

      // act
      final result = await usecase(const GetAssetsParams(
        userId: tUserId,
        assetType: AssetType.paymentAccount,
      ));

      // assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (assets) {
          expect(assets.length, 1);
          expect(assets.first.type, AssetType.paymentAccount);
        },
      );
      verify(() => mockAssetRepository.getAssets(tUserId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should filter assets by search query when searchQuery is specified', () async {
      // arrange
      when(() => mockAssetRepository.getAssets(any()))
          .thenAnswer((_) async => Right(tAssets));

      // act
      final result = await usecase(const GetAssetsParams(
        userId: tUserId,
        searchQuery: 'tài khoản',
      ));

      // assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (assets) {
          expect(assets.length, 2);
          expect(assets.every((asset) => asset.name.toLowerCase().contains('tài khoản')), true);
        },
      );
      verify(() => mockAssetRepository.getAssets(tUserId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should sort assets by name in ascending order', () async {
      // arrange
      when(() => mockAssetRepository.getAssets(any()))
          .thenAnswer((_) async => Right(tAssets));

      // act
      final result = await usecase(const GetAssetsParams(
        userId: tUserId,
        sortBy: AssetSortBy.name,
        sortOrder: SortOrder.ascending,
      ));

      // assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (assets) {
          expect(assets[0].name, 'Tài khoản thanh toán');
          expect(assets[1].name, 'Tài khoản tiết kiệm');
          expect(assets[2].name, 'Vàng SJC');
        },
      );
      verify(() => mockAssetRepository.getAssets(tUserId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should sort assets by balance in descending order', () async {
      // arrange
      when(() => mockAssetRepository.getAssets(any()))
          .thenAnswer((_) async => Right(tAssets));

      // act
      final result = await usecase(const GetAssetsParams(
        userId: tUserId,
        sortBy: AssetSortBy.balance,
        sortOrder: SortOrder.descending,
      ));

      // assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (assets) {
          expect(assets[0].balance, 5000000);
          expect(assets[1].balance, 2000000);
          expect(assets[2].balance, 1000000);
        },
      );
      verify(() => mockAssetRepository.getAssets(tUserId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const tFailure = ServerFailure('Server error');
      when(() => mockAssetRepository.getAssets(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const GetAssetsParams(userId: tUserId));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.getAssets(tUserId));
      verifyNoMoreInteractions(mockAssetRepository);
    });

    test('should return empty list when no assets found', () async {
      // arrange
      when(() => mockAssetRepository.getAssets(any()))
          .thenAnswer((_) async => Right(<Asset>[]));

      // act
      final result = await usecase(const GetAssetsParams(userId: tUserId));

      // assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (assets) => expect(assets, isEmpty),
      );
      verify(() => mockAssetRepository.getAssets(tUserId));
      verifyNoMoreInteractions(mockAssetRepository);
    });
  });
}