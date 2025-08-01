import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/core/error/failures.dart';
import 'package:quan_ly_tai_san/core/usecases/usecase.dart';
import 'package:quan_ly_tai_san/features/auth/domain/entities/user.dart';
import 'package:quan_ly_tai_san/features/auth/domain/repositories/auth_repository.dart';
import 'package:quan_ly_tai_san/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:quan_ly_tai_san/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:quan_ly_tai_san/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:quan_ly_tai_san/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:quan_ly_tai_san/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:quan_ly_tai_san/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:quan_ly_tai_san/features/auth/presentation/bloc/auth_event.dart';
import 'package:quan_ly_tai_san/features/auth/presentation/bloc/auth_state.dart';
import '../../../../helpers/test_helper.dart';

class MockSignInUseCase extends Mock implements SignInUseCase {}
class MockSignUpUseCase extends Mock implements SignUpUseCase {}
class MockSignOutUseCase extends Mock implements SignOutUseCase {}
class MockResetPasswordUseCase extends Mock implements ResetPasswordUseCase {}
class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValues();
  });
  late AuthBloc authBloc;
  late MockSignInUseCase mockSignInUseCase;
  late MockSignUpUseCase mockSignUpUseCase;
  late MockSignOutUseCase mockSignOutUseCase;
  late MockResetPasswordUseCase mockResetPasswordUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockSignInUseCase = MockSignInUseCase();
    mockSignUpUseCase = MockSignUpUseCase();
    mockSignOutUseCase = MockSignOutUseCase();
    mockResetPasswordUseCase = MockResetPasswordUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockAuthRepository = MockAuthRepository();

    // Mock the auth state changes stream
    when(() => mockAuthRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());

    authBloc = AuthBloc(
      signInUseCase: mockSignInUseCase,
      signUpUseCase: mockSignUpUseCase,
      signOutUseCase: mockSignOutUseCase,
      resetPasswordUseCase: mockResetPasswordUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  final tUser = User(
    id: 'test-id',
    email: tEmail,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  group('AuthBloc', () {
    test('initial state should be AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });

    group('AuthSignInRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthAuthenticated] when sign in is successful',
        build: () {
          when(() => mockSignInUseCase(any()))
              .thenAnswer((_) async => Right(tUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignInRequested(
          email: tEmail,
          password: tPassword,
        )),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(user: tUser),
        ],
        verify: (_) {
          verify(() => mockSignInUseCase(const SignInParams(
            email: tEmail,
            password: tPassword,
          ))).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when sign in fails',
        build: () {
          when(() => mockSignInUseCase(any()))
              .thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignInRequested(
          email: tEmail,
          password: tPassword,
        )),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Invalid credentials'),
        ],
        verify: (_) {
          verify(() => mockSignInUseCase(const SignInParams(
            email: tEmail,
            password: tPassword,
          ))).called(1);
        },
      );
    });

    group('AuthSignUpRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthAuthenticated] when sign up is successful',
        build: () {
          when(() => mockSignUpUseCase(any()))
              .thenAnswer((_) async => Right(tUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignUpRequested(
          email: tEmail,
          password: tPassword,
        )),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(user: tUser),
        ],
        verify: (_) {
          verify(() => mockSignUpUseCase(const SignUpParams(
            email: tEmail,
            password: tPassword,
          ))).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when sign up fails',
        build: () {
          when(() => mockSignUpUseCase(any()))
              .thenAnswer((_) async => const Left(AuthFailure('Email already in use')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignUpRequested(
          email: tEmail,
          password: tPassword,
        )),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Email already in use'),
        ],
        verify: (_) {
          verify(() => mockSignUpUseCase(const SignUpParams(
            email: tEmail,
            password: tPassword,
          ))).called(1);
        },
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthUnauthenticated] when sign out is successful',
        build: () {
          when(() => mockSignOutUseCase(any()))
              .thenAnswer((_) async => const Right(null));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
        verify: (_) {
          verify(() => mockSignOutUseCase(NoParams())).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when sign out fails',
        build: () {
          when(() => mockSignOutUseCase(any()))
              .thenAnswer((_) async => const Left(AuthFailure('Sign out failed')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthSignOutRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'Sign out failed'),
        ],
        verify: (_) {
          verify(() => mockSignOutUseCase(NoParams())).called(1);
        },
      );
    });

    group('AuthResetPasswordRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthPasswordResetSent] when reset password is successful',
        build: () {
          when(() => mockResetPasswordUseCase(any()))
              .thenAnswer((_) async => const Right(null));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthResetPasswordRequested(email: tEmail)),
        expect: () => [
          const AuthLoading(),
          const AuthPasswordResetSent(email: tEmail),
        ],
        verify: (_) {
          verify(() => mockResetPasswordUseCase(const ResetPasswordParams(email: tEmail))).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthError] when reset password fails',
        build: () {
          when(() => mockResetPasswordUseCase(any()))
              .thenAnswer((_) async => const Left(AuthFailure('User not found')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthResetPasswordRequested(email: tEmail)),
        expect: () => [
          const AuthLoading(),
          const AuthError(message: 'User not found'),
        ],
        verify: (_) {
          verify(() => mockResetPasswordUseCase(const ResetPasswordParams(email: tEmail))).called(1);
        },
      );
    });

    group('AuthCheckRequested', () {
      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthAuthenticated] when user is authenticated',
        build: () {
          when(() => mockGetCurrentUserUseCase(any()))
              .thenAnswer((_) async => Right(tUser));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthLoading(),
          AuthAuthenticated(user: tUser),
        ],
        verify: (_) {
          verify(() => mockGetCurrentUserUseCase(NoParams())).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthUnauthenticated] when user is not authenticated',
        build: () {
          when(() => mockGetCurrentUserUseCase(any()))
              .thenAnswer((_) async => const Right(null));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
        verify: (_) {
          verify(() => mockGetCurrentUserUseCase(NoParams())).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'should emit [AuthLoading, AuthUnauthenticated] when get current user fails',
        build: () {
          when(() => mockGetCurrentUserUseCase(any()))
              .thenAnswer((_) async => const Left(AuthFailure('Authentication failed')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const AuthCheckRequested()),
        expect: () => [
          const AuthLoading(),
          const AuthUnauthenticated(),
        ],
        verify: (_) {
          verify(() => mockGetCurrentUserUseCase(NoParams())).called(1);
        },
      );
    });

    group('AuthStateChanged', () {
      blocTest<AuthBloc, AuthState>(
        'should emit AuthAuthenticated when user is not null',
        build: () => authBloc,
        act: (bloc) => bloc.add(AuthStateChanged(tUser)),
        expect: () => [
          AuthAuthenticated(user: tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'should emit AuthUnauthenticated when user is null',
        build: () => authBloc,
        act: (bloc) => bloc.add(const AuthStateChanged(null)),
        expect: () => [
          const AuthUnauthenticated(),
        ],
      );
    });
  });
}