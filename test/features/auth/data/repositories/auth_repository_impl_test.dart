import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/core/error/exceptions.dart';
import 'package:quan_ly_tai_san/core/error/failures.dart';
import 'package:quan_ly_tai_san/features/auth/data/datasources/auth_service.dart';
import 'package:quan_ly_tai_san/features/auth/data/models/user_model.dart';
import 'package:quan_ly_tai_san/features/auth/data/repositories/auth_repository_impl.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    repository = AuthRepositoryImpl(authService: mockAuthService);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  final tDateTime = DateTime(2024, 1, 1);
  final tUserModel = UserModel(
    id: 'test-id',
    email: tEmail,
    displayName: 'Test User',
    createdAt: tDateTime,
    updatedAt: tDateTime,
  );

  group('AuthRepositoryImpl', () {
    group('signInWithEmailPassword', () {
      test('should return User when sign in is successful', () async {
        // arrange
        when(() => mockAuthService.signInWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => tUserModel);

        // act
        final result = await repository.signInWithEmailPassword(
          email: tEmail,
          password: tPassword,
        );

        // assert
        expect(result, Right(tUserModel));
        verify(() => mockAuthService.signInWithEmailPassword(
              email: tEmail,
              password: tPassword,
            ));
        verifyNoMoreInteractions(mockAuthService);
      });

      test('should return AuthFailure when AuthException is thrown', () async {
        // arrange
        when(() => mockAuthService.signInWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(const AuthException('Invalid credentials'));

        // act
        final result = await repository.signInWithEmailPassword(
          email: tEmail,
          password: tPassword,
        );

        // assert
        expect(result, const Left(AuthFailure('Invalid credentials')));
        verify(() => mockAuthService.signInWithEmailPassword(
              email: tEmail,
              password: tPassword,
            ));
        verifyNoMoreInteractions(mockAuthService);
      });

      test('should return NetworkFailure when NetworkException is thrown', () async {
        // arrange
        when(() => mockAuthService.signInWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(const NetworkException('No internet connection'));

        // act
        final result = await repository.signInWithEmailPassword(
          email: tEmail,
          password: tPassword,
        );

        // assert
        expect(result, const Left(NetworkFailure('No internet connection')));
        verify(() => mockAuthService.signInWithEmailPassword(
              email: tEmail,
              password: tPassword,
            ));
        verifyNoMoreInteractions(mockAuthService);
      });

      test('should return AuthFailure when unexpected exception is thrown', () async {
        // arrange
        when(() => mockAuthService.signInWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('Unexpected error'));

        // act
        final result = await repository.signInWithEmailPassword(
          email: tEmail,
          password: tPassword,
        );

        // assert
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('Lỗi không xác định'));
          },
          (_) => fail('Expected Left but got Right'),
        );
        verify(() => mockAuthService.signInWithEmailPassword(
              email: tEmail,
              password: tPassword,
            ));
        verifyNoMoreInteractions(mockAuthService);
      });
    });

    group('signUpWithEmailPassword', () {
      test('should return User when sign up is successful', () async {
        // arrange
        when(() => mockAuthService.signUpWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => tUserModel);

        // act
        final result = await repository.signUpWithEmailPassword(
          email: tEmail,
          password: tPassword,
        );

        // assert
        expect(result, Right(tUserModel));
        verify(() => mockAuthService.signUpWithEmailPassword(
              email: tEmail,
              password: tPassword,
            ));
        verifyNoMoreInteractions(mockAuthService);
      });

      test('should return AuthFailure when AuthException is thrown', () async {
        // arrange
        when(() => mockAuthService.signUpWithEmailPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(const AuthException('Email already in use'));

        // act
        final result = await repository.signUpWithEmailPassword(
          email: tEmail,
          password: tPassword,
        );

        // assert
        expect(result, const Left(AuthFailure('Email already in use')));
        verify(() => mockAuthService.signUpWithEmailPassword(
              email: tEmail,
              password: tPassword,
            ));
        verifyNoMoreInteractions(mockAuthService);
      });
    });

    group('signOut', () {
      test('should return void when sign out is successful', () async {
        // arrange
        when(() => mockAuthService.signOut()).thenAnswer((_) async {});

        // act
        final result = await repository.signOut();

        // assert
        expect(result, const Right(null));
        verify(() => mockAuthService.signOut());
        verifyNoMoreInteractions(mockAuthService);
      });

      test('should return AuthFailure when AuthException is thrown', () async {
        // arrange
        when(() => mockAuthService.signOut())
            .thenThrow(const AuthException('Sign out failed'));

        // act
        final result = await repository.signOut();

        // assert
        expect(result, const Left(AuthFailure('Sign out failed')));
        verify(() => mockAuthService.signOut());
        verifyNoMoreInteractions(mockAuthService);
      });

      test('should return AuthFailure when unexpected exception is thrown', () async {
        // arrange
        when(() => mockAuthService.signOut())
            .thenThrow(Exception('Unexpected error'));

        // act
        final result = await repository.signOut();

        // assert
        result.fold(
          (failure) {
            expect(failure, isA<AuthFailure>());
            expect(failure.message, contains('Lỗi đăng xuất'));
          },
          (_) => fail('Expected Left but got Right'),
        );
        verify(() => mockAuthService.signOut());
        verifyNoMoreInteractions(mockAuthService);
      });
    });

    group('resetPassword', () {
      test('should return void when reset password is successful', () async {
        // arrange
        when(() => mockAuthService.resetPassword(email: any(named: 'email')))
            .thenAnswer((_) async {});

        // act
        final result = await repository.resetPassword(email: tEmail);

        // assert
        expect(result, const Right(null));
        verify(() => mockAuthService.resetPassword(email: tEmail));
        verifyNoMoreInteractions(mockAuthService);
      });

      test('should return AuthFailure when AuthException is thrown', () async {
        // arrange
        when(() => mockAuthService.resetPassword(email: any(named: 'email')))
            .thenThrow(const AuthException('User not found'));

        // act
        final result = await repository.resetPassword(email: tEmail);

        // assert
        expect(result, const Left(AuthFailure('User not found')));
        verify(() => mockAuthService.resetPassword(email: tEmail));
        verifyNoMoreInteractions(mockAuthService);
      });

      test('should return NetworkFailure when NetworkException is thrown', () async {
        // arrange
        when(() => mockAuthService.resetPassword(email: any(named: 'email')))
            .thenThrow(const NetworkException('No internet connection'));

        // act
        final result = await repository.resetPassword(email: tEmail);

        // assert
        expect(result, const Left(NetworkFailure('No internet connection')));
        verify(() => mockAuthService.resetPassword(email: tEmail));
        verifyNoMoreInteractions(mockAuthService);
      });
    });

    group('getCurrentUser', () {
      test('should return User when user is authenticated', () async {
        // arrange
        when(() => mockAuthService.getCurrentUser())
            .thenAnswer((_) async => tUserModel);

        // act
        final result = await repository.getCurrentUser();

        // assert
        expect(result, Right(tUserModel));
        verify(() => mockAuthService.getCurrentUser());
        verifyNoMoreInteractions(mockAuthService);
      });

      test('should return null when user is not authenticated', () async {
        // arrange
        when(() => mockAuthService.getCurrentUser())
            .thenAnswer((_) async => null);

        // act
        final result = await repository.getCurrentUser();

        // assert
        expect(result, const Right(null));
        verify(() => mockAuthService.getCurrentUser());
        verifyNoMoreInteractions(mockAuthService);
      });

      test('should return AuthFailure when AuthException is thrown', () async {
        // arrange
        when(() => mockAuthService.getCurrentUser())
            .thenThrow(const AuthException('Authentication failed'));

        // act
        final result = await repository.getCurrentUser();

        // assert
        expect(result, const Left(AuthFailure('Authentication failed')));
        verify(() => mockAuthService.getCurrentUser());
        verifyNoMoreInteractions(mockAuthService);
      });
    });

    group('authStateChanges', () {
      test('should return stream of User from auth service', () async {
        // arrange
        final userStream = Stream.value(tUserModel);
        when(() => mockAuthService.authStateChanges).thenAnswer((_) => userStream);

        // act
        final result = repository.authStateChanges;

        // assert
        expect(result, userStream);
        verify(() => mockAuthService.authStateChanges);
        verifyNoMoreInteractions(mockAuthService);
      });
    });
  });
}