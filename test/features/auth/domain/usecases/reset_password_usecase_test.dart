import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/core/error/failures.dart';
import 'package:quan_ly_tai_san/features/auth/domain/repositories/auth_repository.dart';
import 'package:quan_ly_tai_san/features/auth/domain/usecases/reset_password_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late ResetPasswordUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = ResetPasswordUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';

  group('ResetPasswordUseCase', () {
    test('should reset password successfully', () async {
      // arrange
      when(() => mockAuthRepository.resetPassword(email: any(named: 'email')))
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(const ResetPasswordParams(email: tEmail));

      // assert
      expect(result, const Right(null));
      verify(() => mockAuthRepository.resetPassword(email: tEmail));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return AuthFailure when email is not found', () async {
      // arrange
      const tFailure = AuthFailure('User not found');
      when(() => mockAuthRepository.resetPassword(email: any(named: 'email')))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const ResetPasswordParams(email: tEmail));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.resetPassword(email: tEmail));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return ValidationFailure when email is invalid', () async {
      // arrange
      const tFailure = ValidationFailure('Invalid email format');
      const tInvalidEmail = 'invalid-email';
      when(() => mockAuthRepository.resetPassword(email: any(named: 'email')))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const ResetPasswordParams(email: tInvalidEmail));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.resetPassword(email: tInvalidEmail));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockAuthRepository.resetPassword(email: any(named: 'email')))
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const ResetPasswordParams(email: tEmail));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.resetPassword(email: tEmail));
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}