import 'package:dartz/dartz.dart';

import '../../../../core/entities/onb_data_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/onb_repository.dart';

/// Use case for checking whether the signed-in user already has
/// onboarding data persisted on this device.
///
/// Delegates to [OnbRepository.getLocalData]. `null` (not a [Failure])
/// means no local row exists yet — used by `OnbWrapper` to decide
/// whether to skip straight to `AppState.onboarded()` or show
/// `GetYouStartedScreen`.
class GetLocalDataUseCase extends UseCase<OnbDataEntity?, NoParams> {
  /// The onboarding repository.
  final OnbRepository _repository;

  /// Creates a [GetLocalDataUseCase] with the given [repository].
  GetLocalDataUseCase(this._repository);

  @override
  Future<Either<Failure, OnbDataEntity?>> call(NoParams params) {
    return _repository.getLocalData();
  }
}
