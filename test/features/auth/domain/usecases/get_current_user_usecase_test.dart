import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/core/error/failures.dart';
import 'package:quan_ly_tai_san/core/usecases/usecase.dart';
import 'package:quan_ly_tai_san/features/auth/domain/entities/user.dart';
import 'package:quan_ly_tai_san/features/auth/domain/repositories/auth_repository.dart';
import 'package:quan_ly_tai_san/features/auth/domain/usecases/get_current_user_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetCurrentUserUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = GetCurrentUserUseCase(mockAuthRepository);
  });

  final tUser = User(
    id: 'test-id',
    email: 'test@example.com',
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('GetCurrentUserUseCase', () {
    test('should get current user from the repository', () async {
      // arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => Right(tUser));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, Right(tUser));
      verify(() => mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return null when no user is authenticated', () async {
      // arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Right(null));
      verify(() => mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return AuthFailure when repository fails', () async {
      // arrange
      const tFailure = AuthFailure('Authentication failed');
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.getCurrentUser());
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}