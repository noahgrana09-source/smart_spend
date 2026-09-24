import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smart_spend/core/entities/onb_data_entity.dart';
import 'package:smart_spend/core/error/failures.dart';
import 'package:smart_spend/features/onboarding/domain/usecases/save_data_usecase.dart';

import '../onb_domain_mocks.dart';

void main() {
  late SaveDataUseCase useCase;
  late MockOnbRepository mockRepository;

  setUp(() {
    mockRepository = MockOnbRepository();
    useCase = SaveDataUseCase(mockRepository);
  });

  const tEntity = OnbDataEntity(
    nationality: 'Argentina',
    investorProfile: 'Moderate',
  );

  const tParams = SaveDataParams(
    nationality: 'Argentina',
    investorProfile: 'Moderate',
  );

  group('SaveDataUseCase', () {
    test('should return OnbDataEntity when saving is successful', () async {
      when(
        () => mockRepository.saveData(
          nationality: any(named: 'nationality'),
          investorProfile: any(named: 'investorProfile'),
        ),
      ).thenAnswer((_) async => const Right(tEntity));

      final result = await useCase(tParams);

      expect(result, const Right(tEntity));
      verify(
        () => mockRepository.saveData(
          nationality: 'Argentina',
          investorProfile: 'Moderate',
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return the Failure from the repository unchanged', () async {
      const failure = DatabaseFailure(
        code: 'no-current-user',
        message: 'No signed-in user to save onboarding data for',
      );
      when(
        () => mockRepository.saveData(
          nationality: any(named: 'nationality'),
          investorProfile: any(named: 'investorProfile'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await useCase(tParams);

      expect(result, const Left(failure));
      verify(
        () => mockRepository.saveData(
          nationality: 'Argentina',
          investorProfile: 'Moderate',
        ),
      ).called(1);
    });
  });
}
