import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/core/error/failures.dart';
import 'package:quan_ly_tai_san/features/expenses/domain/entities/expense_category.dart';
import 'package:quan_ly_tai_san/features/expenses/domain/repositories/category_repository.dart';
import 'package:quan_ly_tai_san/features/expenses/domain/usecases/get_categories_usecase.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late GetCategoriesUseCase usecase;
  late MockCategoryRepository mockCategoryRepository;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    usecase = GetCategoriesUseCase(mockCategoryRepository);
  });

  const tUserId = 'test-user-id';
  final tDateTime = DateTime(2024, 1, 1);
  
  final tCategories = [
    ExpenseCategory(
      id: '1',
      userId: tUserId,
      name: 'Ăn uống',
      description: 'Chi phí ăn uống hàng ngày',
      icon: '🍽️',
      isDefault: true,
      createdAt: tDateTime,
      updatedAt: tDateTime,
    ),
    ExpenseCategory(
      id: '2',
      userId: tUserId,
      name: 'Giáo dục',
      description: 'Chi phí học tập, sách vở',
      icon: '📚',
      isDefault: true,
      createdAt: tDateTime,
      updatedAt: tDateTime,
    ),
    ExpenseCategory(
      id: '3',
      userId: tUserId,
      name: 'Danh mục tùy chỉnh',
      description: 'Danh mục do người dùng tạo',
      icon: '📝',
      isDefault: false,
      createdAt: tDateTime,
      updatedAt: tDateTime,
    ),
  ];

  group('GetCategoriesUseCase', () {
    test('should get categories from the repository', () async {
      // arrange
      when(() => mockCategoryRepository.getCategories(any()))
          .thenAnswer((_) async => Right(tCategories));

      // act
      final result = await usecase(tUserId);

      // assert
      expect(result, Right(tCategories));
      verify(() => mockCategoryRepository.getCategories(tUserId));
      verifyNoMoreInteractions(mockCategoryRepository);
    });

    test('should return empty list when no categories found', () async {
      // arrange
      when(() => mockCategoryRepository.getCategories(any()))
          .thenAnswer((_) async => Right(<ExpenseCategory>[]));

      // act
      final result = await usecase(tUserId);

      // assert
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (categories) => expect(categories, isEmpty),
      );
      verify(() => mockCategoryRepository.getCategories(tUserId));
      verifyNoMoreInteractions(mockCategoryRepository);
    });

    test('should return ServerFailure when repository fails', () async {
      // arrange
      const tFailure = ServerFailure('Server error');
      when(() => mockCategoryRepository.getCategories(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tUserId);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockCategoryRepository.getCategories(tUserId));
      verifyNoMoreInteractions(mockCategoryRepository);
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockCategoryRepository.getCategories(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tUserId);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockCategoryRepository.getCategories(tUserId));
      verifyNoMoreInteractions(mockCategoryRepository);
    });

    test('should return AuthFailure when user is not authenticated', () async {
      // arrange
      const tFailure = AuthFailure('User not authenticated');
      when(() => mockCategoryRepository.getCategories(any()))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(tUserId);

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockCategoryRepository.getCategories(tUserId));
      verifyNoMoreInteractions(mockCategoryRepository);
    });
  });
}