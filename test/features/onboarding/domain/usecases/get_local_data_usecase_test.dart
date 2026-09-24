import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/entities/onb_data_entity.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/core/usecases/usecase.dart';
import 'package:smart_spend/features/onboarding/domain/usecases/get_local_data_usecase.dart';

import '../onb_domain_mocks.dart';

void main() {
  late GetLocalDataUseCase useCase;
  late MockOnbRepository mockRepository;

  setUp(() {
    mockRepository = MockOnbRepository();
    useCase = GetLocalDataUseCase(mockRepository);
  });

  const tEntity = OnbDataEntity(
    nationality: 'Argentina',
    investorProfile: 'moderate',
  );

  group('GetLocalDataUseCase', () {
    test('should return OnbDataEntity when a local row exists', () async {
      when(
        () => mockRepository.getLocalData(),
      ).thenAnswer((_) async => const Right(tEntity));

      final result = await useCase(const NoParams());

      expect(result, const Right(tEntity));
      verify(() => mockRepository.getLocalData()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return null (not a Failure) when there is no local row', () async {
      when(
        () => mockRepository.getLocalData(),
      ).thenAnswer((_) async => const Right(null));

      final result = await useCase(const NoParams());

      expect(result, const Right<Failure, OnbDataEntity?>(null));
    });

    test('should return the Failure from the repository unchanged', () async {
      const failure = DatabaseFailure(code: 'unknown-error', message: 'oops');
      when(
        () => mockRepository.getLocalData(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(const NoParams());

      expect(result, const Left(failure));
      verify(() => mockRepository.getLocalData()).called(1);
    });
  });
}
