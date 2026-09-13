import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/check_email_verified_usecase.dart';

import '../auth_domain_mocks.dart';

void main() {
  late CheckEmailVerifiedUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = CheckEmailVerifiedUseCase(mockRepository);
  });

  group('CheckEmailVerifiedUseCase', () {
    test('should return Right(true) when the email is verified', () async {
      when(
        () => mockRepository.checkEmailVerified(),
      ).thenAnswer((_) async => const Right(true));

      final result = await useCase(const NoParams());

      expect(result, const Right(true));
      verify(() => mockRepository.checkEmailVerified()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return Right(false) when the email is not verified yet',
      () async {
        when(
          () => mockRepository.checkEmailVerified(),
        ).thenAnswer((_) async => const Right(false));

        final result = await useCase(const NoParams());

        expect(result, const Right(false));
      },
    );

    test('should return the Failure from the repository unchanged', () async {
      const failure = ServerFailure(
        code: 'no-current-user',
        message: 'No signed-in user',
      );
      when(
        () => mockRepository.checkEmailVerified(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(const NoParams());

      expect(result, const Left(failure));
      verify(() => mockRepository.checkEmailVerified()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
