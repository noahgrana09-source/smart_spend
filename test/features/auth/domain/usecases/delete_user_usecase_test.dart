import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/features/auth/domain/usecases/delete_user_usecase.dart';

import '../auth_domain_mocks.dart';

void main() {
  late DeleteUserUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = DeleteUserUseCase(mockRepository);
  });

  group('DeleteUserUseCase', () {
    test('should return Right(unit) when the repository succeeds', () async {
      when(
        () => mockRepository.deleteUser(),
      ).thenAnswer((_) async => const Right(unit));

      final result = await useCase(const NoParams());

      expect(result, const Right(unit));
      verify(() => mockRepository.deleteUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return the Failure from the repository unchanged', () async {
      const failure = ServerFailure(
        code: 'requires-recent-login',
        message: 'Please sign in again',
      );
      when(
        () => mockRepository.deleteUser(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(const NoParams());

      expect(result, const Left(failure));
      verify(() => mockRepository.deleteUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
