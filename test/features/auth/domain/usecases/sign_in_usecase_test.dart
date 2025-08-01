import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/core/error/failures.dart';
import 'package:quan_ly_tai_san/features/auth/domain/entities/user.dart';
import 'package:quan_ly_tai_san/features/auth/domain/repositories/auth_repository.dart';
import 'package:quan_ly_tai_san/features/auth/domain/usecases/sign_in_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignInUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignInUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  final tUser = User(
    id: 'test-id',
    email: tEmail,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('SignInUseCase', () {
    test('should sign in user with valid credentials', () async {
      // arrange
      when(() => mockAuthRepository.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(tUser));

      // act
      final result = await usecase(const SignInParams(
        email: tEmail,
        password: tPassword,
      ));

      // assert
      expect(result, Right(tUser));
      verify(() => mockAuthRepository.signInWithEmailPassword(
            email: tEmail,
            password: tPassword,
          ));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return AuthFailure when credentials are invalid', () async {
      // arrange
      const tFailure = AuthFailure('Invalid credentials');
      when(() => mockAuthRepository.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const SignInParams(
        email: tEmail,
        password: tPassword,
      ));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.signInWithEmailPassword(
            email: tEmail,
            password: tPassword,
          ));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockAuthRepository.signInWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(const SignInParams(
        email: tEmail,
        password: tPassword,
      ));

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.signInWithEmailPassword(
            email: tEmail,
            password: tPassword,
          ));
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}