import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/core/error/failures.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset.dart';
import 'package:quan_ly_tai_san/features/assets/domain/entities/asset_type.dart';
import 'package:quan_ly_tai_san/features/assets/domain/repositories/asset_repository.dart';
import 'package:quan_ly_tai_san/features/expenses/domain/entities/transaction.dart';
import 'package:quan_ly_tai_san/features/expenses/domain/repositories/transaction_repository.dart';
import 'package:quan_ly_tai_san/features/expenses/domain/usecases/create_transaction_usecase.dart';
import '../../../../helpers/test_helper.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}
class MockAssetRepository extends Mock implements AssetRepository {}

void main() {
  setUpAll(() {
    registerFallbackValues();
  });
  late CreateTransactionUseCase usecase;
  late MockTransactionRepository mockTransactionRepository;
  late MockAssetRepository mockAssetRepository;

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    mockAssetRepository = MockAssetRepository();
    usecase = CreateTransactionUseCase(
      transactionRepository: mockTransactionRepository,
      assetRepository: mockAssetRepository,
    );
  });

  final tDateTime = DateTime(2024, 1, 1);
  const tUserId = 'test-user-id';
  const tAssetId = 'test-asset-id';
  const tCategoryId = 'test-category-id';

  final tAsset = Asset(
    id: tAssetId,
    userId: tUserId,
    name: 'Tài khoản thanh toán',
    type: AssetType.paymentAccount,
    balance: 1000000,
    createdAt: tDateTime,
    updatedAt: tDateTime,
  );

  final tTransaction = Transaction(
    id: 'test-transaction-id',
    userId: tUserId,
    assetId: tAssetId,
    categoryId: tCategoryId,
    amount: 100000,
    description: 'Mua sắm',
    date: tDateTime,
    createdAt: tDateTime,
  );

  group('CreateTransactionUseCase', () {
    test('should create transaction successfully when asset has sufficient balance', () async {
      // arrange
      when(() => mockAssetRepository.getAssetById(any()))
          .thenAnswer((_) async => Right(tAsset));
      when(() => mockTransactionRepository.createTransaction(any()))
          .thenAnswer((_) async => Right(tTransaction));
      when(() => mockAssetRepository.updateAssetBalance(any(), any()))
          .thenAnswer((_) async => Right(tAsset.copyWith(balance: 900000)));

      // act
      final result = await usecase(tTransaction);

      // assert
      expect(result, Right(tTransaction));
      verify(() => mockAssetRepository.getAssetById(tAssetId));
      verify(() => mockTransactionRepository.createTransaction(tTransaction));
      verify(() => mockAssetRepository.updateAssetBalance(tAssetId, 900000));
      verifyNoMoreInteractions(mockAssetRepository);
      verifyNoMoreInteractions(mockTransactionRepository);
    });

    test('should return ValidationFailure when asset has insufficient balance', () async {
      // arrange
      final tAssetWithLowBalance = tAsset.copyWith(balance: 50000);
      when(() => mockAssetRepository.getAssetById(any()))
          .thenAnswer((_) async => Right(tAssetWithLowBalance));

      // act
      final result = await usecase(tTransaction);

      // assert
      expect(result, const Left(ValidationFailure(
        'Số dư tài sản không đủ để thực hiện giao dịch này'
      )));
      verify(() => mockAssetRepository.getAssetById(tAssetId));
      verifyNoMoreInteractions(mockAssetRepository);
      verifyZeroInteractions(mockTransactionRepository);
    });

    test('should return ValidationFailure when asset is not found', () async {
      // arrange
      const tFailure = NotFoundFailure('Asset not found');
      when(() => mockAssetRepository.getAssetById(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tTransaction);

      // assert
      result.fold(
        (failure) {
          expect(failure, isA<NotFoundFailure>());
          expect(failure.message, 'Asset not found');
        },
        (_) => fail('Expected Left but got Right'),
      );
      verify(() => mockAssetRepository.getAssetById(tAssetId));
      verifyNoMoreInteractions(mockAssetRepository);
      verifyZeroInteractions(mockTransactionRepository);
    });

    test('should return ServerFailure when transaction creation fails', () async {
      // arrange
      const tFailure = ServerFailure('Failed to create transaction');
      when(() => mockAssetRepository.getAssetById(any()))
          .thenAnswer((_) async => Right(tAsset));
      when(() => mockTransactionRepository.createTransaction(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tTransaction);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAssetRepository.getAssetById(tAssetId));
      verify(() => mockTransactionRepository.createTransaction(tTransaction));
      verifyNoMoreInteractions(mockAssetRepository);
      verifyNoMoreInteractions(mockTransactionRepository);
    });

    test('should return ServerFailure when balance update fails after transaction creation', () async {
      // arrange
      const tFailure = ServerFailure('Failed to update balance');
      when(() => mockAssetRepository.getAssetById(any()))
          .thenAnswer((_) async => Right(tAsset));
      when(() => mockTransactionRepository.createTransaction(any()))
          .thenAnswer((_) async => Right(tTransaction));
      when(() => mockAssetRepository.updateAssetBalance(any(), any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tTransaction);

      // assert
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Giao dịch đã được tạo nhưng không thể cập nhật số dư tài sản'));
        },
        (_) => fail('Expected Left but got Right'),
      );
      verify(() => mockAssetRepository.getAssetById(tAssetId));
      verify(() => mockTransactionRepository.createTransaction(tTransaction));
      verify(() => mockAssetRepository.updateAssetBalance(tAssetId, 900000));
      verifyNoMoreInteractions(mockAssetRepository);
      verifyNoMoreInteractions(mockTransactionRepository);
    });

    test('should return ServerFailure when an unexpected error occurs', () async {
      // arrange
      when(() => mockAssetRepository.getAssetById(any()))
          .thenThrow(Exception('Unexpected error'));

      // act
      final result = await usecase(tTransaction);

      // assert
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, contains('Lỗi không xác định khi tạo giao dịch'));
        },
        (_) => fail('Expected Left but got Right'),
      );
      verify(() => mockAssetRepository.getAssetById(tAssetId));
      verifyNoMoreInteractions(mockAssetRepository);
      verifyZeroInteractions(mockTransactionRepository);
    });

    test('should handle zero amount transaction', () async {
      // arrange
      final tZeroAmountTransaction = tTransaction.copyWith(amount: 0);
      when(() => mockAssetRepository.getAssetById(any()))
          .thenAnswer((_) async => Right(tAsset));
      when(() => mockTransactionRepository.createTransaction(any()))
          .thenAnswer((_) async => Right(tZeroAmountTransaction));
      when(() => mockAssetRepository.updateAssetBalance(any(), any()))
          .thenAnswer((_) async => Right(tAsset));

      // act
      final result = await usecase(tZeroAmountTransaction);

      // assert
      expect(result, Right(tZeroAmountTransaction));
      verify(() => mockAssetRepository.getAssetById(tAssetId));
      verify(() => mockTransactionRepository.createTransaction(tZeroAmountTransaction));
      verify(() => mockAssetRepository.updateAssetBalance(tAssetId, 1000000)); // Balance unchanged
      verifyNoMoreInteractions(mockAssetRepository);
      verifyNoMoreInteractions(mockTransactionRepository);
    });
  });
}