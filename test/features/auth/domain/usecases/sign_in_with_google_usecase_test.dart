import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/features/auth/domain/entities/user_entity.dart';
import 'package:smart_spend/features/auth/domain/usecases/sign_in_with_google_usecase.dart';

import '../auth_domain_mocks.dart';

void main() {
  late SignInWithGoogleUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithGoogleUseCase(mockRepository);
  });

  final tUser = UserEntity(
    uid: '123',
    email: 'test@example.com',
    displayName: 'Test User',
    photoUrl: 'https://photo.url',
    isEmailVerified: true,
    createdAt: DateTime(2024, 1, 1),
  );

  group('SignInWithGoogleUseCase', () {
    test('should return UserEntity when sign in is successful', () async {
      when(
        () => mockRepository.signInWithGoogle(),
      ).thenAnswer((_) async => Right(tUser));

      final result = await useCase(const NoParams());

      expect(result, Right(tUser));
      verify(() => mockRepository.signInWithGoogle()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return the Failure from the repository unchanged', () async {
      const failure = GoogleSignInFailure(
        code: 'canceled',
        message: 'Sign in cancelled',
      );
      when(
        () => mockRepository.signInWithGoogle(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(const NoParams());

      expect(result, const Left(failure));
      verify(() => mockRepository.signInWithGoogle()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
