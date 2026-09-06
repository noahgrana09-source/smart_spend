import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/resend_email_verification_usecase.dart';

import '../auth_domain_mocks.dart';

void main() {
  late ResendEmailVerificationUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = ResendEmailVerificationUseCase(mockRepository);
  });

  group('ResendEmailVerificationUseCase', () {
    test('should return Right(unit) when the repository succeeds', () async {
      when(
        () => mockRepository.resendEmailVerification(),
      ).thenAnswer((_) async => const Right(unit));

      final result = await useCase(const NoParams());

      expect(result, const Right(unit));
      verify(() => mockRepository.resendEmailVerification()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return the Failure from the repository unchanged', () async {
      const failure = ServerFailure(
        code: 'too-many-requests',
        message: 'Try again later',
      );
      when(
        () => mockRepository.resendEmailVerification(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(const NoParams());

      expect(result, const Left(failure));
      verify(() => mockRepository.resendEmailVerification()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
