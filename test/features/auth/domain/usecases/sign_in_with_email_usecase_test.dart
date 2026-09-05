import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/features/auth/domain/entities/user_entity.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_in_with_email_usecase.dart';

import '../auth_domain_mocks.dart';

void main() {
  late SignInWithEmailUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithEmailUseCase(mockRepository);
  });

  final tUser = UserEntity(
    uid: '123',
    email: 'test@example.com',
    displayName: 'Test User',
    isEmailVerified: false,
    createdAt: DateTime(2024, 1, 1),
  );

  const tParams = SignInWithEmailParams(
    email: 'test@example.com',
    password: 'password123',
  );

  group('SignInWithEmailUseCase', () {
    test('should return UserEntity when sign in is successful', () async {
      when(
        () => mockRepository.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Right(tUser));

      final result = await useCase(tParams);

      expect(result, Right(tUser));
      verify(
        () => mockRepository.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return the Failure from the repository unchanged', () async {
      const failure = AuthFailure(
        code: 'wrong-password',
        message: 'Wrong password',
      );
      when(
        () => mockRepository.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(tParams);

      expect(result, const Left(failure));
      verify(
        () => mockRepository.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });
  });

  group('SignInWithEmailParams', () {
    test('should support equality', () {
      const params1 = SignInWithEmailParams(
        email: 'test@example.com',
        password: 'password123',
      );
      const params2 = SignInWithEmailParams(
        email: 'test@example.com',
        password: 'password123',
      );
      expect(params1, equals(params2));
    });

    test('should not be equal with different values', () {
      const params1 = SignInWithEmailParams(
        email: 'test@example.com',
        password: 'password123',
      );
      const params2 = SignInWithEmailParams(
        email: 'other@example.com',
        password: 'password123',
      );
      expect(params1, isNot(equals(params2)));
    });
  });
}
