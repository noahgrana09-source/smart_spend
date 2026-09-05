import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/features/auth/domain/entities/user_entity.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_up_with_email_usecase.dart';

import '../auth_domain_mocks.dart';

void main() {
  late SignUpWithEmailUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignUpWithEmailUseCase(mockRepository);
  });

  final tUser = UserEntity(
    uid: '456',
    email: 'new@example.com',
    displayName: 'New User',
    isEmailVerified: false,
    createdAt: DateTime(2024, 1, 1),
  );

  const tParams = SignUpWithEmailParams(
    email: 'new@example.com',
    password: 'securePass1',
    name: 'New User',
  );

  group('SignUpWithEmailUseCase', () {
    test('should return UserEntity when sign up is successful', () async {
      when(
        () => mockRepository.signUpWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => Right(tUser));

      final result = await useCase(tParams);

      expect(result, Right(tUser));
      verify(
        () => mockRepository.signUpWithEmailAndPassword(
          email: 'new@example.com',
          password: 'securePass1',
          name: 'New User',
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return the Failure from the repository unchanged', () async {
      const failure = AuthFailure(
        code: 'email-already-in-use',
        message: 'Email already in use',
      );
      when(
        () => mockRepository.signUpWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(tParams);

      expect(result, const Left(failure));
      verify(
        () => mockRepository.signUpWithEmailAndPassword(
          email: 'new@example.com',
          password: 'securePass1',
          name: 'New User',
        ),
      ).called(1);
    });
  });

  group('SignUpWithEmailParams', () {
    test('should support equality', () {
      const params1 = SignUpWithEmailParams(
        email: 'new@example.com',
        password: 'securePass1',
        name: 'New User',
      );
      const params2 = SignUpWithEmailParams(
        email: 'new@example.com',
        password: 'securePass1',
        name: 'New User',
      );
      expect(params1, equals(params2));
    });

    test('should not be equal with different values', () {
      const params1 = SignUpWithEmailParams(
        email: 'new@example.com',
        password: 'securePass1',
        name: 'New User',
      );
      const params2 = SignUpWithEmailParams(
        email: 'new@example.com',
        password: 'differentPass',
        name: 'New User',
      );
      expect(params1, isNot(equals(params2)));
    });
  });
}
