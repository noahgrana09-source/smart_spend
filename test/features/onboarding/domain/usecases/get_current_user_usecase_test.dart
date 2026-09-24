import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/entities/app_user_entity.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/features/onboarding/domain/usecases/get_current_user_usecase.dart';

import '../onb_domain_mocks.dart';

void main() {
  late GetCurrentUserUseCase useCase;
  late MockOnbRepository mockRepository;

  setUp(() {
    mockRepository = MockOnbRepository();
    useCase = GetCurrentUserUseCase(mockRepository);
  });

  const tEntity = AppUserEntity(
    email: 'noah@example.com',
    displayName: 'Noah',
  );

  group('GetCurrentUserUseCase', () {
    test('should return AppUserEntity when there is a signed-in user', () async {
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tEntity));

      final result = await useCase(const NoParams());

      expect(result, const Right(tEntity));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return the Failure from the repository unchanged', () async {
      const failure = AuthFailure(
        code: 'no-current-user',
        message: 'No signed-in user to get onboarding data for',
      );
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(const NoParams());

      expect(result, const Left(failure));
      verify(() => mockRepository.getCurrentUser()).called(1);
    });
  });
}
