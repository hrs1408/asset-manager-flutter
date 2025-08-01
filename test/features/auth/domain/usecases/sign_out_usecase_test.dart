import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quan_ly_tai_san/core/error/failures.dart';
import 'package:quan_ly_tai_san/core/usecases/usecase.dart';
import 'package:quan_ly_tai_san/features/auth/domain/repositories/auth_repository.dart';
import 'package:quan_ly_tai_san/features/auth/domain/usecases/sign_out_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late SignOutUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignOutUseCase(mockAuthRepository);
  });

  group('SignOutUseCase', () {
    test('should sign out user successfully', () async {
      // arrange
      when(() => mockAuthRepository.signOut())
          .thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Right(null));
      verify(() => mockAuthRepository.signOut());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return AuthFailure when sign out fails', () async {
      // arrange
      const tFailure = AuthFailure('Sign out failed');
      when(() => mockAuthRepository.signOut())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.signOut());
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return NetworkFailure when there is no internet connection', () async {
      // arrange
      const tFailure = NetworkFailure('No internet connection');
      when(() => mockAuthRepository.signOut())
          .thenAnswer((_) async => const Left(tFailure));

      // act
      final result = await usecase(NoParams());

      // assert
      expect(result, const Left(tFailure));
      verify(() => mockAuthRepository.signOut());
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}